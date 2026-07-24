-- ============================================================
--  Opulent Casting Bars — Schools.lua
-- ============================================================

SCB.Schools = {}

-- ---- Définitions des écoles --------------------------------
SCB.Schools.data = {

    shadow = {
        name          = "Shadow",
        contour       = nil,
        frame         = SCB.TEX_PATH .. "shadow\\Frame_Shadow",
        fill          = SCB.TEX_PATH .. "shadow\\Fill_Shadow",
        bg            = SCB.TEX_PATH .. "shadow\\BG_Shadow",
        uvSpeed       = 0,
        uvDir         = 1,
        fillMarginL   = 0.1484,
        fillMarginR   = 0.1396,
        textNameOffX  =  31,
        textTimerOffX = -31,
        textOffY      =  2,
        bgFastFade    = true,   -- BG disparaît 2x plus vite que le reste au fade out
        circle  = SCB.TEX_PATH .. "shadow\\Circle_Shadow",
        contours = {
            SCB.TEX_PATH .. "shadow\\Flame_Shadow_01",
            SCB.TEX_PATH .. "shadow\\Flame_Shadow_02",
            SCB.TEX_PATH .. "shadow\\Flame_Shadow_03",
            SCB.TEX_PATH .. "shadow\\Flame_Shadow_04",
            SCB.TEX_PATH .. "shadow\\Flame_Shadow_05",
        },
    },

    nature = {
        name        = "Nature",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "nature\\Frame_Nature_01",
        fill        = SCB.TEX_PATH .. "nature\\Fill_Nature",
        bg          = SCB.TEX_PATH .. "nature\\BG_Nature",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        frames = {
            SCB.TEX_PATH .. "nature\\Frame_Nature_01",
            SCB.TEX_PATH .. "nature\\Frame_Nature_02",
            SCB.TEX_PATH .. "nature\\Frame_Nature_03",
        },
        leaves = {
            SCB.TEX_PATH .. "nature\\Leaf_01",
            SCB.TEX_PATH .. "nature\\Leaf_02",
            SCB.TEX_PATH .. "nature\\Leaf_03",
            SCB.TEX_PATH .. "nature\\Leaf_04",
            SCB.TEX_PATH .. "nature\\Leaf_05",
        },
    },

    thunder = {
        name        = "Thunder",
        bg          = SCB.TEX_PATH .. "thunder\\BG_Thunder",
        fill        = SCB.TEX_PATH .. "thunder\\Fill_Thunder",
        frame       = SCB.TEX_PATH .. "thunder\\Frame_Thunder",
        fillMarginL = 0.1709,
        fillMarginR = 0.1562,
        textOffY    = -2,
        textNameOffX  = 20,
        textTimerOffX = -21,
        light       = SCB.TEX_PATH .. "thunder\\Light_Thunder",
        lightnings  = {
            SCB.TEX_PATH .. "thunder\\Lightning_01",
            SCB.TEX_PATH .. "thunder\\Lightning_02",
            SCB.TEX_PATH .. "thunder\\Lightning_03",
        },
    },

    -- ---- Aim (Chasseur) — double fill symétrique vers le centre ----
    aim = {
        name         = "Aim",
        bg           = SCB.TEX_PATH .. "aim\\BG_Aim",
        -- fill standard caché — la barre utilise fillLeft + fillRight
        fill         = SCB.TEX_PATH .. "aim\\Fill_Left_Aim",
        fillLeft     = SCB.TEX_PATH .. "aim\\Fill_Left_Aim",
        fillRight    = SCB.TEX_PATH .. "aim\\Fill_Right_Aim",
        fillEnding   = SCB.TEX_PATH .. "aim\\Fill_Aim_Ending",
        frame        = SCB.TEX_PATH .. "aim\\Frame_Aim",
        splitFill    = true,   -- double fill symétrique (Left + Right → centre)
        fillMarginL  = 0.0908,
        fillMarginR  = 0.0977,
        textOffY     = 2,
        -- Particules : feuilles Nature + Misc_Skinning pour la variété
        leaves = {
            SCB.TEX_PATH .. "nature\\Leaf_01",
            SCB.TEX_PATH .. "nature\\Leaf_02",
            SCB.TEX_PATH .. "nature\\Leaf_03",
            SCB.TEX_PATH .. "nature\\Leaf_04",
            SCB.TEX_PATH .. "nature\\Leaf_05",
        },
        misc = {
            SCB.TEX_PATH .. "skinning\\Misc_Skinning_01",
            SCB.TEX_PATH .. "skinning\\Misc_Skinning_02",
        },
    },

    chaos = {
        name         = "Chaos",
        frame        = SCB.TEX_PATH .. "chaos\\Frame_Chaos",
        fill         = SCB.TEX_PATH .. "chaos\\Fill_Chaos",
        bg           = SCB.TEX_PATH .. "chaos\\BG_Chaos",
        fillMarginL  = 0.1221,
        fillMarginR  = 0.1162,
        spikes       = {
            SCB.TEX_PATH .. "chaos\\Spike_01",
            SCB.TEX_PATH .. "chaos\\Spike_02",
            SCB.TEX_PATH .. "chaos\\Spike_03",
            SCB.TEX_PATH .. "chaos\\Spike_04",
            SCB.TEX_PATH .. "chaos\\Spike_05",
            SCB.TEX_PATH .. "chaos\\Spike_06",
            SCB.TEX_PATH .. "chaos\\Spike_07",
            SCB.TEX_PATH .. "chaos\\Spike_08",
            SCB.TEX_PATH .. "chaos\\Spike_09",
        },
        spikeBGs     = {
            SCB.TEX_PATH .. "chaos\\Spike_BG_01",
            SCB.TEX_PATH .. "chaos\\Spike_BG_02",
            SCB.TEX_PATH .. "chaos\\Spike_BG_03",
            SCB.TEX_PATH .. "chaos\\Spike_BG_04",
        },
    },

    holy = {
        name         = "Holy",
        frame        = SCB.TEX_PATH .. "holy\\Frame_Holy",
        fill         = SCB.TEX_PATH .. "holy\\Fill_Holy",
        bg           = SCB.TEX_PATH .. "holy\\BG_Holy",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.1758,
        fillMarginR  = 0.1709,
        light        = SCB.TEX_PATH .. "holy\\Light_Holy",
        stars        = SCB.TEX_PATH .. "holy\\Stars_Holy",
        misc         = {
            SCB.TEX_PATH .. "holy\\Misc_Holy_01",
            SCB.TEX_PATH .. "holy\\Misc_Holy_02",
        },
        textNameOffX  =  19,
        textTimerOffX = -25,
        textOffY      =   2,
    },

    moon = {
        name         = "Moon",
        frame        = SCB.TEX_PATH .. "moon\\Frame_Moon",
        fill         = SCB.TEX_PATH .. "moon\\Fill_Moon",
        bg           = SCB.TEX_PATH .. "moon\\BG_Moon",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.0908,   -- calé sur Neutral
        fillMarginR  = 0.0977,
        textOffY     = 2,
        light        = SCB.TEX_PATH .. "moon\\Frame_Moon_Light",
        -- Réutilise les Misc_Holy recolorés en cyan par SetVertexColor dans Particles_Moon
        misc         = {
            SCB.TEX_PATH .. "holy\\Misc_Holy_01",
            SCB.TEX_PATH .. "holy\\Misc_Holy_02",
        },
    },

    water = {
        name          = "Water",
        frame         = SCB.TEX_PATH .. "water\\Frame_Water",
        fill          = SCB.TEX_PATH .. "water\\Fill_Water",
        bg            = SCB.TEX_PATH .. "water\\BG_Water",
        uvSpeed       = 0,
        uvDir         = 1,
        fillMarginL   = 0.19,
        fillMarginR   = 0.21,
        textOffY      = 2,
        textNameOffX  = 40,   -- nom du sort +40 px vers la droite
        textTimerOffX = -40,  -- timer -40 px vers la gauche
        -- Frame_Water_Light révélée progressivement (masque gauche→droite)
        light         = SCB.TEX_PATH .. "water\\Frame_Water_Light",
        -- Anneau d'eau animé (cercles masqués au bord de la barre)
        circle        = SCB.TEX_PATH .. "water\\Water_Circle",
    },

    fists = {
        name         = "Fists of Fury",
        frame        = SCB.TEX_PATH .. "fists\\Frame_Fists",
        fill         = SCB.TEX_PATH .. "fists\\Fill_Fists",
        bg           = SCB.TEX_PATH .. "fists\\BG_Fists",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.1533,   -- +25 px vs Neutral (fill démarre après la déco gauche)
        fillMarginR  = 0.0977,
        noReverse    = true,     -- barre canalisée progresse gauche→droite (pas de sens inverse)
        textOffY      = 2,
        textNameOffX  = 35,
        textTimerOffX = -15,
        light        = SCB.TEX_PATH .. "fists\\Frame_Fists_Light",
        fists = {
            SCB.TEX_PATH .. "fists\\Fists_01",
            SCB.TEX_PATH .. "fists\\Fists_02",
            SCB.TEX_PATH .. "fists\\Fists_03",
            SCB.TEX_PATH .. "fists\\Fists_04",
            SCB.TEX_PATH .. "fists\\Fists_Small",
        },
        -- Feuilles roses dédiées (Particles_Fists)
        leaves = {
            SCB.TEX_PATH .. "fists\\Leafpink_01",
            SCB.TEX_PATH .. "fists\\Leafpink_02",
            SCB.TEX_PATH .. "fists\\Leafpink_03",
            SCB.TEX_PATH .. "fists\\Leafpink_04",
            SCB.TEX_PATH .. "fists\\Leafpink_05",
        },
    },

    mistweaver = {
        name         = "Mistweaver",
        frame        = SCB.TEX_PATH .. "mistweaver\\Frame_Mistweaver",
        fill         = SCB.TEX_PATH .. "mistweaver\\Fill_Mistweaver",
        bg           = SCB.TEX_PATH .. "mistweaver\\BG_Mistweaver",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.0908,
        fillMarginLPx = 20,
        fillMarginR  = 0.0977,
        textOffY     = 2,
        textNameOffX = 35,
        light        = SCB.TEX_PATH .. "mistweaver\\Frame_Mistweaver_Light",
    },

    chiji = {
        name         = "Chi'ji",
        frame        = SCB.TEX_PATH .. "chiji\\Frame_Chiji",
        fill         = SCB.TEX_PATH .. "chiji\\Fill_Chiji",
        bg           = SCB.TEX_PATH .. "chiji\\BG_Chiji",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.0908,
        fillMarginLPx = 20,
        fillMarginR  = 0.0977,
        textOffY     = 2,
        textNameOffX = 35,
        light        = SCB.TEX_PATH .. "chiji\\Frame_Chiji_Light",
    },

    sacred = {
        name         = "Sacred",
        frame        = SCB.TEX_PATH .. "sacred\\Frame_Sacred",
        fill         = SCB.TEX_PATH .. "sacred\\Fill_Sacred",
        bg           = SCB.TEX_PATH .. "sacred\\BG_Sacred",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.1258,
        fillMarginR  = 0.1460,
        light        = SCB.TEX_PATH .. "sacred\\Frame_Sacred_Light",
        misc         = {
            SCB.TEX_PATH .. "holy\\Misc_Holy_01",
            SCB.TEX_PATH .. "holy\\Misc_Holy_02",
        },
        textNameOffX  =  -1,
        textTimerOffX =  -5,
        textOffY      = -11,
    },

    paladin = {
        name         = "Paladin",
        frame        = SCB.TEX_PATH .. "paladin\\Frame_Paladin",
        fill         = SCB.TEX_PATH .. "paladin\\Fill_Paladin",
        bg           = SCB.TEX_PATH .. "paladin\\BG_Paladin",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.075,
        fillMarginR  = 0.121,
        light        = SCB.TEX_PATH .. "paladin\\Frame_Paladin_Light",
        misc         = {
            SCB.TEX_PATH .. "holy\\Misc_Holy_01",
            SCB.TEX_PATH .. "holy\\Misc_Holy_02",
        },
        textNameOffX  =  -1,
        textTimerOffX =  -5,
        textOffY      = -11,
    },

    arcane = {
        name         = "Arcane",
        frame        = SCB.TEX_PATH .. "arcane\\Frame_Arcane",
        fill         = SCB.TEX_PATH .. "arcane\\Fill_Arcane",
        bg           = SCB.TEX_PATH .. "arcane\\BG_Arcane",
        contour      = nil,
        uvSpeed      = 0,
        uvDir        = 1,
        -- Marges du Fill_Mask (les pixels vides sont dans le mask, pas le fill)
        fillMarginL  = 0.1377,
        fillMarginR  = 0.1475,
        -- Textures spéciales gérées par Particles_Arcane
        fillMask     = SCB.TEX_PATH .. "arcane\\Fill_Mask",
        fillBar      = SCB.TEX_PATH .. "arcane\\Fill_Bar_Arcane",
        runeBack     = SCB.TEX_PATH .. "arcane\\Rune_Back",
        rune01       = SCB.TEX_PATH .. "arcane\\Rune_01",
        rune02       = SCB.TEX_PATH .. "arcane\\Rune_02",
        textNameOffX  = 6,
        textTimerOffX = -14,
    },

    arcaneum = {
        name         = "Arcaneum",
        barScale     = 1.15,
        -- Réutilisation Arctic demandée + nouveaux assets Arcaneum
        frame        = SCB.TEX_PATH .. "arctic\\Frame_Arctic",
        frameLight   = SCB.TEX_PATH .. "arcaneum\\Frame_Arcaneum_Light",
        fill         = SCB.TEX_PATH .. "arcaneum\\Fill_Arcaneum",
        bg           = SCB.TEX_PATH .. "arctic\\BG_Arctic",
        fillMarginL  = 0.0908,
        fillMarginR  = 0.0977,
        fillMarginRPx = 20,
        textOffY      = 4,
        textNameOffX  = 35,
        textTimerOffX = -35,
        rune01       = SCB.TEX_PATH .. "arcane\\Rune_01",
        rune02       = SCB.TEX_PATH .. "arcane\\Rune_02",
    },

    fishing = {
        name        = "Fishing",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "fishing\\Frame_Fishing",
        fill        = SCB.TEX_PATH .. "fishing\\Fill_Fishing",
        bg          = SCB.TEX_PATH .. "fishing\\BG_Fishing",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textTimerOffX = -5,
        textOffY    = 2,
    },

    fishing = {
        name        = "Fishing",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "fishing\\Frame_Fishing",
        fill        = SCB.TEX_PATH .. "fishing\\Fill_Fishing",
        bg          = SCB.TEX_PATH .. "fishing\\BG_Fishing",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textTimerOffX = -5,
        textOffY    = 2,
    },



    skinning = {
        name        = "Skinning",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "skinning\\Frame_Skinning",
        fill        = SCB.TEX_PATH .. "skinning\\Fill_Skinning",
        bg          = SCB.TEX_PATH .. "skinning\\BG_Skinning",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        reverseFill = true,
        reverseDir  = true,
        textOffY    = 2,
        misc = {
            SCB.TEX_PATH .. "skinning\\Misc_Skinning_01",
            SCB.TEX_PATH .. "skinning\\Misc_Skinning_02",
        },
    },
    mining = {
        name        = "Mining",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "mining\\Frame_Mining",
        fill        = SCB.TEX_PATH .. "mining\\Fill_Mining",
        bg          = SCB.TEX_PATH .. "mining\\BG_Mining",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
        stones = {
            SCB.TEX_PATH .. "mining\\Stone_01",
            SCB.TEX_PATH .. "mining\\Stone_02",
            SCB.TEX_PATH .. "mining\\Stone_03",
            SCB.TEX_PATH .. "mining\\Stone_04",
            SCB.TEX_PATH .. "mining\\Stone_05",
            SCB.TEX_PATH .. "mining\\Stone_06",
        },
    },

    -- ---- Lumber (récolte de bois) — pas de fill classique ----
    -- La progression est matérialisée par un changement de texture (01→05)
    -- géré via une texture dédiée dans le particleContainer (Particles_Lumber.lua).
    -- texBG est masqué en début de cast et restauré à la fin.
    lumber = {
        name        = "Lumber",
        barScale    = 0.80,   -- barre 20% plus petite
        contour     = nil,
        -- bg : texture initiale utilisée par ApplySchool, masquée en jeu par le FX.
        bg          = SCB.TEX_PATH .. "lumber\\Lumber_01",
        fill        = SCB.TEX_PATH .. "lumber\\Lumber_01",
        frame       = nil,
        fillMask          = true,   -- cache texFill (pas de barre de progression classique)
        noCompletionHold  = true,   -- pas de hold/highlight de fin (split visuel géré par le FX)
        fillMarginL = 0,
        fillMarginR = 0,
        uvSpeed     = 0,
        uvDir       = 1,
        textOffY    = 0,
        -- Textures des stages et morceaux (référencées par Particles_Lumber)
        lumberStages = {
            SCB.TEX_PATH .. "lumber\\Lumber_01",
            SCB.TEX_PATH .. "lumber\\Lumber_02",
            SCB.TEX_PATH .. "lumber\\Lumber_03",
            SCB.TEX_PATH .. "lumber\\Lumber_04",
            SCB.TEX_PATH .. "lumber\\Lumber_05",
        },
        lumberLeft  = SCB.TEX_PATH .. "lumber\\Lumber_Left",
        lumberRight = SCB.TEX_PATH .. "lumber\\Lumber_Right",
        misc = {
            SCB.TEX_PATH .. "lumber\\Lumber_Misc_01",
            SCB.TEX_PATH .. "lumber\\Lumber_Misc_02",
            SCB.TEX_PATH .. "lumber\\Lumber_Misc_03",
            SCB.TEX_PATH .. "lumber\\Lumber_Misc_04",
            SCB.TEX_PATH .. "lumber\\Lumber_Misc_05",
        },
    },

    void = {
        name         = "Void",
        frame        = SCB.TEX_PATH .. "void\\Frame_Void",
        fill         = SCB.TEX_PATH .. "void\\Fill_Void",
        bg           = SCB.TEX_PATH .. "void\\BG_Void",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.0908,   -- calé sur Neutral
        fillMarginR  = 0.0977,
        textOffY     = 2,
        light        = SCB.TEX_PATH .. "void\\Frame_Void_Light",
        vortex       = SCB.TEX_PATH .. "void\\Vortex",
        -- Réutilise les étoiles Holy, recolorées en violet/cyan dans Particles_Void
        misc         = {
            SCB.TEX_PATH .. "holy\\Misc_Holy_01",
            SCB.TEX_PATH .. "holy\\Misc_Holy_02",
        },
    },

    herbalism = {
        name        = "Herbalism",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "herbalism\\Frame_Herbalism_01",
        fill        = SCB.TEX_PATH .. "herbalism\\Fill_Herbalism",
        bg          = SCB.TEX_PATH .. "herbalism\\BG_Herbalism",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY     = 2,
        textNameOffX  =  10,   -- décalage nom +10px droite
        textTimerOffX = -12,   -- décalage timer -12px gauche
        frames = {
            SCB.TEX_PATH .. "herbalism\\Frame_Herbalism_01",
            SCB.TEX_PATH .. "herbalism\\Frame_Herbalism_02",
            SCB.TEX_PATH .. "herbalism\\Frame_Herbalism_03",
        },
        -- Réutilise les feuilles de Nature
        leaves = {
            SCB.TEX_PATH .. "nature\\Leaf_01",
            SCB.TEX_PATH .. "nature\\Leaf_02",
            SCB.TEX_PATH .. "nature\\Leaf_03",
            SCB.TEX_PATH .. "nature\\Leaf_04",
            SCB.TEX_PATH .. "nature\\Leaf_05",
        },
    },

    earth = {
        name        = "Earth",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "earth\\Frame_Earth",
        fill        = SCB.TEX_PATH .. "earth\\Fill_Earth",
        bg          = SCB.TEX_PATH .. "earth\\BG_Earth",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.1230,
        fillMarginR = 0.1084,
        rocks = {
            SCB.TEX_PATH .. "earth\\Misc_Earth_01",
            SCB.TEX_PATH .. "earth\\Misc_Earth_02",
            SCB.TEX_PATH .. "earth\\Misc_Earth_03",
            SCB.TEX_PATH .. "earth\\Misc_Earth_04",
        },
        debris = {
            SCB.TEX_PATH .. "earth\\Misc_Earth_05",
            SCB.TEX_PATH .. "earth\\Misc_Earth_06",
            SCB.TEX_PATH .. "earth\\Misc_Earth_07",
            SCB.TEX_PATH .. "earth\\Misc_Earth_08",
            SCB.TEX_PATH .. "earth\\Misc_Earth_09",
            SCB.TEX_PATH .. "earth\\Misc_Earth_10",
            SCB.TEX_PATH .. "earth\\Misc_Earth_11",
        },
        textOffY = 2,
    },

    neutral = {
        name        = "Neutral",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "neutral\\Frame_Neutral",
        fill        = SCB.TEX_PATH .. "neutral\\Fill_Neutral",
        bg          = SCB.TEX_PATH .. "neutral\\BG_Neutral",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
    },

    neutral3 = {
        name        = "Neutral 3",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "neutral3\\Frame_Neutral3",
        fill        = SCB.TEX_PATH .. "neutral3\\Fill_Neutral3",
        bg          = SCB.TEX_PATH .. "neutral3\\BG_Neutral3",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
    },

    neutral2 = {
        name        = "Neutral 2",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "neutral2\\Frame_Neutral2",
        fill        = SCB.TEX_PATH .. "neutral2\\Fill_Neutral2",
        bg          = SCB.TEX_PATH .. "neutral2\\BG_Neutral2",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
        -- Réutilise les feuilles de Nature, recolorées en cyan par SetVertexColor
        leaves = {
            SCB.TEX_PATH .. "nature\\Leaf_01",
            SCB.TEX_PATH .. "nature\\Leaf_02",
            SCB.TEX_PATH .. "nature\\Leaf_03",
            SCB.TEX_PATH .. "nature\\Leaf_04",
            SCB.TEX_PATH .. "nature\\Leaf_05",
        },
    },

    viking = {
        name        = "Viking Icon",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "viking\\Frame_Neutral2_Ennemy",
        fill        = SCB.TEX_PATH .. "viking\\Fill_Neutral2_Ennemy",
        bg          = SCB.TEX_PATH .. "viking\\BG_Neutral2_Ennemy",
        bubble      = SCB.TEX_PATH .. "viking\\Bulle_Neutral2_Ennemy",
        circle      = SCB.TEX_PATH .. "viking\\Circle_Neutral2_Ennemy",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.2250,
        fillMarginR = 0.0850,
        textNameOffX = 57,
        textOffY    = 2,
    },

    metal = {
        name        = "Neutral - Metal",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "metal\\Frame_Metal",
        fill        = SCB.TEX_PATH .. "metal\\Fill_Metal",
        bg          = SCB.TEX_PATH .. "metal\\BG_Metal",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
    },


    engrenages = {
        name          = "Engrenages",
        contour       = nil,
        frame         = SCB.TEX_PATH .. "engrenages\\Frame_Engrenages",
        fill          = SCB.TEX_PATH .. "engrenages\\Fill_Engrenages",
        bg            = SCB.TEX_PATH .. "engrenages\\BG_Engrenages",
        uvSpeed       = 0,
        uvDir         = 1,
        fillMarginL   = 0.1880,
        fillMarginR   = 0.0600,
        textNameOffX  = 62,
        textTimerOffX = 16,
        textOffY      = 2,
        misc          = SCB.TEX_PATH .. "engrenages\\Misc_Engrenages",
        iconMask      = SCB.TEX_PATH .. "engrenages\\Mask_Icon_Engrenages",
        circle        = SCB.TEX_PATH .. "engrenages\\Circle_Engrenages",
        fork          = SCB.TEX_PATH .. "engrenages\\Fork_Engrenages",
    },

    metal_icon = {
        name         = "Metal Icon",
        contour      = nil,
        frame        = SCB.TEX_PATH .. "Metal_Icon\\Frame_Metalicon",
        fill         = SCB.TEX_PATH .. "Metal_Icon\\Fill_Metalicon",
        bg           = SCB.TEX_PATH .. "Metal_Icon\\BG_Metalicon",
        uvSpeed      = 0,
        uvDir        = 1,
        -- Longueur utile de Fill_Metalicon (calée sur la texture fournie)
        fillMarginL   = 0.1820,
        fillMarginR   = 0.0600,
        -- Ajustements texte demandés
        textNameOffX  = 37,  -- -20px (était 57)
        textTimerOffX = 8,   -- +8px vers la droite
        textOffY      = 2,
    },

    honey_icon = {
        name          = "Honey - Icons",
        contour       = nil,
        frame         = SCB.TEX_PATH .. "honey\\Frame_Honey_Icon",
        fill          = SCB.TEX_PATH .. "honey\\Fill_Honey_Icon",
        bg            = SCB.TEX_PATH .. "honey\\BG_Honey_Icon",
        uvSpeed       = 0,
        uvDir         = 1,
        -- Calé sur le contenu utile de la texture (évite débordement gauche/droite)
        fillMarginL   = 0.1960,
        fillMarginR   = 0.1380,
        textNameOffX  = 52,
        textTimerOffX = -5,
        textOffY      = 2,
    },

    mossystone_icon = {
        name          = "Mossy Stone - Icons",
        contour       = nil,
        frame         = SCB.TEX_PATH .. "mossystone\\Frame_Mossystone_Icon",
        frameLight    = SCB.TEX_PATH .. "mossystone\\Frame_Mossystone_Icon_Light",
        frameLightBlend = "BLEND",
        fill          = SCB.TEX_PATH .. "mossystone\\Fill_Mossystone_Icon",
        bg            = SCB.TEX_PATH .. "mossystone\\BG_Mossystone_Icon",
        uvSpeed       = 0,
        uvDir         = 1,
        -- Compensation des zones transparentes du Fill (comme sur les autres thèmes)
        -- en appliquant une marge gauche plus forte pour éviter un départ trop tôt.
        fillMarginL   = 0.1680,
        fillMarginR   = 0.0680,
        textNameOffX  = 52,
        textTimerOffX = -5,
        textOffY      = 2,
    },

    mossystone = {
        name            = "Mossy Stone",
        contour         = nil,
        frame           = SCB.TEX_PATH .. "mossystone\\Frame_Mossystone",
        frameLight      = SCB.TEX_PATH .. "mossystone\\Frame_Mossystone_Light",
        frameLightBlend = "BLEND",
        fill            = SCB.TEX_PATH .. "mossystone\\Fill_Mossystone",
        bg              = SCB.TEX_PATH .. "mossystone\\BG_Mossystone",
        uvSpeed         = 0,
        uvDir           = 1,
        -- Fill démarrant dès le bord gauche utile (évite un départ visuel à ~10%)
        fillMarginL     = 0.0000,
        fillMarginR     = 0.0977,
        textNameOffX    = -5,
        textOffY        = 2,
    },

    alliance = {
        name        = "Alliance",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "alliance\\Frame_Alliance",
        fill        = SCB.TEX_PATH .. "alliance\\Fill_Alliance",
        bg          = SCB.TEX_PATH .. "alliance\\BG_Alliance",
        bgLight     = SCB.TEX_PATH .. "alliance\\BG_Alliance_Light",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
    },

    horde = {
        name        = "Horde",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "horde\\Frame_Horde",
        fill        = SCB.TEX_PATH .. "horde\\Fill_Horde",
        bg          = SCB.TEX_PATH .. "horde\\BG_Horde",
        bgLight     = SCB.TEX_PATH .. "horde\\BG_Light_Horde",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
        -- Particules front : rouge/orange Horde
        ambPartColor  = { 1.0, 0.25, 0.05 },
        frontPartColor = { 1.0, 0.35, 0.05 },
    },

    bronze = {
        name        = "Bronze",
        frame       = SCB.TEX_PATH .. "bronze\\Frame_Bronze",
        frameRed    = SCB.TEX_PATH .. "bronze\\Frame_Bronze_Red",
        frameGreen  = SCB.TEX_PATH .. "bronze\\Frame_Bronze_Green",
        frameAzur   = SCB.TEX_PATH .. "bronze\\Frame_Bronze_Azur",
        fill        = SCB.TEX_PATH .. "bronze\\Fill_Bronze",
        fillEvoker  = SCB.TEX_PATH .. "bronze\\Fill_Bronze_Evoker",
        bg          = SCB.TEX_PATH .. "bronze\\BG_Bronze",
        uvSpeed     = 0.06,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
        sable       = SCB.TEX_PATH .. "bronze\\Sable_Bronze",
        sableDropPx = 23,
    },

    frost = {
        name        = "Frost",
        contour     = SCB.TEX_PATH .. "frost\\Contour_Frost",
        frame       = SCB.TEX_PATH .. "frost\\Frame_Frost",
        fill        = SCB.TEX_PATH .. "frost\\Fill_Frost",
        bg          = SCB.TEX_PATH .. "frost\\BG_Frost",
        uvSpeed     = 0.10,
        uvDir       = -1,
        fillMarginL = 0.1338,
        fillMarginR = 0.1250,
    },

    arctic = {
        name         = "Arctic",
        barScale     = 1.15,
        contour      = nil,
        frame        = SCB.TEX_PATH .. "arctic\\Frame_Arctic",
        frameLight   = SCB.TEX_PATH .. "arctic\\Frame_Arctic_Light",
        fill         = SCB.TEX_PATH .. "arctic\\Fill_Arctic",
        bg           = SCB.TEX_PATH .. "arctic\\BG_Arctic",
        bgLight      = SCB.TEX_PATH .. "arctic\\FrostBG_Arctic",
        uvSpeed      = 0.10,
        uvDir        = -1,
        fillMarginL  = 0.1338,
        fillMarginR  = 0.1250,
        fillMarginRPx = 20,
        textOffY     = 4,
        textNameOffX = 35,
        textTimerOffX= -35,
    },

    frostfire = {
        name           = "Frostfire",
        frame          = SCB.TEX_PATH .. "frostfire\\Frame_Frostfire",
        fill           = SCB.TEX_PATH .. "frostfire\\Fill_Frostfire",
        bg             = SCB.TEX_PATH .. "frostfire\\BG_Frostfire",
        uvSpeed        = 0.18,
        uvDir          = 1,
        fillMarginL    = 0.1309,
        fillMarginR    = 0.1289,
        textOffY       = 2,
        -- Texture givre révélée progressivement (au-dessus du Frame)
        frostfireGivre = SCB.TEX_PATH .. "frostfire\\Texture_Givre_Frostfire",
        -- Flammes animées (comme Fire fillEffects)
        frostfireEffects = {
            SCB.TEX_PATH .. "frostfire\\Effect_Frostfire_01",
            SCB.TEX_PATH .. "frostfire\\Effect_Frostfire_02",
            SCB.TEX_PATH .. "frostfire\\Effect_Frostfire_03",
            SCB.TEX_PATH .. "frostfire\\Effect_Frostfire_04",
            SCB.TEX_PATH .. "frostfire\\Effect_Frostfire_05",
        },
    },

    felfire = {
        name        = "Felfire",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "felfire\\Frame_Felfire",
        frameLight  = SCB.TEX_PATH .. "felfire\\Frame_Felfire_Light",
        fill        = SCB.TEX_PATH .. "felfire\\Fill_Felfire",
        bg          = SCB.TEX_PATH .. "felfire\\BG_Felfire",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
    },

    lava = {
        name        = "Lava",
        contour     = nil,
        frame       = SCB.TEX_PATH .. "fire2\\Frame_Fire2",
        frameLight  = SCB.TEX_PATH .. "fire2\\Frame_Fire2_Light",
        fill        = SCB.TEX_PATH .. "fire2\\Fill_Fire2",
        bg          = SCB.TEX_PATH .. "fire2\\BG_Fire2",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginR = 0.0977,
        textOffY    = 2,
    },

    inferno = {
        name        = "Inferno",
        barScale    = 1.15,
        contour     = nil,
        frameLight      = SCB.TEX_PATH .. "inferno\\Frame_Inferno_Light",
        frameLightBlend = "BLEND",
        frame       = SCB.TEX_PATH .. "inferno\\Frame_Inferno",
        fill        = SCB.TEX_PATH .. "inferno\\Fill_Inferno",
        bg          = SCB.TEX_PATH .. "inferno\\BG_Inferno",
        uvSpeed     = 0,
        uvDir       = 1,
        fillMarginL = 0.0908,
        fillMarginLPx = 20,
        fillMarginR = 0.1477,
        textOffY      = 4,
        textNameOffX  = 35,
        textTimerOffX = -35,
    },

    fire = {
        name        = "Fire",
        contour     = SCB.TEX_PATH .. "fire\\Contour_Fire_01",
        frame       = SCB.TEX_PATH .. "fire\\Frame_Fire",
        fill        = SCB.TEX_PATH .. "fire\\Fill_Fire",
        bg          = SCB.TEX_PATH .. "fire\\BG_Fire",
        uvSpeed     = 0.28,
        uvDir       = 1,
        fillMarginL = 0.1309,
        fillMarginR = 0.1289,
        bgRed     = SCB.TEX_PATH .. "fire\\BG_Fire_Red",
        frameRed  = SCB.TEX_PATH .. "fire\\Frame_Fire_Red",
        fillEffects = {
            SCB.TEX_PATH .. "fire\\Fill_Fire_Effect_01",
            SCB.TEX_PATH .. "fire\\Fill_Fire_Effect_02",
            SCB.TEX_PATH .. "fire\\Fill_Fire_Effect_03",
            SCB.TEX_PATH .. "fire\\Fill_Fire_Effect_04",
            SCB.TEX_PATH .. "fire\\Fill_Fire_Effect_05",
            SCB.TEX_PATH .. "fire\\Fill_Fire_Effect_06",
        },
        contours  = {
            SCB.TEX_PATH .. "fire\\Contour_Fire_01",
            SCB.TEX_PATH .. "fire\\Contour_Fire_02",
            SCB.TEX_PATH .. "fire\\Contour_Fire_03",
            SCB.TEX_PATH .. "fire\\Contour_Fire_04",
            SCB.TEX_PATH .. "fire\\Contour_Fire_05",
            SCB.TEX_PATH .. "fire\\Contour_Fire_06",
        },
        particles = {
            SCB.TEX_PATH .. "fire\\Particle_Fire_01",
            SCB.TEX_PATH .. "fire\\Particle_Fire_02",
            SCB.TEX_PATH .. "fire\\Particle_Fire_03",
        },
        textOffY = 2,
    },
}

-- ---- Mappage bitmask WoW → clé d'école --------------------
SCB.Schools.maskMap = {
    [64] = "arcane",
    [32] = "shadow",
    [16] = "frost",
    [8]  = "nature",
    [4]  = "lava",
    [2]  = "sacred",
    [1]  = "physical",
    [20] = "frostfire",   -- fire(4) + frost(16) combinés
}

-- ---- Table manuelle spellID → école -----------------------
-- Prioritaire sur les APIs Blizzard, à compléter par sort
SCB.Schools.spellTable = {

    -- =====================================================
    --  PRÊTRE — Holy
    -- =====================================================
    [585]    = "sacred",  -- Châtiment rang 1
    [591]    = "sacred",  -- Châtiment rang 2
    [598]    = "sacred",  -- Châtiment rang 3
    [984]    = "sacred",  -- Châtiment rang 4
    [1004]   = "sacred",  -- Châtiment rang 5
    [6060]   = "sacred",  -- Châtiment rang 6
    [10933]  = "sacred",  -- Châtiment rang 7
    [10934]  = "sacred",  -- Châtiment rang 8
    [25363]  = "sacred",  -- Châtiment rang 9
    [25364]  = "sacred",  -- Châtiment rang 10
    [48122]  = "sacred",  -- Châtiment rang 11 (WotLK)
    [48123]  = "sacred",  -- Châtiment rang 12
    [14914]  = "sacred",  -- Feu sacré rang 1
    [15262]  = "sacred",  -- Feu sacré rang 2
    [15263]  = "sacred",  -- Feu sacré rang 3
    [15264]  = "sacred",  -- Feu sacré rang 4
    [15265]  = "sacred",  -- Feu sacré rang 5
    [15266]  = "sacred",  -- Feu sacré rang 6
    [15267]  = "sacred",  -- Feu sacré rang 7
    [15261]  = "sacred",  -- Feu sacré rang 8
    [25384]  = "sacred",  -- Feu sacré rang 9
    [48134]  = "sacred",  -- Feu sacré rang 10 (WotLK)
    [48135]  = "sacred",  -- Feu sacré rang 11
    [47540]  = "sacred",  -- Penance (cast)
    [47666]  = "sacred",  -- Penance (heal)
    [47750]  = "sacred",  -- Penance (channel)
    [47758]  = "sacred",  -- Penance tick (enemy)
    [47757]  = "sacred",  -- Penance tick (ally)
    [1232567]= "sacred",  -- Penance (TWW)
    [1232571]= "sacred",  -- Penance (TWW variant)
    [2060]   = "sacred",  -- Soin rang 1
    [2061]   = "sacred",  -- Soin rang 2
    [2062]   = "sacred",  -- Soin rang 3
    [2063]   = "sacred",  -- Soin rang 4
    [25314]  = "sacred",  -- Soin rang 5
    [48070]  = "sacred",  -- Soin rang 6
    [48071]  = "sacred",  -- Soin rang 7
    [17]     = "sacred",  -- Soins supérieurs rang 1
    [592]    = "sacred",  -- Soins supérieurs rang 2
    [600]    = "sacred",  -- Soins supérieurs rang 3
    [3747]   = "sacred",  -- Soins supérieurs rang 4
    [6064]   = "sacred",  -- Soins supérieurs rang 5
    [6065]   = "sacred",  -- Soins supérieurs rang 6
    [10963]  = "sacred",  -- Soins supérieurs rang 7
    [10964]  = "sacred",  -- Soins supérieurs rang 8
    [10965]  = "sacred",  -- Soins supérieurs rang 9
    [25213]  = "sacred",  -- Soins supérieurs rang 10
    [25218]  = "sacred",  -- Soins supérieurs rang 11
    [48062]  = "sacred",  -- Soins supérieurs rang 12
    [48063]  = "sacred",  -- Soins supérieurs rang 13
    [2050]   = "sacred",  -- Soins inférieurs rang 1
    [2052]   = "sacred",  -- Soins inférieurs rang 2
    [2053]   = "sacred",  -- Soins inférieurs rang 3
    [2054]   = "sacred",  -- Soins inférieurs rang 4
    [2055]   = "sacred",  -- Soins inférieurs rang 5
    [9472]   = "sacred",  -- Soins rapides rang 1
    [9473]   = "sacred",  -- Soins rapides rang 2
    [9474]   = "sacred",  -- Soins rapides rang 3
    [10916]  = "sacred",  -- Soins rapides rang 4
    [10917]  = "sacred",  -- Soins rapides rang 5
    [25235]  = "sacred",  -- Soins rapides rang 6
    [48069]  = "sacred",  -- Soins rapides rang 7 (WotLK)
    [596]    = "sacred",  -- Prière de soins rang 1
    [996]    = "sacred",  -- Prière de soins rang 2
    [10960]  = "sacred",  -- Prière de soins rang 3
    [10961]  = "sacred",  -- Prière de soins rang 4
    [25316]  = "sacred",  -- Prière de soins rang 5
    [48068]  = "sacred",  -- Prière de soins rang 6
    [48072]  = "sacred",  -- Prière de soins rang 7

    -- PRÊTRE — Shadow
    [589]    = "shadow", -- Mot de l'ombre : Douleur rang 1
    [594]    = "shadow", -- Mot de l'ombre : Douleur rang 2
    [970]    = "shadow", -- Mot de l'ombre : Douleur rang 3
    [8092]   = "shadow", -- Explosion mentale
    [8103]   = "shadow", -- Attaque mentale (Mind Blast TBC rank 1 base)
    [8105]   = "shadow", -- Attaque mentale rang 2
    [8106]   = "shadow", -- Attaque mentale rang 3
    [10945]  = "shadow", -- Attaque mentale rang 4
    [10946]  = "shadow", -- Attaque mentale rang 5
    [10947]  = "shadow", -- Attaque mentale rang 6
    [25372]  = "shadow", -- Attaque mentale rang 7
    [25375]  = "shadow", -- Attaque mentale rang 8
    [48126]  = "shadow", -- Attaque mentale rang 9 (WotLK)
    [48127]  = "shadow", -- Attaque mentale rang 10
    -- Entrave des morts-vivants (Shackle Undead) → holy
    [9484]   = "sacred",   -- Entrave des morts-vivants rang 1
    [9485]   = "sacred",   -- Entrave des morts-vivants rang 2
    [10955]  = "sacred",   -- Entrave des morts-vivants rang 3
    -- Résurrection Prêtre → holy
    [2006]   = "sacred",   -- Résurrection rang 1
    [2010]   = "sacred",   -- Résurrection rang 2
    [10880]  = "sacred",   -- Résurrection rang 3
    [10881]  = "sacred",   -- Résurrection rang 4
    [20770]  = "sacred",   -- Résurrection rang 5
    [25435]  = "sacred",   -- Résurrection rang 6
    [48171]  = "sacred",   -- Résurrection rang 7 (WotLK)
    [15407]  = "shadow", -- Siphon de l'esprit
    [34914]  = "shadow", -- Attouchement vampirique
    [48160]  = "shadow", -- Vague de dispersion
    [2944]   = "shadow", -- Peste dévorante

    -- =====================================================
    --  PALADIN — Holy
    -- =====================================================
    [20271]  = "paladin",  -- Jugement
    [25742]  = "paladin",  -- Jugement de la lumière rang 1
    [20473]  = "paladin",  -- Choc sacré rang 1
    [20929]  = "paladin",  -- Choc sacré rang 2
    [20930]  = "paladin",  -- Choc sacré rang 3
    [27174]  = "paladin",  -- Choc sacré rang 4
    [33072]  = "paladin",  -- Choc sacré rang 5
    [48824]  = "paladin",  -- Choc sacré rang 6
    [48825]  = "paladin",  -- Choc sacré rang 7
    [633]    = "paladin",  -- Imposition des mains
    [24275]  = "paladin",  -- Marteau du courroux rang 1
    [24274]  = "paladin",  -- Marteau du courroux rang 2
    [24239]  = "paladin",  -- Marteau du courroux rang 3
    [27180]  = "paladin",  -- Marteau du courroux rang 4
    [48805]  = "paladin",  -- Marteau du courroux rang 5
    [48806]  = "paladin",  -- Marteau du courroux rang 6
    [26573]  = "paladin",  -- Consécration rang 1
    [20116]  = "paladin",  -- Consécration rang 2
    [20922]  = "paladin",  -- Consécration rang 3
    [20923]  = "paladin",  -- Consécration rang 4
    [20924]  = "paladin",  -- Consécration rang 5
    [27173]  = "paladin",  -- Consécration rang 6
    [48818]  = "paladin",  -- Consécration rang 7
    [48819]  = "paladin",  -- Consécration rang 8
    [35395]  = "paladin",  -- Frappe du croisé
    [53600]  = "paladin",  -- Bouclier du vengeur
    -- Soins Paladin (Flash of Light)
    [19750]  = "paladin",  -- Éclair de lumière rang 1
    [639]    = "paladin",  -- Lumière sacrée rang 2
    [647]    = "paladin",  -- Lumière sacrée rang 3
    [1026]   = "paladin",  -- Lumière sacrée rang 4
    [1042]   = "paladin",  -- Lumière sacrée rang 5
    [3472]   = "paladin",  -- Lumière sacrée rang 6
    [10328]  = "paladin",  -- Lumière sacrée rang 7
    [10329]  = "paladin",  -- Lumière sacrée rang 8
    [25276]  = "paladin",  -- Lumière sacrée rang 9
    [27135]  = "paladin",  -- Lumière sacrée rang 10
    [27136]  = "paladin",  -- Lumière sacrée rang 11
    [48781]  = "paladin",  -- Lumière sacrée rang 12
    [48782]  = "paladin",  -- Lumière sacrée rang 13
    [19750]  = "paladin",  -- Éclair de lumière rang 1
    [19939]  = "paladin",  -- Éclair de lumière rang 2
    [19940]  = "paladin",  -- Éclair de lumière rang 3
    [19941]  = "paladin",  -- Éclair de lumière rang 4
    [19942]  = "paladin",  -- Éclair de lumière rang 5
    [19943]  = "paladin",  -- Éclair de lumière rang 6
    [19944]  = "paladin",  -- Éclair de lumière rang 7
    [48784]  = "paladin",  -- Éclair de lumière rang 8
    [48785]  = "paladin",  -- Éclair de lumière rang 9

    -- =====================================================
    --  CHAMAN — Thunder (Foudre)
    -- =====================================================
    [403]    = "thunder", -- Éclair rang 1
    [529]    = "thunder", -- Éclair rang 2
    [548]    = "thunder", -- Éclair rang 3
    [915]    = "thunder", -- Éclair rang 4
    [943]    = "thunder", -- Éclair rang 5
    [6041]   = "thunder", -- Éclair rang 6
    [10391]  = "thunder", -- Éclair rang 7
    [10392]  = "thunder", -- Éclair rang 8
    [15207]  = "thunder", -- Éclair rang 9
    [15208]  = "thunder", -- Éclair rang 10
    [25448]  = "thunder", -- Éclair rang 11
    [49237]  = "thunder", -- Éclair rang 12
    [49238]  = "thunder", -- Éclair rang 13
    [188196] = "thunder", -- Éclair (retail)
    [421]    = "thunder", -- Chaîne d'éclairs rang 1
    [930]    = "thunder", -- Chaîne d'éclairs rang 2
    [2860]   = "thunder", -- Chaîne d'éclairs rang 3
    [10605]  = "thunder", -- Chaîne d'éclairs rang 4
    [25439]  = "thunder", -- Chaîne d'éclairs rang 5
    [25442]  = "thunder", -- Chaîne d'éclairs rang 6
    [49270]  = "thunder", -- Chaîne d'éclairs rang 7
    [49271]  = "thunder", -- Chaîne d'éclairs rang 8
    [188443] = "thunder", -- Chaîne d'éclairs (retail)
    [51490]  = "thunder", -- Tempête de tonnerre
    -- Chaman Feu
    [51505]  = "lava",    -- Éruption de lave rang 1
    [60043]  = "lava",    -- Éruption de lave rang 2
    [77451]  = "lava",    -- Éruption de lave rang 3 (retail)
    -- Chaman Nature (soins)
    [331]    = "nature",  -- Vague de soins rang 1
    [332]    = "nature",  -- Vague de soins rang 2
    [547]    = "nature",  -- Vague de soins rang 3
    [913]    = "nature",  -- Vague de soins rang 4
    [939]    = "nature",  -- Vague de soins rang 5
    [959]    = "nature",  -- Vague de soins rang 6
    [8005]   = "nature",  -- Vague de soins rang 7
    [10395]  = "nature",  -- Vague de soins rang 8
    [10396]  = "nature",  -- Vague de soins rang 9
    [25357]  = "nature",  -- Vague de soins rang 10
    [25391]  = "nature",  -- Vague de soins rang 11
    [25396]  = "nature",  -- Vague de soins rang 12
    [49272]  = "nature",  -- Vague de soins rang 13
    [49273]  = "nature",  -- Vague de soins rang 14
    [77472]  = "nature",  -- Vague de soins (retail)
    [1064]   = "nature",  -- Chaîne de soins rang 1
    [10622]  = "nature",  -- Chaîne de soins rang 2
    [10623]  = "nature",  -- Chaîne de soins rang 3
    [25422]  = "nature",  -- Chaîne de soins rang 4
    [25423]  = "nature",  -- Chaîne de soins rang 5
    [55459]  = "nature",  -- Chaîne de soins rang 6
    [55460]  = "nature",  -- Chaîne de soins rang 7
    [61295]  = "nature",  -- Ondulation (Riptide)
    -- Afflux de soins (Healing Surge) — toutes versions
    [8004]   = "nature",  -- Afflux de soins rang 1 (classic)
    [8008]   = "nature",  -- Afflux de soins rang 2
    [8010]   = "nature",  -- Afflux de soins rang 3
    [10466]  = "nature",  -- Afflux de soins rang 4
    [10467]  = "nature",  -- Afflux de soins rang 5
    [10468]  = "nature",  -- Afflux de soins rang 6
    [25356]  = "nature",  -- Afflux de soins rang 7
    [25357]  = "nature",  -- Afflux de soins rang 8
    [49269]  = "nature",  -- Afflux de soins rang 9 (WotLK)
    [73685]  = "nature",  -- Afflux de soins (retail/Cata+)
    -- Gardien des tempêtes (Stormkeeper) — thunder
    [191634] = "thunder", -- Gardien des tempêtes (Stormkeeper)
    [319930] = "thunder", -- Gardien des tempêtes rang 2
    -- Tempest (talent Stormbringer)
    [452350] = "thunder", -- Tempest
    -- Choc de la foudre (Lightning Bolt amélioré sous Stormkeeper)
    [45284]  = "thunder", -- Éclair (Stormkeeper proc)
    -- Lame de foudre (Thunderclap chaman / Thunderstrike)
    [17364]  = "thunder", -- Coup de tempête (Stormstrike)
    [32175]  = "thunder", -- Coup de tempête (off-hand)
    -- Pluie de soins (Healing Rain)
    [73920]  = "water",   -- Pluie de soins
    -- Vague primordiale (Primordial Wave)
    [375982] = "water",   -- Vague primordiale

    -- =====================================================
    --  CHAMAN RESTAURATION — Water
    --  Sorts de soins directs du Chaman Restauration (retail)
    --  Peuvent être surchargés via le thème Water dans les options.
    -- =====================================================
    [8004]   = "water",  -- Afflux de soins rang 1 (Healing Surge classic)
    [8008]   = "water",  -- Afflux de soins rang 2
    [8010]   = "water",  -- Afflux de soins rang 3
    [10466]  = "water",  -- Afflux de soins rang 4
    [10467]  = "water",  -- Afflux de soins rang 5
    [10468]  = "water",  -- Afflux de soins rang 6
    [25356]  = "water",  -- Afflux de soins rang 7
    [49269]  = "water",  -- Afflux de soins rang 9 (WotLK)
    [73685]  = "water",  -- Afflux de soins (retail/Cata+)
    [331]    = "water",  -- Vague de soins rang 1
    [332]    = "water",  -- Vague de soins rang 2
    [547]    = "water",  -- Vague de soins rang 3
    [913]    = "water",  -- Vague de soins rang 4
    [939]    = "water",  -- Vague de soins rang 5
    [959]    = "water",  -- Vague de soins rang 6
    [8005]   = "water",  -- Vague de soins rang 7
    [10395]  = "water",  -- Vague de soins rang 8
    [10396]  = "water",  -- Vague de soins rang 9
    [25357]  = "water",  -- Vague de soins rang 10
    [25391]  = "water",  -- Vague de soins rang 11
    [25396]  = "water",  -- Vague de soins rang 12
    [49272]  = "water",  -- Vague de soins rang 13
    [49273]  = "water",  -- Vague de soins rang 14
    [77472]  = "water",  -- Vague de soins (retail)
    [1064]   = "water",  -- Chaîne de soins rang 1
    [10622]  = "water",  -- Chaîne de soins rang 2
    [10623]  = "water",  -- Chaîne de soins rang 3
    [25422]  = "water",  -- Chaîne de soins rang 4
    [25423]  = "water",  -- Chaîne de soins rang 5
    [55459]  = "water",  -- Chaîne de soins rang 6
    [55460]  = "water",  -- Chaîne de soins rang 7
    [61295]  = "water",  -- Ondulation (Riptide)
    [207778] = "water",  -- Surge of Earth / Riptide (retail variant)

    -- =====================================================
    --  MAGE — Feu
    -- =====================================================
    [133]    = "inferno",  -- Boule de feu rang 1
    [143]    = "inferno",  -- Boule de feu rang 2
    [145]    = "inferno",  -- Boule de feu rang 3
    [3140]   = "inferno",  -- Boule de feu rang 4
    [8400]   = "inferno",  -- Boule de feu rang 5
    [8401]   = "inferno",  -- Boule de feu rang 6
    [8402]   = "inferno",  -- Boule de feu rang 7
    [10148]  = "inferno",  -- Boule de feu rang 8
    [10149]  = "inferno",  -- Boule de feu rang 9
    [10150]  = "inferno",  -- Boule de feu rang 10
    [10151]  = "inferno",  -- Boule de feu rang 11
    [25306]  = "inferno",  -- Boule de feu rang 12
    [27070]  = "inferno",  -- Boule de feu rang 13
    [38692]  = "inferno",  -- Boule de feu rang 14
    [42833]  = "inferno",  -- Boule de feu rang 15
    [42834]  = "inferno",  -- Boule de feu rang 16
    [11366]  = "inferno",  -- Boule de feu (retail)
    [2136]   = "inferno",  -- Explosion de feu
    [2120]   = "inferno",  -- Flamestrike / Flammes de l'enfer (toutes versions)
    [108853] = "inferno",  -- Inferno Blast
    [257541] = "inferno",  -- Phoenix Flames / Feu de Phénix
    [190319] = "inferno",  -- Combustion
    [44614]  = "frostfire", -- Boule de feu-givre / Frostfire Bolt (WotLK/Cata/MoP)
    [47610]  = "frostfire", -- Boule de feu-givre rang 2 (WotLK)
    [401502] = "frostfire", -- Éclair de givrefeu (SoD Classic)
    [431044] = "frostfire", -- Éclair de givrefeu (Retail Midnight)
    -- Sorts hero Frostfire Mage (retail) — Glacial Spike, Ray of Frost/Comet Storm
    [228600] = "frostfire", -- Pointe glaciale (Glacial Spike)
    [205021] = "frost",     -- Rayon de givre (Ray of Frost — canalisé)
    [153595] = "frostfire", -- Tempête de comètes (Comet Storm)
    [31661]  = "inferno",  -- Souffle du dragon
    [11113]  = "inferno",  -- Explosion de flammes

    -- MAGE — Givre
    [116]    = "frost", -- Projectile de givre rang 1
    [205]    = "frost", -- Projectile de givre rang 2
    [837]    = "frost", -- Projectile de givre rang 3
    [7322]   = "frost", -- Projectile de givre rang 4
    [8406]   = "frost", -- Projectile de givre rang 5
    [8407]   = "frost", -- Projectile de givre rang 6
    [8408]   = "frost", -- Projectile de givre rang 7
    [10179]  = "frost", -- Projectile de givre rang 8
    [10180]  = "frost", -- Projectile de givre rang 9
    [10181]  = "frost", -- Projectile de givre rang 10
    [25304]  = "frost", -- Projectile de givre rang 11
    [27071]  = "frost", -- Projectile de givre rang 12
    [38697]  = "frost", -- Projectile de givre rang 13
    [42841]  = "frost", -- Projectile de givre rang 14
    [42842]  = "frost", -- Projectile de givre rang 15
    [122]    = "frost", -- Gel
    [120]    = "frost", -- Cône de froid
    [228598] = "frost", -- Boule de glace
    [84714]  = "frost", -- Orbite de givre
    [199786] = "frost", -- Bombe de givre
    [30455]  = "frost", -- Lame de glace
    [212653] = "frost", -- Éclat de givre
    [148022] = "frost", -- Comète de givre

    -- MAGE — Arcane
    [5143]   = "arcane", -- Missiles arcaniques rang 1
    [5144]   = "arcane", -- Missiles arcaniques rang 2
    [5145]   = "arcane", -- Missiles arcaniques rang 3
    [8416]   = "arcane", -- Missiles arcaniques rang 4
    [8417]   = "arcane", -- Missiles arcaniques rang 5
    [10211]  = "arcane", -- Missiles arcaniques rang 6
    [10212]  = "arcane", -- Missiles arcaniques rang 7
    [25345]  = "arcane", -- Missiles arcaniques rang 8
    [27075]  = "arcane", -- Missiles arcaniques rang 9
    [38699]  = "arcane", -- Missiles arcaniques rang 10
    [42843]  = "arcane", -- Missiles arcaniques rang 11
    [42846]  = "arcane", -- Missiles arcaniques rang 12
    [30451]  = "arcane", -- Charges arcaniques
    [7268]   = "arcane", -- Éclat arcanique
    -- Éruption d'arcanes / Impulsion arcanique (retail Midnight)
    [365350] = "arcane", -- Éruption d'arcanes (Arcane Surge)
    [1241462]= "arcane", -- Impulsion arcanique (Arcane Pulse)
    -- Orbe, Salve, Explosion
    [153626] = "arcane", -- Orbe arcanique
    [44425]  = "arcane", -- Salve arcanique (Arcane Barrage)
    [1449]   = "arcane", -- Explosion arcaniste
    [167083] = "arcane", -- Supernova
    [12051]  = "arcane", -- Évocation (canalisé)
    -- Téléportations → arcane
    [3561]   = "arcane", -- Téléportation : Stormwind
    [3562]   = "arcane", -- Téléportation : Ironforge
    [3565]   = "arcane", -- Téléportation : Darnassus
    [32271]  = "arcane", -- Téléportation : Exodar
    [49360]  = "arcane", -- Téléportation : Theramore
    [3567]   = "arcane", -- Téléportation : Orgrimmar
    [3563]   = "arcane", -- Téléportation : Undercity
    [3566]   = "arcane", -- Téléportation : Thunder Bluff
    [35715]  = "arcane", -- Téléportation : Shattrath (Alliance)
    [35716]  = "arcane", -- Téléportation : Shattrath (Horde)
    [33690]  = "arcane", -- Téléportation : Shattrath
    [53140]  = "arcane", -- Téléportation : Dalaran (WotLK Alliance)
    [53142]  = "arcane", -- Téléportation : Dalaran (WotLK Horde)
    [120145] = "arcane", -- Téléportation ancienne : Dalaran
    [88342]  = "arcane", -- Téléportation : Tol Barad
    [132621] = "arcane", -- Téléportation : Vale of Eternal Blossoms
    [176244] = "arcane", -- Téléportation : Ashran
    [176248] = "arcane", -- Téléportation : Stormshield
    [193759] = "arcane", -- Téléportation : Dalaran (Legion)
    [224869] = "arcane", -- Téléportation : Dalaran (Îles Brisées)
    [281400] = "arcane", -- Téléportation : Boralus
    [281403] = "arcane", -- Téléportation : Boralus
    [281404] = "arcane", -- Téléportation : Dazar'alor
    [296270] = "arcane", -- Téléportation : Nazjatar (Alliance)
    [296272] = "arcane", -- Téléportation : Nazjatar (Horde)
    [369350] = "arcane", -- Téléportation : Valdrakken
    [395277] = "arcane", -- Téléportation : Valdrakken
    [446540] = "arcane", -- Téléportation : Dornogal
    [344587] = "arcane", -- Téléportation : Oribos
    [1259190]= "arcane", -- Téléportation : Silvermoon
    [32272]  = "arcane", -- Téléportation : Silvermoon (TBC)
    [49358]  = "arcane", -- Téléportation : Stonard
    [49359]  = "arcane", -- Téléportation : Theramore (Horde)
    [88344]  = "arcane", -- Téléportation : Tol Barad (Horde)
    [132627] = "arcane", -- Téléportation : Vale of Eternal Blossoms (Horde)
    [176242] = "arcane", -- Téléportation : Warspear
    -- Portails → arcane
    [10059]  = "arcane", -- Portail : Stormwind
    [11416]  = "arcane", -- Portail : Ironforge
    [11418]  = "arcane", -- Portail : Darnassus
    [32266]  = "arcane", -- Portail : Exodar
    [49361]  = "arcane", -- Portail : Theramore
    [11417]  = "arcane", -- Portail : Orgrimmar
    [11420]  = "arcane", -- Portail : Undercity
    [11419]  = "arcane", -- Portail : Thunder Bluff
    [35717]  = "arcane", -- Portail : Shattrath (Alliance)
    [35718]  = "arcane", -- Portail : Shattrath (Horde)
    [33691]  = "arcane", -- Portail : Shattrath
    [53156]  = "arcane", -- Portail : Dalaran (WotLK Alliance)
    [53170]  = "arcane", -- Portail : Dalaran (WotLK Horde)
    [120146] = "arcane", -- Portail ancien : Dalaran
    [88345]  = "arcane", -- Portail : Tol Barad
    [132620] = "arcane", -- Portail : Vale of Eternal Blossoms
    [193760] = "arcane", -- Portail : Dalaran (Legion)
    [224871] = "arcane", -- Portail : Dalaran (Îles Brisées)
    [176246] = "arcane", -- Portail : Stormshield
    [281406] = "arcane", -- Portail : Boralus
    [281408] = "arcane", -- Portail : Dazar'alor
    [369352] = "arcane", -- Portail : Valdrakken
    [395289] = "arcane", -- Portail : Valdrakken
    [446534] = "arcane", -- Portail : Dornogal
    [344597] = "arcane", -- Portail : Oribos
    [1259194]= "arcane", -- Portail : Silvermoon
    [32267]  = "arcane", -- Portail : Silvermoon (TBC)
    [88346]  = "arcane", -- Portail : Tol Barad (Horde)
    [132626] = "arcane", -- Portail : Vale of Eternal Blossoms (Horde)
    [281402] = "arcane", -- Portail : Dazar'alor
    -- Conjuration nourriture/eau → arcane
    [5504]   = "arcane", -- Conjurer nourriture rang 1
    [5505]   = "arcane", -- Conjurer nourriture rang 2
    [5506]   = "arcane", -- Conjurer nourriture rang 3
    [6129]   = "arcane", -- Conjurer nourriture rang 4
    [10144]  = "arcane", -- Conjurer nourriture rang 5
    [10145]  = "arcane", -- Conjurer nourriture rang 6
    [28612]  = "arcane", -- Conjurer nourriture rang 7
    [33717]  = "arcane", -- Conjurer nourriture rang 8
    [42955]  = "arcane", -- Conjurer rafraîchissements (WotLK)
    [190336] = "arcane", -- Conjurer rafraîchissements (retail)

    -- =====================================================
    --  DÉMONISTE
    -- =====================================================
    -- Shadow
    [686]    = "shadow", -- Trait des ténèbres rang 1
    [695]    = "shadow", -- Trait des ténèbres rang 2
    [705]    = "shadow", -- Trait des ténèbres rang 3
    [1088]   = "shadow", -- Trait des ténèbres rang 4
    [1106]   = "shadow", -- Trait des ténèbres rang 5
    [7641]   = "shadow", -- Trait des ténèbres rang 6
    [11659]  = "shadow", -- Trait des ténèbres rang 7
    [11660]  = "shadow", -- Trait des ténèbres rang 8
    [11661]  = "shadow", -- Trait des ténèbres rang 9
    [25307]  = "shadow", -- Trait des ténèbres rang 10
    [27209]  = "shadow", -- Trait des ténèbres rang 11
    [47808]  = "shadow", -- Trait des ténèbres rang 12
    [47809]  = "shadow", -- Trait des ténèbres rang 13
    [172]    = "shadow", -- Corruption
    [980]    = "shadow", -- Agonie
    [1120]   = "shadow", -- Drain d'âme
    [30108]  = "shadow", -- Brûlure de l'ombre
    [2944]   = "shadow", -- Peste dévorante
    [48181]  = "shadow", -- Haletement de l'ombre rang 1
    [348]    = "lava",   -- Immolation rang 1
    [707]    = "lava",   -- Immolation rang 2
    [1094]   = "lava",   -- Immolation rang 3
    [2941]   = "lava",   -- Immolation rang 4
    [11665]  = "lava",   -- Immolation rang 5
    [11667]  = "lava",   -- Immolation rang 6
    [11668]  = "lava",   -- Immolation rang 7
    [25309]  = "lava",   -- Immolation rang 8
    [47810]  = "lava",   -- Immolation rang 9
    [47811]  = "lava",   -- Immolation rang 10
    [5740]   = "lava",   -- Pluie de feu rang 1
    [6219]   = "lava",   -- Pluie de feu rang 2
    [11677]  = "lava",   -- Pluie de feu rang 3
    [11678]  = "lava",   -- Pluie de feu rang 4
    [25311]  = "lava",   -- Pluie de feu rang 5
    [47813]  = "lava",   -- Pluie de feu rang 6
    [47814]  = "lava",   -- Pluie de feu rang 7

    -- =====================================================
    --  DRUIDE
    -- =====================================================
    -- Balance (Nature)
    [5176]   = "nature", -- Colère rang 1
    [5177]   = "nature", -- Colère rang 2
    [5178]   = "nature", -- Colère rang 3
    [5179]   = "nature", -- Colère rang 4
    [5180]   = "nature", -- Colère rang 5
    [6780]   = "nature", -- Colère rang 6
    [8905]   = "nature", -- Colère rang 7
    [9739]   = "nature", -- Colère rang 8
    [9910]   = "nature", -- Colère rang 9
    [10611]  = "nature", -- Colère rang 10
    [26984]  = "nature", -- Colère rang 11
    [48459]  = "nature", -- Colère rang 12
    [48461]  = "nature", -- Colère rang 13
    [190984] = "nature", -- Colère (retail/WotLK unified ID)
    [8921]   = "nature", -- Flamme lunaire rang 1
    [164812] = "nature", -- Feu du soleil (retail)
    -- Soins Druide (Nature)
    [8936]   = "nature", -- Rejuvenation rang 1
    [774]    = "nature", -- Rejuvenation rang 2+
    [18562]  = "nature", -- Vivification
    [5185]   = "nature", -- Toucher naturel rang 1
    [5186]   = "nature", -- Toucher naturel rang 2
    [5187]   = "nature", -- Toucher naturel rang 3
    [5188]   = "nature", -- Toucher naturel rang 4
    [5189]   = "nature", -- Toucher naturel rang 5
    [6778]   = "nature", -- Toucher naturel rang 6
    [8903]   = "nature", -- Toucher naturel rang 7
    [9758]   = "nature", -- Toucher naturel rang 8
    [9888]   = "nature", -- Toucher naturel rang 9
    [9889]   = "nature", -- Toucher naturel rang 10
    [25297]  = "nature", -- Toucher naturel rang 11
    [26978]  = "nature", -- Toucher naturel rang 12
    [48377]  = "nature", -- Toucher naturel rang 13
    [48378]  = "nature", -- Toucher naturel rang 14
    [33763]  = "nature", -- Floraison (Lifebloom)
    [48438]  = "nature", -- Croissance sauvage
    [740]    = "nature", -- Tranquillité rang 1
    [8914]   = "nature", -- Repousse (Regrowth) rang 1
    [9750]   = "nature", -- Repousse rang 2
    [9856]   = "nature", -- Repousse rang 3
    [9857]   = "nature", -- Repousse rang 4
    [9858]   = "nature", -- Repousse rang 5
    [25299]  = "nature", -- Repousse rang 6
    [26980]  = "nature", -- Repousse rang 7
    [48442]  = "nature", -- Repousse rang 8
    [48443]  = "nature", -- Repousse rang 9
    [20484]  = "nature", -- Réincarnation (Rebirth) druide rang 1
    [20739]  = "nature", -- Réincarnation druide rang 2
    [20742]  = "nature", -- Réincarnation druide rang 3
    [20747]  = "nature", -- Réincarnation druide rang 4
    [20748]  = "nature", -- Réincarnation druide rang 5
    [26994]  = "nature", -- Réincarnation druide rang 6
    [48477]  = "nature", -- Réincarnation druide rang 7 (WotLK)
    -- Résurrection Druide retail → nature
    [50769]  = "nature", -- Revive / Réveil (Druide, retail)
    [212040] = "nature", -- Revitalize / Revitalisation (Druide, retail)
    -- Résurrection Chaman (Âme ancestrale / Ancestral Spirit)
    [2008]   = "water",  -- Âme ancestrale rang 1
    [20610]  = "nature", -- Âme ancestrale rang 2
    [20776]  = "nature", -- Âme ancestrale rang 3
    [20777]  = "nature", -- Âme ancestrale rang 4
    [20778]  = "nature", -- Âme ancestrale rang 5
    [25590]  = "nature", -- Âme ancestrale rang 6
    [48522]  = "nature", -- Âme ancestrale rang 7 (WotLK)
    [212048] = "water",  -- Vision ancestrale (Ancestral Vision, retail)
    [50464]  = "nature", -- Réconfort (Nourish)

    -- =====================================================
    --  DÉMONISTE CHAOS (Demon Hunter)
    -- =====================================================
    [162794] = "chaos",  -- Frappe du chaos
    [228477] = "chaos",  -- Annihilation
    [179057] = "chaos",  -- Lame du chaos
    [201427] = "shadow", -- Volée de lames

    -- =====================================================
    --  CHEVALIER DE LA MORT
    -- =====================================================
    [45477]  = "frost",    -- Toucher glacial
    [45462]  = "physical", -- Frappe de peste
    [47541]  = "shadow",   -- Coup de mort
    [49998]  = "physical", -- Frappe mortelle (DK)
    [49143]  = "frost",    -- Souffle de givre

    -- =====================================================
    --  SORTS SUPPLÉMENTAIRES OUBLIÉS
    -- =====================================================
    -- Prêtre : Word of the Pious, Renew, Binding Heal
    [139]    = "sacred",  -- Renouveau (Renew) rang 1
    [6074]   = "sacred",  -- Renouveau rang 2
    [6075]   = "sacred",  -- Renouveau rang 3
    [6076]   = "sacred",  -- Renouveau rang 4
    [6077]   = "sacred",  -- Renouveau rang 5
    [6078]   = "sacred",  -- Renouveau rang 6
    [10927]  = "sacred",  -- Renouveau rang 7
    [10928]  = "sacred",  -- Renouveau rang 8
    [25315]  = "sacred",  -- Renouveau rang 9
    [48067]  = "sacred",  -- Renouveau rang 10
    [48068]  = "sacred",  -- Renouveau rang 11
    [32546]  = "sacred",  -- Soin lié (Binding Heal)
    [88625]  = "sacred",  -- Parole sainte : Châtiment (Holy Word: Chastise)
    [200196] = "sacred",  -- Parole sainte : Sanctification
    [64843]  = "sacred",  -- Hymne divin (Divine Hymn)
    [47788]  = "sacred",  -- Esprit gardien (Guardian Spirit)
    [33206]  = "sacred",  -- Répression de la douleur (Pain Suppression)

    -- Paladin : Word of Glory, Templar's Verdict (retail)
    [85673]  = "paladin",  -- Parole de gloire (Word of Glory)
    [136494] = "paladin",  -- Parole de gloire rang 2
    [85256]  = "paladin",  -- Verdict du templier (Templar's Verdict)
    [224266] = "paladin",  -- Templar's Verdict amélioré
    [53385]  = "paladin",  -- Divin Tempête (Divine Storm)
    [20473]  = "paladin",  -- Choc sacré

    -- Mage : Arcane Blast, Arcane Explosion
    [30451]  = "arcane", -- Blast arcanique (Arcane Blast)
    [1449]   = "arcane", -- Explosion arcaniste (Arcane Explosion)
    [167083] = "arcane", -- Supernova
    [153626] = "arcane", -- Missile arcanique (proc)
    [210833] = "arcane", -- Feu d'Aluneth

    -- Mage Givre : Blizzard (AoE)
    [190356] = "frost",  -- Blizzard (retail cursor)
    [1248829] = "frost", -- Blizzard (retail target placement)
    [10]     = "frost",  -- Blizzard rang 1
    [6141]   = "frost",  -- Blizzard rang 2
    [8427]   = "frost",  -- Blizzard rang 3
    [10185]  = "frost",  -- Blizzard rang 4
    [10186]  = "frost",  -- Blizzard rang 5
    [10187]  = "frost",  -- Blizzard rang 6
    [27085]  = "frost",  -- Blizzard rang 7
    [42939]  = "frost",  -- Blizzard rang 8
    [42940]  = "frost",  -- Blizzard rang 9

    -- Démoniste : Drain de vie, Fel Hunter
    [1454]   = "shadow", -- Drain de vie rang 1
    [1455]   = "shadow", -- Drain de vie rang 2
    [1456]   = "shadow", -- Drain de vie rang 3
    [11699]  = "shadow", -- Drain de vie rang 4
    [11700]  = "shadow", -- Drain de vie rang 5
    [27221]  = "shadow", -- Drain de vie rang 6
    [47857]  = "shadow", -- Drain de vie rang 7
    -- Drain de mana
    [5138]   = "shadow", -- Drain de mana rang 1
    [13443]  = "shadow", -- Drain de mana rang 2
    [13444]  = "shadow", -- Drain de mana rang 3
    [13445]  = "shadow", -- Drain de mana rang 4
    [13446]  = "shadow", -- Drain de mana rang 5
    [27220]  = "shadow", -- Drain de mana rang 6
    [47855]  = "shadow", -- Drain de mana rang 7
    -- Invocations → shadow
    [688]    = "shadow", -- Invocation : Familier (Imp)
    [697]    = "shadow", -- Invocation : Marcheur du vide
    [712]    = "shadow", -- Summon Succubus
    [691]    = "shadow", -- Summon Felhunter
    [30146]  = "shadow", -- Summon Felguard
    [1122]   = "shadow", -- Summon Infernal
    [18540]  = "shadow", -- Summon Doomguard
    [698]    = "shadow", -- Ritual of Summoning
    [29893]  = "shadow", -- Ritual of Souls
    [48018]  = "shadow", -- Cercle démoniaque (Demonic Circle)
    [366222] = "shadow", -- Invocation : Sayaad (Summon Sayaad)
    -- Prêtre : Mass Dispel, Ultimate Penitence, Void Blast, Void Torrent
    [32375]  = "sacred",   -- Mass Dispel
    -- Ultimate Penitence — tous IDs vérifiés CSV
    [419305] = "sacred",   -- Ultimate Penitence
    [421256] = "sacred",   -- Ultimate Penitence
    [421354] = "sacred",   -- Ultimate Penitence
    [421434] = "sacred",   -- Ultimate Penitence
    [421453] = "sacred",   -- Ultimate Penitence
    [421543] = "sacred",   -- Ultimate Penitence
    [421544] = "sacred",   -- Ultimate Penitence
    [421602] = "sacred",   -- Ultimate Penitence
    [432154] = "sacred",   -- Ultimate Penitence
    -- Void Blast (Voidweaver — Disc + Shadow) — vérifié CSV
    [450215] = "shadow", -- Void Blast
    -- Void Torrent (Shadow Voidweaver) — vérifiés CSV
    [205065] = "shadow", -- Void Torrent
    [263165] = "shadow", -- Void Torrent (TWW)

    -- Druide : Moonfire tous rangs → moon
    -- (Flamme lunaire classic = école arcane WoW, visuellement lune)
    [8921]   = "moon",  -- Moonfire / Flamme lunaire rang 1  ← aussi retail Moonfire
    [8924]   = "moon",  -- Flamme lunaire rang 2
    [8925]   = "moon",  -- Flamme lunaire rang 3
    [8926]   = "moon",  -- Flamme lunaire rang 4
    [8927]   = "moon",  -- Flamme lunaire rang 5
    [8928]   = "moon",  -- Flamme lunaire rang 6
    [8929]   = "moon",  -- Flamme lunaire rang 7
    [9833]   = "moon",  -- Flamme lunaire rang 8
    [9834]   = "moon",  -- Flamme lunaire rang 9
    [9835]   = "moon",  -- Flamme lunaire rang 10
    [26987]  = "moon",  -- Flamme lunaire rang 11
    [48462]  = "moon",  -- Flamme lunaire rang 12
    [48463]  = "moon",  -- Flamme lunaire rang 13
    [164812] = "moon",  -- Moonfire (retail unified)
    -- Starfire (Feu des étoiles) → moon
    [2912]   = "moon",  -- Feu des étoiles rang 1
    [8949]   = "moon",  -- Feu des étoiles rang 2
    [8950]   = "moon",  -- Feu des étoiles rang 3
    [8951]   = "moon",  -- Feu des étoiles rang 4
    [9875]   = "moon",  -- Feu des étoiles rang 5
    [9876]   = "moon",  -- Feu des étoiles rang 6
    [25298]  = "moon",  -- Feu des étoiles rang 7
    [26986]  = "moon",  -- Feu des étoiles rang 8
    [48464]  = "moon",  -- Feu des étoiles rang 9
    [48465]  = "moon",  -- Feu des étoiles rang 10
    [194153] = "moon",  -- Starfire (retail)
    [197628] = "moon",  -- Starfire (Resto Druid)
    -- Druide Balance retail — sorts supplémentaires → moon
    [78674]  = "moon",  -- Starsurge
    [197626] = "moon",  -- Starsurge (variant)
    [162627] = "moon",  -- Starsurge (variant)
    [191034] = "moon",  -- Starfall (retail)
    [93402]  = "moon",  -- Sunfire
    [164815] = "moon",  -- Sunfire (variant)
    [202767] = "moon",  -- New Moon
    [202768] = "moon",  -- Half Moon
    [202771] = "moon",  -- Full Moon
    [274281] = "moon",  -- New Moon (retail variant)
    [274282] = "moon",  -- Half Moon (variant)
    [274283] = "moon",  -- Full Moon (variant)
    [78675]  = "moon",  -- Solar Beam
    [202770] = "moon",  -- Fury of Elune
    [373269] = "moon",  -- Fury of Elune (variant)
    [194223] = "moon",  -- Celestial Alignment
    [383410] = "moon",  -- Celestial Alignment (variant)
    [202347] = "moon",  -- Stellar Flare
    [366653] = "moon",  -- Stellar Flare (variant)
    [202359] = "moon",  -- Astral Communion
    [400636] = "moon",  -- Astral Communion (variant)
    [88747]  = "moon",  -- Wild Mushroom (Balance)
    [324846] = "moon",  -- Wild Mushroom (variant)
    [205636] = "moon",  -- Force of Nature (Balance)

    -- DK : Frappe de givre (Howling Blast), Frappe du fléau
    [49184]  = "frost",    -- Explosion hurlante (Howling Blast)
    [55090]  = "frost",    -- Fièvre de givre (Frost Fever)
    [55095]  = "shadow",   -- Peste de sang (Blood Plague)
    [77575]  = "shadow",   -- Épidémie (Outbreak)
    [43265]  = "shadow",   -- Mort et décomposition

    -- =====================================================
    --  OUBLIS NOTABLES — DIVERS CLASSES
    -- =====================================================
    -- Chasseur : sorts à temps de cast → thème Aim
    [19434]  = "aim", -- Tir précis (Aimed Shot) rang 1
    [20900]  = "aim", -- Tir précis rang 2
    [20901]  = "aim", -- Tir précis rang 3
    [20902]  = "aim", -- Tir précis rang 4
    [20903]  = "aim", -- Tir précis rang 5
    [20904]  = "aim", -- Tir précis rang 6
    [27065]  = "aim", -- Tir précis rang 7
    [49049]  = "aim", -- Tir précis rang 8
    [49050]  = "aim", -- Tir précis rang 9
    [56641]  = "aim", -- Tir stable (Steady Shot)
    [185358] = "aim", -- Tir stable (retail)
    [19386]  = "aim", -- Tir précis (Aimed Shot) retail
    [1261193]= "aim", -- Bâton-boum (Boomstick)
    [257044] = "aim", -- Tir rapide (Rapid Fire)
    [120360] = "aim", -- Barrage (canalisé)
    [392060] = "aim", -- Flèche hurlante (Wailing Arrow)
    [359844] = "aim", -- Appel de l'Esprit sauvage (Call of the Wild)
    -- Volée de flèches (Multi-Shot) → aim
    [2643]   = "aim", -- Volée de flèches rang 1
    [14288]  = "aim", -- Volée de flèches rang 2
    [14289]  = "aim", -- Volée de flèches rang 3
    [14290]  = "aim", -- Volée de flèches rang 4
    [25294]  = "aim", -- Volée de flèches rang 5
    [27022]  = "aim", -- Volée de flèches rang 6
    [49047]  = "aim", -- Volée de flèches rang 7
    [49048]  = "aim", -- Volée de flèches rang 8
    -- Chasseur : Tir explosif → fire (déjà, mais versions retail)
    [212431] = "lava",     -- Tir explosif (retail)
    -- Démoniste : Peur (Fear) → shadow
    [5782]   = "shadow",   -- Peur rang 1
    [6213]   = "shadow",   -- Peur rang 2
    [6215]   = "shadow",   -- Peur rang 3
    -- Démoniste : Contrôle démoniaque (Enslave Demon) → shadow
    [1098]   = "shadow",   -- Asservissement du démon rang 1
    [11725]  = "shadow",   -- Asservissement du démon rang 2
    [11726]  = "shadow",   -- Asservissement du démon rang 3
    -- Démoniste retail : Drain de mana, Haletement de l'ombre
    [205179] = "shadow",   -- Drain de mana (retail)
    -- Mage : Miroir (Mirror Image) → arcane, Alter Time → arcane
    [55342]  = "arcane",   -- Images miroir (Mirror Image)
    [342245] = "arcane",   -- Altération temporelle (Alter Time)
    -- Mage : Dissipation de magie (Spellsteal) → arcane
    [30449]  = "arcane",   -- Vol de sort (Spellsteal)
    [198100] = "arcane",   -- Kleptomania (talent JcJ, vol de sort canalisé)
    [353128] = "arcane",   -- Arcanosphere
    -- Mage : Contresort → arcane
    [2139]   = "arcane",   -- Contresort (Counterspell)
    -- Mage : Décalage temporel (Time Warp) → arcane
    [80353]  = "arcane",   -- Décalage temporel (Time Warp)
    -- Druide : Insect Swarm → nature
    [5570]   = "nature",   -- Essaim d'insectes rang 1
    [24974]  = "nature",   -- Essaim d'insectes rang 2
    [24975]  = "nature",   -- Essaim d'insectes rang 3
    [24976]  = "nature",   -- Essaim d'insectes rang 4
    [24977]  = "nature",   -- Essaim d'insectes rang 5
    [27013]  = "nature",   -- Essaim d'insectes rang 6
    [48468]  = "nature",   -- Essaim d'insectes rang 7
    -- Druide : Starfall → moon
    [48505]  = "moon",    -- Pluie d'étoiles (Starfall) rang 1
    [48504]  = "moon",    -- Pluie d'étoiles rang 2
    -- Chaman : Choc de givre → frost
    [8056]   = "frost",    -- Choc de givre rang 1
    [8058]   = "frost",    -- Choc de givre rang 2
    [10472]  = "frost",    -- Choc de givre rang 3
    [10473]  = "frost",    -- Choc de givre rang 4
    [25464]  = "frost",    -- Choc de givre rang 5
    [49235]  = "frost",    -- Choc de givre rang 6
    [49236]  = "frost",    -- Choc de givre rang 7
    [196840] = "frost",    -- Choc de givre (retail)
    -- Chaman : Choc de terre → nature
    [8042]   = "nature",   -- Choc de terre rang 1
    [8044]   = "nature",   -- Choc de terre rang 2
    [8045]   = "nature",   -- Choc de terre rang 3
    [8046]   = "nature",   -- Choc de terre rang 4
    [10412]  = "nature",   -- Choc de terre rang 5
    [10413]  = "nature",   -- Choc de terre rang 6
    [10414]  = "nature",   -- Choc de terre rang 7
    [25454]  = "nature",   -- Choc de terre rang 8
    -- Chaman : Hex et variantes → nature
    -- (école WoW = Nature pour tous les CC Shaman)
    [51514]  = "nature",   -- Hex (base, retail)
    [210873] = "nature",   -- Hex: Frog
    [211004] = "nature",   -- Hex: Spider
    [211010] = "nature",   -- Hex: Snake
    [211015] = "nature",   -- Hex: Cockroach
    [269352] = "nature",   -- Hex: Compy
    [309328] = "nature",   -- Hex: Skeletal Hatchling
    [332605] = "nature",   -- Hex: Zandalari Medicine Man
    [343198] = "nature",   -- Hex: Living Honey
    [361690] = "nature",   -- Hex: Raptor
    [1239172] = "nature",  -- Hex (Midnight)
    [1256008] = "nature",  -- Hex (Midnight variant)
    [1270766] = "nature",  -- Hex (Midnight variant)
    -- Chaman : Choc de flamme → fire
    [8050]   = "lava",     -- Choc de flamme rang 1
    [8052]   = "lava",     -- Choc de flamme rang 2
    [8053]   = "lava",     -- Choc de flamme rang 3
    [10447]  = "lava",     -- Choc de flamme rang 4
    [10448]  = "lava",     -- Choc de flamme rang 5
    [25457]  = "lava",     -- Choc de flamme rang 6
    [49232]  = "lava",     -- Choc de flamme rang 7
    [49233]  = "lava",     -- Choc de flamme rang 8
    [188389] = "lava",     -- Choc de flamme (retail)
    -- Prêtre : Contrôle mental → shadow
    [605]    = "shadow",   -- Contrôle mental rang 1
    [10911]  = "shadow",   -- Contrôle mental rang 2
    [10912]  = "shadow",   -- Contrôle mental rang 3
    -- Prêtre : Cri psychique → shadow
    [8122]   = "shadow",   -- Cri psychique rang 1
    [8124]   = "shadow",   -- Cri psychique rang 2
    [10888]  = "shadow",   -- Cri psychique rang 3
    [10890]  = "shadow",   -- Cri psychique rang 4

    -- =====================================================
    --  PÊCHE — Fishing (toutes extensions)
    -- =====================================================
    [7620]    = "fishing", -- Fishing rang 1
    [7731]    = "fishing", -- Fishing rang 2
    [7732]    = "fishing", -- Fishing rang 3
    [13620]   = "fishing", -- Fishing rang 4
    [18248]   = "fishing", -- Fishing rang 5
    [33095]   = "fishing", -- Fishing (TBC)
    [51294]   = "fishing", -- Fishing (WotLK)
    [63275]   = "fishing", -- Fishing (WotLK)
    [88868]   = "fishing", -- Fishing (Cata)
    [110410]  = "fishing", -- Fishing (MoP)
    [111541]  = "fishing", -- Fishing (MoP)
    [116562]  = "fishing", -- Fishing (MoP)
    [122529]  = "fishing", -- Fishing
    [124755]  = "fishing", -- Fishing (MoP)
    [131474]  = "fishing", -- Fishing (MoP)
    [131476]  = "fishing", -- Fishing (MoP)
    [131490]  = "fishing", -- Fishing (MoP)
    [144736]  = "fishing", -- Fishing (MoP)
    [158743]  = "fishing", -- Fishing (WoD)
    [197463]  = "fishing", -- Fishing (Legion)
    [201756]  = "fishing", -- Fishing (Legion)
    [202834]  = "fishing", -- Fishing (Legion)
    [202843]  = "fishing", -- Fishing (Legion)
    [215172]  = "fishing", -- Fishing (Legion)
    [218375]  = "fishing", -- Fishing (Legion)
    [219847]  = "fishing", -- Fishing (Legion)
    [224208]  = "fishing", -- Fish
    [227511]  = "fishing", -- Fishing (Legion)
    [240217]  = "fishing", -- Fishing (Legion)
    [247829]  = "fishing", -- Fishing (BfA)
    [255498]  = "fishing", -- Fishing (BfA)
    [259561]  = "fishing", -- Fishing (BfA)
    [260037]  = "fishing", -- Fishing (BfA)
    [261762]  = "fishing", -- Fishing (BfA)
    [262860]  = "fishing", -- Fishing (BfA)
    [265700]  = "fishing", -- Fishing (BfA)
    [271616]  = "fishing", -- Fishing (BfA)
    [271617]  = "fishing", -- Fishing (BfA)
    [272011]  = "fishing", -- Fishing (BfA)
    [274371]  = "fishing", -- Fishing (BfA)
    [275095]  = "fishing", -- Fishing (BfA)
    [277915]  = "fishing", -- Fishing (BfA)
    [296495]  = "fishing", -- Fishing (BfA)
    [347868]  = "fishing", -- Fishing (Shadowlands)
    [360716]  = "fishing", -- Fishing (Shadowlands)
    [373299]  = "fishing", -- Fishing (Dragonflight)
    [373301]  = "fishing", -- Fishing (Dragonflight)
    [377831]  = "fishing", -- Fishing (Dragonflight)
    [382908]  = "fishing", -- Fishing (Dragonflight)
    [384481]  = "fishing", -- Fishing (Dragonflight)
    [386039]  = "fishing", -- Fishing (Dragonflight)
    [386040]  = "fishing", -- Fishing (Dragonflight)
    [386041]  = "fishing", -- Fishing (Dragonflight)
    [386042]  = "fishing", -- Fishing (Dragonflight)
    [389234]  = "fishing", -- Fishing (Dragonflight)
    [391669]  = "fishing", -- Fishing (Dragonflight)
    [391853]  = "fishing", -- Fishing (Dragonflight)
    [409658]  = "fishing", -- Fishing (Dragonflight)
    [433758]  = "fishing", -- Fishing (TWW)
    [437890]  = "fishing", -- Fishing (TWW)
    [438491]  = "fishing", -- Fishing (TWW)
    [443066]  = "fishing", -- Fish (TWW)
    [450647]  = "fishing", -- Fishing (TWW)
    [450648]  = "fishing", -- Fishing (TWW)
    [454010]  = "fishing", -- Fishing (TWW)
    [454752]  = "fishing", -- Fishing (TWW)
    [454753]  = "fishing", -- Fishing (TWW)
    [454754]  = "fishing", -- Fishing (TWW)
    [454755]  = "fishing", -- Fishing (TWW)
    [454757]  = "fishing", -- Fishing (TWW)
    [454758]  = "fishing", -- Fishing (TWW)
    [454759]  = "fishing", -- Fishing (TWW)
    [454760]  = "fishing", -- Fishing (TWW)
    [454761]  = "fishing", -- Fishing (TWW)
    [463743]  = "fishing", -- Fishing (TWW)
    -- Midnight
    [1234750] = "fishing", -- Fishing (Midnight)
    [1239033] = "fishing", -- Fishing (Midnight)
    [1239040] = "fishing", -- Fishing (Midnight)
    [1239227] = "fishing", -- Fishing (Midnight)
    [1241356] = "fishing", -- Fishing (Midnight)
    [1257770] = "fishing", -- Midnight Fishing
    [1281811] = "fishing", -- Fishing (Midnight)
    [1281821] = "fishing", -- Fishing (Midnight)
    [1281822] = "fishing", -- Fishing (Midnight)
    [1281823] = "fishing", -- Fishing (Midnight)
    [1281824] = "fishing", -- Fishing (Midnight)
    [1281825] = "fishing", -- Fishing (Midnight)
    [1281827] = "fishing", -- Fishing (Midnight)
    [1281828] = "fishing", -- Fishing (Midnight)
    [1281829] = "fishing", -- Fishing (Midnight)
    [1281830] = "fishing", -- Fishing (Midnight)
    [1281831] = "fishing", -- Fishing (Midnight)
    [1281833] = "fishing", -- Fishing (Midnight)

    -- =====================================================
    --  PÊCHE — Fishing (toutes extensions)
    -- =====================================================
    [7620]    = "fishing", [7731]    = "fishing", [7732]    = "fishing",
    [13620]   = "fishing", [18248]   = "fishing", [33095]   = "fishing",
    [51294]   = "fishing", [63275]   = "fishing", [88868]   = "fishing",
    [110410]  = "fishing", [111541]  = "fishing", [116562]  = "fishing",
    [122529]  = "fishing",
    [124755]  = "fishing", [131474]  = "fishing", [131476]  = "fishing",
    [131490]  = "fishing", [144736]  = "fishing", [158743]  = "fishing",
    [197463]  = "fishing", [201756]  = "fishing", [202834]  = "fishing",
    [202843]  = "fishing", [215172]  = "fishing", [218375]  = "fishing",
    [219847]  = "fishing", [224208]  = "fishing", [227511]  = "fishing",
    [240217]  = "fishing", [247829]  = "fishing", [255498]  = "fishing",
    [259561]  = "fishing", [260037]  = "fishing", [261762]  = "fishing",
    [262860]  = "fishing", [265700]  = "fishing", [271616]  = "fishing",
    [271617]  = "fishing", [272011]  = "fishing", [274371]  = "fishing",
    [275095]  = "fishing", [277915]  = "fishing", [296495]  = "fishing",
    [347868]  = "fishing", [360716]  = "fishing", [373299]  = "fishing",
    [373301]  = "fishing", [377831]  = "fishing", [382908]  = "fishing",
    [384481]  = "fishing", [386039]  = "fishing", [386040]  = "fishing",
    [386041]  = "fishing", [386042]  = "fishing", [389234]  = "fishing",
    [391669]  = "fishing", [391853]  = "fishing", [409658]  = "fishing",
    [433758]  = "fishing", [437890]  = "fishing", [438491]  = "fishing",
    [443066]  = "fishing", [450647]  = "fishing", [450648]  = "fishing",
    [454010]  = "fishing", [454752]  = "fishing", [454753]  = "fishing",
    [454754]  = "fishing", [454755]  = "fishing", [454757]  = "fishing",
    [454758]  = "fishing", [454759]  = "fishing", [454760]  = "fishing",
    [454761]  = "fishing", [463743]  = "fishing",
    -- Midnight
    [1234750] = "fishing", [1239033] = "fishing", [1239040] = "fishing",
    [1239227] = "fishing", [1241356] = "fishing", [1281811] = "fishing",
    [1281821] = "fishing", [1281822] = "fishing", [1281823] = "fishing",
    [1281824] = "fishing", [1281825] = "fishing", [1281827] = "fishing",
    [1281828] = "fishing", [1281829] = "fishing", [1281830] = "fishing",
    [1281831] = "fishing", [1281833] = "fishing",
    [1224771] = "fishing", -- Coin de pêche du Vide (TWW)

    -- =====================================================
    --  MINAGE — Mining (toutes extensions)
    -- =====================================================
    -- Classic / Vanilla
    [2575]   = "mining", -- Mining rang 1
    [2576]   = "mining", -- Mining rang 2
    [3564]   = "mining", -- Mining rang 3
    [10248]  = "mining", -- Mining rang 4
    [29354]  = "mining", -- Mining (TBC)
    [32606]  = "mining", -- Mining (TBC)
    [49811]  = "mining", -- Mine
    [49815]  = "mining", -- Mine
    [50310]  = "mining", -- Mining (WotLK)
    [74517]  = "mining", -- Mining (Cata)
    [102161] = "mining", -- Mining (MoP)
    [135120] = "mining", -- Mining (MoP)
    [158754] = "mining", -- Mining (WoD)
    [170599] = "mining", -- Mining (WoD)
    [184377] = "mining", -- Mining (Legion)
    [195122] = "mining", -- Mining (Legion)
    [265837] = "mining", -- Mining (BfA)
    [265838] = "mining", -- Mining (BfA)
    [265839] = "mining", -- Mining (BfA)
    [265841] = "mining", -- Mining (BfA)
    [265843] = "mining", -- Mining (BfA)
    [265845] = "mining", -- Mining (BfA)
    [265847] = "mining", -- Mining (BfA)
    [265849] = "mining", -- Mining (BfA)
    [265851] = "mining", -- Mining (BfA)
    [265853] = "mining", -- Mining (BfA)
    [274126] = "mining", -- Mining (BfA)
    [274127] = "mining", -- Mining (BfA)
    [274128] = "mining", -- Mining (BfA)
    [274129] = "mining", -- Mining (BfA)
    [309835] = "mining", -- Mining (Shadowlands)
    [346758] = "mining", -- Mining (Shadowlands)
    [366260] = "mining", -- Mining (Dragonflight)
    [367115] = "mining", -- Mining (Dragonflight)
    [381827] = "mining", -- Mining (Dragonflight)
    [382705] = "mining", -- Mining (Dragonflight)
    [382710] = "mining", -- Mining (Dragonflight)
    [404022] = "mining", -- Mining (Dragonflight)
    [438767] = "mining", -- Mining (TWW)
    [423341] = "mining", -- Mining (TWW)
    [450846] = "mining", -- Mining (TWW)
    [451103] = "mining", -- Mining (TWW)
    [451105] = "mining", -- Mining (TWW)
    [451106] = "mining", -- Mining (TWW)
    -- Midnight
    [1215464]  = "mining", -- Mining (Midnight)
    [1243516]  = "mining", -- Mining (Midnight)
    [1243517]  = "mining", -- Mining (Midnight)
    [1243518]  = "mining", -- Mining (Midnight)
    [1243519]  = "mining", -- Mining (Midnight)
    [1243520]  = "mining", -- Mining (Midnight)
    [1251313]  = "mining", -- Mining (Midnight)
    [1251314]  = "mining", -- Mining (Midnight)
    [1251315]  = "mining", -- Mining (Midnight)
    [1251316]  = "mining", -- Mining (Midnight)
    [1252075]  = "mining", -- Mining (Midnight)
    [1254015]  = "mining", -- Mining (Midnight)
    [1258339]  = "mining", -- Mining (Midnight)
    [1258340]  = "mining", -- Mining (Midnight)
    [1281748]  = "mining", -- Mining (Midnight)
    [1281794]  = "mining", -- Mining (Midnight)
    [1281795]  = "mining", -- Mining (Midnight)
    [471013]   = "mining", -- Midnight Mining (retail Midnight)
    [471028]   = "mining", -- Midnight Mining (variant)



    -- =====================================================
    --  DÉPEÇAGE — Skinning (toutes extensions)
    -- =====================================================
    [8613]    = "skinning", -- Skinning rang 1
    [8617]    = "skinning", -- Skinning rang 2
    [8618]    = "skinning", -- Skinning rang 3
    [10768]   = "skinning", -- Skinning rang 4
    [32678]   = "skinning", -- Skinning (TBC)
    [50305]   = "skinning", -- Skinning (WotLK)
    [74523]   = "skinning", -- Skinning (Cata)
    [102220]  = "skinning", -- Skinning (MoP)
    [158756]  = "skinning", -- Skinning (WoD)
    [195125]  = "skinning", -- Skinning (Legion)
    [265856]  = "skinning", -- Skinning (BfA)
    [309811]  = "skinning", -- Skinning (Shadowlands)
    [366259]  = "skinning", -- Skinning (Dragonflight)
    [438769]  = "skinning", -- Skinning (TWW)
    -- =====================================================
    --  HERBORISME — Herb Gathering (toutes extensions)
    --  Ces sorts sont déclenchés par UNIT_SPELLCAST_START
    --  quand le joueur cueille une plante.
    -- =====================================================
    -- Classic / Vanilla
    [2366]   = "herbalism", -- Herb Gathering rang 1
    [2368]   = "herbalism", -- Herb Gathering rang 2
    [2369]   = "herbalism", -- Herb Gathering rang 3
    [2371]   = "herbalism", -- Herb Gathering rang 4
    [3570]   = "herbalism", -- Herb Gathering rang 5
    [11993]  = "herbalism", -- Herb Gathering rang 6
    [28695]  = "herbalism", -- Herb Gathering (TBC)
    [32605]  = "herbalism", -- Herb Gathering (TBC)
    [50300]  = "herbalism", -- Herb Gathering (WotLK)
    [61413]  = "herbalism", -- Herb Gathering (WotLK)
    [74519]  = "herbalism", -- Herb Gathering (Cata)
    [110413] = "herbalism", -- Herb Gathering (MoP)
    [158745] = "herbalism", -- Herb Gathering (WoD)
    [195114] = "herbalism", -- Herb Gathering (Legion)
    [265819] = "herbalism", -- Herb Gathering (BfA)
    [265821] = "herbalism", -- Herb Gathering (BfA)
    [265823] = "herbalism", -- Herb Gathering (BfA)
    [265825] = "herbalism", -- Herb Gathering (BfA)
    [265827] = "herbalism", -- Herb Gathering (BfA)
    [265829] = "herbalism", -- Herb Gathering (BfA)
    [265831] = "herbalism", -- Herb Gathering (BfA)
    [265834] = "herbalism", -- Herb Gathering (BfA)
    [265835] = "herbalism", -- Herb Gathering (BfA)
    [309780] = "herbalism", -- Herb Gathering (Shadowlands)
    [366252] = "herbalism", -- Herb Gathering (Dragonflight)
    [441327] = "herbalism", -- Herb Gathering (TWW)
    [451082] = "herbalism", -- Herb Gathering (TWW)
    [451083] = "herbalism", -- Herb Gathering (TWW)
    [451108] = "herbalism", -- Herb Gathering (TWW)
    [451109] = "herbalism", -- Herb Gathering (TWW)
    [451110] = "herbalism", -- Herb Gathering (TWW)
    [451111] = "herbalism", -- Herb Gathering (TWW)
    [471009] = "herbalism", -- Herb Gathering (Midnight)
    -- Variante cueillette fleur MoP
    [122934] = "herbalism", -- Pick Flower
    -- Midnight : Herb Gathering (IDs hauts)
    [1263670] = "herbalism", -- Herb Gathering (Midnight)
    [1281796] = "herbalism", -- Herb Gathering (Midnight)
    [1281797] = "herbalism", -- Herb Gathering (Midnight)
    [1281799] = "herbalism", -- Herb Gathering (Midnight)
    [1281800] = "herbalism", -- Herb Gathering (Midnight)
    [1281801] = "herbalism", -- Herb Gathering (Midnight)
    -- Midnight : Gathering Herbs (profession active)
    [1258284] = "herbalism", -- Gathering Herbs (Midnight)
    [1258286] = "herbalism", -- Gathering Herbs (Midnight)
    -- Midnight : Plantation de graines
    [1223244] = "herbalism", -- Plant Midnight Seed
    [1223248] = "herbalism", -- Plant Seed
    [1223249] = "herbalism", -- Plant Seed
    [1223250] = "herbalism", -- Plant Seed
    [1223251] = "herbalism", -- Plant Seed
    [1223252] = "herbalism", -- Plant Seed
    [1224738] = "herbalism", -- Plant Glowing Resilient Seed
    [1224740] = "herbalism", -- Plant Seed
    [1224741] = "herbalism", -- Plant Seed
    [1224742] = "herbalism", -- Plant Seed
    [1224743] = "herbalism", -- Plant Seed
    [1224744] = "herbalism", -- Plant Seed
    [1224745] = "herbalism", -- Plant Seed
    [1224746] = "herbalism", -- Plant Seed
    [1224747] = "herbalism", -- Plant Seed
    [1224748] = "herbalism", -- Plant Seed
    [1224750] = "herbalism", -- Plant Seed
    [1224753] = "herbalism", -- Plant Seed
    [1224754] = "herbalism", -- Plant Seed
    [1224755] = "herbalism", -- Plant Seed
    [1224756] = "herbalism", -- Plant Seed
    [1224757] = "herbalism", -- Plant Seed
    [1224758] = "herbalism", -- Plant Primal Resilient Seed
    [1224759] = "herbalism", -- Plant Wild Resilient Seed

    -- =====================================================
    --  BÛCHERONNAGE — Lumber / Woodcutting (Midnight)
    -- =====================================================
    [1239682] = "lumber", -- Coupe de bois (Midnight)

    -- =====================================================
    --  VOID — Demon Hunter Dévoreur (Midnight)
    -- =====================================================
    -- Spec identifier
    [1213636] = "void",  -- Devourer Demon Hunter
    [1256964] = "void",  -- Devourer Demon Hunter
    [1256968] = "void",  -- Devourer Demon Hunter
    [1264881] = "void",  -- Demon Hunter Devourer 12.0 Class Set 2pc
    [1264882] = "void",  -- Demon Hunter Devourer 12.0 Class Set 4pc
    -- Hungering Slash
    [1227681] = "void",  -- Hungering Slash
    [1227682] = "void",  -- Hungering Slash
    [1227685] = "void",  -- Hungering Slash
    [1239507] = "void",  -- Hungering Slash
    [1239519] = "void",  -- Hungering Slash
    [1239525] = "void",  -- Hungering Slash
    [1239541] = "void",  -- Hungering Slash
    [1239542] = "void",  -- Hungering Slash
    -- Void Metamorphosis
    [1217605] = "void",  -- Void Metamorphosis
    [1217607] = "void",  -- Void Metamorphosis
    [1225789] = "void",  -- Void Metamorphosis
    [1261907] = "void",  -- Void Metamorphosis
    -- Devouring Voidblade
    [1261906] = "void",  -- Devouring Voidblade
    [1261908] = "void",  -- Devouring Voidblade
    [1261932] = "void",  -- Devouring Voidblade
    [1261934] = "void",  -- Devouring Voidblade
    [1262004] = "void",  -- Devouring Voidblade
    [1262007] = "void",  -- Devouring Voidblade
    [1262168] = "void",  -- Devouring Voidblade
    [1262169] = "void",  -- Devouring Voidblade
    [1262198] = "void",  -- Devouring Voidblade
    [1262395] = "void",  -- Devouring Voidblade
    -- Void Spear / Hunger
    [1217611] = "void",  -- Empowered Void Spear
    [1217617] = "void",  -- Demonic Hunger
    -- King's Hunger
    [1228265] = "void",  -- King's Hunger
    [1228280] = "void",  -- King's Hunger
    [1228293] = "void",  -- King's Hunger
    [1228317] = "void",  -- King's Hunger
    [1231101] = "void",  -- King's Hunger
    [1231142] = "void",  -- King's Hunger
    [1231150] = "void",  -- King's Hunger
    -- Devouring Cosmos
    [1227555] = "void",  -- Devouring Cosmos
    [1227556] = "void",  -- Devouring Cosmos
    [1227557] = "void",  -- Devouring Cosmos
    [1227559] = "void",  -- Devouring Cosmos
    [1238843] = "void",  -- Devouring Cosmos
    [1238865] = "void",  -- Devouring Cosmos
    [1238882] = "void",  -- Devouring Cosmos
    [1261387] = "void",  -- Devouring Cosmos
    [1261388] = "void",  -- Devouring Cosmos
    -- Devouring Lunge
    [1243409] = "void",  -- Devouring Lunge
    [1243470] = "void",  -- Devouring Lunge
    [1243473] = "void",  -- Devouring Lunge
    -- Ravenous Dive
    [1257693] = "void",  -- Ravenous Dive
    [1248151] = "void",  -- Ravenous Dive
    [1248153] = "void",  -- Ravenous Dive
    [1245839] = "void",  -- Ravenous Dive
    [1259403] = "void",  -- Ravenous Dive
    [1259824] = "void",  -- Ravenous Dive
    -- Devouring Frenzy / Strike
    [1264670] = "void",  -- Devouring Frenzy
    [1264678] = "void",  -- Devouring Frenzy
    [1264755] = "void",  -- Devouring Frenzy
    [1264687] = "void",  -- Devouring Strike
    -- Voidlust
    [1222911] = "void",  -- Voidlust
    [1222914] = "void",  -- Voidlust
    [1222915] = "void",  -- Depleted Voidlust
    [1222921] = "void",  -- Ineffable Voidlust
    [1222926] = "void",  -- Emboldened Voidlust
    [1222927] = "void",  -- Voidlust
    [1255741] = "void",  -- Voidlust
    [1255742] = "void",  -- Voidlust
    [1271618] = "void",  -- Voidlust
    [1271644] = "void",  -- Voidlust
    [1271646] = "void",  -- Voidlust
    [1271650] = "void",  -- Void Shadow
    [1271672] = "void",  -- Voidlust
    [1272113] = "void",  -- Voidlust
    [1277482] = "void",  -- Voidlust
    [1225312] = "void",  -- Amassing Voidlust
    -- Unbound Fury / Rage
    [1240025] = "void",  -- Unbound Fury
    [1240027] = "void",  -- Unbound Fury
    [1228059] = "void",  -- Unbound Rage
    [1228069] = "void",  -- Unbound Rage
    [1228070] = "void",  -- Unbound Rage
    [1228144] = "void",  -- Unbound Rage
    [1240194] = "void",  -- Unbound Rage
    [1240215] = "void",  -- Unbound Rage
    [1240260] = "void",  -- Unbound Rage
    [1245693] = "void",  -- Unbound Rage
    -- Abyssal Surge
    [1227704] = "void",  -- Abyssal Surge
    [1227710] = "void",  -- Abyssal Surge
    [1227713] = "void",  -- Abyssal Surge
    -- Volatile Oblivion
    [1227688] = "void",  -- Volatile Oblivion
    [1227705] = "void",  -- Volatile Oblivion
    [1227757] = "void",  -- Volatile Oblivion
    [1227761] = "void",  -- Volatile Oblivion
    [1227763] = "void",  -- Volatile Oblivion
    [1227766] = "void",  -- Volatile Oblivion
    [1227767] = "void",  -- Volatile Oblivion
    [1227780] = "void",  -- Volatile Oblivion
    [1229334] = "void",  -- Volatile Oblivion
    [1229335] = "void",  -- Volatile Oblivion
    [1229379] = "void",  -- Volatile Oblivion
    [1233991] = "void",  -- Volatile Oblivion
    [1233993] = "void",  -- Volatile Oblivion
    [1234011] = "void",  -- Volatile Oblivion
    [1234012] = "void",  -- Volatile Oblivion
    [1235150] = "void",  -- Volatile Oblivion
    [1235152] = "void",  -- Volatile Oblivion
    -- Oblivion
    [1229325] = "void",  -- Oblivion
    [1229326] = "void",  -- Oblivion
    [1229327] = "void",  -- Oblivion
    [1230666] = "void",  -- Oblivion
    [1249077] = "void",  -- Oblivion
    -- Consume Sigil (signature Dévoreur)
    [1220609] = "void",  -- Consume Sigil
    [1220622] = "void",  -- Consume Torentia's Sigil
    [1220766] = "void",  -- Consume Sigil
    [1239540] = "void",  -- Devour: Sigil of Flame
    [1230214] = "void",  -- Consume Severum's Sigil
    -- Fists of the Voidlord
    [1227659] = "void",  -- Fists of the Voidlord
    [1227663] = "void",  -- Fists of the Voidlord
    [1227665] = "void",  -- Fists of the Voidlord
    [1243053] = "void",  -- Fists of the Voidlord
    [1243054] = "void",  -- Fists of the Voidlord
    [1243055] = "void",  -- Fists of the Voidlord
    [1243056] = "void",  -- Fists of the Voidlord
    [1243057] = "void",  -- Fists of the Voidlord
    [1244609] = "void",  -- Fists of the Voidlord
    [1244610] = "void",  -- Fists of the Voidlord
    [1252103] = "void",  -- Fists of the Voidlord
    -- Hungering Presence / Battle
    [1227420] = "void",  -- Hungering Presence
    [1251978] = "void",  -- Hungering Presence
    [1244547] = "void",  -- Hunger for Battle
    [1244550] = "void",  -- Hunger for Battle
    [1244553] = "void",  -- Hunger for Battle
    -- Voidbinder's Mastery
    [1228117] = "void",  -- Voidbinder's Mastery
    [1228147] = "void",  -- Voidbinder's Mastery
    [1228174] = "void",  -- Voidbinder's Mastery
    [1228201] = "void",  -- Voidbinder's Mastery
    [1243344] = "void",  -- Voidbinder's Mastery
    [1228203] = "void",  -- Voidmastery
    -- Devourer's Pact / Ire / Bite / Heart / Edge
    [1240187] = "void",  -- Devourer's Pact
    [1241345] = "void",  -- Devourer's Pact
    [1240201] = "void",  -- Devourer's Bite
    [1241532] = "void",  -- Devourer's Bite
    [1241534] = "void",  -- Devourer's Bite
    [1222232] = "void",  -- Devourer's Ire
    [1224005] = "void",  -- Devourer's Ire
    [1226269] = "void",  -- Devourer's Ire
    [1226330] = "void",  -- Devourer's Ire
    [1226367] = "void",  -- Devourer's Ire
    [1226539] = "void",  -- Devourer's Ire
    [1226768] = "void",  -- Devourer's Ire
    [1245575] = "void",  -- Devourer's Ire
    [1245578] = "void",  -- Devourer's Ire
    [1246377] = "void",  -- Devourer's Heart
    [1244222] = "void",  -- Devourer's Edge
    -- Soulfray Annihilation
    [1227276] = "void",  -- Soulfray Annihilation
    [1227277] = "void",  -- Soulfray Annihilation
    [1227279] = "void",  -- Soulfray Annihilation
    [1240197] = "void",  -- Soulfray Annihilation
    [1241357] = "void",  -- Soulfray Annihilation
    [1246539] = "void",  -- Soulfray Annihilation
    -- Voidstep
    [1223157] = "void",  -- Voidstep
    [1227299] = "void",  -- Voidstep
    [1227355] = "void",  -- Voidstep
    [1227359] = "void",  -- Voidstep
    [1227361] = "void",  -- Voidstep
    [1237205] = "void",  -- Voidstep
    [1239520] = "void",  -- Voidstep
    [1239526] = "void",  -- Voidstep
    [473215]  = "void",  -- Voidstep
    [473293]  = "void",  -- Voidstep
    [473294]  = "void",  -- Voidstep
    [473295]  = "void",  -- Voidstep
    -- Voidblade
    [1241285] = "void",  -- Voidblade
    [1245412] = "void",  -- Voidblade
    [1245414] = "void",  -- Voidblade
    -- Void Form
    [1228072] = "void",  -- Void Form / Unbound Rage
    [1241877] = "void",  -- Void Form
    [1244537] = "void",  -- Void Form
    -- Misc
    [1232420] = "void",  -- Hungering Shard of Ancient Mana
    [1261838] = "void",  -- Hungering Nullcore
    -- Devouring Entropy
    [1215893] = "void",  -- Devouring Entropy
    [1215896] = "void",  -- Devouring Entropy
    [1215897] = "void",  -- Devouring Entropy
    [1269629] = "void",  -- Devouring Entropy
    [1269642] = "void",  -- Devouring Entropy
    [1269647] = "void",  -- Devouring Entropy
    [1284558] = "void",  -- Devouring Entropy
    -- Devour Essence / Consuming Strikes
    [1215999] = "void",  -- Devour Essence
    [1216000] = "void",  -- Devour Essence
    [1216002] = "void",  -- Devour Essence
    [1216003] = "void",  -- Consuming Strikes
    [1216004] = "void",  -- Consuming Strikes
    [1221130] = "void",  -- Consuming Strikes
    [1221131] = "void",  -- Consuming Strikes
    -- Hungering Rage
    [1221133] = "void",  -- Hungering Rage
    [394413]  = "void",  -- Hungering Rage (retail)
    -- Ravenous Upheaval
    [1227221] = "void",  -- Ravenous Upheaval
    [1227224] = "void",  -- Ravenous Upheaval
    [1227225] = "void",  -- Ravenous Upheaval
    [1227233] = "void",  -- Ravenous Upheaval
    -- Devouring Void
    [1228179] = "void",  -- Devouring Void
    [1228181] = "void",  -- Devouring Void
    [1228182] = "void",  -- Devouring Void
    [1228184] = "void",  -- Devouring Void
    [1228194] = "void",  -- Devouring Void
    [1236689] = "void",  -- Devouring Void
    [1236690] = "void",  -- Devouring Void
    [1258585] = "void",  -- Devouring Void
    [1258586] = "void",  -- Devouring Void
    -- Void Eruption (DH Dévoreur)
    [1228248] = "void",  -- Void Eruption
    [1228250] = "void",  -- Void Eruption
    [1228263] = "void",  -- Void Eruption
    [1243854] = "void",  -- Void Eruption
    [1252102] = "void",  -- Void Eruption
    [1252104] = "void",  -- Void Eruption
    [1252105] = "void",  -- Void Eruption
    [1252107] = "void",  -- Void Eruption
    [1264806] = "void",  -- Void Eruption
    [1264931] = "void",  -- Void Eruption
    [1264941] = "void",  -- Void Eruption
    [1264943] = "void",  -- Void Eruption
    [1264951] = "void",  -- Void Eruption
    [1282415] = "void",  -- Void Eruption
    [1281524] = "void",  -- Void Eruption
    -- Void Cascade
    [1222755] = "void",  -- Void Cascade
    [1222756] = "void",  -- Void Cascade
    [1222758] = "void",  -- Void Cascade
    [1227247] = "void",  -- Void Cascade
    -- Collapsing Star / Consume (formes Void Metamorphosis)
    [1221150] = "void", -- Collapsing Star
    [1217610] = "void", -- Consume (Void form)
    -- Ingestion
    [473662] = "void",  -- Ingestion
    -- Rayon du vide
    [473728] = "void",  -- Rayon du vide
    -- =====================================================
    --  CHAMAN — Choc de flamme corrigé
    -- =====================================================
    [1254851] = "inferno",     -- Flamestrike / Choc de flamme (TWW variant)
    -- =====================================================
    -- Note : [116858] Chaos Bolt Warlock déclaré dans le bloc Warlock Destro (felfire)
    -- Démoniste Shadow
    [30283]  = "shadow", -- Furie de l'ombre (Shadow Fury)
    [20707]  = "shadow", -- Pierre d'âme (Healthstone creation)
    [6201]   = "shadow", -- Création de pierre de soins rang 1
    [6202]   = "shadow", -- Création de pierre de soins rang 2
    [5699]   = "shadow", -- Création de pierre de soins rang 3
    [11729]  = "shadow", -- Création de pierre de soins rang 4
    [11730]  = "shadow", -- Création de pierre de soins rang 5
    [27230]  = "shadow", -- Création de pierre de soins rang 6
    [47871]  = "shadow", -- Création de pierre de soins rang 7
    [342601] = "shadow", -- Rituel funeste (Malefic Rapture / Doom ritual)
    -- Aspiration d'âme (Drain Soul) — canalisé, génère fragments d'âme
    [1120]   = "shadow", -- Aspiration d'âme rang 1
    [8288]   = "shadow", -- Aspiration d'âme rang 2
    [8289]   = "shadow", -- Aspiration d'âme rang 3
    [11675]  = "shadow", -- Aspiration d'âme rang 4
    [11676]  = "shadow", -- Aspiration d'âme rang 5
    [27217]  = "shadow", -- Aspiration d'âme rang 6
    [47855]  = "shadow", -- Aspiration d'âme rang 7 (WotLK)
    [198590] = "shadow", -- Aspiration d'âme (retail)
    -- Chaman Tempête → thunder
    [452201] = "thunder", -- Tempête (Storm)
    -- Druide : Convoke the Spirits → moon
    [391528] = "moon",  -- Convoke the Spirits (retail)
    -- Prêtre : talents PvP manquants
    [289666]  = "sacred",   -- Greater Heal (PvP talent)
    [375901]  = "shadow", -- Mindgames (PvP talent)
    [1262766] = "sacred",   -- Benediction (Midnight)
    -- Demon Hunter : Rayon accablant / Eye Beam → chaos
    [198013]  = "chaos",  -- Eye Beam (base)
    [391058]  = "chaos",  -- Eye Beam (Abyssal Gaze variant)
    [1271144] = "chaos",  -- Eye Beam (Abyssal Gaze variant)
    [1287949] = "chaos",  -- Eye Beam (Abyssal Gaze variant)
    -- Demon Hunter : Fel Devastation, Abyssal Gaze → chaos
    [212084]  = "chaos",  -- Fel Devastation
    [452497]  = "chaos",  -- Abyssal Gaze
    -- Druide : Sarments (Entangling Roots) → nature
    [339]    = "nature", -- Sarments rang 1
    [1062]   = "nature", -- Sarments rang 2
    [5195]   = "nature", -- Sarments rang 3
    [5196]   = "nature", -- Sarments rang 4
    [9852]   = "nature", -- Sarments rang 5
    [9853]   = "nature", -- Sarments rang 6
    [26989]  = "nature", -- Sarments rang 7
    [53308]  = "nature", -- Sarments rang 8 (WotLK)
    [235963] = "nature", -- Sarments (retail)
    -- Paladin : Rédemption (Redemption) → paladin
    [7328]   = "paladin",   -- Rédemption (Redemption)
    -- Paladin : Intercession → paladin
    [391054] = "paladin",   -- Intercession (Battle Rez paladin)
    -- Paladin : Absolution → paladin
    [212056] = "paladin",   -- Absolution
    -- Paladin : Rite de sanctification → paladin
    [433568] = "paladin",   -- Rite de sanctification
    -- Paladin : Lumière sacrée (Light of the Martyr / Word of Glory retail)
    [82326]  = "paladin",   -- Lumière sacrée (retail unified)

    -- =====================================================
    --  MAGE FEU — sorts manquants signalés
    -- =====================================================
    [2948]   = "inferno",   -- Scorch (classic)
    [12873]  = "inferno",   -- Scorch amélioré (TBC)
    [383675] = "inferno",   -- Scorch (retail)
    [2121]   = "inferno",   -- Flamestrike rank 2
    [8422]   = "inferno",   -- Flamestrike rank 3
    [8423]   = "inferno",   -- Flamestrike rank 4
    [10215]  = "inferno",   -- Flamestrike rank 5
    [10216]  = "inferno",   -- Flamestrike rank 6
    [27086]  = "inferno",   -- Flamestrike rank 7
    [42925]  = "inferno",   -- Flamestrike rank 8
    [42926]  = "inferno",   -- Flamestrike rank 9
    -- Flamestrike [2120] déjà déclaré en bloc Mage global plus haut
    [153561] = "inferno",   -- Meteor
    -- Greater Pyroblast (PvP talent) — IDs vérifiés CSV
    [148002] = "inferno",   -- Greater Pyroblast
    [203286] = "inferno",   -- Greater Pyroblast (variant)
    [450421] = "inferno",   -- Greater Pyroblast (TWW)
    -- Ring of Fire (PvP talent Mage) — IDs vérifiés CSV
    [353082] = "inferno",   -- Ring of Fire
    [353084] = "inferno",   -- Ring of Fire (variant)
    [363405] = "inferno",   -- Ring of Fire (variant)

    -- MAGE ARCANE — Polymorph tous variants (IDs vérifiés CSV)
    [118]    = "arcane", -- Polymorph: Sheep (baseline)
    [28271]  = "arcane", -- Polymorph (variant)
    [28272]  = "arcane", -- Polymorph: Pig
    [61025]  = "arcane", -- Polymorph (variant)
    [61305]  = "arcane", -- Polymorph: Black Cat
    [61721]  = "arcane", -- Polymorph: Rabbit
    [61780]  = "arcane", -- Polymorph: Turkey
    [126819] = "arcane", -- Polymorph: Porcupine
    [161353] = "arcane", -- Polymorph: Polar Bear Cub
    [161354] = "arcane", -- Polymorph (variant)
    [161355] = "arcane", -- Polymorph: Monkey
    [161372] = "arcane", -- Polymorph: Penguin
    [277787] = "arcane", -- Polymorph: Direhorn (Horde)
    [277788] = "arcane", -- Polymorph: Direhorn (variant)
    [277792] = "arcane", -- Polymorph: Bumblebee (Alliance)
    [277793] = "arcane", -- Polymorph: Bumblebee (variant)
    [391622] = "arcane", -- Polymorph: Duck (Dragonflight)
    [391631] = "arcane", -- Polymorph: Duck (variant)
    [460392] = "arcane", -- Polymorph: Mosswool (TWW)
    [460396] = "arcane", -- Polymorph: Mosswool (variant)
    -- Mass Polymorph (PvP talent) — IDs vérifiés CSV
    [361095] = "arcane", -- Mass Polymorph
    [383121] = "arcane", -- Mass Polymorph (Dragonflight)
    [413094] = "arcane", -- Mass Polymorph (variant)

    -- MAGE GIVRE — Ring of Frost (PvP talent), Frozen Orb
    [82691]  = "frost",  -- Ring of Frost
    [91264]  = "frost",  -- Ring of Frost (variant)
    [113724] = "frost",  -- Ring of Frost (correct retail ID)
    [221701] = "frost",  -- Ring of Frost (variant)
    [321329] = "frost",  -- Ring of Frost (TWW)
    [228596] = "frost",  -- Frozen Orb
    [235219] = "frost",  -- Cold Snap (PvP)
    [352278] = "frost",  -- Ice Wall (PvP talent Mage)
    -- Mage Givre : Invocation de l'élémentaire d'eau → arctic
    [31687]  = "arctic", -- Summon Water Elemental / Invoquer l'élémentaire d'eau

    -- =====================================================
    --  PRÊTRE — sorts manquants signalés
    -- =====================================================
    -- Penance [47540, 47666, 47750, 47757, 47758, 1232567, 1232571] déclarés en bloc Prêtre Holy plus haut
    [194509] = "sacred",   -- Power Word: Radiance
    [186263] = "shadow", -- Shadow Mend
    [214621] = "sacred",   -- Schism
    [585]    = "sacred",   -- Smite (retail)
    [8129]   = "shadow", -- Mind Blast (retail)
    [335467] = "shadow", -- Devouring Plague
    [228260] = "shadow", -- Void Eruption
    [205448] = "shadow", -- Void Bolt
    [186257] = "shadow", -- Shadow Word: Void
    -- Halo (Holy) → sacred | Halo (Shadow) → shadow
    [120517] = "sacred",   -- Halo (Holy)
    [120644] = "shadow",   -- Halo (Shadow)
    -- Résurrection de masse (Mass Resurrection) → sacred
    [212036] = "sacred",   -- Mass Resurrection
    -- Mind Flay: Insanity → shadow
    [391403] = "shadow",   -- Mind Flay: Insanity
    -- Void Blast (Voidweaver talent) → void
    [450983] = "void",     -- Void Blast (Voidweaver)

    -- =====================================================
    --  CHAMAN — sorts manquants signalés
    -- =====================================================
    [117014] = "thunder", -- Elemental Blast / Blast élémentaire
    [344357] = "thunder", -- Elemental Blast (overload)
    [305485] = "thunder", -- Lightning Lasso / Lasso de foudre (PvP talent)

    -- =====================================================
    --  DÉMONISTE — tous les sorts manquants signalés
    -- =====================================================
    -- Affliction
    [316099] = "shadow", -- Unstable Affliction (ancien)
    [1259790]= "shadow", -- Unstable Affliction (retail)
    -- Dark Harvest (talent Affliction) — IDs vérifiés CSV
    [387016] = "shadow", -- Dark Harvest (TWW passive buff, conservé)
    [387018] = "shadow", -- Dark Harvest (TWW passive buff, conservé)
    [1257052] = "shadow", -- Dark Harvest (Midnight — nuke canalisé)
    -- Malefic Grasp (channel talent Affliction) — IDs vérifiés CSV
    [170619] = "shadow", -- Malefic Grasp
    [235155] = "shadow", -- Malefic Grasp (variant)
    [1261149] = "shadow", -- Malefic Grasp (Midnight)
    [27243]  = "shadow", -- Seed of Corruption
    [689]    = "shadow", -- Drain Life (ancien)
    [234153] = "shadow", -- Drain Life (retail)
    [321938] = "shadow", -- Bonds of Fel (PvP)
    [126]    = "shadow", -- Eye of Kilrogg (classic)
    [6243]   = "shadow", -- Eye of Kilrogg (retail)

    -- Demonology
    [264178] = "shadow", -- Demonbolt
    [265187] = "shadow", -- Summon Demonic Tyrant
    [104316] = "shadow", -- Summon Dreadstalkers
    -- Hand of Gul'dan (Demo retail) — IDs vérifiés CSV
    [86040]  = "shadow", -- Hand of Gul'dan
    [105174] = "shadow", -- Hand of Gul'dan (variant)
    [196282] = "shadow", -- Hand of Gul'dan (retail Demo)
    [206844] = "shadow", -- Hand of Gul'dan (variant)
    [270215] = "shadow", -- Hand of Gul'dan (variant)

    -- Destruction — Chaos Bolt → felfire
    [116858] = "felfire", -- Chaos Bolt
    [17962]  = "felfire", -- Conflagrate
    [196447] = "felfire", -- Channel Demonfire
    [333]    = "felfire", -- Shadowburn
    [385899] = "felfire", -- Dimensional Rift
    [111771] = "felfire", -- Demonic Gateway
    -- Ruination (Diabolist hero talent) — IDs vérifiés CSV
    [428522] = "felfire", -- Ruination
    [433885] = "felfire", -- Ruination (variant)
    [434635] = "felfire", -- Ruination (variant)
    [434636] = "felfire", -- Ruination (variant)

    -- Infernal Bolt (Diabolist — Mother of Chaos proc) → toujours felfire, PAS de green fire switch
    [434506] = "felfire", -- Infernal Bolt (Diabolist hero talent)

    -- Sorts feu Warlock : lava par défaut, felfire si Green Fire actif (voir greenFireSpells)
    [29722]  = "lava",   -- Incinerate rang 1
    [29975]  = "lava",   -- Incinerate rang 2
    [47837]  = "lava",   -- Incinerate rang 3
    [47838]  = "lava",   -- Incinerate rang 4
    [196396] = "lava",   -- Incinerate (retail)
    [152108] = "lava",   -- Cataclysm (lava par défaut, felfire avec Green Fire)
    [6353]   = "lava",   -- Soul Fire (lava par défaut, felfire avec Green Fire)

    -- =====================================================
    --  ÉVOCATEUR — Dévastation
    -- =====================================================
    -- Sorts rouges → empowerTable ou evokerBronzeTable gèrent l'apparence Bronze
    -- On garde "fire" ici uniquement pour les sorts qui n'ont PAS d'override bronze
    [357211] = "lava",   -- Pyre / Bûcher
    [382731] = "lava",   -- Firestorm / Tempête de feu
    [357210] = "lava",   -- Deep Breath / Souffle profond
    [370452] = "lava",   -- Dragonrage / Rage du dragon
    [382266] = "lava",   -- Fire Breath / Souffle de feu (Font of Magic — empowerTable le surcharge si EMPOWER)

    -- Sorts bleus — Désintégration gérée par evokerBronzeTable (→ azur)
    [359073] = "arcane", -- Eternity Surge / Afflux d'éternité (empowerTable le surcharge si EMPOWER)
    [387839] = "arcane", -- Eternity Surge rang 2
    [382411] = "arcane", -- Eternity Surge (Font of Magic — empowerTable le surcharge si EMPOWER)
    [368432] = "arcane", -- Unravel / Effondrement
    [362969] = "arcane", -- Azure Strike / Frappe d'azur

    -- =====================================================
    --  ÉVOCATEUR — Préservation
    -- =====================================================
    -- empowerTable surcharge 355941 si EMPOWER_START
    [367226] = "nature", -- Spiritbloom / Floraison spirituelle (empowered)
    [409895] = "nature", -- Spiritbloom (variante)
    [355913] = "nature", -- Emerald Blossom / Floraison d'émeraude
    [360995] = "sacred",   -- Verdant Embrace / Étreinte verdoyante
    [373861] = "bronze", -- Temporal Anomaly / Anomalie temporelle → Bronze

    -- =====================================================
    --  ÉVOCATEUR — Augmentation
    -- =====================================================
    [395152] = "bronze", -- Ebon Might / Puissance d'ébène
    [403631] = "bronze", -- Breath of Eons / Souffle des présages
    [409311] = "bronze", -- Prescience / Prescience
    [396286] = "bronze", -- Upheaval / Soulèvement (empowerTable le surcharge si EMPOWER)
    [404977] = "bronze", -- Upheaval variante (sécurité)
    [431443] = "bronze", -- Chrono Flames / Flammes chrono (talent remplaçant Living Flame)
    -- Résurrections Évocateur → bronze
    [361178] = "bronze", -- Mass Return / Retour de masse
    [361227] = "bronze", -- Return / Retour

    -- =====================================================
    --  MOINE TISSEVENT (Mistweaver)
    --  Logique : brume/soin → mistweaver | grands CDs → holy
    --            dégâts physiques/Chi → physical
    -- =====================================================

    -- Soins de Brume — mistweaver
    [115175] = "mistweaver", -- Soothing Mist / Brume apaisante (canal)
    [116670] = "mistweaver", -- Vivify / Vivification
    [124682] = "mistweaver", -- Enveloping Mist / Brume enveloppante
    [115151] = "mistweaver", -- Renewing Mist / Brume régénérante
    [191837] = "mistweaver", -- Essence Font / Font d'essence (canal AoE)
    [116694] = "mistweaver", -- Surging Mist / Brume déferlante (ancienne)
    [388615] = "mistweaver", -- Sheilun's Gift / Don de Sheilun (retail)
    [116680] = "mistweaver", -- Thunder Focus Tea / Thé de la concentration du tonnerre
    [117952] = "thunder",    -- Crackling Jade Lightning / Éclair de jade crépitant
    [325209] = "mistweaver", -- Restoral / Restauration
    [388477] = "mistweaver", -- Chi Cocoon (passif Conduit)

    -- Grands Cooldowns de Soin — mistweaver
    [115310] = "mistweaver",   -- Revival / Réveil (résurrection de masse)
    [116849] = "mistweaver",   -- Life Cocoon / Cocon de vie
    [322118] = "mistweaver",   -- Invoke Yu'lon, the Jade Serpent / Jade Serpent
    [325197] = "mistweaver",   -- Invoke Chi-Ji, the Red Crane / Grue rouge
    [443028] = "mistweaver",   -- Celestial Conduit (canal héroïque Midnight)
    [209584] = "mistweaver",   -- Refreshing Jade Wind / Vent de jade régénérant

    -- Dégâts physiques / Chi — physical
    [100780] = "physical", -- Tiger Palm / Paume du tigre
    [100784] = "physical", -- Blackout Kick / Coup de pied ténébreux
    [107428] = "physical", -- Rising Sun Kick / Coup de pied du soleil levant
    [101546] = "physical", -- Spinning Crane Kick / Coup de pied de la grue tournoyante
    [116705] = "physical", -- Spear Hand Strike / Frappe de lance (interrupt)
    [113656] = "fists",    -- Fists of Fury / Poings de la fureur (canal Windwalker)
    [392983] = "physical", -- Rushing Wind Kick / Coup de pied du vent précipité (Midnight)
    [398478] = "physical", -- Jadefire Stomp / Piétinement de feu de jade

    -- Utilitaires / Divers Monk — mistweaver
    [116841] = "mistweaver", -- Tiger's Lust / Ardeur du tigre (sprint)
    [115294] = "mistweaver", -- Mana Tea / Thé de mana (canal)
    [119611] = "mistweaver", -- Renewing Mist (HoT proc interne)
    [212051] = "mistweaver", -- Revival / Réveil
    [126892] = "mistweaver", -- Zen Pilgrimage / Pèlerinage zen
    -- Résurrection Moine → mistweaver
    [115178] = "mistweaver", -- Resuscitate / Réanimation
    -- Chi Burst → mistweaver
    [123986] = "mistweaver", -- Chi Burst
    -- Sheilun's Gift (talent alternatif) → mistweaver
    [399491] = "mistweaver", -- Sheilun's Gift (talent variant)
    -- Chi'ji
    [101546]  = "chiji", -- Spinning Crane Kick / Coup tournoyant de la grue
    [107270]  = "chiji", -- Spinning Crane Kick / Coup tournoyant de la grue
    [1217413] = "chiji", -- (Empower) Sort Chi'ji identifié en debug
    [433089]  = "chiji", -- Sort Chi'ji identifié en debug

}

-- ---- API -----------------------------------------------

function SCB.Schools:Get(key)
    return self.data[key] or self.data["neutral"] or self.data["frost"]
end

function SCB.Schools:Exists(key)
    return self.data[key] ~= nil
end

function SCB.Schools:_firstAvailable()
    if SCB.Config and SCB.Config:Get("useThemeAssignments") then
        local assignments = SCB.Config:Get("themeAssignments") or {}
        local misc = assignments.misc
        -- "blizzard" = barre Blizzard : OCB ne doit rien afficher
        if misc == "blizzard" then return "blizzard" end
        -- "none" = pas d'override : tomber sur la détection par défaut
        if misc and misc ~= "none" and self.data[misc] then return misc end
    end
    -- Respecter le choix du joueur si défini
    local default = SCB.Config and SCB.Config:Get("defaultSchool")
    if default and self.data[default] then return default end
    local priority = {"neutral", "frost", "fire", "arcane", "shadow", "nature", "mistweaver", "sacred", "physical"}
    for _, key in ipairs(priority) do
        if self.data[key] then return key end
    end
    return next(self.data)
end

function SCB.Schools:_applyThemeAssignment(schoolKey)
    if not schoolKey then return schoolKey end
    if SCB.Config and SCB.Config:Get("useThemeAssignments") then
        local assignments = SCB.Config:Get("themeAssignments") or {}
        -- Map theme keys returned by detection to the school-row key used in the UI.
        -- "Fire/Frost/Arcane" rows use the Mage-default theme as key; other-class spells
        -- that resolve to the generic school key fall through to the same row.
        local PARENT = {
            neutral  = "misc",     -- neutral school → misc row
            lava     = "inferno",  -- non-Mage fire (Warlock, Shaman) → Fire row
            frost    = "arctic",   -- non-Mage frost spells → Frost row
            arcane   = "arcaneum", -- non-Mage arcane spells → Arcane row
        }
        local lookupKey = PARENT[schoolKey] or schoolKey
        local mapped = assignments[schoolKey] or (lookupKey ~= schoolKey and assignments[lookupKey])
        -- "none" = pas d'override : détection naturelle de l'école
        if mapped == "none" then
            return schoolKey
        end
        -- "blizzard" = sentinelle : OCB se retire, la barre Blizzard gère ce sort
        if mapped == "blizzard" then
            return "blizzard"
        end
        if mapped and self.data[mapped] then
            return mapped
        end
    end
    return schoolKey
end

-- ============================================================
--  TABLE DES SORTS EMPOWERED EVOKER
--  Chaque sort empowered → frame colorée à utiliser sur la barre Bronze
--  "bronze" = Frame_Bronze standard (sorts Augmentation)
--  "red"    = Frame_Bronze_Red (feu)
--  "green"  = Frame_Bronze_Green (nature/soin vert)
--  "azur"   = Frame_Bronze_Azur (arcane/spellfrost bleu)
-- ============================================================
--  TABLE DES SORTS EMPOWERED EVOKER
--  Déclenchés via UNIT_SPELLCAST_EMPOWER_START
--  frame = couleur du cadre Bronze à utiliser
--  fill  = true → Fill_Bronze_Evoker | false → Fill_Bronze normal
-- ============================================================
SCB.Schools.empowerTable = {
    [357208] = { frame="red",    fill=true  }, -- Fire Breath / Souffle de feu ✓
    [382266] = { frame="red",    fill=true  }, -- Fire Breath (Font of Magic)
    [359073] = { frame="azur",   fill=true  }, -- Eternity Surge / Afflux d'éternité
    [387839] = { frame="azur",   fill=true  }, -- Eternity Surge rang 2
    [382411] = { frame="azur",   fill=true  }, -- Eternity Surge (Font of Magic)
    [355936] = { frame="green",  fill=true  }, -- Dream Breath / Souffle onirique ✓ ID=355936
    [382614] = { frame="green",  fill=true  }, -- Dream Breath (Font of Magic)
    [367226] = { frame="green",  fill=true  }, -- Spiritbloom / Floraison spirituelle
    [409895] = { frame="green",  fill=true  }, -- Spiritbloom (variante)
    [396286] = { frame="bronze", fill=true  }, -- Upheaval / Soulèvement ✓
    [408092] = { frame="bronze", fill=true  }, -- Upheaval (Font of Magic)
}

-- ============================================================
--  TABLE DES SORTS EVOKER BRONZE NON-EMPOWERED
--  Via SPELLCAST_START normal → barre Bronze colorée
--  fill=true  → Fill_Bronze_Evoker
--  fill=false → Fill_Bronze standard (pas un sort "chargé")
-- ============================================================
SCB.Schools.evokerBronzeTable = {
    [361469] = { frame="red",  fill=false }, -- Living Flame / Flamme vivante
    [431443] = { frame="red",  fill=false }, -- Chrono Flames / Flammes chrono
    [395160] = { frame="red",  fill=false }, -- Eruption / Éruption
    [356995] = { frame="azur", fill=false }, -- Disintegrate / Désintégration
}

-- Frame et fill en attente pour le prochain ApplySchool
SCB.Schools.pendingEmpowerFrame = nil
SCB.Schools.pendingEmpowerFill  = false

-- ============================================================
--  GREEN FIRE WARLOCK
--  The Codex of Xerrath (spellID 101508) est un aura passif
--  permanent appliqué sur le joueur après la quête Green Fire.
--  On le détecte via UnitAura("player", 101508).
--  Si actif, les sorts de feu Warlock passent en felfire.
-- ============================================================
SCB.Schools.greenFireSpells = {
    [196396] = true, -- Incinerate (retail)
    [29722]  = true, -- Incinerate rang 1
    [29975]  = true, -- Incinerate rang 2
    [47837]  = true, -- Incinerate rang 3
    [47838]  = true, -- Incinerate rang 4
    [348]    = true, -- Immolate rang 1
    [707]    = true, -- Immolate rang 2
    [1094]   = true, -- Immolate rang 3
    [2941]   = true, -- Immolate rang 4
    [11665]  = true, -- Immolate rang 5
    [11667]  = true, -- Immolate rang 6
    [11668]  = true, -- Immolate rang 7
    [25309]  = true, -- Immolate rang 8
    [47810]  = true, -- Immolate rang 9
    [47811]  = true, -- Immolate rang 10
    [348527] = true, -- Immolate (retail)
    [152108] = true, -- Cataclysm
    [6353]   = true, -- Soul Fire
    [196447] = true, -- Channel Demonfire
}

-- Cache pour éviter de rappeler UnitAura à chaque cast
SCB.Schools._greenFireCache = nil
SCB.Schools._greenFireCacheTime = 0

function SCB.Schools:HasGreenFire()
    local now = GetTime()
    if self._greenFireCache ~= nil and (now - self._greenFireCacheTime) < 10 then
        return self._greenFireCache
    end
    -- The Codex of Xerrath = passive aura. Multiple IDs observed across patches.
    -- 101508 = original, 101511 = alternate, 138949 = visual overlay
    local GREEN_FIRE_AURAS = { [101508]=true, [101511]=true, [138949]=true }
    local hasGF = false
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        for id in pairs(GREEN_FIRE_AURAS) do
            if C_UnitAuras.GetPlayerAuraBySpellID(id) ~= nil then
                hasGF = true ; break
            end
        end
    elseif UnitAura then
        local i = 1
        while true do
            local _, _, _, _, _, _, _, _, _, spellId = UnitAura("player", i, "HELPFUL|PASSIVE")
            if not spellId then break end
            if GREEN_FIRE_AURAS[spellId] then hasGF = true ; break end
            i = i + 1
        end
    end
    -- Fallback : vérifier si le joueur est un Démoniste via GetSpellInfo sur le sort Green Fire
    -- Si HasGreenFire échoue malgré tout, on vérifie aussi IsSpellKnown pour les sorts de déclenchement
    if not hasGF and IsSpellKnown then
        -- Green Fire toggle spell IDs (le sort de quête / compétence de classe)
        for _, id in ipairs({138200, 101508, 101511}) do
            if IsSpellKnown(id) then hasGF = true ; break end
        end
    end
    self._greenFireCache = hasGF
    self._greenFireCacheTime = now
    return hasGF
end

function SCB.Schools:_remapDetectedSchoolForPlayer(key)
    -- Demande produit : les sorts Frost du Mage utilisent Arctic par défaut.
    if key ~= "frost" and key ~= "arcane" then return key end
    if UnitClass then
        local _, classFile = UnitClass("player")
        if classFile == "MAGE" then
            if key == "frost" then
                return "arctic"
            end
            if key == "arcane" then
                return "arcaneum"
            end
        end
    end
    return key
end

function SCB.Schools:DetectFromSpell(spellID, isEmpower)
    -- Sorts empowered : toujours Bronze, frame + fill selon la config
    if isEmpower and spellID and self.empowerTable[spellID] then
        local e = self.empowerTable[spellID]
        self.pendingEmpowerFrame = e.frame
        self.pendingEmpowerFill  = e.fill
        if SCB._debugMode then
            print(string.format("|cffFF9900[SCB Debug]|r DetectFromSpell spellID=%s → |cffFFAA00EMPOWER bronze/%s fill=%s|r",
                tostring(spellID), tostring(e.frame), tostring(e.fill)))
        end
        return "bronze"
    end

    -- Sorts Evoker non-empowered → Bronze coloré
    if spellID and self.evokerBronzeTable[spellID] then
        local e = self.evokerBronzeTable[spellID]
        self.pendingEmpowerFrame = e.frame
        self.pendingEmpowerFill  = e.fill
        if SCB._debugMode then
            print(string.format("|cffFF9900[SCB Debug]|r DetectFromSpell spellID=%s → |cffAAFFAAevokerBronze/%s fill=%s|r",
                tostring(spellID), tostring(e.frame), tostring(e.fill)))
        end
        return "bronze"
    end

    self.pendingEmpowerFrame = nil
    self.pendingEmpowerFill  = false

    -- Si l'utilisateur veut une barre fixe pour tous les sorts
    if SCB.Config and not SCB.Config:Get("useSchoolDetection") then
        return self:_firstAvailable()
    end

    if spellID and SCB.Config and SCB.Config:Get("useThemeAssignments")
       and OCBSpellOverridesDB and OCBSpellOverridesDB[spellID] then
        local forced = OCBSpellOverridesDB[spellID]
        if self.data[forced] then
            return forced
        end
    end

    if not spellID then return self:_firstAvailable() end

    -- Méthode 1 : table manuelle (prioritaire)
    local manual = self.spellTable[spellID]
    if manual then
        -- Green Fire Warlock : override lava → felfire si sorts concernés
        if manual == "lava" and self.greenFireSpells[spellID] and self:HasGreenFire() then
            return self:_applyThemeAssignment("felfire")
        end
        local mapped = self:_remapDetectedSchoolForPlayer(manual)
        if self.data[mapped] then return self:_applyThemeAssignment(mapped) end
    end

    -- Méthode 2 : C_Spell.GetSpellSchools
    if C_Spell and C_Spell.GetSpellSchools then
        local schools = C_Spell.GetSpellSchools(spellID)
        if schools then
            for _, bits in ipairs({64, 32, 16, 8, 4, 2, 1}) do
                for _, s in ipairs(schools) do
                    if s == bits then
                        local key = self.maskMap[bits]
                        if key and self.data[key] then
                            if key == "lava" and self.greenFireSpells[spellID] and self:HasGreenFire() then
                                return self:_applyThemeAssignment("felfire")
                            end
                            key = self:_remapDetectedSchoolForPlayer(key)
                            return self:_applyThemeAssignment(key)
                        end
                    end
                end
            end
        end
    end

    -- Méthode 3 : C_Spell.GetSpellInfo
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            local mask = info.schoolMask or info.spellSchool
            if mask and mask > 0 then
                for _, bits in ipairs({64, 32, 16, 8, 4, 2, 1}) do
                    if (mask % (bits * 2)) >= bits then
                        local key = self.maskMap[bits]
                        key = self:_remapDetectedSchoolForPlayer(key)
                        if key and self.data[key] then return self:_applyThemeAssignment(key) end
                    end
                end
            end
        end
    end

    -- Méthode 4 : ancienne API Classic
    if GetSpellInfo then
        local _,_,_,_,_,_,_,school = GetSpellInfo(spellID)
        if school and school > 0 then
            for _, bits in ipairs({64, 32, 16, 8, 4, 2, 1}) do
                if (school % (bits * 2)) >= bits then
                    local key = self.maskMap[bits]
                    key = self:_remapDetectedSchoolForPlayer(key)
                    if key and self.data[key] then return self:_applyThemeAssignment(key) end
                end
            end
        end
    end

    return self:_firstAvailable()
end
