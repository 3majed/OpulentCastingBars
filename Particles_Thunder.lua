-- ============================================================
--  Sleek Casting Bars — Particles_Thunder.lua
--
--  · Light_Thunder  : au-dessus de Frame, suit la progression
--  · Lightning_01/02/03 : éclairs qui clignotent au-dessus de
--    tout, apparaissent d'un coup / disparaissent en fade,
--    offset X aléatoire, actifs dans la zone progressée
--  · Glow particles bleues électriques sur le front
-- ============================================================

local FX = {}
SCB.FX            = SCB.FX or {}
SCB.FX["thunder"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local pi2 = math.pi * 2

-- ============================================================
--  CONSTANTES
-- ============================================================

-- Couleur éclair
local LTN_R, LTN_G, LTN_B  = 0.7, 0.9, 1.0

-- Light_Thunder (suit la progression comme un fill)
-- (gérée via AddMaskTexture sur texMask)

-- Éclairs
local LIGHTNING_COUNT       = 3     -- un de chaque texture simultané max
local LIGHTNING_HOLD_MIN    = 0.04  -- durée d'apparition (instantané)
local LIGHTNING_HOLD_MAX    = 0.10
local LIGHTNING_FADE_MIN    = 0.15  -- durée fade out
local LIGHTNING_FADE_MAX    = 0.35
local LIGHTNING_PAUSE_MIN   = 0.20  -- pause entre deux éclairs
local LIGHTNING_PAUSE_MAX   = 0.80
local LIGHTNING_OFFSET_X    = 40    -- offset X max aléatoire (px)
local LIGHTNING_ALPHA       = 0.95

-- Glow front
local GLOW_COUNT            = 50
local GLOW_SPAWN_RATE       = 0.025
local GLOW_STOP_AT          = 0.90
local GLOW_ALPHA            = 0.65
local GLOW_SIZE_MIN         = 5
local GLOW_SIZE_MAX         = 14
local GLOW_LIFE_MIN         = 0.15
local GLOW_LIFE_MAX         = 0.30
local GLOW_R, GLOW_G, GLOW_B = 0.6, 0.85, 1.0

local FADE_DUR              = 0.40

-- ============================================================
--  ÉTAT
-- ============================================================

local isActive      = false
local isFading      = false
local fadeT         = 0
local glowSpawnAcc  = 0

local texLight      = nil   -- Light_Thunder (suit progression)
local maskLight     = nil   -- masque dédié pour texLight (sans offset marge)
local lightnings    = {}    -- pool des 3 éclairs
local glowParts     = {}

-- ============================================================
--  GLOW
-- ============================================================

local function SpawnGlow(frontX, cy, barH)
    for _, p in ipairs(glowParts) do
        if not p.active then
            local spread = math.min(barH * 0.30, 14)
            p.active=true ; p.life=0
            p.maxLife = rand(GLOW_LIFE_MIN, GLOW_LIFE_MAX)
            p.x = frontX + rand(-4, 4)
            p.y = cy + rand(-spread, spread)
            p.vy = rand(-8, 12)
            p.phase = math.random() * pi2
            p.tex:SetSize(rand(GLOW_SIZE_MIN, GLOW_SIZE_MAX), rand(GLOW_SIZE_MIN, GLOW_SIZE_MAX))
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateGlow(p, dt)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active=false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy * 0.88
    p.y  = p.y + p.vy * dt + math.sin(p.life * 12 + p.phase) * 0.4
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t < 0.15 and t/0.15 or (t < 0.75 and 1 or (1-t)/0.25)
    p.tex:SetAlpha(math.max(0, env) * GLOW_ALPHA)
end

-- ============================================================
--  ÉCLAIRS
--  Cycle : pause → apparition instantanée → hold → fade out → pause
-- ============================================================

local function ResetLightning(ln, fillLX, fillW, progress, cy, barH)
    -- Position X aléatoire dans la zone progressée
    local maxX   = fillLX + fillW * math.max(progress, 0.05)
    local cx     = rand(fillLX, maxX) + rand(-LIGHTNING_OFFSET_X, LIGHTNING_OFFSET_X)
    ln.cx        = cx
    ln.cy        = cy
    ln.phase     = "pause"
    ln.phaseT    = 0
    ln.pauseDur  = rand(LIGHTNING_PAUSE_MIN, LIGHTNING_PAUSE_MAX)
    ln.tex:SetAlpha(0)
end

local function UpdateLightning(ln, dt, fillLX, fillW, progress, cy, barH, gf)
    ln.phaseT = ln.phaseT + dt

    if ln.phase == "pause" then
        if ln.phaseT >= ln.pauseDur then
            -- Apparition instantanée
            ln.phase    = "hold"
            ln.phaseT   = 0
            ln.holdDur  = rand(LIGHTNING_HOLD_MIN, LIGHTNING_HOLD_MAX)
            ln.fadeDur  = rand(LIGHTNING_FADE_MIN, LIGHTNING_FADE_MAX)
            -- Nouvelle position dans la zone progressée
            local maxX  = fillLX + fillW * math.max(progress, 0.05)
            ln.cx       = rand(fillLX, maxX) + rand(-LIGHTNING_OFFSET_X, LIGHTNING_OFFSET_X)
            ln.cy       = cy
            ln.tex:SetAlpha(LIGHTNING_ALPHA * (gf or 1))
        end

    elseif ln.phase == "hold" then
        if ln.phaseT >= ln.holdDur then
            ln.phase  = "fade"
            ln.phaseT = 0
        end

    elseif ln.phase == "fade" then
        local t = math.min(ln.phaseT / ln.fadeDur, 1)
        ln.tex:SetAlpha((1-t) * LIGHTNING_ALPHA * (gf or 1))
        if t >= 1 then
            ln.tex:SetAlpha(0)
            ResetLightning(ln, fillLX, fillW, progress, cy, barH)
        end
    end
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["thunder"]
    if not school then return end

    local f = SCB.Bar.frameInner

    -- Light_Thunder : au-dessus de Frame, suit la progression via texMask
    if school.light then
        texLight = f:CreateTexture(nil, "OVERLAY", nil, 7)
        texLight:SetTexture(school.light)
        texLight:SetBlendMode("ADD")
        texLight:SetAllPoints(f)
        -- Masque dédié : part du bord gauche du frame, sans offset de marge fill
        maskLight = f:CreateMaskTexture()
        maskLight:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        maskLight:SetPoint("TOPLEFT",    f, "TOPLEFT")
        maskLight:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
        maskLight:SetWidth(1)
        texLight:AddMaskTexture(maskLight)
        texLight:SetAlpha(0)
    end

    -- Éclairs (OVERLAY au-dessus de tout, pas de mask — visibles sur toute la hauteur)
    local ltnTexs = school.lightnings or {}
    lightnings = {}
    for i = 1, LIGHTNING_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY", nil, 7)
        if ltnTexs[i] then tex:SetTexture(ltnTexs[i]) end
        tex:SetBlendMode("ADD")
        tex:SetAllPoints(f)
        tex:AddMaskTexture(SCB.Bar.texMask)
        tex:SetAlpha(0)
        lightnings[i] = {
            tex=tex, phase="pause", phaseT=0,
            pauseDur=0, holdDur=0, fadeDur=0,
            cx=0, cy=0,
        }
    end

    -- Glow
    glowParts = {}
    local glowTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(glowTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(GLOW_R, GLOW_G, GLOW_B)
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vy=0, phase=0 }
    end
end

function FX.Start(duration)
    isActive=true ; isFading=false ; fadeT=0 ; glowSpawnAcc=0

    -- Créer texLight si pas encore fait (sécurité)
    if not texLight then
        local school = SCB.Schools.data["thunder"]
        if school and school.light then
            local f = SCB.Bar.frameInner
            texLight = f:CreateTexture(nil, "OVERLAY", nil, 6)
            texLight:SetTexture(school.light)
            texLight:SetBlendMode("ADD")
            texLight:SetAllPoints(f)
            texLight:AddMaskTexture(SCB.Bar.texMask)
        end
    end
    if texLight  then texLight:SetAlpha(1) end
    if maskLight then maskLight:SetWidth(1) end

    for _, p  in ipairs(glowParts)  do p.active=false ; p.tex:SetAlpha(0) end
    -- Init éclairs avec délais décalés
    for i, ln in ipairs(lightnings) do
        ln.phase    = "pause"
        ln.phaseT   = 0
        ln.pauseDur = rand(0, LIGHTNING_PAUSE_MAX) * (i / LIGHTNING_COUNT)
        ln.tex:SetAlpha(0)
    end
end

function FX.Stop()
    isActive=false ; isFading=true ; fadeT=0
end

function FX.UpdateFade(dt)
    if not isFading then return end
    fadeT = fadeT + dt
    local gf = math.max(0, 1 - fadeT / FADE_DUR)
    if texLight then texLight:SetAlpha(gf) end
    for _, ln in ipairs(lightnings) do ln.tex:SetAlpha(0) end
    for _, p  in ipairs(glowParts)  do UpdateGlow(p, dt) end
    if fadeT >= FADE_DUR then
        isFading = false
        if texLight then texLight:SetAlpha(0) end
        for _, p in ipairs(glowParts) do p.active=false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    isActive=false ; isFading=false
    if texLight  then texLight:SetAlpha(0) end
    if maskLight then maskLight:SetWidth(1) end
    for _, ln in ipairs(lightnings) do ln.tex:SetAlpha(0) end
    for _, p  in ipairs(glowParts)  do p.active=false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    -- Masque Light_Thunder (depuis bord gauche du frame, sans marge fill)
    if maskLight then
        local frameW = SCB.Bar.frame:GetWidth()
        maskLight:SetWidth(math.max(frameW * progress, 1))
    end

    -- Éclairs
    for _, ln in ipairs(lightnings) do
        UpdateLightning(ln, dt, fillLX, fillW, progress, cy, barH, 1)
    end

    -- Glow front
    for _, p in ipairs(glowParts) do UpdateGlow(p, dt) end
    if progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc + dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc = 0
            for _ = 1, math.random(2, 4) do SpawnGlow(frontX, cy, barH) end
        end
    end
end
