-- ============================================================
--  Sleek Casting Bars — Particles_Shadow.lua
--  Effets visuels pour l'école Shadow :
--
--  · Flames  — 5 textures Flame_Shadow cyclées sur les slots
--              texContoursFire (même logique que Fire)
--  · Circles — deux cercles Circle_Shadow aux extrémités
--              de la barre, rotation + légère pulsation scale
-- ============================================================

local FX = {}
SCB.FX        = SCB.FX or {}
SCB.FX["shadow"] = FX

local function rand(a, b) return a + math.random() * (b - a) end

local function SetTextureRotation(tex, angle)
    local c, s = math.cos(angle), math.sin(angle)
    tex:SetTexCoord(
        0.5 + (-0.5)*c - (-0.5)*s,  0.5 + (-0.5)*s + (-0.5)*c,
        0.5 + (-0.5)*c - ( 0.5)*s,  0.5 + (-0.5)*s + ( 0.5)*c,
        0.5 + ( 0.5)*c - (-0.5)*s,  0.5 + ( 0.5)*s + (-0.5)*c,
        0.5 + ( 0.5)*c - ( 0.5)*s,  0.5 + ( 0.5)*s + ( 0.5)*c
    )
end

-- ============================================================
--  CONSTANTES FLAMES
-- ============================================================

local SHADOW_CONTOUR_BASE  = { 1, 2, 3, 4, 5 }
local SHADOW_SLOT_CYCLE    = 0.65
local SHADOW_SLOT_FADE     = 0.13
local SHADOW_SLOT_COUNT    = 3
local SHADOW_GHOST_COUNT   = 2
local SHADOW_GHOST_ALPHA   = 0.5 * 0.40  -- ghost = 50% de 40%
local SHADOW_MAX_ALPHA     = 0.40         -- opacité max des slots principaux

local SHADOW_BONUS_IDX      = 1
local SHADOW_BONUS_HOLD_MIN = 1.5
local SHADOW_BONUS_HOLD_MAX = 3.5
local SHADOW_BONUS_FADE     = 0.35
local SHADOW_BONUS_GAP_MIN  = 2.0
local SHADOW_BONUS_GAP_MAX  = 5.0

-- ============================================================
--  CONSTANTES CERCLES
-- ============================================================

local CIRCLE_SIZE_START  = 18
local CIRCLE_SIZE_MAX    = 60
local CIRCLE_ROT_SPEED   = 1.6   -- rad/s horaire
local CIRCLE_PULSE_SPEED = 2.0
local CIRCLE_PULSE_AMP   = 0.07
local CIRCLE_ALPHA       = 0.95
local CIRCLE_OFFSET_Y    = 7    -- -1px
local CIRCLE_OFFSET_X    = -49  -- cercles vers l'intérieur

-- ============================================================
--  CONSTANTES PARTICULES ORBITE (trou noir)
-- ============================================================

local ORB_PER_CIRCLE    = 20     -- particules par cercle
local ORB_R_MIN         = 22     -- rayon spawn min (px)
local ORB_R_MAX         = 48     -- rayon spawn max (px)
local ORB_INFALL_SPEED  = 20     -- px/s vers le centre
local ORB_ORBIT_SPEED   = 2.6    -- rad/s angulaire
local ORB_SPAWN_RATE    = 0.09   -- s entre spawns par cercle
local ORB_ALPHA         = 0.90
local ORB_SIZE_MIN      = 4
local ORB_SIZE_MAX      = 9

-- ============================================================
--  CONSTANTES PARTICULES FRONT
-- ============================================================

local PART_COUNT      = 50
local PART_SPAWN_RATE = 0.035
local PART_STOP_AT    = 0.87
local PART_ALPHA      = 1.0
-- Teinte violet sombre identique aux Flames
local PART_R, PART_G, PART_B = 0.35, 0.15, 0.45

-- ============================================================
--  CONSTANTES CENDRES (depuis les flames)
-- ============================================================

local ASH_COUNT      = 60
local ASH_SPAWN_RATE = 0.05
local ASH_ALPHA      = 0.95
local ASH_SIZE_MIN   = 3
local ASH_SIZE_MAX   = 8

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local shadowSlots  = {}
local shadowBonus  = { phase = "wait", timer = 0, duration = 0 }
local circles      = {}
local orbPools     = { {}, {} }   -- pool de particules par cercle
local orbSpawnAccs = { 0, 0 }
local parts        = {}
local ashes        = {}
local spawnAcc     = 0
local ashSpawnAcc  = 0
local castDuration = 5
local circlesFading   = false
local circlesFadeT    = 0
local CIRCLE_FADE_DUR = 0.55
local circlesLastProg = 0

-- ============================================================
--  FLAMES
-- ============================================================

-- Scratch reused every frame (avoids GC churn)
local shadowAlphas = {}

local function UpdateShadowFlames(dt)
    local bar = SCB.Bar
    if not bar.texContoursFire then return end

    local alphas = shadowAlphas
    for i = 1, #bar.texContoursFire do alphas[i] = 0 end

    for _, slot in ipairs(shadowSlots) do
        slot.timer = slot.timer + dt
        if slot.timer >= SHADOW_SLOT_CYCLE then
            slot.timer   = slot.timer - SHADOW_SLOT_CYCLE
            slot.basePos = (slot.basePos % #SHADOW_CONTOUR_BASE) + 1
        end
        local t     = slot.timer / SHADOW_SLOT_CYCLE
        local fadeT = SHADOW_SLOT_FADE / SHADOW_SLOT_CYCLE
        local alpha
        if t < fadeT then
            alpha = t / fadeT
        elseif t < 1 - fadeT then
            alpha = 1
        else
            alpha = (1 - t) / fadeT
        end
        local maxAlpha = slot.isGhost and SHADOW_GHOST_ALPHA or SHADOW_MAX_ALPHA
        local texIdx   = SHADOW_CONTOUR_BASE[slot.basePos]
        alphas[texIdx] = math.max(alphas[texIdx], math.max(0, alpha) * maxAlpha)
    end

    -- Bonus
    shadowBonus.timer = shadowBonus.timer + dt
    if shadowBonus.phase == "wait" then
        if shadowBonus.timer >= shadowBonus.duration then
            shadowBonus.phase    = "fadein"
            shadowBonus.timer    = 0
            shadowBonus.duration = rand(SHADOW_BONUS_HOLD_MIN, SHADOW_BONUS_HOLD_MAX)
        end
    elseif shadowBonus.phase == "fadein" then
        local a = math.min(shadowBonus.timer / SHADOW_BONUS_FADE, 1) * SHADOW_MAX_ALPHA
        alphas[SHADOW_BONUS_IDX] = math.max(alphas[SHADOW_BONUS_IDX], a)
        if shadowBonus.timer >= SHADOW_BONUS_FADE then
            shadowBonus.phase = "hold" ; shadowBonus.timer = 0
        end
    elseif shadowBonus.phase == "hold" then
        alphas[SHADOW_BONUS_IDX] = math.max(alphas[SHADOW_BONUS_IDX], SHADOW_MAX_ALPHA)
        if shadowBonus.timer >= shadowBonus.duration then
            shadowBonus.phase = "fadeout" ; shadowBonus.timer = 0
        end
    elseif shadowBonus.phase == "fadeout" then
        local a = math.max(0, 1 - shadowBonus.timer / SHADOW_BONUS_FADE) * SHADOW_MAX_ALPHA
        alphas[SHADOW_BONUS_IDX] = math.max(alphas[SHADOW_BONUS_IDX], a)
        if shadowBonus.timer >= SHADOW_BONUS_FADE then
            shadowBonus.phase    = "wait"
            shadowBonus.timer    = 0
            shadowBonus.duration = rand(SHADOW_BONUS_GAP_MIN, SHADOW_BONUS_GAP_MAX)
        end
    end

    -- Teinte sombre violette appliquée sur chaque slot
    local r, g, b = 0.35, 0.15, 0.45
    for i, t in ipairs(bar.texContoursFire) do
        local a = alphas[i] or 0
        if a > 0 then t:SetAlpha(a) ; t:Show() else t:Hide() end
        t:SetVertexColor(r, g, b)
    end
end

local function ResetShadowFlames()
    local bar = SCB.Bar
    if bar.texContoursFire then
        for _, t in ipairs(bar.texContoursFire) do t:Hide() end
    end
    local gi = 0
    for s, slot in ipairs(shadowSlots) do
        if slot.isGhost then
            gi = gi + 1
            slot.timer   = (gi - 0.5) * (SHADOW_SLOT_CYCLE / SHADOW_SLOT_COUNT)
            slot.basePos = (gi + 1) % #SHADOW_CONTOUR_BASE + 1
        else
            slot.timer   = (s - 1) * (SHADOW_SLOT_CYCLE / SHADOW_SLOT_COUNT)
            slot.basePos = s
        end
    end
    shadowBonus.phase    = "wait"
    shadowBonus.timer    = 0
    shadowBonus.duration = rand(SHADOW_BONUS_GAP_MIN, SHADOW_BONUS_GAP_MAX)
end

-- ============================================================
--  PARTICULES FRONT
-- ============================================================

local function SpawnParticle(frontX, cy)
    for _, p in ipairs(parts) do
        if not p.active then
            local angle = math.rad(rand(50, 130))
            local speed = rand(40, 110)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(0.4, 0.9)
            p.x       = frontX + rand(-3, 3)
            p.y       = cy + rand(-8, 8)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            local size = rand(6, 14)
            p.tex:SetSize(size, size)
            p.tex:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
            p.tex:SetVertexColor(PART_R, PART_G, PART_B)
            p.tex:SetAlpha(PART_ALPHA)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            return
        end
    end
end

local function UpdateParticle(p, dt)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end

    p.vy = p.vy - 120 * dt
    p.x  = p.x  + p.vx * dt
    p.y  = p.y  + p.vy * dt
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)

    local alpha = t < 0.6 and 1 or math.max(0, (1 - t) / 0.4)
    p.tex:SetAlpha(alpha * PART_ALPHA)
end

local function SpawnAsh(barLX, barRX, barCY, barH)
    for _, a in ipairs(ashes) do
        if not a.active then
            -- Spawn distribué sur toute la largeur, aux bords haut/bas de la barre
            local x    = rand(barLX, barRX)
            local edge = (math.random(2) == 1) and 1 or -1  -- haut ou bas
            local y    = barCY + edge * (barH * 0.5) * rand(0.3, 0.9)

            -- Vélocité : légèrement vers le haut, dérive latérale aléatoire
            local vx = rand(-18, 18)
            local vy = rand(12, 35)

            a.active  = true
            a.life    = 0
            a.maxLife = rand(0.8, 2.2)
            a.x, a.y  = x, y
            a.vx, a.vy = vx, vy
            a.drift   = rand(-8, 8)   -- oscillation sinusoïdale
            a.phase   = rand(0, math.pi * 2)

            local size = rand(ASH_SIZE_MIN, ASH_SIZE_MAX)
            a.tex:SetSize(size, size)
            a.tex:SetVertexColor(PART_R, PART_G, PART_B)
            a.tex:SetAlpha(ASH_ALPHA)
            a.tex:ClearAllPoints()
            a.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
            return
        end
    end
end

local function UpdateAsh(a, dt)
    if not a.active then return end
    a.life = a.life + dt
    local t = a.life / a.maxLife
    if t >= 1 then a.active = false ; a.tex:SetAlpha(0) ; return end

    -- Légère gravité inverse (cendres qui montent et dériveni)
    a.vy = a.vy - 4 * dt   -- très légère gravité
    a.x  = a.x + a.vx * dt + math.sin(a.life * 2.5 + a.phase) * a.drift * dt
    a.y  = a.y + a.vy * dt
    a.tex:ClearAllPoints()
    a.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", a.x, a.y)

    -- Fade in sur 15%, fade out sur le dernier 35%
    local alpha
    if t < 0.15 then
        alpha = t / 0.15
    elseif t < 0.65 then
        alpha = 1
    else
        alpha = math.max(0, (1 - t) / 0.35)
    end
    a.tex:SetAlpha(alpha * ASH_ALPHA)
end

-- ============================================================
--  PARTICULES ORBITE (trou noir)
-- ============================================================

local function SpawnOrb(pool, cx, cy)
    for _, o in ipairs(pool) do
        if not o.active then
            local angle = math.random() * math.pi * 2
            local r     = rand(ORB_R_MIN, ORB_R_MAX)
            o.active  = true
            o.r       = r
            o.angle   = angle
            o.life    = 0
            o.maxLife = r / ORB_INFALL_SPEED
            local size = rand(ORB_SIZE_MIN, ORB_SIZE_MAX)
            o.tex:SetSize(size, size)
            o.tex:SetVertexColor(PART_R, PART_G, PART_B)
            o.tex:SetAlpha(ORB_ALPHA)
            o.tex:ClearAllPoints()
            o.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
                cx + math.cos(angle) * r, cy + math.sin(angle) * r)
            return
        end
    end
end

local function UpdateOrb(o, dt, cx, cy)
    if not o.active then return end
    o.life  = o.life + dt

    -- Accélération angulaire au fur et à mesure que r diminue
    local omega = ORB_ORBIT_SPEED * (ORB_R_MIN / math.max(o.r, 4))
    o.angle = o.angle + omega * dt
    o.r     = o.r - ORB_INFALL_SPEED * dt

    if o.r <= 2 then
        o.active = false
        o.tex:SetAlpha(0)
        return
    end

    local x = cx + math.cos(o.angle) * o.r
    local y = cy + math.sin(o.angle) * o.r
    o.tex:ClearAllPoints()
    o.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)

    -- Fade sur le dernier 30% de vie
    local t = o.life / o.maxLife
    local alpha = t > 0.7 and math.max(0, (1 - t) / 0.3) or 1
    o.tex:SetAlpha(alpha * ORB_ALPHA)
end

-- ============================================================
--  CERCLES
-- ============================================================

local function UpdateCircles(dt, progress, barLX, barRX, barCY)
    local posX = { barLX - CIRCLE_OFFSET_X, barRX + CIRCLE_OFFSET_X }

    local currentProg, currentAlpha

    if circlesFading then
        circlesFadeT = circlesFadeT + dt
        local t = math.min(circlesFadeT / CIRCLE_FADE_DUR, 1)
        -- Alpha : linéaire de 1 → 0
        currentAlpha = CIRCLE_ALPHA * (1 - t)
        -- Scale : redescend de lastProg → 0 (même courbe que le fade in)
        currentProg  = circlesLastProg * (1 - t)
        if t >= 1 then
            circlesFading = false
            for _, c in ipairs(circles) do c.tex:SetAlpha(0) end
            return
        end
    else
        circlesLastProg = progress
        currentProg  = progress
        currentAlpha = math.max(0, CIRCLE_ALPHA * math.min(progress * 6, 1))
    end

    for i, c in ipairs(circles) do
        c.angle  = c.angle  - CIRCLE_ROT_SPEED * dt
        c.pulseT = c.pulseT + dt

        local size  = CIRCLE_SIZE_START + (CIRCLE_SIZE_MAX - CIRCLE_SIZE_START) * currentProg
        local pulse = 1 + math.sin(c.pulseT * CIRCLE_PULSE_SPEED) * CIRCLE_PULSE_AMP
        c.tex:SetSize(size * pulse, size * pulse)
        SetTextureRotation(c.tex, c.angle)
        c.tex:SetAlpha(currentAlpha)
        c.tex:ClearAllPoints()
        c.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
            posX[i], barCY + CIRCLE_OFFSET_Y)
    end
end

local function ResetCircles()
    for _, c in ipairs(circles) do
        c.tex:SetAlpha(0)
        c.angle  = math.random() * math.pi * 2
        c.pulseT = math.random() * math.pi
    end
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["shadow"]
    if not school then return end

    -- Les textures Flame sont chargées par ApplySchool via school.contours
    -- On crée juste les slots ici

    shadowSlots = {}
    local gi = 0
    for s = 1, SHADOW_SLOT_COUNT + SHADOW_GHOST_COUNT do
        local isGhost = (s > SHADOW_SLOT_COUNT)
        if isGhost then gi = gi + 1 end
        shadowSlots[s] = {
            isGhost  = isGhost,
            timer    = isGhost
                and (gi - 0.5) * (SHADOW_SLOT_CYCLE / SHADOW_SLOT_COUNT)
                or  (s  - 1)  * (SHADOW_SLOT_CYCLE / SHADOW_SLOT_COUNT),
            basePos  = isGhost and ((gi + 1) % #SHADOW_CONTOUR_BASE + 1) or s,
        }
    end

    shadowBonus = {
        phase    = "wait",
        timer    = 0,
        duration = rand(SHADOW_BONUS_GAP_MIN, SHADOW_BONUS_GAP_MAX),
    }

    -- Textures Misc_Earth pour les particules
    local earthSchool = SCB.Schools.data["earth"]
    local miscTexs = {}
    if earthSchool then
        for _, t in ipairs(earthSchool.rocks   or {}) do miscTexs[#miscTexs+1] = t end
        for _, t in ipairs(earthSchool.debris  or {}) do miscTexs[#miscTexs+1] = t end
    end
    local function getMisc(i)
        if #miscTexs == 0 then return school.contours[1] end
        return miscTexs[((i-1) % #miscTexs) + 1]
    end

    -- Particules orbite trou noir
    orbPools = { {}, {} }
    for ci = 1, 2 do
        for i = 1, ORB_PER_CIRCLE do
            local tex = container:CreateTexture(nil, "OVERLAY")
            tex:SetTexture(getMisc(i))
            tex:SetBlendMode("ADD")
            tex:SetAlpha(0)
            orbPools[ci][i] = {
                tex = tex, active = false,
                r = 0, angle = 0, life = 0, maxLife = 0,
            }
        end
    end

    -- Particules front
    parts = {}
    for i = 1, PART_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getMisc(i))
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        parts[i] = {
            tex = tex, active = false,
            life = 0, maxLife = 0,
            x = 0, y = 0, vx = 0, vy = 0,
        }
    end

    -- Cendres depuis les flames
    ashes = {}
    for i = 1, ASH_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getMisc(i))
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        ashes[i] = {
            tex = tex, active = false,
            life = 0, maxLife = 0,
            x = 0, y = 0, vx = 0, vy = 0,
            drift = 0, phase = 0,
        }
    end
    for i = 1, 2 do
        local tex = bar:CreateTexture(nil, "OVERLAY", nil, 3)
        tex:SetTexture(school.circle)
        tex:SetBlendMode("BLEND")
        tex:SetSize(CIRCLE_SIZE_START, CIRCLE_SIZE_START)
        tex:SetAlpha(0)
        circles[i] = {
            tex    = tex,
            angle  = math.random() * math.pi * 2,
            pulseT = math.random() * math.pi,
        }
    end
end

function FX.Start(duration)
    castDuration    = duration or 5
    spawnAcc        = 0
    ashSpawnAcc     = 0
    orbSpawnAccs    = { 0, 0 }
    circlesFading   = false
    circlesFadeT    = 0
    circlesLastProg = 0
    ResetShadowFlames()
    ResetCircles()
    for _, p in ipairs(parts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, a in ipairs(ashes)  do a.active = false ; a.tex:SetAlpha(0) end
    for ci = 1, 2 do
        for _, o in ipairs(orbPools[ci]) do o.active = false ; o.tex:SetAlpha(0) end
    end
end

function FX.Stop()
    -- Déclencher le fade out des cercles (géré dans UpdateCircles)
    circlesFading = true
    circlesFadeT  = 0
    -- Stopper les particules immédiatement
    for _, p in ipairs(parts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, a in ipairs(ashes)  do a.active = false ; a.tex:SetAlpha(0) end
    for ci = 1, 2 do
        for _, o in ipairs(orbPools[ci]) do o.active = false ; o.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    -- Appelé après la fin du fade — on remet la VertexColor proprement
    if SCB.Bar.texContoursFire then
        for _, t in ipairs(SCB.Bar.texContoursFire) do
            t:Hide()
            t:SetVertexColor(1, 1, 1)
        end
    end
    for _, c in ipairs(circles) do c.tex:SetAlpha(0) end
    for _, p in ipairs(parts)  do p.active = false ; p.tex:SetAlpha(0) end
    for ci = 1, 2 do
        for _, o in ipairs(orbPools[ci]) do o.active = false ; o.tex:SetAlpha(0) end
    end
    for _, a in ipairs(ashes)  do a.active = false ; a.tex:SetAlpha(0) end
end

function FX.UpdateCirclesFade(dt)
    if not circlesFading then return end
    local f = SCB.Bar.frameInner
    local cx, barCY = f:GetCenter()
    if not cx then return end
    local barW = SCB.Bar.frame:GetWidth()
    local barLX = cx - barW * 0.5
    local barRX = cx + barW * 0.5
    UpdateCircles(dt, 0, barLX, barRX, barCY)
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    local f = SCB.Bar.frameInner
    local cx, barCY = f:GetCenter()
    if not cx then return end

    local barLX = cx - barW * 0.5
    local barRX = cx + barW * 0.5

    UpdateShadowFlames(dt)
    UpdateCircles(dt, progress, barLX, barRX, barCY)

    -- Particules front
    for _, p in ipairs(parts) do UpdateParticle(p, dt) end
    if progress < PART_STOP_AT then
        spawnAcc = spawnAcc + dt
        if spawnAcc >= PART_SPAWN_RATE then
            spawnAcc = 0
            SpawnParticle(frontX, barCY)
        end
    end

    -- Cendres depuis les flames
    for _, a in ipairs(ashes) do UpdateAsh(a, dt) end
    ashSpawnAcc = ashSpawnAcc + dt
    if ashSpawnAcc >= ASH_SPAWN_RATE then
        ashSpawnAcc = 0
        SpawnAsh(barLX, barRX, barCY, barH)
    end

    -- Particules orbite (trous noirs)
    local posX = { barLX - CIRCLE_OFFSET_X, barRX + CIRCLE_OFFSET_X }
    for ci = 1, 2 do
        local pcx = posX[ci]
        local pcy = barCY + CIRCLE_OFFSET_Y
        for _, o in ipairs(orbPools[ci]) do UpdateOrb(o, dt, pcx, pcy) end
        orbSpawnAccs[ci] = orbSpawnAccs[ci] + dt
        if orbSpawnAccs[ci] >= ORB_SPAWN_RATE then
            orbSpawnAccs[ci] = 0
            SpawnOrb(orbPools[ci], pcx, pcy)
        end
    end
end
