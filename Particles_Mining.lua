-- ============================================================
--  Opulent Casting Bars — Particles_Mining.lua
--
--  Effet "coup de pioche" : des éclats de pierre (Stone_01-06)
--  jaillissent depuis le front de progression avec :
--    · un éventail de trajectoires (surtout vers le haut/avant)
--    · une rotation propre sur chaque fragment
--    · une gravité forte → retombée réaliste
--    · des fragments de tailles variées (petits débris + gros morceaux)
--
--  Pas d'orbite, pas d'ambient : tout se concentre sur le front.
-- ============================================================

local FX = {}
SCB.FX            = SCB.FX or {}
SCB.FX["mining"]  = FX

local function rand(a, b) return a + math.random() * (b - a) end
local pi2 = math.pi * 2

local function SetTexRot(tex, angle)
    local c, s = math.cos(angle), math.sin(angle)
    tex:SetTexCoord(
        0.5+(-0.5)*c-(-0.5)*s, 0.5+(-0.5)*s+(-0.5)*c,
        0.5+(-0.5)*c-( 0.5)*s, 0.5+(-0.5)*s+( 0.5)*c,
        0.5+( 0.5)*c-(-0.5)*s, 0.5+( 0.5)*s+(-0.5)*c,
        0.5+( 0.5)*c-( 0.5)*s, 0.5+( 0.5)*s+( 0.5)*c
    )
end

-- ============================================================
--  CONSTANTES
-- ============================================================

-- Éclats principaux : 60 particules, spawn en rafales irrégulières
local CHIP_COUNT        = 60
local CHIP_SPAWN_RATE   = 0.04     -- intervalle entre rafales (s)
local CHIP_BURST_MIN    = 1        -- fragments par rafale
local CHIP_BURST_MAX    = 3
local CHIP_STOP_AT      = 0.92     -- arrêt quand proche de la fin

-- Taille des éclats : deux populations (petits débris + gros morceaux)
local CHIP_SIZE_SMALL_MIN = 6
local CHIP_SIZE_SMALL_MAX = 14
local CHIP_SIZE_BIG_MIN   = 14
local CHIP_SIZE_BIG_MAX   = 26
local CHIP_BIG_CHANCE     = 0.25   -- 25% de gros fragments

-- Physique
local CHIP_SPEED_MIN    = 50
local CHIP_SPEED_MAX    = 140
local CHIP_GRAVITY      = 180      -- forte : les pierres retombent vite
local CHIP_LIFE_MIN     = 0.35
local CHIP_LIFE_MAX     = 0.80
local CHIP_ALPHA        = 0.92
local CHIP_ROT_MIN      = 2.0      -- rotation propre (rad/s)
local CHIP_ROT_MAX      = 6.0

-- Éventail : principalement vers le haut et vers l'avant
-- angle 0 = droite, 90 = haut — on veut 40°→140° (haut) + léger biais arrière
local CHIP_ANGLE_MIN    = math.rad(30)   -- 30° (légèrement avant-haut)
local CHIP_ANGLE_MAX    = math.rad(150)  -- 150° (légèrement arrière-haut)

-- Fade
local FADE_DUR          = 0.40

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local isActive   = false
local isFading   = false
local fadeT      = 0
local spawnAcc   = 0
local chips      = {}

-- ============================================================
--  SPAWN / UPDATE ÉCLAT
-- ============================================================

local function SpawnChip(frontX, cy, barH)
    for _, p in ipairs(chips) do
        if not p.active then
            local angle = rand(CHIP_ANGLE_MIN, CHIP_ANGLE_MAX)
            local speed = rand(CHIP_SPEED_MIN, CHIP_SPEED_MAX)

            -- Légère dispersion verticale au point de spawn
            local spread = math.min(barH * 0.35, 14)

            p.active   = true
            p.life     = 0
            p.maxLife  = rand(CHIP_LIFE_MIN, CHIP_LIFE_MAX)
            p.x        = frontX + rand(-4, 5)
            p.y        = cy + rand(-spread, spread)
            p.vx       = math.cos(angle) * speed
            p.vy       = math.sin(angle) * speed
            p.rot      = rand(0, pi2)
            p.rotSpeed = rand(CHIP_ROT_MIN, CHIP_ROT_MAX) * (math.random(2) == 1 and 1 or -1)

            -- Taille : petit ou gros selon la chance
            local size
            if math.random() < CHIP_BIG_CHANCE then
                size = rand(CHIP_SIZE_BIG_MIN, CHIP_SIZE_BIG_MAX)
            else
                size = rand(CHIP_SIZE_SMALL_MIN, CHIP_SIZE_SMALL_MAX)
            end
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateChip(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end

    -- Physique
    p.vy = p.vy - CHIP_GRAVITY * dt
    p.x  = p.x  + p.vx * dt
    p.y  = p.y  + p.vy * dt
    p.rot = p.rot + p.rotSpeed * dt

    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    SetTexRot(p.tex, p.rot)

    -- Fade : apparition rapide, disparition sur le dernier tiers
    local env = t < 0.15 and t/0.15 or (t < 0.65 and 1 or math.max(0, (1-t)/0.35))
    p.tex:SetAlpha(env * CHIP_ALPHA * (gf or 1))
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["mining"]
    if not school then return end

    local stoneTex = school.stones or {}
    local nStones  = #stoneTex

    chips = {}
    for i = 1, CHIP_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nStones > 0 then
            tex:SetTexture(stoneTex[((i - 1) % nStones) + 1])
        end
        tex:SetBlendMode("BLEND")
        tex:SetAlpha(0)
        chips[i] = {
            tex=tex, active=false,
            life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0,
            rot=0, rotSpeed=0,
        }
    end

    -- Préchargement GPU
    if school.stones then
        for _, f in ipairs(school.stones) do
            local preload = UIParent:CreateTexture(nil, "BACKGROUND")
            preload:SetTexture(f)
            preload:SetSize(1, 1)
            preload:SetAlpha(0.0001)
            preload:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
        end
    end
end

function FX.Start(duration)
    isActive = true
    isFading = false
    fadeT    = 0
    spawnAcc = 0
    for _, p in ipairs(chips) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive = false
    isFading = true
    fadeT    = 0
end

function FX.UpdateFade(dt)
    if not isFading then return end
    fadeT = fadeT + dt
    local gf = math.max(0, 1 - fadeT / FADE_DUR)
    for _, p in ipairs(chips) do UpdateChip(p, dt, gf) end
    if fadeT >= FADE_DUR then
        isFading = false
        for _, p in ipairs(chips) do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    isActive = false
    isFading = false
    for _, p in ipairs(chips) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    -- Mise à jour des éclats en vol
    for _, p in ipairs(chips) do UpdateChip(p, dt, 1) end

    -- Spawn en rafales irrégulières depuis le front
    if progress > 0.01 and progress < CHIP_STOP_AT then
        spawnAcc = spawnAcc + dt
        if spawnAcc >= CHIP_SPAWN_RATE then
            spawnAcc = 0
            local burst = math.random(CHIP_BURST_MIN, CHIP_BURST_MAX)
            for _ = 1, burst do
                SpawnChip(frontX, cy, barH)
            end
        end
    end
end
