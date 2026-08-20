-- ============================================================
--  Opulent Casting Bars — Schools.lua
-- ============================================================

SCB.Schools = {}

-- ---- Définitions des écoles --------------------------------
SCB.Schools.data = {

    -- ==== Restored custom styles (Chaos / Fists / Mistweaver / Chi'ji / Bronze) ====
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

    fists = {
        name         = "Fists of Fury",
        frame        = SCB.TEX_PATH .. "fists\\Frame_Fists",
        fill         = SCB.TEX_PATH .. "fists\\Fill_Fists",
        bg           = SCB.TEX_PATH .. "fists\\BG_Fists",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.1533,
        fillMarginR  = 0.0977,
        noReverse    = true,
        textOffY      = 2,
        textNameOffX  = 35,
        textTimerOffX = -15,
        frameLight   = SCB.TEX_PATH .. "fists\\Frame_Fists_Light",
        fists = {
            SCB.TEX_PATH .. "fists\\Fists_01",
            SCB.TEX_PATH .. "fists\\Fists_02",
            SCB.TEX_PATH .. "fists\\Fists_03",
            SCB.TEX_PATH .. "fists\\Fists_04",
            SCB.TEX_PATH .. "fists\\Fists_Small",
        },
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
        frameLight   = SCB.TEX_PATH .. "mistweaver\\Frame_Mistweaver_Light",
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
        frameLight   = SCB.TEX_PATH .. "chiji\\Frame_Chiji_Light",
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

    void = {
        name         = "Void",
        frame        = SCB.TEX_PATH .. "void\\Frame_Void",
        fill         = SCB.TEX_PATH .. "void\\Fill_Void",
        bg           = SCB.TEX_PATH .. "void\\BG_Void",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.0908,
        fillMarginR  = 0.0977,
        textOffY     = 2,
        frameLight   = SCB.TEX_PATH .. "void\\Frame_Void_Light",
        frameLightAlpha = 0.55,
        vortex       = SCB.TEX_PATH .. "void\\Vortex",
        misc         = {
            SCB.TEX_PATH .. "holy\\Misc_Holy_01",
            SCB.TEX_PATH .. "holy\\Misc_Holy_02",
        },
    },

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
        frameLight  = SCB.TEX_PATH .. "thunder\\Light_Thunder",
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

    holy = {
        name         = "Holy",
        frame        = SCB.TEX_PATH .. "holy\\Frame_Holy",
        fill         = SCB.TEX_PATH .. "holy\\Fill_Holy",
        bg           = SCB.TEX_PATH .. "holy\\BG_Holy",
        uvSpeed      = 0,
        uvDir        = 1,
        fillMarginL  = 0.1758,
        fillMarginR  = 0.1709,
        frameLight   = SCB.TEX_PATH .. "holy\\Light_Holy",
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
        frameLight   = SCB.TEX_PATH .. "moon\\Frame_Moon_Light",
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
        frameLight    = SCB.TEX_PATH .. "water\\Frame_Water_Light",
        -- Anneau d'eau animé (cercles masqués au bord de la barre)
        circle        = SCB.TEX_PATH .. "water\\Water_Circle",
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
        frameLight   = SCB.TEX_PATH .. "sacred\\Frame_Sacred_Light",
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
        frameLight   = SCB.TEX_PATH .. "paladin\\Frame_Paladin_Light",
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
        bgLightBlend = "BLEND",
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
        frameLight  = SCB.TEX_PATH .. "inferno\\Frame_Inferno_Light",
        frame       = SCB.TEX_PATH .. "inferno\\Frame_Inferno",
        fill        = SCB.TEX_PATH .. "inferno\\Fill_Inferno",
        bg          = SCB.TEX_PATH .. "inferno\\BG_Inferno",
        flames      = {
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_01",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_02",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_03",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_04",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_05",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_06",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_07",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_08",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_09",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_10",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_11",
            SCB.TEX_PATH .. "inferno\\Fire_Inferno_12",
        },
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
    [1]  = "neutral",
    [20] = "frostfire",   -- fire(4) + frost(16) combinés
}

-- ---- Table manuelle spellID → école -----------------------
-- Prioritaire sur les APIs Blizzard, à compléter par sort
SCB.Schools.spellTable = {

    -- =====================================================
    --  WotLK 3.3.5a (build 12340) class spell mappings
    --  Retail/Cataclysm+ spell IDs intentionally removed.
    -- =====================================================

    -- =====================================================
    --  DEATH KNIGHT — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- -----------------------------------------------------
    -- Normal class abilities
    -- -----------------------------------------------------
    [50977] = "shadow", -- Death Gate — 10 sec cast
    [42650] = "shadow", -- Army of the Dead — 4 sec channel

    -- -----------------------------------------------------
    -- Death Knight class mounts
    -- -----------------------------------------------------
    [48778] = "shadow",  -- Acherus Deathcharger — 1.5 sec cast
    [54729] = "shadow", -- Winged Steed of the Ebon Blade — 1.5 sec cast

    -- -----------------------------------------------------
    -- Runeforging recipes
    -- All have a 5 sec cast
    -- -----------------------------------------------------
    [53341] = "neutral", -- Rune of Cinderglacier
    [53343] = "neutral", -- Rune of Razorice

    [54447] = "neutral", -- Rune of Spellbreaking — one-handed
    [53342] = "neutral", -- Rune of Spellshattering — two-handed

    [53331] = "neutral", -- Rune of Lichbane

    [54446] = "neutral", -- Rune of Swordbreaking — one-handed
    [53323] = "neutral", -- Rune of Swordshattering — two-handed

    [53344] = "neutral", -- Rune of the Fallen Crusader

    [62158] = "neutral", -- Rune of the Stoneskin Gargoyle — two-handed
    [70164] = "neutral", -- Rune of the Nerubian Carapace — one-handed

    -- =====================================================
    --  DRUID — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- -----------------------------------------------------
    -- Teleport: Moonglade
    -- -----------------------------------------------------
    [18960] = "moon", -- Teleport: Moonglade

    -- -----------------------------------------------------
    -- Wrath — ranks 1–12
    -- -----------------------------------------------------
    [5176]  = "nature", -- Wrath rank 1
    [5177]  = "nature", -- Wrath rank 2
    [5178]  = "nature", -- Wrath rank 3
    [5179]  = "nature", -- Wrath rank 4
    [5180]  = "nature", -- Wrath rank 5
    [6780]  = "nature", -- Wrath rank 6
    [8905]  = "nature", -- Wrath rank 7
    [9912]  = "nature", -- Wrath rank 8
    [26984] = "nature", -- Wrath rank 9
    [26985] = "nature", -- Wrath rank 10
    [48459] = "nature", -- Wrath rank 11
    [48461] = "nature", -- Wrath rank 12

    -- -----------------------------------------------------
    -- Starfire — ranks 1–10
    -- -----------------------------------------------------
    [2912]  = "moon", -- Starfire rank 1
    [8949]  = "moon", -- Starfire rank 2
    [8950]  = "moon", -- Starfire rank 3
    [8951]  = "moon", -- Starfire rank 4
    [9875]  = "moon", -- Starfire rank 5
    [9876]  = "moon", -- Starfire rank 6
    [25298] = "moon", -- Starfire rank 7
    [26986] = "moon", -- Starfire rank 8
    [48464] = "moon", -- Starfire rank 9
    [48465] = "moon", -- Starfire rank 10

    -- -----------------------------------------------------
    -- Entangling Roots — ranks 1–8
    -- -----------------------------------------------------
    [339]   = "nature", -- Entangling Roots rank 1
    [1062]  = "nature", -- Entangling Roots rank 2
    [5195]  = "nature", -- Entangling Roots rank 3
    [5196]  = "nature", -- Entangling Roots rank 4
    [9852]  = "nature", -- Entangling Roots rank 5
    [9853]  = "nature", -- Entangling Roots rank 6
    [26989] = "nature", -- Entangling Roots rank 7
    [53308] = "nature", -- Entangling Roots rank 8

    -- -----------------------------------------------------
    -- Hibernate — ranks 1–3
    -- -----------------------------------------------------
    [2637]  = "nature", -- Hibernate rank 1
    [18657] = "nature", -- Hibernate rank 2
    [18658] = "nature", -- Hibernate rank 3

    -- -----------------------------------------------------
    -- Cyclone
    -- -----------------------------------------------------
    [33786] = "nature", -- Cyclone

    -- -----------------------------------------------------
    -- Hurricane — ranks 1–5
    -- Channeled
    -- -----------------------------------------------------
    [16914] = "nature", -- Hurricane rank 1
    [17401] = "nature", -- Hurricane rank 2
    [17402] = "nature", -- Hurricane rank 3
    [27012] = "nature", -- Hurricane rank 4
    [48467] = "nature", -- Hurricane rank 5

    -- -----------------------------------------------------
    -- Healing Touch — ranks 1–15
    -- -----------------------------------------------------
    [5185]  = "nature", -- Healing Touch rank 1
    [5186]  = "nature", -- Healing Touch rank 2
    [5187]  = "nature", -- Healing Touch rank 3
    [5188]  = "nature", -- Healing Touch rank 4
    [5189]  = "nature", -- Healing Touch rank 5
    [6778]  = "nature", -- Healing Touch rank 6
    [8903]  = "nature", -- Healing Touch rank 7
    [9758]  = "nature", -- Healing Touch rank 8
    [9888]  = "nature", -- Healing Touch rank 9
    [9889]  = "nature", -- Healing Touch rank 10
    [25297] = "nature", -- Healing Touch rank 11
    [26978] = "nature", -- Healing Touch rank 12
    [26979] = "nature", -- Healing Touch rank 13
    [48377] = "nature", -- Healing Touch rank 14
    [48378] = "nature", -- Healing Touch rank 15

    -- -----------------------------------------------------
    -- Regrowth — ranks 1–12
    -- -----------------------------------------------------
    [8936]  = "nature", -- Regrowth rank 1
    [8938]  = "nature", -- Regrowth rank 2
    [8939]  = "nature", -- Regrowth rank 3
    [8940]  = "nature", -- Regrowth rank 4
    [8941]  = "nature", -- Regrowth rank 5
    [9750]  = "nature", -- Regrowth rank 6
    [9856]  = "nature", -- Regrowth rank 7
    [9857]  = "nature", -- Regrowth rank 8
    [9858]  = "nature", -- Regrowth rank 9
    [26980] = "nature", -- Regrowth rank 10
    [48442] = "nature", -- Regrowth rank 11
    [48443] = "nature", -- Regrowth rank 12

    -- -----------------------------------------------------
    -- Nourish
    -- -----------------------------------------------------
    [50464] = "nature", -- Nourish

    -- -----------------------------------------------------
    -- Rebirth — ranks 1–7
    -- Combat resurrection
    -- -----------------------------------------------------
    [20484] = "nature", -- Rebirth rank 1
    [20739] = "nature", -- Rebirth rank 2
    [20742] = "nature", -- Rebirth rank 3
    [20747] = "nature", -- Rebirth rank 4
    [20748] = "nature", -- Rebirth rank 5
    [26994] = "nature", -- Rebirth rank 6
    [48477] = "nature", -- Rebirth rank 7

    -- -----------------------------------------------------
    -- Revive — ranks 1–7
    -- 10-second cast
    -- -----------------------------------------------------
    [50769] = "nature", -- Revive rank 1
    [50768] = "nature", -- Revive rank 2
    [50767] = "nature", -- Revive rank 3
    [50766] = "nature", -- Revive rank 4
    [50765] = "nature", -- Revive rank 5
    [50764] = "nature", -- Revive rank 6
    [50763] = "nature", -- Revive rank 7

    -- -----------------------------------------------------
    -- Tranquility — ranks 1–7
    -- Channeled
    -- -----------------------------------------------------
    [740]   = "nature", -- Tranquility rank 1
    [8918]  = "nature", -- Tranquility rank 2
    [9862]  = "nature", -- Tranquility rank 3
    [9863]  = "nature", -- Tranquility rank 4
    [26983] = "nature", -- Tranquility rank 5
    [48446] = "nature", -- Tranquility rank 6
    [48447] = "nature", -- Tranquility rank 7

    -- =====================================================
    --  HUNTER — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- Pet abilities
    [2641] = "aim", -- Dismiss Pet — 5 sec cast
    [982]  = "aim", -- Revive Pet — 10 sec cast
    [1515] = "aim", -- Tame Beast — 20 sec channel

    -- Vision abilities
    [6197] = "aim", -- Eagle Eye — channeled
    [1002] = "aim", -- Eyes of the Beast — 2 sec cast/channel

    -- Scare Beast — ranks 1–3
    [1513]  = "aim", -- Scare Beast rank 1 — 1.5 sec cast
    [14326] = "aim", -- Scare Beast rank 2 — 1.5 sec cast
    [14327] = "aim", -- Scare Beast rank 3 — 1.5 sec cast

    -- Volley — ranks 1–6
    [1510]  = "aim", -- Volley rank 1 — channel
    [14294] = "aim", -- Volley rank 2 — channel
    [14295] = "aim", -- Volley rank 3 — channel
    [27022] = "aim", -- Volley rank 4 — channel
    [58431] = "aim", -- Volley rank 5 — channel
    [58434] = "aim", -- Volley rank 6 — channel

    -- Steady Shot — ranks 1–4
    [56641] = "aim", -- Steady Shot rank 1 — 1.5 sec cast
    [34120] = "aim", -- Steady Shot rank 2 — 1.5 sec cast
    [49051] = "aim", -- Steady Shot rank 3 — 1.5 sec cast
    [49052] = "aim", -- Steady Shot rank 4 — 1.5 sec cast

        -- =====================================================
    --  MAGE — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- =====================================================
    --  ARCANE
    -- =====================================================

    -- Arcane Missiles — ranks 1–13
    -- Channeled
    [5143]  = "arcane", -- Arcane Missiles rank 1
    [5144]  = "arcane", -- Arcane Missiles rank 2
    [5145]  = "arcane", -- Arcane Missiles rank 3
    [8416]  = "arcane", -- Arcane Missiles rank 4
    [8417]  = "arcane", -- Arcane Missiles rank 5
    [10211] = "arcane", -- Arcane Missiles rank 6
    [10212] = "arcane", -- Arcane Missiles rank 7
    [25345] = "arcane", -- Arcane Missiles rank 8
    [27075] = "arcane", -- Arcane Missiles rank 9
    [38699] = "arcane", -- Arcane Missiles rank 10
    [38704] = "arcane", -- Arcane Missiles rank 11
    [42843] = "arcane", -- Arcane Missiles rank 12
    [42846] = "arcane", -- Arcane Missiles rank 13

    -- Arcane Blast — ranks 1–4
    [30451] = "arcane", -- Arcane Blast rank 1
    [42894] = "arcane", -- Arcane Blast rank 2
    [42896] = "arcane", -- Arcane Blast rank 3
    [42897] = "arcane", -- Arcane Blast rank 4

    -- Evocation
    -- Channeled
    [12051] = "arcane", -- Evocation

    -- Polymorph: Sheep — ranks 1–4
    [118]   = "arcane", -- Polymorph rank 1
    [12824] = "arcane", -- Polymorph rank 2
    [12825] = "arcane", -- Polymorph rank 3
    [12826] = "arcane", -- Polymorph rank 4

    -- Polymorph cosmetic variants
    [28271] = "arcane", -- Polymorph: Turtle
    [28272] = "arcane", -- Polymorph: Pig
    [61025] = "arcane", -- Polymorph: Serpent
    [61305] = "arcane", -- Polymorph: Black Cat
    [61721] = "arcane", -- Polymorph: Rabbit
    [61780] = "arcane", -- Polymorph: Turkey

    -- -----------------------------------------------------
    -- Conjure Water — ranks 1–9
    -- -----------------------------------------------------
    [5504]  = "arcane", -- Conjure Water rank 1
    [5505]  = "arcane", -- Conjure Water rank 2
    [5506]  = "arcane", -- Conjure Water rank 3
    [6127]  = "arcane", -- Conjure Water rank 4
    [10138] = "arcane", -- Conjure Water rank 5
    [10139] = "arcane", -- Conjure Water rank 6
    [10140] = "arcane", -- Conjure Water rank 7
    [37420] = "arcane", -- Conjure Water rank 8
    [27090] = "arcane", -- Conjure Water rank 9

    -- -----------------------------------------------------
    -- Conjure Food — ranks 1–8
    -- -----------------------------------------------------
    [587]   = "arcane", -- Conjure Food rank 1
    [597]   = "arcane", -- Conjure Food rank 2
    [990]   = "arcane", -- Conjure Food rank 3
    [6129]  = "arcane", -- Conjure Food rank 4
    [10144] = "arcane", -- Conjure Food rank 5
    [10145] = "arcane", -- Conjure Food rank 6
    [28612] = "arcane", -- Conjure Food rank 7
    [33717] = "arcane", -- Conjure Food rank 8

    -- -----------------------------------------------------
    -- Conjure Mana Gem — ranks 1–6
    -- -----------------------------------------------------
    [759]   = "arcane", -- Conjure Mana Gem rank 1
    [3552]  = "arcane", -- Conjure Mana Gem rank 2
    [10053] = "arcane", -- Conjure Mana Gem rank 3
    [10054] = "arcane", -- Conjure Mana Gem rank 4
    [27101] = "arcane", -- Conjure Mana Gem rank 5
    [42985] = "arcane", -- Conjure Mana Gem rank 6

    -- Conjure Refreshment — ranks 1–2
    [42955] = "arcane", -- Conjure Refreshment rank 1
    [42956] = "arcane", -- Conjure Refreshment rank 2

    -- Ritual of Refreshment — ranks 1–2
    [43987] = "arcane", -- Ritual of Refreshment rank 1
    [58659] = "arcane", -- Ritual of Refreshment rank 2

    -- -----------------------------------------------------
    -- Alliance teleports
    -- 10-second casts
    -- -----------------------------------------------------
    [3561]  = "arcane", -- Teleport: Stormwind
    [3562]  = "arcane", -- Teleport: Ironforge
    [3565]  = "arcane", -- Teleport: Darnassus
    [32271] = "arcane", -- Teleport: Exodar
    [49359] = "arcane", -- Teleport: Theramore
    [33690] = "arcane", -- Teleport: Shattrath — Alliance
    [53140] = "arcane", -- Teleport: Dalaran — Alliance

    -- Horde teleports
    [3567]  = "arcane", -- Teleport: Orgrimmar
    [3563]  = "arcane", -- Teleport: Undercity
    [3566]  = "arcane", -- Teleport: Thunder Bluff
    [32272] = "arcane", -- Teleport: Silvermoon
    [49358] = "arcane", -- Teleport: Stonard
    [35715] = "arcane", -- Teleport: Shattrath — Horde
    [53142] = "arcane", -- Teleport: Dalaran — Horde

    -- -----------------------------------------------------
    -- Alliance portals
    -- 10-second casts
    -- -----------------------------------------------------
    [10059] = "arcane", -- Portal: Stormwind
    [11416] = "arcane", -- Portal: Ironforge
    [11419] = "arcane", -- Portal: Darnassus
    [32266] = "arcane", -- Portal: Exodar
    [49360] = "arcane", -- Portal: Theramore
    [33691] = "arcane", -- Portal: Shattrath — Alliance
    [53156] = "arcane", -- Portal: Dalaran — Alliance

    -- Horde portals
    [11417] = "arcane", -- Portal: Orgrimmar
    [11418] = "arcane", -- Portal: Undercity
    [11420] = "arcane", -- Portal: Thunder Bluff
    [32267] = "arcane", -- Portal: Silvermoon
    [49361] = "arcane", -- Portal: Stonard
    [35717] = "arcane", -- Portal: Shattrath — Horde
    [53170] = "arcane", -- Portal: Dalaran — Horde

    -- =====================================================
    --  FIRE
    -- =====================================================

    -- Fireball — ranks 1–16
    [133]   = "inferno", -- Fireball rank 1
    [143]   = "inferno", -- Fireball rank 2
    [145]   = "inferno", -- Fireball rank 3
    [3140]  = "inferno", -- Fireball rank 4
    [8400]  = "inferno", -- Fireball rank 5
    [8401]  = "inferno", -- Fireball rank 6
    [8402]  = "inferno", -- Fireball rank 7
    [10148] = "inferno", -- Fireball rank 8
    [10149] = "inferno", -- Fireball rank 9
    [10150] = "inferno", -- Fireball rank 10
    [10151] = "inferno", -- Fireball rank 11
    [25306] = "inferno", -- Fireball rank 12
    [27070] = "inferno", -- Fireball rank 13
    [38692] = "inferno", -- Fireball rank 14
    [42832] = "inferno", -- Fireball rank 15
    [42833] = "inferno", -- Fireball rank 16

    -- Scorch — ranks 1–11
    [2948]  = "inferno", -- Scorch rank 1
    [8444]  = "inferno", -- Scorch rank 2
    [8445]  = "inferno", -- Scorch rank 3
    [8446]  = "inferno", -- Scorch rank 4
    [10205] = "inferno", -- Scorch rank 5
    [10206] = "inferno", -- Scorch rank 6
    [10207] = "inferno", -- Scorch rank 7
    [27073] = "inferno", -- Scorch rank 8
    [27074] = "inferno", -- Scorch rank 9
    [42858] = "inferno", -- Scorch rank 10
    [42859] = "inferno", -- Scorch rank 11

    -- Flamestrike — ranks 1–9
    [2120]  = "inferno", -- Flamestrike rank 1
    [2121]  = "inferno", -- Flamestrike rank 2
    [8422]  = "inferno", -- Flamestrike rank 3
    [8423]  = "inferno", -- Flamestrike rank 4
    [10215] = "inferno", -- Flamestrike rank 5
    [10216] = "inferno", -- Flamestrike rank 6
    [27086] = "inferno", -- Flamestrike rank 7
    [42925] = "inferno", -- Flamestrike rank 8
    [42926] = "inferno", -- Flamestrike rank 9

    -- Pyroblast — ranks 1–12
    [11366] = "inferno", -- Pyroblast rank 1
    [12505] = "inferno", -- Pyroblast rank 2
    [12522] = "inferno", -- Pyroblast rank 3
    [12523] = "inferno", -- Pyroblast rank 4
    [12524] = "inferno", -- Pyroblast rank 5
    [12525] = "inferno", -- Pyroblast rank 6
    [12526] = "inferno", -- Pyroblast rank 7
    [18809] = "inferno", -- Pyroblast rank 8
    [27132] = "inferno", -- Pyroblast rank 9
    [33938] = "inferno", -- Pyroblast rank 10
    [42890] = "inferno", -- Pyroblast rank 11
    [42891] = "inferno", -- Pyroblast rank 12

    -- =====================================================
    --  FROST
    -- =====================================================

    -- Frostbolt — ranks 1–16
    [116]   = "frost", -- Frostbolt rank 1
    [205]   = "frost", -- Frostbolt rank 2
    [837]   = "frost", -- Frostbolt rank 3
    [7322]  = "frost", -- Frostbolt rank 4
    [8406]  = "frost", -- Frostbolt rank 5
    [8407]  = "frost", -- Frostbolt rank 6
    [8408]  = "frost", -- Frostbolt rank 7
    [10179] = "frost", -- Frostbolt rank 8
    [10180] = "frost", -- Frostbolt rank 9
    [10181] = "frost", -- Frostbolt rank 10
    [25304] = "frost", -- Frostbolt rank 11
    [27071] = "frost", -- Frostbolt rank 12
    [27072] = "frost", -- Frostbolt rank 13
    [38697] = "frost", -- Frostbolt rank 14
    [42841] = "frost", -- Frostbolt rank 15
    [42842] = "frost", -- Frostbolt rank 16

    -- Blizzard — ranks 1–9
    -- Channeled
    [10]    = "frost", -- Blizzard rank 1
    [6141]  = "frost", -- Blizzard rank 2
    [8427]  = "frost", -- Blizzard rank 3
    [10185] = "frost", -- Blizzard rank 4
    [10186] = "frost", -- Blizzard rank 5
    [10187] = "frost", -- Blizzard rank 6
    [27085] = "frost", -- Blizzard rank 7
    [42939] = "frost", -- Blizzard rank 8
    [42940] = "frost", -- Blizzard rank 9

    -- =====================================================
    --  FROSTFIRE
    -- =====================================================

    -- Frostfire Bolt — ranks 1–2
    [44614] = "frostfire", -- Frostfire Bolt rank 1
    [47610] = "frostfire", -- Frostfire Bolt rank 2


    -- =====================================================
    --  PALADIN — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- =====================================================
    --  HOLY LIGHT — ranks 1–13
    --  Base cast time: 2.5 sec
    -- =====================================================
    [635]   = "paladin", -- Holy Light rank 1
    [639]   = "paladin", -- Holy Light rank 2
    [647]   = "paladin", -- Holy Light rank 3
    [1026]  = "paladin", -- Holy Light rank 4
    [1042]  = "paladin", -- Holy Light rank 5
    [3472]  = "paladin", -- Holy Light rank 6
    [10328] = "paladin", -- Holy Light rank 7
    [10329] = "paladin", -- Holy Light rank 8
    [25292] = "paladin", -- Holy Light rank 9
    [27135] = "paladin", -- Holy Light rank 10
    [27136] = "paladin", -- Holy Light rank 11
    [48781] = "paladin", -- Holy Light rank 12
    [48782] = "paladin", -- Holy Light rank 13

    -- =====================================================
    --  FLASH OF LIGHT — ranks 1–9
    --  Base cast time: 1.5 sec
    -- =====================================================
    [19750] = "paladin", -- Flash of Light rank 1
    [19939] = "paladin", -- Flash of Light rank 2
    [19940] = "paladin", -- Flash of Light rank 3
    [19941] = "paladin", -- Flash of Light rank 4
    [19942] = "paladin", -- Flash of Light rank 5
    [19943] = "paladin", -- Flash of Light rank 6
    [27137] = "paladin", -- Flash of Light rank 7
    [48784] = "paladin", -- Flash of Light rank 8
    [48785] = "paladin", -- Flash of Light rank 9

    -- =====================================================
    --  EXORCISM — ranks 1–9
    --  Base cast time: 1.5 sec
    -- =====================================================
    [879]   = "paladin", -- Exorcism rank 1
    [5614]  = "paladin", -- Exorcism rank 2
    [5615]  = "paladin", -- Exorcism rank 3
    [10312] = "paladin", -- Exorcism rank 4
    [10313] = "paladin", -- Exorcism rank 5
    [10314] = "paladin", -- Exorcism rank 6
    [27138] = "paladin", -- Exorcism rank 7
    [48800] = "paladin", -- Exorcism rank 8
    [48801] = "paladin", -- Exorcism rank 9

    -- =====================================================
    --  REDEMPTION — ranks 1–7
    --  Cast time: 10 sec
    -- =====================================================
    [7328]  = "paladin", -- Redemption rank 1
    [10322] = "paladin", -- Redemption rank 2
    [10324] = "paladin", -- Redemption rank 3
    [20772] = "paladin", -- Redemption rank 4
    [20773] = "paladin", -- Redemption rank 5
    [48949] = "paladin", -- Redemption rank 6
    [48950] = "paladin", -- Redemption rank 7

    -- =====================================================
    --  TURN EVIL
    --  Cast time: 1.5 sec
    -- =====================================================
    [10326] = "paladin", -- Turn Evil

    -- =====================================================
    --  PALADIN CLASS MOUNTS
    --  Cast time: 1.5 sec
    -- =====================================================

    -- Alliance
    [13819] = "paladin", -- Summon Warhorse
    [23214] = "paladin", -- Summon Charger

    -- Blood Elf / Horde
    [34769] = "paladin", -- Summon Warhorse
    [34767] = "paladin", -- Summon Charger

        -- =====================================================
    --  PRIEST — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- =====================================================
    --  DISCIPLINE / HOLY UTILITY
    -- =====================================================

    -- Shackle Undead — ranks 1–3
    [9484]  = "sacred", -- Shackle Undead rank 1
    [9485]  = "sacred", -- Shackle Undead rank 2
    [10955] = "sacred", -- Shackle Undead rank 3

    -- Mana Burn
    [8129] = "shadow", -- Mana Burn

    -- Mass Dispel
    [32375] = "sacred", -- Mass Dispel

    -- =====================================================
    --  PENANCE — ranks 1–4
    --  Channeled
    -- =====================================================
    [47540] = "sacred", -- Penance rank 1
    [53005] = "sacred", -- Penance rank 2
    [53006] = "sacred", -- Penance rank 3
    [53007] = "sacred", -- Penance rank 4

    -- =====================================================
    --  LESSER HEAL — ranks 1–3
    -- =====================================================
    [2050] = "sacred", -- Lesser Heal rank 1
    [2052] = "sacred", -- Lesser Heal rank 2
    [2053] = "sacred", -- Lesser Heal rank 3

    -- =====================================================
    --  HEAL — ranks 1–4
    -- =====================================================
    [2054] = "sacred", -- Heal rank 1
    [2055] = "sacred", -- Heal rank 2
    [6063] = "sacred", -- Heal rank 3
    [6064] = "sacred", -- Heal rank 4

    -- =====================================================
    --  GREATER HEAL — ranks 1–9
    -- =====================================================
    [2060]  = "sacred", -- Greater Heal rank 1
    [10963] = "sacred", -- Greater Heal rank 2
    [10964] = "sacred", -- Greater Heal rank 3
    [10965] = "sacred", -- Greater Heal rank 4
    [25314] = "sacred", -- Greater Heal rank 5
    [25210] = "sacred", -- Greater Heal rank 6
    [25213] = "sacred", -- Greater Heal rank 7
    [48062] = "sacred", -- Greater Heal rank 8
    [48063] = "sacred", -- Greater Heal rank 9

    -- =====================================================
    --  FLASH HEAL — ranks 1–11
    -- =====================================================
    [2061]  = "sacred", -- Flash Heal rank 1
    [9472]  = "sacred", -- Flash Heal rank 2
    [9473]  = "sacred", -- Flash Heal rank 3
    [9474]  = "sacred", -- Flash Heal rank 4
    [10915] = "sacred", -- Flash Heal rank 5
    [10916] = "sacred", -- Flash Heal rank 6
    [10917] = "sacred", -- Flash Heal rank 7
    [25233] = "sacred", -- Flash Heal rank 8
    [25235] = "sacred", -- Flash Heal rank 9
    [48070] = "sacred", -- Flash Heal rank 10
    [48071] = "sacred", -- Flash Heal rank 11

    -- =====================================================
    --  BINDING HEAL — ranks 1–3
    -- =====================================================
    [32546] = "sacred", -- Binding Heal rank 1
    [48119] = "sacred", -- Binding Heal rank 2
    [48120] = "sacred", -- Binding Heal rank 3

    -- =====================================================
    --  PRAYER OF HEALING — ranks 1–7
    -- =====================================================
    [596]   = "sacred", -- Prayer of Healing rank 1
    [996]   = "sacred", -- Prayer of Healing rank 2
    [10960] = "sacred", -- Prayer of Healing rank 3
    [10961] = "sacred", -- Prayer of Healing rank 4
    [25316] = "sacred", -- Prayer of Healing rank 5
    [25308] = "sacred", -- Prayer of Healing rank 6
    [48072] = "sacred", -- Prayer of Healing rank 7

    -- =====================================================
    --  RESURRECTION — ranks 1–7
    -- =====================================================
    [2006]  = "sacred", -- Resurrection rank 1
    [2010]  = "sacred", -- Resurrection rank 2
    [10880] = "sacred", -- Resurrection rank 3
    [10881] = "sacred", -- Resurrection rank 4
    [20770] = "sacred", -- Resurrection rank 5
    [25435] = "sacred", -- Resurrection rank 6
    [48171] = "sacred", -- Resurrection rank 7

    -- =====================================================
    --  SMITE — ranks 1–12
    -- =====================================================
    [585]   = "sacred", -- Smite rank 1
    [591]   = "sacred", -- Smite rank 2
    [598]   = "sacred", -- Smite rank 3
    [984]   = "sacred", -- Smite rank 4
    [1004]  = "sacred", -- Smite rank 5
    [6060]  = "sacred", -- Smite rank 6
    [10933] = "sacred", -- Smite rank 7
    [10934] = "sacred", -- Smite rank 8
    [25363] = "sacred", -- Smite rank 9
    [25364] = "sacred", -- Smite rank 10
    [48122] = "sacred", -- Smite rank 11
    [48123] = "sacred", -- Smite rank 12

    -- =====================================================
    --  HOLY FIRE — ranks 1–11
    -- =====================================================
    [14914] = "sacred", -- Holy Fire rank 1
    [15262] = "sacred", -- Holy Fire rank 2
    [15263] = "sacred", -- Holy Fire rank 3
    [15264] = "sacred", -- Holy Fire rank 4
    [15265] = "sacred", -- Holy Fire rank 5
    [15266] = "sacred", -- Holy Fire rank 6
    [15267] = "sacred", -- Holy Fire rank 7
    [15261] = "sacred", -- Holy Fire rank 8
    [25384] = "sacred", -- Holy Fire rank 9
    [48134] = "sacred", -- Holy Fire rank 10
    [48135] = "sacred", -- Holy Fire rank 11

    -- =====================================================
    --  LIGHTWELL — ranks 1–6
    --  0.5 sec cast
    -- =====================================================
    [724]   = "sacred", -- Lightwell rank 1
    [27870] = "sacred", -- Lightwell rank 2
    [27871] = "sacred", -- Lightwell rank 3
    [28275] = "sacred", -- Lightwell rank 4
    [48086] = "sacred", -- Lightwell rank 5
    [48087] = "sacred", -- Lightwell rank 6

    -- =====================================================
    --  HOLY CHANNELS
    -- =====================================================
    [64843] = "sacred", -- Divine Hymn
    [64901] = "sacred", -- Hymn of Hope

    -- =====================================================
    --  SHADOW
    -- =====================================================

    -- Mind Blast — ranks 1–13
    [8092]  = "shadow", -- Mind Blast rank 1
    [8102]  = "shadow", -- Mind Blast rank 2
    [8103]  = "shadow", -- Mind Blast rank 3
    [8104]  = "shadow", -- Mind Blast rank 4
    [8105]  = "shadow", -- Mind Blast rank 5
    [8106]  = "shadow", -- Mind Blast rank 6
    [10945] = "shadow", -- Mind Blast rank 7
    [10946] = "shadow", -- Mind Blast rank 8
    [10947] = "shadow", -- Mind Blast rank 9
    [25372] = "shadow", -- Mind Blast rank 10
    [25375] = "shadow", -- Mind Blast rank 11
    [48126] = "shadow", -- Mind Blast rank 12
    [48127] = "shadow", -- Mind Blast rank 13

    -- Mind Flay — ranks 1–9
    -- Channeled
    [15407] = "shadow", -- Mind Flay rank 1
    [17311] = "shadow", -- Mind Flay rank 2
    [17312] = "shadow", -- Mind Flay rank 3
    [17313] = "shadow", -- Mind Flay rank 4
    [17314] = "shadow", -- Mind Flay rank 5
    [18807] = "shadow", -- Mind Flay rank 6
    [25387] = "shadow", -- Mind Flay rank 7
    [48155] = "shadow", -- Mind Flay rank 8
    [48156] = "shadow", -- Mind Flay rank 9

    -- Vampiric Touch — ranks 1–5
    [34914] = "shadow", -- Vampiric Touch rank 1
    [34916] = "shadow", -- Vampiric Touch rank 2
    [34917] = "shadow", -- Vampiric Touch rank 3
    [48159] = "shadow", -- Vampiric Touch rank 4
    [48160] = "shadow", -- Vampiric Touch rank 5

    -- Mind Sear — ranks 1–2
    -- Channeled
    [48045] = "shadow", -- Mind Sear rank 1
    [53023] = "shadow", -- Mind Sear rank 2

    -- Mind Vision — ranks 1–2
    -- Channeled
    [2096]  = "shadow", -- Mind Vision rank 1
    [10909] = "shadow", -- Mind Vision rank 2

    -- Mind Control
    [605] = "shadow", -- Mind Control — cast/channel

    -- =====================================================
    --  ROGUE — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    [1804] = "neutral", -- Pick Lock — 5 sec cast
    [1842] = "neutral", -- Disarm Trap — 1 sec cast

    
        -- =====================================================
    --  SHAMAN — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- =====================================================
    --  ELEMENTAL
    -- =====================================================

    -- Lightning Bolt — ranks 1–14
    [403]   = "thunder", -- Lightning Bolt rank 1
    [529]   = "thunder", -- Lightning Bolt rank 2
    [548]   = "thunder", -- Lightning Bolt rank 3
    [915]   = "thunder", -- Lightning Bolt rank 4
    [943]   = "thunder", -- Lightning Bolt rank 5
    [6041]  = "thunder", -- Lightning Bolt rank 6
    [10391] = "thunder", -- Lightning Bolt rank 7
    [10392] = "thunder", -- Lightning Bolt rank 8
    [15207] = "thunder", -- Lightning Bolt rank 9
    [15208] = "thunder", -- Lightning Bolt rank 10
    [25448] = "thunder", -- Lightning Bolt rank 11
    [25449] = "thunder", -- Lightning Bolt rank 12
    [49237] = "thunder", -- Lightning Bolt rank 13
    [49238] = "thunder", -- Lightning Bolt rank 14

    -- Chain Lightning — ranks 1–8
    [421]   = "thunder", -- Chain Lightning rank 1
    [930]   = "thunder", -- Chain Lightning rank 2
    [2860]  = "thunder", -- Chain Lightning rank 3
    [10605] = "thunder", -- Chain Lightning rank 4
    [25439] = "thunder", -- Chain Lightning rank 5
    [25442] = "thunder", -- Chain Lightning rank 6
    [49270] = "thunder", -- Chain Lightning rank 7
    [49271] = "thunder", -- Chain Lightning rank 8

    -- Lava Burst — ranks 1–2
    [51505] = "lava", -- Lava Burst rank 1
    [60043] = "lava", -- Lava Burst rank 2

    -- Hex
    [51514] = "nature", -- Hex

    -- =====================================================
    --  RESTORATION
    -- =====================================================

    -- Healing Wave — ranks 1–14
    [331]   = "water", -- Healing Wave rank 1
    [332]   = "water", -- Healing Wave rank 2
    [547]   = "water", -- Healing Wave rank 3
    [913]   = "water", -- Healing Wave rank 4
    [939]   = "water", -- Healing Wave rank 5
    [959]   = "water", -- Healing Wave rank 6
    [8005]  = "water", -- Healing Wave rank 7
    [10395] = "water", -- Healing Wave rank 8
    [10396] = "water", -- Healing Wave rank 9
    [25357] = "water", -- Healing Wave rank 10
    [25391] = "water", -- Healing Wave rank 11
    [25396] = "water", -- Healing Wave rank 12
    [49272] = "water", -- Healing Wave rank 13
    [49273] = "water", -- Healing Wave rank 14

    -- Lesser Healing Wave — ranks 1–9
    [8004]  = "water", -- Lesser Healing Wave rank 1
    [8008]  = "water", -- Lesser Healing Wave rank 2
    [8010]  = "water", -- Lesser Healing Wave rank 3
    [10466] = "water", -- Lesser Healing Wave rank 4
    [10467] = "water", -- Lesser Healing Wave rank 5
    [10468] = "water", -- Lesser Healing Wave rank 6
    [25420] = "water", -- Lesser Healing Wave rank 7
    [49275] = "water", -- Lesser Healing Wave rank 8
    [49276] = "water", -- Lesser Healing Wave rank 9

    -- Chain Heal — ranks 1–7
    [1064]  = "water", -- Chain Heal rank 1
    [10622] = "water", -- Chain Heal rank 2
    [10623] = "water", -- Chain Heal rank 3
    [25422] = "water", -- Chain Heal rank 4
    [25423] = "water", -- Chain Heal rank 5
    [55458] = "water", -- Chain Heal rank 6
    [55459] = "water", -- Chain Heal rank 7

    -- Ancestral Spirit — ranks 1–7
    -- Resurrection spell
    [2008]  = "water", -- Ancestral Spirit rank 1
    [20609] = "water", -- Ancestral Spirit rank 2
    [20610] = "water", -- Ancestral Spirit rank 3
    [20776] = "water", -- Ancestral Spirit rank 4
    [20777] = "water", -- Ancestral Spirit rank 5
    [25590] = "water", -- Ancestral Spirit rank 6
    [49277] = "water", -- Ancestral Spirit rank 7

    -- =====================================================
    --  UTILITY
    -- =====================================================

    [2645] = "nature", -- Ghost Wolf — base 3 sec cast
    [6196] = "nature", -- Far Sight — 2 sec cast
    [556]  = "nature", -- Astral Recall — 10 sec cast

        -- =====================================================
    --  WARLOCK — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- =====================================================
    --  SHADOW DAMAGE
    -- =====================================================

    -- Shadow Bolt — ranks 1–13
    [686]   = "shadow", -- Shadow Bolt rank 1
    [695]   = "shadow", -- Shadow Bolt rank 2
    [705]   = "shadow", -- Shadow Bolt rank 3
    [1088]  = "shadow", -- Shadow Bolt rank 4
    [1106]  = "shadow", -- Shadow Bolt rank 5
    [7641]  = "shadow", -- Shadow Bolt rank 6
    [11659] = "shadow", -- Shadow Bolt rank 7
    [11660] = "shadow", -- Shadow Bolt rank 8
    [11661] = "shadow", -- Shadow Bolt rank 9
    [25307] = "shadow", -- Shadow Bolt rank 10
    [27209] = "shadow", -- Shadow Bolt rank 11
    [47808] = "shadow", -- Shadow Bolt rank 12
    [47809] = "shadow", -- Shadow Bolt rank 13

    -- Seed of Corruption — ranks 1–3
    [27243] = "shadow", -- Seed of Corruption rank 1
    [47835] = "shadow", -- Seed of Corruption rank 2
    [47836] = "shadow", -- Seed of Corruption rank 3

    -- Unstable Affliction — ranks 1–5
    [30108] = "shadow", -- Unstable Affliction rank 1
    [30404] = "shadow", -- Unstable Affliction rank 2
    [30405] = "shadow", -- Unstable Affliction rank 3
    [47841] = "shadow", -- Unstable Affliction rank 4
    [47843] = "shadow", -- Unstable Affliction rank 5

    -- Haunt — ranks 1–4
    [48181] = "shadow", -- Haunt rank 1
    [59161] = "shadow", -- Haunt rank 2
    [59163] = "shadow", -- Haunt rank 3
    [59164] = "shadow", -- Haunt rank 4

    -- =====================================================
    --  SHADOW CHANNELS
    -- =====================================================

    -- Drain Soul — ranks 1–6
    [1120]  = "shadow", -- Drain Soul rank 1
    [8288]  = "shadow", -- Drain Soul rank 2
    [8289]  = "shadow", -- Drain Soul rank 3
    [11675] = "shadow", -- Drain Soul rank 4
    [27217] = "shadow", -- Drain Soul rank 5
    [47855] = "shadow", -- Drain Soul rank 6

    -- Drain Life — ranks 1–9
    [689]   = "shadow", -- Drain Life rank 1
    [699]   = "shadow", -- Drain Life rank 2
    [709]   = "shadow", -- Drain Life rank 3
    [7651]  = "shadow", -- Drain Life rank 4
    [11699] = "shadow", -- Drain Life rank 5
    [11700] = "shadow", -- Drain Life rank 6
    [27219] = "shadow", -- Drain Life rank 7
    [27220] = "shadow", -- Drain Life rank 8
    [47857] = "shadow", -- Drain Life rank 9

    -- Drain Mana
    [5138] = "shadow", -- Drain Mana

    -- Health Funnel — ranks 1–9
    [755]   = "shadow", -- Health Funnel rank 1
    [3698]  = "shadow", -- Health Funnel rank 2
    [3699]  = "shadow", -- Health Funnel rank 3
    [3700]  = "shadow", -- Health Funnel rank 4
    [11693] = "shadow", -- Health Funnel rank 5
    [11694] = "shadow", -- Health Funnel rank 6
    [11695] = "shadow", -- Health Funnel rank 7
    [27259] = "shadow", -- Health Funnel rank 8
    [47856] = "shadow", -- Health Funnel rank 9

    -- =====================================================
    --  FIRE DAMAGE
    -- =====================================================

    -- Immolate — ranks 1–11
    [348]   = "lava", -- Immolate rank 1
    [707]   = "lava", -- Immolate rank 2
    [1094]  = "lava", -- Immolate rank 3
    [2941]  = "lava", -- Immolate rank 4
    [11665] = "lava", -- Immolate rank 5
    [11667] = "lava", -- Immolate rank 6
    [11668] = "lava", -- Immolate rank 7
    [25309] = "lava", -- Immolate rank 8
    [27215] = "lava", -- Immolate rank 9
    [47810] = "lava", -- Immolate rank 10
    [47811] = "lava", -- Immolate rank 11

    -- Searing Pain — ranks 1–10
    [5676]  = "lava", -- Searing Pain rank 1
    [17919] = "lava", -- Searing Pain rank 2
    [17920] = "lava", -- Searing Pain rank 3
    [17921] = "lava", -- Searing Pain rank 4
    [17922] = "lava", -- Searing Pain rank 5
    [17923] = "lava", -- Searing Pain rank 6
    [27210] = "lava", -- Searing Pain rank 7
    [30459] = "lava", -- Searing Pain rank 8
    [47814] = "lava", -- Searing Pain rank 9
    [47815] = "lava", -- Searing Pain rank 10

    -- Soul Fire — ranks 1–6
    [6353]  = "lava", -- Soul Fire rank 1
    [17924] = "lava", -- Soul Fire rank 2
    [27211] = "lava", -- Soul Fire rank 3
    [30545] = "lava", -- Soul Fire rank 4
    [47824] = "lava", -- Soul Fire rank 5
    [47825] = "lava", -- Soul Fire rank 6

    -- Incinerate — ranks 1–4
    [29722] = "lava", -- Incinerate rank 1
    [32231] = "lava", -- Incinerate rank 2
    [47837] = "lava", -- Incinerate rank 3
    [47838] = "lava", -- Incinerate rank 4

    -- Chaos Bolt — ranks 1–4
    [50796] = "lava", -- Chaos Bolt rank 1
    [59170] = "lava", -- Chaos Bolt rank 2
    [59171] = "lava", -- Chaos Bolt rank 3
    [59172] = "lava", -- Chaos Bolt rank 4

    -- =====================================================
    --  FIRE CHANNELS
    -- =====================================================

    -- Rain of Fire — ranks 1–7
    [5740]  = "lava", -- Rain of Fire rank 1
    [6219]  = "lava", -- Rain of Fire rank 2
    [11677] = "lava", -- Rain of Fire rank 3
    [11678] = "lava", -- Rain of Fire rank 4
    [27212] = "lava", -- Rain of Fire rank 5
    [47819] = "lava", -- Rain of Fire rank 6
    [47820] = "lava", -- Rain of Fire rank 7

    -- Hellfire — ranks 1–5
    [1949]  = "lava", -- Hellfire rank 1
    [11683] = "lava", -- Hellfire rank 2
    [11684] = "lava", -- Hellfire rank 3
    [27213] = "lava", -- Hellfire rank 4
    [47823] = "lava", -- Hellfire rank 5

    -- =====================================================
    --  CROWD CONTROL
    -- =====================================================

    -- Fear — ranks 1–3
    [5782] = "shadow", -- Fear rank 1
    [6213] = "shadow", -- Fear rank 2
    [6215] = "shadow", -- Fear rank 3

    -- Howl of Terror — ranks 1–2
    [5484]  = "shadow", -- Howl of Terror rank 1
    [17928] = "shadow", -- Howl of Terror rank 2

    -- Banish — ranks 1–2
    [710]   = "shadow", -- Banish rank 1
    [18647] = "shadow", -- Banish rank 2

    -- Enslave Demon — ranks 1–4
    [1098]  = "shadow", -- Enslave Demon rank 1
    [11725] = "shadow", -- Enslave Demon rank 2
    [11726] = "shadow", -- Enslave Demon rank 3
    [61191] = "shadow", -- Enslave Demon rank 4

    -- =====================================================
    --  DEMON SUMMONING
    -- =====================================================

    [688]   = "shadow", -- Summon Imp
    [697]   = "shadow", -- Summon Voidwalker
    [712]   = "shadow", -- Summon Succubus
    [691]   = "shadow", -- Summon Felhunter
    [30146] = "shadow", -- Summon Felguard

    [1122]  = "shadow", -- Inferno
    [18540] = "shadow", -- Ritual of Doom

    -- =====================================================
    --  RITUALS AND DEMONIC UTILITY
    -- =====================================================

    [126] = "shadow", -- Eye of Kilrogg
    [698] = "shadow", -- Ritual of Summoning

    -- Ritual of Souls — ranks 1–2
    [29893] = "shadow", -- Ritual of Souls rank 1
    [58887] = "shadow", -- Ritual of Souls rank 2

    [48018] = "shadow", -- Demonic Circle: Summon

    -- =====================================================
    --  CREATE HEALTHSTONE — ranks 1–8
    -- =====================================================

    [6201]  = "shadow", -- Create Healthstone rank 1
    [6202]  = "shadow", -- Create Healthstone rank 2
    [5699]  = "shadow", -- Create Healthstone rank 3
    [11729] = "shadow", -- Create Healthstone rank 4
    [11730] = "shadow", -- Create Healthstone rank 5
    [27230] = "shadow", -- Create Healthstone rank 6
    [47871] = "shadow", -- Create Healthstone rank 7
    [47878] = "shadow", -- Create Healthstone rank 8

    -- =====================================================
    --  CREATE SOULSTONE — ranks 1–7
    -- =====================================================

    [693]   = "shadow", -- Create Soulstone rank 1
    [20752] = "shadow", -- Create Soulstone rank 2
    [20755] = "shadow", -- Create Soulstone rank 3
    [20756] = "shadow", -- Create Soulstone rank 4
    [20757] = "shadow", -- Create Soulstone rank 5
    [27238] = "shadow", -- Create Soulstone rank 6
    [47884] = "shadow", -- Create Soulstone rank 7

    -- =====================================================
    --  CREATE FIRESTONE — ranks 1–7
    -- =====================================================

    [6366]  = "lava", -- Create Firestone rank 1
    [17951] = "lava", -- Create Firestone rank 2
    [17952] = "lava", -- Create Firestone rank 3
    [17953] = "lava", -- Create Firestone rank 4
    [27250] = "lava", -- Create Firestone rank 5
    [60219] = "lava", -- Create Firestone rank 6
    [60220] = "lava", -- Create Firestone rank 7

    -- =====================================================
    --  CREATE SPELLSTONE — ranks 1–6
    -- =====================================================

    [2362]  = "shadow", -- Create Spellstone rank 1
    [17727] = "shadow", -- Create Spellstone rank 2
    [17728] = "shadow", -- Create Spellstone rank 3
    [28172] = "shadow", -- Create Spellstone rank 4
    [47886] = "shadow", -- Create Spellstone rank 5
    [47888] = "shadow", -- Create Spellstone rank 6

    -- =====================================================
    --  WARLOCK CLASS MOUNTS
    -- =====================================================

    [5784]  = "shadow", -- Felsteed
    [23161] = "shadow", -- Dreadsteed

    -- =====================================================
    --  WARRIOR — Non-instant casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- -----------------------------------------------------
    -- Slam — ranks 1–8
    -- Base cast time: 1.5 sec
    -- Bloodsurge can temporarily make Slam instant
    -- -----------------------------------------------------
    [1464]  = "neutral", -- Slam rank 1
    [8820]  = "neutral", -- Slam rank 2
    [11604] = "neutral", -- Slam rank 3
    [11605] = "neutral", -- Slam rank 4
    [25241] = "neutral", -- Slam rank 5
    [25242] = "neutral", -- Slam rank 6
    [47474] = "neutral", -- Slam rank 7
    [47475] = "neutral", -- Slam rank 8

    -- -----------------------------------------------------
    -- Shattering Throw
    -- Cast time: 1.5 sec
    -- -----------------------------------------------------
    [64382] = "neutral", -- Shattering Throw

    -- =====================================================
    --  PROFESSIONS — Non-instant gathering casts only
    --  WotLK 3.3.5a
    -- =====================================================

    -- =====================================================
    --  FISHING
    --  Channeled
    -- =====================================================

    [7620]  = "fishing", -- Fishing — Apprentice
    [7731]  = "fishing", -- Fishing — Journeyman
    [7732]  = "fishing", -- Fishing — Expert
    [18248] = "fishing", -- Fishing — Artisan
    [33095] = "fishing", -- Fishing — Master
    [51294] = "fishing", -- Fishing — Grand Master

    -- Generic/alternate WotLK Fishing cast
    [63275] = "fishing", -- Fishing — channeled


    -- =====================================================
    --  MINING
    --  Gathering casts
    -- =====================================================

    [2575]  = "mining", -- Mining — Apprentice
    [2576]  = "mining", -- Mining — Journeyman
    [3564]  = "mining", -- Mining — Expert
    [10248] = "mining", -- Mining — Artisan
    [29354] = "mining", -- Mining — Master
    [50310] = "mining", -- Mining — Grand Master

    -- Hidden interaction used when mining certain creatures
    [32606] = "mining", -- Mining — hidden 1.6 sec cast


    -- =====================================================
    --  SKINNING
    --  1.5 sec gathering casts
    -- =====================================================

    [8613]  = "skinning", -- Skinning — Apprentice
    [8617]  = "skinning", -- Skinning — Journeyman
    [8618]  = "skinning", -- Skinning — Expert
    [10768] = "skinning", -- Skinning — Artisan
    [32678] = "skinning", -- Skinning — Master
    [50305] = "skinning", -- Skinning — Grand Master


    -- =====================================================
    --  HERBALISM
    --  Gathering casts
    -- =====================================================

    [2366]  = "herbalism", -- Herb Gathering — Apprentice
    [2368]  = "herbalism", -- Herb Gathering — Journeyman
    [3570]  = "herbalism", -- Herb Gathering — Expert
    [11993] = "herbalism", -- Herb Gathering — Artisan
    [28695] = "herbalism", -- Herb Gathering — Master
    [50300] = "herbalism", -- Herb Gathering — Grand Master

    -- Hidden gathering variants that can appear in cast events
    [2369]  = "herbalism", -- Herb Gathering — hidden variant
    [2371]  = "herbalism", -- Herb Gathering — hidden variant
    [32605] = "herbalism", -- Herb Gathering — hidden interaction

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
    local priority = {"neutral", "frost", "fire", "arcane", "shadow", "nature", "sacred", "physical"}
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
--  GREEN FIRE
--  Not available in WotLK 3.3.5a. Kept as no-op compatibility
--  hooks because DetectFromSpell references these members.
-- ============================================================
SCB.Schools.greenFireSpells = {}

function SCB.Schools:HasGreenFire()
    return false
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

-- ============================================================
--  DÉTECTION PAR NOM (3.3.5a)
--  En 3.3.5a, les events de cast et UnitCastingInfo ne donnent
--  pas de spellID exploitable. On détecte donc par NOM de sort.
--  La table nom → thème est construite depuis spellTable via
--  GetSpellInfo : chaque spellID WotLK valide fournit son nom
--  localisé ; les IDs retail-only renvoient nil et sont ignorés.
-- ============================================================
SCB.Schools.nameTable = nil

function SCB.Schools:BuildNameTable()
    local nameTable = {}
    if GetSpellInfo then
        for id, theme in pairs(self.spellTable) do
            local ok, spellName = pcall(GetSpellInfo, id)
            if ok and spellName and nameTable[spellName] == nil then
                nameTable[spellName] = theme
            end
        end
    end
    self.nameTable = nameTable
    return nameTable
end

function SCB.Schools:GetThemeForName(spellName)
    if not spellName then return nil end
    if not self.nameTable then self:BuildNameTable() end
    return self.nameTable[spellName]
end

-- Natural school before school-style assignments or per-spell overrides. This
-- is used by the override editor to explain the automatic result.
function SCB.Schools:GetNaturalSchoolForSpell(spellID, spellName)
    local numericID = tonumber(spellID)
    local detected = numericID and self.spellTable[numericID] or nil
    if not detected and spellName then detected = self:GetThemeForName(spellName) end
    if detected then detected = self:_remapDetectedSchoolForPlayer(detected) end
    if detected and self.data[detected] then return detected end
    return nil
end

local function GetSpellIdentity(spellID)
    local spellName, spellRank
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            spellName = info.name
            spellRank = info.subName or info.rank
        end
    end
    if GetSpellInfo and (not spellName or not spellRank or spellRank == "") then
        local legacyName, legacyRank = GetSpellInfo(spellID)
        spellName = spellName or legacyName
        if not spellRank or spellRank == "" then spellRank = legacyRank end
    end
    return spellName, spellRank
end

local function SpellIdentityMatchesCast(idName, idRank, castName, castRank)
    if not idName or not castName or idName ~= castName then return false end
    if castRank and castRank ~= "" then
        return idRank ~= nil and idRank ~= "" and idRank == castRank
    end
    return true
end

-- Resolve a configured spell-ID override on clients where cast events do not
-- expose a usable spellID (notably 3.3.5a). GetSpellInfo lets us compare each
-- saved ID with the localized live cast name; the rank disambiguates spells
-- that use a separate ID for every rank on the legacy client.
function SCB.Schools:GetSpellOverride(spellID, spellName, spellRank)
    self.lastOverrideMatchID = nil
    self.lastOverrideMatchTheme = nil
    if not (SCB.Config and SCB.Config:Get("useThemeAssignments")) then return nil end

    local overrides = SCB.Config:Get("spellThemeOverrides")
    if type(overrides) ~= "table" then overrides = OCBSpellOverridesDB end
    if type(overrides) ~= "table" then return nil end

    -- Modern/backported clients: prefer the exact ID from the cast event.
    local numericID = tonumber(spellID)
    if numericID then
        local forced = overrides[numericID] or overrides[tostring(numericID)]
        if forced and self.data[forced] then
            self.lastOverrideMatchID = numericID
            self.lastOverrideMatchTheme = forced
            return forced, numericID
        end

        -- A verified event ID with no exact override must continue through
        -- normal school detection. The legacy name/rank scan is only for
        -- clients whose event ID is absent or does not identify this cast.
        local idName, idRank = GetSpellIdentity(numericID)
        if SpellIdentityMatchesCast(idName, idRank, spellName, spellRank) then
            return nil
        end
    end

    if not spellName then return nil end

    local bestID, bestTheme
    for savedID, theme in pairs(overrides) do
        local id = tonumber(savedID)
        if id and self.data[theme] then
            local idName, idRank = GetSpellIdentity(id)
            if SpellIdentityMatchesCast(idName, idRank, spellName, spellRank)
               and (not bestID or id < bestID) then
                bestID, bestTheme = id, theme
            end
        end
    end
    if bestTheme then
        self.lastOverrideMatchID = bestID
        self.lastOverrideMatchTheme = bestTheme
    end
    return bestTheme, bestID
end

function SCB.Schools:DetectFromSpell(spellID, spellName, spellRank)
    self.lastOverrideMatchID = nil
    self.lastOverrideMatchTheme = nil
    -- Barre fixe pour tous les sorts
    if SCB.Config and not SCB.Config:Get("useSchoolDetection") then
        return self:_firstAvailable()
    end

    -- Surcharge par sort (ID direct, puis nom/rang sur le client 3.3.5a).
    local forced = self:GetSpellOverride(spellID, spellName, spellRank)
    if forced then return forced end

    -- Méthode 1 : table manuelle par spellID (Retail / clients backportés).
    -- En 3.3.5a la valeur "spellID" de l'event n'est pas fiable ; on ne
    -- l'utilise que si GetSpellInfo confirme qu'elle correspond au sort casté.
    if spellID then
        local manual = self.spellTable[spellID]
        if manual then
            local idMatchesCast = true
            if spellName and GetSpellInfo then
                local idName = GetSpellInfo(spellID)
                if idName and idName ~= spellName then
                    idMatchesCast = false
                end
            end
            if idMatchesCast then
                local mapped = self:_remapDetectedSchoolForPlayer(manual)
                if self.data[mapped] then return self:_applyThemeAssignment(mapped) end
            end
        end
    end

    -- Méthode 1b : table par NOM de sort (3.3.5a — spellID indisponible)
    if spellName then
        local byName = self:GetThemeForName(spellName)
        if byName then
            local mapped = self:_remapDetectedSchoolForPlayer(byName)
            if self.data[mapped] then return self:_applyThemeAssignment(mapped) end
        end
    end

    -- Méthodes 2/3 : APIs Blizzard Retail (nécessitent un spellID valide)
    if spellID and C_Spell then
        if C_Spell.GetSpellSchools then
            local schools = C_Spell.GetSpellSchools(spellID)
            if schools then
                for _, bits in ipairs({64, 32, 16, 8, 4, 2, 1}) do
                    for _, s in ipairs(schools) do
                        if s == bits then
                            local key = self.maskMap[bits]
                            if key and self.data[key] then
                                key = self:_remapDetectedSchoolForPlayer(key)
                                return self:_applyThemeAssignment(key)
                            end
                        end
                    end
                end
            end
        end

        if C_Spell.GetSpellInfo then
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
    end

    return self:_firstAvailable()
end
