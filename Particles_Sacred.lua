-- ============================================================
--  Opulent Casting Bars — Particles_Sacred.lua
--
--  · Frame_Sacred_Light : suit la progression (masque horizontal)
--  · Glow tip           : logique Metal, couleur dorée sacrée
--  · Embers tip         : logique Metal, couleur dorée sacrée
--  · Misc ambient       : Misc_Holy en masse autour de la barre,
--    transparences variées (#fcedca)
--  · Misc front         : Misc_Holy au front de la progression
-- ============================================================

local FX = {}
SCB.FX            = SCB.FX or {}
SCB.FX["sacred"]  = FX

local function rand(a, b)  return a + math.random() * (b - a) end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end
local pi2 = math.pi * 2

-- Couleur Sacred
local SAC_R, SAC_G, SAC_B = 0xFC/255, 0xED/255, 0xCA/255   -- #fcedca

-- ============================================================
--  CONSTANTES GLOW (bout de barre — Metal)
-- ============================================================
local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.02
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.55
local GLOW_SIZE_MIN   = 4
local GLOW_SIZE_MAX   = 9
local GLOW_LIFE_MIN   = 0.10
local GLOW_LIFE_MAX   = 0.20

-- ============================================================
--  CONSTANTES EMBERS (bout de barre — Metal)
-- ============================================================
local EMBER_COUNT = 60
local EMBER_SPAWN = 0.03

local emberTypes = {
    { sizeMin=8,  sizeMax=14, speedMin=25, speedMax=60,  lifeMin=0.8, lifeMax=1.6, gravity=8,  spread=140, driftX=0.4 },
    { sizeMin=4,  sizeMax=8,  speedMin=80, speedMax=160, lifeMin=0.3, lifeMax=0.7, gravity=15, spread=80,  driftX=0.0 },
    { sizeMin=6,  sizeMax=12, speedMin=40, speedMax=90,  lifeMin=0.6, lifeMax=1.2, gravity=20, spread=100, driftX=0.2 },
}

-- ============================================================
--  CONSTANTES MISC FRONT (Holy, front de progression)
-- ============================================================
local MISC_FRONT_COUNT      = 80
local MISC_FRONT_SPAWN_RATE = 0.08
local MISC_FRONT_SIZE_MIN   = 4
local MISC_FRONT_SIZE_MAX   = 22
local MISC_FRONT_LIFE_MIN   = 0.4
local MISC_FRONT_LIFE_MAX   = 0.9
local MISC_FRONT_ALPHA      = 0.90
local MISC_FRONT_STOP_AT    = 0.90

-- ============================================================
--  CONSTANTES MISC AMBIENT (Holy, autour de la barre — en masse)
-- ============================================================
local MISC_AMB_COUNT      = 180
local MISC_AMB_SPAWN_RATE = 0.07
local MISC_AMB_SIZE_MIN   = 3
local MISC_AMB_SIZE_MAX   = 26
local MISC_AMB_LIFE_MIN   = 0.5
local MISC_AMB_LIFE_MAX   = 1.6
local MISC_AMB_ALPHA_MIN  = 0.08
local MISC_AMB_ALPHA_MAX  = 0.72
local MISC_AMB_SPREAD_X   = 12
local MISC_AMB_SPREAD_Y   = 10

local PARTS_FADE_DUR = 0.55

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================
local isActive    = false
local partsFading = false
local partsFadeT  = 0
local castDuration = 5

local glowParts    = {}
local glowAcc      = 0

local emberParts   = {}
local emberAcc     = 0

local miscFrontParts = {}
local miscFrontAcc   = 0

local miscAmbParts   = {}
local miscAmbAcc     = 0

-- ============================================================
--  GLOW (Metal)
-- ============================================================
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
            p.phase   = math.random() * pi2
            local size = rand(GLOW_SIZE_MIN, GLOW_SIZE_MAX)
            p.tex:SetSize(size, size)
            p.tex:SetVertexColor(SAC_R, SAC_G, SAC_B)
            p.tex:SetAlpha(0)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateGlow(p, dt, gf)
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
    p.tex:SetAlpha(math.max(0, env) * GLOW_ALPHA * (gf or 1))
end

-- ============================================================
--  EMBERS (Metal)
-- ============================================================
local function SpawnEmber(wx, wy)
    local roll    = math.random(10)
    local typeIdx = roll <= 4 and 1 or (roll <= 7 and 3 or 2)
    local ptype   = emberTypes[typeIdx]

    for _, p in ipairs(emberParts) do
        if not p.active and p.typeIdx == typeIdx then
            local tCast = math.max(0, math.min((castDuration - 2) / 3, 1))
            local speed = rand(lerp(ptype.speedMax * 0.5, ptype.speedMin, tCast),
                               lerp(ptype.speedMax, ptype.speedMax * 0.8, tCast))
            local angle = math.rad(90 + rand(-ptype.spread * 0.5, ptype.spread * 0.5))
            local size  = rand(ptype.sizeMin, ptype.sizeMax)

            p.active  = true ; p.life = 0
            p.maxLife = rand(ptype.lifeMin, ptype.lifeMax)
            p.x       = wx + rand(-5, 5)
            p.y       = wy + rand(-8, 8)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            p.drift   = rand(-ptype.driftX, ptype.driftX) * 30
            p.tex:SetVertexColor(SAC_R, SAC_G, SAC_B)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(1)
            return
        end
    end
end

local function UpdateEmber(p, dt, gf)
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
    p.tex:SetAlpha(alpha * 0.85 * (gf or 1))
end

-- ============================================================
--  MISC FRONT (Holy)
-- ============================================================
local function SpawnMiscFront(frontX, cy, barH)
    for _, p in ipairs(miscFrontParts) do
        if not p.active then
            local spread = math.min(barH * 0.15, 6)
            p.active  = true ; p.life = 0
            p.maxLife = rand(MISC_FRONT_LIFE_MIN, MISC_FRONT_LIFE_MAX)
            p.x       = frontX + rand(-4, 6)
            p.y       = cy + rand(-spread, spread)
            p.vx      = rand(-10, 10)
            p.vy      = rand(-18, 4)
            p.phase   = math.random() * pi2
            local sz  = rand(MISC_FRONT_SIZE_MIN, MISC_FRONT_SIZE_MAX)
            p.tex:SetSize(sz, sz)
            p.tex:SetVertexColor(SAC_R, SAC_G, SAC_B)
            p.tex:SetAlpha(0)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateMiscFront(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - 8 * dt
    p.x  = p.x + p.vx * dt + math.sin(p.life * 4 + p.phase) * 0.4
    p.y  = p.y + p.vy * dt
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t < 0.2 and t/0.2 or (t < 0.7 and 1 or (1-t)/0.3)
    p.tex:SetAlpha(math.max(0, env) * MISC_FRONT_ALPHA * (gf or 1))
end

-- ============================================================
--  MISC AMBIENT (Holy, en masse)
-- ============================================================
local function SpawnMiscAmb(cx, cy, barW, barH)
    for i, p in ipairs(miscAmbParts) do
        if not p.active then
            p.active  = true ; p.life = 0
            p.maxLife = rand(MISC_AMB_LIFE_MIN, MISC_AMB_LIFE_MAX)
            local function gauss(r) return (rand(-r,r) + rand(-r,r) + rand(-r,r)) / 3 end
            p.x     = cx + gauss(barW * 0.5 + MISC_AMB_SPREAD_X)
            p.y     = cy + gauss(barH * 0.5 + MISC_AMB_SPREAD_Y)
            p.vx    = rand(-6, 6)
            p.vy    = rand(-4, 8)
            p.phase = math.random() * pi2
            local sz = rand(MISC_AMB_SIZE_MIN, MISC_AMB_SIZE_MAX)
            p.tex:SetSize(sz, sz)
            p.maxAlpha = rand(MISC_AMB_ALPHA_MIN, MISC_AMB_ALPHA_MAX)
            p.tex:SetVertexColor(SAC_R, SAC_G, SAC_B)
            p.tex:SetAlpha(0)
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
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t < 0.25 and t/0.25 or (t < 0.65 and 1 or (1-t)/0.35)
    p.tex:SetAlpha(math.max(0, env) * (p.maxAlpha or MISC_AMB_ALPHA_MAX) * (gf or 1))
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["sacred"]
    local f      = SCB.Bar.frameInner

    -- Glow tip (Sacred, recoloré #fcedca)
    local glowTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    glowParts = {}
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(glowTex)
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vy=0, phase=0 }
    end

    -- Embers tip (réutilise textures earth ou fallback frost)
    local earthSchool = SCB.Schools.data["earth"]
    local miscTexs    = {}
    if earthSchool then
        for _, t in ipairs(earthSchool.rocks  or {}) do miscTexs[#miscTexs+1] = t end
        for _, t in ipairs(earthSchool.debris or {}) do miscTexs[#miscTexs+1] = t end
    end
    local function getEmberTex(i)
        if #miscTexs == 0 then return glowTex end
        return miscTexs[((i-1) % #miscTexs) + 1]
    end

    emberParts = {}
    for i = 1, EMBER_COUNT do
        local typeIdx = ((i - 1) % 3) + 1
        local ptype   = emberTypes[typeIdx]
        local tex     = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getEmberTex(i))
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        emberParts[i] = {
            tex=tex, ptype=ptype, typeIdx=typeIdx,
            active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, drift=0,
        }
    end

    -- Misc textures (réutilise Misc_Holy)
    local holySchool = SCB.Schools.data["holy"]
    local sacSchool  = school
    local holyMisc   = (sacSchool and sacSchool.misc)
                    or (holySchool and holySchool.misc)
                    or {}
    local nMisc      = #holyMisc
    local function getMiscTex(i)
        if nMisc == 0 then return glowTex end
        return holyMisc[((i-1) % nMisc) + 1]
    end

    -- Misc front
    miscFrontParts = {}
    for i = 1, MISC_FRONT_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getMiscTex(i))
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        miscFrontParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0, phase=0 }
    end

    -- Misc ambient (en masse, créés sur le bar pour rester en arrière)
    miscAmbParts = {}
    for i = 1, MISC_AMB_COUNT do
        local tex = bar:CreateTexture(nil, "BACKGROUND", nil, -1)
        tex:SetTexture(getMiscTex(i + MISC_FRONT_COUNT))
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        miscAmbParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0, phase=0, maxAlpha=0 }
    end
end

function FX.Start(duration)
    castDuration  = duration or 5
    isActive      = true
    partsFading   = false
    partsFadeT    = 0
    glowAcc       = 0
    emberAcc      = 0
    miscFrontAcc  = 0
    miscAmbAcc    = 0

    for _, p in ipairs(glowParts)      do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts)     do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(miscFrontParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(miscAmbParts)   do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive    = false
    partsFading = true
    partsFadeT  = 0
    glowAcc     = 0
    emberAcc    = 0
    miscFrontAcc = 0
    miscAmbAcc   = 0
end

function FX.Reset()
    isActive    = false
    partsFading = false
    partsFadeT  = 0
    glowAcc     = 0
    emberAcc    = 0
    miscFrontAcc = 0
    miscAmbAcc   = 0

    for _, p in ipairs(glowParts)      do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts)     do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(miscFrontParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(miscAmbParts)   do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.UpdateFade(dt)
    if not partsFading then return end
    partsFadeT = partsFadeT + dt
    local gf   = math.max(0, 1 - (partsFadeT / PARTS_FADE_DUR))

    for _, p in ipairs(glowParts)      do UpdateGlow(p,       dt, gf) end
    for _, p in ipairs(emberParts)     do UpdateEmber(p,      dt, gf) end
    for _, p in ipairs(miscFrontParts) do UpdateMiscFront(p,  dt, gf) end
    for _, p in ipairs(miscAmbParts)   do UpdateMiscAmb(p,    dt, gf) end

    if gf <= 0 then
        partsFading = false
        for _, p in ipairs(glowParts)      do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(emberParts)     do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(miscFrontParts) do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(miscAmbParts)   do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)

    -- Mise à jour de toutes les particules actives
    for _, p in ipairs(glowParts)      do UpdateGlow(p,       dt, 1) end
    for _, p in ipairs(emberParts)     do UpdateEmber(p,      dt, 1) end
    for _, p in ipairs(miscFrontParts) do UpdateMiscFront(p,  dt, 1) end
    for _, p in ipairs(miscAmbParts)   do UpdateMiscAmb(p,    dt, 1) end

    if not isActive then return end

    local cx = (fillLX or (frontX - barW * progress)) + (fillW or barW) * 0.5

    -- Glow tip
    glowAcc = glowAcc + dt
    if progress < GLOW_STOP_AT and glowAcc >= GLOW_SPAWN_RATE then
        glowAcc = 0
        local count = math.random(2, 4)
        for i = 1, count do
            SpawnGlow(frontX, cy, barH)
        end
    end

    -- Embers tip
    emberAcc = emberAcc + dt
    if emberAcc >= EMBER_SPAWN then
        emberAcc = 0
        local count = math.random(2, 4)
        for i = 1, count do
            SpawnEmber(frontX, cy)
        end
    end

    -- Misc front
    miscFrontAcc = miscFrontAcc + dt
    if progress < MISC_FRONT_STOP_AT and miscFrontAcc >= MISC_FRONT_SPAWN_RATE then
        miscFrontAcc = 0
        for _ = 1, 2 do SpawnMiscFront(frontX, cy, barH) end
    end

    -- Misc ambient (autour de toute la barre)
    miscAmbAcc = miscAmbAcc + dt
    if miscAmbAcc >= MISC_AMB_SPAWN_RATE then
        miscAmbAcc = 0
        for _ = 1, 3 do SpawnMiscAmb(cx, cy, barW, barH) end
    end
end
