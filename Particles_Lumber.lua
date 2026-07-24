-- ============================================================
--  Opulent Casting Bars — Particles_Lumber.lua
--
--  Effet "récolte de bois" : un tronc d'arbre se coupe peu à peu.
--
--  · 5 textures de tronc (Lumber_01 → Lumber_05) gérées via stageTex,
--    créée dans frameInner à la couche ARTWORK : toujours visible mais
--    sous les textes (OVERLAY), qui restent lisibles par-dessus.
--  · À chaque changement de stage :
--      — Tremblement de la barre (coup de hache)
--      — Éclats de bois/écorce (Lumber_Misc_01-05) jaillissent
--        depuis le centre avec gravité et rotation.
--  · En fin de cast (succès) :
--      — Lumber_05 (stageTex) et les textes disparaissent simultanément
--      — Lumber_Left et Lumber_Right apparaissent à la place,
--        s'écartent avec gravité, impulsion latérale et rotation.
-- ============================================================

local FX = {}
SCB.FX            = SCB.FX or {}
SCB.FX["lumber"]  = FX

local TEX = SCB.TEX_PATH .. "lumber\\"

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

local STAGES = {
    TEX .. "Lumber_01",
    TEX .. "Lumber_02",
    TEX .. "Lumber_03",
    TEX .. "Lumber_04",
    TEX .. "Lumber_05",
}

local STAGE_THRESHOLDS = { 0.00, 0.20, 0.40, 0.60, 0.80 }

local MISC_TEX = {
    TEX .. "Lumber_Misc_01",
    TEX .. "Lumber_Misc_02",
    TEX .. "Lumber_Misc_03",
    TEX .. "Lumber_Misc_04",
    TEX .. "Lumber_Misc_05",
}

-- Éclats (+30% count, +25% size vs v1)
local CHIP_COUNT     = 52
local CHIP_PER_STAGE = 9
local CHIP_SPEED_MIN = 45
local CHIP_SPEED_MAX = 135
local CHIP_GRAVITY   = 210
local CHIP_LIFE_MIN  = 0.38
local CHIP_LIFE_MAX  = 0.90
local CHIP_SIZE_MIN  = 8    -- was 6  (+25%)
local CHIP_SIZE_MAX  = 24   -- was 19 (+25%)
local CHIP_ALPHA     = 0.92
local FADE_DUR       = 0.42

-- Séparation finale
local SPLIT_GRAVITY     = 170
local SPLIT_VX_MIN      = 90    -- légèrement plus de déviation latérale
local SPLIT_VX_MAX      = 150
local SPLIT_VY_MIN      = 35
local SPLIT_VY_MAX      = 80
local SPLIT_ROT_MIN     = 1.2
local SPLIT_ROT_MAX     = 2.8
local SPLIT_SIZE_FACTOR = 0.85  -- morceaux 15% plus petits

-- Tremblement
local SHAKE_AMOUNT   = 5
local SHAKE_INTERVAL = 0.028
local SHAKE_COUNT    = 5

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local isActive     = false
local isFading     = false
local fadeT        = 0
local currentStage = 0
local chips        = {}

-- Texture du tronc — dans frameInner à la couche ARTWORK (sublevel 2).
-- Les textes (OVERLAY) restent au premier plan au-dessus d'elle.
local stageTex  = nil

-- Séparation finale
local splitActive  = false
local splitTime    = 0
local leftTex      = nil
local rightTex     = nil
local leftX,  leftY,  leftVX,  leftVY,  leftRot,  leftRotSpeed  = 0,0,0,0,0,0
local rightX, rightY, rightVX, rightVY, rightRot, rightRotSpeed = 0,0,0,0,0,0

local savedCX, savedCY, savedBarW, savedBarH = 0, 0, 0, 0

-- ============================================================
--  ÉCLATS DE BOIS
-- ============================================================

local function SpawnChip(cx, cy, barH)
    local spread  = math.min(barH * 0.22, 14)
    local spawned = 0
    for _, p in ipairs(chips) do
        if not p.active then
            local angle = rand(0, pi2)
            local speed = rand(CHIP_SPEED_MIN, CHIP_SPEED_MAX)
            p.active   = true
            p.life     = 0
            p.maxLife  = rand(CHIP_LIFE_MIN, CHIP_LIFE_MAX)
            p.x        = cx + rand(-10, 10)
            p.y        = cy + rand(-spread, spread)
            p.vx       = math.cos(angle) * speed
            p.vy       = math.sin(angle) * speed + rand(8, 28)
            p.rot      = rand(0, pi2)
            p.rotSpeed = rand(2.0, 5.5) * (math.random(2) == 1 and 1 or -1)
            local sz   = rand(CHIP_SIZE_MIN, CHIP_SIZE_MAX)
            p.tex:SetSize(sz, sz)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            spawned = spawned + 1
            if spawned >= CHIP_PER_STAGE then return end
        end
    end
end

local function UpdateChip(p, dt, gf)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy  = p.vy  - CHIP_GRAVITY * dt
    p.x   = p.x   + p.vx * dt
    p.y   = p.y   + p.vy * dt
    p.rot = p.rot + p.rotSpeed * dt
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    SetTexRot(p.tex, p.rot)
    local env = t < 0.14 and (t / 0.14) or (t < 0.68 and 1 or math.max(0, (1 - t) / 0.32))
    p.tex:SetAlpha(env * CHIP_ALPHA * (gf or 1))
end

-- ============================================================
--  TREMBLEMENT
-- ============================================================

local function TriggerShake()
    local frame = SCB.Bar and SCB.Bar.frame
    if not frame then return end
    local anchor = SCB.Config:Get("anchor")
    local origX  = SCB.Config:Get("x")
    local origY  = SCB.Config:Get("y")
    if not anchor then return end
    local count = 0

    local function doShake()
        if not SCB.Bar.isActive and not SCB.Bar.isFading then return end
        count = count + 1
        if count > SHAKE_COUNT then
            frame:ClearAllPoints()
            frame:SetPoint(anchor, UIParent, anchor, origX, origY)
            return
        end
        local ox = (count % 2 == 0) and SHAKE_AMOUNT or -SHAKE_AMOUNT
        local oy = (count % 2 == 0) and -2 or 2
        frame:ClearAllPoints()
        frame:SetPoint(anchor, UIParent, anchor, origX + ox, origY + oy)
        C_Timer.After(SHAKE_INTERVAL, doShake)
    end

    doShake()
end

-- ============================================================
--  SÉPARATION FINALE
-- ============================================================

local function TriggerSplit()
    local cx   = savedCX
    local cy   = savedCY
    local barH = savedBarH
    if cx == 0 and cy == 0 then return end

    -- Tout le contenu Lumber disparaît au moment de la séparation
    if stageTex then stageTex:SetAlpha(0) end
    if SCB.Bar then
        if SCB.Bar.texBG        then SCB.Bar.texBG:SetAlpha(0)        end
        if SCB.Bar.spellNameText then SCB.Bar.spellNameText:SetAlpha(0) end
        if SCB.Bar.castTimerText  then SCB.Bar.castTimerText:SetAlpha(0)  end
    end

    local scale = (SCB.Config and SCB.Config:Get("scale")) or 1
    local texSz = math.max(barH / scale, 40) * SPLIT_SIZE_FACTOR
    local halfOff = barH * 0.08

    leftX        = cx - halfOff
    leftY        = cy
    leftVX       = -rand(SPLIT_VX_MIN, SPLIT_VX_MAX)
    leftVY       =  rand(SPLIT_VY_MIN, SPLIT_VY_MAX)
    leftRot      =  0
    leftRotSpeed = -rand(SPLIT_ROT_MIN, SPLIT_ROT_MAX)

    rightX        = cx + halfOff
    rightY        = cy
    rightVX       =  rand(SPLIT_VX_MIN, SPLIT_VX_MAX)
    rightVY       =  rand(SPLIT_VY_MIN, SPLIT_VY_MAX)
    rightRot      =  0
    rightRotSpeed =  rand(SPLIT_ROT_MIN, SPLIT_ROT_MAX)

    splitTime   = 0
    splitActive = true

    if leftTex then
        leftTex:SetSize(texSz, texSz)
        leftTex:SetAlpha(1)
        leftTex:SetTexCoord(0, 1, 0, 1)
        leftTex:ClearAllPoints()
        leftTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", leftX, leftY)
    end
    if rightTex then
        rightTex:SetSize(texSz, texSz)
        rightTex:SetAlpha(1)
        rightTex:SetTexCoord(0, 1, 0, 1)
        rightTex:ClearAllPoints()
        rightTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", rightX, rightY)
    end
end

local function UpdateSplit(dt)
    if not splitActive then return end
    splitTime = splitTime + dt

    leftVY   = leftVY  - SPLIT_GRAVITY * dt
    rightVY  = rightVY - SPLIT_GRAVITY * dt
    leftX    = leftX   + leftVX  * dt
    leftY    = leftY   + leftVY  * dt
    rightX   = rightX  + rightVX * dt
    rightY   = rightY  + rightVY * dt
    leftRot  = leftRot  + leftRotSpeed  * dt
    rightRot = rightRot + rightRotSpeed * dt

    if leftTex then
        leftTex:ClearAllPoints()
        leftTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", leftX, leftY)
        SetTexRot(leftTex, leftRot)
    end
    if rightTex then
        rightTex:ClearAllPoints()
        rightTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", rightX, rightY)
        SetTexRot(rightTex, rightRot)
    end
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, frameInner)
    -- Texture de tronc dans frameInner à ARTWORK (sublevel 2).
    -- Se trouve ainsi AU-DESSUS du fill (ARTWORK 0/1) mais EN-DESSOUS
    -- des textes (OVERLAY), qui restent lisibles par-dessus le tronc.
    stageTex = frameInner:CreateTexture(nil, "ARTWORK", nil, 2)
    stageTex:SetAllPoints(frameInner)
    stageTex:SetTexture(STAGES[1])
    stageTex:SetBlendMode("BLEND")
    stageTex:SetAlpha(0)

    -- Pool d'éclats (dans container = FrameLevel élevé → au-dessus du texte)
    local nMisc = #MISC_TEX
    chips = {}
    for i = 1, CHIP_COUNT do
        local tex = container:CreateTexture(nil, "OVERLAY")
        tex:SetTexture(MISC_TEX[((i - 1) % nMisc) + 1])
        tex:SetBlendMode("BLEND")
        tex:SetAlpha(0)
        chips[i] = {
            tex=tex, active=false,
            life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0,
            rot=0, rotSpeed=0,
        }
    end

    -- Morceaux de séparation (container → au-dessus du texte)
    leftTex = container:CreateTexture(nil, "OVERLAY")
    leftTex:SetTexture(TEX .. "Lumber_Left")
    leftTex:SetBlendMode("BLEND")
    leftTex:SetAlpha(0)

    rightTex = container:CreateTexture(nil, "OVERLAY")
    rightTex:SetTexture(TEX .. "Lumber_Right")
    rightTex:SetBlendMode("BLEND")
    rightTex:SetAlpha(0)

    -- Préchargement GPU
    local function preload(path)
        local t = UIParent:CreateTexture(nil, "BACKGROUND")
        t:SetTexture(path) ; t:SetSize(1,1) ; t:SetAlpha(0.0001)
        t:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    end
    for _, p in ipairs(MISC_TEX) do preload(p) end
    for _, p in ipairs(STAGES)   do preload(p) end
    preload(TEX .. "Lumber_Left")
    preload(TEX .. "Lumber_Right")
end

function FX.Start(dur)
    isActive     = true
    isFading     = false
    fadeT        = 0
    currentStage = 0
    splitActive  = false
    splitTime    = 0

    if stageTex then
        stageTex:SetTexture(STAGES[1])
        stageTex:SetAlpha(1)
        stageTex:SetTexCoord(0, 1, 0, 1)
    end

    -- Restaurer l'alpha des textes au cas où le cast précédent les aurait masqués
    if SCB.Bar then
        if SCB.Bar.spellNameText then SCB.Bar.spellNameText:SetAlpha(1) end
        if SCB.Bar.castTimerText  then SCB.Bar.castTimerText:SetAlpha(1)  end
    end

    for _, p in ipairs(chips) do p.active = false ; p.tex:SetAlpha(0) end
    if leftTex  then leftTex:SetAlpha(0)  end
    if rightTex then rightTex:SetAlpha(0) end
end

function FX.Stop(success)
    isActive = false
    isFading = true
    fadeT    = 0

    if SCB.Bar and SCB.Bar.frame then
        local cx, cy = SCB.Bar.frame:GetCenter()
        if cx then
            savedCX   = cx
            savedCY   = cy
            savedBarW = SCB.Bar.frame:GetWidth()
            savedBarH = SCB.Bar.frame:GetHeight()
        end
    end

    if success then
        TriggerSplit()
    end
end

function FX.UpdateFade(dt)
    if not isFading then return end
    fadeT = fadeT + dt

    -- Pendant la séparation, forcer toutes les couches Lumber à 0
    -- (le fade du wrapper pourrait sinon restaurer brièvement texBG ou stageTex)
    if splitActive then
        if stageTex then stageTex:SetAlpha(0) end
        if SCB.Bar then
            if SCB.Bar.texBG   then SCB.Bar.texBG:SetAlpha(0)   end
            if SCB.Bar.texFill then SCB.Bar.texFill:SetAlpha(0) end
        end
    end

    UpdateSplit(dt)
    local gf = math.max(0, 1 - fadeT / FADE_DUR)
    for _, p in ipairs(chips) do UpdateChip(p, dt, gf) end
end

function FX.Reset()
    isActive     = false
    isFading     = false
    fadeT        = 0
    splitActive  = false
    splitTime    = 0
    currentStage = 0

    if stageTex then stageTex:SetAlpha(0) end

    -- Restaurer tout ce que le split avait masqué
    if SCB.Bar then
        if SCB.Bar.texBG         then SCB.Bar.texBG:SetAlpha(1)         end
        if SCB.Bar.spellNameText then SCB.Bar.spellNameText:SetAlpha(1) end
        if SCB.Bar.castTimerText  then SCB.Bar.castTimerText:SetAlpha(1)  end
    end

    for _, p in ipairs(chips) do p.active = false ; p.tex:SetAlpha(0) end
    if leftTex  then leftTex:SetAlpha(0)  ; leftTex:SetTexCoord(0,1,0,1)  end
    if rightTex then rightTex:SetAlpha(0) ; rightTex:SetTexCoord(0,1,0,1) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    local newStage = 1
    for i = #STAGE_THRESHOLDS, 1, -1 do
        if progress >= STAGE_THRESHOLDS[i] then
            newStage = i
            break
        end
    end

    if newStage ~= currentStage then
        currentStage = newStage
        if stageTex then
            stageTex:SetTexture(STAGES[newStage])
            stageTex:SetTexCoord(0, 1, 0, 1)
        end
        TriggerShake()
        local cx = fillLX + fillW * 0.5
        SpawnChip(cx, cy, barH)
    end

    for _, p in ipairs(chips) do UpdateChip(p, dt, 1) end
end
