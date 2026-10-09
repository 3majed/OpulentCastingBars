-- ============================================================
--  Sleek Casting Bars — Particles_Frost.lua
--  Effets visuels pour l'école Frost :
--    · Mist      — 3 brumes flottantes autour de la barre
--    · Particles — particules depuis le front de progression
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["frost"] = FX

-- ============================================================
--  UTILITAIRES LOCAUX
-- ============================================================

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end

local TEX = SCB.TEX_PATH .. "frost\\"

-- ============================================================
--  CONSTANTES MIST
-- ============================================================

local MIST_COUNT     = 6
local MIST_W_BASE    = 338
local MIST_H_BASE    = 169
local MIST_ALPHA_MAX = 0.08
local MIST_SCALE_MIN = 0.45
local MIST_SCALE_MAX = 0.75
local MIST_FADE_IN   = 1.8
local MIST_HOLD_MIN  = 1.2
local MIST_HOLD_MAX  = 2.5
local MIST_FADE_OUT  = 1.5
local MIST_ROT_SPEED = 0.04

local MIST_POSITIONS = { 3/8, 5/8 }

-- ============================================================
--  CONSTANTES PARTICULES
-- ============================================================

local PART_COUNT           = 16
local PART_SIZE_BASE       = 7
local PART_SPREAD          = 70
local PART_GRAVITY         = 30
local PART_SPAWN_RATE      = 0.12
local PART_SPEED_SHORT_MIN = 90
local PART_SPEED_SHORT_MAX = 180
local PART_LIFE_SHORT_MIN  = 0.25
local PART_LIFE_SHORT_MAX  = 0.55
local PART_SPEED_LONG_MIN  = 40
local PART_SPEED_LONG_MAX  = 110
local PART_LIFE_LONG_MIN   = 0.6
local PART_LIFE_LONG_MAX   = 1.4

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local mists        = {}
local parts        = {}
local spawnAccum   = 0
local castDuration = 5

-- ============================================================
--  ROTATION UV (compatible Classic + Retail)
-- ============================================================

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
--  MIST
-- ============================================================

local function SpawnMist(m)
    local scale = rand(MIST_SCALE_MIN, MIST_SCALE_MAX)
    m.baseW    = MIST_W_BASE * scale
    m.baseH    = MIST_H_BASE * scale
    m.tex:SetSize(m.baseW, m.baseH)
    m.tex:SetAlpha(0)
    m.phase    = "fadein"
    m.timer    = 0
    m.duration = MIST_FADE_IN
    m.alpha    = 0
    m.scaleT   = 0
    m.scaleDir = math.random(2) == 1 and 1 or -1
end

local function UpdateMist(m, dt)
    if m.delay and m.delay > 0 then
        m.delay = m.delay - dt
        return
    end
    if m.phase == "idle" then
        SpawnMist(m)
        return
    end

    -- Position dynamique : recalculée à chaque tick depuis les coords absolues de la barre
    local f = SCB.Bar.frameInner
    local cx, cy = f:GetCenter()
    if cx then
        local barW = f:GetWidth()
        local x = cx - barW * 0.5 + barW * m.xFrac
        m.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, cy)
    end

    m.timer  = m.timer + dt
    m.scaleT = m.scaleT + dt
    m.angle  = m.angle + MIST_ROT_SPEED * m.rotDir * dt

    local scalePulse = 1 + math.sin(m.scaleT * 0.45 * m.scaleDir) * 0.09
    m.tex:SetSize(m.baseW * scalePulse, m.baseH * scalePulse)
    SetTextureRotation(m.tex, m.angle)

    if m.phase == "fadein" then
        m.alpha = math.min(m.timer / m.duration, 1) * MIST_ALPHA_MAX
        local pulse = math.sin(m.scaleT * 1.8) * 0.018
        m.tex:SetAlpha(math.max(0, m.alpha + pulse))
        if m.timer >= m.duration then
            m.phase = "hold" ; m.timer = 0
            m.duration = rand(MIST_HOLD_MIN, MIST_HOLD_MAX)
        end
    elseif m.phase == "hold" then
        local pulse = math.sin(m.scaleT * 1.8) * 0.025
        m.tex:SetAlpha(math.max(0, MIST_ALPHA_MAX + pulse))
        if m.timer >= m.duration then
            m.phase = "fadeout" ; m.timer = 0 ; m.duration = MIST_FADE_OUT
        end
    elseif m.phase == "fadeout" then
        m.alpha = (1 - m.timer / m.duration) * MIST_ALPHA_MAX
        m.tex:SetAlpha(math.max(0, m.alpha))
        if m.timer >= m.duration then
            m.tex:SetAlpha(0) ; m.phase = "idle"
        end
    end
end

-- ============================================================
--  PARTICULES FROST
-- ============================================================

local function GetPartParams()
    local t = math.max(0, math.min((castDuration - 2) / 3, 1))
    return
        lerp(PART_SPEED_SHORT_MIN, PART_SPEED_LONG_MIN, t),
        lerp(PART_SPEED_SHORT_MAX, PART_SPEED_LONG_MAX, t),
        lerp(PART_LIFE_SHORT_MIN,  PART_LIFE_LONG_MIN,  t),
        lerp(PART_LIFE_SHORT_MAX,  PART_LIFE_LONG_MAX,  t)
end

local function SpawnParticle(wx, wy)
    local speedMin, speedMax, lifeMin, lifeMax = GetPartParams()
    for _, p in ipairs(parts) do
        if not p.active then
            local angle = rad(90 + rand(-PART_SPREAD, PART_SPREAD))
            local speed = rand(speedMin, speedMax)
            local size  = PART_SIZE_BASE + rand(-3, 5)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(lifeMin, lifeMax)
            p.x       = wx + rand(-4, 4)
            p.y       = wy + rand(-6, 6)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0.42)
            return
        end
    end
end

local function UpdateParticle(p, dt)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - PART_GRAVITY * dt
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha = t < 0.4 and 1 or (1 - (t - 0.4) / 0.6)
    p.tex:SetAlpha(math.max(0, alpha) * 0.42)
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local textures = { TEX .. "Particle_Frost_01", TEX .. "Particle_Frost_02" }
    for i = 1, PART_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(textures[(i % 2) + 1])
        tex:SetAlpha(0)
        tex:SetBlendMode("ADD")
        parts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0 }
    end

    for i, xFrac in ipairs(MIST_POSITIONS) do
        local tex = bar:CreateTexture(nil, "BACKGROUND", nil, -1)
        tex:SetTexture(TEX .. "Mist_Frost_01")
        tex:SetSize(MIST_W_BASE, MIST_H_BASE)
        tex:SetAlpha(0)
        tex:SetBlendMode("BLEND")
        -- Position calculée dynamiquement dans Update (bar:GetWidth() = 0 à l'Init)
        mists[i] = {
            tex=tex, xFrac=xFrac, phase="idle", timer=0, duration=0,
            alpha=0, scaleT=0, scaleDir=1, angle=0,
            rotDir=(i % 2 == 0) and 1 or -1,
            baseW=MIST_W_BASE, baseH=MIST_H_BASE,
            delay=(i - 1) * 0.8,
        }
    end
end

function FX.Start(duration)
    castDuration = duration or 5
    spawnAccum   = 0
    for i, m in ipairs(mists) do
        m.phase = "idle" ; m.delay = (i - 1) * 0.8 ; m.tex:SetAlpha(0)
    end
    for _, p in ipairs(parts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    for _, m in ipairs(mists) do
        if m.phase ~= "idle" then
            m.phase = "fadeout" ; m.timer = 0 ; m.duration = 0.35
        end
    end
end

function FX.Reset()
    for _, p in ipairs(parts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, m in ipairs(mists) do m.tex:SetAlpha(0) ; m.phase = "idle" end
end

function FX.Update(dt, progress, frontX, cy, barW, barH)
    -- Particules en vol continuent toujours
    for _, p in ipairs(parts) do UpdateParticle(p, dt) end
    for _, m in ipairs(mists) do UpdateMist(m, dt) end

    -- Spawn uniquement si actif
    spawnAccum = spawnAccum + dt
    if spawnAccum >= PART_SPAWN_RATE then
        spawnAccum = 0
        local count = (math.random(1, 4) == 1) and 2 or 1
        for _ = 1, count do SpawnParticle(frontX, cy) end
    end
end
