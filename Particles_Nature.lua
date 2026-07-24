-- ============================================================
--  Sleek Casting Bars — Particles_Nature.lua
-- ============================================================

local FX = {}
SCB.FX           = SCB.FX or {}
SCB.FX["nature"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local pi2 = math.pi * 2

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
--  CONSTANTES
-- ============================================================

local FRAME_SEQUENCE  = { 1, 2, 3, 2 }
local FRAME_SEQ_LEN   = #FRAME_SEQUENCE
local FRAME_DUR_MIN   = 0.10
local FRAME_DUR_MAX   = 0.18

local LEAF_COUNT         = 35
local LEAF_SPAWN_RATE    = 0.12
local LEAF_SIZE_MIN      = 10
local LEAF_SIZE_MAX      = 22
local LEAF_ALPHA_MIN     = 0.55
local LEAF_ALPHA_MAX     = 0.90
local LEAF_ROT_MIN       = 0.8
local LEAF_ROT_MAX       = 2.8
local LEAF_WAVE_AMP_MIN  = 3
local LEAF_WAVE_AMP_MAX  = 9
local LEAF_WAVE_FREQ_MIN = 1.2
local LEAF_WAVE_FREQ_MAX = 2.8
local LEAF_VY_MIN        = -4
local LEAF_VY_MAX        =  4
local LEAF_SPEED_MIN     = 55
local LEAF_SPEED_MAX     = 120

local FRONT_COUNT      = 60
local FRONT_SPAWN_RATE = 0.027
local FRONT_STOP_AT    = 0.90
local FRONT_SIZE_MIN   = 7
local FRONT_SIZE_MAX   = 16
local FRONT_ALPHA      = 0.88
local FRONT_SPEED_MIN  = 35
local FRONT_SPEED_MAX  = 95
local FRONT_GRAVITY    = 80
local FRONT_LIFE_MIN   = 0.35
local FRONT_LIFE_MAX   = 0.75

local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.02
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.55
local GLOW_SIZE_MIN   = 6
local GLOW_SIZE_MAX   = 12
local GLOW_LIFE_MIN   = 0.18
local GLOW_LIFE_MAX   = 0.35
local GLOW_R, GLOW_G, GLOW_B = 0.30, 1.0, 0.25

local LEAVES_FADE_DUR = 0.6

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local frameTimer    = 0
local frameDur      = 0.14
local seqPos        = 1
local isActive      = false
local leavesFading  = false
local leavesFadeT   = 0

local leaves        = {}
local frontLeaves   = {}
local glowParts     = {}
local leafSpawnAcc  = 0
local frontSpawnAcc = 0
local glowSpawnAcc  = 0

-- ============================================================
--  FRAME ANIMÉE
-- ============================================================

local function ApplyFrame()
    local bar    = SCB.Bar
    local school = SCB.Schools.data["nature"]
    if bar and bar.texFrame and school and school.frames then
        bar.texFrame:SetTexture(school.frames[FRAME_SEQUENCE[seqPos]])
    end
end

local function UpdateFrame(dt)
    if frameTimer < 0 then
        frameTimer = frameTimer + dt
        return
    end
    frameTimer = frameTimer + dt
    if frameTimer >= frameDur then
        frameTimer = frameTimer - frameDur
        frameDur   = rand(FRAME_DUR_MIN, FRAME_DUR_MAX)
        seqPos     = (seqPos % FRAME_SEQ_LEN) + 1
            ApplyFrame()
    end
end

-- ============================================================
--  FEUILLES FLUX
-- ============================================================

local function SpawnLeaf(barLX, barRX, barCY, barH)
    for _, lf in ipairs(leaves) do
        if not lf.active then
            local size     = rand(LEAF_SIZE_MIN, LEAF_SIZE_MAX)
            local speed    = rand(LEAF_SPEED_MIN, LEAF_SPEED_MAX)
            local waveAmp  = rand(LEAF_WAVE_AMP_MIN, LEAF_WAVE_AMP_MAX)
            local waveFreq = rand(LEAF_WAVE_FREQ_MIN, LEAF_WAVE_FREQ_MAX)
            local vy       = rand(LEAF_VY_MIN, LEAF_VY_MAX)
            local rotSpeed = rand(LEAF_ROT_MIN, LEAF_ROT_MAX)
                             * (math.random(2) == 1 and 1 or -1)
            local startY   = barCY + rand(-barH * 0.2, barH * 0.2)
            lf.active    = true
            lf.x         = barLX - size
            lf.y         = startY
            lf.baseY     = startY
            lf.vx        = speed
            lf.vy        = vy
            lf.waveAmp   = waveAmp
            lf.waveFreq  = waveFreq
            lf.wavePhase = rand(0, pi2)
            lf.rot       = rand(0, pi2)
            lf.rotSpeed  = rotSpeed
            lf.life      = 0
            lf.maxAlpha  = rand(LEAF_ALPHA_MIN, LEAF_ALPHA_MAX)
            lf.size      = size
            lf.deadX     = barRX + size * 2
            lf.tex:SetSize(size, size)
            lf.tex:SetAlpha(0)
            lf.tex:ClearAllPoints()
            lf.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", lf.x, lf.y)
            return
        end
    end
end

local function UpdateLeaf(lf, dt, globalFade)
    if not lf.active then return end
    lf.life = lf.life + dt
    lf.x    = lf.x + lf.vx * dt
    lf.y    = lf.baseY
              + math.sin(lf.life * lf.waveFreq + lf.wavePhase) * lf.waveAmp
              + lf.vy * lf.life
    lf.rot  = lf.rot + lf.rotSpeed * dt
    local fadeIn = math.min(lf.life / 0.5, 1)
    local alpha
    if lf.x > lf.deadX - 40 then
        local t = math.max(0, 1 - (lf.deadX - lf.x) / 40)
        alpha = lf.maxAlpha * fadeIn * (1 - t)
    else
        alpha = lf.maxAlpha * fadeIn
    end
    alpha = alpha * (globalFade or 1)
    if lf.x >= lf.deadX then
        lf.active = false ; lf.tex:SetAlpha(0) ; return
    end
    lf.tex:SetAlpha(alpha)
    lf.tex:ClearAllPoints()
    lf.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", lf.x, lf.y)
    SetTexRot(lf.tex, lf.rot)
end

-- ============================================================
--  FEUILLES FRONT (style Earth)
-- ============================================================

local function SpawnFrontLeaf(frontX, barCY, barH)
    for _, lf in ipairs(frontLeaves) do
        if not lf.active then
            local angle    = math.rad(rand(40, 140))
            local speed    = rand(FRONT_SPEED_MIN, FRONT_SPEED_MAX)
            local size     = rand(FRONT_SIZE_MIN, FRONT_SIZE_MAX)
            local rotSpeed = rand(LEAF_ROT_MIN, LEAF_ROT_MAX)
                             * (math.random(2) == 1 and 1 or -1)
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
    local alpha = (t < 0.55 and 1 or math.max(0, (1 - t) / 0.45))
                  * FRONT_ALPHA * (globalFade or 1)
    lf.tex:SetAlpha(alpha)
    lf.tex:ClearAllPoints()
    lf.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", lf.x, lf.y)
    SetTexRot(lf.tex, lf.rot)
end

-- ============================================================
--  PARTICULES GLOW (style Neutral, vert)
-- ============================================================

local function SpawnGlow(frontX, cy, barH)
    for _, p in ipairs(glowParts) do
        if not p.active then
            local spread = math.min(barH * 0.25, 10)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(GLOW_LIFE_MIN, GLOW_LIFE_MAX)
            p.x       = frontX + rand(0, 3)
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

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school   = SCB.Schools.data["nature"]
    local leafTexs = (school and school.leaves) or {}
    local nLeafs   = #leafTexs

    leaves = {}
    for i = 1, LEAF_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nLeafs > 0 then tex:SetTexture(leafTexs[((i-1) % nLeafs) + 1]) end
        tex:SetBlendMode("BLEND") ; tex:SetAlpha(0)
        leaves[i] = { tex=tex, active=false, x=0, y=0, baseY=0,
                      vx=0, vy=0, waveAmp=0, waveFreq=0, wavePhase=0,
                      rot=0, rotSpeed=0, life=0, maxAlpha=0, size=0, deadX=0 }
    end

    frontLeaves = {}
    for i = 1, FRONT_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nLeafs > 0 then tex:SetTexture(leafTexs[((i-1) % nLeafs) + 1]) end
        tex:SetBlendMode("BLEND") ; tex:SetAlpha(0)
        frontLeaves[i] = { tex=tex, active=false, x=0, y=0,
                           vx=0, vy=0, rot=0, rotSpeed=0, life=0, maxLife=0, size=0 }
    end

    glowParts = {}
    local glowTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(glowTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(GLOW_R, GLOW_G, GLOW_B)
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0,
                         x=0, y=0, vy=0, phase=0 }
    end

    seqPos     = 1
    frameTimer = 0
    frameDur   = rand(FRAME_DUR_MIN, FRAME_DUR_MAX)
    ApplyFrame()

    -- Préchargement GPU : créer des textures sur UIParent (toujours visible)
    -- à alpha quasi-zéro pour forcer le transfert en VRAM dès l'init
    local school = SCB.Schools.data["nature"]
    if school and school.frames then
        for _, f in ipairs(school.frames) do
            local preload = UIParent:CreateTexture(nil, "BACKGROUND")
            preload:SetTexture(f)
            preload:SetSize(1, 1)
            preload:SetAlpha(0.0001)
            preload:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
        end
    end
end



function FX.ResetFrame()
    seqPos     = 1
    frameTimer = 0
    local bar    = SCB.Bar
    local school = SCB.Schools.data["nature"]
    if bar and bar.texFrame and school and school.frames then
        bar.texFrame:SetTexture(school.frames[FRAME_SEQUENCE[seqPos]])
    end
end

function FX.Start(duration)
    isActive      = true
    leavesFading  = false
    frameDur      = rand(FRAME_DUR_MIN, FRAME_DUR_MAX)
    frameTimer    = -0.10
    leafSpawnAcc  = 0
    frontSpawnAcc = 0
    glowSpawnAcc  = 0
    local bar = SCB.Bar
    if bar and bar.texFrame then
        bar.texFrame:SetAlpha(1)
    end
    for _, lf in ipairs(leaves)      do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, lf in ipairs(frontLeaves) do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, p  in ipairs(glowParts)   do p.active  = false ; p.tex:SetAlpha(0)  end
end

function FX.Stop()
    isActive      = false
    leavesFading  = true
    leavesFadeT   = 0
    leafSpawnAcc  = 0
    frontSpawnAcc = 0
    glowSpawnAcc  = 0
end

function FX.UpdateFade(dt)
    if not leavesFading then return end
    leavesFadeT = leavesFadeT + dt
    local gFade = math.max(0, 1 - leavesFadeT / LEAVES_FADE_DUR)

    for _, lf in ipairs(leaves)      do UpdateLeaf(lf, dt, gFade) end
    for _, lf in ipairs(frontLeaves) do UpdateFrontLeaf(lf, dt, gFade) end
    for _, p  in ipairs(glowParts)   do UpdateGlow(p, dt, gFade) end

    if leavesFadeT >= LEAVES_FADE_DUR then
        leavesFading = false
        for _, lf in ipairs(leaves)      do lf.active = false ; lf.tex:SetAlpha(0) end
        for _, lf in ipairs(frontLeaves) do lf.active = false ; lf.tex:SetAlpha(0) end
        for _, p  in ipairs(glowParts)   do p.active  = false ; p.tex:SetAlpha(0)  end
    end
end

function FX.Reset()
    leavesFading = false
    for _, lf in ipairs(leaves)      do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, lf in ipairs(frontLeaves) do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, p  in ipairs(glowParts)   do p.active  = false ; p.tex:SetAlpha(0)  end
    -- Ne toucher à texFrame que si Nature est encore l'école active
    if SCB.Bar.currentSchoolKey == "nature" then
        local bar    = SCB.Bar
        local school = SCB.Schools.data["nature"]
        if bar and bar.texFrame and school and school.frames then
            bar.texFrame:SetTexture(school.frames[1])
            bar.texFrame:SetAlpha(1)
        end
    end
end


function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    local f = SCB.Bar.frameInner
    local cx, barCY = f:GetCenter()
    if not cx then return end

    local barLX = cx - barW * 0.5
    local barRX = cx + barW * 0.5

    UpdateFrame(dt)

    for _, lf in ipairs(leaves) do UpdateLeaf(lf, dt, 1) end
    leafSpawnAcc = leafSpawnAcc + dt
    if leafSpawnAcc >= LEAF_SPAWN_RATE then
        leafSpawnAcc = 0
        SpawnLeaf(barLX, barRX, barCY, barH)
    end

    for _, lf in ipairs(frontLeaves) do UpdateFrontLeaf(lf, dt, 1) end
    if progress > 0.02 and progress < FRONT_STOP_AT then
        frontSpawnAcc = frontSpawnAcc + dt
        if frontSpawnAcc >= FRONT_SPAWN_RATE then
            frontSpawnAcc = 0
            SpawnFrontLeaf(frontX, barCY, barH)
        end
    end

    for _, p in ipairs(glowParts) do UpdateGlow(p, dt, 1) end
    if progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc + dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc = 0
            local count = math.random(2, 4)
            for _ = 1, count do SpawnGlow(frontX, barCY, barH) end
        end
    end
end
