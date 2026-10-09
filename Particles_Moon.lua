-- ============================================================
--  Opulent Casting Bars — Particles_Moon.lua
--
--  · Light_Moon  : suit la progression (Frame_Moon_Light masqué)
--  · Misc_Moon   : spawn sur le front ET autour de la barre
--  · Glow cyan   : particules fines sur le front
--
--  Même architecture que Particles_Holy, palette cyan fluo.
-- ============================================================

local FX = {}
SCB.FX         = SCB.FX or {}
SCB.FX["moon"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local pi2 = math.pi * 2

-- ============================================================
--  CONSTANTES
-- ============================================================

-- Cyan fluo : R=0  G=0.90  B=1.0
local MOON_R, MOON_G, MOON_B = 0.0, 0.90, 1.0

-- Misc front (sur le front de progression)
local MISC_FRONT_COUNT      = 80
local MISC_FRONT_SPAWN_RATE = 0.08
local MISC_FRONT_SIZE_MIN   = 4
local MISC_FRONT_SIZE_MAX   = 22
local MISC_FRONT_LIFE_MIN   = 0.4
local MISC_FRONT_LIFE_MAX   = 0.9
local MISC_FRONT_ALPHA      = 0.90
local MISC_FRONT_STOP_AT    = 0.90

-- Misc ambient (autour de la barre)
local MISC_AMB_COUNT        = 120
local MISC_AMB_SPAWN_RATE   = 0.12
local MISC_AMB_SIZE_MIN     = 3
local MISC_AMB_SIZE_MAX     = 20
local MISC_AMB_LIFE_MIN     = 0.6
local MISC_AMB_LIFE_MAX     = 1.4
local MISC_AMB_ALPHA        = 0.65
local MISC_AMB_SPREAD_X     = 5
local MISC_AMB_SPREAD_Y     = 5

-- Glow front
local GLOW_COUNT            = 50
local GLOW_SPAWN_RATE       = 0.02
local GLOW_STOP_AT          = 0.87
local GLOW_ALPHA            = 0.65
local GLOW_SIZE_MIN         = 4
local GLOW_SIZE_MAX         = 10
local GLOW_LIFE_MIN         = 0.25
local GLOW_LIFE_MAX         = 0.50

local FADE_DUR              = 0.50

-- ============================================================
--  ÉTAT
-- ============================================================

local isActive          = false
local isFading          = false
local fadeT             = 0
local miscFrontAcc      = 0
local miscAmbAcc        = 0
local glowSpawnAcc      = 0

local miscFrontParts    = {}
local miscAmbParts      = {}
local glowParts         = {}

-- ============================================================
--  MISC FRONT
-- ============================================================

local function SpawnMiscFront(frontX, cy, barH)
    for _, p in ipairs(miscFrontParts) do
        if not p.active then
            local spread = math.min(barH * 0.15, 6)
            p.active  = true ; p.life = 0
            p.maxLife = rand(MISC_FRONT_LIFE_MIN, MISC_FRONT_LIFE_MAX)
            p.x  = frontX + rand(-4, 6)
            p.y  = cy + rand(-spread, spread)
            p.vx = rand(-10, 10)
            p.vy = rand(-18, 4)
            p.phase = math.random() * pi2
            local sz = rand(MISC_FRONT_SIZE_MIN, MISC_FRONT_SIZE_MAX)
            p.tex:SetSize(sz, sz)
            p.tex:SetAlpha(0)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateMiscFront(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - 8 * dt
    p.x  = p.x + p.vx * dt + math.sin(p.life * 4 + p.phase) * 0.4
    p.y  = p.y + p.vy * dt
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t < 0.2 and t/0.2 or (t < 0.7 and 1 or (1-t)/0.3)
    p.tex:SetAlpha(math.max(0, env) * MISC_FRONT_ALPHA * (gf or 1))
end

-- ============================================================
--  MISC AMBIENT
-- ============================================================

local function SpawnMiscAmb(cx, cy, barW, barH)
    for _, p in ipairs(miscAmbParts) do
        if not p.active then
            p.active  = true ; p.life = 0
            p.maxLife = rand(MISC_AMB_LIFE_MIN, MISC_AMB_LIFE_MAX)
            local function gauss(r) return (rand(-r,r) + rand(-r,r) + rand(-r,r)) / 3 end
            p.x  = cx + gauss(barW * 0.5 + MISC_AMB_SPREAD_X)
            p.y  = cy + gauss(barH * 0.5 + MISC_AMB_SPREAD_Y)
            p.vx = rand(-6, 6)
            p.vy = rand(-4, 8)
            p.phase = math.random() * pi2
            local sz = rand(MISC_AMB_SIZE_MIN, MISC_AMB_SIZE_MAX)
            p.tex:SetSize(sz, sz)
            p.tex:SetAlpha(0)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateMiscAmb(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.x = p.x + p.vx * dt + math.sin(p.life * 2 + p.phase) * 0.3
    p.y = p.y + p.vy * dt
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t < 0.25 and t/0.25 or (t < 0.65 and 1 or (1-t)/0.35)
    p.tex:SetAlpha(math.max(0, env) * MISC_AMB_ALPHA * (gf or 1))
end

-- ============================================================
--  GLOW FRONT
-- ============================================================

local function SpawnGlow(frontX, cy, barH)
    for _, p in ipairs(glowParts) do
        if not p.active then
            local spread = math.min(barH * 0.28, 12)
            p.active  = true ; p.life = 0
            p.maxLife = rand(GLOW_LIFE_MIN, GLOW_LIFE_MAX)
            p.x = frontX + rand(-2, 4)
            p.y = cy + rand(-spread, spread)
            p.vy = rand(-8, 8)
            p.phase = math.random() * pi2
            p.tex:SetSize(rand(GLOW_SIZE_MIN, GLOW_SIZE_MAX), rand(GLOW_SIZE_MIN, GLOW_SIZE_MAX))
            p.tex:SetAlpha(0)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateGlow(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy * 0.88
    p.y  = p.y + p.vy * dt + math.sin(p.life * 10 + p.phase) * 0.4
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t < 0.2 and t/0.2 or (t < 0.75 and 1 or (1-t)/0.25)
    p.tex:SetAlpha(math.max(0, env) * GLOW_ALPHA * (gf or 1))
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["moon"]
    if not school then return end
    local f = SCB.Bar.frameInner
    if not f then return end

    -- Misc textures (Misc_Holy_01 / 02 recolorées en cyan)
    local miscTexs = school.misc or {}
    local nMisc = #miscTexs

    miscFrontParts = {}
    for i = 1, MISC_FRONT_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nMisc > 0 then tex:SetTexture(miscTexs[((i-1) % nMisc) + 1]) end
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(MOON_R, MOON_G, MOON_B)
        tex:SetAlpha(0)
        miscFrontParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0, phase=0 }
    end

    miscAmbParts = {}
    for i = 1, MISC_AMB_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nMisc > 0 then tex:SetTexture(miscTexs[((i-1) % nMisc) + 1]) end
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(MOON_R, MOON_G, MOON_B)
        tex:SetAlpha(0)
        miscAmbParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0, phase=0 }
    end

    -- Glow : Particle_Frost_01 recoloré cyan
    local glowTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    glowParts = {}
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(glowTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(MOON_R, MOON_G, MOON_B)
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vy=0, phase=0 }
    end
end

function FX.Start(duration)
    isActive=true ; isFading=false ; fadeT=0
    miscFrontAcc=0 ; miscAmbAcc=0 ; glowSpawnAcc=0
    for _, p in ipairs(miscFrontParts) do p.active=false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(miscAmbParts)   do p.active=false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(glowParts)      do p.active=false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive=false ; isFading=true ; fadeT=0
end

function FX.UpdateFade(dt)
    if not isFading then return end
    fadeT = fadeT + dt
    local gf = math.max(0, 1 - fadeT / FADE_DUR)
    for _, p in ipairs(miscFrontParts) do UpdateMiscFront(p, dt, gf) end
    for _, p in ipairs(miscAmbParts)   do UpdateMiscAmb(p,   dt, gf) end
    for _, p in ipairs(glowParts)      do UpdateGlow(p,      dt, gf) end
    if fadeT >= FADE_DUR then
        isFading = false
        for _, p in ipairs(miscFrontParts) do p.active=false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(miscAmbParts)   do p.active=false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(glowParts)      do p.active=false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    isActive=false ; isFading=false
    for _, p in ipairs(miscFrontParts) do p.active=false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(miscAmbParts)   do p.active=false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(glowParts)      do p.active=false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    -- Misc front
    for _, p in ipairs(miscFrontParts) do UpdateMiscFront(p, dt, 1) end
    if progress < MISC_FRONT_STOP_AT then
        miscFrontAcc = miscFrontAcc + dt
        if miscFrontAcc >= MISC_FRONT_SPAWN_RATE then
            miscFrontAcc = 0
            for _ = 1, 2 do SpawnMiscFront(frontX, cy, barH) end
        end
    end

    -- Misc ambient
    for _, p in ipairs(miscAmbParts) do UpdateMiscAmb(p, dt, 1) end
    miscAmbAcc = miscAmbAcc + dt
    if miscAmbAcc >= MISC_AMB_SPAWN_RATE then
        miscAmbAcc = 0
        local cx = fillLX + fillW * 0.5
        for _ = 1, 3 do SpawnMiscAmb(cx, cy, barW, barH) end
    end

    -- Glow front
    for _, p in ipairs(glowParts) do UpdateGlow(p, dt, 1) end
    if progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc + dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc = 0
            for _ = 1, math.random(2, 4) do SpawnGlow(frontX, cy, barH) end
        end
    end
end
