-- ============================================================
--  Sleek Casting Bars — Particles_Earth.lua
--  Effets visuels pour l'école Earth :
--
--  · Rocks   (01-04, 64x64) — 4 cailloux qui orbitent autour
--              de la barre entière en tournant sur eux-mêmes.
--              Chacun sur sa propre ellipse, vitesse différente.
--
--  · Debris  (05-11, 32x32) — ~14 morceaux de terre en orbite
--              plus serrée et plus rapide, plus nombreux.
--
--  · Particules front — morceaux de terre (05-11) qui jaillissent
--              depuis le front de progression et retombent.
-- ============================================================

local FX = {}
SCB.FX        = SCB.FX or {}
SCB.FX["earth"] = FX

-- ============================================================
--  UTILITAIRES LOCAUX
-- ============================================================

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end

local function SetTextureRotation(tex, angle)
    local c, s = math.cos(angle), math.sin(angle)
    tex:SetTexCoord(
        0.5 + (-0.5)*c - (-0.5)*s,  0.5 + (-0.5)*s + (-0.5)*c,
        0.5 + (-0.5)*c - ( 0.5)*s,  0.5 + (-0.5)*s + ( 0.5)*c,
        0.5 + ( 0.5)*c - (-0.5)*s,  0.5 + ( 0.5)*s + (-0.5)*c,
        0.5 + ( 0.5)*c - ( 0.5)*s,  0.5 + ( 0.5)*s + ( 0.5)*c
    )
end

-- ============================================================
--  CONSTANTES ORBITE
-- ============================================================

-- Rochers : 4 instances, orbite elliptique large autour de la barre
local ROCK_COUNT        = 4
local ROCK_SIZE         = 28          -- taille affichée (px)
local ROCK_ORBIT_RX_MIN = 130
local ROCK_ORBIT_RX_MAX = 160
local ROCK_ORBIT_RY_MIN = 28          -- demi-axe Y (légèrement au-dessus/dessous)
local ROCK_ORBIT_RY_MAX = 42
local ROCK_SPEED_MIN    = 0.18        -- tours/seconde
local ROCK_SPEED_MAX    = 0.28
local ROCK_SELF_ROT     = 1.2         -- vitesse rotation propre (rad/s)
local ROCK_ALPHA        = 0.90

-- Débris : ~14 instances, orbite plus serrée et rapide
local DEBRIS_COUNT      = 14
local DEBRIS_SIZE_MIN   = 10
local DEBRIS_SIZE_MAX   = 18
local DEBRIS_ORBIT_RX_MIN = 100
local DEBRIS_ORBIT_RX_MAX = 135
local DEBRIS_ORBIT_RY_MIN = 18
local DEBRIS_ORBIT_RY_MAX = 36
local DEBRIS_SPEED_MIN  = 0.30
local DEBRIS_SPEED_MAX  = 0.55
local DEBRIS_SELF_ROT   = 2.5
local DEBRIS_ALPHA      = 0.75

-- ============================================================
--  CONSTANTES PARTICULES FRONT
-- ============================================================

local PART_COUNT      = 50
local PART_SPAWN_RATE = 0.035
local PART_STOP_AT    = 0.87
local PART_ALPHA      = 0.85

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local rocks    = {}
local debris   = {}
local parts    = {}
local spawnAcc = 0
local isActive = false

-- ============================================================
--  ORBITE — mise à jour commune rocks + debris
-- ============================================================

local function UpdateOrbit(obj, dt, cx, cy)
    obj.angle    = obj.angle    + obj.speed    * dt * math.pi * 2
    obj.selfAngle = obj.selfAngle + obj.selfRot * dt

    -- Position sur l'ellipse, centrée sur la barre
    local x = cx + math.cos(obj.angle) * obj.rx
    local y = cy + math.sin(obj.angle) * obj.ry

    -- Fade-in au départ
    if obj.fadeIn < 1 then
        obj.fadeIn = math.min(obj.fadeIn + dt / 1.0, 1)
        obj.tex:SetAlpha(obj.fadeIn * obj.maxAlpha)
    end

    obj.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    SetTextureRotation(obj.tex, obj.selfAngle)
end

-- ============================================================
--  PARTICULES FRONT
-- ============================================================

local function SpawnParticle(frontX, cy)
    for _, p in ipairs(parts) do
        if not p.active then
            local angle = rad(rand(50, 130))   -- éventail vers le haut
            local speed = rand(40, 110)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(0.4, 0.9)
            p.x       = frontX + rand(-3, 3)
            p.y       = cy + rand(-8, 8)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed

            local size = rand(6, 14)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            -- Rotation initiale aléatoire figée (pas d'animation de rotation sur les particules)
            p.tex:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
            p.tex:SetAlpha(PART_ALPHA)
            return
        end
    end
end

local function UpdateParticle(p, dt)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end

    -- Gravité assez forte : les morceaux retombent vite
    p.vy = p.vy - 120 * dt
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt

    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)

    -- Fade sur le dernier tiers de vie
    local alpha = t < 0.6 and 1 or math.max(0, (1 - t) / 0.4)
    p.tex:SetAlpha(alpha * PART_ALPHA)
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["earth"]
    if not school then return end

    local rockTex   = school.rocks
    local debrisTex = school.debris

    -- Rochers : créés sur le frameInner avec sublevel -8 → derrière le BG
    for i = 1, ROCK_COUNT do
        local tex = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
        tex:SetTexture(rockTex[((i - 1) % #rockTex) + 1])
        tex:SetBlendMode("BLEND")
        tex:SetSize(ROCK_SIZE, ROCK_SIZE)
        tex:SetAlpha(0)

        rocks[i] = {
            tex       = tex,
            angle     = (i - 1) * (math.pi * 2 / ROCK_COUNT),
            selfAngle = rand(0, math.pi * 2),
            speed     = rand(ROCK_SPEED_MIN, ROCK_SPEED_MAX) * (math.random(2) == 1 and 1 or -1),
            selfRot   = rand(ROCK_SELF_ROT * 0.5, ROCK_SELF_ROT) * (math.random(2) == 1 and 1 or -1),
            rx        = rand(ROCK_ORBIT_RX_MIN, ROCK_ORBIT_RX_MAX),
            ry        = rand(ROCK_ORBIT_RY_MIN, ROCK_ORBIT_RY_MAX),
            maxAlpha  = ROCK_ALPHA,
            fadeIn    = 0,
        }
    end

    -- Débris : même chose, sublevel -8
    for i = 1, DEBRIS_COUNT do
        local tex = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
        tex:SetTexture(debrisTex[((i - 1) % #debrisTex) + 1])
        tex:SetBlendMode("BLEND")
        local size = rand(DEBRIS_SIZE_MIN, DEBRIS_SIZE_MAX)
        tex:SetSize(size, size)
        tex:SetAlpha(0)

        debris[i] = {
            tex       = tex,
            angle     = (i - 1) * (math.pi * 2 / DEBRIS_COUNT) + math.pi / DEBRIS_COUNT,
            selfAngle = rand(0, math.pi * 2),
            speed     = rand(DEBRIS_SPEED_MIN, DEBRIS_SPEED_MAX) * (math.random(2) == 1 and 1 or -1),
            selfRot   = rand(DEBRIS_SELF_ROT * 0.5, DEBRIS_SELF_ROT) * (math.random(2) == 1 and 1 or -1),
            rx        = rand(DEBRIS_ORBIT_RX_MIN, DEBRIS_ORBIT_RX_MAX),
            ry        = rand(DEBRIS_ORBIT_RY_MIN, DEBRIS_ORBIT_RY_MAX),
            maxAlpha  = DEBRIS_ALPHA,
            fadeIn    = 0,
        }
    end

    -- Particules front : sur container (devant la barre)
    for i = 1, PART_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(debrisTex[((i - 1) % #debrisTex) + 1])
        tex:SetBlendMode("BLEND")
        tex:SetAlpha(0)

        parts[i] = {
            tex = tex, active = false,
            life = 0, maxLife = 0,
            x = 0, y = 0, vx = 0, vy = 0,
        }
    end
end

function FX.Start(duration)
    isActive = true
    spawnAcc = 0
    -- Réinitialise le fade-in des orbiteurs
    for _, r in ipairs(rocks)   do r.fadeIn = 0 ; r.tex:SetAlpha(0) end
    for _, d in ipairs(debris)  do d.fadeIn = 0 ; d.tex:SetAlpha(0) end
    for _, p in ipairs(parts)   do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive = false
    -- bgContainer n'est plus enfant du wrapper, fade manuel
    for _, r in ipairs(rocks)  do r.tex:SetAlpha(0) end
    for _, d in ipairs(debris) do d.tex:SetAlpha(0) end
    for _, p in ipairs(parts)  do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Reset()
    isActive = false
    for _, r in ipairs(rocks)  do r.tex:SetAlpha(0) ; r.fadeIn = 0 end
    for _, d in ipairs(debris) do d.tex:SetAlpha(0) ; d.fadeIn = 0 end
    for _, p in ipairs(parts)  do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    local f = SCB.Bar.frame
    local cx, barCY = f:GetCenter()
    if not cx then return end

    -- Orbite rochers
    for _, r in ipairs(rocks)  do UpdateOrbit(r, dt, cx, barCY) end
    -- Orbite débris
    for _, d in ipairs(debris) do UpdateOrbit(d, dt, cx, barCY) end

    -- Particules en vol continuent toujours
    for _, p in ipairs(parts)  do UpdateParticle(p, dt) end

    -- Spawn depuis le front (seulement si cast actif)
    if isActive and progress > 0.02 and progress < PART_STOP_AT then
        spawnAcc = spawnAcc + dt
        if spawnAcc >= PART_SPAWN_RATE then
            spawnAcc = 0
            local count = math.random(1, 3)
            for _ = 1, count do SpawnParticle(frontX, barCY) end
        end
    end
end
