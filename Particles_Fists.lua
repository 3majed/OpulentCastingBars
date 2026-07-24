-- ============================================================
--  Opulent Casting Bars — Particles_Fists.lua
--
--  · Light_Fists  : suit la progression (Frame_Fists_Light masqué)
--  · Fists        : poings Fists_01..04 + Fists_Small qui apparaissent
--                   le long de la barre de progression, en haut (normal)
--                   et en bas (miroir vertical), trajectoire dynamique
--                   dans le sens du poing, fade-out rapide style "coup"
--  · Glow/Embers  : animation bout-de-barre style Metal, couleur #67cde6
--  · Feuilles     : feuilles Nature recolorées #ffb7d5, moitié des effectifs
-- ============================================================

local FX = {}
SCB.FX          = SCB.FX or {}
SCB.FX["fists"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end
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

-- Couleur glow/embers : #67cde6
local GLOW_R, GLOW_G, GLOW_B = 103/255, 205/255, 230/255

-- Glow bout de barre (style Metal)
local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.02
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.55
local GLOW_SIZE_MIN   = 4
local GLOW_SIZE_MAX   = 9
local GLOW_LIFE_MIN   = 0.10
local GLOW_LIFE_MAX   = 0.20

-- Embers (style Metal)
local EMBER_COUNT = 60
local EMBER_SPAWN = 0.03

local emberTypes = {
    { sizeMin=8,  sizeMax=14, speedMin=25, speedMax=60,  lifeMin=0.8, lifeMax=1.6, gravity=8,  spread=140, driftX=0.4 },
    { sizeMin=4,  sizeMax=8,  speedMin=80, speedMax=160, lifeMin=0.3, lifeMax=0.7, gravity=15, spread=80,  driftX=0.0 },
    { sizeMin=6,  sizeMax=12, speedMin=40, speedMax=90,  lifeMin=0.6, lifeMax=1.2, gravity=20, spread=100, driftX=0.2 },
}

-- Poings
local FIST_COUNT      = 80
local FIST_SPAWN_RATE = 0.07
local FIST_SIZE_MIN   = 55
local FIST_SIZE_MAX   = 125
local FIST_ALPHA      = 0.90
local FIST_LIFE_MIN   = 0.30
local FIST_LIFE_MAX   = 0.65
local FIST_STOP_AT    = 0.95

-- Feuilles (moitié de Nature : 35 → 17)
local LEAF_COUNT         = 17
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

local FADE_DUR = 0.6

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local isActive      = false
local isFading      = false
local fadeT         = 0
local castDuration  = 5

local texLight      = nil
local maskLight     = nil

local glowParts     = {}
local glowSpawnAcc  = 0

local emberParts    = {}
local emberSpawnAcc = 0

local fistParts     = {}
local fistSpawnAcc  = 0

local leafParts     = {}
local leafSpawnAcc  = 0

-- ============================================================
--  GLOW (bout de barre, style Metal, couleur #67cde6)
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
--  EMBERS (style Metal, couleur #67cde6)
-- ============================================================

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

-- ============================================================
--  POINGS (FISTS)
--  · isTop = true  → poing normal (pointe haut-droite)
--                    trajectoire : droite + haut
--  · isTop = false → poing miroir vertical (pointe bas-droite)
--                    trajectoire : droite + bas
-- ============================================================

local function SetFistUV(tex, isTop)
    if isTop then
        -- Orientation normale
        tex:SetTexCoord(0, 1, 0, 1)
    else
        -- Miroir vertical : inverse haut et bas
        tex:SetTexCoord(0, 1, 1, 0)
    end
end

local function SpawnFist(frontX, cy, barH)
    for _, p in ipairs(fistParts) do
        if not p.active then
            local isTop = math.random(2) == 1
            local side  = isTop and 1 or -1
            local sz    = rand(FIST_SIZE_MIN, FIST_SIZE_MAX)
            -- Spawn concentré autour du bout de la barre (frontX)
            local spawnX = frontX + rand(-35, 10)
            -- Poings du bas : +15 px supplémentaires vers le haut (vers le centre)
            local extraUp = isTop and 0 or 15
            local spawnY  = cy + side * math.max(4, barH * 0.5 + rand(4, 12) - 60 - extraUp)
            -- Trajectoire dans la direction du poing :
            --   haut-droite pour le dessus, bas-droite pour le dessous
            local speed = rand(45, 95)
            local vx    = speed * rand(0.7, 1.0)      -- composante horizontale (droite)
            local vy    = side * speed * rand(0.4, 0.7) -- composante verticale (sens du poing)

            p.active  = true
            p.life    = 0
            p.maxLife = rand(FIST_LIFE_MIN, FIST_LIFE_MAX)
            p.x       = spawnX
            p.y       = spawnY
            p.vx      = vx
            p.vy      = vy
            p.isTop   = isTop
            p.tex:SetSize(sz, sz)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            SetFistUV(p.tex, isTop)
            return
        end
    end
end

local function UpdateFist(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt
    -- Décélération naturelle (comme un coup qui suit son élan)
    p.vx = p.vx * (1 - dt * 2.0)
    p.vy = p.vy * (1 - dt * 2.0)
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    -- Enveloppe : apparition très rapide (0.12), tenue, puis fondu progressif
    local env = t < 0.12 and (t / 0.12) or math.max(0, (1 - t) / 0.88)
    p.tex:SetAlpha(env * FIST_ALPHA * (gf or 1))
end

-- ============================================================
--  FEUILLES (style Nature, couleur #ffb7d5, moitié des effectifs)
-- ============================================================

local function SpawnLeaf(barLX, barRX, barCY, barH)
    for _, lf in ipairs(leafParts) do
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
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["fists"]
    if not school then return end
    local f = SCB.Bar.frameInner
    if not f then return end

    -- Frame_Fists_Light : suit la progression via masque (comme Moon)
    if school.light then
        texLight = f:CreateTexture(nil, "OVERLAY", nil, 6)
        texLight:SetTexture(school.light)
        texLight:SetBlendMode("ADD")
        texLight:SetAllPoints(f)
        maskLight = f:CreateMaskTexture()
        maskLight:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        maskLight:SetPoint("TOPLEFT",    f, "TOPLEFT")
        maskLight:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
        maskLight:SetWidth(1)
        texLight:AddMaskTexture(maskLight)
        texLight:SetAlpha(0)
    end

    -- Glow : Particle_Frost_01, couleur #67cde6
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

    -- Embers : textures Earth, couleur #67cde6
    local earthSchool = SCB.Schools.data["earth"]
    local miscTexs = {}
    if earthSchool then
        for _, t in ipairs(earthSchool.rocks  or {}) do miscTexs[#miscTexs+1] = t end
        for _, t in ipairs(earthSchool.debris or {}) do miscTexs[#miscTexs+1] = t end
    end
    local function getMisc(i)
        if #miscTexs == 0 then return glowTex end
        return miscTexs[((i-1) % #miscTexs) + 1]
    end

    emberParts = {}
    for i = 1, EMBER_COUNT do
        local typeIdx = ((i - 1) % 3) + 1
        local ptype   = emberTypes[typeIdx]
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(getMisc(i))
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(GLOW_R, GLOW_G, GLOW_B)
        tex:SetAlpha(0)
        emberParts[i] = {
            tex=tex, ptype=ptype, typeIdx=typeIdx,
            active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, drift=0,
        }
    end

    -- Poings : Fists_01..04 + Fists_Small
    local fistTexs = school.fists or {}
    local nFist = #fistTexs
    fistParts = {}
    for i = 1, FIST_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nFist > 0 then
            tex:SetTexture(fistTexs[((i-1) % nFist) + 1])
        end
        tex:SetBlendMode("BLEND")
        tex:SetAlpha(0)
        fistParts[i] = { tex=tex, active=false, life=0, maxLife=0,
                         x=0, y=0, vx=0, vy=0, isTop=true }
    end

    -- Feuilles Nature, couleur #ffb7d5, moitié des effectifs
    local leafTexs = school.leaves or {}
    local nLeafs   = #leafTexs
    leafParts = {}
    for i = 1, LEAF_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nLeafs > 0 then tex:SetTexture(leafTexs[((i-1) % nLeafs) + 1]) end
        tex:SetBlendMode("BLEND")
        tex:SetAlpha(0)
        leafParts[i] = { tex=tex, active=false, x=0, y=0, baseY=0,
                         vx=0, vy=0, waveAmp=0, waveFreq=0, wavePhase=0,
                         rot=0, rotSpeed=0, life=0, maxAlpha=0, size=0, deadX=0 }
    end
end

function FX.Start(duration)
    castDuration  = duration or 5
    isActive      = true
    isFading      = false
    fadeT         = 0
    glowSpawnAcc  = 0
    emberSpawnAcc = 0
    fistSpawnAcc  = 0
    leafSpawnAcc  = 0
    if texLight  then texLight:SetAlpha(1) end
    if maskLight then maskLight:SetWidth(1) end
    for _, p  in ipairs(glowParts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, p  in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p  in ipairs(fistParts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, lf in ipairs(leafParts)  do lf.active = false ; lf.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive      = false
    isFading      = true
    fadeT         = 0
    glowSpawnAcc  = 0
    emberSpawnAcc = 0
    fistSpawnAcc  = 0
    leafSpawnAcc  = 0
end

function FX.UpdateFade(dt)
    if not isFading then return end
    fadeT = fadeT + dt
    local gf = math.max(0, 1 - fadeT / FADE_DUR)
    if texLight then texLight:SetAlpha(gf) end
    for _, p  in ipairs(glowParts)  do UpdateGlow(p,   dt, gf) end
    for _, p  in ipairs(emberParts) do UpdateEmber(p,  dt, gf) end
    for _, p  in ipairs(fistParts)  do UpdateFist(p,   dt, gf) end
    for _, lf in ipairs(leafParts)  do UpdateLeaf(lf,  dt, gf) end
    if fadeT >= FADE_DUR then
        isFading = false
        if texLight then texLight:SetAlpha(0) end
        for _, p  in ipairs(glowParts)  do p.active = false ; p.tex:SetAlpha(0) end
        for _, p  in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
        for _, p  in ipairs(fistParts)  do p.active = false ; p.tex:SetAlpha(0) end
        for _, lf in ipairs(leafParts)  do lf.active = false ; lf.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    isActive = false ; isFading = false
    if texLight  then texLight:SetAlpha(0) end
    if maskLight then maskLight:SetWidth(1) end
    for _, p  in ipairs(glowParts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, p  in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p  in ipairs(fistParts)  do p.active = false ; p.tex:SetAlpha(0) end
    for _, lf in ipairs(leafParts)  do lf.active = false ; lf.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    local f = SCB.Bar.frameInner
    local cx, barCY = f:GetCenter()
    if not cx then return end

    -- Masque Frame_Fists_Light (révélé avec la progression comme Moon)
    if maskLight then
        local frameW = SCB.Bar.frame:GetWidth()
        maskLight:SetWidth(math.max(frameW * progress, 1))
    end

    -- Glow au bout du fill
    for _, p in ipairs(glowParts) do UpdateGlow(p, dt, 1) end
    if progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc + dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc = 0
            for _ = 1, math.random(2, 4) do SpawnGlow(frontX, barCY, barH) end
        end
    end

    -- Embers au bout du fill
    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, 1) end
    emberSpawnAcc = emberSpawnAcc + dt
    if emberSpawnAcc >= EMBER_SPAWN then
        emberSpawnAcc = 0
        for _ = 1, math.random(2, 4) do SpawnEmber(frontX, barCY) end
    end

    -- Poings le long de la zone de fill (haut et bas)
    for _, p in ipairs(fistParts) do UpdateFist(p, dt, 1) end
    if progress > 0.02 and progress < FIST_STOP_AT then
        fistSpawnAcc = fistSpawnAcc + dt
        if fistSpawnAcc >= FIST_SPAWN_RATE then
            fistSpawnAcc = 0
            for _ = 1, math.random(2, 4) do
                SpawnFist(frontX, barCY, barH)
            end
        end
    end

    -- Feuilles autour de la barre (en dehors)
    local barLX = cx - barW * 0.5
    local barRX = cx + barW * 0.5
    for _, lf in ipairs(leafParts) do UpdateLeaf(lf, dt, 1) end
    leafSpawnAcc = leafSpawnAcc + dt
    if leafSpawnAcc >= LEAF_SPAWN_RATE then
        leafSpawnAcc = 0
        SpawnLeaf(barLX, barRX, barCY, barH)
    end
end
