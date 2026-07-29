-- ============================================================
--  Opulent Casting Bars — Particles_Inferno.lua
--  · Flammes animées en BG (Fire_Inferno_01..12, ping-pong)
--    + 3 slots aléatoires supplémentaires
--  · Frame_Inferno_Light : masque full-frame indépendant du fill
--  · Fumée noire (Mist_Frost, rouge très sombre)
--  · Cendres abondantes + braises pixel (Lava ×1.5)
--  · Particules hors barre (émissions latérales)
-- ============================================================

local FX = {}
SCB.FX            = SCB.FX or {}
SCB.FX["inferno"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end

local function Clamp01(v)
    if type(v) ~= "number" or v ~= v then return 0 end
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

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
--  CONSTANTES ANIMATION DE FOND
-- ============================================================

-- Séquence ping-pong : 1→12→1→...
local INFERNO_SEQ = {1,2,3,4,5,6,7,8,9,10,11,12,11,10,9,8,7,6,5,4,3,2}
local INFERNO_SEQ_LEN   = #INFERNO_SEQ
-- 3 slots décalés dans la séquence, crossfade entre chaque frame
local INFERNO_SLOT_COUNT = 3
local INFERNO_FRAME_DUR  = 0.20    -- durée d'affichage de chaque frame (~5 fps)
local INFERNO_XFADE_DUR  = 0.18    -- fondu entre frames (90% du cycle pour transition douce)
local INFERNO_SLOT_ALPHA = 0.32    -- alpha par slot (3 couches ADD superposées)
local INFERNO_RAND_COUNT = 3      -- slots aléatoires supplémentaires
local INFERNO_RAND_FADE_IN  = 0.50
local INFERNO_RAND_FADE_OUT = 0.70
local INFERNO_RAND_HOLD_MIN = 0.35
local INFERNO_RAND_HOLD_MAX = 1.1
local INFERNO_RAND_ALPHA    = 0.30
-- 3 instances de Frame_Inferno_Light en fond (glow ambiant)
local INFERNO_LIGHT_BG_COUNT    = 3
local INFERNO_LIGHT_BG_ALPHA    = 0.18
local INFERNO_LIGHT_BG_FADE_IN  = 0.45
local INFERNO_LIGHT_BG_FADE_OUT = 0.55
local INFERNO_LIGHT_BG_HOLD_MIN = 0.9
local INFERNO_LIGHT_BG_HOLD_MAX = 2.8

-- ============================================================
--  CONSTANTES FUMÉE
-- ============================================================

local SMOKE_W_BASE    = 310
local SMOKE_H_BASE    = 155
local SMOKE_ALPHA_MAX = 0.40
local SMOKE_SCALE_MIN = 0.8
local SMOKE_SCALE_MAX = 1.5
local SMOKE_FADE_IN   = 1.8
local SMOKE_HOLD_MIN  = 1.2
local SMOKE_HOLD_MAX  = 2.8
local SMOKE_FADE_OUT  = 1.5
local SMOKE_ROT_SPEED = 0.03
-- 6 positions × 2 passes = 12 couches de fumée (plus que Lava)
local SMOKE_POSITIONS = {1/8, 2/8, 3/8, 4/8, 5/8, 6/8}

-- ============================================================
--  CONSTANTES CENDRES
-- ============================================================

local EMBER_COUNT = 130
local EMBER_SPAWN = 0.016

local emberTypes = {
    { sizeMin=8,  sizeMax=18, speedMin=22, speedMax=65,  lifeMin=0.9, lifeMax=2.0, gravity=5,  spread=170, driftX=0.6 },
    { sizeMin=4,  sizeMax=10, speedMin=75, speedMax=180, lifeMin=0.3, lifeMax=0.8, gravity=11, spread=100, driftX=0.0 },
    { sizeMin=5,  sizeMax=15, speedMin=38, speedMax=95,  lifeMin=0.7, lifeMax=1.5, gravity=16, spread=130, driftX=0.4 },
}

local EMBER_COLORS = {
    { 1.0, 0.30, 0.01 },
    { 1.0, 0.10, 0.00 },
    { 1.0, 0.50, 0.03 },
    { 1.0, 0.65, 0.10 },
}

-- ============================================================
--  CONSTANTES BRAISES PIXEL
-- ============================================================

local SPARK_COUNT     = 75
local SPARK_SPAWN     = 0.025
local SPARK_SIZE_MIN  = 3
local SPARK_SIZE_MAX  = 8
local SPARK_LIFE_MIN  = 0.4
local SPARK_LIFE_MAX  = 1.3
local SPARK_SPEED_MIN = 35
local SPARK_SPEED_MAX = 115
local SPARK_GRAVITY   = 22

local SPARK_COLORS = {
    { 1.0, 0.95, 0.15, 1.0  },
    { 1.0, 0.75, 0.05, 0.90 },
    { 1.0, 0.98, 0.35, 0.65 },
    { 1.0, 0.60, 0.02, 0.75 },
    { 1.0, 1.00, 0.55, 0.50 },
    { 1.0, 0.40, 0.00, 0.85 },
}

-- ============================================================
--  CONSTANTES AMBIANTES + HORS BARRE
-- ============================================================

local AMB_COUNT     = 60
local AMB_SPAWN     = 0.055
local OUTSIDE_COUNT = 30
local OUTSIDE_SPAWN = 0.040

local PARTS_FADE_DUR = 0.8
local castDuration   = 5

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local isActive        = false
local partsFading     = false
local partsFadeT      = 0
local smokes          = {}
local emberParts      = {}
local sparkParts      = {}
local ambParts        = {}
local outsideParts    = {}
local emberSpawnAcc   = 0
local sparkSpawnAcc   = 0
local ambSpawnAcc     = 0
local outsideSpawnAcc = 0

-- Animation de fond
local infernoBgPaths      = {}   -- chemins des 12 textures
local infernoSlots        = {}   -- 3 slots, chacun avec texCur+texNext+seqPos+timer
local infernoRandSlots    = {}
local infernoLightBgSlots = {}   -- 3 instances Frame_Inferno_Light en fond (glow ambiant)

-- Masque de progression pour les textures Fire_Inferno de fond.
-- Même logique que Frostfire: masque ancré au bord gauche de la frame
-- principale, largeur pilotée par la progression du cast.
local infernoLightMask = nil

local function UpdateInfernoMask(progress)
    if not infernoLightMask then return end
    local bar = SCB.Bar
    local f   = bar.frame
    if not f then return end
    local barW = f:GetWidth()
    local startOffset = 5
    -- Décaler le départ de 5px vers la droite pour mieux coller au fill.
    local usableW = math.max(barW - startOffset, 1)
    infernoLightMask:SetWidth(math.max(usableW * progress, 1))
end

-- ============================================================
--  ANIMATION DE FOND — PING-PONG + SLOTS ALÉATOIRES
-- ============================================================

local function UpdateInfernoBackground(dt, globalFade)
    local gf = globalFade or 1

    -- 3 slots décalés avec crossfade vers la frame suivante
    for _, slot in ipairs(infernoSlots) do
        slot.timer = slot.timer + dt
        if slot.timer >= INFERNO_FRAME_DUR then
            slot.timer   = slot.timer - INFERNO_FRAME_DUR
            slot.seqPos  = (slot.seqPos % INFERNO_SEQ_LEN) + 1
            slot.texCur, slot.texNext = slot.texNext, slot.texCur
        end
        local xfStart = INFERNO_FRAME_DUR - INFERNO_XFADE_DUR
        if slot.timer >= xfStart then
            local xfT    = math.min((slot.timer - xfStart) / INFERNO_XFADE_DUR, 1)
            local nxtPos = (slot.seqPos % INFERNO_SEQ_LEN) + 1
            slot.texNext:SetTexture(infernoBgPaths[INFERNO_SEQ[nxtPos]])
            slot.texCur:SetAlpha(Clamp01((1 - xfT) * INFERNO_SLOT_ALPHA * gf))
            slot.texNext:SetAlpha(Clamp01(xfT * INFERNO_SLOT_ALPHA * gf))
        else
            slot.texCur:SetAlpha(Clamp01(INFERNO_SLOT_ALPHA * gf))
            slot.texNext:SetAlpha(0)
        end
    end

    -- Slots aléatoires indépendants (Fire_Inferno)
    for _, slot in ipairs(infernoRandSlots) do
        slot.timer = slot.timer + dt
        if slot.phase == "fadein" then
            local a = math.min(slot.timer / INFERNO_RAND_FADE_IN, 1)
            slot.tex:SetAlpha(Clamp01(a * INFERNO_RAND_ALPHA * gf))
            if slot.timer >= INFERNO_RAND_FADE_IN then
                slot.phase = "hold" ; slot.timer = 0
                slot.duration = rand(INFERNO_RAND_HOLD_MIN, INFERNO_RAND_HOLD_MAX)
            end
        elseif slot.phase == "hold" then
            slot.tex:SetAlpha(Clamp01(INFERNO_RAND_ALPHA * gf))
            if slot.timer >= slot.duration then
                slot.phase = "fadeout" ; slot.timer = 0
            end
        elseif slot.phase == "fadeout" then
            local a = math.max(0, 1 - slot.timer / INFERNO_RAND_FADE_OUT)
            slot.tex:SetAlpha(Clamp01(a * INFERNO_RAND_ALPHA * gf))
            if slot.timer >= INFERNO_RAND_FADE_OUT then
                local idx = math.random(12)
                slot.tex:SetTexture(infernoBgPaths[idx])
                slot.phase = "fadein" ; slot.timer = 0
            end
        end
    end

    -- Slots Frame_Inferno_Light en fond (glow ambiant, boucle infinie)
    for _, slot in ipairs(infernoLightBgSlots) do
        slot.timer = slot.timer + dt
        if slot.phase == "fadein" then
            local a = math.min(slot.timer / INFERNO_LIGHT_BG_FADE_IN, 1)
            slot.tex:SetAlpha(Clamp01(a * INFERNO_LIGHT_BG_ALPHA * gf))
            if slot.timer >= INFERNO_LIGHT_BG_FADE_IN then
                slot.phase = "hold" ; slot.timer = 0
                slot.duration = rand(INFERNO_LIGHT_BG_HOLD_MIN, INFERNO_LIGHT_BG_HOLD_MAX)
            end
        elseif slot.phase == "hold" then
            slot.tex:SetAlpha(Clamp01(INFERNO_LIGHT_BG_ALPHA * gf))
            if slot.timer >= slot.duration then
                slot.phase = "fadeout" ; slot.timer = 0
            end
        elseif slot.phase == "fadeout" then
            local a = math.max(0, 1 - slot.timer / INFERNO_LIGHT_BG_FADE_OUT)
            slot.tex:SetAlpha(Clamp01(a * INFERNO_LIGHT_BG_ALPHA * gf))
            if slot.timer >= INFERNO_LIGHT_BG_FADE_OUT then
                slot.tex:SetTexture(infernoBgPaths[math.random(12)])
                slot.phase = "fadein" ; slot.timer = 0
            end
        end
    end
end

local function ResetInfernoBackground()
    local step = math.floor(INFERNO_SEQ_LEN / INFERNO_SLOT_COUNT)
    for i, slot in ipairs(infernoSlots) do
        slot.seqPos = ((i - 1) * step) % INFERNO_SEQ_LEN + 1
        slot.timer  = 0
        slot.texCur:SetTexture(infernoBgPaths[INFERNO_SEQ[slot.seqPos]])
        slot.texCur:SetAlpha(INFERNO_SLOT_ALPHA)
        slot.texNext:SetAlpha(0)
    end
    for i, slot in ipairs(infernoRandSlots) do
        slot.phase    = "fadein"
        slot.timer    = (i - 1) * (INFERNO_RAND_HOLD_MIN * 0.8)
        slot.tex:SetTexture(infernoBgPaths[math.random(12)])
        slot.tex:SetAlpha(0)
    end
    for i, slot in ipairs(infernoLightBgSlots) do
        slot.phase    = "fadein"
        slot.timer    = (i - 1) * 0.7
        slot.duration = rand(INFERNO_LIGHT_BG_HOLD_MIN, INFERNO_LIGHT_BG_HOLD_MAX)
        slot.tex:SetTexture(infernoBgPaths[math.random(12)])
        slot.tex:SetAlpha(0)
    end
end

local function HideInfernoBackground()
    for _, slot in ipairs(infernoSlots) do
        slot.texCur:SetAlpha(0) ; slot.texNext:SetAlpha(0)
    end
    for _, slot in ipairs(infernoRandSlots)    do slot.tex:SetAlpha(0) end
    for _, slot in ipairs(infernoLightBgSlots) do slot.tex:SetAlpha(0) end
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
        local x    = cx - barW * 0.5 + barW * m.xFrac
        m.riseY = (m.riseY or cy) + 12 * dt
        m.tex:ClearAllPoints()
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
        m.tex:SetAlpha(Clamp01(math.max(0, m.alpha) * gf))
        if m.timer >= m.duration then
            m.phase = "hold" ; m.timer = 0
            m.duration = rand(SMOKE_HOLD_MIN, SMOKE_HOLD_MAX)
        end
    elseif m.phase == "hold" then
        local pulse = math.sin(m.scaleT * 1.5) * 0.04
        m.tex:SetAlpha(Clamp01(math.max(0, SMOKE_ALPHA_MAX + pulse) * gf))
        if m.timer >= m.duration then
            m.phase = "fadeout" ; m.timer = 0 ; m.duration = SMOKE_FADE_OUT
        end
    elseif m.phase == "fadeout" then
        m.alpha = (1 - m.timer / m.duration) * SMOKE_ALPHA_MAX
        m.tex:SetAlpha(Clamp01(math.max(0, m.alpha) * gf))
        if m.timer >= m.duration then
            m.tex:SetAlpha(0) ; m.phase = "idle"
        end
    end
end

-- ============================================================
--  CENDRES
-- ============================================================

local function SpawnEmber(wx, wy)
    local roll    = math.random(10)
    local typeIdx = roll <= 4 and 1 or (roll <= 7 and 3 or 2)
    local ptype   = emberTypes[typeIdx]
    local col     = EMBER_COLORS[math.random(#EMBER_COLORS)]

    for _, p in ipairs(emberParts) do
        if not p.active and p.typeIdx == typeIdx then
            local tCast = math.max(0, math.min((castDuration - 2) / 3, 1))
            local speed = rand(lerp(ptype.speedMax * 0.5, ptype.speedMin, tCast),
                               lerp(ptype.speedMax, ptype.speedMax * 0.8, tCast))
            local angle = rad(90 + rand(-ptype.spread * 0.5, ptype.spread * 0.5))
            local size  = rand(ptype.sizeMin, ptype.sizeMax)
            p.active  = true ; p.life = 0
            p.maxLife = rand(ptype.lifeMin, ptype.lifeMax)
            p.x       = wx + rand(-8, 8)
            p.y       = wy + rand(-10, 10)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            p.drift   = rand(-ptype.driftX, ptype.driftX) * 30
            p.tex:SetVertexColor(col[1], col[2], col[3])
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(1)
            p.tex:ClearAllPoints()
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
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha
    if p.typeIdx == 2 then
        alpha = t < 0.15 and 1 or math.max(0, 1 - (t - 0.15) / 0.85)
    else
        alpha = t < 0.5 and 1 or math.max(0, (1 - t) / 0.5)
    end
    p.tex:SetAlpha(Clamp01(alpha * 0.9 * (globalFade or 1)))
end

-- ============================================================
--  BRAISES PIXEL
-- ============================================================

local function SpawnSpark(wx, wy)
    local col = SPARK_COLORS[math.random(#SPARK_COLORS)]
    for _, p in ipairs(sparkParts) do
        if not p.active then
            local angle = rad(rand(25, 155))
            local speed = rand(SPARK_SPEED_MIN, SPARK_SPEED_MAX)
            p.active    = true ; p.life = 0
            p.maxLife   = rand(SPARK_LIFE_MIN, SPARK_LIFE_MAX)
            p.x         = wx + rand(-5, 5)
            p.y         = wy + rand(-8, 8)
            p.vx        = math.cos(angle) * speed
            p.vy        = math.sin(angle) * speed
            p.baseAlpha = col[4]
            p.tex:SetVertexColor(col[1], col[2], col[3])
            local size = rand(SPARK_SIZE_MIN, SPARK_SIZE_MAX)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
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
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env
    if t < 0.15 then env = t / 0.15
    elseif t < 0.75 then env = 1 + math.sin(p.life * 18) * 0.15
    else env = (1 - t) / 0.25 end
    p.tex:SetAlpha(Clamp01(math.max(0, env) * p.baseAlpha * (globalFade or 1)))
end

-- ============================================================
--  CENDRES AMBIANTES
-- ============================================================

local function SpawnAmb(progress)
    local f = SCB.Bar.frame
    local cx, cy = f:GetCenter()
    if not cx then return end
    local barW, barH = f:GetWidth(), f:GetHeight()

    for _, p in ipairs(ambParts) do
        if not p.active then
            -- Spawn réparti sur toute la zone déjà remplie (gauche → front du fill)
            local fillEdge = (progress - 0.5) * barW
            local xOffset = rand(-barW * 0.5, math.max(-barW * 0.5 + 4, fillEdge))
            local yOffset = rand(-barH * 0.40, barH * 0.40)
            local wx, wy  = cx + xOffset, cy + yOffset
            local dirX    = xOffset > 0 and 1 or -1
            local angle   = rad(rand(55, 125)) * (yOffset > 0 and 1 or -1)
            local speed   = rand(18, 55)
            local col     = EMBER_COLORS[math.random(#EMBER_COLORS)]

            p.active  = true ; p.life = 0
            p.maxLife = rand(1.0, 2.5)
            p.x       = wx ; p.y = wy
            p.vx      = dirX * rand(5, 25)
            p.vy      = math.sin(angle) * speed
            p.tex:SetVertexColor(col[1], col[2], col[3])
            local size = rand(5, 15)
            p.tex:ClearAllPoints()
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
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha
    if t < 0.1 then alpha = t / 0.1
    elseif t < 0.65 then alpha = 1
    else alpha = (1 - t) / 0.35 end
    p.tex:SetAlpha(Clamp01(math.max(0, alpha) * 0.60 * (globalFade or 1)))
end

-- ============================================================
--  PARTICULES HORS BARRE (gauche / droite)
-- ============================================================

local function SpawnOutside()
    local f = SCB.Bar.frame
    local cx, cy = f:GetCenter()
    if not cx then return end
    local barW, barH = f:GetWidth(), f:GetHeight()
    local col = EMBER_COLORS[math.random(#EMBER_COLORS)]

    for _, p in ipairs(outsideParts) do
        if not p.active then
            -- Spawn réparti sur tous les bords de la barre (pas seulement les côtés)
            local edge = math.random(4)  -- 1=haut, 2=bas, 3=gauche, 4=droite
            local wx, wy, baseAng
            if edge == 1 then       -- bord supérieur
                wx = cx + rand(-barW * 0.5, barW * 0.5)
                wy = cy + barH * 0.5 + rand(2, 8)
                baseAng = rand(55, 125)
            elseif edge == 2 then   -- bord inférieur
                wx = cx + rand(-barW * 0.5, barW * 0.5)
                wy = cy - barH * 0.5 - rand(2, 8)
                baseAng = rand(60, 120)
            elseif edge == 3 then   -- côté gauche
                wx = cx - barW * 0.5 - rand(2, 14)
                wy = cy + rand(-barH * 0.5, barH * 0.5)
                baseAng = rand(60, 120)
            else                    -- côté droit
                wx = cx + barW * 0.5 + rand(2, 14)
                wy = cy + rand(-barH * 0.5, barH * 0.5)
                baseAng = rand(60, 120)
            end
            local angle = rad(baseAng + rand(-15, 15))
            local speed = rand(45, 130)

            p.active  = true ; p.life = 0
            p.maxLife = rand(0.6, 1.9)
            p.x       = wx ; p.y = wy
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            p.drift   = rand(-18, 18)
            p.tex:SetVertexColor(col[1], col[2], col[3])
            local size = rand(5, 15)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateOutside(p, dt, globalFade)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - 7 * dt
    p.vx = p.vx + p.drift * dt * (1 - t)
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha
    if t < 0.12 then alpha = t / 0.12
    elseif t < 0.60 then alpha = 1
    else alpha = (1 - t) / 0.40 end
    p.tex:SetAlpha(Clamp01(math.max(0, alpha) * 0.85 * (globalFade or 1)))
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local texPath = SCB.TEX_PATH
    local f       = SCB.Bar.frame   -- frame principale (comme Frostfire)

    -- Chemins des 12 textures de fond Inferno
    infernoBgPaths = {}
    for i = 1, 12 do
        infernoBgPaths[i] = texPath .. string.format("inferno\\Fire_Inferno_%02d", i)
    end

    -- 3 slots décalés : chaque slot a 2 couches (texCur + texNext) pour crossfade
    infernoSlots = {}
    for i = 1, INFERNO_SLOT_COUNT do
        local function makeBgTex(subLvl)
            local t = f:CreateTexture(nil, "BACKGROUND", nil, subLvl)
            t:SetAllPoints(f) ; t:SetBlendMode("ADD") ; t:SetAlpha(0)
            return t
        end
        infernoSlots[i] = {
            texCur  = makeBgTex(-4 + (i - 1)),
            texNext = makeBgTex(-4 + (i - 1)),
            seqPos  = 1,
            timer   = 0,
        }
    end

    -- Slots aléatoires supplémentaires
    infernoRandSlots = {}
    for i = 1, INFERNO_RAND_COUNT do
        local subLvl = -3 + (i % 2)
        local tex = f:CreateTexture(nil, "BACKGROUND", nil, subLvl)
        tex:SetAllPoints(f)
        tex:SetTexture(infernoBgPaths[math.random(12)])
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        infernoRandSlots[i] = {
            tex      = tex,
            phase    = "fadein",
            timer    = (i - 1) * 0.45,
            duration = rand(INFERNO_RAND_HOLD_MIN, INFERNO_RAND_HOLD_MAX),
        }
    end

    -- Masque de progression pour les textures Fire_Inferno de fond
    -- 3 slots Fire_Inferno supplémentaires en fond (glow ambiant, boucle infinie)
    -- Séquence indépendante des 3 slots principaux pour encore plus de douceur
    infernoLightBgSlots = {}
    for i = 1, INFERNO_LIGHT_BG_COUNT do
        local tex = f:CreateTexture(nil, "BACKGROUND", nil, -1)
        tex:SetAllPoints(f)
        tex:SetTexture(infernoBgPaths[math.random(12)])
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        infernoLightBgSlots[i] = {
            tex      = tex,
            phase    = "fadein",
            timer    = (i - 1) * 0.7,
            duration = rand(INFERNO_LIGHT_BG_HOLD_MIN, INFERNO_LIGHT_BG_HOLD_MAX),
        }
    end

    -- Masque de progression pour les textures Fire_Inferno (ancré en x=0, pas d'offset gauche).
    infernoLightMask = f:CreateMaskTexture()
    infernoLightMask:SetTexture("Interface\\BUTTONS\\WHITE8X8",
                                "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    infernoLightMask:SetPoint("TOPLEFT",    f, "TOPLEFT", 5, 0)
    infernoLightMask:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 5, 0)
    infernoLightMask:SetWidth(1)

    for _, slot in ipairs(infernoSlots) do
        slot.texCur:AddMaskTexture(infernoLightMask)
        slot.texNext:AddMaskTexture(infernoLightMask)
    end
    for _, slot in ipairs(infernoRandSlots) do
        slot.tex:AddMaskTexture(infernoLightMask)
    end
    for _, slot in ipairs(infernoLightBgSlots) do
        slot.tex:AddMaskTexture(infernoLightMask)
    end

    -- Fumée (12 couches : 6 positions × 2 passes)
    smokes = {}
    local mistTex = texPath .. "frost\\Mist_Frost_01"
    for i, xFrac in ipairs(SMOKE_POSITIONS) do
        for pass = 1, 2 do
            local idx = (i - 1) * 2 + pass
            local tex = bar:CreateTexture(nil, "BACKGROUND", nil, -2)
            tex:SetTexture(mistTex)
            tex:SetSize(SMOKE_W_BASE, SMOKE_H_BASE)
            tex:SetAlpha(0)
            tex:SetBlendMode("ADD")
            tex:SetVertexColor(0.10, 0.03, 0.01)
            local xf = pass == 1 and xFrac or math.min(xFrac + 0.04, 0.98)
            smokes[idx] = {
                tex      = tex,
                xFrac    = xf,
                phase    = "idle",
                timer    = 0,
                duration = 0,
                alpha    = 0,
                scaleT   = 0,
                scaleDir = (pass == 1) and 1 or -1,
                angle    = rand(0, math.pi * 2),
                rotDir   = (idx % 2 == 0) and 1 or -1,
                baseW    = SMOKE_W_BASE * (pass == 1 and 1.0 or 0.85),
                baseH    = SMOKE_H_BASE * (pass == 1 and 1.0 or 0.85),
                delay    = (idx - 1) * 0.38,
                riseY    = 0,
            }
        end
    end

    -- Textures misc (Misc_Earth) pour les cendres
    local earthSchool = SCB.Schools.data["earth"]
    local miscTexs = {}
    if earthSchool then
        for _, t in ipairs(earthSchool.rocks  or {}) do miscTexs[#miscTexs+1] = t end
        for _, t in ipairs(earthSchool.debris or {}) do miscTexs[#miscTexs+1] = t end
    end
    local function getMisc(i)
        if #miscTexs == 0 then return texPath .. "frost\\Particle_Frost_01" end
        return miscTexs[((i - 1) % #miscTexs) + 1]
    end

    -- Cendres
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
    local sparkTex = texPath .. "frost\\Particle_Frost_01"
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

    -- Particules hors barre
    outsideParts = {}
    for i = 1, OUTSIDE_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getMisc(i))
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        outsideParts[i] = {
            tex=tex, active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, drift=0,
        }
    end
end

function FX.Start(duration)
    castDuration    = duration or 5
    isActive        = true
    partsFading     = false
    emberSpawnAcc   = 0
    sparkSpawnAcc   = 0
    ambSpawnAcc     = 0
    outsideSpawnAcc = 0

    local bar = SCB.Bar
    if infernoLightMask then infernoLightMask:SetWidth(1) end

    -- Fumée
    local fi = bar.frameInner
    local _, cy = fi:GetCenter()
    for i, m in ipairs(smokes) do
        m.phase = "idle" ; m.delay = (i - 1) * 0.38
        m.tex:SetAlpha(0) ; m.riseY = cy or 0
    end

    for _, p in ipairs(emberParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(sparkParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(ambParts)     do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(outsideParts) do p.active = false ; p.tex:SetAlpha(0) end

    ResetInfernoBackground()
end

function FX.Stop()
    isActive        = false
    partsFading     = true
    partsFadeT      = 0
    emberSpawnAcc   = 0
    sparkSpawnAcc   = 0
    ambSpawnAcc     = 0
    outsideSpawnAcc = 0
    for _, m in ipairs(smokes) do
        if m.phase ~= "idle" then
            m.phase = "fadeout" ; m.timer = 0 ; m.duration = 0.5
        end
    end
    -- Pas de hide immédiat : UpdateFade gère le fondu progressif
    -- (background flames, Frame_Inferno_Light, slots aléatoires)
end

function FX.UpdateFade(dt)
    if not partsFading then return end
    partsFadeT = partsFadeT + dt
    local gFade = math.max(0, 1 - partsFadeT / PARTS_FADE_DUR)
    -- Fondu progressif du fond (flammes bg + lumières)
    UpdateInfernoBackground(dt, gFade)
    for _, m in ipairs(smokes)       do UpdateSmoke(m,   dt, gFade) end
    for _, p in ipairs(emberParts)   do UpdateEmber(p,   dt, gFade) end
    for _, p in ipairs(sparkParts)   do UpdateSpark(p,   dt, gFade) end
    for _, p in ipairs(ambParts)     do UpdateAmb(p,     dt, gFade) end
    for _, p in ipairs(outsideParts) do UpdateOutside(p, dt, gFade) end
    if partsFadeT >= PARTS_FADE_DUR then
        partsFading = false
        HideInfernoBackground()
        for _, m in ipairs(smokes)       do m.tex:SetAlpha(0) ; m.phase = "idle" end
        for _, p in ipairs(emberParts)   do p.active = false  ; p.tex:SetAlpha(0) end
        for _, p in ipairs(sparkParts)   do p.active = false  ; p.tex:SetAlpha(0) end
        for _, p in ipairs(ambParts)     do p.active = false  ; p.tex:SetAlpha(0) end
        for _, p in ipairs(outsideParts) do p.active = false  ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    partsFading = false
    for _, m in ipairs(smokes)       do m.tex:SetAlpha(0) ; m.phase = "idle" end
    for _, p in ipairs(emberParts)   do p.active = false  ; p.tex:SetAlpha(0) end
    for _, p in ipairs(sparkParts)   do p.active = false  ; p.tex:SetAlpha(0) end
    for _, p in ipairs(ambParts)     do p.active = false  ; p.tex:SetAlpha(0) end
    for _, p in ipairs(outsideParts) do p.active = false  ; p.tex:SetAlpha(0) end
    HideInfernoBackground()
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end
    local fi = SCB.Bar.frameInner
    local _, barCY = fi:GetCenter()
    if not barCY then return end

    -- Animation de fond Inferno
    UpdateInfernoBackground(dt, 1)
    UpdateInfernoMask(progress)

    -- Fumée
    for _, m in ipairs(smokes) do UpdateSmoke(m, dt, 1) end

    -- Cendres (front)
    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, 1) end
    emberSpawnAcc = emberSpawnAcc + dt
    if emberSpawnAcc >= EMBER_SPAWN then
        emberSpawnAcc = 0
        local count = math.random(4, 8)
        for _ = 1, count do SpawnEmber(frontX, barCY) end
    end

    -- Braises pixel
    for _, p in ipairs(sparkParts) do UpdateSpark(p, dt, 1) end
    sparkSpawnAcc = sparkSpawnAcc + dt
    if sparkSpawnAcc >= SPARK_SPAWN then
        sparkSpawnAcc = 0
        local count = math.random(3, 6)
        for _ = 1, count do SpawnSpark(frontX, barCY) end
    end

    -- Cendres ambiantes
    for _, p in ipairs(ambParts) do UpdateAmb(p, dt, 1) end
    ambSpawnAcc = ambSpawnAcc + dt
    if ambSpawnAcc >= AMB_SPAWN then
        ambSpawnAcc = 0
        SpawnAmb(progress)
    end

    -- Particules hors barre
    for _, p in ipairs(outsideParts) do UpdateOutside(p, dt, 1) end
    outsideSpawnAcc = outsideSpawnAcc + dt
    if outsideSpawnAcc >= OUTSIDE_SPAWN then
        outsideSpawnAcc = 0
        SpawnOutside()
    end
end
