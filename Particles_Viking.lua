-- ============================================================
--  Opulent Casting Bars — Particles_Viking.lua
--  Variante Neutral2 "Viking Icon"
--  - Bulle + Cercle à gauche
--  - Icône de sort centrée dans le cercle
--  - Rotation continue du cercle (sens alterné à chaque cast)
--  - Particules calquées sur Metal, teinte #5DE4EB
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["viking"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg) return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end

-- Cercle gauche (à ajuster finement ensuite)
local CIRCLE_CENTER_X  = -140
local CIRCLE_CENTER_Y  = 9
local BUBBLE_OFFSET_X  = 1
local CIRCLE_SIZE      = 90.2 -- +10% texture circle
local ICON_SIZE        = 48.3
local ICON_OFFSET_X    = 0
local ICON_OFFSET_Y    = -1
local CIRCLE_ROT_SPEED = 0.595 -- rad/s (-30%)
local CIRCLE_ROT_DEG_PER_SEC = CIRCLE_ROT_SPEED * 57.295779513

-- Particules : calque de Metal
local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.02
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.55
local GLOW_SIZE_MIN   = 4
local GLOW_SIZE_MAX   = 9
local GLOW_LIFE_MIN   = 0.10
local GLOW_LIFE_MAX   = 0.20
local GLOW_R, GLOW_G, GLOW_B = 0x5D / 255, 0xE4 / 255, 0xEB / 255

local EMBER_COUNT = 60
local EMBER_SPAWN = 0.03
local EMBER_R, EMBER_G, EMBER_B = GLOW_R, GLOW_G, GLOW_B

local emberTypes = {
    { sizeMin=8,  sizeMax=14, speedMin=25, speedMax=60,  lifeMin=0.8, lifeMax=1.6, gravity=8,  spread=140, driftX=0.4 },
    { sizeMin=4,  sizeMax=8,  speedMin=80, speedMax=160, lifeMin=0.3, lifeMax=0.7, gravity=15, spread=80,  driftX=0.0 },
    { sizeMin=6,  sizeMax=12, speedMin=40, speedMax=90,  lifeMin=0.6, lifeMax=1.2, gravity=20, spread=100, driftX=0.2 },
}

local PARTS_FADE_DUR = 0.6

local isActive      = false
local partsFading   = false
local partsFadeT    = 0
local castDuration  = 5
local glowParts     = {}
local glowSpawnAcc  = 0
local emberParts    = {}
local emberSpawnAcc = 0

local bubbleTex, circleTex, iconTex
local circleRotDir = 1
local nextCircleRotDir = 1
local circleSpinAG, circleSpinRot

local circleSX, circleSY

local function PositionLeftCircle()
    if not circleTex or not iconTex or not bubbleTex then return end

    -- Circle + icon centrés ensemble. Le cercle tourne via une Animation
    -- (le quad lui-même pivote) : il doit rester carré, donc échelle uniforme.
    local sx, sy = SCB.Bar:GetArtScale()
    -- Anchored relative to the bar: only re-lay out when the scale changes.
    if sx == circleSX and sy == circleSY then return end
    circleSX, circleSY = sx, sy
    local s = math.min(sx, sy)
    local cx, cy = CIRCLE_CENTER_X * sx, CIRCLE_CENTER_Y * sy
    circleTex:SetSize(CIRCLE_SIZE * s, CIRCLE_SIZE * s)
    circleTex:ClearAllPoints()
    circleTex:SetPoint("CENTER", SCB.Bar.frameInner, "CENTER", cx, cy)
    iconTex:SetSize(ICON_SIZE * s, ICON_SIZE * s)
    iconTex:ClearAllPoints()
    iconTex:SetPoint("CENTER", SCB.Bar.frameInner, "CENTER", cx + ICON_OFFSET_X * s, cy + ICON_OFFSET_Y * s)

    -- Bulle légèrement décalée à droite
    bubbleTex:ClearAllPoints()
    bubbleTex:SetPoint("TOPLEFT",     SCB.Bar.frameInner, "TOPLEFT",     BUBBLE_OFFSET_X, -2)
    bubbleTex:SetPoint("BOTTOMRIGHT", SCB.Bar.frameInner, "BOTTOMRIGHT", BUBBLE_OFFSET_X, -2)
end

local function ConfigureCircleSpin()
    if not circleSpinAG or not circleSpinRot then return end
    local duration = 360 / CIRCLE_ROT_DEG_PER_SEC
    circleSpinAG:Stop()
    circleSpinRot:SetDegrees(360 * circleRotDir)
    circleSpinRot:SetDuration(duration)
    circleTex:SetRotation(0)
    circleSpinAG:Play()
end

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
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env
    if t < 0.2 then env = t / 0.2
    elseif t < 0.8 then env = 1
    else env = (1 - t) / 0.2 end
    p.tex:SetAlpha(math.max(0, env) * GLOW_ALPHA * (globalFade or 1))
end

local function SpawnEmber(wx, wy)
    local roll = math.random(10)
    local typeIdx = roll <= 4 and 1 or (roll <= 7 and 3 or 2)
    local ptype = emberTypes[typeIdx]

    for _, p in ipairs(emberParts) do
        if not p.active and p.typeIdx == typeIdx then
            local tCast = math.max(0, math.min((castDuration - 2) / 3, 1))
            local speed = rand(lerp(ptype.speedMax * 0.5, ptype.speedMin, tCast),
                               lerp(ptype.speedMax, ptype.speedMax * 0.8, tCast))
            local angle = rad(90 + rand(-ptype.spread * 0.5, ptype.spread * 0.5))
            local size  = rand(ptype.sizeMin, ptype.sizeMax)

            p.active  = true ; p.life = 0
            p.maxLife = rand(ptype.lifeMin, ptype.lifeMax)
            p.x       = wx + rand(-5, 5)
            p.y       = wy + rand(-8, 8)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            p.drift   = rand(-ptype.driftX, ptype.driftX) * 30
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(1)
            return
        end
    end
end

local function UpdateEmber(p, dt, globalFade)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - p.ptype.gravity * dt
    p.vx = p.vx + p.drift * dt * (1 - t)
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha
    if p.typeIdx == 2 then
        alpha = t < 0.15 and 1 or math.max(0, 1 - (t - 0.15) / 0.85)
    else
        alpha = t < 0.5 and 1 or math.max(0, (1 - t) / 0.5)
    end
    p.tex:SetAlpha(alpha * 0.85 * (globalFade or 1))
end

function FX.Init(container, bar)
    local school = SCB.Schools.data["viking"] or {}

    -- Ordre avant->arrière demandé:
    -- Frame / Fill / Circle / Bulle / Icon / BG
    -- (Frame+Fill existent déjà dans Bar.lua)
    -- Texture sub-levels are not honoured by this client, so the three sit in
    -- the BORDER layer (above BG, below Fill/Frame) and are created back to
    -- front: icon, bulle, circle. The icon is also drawn round (see FX.Start)
    -- so it fits the ring's hole whatever the stacking ends up being.
    iconTex = bar:CreateTexture(nil, "BORDER")
    iconTex:SetSize(ICON_SIZE, ICON_SIZE)
    iconTex:SetAlpha(0)

    bubbleTex = bar:CreateTexture(nil, "BORDER")
    bubbleTex:SetTexture(school.bubble)
    bubbleTex:SetBlendMode("BLEND")
    bubbleTex:SetAlpha(0)

    circleTex = bar:CreateTexture(nil, "BORDER")
    circleTex:SetSize(CIRCLE_SIZE, CIRCLE_SIZE)
    circleTex:SetTexture(school.circle)
    circleTex:SetBlendMode("BLEND")
    circleTex:SetAlpha(0)

    -- Animation native (plus smooth que la rotation dans Update throttlé)
    circleSpinAG = circleTex:CreateAnimationGroup()
    circleSpinAG:SetLooping("REPEAT")
    circleSpinRot = circleSpinAG:CreateAnimation("Rotation")
    circleSpinRot:SetOrder(1)
    circleSpinRot:SetOrigin("CENTER", 0, 0)
    circleSpinRot:SetSmoothing("NONE")

    PositionLeftCircle()

    local glowTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    glowParts = {}
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(glowTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(GLOW_R, GLOW_G, GLOW_B)
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vy=0, phase=0 }
    end

    local earthSchool = SCB.Schools.data["earth"]
    local miscTexs = {}
    if earthSchool then
        for _, t in ipairs(earthSchool.rocks or {}) do miscTexs[#miscTexs + 1] = t end
        for _, t in ipairs(earthSchool.debris or {}) do miscTexs[#miscTexs + 1] = t end
    end

    emberParts = {}
    for i = 1, EMBER_COUNT do
        local typeIdx = ((i - 1) % 3) + 1
        local ptype = emberTypes[typeIdx]
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(miscTexs[((i - 1) % math.max(#miscTexs, 1)) + 1] or glowTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(EMBER_R, EMBER_G, EMBER_B)
        tex:SetAlpha(0)
        emberParts[i] = {
            tex=tex, ptype=ptype, typeIdx=typeIdx,
            active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, drift=0,
        }
    end
end

function FX.Start(duration)
    castDuration  = duration or 5
    isActive      = true
    partsFading   = false
    partsFadeT    = 0
    glowSpawnAcc  = 0
    emberSpawnAcc = 0

    circleRotDir = nextCircleRotDir
    nextCircleRotDir = -nextCircleRotDir

    if bubbleTex then bubbleTex:SetAlpha(1) end
    if circleTex then
        circleTex:SetAlpha(1)
        ConfigureCircleSpin()
    end
    if iconTex then
        SCB.SetRoundIcon(iconTex, SCB.Bar.currentSpellIcon)
        iconTex:SetAlpha(1)
    end
    PositionLeftCircle()

    for _, p in ipairs(glowParts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
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
    local gFade = math.max(0, 1 - partsFadeT / PARTS_FADE_DUR)

    if circleTex then circleTex:SetAlpha(gFade) end
    if iconTex then iconTex:SetAlpha(gFade) end
    if bubbleTex then bubbleTex:SetAlpha(gFade) end

    for _, p in ipairs(glowParts)  do UpdateGlow(p, dt, gFade) end
    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, gFade) end

    if partsFadeT >= PARTS_FADE_DUR then
        partsFading = false
        if bubbleTex then bubbleTex:SetAlpha(0) end
        if circleTex then circleTex:SetAlpha(0) end
        if iconTex then iconTex:SetAlpha(0) end
        if circleSpinAG then circleSpinAG:Stop() end
        for _, p in ipairs(glowParts)  do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    partsFading = false
    if bubbleTex then bubbleTex:SetAlpha(0) end
    if circleTex then
        circleTex:SetAlpha(0)
        circleTex:SetRotation(0)
    end
    if iconTex then iconTex:SetAlpha(0) end
    if circleSpinAG then circleSpinAG:Stop() end
    for _, p in ipairs(glowParts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH)
    if not isActive then return end

    -- Reposition pour suivre resize/move live
    PositionLeftCircle()

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

    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, 1) end
    emberSpawnAcc = emberSpawnAcc + dt
    if emberSpawnAcc >= EMBER_SPAWN then
        emberSpawnAcc = 0
        local count = math.random(2, 4)
        for _ = 1, count do SpawnEmber(frontX, barCY) end
    end
end
