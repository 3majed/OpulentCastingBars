-- ============================================================
--  Opulent Casting Bars — Particles_MossystoneIcon.lua
--  Mossy Stone Icon
--  - Icône de sort au même emplacement que Honey Icon
--  - Particules type Fishing (front + extérieur barre)
--  - Recoloration vert d'eau #38C9A0
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["mossystone_icon"] = FX

local function rand(a, b) return a + math.random() * (b - a) end

local ICON_CENTER_X = -149
local ICON_CENTER_Y = 10
local ICON_SIZE     = 51

-- Fishing-like droplets
local DROP_COUNT      = 55
local DROP_SPAWN_RATE = 0.045
local DROP_BURST_MIN  = 1
local DROP_BURST_MAX  = 3
local DROP_STOP_AT    = 0.93
local DROP_SIZE_MIN   = 5
local DROP_SIZE_MAX   = 13
local DROP_SPEED_MIN  = 45
local DROP_SPEED_MAX  = 115
local DROP_GRAVITY    = 160
local DROP_LIFE_MIN   = 0.30
local DROP_LIFE_MAX   = 0.70
local DROP_ALPHA      = 0.88
local DROP_ANGLE_MIN  = math.rad(45)
local DROP_ANGLE_MAX  = math.rad(135)

-- Fishing-like ripples
local RIP_COUNT       = 12
local RIP_SPAWN_RATE  = 0.18
local RIP_SIZE_START  = 8
local RIP_SIZE_END    = 38
local RIP_LIFE        = 0.55
local RIP_ALPHA_PEAK  = 0.45

-- Exterior ambient
local AMB_COUNT       = 40
local AMB_SPAWN_RATE  = 0.08
local AMB_STOP_AT     = 0.95
local AMB_SIZE_MIN    = 3
local AMB_SIZE_MAX    = 8
local AMB_VY_MIN      = 8
local AMB_VY_MAX      = 22
local AMB_VX_MIN      = -12
local AMB_VX_MAX      = 12
local AMB_LIFE_MIN    = 0.6
local AMB_LIFE_MAX    = 1.4
local AMB_ALPHA       = 0.38

local FADE_DUR = 0.45

local COLOR_R, COLOR_G, COLOR_B = 0.22, 0.79, 0.63 -- #38C9A0

local isActive = false
local isFading = false
local fadeT    = 0
local drops    = {}
local ripples  = {}
local ambs     = {}
local dropAcc  = 0
local ripAcc   = 0
local ambAcc   = 0
local iconTex

local function PositionIcon()
    if not iconTex or not SCB.Bar.frameInner then return end
    iconTex:ClearAllPoints()
    iconTex:SetPoint("CENTER", SCB.Bar.frameInner, "CENTER", ICON_CENTER_X, ICON_CENTER_Y)
end

local function SpawnDrop(frontX, cy, barH)
    for _, p in ipairs(drops) do
        if not p.active then
            local angle = rand(DROP_ANGLE_MIN, DROP_ANGLE_MAX)
            local speed = rand(DROP_SPEED_MIN, DROP_SPEED_MAX)
            local spread = math.min(barH * 0.3, 12)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(DROP_LIFE_MIN, DROP_LIFE_MAX)
            p.x       = frontX + rand(-5, 6)
            p.y       = cy + rand(-spread, spread)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            local size = rand(DROP_SIZE_MIN, DROP_SIZE_MAX)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateDrop(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - DROP_GRAVITY * dt
    p.x  = p.x  + p.vx * dt
    p.y  = p.y  + p.vy * dt
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t < 0.12 and t/0.12 or (t < 0.60 and 1 or math.max(0, (1-t)/0.40))
    p.tex:SetAlpha(env * DROP_ALPHA * (gf or 1))
end

local function SpawnRipple(frontX, cy, barH)
    for _, r in ipairs(ripples) do
        if not r.active then
            local spread = math.min(barH * 0.25, 10)
            r.active = true
            r.life   = 0
            r.x      = frontX + rand(-6, 6)
            r.y      = cy + rand(-spread, spread)
            r.tex:SetSize(RIP_SIZE_START, RIP_SIZE_START * 0.45)
            r.tex:SetAlpha(0)
            r.tex:ClearAllPoints()
            r.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", r.x, r.y)
            return
        end
    end
end

local function UpdateRipple(r, dt, gf)
    if not r.active then return end
    r.life = r.life + dt
    local t = r.life / RIP_LIFE
    if t >= 1 then r.active = false ; r.tex:SetAlpha(0) ; return end
    local size = RIP_SIZE_START + (RIP_SIZE_END - RIP_SIZE_START) * t
    r.tex:SetSize(size, size * 0.45)
    r.tex:ClearAllPoints()
    r.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", r.x, r.y)
    local env = t < 0.25 and t/0.25 or math.max(0, (1-t)/0.75)
    r.tex:SetAlpha(env * RIP_ALPHA_PEAK * (gf or 1))
end

local function SpawnAmb(barLX, barW, cy, barH)
    for _, p in ipairs(ambs) do
        if not p.active then
            local spread = math.min(barH * 0.4, 16)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(AMB_LIFE_MIN, AMB_LIFE_MAX)
            p.x       = barLX + rand(0, barW)
            p.y       = cy + rand(-spread, spread)
            p.vx      = rand(AMB_VX_MIN, AMB_VX_MAX)
            p.vy      = rand(AMB_VY_MIN, AMB_VY_MAX)
            local size = rand(AMB_SIZE_MIN, AMB_SIZE_MAX)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateAmb(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t < 0.20 and t/0.20 or (t < 0.70 and 1 or math.max(0, (1-t)/0.30))
    p.tex:SetAlpha(env * AMB_ALPHA * (gf or 1))
end

function FX.Init(container, bar)
    iconTex = bar:CreateTexture(nil, "ARTWORK", nil, -1)
    iconTex:SetSize(ICON_SIZE, ICON_SIZE)
    iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    iconTex:SetAlpha(0)
    PositionIcon()

    local dropTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    local ripTex  = SCB.TEX_PATH .. "frost\\Particle_Frost_02"

    drops = {}
    for i = 1, DROP_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(dropTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(COLOR_R, COLOR_G, COLOR_B)
        tex:SetAlpha(0)
        drops[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0 }
    end

    ripples = {}
    for i = 1, RIP_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(ripTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(COLOR_R, COLOR_G, COLOR_B)
        tex:SetAlpha(0)
        ripples[i] = { tex=tex, active=false, life=0, x=0, y=0 }
    end

    ambs = {}
    for i = 1, AMB_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(i % 2 == 0 and dropTex or ripTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(COLOR_R, COLOR_G, COLOR_B)
        tex:SetAlpha(0)
        ambs[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0 }
    end
end

function FX.Start(duration)
    isActive = true
    isFading = false
    fadeT    = 0
    dropAcc  = 0
    ripAcc   = 0
    ambAcc   = 0

    if iconTex then
        iconTex:SetTexture(SCB.Bar.currentSpellIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
        iconTex:SetAlpha(1)
        PositionIcon()
    end

    for _, p in ipairs(drops)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, r in ipairs(ripples) do r.active = false ; r.tex:SetAlpha(0) end
    for _, p in ipairs(ambs)    do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive = false
    isFading = true
    fadeT    = 0
end

function FX.UpdateFade(dt)
    if not isFading then return end
    fadeT = fadeT + dt
    local gf = math.max(0, 1 - fadeT / FADE_DUR)
    for _, p in ipairs(drops)   do UpdateDrop(p, dt, gf) end
    for _, r in ipairs(ripples) do UpdateRipple(r, dt, gf) end
    for _, p in ipairs(ambs)    do UpdateAmb(p, dt, gf) end
    if iconTex then iconTex:SetAlpha(gf) end
    if fadeT >= FADE_DUR then
        isFading = false
        for _, p in ipairs(drops)   do p.active = false ; p.tex:SetAlpha(0) end
        for _, r in ipairs(ripples) do r.active = false ; r.tex:SetAlpha(0) end
        for _, p in ipairs(ambs)    do p.active = false ; p.tex:SetAlpha(0) end
        if iconTex then iconTex:SetAlpha(0) end
    end
end

function FX.Reset()
    isActive = false
    isFading = false
    for _, p in ipairs(drops)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, r in ipairs(ripples) do r.active = false ; r.tex:SetAlpha(0) end
    for _, p in ipairs(ambs)    do p.active = false ; p.tex:SetAlpha(0) end
    if iconTex then iconTex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH)
    if not isActive then return end

    PositionIcon()

    local f = SCB.Bar.frameInner
    local cx, barCY = f:GetCenter()
    if not cx then return end
    local barLX = cx - barW * 0.5

    for _, p in ipairs(drops) do UpdateDrop(p, dt, 1) end
    if progress > 0.01 and progress < DROP_STOP_AT then
        dropAcc = dropAcc + dt
        if dropAcc >= DROP_SPAWN_RATE then
            dropAcc = 0
            for _ = 1, math.random(DROP_BURST_MIN, DROP_BURST_MAX) do
                SpawnDrop(frontX, barCY, barH)
            end
        end
    end

    for _, r in ipairs(ripples) do UpdateRipple(r, dt, 1) end
    if progress > 0.01 and progress < DROP_STOP_AT then
        ripAcc = ripAcc + dt
        if ripAcc >= RIP_SPAWN_RATE then
            ripAcc = 0
            SpawnRipple(frontX, barCY, barH)
        end
    end

    for _, p in ipairs(ambs) do UpdateAmb(p, dt, 1) end
    if progress > 0.01 and progress < AMB_STOP_AT then
        ambAcc = ambAcc + dt
        if ambAcc >= AMB_SPAWN_RATE then
            ambAcc = 0
            SpawnAmb(barLX, barW, barCY, barH)
        end
    end
end
