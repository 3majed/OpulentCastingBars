-- ============================================================
--  Sleek Casting Bars — Particles.lua
--  Dispatcher principal des effets visuels par école.
--
--  Chaque école a son propre fichier Particles_[school].lua
--  qui expose une interface standard :
--    FX.Init(container, frameInner)
--    FX.Start(duration)
--    FX.Stop()
--    FX.Reset()
--    FX.Update(dt, progress, frontX, cy, barW, barH)
--
--  Ce fichier gère également :
--    · FrostBG — texture de fond révélée avec le masque (Frost)
--    · Start / Stop / Update centralisés
-- ============================================================

SCB.Particles = {}
SCB.FX        = SCB.FX or {}

-- ============================================================
--  UTILITAIRES COMMUNS
-- ============================================================

local function GetBarDimensions()
    local f = SCB.Bar.frame
    local cx, cy = f:GetCenter()
    if not cx then return nil end
    return cx, cy, f:GetWidth(), f:GetHeight()
end

-- ============================================================
--  FROSTBG — texture de fond frost révélée progressivement
-- ============================================================

local TEX_FROST = SCB.TEX_PATH .. "frost\\"

function SCB.Particles:CreateFrostBG()
    local f   = SCB.Bar.frame
    local tex = f:CreateTexture(nil, "BACKGROUND", nil, -1)
    tex:SetAllPoints(f)
    tex:SetTexture(TEX_FROST .. "FrostBG_Frost")
    tex:SetAlpha(0.85)

    local mask = f:CreateMaskTexture()
    mask:SetTexture("Interface\\BUTTONS\\WHITE8X8",
                    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetPoint("TOPLEFT",    f, "TOPLEFT")
    mask:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
    mask:SetWidth(1)
    tex:AddMaskTexture(mask)

    self.frostBGTex  = tex
    self.frostBGMask = mask
end

function SCB.Particles:UpdateFrostBG(schoolKey, progress)
    if not self.frostBGMask then return end
    if schoolKey ~= "frost" then
        self.frostBGTex:SetAlpha(0)
        self.frostBGMask:SetWidth(1)
        return
    end
    self.frostBGTex:SetAlpha(0.85)
    self.frostBGMask:SetWidth(math.max(SCB.Bar.frame:GetWidth() * progress, 1))
end

function SCB.Particles:ResetFrostBG()
    if self.frostBGMask then self.frostBGMask:SetWidth(1) end
    if self.frostBGTex  then self.frostBGTex:SetAlpha(0) end
end

-- ============================================================
--  FROSTFIRE — masque Givre synchronisé avec progression
-- ============================================================

function SCB.Particles:UpdateFrostfireLayers(schoolKey, progress)
    local bar = SCB.Bar
    if schoolKey ~= "frostfire" then
        if bar.maskGivreFrostfire then bar.maskGivreFrostfire:SetWidth(1) end
        return
    end
    if bar.maskGivreFrostfire then
        bar.maskGivreFrostfire:SetWidth(math.max(bar.frame:GetWidth() * progress, 1))
    end
end

function SCB.Particles:ResetFrostfireLayers()
    local bar = SCB.Bar
    if bar.maskGivreFrostfire then bar.maskGivreFrostfire:SetWidth(1) end
    if bar.texGivreFrostfire  then bar.texGivreFrostfire:SetAlpha(0)  end
end

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local isRunning    = false
local castDuration = 5
local currentFX    = nil

-- ============================================================
--  INIT
-- ============================================================

function SCB.Particles:Init()
    self:CreateFrostBG()

    local container  = SCB.Bar.particleContainer
    local frameInner = SCB.Bar.frameInner

    for _, fx in pairs(SCB.FX) do
        if fx.Init then
            fx.Init(container, frameInner)
        end
    end

    -- Masque de progression sur les contours Fire
    local texMask = SCB.Bar.texMask
    if texMask then
        for _, t in ipairs(SCB.Bar.texContoursFire) do
            t:AddMaskTexture(texMask)
        end
    end
end

-- ============================================================
--  START / STOP
-- ============================================================

function SCB.Particles:Start(duration)
    isRunning    = true
    castDuration = duration or 5

    self:ResetFrostBG()

    for _, fx in pairs(SCB.FX) do
        if fx.Reset then fx.Reset() end
    end

    local schoolKey = SCB.Bar.currentSchoolKey or "neutral"
    currentFX = SCB.FX[schoolKey]
    if currentFX and currentFX.Start then
        currentFX.Start(castDuration)
    end
end

function SCB.Particles:Stop(success)
    isRunning = false
    self:ResetFrostBG()
    -- Ne PAS appeler ResetFrostfireLayers ici : le masque doit
    -- rester à sa largeur courante pendant le fade out, le FX.UpdateFade
    -- gère lui-même la disparition progressive de la Givre.

    if currentFX and currentFX.Stop then
        currentFX.Stop(success)
    end
end

function SCB.Particles:ResetAll()
    -- Appelé après la fin du fade — remet proprement tous les FX
    for _, fx in pairs(SCB.FX) do
        if fx.Reset then fx.Reset() end
    end
    self:ResetFrostfireLayers()
end

-- ============================================================
--  UPDATE
-- ============================================================

function SCB.Particles:UpdateCirclesFade(dt)
    -- Appelé pendant le fade out de la barre
    if currentFX then
        if currentFX.UpdateCirclesFade then currentFX.UpdateCirclesFade(dt) end
        if currentFX.UpdateFade        then currentFX.UpdateFade(dt) end
    end
end

function SCB.Particles:Update(dt, progress)
    local schoolKey = SCB.Bar.currentSchoolKey

    self:UpdateFrostBG(schoolKey, progress)
    self:UpdateFrostfireLayers(schoolKey, progress)

    if not currentFX then return end

    local cx, cy, barW, barH = GetBarDimensions()
    if not cx then return end

    -- Correction des marges internes de la texture Fill
    local school = SCB.Bar.currentSchool
    local mL = (school and school.fillMarginL or 0) * barW + (school and school.fillMarginLPx or 0)
    local mR = (school and school.fillMarginR or 0) * barW + (school and school.fillMarginRPx or 0)
    local fillW   = barW - mL - mR          -- largeur utile de la fill
    local fillLX  = cx - barW * 0.5 + mL    -- bord gauche réel du contenu
    local frontProgress = progress
    if school and school.reverseDir then
        frontProgress = 1 - progress
    end
    local frontX  = fillLX + fillW * frontProgress

    currentFX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
end
