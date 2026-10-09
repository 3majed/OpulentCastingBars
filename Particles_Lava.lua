-- ============================================================
--  Opulent Casting Bars — Particles_Lava.lua
--  · Fumée noire (Mist_Frost, BACKGROUND, noir)
--  · Cendres abondantes (Misc_Earth, rouge/orange chaud)
--  · Braises pixel (Particle_Frost_01, jaune/orange, ADD)
-- ============================================================

local FX = {}
SCB.FX          = SCB.FX or {}
SCB.FX["lava"]  = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end

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
--  CONSTANTES FUMÉE
-- ============================================================

local SMOKE_W_BASE    = 280
local SMOKE_H_BASE    = 140
local SMOKE_ALPHA_MAX = 0.35
local SMOKE_SCALE_MIN = 0.8
local SMOKE_SCALE_MAX = 1.4
local SMOKE_FADE_IN   = 2.0
local SMOKE_HOLD_MIN  = 1.5
local SMOKE_HOLD_MAX  = 3.0
local SMOKE_FADE_OUT  = 1.8
local SMOKE_ROT_SPEED = 0.025
local SMOKE_POSITIONS = { 1/6, 2/6, 3/6, 4/6 }

-- ============================================================
--  CONSTANTES CENDRES
-- ============================================================

local EMBER_COUNT = 90
local EMBER_SPAWN = 0.02

local emberTypes = {
    { sizeMin=8,  sizeMax=16, speedMin=20, speedMax=55,  lifeMin=0.9, lifeMax=1.8, gravity=6,  spread=150, driftX=0.5 },
    { sizeMin=4,  sizeMax=9,  speedMin=70, speedMax=150, lifeMin=0.3, lifeMax=0.7, gravity=12, spread=90,  driftX=0.0 },
    { sizeMin=5,  sizeMax=13, speedMin=35, speedMax=80,  lifeMin=0.7, lifeMax=1.3, gravity=18, spread=110, driftX=0.3 },
}

local EMBER_COLORS = {
    { 1.0, 0.35, 0.02 },
    { 1.0, 0.15, 0.01 },
    { 1.0, 0.55, 0.05 },
}

-- ============================================================
--  CONSTANTES BRAISES PIXEL
-- ============================================================

local SPARK_COUNT     = 50
local SPARK_SPAWN     = 0.035
local SPARK_SIZE_MIN  = 3
local SPARK_SIZE_MAX  = 7
local SPARK_LIFE_MIN  = 0.4
local SPARK_LIFE_MAX  = 1.1
local SPARK_SPEED_MIN = 30
local SPARK_SPEED_MAX = 90
local SPARK_GRAVITY   = 25

local SPARK_COLORS = {
    { 1.0, 0.90, 0.10, 1.0  },
    { 1.0, 0.70, 0.05, 0.85 },
    { 1.0, 0.95, 0.30, 0.6  },
    { 1.0, 0.55, 0.02, 0.7  },
    { 1.0, 1.00, 0.50, 0.45 },
}

local PARTS_FADE_DUR = 0.8
local castDuration   = 5

-- Center crystal crop from fire2\Frame_Fire2_Light.tga (1024x512).
local RUNE_TEX_W = 1024
local RUNE_TEX_H = 512
local RUNE_X1    = 454
local RUNE_X2    = 570
local RUNE_Y1    = 55
local RUNE_Y2    = 205
local RUNE_TEX    = SCB.TEX_PATH .. "fire2\\Rune_Fire2_Light"
local RUNE_W_FRAC = (RUNE_X2 - RUNE_X1) / RUNE_TEX_W
local RUNE_H_FRAC = (RUNE_Y2 - RUNE_Y1) / RUNE_TEX_H
local RUNE_CX_FRAC = ((RUNE_X1 + RUNE_X2) * 0.5) / RUNE_TEX_W
local RUNE_CY_FRAC = 0.5 - (((RUNE_Y1 + RUNE_Y2) * 0.5) / RUNE_TEX_H)
local RUNE_ALPHA  = 1

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local isActive      = false
local partsFading   = false
local partsFadeT    = 0
local smokes        = {}
local emberParts    = {}
local sparkParts    = {}
local ambParts      = {}
local texRuneHot    = nil
local runeHotVisible = false
local emberSpawnAcc = 0
local sparkSpawnAcc = 0
local ambSpawnAcc   = 0

local AMB_COUNT = 40
local AMB_SPAWN = 0.07

local function Clamp01(v)
    if type(v) ~= "number" or v ~= v then return 0 end
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

local function UpdateCenterRune(progress, frontX, barW, barH, fillLX, fillW)
    if not texRuneHot then return end

    local bar = SCB.Bar and SCB.Bar.frameInner
    if not bar then return end

    barW = barW or bar:GetWidth()
    barH = barH or bar:GetHeight()
    if not barW or not barH or barW <= 0 or barH <= 0 then
        texRuneHot:SetAlpha(0)
        return
    end

    local cx = bar:GetCenter()
    if not cx then
        texRuneHot:SetAlpha(0)
        return
    end

    fillW = fillW or barW
    fillLX = fillLX or (cx - barW * 0.5)
    local frontLocalX = (frontX or (fillLX + fillW * Clamp01(progress))) - (cx - barW * 0.5)
    local runeW       = math.max(1, barW * RUNE_W_FRAC)
    local runeH       = math.max(1, barH * RUNE_H_FRAC)
    local runeX       = barW * RUNE_CX_FRAC
    local runeY       = barH * RUNE_CY_FRAC
    local runeLeft    = runeX - runeW * 0.5
    local runeRight   = runeX + runeW * 0.5
    local reverseDir  = SCB.Bar.currentSchool and SCB.Bar.currentSchool.reverseDir
    local reached

    if reverseDir then
        reached = frontLocalX <= runeRight
    else
        reached = frontLocalX >= runeLeft
    end

    texRuneHot:ClearAllPoints()
    texRuneHot:SetPoint("CENTER", bar, "LEFT", runeX, runeY)
    texRuneHot:SetSize(runeW, runeH)
    texRuneHot:SetTexCoord(0, 1, 0, 1)
    runeHotVisible = reached and true or false
    texRuneHot:SetAlpha(runeHotVisible and RUNE_ALPHA or 0)
end

-- ============================================================
--  FUMÉE
-- ============================================================

local function SpawnSmoke(m)
    local scale = rand(SMOKE_SCALE_MIN, SMOKE_SCALE_MAX)
    m.baseW    = SMOKE_W_BASE * scale
    m.baseH    = SMOKE_H_BASE * scale
    m.tex:SetSize(m.baseW, m.baseH)
    m.tex:SetAlpha(0)
    m.phase    = "fadein"
    m.timer    = 0
    m.duration = SMOKE_FADE_IN
    m.alpha    = 0
    m.scaleT   = 0
    m.scaleDir = math.random(2) == 1 and 1 or -1
    -- Reset la position de montée
    local f = SCB.Bar.frameInner
    local _, cy = f:GetCenter()
    m.riseY = cy or m.riseY or 0
end

local function UpdateSmoke(m, dt, globalFade)
    if m.delay and m.delay > 0 then m.delay = m.delay - dt ; return end
    if m.phase == "idle" then SpawnSmoke(m) ; return end

    local f = SCB.Bar.frameInner
    local cx, cy = f:GetCenter()
    if cx then
        local barW = f:GetWidth()
        local x = cx - barW * 0.5 + barW * m.xFrac
        m.riseY = (m.riseY or cy) + 10 * dt
        m.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, m.riseY)
    end

    m.timer  = m.timer + dt
    m.scaleT = m.scaleT + dt
    m.angle  = m.angle + SMOKE_ROT_SPEED * m.rotDir * dt

    local scalePulse = 1 + math.sin(m.scaleT * 0.35 * m.scaleDir) * 0.08
    m.tex:SetSize(m.baseW * scalePulse, m.baseH * scalePulse)
    SetTexRot(m.tex, m.angle)

    local gf = globalFade or 1
    if m.phase == "fadein" then
        m.alpha = math.min(m.timer / m.duration, 1) * SMOKE_ALPHA_MAX
        m.tex:SetAlpha(math.max(0, m.alpha) * gf)
        if m.timer >= m.duration then
            m.phase = "hold" ; m.timer = 0
            m.duration = rand(SMOKE_HOLD_MIN, SMOKE_HOLD_MAX)
        end
    elseif m.phase == "hold" then
        local pulse = math.sin(m.scaleT * 1.5) * 0.04
        m.tex:SetAlpha(math.max(0, SMOKE_ALPHA_MAX + pulse) * gf)
        if m.timer >= m.duration then
            m.phase = "fadeout" ; m.timer = 0 ; m.duration = SMOKE_FADE_OUT
        end
    elseif m.phase == "fadeout" then
        m.alpha = (1 - m.timer / m.duration) * SMOKE_ALPHA_MAX
        m.tex:SetAlpha(math.max(0, m.alpha) * gf)
        if m.timer >= m.duration then
            m.tex:SetAlpha(0) ; m.phase = "idle"
        end
    end
end

-- ============================================================
--  CENDRES
-- ============================================================

local function SpawnEmber(wx, wy)
    local roll = math.random(10)
    local typeIdx = roll <= 4 and 1 or (roll <= 7 and 3 or 2)
    local ptype = emberTypes[typeIdx]
    local col   = EMBER_COLORS[math.random(#EMBER_COLORS)]

    for _, p in ipairs(emberParts) do
        if not p.active and p.typeIdx == typeIdx then
            local tCast = math.max(0, math.min((castDuration - 2) / 3, 1))
            local speed = rand(lerp(ptype.speedMax * 0.5, ptype.speedMin, tCast),
                               lerp(ptype.speedMax, ptype.speedMax * 0.8, tCast))
            local angle = rad(90 + rand(-ptype.spread * 0.5, ptype.spread * 0.5))
            local size  = rand(ptype.sizeMin, ptype.sizeMax)
            p.active  = true ; p.life = 0
            p.maxLife = rand(ptype.lifeMin, ptype.lifeMax)
            p.x       = wx + rand(-6, 6)
            p.y       = wy + rand(-8, 8)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            p.drift   = rand(-ptype.driftX, ptype.driftX) * 30
            p.tex:SetVertexColor(col[1], col[2], col[3])
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(1)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
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
    p.tex:SetAlpha(alpha * 0.9 * (globalFade or 1))
end

-- ============================================================
--  BRAISES PIXEL
-- ============================================================

local function SpawnSpark(wx, wy)
    local col = SPARK_COLORS[math.random(#SPARK_COLORS)]
    for _, p in ipairs(sparkParts) do
        if not p.active then
            local angle = rad(rand(30, 150))
            local speed = rand(SPARK_SPEED_MIN, SPARK_SPEED_MAX)
            p.active    = true ; p.life = 0
            p.maxLife   = rand(SPARK_LIFE_MIN, SPARK_LIFE_MAX)
            p.x         = wx + rand(-4, 4)
            p.y         = wy + rand(-6, 6)
            p.vx        = math.cos(angle) * speed
            p.vy        = math.sin(angle) * speed
            p.baseAlpha = col[4]
            p.tex:SetVertexColor(col[1], col[2], col[3])
            local size = rand(SPARK_SIZE_MIN, SPARK_SIZE_MAX)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateSpark(p, dt, globalFade)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - SPARK_GRAVITY * dt
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env
    if t < 0.15 then env = t / 0.15
    elseif t < 0.75 then env = 1 + math.sin(p.life * 18) * 0.15
    else env = (1 - t) / 0.25 end
    local sparkAlpha = math.max(0, env) * p.baseAlpha * (globalFade or 1)
    p.tex:SetAlpha(math.min(1, sparkAlpha))
end

-- ============================================================
--  CENDRES AMBIANTES (autour de la barre)
-- ============================================================

local function SpawnAmb(progress)
    local f = SCB.Bar.frame
    local cx, cy = f:GetCenter()
    if not cx then return end
    local barW, barH = f:GetWidth(), f:GetHeight()

    for _, p in ipairs(ambParts) do
        if not p.active then
            local xOffset = rand(-barW * 0.5, barW * 0.5 * progress - barW * 0.5)
            local yOffset = rand(-barH * 0.35, barH * 0.35)
            local wx, wy  = cx + xOffset, cy + yOffset
            local dirX    = xOffset > 0 and 1 or -1
            local angle   = rad(rand(60, 120)) * (yOffset > 0 and 1 or -1)
            local speed   = rand(15, 45)
            local col     = EMBER_COLORS[math.random(#EMBER_COLORS)]

            p.active  = true ; p.life = 0
            p.maxLife = rand(1.0, 2.2)
            p.x       = wx ; p.y = wy
            p.vx      = dirX * rand(5, 20)
            p.vy      = math.sin(angle) * speed
            p.tex:SetVertexColor(col[1], col[2], col[3])
            local size = rand(5, 13)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            return
        end
    end
end

local function UpdateAmb(p, dt, globalFade)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - 4 * dt
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha
    if t < 0.1 then alpha = t / 0.1
    elseif t < 0.65 then alpha = 1
    else alpha = (1 - t) / 0.35 end
    p.tex:SetAlpha(math.max(0, alpha) * 0.55 * (globalFade or 1))
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local mistTex = SCB.TEX_PATH .. "frost\\Mist_Frost_01"

    texRuneHot = container:CreateTexture(nil, "OVERLAY")
    texRuneHot:SetTexture(RUNE_TEX)
    texRuneHot:SetBlendMode("ADD")
    texRuneHot:SetTexCoord(0, 1, 0, 1)
    texRuneHot:SetAlpha(0)

    smokes = {}
    local nPos = #SMOKE_POSITIONS
    for i, xFrac in ipairs(SMOKE_POSITIONS) do
        for pass = 1, 2 do
            local idx = (i - 1) * 2 + pass
            local tex = bar:CreateTexture(nil, "BACKGROUND", nil, -2)
            tex:SetTexture(mistTex)
            tex:SetSize(SMOKE_W_BASE, SMOKE_H_BASE)
            tex:SetAlpha(0)
            tex:SetBlendMode("ADD")
            tex:SetVertexColor(0.07, 0.03, 0.03)
            local xf = pass == 1 and xFrac or (xFrac + 0.06)
            smokes[idx] = {
                tex=tex, xFrac=xf, phase="idle", timer=0, duration=0,
                alpha=0, scaleT=0, scaleDir=(pass == 1) and 1 or -1,
                angle=rand(0, math.pi * 2),
                rotDir=(idx % 2 == 0) and 1 or -1,
                baseW=SMOKE_W_BASE * (pass == 1 and 1 or 0.8),
                baseH=SMOKE_H_BASE * (pass == 1 and 1 or 0.8),
                delay=((idx - 1) * 0.55),
                riseY=0,
            }
        end
    end

    -- Cendres
    local earthSchool = SCB.Schools.data["earth"]
    local miscTexs = {}
    if earthSchool then
        for _, t in ipairs(earthSchool.rocks  or {}) do miscTexs[#miscTexs+1] = t end
        for _, t in ipairs(earthSchool.debris or {}) do miscTexs[#miscTexs+1] = t end
    end
    local function getMisc(i)
        if #miscTexs == 0 then return SCB.TEX_PATH .. "frost\\Particle_Frost_01" end
        return miscTexs[((i-1) % #miscTexs) + 1]
    end

    emberParts = {}
    for i = 1, EMBER_COUNT do
        local typeIdx = ((i - 1) % 3) + 1
        local ptype   = emberTypes[typeIdx]
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getMisc(i))
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        emberParts[i] = {
            tex=tex, ptype=ptype, typeIdx=typeIdx,
            active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, drift=0,
        }
    end

    -- Braises pixel
    sparkParts = {}
    local sparkTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    for i = 1, SPARK_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(sparkTex)
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        sparkParts[i] = {
            tex=tex, active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, baseAlpha=1,
        }
    end
    -- Cendres ambiantes
    ambParts = {}
    for i = 1, AMB_COUNT do
        local tex = container:CreateTexture(nil, "BACKGROUND")
        tex:SetTexture(getMisc(i))
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        ambParts[i] = {
            tex=tex, active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0,
        }
    end
end

function FX.Start(duration)
    castDuration  = duration or 5
    isActive      = true
    partsFading   = false
    emberSpawnAcc = 0
    sparkSpawnAcc = 0
    ambSpawnAcc   = 0
    local f = SCB.Bar.frameInner
    local _, cy = f:GetCenter()
    for i, m in ipairs(smokes) do
        m.phase = "idle" ; m.delay = (i - 1) * 0.45
        m.tex:SetAlpha(0) ; m.riseY = cy or 0
    end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(sparkParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(ambParts)   do p.active = false ; p.tex:SetAlpha(0) end
    runeHotVisible = false
    if texRuneHot then texRuneHot:SetAlpha(0) end
end

function FX.Stop()
    isActive      = false
    partsFading   = true
    partsFadeT    = 0
    emberSpawnAcc = 0
    sparkSpawnAcc = 0
    ambSpawnAcc   = 0
    for _, m in ipairs(smokes) do
        if m.phase ~= "idle" then
            m.phase = "fadeout" ; m.timer = 0 ; m.duration = 0.5
        end
    end
end

function FX.UpdateFade(dt)
    if not partsFading then return end
    partsFadeT = partsFadeT + dt
    local gFade = math.max(0, 1 - partsFadeT / PARTS_FADE_DUR)
    for _, m in ipairs(smokes)     do UpdateSmoke(m, dt, gFade) end
    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, gFade) end
    for _, p in ipairs(sparkParts) do UpdateSpark(p, dt, gFade) end
    for _, p in ipairs(ambParts)   do UpdateAmb(p,   dt, gFade) end
    if texRuneHot then texRuneHot:SetAlpha(runeHotVisible and (RUNE_ALPHA * gFade) or 0) end
    if partsFadeT >= PARTS_FADE_DUR then
        partsFading = false
        for _, m in ipairs(smokes)     do m.tex:SetAlpha(0) ; m.phase = "idle" end
        for _, p in ipairs(emberParts) do p.active = false  ; p.tex:SetAlpha(0) end
        for _, p in ipairs(sparkParts) do p.active = false  ; p.tex:SetAlpha(0) end
        for _, p in ipairs(ambParts)   do p.active = false  ; p.tex:SetAlpha(0) end
        runeHotVisible = false
        if texRuneHot then texRuneHot:SetAlpha(0) end
    end
end

function FX.Reset()
    partsFading = false
    for _, m in ipairs(smokes)     do m.tex:SetAlpha(0) ; m.phase = "idle" end
    for _, p in ipairs(emberParts) do p.active = false  ; p.tex:SetAlpha(0) end
    for _, p in ipairs(sparkParts) do p.active = false  ; p.tex:SetAlpha(0) end
    for _, p in ipairs(ambParts)   do p.active = false  ; p.tex:SetAlpha(0) end
    runeHotVisible = false
    if texRuneHot then texRuneHot:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end
    local f = SCB.Bar.frameInner
    local _, barCY = f:GetCenter()
    if not barCY then return end

    UpdateCenterRune(progress, frontX, barW, barH, fillLX, fillW)

    for _, m in ipairs(smokes) do UpdateSmoke(m, dt, 1) end

    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, 1) end
    emberSpawnAcc = emberSpawnAcc + dt
    if emberSpawnAcc >= EMBER_SPAWN then
        emberSpawnAcc = 0
        local count = math.random(3, 6)
        for _ = 1, count do SpawnEmber(frontX, barCY) end
    end

    for _, p in ipairs(sparkParts) do UpdateSpark(p, dt, 1) end
    sparkSpawnAcc = sparkSpawnAcc + dt
    if sparkSpawnAcc >= SPARK_SPAWN then
        sparkSpawnAcc = 0
        local count = math.random(2, 4)
        for _ = 1, count do SpawnSpark(frontX, barCY) end
    end

    for _, p in ipairs(ambParts) do UpdateAmb(p, dt, 1) end
    ambSpawnAcc = ambSpawnAcc + dt
    if ambSpawnAcc >= AMB_SPAWN then
        ambSpawnAcc = 0
        SpawnAmb(progress)
    end
end
