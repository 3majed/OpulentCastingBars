-- ============================================================
--  Opulent Casting Bars — Particles_Void.lua
--
--  École Void — Demon Hunter Dévoreur (Midnight)
--
--  Architecture calquée sur Particles_Lava :
--  · Vortex  : Vortex.tga rotation constante/accélérée (77px, +20px)
--  · Light   : Frame_Void_Light clip gauche→droite, 100% opaque
--  · Embers  : fragments void éjectés depuis le front (gravité vers le haut)
--  · Sparks  : micro-étincelles cyan
--  · Amb     : particules ambiantes sur la barre
-- ============================================================

local FX = {}
SCB.FX         = SCB.FX or {}
SCB.FX["void"] = FX

local function rand(a, b)    return a + math.random() * (b - a) end
local function rad(deg)      return deg * math.pi / 180 end
local function lerp(a, b, t) return a + (b - a) * math.max(0, math.min(t, 1)) end

local function SetTexSize(tex, w, h)
    tex:SetWidth(w)
    tex:SetHeight(h)
end

-- ============================================================
--  PALETTE VOID
-- ============================================================

local EMBER_COLORS = {
    { 0.62, 0.30, 1.00 },
    { 0.42, 0.18, 0.98 },
    { 0.22, 0.72, 1.00 },
}

local SPARK_COLORS = {
    { 0.50, 0.85, 1.00, 1.00 },
    { 0.65, 0.78, 1.00, 0.90 },
    { 0.70, 0.35, 1.00, 0.82 },
    { 0.38, 0.64, 1.00, 0.72 },
    { 0.82, 0.48, 1.00, 0.58 },
}

-- ============================================================
--  CONSTANTES — VORTEX
-- ============================================================

local VORTEX_SIZE     = 38
local VORTEX_OFFSET_Y = 35
local VORTEX_OFFSET_X = -5    -- décalé de 5px vers la droite (était -10)
local VORTEX_ROT_SPEED = 0.55  -- rad/s, rotation constante douce
local VORTEX_ALPHA    = 1.00
local SHOW_BACKGROUND_VORTEX = true
local SHOW_FILL_VORTEX = false
local VORTEX_TEX       = SCB.TEX_PATH .. "void\\Vortex"
local VORTEX_SMALL_TEX = VORTEX_TEX

-- The original addon masks the fill vortex with Fill_Void.tga, whose
-- visible alpha lives in this narrow band of the 1024x512 source image.
-- WotLK cannot use that texture as a real alpha mask, so the ScrollFrame
-- fallback clips the vortex to the same vertical strip instead.
local VORTEX_FILL_MASK_TOP    = 231 / 512
local VORTEX_FILL_MASK_BOTTOM = 303 / 512

-- ============================================================
--  CONSTANTES — STONES (orbitent vers le centre du vortex)
-- ============================================================

local STONE_COUNT      = 28
local STONE_SPAWN_RATE = 0.18   -- s entre apparitions
local STONE_SIZE_MIN   = 4
local STONE_SIZE_MAX   = 10
local STONE_SIZE_SCALE = 1.5
local STONE_RADIUS_MIN = 28     -- rayon de départ (px)
local STONE_RADIUS_MAX = 55
local STONE_LIFE_MIN   = 1.2
local STONE_LIFE_MAX   = 2.4
local STONE_ROT_MIN    = 2.5    -- rad/s angulaire
local STONE_ROT_MAX    = 5.0

-- ============================================================
--  CONSTANTES — EMBERS
-- ============================================================

local EMBER_COUNT = 90
local EMBER_SPAWN = 0.02

local emberTypes = {
    { sizeMin=6,  sizeMax=14, speedMin=20, speedMax=50,  lifeMin=0.9, lifeMax=1.8, gravity=-8,  spread=150, driftX=0.4 },
    { sizeMin=3,  sizeMax=7,  speedMin=60, speedMax=130, lifeMin=0.3, lifeMax=0.7, gravity=-10, spread=90,  driftX=0.0 },
    { sizeMin=4,  sizeMax=10, speedMin=30, speedMax=70,  lifeMin=0.7, lifeMax=1.3, gravity=-14, spread=110, driftX=0.2 },
}

-- ============================================================
--  CONSTANTES — SPARKS
-- ============================================================

local SPARK_COUNT     = 50
local SPARK_SPAWN     = 0.035
local SPARK_SIZE_MIN  = 2
local SPARK_SIZE_MAX  = 6
local SPARK_LIFE_MIN  = 0.4
local SPARK_LIFE_MAX  = 1.1
local SPARK_SPEED_MIN = 25
local SPARK_SPEED_MAX = 80
local SPARK_GRAVITY   = -20

-- ============================================================
--  CONSTANTES — AMBIANTES
-- ============================================================

local AMB_COUNT = 40
local AMB_SPAWN = 0.07

local PARTS_FADE_DUR = 0.8
local castDuration   = 5

-- ============================================================
--  ÉTAT INTERNE
-- ============================================================

local isActive      = false
local partsFading   = false
local partsFadeT    = 0
local emberParts    = {}
local sparkParts    = {}
local ambParts      = {}
local emberSpawnAcc = 0
local sparkSpawnAcc = 0
local ambSpawnAcc   = 0
local castProgress  = 0

local texVortex      = nil
local vortexAngle    = 0
local vortexBar      = nil
local vortexLayoutW  = nil
local vortexLayoutH  = nil
local texVortexFill  = nil
local vortexFillAngle = 0
local texLight    = nil
local maskLight   = nil
local lightBar    = nil

-- Vortex center (calculé à chaque frame)
local vortCX, vortCY = 0, 0

local stoneParts    = {}
local stoneSpawnAcc = 0

-- ============================================================
--  VORTEX
-- ============================================================

local function LayoutVortex()
    if not texVortex or not vortexBar then return end

    local barW = vortexBar:GetWidth()
    local barH = vortexBar:GetHeight()
    if not barW or barW <= 0 or not barH or barH <= 0 then return end
    if vortexLayoutW == barW and vortexLayoutH == barH then return end

    local defaultW = (SCB.Config.defaults and SCB.Config.defaults.barWidth) or 400
    local defaultH = (SCB.Config.defaults and SCB.Config.defaults.barHeight) or 200
    local scaleX = barW / defaultW
    local scaleY = barH / defaultH

    SetTexSize(texVortex, VORTEX_SIZE * scaleX, VORTEX_SIZE * scaleY)
    texVortex:ClearAllPoints()
    texVortex:SetPoint("CENTER", vortexBar, "CENTER",
        VORTEX_OFFSET_X * scaleX, VORTEX_OFFSET_Y * scaleY)

    vortexLayoutW, vortexLayoutH = barW, barH
end

local function InitVortex(container, bar)
    if not SHOW_BACKGROUND_VORTEX then
        texVortex = nil
        vortexBar = nil
        vortexLayoutW, vortexLayoutH = nil, nil
        vortexAngle = 0
        return
    end

    vortexBar = bar
    vortexLayoutW, vortexLayoutH = nil, nil

    -- Draw the medallion vortex above the frame art; the texture is small
    -- and feathered, so it stays inside the circular socket.
    texVortex = bar:CreateTexture(nil, "OVERLAY", nil, 1)
    texVortex:SetTexture(VORTEX_SMALL_TEX)
    texVortex:SetBlendMode("BLEND")
    texVortex:SetTexCoord(0, 1, 0, 1)
    LayoutVortex()
    texVortex:SetAlpha(VORTEX_ALPHA)
    texVortex:Hide()
    vortexAngle = 0
end

local function UpdateVortex(dt, globalFade)
    if not texVortex then return end
    LayoutVortex()
    texVortex:SetAlpha(VORTEX_ALPHA * (globalFade or 1))
    texVortex:Show()
end

-- ============================================================
--  VORTEX FILL (dans la fill bar, clippé par texMask de progression)
-- ============================================================

local texVortexFill2  = nil
local vortexFill2Angle = 0

-- ScrollFrame clip that reveals the (rotating) vortex overlays with cast
-- progress — 3.3.5a can't mask a self-animating texture (see Clip.lua).
local vortexClip = nil
local _vfBar, _vfL, _vfW, _vfY, _vfH, _vfProg = nil, 0, 0, 0, 0, 0

local function InitVortexFill(bar)
    if not SHOW_FILL_VORTEX then
        vortexClip = nil
        texVortexFill = nil
        texVortexFill2 = nil
        vortexFillAngle = 0
        vortexFill2Angle = 0
        return
    end

    local bW, bH = bar:GetWidth(), bar:GetHeight()
    local vW  = bW * 0.18
    local vH  = bH * 0.18
    local vW2 = vW * 0.20
    local vH2 = vH * 0.20

    -- Wrap the two rotating vortex overlays in a ScrollFrame clip so they
    -- reveal left→right with progress (native masks can't clip a texture
    -- that animates its own texcoords). They sit at the CENTER of the clip
    -- child, i.e. the centre of the fill region.
    vortexClip = SCB.Clip:New(bar)
    local child = vortexClip:GetChild()

    -- Vortex fill 1
    texVortexFill = child:CreateTexture(nil, "ARTWORK", nil, 2)
    texVortexFill:SetBlendMode("BLEND")
    texVortexFill:SetTexture(VORTEX_TEX)
    SetTexSize(texVortexFill, vW, vH)
    texVortexFill:SetPoint("CENTER", child, "CENTER", 0, 0)
    texVortexFill:SetAlpha(0)

    -- Vortex fill 2 : 50% de la taille du 1, même position, rotation constante
    texVortexFill2 = child:CreateTexture(nil, "ARTWORK", nil, 3)
    texVortexFill2:SetBlendMode("BLEND")
    texVortexFill2:SetTexture(VORTEX_TEX)
    SetTexSize(texVortexFill2, vW2, vH2)
    texVortexFill2:SetPoint("CENTER", child, "CENTER", 0, 0)
    texVortexFill2:SetAlpha(0)

    vortexFillAngle  = 0
    vortexFill2Angle = 0
end

local function UpdateVortexFill(dt, globalFade)
    if not texVortexFill then return end

    -- Reveal the clip window over the fill region at current progress.
    if vortexClip and _vfBar then
        vortexClip:Layout(_vfBar, _vfL, _vfW, _vfY, _vfH, _vfProg)
    end

    -- Vortex 1 : sens inverse, vitesse 0.7×
    vortexFillAngle = (vortexFillAngle - VORTEX_ROT_SPEED * 0.7 * dt) % (math.pi * 2)
    local c, s = math.cos(vortexFillAngle), math.sin(vortexFillAngle)
    texVortexFill:SetTexCoord(
        0.5+(-0.5)*c-(-0.5)*s, 0.5+(-0.5)*s+(-0.5)*c,
        0.5+(-0.5)*c-( 0.5)*s, 0.5+(-0.5)*s+( 0.5)*c,
        0.5+( 0.5)*c-(-0.5)*s, 0.5+( 0.5)*s+(-0.5)*c,
        0.5+( 0.5)*c-( 0.5)*s, 0.5+( 0.5)*s+( 0.5)*c
    )
    texVortexFill:SetAlpha(0.55 * (globalFade or 1))
    texVortexFill:Show()

    -- Vortex 2 : même sens que le vortex de fond, vitesse 1.3× (plus rapide)
    if texVortexFill2 then
        vortexFill2Angle = (vortexFill2Angle + VORTEX_ROT_SPEED * 1.3 * dt) % (math.pi * 2)
        local c2, s2 = math.cos(vortexFill2Angle), math.sin(vortexFill2Angle)
        texVortexFill2:SetTexCoord(
            0.5+(-0.5)*c2-(-0.5)*s2, 0.5+(-0.5)*s2+(-0.5)*c2,
            0.5+(-0.5)*c2-( 0.5)*s2, 0.5+(-0.5)*s2+( 0.5)*c2,
            0.5+( 0.5)*c2-(-0.5)*s2, 0.5+( 0.5)*s2+(-0.5)*c2,
            0.5+( 0.5)*c2-( 0.5)*s2, 0.5+( 0.5)*s2+( 0.5)*c2
        )
        texVortexFill2:SetAlpha(0.70 * (globalFade or 1))
        texVortexFill2:Show()
    end
end
--
--  · Rayon décroît en ease-in³ : lent au début, aspiration violente
--  · Vitesse angulaire ∝ 1/r (conservation moment cinétique)
--  · Perturbation sinusoïdale unique par stone (trajectoire irrégulière)
--  · Taille rétrécit en approchant du centre
--  · Couleur assombrit vers le noir au centre
-- ============================================================

local STONE_TEXS = {
    SCB.TEX_PATH .. "mining\\Stone_01",
    SCB.TEX_PATH .. "mining\\Stone_02",
    SCB.TEX_PATH .. "mining\\Stone_03",
    SCB.TEX_PATH .. "mining\\Stone_04",
    SCB.TEX_PATH .. "mining\\Stone_05",
    SCB.TEX_PATH .. "mining\\Stone_06",
}

local VOID_STONE_COLORS = {
    { 0.50, 0.15, 1.0 },
    { 0.35, 0.08, 0.9 },
    { 0.20, 0.50, 1.0 },
    { 0.60, 0.25, 1.0 },
}

local function InitStones(container)
    stoneParts = {}
    for i = 1, STONE_COUNT do
        local tex = container:CreateTexture(nil, "ARTWORK")
        tex:SetBlendMode("BLEND")
        tex:SetTexture(STONE_TEXS[((i-1) % 6) + 1])
        tex:SetAlpha(0)
        tex:Hide()
        stoneParts[i] = {
            tex=tex, active=false,
            angle=0, baseRadius=0, radius=0, angVel0=0,
            life=0, maxLife=0, baseSize=0,
            pertAmp=0, pertFreq=0, pertPhase=0,
            cr=0, cg=0, cb=0,
        }
    end
end

local function SpawnStone(cx, cy)
    for _, p in ipairs(stoneParts) do
        if not p.active then
            local col       = VOID_STONE_COLORS[math.random(#VOID_STONE_COLORS)]
            p.active        = true
            p.life          = 0
            p.maxLife       = rand(STONE_LIFE_MIN, STONE_LIFE_MAX)
            p.angle         = rand(0, math.pi * 2)
            p.baseRadius    = rand(STONE_RADIUS_MIN, STONE_RADIUS_MAX)
            p.radius        = p.baseRadius
            -- Sens de rotation aléatoire, vitesse de base aléatoire
            p.angVel0       = rand(STONE_ROT_MIN, STONE_ROT_MAX)
                              * (math.random() < 0.5 and 1 or -1)
            p.baseSize      = rand(STONE_SIZE_MIN, STONE_SIZE_MAX) * STONE_SIZE_SCALE
            -- Perturbation orbitale : légère déviation sinusoïdale
            p.pertAmp       = rand(3, 10)
            p.pertFreq      = rand(0.8, 2.8)
            p.pertPhase     = rand(0, math.pi * 2)
            p.cr, p.cg, p.cb = col[1], col[2], col[3]
            p.tex:SetSize(p.baseSize, p.baseSize)
            p.tex:SetVertexColor(p.cr, p.cg, p.cb)
            p.tex:SetAlpha(0)
            p.tex:Show()
            return
        end
    end
end

local function UpdateStones(dt, cx, cy, globalFade)
    for _, p in ipairs(stoneParts) do
        if p.active then
            p.life = p.life + dt
            local t = p.life / p.maxLife   -- 0..1
            if t >= 1 then
                p.active = false
                p.tex:SetAlpha(0)
                p.tex:Hide()
            else
                -- Ease-in³ : l'aspiration s'emballe en fin de vie
                local eased   = t * t * t
                p.radius      = p.baseRadius * (1 - eased)

                -- Conservation du moment cinétique : ω ∝ 1/r
                local rSafe   = math.max(p.radius, 1.0)
                local angVel  = p.angVel0 * (p.baseRadius / rSafe)
                -- Plafonner pour éviter aliasing visuel
                local maxAng  = STONE_ROT_MAX * 8
                angVel = math.max(-maxAng, math.min(maxAng, angVel))
                p.angle = p.angle + angVel * dt

                -- Perturbation : oscille perpendiculairement, s'estompe au centre
                local perturb = math.sin(p.pertPhase + p.life * p.pertFreq * math.pi * 2)
                                * p.pertAmp * (1 - eased)

                local px = cx + math.cos(p.angle) * (p.radius + perturb)
                local py = cy + math.sin(p.angle) * (p.radius + perturb * 0.55)

                p.tex:ClearAllPoints()
                p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", px, py)

                -- Rétrécissement progressif vers le centre
                local sz = math.max(1, p.baseSize * (1 - eased * 0.80))
                p.tex:SetSize(sz, sz)

                -- Assombrissement vers le noir au centre
                local bright = 1 - eased * 0.90
                p.tex:SetVertexColor(p.cr * bright, p.cg * bright, p.cb * bright)

                -- Alpha : fade-in court (0.12), plateau, extinction brutale
                local alpha
                if t < 0.12 then
                    alpha = t / 0.12
                elseif t < 0.82 then
                    alpha = 1.0
                else
                    alpha = (1 - t) / 0.18
                end
                p.tex:SetAlpha(math.max(0, alpha) * 1.0 * (globalFade or 1))
            end
        end
    end
end

-- ============================================================
--  LIGHT (clip gauche→droite, 100% opaque)
-- ============================================================

local function InitLight(container, bar)
    local school = SCB.Schools.data["void"]
    if school and school.frameLight then
        lightBar  = bar
        texLight  = nil
        maskLight = nil
        return
    end

    lightBar = bar
    texLight = bar:CreateTexture(nil, "ARTWORK", nil, 4)
    texLight:SetBlendMode("BLEND")
    texLight:SetTexture((school and school.light) or (SCB.TEX_PATH .. "void\\Frame_Void_Light"))
    texLight:SetAllPoints(bar)
    texLight:SetAlpha(0)
    texLight:Hide()

    maskLight = bar:CreateMaskTexture()
    maskLight:SetTexture("Interface\\BUTTONS\\WHITE8X8",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    maskLight:SetPoint("TOPLEFT",    bar, "TOPLEFT",    0, 0)
    maskLight:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
    maskLight:SetWidth(1)
    texLight:AddMaskTexture(maskLight)
end

local function UpdateLight(progress, globalFade)
    if not texLight or not maskLight then return end
    texLight:Show()
    texLight:SetAlpha(1.0 * (globalFade or 1))
    local bW = (lightBar and lightBar:GetWidth()) or texLight:GetWidth()
    local visW = math.max(1, bW * progress)
    maskLight:SetWidth(visW)
    maskLight:ClearAllPoints()
    maskLight:SetPoint("TOPLEFT",    lightBar or texLight, "TOPLEFT",    0, 0)
    maskLight:SetPoint("BOTTOMLEFT", lightBar or texLight, "BOTTOMLEFT", 0, 0)
end

-- ============================================================
--  EMBERS
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
            p.x       = wx + rand(-6, 6)
            p.y       = wy + rand(-8, 8)
            p.vx      = math.cos(angle) * speed
            p.vy      = math.sin(angle) * speed
            p.drift   = rand(-ptype.driftX, ptype.driftX) * 30
            p.tex:SetVertexColor(col[1], col[2], col[3])
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(1)
            p.tex:ClearAllPoints()
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
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local alpha
    if p.typeIdx == 2 then
        alpha = t < 0.15 and 1 or math.max(0, 1 - (t - 0.15) / 0.85)
    else
        alpha = t < 0.5 and 1 or math.max(0, (1 - t) / 0.5)
    end
    p.tex:SetAlpha(alpha * 0.9 * (globalFade or 1))
end

-- ============================================================
--  SPARKS
-- ============================================================

local function SpawnSpark(wx, wy)
    local col = SPARK_COLORS[math.random(#SPARK_COLORS)]
    for _, p in ipairs(sparkParts) do
        if not p.active then
            local angle = rad(rand(30, 150))
            local speed = rand(SPARK_SPEED_MIN, SPARK_SPEED_MAX)
            p.active    = true ; p.life = 0
            p.maxLife   = rand(SPARK_LIFE_MIN, SPARK_LIFE_MAX)
            p.x         = wx + rand(-4, 4)
            p.y         = wy + rand(-6, 6)
            p.vx        = math.cos(angle) * speed
            p.vy        = math.sin(angle) * speed
            p.baseAlpha = col[4]
            p.tex:SetVertexColor(col[1], col[2], col[3])
            local size = rand(SPARK_SIZE_MIN, SPARK_SIZE_MAX)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            p.tex:ClearAllPoints()
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
    p.tex:ClearAllPoints()
    p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
    local env
    if t < 0.15 then env = t / 0.15
    elseif t < 0.75 then env = 1 + math.sin(p.life * 18) * 0.15
    else env = (1 - t) / 0.25 end
    p.tex:SetAlpha(math.max(0, env) * p.baseAlpha * (globalFade or 1))
end

-- ============================================================
--  AMBIANTES
-- ============================================================

local function SpawnAmb(progress)
    local f = SCB.Bar.frame
    local cx, cy = f:GetCenter()
    if not cx then return end
    local barW, barH = f:GetWidth(), f:GetHeight()

    for _, p in ipairs(ambParts) do
        if not p.active then
            local xOffset = rand(-barW * 0.5, barW * 0.5 * progress - barW * 0.5)
            local yOffset = rand(-barH * 0.35, barH * 0.35)
            local wx, wy  = cx + xOffset, cy + yOffset
            local dirX    = xOffset > 0 and 1 or -1
            local angle   = rad(rand(60, 120)) * (yOffset > 0 and 1 or -1)
            local speed   = rand(15, 45)
            local col     = EMBER_COLORS[math.random(#EMBER_COLORS)]

            p.active  = true ; p.life = 0
            p.maxLife = rand(1.0, 2.2)
            p.x       = wx ; p.y = wy
            p.vx      = dirX * rand(5, 20)
            p.vy      = math.sin(angle) * speed
            p.tex:SetVertexColor(col[1], col[2], col[3])
            local size = rand(4, 10)
            p.tex:ClearAllPoints()
            p.tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", p.x, p.y)
            p.tex:SetSize(size, size)
            p.tex:SetAlpha(0)
            return
        end
    end
end

local function UpdateAmb(p, dt, globalFade)
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
    p.tex:SetAlpha(math.max(0, alpha) * 0.55 * (globalFade or 1))
end

-- ============================================================
--  API PUBLIQUE
-- ============================================================

function FX.Init(container, bar)
    InitVortex(container, bar)
    InitVortexFill(bar)
    InitLight(container, bar)
    InitStones(container)

    local voidSchool = SCB.Schools.data["void"]
    local miscTexs = {}

    -- Priorité: étoiles Holy réutilisées pour Void (Misc_Holy_01/02).
    if voidSchool then
        for _, t in ipairs(voidSchool.misc or {}) do miscTexs[#miscTexs+1] = t end
    end

    -- Fallback sécurité si la table misc est vide/corrompue.
    if #miscTexs == 0 then
        local earthSchool = SCB.Schools.data["earth"]
        if earthSchool then
            for _, t in ipairs(earthSchool.rocks  or {}) do miscTexs[#miscTexs+1] = t end
            for _, t in ipairs(earthSchool.debris or {}) do miscTexs[#miscTexs+1] = t end
        end
    end

    local function getMisc(i)
        if #miscTexs == 0 then return SCB.TEX_PATH .. "frost\\Particle_Frost_01" end
        return miscTexs[((i-1) % #miscTexs) + 1]
    end

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

    ambParts = {}
    for i = 1, AMB_COUNT do
        local tex = container:CreateTexture(nil, "BACKGROUND")
        tex:SetTexture(getMisc(i))
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        ambParts[i] = {
            tex=tex, active=false, life=0, maxLife=0,
            x=0, y=0, vx=0, vy=0,
        }
    end
end

function FX.Start(duration)
    castDuration  = duration or 5
    isActive      = true
    partsFading   = false
    castProgress  = 0
    emberSpawnAcc = 0
    sparkSpawnAcc = 0
    ambSpawnAcc   = 0
    stoneSpawnAcc = 0
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(sparkParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(ambParts)   do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(stoneParts) do p.active = false ; p.tex:SetAlpha(0) ; p.tex:Hide() end
    LayoutVortex()
    if texVortex      then texVortex:Show()      end
    if texVortexFill  then texVortexFill:Show()  end
    if texVortexFill2 then texVortexFill2:Show() end
    if texLight       then texLight:Show()       end
end

function FX.Stop()
    isActive      = false
    partsFading   = true
    partsFadeT    = 0
    emberSpawnAcc = 0
    sparkSpawnAcc = 0
    ambSpawnAcc   = 0
end

function FX.UpdateFade(dt)
    if not partsFading then return end
    partsFadeT = partsFadeT + dt
    local gFade = math.max(0, 1 - partsFadeT / PARTS_FADE_DUR)
    UpdateVortex(dt, gFade)
    UpdateVortexFill(dt, gFade)
    UpdateLight(castProgress, gFade)
    UpdateStones(dt, vortCX, vortCY, gFade)
    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, gFade) end
    for _, p in ipairs(sparkParts) do UpdateSpark(p, dt, gFade) end
    for _, p in ipairs(ambParts)   do UpdateAmb(p,   dt, gFade) end
    if partsFadeT >= PARTS_FADE_DUR then
        partsFading = false
        if texVortex      then texVortex:SetAlpha(0)      ; texVortex:Hide()      end
        if texVortexFill  then texVortexFill:SetAlpha(0)  ; texVortexFill:Hide()  end
        if texVortexFill2 then texVortexFill2:SetAlpha(0) ; texVortexFill2:Hide() end
        if texLight       then texLight:SetAlpha(0)       ; texLight:Hide()       end
        for _, p in ipairs(stoneParts) do p.active = false ; p.tex:SetAlpha(0) ; p.tex:Hide() end
        for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(sparkParts) do p.active = false ; p.tex:SetAlpha(0) end
        for _, p in ipairs(ambParts)   do p.active = false ; p.tex:SetAlpha(0) end
    end
end

function FX.Reset()
    partsFading = false
    if vortexClip     then vortexClip:Hide() end
    if texVortex      then texVortex:SetAlpha(0)      ; texVortex:Hide()      end
    if texVortexFill  then texVortexFill:SetAlpha(0)  ; texVortexFill:Hide()  end
    if texVortexFill2 then texVortexFill2:SetAlpha(0) ; texVortexFill2:Hide() end
    if texLight       then texLight:SetAlpha(0)       ; texLight:Hide()       end
    for _, p in ipairs(stoneParts) do p.active = false ; p.tex:SetAlpha(0) ; p.tex:Hide() end
    for _, p in ipairs(emberParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(sparkParts) do p.active = false ; p.tex:SetAlpha(0) end
    for _, p in ipairs(ambParts)   do p.active = false ; p.tex:SetAlpha(0) end
end

function FX.Update(dt, progress, frontX, cy, barW, barH, fillLX, fillW)
    if not isActive then return end
    castProgress = progress or 0

    local f = SCB.Bar.frameInner
    local barCX, barCY = f:GetCenter()
    if not barCY then return end

    -- Centre du vortex en coords écran
    vortCX = barCX + VORTEX_OFFSET_X
    vortCY = barCY + VORTEX_OFFSET_Y

    -- Géométrie (bar-local) pour le clip ScrollFrame du vortex fill
    local vs = SCB.Schools.data["void"]
    _vfBar  = f
    _vfL    = (vs and vs.fillMarginL or 0) * barW + (vs and vs.fillMarginLPx or 0)
    _vfW    = fillW or barW
    local fullH = barH or f:GetHeight()
    _vfY    = fullH * (0.5 - (VORTEX_FILL_MASK_TOP + VORTEX_FILL_MASK_BOTTOM) * 0.5)
    _vfH    = math.max(1, fullH * (VORTEX_FILL_MASK_BOTTOM - VORTEX_FILL_MASK_TOP))
    _vfProg = castProgress

    UpdateVortex(dt, 1)
    UpdateVortexFill(dt, 1)
    UpdateLight(castProgress, 1)

    -- Stones orbitales aspirées vers le vortex
    UpdateStones(dt, vortCX, vortCY, 1)
    stoneSpawnAcc = stoneSpawnAcc + dt
    if stoneSpawnAcc >= STONE_SPAWN_RATE then
        stoneSpawnAcc = 0
        SpawnStone(vortCX, vortCY)
    end

    for _, p in ipairs(emberParts) do UpdateEmber(p, dt, 1) end
    emberSpawnAcc = emberSpawnAcc + dt
    if emberSpawnAcc >= EMBER_SPAWN then
        emberSpawnAcc = 0
        local count = math.random(3, 6)
        for _ = 1, count do SpawnEmber(frontX, barCY) end
    end

    for _, p in ipairs(sparkParts) do UpdateSpark(p, dt, 1) end
    sparkSpawnAcc = sparkSpawnAcc + dt
    if sparkSpawnAcc >= SPARK_SPAWN then
        sparkSpawnAcc = 0
        local count = math.random(2, 4)
        for _ = 1, count do SpawnSpark(frontX, barCY) end
    end

    for _, p in ipairs(ambParts) do UpdateAmb(p, dt, 1) end
    ambSpawnAcc = ambSpawnAcc + dt
    if ambSpawnAcc >= AMB_SPAWN then
        ambSpawnAcc = 0
        SpawnAmb(castProgress)
    end
end
