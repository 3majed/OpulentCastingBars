-- ============================================================
--  Sleek Casting Bars — Particles_Frostfire.lua
--  Effets visuels pour l'école Frostfire :
--    · FrostfireEffects — 5 flammes animées, masquées par progression
--    · MistFrost        — brumes de givre flottantes
--    · AmbParts         — cendres ambiantes (teinte bleutée)
--    · FrontParts       — mix frost+fire au bout de la barre
-- ============================================================

local FX = {}
SCB.FX = SCB.FX or {}
SCB.FX["frostfire"] = FX

-- ============================================================
--  UTILITAIRES LOCAUX
-- ============================================================

local function rand(a, b) return a + math.random() * (b - a) end
local function rad(deg)   return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end

local TEX_FF    = SCB.TEX_PATH .. "frostfire\\"
local TEX_FROST = SCB.TEX_PATH .. "frost\\"
local TEX_FIRE  = SCB.TEX_PATH .. "fire\\"

-- ============================================================
--  CONSTANTES — FILL EFFECTS (flammes)
-- ============================================================

local FF_EFFECT_COUNT = 3       -- slots actifs simultanément
local FF_EFFECT_CYCLE = 0.65
local FF_EFFECT_FADE  = 0.13
local FF_EFFECT_BASE  = { 1, 2, 3, 4, 5 }

-- ============================================================
--  CONSTANTES — MIST (brumes de givre)
-- ============================================================

local MIST_COUNT     = 4
local MIST_W_BASE    = 338
local MIST_H_BASE    = 169
local MIST_ALPHA_MAX = 0.38    -- plus discret que Frost pur (on mélange avec fire)
local MIST_SCALE_MIN = 0.70
local MIST_SCALE_MAX = 1.20
local MIST_FADE_IN   = 1.6
local MIST_HOLD_MIN  = 1.0
local MIST_HOLD_MAX  = 2.2
local MIST_FADE_OUT  = 1.3
local MIST_ROT_SPEED = 0.035

local MIST_POSITIONS = { 1/5, 2/5, 3/5, 4/5 }

-- ============================================================
--  CONSTANTES — PARTICULES AMBIANTES (cendres bleutées)
-- ============================================================

local AMB_COUNT = 40
local AMB_SPAWN = 0.09

-- ============================================================
--  CONSTANTES — FRONT MIX (frost+fire au bout de barre)
-- ============================================================

local FRONT_COUNT     = 60
local FRONT_SPAWN     = 0.028

local frontTypes = {
    -- type 1 : braises fire (chaudes, montantes)
    { kind="fire",  sizeMin=6,  sizeMax=13, speedMin=25, speedMax=65,  lifeMin=0.7, lifeMax=1.5, gravity=7,  spread=130, driftX=0.3  },
    -- type 2 : éclats frost (froids, rapides)
    { kind="frost", sizeMin=5,  sizeMax=10, speedMin=85, speedMax=160, lifeMin=0.2, lifeMax=0.55, gravity=18, spread=70,  driftX=0.0  },
    -- type 3 : braises lentes (intermédiaires)
    { kind="fire",  sizeMin=7,  sizeMax=12, speedMin=40, speedMax=90,  lifeMin=0.5, lifeMax=1.1, gravity=22, spread=95,  driftX=0.15 },
}

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local ffEffectSlots   = {}
local mists           = {}
local ambParts        = {}
local frontParts      = {}
local ambSpawnAcc     = 0
local frontSpawnAcc   = 0
local castDuration    = 5

local isActive        = false
local givreFading     = false
local givreFadeT      = 0
local GIVRE_FADE_DUR  = 0.55   -- fade out Givre synchro avec le wrapper

-- ============================================================
--  ROTATION UV (compatible Classic + Retail)
-- ============================================================

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
--  FILL EFFECTS — Flammes Frostfire
-- ============================================================

local function UpdateFillEffects(dt)
    local bar = SCB.Bar
    if not bar.texFillEffectsFrostfire then return end
    if not bar.currentSchool or not bar.currentSchool.frostfireEffects then return end

    local effectAlphas = {}
    for i = 1, 5 do effectAlphas[i] = 0 end

    for _, slot in ipairs(ffEffectSlots) do
        slot.timer = slot.timer + dt
        if slot.timer >= FF_EFFECT_CYCLE then
            slot.timer   = slot.timer - FF_EFFECT_CYCLE
            slot.basePos = (slot.basePos % #FF_EFFECT_BASE) + 1
        end
        local t     = slot.timer / FF_EFFECT_CYCLE
        local fadeT = FF_EFFECT_FADE / FF_EFFECT_CYCLE
        local alpha
        if     t < fadeT       then alpha = t / fadeT
        elseif t < 1 - fadeT   then alpha = 1
        else                        alpha = (1 - t) / fadeT end
        local texIdx = FF_EFFECT_BASE[slot.basePos]
        effectAlphas[texIdx] = math.max(effectAlphas[texIdx], math.max(0, alpha) * 0.82)
    end

    for i, t in ipairs(bar.texFillEffectsFrostfire) do
        t:SetAlpha(effectAlphas[i] or 0)
    end
end

local function ResetFillEffects()
    local bar = SCB.Bar
    if bar.texFillEffectsFrostfire then
        for _, t in ipairs(bar.texFillEffectsFrostfire) do t:SetAlpha(0) end
    end
    for s = 1, FF_EFFECT_COUNT do
        ffEffectSlots[s].timer   = (s - 1) * (FF_EFFECT_CYCLE / FF_EFFECT_COUNT)
        ffEffectSlots[s].basePos = s
    end
end

-- ============================================================
--  MIST
-- ============================================================

local function SpawnMist(m)
    local scale = rand(MIST_SCALE_MIN, MIST_SCALE_MAX)
    m.baseW    = MIST_W_BASE * scale
    m.baseH    = MIST_H_BASE * scale
    m.tex:SetSize(m.baseW, m.baseH)
    m.tex:SetAlpha(0)
    m.phase    = "fadein"
    m.timer    = 0
    m.duration = MIST_FADE_IN
    m.alpha    = 0
    m.scaleT   = 0
    m.scaleDir = math.random(2) == 1 and 1 or -1
end

local function UpdateMist(m, dt)
    if m.delay and m.delay > 0 then
        m.delay = m.delay - dt
        return
    end
    if m.phase == "idle" then SpawnMist(m) ; return end

    local f = SCB.Bar.frameInner
    local cx, cy = f:GetCenter()
    if cx then
        local barW = f:GetWidth()
        local x = cx - barW * 0.5 + barW * m.xFrac
        m.tex:ClearAllPoints()
        m.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, cy)
    end

    m.timer  = m.timer + dt
    m.scaleT = m.scaleT + dt
    m.angle  = m.angle + MIST_ROT_SPEED * m.rotDir * dt

    local scalePulse = 1 + math.sin(m.scaleT * 0.45 * m.scaleDir) * 0.09
    m.tex:SetSize(m.baseW * scalePulse, m.baseH * scalePulse)
    SetTextureRotation(m.tex, m.angle)

    if m.phase == "fadein" then
        m.alpha = math.min(m.timer / m.duration, 1) * MIST_ALPHA_MAX
        m.tex:SetAlpha(math.max(0, m.alpha + math.sin(m.scaleT * 1.8) * 0.03))
        if m.timer >= m.duration then
            m.phase = "hold" ; m.timer = 0
            m.duration = rand(MIST_HOLD_MIN, MIST_HOLD_MAX)
        end
    elseif m.phase == "hold" then
        m.tex:SetAlpha(math.max(0, MIST_ALPHA_MAX + math.sin(m.scaleT * 1.8) * 0.05))
        if m.timer >= m.duration then
            m.phase = "fadeout" ; m.timer = 0 ; m.duration = MIST_FADE_OUT
        end
    elseif m.phase == "fadeout" then
        m.alpha = (1 - m.timer / m.duration) * MIST_ALPHA_MAX
        m.tex:SetAlpha(math.max(0, m.alpha))
        if m.timer >= m.duration then
            m.tex:SetAlpha(0) ; m.phase = "idle"
        end
    end
end

-- ============================================================
--  PARTICULES AMBIANTES (cendres teinte bleutée)
-- ============================================================

local function SpawnAmbient(progress)
    local f = SCB.Bar.frame
    local cx, cy = f:GetCenter()
    if not cx then return end
    local barW, barH = f:GetWidth(), f:GetHeight()

    for _, p in ipairs(ambParts) do
        if not p.active then
            local xOffset = rand(-barW * 0.5, barW * 0.5 * progress - barW * 0.5)
            local yOffset = rand(-barH * 0.35, barH * 0.35)
            local dirX    = xOffset > 0 and 1 or -1

            p.active  = true ; p.life = 0
            p.maxLife = rand(1.0, 2.2)
            p.x       = cx + xOffset ; p.y = cy + yOffset
            p.vx      = dirX * rand(4, 18)
            p.vy      = rand(12, 40)

            local size = rand(5, 13)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            return
        end
    end
end

local function UpdateAmbient(p, dt)
    if not p.active then return end
    p.life = p.life + dt
    local t = p.life / p.maxLife
    if t >= 1 then p.active = false ; p.tex:SetAlpha(0) ; return end
    p.vy = p.vy - 4 * dt
    p.x  = p.x + p.vx * dt
    p.y  = p.y + p.vy * dt
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha
    if t < 0.1 then alpha = t / 0.1
    elseif t < 0.65 then alpha = 1
    else alpha = (1 - t) / 0.35 end
    p.tex:SetAlpha(math.max(0, alpha) * 0.50)
end

-- ============================================================
--  PARTICULES FRONT (mix frost + fire)
-- ============================================================

local function SpawnFrontParticle(wx, wy)
    -- Choisir le type : 40% fire1, 30% frost2, 30% fire3
    local roll = math.random(10)
    local typeIdx = roll <= 4 and 1 or (roll <= 7 and 2 or 3)
    local ptype = frontTypes[typeIdx]

    for _, p in ipairs(frontParts) do
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
            p.drift   = rand(-ptype.driftX, ptype.driftX) * 28
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(1)
            return
        end
    end
end

local function UpdateFrontParticle(p, dt)
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
    if p.typeIdx == 2 then  -- frost : flash puis fade
        alpha = t < 0.15 and 1 or math.max(0, 1 - (t - 0.15) / 0.85)
    else                    -- fire  : stable puis fade
        alpha = t < 0.5 and 1 or math.max(0, (1 - t) / 0.5)
    end
    p.tex:SetAlpha(alpha * 0.88)
end

-- ============================================================
--  INTERFACE STANDARD
-- ============================================================

function FX.Init(container, bar)
    local fireTex1  = TEX_FIRE  .. "Particle_Fire_01"
    local fireTex2  = TEX_FIRE  .. "Particle_Fire_02"
    local fireTex3  = TEX_FIRE  .. "Particle_Fire_03"
    local frostTex1 = TEX_FROST .. "Particle_Frost_01"
    local frostTex2 = TEX_FROST .. "Particle_Frost_02"
    local fireMisc1 = TEX_FIRE  .. "Particle_Fire_01"  -- pour les cendres ambiantes

    -- ---- Slots fill effects ---------------------------------
    for s = 1, FF_EFFECT_COUNT do
        ffEffectSlots[s] = {
            timer   = (s - 1) * (FF_EFFECT_CYCLE / FF_EFFECT_COUNT),
            basePos = s,
        }
    end

    -- ---- Mists ----------------------------------------------
    for i, xFrac in ipairs(MIST_POSITIONS) do
        local tex = bar:CreateTexture(nil, "BACKGROUND", nil, -1)
        tex:SetTexture(TEX_FROST .. "Mist_Frost_01")
        tex:SetSize(MIST_W_BASE, MIST_H_BASE)
        tex:SetAlpha(0)
        tex:SetBlendMode("ADD")
        -- Légère teinte bleue sur la brume pour coller à l'esthétique Frostfire
        tex:SetVertexColor(0.72, 0.88, 1.0)
        mists[i] = {
            tex=tex, xFrac=xFrac, phase="idle", timer=0, duration=0,
            alpha=0, scaleT=0, scaleDir=1, angle=0,
            rotDir=(i % 2 == 0) and 1 or -1,
            baseW=MIST_W_BASE, baseH=MIST_H_BASE,
            delay=(i - 1) * 0.75,
        }
    end

    -- ---- Cendres ambiantes (teinte bleu-violet) -----------
    for i = 1, AMB_COUNT do
        local tex = container:CreateTexture(nil, "BACKGROUND")
        -- Alterner entre textures fire et frost pour la variété
        local t = (i % 3 == 0) and frostTex1 or ((i % 3 == 1) and fireMisc1 or fireTex2)
        tex:SetTexture(t)
        tex:SetAlpha(0)
        tex:SetBlendMode("ADD")
        -- Teinte : mélange bleu-orange pour l'effet frostfire
        if i % 3 == 0 then
            tex:SetVertexColor(0.5, 0.75, 1.0)   -- frost
        else
            tex:SetVertexColor(1.0, 0.6, 0.15)   -- fire
        end
        ambParts[i] = { tex=tex, active=false, life=0, maxLife=0, x=0, y=0, vx=0, vy=0 }
    end

    -- ---- Particules front mix frost+fire ------------------
    for i = 1, FRONT_COUNT do
        local typeIdx = ((i - 1) % 3) + 1
        local ptype   = frontTypes[typeIdx]
        local tex = container:CreateTexture(nil, "OVERLAY")

        -- Texture selon le kind
        local texPath
        if ptype.kind == "frost" then
            texPath = (i % 2 == 0) and frostTex1 or frostTex2
        else
            texPath = (i % 3 == 0) and fireTex1 or ((i % 3 == 1) and fireTex2 or fireTex3)
        end
        tex:SetTexture(texPath)
        tex:SetAlpha(0)
        tex:SetBlendMode("ADD")

        -- Couleur : frost = bleu glacé, fire = orange chaud
        if ptype.kind == "frost" then
            tex:SetVertexColor(0.55, 0.85, 1.0)
        else
            tex:SetVertexColor(1.0, 0.55, 0.10)
        end

        frontParts[i] = {
            tex=tex, ptype=ptype, typeIdx=typeIdx,
            active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0, drift=0,
        }
    end
end

function FX.Start(duration)
    castDuration  = duration or 5
    ambSpawnAcc   = 0
    frontSpawnAcc = 0
    isActive      = true
    givreFading   = false
    givreFadeT    = 0

    ResetFillEffects()
    for _, m in ipairs(mists)      do m.phase = "idle" ; m.delay = 0 ; m.tex:SetAlpha(0) end
    for _, p in ipairs(ambParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(frontParts) do p.active = false ; p.tex:SetAlpha(0) end

    -- Réactiver la Givre (au cas où elle serait restée à 0 d'un reset)
    local bar = SCB.Bar
    if bar.texGivreFrostfire then bar.texGivreFrostfire:SetAlpha(1) end

    -- Décaler les mists pour un démarrage progressif
    for i, m in ipairs(mists) do
        m.delay = (i - 1) * 0.75
    end
end

function FX.Stop()
    isActive    = false
    givreFading = true
    givreFadeT  = 0

    for _, m in ipairs(mists) do
        if m.phase ~= "idle" then
            m.phase = "fadeout" ; m.timer = 0 ; m.duration = 0.35
        end
    end
    -- Les particules en vol terminent leur trajectoire naturellement
end

-- Appelé par Particles.lua pendant le fade out du wrapper
function FX.UpdateFade(dt)
    if not givreFading then return end
    givreFadeT = givreFadeT + dt
    local t = givreFadeT / GIVRE_FADE_DUR
    local alpha = math.max(0, 1 - t)

    local bar = SCB.Bar
    if bar.texGivreFrostfire then
        bar.texGivreFrostfire:SetAlpha(alpha)
    end
    -- Continuer à mettre à jour les mists pendant le fade
    for _, m in ipairs(mists) do UpdateMist(m, dt) end
    -- Continuer à mettre à jour les particules en vol
    for _, p in ipairs(ambParts)   do UpdateAmbient(p, dt) end
    for _, p in ipairs(frontParts) do UpdateFrontParticle(p, dt) end

    if t >= 1 then
        givreFading = false
        if bar.texGivreFrostfire then bar.texGivreFrostfire:SetAlpha(0) end
        for _, m in ipairs(mists)      do m.tex:SetAlpha(0) ; m.phase = "idle" end
        for _, p in ipairs(ambParts)   do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(frontParts) do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    isActive    = false
    givreFading = false
    givreFadeT  = 0
    ResetFillEffects()
    for _, m in ipairs(mists)      do m.tex:SetAlpha(0) ; m.phase = "idle" end
    for _, p in ipairs(ambParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(frontParts) do p.active = false ; p.tex:SetAlpha(0) end
    -- Reset alpha Givre seulement si on est encore sur frostfire
    if SCB.Bar.currentSchoolKey == "frostfire" then
        if SCB.Bar.texGivreFrostfire then SCB.Bar.texGivreFrostfire:SetAlpha(0) end
    end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end

    -- Toujours mettre à jour les particules en vol
    for _, p in ipairs(ambParts)   do UpdateAmbient(p, dt) end
    for _, p in ipairs(frontParts) do UpdateFrontParticle(p, dt) end
    for _, m in ipairs(mists)      do UpdateMist(m, dt) end

    -- Fill effects (flammes)
    UpdateFillEffects(dt)

    -- Spawn ambient
    ambSpawnAcc = ambSpawnAcc + dt
    if ambSpawnAcc >= AMB_SPAWN then
        ambSpawnAcc = 0
        SpawnAmbient(progress)
    end

    -- Spawn front
    frontSpawnAcc = frontSpawnAcc + dt
    if frontSpawnAcc >= FRONT_SPAWN then
        frontSpawnAcc = 0
        local count = math.random(2, 4)
        for _ = 1, count do SpawnFrontParticle(frontX, cy) end
    end
end
