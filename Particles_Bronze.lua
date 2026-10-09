-- ============================================================
--  Sleek Casting Bars — Particles_Bronze.lua
--  Sable tourbillonnant : grains 1-2px qui virevoltent vers la droite
--
--  Physique : chaque grain avance vers la droite (vx toujours > 0)
--  mais son vy oscille sinusoïdalement avec une fréquence et phase
--  propres → trajectoire en S / vague organique.
--  Des rafales périodiques accélèrent le flux global.
-- ============================================================

local FX = {}
SCB.FX           = SCB.FX or {}
SCB.FX["bronze"] = FX

local rand = function(a, b) return a + math.random() * (b - a) end
local sin, cos, pi = math.sin, math.cos, math.pi

-- ============================================================
--  CONSTANTES
-- ============================================================

local SAND_COUNT      = 380
local SAND_SPAWN_RATE = 0.009

local SAND_SIZE_MIN   = 1
local SAND_SIZE_MAX   = 2

-- Vitesse horizontale : toujours positive, grain avance vers la droite
local SAND_VX_MIN     = 45
local SAND_VX_MAX     = 120

-- Ondulation verticale : chaque grain a son propre sinus
-- amplitude = combien le grain monte/descend
-- fréquence = vitesse de l'ondulation
-- phase     = décalage (grains pas en sync)
local SAND_AMP_MIN    = 6
local SAND_AMP_MAX    = 22
-- Fréquence en rad/s directement — pas de * 2π dans le calcul
-- 0.3 rad/s = une ondulation complète en ~21s (très lent, smooth)
-- 1.2 rad/s = une ondulation complète en ~5s (modéré)
local SAND_FRQ_MIN    = 0.3
local SAND_FRQ_MAX    = 1.2

local SAND_DRIFT_MIN  = -15
local SAND_DRIFT_MAX  =  15

-- Rafales de vent
local WIND_CYCLE      = 1.8
local WIND_PEAK_FRAC  = 0.28
local WIND_BOOST      = 60      -- px/s ajoutés lors d'une rafale

-- Couleurs
local COLS = {
    { 1.00, 0.88, 0.22 },
    { 1.00, 0.72, 0.12 },
    { 1.00, 0.95, 0.55 },
    { 0.95, 0.78, 0.18 },
    { 1.00, 0.62, 0.10 },
}

-- Éclats tip — style Earth : jaillissent en éventail vers le haut, retombent
local TIP_COUNT      = 50
local TIP_SPAWN_RATE = 0.027
local TIP_STOP_AT    = 0.87
local TIP_SIZE_MIN   = 4
local TIP_SIZE_MAX   = 9
local TIP_ALPHA      = 0.85
local TIP_ANGLE_MIN  = 50
local TIP_ANGLE_MAX  = 130
local TIP_SPD_MIN    = 35
local TIP_SPD_MAX    = 95
local TIP_LIFE_MIN   = 0.35
local TIP_LIFE_MAX   = 0.75
local TIP_GRAVITY    = 80

-- Glow tip — couche dense de petites particules lumineuses (style Nature glowParts)
local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.020
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.60
local GLOW_SIZE_MIN   = 4
local GLOW_SIZE_MAX   = 10
local GLOW_LIFE_MIN   = 0.18
local GLOW_LIFE_MAX   = 0.38

local FADE_DUR = 0.40

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
--  ÉTAT INTERNE
-- ============================================================
local sandParts    = {}
local tipParts     = {}
local glowParts    = {}
local sandSpawnAcc = 0
local tipSpawnAcc  = 0
local glowSpawnAcc = 0
local isActive     = false
local isFading     = false
local fadeT        = 0
local windAccum    = 0

-- ============================================================
--  SABLE — spawn
-- ============================================================
local function SpawnSand(barLX, barCY, barH)
    for _, g in ipairs(sandParts) do
        if not g.active then
            local col = COLS[math.random(#COLS)]
            g.active   = true
            g.x        = barLX - 2
            g.y0       = barCY + rand(-barH * 0.18, barH * 0.18)
            g.y        = g.y0
            g.vx       = rand(SAND_VX_MIN, SAND_VX_MAX)
            g.amp      = rand(SAND_AMP_MIN, SAND_AMP_MAX)
            g.frq      = rand(SAND_FRQ_MIN, SAND_FRQ_MAX)
            g.phase    = rand(0, pi * 2)
            g.drift    = rand(SAND_DRIFT_MIN, SAND_DRIFT_MAX)
            g.windOff  = rand(0, WIND_CYCLE)
            g.life     = 0
            local r    = math.random()
            g.maxAlpha = r * r * 0.75 + 0.08
            g.deadX    = 0
            local size = math.random(2) == 1 and 1 or 2
            g.tex:SetSize(size, size)
            g.tex:SetVertexColor(col[1], col[2], col[3])
            g.tex:SetAlpha(0)
            g.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", g.x, g.y)
            return
        end
    end
end

-- ============================================================
--  SABLE — update
-- ============================================================
local function GetGust(offset)
    local phase = math.fmod(windAccum + offset, WIND_CYCLE) / WIND_CYCLE
    if phase < WIND_PEAK_FRAC then
        return phase / WIND_PEAK_FRAC
    else
        return 1 - (phase - WIND_PEAK_FRAC) / (1 - WIND_PEAK_FRAC)
    end
end

local function UpdateSand(g, dt, barRX, gFade)
    if not g.active then return end
    g.life = g.life + dt
    local vx = g.vx + WIND_BOOST * GetGust(g.windOff) * 0.45
    g.x = g.x + vx * dt
    g.y = g.y0
        + sin(g.life * g.frq + g.phase) * g.amp
        + g.drift * g.life
    if g.deadX == 0 then g.deadX = barRX + 4 end
    local fadeIn  = math.min(g.life / 0.12, 1)
    local distEnd = g.deadX - g.x
    local fadeOut = distEnd < 22 and (distEnd / 22) or 1
    local alpha   = g.maxAlpha * fadeIn * fadeOut * (gFade or 1)
    if g.x >= g.deadX or g.life > 5 then
        g.active = false ; g.tex:SetAlpha(0) ; return
    end
    g.tex:SetAlpha(alpha)
    g.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", g.x, g.y)
end

-- ============================================================
--  ÉCLATS TIP — style Earth, couleurs Bronze
--  Jaillissent en éventail vers le haut, retombent avec gravité,
--  tournent sur eux-mêmes
-- ============================================================
local function SpawnTip(frontX, barCY, barH)
    for _, p in ipairs(tipParts) do
        if not p.active then
            local col   = COLS[math.random(#COLS)]
            local angle = math.rad(rand(TIP_ANGLE_MIN, TIP_ANGLE_MAX))
            local spd   = rand(TIP_SPD_MIN, TIP_SPD_MAX)
            local size  = rand(TIP_SIZE_MIN, TIP_SIZE_MAX)
            p.active   = true
            p.life     = 0
            p.maxLife  = rand(TIP_LIFE_MIN, TIP_LIFE_MAX)
            p.x        = frontX + rand(-4, 4)
            p.y        = barCY  + rand(-barH * 0.18, barH * 0.18)
            p.vx       = math.cos(angle) * spd
            p.vy       = math.sin(angle) * spd
            p.tex:SetSize(size, size)
            p.tex:SetVertexColor(col[1], col[2], col[3])
            p.tex:SetAlpha(TIP_ALPHA)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateTip(p, dt, gFade)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - TIP_GRAVITY * dt
    p.x  = p.x  + p.vx * dt
    p.y  = p.y  + p.vy * dt
    local alpha = (t < 0.55 and 1 or math.max(0, (1-t)/0.45))
                  * TIP_ALPHA * (gFade or 1)
    p.tex:SetAlpha(alpha)
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
end

-- ============================================================
--  GLOW TIP — nuage dense de petites particules dorées
--  Style Nature glowParts : vie courte, spawn rapide 2-4/tick
-- ============================================================
local function SpawnGlow(frontX, barCY, barH)
    for _, p in ipairs(glowParts) do
        if not p.active then
            local col  = COLS[math.random(#COLS)]
            local size = rand(GLOW_SIZE_MIN, GLOW_SIZE_MAX)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(GLOW_LIFE_MIN, GLOW_LIFE_MAX)
            p.x       = frontX + rand(-3, 3)
            p.y       = barCY  + rand(-barH * 0.15, barH * 0.15)
            p.vy      = rand(-18, 18)
            p.tex:SetSize(size, size)
            p.tex:SetVertexColor(col[1], col[2], col[3])
            p.tex:SetAlpha(0)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateGlow(p, dt, gFade)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.y = p.y + p.vy * dt
    p.vy = p.vy * 0.88
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    -- Enveloppe : monte vite, descend doucement
    local env
    if t < 0.25 then env = t / 0.25
    elseif t < 0.75 then env = 1
    else env = (1 - t) / 0.25 end
    p.tex:SetAlpha(math.max(0, env) * GLOW_ALPHA * (gFade or 1))
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================
function FX.Init(container, bar)
    sandParts = {}
    for i = 1, SAND_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture("Interface\\Buttons\\WHITE8X8")
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        sandParts[i] = {
            tex=tex, active=false,
            x=0, y=0, y0=0, vx=0,
            amp=0, frq=0, phase=0, drift=0, windOff=0,
            life=0, maxAlpha=0, deadX=0,
        }
    end
    tipParts = {}
    local tipTextures = {
        SCB.TEX_PATH .. "frost\\Particle_Frost_01",
        SCB.TEX_PATH .. "frost\\Particle_Frost_02",
    }
    for i = 1, TIP_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(tipTextures[((i-1) % 2) + 1])
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        tipParts[i] = {
            tex=tex, active=false,
            x=0, y=0, vx=0, vy=0,
            life=0, maxLife=0,
        }
    end
    glowParts = {}
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(tipTextures[((i-1) % 2) + 1])
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, x=0, y=0, vy=0, life=0, maxLife=0 }
    end
end

function FX.Start(duration)
    isActive     = true
    isFading     = false
    sandSpawnAcc = 0
    tipSpawnAcc  = 0
    glowSpawnAcc = 0
    windAccum    = 0
    for _, g in ipairs(sandParts) do g.active=false ; g.tex:SetAlpha(0) end
    for _, p in ipairs(tipParts)  do p.active=false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(glowParts) do p.active=false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive=false ; isFading=true ; fadeT=0
    sandSpawnAcc=0 ; tipSpawnAcc=0 ; glowSpawnAcc=0
end

function FX.UpdateFade(dt)
    if not isFading then return end
    fadeT = fadeT + dt
    local gFade = math.max(0, 1 - fadeT / FADE_DUR)
    local f   = SCB.Bar.frameInner
    local cx  = f:GetCenter()
    local barRX = cx and (cx + SCB.Bar.frame:GetWidth() * 0.5) or 9999
    for _, g in ipairs(sandParts) do UpdateSand(g, dt, barRX, gFade) end
    for _, p in ipairs(tipParts)  do UpdateTip(p, dt, gFade) end
    for _, p in ipairs(glowParts) do UpdateGlow(p, dt, gFade) end
    if fadeT >= FADE_DUR then
        isFading = false
        for _, g in ipairs(sandParts) do g.active=false ; g.tex:SetAlpha(0) end
        for _, p in ipairs(tipParts)  do p.active=false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(glowParts) do p.active=false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    isFading = false
    for _, g in ipairs(sandParts) do g.active=false ; g.tex:SetAlpha(0) end
    for _, p in ipairs(tipParts)  do p.active=false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(glowParts) do p.active=false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end
    local f = SCB.Bar.frameInner
    local cx, barCY = f:GetCenter()
    if not cx then return end
    local barLX = cx - barW * 0.5
    local barRX = cx + barW * 0.5

    windAccum = windAccum + dt
    if windAccum >= WIND_CYCLE then windAccum = windAccum - WIND_CYCLE end

    -- Sable
    for _, g in ipairs(sandParts) do UpdateSand(g, dt, barRX, 1) end
    sandSpawnAcc = sandSpawnAcc + dt
    if sandSpawnAcc >= SAND_SPAWN_RATE then
        sandSpawnAcc = 0
        for _ = 1, math.random(3, 5) do SpawnSand(barLX, barCY, barH) end
    end

    -- Éclats tip et Glow tip : supprimés pour les sorts Empowered
    -- (le "flou en bout de barre" demandé à supprimer sur les sorts chargés)
    local isEmpower = SCB.Bar and SCB.Bar._isEmpower

    -- Éclats tip (balistiques)
    for _, p in ipairs(tipParts) do UpdateTip(p, dt, 1) end
    if not isEmpower and progress > 0.02 and progress < TIP_STOP_AT then
        tipSpawnAcc = tipSpawnAcc + dt
        if tipSpawnAcc >= TIP_SPAWN_RATE then
            tipSpawnAcc = 0
            SpawnTip(frontX, barCY, barH)
        end
    end

    -- Glow dense (vie courte, spawn rapide 2-4/tick)
    for _, p in ipairs(glowParts) do UpdateGlow(p, dt, 1) end
    if not isEmpower and progress > 0.02 and progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc + dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc = 0
            for _ = 1, math.random(2, 4) do SpawnGlow(frontX, barCY, barH) end
        end
    end
end

function FX.UpdateCirclesFade(dt) end
