-- ============================================================
--  Opulent Casting Bars — Particles_Engrenages.lua
--  Style Engrenages
--  - Particules proches de Metal (glow + cendres)
--  - Cercle icon masqué + engrenage rotatif constant
--  - Circle premier plan
--  - 5 Fork dont 4 animés selon la progression
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["engrenages"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg) return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end

local ICON_CENTER_X = -140
local ICON_CENTER_Y = 7
local MISC_OFFSET_X = 0
local MISC_OFFSET_Y = 0
local ICON_SIZE     = 52  -- round icon; the ring's hole is ~76 across

local MISC_SIZE        = 111
local MISC_ROT_SPEED   = 18 -- deg/s, rotation lente

local FORK_COUNT       = 5
local FORK_STEP_X      = 10
local FORK_MAX_SHIFT   = { 0, 35, 65, 95, 125 }
local FORK_TRACK_RANGE = 125

local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.02
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.55
local GLOW_SIZE_MIN   = 4
local GLOW_SIZE_MAX   = 9
local GLOW_LIFE_MIN   = 0.10
local GLOW_LIFE_MAX   = 0.20
local GLOW_R, GLOW_G, GLOW_B = 0.92, 0.78, 0.52

local EMBER_COUNT = 60
local EMBER_SPAWN = 0.03
local EMBER_R, EMBER_G, EMBER_B = 0.92, 0.78, 0.52

local emberTypes = {
    { sizeMin=8,  sizeMax=14, speedMin=25, speedMax=60,  lifeMin=0.8, lifeMax=1.6, gravity=8,  spread=140, driftX=0.4 },
    { sizeMin=4,  sizeMax=8,  speedMin=80, speedMax=160, lifeMin=0.3, lifeMax=0.7, gravity=15, spread=80,  driftX=0.0 },
    { sizeMin=6,  sizeMax=12, speedMin=40, speedMax=90,  lifeMin=0.6, lifeMax=1.2, gravity=20, spread=100, driftX=0.2 },
}

local PARTS_FADE_DUR  = 0.6
local FORK_REWIND_DUR = 0.22
local RECAST_WINDOW   = 0.45

local PSHIT_DUR       = 0.22
local BAR_FADE_TOTAL  = 0.90  -- hold(0.25) + fade(0.65), cf Animations.lua
local PSHIT_FADE_DUR  = (BAR_FADE_TOTAL + 0.5) * 2
local PSHIT_SIZE_START = 192
local PSHIT_SIZE_END   = 372
local PSHIT_ALPHA_PEAK = 0.85
local PSHIT_R, PSHIT_G, PSHIT_B = 0.95, 0.62, 0.32

local isActive      = false
local partsFading   = false
local partsFadeT    = 0
local castDuration  = 5
local glowParts     = {}
local glowSpawnAcc  = 0
local emberParts    = {}
local emberSpawnAcc = 0
local miscAngle        = 0
local lastProgress     = 0
local rewindActive     = false
local rewindStartProg  = 0
local rewindT          = 0
local pshitActive      = false
local pshitT           = 0
local pshitX           = 0
local pshitY           = 0
local pshitBurstDone   = false
local pshitFrontX      = 0
local pshitFrontY      = 0
local pshitDriftX      = 0
local pshitDriftY      = 0
local pshitFrontDriftX = 0
local pshitFrontDriftY = 0
local lastStopTime     = 0

local iconTex, iconMask, miscTex, circleTex, pshitTex, pshitFrontTex
local forks = {}

local function PositionElements(progress)
    local f = SCB.Bar.frameInner
    if not f then return end
    local sx, sy = SCB.Bar:GetArtScale()
    if iconTex then
        iconTex:ClearAllPoints()
        iconTex:SetPoint("CENTER", f, "CENTER", ICON_CENTER_X * sx, ICON_CENTER_Y * sy)
        iconTex:SetSize(ICON_SIZE * sx, ICON_SIZE * sy)
    end
    if miscTex then
        miscTex:ClearAllPoints()
        miscTex:SetPoint("CENTER", f, "CENTER",
            (ICON_CENTER_X + MISC_OFFSET_X) * sx, (ICON_CENTER_Y + MISC_OFFSET_Y) * sy)
        miscTex:SetSize(MISC_SIZE * sx, MISC_SIZE * sy)
    end

    local track = math.max(0, math.min(progress or 0, 1)) * FORK_TRACK_RANGE
    for i = 1, FORK_COUNT do
        local t = forks[i]
        if t then
            local shift = 0
            if i > 1 then
                shift = math.min(track, FORK_MAX_SHIFT[i] or 0)
            end
            local baseShift = (i - 1) * FORK_STEP_X
            local totalShift = (baseShift + shift) * sx
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", f, "TOPLEFT", totalShift, 0)
            t:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", totalShift, 0)
        end
    end
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
    local school = SCB.Schools.data["engrenages"] or {}

    -- Stacking order (back to front): icon, gear, circle, steam, forks — all
    -- above the bar art. Texture sub-levels are not honoured by this client,
    -- so each step gets its own child frame; frame levels always are. They
    -- stay below the light (+8), the texts (+9) and the particles (+10).
    local baseLevel = bar:GetFrameLevel() or 0
    local function Layer(offset)
        local fr = CreateFrame("Frame", nil, bar)
        fr:SetAllPoints(bar)
        fr:SetFrameLevel(baseLevel + offset)
        return fr
    end

    iconTex = Layer(1):CreateTexture(nil, "ARTWORK")
    iconTex:SetSize(ICON_SIZE, ICON_SIZE)
    iconTex:SetAlpha(0)

    -- A real circular mask only where the client supports one; elsewhere the
    -- icon is drawn round by SCB.SetRoundIcon (see FX.Start).
    if type(SetPortraitToTexture) ~= "function" then
        iconMask = bar:CreateMaskTexture()
        iconMask:SetTexture(school.iconMask or "Interface\\Buttons\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        iconMask:SetAllPoints(bar)
        iconTex:AddMaskTexture(iconMask)
    end

    miscTex = Layer(2):CreateTexture(nil, "ARTWORK")
    miscTex:SetSize(MISC_SIZE, MISC_SIZE)
    miscTex:SetTexture(school.misc)
    miscTex:SetAlpha(0)

    circleTex = Layer(3):CreateTexture(nil, "ARTWORK")
    circleTex:SetAllPoints(bar)
    circleTex:SetTexture(school.circle)
    circleTex:SetAlpha(0)

    local steamLayer = Layer(4)
    pshitTex = steamLayer:CreateTexture(nil, "ARTWORK")
    pshitTex:SetTexture(SCB.TEX_PATH .. "frost\\Mist_Frost_01")
    pshitTex:SetBlendMode("ADD")
    pshitTex:SetVertexColor(PSHIT_R, PSHIT_G, PSHIT_B)
    pshitTex:SetAlpha(0)

    pshitFrontTex = steamLayer:CreateTexture(nil, "ARTWORK")
    pshitFrontTex:SetTexture(SCB.TEX_PATH .. "frost\\Mist_Frost_01")
    pshitFrontTex:SetBlendMode("ADD")
    pshitFrontTex:SetVertexColor(PSHIT_R, PSHIT_G, PSHIT_B)
    pshitFrontTex:SetAlpha(0)

    forks = {}
    local forkLayer = Layer(5)
    for i = 1, FORK_COUNT do
        local t = forkLayer:CreateTexture(nil, "ARTWORK")
        t:SetTexture(school.fork)
        t:SetAlpha(0)
        forks[i] = t
    end

    PositionElements(0)

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
    miscAngle     = 0

    local now = GetTime()
    if lastProgress > 0.02 and (now - (lastStopTime or 0)) <= RECAST_WINDOW then
        rewindActive = true
        rewindStartProg = lastProgress
        rewindT = 0
    else
        rewindActive = false
        rewindStartProg = 0
        rewindT = 0
    end

    pshitActive = false
    pshitT = 0
    pshitBurstDone = false
    if pshitTex then pshitTex:SetAlpha(0) end
    if pshitFrontTex then pshitFrontTex:SetAlpha(0) end

    if iconTex then
        SCB.SetRoundIcon(iconTex, SCB.Bar.currentSpellIcon)
        iconTex:SetAlpha(1)
    end
    if miscTex then
        miscTex:SetRotation(0)
        miscTex:SetAlpha(1)
    end
    if circleTex then circleTex:SetAlpha(1) end
    for _, t in ipairs(forks) do if t then t:SetAlpha(1) end end

    PositionElements(0)

    for _, p in ipairs(glowParts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive      = false
    partsFading   = true
    partsFadeT    = 0
    glowSpawnAcc  = 0
    emberSpawnAcc = 0
    lastStopTime = GetTime()
    pshitActive = true
    pshitT = 0
    pshitBurstDone = false

    local f = SCB.Bar and SCB.Bar.frameInner
    if f then
        local cx, cy = f:GetCenter()
        if cx and cy then
            pshitX = cx - 40 * SCB.Bar:GetArtScale() + rand(-8, 8)
            pshitY = cy + rand(-4, 4)
        end
    end
    pshitDriftX = rand(-4, 4)
    pshitDriftY = rand(3, 7)
    pshitFrontDriftX = rand(-3, 3)
    pshitFrontDriftY = rand(2, 5)

    if pshitTex then
        pshitTex:SetSize(PSHIT_SIZE_START, PSHIT_SIZE_START * 0.58)
        pshitTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pshitX, pshitY)
        pshitTex:SetAlpha(0)
    end
    if pshitFrontTex then
        pshitFrontTex:SetSize(PSHIT_SIZE_START, PSHIT_SIZE_START * 0.58)
        pshitFrontTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pshitFrontX, pshitFrontY)
        pshitFrontTex:SetAlpha(0)
    end
end

function FX.UpdateFade(dt)
    if not partsFading then return end
    partsFadeT = partsFadeT + dt
    local gFade = math.max(0, 1 - partsFadeT / PARTS_FADE_DUR)
    local pshitFade = math.max(0, 1 - partsFadeT / PSHIT_FADE_DUR)

    if iconTex then iconTex:SetAlpha(gFade) end
    if miscTex then miscTex:SetAlpha(gFade) end
    if circleTex then circleTex:SetAlpha(gFade) end
    for _, t in ipairs(forks) do if t then t:SetAlpha(gFade) end end

    if pshitActive and pshitTex then
        if not pshitBurstDone then
            pshitT = pshitT + dt
            local tp = math.min(pshitT / PSHIT_DUR, 1)
            local size = PSHIT_SIZE_START + (PSHIT_SIZE_END - PSHIT_SIZE_START) * tp
            local driftT = partsFadeT
            pshitTex:SetSize(size, size * 0.58)
            pshitTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pshitX + tp * 10 + driftT * pshitDriftX, pshitY + tp * 2 + driftT * pshitDriftY)
            local env = tp < 0.18 and tp / 0.18 or math.max(0.45, (1 - tp) / 0.82)
            pshitTex:SetAlpha(env * PSHIT_ALPHA_PEAK * pshitFade)
            if pshitFrontTex then
                pshitFrontTex:SetSize(size, size * 0.58)
                pshitFrontTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pshitFrontX + tp * 12 + driftT * pshitFrontDriftX, pshitFrontY + tp * 3 + driftT * pshitFrontDriftY)
                pshitFrontTex:SetAlpha(env * (PSHIT_ALPHA_PEAK * 0.9) * pshitFade)
            end
            if tp >= 1 then
                pshitBurstDone = true
            end
        else
            local driftT = partsFadeT
            pshitTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pshitX + 10 + driftT * pshitDriftX, pshitY + 2 + driftT * pshitDriftY)
            pshitTex:SetAlpha(PSHIT_ALPHA_PEAK * 0.45 * pshitFade)
            if pshitFrontTex then
                pshitFrontTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pshitFrontX + 12 + driftT * pshitFrontDriftX, pshitFrontY + 3 + driftT * pshitFrontDriftY)
                pshitFrontTex:SetAlpha((PSHIT_ALPHA_PEAK * 0.9) * 0.45 * pshitFade)
            end
        end
    end

    for _, p in ipairs(glowParts)  do UpdateGlow(p, dt, gFade) end
    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, gFade) end

    if partsFadeT >= math.max(PARTS_FADE_DUR, PSHIT_FADE_DUR) then
        partsFading = false
        if iconTex then iconTex:SetAlpha(0) end
        if miscTex then miscTex:SetAlpha(0) end
        if circleTex then circleTex:SetAlpha(0) end
        for _, t in ipairs(forks) do if t then t:SetAlpha(0) end end
        pshitActive = false
        if pshitTex then pshitTex:SetAlpha(0) end
        if pshitFrontTex then pshitFrontTex:SetAlpha(0) end
        for _, p in ipairs(glowParts)  do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    partsFading = false
    pshitActive = false
    pshitT = 0
    pshitBurstDone = false
    pshitDriftX, pshitDriftY = 0, 0
    pshitFrontDriftX, pshitFrontDriftY = 0, 0
    if pshitTex then pshitTex:SetAlpha(0) end
    if pshitFrontTex then pshitFrontTex:SetAlpha(0) end
    rewindActive = false
    rewindStartProg = 0
    rewindT = 0
    if iconTex then iconTex:SetAlpha(0) end
    if miscTex then
        miscTex:SetAlpha(0)
        miscTex:SetRotation(0)
    end
    if circleTex then circleTex:SetAlpha(0) end
    for _, t in ipairs(forks) do if t then t:SetAlpha(0) end end
    for _, p in ipairs(glowParts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH)
    if not isActive then return end

    miscAngle = miscAngle + dt * MISC_ROT_SPEED
    if miscTex then miscTex:SetRotation(math.rad(miscAngle)) end

    local visualProgress = progress
    if rewindActive then
        rewindT = rewindT + dt
        local tr = math.min(rewindT / FORK_REWIND_DUR, 1)
        local rewindProgress = rewindStartProg * (1 - tr)
        visualProgress = math.max(progress, rewindProgress)
        if tr >= 1 then
            rewindActive = false
            rewindStartProg = 0
            rewindT = 0
        end
    end
    PositionElements(visualProgress)
    lastProgress = progress
    pshitFrontX = frontX
    pshitFrontY = cy

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
