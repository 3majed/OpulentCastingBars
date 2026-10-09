-- ============================================================
--  Sleek Casting Bars — Particles_Chaos.lua
--  · Spike_BG : 1 texture aléatoire parmi 4, en fond
--  · Cendres corrompues vertes (style Shadow)
--  · Glow vert sur le front de progression
-- ============================================================

local FX = {}
SCB.FX          = SCB.FX or {}
SCB.FX["chaos"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local pi2 = math.pi * 2

local ASH_R, ASH_G, ASH_B  = 0.10, 0.85, 0.20
local ASH_COUNT             = 60
local ASH_SPAWN_RATE        = 0.05
local ASH_ALPHA             = 0.90
local ASH_SIZE_MIN, ASH_SIZE_MAX = 3, 9
local GLOW_COUNT            = 60
local GLOW_SPAWN_RATE       = 0.02
local GLOW_STOP_AT          = 0.87
local GLOW_ALPHA            = 0.55
local GLOW_SIZE_MIN, GLOW_SIZE_MAX = 6, 12
local GLOW_LIFE_MIN, GLOW_LIFE_MAX = 0.18, 0.35
local FADE_DUR              = 0.50
local SPIKE_GROW_END        = 0.60  -- progress à laquelle le spike est à taille réelle

local isActive     = false
local isFading     = false
local fadeT        = 0
local ashes        = {}
local glowParts    = {}
local ashSpawnAcc  = 0
local glowSpawnAcc = 0
local spikeBGTex   = nil

local function SpawnAsh(fillLX, fillW, barCY, barH, progress)
    for _, a in ipairs(ashes) do
        if not a.active then
            local x = rand(fillLX, fillLX + fillW * progress)
            local edge = (math.random(2) == 1) and 1 or -1
            local y = barCY + edge * (barH * 0.5) * rand(0.2, 0.8)
            a.active=true ; a.life=0
            a.maxLife = rand(0.8, 2.2)
            a.x, a.y  = x, y
            a.vx      = rand(-18, 18)
            a.vy      = rand(12, 35)
            a.drift   = rand(-8, 8)
            a.phase   = rand(0, pi2)
            a.tex:SetSize(rand(ASH_SIZE_MIN, ASH_SIZE_MAX), rand(ASH_SIZE_MIN, ASH_SIZE_MAX))
            a.tex:SetAlpha(ASH_ALPHA)
            a.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
            return
        end
    end
end

local function UpdateAsh(a, dt)
    if not a.active then return end
    a.life = a.life + dt
    local t = a.life / a.maxLife
    if t >= 1 then a.active=false ; a.tex:SetAlpha(0) ; return end
    a.vy = a.vy - 4*dt
    a.x  = a.x + a.vx*dt + math.sin(a.life*2.5+a.phase)*a.drift*dt
    a.y  = a.y + a.vy*dt
    a.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", a.x, a.y)
    local alpha = t<0.15 and t/0.15 or (t<0.65 and 1 or math.max(0,(1-t)/0.35))
    a.tex:SetAlpha(alpha * ASH_ALPHA)
end

local function SpawnGlow(frontX, cy, barH)
    for _, p in ipairs(glowParts) do
        if not p.active then
            local spread = math.min(barH*0.25, 10)
            p.active=true ; p.life=0
            p.maxLife = rand(GLOW_LIFE_MIN, GLOW_LIFE_MAX)
            p.x = frontX+rand(0,3) ; p.y = cy+rand(-spread,spread)
            p.vy = rand(-5,5) ; p.phase = math.random()*pi2
            p.tex:SetSize(rand(GLOW_SIZE_MIN,GLOW_SIZE_MAX), rand(GLOW_SIZE_MIN,GLOW_SIZE_MAX))
            p.tex:SetAlpha(0)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateGlow(p, dt)
    if not p.active then return end
    p.life = p.life+dt
    local t = p.life/p.maxLife
    if t >= 1 then p.active=false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy*0.90
    p.y  = p.y+p.vy*dt+math.sin(p.life*10+p.phase)*0.3
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env = t<0.2 and t/0.2 or (t<0.8 and 1 or (1-t)/0.2)
    p.tex:SetAlpha(math.max(0,env)*GLOW_ALPHA)
end

function FX.Init(container, bar)
    local school = SCB.Schools.data["chaos"]
    if not school then return end

    -- Spike_BG
    local spikeBGs = school.spikeBGs or {}
    if #spikeBGs > 0 then
        spikeBGTex = bar:CreateTexture(nil, "BACKGROUND", nil, -2)
        spikeBGTex:SetTexture(spikeBGs[1])
        spikeBGTex:SetBlendMode("BLEND")
        spikeBGTex:SetPoint("CENTER", bar, "CENTER", 0, 0)
        spikeBGTex:SetSize(1, 1)
        spikeBGTex:SetAlpha(0)
    end

    -- Cendres
    local earthSchool = SCB.Schools.data["earth"]
    local miscTexs = {}
    if earthSchool then
        for _, t in ipairs(earthSchool.rocks  or {}) do miscTexs[#miscTexs+1] = t end
        for _, t in ipairs(earthSchool.debris or {}) do miscTexs[#miscTexs+1] = t end
    end
    ashes = {}
    for i = 1, ASH_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if #miscTexs > 0 then tex:SetTexture(miscTexs[((i-1)%#miscTexs)+1]) end
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(ASH_R, ASH_G, ASH_B)
        tex:SetAlpha(0)
        ashes[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0, drift=0, phase=0 }
    end

    -- Glow
    glowParts = {}
    local glowTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(glowTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(ASH_R, ASH_G, ASH_B)
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vy=0, phase=0 }
    end
end

function FX.Start(duration)
    isActive=true ; isFading=false ; fadeT=0
    ashSpawnAcc=0 ; glowSpawnAcc=0
    for _, a in ipairs(ashes)     do a.active=false ; a.tex:SetAlpha(0) end
    for _, p in ipairs(glowParts) do p.active=false ; p.tex:SetAlpha(0) end
    if spikeBGTex then
        local school   = SCB.Schools.data["chaos"]
        local spikeBGs = school and school.spikeBGs or {}
        if #spikeBGs > 0 then spikeBGTex:SetTexture(spikeBGs[math.random(#spikeBGs)]) end
        spikeBGTex:SetSize(1, 1)
        spikeBGTex:SetAlpha(1)
    end
end

function FX.Stop()
    isActive=false ; isFading=true ; fadeT=0
end

function FX.UpdateFade(dt)
    if not isFading then return end
    fadeT = fadeT+dt
    local gf = math.max(0, 1-fadeT/FADE_DUR)
    if spikeBGTex then spikeBGTex:SetAlpha(gf) end
    if fadeT >= FADE_DUR then
        isFading=false
        if spikeBGTex then spikeBGTex:SetAlpha(0) end
        for _, a in ipairs(ashes)     do a.active=false ; a.tex:SetAlpha(0) end
        for _, p in ipairs(glowParts) do p.active=false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    isActive=false ; isFading=false
    if spikeBGTex then spikeBGTex:SetAlpha(0) end
    for _, a in ipairs(ashes)     do a.active=false ; a.tex:SetAlpha(0) end
    for _, p in ipairs(glowParts) do p.active=false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end
    -- Scale Spike_BG selon la progression
    if spikeBGTex then
        local t     = math.min(progress / SPIKE_GROW_END, 1)
        local ease  = 1 - (1-t)^3
        local barW2 = barW or (SCB.Bar.frame and SCB.Bar.frame:GetWidth()) or 400
        local barH2 = barH or (SCB.Bar.frame and SCB.Bar.frame:GetHeight()) or 200
        spikeBGTex:SetSize(math.max(barW2 * ease, 1), math.max(barH2 * ease, 1))
    end

    for _, a in ipairs(ashes) do UpdateAsh(a, dt) end
    ashSpawnAcc = ashSpawnAcc+dt
    if ashSpawnAcc >= ASH_SPAWN_RATE then
        ashSpawnAcc=0
        SpawnAsh(fillLX, fillW, cy, barH, progress)
    end
    for _, p in ipairs(glowParts) do UpdateGlow(p, dt) end
    if progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc+dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc=0
            for _ = 1, math.random(2,4) do SpawnGlow(frontX, cy, barH) end
        end
    end
end
