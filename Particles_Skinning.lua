-- ============================================================
--  Opulent Casting Bars — Particles_Skinning.lua
--
--  Variante Skinning basée sur l'animation Mining :
--  des morceaux de fourrure (Misc_Skinning_01/02) jaillissent
--  autour du front de progression.
-- ============================================================

local FX = {}
SCB.FX              = SCB.FX or {}
SCB.FX["skinning"] = FX

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

local CHIP_COUNT        = 60
local CHIP_SPAWN_RATE   = 0.04
local CHIP_BURST_MIN    = 1
local CHIP_BURST_MAX    = 3
local CHIP_STOP_AT      = 0.92

local CHIP_SIZE_SMALL_MIN = 3
local CHIP_SIZE_SMALL_MAX = 7
local CHIP_SIZE_BIG_MIN   = 7
local CHIP_SIZE_BIG_MAX   = 13
local CHIP_BIG_CHANCE     = 0.25

local CHIP_SPEED_MIN    = 50
local CHIP_SPEED_MAX    = 140
local CHIP_GRAVITY      = 180
local CHIP_LIFE_MIN     = 0.35
local CHIP_LIFE_MAX     = 0.80
local CHIP_ALPHA        = 0.85
local CHIP_ROT_MIN      = 2.0
local CHIP_ROT_MAX      = 6.0

local CHIP_ANGLE_MIN    = math.rad(30)
local CHIP_ANGLE_MAX    = math.rad(150)

local FADE_DUR          = 0.40

local isActive   = false
local isFading   = false
local fadeT      = 0
local spawnAcc   = 0
local chips      = {}

local function SpawnChip(frontX, cy, barH)
    for _, p in ipairs(chips) do
        if not p.active then
            local angle = rand(CHIP_ANGLE_MIN, CHIP_ANGLE_MAX)
            local speed = rand(CHIP_SPEED_MIN, CHIP_SPEED_MAX)
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

    p.vy = p.vy - CHIP_GRAVITY * dt
    p.x  = p.x  + p.vx * dt
    p.y  = p.y  + p.vy * dt
    p.rot = p.rot + p.rotSpeed * dt

    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    SetTexRot(p.tex, p.rot)

    local env = t < 0.15 and t/0.15 or (t < 0.65 and 1 or math.max(0, (1-t)/0.35))
    p.tex:SetAlpha(env * CHIP_ALPHA * (gf or 1))
end

function FX.Init(container, bar)
    local school = SCB.Schools.data["skinning"]
    if not school then return end

    local furTex = school.misc or {}
    local nFur   = #furTex

    chips = {}
    for i = 1, CHIP_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nFur > 0 then
            tex:SetTexture(furTex[((i - 1) % nFur) + 1])
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

    if school.misc then
        for _, f in ipairs(school.misc) do
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

    for _, p in ipairs(chips) do UpdateChip(p, dt, 1) end

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
