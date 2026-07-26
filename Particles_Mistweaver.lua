-- ============================================================
--  Opulent Casting Bars — Particles_Mistweaver.lua
--
--  · Frame_Mistweaver_Light : suit la progression (masque horizontal)
--  · Mist ambient : réutilise Mist_Frost_01 recoloré jade/indigo
--  · Front FX : logique Metal (glow + embers) recolorée #36fbb6
--  · Feuilles : style Nature, densité réduite et recolorées #36fbb6
-- ============================================================

local FX = {}
SCB.FX               = SCB.FX or {}
SCB.FX["mistweaver"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end
local pi2 = math.pi * 2

local MW_R, MW_G, MW_B = 0x36/255, 0xFB/255, 0xB6/255

-- Mist (Frost)
local MIST_W_BASE    = 338
local MIST_H_BASE    = 169
local MIST_ALPHA_MAX = 0.50
local MIST_SCALE_MIN = 0.75
local MIST_SCALE_MAX = 1.30
local MIST_FADE_IN   = 1.8
local MIST_HOLD_MIN  = 1.2
local MIST_HOLD_MAX  = 2.5
local MIST_FADE_OUT  = 1.5
local MIST_ROT_SPEED = 0.04
local MIST_POSITIONS = { 2/8, 4/8, 6/8 }

-- Glow tip (Metal)
local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.02
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.55
local GLOW_SIZE_MIN   = 4
local GLOW_SIZE_MAX   = 9
local GLOW_LIFE_MIN   = 0.10
local GLOW_LIFE_MAX   = 0.20

-- Embers tip (Metal)
local EMBER_COUNT = 60
local EMBER_SPAWN = 0.03
local emberTypes = {
    { sizeMin=8,  sizeMax=14, speedMin=25, speedMax=60,  lifeMin=0.8, lifeMax=1.6, gravity=8,  spread=140, driftX=0.4 },
    { sizeMin=4,  sizeMax=8,  speedMin=80, speedMax=160, lifeMin=0.3, lifeMax=0.7, gravity=15, spread=80,  driftX=0.0 },
    { sizeMin=6,  sizeMax=12, speedMin=40, speedMax=90,  lifeMin=0.6, lifeMax=1.2, gravity=20, spread=100, driftX=0.2 },
}

-- Leaves (sur la barre): même apparence que les feuilles de front
local LEAF_COUNT         = 14
local LEAF_SPAWN_RATE    = 0.18
local LEAF_FLOW_SPEED_MIN= 35
local LEAF_FLOW_SPEED_MAX= 85
local LEAF_FLOW_ANGLE_MIN= -20
local LEAF_FLOW_ANGLE_MAX=  20

local FRONT_LEAF_COUNT   = 8
local FRONT_SPAWN_RATE   = 0.09
local FRONT_SIZE_MIN     = 7
local FRONT_SIZE_MAX     = 13
local FRONT_SPEED_MIN    = 25
local FRONT_SPEED_MAX    = 70
local FRONT_LIFE_MIN     = 0.40
local FRONT_LIFE_MAX     = 0.90
local FRONT_ALPHA        = 0.75
local FRONT_GRAVITY      = 18
local LEAF_ROT_MIN       = 0.8
local LEAF_ROT_MAX       = 2.6

local PARTS_FADE_DUR = 0.6

local castDuration = 5
local isActive = false
local partsFading = false
local partsFadeT = 0

local texLight = nil
local maskLight = nil

local mists = {}
local glowParts = {}
local emberParts = {}
local leaves = {}
local frontLeaves = {}

local glowAcc = 0
local emberAcc = 0
local leafAcc = 0
local frontLeafAcc = 0

local function SetTextureRotation(tex, angle)
    local c, s = math.cos(angle), math.sin(angle)
    tex:SetTexCoord(
        0.5 + (-0.5)*c - (-0.5)*s,  0.5 + (-0.5)*s + (-0.5)*c,
        0.5 + (-0.5)*c - ( 0.5)*s,  0.5 + (-0.5)*s + ( 0.5)*c,
        0.5 + ( 0.5)*c - (-0.5)*s,  0.5 + ( 0.5)*s + (-0.5)*c,
        0.5 + ( 0.5)*c - ( 0.5)*s,  0.5 + ( 0.5)*s + ( 0.5)*c
    )
end

local function SetTexRot(tex, rot)
    local c, s = math.cos(rot), math.sin(rot)
    tex:SetTexCoord(
        0.5 + (-0.5)*c - (-0.5)*s, 0.5 + (-0.5)*s + (-0.5)*c,
        0.5 + (-0.5)*c - ( 0.5)*s, 0.5 + (-0.5)*s + ( 0.5)*c,
        0.5 + ( 0.5)*c - (-0.5)*s, 0.5 + ( 0.5)*s + (-0.5)*c,
        0.5 + ( 0.5)*c - ( 0.5)*s, 0.5 + ( 0.5)*s + ( 0.5)*c
    )
end

-- Mist
local function SpawnMist(m)
    local scale = rand(MIST_SCALE_MIN, MIST_SCALE_MAX)
    m.baseW = MIST_W_BASE * scale
    m.baseH = MIST_H_BASE * scale
    m.tex:SetSize(m.baseW, m.baseH)
    m.tex:SetAlpha(0)
    m.phase = "fadein"
    m.timer = 0
    m.duration = MIST_FADE_IN
    m.alpha = 0
    m.scaleT = 0
    m.scaleDir = math.random(2) == 1 and 1 or -1
end

local function UpdateMist(m, dt)
    if m.delay and m.delay > 0 then m.delay = m.delay - dt ; return end
    if m.phase == "idle" then SpawnMist(m) ; return end

    local f = SCB.Bar.frameInner
    local cx, cy = f:GetCenter()
    if cx then
        local barW = f:GetWidth()
        local x = cx - barW * 0.5 + barW * m.xFrac
        m.tex:ClearAllPoints()
        m.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, cy)
    end

    m.timer  = m.timer + dt
    m.scaleT = m.scaleT + dt
    m.angle  = m.angle + MIST_ROT_SPEED * m.rotDir * dt

    local scalePulse = 1 + math.sin(m.scaleT * 0.45 * m.scaleDir) * 0.09
    m.tex:SetSize(m.baseW * scalePulse, m.baseH * scalePulse)
    SetTextureRotation(m.tex, m.angle)

    if m.phase == "fadein" then
        m.alpha = math.min(m.timer / m.duration, 1) * MIST_ALPHA_MAX
        local pulse = math.sin(m.scaleT * 1.8) * 0.035
        m.tex:SetAlpha(math.max(0, m.alpha + pulse))
        if m.timer >= m.duration then
            m.phase = "hold" ; m.timer = 0 ; m.duration = rand(MIST_HOLD_MIN, MIST_HOLD_MAX)
        end
    elseif m.phase == "hold" then
        local pulse = math.sin(m.scaleT * 1.8) * 0.06
        m.tex:SetAlpha(math.max(0, MIST_ALPHA_MAX + pulse))
        if m.timer >= m.duration then m.phase = "fadeout" ; m.timer = 0 ; m.duration = MIST_FADE_OUT end
    elseif m.phase == "fadeout" then
        m.alpha = (1 - m.timer / m.duration) * MIST_ALPHA_MAX
        m.tex:SetAlpha(math.max(0, m.alpha))
        if m.timer >= m.duration then m.tex:SetAlpha(0) ; m.phase = "idle" end
    end
end

-- Glow (Metal)
local function SpawnGlow(frontX, cy, barH)
    for _, p in ipairs(glowParts) do
        if not p.active then
            local spread = math.min(barH * 0.25, 10)
            p.active  = true ; p.life = 0
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

local function UpdateGlow(p, dt, globalFade)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy * 0.90
    p.y  = p.y + p.vy * dt + math.sin(p.life * 10 + p.phase) * 0.3
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)

    local env
    if t < 0.2 then env = t / 0.2
    elseif t < 0.8 then env = 1
    else env = (1 - t) / 0.2 end
    p.tex:SetAlpha(math.max(0, env) * GLOW_ALPHA * (globalFade or 1))
end

-- Embers (Metal)
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
            p.tex:ClearAllPoints()
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
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)

    local alpha
    if p.typeIdx == 2 then
        alpha = t < 0.15 and 1 or math.max(0, 1 - (t - 0.15) / 0.85)
    else
        alpha = t < 0.5 and 1 or math.max(0, (1 - t) / 0.5)
    end
    p.tex:SetAlpha(alpha * 0.85 * (globalFade or 1))
end

-- Leaves (Nature-style)
local function SpawnLeaf(barLX, barRX, barCY, barH)
    for _, lf in ipairs(leaves) do
        if not lf.active then
            local angle    = rad(rand(LEAF_FLOW_ANGLE_MIN, LEAF_FLOW_ANGLE_MAX))
            local speed    = rand(LEAF_FLOW_SPEED_MIN, LEAF_FLOW_SPEED_MAX)
            local size     = rand(FRONT_SIZE_MIN, FRONT_SIZE_MAX)
            local rotSpeed = rand(LEAF_ROT_MIN, LEAF_ROT_MAX) * (math.random(2) == 1 and 1 or -1)
            lf.active   = true
            lf.life     = 0
            lf.maxLife  = rand(FRONT_LIFE_MIN, FRONT_LIFE_MAX)
            lf.x        = barLX + rand(-8, 4)
            lf.y        = barCY + rand(-barH * 0.30, barH * 0.30)
            lf.vx       = math.cos(angle) * speed
            lf.vy       = math.sin(angle) * speed
            lf.rot      = rand(0, pi2)
            lf.rotSpeed = rotSpeed
            lf.size     = size
            lf.deadX    = barRX + size * 1.5
            lf.tex:SetSize(size, size)
            lf.tex:SetAlpha(FRONT_ALPHA)
            lf.tex:ClearAllPoints()
            lf.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", lf.x, lf.y)
            return
        end
    end
end

local function UpdateLeaf(lf, dt, globalFade)
    if not lf.active then return end
    lf.life = lf.life + dt
    local t = lf.life / lf.maxLife
    if t >= 1 or lf.x >= lf.deadX then
        lf.active = false ; lf.tex:SetAlpha(0) ; return
    end
    lf.vy  = lf.vy - FRONT_GRAVITY * dt
    lf.x   = lf.x + lf.vx * dt
    lf.y   = lf.y + lf.vy * dt
    lf.rot = lf.rot + lf.rotSpeed * dt
    local alpha = (t < 0.55 and 1 or math.max(0, (1 - t) / 0.45)) * FRONT_ALPHA * (globalFade or 1)
    lf.tex:SetAlpha(alpha)
    lf.tex:ClearAllPoints()
    lf.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", lf.x, lf.y)
    SetTexRot(lf.tex, lf.rot)
end

local function SpawnFrontLeaf(frontX, barCY, barH)
    for _, lf in ipairs(frontLeaves) do
        if not lf.active then
            local angle    = rad(rand(40, 140))
            local speed    = rand(FRONT_SPEED_MIN, FRONT_SPEED_MAX)
            local size     = rand(FRONT_SIZE_MIN, FRONT_SIZE_MAX)
            local rotSpeed = rand(LEAF_ROT_MIN, LEAF_ROT_MAX) * (math.random(2) == 1 and 1 or -1)
            lf.active   = true
            lf.life     = 0
            lf.maxLife  = rand(FRONT_LIFE_MIN, FRONT_LIFE_MAX)
            lf.x        = frontX + rand(-3, 3)
            lf.y        = barCY  + rand(-barH * 0.3, barH * 0.3)
            lf.vx       = math.cos(angle) * speed
            lf.vy       = math.sin(angle) * speed
            lf.rot      = rand(0, pi2)
            lf.rotSpeed = rotSpeed
            lf.size     = size
            lf.tex:SetSize(size, size)
            lf.tex:SetAlpha(FRONT_ALPHA)
            lf.tex:ClearAllPoints()
            lf.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", lf.x, lf.y)
            return
        end
    end
end

local function UpdateFrontLeaf(lf, dt, globalFade)
    if not lf.active then return end
    lf.life = lf.life + dt
    local t = lf.life / lf.maxLife
    if t >= 1 then lf.active = false ; lf.tex:SetAlpha(0) ; return end
    lf.vy  = lf.vy - FRONT_GRAVITY * dt
    lf.x   = lf.x  + lf.vx * dt
    lf.y   = lf.y  + lf.vy * dt
    lf.rot = lf.rot + lf.rotSpeed * dt
    local alpha = (t < 0.55 and 1 or math.max(0, (1 - t) / 0.45)) * FRONT_ALPHA * (globalFade or 1)
    lf.tex:SetAlpha(alpha)
    lf.tex:ClearAllPoints()
    lf.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", lf.x, lf.y)
    SetTexRot(lf.tex, lf.rot)
end

function FX.Init(container, bar)
    local school = SCB.Schools.data["mistweaver"]
    local f = SCB.Bar.frameInner

    if school and school.light and f then
        texLight = f:CreateTexture(nil, "OVERLAY", nil, 6)
        texLight:SetTexture(school.light)
        texLight:SetAllPoints(f)
        maskLight = f:CreateMaskTexture()
        maskLight:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        maskLight:SetPoint("TOPLEFT", f, "TOPLEFT")
        maskLight:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
        maskLight:SetWidth(1)
        texLight:AddMaskTexture(maskLight)
        texLight:SetAlpha(0)
    end

    glowParts = {}
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(SCB.TEX_PATH .. "frost\\Particle_Frost_01")
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(MW_R, MW_G, MW_B)
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vy=0, phase=0 }
    end

    local earthSchool = SCB.Schools.data["earth"]
    local emberTexs = {}
    if earthSchool then
        for _, t in ipairs(earthSchool.rocks or {})  do emberTexs[#emberTexs+1] = t end
        for _, t in ipairs(earthSchool.debris or {}) do emberTexs[#emberTexs+1] = t end
    end
    local function getEmberTex(i)
        if #emberTexs == 0 then return SCB.TEX_PATH .. "frost\\Particle_Frost_02" end
        return emberTexs[((i - 1) % #emberTexs) + 1]
    end

    emberParts = {}
    for i = 1, EMBER_COUNT do
        local typeIdx = ((i - 1) % 3) + 1
        local ptype = emberTypes[typeIdx]
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getEmberTex(i))
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(MW_R, MW_G, MW_B)
        tex:SetAlpha(0)
        emberParts[i] = {
            tex=tex, ptype=ptype, typeIdx=typeIdx,
            active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, drift=0,
        }
    end

    mists = {}
    for i, xFrac in ipairs(MIST_POSITIONS) do
        local tex = bar:CreateTexture(nil, "BACKGROUND", nil, -1)
        tex:SetTexture(SCB.TEX_PATH .. "frost\\Mist_Frost_01")
        tex:SetSize(MIST_W_BASE, MIST_H_BASE)
        tex:SetAlpha(0)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(MW_R, MW_G, MW_B)
        mists[i] = {
            tex=tex, xFrac=xFrac, phase="idle", timer=0, duration=0,
            alpha=0, scaleT=0, scaleDir=1, angle=0,
            rotDir=(i % 2 == 0) and 1 or -1,
            baseW=MIST_W_BASE, baseH=MIST_H_BASE,
            delay=(i - 1) * 0.8,
        }
    end

    local natureLeaves = (SCB.Schools.data["nature"] and SCB.Schools.data["nature"].leaves) or {}
    local nLeaf = #natureLeaves
    local function getLeafTex(i)
        if nLeaf == 0 then return SCB.TEX_PATH .. "frost\\Particle_Frost_01" end
        return natureLeaves[((i - 1) % nLeaf) + 1]
    end

    leaves = {}
    for i = 1, LEAF_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getLeafTex(i))
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(MW_R, MW_G, MW_B)
        tex:SetAlpha(0)
        leaves[i] = { tex=tex, active=false, x=0, y=0, baseY=0, vx=0, vy=0,
                      waveAmp=0, waveFreq=0, wavePhase=0, rot=0, rotSpeed=0,
                      life=0, maxAlpha=0, size=0, deadX=0 }
    end

    frontLeaves = {}
    for i = 1, FRONT_LEAF_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getLeafTex(i + LEAF_COUNT))
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(MW_R, MW_G, MW_B)
        tex:SetAlpha(0)
        frontLeaves[i] = { tex=tex, active=false, x=0, y=0, vx=0, vy=0, rot=0, rotSpeed=0,
                           life=0, maxLife=0, size=0 }
    end
end

function FX.Start(duration)
    castDuration = duration or 5
    isActive = true
    partsFading = false
    partsFadeT = 0
    glowAcc, emberAcc, leafAcc, frontLeafAcc = 0, 0, 0, 0

    if texLight then texLight:SetAlpha(1) end
    if maskLight then maskLight:SetWidth(1) end

    for i, m in ipairs(mists) do m.phase = "idle" ; m.delay = (i - 1) * 0.8 ; m.tex:SetAlpha(0) end
    for _, p in ipairs(glowParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, lf in ipairs(leaves) do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, lf in ipairs(frontLeaves) do lf.active = false ; lf.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive = false
    partsFading = true
    partsFadeT = 0
    glowAcc, emberAcc, leafAcc, frontLeafAcc = 0, 0, 0, 0
    for _, m in ipairs(mists) do
        if m.phase ~= "idle" then m.phase = "fadeout" ; m.timer = 0 ; m.duration = 0.35 end
    end
end

function FX.Reset()
    isActive = false
    partsFading = false
    partsFadeT = 0
    glowAcc, emberAcc, leafAcc, frontLeafAcc = 0, 0, 0, 0

    if texLight then texLight:SetAlpha(0) end
    if maskLight then maskLight:SetWidth(1) end

    for _, m in ipairs(mists) do m.phase = "idle" ; m.tex:SetAlpha(0) end
    for _, p in ipairs(glowParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, lf in ipairs(leaves) do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, lf in ipairs(frontLeaves) do lf.active = false ; lf.tex:SetAlpha(0) end
end

function FX.UpdateFade(dt)
    if not partsFading then return end
    partsFadeT = partsFadeT + dt
    local gf = math.max(0, 1 - (partsFadeT / PARTS_FADE_DUR))
    if gf <= 0 then
        partsFading = false
        for _, p in ipairs(glowParts) do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
        for _, lf in ipairs(leaves) do lf.active = false ; lf.tex:SetAlpha(0) end
        for _, lf in ipairs(frontLeaves) do lf.active = false ; lf.tex:SetAlpha(0) end
        if texLight then texLight:SetAlpha(0) end
        return
    end

    for _, p in ipairs(glowParts) do if p.active then UpdateGlow(p, dt, gf) end end
    for _, p in ipairs(emberParts) do if p.active then UpdateEmber(p, dt, gf) end end
    for _, lf in ipairs(leaves) do if lf.active then UpdateLeaf(lf, dt, gf) end end
    for _, lf in ipairs(frontLeaves) do if lf.active then UpdateFrontLeaf(lf, dt, gf) end end
    for _, m in ipairs(mists) do if m.phase ~= "idle" then UpdateMist(m, dt) ; m.tex:SetAlpha(m.tex:GetAlpha() * gf) end end
    if texLight then
        -- Le light doit disparaître après la frame: on le maintient visible
        -- pendant la majeure partie du fade puis on le coupe en toute fin.
        local lightFade
        if gf > 0.20 then
            lightFade = 1
        else
            lightFade = math.max(0, gf / 0.20)
        end
        texLight:SetAlpha(lightFade)
    end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    for _, p in ipairs(glowParts) do if p.active then UpdateGlow(p, dt, 1) end end
    for _, p in ipairs(emberParts) do if p.active then UpdateEmber(p, dt, 1) end end
    for _, lf in ipairs(leaves) do if lf.active then UpdateLeaf(lf, dt, 1) end end
    for _, lf in ipairs(frontLeaves) do if lf.active then UpdateFrontLeaf(lf, dt, 1) end end
    for _, m in ipairs(mists) do UpdateMist(m, dt) end

    if maskLight then
        local bar = SCB.Bar.frameInner
        maskLight:SetWidth(math.max(bar:GetWidth() * progress, 1))
    end

    if not isActive then return end

    local barLX = fillLX or (frontX - barW * progress)
    local barRX = barLX + (fillW or barW)

    glowAcc = glowAcc + dt
    if progress < GLOW_STOP_AT and glowAcc >= GLOW_SPAWN_RATE then
        glowAcc = glowAcc - GLOW_SPAWN_RATE
        SpawnGlow(frontX, cy, barH)
    end

    emberAcc = emberAcc + dt
    if emberAcc >= EMBER_SPAWN then
        emberAcc = emberAcc - EMBER_SPAWN
        SpawnEmber(frontX, cy)
    end

    leafAcc = leafAcc + dt
    if leafAcc >= LEAF_SPAWN_RATE then
        leafAcc = leafAcc - LEAF_SPAWN_RATE
        SpawnLeaf(barLX, barRX, cy, barH)
    end

    frontLeafAcc = frontLeafAcc + dt
    if progress < 0.95 and frontLeafAcc >= FRONT_SPAWN_RATE then
        frontLeafAcc = frontLeafAcc - FRONT_SPAWN_RATE
        SpawnFrontLeaf(frontX, cy, barH)
    end
end
