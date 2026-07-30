-- ============================================================
--  Opulent Casting Bars — Bar.lua
--  Création de la barre, gestion du cast, OnUpdate throttlé
-- ============================================================

SCB.Bar = {}

local UPDATE_RATE = 0.016  -- ~60 fps logique

local function TruncateSpellName(text)
    if type(text) ~= "string" then return "" end
    if not (SCB and SCB.Config and SCB.Config.Get and SCB.Config:Get("textNameTruncate")) then
        return text
    end
    local maxChars = 30
    if #text <= maxChars then return text end
    return text:sub(1, maxChars - 3) .. "..."
end

local function Clamp01(v)
    v = tonumber(v) or 0
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

local function ResolveBarDimensions(school, rawW, rawH)
    local cfg = SCB.Config
    local defaultW = (cfg.defaults and cfg.defaults.barWidth) or 400
    local defaultH = (cfg.defaults and cfg.defaults.barHeight) or 200
    local configuredW = tonumber(rawW) or tonumber(cfg:Get("barWidth")) or defaultW
    local configuredH = tonumber(rawH) or tonumber(cfg:Get("barHeight")) or defaultH
    local barScale = tonumber(school and school.barScale) or 1

    return math.floor(configuredW * barScale + 0.5),
           math.floor(configuredH * barScale + 0.5)
end


-- ============================================================
--  CRÉATION
-- ============================================================

function SCB.Bar:Create()
    local cfg = SCB.Config
    local w   = cfg:Get("barWidth")
    local h   = cfg:Get("barHeight")

    -- ---- Wrapper pour le fade (parent de f) -----------------
    -- Le fade agit sur ce wrapper, f reste Show() en permanence
    -- donc OnUpdate continue de tourner pendant le fade.
    local wrapper = CreateFrame("Frame", "OpulentCastingBarsWrapper", UIParent)
    wrapper:SetSize(w, h)
    wrapper:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM")
    wrapper:SetMovable(true)
    wrapper:SetClampedToScreen(true)
    wrapper:EnableMouse(false)
    -- Laisse les clics traverser la barre (target/interactions monde)
    -- tout en conservant la possibilité de drag quand elle est déverrouillée.
    if wrapper.SetPropagateMouseClicks then
        wrapper:SetPropagateMouseClicks(true)
    end
    wrapper:Hide()

    wrapper:SetScript("OnMouseDown", function(_, btn)
        if btn == "LeftButton" and not SCB.Config:Get("locked") then
            wrapper:StartMoving()
        end
    end)
    wrapper:SetScript("OnMouseUp", function()
        wrapper:StopMovingOrSizing()
        local point, _, _, x, y = wrapper:GetPoint()
        SCB.Config:Set("anchor", point)
        SCB.Config:Set("x", x)
        SCB.Config:Set("y", y)
    end)

    -- ---- Conteneur principal (enfant du wrapper) ------------
    local f = CreateFrame("Frame", "OpulentCastingBarsFrame", wrapper)
    f:SetAllPoints(wrapper)
    f:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM")

    -- ---- Couche 4 : Fond (BG) --------------------------------
    local texBGLight = f:CreateTexture(nil, "BACKGROUND", nil, 1)
    texBGLight:SetAllPoints(f)
    texBGLight:SetAlpha(0)
    texBGLight:SetBlendMode("ADD")

    local texBG = f:CreateTexture(nil, "BACKGROUND")
    texBG:SetAllPoints(f)

    -- ---- Couche 3 : Fill avec masque gauche→droite ----------
    local texFill = f:CreateTexture(nil, "ARTWORK")
    texFill:SetAllPoints(f)

    local texMask = f:CreateMaskTexture()
    texMask:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    texMask:SetPoint("TOPLEFT",    f, "TOPLEFT")
    texMask:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
    texMask:SetWidth(1)
    texFill:AddMaskTexture(texMask)

    -- ---- Couche 2 : Frame / bordure -------------------------
    local texFrame = f:CreateTexture(nil, "OVERLAY")
    texFrame:SetAllPoints(f)

    -- ---- Couche 2b : Frame Light — ADD, suit la progression (ex: Lava) ----
    local texFrameLight = f:CreateTexture(nil, "OVERLAY", nil, 2)
    texFrameLight:SetAllPoints(f)
    texFrameLight:SetAlpha(0)
    texFrameLight:SetBlendMode("ADD")

    local frameLightClip, texFrameLightClip
    if SCB.Clip and SCB.Clip.New then
        frameLightClip = SCB.Clip:New(f)
        if frameLightClip.SetFrameLevel and f.GetFrameLevel then
            frameLightClip:SetFrameLevel((f:GetFrameLevel() or 0) + 8)
        end
        local child = frameLightClip:GetChild()
        if child.SetFrameLevel and f.GetFrameLevel then
            child:SetFrameLevel((f:GetFrameLevel() or 0) + 8)
        end
        texFrameLightClip = child:CreateTexture(nil, "OVERLAY")
        texFrameLightClip:SetAllPoints(child)
        texFrameLightClip:SetAlpha(0)
        texFrameLightClip:SetBlendMode("ADD")
        frameLightClip:Hide()
    end

    -- ---- Couche 1 : Contour d'école (tout au-dessus) --------
    local texContour = f:CreateTexture(nil, "OVERLAY", nil, 1)
    texContour:SetAllPoints(f)

    -- ---- Texte : Nom du sort --------------------------------
    local spellNameFS = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    spellNameFS:SetPoint("LEFT", f, "LEFT", 66, 6)  -- +20px
    spellNameFS:SetJustifyH("LEFT")
    spellNameFS:SetTextColor(1, 1, 1, 1)
    spellNameFS:SetShadowOffset(1, -1)
    spellNameFS:SetFont(spellNameFS:GetFont(), 11)  -- réduit de 30% (~15→11)

    -- ---- Texte : Timer --------------------------------------
    local castTimerFS = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    castTimerFS:SetPoint("RIGHT", f, "RIGHT", -60, 6)  -- +20px
    castTimerFS:SetJustifyH("RIGHT")
    castTimerFS:SetTextColor(1, 1, 1, 0.9)
    castTimerFS:SetShadowOffset(1, -1)
    castTimerFS:SetFont(castTimerFS:GetFont(), 11)  -- réduit de 30%

    -- ---- Couches supplémentaires Fire (masquées par défaut) ----
    -- BG_Red : révélé progressivement comme FrostBG
    local texBGRed = f:CreateTexture(nil, "BACKGROUND", nil, 0)
    texBGRed:SetAllPoints(f)
    texBGRed:SetAlpha(0)
    local maskBGRed = f:CreateMaskTexture()
    maskBGRed:SetTexture("Interface\\BUTTONS\\WHITE8X8",
                         "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    maskBGRed:SetPoint("TOPLEFT",    f, "TOPLEFT")
    maskBGRed:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
    maskBGRed:SetWidth(1)
    texBGRed:AddMaskTexture(maskBGRed)

    -- Frame_Red : révélé progressivement par-dessus Frame_Fire
    local texFrameRed = f:CreateTexture(nil, "OVERLAY", nil, 1)
    texFrameRed:SetAllPoints(f)
    texFrameRed:SetAlpha(0)
    texFrameRed:SetBlendMode("BLEND")
    local maskFrameRed = f:CreateMaskTexture()
    maskFrameRed:SetTexture("Interface\\BUTTONS\\WHITE8X8",
                            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    maskFrameRed:SetPoint("TOPLEFT",    f, "TOPLEFT")
    maskFrameRed:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
    maskFrameRed:SetWidth(1)
    texFrameRed:AddMaskTexture(maskFrameRed)

    -- Fill Effects (x6) : au-dessus du Fill, animés en cycle
    local texFillEffects = {}
    for i = 1, 6 do
        local t = f:CreateTexture(nil, "ARTWORK", nil, 1)
        t:SetAllPoints(f)
        t:SetAlpha(0)
        t:SetBlendMode("BLEND")
        texFillEffects[i] = t
    end

    -- Contours animés (x6) : au-dessus de tout, remplacent texContour pour Fire
    local texContoursFire = {}
    for i = 1, 6 do
        local t = f:CreateTexture(nil, "OVERLAY", nil, 2)
        t:SetAllPoints(f)
        t:SetAlpha(0)
        t:SetBlendMode("BLEND")
        texContoursFire[i] = t
    end

    local texGivreFrostfire = f:CreateTexture(nil, "OVERLAY", nil, 1)
    texGivreFrostfire:SetAllPoints(f)
    texGivreFrostfire:SetAlpha(0)
    local maskGivreFrostfire = f:CreateMaskTexture()
    maskGivreFrostfire:SetTexture("Interface\\BUTTONS\\WHITE8X8",
                                  "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    maskGivreFrostfire:SetPoint("TOPLEFT",    f, "TOPLEFT")
    maskGivreFrostfire:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
    maskGivreFrostfire:SetWidth(1)
    texGivreFrostfire:AddMaskTexture(maskGivreFrostfire)

    -- Fill Effects Frostfire (x5) : flammes animées, masquées par progression
    local texFillEffectsFrostfire = {}
    for i = 1, 5 do
        local t = f:CreateTexture(nil, "ARTWORK", nil, 1)
        t:SetAllPoints(f)
        t:SetAlpha(0)
        texFillEffectsFrostfire[i] = t
    end

    -- ---- Couches Split Fill Aim (double fill symétrique → centre) ----
    -- Fill gauche : depuis le bord gauche vers le centre
    -- Bronze sand sheet. The artwork lives in a full-bar texture with a small
    -- alpha island, so it must be sized from the current bar, not the TGA size.
    local sableFrame = CreateFrame("Frame", nil, f)
    sableFrame:SetSize(w, h)
    sableFrame:SetPoint("CENTER", f, "CENTER", 0, 0)
    sableFrame:SetFrameLevel(f:GetFrameLevel())
    sableFrame:Hide()
    local texSabre = sableFrame:CreateTexture(nil, "BACKGROUND", nil, -2)
    texSabre:SetAllPoints(sableFrame)
    texSabre:SetAlpha(0)
    texSabre:SetBlendMode("BLEND")
    texSabre:Hide()

    local sableAG = sableFrame:CreateAnimationGroup()
    local sableTrans = sableAG:CreateAnimation("Translation")
    if sableTrans.SetSmoothing then
        sableTrans:SetSmoothing("NONE")
    end
    sableAG:SetLooping("NONE")

    local texFillLeft = f:CreateTexture(nil, "ARTWORK")
    texFillLeft:SetAllPoints(f)
    texFillLeft:SetAlpha(0)
    local maskFillLeft = f:CreateMaskTexture()
    maskFillLeft:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    maskFillLeft:SetPoint("TOPLEFT",    f, "TOPLEFT")
    maskFillLeft:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
    maskFillLeft:SetWidth(1)
    texFillLeft:AddMaskTexture(maskFillLeft)

    -- Fill droit : depuis le bord droit vers le centre
    local texFillRight = f:CreateTexture(nil, "ARTWORK")
    texFillRight:SetAllPoints(f)
    texFillRight:SetAlpha(0)
    local maskFillRight = f:CreateMaskTexture()
    maskFillRight:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    maskFillRight:SetPoint("TOPRIGHT",    f, "TOPRIGHT")
    maskFillRight:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
    maskFillRight:SetWidth(1)
    texFillRight:AddMaskTexture(maskFillRight)

    -- Texture flash fin de cast (apparaît à ~97%)
    local texFillEnding = f:CreateTexture(nil, "ARTWORK", nil, 2)
    texFillEnding:SetAllPoints(f)
    texFillEnding:SetAlpha(0)
    texFillEnding:SetBlendMode("ADD")

    local particleContainer = CreateFrame("Frame", "SCBParticleContainer", f)
    particleContainer:SetPoint("CENTER", f, "CENTER")
    particleContainer:SetSize(w + 120, h + 120)
    particleContainer:SetFrameLevel(f:GetFrameLevel() + 10)

    -- ---- OnUpdate sur frame principal -----------------------
    -- Le frame est Show() avant le premier tick donc OnUpdate
    -- démarre immédiatement sans délai.
    -- accum est exposé dans self pour pouvoir être remis à zéro
    -- depuis StartCast.
    self._accum = 0
    f:SetScript("OnUpdate", function(_, dt)
        self._accum = self._accum + dt
        if self._accum < UPDATE_RATE then return end
        SCB.Bar:_Tick(self._accum)
        self._accum = 0
    end)

    -- ---- Références ----------------------------------------
    self.frame             = wrapper   -- le reste du code utilise self.frame pour position/alpha/show
    self.frameInner        = f         -- OnUpdate tourne ici, toujours visible quand wrapper visible
    self.texBGLight        = texBGLight
    self.texBG             = texBG
    self.texFill           = texFill
    self.texMask           = texMask
    self.texFrame          = texFrame
    self.texFrameLight     = texFrameLight
    self.frameLightClip    = frameLightClip
    self.texFrameLightClip = texFrameLightClip
    self.texContour        = texContour
    self.spellNameText     = spellNameFS
    self.castTimerText     = castTimerFS
    self.particleContainer = particleContainer

    self.texBGRed        = texBGRed
    self.maskBGRed       = maskBGRed
    self.texFrameRed     = texFrameRed
    self.maskFrameRed    = maskFrameRed
    self.texFillEffects  = texFillEffects
    self.texContoursFire = texContoursFire

    self.texGivreFrostfire        = texGivreFrostfire
    self.maskGivreFrostfire       = maskGivreFrostfire
    self.texFillEffectsFrostfire  = texFillEffectsFrostfire
    self.texSabre                 = texSabre
    self.sableFrame               = sableFrame
    self.sableAG                  = sableAG
    self.sableTrans               = sableTrans

    self.texFillLeft    = texFillLeft
    self.maskFillLeft   = maskFillLeft
    self.texFillRight   = texFillRight
    self.maskFillRight  = maskFillRight
    self.texFillEnding  = texFillEnding

    -- Relier les FillEffects au masque de progression (créé avant)
    for _, t in ipairs(texFillEffects) do
        t:AddMaskTexture(texMask)
    end
    -- BG Light suit aussi la progression
    texBGLight:AddMaskTexture(texMask)
    -- Frame Light suit la progression (ex: Lava, Felfire)
    texFrameLight:AddMaskTexture(texMask)
    -- Relier les FillEffects Frostfire au masque de progression
    -- (pas texGivreFrostfire : elle a son propre maskGivreFrostfire,
    --  ce qui permet de la fade out indépendamment via FX.UpdateFade)
    for _, t in ipairs(texFillEffectsFrostfire) do
        t:AddMaskTexture(texMask)
    end

    -- État
    self.isActive   = false
    self.isFading   = false   -- true pendant le fade out → bloque tout nouveau StopCast
    self.castStart  = 0
    self.castEnd    = 0
    self.currentSchool = nil

    -- wrapper est déjà Hide() par défaut, f suit son parent

    -- Init des effets de particules (doit être après création du frame)
    SCB.Particles:Init()
end

function SCB.Bar:GetSableDrop()
    local school = self.currentSchool
    local baseDrop = (school and school.sableDropPx) or 23
    local h = (self.frameInner and self.frameInner:GetHeight()) or 0
    local defaultH = (SCB.Config.defaults and SCB.Config.defaults.barHeight) or h
    if not defaultH or defaultH <= 0 then defaultH = 200 end
    if not h or h <= 0 then h = defaultH end
    return baseDrop * (h / defaultH)
end

function SCB.Bar:LayoutSable(progress, force)
    if not (self.sableFrame and self.texSabre and self.frameInner) then return end

    local w = self.frameInner:GetWidth()
    local h = self.frameInner:GetHeight()
    if not w or w <= 0 or not h or h <= 0 then return end

    local drop = self:GetSableDrop()
    local y = -drop * Clamp01(progress)

    if force or self._sabreLayoutW ~= w or self._sabreLayoutH ~= h or self._sabreLayoutY ~= y then
        self.sableFrame:SetSize(w, h)
        self.sableFrame:ClearAllPoints()
        self.sableFrame:SetPoint("CENTER", self.frameInner, "CENTER", 0, y)
        self._sabreLayoutW = w
        self._sabreLayoutH = h
        self._sabreLayoutY = y
    end

    self._sabreDropPx = drop
end

function SCB.Bar:GetSableProgress()
    local now = GetTime()
    local startTime = self._sabreStartTime or now
    local endTime = self._sabreEndTime or self.castEnd or now
    return Clamp01((now - startTime) / math.max(endTime - startTime, 0.001))
end

function SCB.Bar:ResetSable()
    if self.sableAG then self.sableAG:Stop() end
    self._sabreActive = false
    self._sabreDropPx = nil
    self._sabreStartTime = nil
    self._sabreEndTime = nil
    self._sabreLayoutW = nil
    self._sabreLayoutH = nil
    self._sabreLayoutY = nil
    self:LayoutSable(0, true)
    if self.texSabre then
        self.texSabre:SetAlpha(0)
        self.texSabre:Hide()
    end
    if self.sableFrame then
        self.sableFrame:Hide()
    end
end

function SCB.Bar:StartSable()
    local school = self.currentSchool
    if not (school and school.sable and self.sableFrame and self.texSabre) then
        self:ResetSable()
        return
    end

    if self.sableAG then self.sableAG:Stop() end
    self.texSabre:SetTexture(school.sable)
    self:LayoutSable(0, true)
    self.sableFrame:Show()
    self.texSabre:SetAlpha(1)
    self.texSabre:Show()
    self._sabreActive = true

    local now = GetTime()
    self._sabreStartTime = now
    self._sabreEndTime = self.castEnd or (now + 5)
end

function SCB.Bar:FreezeSableAtProgress(progress)
    if not self._sabreActive then return end
    if self.sableAG then self.sableAG:Stop() end
    self:LayoutSable(progress, true)
end

function SCB.Bar:PlaySableFromProgress(progress)
    if not self._sabreActive then return end
    progress = Clamp01(progress)
    if self.sableAG then self.sableAG:Stop() end
    local now = GetTime()
    local endTime = self._sabreEndTime or self.castEnd or now
    if progress < 1 and endTime > now then
        local total = (endTime - now) / math.max(1 - progress, 0.001)
        self._sabreStartTime = now - total * progress
        self._sabreEndTime = endTime
    end
    self:LayoutSable(progress, true)
end

function SCB.Bar:UpdateGenericLightClips(progress)
    local f = self.frameInner
    if not f then return end

    local w = f:GetWidth()
    local h = f:GetHeight()
    if not w or w <= 0 or not h or h <= 0 then return end

    progress = Clamp01(progress)
    if self._frameLightClipActive and self.frameLightClip and self.texFrameLightClip then
        self.texFrameLightClip:SetAlpha(self._frameLightAlpha or 1)
        self.frameLightClip:Layout(f, 0, w, 0, h, progress)
    elseif self.frameLightClip then
        self.frameLightClip:Hide()
    end
end

-- ============================================================
--  CHARGEMENT D'UNE ÉCOLE
-- ============================================================

function SCB.Bar:ApplySchool(schoolKey)
    local school = SCB.Schools:Get(schoolKey)
    if not school then return end

    local appliedW, appliedH = ResolveBarDimensions(school)
    self:ApplyDimensions(appliedW, appliedH)

    self.texBG:SetTexture(school.bg)
    if school.bgLight then
        self.texBGLight:SetTexture(school.bgLight)
        self.texBGLight:SetBlendMode(school.bgLightBlend or "ADD")
        self.texBGLight:SetAlpha(school.bgLightAlpha or 1)
        self.texBGLight:Show()
    else
        self.texBGLight:Hide()
    end
    local useGenericFrameLight = school.frameLight
    if useGenericFrameLight then
        self._frameLightAlpha = school.frameLightAlpha or 1
        if self.frameLightClip and self.texFrameLightClip then
            self.texFrameLight:Hide()
            self.texFrameLight:SetAlpha(0)
            self.texFrameLightClip:SetTexture(school.frameLight)
            self.texFrameLightClip:SetBlendMode(school.frameLightBlend or "ADD")
            self.texFrameLightClip:SetAlpha(self._frameLightAlpha)
            self._frameLightClipActive = true
        else
            if self.frameLightClip then self.frameLightClip:Hide() end
            if self.texFrameLightClip then self.texFrameLightClip:SetAlpha(0) end
            self.texFrameLight:SetTexture(school.frameLight)
            self.texFrameLight:SetBlendMode(school.frameLightBlend or "ADD")
            self.texFrameLight:SetAlpha(self._frameLightAlpha) ; self.texFrameLight:Show()
            self._frameLightClipActive = false
        end
    else
        self._frameLightAlpha = nil
        self.texFrameLight:SetBlendMode("ADD")
        self.texFrameLight:Hide()
        if self.frameLightClip then self.frameLightClip:Hide() end
        if self.texFrameLightClip then self.texFrameLightClip:SetAlpha(0) end
        self._frameLightClipActive = false
    end

    self.texFill:SetTexture(school.fill)
    -- Écoles avec fill custom (ex: Arcane) cachent texFill
    -- Pour splitFill (ex: Aim), texFill + texMask gèrent le fill gauche
    if school.fillMask then
        self.texFill:SetAlpha(0)
    else
        self.texFill:SetAlpha(1)
    end
    if school.frames then
        -- Frames animées : réinitialiser via le FX directement
        -- pour éviter tout flash (pas de SetAlpha(0) nécessaire)
        local fx = SCB.FX and SCB.FX["nature"]
        if fx and fx.ResetFrame then
            fx.ResetFrame()
        else
            self.texFrame:SetTexture(school.frames[1])
        end
        self.texFrame:SetAlpha(1)
    else
        self.texFrame:SetTexture(school.frame)
        self.texFrame:SetAlpha(1)
    end

    -- BG toujours pleinement visible dès le début du cast
    self.texBG:SetAlpha(1)

    -- Reset couches Fire (cachées par défaut) — Hide() plutôt que SetAlpha(0)
    -- retire ces grands quads plein-barre du rendu tant qu'ils ne servent pas.
    self.texBGRed:SetAlpha(0)
    self.texBGRed:SetVertexColor(1, 1, 1)
    self.texBGRed:SetTexCoord(0, 1, 0, 1)
    self.texBGRed:Hide()
    self.maskBGRed:SetWidth(1)
    self.texFrameRed:SetAlpha(0)
    self.texFrameRed:SetVertexColor(1, 1, 1)
    self.texFrameRed:SetTexCoord(0, 1, 0, 1)
    self.texFrameRed:SetBlendMode("BLEND")
    self.texFrameRed:Hide()
    self.maskFrameRed:SetWidth(1)
    for _, t in ipairs(self.texFillEffects) do
        t:SetAlpha(0)
        t:SetVertexColor(1, 1, 1)
        t:SetTexCoord(0, 1, 0, 1)
        t:SetBlendMode("BLEND")
        t:Hide()
    end
    for _, t in ipairs(self.texContoursFire) do
        t:SetAlpha(0)
        t:SetVertexColor(1, 1, 1)
        t:SetTexCoord(0, 1, 0, 1)
        t:SetBlendMode("BLEND")
        t:Hide()
    end

    -- Reset couches Frostfire (cachées par défaut)
    self.texGivreFrostfire:Hide()
    self.maskGivreFrostfire:SetWidth(1)
    for _, t in ipairs(self.texFillEffectsFrostfire) do t:Hide() end

    -- Reset couches Split Fill Aim (cachées par défaut)
    self.texFillLeft:SetAlpha(0)
    self.texFillRight:SetAlpha(0)
    self.texFillEnding:SetAlpha(0)
    self.maskFillLeft:SetWidth(1)
    self.maskFillRight:SetWidth(1)
    self._aimEndingFired = false
    self._aimEndingT     = 0
    self:ResetSable()

    if school.bgRed then
        -- École avec couches animées complètes (Fire & co)
        self.texBGRed:SetTexture(school.bgRed)
        self.texBGRed:SetVertexColor(1, 1, 1)
        self.texBGRed:SetTexCoord(0, 1, 0, 1)
        self.texBGRed:SetAlpha(1) ; self.texBGRed:Show()
        self.texFrameRed:SetTexture(school.frameRed)
        self.texFrameRed:SetVertexColor(1, 1, 1)
        self.texFrameRed:SetTexCoord(0, 1, 0, 1)
        self.texFrameRed:SetBlendMode("BLEND")
        self.texFrameRed:SetAlpha(1) ; self.texFrameRed:Show()
        -- Contour de base caché — les contours animés prennent le relais
        self.texContour:Hide()
        if school.fillEffects then
            for i, t in ipairs(self.texFillEffects) do
                t:SetTexture(school.fillEffects[i] or school.fillEffects[1])
                t:SetVertexColor(1, 1, 1)
                t:SetTexCoord(0, 1, 0, 1)
                t:SetBlendMode("BLEND")
            end
        end
        if school.contours then
            for i, t in ipairs(self.texContoursFire) do
                t:SetTexture(school.contours[i] or school.contours[1])
                t:SetVertexColor(1, 1, 1)
                t:SetTexCoord(0, 1, 0, 1)
                t:SetBlendMode("BLEND")
            end
        end
    elseif school.frostfireEffects then
        -- École Frostfire : givre + effets de flamme revelés par progression
        self.texContour:Hide()
        self.texGivreFrostfire:SetTexture(school.frostfireGivre)
        self.texGivreFrostfire:SetAlpha(1) ; self.texGivreFrostfire:Show()
        for i, t in ipairs(self.texFillEffectsFrostfire) do
            t:SetTexture(school.frostfireEffects[i] or school.frostfireEffects[1])
        end
    elseif school.contours then
        -- École avec contours animés uniquement (Shadow & co), sans BGRed
        self.texContour:Hide()
        for i, t in ipairs(self.texContoursFire) do
            t:SetTexture(school.contours[i] or school.contours[1])
            t:SetVertexColor(1, 1, 1)
            t:SetTexCoord(0, 1, 0, 1)
            t:SetBlendMode("BLEND")
            -- Les alphas seront gérés par le module FX
        end
    else
        -- École simple : contour statique
        if school.contour then
            self.texContour:SetTexture(school.contour)
            self.texContour:SetAlpha(1) ; self.texContour:Show()
        else
            self.texContour:Hide()
        end
    end

    -- Thème à double fill symétrique (ex: Aim)
    -- texFill + texMask (mécanisme standard) gèrent le fill gauche (bord gauche → centre)
    -- texFillRight + maskFillRight gèrent le fill droit (bord droit → centre)
    if school.splitFill then
        -- Fill droit
        if school.fillRight then
            self.texFillRight:SetTexture(school.fillRight)
            self.texFillRight:SetAlpha(1)
        end
        -- Texture de fin (flash à 97%)
        if school.fillEnding then
            self.texFillEnding:SetTexture(school.fillEnding)
        end
        -- Ancrer le masque droit selon la marge du thème
        local bW = self.frame:GetWidth()
        local oR = bW * (school.fillMarginR or 0)
        self.maskFillRight:ClearAllPoints()
        self.maskFillRight:SetPoint("TOPRIGHT",    self.frameInner, "TOPRIGHT",    -oR, 0)
        self.maskFillRight:SetPoint("BOTTOMRIGHT", self.frameInner, "BOTTOMRIGHT", -oR, 0)
        self.maskFillRight:SetWidth(1)
    end

    self.currentSchool    = school
    self.currentSchoolKey = schoolKey

    if school.sable then
        self:StartSable()
    end

    -- Décalage des textes selon l'école
    local nameOffX  = school.textNameOffX  or 0
    local timerOffX = school.textTimerOffX or 0
    local textOffY  = school.textOffY      or 0
    self.spellNameText:ClearAllPoints()
    self.castTimerText:ClearAllPoints()
    self.spellNameText:SetPoint("LEFT",  self.frameInner, "LEFT",  66 + nameOffX,   4 + textOffY)
    self.castTimerText:SetPoint("RIGHT", self.frameInner, "RIGHT", -60 + timerOffX, 4 + textOffY)

    -- Stocker les marges Fill — le masque sera réancré dans _Tick
    self.fillMarginL  = school.fillMarginL or 0
    self.fillMarginR  = school.fillMarginR or 0
    self._maskOffsetL   = nil  -- force le réancrage au prochain tick
    self._maskOffsetR   = nil
    self._maskReverseDir = nil
end

-- ============================================================
--  CONTRÔLE DU CAST
-- ============================================================

function SCB.Bar:StartCast(spellName, duration, schoolKey, isChannel, spellIcon)
    if not self.frame then return end
    if duration <= 0 then return end

    self.castGeneration = (self.castGeneration or 0) + 1
    local wasActive = self.isActive or self.isFading

    SCB.Animations:Cancel(self.frame)
    self.isFading          = false
    self.isActive          = true
    self.isChannel         = isChannel or false
    self.castStart  = GetTime() - duration * 0.10
    self.castEnd    = GetTime() + duration
    self._accum     = 0
    self.currentSpellIcon = spellIcon
    self.currentSpellName = spellName or ""

    -- Mode dynamique : masquer la barre Blizzard pendant ce cast OCB
    if SCB._blizzardDynamic then
        SCB.HideBlizzardBarFrames(true)
    end

    -- Garantit que l'échelle de la barre correspond toujours au réglage courant,
    -- y compris pour les barres neutres (monture) et le bouton de test.
    self.frame:SetScale(SCB.Config:Get("scale") or 0.8)

    self:ApplySchool(schoolKey or "frost")

    if SCB.Config:Get("showSpellName") then
        self.spellNameText:SetText(TruncateSpellName(self.currentSpellName))
    else
        self.spellNameText:SetText("")
    end
    if SCB.Config:Get("showCastTime") then
        self._timerTenth = nil
        self.castTimerText:SetText(string.format("%.1f", duration))
    else
        self.castTimerText:SetText("")
    end

    -- Appliquer les prefs visuelles du texte
    SCB.Bar:ApplyTextPrefs()

    self.texMask:SetWidth(self.frame:GetWidth() * 0.10)

    -- Show before lazy FX init so first-use mask/clip layers are created
    -- against a visible bar. Preview already did this, which is why some
    -- styles only worked after opening preview first.
    self.frame:SetAlpha(1)
    self.frame:Show()

    SCB.Particles:Start(duration)
    self:_Tick(UPDATE_RATE)
    if wasActive then
        SCB.Animations:FlashRecast()
    end
end

function SCB.Bar:StopCast(success)
    if not self.isActive then return end
    if self.isFading then return end

    self.isActive = false
    self.isFading = true

    if self._sabreActive then
        self:FreezeSableAtProgress(self:GetSableProgress())
    end

    local gen = self.castGeneration  -- capture la génération de ce cast

    SCB.Particles:Stop(success)

    if success then
        -- Fixer les masques à leur position finale pour un fade-out synchrone.
        if self.currentSchool and self.currentSchool.splitFill then
            -- Double fill : bloquer les deux masques au centre (halfFillW) pour disparaître ensemble
            local barW  = self.frame:GetWidth()
            local fillW = barW * (1 - (self.fillMarginL or 0) - (self.fillMarginR or 0))
            local halfFillW = fillW * 0.5
            self.texMask:SetWidth(halfFillW)
            self.maskFillRight:SetWidth(halfFillW)
            self:UpdateGenericLightClips(1)
        elseif not (self.currentSchool and self.currentSchool.reverseFill) then
            -- Styles normaux : étendre le masque sur toute la largeur
            self.texMask:SetWidth(self.frame:GetWidth())
            self:UpdateGenericLightClips(1)
        end
        SCB.Animations:PlayComplete(self.frame, gen, function()
            self.isFading = false
            self:ResetSable()
            SCB.Particles:ResetAll()
            if not self.isActive and SCB.Config:Get("hideWhenIdle") then
                self.frame:Hide()
            end
        end)
    else
        SCB.Animations:PlayFail(self.frame, function()
            self.isFading = false
            self:ResetSable()
            SCB.Particles:ResetAll()
            if not self.isActive and SCB.Config:Get("hideWhenIdle") then
                self.frame:Hide()
            end
        end)
    end
end

-- ============================================================
--  PUSHBACK
-- ============================================================

function SCB.Bar:ApplyPushback(newStartSec, newEndSec)
    if not self.isActive then return end
    local sableProgress = self._sabreActive and self:GetSableProgress() or nil
    self.castStart = newStartSec
    self.castEnd   = newEndSec
    if sableProgress then
        self._sabreEndTime = newEndSec
        self:PlaySableFromProgress(sableProgress)
    end
    SCB.Animations:PlayPushback(self.frameInner)
end

-- ============================================================
--  TICK
-- ============================================================

function SCB.Bar:_Tick(elapsed)
    -- Pendant le fade out, on continue uniquement pour les cercles Shadow
    if self.isFading and not self.isActive then
        SCB.Particles:UpdateCirclesFade(elapsed)
        return
    end

    if not self.isActive then return end

    local now       = GetTime()
    local total     = self.castEnd - self.castStart
    local progress  = math.min((now - self.castStart) / total, 1)
    local remaining = math.max(self.castEnd - now, 0)

    -- Pour les sorts canalisés (ou styles inversés), la barre se vide progressivement
    -- Exception : la barre Aim (splitFill) ou les thèmes avec noReverse=true progressent
    -- toujours dans le sens normal, même pour un sort canalisé.
    local isAim     = self.currentSchool and self.currentSchool.splitFill
    local noReverse = self.currentSchool and self.currentSchool.noReverse
    local reverseFill = (not isAim) and (not noReverse) and (self.isChannel or (self.currentSchool and self.currentSchool.reverseFill))
    local fillProgress = reverseFill and (1 - progress) or progress

    local barW = self.frame:GetWidth()
    local mL   = self.fillMarginL or 0
    local mR   = self.fillMarginR or 0
    local fillMarginLPx = (self.currentSchool and self.currentSchool.fillMarginLPx) or 0
    local fillMarginRPx = (self.currentSchool and self.currentSchool.fillMarginRPx) or 0
    local fillW = barW * (1 - mL - mR) - fillMarginLPx - fillMarginRPx
    local offsetL = barW * mL + fillMarginLPx
    local offsetR = barW * mR + fillMarginRPx
    local reverseDir = self.currentSchool and self.currentSchool.reverseDir
    if self._sabreActive then
        self:LayoutSable(self:GetSableProgress())
    end

    -- Réancrer le masque au bon offset si nécessaire
    if (not self._maskOffsetL) or (self._maskOffsetL ~= offsetL) or
       (not self._maskOffsetR) or (self._maskOffsetR ~= offsetR) or
       (self._maskReverseDir ~= reverseDir) then
        self._maskOffsetL = offsetL
        self._maskOffsetR = offsetR
        self._maskReverseDir = reverseDir
        self.texMask:ClearAllPoints()
        if reverseDir then
            self.texMask:SetPoint("TOPRIGHT",    self.frameInner, "TOPRIGHT",    -offsetR, 0)
            self.texMask:SetPoint("BOTTOMRIGHT", self.frameInner, "BOTTOMRIGHT", -offsetR, 0)
        else
            self.texMask:SetPoint("TOPLEFT",    self.frameInner, "TOPLEFT",    offsetL, 0)
            self.texMask:SetPoint("BOTTOMLEFT", self.frameInner, "BOTTOMLEFT", offsetL, 0)
        end
    end

    -- Pour splitFill : texMask est le fill gauche, plafonné à halfFillW (bord → centre)
    if self.currentSchool and self.currentSchool.splitFill then
        self.texMask:SetWidth(math.max(fillW * 0.5 * fillProgress, 1))
        self:UpdateGenericLightClips(fillProgress)
    else
        self.texMask:SetWidth(math.max(fillW * fillProgress, 1))
        self:UpdateGenericLightClips(fillProgress)
    end

    -- Thème à double fill symétrique (Aim) — masque droit uniquement
    -- (le fill gauche est géré par texMask standard, déjà mis à jour ci-dessus)
    if self.currentSchool and self.currentSchool.splitFill then
        local halfFillW = fillW * 0.5
        self.maskFillRight:SetWidth(math.max(halfFillW * fillProgress, 1))
        -- Flash de fin (Fill_Aim_Ending) : apparaît à 97% et pulse jusqu'à la fin
        if fillProgress >= 0.97 then
            if not self._aimEndingFired then
                self._aimEndingFired = true
                self._aimEndingT     = 0
            end
        end
        if self._aimEndingFired then
            self._aimEndingT = (self._aimEndingT or 0) + elapsed
            local flashAlpha = math.abs(math.sin(self._aimEndingT * math.pi / 0.16)) * 0.90
            self.texFillEnding:SetAlpha(flashAlpha)
        end
    end

    -- Mise à jour des effets de particules
    SCB.Particles:Update(elapsed, fillProgress)

    if SCB.Config:Get("showCastTime") then
        -- Only reformat/redraw when the displayed tenth actually changes
        -- (avoids ~50 string.format allocations per second during a cast).
        local tenth = math.floor(remaining * 10 + 0.5)
        if tenth ~= self._timerTenth then
            self._timerTenth = tenth
            self.castTimerText:SetText(string.format("%.1f", tenth * 0.1))
        end
    end

    if progress >= 1 then
        self:StopCast(true)
    end
end

-- ============================================================
--  UTILITAIRES
-- ============================================================

function SCB.Bar:Resize(w, h)
    SCB.Config:Set("barWidth", w)
    SCB.Config:Set("barHeight", h)
    local appliedW, appliedH = ResolveBarDimensions(self.currentSchool, w, h)
    self:ApplyDimensions(appliedW, appliedH)
    self._maskOffsetL = nil
    self._maskOffsetR = nil
    self._maskReverseDir = nil
    if self.spellNameText and self.castTimerText then
        self:ApplyTextPrefs()
    end
    if SCB.Particles and SCB.Particles.RefreshLayout then
        SCB.Particles:RefreshLayout()
    end
    if self._sabreActive then
        self:PlaySableFromProgress(self:GetSableProgress())
    else
        self:LayoutSable(0, true)
    end
    if self.isActive then
        self:_Tick(UPDATE_RATE)
    end
end

function SCB.Bar:ApplyDimensions(w, h)
    if self.frame then
        self.frame:SetSize(w, h)
    end
    if self.particleContainer then
        self.particleContainer:SetSize(w + 120, h + 120)
    end
    if SCB.Particles and SCB.Particles.LayoutFrames then
        SCB.Particles:LayoutFrames()
    end
end

-- ============================================================
--  PREFS DE TEXTE
-- ============================================================

-- Table de résolution couleur → RGBA
local TEXT_COLORS = {
    white  = { 1.0, 1.0, 1.0, 1.0 },
    yellow = { 1.0, 0.85, 0.0, 1.0 },
}

-- Couleurs par école pour le mode "school"
local SCHOOL_COLORS = {
    fire      = { 1.0, 0.4,  0.1,  1.0 },
    frost     = { 0.5, 0.85, 1.0,  1.0 },
    arctic    = { 0.62, 0.90, 1.0,  1.0 },
    arcane    = { 0.7, 0.4,  1.0,  1.0 },
    arcaneum  = { 0.62, 0.40, 1.0,  1.0 },
    shadow    = { 0.7, 0.2,  0.9,  1.0 },
    nature    = { 0.3, 0.9,  0.3,  1.0 },
    holy      = { 1.0, 0.9,  0.5,  1.0 },
    frostfire = { 0.4, 0.8,  1.0,  1.0 },
    thunder   = { 0.6, 0.7,  1.0,  1.0 },
    aim       = { 1.0, 0.25, 0.05, 1.0 },  -- rouge chasseur
    neutral   = { 1.0, 1.0,  1.0,  1.0 },
    metal     = { 0.95, 0.82, 0.58, 1.0 },
    metal_icon= { 0.95, 0.82, 0.58, 1.0 },
    engrenages= { 0.95, 0.82, 0.58, 1.0 },
    alliance  = { 0.3, 0.6,  1.0,  1.0 },
    horde     = { 1.0, 0.2,  0.1,  1.0 },
}

function SCB.Bar:ApplyTextPrefs()
    local cfg = SCB.Config
    local school = self.currentSchoolKey or "neutral"
    local school_data = SCB.Schools:Get(school)
    -- Offsets école (non appliqués en mode centré, par design)
    local schoolNameOffX  = (school_data and school_data.textNameOffX)  or 0
    local schoolTimerOffX = (school_data and school_data.textTimerOffX) or 0
    local schoolOffY      = (school_data and school_data.textOffY)      or 0
    -- Offsets globaux réglables par l'utilisateur
    local userNamePosX  = cfg:Get("textNamePosX")  or 0
    local userTimerPosX = cfg:Get("textTimerPosX") or 0
    -- Offsets combinés (école + utilisateur) pour les alignements gauche/droite
    local nameOffX  = schoolNameOffX  + userNamePosX
    local timerOffX = schoolTimerOffX + userTimerPosX
    local nameOffY  = schoolOffY + (cfg:Get("textNamePosY")  or 0)
    local timerOffY = schoolOffY + (cfg:Get("textTimerPosY") or 0)
    local defaultW  = (SCB.Config.defaults and SCB.Config.defaults.barWidth) or 400
    local barW      = (self.frameInner and self.frameInner:GetWidth())
                   or (self.frame and self.frame:GetWidth())
                   or cfg:Get("barWidth")
                   or defaultW
    if defaultW <= 0 then defaultW = 400 end
    if not barW or barW <= 0 then barW = defaultW end
    local widthScale = barW / defaultW
    local leftInset  = 66 * widthScale
    local rightInset = 60 * widthScale

    -- ---- Police -----------------------------------------------
    local fontKey   = cfg:Get("fontFace") or "DEFAULT"
    local outline   = cfg:Get("textOutline") and "OUTLINE" or ""
    local KENYAN    = "Interface\\AddOns\\OpulentCastingBars\\Fonts\\KenyanCoffee.otf"
    local BLIZZARD  = "Fonts\\FRIZQT__.TTF"   -- police Blizzard UI par défaut
    local function resolveFace(fs)
        if fontKey == "DEFAULT" then
            return KENYAN
        elseif fontKey == "BLIZZARD" then
            return BLIZZARD
        elseif fontKey == "GAME_CHINESE" then
            local locale = GetLocale and GetLocale() or ""
            return (locale == "zhTW") and "Fonts\\ARKai_T.ttf" or "Fonts\\ARKai_C.ttf"
        end
        -- Try LibSharedMedia first (covers OCB bundled fonts + external fonts).
        -- noDefault=true: if the key isn't registered don't silently return the
        -- LSM default (Friz Quadrata); let us decide the fallback instead.
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        if LSM then
            local path = LSM:Fetch(LSM.MediaType.FONT, fontKey, true)
            if path then return path end
        end
        -- Legacy fallback: pre-LSM config values stored as bare filenames
        -- (e.g. "Gaegu-Bold.ttf" from saves made before the LSM migration).
        -- "%.[a-z]" matches a literal dot followed by a letter (.ttf, .otf …)
        if fontKey:find("%.[a-z]") then
            return "Interface\\AddOns\\OpulentCastingBars\\Fonts\\" .. fontKey
        end
        return KENYAN
    end

    -- ---- Mode centré ------------------------------------------
    -- "textCentered" = nom à gauche du centre, timer à droite du centre
    -- Les alignements individuels sont ignorés dans ce mode
    local centered  = cfg:Get("textCentered")

    -- ---- Couleurs ---------------------------------------------
    local function resolveColor(colorKey)
        if colorKey == "custom" then
            local col = cfg:Get("textCustomColor") or {r=1,g=1,b=1}
            return col.r, col.g, col.b, 1
        elseif colorKey == "school" then
            return unpack(SCHOOL_COLORS[school] or TEXT_COLORS.white)
        end
        return unpack(TEXT_COLORS[colorKey] or TEXT_COLORS.white)
    end

    -- ---- Nom du sort ------------------------------------------
    local nameFS       = self.spellNameText
    local nameSize     = cfg:Get("textNameSize")  or 11
    local nameAlign    = cfg:Get("textNameAlign") or "LEFT"
    local nr, ng, nb, na = resolveColor(cfg:Get("textNameColor") or "white")

    nameFS:SetFont(resolveFace(nameFS), nameSize, outline)
    nameFS:SetTextColor(nr, ng, nb, na)
    if cfg:Get("showSpellName") then
        nameFS:SetText(TruncateSpellName(self.currentSpellName or ""))
    else
        nameFS:SetText("")
    end

    nameFS:ClearAllPoints()
    if centered then
        nameFS:SetJustifyH("RIGHT")
        nameFS:SetWidth(barW * 0.42)
        nameFS:SetPoint("RIGHT", self.frameInner, "CENTER", 6 + userNamePosX, 4 + nameOffY)
    elseif nameAlign == "CENTER" then
        nameFS:SetJustifyH("CENTER")
        nameFS:SetWidth(barW * 0.6)
        nameFS:SetPoint("CENTER", self.frameInner, "CENTER", userNamePosX, 4 + nameOffY)
    elseif nameAlign == "RIGHT" then
        nameFS:SetJustifyH("RIGHT")
        nameFS:SetWidth(0)
        nameFS:SetPoint("RIGHT", self.frameInner, "RIGHT", -rightInset + nameOffX, 4 + nameOffY)
    else
        nameFS:SetJustifyH("LEFT")
        nameFS:SetWidth(0)
        nameFS:SetPoint("LEFT", self.frameInner, "LEFT", leftInset + nameOffX, 4 + nameOffY)
    end

    -- ---- Timer ------------------------------------------------
    local timerFS      = self.castTimerText
    local timerSize    = cfg:Get("textTimerSize")  or 11
    local timerAlign   = cfg:Get("textTimerAlign") or "RIGHT"
    local tr, tg, tb, ta = resolveColor(cfg:Get("textTimerColor") or "white")

    timerFS:SetFont(resolveFace(timerFS), timerSize, outline)
    timerFS:SetTextColor(tr, tg, tb, ta)

    timerFS:ClearAllPoints()
    if centered then
        timerFS:SetJustifyH("LEFT")
        timerFS:SetWidth(barW * 0.25)
        timerFS:SetPoint("LEFT", self.frameInner, "CENTER", 14 + userTimerPosX, 4 + timerOffY)
    elseif timerAlign == "CENTER" then
        timerFS:SetJustifyH("CENTER")
        timerFS:SetWidth(barW * 0.3)
        timerFS:SetPoint("CENTER", self.frameInner, "CENTER", userTimerPosX, 4 + timerOffY)
    elseif timerAlign == "LEFT" then
        timerFS:SetJustifyH("LEFT")
        timerFS:SetWidth(0)
        timerFS:SetPoint("LEFT", self.frameInner, "LEFT", leftInset + timerOffX, 4 + timerOffY)
    else
        timerFS:SetJustifyH("RIGHT")
        timerFS:SetWidth(0)
        timerFS:SetPoint("RIGHT", self.frameInner, "RIGHT", -rightInset + timerOffX, 4 + timerOffY)
    end
end
