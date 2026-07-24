-- ============================================================
--  Sleek Casting Bars — Particles_Horde.lua
--  Effets visuels pour l'école Horde :
--    · Particules ambiantes rouge/orange sur la zone révélée
--    · Particules front rouge/orange au bout de la barre
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["horde"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end

local TEX_FIRE = SCB.TEX_PATH .. "fire\\"

-- ============================================================
--  CONSTANTES
-- ============================================================

local AMB_COUNT  = 35
local AMB_SPAWN  = 0.10

local FRONT_COUNT = 50
local FRONT_SPAWN = 0.032

local frontTypes = {
    { sizeMin=6,  sizeMax=13, speedMin=28, speedMax=65,  lifeMin=0.7, lifeMax=1.5, gravity=8,  spread=130 },
    { sizeMin=4,  sizeMax=8,  speedMin=80, speedMax=150, lifeMin=0.3, lifeMax=0.6, gravity=16, spread=75  },
    { sizeMin=7,  sizeMax=12, speedMin=40, speedMax=85,  lifeMin=0.5, lifeMax=1.1, gravity=20, spread=100 },
}

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local ambParts      = {}
local frontParts    = {}
local ambSpawnAcc   = 0
local frontSpawnAcc = 0
local isActive      = false

-- ============================================================
--  PARTICULES AMBIANTES
-- ============================================================

local function SpawnAmbient(progress)
    local f = SCB.Bar.frame
    local cx, cy = f:GetCenter()
    if not cx then return end
    local barW, barH = f:GetWidth(), f:GetHeight()

    for _, p in ipairs(ambParts) do
        if not p.active then
            local xOffset = rand(-barW * 0.5, barW * 0.5 * progress - barW * 0.5)
            local yOffset = rand(-barH * 0.35, barH * 0.35)
            local dirX    = xOffset > 0 and 1 or -1

            p.active  = true ; p.life = 0
            p.maxLife = rand(1.0, 2.2)
            p.x       = cx + xOffset ; p.y = cy + yOffset
            p.vx      = dirX * rand(4, 18)
            p.vy      = rand(12, 38)

            local size = rand(5, 12)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            return
        end
    end
end

local function UpdateAmbient(p, dt)
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
    p.tex:SetAlpha(math.max(0, alpha) * 0.50)
end

-- ============================================================
--  PARTICULES FRONT
-- ============================================================

local function SpawnFront(wx, wy)
    local roll    = math.random(10)
    local typeIdx = roll <= 4 and 1 or (roll <= 7 and 3 or 2)
    local ptype   = frontTypes[typeIdx]

    for _, p in ipairs(frontParts) do
        if not p.active and p.typeIdx == typeIdx then
            local angle = rad(90 + rand(-ptype.spread * 0.5, ptype.spread * 0.5))
            local speed = rand(ptype.speedMin, ptype.speedMax)
            local size  = rand(ptype.sizeMin, ptype.sizeMax)

            p.active  = true ; p.life = 0
            p.maxLife = rand(ptype.lifeMin, ptype.lifeMax)
            p.x       = wx + rand(-5, 5)
            p.y       = wy + rand(-8, 8)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(1)
            return
        end
    end
end

local function UpdateFront(p, dt)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - p.ptype.gravity * dt
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha = t < 0.5 and 1 or math.max(0, (1 - t) / 0.5)
    p.tex:SetAlpha(alpha * 0.88)
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local texPaths = {
        TEX_FIRE .. "Particle_Fire_01",
        TEX_FIRE .. "Particle_Fire_02",
        TEX_FIRE .. "Particle_Fire_03",
    }

    -- Particules ambiantes — rouge sombre
    for i = 1, AMB_COUNT do
        local tex = container:CreateTexture(nil, "BACKGROUND")
        tex:SetTexture(texPaths[(i % 3) + 1])
        tex:SetAlpha(0)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(1.0, 0.20, 0.03)
        ambParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0 }
    end

    -- Particules front — rouge/orange vif
    for i = 1, FRONT_COUNT do
        local typeIdx = ((i - 1) % 3) + 1
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(texPaths[typeIdx])
        tex:SetAlpha(0)
        tex:SetBlendMode("ADD")
        -- Alterner rouge vif et orange selon le type
        if typeIdx == 2 then
            tex:SetVertexColor(1.0, 0.55, 0.08)   -- orange
        else
            tex:SetVertexColor(1.0, 0.18, 0.02)   -- rouge
        end
        frontParts[i] = {
            tex=tex, ptype=frontTypes[typeIdx], typeIdx=typeIdx,
            active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0,
        }
    end
end

function FX.Start(duration)
    isActive      = true
    ambSpawnAcc   = 0
    frontSpawnAcc = 0
    for _, p in ipairs(ambParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(frontParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive = false
end

function FX.Reset()
    isActive = false
    for _, p in ipairs(ambParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(frontParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    for _, p in ipairs(ambParts)   do UpdateAmbient(p, dt) end
    for _, p in ipairs(frontParts) do UpdateFront(p, dt)   end

    ambSpawnAcc = ambSpawnAcc + dt
    if ambSpawnAcc >= AMB_SPAWN then
        ambSpawnAcc = 0
        SpawnAmbient(progress)
    end

    frontSpawnAcc = frontSpawnAcc + dt
    if frontSpawnAcc >= FRONT_SPAWN then
        frontSpawnAcc = 0
        local count = math.random(2, 4)
        for _ = 1, count do SpawnFront(frontX, cy) end
    end
end
