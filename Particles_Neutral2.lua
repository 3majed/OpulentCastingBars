-- ============================================================
--  Sleek Casting Bars — Particles_Neutral2.lua
--  Uniquement glowParts cyan au bout de la barre
-- ============================================================

local FX = {}
SCB.FX             = SCB.FX or {}
SCB.FX["neutral2"] = FX

local function rand(a, b) return a + math.random() * (b - a) end

local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.02
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.55
local GLOW_SIZE_MIN   = 4
local GLOW_SIZE_MAX   = 9
local GLOW_LIFE_MIN   = 0.10
local GLOW_LIFE_MAX   = 0.20

local GLOW_R, GLOW_G, GLOW_B = 0.0, 0.85, 1.0
local PARTS_FADE_DUR = 0.6

local isActive    = false
local partsFading = false
local partsFadeT  = 0
local glowParts   = {}
local glowSpawnAcc = 0

local function SpawnGlow(frontX, cy, barH)
    for _, p in ipairs(glowParts) do
        if not p.active then
            local spread = math.min(barH * 0.25, 10)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(GLOW_LIFE_MIN, GLOW_LIFE_MAX)
            p.x       = frontX + rand(-2, 2)
            p.y       = cy + rand(-spread, spread)
            p.vy      = rand(-5, 5)
            p.phase   = math.random() * math.pi * 2
            local size = rand(GLOW_SIZE_MIN, GLOW_SIZE_MAX)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateGlow(p, dt, globalFade)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy * 0.90
    p.y  = p.y + p.vy * dt + math.sin(p.life * 10 + p.phase) * 0.3
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env
    if t < 0.2 then env = t / 0.2
    elseif t < 0.8 then env = 1
    else env = (1 - t) / 0.2 end
    p.tex:SetAlpha(math.max(0, env) * GLOW_ALPHA * (globalFade or 1))
end

function FX.Init(container, bar)
    glowParts = {}
    local glowTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(glowTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(GLOW_R, GLOW_G, GLOW_B)
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0,
                         x=0, y=0, vy=0, phase=0 }
    end
end

function FX.Start(duration)
    isActive     = true
    partsFading  = false
    glowSpawnAcc = 0
    for _, p in ipairs(glowParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive     = false
    partsFading  = true
    partsFadeT   = 0
    glowSpawnAcc = 0
end

function FX.UpdateFade(dt)
    if not partsFading then return end
    partsFadeT = partsFadeT + dt
    local gFade = math.max(0, 1 - partsFadeT / PARTS_FADE_DUR)
    for _, p in ipairs(glowParts) do UpdateGlow(p, dt, gFade) end
    if partsFadeT >= PARTS_FADE_DUR then
        partsFading = false
        for _, p in ipairs(glowParts) do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    partsFading = false
    for _, p in ipairs(glowParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    local f = SCB.Bar.frameInner
    local _, barCY = f:GetCenter()
    if not barCY then return end

    for _, p in ipairs(glowParts) do UpdateGlow(p, dt, 1) end
    if progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc + dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc = 0
            local count = math.random(2, 4)
            for _ = 1, count do SpawnGlow(frontX, barCY, barH) end
        end
    end
end
