-- ============================================================
--  Opulent Casting Bars — Particles_Aim.lua
--
--  Thème Chasseur (Aim) — double fill symétrique vers le centre
--
--  Les deux fills avancent depuis leurs bords respectifs vers le centre.
--  Les positions des fronts avançants :
--    leftTipX  = fillLX + fillW*0.5*progress   (front gauche → droite)
--    rightTipX = fillLX + fillW*(1-0.5*progress) (front droit → gauche)
--
--  Effets :
--  · Feuilles flux     : traversent la barre de G à D (ambiance Nature)
--  · Glow rouge/orange : sur les deux fronts avançants
--  · Flashs rouges     : style Thunder sur les deux fronts (3 par côté)
--  · Particules front  : éjectées depuis chaque front, légèrement vers le haut
-- ============================================================

local FX = {}
SCB.FX          = SCB.FX or {}
SCB.FX["aim"]   = FX

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

-- Feuilles flux (ambiance Nature, traversent la barre G→D)
local LEAF_COUNT         = 30
local LEAF_SPAWN_RATE    = 0.13
local LEAF_SIZE_MIN      = 9
local LEAF_SIZE_MAX      = 20
local LEAF_ALPHA_MIN     = 0.40
local LEAF_ALPHA_MAX     = 0.75
local LEAF_ROT_MIN       = 0.8
local LEAF_ROT_MAX       = 2.8
local LEAF_WAVE_AMP_MIN  = 3
local LEAF_WAVE_AMP_MAX  = 9
local LEAF_WAVE_FREQ_MIN = 1.2
local LEAF_WAVE_FREQ_MAX = 2.8
local LEAF_VY_MIN        = -3
local LEAF_VY_MAX        =  3
local LEAF_SPEED_MIN     = 50
local LEAF_SPEED_MAX     = 110

-- Glow rouge/orange sur les deux fronts avançants
local GLOW_COUNT      = 70      -- pool total (35 par côté en pratique)
local GLOW_SPAWN_RATE = 0.024
local GLOW_STOP_AT    = 0.96
local GLOW_ALPHA      = 0.62
local GLOW_SIZE_MIN   = 5
local GLOW_SIZE_MAX   = 13
local GLOW_LIFE_MIN   = 0.15
local GLOW_LIFE_MAX   = 0.32
local GLOW_R, GLOW_G, GLOW_B = 1.0, 0.18, 0.05  -- rouge Aim

-- Particules front éjectées depuis chaque tip (comme Earth/Nature front)
local FRONT_COUNT      = 60      -- pool total (30 par côté)
local FRONT_SPAWN_RATE = 0.030
local FRONT_STOP_AT    = 0.96
local FRONT_SIZE_MIN   = 6
local FRONT_SIZE_MAX   = 14
local FRONT_ALPHA      = 0.78
local FRONT_SPEED_MIN  = 28
local FRONT_SPEED_MAX  = 75
local FRONT_GRAVITY    = 65
local FRONT_LIFE_MIN   = 0.28
local FRONT_LIFE_MAX   = 0.65

-- Flashs rouges style Thunder — 3 par côté = 6 au total
-- Cycle : pause → apparition instantanée → hold → fade → pause
local FLASH_PER_SIDE    = 3
local FLASH_HOLD_MIN    = 0.04
local FLASH_HOLD_MAX    = 0.10
local FLASH_FADE_MIN    = 0.12
local FLASH_FADE_MAX    = 0.28
local FLASH_PAUSE_MIN   = 0.20
local FLASH_PAUSE_MAX   = 0.80
local FLASH_OFFSET_X    = 18    -- dispersion X autour du tip (px)
local FLASH_ALPHA       = 0.92
local FLASH_SIZE_MIN    = 7
local FLASH_SIZE_MAX    = 16
local FLASH_R, FLASH_G, FLASH_B = 1.0, 0.12, 0.06

local FADE_DUR = 0.45

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local isActive      = false
local isFading      = false
local fadeT         = 0
local glowSpawnAcc  = 0
local leafSpawnAcc  = 0
local frontSpawnAcc = 0

local leaves      = {}
local frontParts  = {}
local glowParts   = {}
local flashPartsL = {}  -- 3 flashs sur le front gauche
local flashPartsR = {}  -- 3 flashs sur le front droit

-- ============================================================
--  FEUILLES FLUX (ambiance, G→D comme Nature)
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
--  PARTICULES FRONT (éjectées depuis un tip vers le haut)
--  sideSign : +1 = éjectées depuis tip gauche (arc vers le haut-gauche)
--             -1 = éjectées depuis tip droit  (arc vers le haut-droit)
-- ============================================================

local function SpawnFrontPart(pool, tipX, barCY, barH, sideSign)
    for _, lf in ipairs(pool) do
        if not lf.active then
            -- Arc centré vers le haut, légèrement du côté opposé au fill
            -- Tip gauche (sideSign=+1) : arc 60°-120° (vers le haut, éventail)
            -- Tip droit  (sideSign=-1) : arc 60°-120° miroir
            local baseDeg  = sideSign > 0 and 60 or 60
            local spreadDeg = 60
            local angleDeg = baseDeg + rand(0, spreadDeg)
            local angle    = math.rad(angleDeg)
            -- Miroir pour le côté droit : cos négatif
            local vx = math.cos(angle) * rand(FRONT_SPEED_MIN, FRONT_SPEED_MAX) * (-sideSign)
            local vy = math.sin(angle) * rand(FRONT_SPEED_MIN, FRONT_SPEED_MAX)
            local size     = rand(FRONT_SIZE_MIN, FRONT_SIZE_MAX)
            local rotSpeed = rand(LEAF_ROT_MIN, LEAF_ROT_MAX)
                             * (math.random(2) == 1 and 1 or -1)
            lf.active   = true
            lf.life     = 0
            lf.maxLife  = rand(FRONT_LIFE_MIN, FRONT_LIFE_MAX)
            lf.x        = tipX  + rand(-3, 3)
            lf.y        = barCY + rand(-barH * 0.25, barH * 0.25)
            lf.vx       = vx
            lf.vy       = vy
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

local function UpdateFrontPart(lf, dt, globalFade)
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
--  GLOW SUR UN TIP
-- ============================================================

local function SpawnGlowAt(tipX, cy, barH)
    for _, p in ipairs(glowParts) do
        if not p.active then
            local spread = math.min(barH * 0.28, 12)
            p.active  = true
            p.life    = 0
            p.maxLife = rand(GLOW_LIFE_MIN, GLOW_LIFE_MAX)
            p.x       = tipX + rand(-5, 5)
            p.y       = cy   + rand(-spread, spread)
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
--  FLASHS ROUGES STYLE THUNDER (un pool par côté)
--  Chaque flash suit son tip respectif.
-- ============================================================

local function ResetFlash(fl)
    fl.phase    = "pause"
    fl.phaseT   = 0
    fl.pauseDur = rand(FLASH_PAUSE_MIN, FLASH_PAUSE_MAX)
    fl.tex:SetAlpha(0)
end

local function UpdateFlash(fl, dt, tipX, cy, barH, gf)
    fl.phaseT = fl.phaseT + dt

    if fl.phase == "pause" then
        if fl.phaseT >= fl.pauseDur then
            fl.phase   = "hold"
            fl.phaseT  = 0
            fl.holdDur = rand(FLASH_HOLD_MIN, FLASH_HOLD_MAX)
            fl.fadeDur = rand(FLASH_FADE_MIN, FLASH_FADE_MAX)
            -- Position : tip ± dispersion aléatoire
            fl.cx      = tipX + rand(-FLASH_OFFSET_X, FLASH_OFFSET_X)
            fl.cy      = cy
            local size = rand(FLASH_SIZE_MIN, FLASH_SIZE_MAX)
            fl.tex:SetSize(size, size)
            fl.tex:ClearAllPoints()
            fl.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", fl.cx, fl.cy)
            fl.tex:SetAlpha(FLASH_ALPHA * (gf or 1))
        end

    elseif fl.phase == "hold" then
        fl.tex:ClearAllPoints()
        fl.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", fl.cx, fl.cy)
        if fl.phaseT >= fl.holdDur then
            fl.phase  = "fade"
            fl.phaseT = 0
        end

    elseif fl.phase == "fade" then
        local t = math.min(fl.phaseT / fl.fadeDur, 1)
        fl.tex:SetAlpha((1 - t) * FLASH_ALPHA * (gf or 1))
        fl.tex:ClearAllPoints()
        fl.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", fl.cx, fl.cy)
        if t >= 1 then
            fl.tex:SetAlpha(0)
            ResetFlash(fl)
        end
    end
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school   = SCB.Schools.data["aim"]
    local leafTexs = (school and school.leaves) or {}
    local miscTexs = (school and school.misc)   or {}

    -- Pool mixé : feuilles (×3) + Misc_Skinning entrelacés
    local allTexs = {}
    for i = 1, #leafTexs do allTexs[#allTexs+1] = leafTexs[i] end
    for i = 1, #leafTexs do allTexs[#allTexs+1] = leafTexs[i] end
    for i = 1, #leafTexs do allTexs[#allTexs+1] = leafTexs[i] end
    for i = 1, #miscTexs do allTexs[#allTexs+1] = miscTexs[i] end
    local nAll = #allTexs

    -- Feuilles flux
    leaves = {}
    for i = 1, LEAF_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nAll > 0 then tex:SetTexture(allTexs[((i-1) % nAll) + 1]) end
        tex:SetBlendMode("BLEND") ; tex:SetAlpha(0)
        leaves[i] = { tex=tex, active=false, x=0, y=0, baseY=0,
                      vx=0, vy=0, waveAmp=0, waveFreq=0, wavePhase=0,
                      rot=0, rotSpeed=0, life=0, maxAlpha=0, size=0, deadX=0 }
    end

    -- Particules front (pool partagé, moitié gauche / moitié droite)
    frontParts = {}
    for i = 1, FRONT_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        if nAll > 0 then tex:SetTexture(allTexs[((i-1) % nAll) + 1]) end
        tex:SetBlendMode("BLEND") ; tex:SetAlpha(0)
        frontParts[i] = { tex=tex, active=false, x=0, y=0,
                          vx=0, vy=0, rot=0, rotSpeed=0, life=0, maxLife=0, size=0 }
    end

    -- Glow rouge/orange (pool partagé gauche + droite)
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

    -- Flashs rouges style Thunder — 3 sur le front gauche
    flashPartsL = {}
    local flashTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    for i = 1, FLASH_PER_SIDE do
        local tex = container:CreateTexture(nil, "OVERLAY", nil, 7)
        tex:SetTexture(flashTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(FLASH_R, FLASH_G, FLASH_B)
        tex:SetAlpha(0)
        flashPartsL[i] = {
            tex=tex, phase="pause", phaseT=0,
            -- Décalage initial pour éviter que tous flashent en même temps
            pauseDur = rand(0, FLASH_PAUSE_MAX) * (i / FLASH_PER_SIDE),
            holdDur=0, fadeDur=0, cx=0, cy=0,
        }
    end

    -- Flashs rouges style Thunder — 3 sur le front droit
    flashPartsR = {}
    for i = 1, FLASH_PER_SIDE do
        local tex = container:CreateTexture(nil, "OVERLAY", nil, 7)
        tex:SetTexture(flashTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(FLASH_R, FLASH_G, FLASH_B)
        tex:SetAlpha(0)
        flashPartsR[i] = {
            tex=tex, phase="pause", phaseT=0,
            pauseDur = rand(0, FLASH_PAUSE_MAX) * (i / FLASH_PER_SIDE),
            holdDur=0, fadeDur=0, cx=0, cy=0,
        }
    end
end

function FX.Start(duration)
    isActive      = true
    isFading      = false
    fadeT         = 0
    leafSpawnAcc  = 0
    frontSpawnAcc = 0
    glowSpawnAcc  = 0

    for _, lf in ipairs(leaves)     do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, lf in ipairs(frontParts) do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, p  in ipairs(glowParts)  do p.active  = false ; p.tex:SetAlpha(0)  end
    for i, fl in ipairs(flashPartsL) do
        fl.phase    = "pause"
        fl.phaseT   = 0
        fl.pauseDur = rand(0, FLASH_PAUSE_MAX) * (i / FLASH_PER_SIDE)
        fl.tex:SetAlpha(0)
    end
    for i, fl in ipairs(flashPartsR) do
        fl.phase    = "pause"
        fl.phaseT   = 0
        fl.pauseDur = rand(0, FLASH_PAUSE_MAX) * (i / FLASH_PER_SIDE)
        fl.tex:SetAlpha(0)
    end
end

function FX.Stop()
    isActive      = false
    isFading      = true
    fadeT         = 0
    leafSpawnAcc  = 0
    frontSpawnAcc = 0
    glowSpawnAcc  = 0
end

function FX.UpdateFade(dt)
    if not isFading then return end
    fadeT = fadeT + dt
    local gf = math.max(0, 1 - fadeT / FADE_DUR)

    for _, lf in ipairs(leaves)     do UpdateLeaf(lf, dt, gf)      end
    for _, lf in ipairs(frontParts) do UpdateFrontPart(lf, dt, gf) end
    for _, p  in ipairs(glowParts)  do UpdateGlow(p, dt, gf)       end
    for _, fl in ipairs(flashPartsL) do fl.tex:SetAlpha(0) end
    for _, fl in ipairs(flashPartsR) do fl.tex:SetAlpha(0) end

    if fadeT >= FADE_DUR then
        isFading = false
        for _, lf in ipairs(leaves)     do lf.active = false ; lf.tex:SetAlpha(0) end
        for _, lf in ipairs(frontParts) do lf.active = false ; lf.tex:SetAlpha(0) end
        for _, p  in ipairs(glowParts)  do p.active  = false ; p.tex:SetAlpha(0)  end
    end
end

function FX.Reset()
    isActive = false
    isFading = false
    for _, lf in ipairs(leaves)      do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, lf in ipairs(frontParts)  do lf.active = false ; lf.tex:SetAlpha(0) end
    for _, p  in ipairs(glowParts)   do p.active  = false ; p.tex:SetAlpha(0)  end
    for _, fl in ipairs(flashPartsL) do fl.tex:SetAlpha(0) end
    for _, fl in ipairs(flashPartsR) do fl.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    local f = SCB.Bar.frameInner
    local barCX, barCY = f:GetCenter()
    if not barCX then return end

    local barLX = barCX - barW * 0.5
    local barRX = barCX + barW * 0.5

    -- Positions des deux fronts avançants
    -- leftTip  : part de fillLX, avance vers fillLX + fillW/2 (centre)
    -- rightTip : part de fillLX+fillW, avance vers fillLX + fillW/2 (centre)
    local halfFillW  = fillW * 0.5
    local leftTipX   = fillLX + halfFillW * progress
    local rightTipX  = fillLX + fillW - halfFillW * progress

    -- ---- Feuilles flux (ambiance, G→D) --------------------------------
    for _, lf in ipairs(leaves) do UpdateLeaf(lf, dt, 1) end
    leafSpawnAcc = leafSpawnAcc + dt
    if leafSpawnAcc >= LEAF_SPAWN_RATE then
        leafSpawnAcc = 0
        SpawnLeaf(barLX, barRX, barCY, barH)
    end

    -- ---- Particules front sur les deux tips ----------------------------
    for _, lf in ipairs(frontParts) do UpdateFrontPart(lf, dt, 1) end
    if progress < FRONT_STOP_AT then
        frontSpawnAcc = frontSpawnAcc + dt
        if frontSpawnAcc >= FRONT_SPAWN_RATE then
            frontSpawnAcc = 0
            -- Un spawn sur le tip gauche, un sur le tip droit
            SpawnFrontPart(frontParts, leftTipX,  barCY, barH,  1)
            SpawnFrontPart(frontParts, rightTipX, barCY, barH, -1)
        end
    end

    -- ---- Glow rouge/orange sur les deux tips --------------------------
    for _, p in ipairs(glowParts) do UpdateGlow(p, dt, 1) end
    if progress < GLOW_STOP_AT then
        glowSpawnAcc = glowSpawnAcc + dt
        if glowSpawnAcc >= GLOW_SPAWN_RATE then
            glowSpawnAcc = 0
            -- Spawn en alternance G/D (ou simultané) pour les deux côtés
            local n = math.random(1, 3)
            for _ = 1, n do SpawnGlowAt(leftTipX,  barCY, barH) end
            for _ = 1, n do SpawnGlowAt(rightTipX, barCY, barH) end
        end
    end

    -- ---- Flashs rouges style Thunder sur les deux tips ----------------
    for _, fl in ipairs(flashPartsL) do
        UpdateFlash(fl, dt, leftTipX,  barCY, barH, 1)
    end
    for _, fl in ipairs(flashPartsR) do
        UpdateFlash(fl, dt, rightTipX, barCY, barH, 1)
    end
end
