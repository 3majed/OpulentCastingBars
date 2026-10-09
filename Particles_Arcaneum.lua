-- ============================================================
--  Opulent Casting Bars — Particles_Arcaneum.lua
--  Arcaneum : rune centrale alternée + rochers en orbite
--  · Bout de barre : cendres + braises pixel (style Inferno)
--    recolorées rose-violet magenta
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["arcaneum"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end
local function Clamp01(v)
    if type(v) ~= "number" or v ~= v then return 0 end
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

local TEX_ARCANEUM = SCB.TEX_PATH .. "arcaneum\\"

local ROCK_SMALL_COUNT  = 0
local ROCK_MEDIUM_COUNT = 0
local ROCK_BIG_COUNT    = 0

local ORBIT_MISC_COUNT   = 10
local ORBIT_RX_MIN       = 105
local ORBIT_RX_MAX       = 145
local ORBIT_RY_MIN       = 14
local ORBIT_RY_MAX       = 32
local ORBIT_SPEED_MIN    = 0.18
local ORBIT_SPEED_MAX    = 0.38
local ORBIT_SELF_ROT_MIN = 0.35
local ORBIT_SELF_ROT_MAX = 1.15

local FALL_GRAVITY = 260
local FX_FADE_DUR  = 0.65

local RUNE_SIZE      = 230
local RUNE_ALPHA     = 0.42
local RUNE_ROT_SPEED = 0.55

-- ============================================================
--  CONSTANTES BOUT DE BARRE — CENDRES (style Inferno, magenta)
-- ============================================================

local EMBER_COUNT = 130
local EMBER_SPAWN = 0.016

local emberTypes = {
    { sizeMin=8,  sizeMax=18, speedMin=22, speedMax=65,  lifeMin=0.9, lifeMax=2.0, gravity=5,  spread=170, driftX=0.6 },
    { sizeMin=4,  sizeMax=10, speedMin=75, speedMax=180, lifeMin=0.3, lifeMax=0.8, gravity=11, spread=100, driftX=0.0 },
    { sizeMin=5,  sizeMax=15, speedMin=38, speedMax=95,  lifeMin=0.7, lifeMax=1.5, gravity=16, spread=130, driftX=0.4 },
}

local EMBER_COLORS = {
    { 1.0,  0.15, 0.85 },
    { 0.90, 0.05, 0.95 },
    { 1.0,  0.30, 0.75 },
    { 0.85, 0.10, 1.0  },
}

-- ============================================================
--  CONSTANTES BOUT DE BARRE — BRAISES PIXEL (style Inferno, magenta)
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
    { 1.0,  0.15, 0.90, 1.0  },
    { 0.90, 0.10, 1.0,  0.90 },
    { 1.0,  0.35, 0.85, 0.65 },
    { 0.95, 0.05, 0.80, 0.75 },
    { 1.0,  0.50, 0.95, 0.50 },
    { 0.80, 0.10, 0.95, 0.85 },
}

-- ============================================================
--  ÉTAT
-- ============================================================

local rocks, orbitRocks     = {}, {}
local emberParts, sparkParts = {}, {}
local active, fading        = false, false
local fadeT, runeTimer      = 0, 0
local emberSpawnAcc, sparkSpawnAcc = 0, 0
local castDuration          = 5
local runeSwap              = false
local runeRevealAlpha       = 0

local texRuneCenter = nil
local texRuneClip   = nil
local rune01Tex     = nil
local rune02Tex     = nil

-- ============================================================
--  ROTATION TEXTURE
-- ============================================================

local function SetTextureRotation(tex, angle)
    local c, s = math.cos(angle), math.sin(angle)
    tex:SetTexCoord(
        0.5 + (-0.5)*c - (-0.5)*s, 0.5 + (-0.5)*s + (-0.5)*c,
        0.5 + (-0.5)*c - ( 0.5)*s, 0.5 + (-0.5)*s + ( 0.5)*c,
        0.5 + ( 0.5)*c - (-0.5)*s, 0.5 + ( 0.5)*s + (-0.5)*c,
        0.5 + ( 0.5)*c - ( 0.5)*s, 0.5 + ( 0.5)*s + ( 0.5)*c
    )
end

local function GetRuneReveal(frontX)
    local f = SCB.Bar and SCB.Bar.frameInner
    if not f or not frontX then return 0 end
    local runeX = f:GetCenter()
    if not runeX then return 0 end
    local runeW = RUNE_SIZE * SCB.Bar:GetArtScale()
    local runeLeft = runeX - runeW * 0.5
    return Clamp01((frontX - runeLeft) / runeW)
end

local function SetRuneReveal(reveal, alphaMul)
    if not texRuneCenter then return end

    reveal = Clamp01(reveal)
    runeRevealAlpha = reveal
    alphaMul = alphaMul == nil and 1 or alphaMul

    if texRuneClip then
        if reveal <= 0 or alphaMul <= 0 then
            texRuneCenter:SetAlpha(0)
            texRuneClip:Hide()
            return
        end

        local f = SCB.Bar and SCB.Bar.frameInner
        if not f then return end
        local barW = f:GetWidth()
        if not barW or barW <= 0 then return end
        local sx, sy = SCB.Bar:GetArtScale()
        local runeW, runeH = RUNE_SIZE * sx, RUNE_SIZE * sy
        local runeLeft = (barW - runeW) * 0.5
        texRuneClip:Layout(f, runeLeft, runeW, 18 * sy, runeH, reveal)
        texRuneCenter:SetAlpha(RUNE_ALPHA * alphaMul)
    else
        texRuneCenter:SetAlpha(RUNE_ALPHA * reveal * alphaMul)
    end
end

-- ============================================================
--  ROCHERS
-- ============================================================

local function BuildRockTexturePool()
    local pool = {}
    for i = 1, 8 do pool[#pool + 1] = TEX_ARCANEUM .. string.format("Misc_Arcaneum_%02d", i) end
    for i = 1, 2 do pool[#pool + 1] = TEX_ARCANEUM .. string.format("Misc_Arcaneum_Medium_%02d", i) end
    for i = 1, 2 do pool[#pool + 1] = TEX_ARCANEUM .. string.format("Misc_Arcaneum_Big_%02d", i) end
    return pool
end

local ROCK_TEX_POOL = BuildRockTexturePool()

local function PickRockTexture(i)
    return ROCK_TEX_POOL[((i - 1) % #ROCK_TEX_POOL) + 1]
end

local function SetupOrbitRock(rock)
    rock.phase = "orbit"
    rock.tex:SetTexture(PickRockTexture(math.random(1, #ROCK_TEX_POOL)))
    local base = rand(12, 28)
    rock.baseSize = base
    rock.rx = rand(ORBIT_RX_MIN, ORBIT_RX_MAX)
    rock.ry = rand(ORBIT_RY_MIN, ORBIT_RY_MAX)
    rock.orbitAngle = rand(0, math.pi * 2)
    rock.orbitSpeed = rand(ORBIT_SPEED_MIN, ORBIT_SPEED_MAX) * (math.random(2) == 1 and 1 or -1)
    rock.rot = rand(0, math.pi * 2)
    rock.rotSpeed = rand(ORBIT_SELF_ROT_MIN, ORBIT_SELF_ROT_MAX) * (math.random(2) == 1 and 1 or -1)
    rock.maxAlpha = rand(0.38, 0.72)
    rock.tex:SetSize(base, base)
    rock.tex:SetAlpha(0)
    SetTextureRotation(rock.tex, rock.rot)
end

local function SetupRock(rock, kind)
    rock.kind = kind
    rock.phase = "float"
    rock.tex:SetTexture(PickRockTexture(math.random(1, #ROCK_TEX_POOL)))
    if kind == "small" then rock.size = rand(10, 20) * 0.60
    elseif kind == "medium" then rock.size = rand(20, 30) * 0.60
    else rock.size = rand(30, 42) * 0.60 end
    rock.xFrac = rand(0.04, 0.96)
    rock.revealAt = rand(0.03, 0.92)
    rock.side = (math.random(2) == 1) and -1 or 1
    rock.yOuter = rand(-2, 4)
    rock.yBase = rand(-3, 3)
    rock.floatAmp = rand(2, 6)
    rock.floatSpeed = rand(0.8, 1.8)
    rock.floatT = rand(0, math.pi * 2)
    rock.riseSpeed = rand(2, 8)
    rock.riseOffset = rand(-4, 6)
    rock.rot = rand(0, math.pi * 2)
    rock.seed = rand(0, math.pi * 2)
    rock.rotSpeed = rand(-0.45, 0.45)
    rock.maxAlpha = rand(0.45, 0.85)
    rock.vx, rock.vy, rock.x, rock.y = 0, 0, 0, 0
    rock.tex:SetSize(rock.size, rock.size)
    rock.tex:SetAlpha(0)
    SetTextureRotation(rock.tex, rock.rot)
end

local function UpdateFloatingRock(rock, dt, progress, fillLX, fillW)
    rock.floatT = rock.floatT + dt * rock.floatSpeed
    rock.rot = rock.rot + rock.rotSpeed * dt
    rock.riseOffset = rock.riseOffset + rock.riseSpeed * dt
    local appear = math.min(1, math.max(0, (progress - rock.revealAt) / 0.16))
    local x = fillLX + fillW * rock.xFrac + math.sin(rock.floatT * 0.7 + rock.seed) * 3
    local f = SCB.Bar.frameInner
    local _, cy = f:GetCenter()
    local halfH = f:GetHeight() * 0.5
    local y = (cy or 0) + rock.side * (halfH * 0.30 + rock.yOuter) + rock.yBase
            + math.sin(rock.floatT) * rock.floatAmp + rock.riseOffset + 15
    rock.x, rock.y = x, y
    rock.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    rock.tex:SetAlpha(rock.maxAlpha * appear)
    local scale = 0.90 + 0.18 * (0.5 + 0.5 * math.sin(rock.floatT * 0.9 + rock.seed))
    rock.tex:SetSize(rock.size * scale, rock.size * scale)
    SetTextureRotation(rock.tex, rock.rot)
end

local function UpdateOrbitRock(rock, dt, alphaMul)
    if rock.phase ~= "orbit" then return end
    local f = SCB.Bar.frameInner
    local cx, cy = f:GetCenter()
    if not cx then return end
    rock.orbitAngle = rock.orbitAngle + rock.orbitSpeed * dt * math.pi * 2
    rock.rot = rock.rot + rock.rotSpeed * dt
    local x = cx + math.cos(rock.orbitAngle) * rock.rx
    local y = cy + math.sin(rock.orbitAngle) * rock.ry
    rock.x, rock.y = x, y
    rock.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    rock.tex:SetAlpha(rock.maxAlpha * (alphaMul or 1))
    rock.tex:SetSize(rock.baseSize, rock.baseSize)
    SetTextureRotation(rock.tex, rock.rot)
end

local function UpdateFallingRock(rock, dt, alphaMul)
    if rock.phase ~= "fall" then return end
    rock.vy = rock.vy - FALL_GRAVITY * dt
    rock.x = rock.x + rock.vx * dt
    rock.y = rock.y + rock.vy * dt
    rock.rot = rock.rot + rock.rotSpeed * dt * 1.8
    rock.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", rock.x, rock.y)
    rock.tex:SetAlpha((alphaMul or 1) * rock.maxAlpha)
    SetTextureRotation(rock.tex, rock.rot)
end

local function StartFallingRocks()
    local function toFall(r)
        if (r.phase == "float" or r.phase == "orbit") and r.tex:GetAlpha() > 0.02 then
            r.phase = "fall" ; r.vx = rand(-18, 18) ; r.vy = rand(18, 52)
        else
            r.phase = "idle" ; r.tex:SetAlpha(0)
        end
    end
    for _, r in ipairs(rocks)      do toFall(r) end
    for _, r in ipairs(orbitRocks) do toFall(r) end
end

-- ============================================================
--  CENDRES (bout de barre, style Inferno — magenta)
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
--  BRAISES PIXEL (bout de barre, style Inferno — magenta)
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
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env
    if t < 0.15 then env = t / 0.15
    elseif t < 0.75 then env = 1 + math.sin(p.life * 18) * 0.15
    else env = (1 - t) / 0.25 end
    p.tex:SetAlpha(Clamp01(math.max(0, env) * p.baseAlpha * (globalFade or 1)))
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["arcaneum"]
    rune01Tex = school and school.rune01 or (SCB.TEX_PATH .. "arcane\\Rune_01")
    rune02Tex = school and school.rune02 or (SCB.TEX_PATH .. "arcane\\Rune_02")

    if SCB.Clip and SCB.Clip.New then
        texRuneClip = SCB.Clip:New(bar)
        if texRuneClip.SetFrameLevel and bar.GetFrameLevel then
            texRuneClip:SetFrameLevel(math.max(0, (bar:GetFrameLevel() or 0) - 1))
        end
        local child = texRuneClip:GetChild()
        if child.SetFrameLevel and bar.GetFrameLevel then
            child:SetFrameLevel(math.max(0, (bar:GetFrameLevel() or 0) - 1))
        end
        texRuneCenter = child:CreateTexture(nil, "BACKGROUND")
        texRuneCenter:SetAllPoints(child)
        texRuneClip:Hide()
    else
        texRuneCenter = bar:CreateTexture(nil, "BACKGROUND", nil, -6)
        texRuneCenter:SetPoint("CENTER", bar, "CENTER", 0, 18)
    end
    texRuneCenter:SetTexture(rune01Tex)
    texRuneCenter:SetBlendMode("ADD")
    if not texRuneClip then
        texRuneCenter:SetSize(RUNE_SIZE, RUNE_SIZE)
    end
    texRuneCenter:SetAlpha(0)

    local function allocRocks(count, kind)
        for _ = 1, count do
            local t = bar:CreateTexture(nil, "BACKGROUND", nil, -4)
            t:SetAlpha(0)
            local r = { tex = t, phase = "idle" }
            SetupRock(r, kind)
            rocks[#rocks + 1] = r
        end
    end

    allocRocks(ROCK_SMALL_COUNT,  "small")
    allocRocks(ROCK_MEDIUM_COUNT, "medium")
    allocRocks(ROCK_BIG_COUNT,    "big")

    for _ = 1, ORBIT_MISC_COUNT do
        local t = bar:CreateTexture(nil, "BACKGROUND", nil, -5)
        t:SetAlpha(0)
        local r = { tex = t, phase = "idle" }
        SetupOrbitRock(r)
        orbitRocks[#orbitRocks + 1] = r
    end

    -- Textures pour les cendres : particules Arcaneum propres
    local FRONT_TEX = {
        TEX_ARCANEUM .. "Particle_Arcaneum_01",
        TEX_ARCANEUM .. "Particle_Arcaneum_02",
    }
    local function getMisc(i)
        return FRONT_TEX[((i - 1) % #FRONT_TEX) + 1]
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
    local sparkTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
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
end

function FX.Start(duration)
    castDuration   = duration or 5
    active, fading, fadeT = true, false, 0
    runeTimer      = 0
    runeRevealAlpha = 0
    emberSpawnAcc  = 0
    sparkSpawnAcc  = 0

    if texRuneCenter then
        texRuneCenter:SetTexture(runeSwap and rune02Tex or rune01Tex)
        if not texRuneClip then
            texRuneCenter:SetSize(RUNE_SIZE, RUNE_SIZE)
        end
        SetRuneReveal(0)
        SetTextureRotation(texRuneCenter, 0)
    end
    runeSwap = not runeSwap

    for _, r in ipairs(rocks)      do SetupRock(r, r.kind) end
    for _, r in ipairs(orbitRocks) do SetupOrbitRock(r) end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(sparkParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    active, fading, fadeT = false, true, 0
    StartFallingRocks()
end

function FX.Reset()
    active, fading = false, false
    SetRuneReveal(0)
    for _, r in ipairs(rocks)      do r.phase = "idle" ; r.tex:SetAlpha(0) end
    for _, r in ipairs(orbitRocks) do r.phase = "idle" ; r.tex:SetAlpha(0) end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(sparkParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.UpdateFade(dt)
    if not fading then return end
    fadeT = fadeT + dt
    local fade = math.max(0, 1 - fadeT / FX_FADE_DUR)
    if texRuneCenter then SetRuneReveal(runeRevealAlpha, fade) end
    for _, r in ipairs(rocks)      do UpdateFallingRock(r, dt, fade) end
    for _, r in ipairs(orbitRocks) do UpdateFallingRock(r, dt, fade) end
    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, fade) end
    for _, p in ipairs(sparkParts) do UpdateSpark(p,  dt, fade) end
    if fadeT >= FX_FADE_DUR then FX.Reset() end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if texRuneCenter and active then
        runeTimer = runeTimer + dt
        if not texRuneClip then
            texRuneCenter:SetSize(RUNE_SIZE, RUNE_SIZE)
        end
        SetTextureRotation(texRuneCenter, runeTimer * RUNE_ROT_SPEED)
        SetRuneReveal(GetRuneReveal(frontX))
    end

    if not active then return end

    for _, r in ipairs(rocks) do
        if r.phase == "float" then UpdateFloatingRock(r, dt, progress, fillLX, fillW) end
    end
    for _, r in ipairs(orbitRocks) do
        if r.phase == "orbit" then UpdateOrbitRock(r, dt, 1) end
    end

    -- Cendres (bout de barre — magenta)
    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, 1) end
    emberSpawnAcc = emberSpawnAcc + dt
    if emberSpawnAcc >= EMBER_SPAWN then
        emberSpawnAcc = 0
        local count = math.random(4, 8)
        for _ = 1, count do SpawnEmber(frontX, cy) end
    end

    -- Braises pixel (bout de barre — magenta)
    for _, p in ipairs(sparkParts) do UpdateSpark(p, dt, 1) end
    sparkSpawnAcc = sparkSpawnAcc + dt
    if sparkSpawnAcc >= SPARK_SPAWN then
        sparkSpawnAcc = 0
        local count = math.random(3, 6)
        for _ = 1, count do SpawnSpark(frontX, cy) end
    end
end
