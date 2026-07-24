-- ============================================================
--  Opulent Casting Bars — Core.lua
--  Namespace global, configuration, SavedVariables, init
-- ============================================================

local ADDON_NAME = "OpulentCastingBars"

-- Namespace global partagé par tous les modules
SCB = {
    ADDON_PATH = "Interface\\AddOns\\OpulentCastingBars\\",
    TEX_PATH   = "Interface\\AddOns\\OpulentCastingBars\\textures\\",
    VERSION    = "0.1.0",
}

-- ============================================================
--  CONFIG & SAVEDVARIABLES
-- ============================================================

SCB.Config = {}

SCB.Config.defaults = {
    x            = 0,
    y            = -250,
    anchor       = "CENTER",
    barWidth     = 400,
    barHeight    = 200,
    uvSpeed      = 0.15,
    locked            = true,
    showCastTime      = true,
    showSpellName     = true,
    hideBlizzardBar   = true,
    scale        = 0.8,
    defaultSchool = "metal",
    useSchoolDetection = true,   -- true = barre automatique par école, false = barre fixe
    useThemeAssignments = false,
    empowerKeepDefault = false,  -- true = laisser l'UI Blizzard gérer les sorts Empowered
    themeAssignments = {},
    spellThemeOverrides = {},
    -- Texte — Nom du sort
    textNameShow   = true,
    textNameSize   = 13,
    textNameAlign  = "LEFT",
    textNameColor  = "white",
    textNameTruncate = true,
    barStrata    = "MEDIUM",
    -- Texte — Timer
    textTimerShow  = true,
    textTimerSize  = 13,
    textTimerAlign = "RIGHT",
    textTimerColor = "white",
    -- Texte — Police et style
    fontFace       = "DEFAULT",  -- "DEFAULT" = Kenyan Coffee taille 13
    textOutline    = false,
    textCentered   = false,
    textCustomColor = {r=1.0, g=1.0, b=1.0},  -- couleur custom (blanc par défaut)
    -- Décalage XY global des textes (s'additionne aux offsets par école)
    textNamePosX  = 0,
    textNamePosY  = 0,
    textTimerPosX = 0,
    textTimerPosY = 0,
}

function SCB.Config:Init()
    OpulentCastingBarsDB = OpulentCastingBarsDB or {}
    for k, v in pairs(self.defaults) do
        if OpulentCastingBarsDB[k] == nil then
            -- Deep-copy tables so the live DB never shares references
            -- with SCB.Config.defaults (e.g. textCustomColor).
            if type(v) == "table" then
                local c = {}
                for tk, tv in pairs(v) do c[tk] = tv end
                OpulentCastingBarsDB[k] = c
            else
                OpulentCastingBarsDB[k] = v
            end
        end
    end
    self.db = OpulentCastingBarsDB
    -- Migration: remove the old hardcoded misc="neutral" default that was
    -- erroneously saved as a user assignment. Misc should default to "none"
    -- (no override) so the natural defaultSchool ("metal") is used.
    local ta = self.db.themeAssignments
    if ta and ta.misc == "neutral" then
        ta.misc = nil
    end
end

function SCB.Config:Get(key)
    return self.db[key]
end

function SCB.Config:Set(key, value)
    self.db[key] = value
    -- Keep the active profile snapshot in sync with any live option change
    -- so users don't lose edits when they forget to click "Save profile".
    if SCB and SCB.Profiles and SCB.Profiles.OnSettingChanged then
        SCB.Profiles:OnSettingChanged()
    end
end

function SCB.Config:Reset()
    for k, v in pairs(self.defaults) do
        if type(v) == "table" then
            local c = {}
            for tk, tv in pairs(v) do c[tk] = tv end
            self.db[k] = c
        else
            self.db[k] = v
        end
    end
end

-- ============================================================
--  ÉVÉNEMENTS DE CAST
--  Wrapper compatible Classic / Retail
-- ============================================================

SCB.Events = {}

function SCB.Events:Register(frame)
    frame:RegisterEvent("UNIT_SPELLCAST_START")
    frame:RegisterEvent("UNIT_SPELLCAST_STOP")
    frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    -- Sorts chargés (Empowered) — Evoker uniquement, retail
    if frame.RegisterEvent then
        pcall(function()
            frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
            frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
            frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_INTERRUPTED")
        end)
    end
    frame:SetScript("OnEvent", function(_, event, ...)
        SCB.Events:Dispatch(event, ...)
    end)
end

function SCB.Events:Dispatch(event, unit, castGUID, spellID)
    if unit ~= "player" then return end

    if SCB._debugMode then
        print(string.format("|cffFF9900[OCB Debug]|r event=|cffffff00%s|r spellID=|cffAAFFAA%s|r",
            tostring(event), tostring(spellID)))
    end

    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START"
    or event == "UNIT_SPELLCAST_EMPOWER_START" then
        local isChannel = (event == "UNIT_SPELLCAST_CHANNEL_START")
        -- Seul EMPOWER_START est fiable — empoweredFlag dans UnitCastingInfo est un castID, pas un bool
        local isEmpower = (event == "UNIT_SPELLCAST_EMPOWER_START")

        -- Option "Garder l'UI par défaut pour les sorts Empowered" :
        -- OCB se retire et laisse la barre Blizzard gérer l'affichage.
        if isEmpower and SCB.Config and SCB.Config:Get("empowerKeepDefault") then
            if SCB._blizzardDynamic then SCB.HideBlizzardBarFrames(false) end
            return
        end

        local name, texture, startMS, endMS = self:GetCastInfo(unit)
        if not name then return end

        if SCB._debugMode then
            print(string.format(
                "|cffFF9900[OCB Debug]|r  → name=|cffffff00%s|r isEmpower=|cffAAFFAA%s|r",
                tostring(name), tostring(isEmpower)))
        end

        local duration = math.max(((endMS or 0) - (startMS or 0)) / 1000, 0)
        local school   = SCB.Schools:DetectFromSpell(spellID, isEmpower)

        -- Sentinelle "blizzard" : l'assignment pour cette école est "Blizzard UI"
        if school == "blizzard" then
            if SCB._blizzardDynamic then SCB.HideBlizzardBarFrames(false) end
            self.activeCastGUID = castGUID   -- track le GUID pour les events stop
            return
        end

        self.activeCastGUID = castGUID
        SCB.Bar:StartCast(name, duration, school, isChannel, isEmpower, texture)

    elseif event == "UNIT_SPELLCAST_STOP"
        or event == "UNIT_SPELLCAST_SUCCEEDED"
        or event == "UNIT_SPELLCAST_CHANNEL_STOP"
        or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        if castGUID ~= self.activeCastGUID then return end
        self.activeCastGUID = nil
        SCB.Bar:StopCast(true)

    elseif event == "UNIT_SPELLCAST_FAILED"
        or event == "UNIT_SPELLCAST_INTERRUPTED"
        or event == "UNIT_SPELLCAST_EMPOWER_INTERRUPTED" then
        if castGUID ~= self.activeCastGUID then return end
        self.activeCastGUID = nil
        SCB.Bar:StopCast(false)

    elseif event == "UNIT_SPELLCAST_DELAYED"
        or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        if castGUID ~= self.activeCastGUID then return end
        local name, _, _, startMS, endMS
        if event == "UNIT_SPELLCAST_CHANNEL_UPDATE" and UnitChannelInfo then
            name, _, _, startMS, endMS = UnitChannelInfo(unit)
        elseif UnitCastingInfo then
            name, _, _, startMS, endMS = UnitCastingInfo(unit)
        end
        if name and endMS then
            SCB.Bar:ApplyPushback(startMS / 1000, endMS / 1000)
        end
    end
end

-- UnitCastingInfo existe en Classic et Retail, signatures légèrement
-- différentes mais les 4 premiers retours (name,_,_,startMS,endMS) sont stables
function SCB.Events:GetCastInfo(unit)
    if UnitCastingInfo then
        local name, text, texture, startTime, endTime = UnitCastingInfo(unit)
        if name then return name, texture, startTime, endTime end
    end
    if UnitChannelInfo then
        local name, text, texture, startTime, endTime = UnitChannelInfo(unit)
        if name then return name, texture, startTime, endTime end
    end
    return nil
end

-- ============================================================
--  MASQUAGE BARRE BLIZZARD
-- ============================================================

local BLIZZARD_BARS = {
    "CastingBarFrame",             -- Classic / Wrath / Cata
    "PlayerCastingBarFrame",       -- Retail (Dragonflight+)
    "PetCastingBarFrame",          -- Pet (toutes versions)
}

local _blizzHideFrame = nil

-- Événements de cast NON-empowered à désactiver sur la barre Blizzard
local NON_EMPOWER_CAST_EVENTS = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
}

-- _blizzardDynamic = true quand la barre Blizzard est préservée vivante
-- et qu'OCB la gère (cache/restaure) au fil des casts.
SCB._blizzardDynamic = false

-- Indique si au moins une école a l'assignment "blizzard" (→ barre Blizzard)
local function HasBlizzardAssignments()
    if not (SCB.Config and SCB.Config:Get("useThemeAssignments")) then return false end
    local assignments = SCB.Config:Get("themeAssignments") or {}
    for _, v in pairs(assignments) do
        if v == "blizzard" then return true end
    end
    return false
end

-- Cache ou restaure les frames Blizzard (alpha parent uniquement — scripts et enfants intacts)
-- L'alpha du parent à 0 suffit à cacher tous les enfants (héritage).
-- On ne touche PAS aux enfants pour ne pas perturber leur état géré par Blizzard.
function SCB.HideBlizzardBarFrames(hide)
    local a = hide and 0 or 1
    for _, name in ipairs(BLIZZARD_BARS) do
        local f = _G[name]
        if f then f:SetAlpha(a) end
    end
end

function SCB.ApplyHideBlizzardBar(hide)
    if hide then
        if HasBlizzardAssignments() then
            -- Mode dynamique : la barre Blizzard reste vivante (scripts/events intacts).
            -- OCB la masque pendant ses casts et la restaure après.
            SCB._blizzardDynamic = true
            SCB.HideBlizzardBarFrames(true)   -- cachée par défaut, pas de cast en cours
        else
            SCB._blizzardDynamic = false
            -- empowerKeepDefault : préservation partielle pour les sorts Empowered
            local keepEmpower = SCB.Config and SCB.Config:Get("empowerKeepDefault")
            for _, name in ipairs(BLIZZARD_BARS) do
                local f = _G[name]
                if f then
                    if keepEmpower and name == "PlayerCastingBarFrame" then
                        -- Désactiver uniquement les events non-empowered
                        for _, event in ipairs(NON_EMPOWER_CAST_EVENTS) do
                            f:UnregisterEvent(event)
                        end
                    else
                        f:SetAlpha(0)
                        f:UnregisterAllEvents()
                        f:SetScript("OnUpdate", nil)
                        f:SetScript("OnEvent",  nil)
                        f:SetScript("OnShow",   nil)
                        for _, child in ipairs({f:GetChildren()}) do
                            child:SetAlpha(0)
                            child:SetScript("OnUpdate", nil)
                            child:SetScript("OnEvent",  nil)
                        end
                        for _, region in ipairs({f:GetRegions()}) do
                            region:SetAlpha(0)
                        end
                    end
                end
            end
        end
    else
        SCB._blizzardDynamic = false
        -- Restaurer nécessite un ReloadUI (les events sont perdus),
        -- on se contente de remettre l'alpha visible
        for _, name in ipairs(BLIZZARD_BARS) do
            local f = _G[name]
            if f then
                f:SetAlpha(1)
                for _, child in ipairs({f:GetChildren()}) do child:SetAlpha(1) end
                for _, region in ipairs({f:GetRegions()}) do region:SetAlpha(1) end
            end
        end
    end
    -- Supprimer l'OnUpdate polling (plus nécessaire)
    if _blizzHideFrame then
        _blizzHideFrame:Hide()
        _blizzHideFrame:SetScript("OnUpdate", nil)
    end
end

-- ============================================================
--  INIT PRINCIPAL
-- ============================================================

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGIN")

initFrame:SetScript("OnEvent", function(_, event, arg1)

    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        SCB.Config:Init()

        -- Public Spell Overrides API (used by Profiles.lua and options UI)
        local function SyncSpellOverridesDB()
            local db = SCB.Config:Get("spellThemeOverrides")
            if type(db) ~= "table" then
                db = {}
                SCB.Config:Set("spellThemeOverrides", db)
            end
            OCBSpellOverridesDB = db
            return db
        end

        SyncSpellOverridesDB()
        OCBSpellOverrides = OCBSpellOverrides or {}
        OCBSpellOverrides.Sync = SyncSpellOverridesDB
        function OCBSpellOverrides.Set(spellID, school)
            spellID = tonumber(spellID)
            if not spellID or spellID <= 0 then return false end
            if not school or (SCB.Schools and not SCB.Schools:Exists(school)) then return false end
            local db = SyncSpellOverridesDB()
            db[spellID] = school
            -- Notify profile autosave hook that spell overrides changed.
            SCB.Config:Set("spellThemeOverrides", db)
            return true
        end
        function OCBSpellOverrides.Remove(spellID)
            spellID = tonumber(spellID)
            if not spellID then return end
            local db = SyncSpellOverridesDB()
            db[spellID] = nil
            -- Notify profile autosave hook that spell overrides changed.
            SCB.Config:Set("spellThemeOverrides", db)
        end

        -- Register OCB's bundled fonts with LibSharedMedia so other addons
        -- (and our own LSM-aware font picker) can discover them.
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        if LSM then
            local base = SCB.ADDON_PATH .. "Fonts\\"
            LSM:Register(LSM.MediaType.FONT, "Kenyan Coffee",      base .. "KenyanCoffee.otf")
            LSM:Register(LSM.MediaType.FONT, "Gaegu",              base .. "Gaegu-Bold.ttf")
            LSM:Register(LSM.MediaType.FONT, "Teko",               base .. "Teko-Bold.ttf")
            LSM:Register(LSM.MediaType.FONT, "Titan One",          base .. "TitanOne-Regular.ttf")
            LSM:Register(LSM.MediaType.FONT, "Yanone Kaffeesatz",  base .. "YanoneKaffeesatz-Bold.ttf")
            LSM:Register(LSM.MediaType.FONT, "Expressway",         base .. "expressway.otf")
            LSM:Register(LSM.MediaType.FONT, "Nexa",               base .. "Nexa-Heavy.ttf")
            LSM:Register(LSM.MediaType.FONT, "Casual Memories",    base .. "CasualMemoriesBold.ttf")
            LSM:Register(LSM.MediaType.FONT, "Alte Haas Grotesk",  base .. "AlteHaasGroteskBold.ttf")
            LSM:Register(LSM.MediaType.FONT, "Steelfish",          base .. "Steelfish.otf")
        end

    elseif event == "PLAYER_LOGIN" then
        SCB.Bar:Create()
        SCB.Options:Create()
        SCB.Profiles:Init()
        if OCBSpellOverrides and OCBSpellOverrides.Sync then
            OCBSpellOverrides.Sync()
        end
        SCB.Profiles:BuildPanel()
        SCB.Commands:Register()

        local bar = SCB.Bar.frame
        bar:SetScale(SCB.Config:Get("scale"))
        bar:ClearAllPoints()
        bar:SetPoint(
            SCB.Config:Get("anchor"), UIParent, SCB.Config:Get("anchor"),
            SCB.Config:Get("x"), SCB.Config:Get("y"))
        bar:EnableMouse(not SCB.Config:Get("locked"))

        -- Masquer la barre Blizzard si option active
        SCB.ApplyHideBlizzardBar(SCB.Config:Get("hideBlizzardBar"))

        SCB.Events:Register(initFrame)

        print("|cff00CCFFOpulent Casting Bars|r v" .. SCB.VERSION ..
              " loaded. |cffffff00/ocb help|r for commands.")
    end
end)
