-- ============================================================
--  Opulent Casting Bars — Particles_Inferno.lua
--  · Flammes animées en BG (Fire_Inferno_01..12, ping-pong)
--    + slot aléatoire supplémentaire
--  · Frame_Inferno_Light : reveal direct par SetTexCoord/largeur
--  · Fumée noire (Mist_Frost, rouge très sombre)
--  · Cendres + braises pixel
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
-- Slots décalés dans la séquence, crossfade entre chaque frame
local INFERNO_SLOT_COUNT = 2
local INFERNO_FRAME_DUR  = 0.12    -- durée d'affichage de chaque frame (~8 fps)
local INFERNO_XFADE_DUR  = 0.105   -- crossfade long pour lisser les flammes
local INFERNO_SLOT_ALPHA = 0.38    -- alpha par slot (moins de couches ADD superposées)
local INFERNO_RAND_COUNT = 1       -- slot aléatoire supplémentaire
local INFERNO_RAND_FADE_IN  = 0.36
local INFERNO_RAND_FADE_OUT = 0.52
local INFERNO_RAND_HOLD_MIN = 0.28
local INFERNO_RAND_HOLD_MAX = 0.8
local INFERNO_RAND_ALPHA    = 0.16
-- Instances de Frame_Inferno_Light en fond (glow ambiant)
local INFERNO_LIGHT_BG_COUNT    = 1
local INFERNO_LIGHT_BG_ALPHA    = 0.08
local INFERNO_LIGHT_BG_FADE_IN  = 0.40
local INFERNO_LIGHT_BG_FADE_OUT = 0.50
local INFERNO_LIGHT_BG_HOLD_MIN = 0.9
local INFERNO_LIGHT_BG_HOLD_MAX = 2.8
local INFERNO_PROGRESS_OFFSET_X = 5
local INFERNO_PARTICLE_STEP = 0.040

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
-- 3 positions × 2 passes = 6 couches de fumée.
local SMOKE_POSITIONS = {1/5, 2/5, 3/5}

-- ============================================================
--  CONSTANTES CENDRES
-- ============================================================

local EMBER_COUNT = 54
local EMBER_SPAWN = 0.050

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

local SPARK_COUNT     = 28
local SPARK_SPAWN     = 0.070
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

local AMB_COUNT     = 12
local AMB_SPAWN     = 0.180
local OUTSIDE_COUNT = 6
local OUTSIDE_SPAWN = 0.180

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
local particleStepAcc = 0
local fadeParticleStepAcc = 0

-- Animation de fond
local infernoBgPaths      = {}   -- chemins des 12 textures
local infernoSlots        = {}   -- slots, chacun avec texCur+texNext+seqPos+timer
local infernoRandSlots    = {}
local infernoLightBgSlots = {}   -- instances Frame_Inferno_Light en fond (glow ambiant)
local infernoProgressTextures = {}
local infernoFrameLightTex  = nil
local infernoFrameLightPath = nil
local infernoFrameLightReady = false
local infernoProgressW = nil
local infernoProgressH = nil
local infernoProgressRevealW = nil
local infernoFrameLightW = nil
local infernoFrameLightH = nil
local infernoFrameLightRevealW = nil

-- WeakAuras-style reveal: crop each fire texture with texcoords and width.
local function RegisterInfernoProgressTexture(tex)
    if tex then
        infernoProgressTextures[#infernoProgressTextures + 1] = tex
    end
end

local function LayoutInfernoProgress(progress)
    local bar = SCB.Bar
    local f   = bar and bar.frame
    if not f then return end

    local barW = f:GetWidth()
    local barH = f:GetHeight()
    if not barW or not barH or barW <= 0 or barH <= 0 then return end

    progress = Clamp01(progress)

    local startOffset = INFERNO_PROGRESS_OFFSET_X
    local usableW = math.max(barW - startOffset, 1)
    local revealW = math.max(math.floor(usableW * progress + 0.5), 1)
    local revealR = startOffset + revealW
    local u0 = startOffset / barW
    local u1 = revealR / barW
    local resized = infernoProgressW ~= barW or infernoProgressH ~= barH

    if resized then
        infernoProgressW = barW
        infernoProgressH = barH
        infernoProgressRevealW = nil
        for _, tex in ipairs(infernoProgressTextures) do
            tex:ClearAllPoints()
            tex:SetPoint("LEFT", f, "LEFT", startOffset, 0)
            tex:SetHeight(barH)
        end
    end

    if infernoProgressRevealW ~= revealW then
        infernoProgressRevealW = revealW
        for _, tex in ipairs(infernoProgressTextures) do
            tex:SetWidth(revealW)
            tex:SetTexCoord(u0, 0, u0, 1, u1, 0, u1, 1)
        end
    end
end

local function LayoutInfernoFrameLight(progress)
    local bar = SCB.Bar
    local f   = bar and bar.frameInner
    if not (f and infernoFrameLightTex) then return end

    local frameW = f:GetWidth()
    local frameH = f:GetHeight()
    if not frameW or not frameH or frameW <= 0 or frameH <= 0 then return end

    progress = Clamp01(progress)

    local revealW = math.max(math.floor(frameW * progress + 0.5), 1)
    local u1 = revealW / frameW

    if not infernoFrameLightReady then
        infernoFrameLightTex:SetTexture(infernoFrameLightPath or (SCB.TEX_PATH .. "inferno\\Frame_Inferno_Light"))
        infernoFrameLightTex:SetBlendMode("BLEND")
        infernoFrameLightReady = true
    end

    if infernoFrameLightW ~= frameW or infernoFrameLightH ~= frameH then
        infernoFrameLightW = frameW
        infernoFrameLightH = frameH
        infernoFrameLightRevealW = nil
        infernoFrameLightTex:ClearAllPoints()
        infernoFrameLightTex:SetPoint("LEFT", f, "LEFT", 0, 0)
        infernoFrameLightTex:SetHeight(frameH)
    end

    if infernoFrameLightRevealW ~= revealW then
        infernoFrameLightRevealW = revealW
        infernoFrameLightTex:SetWidth(revealW)
        infernoFrameLightTex:SetTexCoord(0, 0, 0, 1, u1, 0, u1, 1)
    end
end

local function UpdateInfernoProgress(progress)
    LayoutInfernoProgress(progress)
    LayoutInfernoFrameLight(progress)
end

local function SetTextureCached(owner, key, tex, path)
    if not path or owner[key] == path then return end
    tex:SetTexture(path)
    owner[key] = path
end

-- ============================================================
--  ANIMATION DE FOND — PING-PONG + SLOTS ALÉATOIRES
-- ============================================================

local function UpdateInfernoBackground(dt, globalFade)
    local gf = globalFade or 1

    -- Slots décalés avec crossfade vers la frame suivante
    for _, slot in ipairs(infernoSlots) do
        slot.timer = slot.timer + dt
        if slot.timer >= INFERNO_FRAME_DUR then
            slot.timer   = slot.timer - INFERNO_FRAME_DUR
            slot.seqPos  = (slot.seqPos % INFERNO_SEQ_LEN) + 1
            slot.texCur, slot.texNext = slot.texNext, slot.texCur
            slot.curPath, slot.nextPath = slot.nextPath, slot.curPath
            SetTextureCached(slot, "curPath", slot.texCur, infernoBgPaths[INFERNO_SEQ[slot.seqPos]])
        end
        local xfStart = INFERNO_FRAME_DUR - INFERNO_XFADE_DUR
        if slot.timer >= xfStart then
            local xfT    = math.min((slot.timer - xfStart) / INFERNO_XFADE_DUR, 1)
            local nxtPos = (slot.seqPos % INFERNO_SEQ_LEN) + 1
            SetTextureCached(slot, "nextPath", slot.texNext, infernoBgPaths[INFERNO_SEQ[nxtPos]])
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
                SetTextureCached(slot, "path", slot.tex, infernoBgPaths[idx])
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
                SetTextureCached(slot, "path", slot.tex, infernoBgPaths[math.random(12)])
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
        SetTextureCached(slot, "curPath", slot.texCur, infernoBgPaths[INFERNO_SEQ[slot.seqPos]])
        slot.texCur:SetAlpha(INFERNO_SLOT_ALPHA)
        slot.texNext:SetAlpha(0)
    end
    for i, slot in ipairs(infernoRandSlots) do
        slot.phase    = "fadein"
        slot.timer    = (i - 1) * (INFERNO_RAND_HOLD_MIN * 0.8)
        SetTextureCached(slot, "path", slot.tex, infernoBgPaths[math.random(12)])
        slot.tex:SetAlpha(0)
    end
    for i, slot in ipairs(infernoLightBgSlots) do
        slot.phase    = "fadein"
        slot.timer    = (i - 1) * 0.7
        slot.duration = rand(INFERNO_LIGHT_BG_HOLD_MIN, INFERNO_LIGHT_BG_HOLD_MAX)
        SetTextureCached(slot, "path", slot.tex, infernoBgPaths[math.random(12)])
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

local function SpawnSmoke(m, cx, cy)
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
    m.riseY = cy or m.riseY or 0
end

local function UpdateSmoke(m, dt, globalFade, cx, cy, barW)
    if m.delay and m.delay > 0 then m.delay = m.delay - dt ; return end
    if m.phase == "idle" then SpawnSmoke(m, cx, cy) ; return end

    if cx then
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

local function SpawnAmb(progress, cx, cy, barW, barH)
    if not cx then return end
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

local function SpawnOutside(cx, cy, barW, barH)
    if not cx then return end
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
    infernoProgressTextures = {}
    infernoProgressW = nil
    infernoProgressH = nil
    infernoProgressRevealW = nil
    infernoFrameLightW = nil
    infernoFrameLightH = nil
    infernoFrameLightRevealW = nil

    -- Chemins des 12 textures de fond Inferno
    infernoBgPaths = {}
    for i = 1, 12 do
        infernoBgPaths[i] = texPath .. string.format("inferno\\Fire_Inferno_%02d", i)
    end

    -- Slots décalés : chaque slot a 2 couches (texCur + texNext) pour crossfade
    infernoSlots = {}
    for i = 1, INFERNO_SLOT_COUNT do
        local function makeBgTex(subLvl)
            local t = f:CreateTexture(nil, "BACKGROUND", nil, subLvl)
            t:SetAllPoints(f) ; t:SetBlendMode("ADD") ; t:SetAlpha(0)
            RegisterInfernoProgressTexture(t)
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
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        RegisterInfernoProgressTexture(tex)
        infernoRandSlots[i] = {
            tex      = tex,
            phase    = "fadein",
            timer    = (i - 1) * 0.45,
            duration = rand(INFERNO_RAND_HOLD_MIN, INFERNO_RAND_HOLD_MAX),
        }
    end

    -- Texture-only glow slots, revealed by the same direct crop as the main fire.
    -- Slots Fire_Inferno supplémentaires en fond (glow ambiant, boucle infinie)
    -- Séquence indépendante des slots principaux pour encore plus de douceur
    infernoLightBgSlots = {}
    for i = 1, INFERNO_LIGHT_BG_COUNT do
        local tex = f:CreateTexture(nil, "BACKGROUND", nil, -1)
        tex:SetAllPoints(f)
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        RegisterInfernoProgressTexture(tex)
        infernoLightBgSlots[i] = {
            tex      = tex,
            phase    = "fadein",
            timer    = (i - 1) * 0.7,
            duration = rand(INFERNO_LIGHT_BG_HOLD_MIN, INFERNO_LIGHT_BG_HOLD_MAX),
        }
    end

    -- Initialize the crop reveal before the first cast update.
    LayoutInfernoProgress(0)

    local infernoSchool = SCB.Schools and SCB.Schools.data and SCB.Schools.data["inferno"]
    infernoFrameLightPath = (infernoSchool and infernoSchool.frameLight) or (texPath .. "inferno\\Frame_Inferno_Light")
    infernoFrameLightTex = f:CreateTexture(nil, "OVERLAY", nil, 2)
    infernoFrameLightTex:SetTexture(infernoFrameLightPath)
    infernoFrameLightTex:SetBlendMode("BLEND")
    infernoFrameLightTex:SetAlpha(0)
    infernoFrameLightReady = true
    LayoutInfernoFrameLight(0)

    -- Fumée (6 couches : 3 positions × 2 passes)
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
    partsFadeT      = 0
    emberSpawnAcc   = 0
    sparkSpawnAcc   = 0
    ambSpawnAcc     = 0
    outsideSpawnAcc = 0
    particleStepAcc = 0
    fadeParticleStepAcc = 0

    local bar = SCB.Bar
    LayoutInfernoProgress(0)
    LayoutInfernoFrameLight(0)
    if infernoFrameLightTex then infernoFrameLightTex:SetAlpha(1) end
    if bar.texFrameLight then bar.texFrameLight:SetAlpha(0) end

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
    fadeParticleStepAcc = 0
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
    if infernoFrameLightTex then infernoFrameLightTex:SetAlpha(gFade) end
    fadeParticleStepAcc = fadeParticleStepAcc + dt
    if fadeParticleStepAcc >= INFERNO_PARTICLE_STEP then
        local pdt = math.min(fadeParticleStepAcc, INFERNO_PARTICLE_STEP * 2)
        fadeParticleStepAcc = 0
        local f = SCB.Bar and SCB.Bar.frame
        local bx, by, bw = nil, nil, nil
        if f then
            bx, by = f:GetCenter()
            bw = f:GetWidth()
        end
        for _, m in ipairs(smokes)       do UpdateSmoke(m,   pdt, gFade, bx, by, bw or 1) end
        for _, p in ipairs(emberParts)   do UpdateEmber(p,   pdt, gFade) end
        for _, p in ipairs(sparkParts)   do UpdateSpark(p,   pdt, gFade) end
        for _, p in ipairs(ambParts)     do UpdateAmb(p,     pdt, gFade) end
        for _, p in ipairs(outsideParts) do UpdateOutside(p, pdt, gFade) end
    end
    if partsFadeT >= PARTS_FADE_DUR then
        partsFading = false
        if infernoFrameLightTex then infernoFrameLightTex:SetAlpha(0) end
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
    particleStepAcc = 0
    fadeParticleStepAcc = 0
    if infernoFrameLightTex then infernoFrameLightTex:SetAlpha(0) end
    for _, m in ipairs(smokes)       do m.tex:SetAlpha(0) ; m.phase = "idle" end
    for _, p in ipairs(emberParts)   do p.active = false  ; p.tex:SetAlpha(0) end
    for _, p in ipairs(sparkParts)   do p.active = false  ; p.tex:SetAlpha(0) end
    for _, p in ipairs(ambParts)     do p.active = false  ; p.tex:SetAlpha(0) end
    for _, p in ipairs(outsideParts) do p.active = false  ; p.tex:SetAlpha(0) end
    HideInfernoBackground()
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end
    local barCY = cy
    if not barCY then return end

    -- Animation de fond Inferno
    UpdateInfernoBackground(dt, 1)
    UpdateInfernoProgress(progress)

    particleStepAcc = particleStepAcc + dt
    if particleStepAcc < INFERNO_PARTICLE_STEP then return end
    local pdt = math.min(particleStepAcc, INFERNO_PARTICLE_STEP * 2)
    particleStepAcc = 0
    if not (frontX and fillLX and fillW and barH) then return end
    local particleCX = fillLX + fillW * 0.5

    -- Fumée
    for _, m in ipairs(smokes) do UpdateSmoke(m, pdt, 1, particleCX, barCY, fillW) end

    -- Cendres (front)
    for _, p in ipairs(emberParts) do UpdateEmber(p, pdt, 1) end
    emberSpawnAcc = emberSpawnAcc + pdt
    if emberSpawnAcc >= EMBER_SPAWN then
        emberSpawnAcc = 0
        local count = math.random(1, 2)
        for _ = 1, count do SpawnEmber(frontX, barCY) end
    end

    -- Braises pixel
    for _, p in ipairs(sparkParts) do UpdateSpark(p, pdt, 1) end
    sparkSpawnAcc = sparkSpawnAcc + pdt
    if sparkSpawnAcc >= SPARK_SPAWN then
        sparkSpawnAcc = 0
        local count = math.random(1, 2)
        for _ = 1, count do SpawnSpark(frontX, barCY) end
    end

    -- Cendres ambiantes
    for _, p in ipairs(ambParts) do UpdateAmb(p, pdt, 1) end
    ambSpawnAcc = ambSpawnAcc + pdt
    if ambSpawnAcc >= AMB_SPAWN then
        ambSpawnAcc = 0
        SpawnAmb(progress, particleCX, barCY, fillW, barH)
    end

    -- Particules hors barre
    for _, p in ipairs(outsideParts) do UpdateOutside(p, pdt, 1) end
    outsideSpawnAcc = outsideSpawnAcc + pdt
    if outsideSpawnAcc >= OUTSIDE_SPAWN then
        outsideSpawnAcc = 0
        SpawnOutside(particleCX, barCY, fillW, barH)
    end
end
