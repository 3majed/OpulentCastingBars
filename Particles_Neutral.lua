-- ============================================================
--  Sleek Casting Bars — Particles_Neutral.lua
--  Effets visuels pour l'école Neutral :
--    · Ligne de particules cyan concentrée sur le front
--    · Pas de mist, pas de FrostBG
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["neutral"]  = FX
SCB.FX["alliance"] = FX   -- même effets que neutral
SCB.FX["horde"]    = FX   -- même effets que neutral

-- ============================================================
--  UTILITAIRES LOCAUX
-- ============================================================

local function rand(a, b) return a + math.random() * (b - a) end

-- ============================================================
--  CONSTANTES
-- ============================================================

local NEUTRAL_COUNT      = 60
local NEUTRAL_SPAWN_RATE = 0.02
local NEUTRAL_COLOR_R    = 0x31 / 255
local NEUTRAL_COLOR_G    = 0xf4 / 255
local NEUTRAL_COLOR_B    = 0xfe / 255
local NEUTRAL_ALPHA      = 0.50
local NEUTRAL_STOP_AT    = 0.87   -- arrêt du spawn à 87% de progression

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local parts     = {}
local spawnAcc  = 0

-- ============================================================
--  PARTICULES
-- ============================================================

local function SpawnParticle(frontX, cy, barH)
    for _, p in ipairs(parts) do
        if not p.active then
            local spread = math.min(barH * 0.25, 10)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(0.40, 0.70)
            p.x       = frontX + rand(0, 3)
            p.y       = cy + rand(-spread, spread)
            p.vx      = 0
            p.vy      = rand(-5, 5)
            p.phase   = math.random() * math.pi * 2

            local size = rand(3, 6)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            return
        end
    end
end

local function UpdateParticle(p, dt)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end

    p.vy = p.vy * 0.90
    p.y  = p.y + p.vy * dt + math.sin(p.life * 10 + p.phase) * 0.3
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)

    local alpha
    if t < 0.2 then alpha = t / 0.2
    elseif t < 0.8 then alpha = 1
    else alpha = (1 - t) / 0.2 end
    p.tex:SetAlpha(math.max(0, alpha) * NEUTRAL_ALPHA)
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local texPath = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    for i = 1, NEUTRAL_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(texPath)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(NEUTRAL_COLOR_R, NEUTRAL_COLOR_G, NEUTRAL_COLOR_B)
        tex:SetAlpha(0)
        parts[i] = {
            tex=tex, active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, phase=0,
        }
    end
end

function FX.Start(duration)
    spawnAcc = 0
    for _, p in ipairs(parts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    -- Particules en vol terminent naturellement
end

function FX.Reset()
    for _, p in ipairs(parts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    for _, p in ipairs(parts) do UpdateParticle(p, dt) end

    if progress < NEUTRAL_STOP_AT then
        spawnAcc = spawnAcc + dt
        if spawnAcc >= NEUTRAL_SPAWN_RATE then
            spawnAcc = 0
            local count = math.random(2, 4)
            for _ = 1, count do SpawnParticle(frontX, cy, barH) end
        end
    end
end
