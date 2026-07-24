-- ============================================================
--  Opulent Casting Bars — Particles_HoneyIcon.lua
--  Variante Honey avec icône de sort à gauche
--  - Base identique à Metal Icon (glow + projectiles en bout de barre)
--  - Ambient autour de la barre calé sur Holy
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["honey_icon"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end

local ICON_CENTER_X = -147 -- +1 px (droite)
local ICON_CENTER_Y = 10   -- +1 px (haut)
local ICON_SIZE     = 57   -- +5%

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

local emberTypes = {
    { sizeMin=8,  sizeMax=14, speedMin=25, speedMax=60,  lifeMin=0.8, lifeMax=1.6, gravity=8,  spread=140, driftX=0.4 },
    { sizeMin=4,  sizeMax=8,  speedMin=80, speedMax=160, lifeMin=0.3, lifeMax=0.7, gravity=15, spread=80,  driftX=0.0 },
    { sizeMin=6,  sizeMax=12, speedMin=40, speedMax=90,  lifeMin=0.6, lifeMax=1.2, gravity=20, spread=100, driftX=0.2 },
}

local EMBER_R, EMBER_G, EMBER_B = 0.92, 0.78, 0.52

-- Holy-like ambient autour de la barre
local MISC_AMB_COUNT      = 120
local MISC_AMB_SPAWN_RATE = 0.12
local MISC_AMB_SIZE_MIN   = 3
local MISC_AMB_SIZE_MAX   = 20
local MISC_AMB_LIFE_MIN   = 0.6
local MISC_AMB_LIFE_MAX   = 1.4
local MISC_AMB_ALPHA      = 0.65
local MISC_AMB_SPREAD_X   = 5
local MISC_AMB_SPREAD_Y   = 5

local PARTS_FADE_DUR = 0.6

local isActive      = false
local partsFading   = false
local partsFadeT    = 0
local castDuration  = 5
local glowParts     = {}
local glowSpawnAcc  = 0
local emberParts    = {}
local emberSpawnAcc = 0
local miscAmbParts  = {}
local miscAmbAcc    = 0

local iconTex

local function PositionIcon()
    if not iconTex or not SCB.Bar.frameInner then return end
    iconTex:ClearAllPoints()
    iconTex:SetPoint("CENTER", SCB.Bar.frameInner, "CENTER", ICON_CENTER_X, ICON_CENTER_Y)
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

local function SpawnMiscAmb(cx, cy, barW, barH)
    for _, p in ipairs(miscAmbParts) do
        if not p.active then
            p.active  = true ; p.life = 0
            p.maxLife = rand(MISC_AMB_LIFE_MIN, MISC_AMB_LIFE_MAX)
            local function gauss(r) return (rand(-r,r) + rand(-r,r) + rand(-r,r)) / 3 end
            p.x  = cx + gauss(barW * 0.5 + MISC_AMB_SPREAD_X)
            p.y  = cy + gauss(barH * 0.5 + MISC_AMB_SPREAD_Y)
            p.vx = rand(-6, 6)
            p.vy = rand(-4, 8)
            p.phase = math.random() * math.pi * 2
            local sz = rand(MISC_AMB_SIZE_MIN, MISC_AMB_SIZE_MAX)
            p.tex:SetSize(sz, sz)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateMiscAmb(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.x = p.x + p.vx * dt + math.sin(p.life * 2 + p.phase) * 0.3
    p.y = p.y + p.vy * dt
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t < 0.25 and t/0.25 or (t < 0.65 and 1 or (1-t)/0.35)
    p.tex:SetAlpha(math.max(0, env) * MISC_AMB_ALPHA * (gf or 1))
end

function FX.Init(container, bar)
    iconTex = bar:CreateTexture(nil, "ARTWORK", nil, -1)
    iconTex:SetSize(ICON_SIZE, ICON_SIZE)
    iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    iconTex:SetAlpha(0)
    PositionIcon()

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

    local holy = SCB.Schools.data["holy"]
    local holyMisc = (holy and holy.misc) or {}
    local nMisc = #holyMisc

    miscAmbParts = {}
    for i = 1, MISC_AMB_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nMisc > 0 then tex:SetTexture(holyMisc[((i - 1) % nMisc) + 1]) end
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        miscAmbParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0, phase=0 }
    end
end

function FX.Start(duration)
    castDuration  = duration or 5
    isActive      = true
    partsFading   = false
    partsFadeT    = 0
    glowSpawnAcc  = 0
    emberSpawnAcc = 0
    miscAmbAcc    = 0

    if iconTex then
        iconTex:SetTexture(SCB.Bar.currentSpellIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
        iconTex:SetAlpha(1)
        PositionIcon()
    end

    for _, p in ipairs(glowParts)    do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(miscAmbParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive      = false
    partsFading   = true
    partsFadeT    = 0
    glowSpawnAcc  = 0
    emberSpawnAcc = 0
    miscAmbAcc    = 0
end

function FX.UpdateFade(dt)
    if not partsFading then return end
    partsFadeT = partsFadeT + dt
    local gFade = math.max(0, 1 - partsFadeT / PARTS_FADE_DUR)

    if iconTex then iconTex:SetAlpha(gFade) end

    for _, p in ipairs(glowParts)    do UpdateGlow(p, dt, gFade) end
    for _, p in ipairs(emberParts)   do UpdateEmber(p, dt, gFade) end
    for _, p in ipairs(miscAmbParts) do UpdateMiscAmb(p, dt, gFade) end

    if partsFadeT >= PARTS_FADE_DUR then
        partsFading = false
        if iconTex then iconTex:SetAlpha(0) end
        for _, p in ipairs(glowParts)    do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(emberParts)   do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(miscAmbParts) do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    partsFading = false
    if iconTex then iconTex:SetAlpha(0) end
    for _, p in ipairs(glowParts)    do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(miscAmbParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH)
    if not isActive then return end

    PositionIcon()

    local f = SCB.Bar.frameInner
    local barCX, barCY = f:GetCenter()
    if not barCY then return end

    for _, p in ipairs(glowParts)    do UpdateGlow(p, dt, 1) end
    for _, p in ipairs(emberParts)   do UpdateEmber(p, dt, 1) end
    for _, p in ipairs(miscAmbParts) do UpdateMiscAmb(p, dt, 1) end

    if progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc + dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc = 0
            local count = math.random(2, 4)
            for _ = 1, count do SpawnGlow(frontX, barCY, barH) end
        end
    end

    emberSpawnAcc = emberSpawnAcc + dt
    if emberSpawnAcc >= EMBER_SPAWN then
        emberSpawnAcc = 0
        local count = math.random(2, 4)
        for _ = 1, count do SpawnEmber(frontX, barCY) end
    end

    miscAmbAcc = miscAmbAcc + dt
    if miscAmbAcc >= MISC_AMB_SPAWN_RATE then
        miscAmbAcc = 0
        for _ = 1, 3 do SpawnMiscAmb(barCX, barCY, barW, barH) end
    end
end
