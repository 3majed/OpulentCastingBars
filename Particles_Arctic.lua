-- ============================================================
--  Opulent Casting Bars — Particles_Arctic.lua
--  Effets visuels Arctic :
--    · Mist glacée (réutilise Mist_Frost_01)
--    · Cailloux flottants (misc small/medium/big) derrière la barre
--    · Particules de front (Particle_Frost_01/02)
--    · À la fin du cast, les cailloux retombent avec gravité
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["arctic"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg) return deg * math.pi / 180 end

local TEX_ARCTIC = SCB.TEX_PATH .. "arctic\\"
local TEX_FROST  = SCB.TEX_PATH .. "frost\\"

local MIST_COUNT = 4
local MIST_W, MIST_H = 338, 169
local MIST_POS = { 0.18, 0.38, 0.62, 0.82 }

local ROCK_SMALL_COUNT  = 24
local ROCK_MEDIUM_COUNT = 12
local ROCK_BIG_COUNT    = 9

local FRONT_PART_COUNT = 48
local FRONT_SPAWN_RATE = 0.045

-- Anneau de misc en rotation (inspiré Earth)
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

local mists, rocks, orbitRocks, frontParts = {}, {}, {}, {}
local active = false
local fading = false
local fadeT = 0
local spawnAcc = 0

local function SetTextureRotation(tex, angle)
    local c, s = math.cos(angle), math.sin(angle)
    tex:SetTexCoord(
        0.5 + (-0.5)*c - (-0.5)*s, 0.5 + (-0.5)*s + (-0.5)*c,
        0.5 + (-0.5)*c - ( 0.5)*s, 0.5 + (-0.5)*s + ( 0.5)*c,
        0.5 + ( 0.5)*c - (-0.5)*s, 0.5 + ( 0.5)*s + (-0.5)*c,
        0.5 + ( 0.5)*c - ( 0.5)*s, 0.5 + ( 0.5)*s + ( 0.5)*c
    )
end

local function BuildRockTexturePool()
    local pool = {}
    for i = 1, 8 do pool[#pool + 1] = TEX_ARCTIC .. string.format("Misc_Arctic_%02d", i) end
    for i = 1, 2 do pool[#pool + 1] = TEX_ARCTIC .. string.format("Misc_Arctic_Medium_%02d", i) end
    for i = 1, 2 do pool[#pool + 1] = TEX_ARCTIC .. string.format("Misc_Arctic_Big_%02d", i) end
    return pool
end

local ROCK_TEX_POOL = BuildRockTexturePool()
local FRONT_TEX = {
    TEX_FROST .. "Particle_Frost_01",
    TEX_FROST .. "Particle_Frost_02",
}

local function PickRockTexture(i)
    return ROCK_TEX_POOL[((i - 1) % #ROCK_TEX_POOL) + 1]
end

local function SpawnFront(frontX, cy)
    for _, p in ipairs(frontParts) do
        if not p.active then
            local a = rad(rand(70, 125))
            local speed = rand(45, 125)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(0.30, 0.70)
            p.x       = frontX + rand(-4, 4)
            p.y       = cy + rand(-8, 8)
            p.vx      = math.cos(a) * speed
            p.vy      = math.sin(a) * speed
            local size = rand(7, 14)
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0.9)
            return
        end
    end
end

local function UpdateFrontParticle(p, dt, alphaMul)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then
        p.active = false
        p.tex:SetAlpha(0)
        return
    end
    p.vy = p.vy - 110 * dt
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local a = t < 0.45 and 1 or math.max(0, (1 - t) / 0.55)
    p.tex:SetAlpha(a * 0.75 * (alphaMul or 1))
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
    rock.x = 0
    rock.y = 0
    rock.vx = 0
    rock.vy = 0

    rock.tex:SetSize(base, base)
    rock.tex:SetAlpha(0)
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

local function SetupRock(rock, kind)
    rock.kind = kind
    rock.phase = "float"
    rock.tex:SetTexture(PickRockTexture(math.random(1, #ROCK_TEX_POOL)))

    if kind == "small" then
        rock.size = rand(10, 20) * 0.60
    elseif kind == "medium" then
        rock.size = rand(20, 30) * 0.60
    else
        rock.size = rand(30, 42) * 0.60
    end

    rock.xFrac = rand(0.04, 0.96)
    rock.revealAt = rand(0.03, 0.92)
    rock.side = (math.random(2) == 1) and -1 or 1  -- haut/bas, proche du niveau de barre
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
    rock.vx = 0
    rock.vy = 0
    rock.x = 0
    rock.y = 0

    rock.tex:SetSize(rock.size, rock.size)
    rock.tex:SetAlpha(0)
    SetTextureRotation(rock.tex, rock.rot)
end

local function UpdateMist(m, dt, alphaMul)
    m.t = m.t + dt
    local pulse = 0.5 + 0.5 * math.sin(m.t * m.speed + m.seed)
    local alpha = (0.10 + pulse * 0.20) * (alphaMul or 1)
    local scale = 0.90 + 0.16 * math.sin(m.t * 0.65 + m.seed)
    local f = SCB.Bar.frameInner
    local cx, cy = f:GetCenter()
    if not cx then return end
    local bw = f:GetWidth()
    local x = cx - bw * 0.5 + bw * m.xFrac
    m.rot = m.rot + m.rotSpeed * dt
    m.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, cy + m.yOff)
    m.tex:SetSize(MIST_W * scale, MIST_H * scale)
    SetTextureRotation(m.tex, m.rot)
    m.tex:SetAlpha(alpha)
end

local function UpdateFloatingRock(rock, dt, progress, fillLX, fillW)
    rock.floatT = rock.floatT + dt * rock.floatSpeed
    rock.rot = rock.rot + rock.rotSpeed * dt
    rock.riseOffset = rock.riseOffset + rock.riseSpeed * dt

    local appear = math.min(1, math.max(0, (progress - rock.revealAt) / 0.16))
    local alpha = rock.maxAlpha * appear

    -- X fixé aléatoirement le long de la barre (plus de glissement vers la droite)
    local x = fillLX + fillW * rock.xFrac + math.sin(rock.floatT * 0.7 + rock.seed) * 3

    -- Y : position proche de la barre + montée lente continue
    local f = SCB.Bar.frameInner
    local _, cy = f:GetCenter()
    local halfH = f:GetHeight() * 0.5
    local edgeBias = halfH * 0.30
    local y = (cy or 0)
        + rock.side * (edgeBias + rock.yOuter)
        + rock.yBase
        + math.sin(rock.floatT) * rock.floatAmp
        + rock.riseOffset
        + 15

    rock.x, rock.y = x, y
    rock.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    rock.tex:SetAlpha(alpha)

    local scale = 0.90 + 0.18 * (0.5 + 0.5 * math.sin(rock.floatT * 0.9 + rock.seed))
    rock.tex:SetSize(rock.size * scale, rock.size * scale)
    SetTextureRotation(rock.tex, rock.rot)
end

local function StartFallingRocks()
    local function toFall(r)
        if (r.phase == "float" or r.phase == "orbit") and r.tex:GetAlpha() > 0.02 then
            r.phase = "fall"
            r.vx = rand(-18, 18)
            r.vy = rand(18, 52)
        else
            r.phase = "idle"
            r.tex:SetAlpha(0)
        end
    end

    for _, r in ipairs(rocks) do toFall(r) end
    for _, r in ipairs(orbitRocks) do toFall(r) end
end

local function UpdateFallingRock(rock, dt, alphaMul)
    if rock.phase ~= "fall" then return end
    rock.vy = rock.vy - FALL_GRAVITY * dt
    rock.x  = rock.x + rock.vx * dt
    rock.y  = rock.y + rock.vy * dt
    rock.rot = rock.rot + rock.rotSpeed * dt * 1.8

    rock.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", rock.x, rock.y)
    rock.tex:SetAlpha((alphaMul or 1) * rock.maxAlpha)
    SetTextureRotation(rock.tex, rock.rot)
end

function FX.Init(container, bar)
    for i = 1, MIST_COUNT do
        local t = bar:CreateTexture(nil, "BACKGROUND", nil, -2)
        t:SetTexture(TEX_FROST .. "Mist_Frost_01")
        t:SetBlendMode("ADD")
        t:SetSize(MIST_W, MIST_H)
        t:SetAlpha(0)
        mists[i] = {
            tex = t, xFrac = MIST_POS[i], yOff = rand(-6, 6),
            t = rand(0, 7), speed = rand(0.7, 1.3), seed = rand(0, 7),
            rot = rand(0, math.pi * 2), rotSpeed = rand(-0.06, 0.06),
        }
    end

    local function allocRocks(count, kind)
        for _ = 1, count do
            local t = bar:CreateTexture(nil, "BACKGROUND", nil, -4)
            -- Transparence normale: mode par défaut (sans blend mode forcé).
            t:SetAlpha(0)
            local r = { tex = t, phase = "idle" }
            SetupRock(r, kind)
            rocks[#rocks + 1] = r
        end
    end

    allocRocks(ROCK_SMALL_COUNT, "small")
    allocRocks(ROCK_MEDIUM_COUNT, "medium")
    allocRocks(ROCK_BIG_COUNT, "big")

    for _ = 1, ORBIT_MISC_COUNT do
        local t = bar:CreateTexture(nil, "BACKGROUND", nil, -5)
        t:SetAlpha(0)
        local r = { tex = t, phase = "idle" }
        SetupOrbitRock(r)
        orbitRocks[#orbitRocks + 1] = r
    end

    for i = 1, FRONT_PART_COUNT do
        local t = container:CreateTexture(nil, "OVERLAY")
        t:SetTexture(FRONT_TEX[(i % 2) + 1])
        t:SetBlendMode("ADD")
        t:SetAlpha(0)
        frontParts[i] = { tex=t, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0 }
    end
end

function FX.Start(duration)
    active = true
    fading = false
    fadeT = 0
    spawnAcc = 0

    for i, m in ipairs(mists) do
        m.t = i * 0.25
        m.tex:SetAlpha(0)
    end

    for _, r in ipairs(rocks) do
        SetupRock(r, r.kind)
    end
    for _, r in ipairs(orbitRocks) do
        SetupOrbitRock(r)
    end

    for _, p in ipairs(frontParts) do
        p.active = false
        p.tex:SetAlpha(0)
    end
end

function FX.Stop()
    active = false
    fading = true
    fadeT = 0
    StartFallingRocks()
end

function FX.Reset()
    active = false
    fading = false
    for _, m in ipairs(mists) do m.tex:SetAlpha(0) end
    for _, r in ipairs(rocks) do r.phase = "idle" ; r.tex:SetAlpha(0) end
    for _, r in ipairs(orbitRocks) do r.phase = "idle" ; r.tex:SetAlpha(0) end
    for _, p in ipairs(frontParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.UpdateFade(dt)
    if not fading then return end
    fadeT = fadeT + dt
    local fade = math.max(0, 1 - fadeT / FX_FADE_DUR)

    for _, m in ipairs(mists) do UpdateMist(m, dt, fade) end
    for _, r in ipairs(rocks) do UpdateFallingRock(r, dt, fade) end
    for _, r in ipairs(orbitRocks) do UpdateFallingRock(r, dt, fade) end
    for _, p in ipairs(frontParts) do UpdateFrontParticle(p, dt, fade) end

    if fadeT >= FX_FADE_DUR then
        fading = false
        for _, m in ipairs(mists) do m.tex:SetAlpha(0) end
        for _, r in ipairs(rocks) do r.phase = "idle" ; r.tex:SetAlpha(0) end
        for _, r in ipairs(orbitRocks) do r.phase = "idle" ; r.tex:SetAlpha(0) end
        for _, p in ipairs(frontParts) do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    for _, m in ipairs(mists) do UpdateMist(m, dt, 1) end

    for _, p in ipairs(frontParts) do UpdateFrontParticle(p, dt, 1) end

    if not active then return end

    for _, r in ipairs(rocks) do
        if r.phase == "float" then
            UpdateFloatingRock(r, dt, progress, fillLX, fillW)
        end
    end
    for _, r in ipairs(orbitRocks) do
        if r.phase == "orbit" then
            UpdateOrbitRock(r, dt, 1)
        end
    end

    spawnAcc = spawnAcc + dt
    if progress > 0.02 and progress < 0.985 and spawnAcc >= FRONT_SPAWN_RATE then
        spawnAcc = 0
        local n = math.random(1, 3)
        for _ = 1, n do SpawnFront(frontX, cy) end
    end
end
