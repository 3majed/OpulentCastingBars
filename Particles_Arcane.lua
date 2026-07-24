-- ============================================================
--  Sleek Casting Bars — Particles_Arcane.lua
-- ============================================================

local FX = {}
SCB.FX           = SCB.FX or {}
SCB.FX["arcane"] = FX

local function rand(a, b) return a + math.random() * (b - a) end
local pi2 = math.pi * 2

-- ============================================================
--  CONSTANTES
-- ============================================================

-- Fill : ratio natif 2048x128 = 0.0625, scroll via UVs
local FILL_RATIO         = 128 / 2048
local FILL_SCROLL_SPEED  = 0.12   -- UV/s (fraction de texture par seconde)
local FILL_BASE_ALPHA    = 0.90
local FILL_MIRROR_ALPHA  = 0.45
local FILL_BOTH_ALPHA    = 0.30

-- Runes latérales
local RUNE_SIZE          = 141
local RUNE_ROT_SPEED     = 0.6
local RUNE_PULSE_SPEED   = 1.8
local RUNE_ALPHA_MIN     = 0.55
local RUNE_ALPHA_MAX     = 0.90
local RUNE_OFFSET_Y      = 8
local RUNE_OFFSET_X      = 28
local RUNE_GROW_END      = 0.35   -- scale up jusqu'à 35% de progression

-- Rune_Back
local RUNE_BACK_W        = 460
local RUNE_BACK_H        = 115
local RUNE_BACK_OFFSET_Y = 56
local RUNE_BACK_ALPHA    = 0.55
local RUNE_BACK_PULSE_SPEED = 1.4

-- Particules glow (identiques à Nature/Neutral)
local GLOW_COUNT      = 60
local GLOW_SPAWN_RATE = 0.02
local GLOW_STOP_AT    = 0.87
local GLOW_ALPHA      = 0.55
local GLOW_SIZE_MIN   = 6
local GLOW_SIZE_MAX   = 12
local GLOW_LIFE_MIN   = 0.18
local GLOW_LIFE_MAX   = 0.35
local GLOW_R, GLOW_G, GLOW_B = 0.55, 0.20, 1.0   -- violet arcane

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local isActive      = false
local scrollU       = 0
local runeTimer     = 0
local runeBackTimer = 0
local glowSpawnAcc  = 0

-- Swap des runes entre les casts
local rune01Tex     = nil   -- texture actuellement sur le slot gauche
local rune02Tex     = nil   -- texture actuellement sur le slot droit
local swapNext      = false -- true = les deux runes seront swapées au prochain cast

local texFillBar    = nil
local texFillA      = nil
local texFillB      = nil
local texFillC      = nil
local texRuneBack   = nil
local texRuneBack2  = nil
local texRune01     = nil
local texRune02     = nil
local glowParts     = {}

-- ============================================================
--  ROTATION
-- ============================================================

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
--  GLOW PARTICLES (style Neutral/Nature)
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
--  UPDATE FILL (scroll UV, parfaitement synchro avec Fill_Bar)
-- ============================================================

local function UpdateFill(dt)
    if not texFillA then return end

    -- u décroît → image se déplace G→D
    scrollU = (scrollU + FILL_SCROLL_SPEED * dt) % 1
    local u = 1 - scrollU   -- inverser pour G→D

    -- Couche A : normale G→D
    texFillA:SetTexCoord(u, 0,  u, 1,  u+1, 0,  u+1, 1)
    -- Couche B : miroir H
    texFillB:SetTexCoord(1-u, 0,  1-u, 1,  -u, 0,  -u, 1)
    -- Couche C : miroir HV
    texFillC:SetTexCoord(1-u, 1,  1-u, 0,  -u, 1,  -u, 0)

    -- Pulse Rune_Back
    if texRuneBack2 then
        runeBackTimer = runeBackTimer + dt
        local pulse = 0.5 + 0.5 * math.sin(runeBackTimer * RUNE_BACK_PULSE_SPEED)
        texRuneBack2:SetAlpha(pulse * RUNE_BACK_ALPHA)
    end
end

-- ============================================================
--  UPDATE RUNES
-- ============================================================

local function UpdateRunes(dt, progress, fillLX, fillW, barCY)
    if not texRune01 then return end

    runeTimer = runeTimer + dt
    local pulse = RUNE_ALPHA_MIN + (RUNE_ALPHA_MAX - RUNE_ALPHA_MIN)
                  * (0.5 + 0.5 * math.sin(runeTimer * RUNE_PULSE_SPEED))

    -- Scale up sur les 35 premiers %
    local scale
    if progress < RUNE_GROW_END then
        scale = progress / RUNE_GROW_END
        scale = math.max(scale, 0.05)
    else
        scale = 1.0
    end
    local size = RUNE_SIZE * scale

    local rightX = fillLX + fillW

    texRune01:SetSize(size, size)
    texRune01:ClearAllPoints()
    texRune01:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
        fillLX - RUNE_OFFSET_X, barCY + RUNE_OFFSET_Y)
    SetTexRot(texRune01, runeTimer * RUNE_ROT_SPEED)
    texRune01:SetAlpha(pulse * scale)

    texRune02:SetSize(size, size)
    texRune02:ClearAllPoints()
    texRune02:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
        rightX + RUNE_OFFSET_X, barCY + RUNE_OFFSET_Y)
    SetTexRot(texRune02, -runeTimer * RUNE_ROT_SPEED)
    texRune02:SetAlpha(pulse * scale)
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local school = SCB.Schools.data["arcane"]
    if not school then return end

    local f = SCB.Bar.frameInner

    -- Rune_Back (fixe, offset Y, masquée par progression)
    texRuneBack = f:CreateTexture(nil, "BACKGROUND", nil, -1)
    texRuneBack:SetTexture(school.runeBack)
    texRuneBack:SetBlendMode("ADD")
    texRuneBack:SetSize(RUNE_BACK_W, RUNE_BACK_H)
    texRuneBack:SetPoint("CENTER", f, "CENTER", 0, RUNE_BACK_OFFSET_Y)
    texRuneBack:AddMaskTexture(SCB.Bar.texMask)
    texRuneBack:SetAlpha(0)

    texRuneBack2 = f:CreateTexture(nil, "BACKGROUND", nil, -2)
    texRuneBack2:SetTexture(school.runeBack)
    texRuneBack2:SetBlendMode("ADD")
    texRuneBack2:SetSize(RUNE_BACK_W, RUNE_BACK_H)
    texRuneBack2:SetPoint("CENTER", f, "CENTER", 0, RUNE_BACK_OFFSET_Y)
    texRuneBack2:AddMaskTexture(SCB.Bar.texMask)
    texRuneBack2:SetAlpha(0)

    -- Fill_Bar_Arcane : fond statique, suit texMask
    texFillBar = f:CreateTexture(nil, "ARTWORK", nil, 0)
    if school.fillBar then texFillBar:SetTexture(school.fillBar) end
    texFillBar:SetAllPoints(f)
    texFillBar:AddMaskTexture(SCB.Bar.texMask)
    texFillBar:SetAlpha(0)

    -- Trois couches Fill_Arcane : hauteur native respectée (84px), centrées
    -- Le scroll via SetTexCoord REPEAT, sens G→D = u décroît
    local fillTex = school.fill
    local fillH   = 84    -- hauteur visible Fill_Mask
    local frameH  = SCB.Config:Get("barHeight") or 200
    local offTop  = -(frameH - fillH) / 2
    local offBot  =  (frameH - fillH) / 2

    texFillA = f:CreateTexture(nil, "ARTWORK", nil, 2)
    texFillA:SetTexture(fillTex, "REPEAT", "REPEAT")
    texFillA:SetBlendMode("ADD")
    texFillA:SetPoint("TOPLEFT",     f, "TOPLEFT",     0, offTop)
    texFillA:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, offBot)
    texFillA:SetAlpha(0)

    texFillB = f:CreateTexture(nil, "ARTWORK", nil, 3)
    texFillB:SetTexture(fillTex, "REPEAT", "REPEAT")
    texFillB:SetBlendMode("ADD")
    texFillB:SetPoint("TOPLEFT",     f, "TOPLEFT",     0, offTop)
    texFillB:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, offBot)
    texFillB:SetAlpha(0)

    texFillC = f:CreateTexture(nil, "ARTWORK", nil, 4)
    texFillC:SetTexture(fillTex, "REPEAT", "REPEAT")
    texFillC:SetBlendMode("ADD")
    texFillC:SetPoint("TOPLEFT",     f, "TOPLEFT",     0, offTop)
    texFillC:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, offBot)
    texFillC:SetAlpha(0)

    -- Masks sur les couches fill : Fill_Mask (forme) + texMask (progression)
    for _, tex in ipairs({texFillA, texFillB, texFillC}) do
        local msk = f:CreateMaskTexture()
        msk:SetTexture(school.fillMask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        msk:SetAllPoints(f)
        tex:AddMaskTexture(msk)
        tex:AddMaskTexture(SCB.Bar.texMask)
    end

    -- Masquer le fill standard
    SCB.Bar.texFill:SetAlpha(0)

    -- Runes
    local school_r = SCB.Schools.data["arcane"]
    rune01Tex = school_r.rune01
    rune02Tex = school_r.rune02

    texRune01 = container:CreateTexture(nil, "OVERLAY")
    texRune01:SetTexture(rune01Tex)
    texRune01:SetBlendMode("ADD")
    texRune01:SetSize(RUNE_SIZE, RUNE_SIZE)
    texRune01:SetAlpha(0)

    texRune02 = container:CreateTexture(nil, "OVERLAY")
    texRune02:SetTexture(rune02Tex)
    texRune02:SetBlendMode("ADD")
    texRune02:SetSize(RUNE_SIZE, RUNE_SIZE)
    texRune02:SetAlpha(0)

    -- Glow particles
    local glowTex = SCB.TEX_PATH .. "frost\\Particle_Frost_01"
    glowParts = {}
    for i = 1, GLOW_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(glowTex)
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(GLOW_R, GLOW_G, GLOW_B)
        tex:SetAlpha(0)
        glowParts[i] = { tex=tex, active=false, life=0, maxLife=0,
                         x=0, y=0, vy=0, phase=0 }
    end
end

function FX.Start(duration)
    -- Exposer texFillA pour le highlight de fin de cast (Animations.lua)
    FX.texFillA = texFillA
    isActive      = true
    scrollU       = 0
    runeTimer     = 0
    runeBackTimer = 0
    glowSpawnAcc  = 0

    -- Swap des textures de runes si flagué
    if swapNext and texRune01 and texRune02 then
        local tmp = rune01Tex
        rune01Tex = rune02Tex
        rune02Tex = tmp
        texRune01:SetTexture(rune01Tex)
        texRune02:SetTexture(rune02Tex)
    end
    swapNext = not swapNext   -- alterner à chaque cast

    if texFillBar  then texFillBar:SetAlpha(1)             end
    if texFillA    then texFillA:SetAlpha(FILL_BASE_ALPHA)  end
    if texFillB    then texFillB:SetAlpha(FILL_MIRROR_ALPHA) end
    if texFillC    then texFillC:SetAlpha(FILL_BOTH_ALPHA)  end
    if texRuneBack then texRuneBack:SetAlpha(RUNE_BACK_ALPHA) end
    if texRune01   then texRune01:SetAlpha(RUNE_ALPHA_MIN)  end
    if texRune02   then texRune02:SetAlpha(RUNE_ALPHA_MIN)  end

    for _, p in ipairs(glowParts) do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Stop()
    isActive = false
end

function FX.Reset()
    isActive = false
    if texFillBar  then texFillBar:SetAlpha(0)   end
    if texFillA    then texFillA:SetAlpha(0)     end
    if texFillB    then texFillB:SetAlpha(0)     end
    if texFillC    then texFillC:SetAlpha(0)     end
    if texRuneBack then texRuneBack:SetAlpha(0)  end
    if texRuneBack2 then texRuneBack2:SetAlpha(0) end
    if texRune01   then texRune01:SetAlpha(0)    end
    if texRune02   then texRune02:SetAlpha(0)    end
    for _, p in ipairs(glowParts) do p.active = false ; p.tex:SetAlpha(0) end
    if SCB.Bar.currentSchoolKey ~= "arcane" then
        SCB.Bar.texFill:SetAlpha(1)
    end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    local f = SCB.Bar.frameInner
    local cx, barCY = f:GetCenter()
    if not cx then return end

    UpdateFill(dt)
    UpdateRunes(dt, progress, fillLX, fillW, barCY)

    -- Glow particles
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
