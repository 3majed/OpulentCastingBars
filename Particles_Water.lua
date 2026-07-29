-- ============================================================
--  Opulent Casting Bars — Particles_Water.lua
--
--  Thème Water — Chaman Restauration
--
--  · Frame_Water_Light  : suit la progression (masqué, comme Moon)
--  · Glow + Ember bleu  : animation identique à Metal, teinte #3bbcdc
--  · Cercles d'eau      : Water_Circle.tga, spawn aléatoire le long
--                         de la barre, fade in/out, masqués pour ne
--                         montrer que la demi-portion qui dépasse du
--                         bord de la barre (haut ou bas). Angle et
--                         échelle variés à chaque apparition.
-- ============================================================

local FX = {}
SCB.FX           = SCB.FX or {}
SCB.FX["water"]  = FX

local function rand(a, b)   return a + math.random() * (b - a) end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end
local function rad(deg)      return deg * math.pi / 180 end
local pi2 = math.pi * 2

-- ============================================================
--  CONSTANTES
-- ============================================================

-- Couleur eau : #3bbcdc → R=0.231  G=0.737  B=0.863
local WATER_R, WATER_G, WATER_B = 0x3b/255, 0xbc/255, 0xdc/255

-- ---- Glow (bout de barre, même réglages que Metal) ----------
local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.02
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.55
local GLOW_SIZE_MIN   = 4
local GLOW_SIZE_MAX   = 9
local GLOW_LIFE_MIN   = 0.10
local GLOW_LIFE_MAX   = 0.20

-- ---- Ember / gouttelettes (bout de barre, même réglages que Metal) ----
local EMBER_COUNT = 60
local EMBER_SPAWN = 0.03

local emberTypes = {
    { sizeMin=8,  sizeMax=14, speedMin=25,  speedMax=60,  lifeMin=0.8, lifeMax=1.6, gravity=8,  spread=140, driftX=0.4 },
    { sizeMin=4,  sizeMax=8,  speedMin=80,  speedMax=160, lifeMin=0.3, lifeMax=0.7, gravity=15, spread=80,  driftX=0.0 },
    { sizeMin=6,  sizeMax=12, speedMin=40,  speedMax=90,  lifeMin=0.6, lifeMax=1.2, gravity=20, spread=100, driftX=0.2 },
}

-- ---- Cercles d'eau ----------------------------------------
local CIRCLE_COUNT      = 12
local CIRCLE_SPAWN_MIN  = 0.20   -- délai min entre deux cercles (s)
local CIRCLE_SPAWN_MAX  = 0.37   -- délai max
local CIRCLE_LIFE_MIN   = 1.20
local CIRCLE_LIFE_MAX   = 2.20
local CIRCLE_ALPHA_MAX  = 0.80
local CIRCLE_FG_ALPHA_MAX = CIRCLE_ALPHA_MAX * 0.50
local CIRCLE_SCALE_MIN  = 0.80   -- 0.70 × 0.85 (−15 %)
local CIRCLE_SCALE_MAX  = 1.48   -- 1.50 × 0.85 (−15 %)

local CIRCLE_START_PROGRESS = 0.01

local FADE_DUR = 0.60

-- ============================================================
--  ÉTAT
-- ============================================================

local isActive     = false
local partsFading  = false
local partsFadeT   = 0
local castDuration = 5

local texLight  = nil
local maskLight = nil

local glowParts    = {}
local glowSpawnAcc = 0

local emberParts    = {}
local emberSpawnAcc = 0

local circleParts   = {}
local circleAcc     = 0
local circleNext    = 0

local circleFGParts = {}
local circleFGAcc   = 0
local circleFGNext  = 0

-- ============================================================
--  GLOW (bout de barre)
-- ============================================================

local function SpawnGlow(frontX, cy, barH)
    for _, p in ipairs(glowParts) do
        if not p.active then
            local spread  = math.min(barH * 0.25, 10)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(GLOW_LIFE_MIN, GLOW_LIFE_MAX)
            p.x       = frontX + rand(-2, 2)
            p.y       = cy + rand(-spread, spread)
            p.vy      = rand(-5, 5)
            p.phase   = math.random() * pi2
            local size = rand(GLOW_SIZE_MIN, GLOW_SIZE_MAX)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
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
    p.vy = p.vy * 0.90
    p.y  = p.y + p.vy * dt + math.sin(p.life * 10 + p.phase) * 0.3
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env
    if     t < 0.2 then env = t / 0.2
    elseif t < 0.8 then env = 1
    else             env = (1 - t) / 0.2 end
    p.tex:SetAlpha(math.max(0, env) * GLOW_ALPHA * (gFade or 1))
end

-- ============================================================
--  EMBER / gouttelettes (bout de barre)
-- ============================================================

local function SpawnEmber(wx, wy)
    local roll    = math.random(10)
    local typeIdx = roll <= 4 and 1 or (roll <= 7 and 3 or 2)
    local ptype   = emberTypes[typeIdx]
    for _, p in ipairs(emberParts) do
        if not p.active and p.typeIdx == typeIdx then
            local tCast = math.max(0, math.min((castDuration - 2) / 3, 1))
            local speed = rand(
                lerp(ptype.speedMax * 0.5, ptype.speedMin,       tCast),
                lerp(ptype.speedMax,       ptype.speedMax * 0.8, tCast))
            local angle = rad(90 + rand(-ptype.spread * 0.5, ptype.spread * 0.5))
            local size  = rand(ptype.sizeMin, ptype.sizeMax)
            p.active  = true ; p.life = 0
            p.maxLife = rand(ptype.lifeMin, ptype.lifeMax)
            p.x       = wx + rand(-5, 5)
            p.y       = wy + rand(-8, 8)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            p.drift   = rand(-ptype.driftX, ptype.driftX) * 30
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(1)
            return
        end
    end
end

local function UpdateEmber(p, dt, gFade)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - p.ptype.gravity * dt
    p.vx = p.vx + p.drift * dt * (1 - t)
    p.x  = p.x  + p.vx * dt
    p.y  = p.y  + p.vy * dt
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha
    if p.typeIdx == 2 then
        alpha = t < 0.15 and 1 or math.max(0, 1 - (t - 0.15) / 0.85)
    else
        alpha = t < 0.5  and 1 or math.max(0, (1 - t) / 0.5)
    end
    p.tex:SetAlpha(alpha * 0.85 * (gFade or 1))
end

local function ResetCircleTexCoords(tex)
    tex:SetTexCoord(0, 1, 0, 1)
end

local function RotateCircleUV(u, v, angle)
    local c, s = math.cos(angle), math.sin(angle)
    local x, y = u - 0.5, v - 0.5
    return 0.5 + x * c - y * s, 0.5 + x * s + y * c
end

-- Vitesse de rotation des cercles (rad/s) — valeurs absolues
local CIRCLE_ROT_SPEED_MIN = 0.25
local CIRCLE_ROT_SPEED_MAX = 0.80

-- Fraction du rayon utilisée pour décaler le centre du bord de la barre.
local CIRCLE_EDGE_FACTOR = 0.80

-- ============================================================
--  CERCLES D'EAU
-- ============================================================

local function ApplyCircleProgressClip(p, clipL, clipR)
    local diameter = p.diameter or 0
    local radius   = p.radius or 0
    if diameter <= 0 or radius <= 0 then return false end

    if clipL then p.hClipL = clipL end
    if clipR then p.hClipR = clipR end

    local texLeft  = p.x - radius
    local texRight = p.x + radius
    local sliceLeft  = texLeft
    local sliceRight = texRight

    if p.hClipL and sliceLeft < p.hClipL then sliceLeft = p.hClipL end
    if p.hClipR and sliceRight > p.hClipR then sliceRight = p.hClipR end
    if sliceRight <= sliceLeft then
        p.tex:SetAlpha(0)
        return false
    end

    local texBottom = p.y - radius
    local texTop    = p.y + radius
    local sliceBottom, sliceTop
    if p.mask and p.mask.__scbFakeMask then
        local maskH = 40
        if p.isAbove then
            sliceBottom = p.clipY - 70
            sliceTop    = sliceBottom + maskH
        else
            sliceTop    = p.clipY + 70
            sliceBottom = sliceTop - maskH
        end
    else
        sliceBottom = texBottom
        sliceTop    = texTop
    end

    if sliceBottom < texBottom then sliceBottom = texBottom end
    if sliceTop > texTop then sliceTop = texTop end

    local sliceH = sliceTop - sliceBottom
    if sliceH <= 0 then
        p.tex:SetAlpha(0)
        return false
    end

    local sliceW = sliceRight - sliceLeft
    local uLeft  = (sliceLeft - texLeft) / diameter
    local uRight = (sliceRight - texLeft) / diameter
    local vTop    = (texTop - sliceTop) / diameter
    local vBottom = (texTop - sliceBottom) / diameter
    if uLeft < 0 then uLeft = 0 end
    if uRight > 1 then uRight = 1 end
    if vTop < 0 then vTop = 0 end
    if vBottom > 1 then vBottom = 1 end

    local angle = p.angle or 0
    local tlU, tlV = RotateCircleUV(uLeft,  vTop,    angle)
    local blU, blV = RotateCircleUV(uLeft,  vBottom, angle)
    local trU, trV = RotateCircleUV(uRight, vTop,    angle)
    local brU, brV = RotateCircleUV(uRight, vBottom, angle)

    p.tex:SetSize(sliceW, sliceH)
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
        (sliceLeft + sliceRight) * 0.5, (sliceBottom + sliceTop) * 0.5)
    p.tex:SetTexCoord(tlU, tlV, blU, blV, trU, trV, brU, brV)
    return true
end

local function SpawnCircle(parts, fillLX, filledW, barCY, barH, clipL, clipR)
    clipL = clipL or fillLX
    clipR = clipR or (fillLX + filledW)
    if filledW <= 0 or clipR <= clipL then return end

    for _, p in ipairs(parts) do
        if not p.active then
            -- Position aléatoire dans la zone déjà remplie,
            -- avec 30 px de marge de chaque côté pour éviter les débordements
            local marginPx = 30
            local xMin = fillLX + 0.06 * filledW + marginPx
            local xMax = fillLX + 0.94 * filledW + marginPx
            if xMin >= xMax then xMin = fillLX + filledW * 0.5 ; xMax = xMin end
            local x = rand(xMin, xMax)

            -- Côté aléatoire : au-dessus ou en dessous de la barre
            local isAbove = (math.random(2) == 1)
            -- clipY = bord de la barre (ancrage du masque, inchangé)
            local clipY   = isAbove and (barCY + barH * 0.5)
                                     or (barCY - barH * 0.5)

            -- Taille variable
            local scale    = rand(CIRCLE_SCALE_MIN, CIRCLE_SCALE_MAX)
            local diameter = barH * 1.2 * scale
            local radius   = diameter * 0.5

            -- Centre : EDGE_FACTOR × rayon depuis le bord, + décalage 60 px
            local anchorY = isAbove and (clipY - 70) or (clipY + 70)
            local circleY = isAbove and (anchorY - radius * CIRCLE_EDGE_FACTOR)
                                     or (anchorY + radius * CIRCLE_EDGE_FACTOR)

            -- Angle initial et vitesse de rotation aléatoires
            local angle    = rand(0, pi2)
            local rotSpeed = rand(CIRCLE_ROT_SPEED_MIN, CIRCLE_ROT_SPEED_MAX)
            local rotDir   = p.rotDir or 1

            p.active   = true
            p.life     = 0
            p.maxLife  = rand(CIRCLE_LIFE_MIN, CIRCLE_LIFE_MAX)
            p.isAbove  = isAbove
            p.x        = x
            p.y        = circleY
            p.clipY    = clipY
            p.diameter = diameter
            p.radius   = radius
            p.angle    = angle
            p.rotSpeed = rotSpeed
            p.rotDir   = rotDir
            p.hClipL   = clipL
            p.hClipR   = clipR

            -- Texture : centrée sur le point décalé
            ResetCircleTexCoords(p.tex)
            p.tex:SetSize(diameter, diameter)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, circleY)

            p.mask:ClearAllPoints()
            local maskH = 40
            if isAbove then
                p.mask:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
                    x - radius, clipY - 70)
                p.mask:SetSize(diameter, maskH)
            else
                p.mask:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
                    x - radius, clipY + 70)
                p.mask:SetSize(diameter, maskH)
            end
            ApplyCircleProgressClip(p, clipL, clipR)
            return
        end
    end
end

local function UpdateCircle(p, dt, gFade, alphaMax, clipL, clipR)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then
        p.active = false
        p.tex:SetAlpha(0)
        return
    end
    p.angle = (p.angle or 0) + (p.rotSpeed or 0) * (p.rotDir or 1) * dt
    local visible = ApplyCircleProgressClip(p, clipL, clipR)
    if not visible then return end
    -- Enveloppe : fade-in 0–0.30, plateau, fade-out 0.70–1.0
    local env
    if     t < 0.30 then env = t / 0.30
    elseif t < 0.70 then env = 1
    else             env = (1 - t) / 0.30 end
    p.tex:SetAlpha(math.max(0, env) * (alphaMax or CIRCLE_ALPHA_MAX) * (gFade or 1))
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["water"]
    if not school then return end
    local f = SCB.Bar.frameInner
    if not f then return end

    -- Frame_Water_Light : suit la progression via masque (comme Moon)
    if school.light then
        texLight = f:CreateTexture(nil, "OVERLAY", nil, 6)
        texLight:SetTexture(school.light)
        texLight:SetBlendMode("ADD")
        texLight:SetAllPoints(f)
        maskLight = f:CreateMaskTexture()
        maskLight:SetTexture("Interface\\BUTTONS\\WHITE8X8",
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        maskLight:SetPoint("TOPLEFT",    f, "TOPLEFT")
        maskLight:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
        maskLight:SetWidth(1)
        texLight:AddMaskTexture(maskLight)
        texLight:SetAlpha(0)
        -- Préchargement silencieux
        local pl = UIParent:CreateTexture(nil, "BACKGROUND")
        pl:SetTexture(school.light)
        pl:SetSize(1, 1) ; pl:SetAlpha(0.0001)
        pl:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    end

    -- Glow : Particle_Frost_01 teinté bleu eau
    local partTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    glowParts = {}
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(partTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(WATER_R, WATER_G, WATER_B)
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0,
                         x=0, y=0, vy=0, phase=0 }
    end

    -- Ember / gouttelettes : même texture, physique de métal en bleu
    emberParts = {}
    for i = 1, EMBER_COUNT do
        local typeIdx = ((i - 1) % 3) + 1
        local ptype   = emberTypes[typeIdx]
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(partTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(WATER_R, WATER_G, WATER_B)
        tex:SetAlpha(0)
        emberParts[i] = {
            tex=tex, ptype=ptype, typeIdx=typeIdx,
            active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, drift=0,
        }
    end

    -- Cercles d'eau (Water_Circle masqués au bord de la barre)
    -- Créés sur `bar` (frameInner) en couche BACKGROUND pour apparaître
    -- derrière la barre de cast (texFill, couche ARTWORK).
    local circleTex = school.circle
    circleParts = {}
    for i = 1, CIRCLE_COUNT do
        local tex = bar:CreateTexture(nil, "BACKGROUND")
        if circleTex then
            tex:SetTexture(circleTex)
        end
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(WATER_R, WATER_G, WATER_B)
        tex:SetAlpha(0)

        -- Masque individuel : positionné en coordonnées écran lors du spawn
        local mask = bar:CreateMaskTexture()
        mask:SetTexture("Interface\\BUTTONS\\WHITE8X8",
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetSize(1, 1)
        tex:AddMaskTexture(mask)

        circleParts[i] = {
            tex=tex, mask=mask,
            active=false, life=0, maxLife=0,
            x=0, y=0, clipY=0, isAbove=true,
            diameter=0, radius=0, angle=0, rotSpeed=0,
            rotDir=(i % 2 == 1) and 1 or -1,
            hClipL=0, hClipR=0,
        }
    end

    -- Cercles d'eau — premier plan (OVERLAY sur particleContainer, opacité 50 %)
    circleFGParts = {}
    for i = 1, CIRCLE_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if circleTex then
            tex:SetTexture(circleTex)
        end
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(WATER_R, WATER_G, WATER_B)
        tex:SetAlpha(0)

        local mask = container:CreateMaskTexture()
        mask:SetTexture("Interface\\BUTTONS\\WHITE8X8",
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetSize(1, 1)
        tex:AddMaskTexture(mask)

        circleFGParts[i] = {
            tex=tex, mask=mask,
            active=false, life=0, maxLife=0,
            x=0, y=0, clipY=0, isAbove=true,
            diameter=0, radius=0, angle=0, rotSpeed=0,
            rotDir=(i % 2 == 1) and -1 or 1,
            hClipL=0, hClipR=0,
        }
    end
end

function FX.Start(duration)
    castDuration  = duration or 5
    isActive      = true
    partsFading   = false
    glowSpawnAcc  = 0
    emberSpawnAcc = 0
    circleAcc     = 0
    circleNext    = rand(CIRCLE_SPAWN_MIN, CIRCLE_SPAWN_MAX)
    circleFGAcc   = 0
    circleFGNext  = rand(CIRCLE_SPAWN_MIN, CIRCLE_SPAWN_MAX)
    if texLight  then texLight:SetAlpha(1) end
    if maskLight then maskLight:SetWidth(1) end
    for _, p in ipairs(glowParts)     do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts)    do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(circleParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(circleFGParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive      = false
    partsFading   = true
    partsFadeT    = 0
    glowSpawnAcc  = 0
    emberSpawnAcc = 0
end

function FX.UpdateFade(dt)
    if not partsFading then return end
    partsFadeT = partsFadeT + dt
    local gFade = math.max(0, 1 - partsFadeT / FADE_DUR)
    if texLight then texLight:SetAlpha(gFade) end
    for _, p in ipairs(glowParts)     do UpdateGlow(p,   dt, gFade) end
    for _, p in ipairs(emberParts)    do UpdateEmber(p,  dt, gFade) end
    for _, p in ipairs(circleParts)   do UpdateCircle(p, dt, gFade) end
    for _, p in ipairs(circleFGParts) do UpdateCircle(p, dt, gFade, CIRCLE_FG_ALPHA_MAX) end
    if partsFadeT >= FADE_DUR then
        partsFading = false
        if texLight then texLight:SetAlpha(0) end
        for _, p in ipairs(glowParts)     do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(emberParts)    do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(circleParts)   do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(circleFGParts) do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    isActive = false ; partsFading = false
    if texLight  then texLight:SetAlpha(0) end
    if maskLight then maskLight:SetWidth(1) end
    for _, p in ipairs(glowParts)     do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts)    do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(circleParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(circleFGParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    local f = SCB.Bar.frameInner
    local _, barCY = f:GetCenter()
    if not barCY then return end

    -- Frame_Water_Light suit la progression (masque gauche→droite)
    if maskLight then
        local frameW = SCB.Bar.frame:GetWidth()
        maskLight:SetWidth(math.max(frameW * progress, 1))
    end

    -- Glow au bout du fill
    for _, p in ipairs(glowParts) do UpdateGlow(p, dt, 1) end
    if progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc + dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc = 0
            for _ = 1, math.random(2, 4) do
                SpawnGlow(frontX, barCY, barH)
            end
        end
    end

    -- Ember / gouttelettes au bout du fill
    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, 1) end
    emberSpawnAcc = emberSpawnAcc + dt
    if emberSpawnAcc >= EMBER_SPAWN then
        emberSpawnAcc = 0
        for _ = 1, math.random(2, 4) do
            SpawnEmber(frontX, barCY)
        end
    end

    -- Cercles d'eau le long de la zone remplie
    local filledW = fillW * progress
    local clipL   = fillLX
    local clipR   = fillLX + filledW
    for _, p in ipairs(circleParts)   do UpdateCircle(p, dt, 1, nil, clipL, clipR) end
    for _, p in ipairs(circleFGParts) do UpdateCircle(p, dt, 1, CIRCLE_FG_ALPHA_MAX, clipL, clipR) end
    if progress > CIRCLE_START_PROGRESS then
        circleAcc = circleAcc + dt
        if circleAcc >= circleNext then
            circleAcc  = 0
            circleNext = rand(CIRCLE_SPAWN_MIN, CIRCLE_SPAWN_MAX)
            SpawnCircle(circleParts, fillLX, filledW, barCY, barH, clipL, clipR)
        end
        circleFGAcc = circleFGAcc + dt
        if circleFGAcc >= circleFGNext then
            circleFGAcc  = 0
            circleFGNext = rand(CIRCLE_SPAWN_MIN, CIRCLE_SPAWN_MAX)
            SpawnCircle(circleFGParts, fillLX, filledW, barCY, barH, clipL, clipR)
        end
    end
end
