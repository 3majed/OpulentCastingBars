-- ============================================================
--  Opulent Casting Bars — Core.lua
--  Namespace global, configuration, SavedVariables, init
-- ============================================================

local ADDON_NAME = "OpulentCastingBars"

-- Namespace global partagé par tous les modules
SCB = {
    ADDON_PATH = "Interface\\AddOns\\OpulentCastingBars\\",
    TEX_PATH   = "Interface\\AddOns\\OpulentCastingBars\\textures\\",
    VERSION    = "0.1.3",
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
    themeAssignments = {},
    spellThemeOverrides = {},
    -- Texte — Nom du sort
    textNameShow   = true,
    textNameSize   = 13,
    textNameAlign  = "LEFT",
    textNameColor  = "white",
    textNameTruncate = true,
    barStrata    = "MEDIUM",
    precacheOnLogin = false,
    fontPrewarmOnLogin = false,
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

-- Return the localized identity for a numeric spell ID on both the legacy
-- client and newer clients/backports.
local function GetSpellIdentityByID(spellID)
    spellID = tonumber(spellID)
    if not spellID then return nil end

    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then return info.name, info.subName or info.rank, info.iconID end
    end
    if GetSpellInfo then
        local name, rank, icon = GetSpellInfo(spellID)
        if name then return name, rank, icon end
    end
    return nil
end

local function SpellIdentityMatches(name, rank, expectedName, expectedRank)
    if not name or not expectedName or name ~= expectedName then return false end
    if expectedRank and expectedRank ~= "" then
        return rank ~= nil and rank ~= "" and rank == expectedRank
    end
    return true
end

-- 3.3.5a cast events normally expose name/rank instead of an ID. Resolve the
-- exact learned rank from the spellbook, whose item info/link includes the ID.
local function FindSpellBookID(spellName, spellRank)
    if not spellName or not GetNumSpellTabs or not GetSpellTabInfo then return nil end

    local bookType = BOOKTYPE_SPELL or "spell"
    local bestID
    for tab = 1, GetNumSpellTabs() do
        local _, _, offset, numSpells = GetSpellTabInfo(tab)
        offset, numSpells = tonumber(offset) or 0, tonumber(numSpells) or 0
        for slot = offset + 1, offset + numSpells do
            local name, rank
            if GetSpellBookItemName then
                name, rank = GetSpellBookItemName(slot, bookType)
            elseif GetSpellName then
                name, rank = GetSpellName(slot, bookType)
            end

            if SpellIdentityMatches(name, rank, spellName, spellRank) then
                local spellID
                if GetSpellBookItemInfo then
                    local _, itemID = GetSpellBookItemInfo(slot, bookType)
                    spellID = tonumber(itemID)
                end
                if not spellID and GetSpellLink then
                    local link = GetSpellLink(slot, bookType)
                    spellID = link and tonumber(link:match("spell:(%d+)"))
                end
                if spellID then
                    if spellRank and spellRank ~= "" then return spellID end
                    if not bestID or spellID > bestID then bestID = spellID end
                end
            end
        end
    end
    return bestID
end

-- Mounts and vanity pets use the companion collection instead of the player
-- spellbook on Wrath. Their companion records expose the summon spell ID.
local function FindCompanionSpellID(spellName, spellRank)
    if not spellName or not GetNumCompanions or not GetCompanionInfo then return nil end

    for _, companionType in ipairs({ "MOUNT", "CRITTER" }) do
        local count = tonumber(GetNumCompanions(companionType)) or 0
        for index = 1, count do
            local _, companionName, rawSpellID = GetCompanionInfo(companionType, index)
            local companionSpellID = tonumber(rawSpellID)
            if companionSpellID then
                local idName, idRank = GetSpellIdentityByID(companionSpellID)
                if SpellIdentityMatches(idName or companionName, idRank, spellName, spellRank) then
                    return companionSpellID
                end
            end
        end
    end
    return nil
end

SCB.Events.spellIdentityCache = {}
SCB.Events.knownRankCache = {}
SCB.Events.recentCasts = {}
SCB.Events.castSerial = 0

function SCB.Events:ResolveSpellID(eventSpellID, spellName, spellRank)
    -- Modern/backported clients may supply a real event ID. Never trust it
    -- until its localized identity agrees with the live cast.
    local numericID = tonumber(eventSpellID)
    if numericID then
        local idName, idRank = GetSpellIdentityByID(numericID)
        if SpellIdentityMatches(idName, idRank, spellName, spellRank) then
            return numericID
        end
    end

    if not spellName then return nil end
    local cacheKey = spellName .. "\031" .. tostring(spellRank or "")
    local cached = self.spellIdentityCache[cacheKey]
    if cached then return cached end

    local resolved = FindSpellBookID(spellName, spellRank)
        or FindCompanionSpellID(spellName, spellRank)

    -- Some private clients omit GetSpellBookItemInfo. OCB's WotLK spell table
    -- provides a safe exact-rank fallback for spells it already recognizes.
    if not resolved and SCB.Schools and SCB.Schools.spellTable then
        local onlyMatch
        for id in pairs(SCB.Schools.spellTable) do
            local idName, idRank = GetSpellIdentityByID(id)
            if SpellIdentityMatches(idName, idRank, spellName, spellRank) then
                if spellRank and spellRank ~= "" then
                    onlyMatch = tonumber(id)
                    break
                elseif onlyMatch and onlyMatch ~= tonumber(id) then
                    onlyMatch = nil
                    break
                else
                    onlyMatch = tonumber(id)
                end
            end
        end
        resolved = onlyMatch
    end

    if resolved then self.spellIdentityCache[cacheKey] = resolved end
    return resolved
end

function SCB.Events:RememberLastCast(eventSpellID, spellName, spellRank, icon)
    local resolvedID = self:ResolveSpellID(eventSpellID, spellName, spellRank)
    self.lastCastSpellID = resolvedID
    self.lastCastName = spellName
    self.lastCastRank = spellRank
    self.lastCastIcon = icon

    local now = GetTime and GetTime() or 0
    local newest = self.recentCasts[1]
    local isDuplicate = newest
        and newest.name == spellName
        and tostring(newest.rank or "") == tostring(spellRank or "")
        and (now - (newest.time or 0)) < 0.75
    local record
    if isDuplicate then
        record = newest
        record.id = resolvedID or record.id
        record.icon = icon or record.icon
        record.rawEventSpellID = eventSpellID
        record.time = now
    else
        self.castSerial = self.castSerial + 1
        record = {
            serial = self.castSerial,
            id = resolvedID,
            name = spellName,
            rank = spellRank,
            icon = icon,
            rawEventSpellID = eventSpellID,
            time = now,
        }
        table.insert(self.recentCasts, 1, record)
        while #self.recentCasts > 10 do table.remove(self.recentCasts) end
    end
    self.lastCastRecord = record

    -- Refresh the button/status immediately if the options window is open.
    if SCB.Options and SCB.Options.RefreshFromConfig then
        SCB.Options.RefreshFromConfig()
    end
    return record
end

function SCB.Events:RecordCastResolution(eventSpellID, spellName, spellRank, finalStyle)
    local record = self.lastCastRecord
    if not record then return end

    local schools = SCB.Schools
    local naturalSchool = schools and schools.GetNaturalSchoolForSpell
        and schools:GetNaturalSchoolForSpell(self.lastCastSpellID, spellName) or nil
    record.rawEventSpellID = eventSpellID
    record.id = self.lastCastSpellID or record.id
    record.name = spellName or record.name
    record.rank = spellRank or record.rank
    record.naturalSchool = naturalSchool
    record.overrideID = schools and schools.lastOverrideMatchID or nil
    record.overrideTheme = schools and schools.lastOverrideMatchTheme or nil
    record.finalStyle = finalStyle
    self.lastResolution = record

    if SCB.Options and SCB.Options.RefreshFromConfig then
        SCB.Options.RefreshFromConfig()
    end
end

local function AddKnownRank(target, spellID)
    spellID = tonumber(spellID)
    if not spellID or target[spellID] then return end
    local name, rank, icon = GetSpellIdentityByID(spellID)
    if name then
        target[spellID] = { id = spellID, name = name, rank = rank, icon = icon }
    end
end

-- Return every rank/variant with the same localized spell name that this
-- client can identify. Learned spellbook entries are preferred, while OCB's
-- WotLK table fills in ranks that are not currently learned.
function SCB.Events:GetKnownSpellRanks(spellID)
    spellID = tonumber(spellID)
    local spellName = spellID and GetSpellIdentityByID(spellID)
    if not spellName then return {} end
    if self.knownRankCache[spellName] then return self.knownRankCache[spellName] end

    local byID = {}
    AddKnownRank(byID, spellID)

    local bookType = BOOKTYPE_SPELL or "spell"
    if GetNumSpellTabs and GetSpellTabInfo then
        for tab = 1, GetNumSpellTabs() do
            local _, _, offset, numSpells = GetSpellTabInfo(tab)
            offset, numSpells = tonumber(offset) or 0, tonumber(numSpells) or 0
            for slot = offset + 1, offset + numSpells do
                local name
                if GetSpellBookItemName then
                    name = GetSpellBookItemName(slot, bookType)
                elseif GetSpellName then
                    name = GetSpellName(slot, bookType)
                end
                if name == spellName then
                    local slotID
                    if GetSpellBookItemInfo then
                        local _, itemID = GetSpellBookItemInfo(slot, bookType)
                        slotID = tonumber(itemID)
                    end
                    if not slotID and GetSpellLink then
                        local link = GetSpellLink(slot, bookType)
                        slotID = link and tonumber(link:match("spell:(%d+)"))
                    end
                    AddKnownRank(byID, slotID)
                end
            end
        end
    end

    if GetNumCompanions and GetCompanionInfo then
        for _, companionType in ipairs({ "MOUNT", "CRITTER" }) do
            for index = 1, tonumber(GetNumCompanions(companionType)) or 0 do
                local _, companionName, companionSpellID = GetCompanionInfo(companionType, index)
                if companionName == spellName then AddKnownRank(byID, companionSpellID) end
            end
        end
    end

    if SCB.Schools and SCB.Schools.spellTable then
        for id in pairs(SCB.Schools.spellTable) do
            local name = GetSpellIdentityByID(id)
            if name == spellName then AddKnownRank(byID, id) end
        end
    end

    local rows = {}
    for _, row in pairs(byID) do rows[#rows + 1] = row end
    table.sort(rows, function(a, b)
        local ar = tonumber(tostring(a.rank or ""):match("(%d+)")) or 0
        local br = tonumber(tostring(b.rank or ""):match("(%d+)")) or 0
        if ar == br then return a.id < b.id end
        return ar < br
    end)
    self.knownRankCache[spellName] = rows
    return rows
end

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
    frame:RegisterEvent("SPELLS_CHANGED")
    frame:SetScript("OnEvent", function(_, event, ...)
        SCB.Events:Dispatch(event, ...)
    end)
end

function SCB.Events:Dispatch(event, unit, castGUID, spellID)
    if event == "SPELLS_CHANGED" then
        self.spellIdentityCache = {}
        self.knownRankCache = {}
        return
    end
    if unit ~= "player" then return end

    if SCB._debugMode then
        print(string.format("|cffFF9900[OCB Debug]|r event=|cffffff00%s|r spellID=|cffAAFFAA%s|r",
            tostring(event), tostring(spellID)))
    end

    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        local isChannel = (event == "UNIT_SPELLCAST_CHANNEL_START")

        local name, texture, startMS, endMS, spellRank = self:GetCastInfo(unit)
        if not name then return end

        self:RememberLastCast(spellID, name, spellRank, texture)

        if SCB._debugMode then
            print(string.format(
                "|cffFF9900[OCB Debug]|r  → name=|cffffff00%s|r",
                tostring(name)))
        end

        local duration = math.max(((endMS or 0) - (startMS or 0)) / 1000, 0)
        local school   = SCB.Schools:DetectFromSpell(spellID, name, spellRank)
        self:RecordCastResolution(spellID, name, spellRank, school)

        -- Sentinelle "blizzard" : l'assignment pour cette école est "Blizzard UI"
        if school == "blizzard" then
            if SCB._blizzardDynamic then SCB.HideBlizzardBarFrames(false) end
            self.activeCastGUID = castGUID   -- track le GUID pour les events stop
            return
        end

        self.activeCastGUID = castGUID
        SCB.Bar:StartCast(name, duration, school, isChannel, texture)

    elseif event == "UNIT_SPELLCAST_STOP"
        or event == "UNIT_SPELLCAST_SUCCEEDED"
        or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if castGUID ~= self.activeCastGUID then return end
        self.activeCastGUID = nil
        SCB.Bar:StopCast(true)

    elseif event == "UNIT_SPELLCAST_FAILED"
        or event == "UNIT_SPELLCAST_INTERRUPTED" then
        if castGUID ~= self.activeCastGUID then return end
        self.activeCastGUID = nil
        SCB.Bar:StopCast(false)

    elseif event == "UNIT_SPELLCAST_DELAYED"
        or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        if castGUID ~= self.activeCastGUID then return end
        local name, _, startMS, endMS = self:GetCastInfo(unit)
        if name and startMS and endMS then
            SCB.Bar:ApplyPushback(startMS / 1000, endMS / 1000)
        end
    end
end

-- UnitCastingInfo/UnitChannelInfo diffèrent entre Classic (3.3.5a) et Retail :
-- Classic renvoie un champ "nameSubtext" en position 2, ce qui décale texture,
-- startTime et endTime d'un cran. On détecte la version via le type du 4e retour
-- (nombre = startTime → Retail ; sinon = texture → Classic 3.3.5a).
local function ParseCastInfo(name, a2, a3, a4, a5, a6)
    if not name then return nil end
    if type(a4) == "number" then
        -- Retail : name, text, texture, startTime, endTime
        return name, a3, a4, a5, nil
    end
    -- Classic 3.3.5a : name, nameSubtext, text, texture, startTime, endTime
    return name, a4, a5, a6, a2
end

function SCB.Events:GetCastInfo(unit)
    if UnitCastingInfo then
        local name, a2, a3, a4, a5, a6 = UnitCastingInfo(unit)
        if name then return ParseCastInfo(name, a2, a3, a4, a5, a6) end
    end
    if UnitChannelInfo then
        local name, a2, a3, a4, a5, a6 = UnitChannelInfo(unit)
        if name then return ParseCastInfo(name, a2, a3, a4, a5, a6) end
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
            for _, name in ipairs(BLIZZARD_BARS) do
                local f = _G[name]
                if f then
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
            -- Imported/older profiles may contain string keys. Keep one
            -- canonical numeric entry so the editor never shows duplicates.
            db[tostring(spellID)] = nil
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
            db[tostring(spellID)] = nil
            -- Notify profile autosave hook that spell overrides changed.
            SCB.Config:Set("spellThemeOverrides", db)
        end
        function OCBSpellOverrides.Clear()
            SCB.Config:Set("spellThemeOverrides", {})
            SyncSpellOverridesDB()
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
            -- Blizzard's built-in Chinese game font (locale-appropriate) so the
            -- old "GAME_CHINESE" option stays available in the LSM font picker.
            LSM:Register(LSM.MediaType.FONT, "Game Chinese",
                (GetLocale and GetLocale() == "zhTW") and "Fonts\\ARKai_T.ttf" or "Fonts\\ARKai_C.ttf")
        end

    elseif event == "PLAYER_LOGIN" then
        SCB.Bar:Create()
        SCB.Options:Create()
        SCB.Profiles:Init()
        if OCBSpellOverrides and OCBSpellOverrides.Sync then
            OCBSpellOverrides.Sync()
        end
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

        -- Warm HD textures into VRAM a moment after login so the first
        -- heavy cast (Fire, …) doesn't stutter while the client streams
        -- the uncompressed .tga files on demand.
        if SCB.Precache and SCB.Config:Get("precacheOnLogin") then
            C_Timer.After(10, function() SCB.Precache:Start() end)
        end

        C_Timer.After(2, function()
            if SCB.Particles and SCB.Particles.PrewarmFX then
                SCB.Particles:PrewarmFX("inferno")
            end
            if SCB.Precache and SCB.Precache.StartSchool and not SCB.Config:Get("precacheOnLogin") then
                SCB.Precache:StartSchool("inferno", 1)
            end
        end)

        -- Pre-warm the font cache so the LSM30_Font picker (Text tab) doesn't
        -- hitch the first time it's opened. FontString:SetFont() loads the font
        -- file synchronously, and the dropdown does that for EVERY registered
        -- font at once (plus lazily as you scroll), which stutters when many
        -- LSM fonts are present. We load each one into a hidden off-screen
        -- string, a few per frame, so they're already cached before use.
        if SCB.Config:Get("fontPrewarmOnLogin") then
            C_Timer.After(10, function()
                local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
                if not (LSM and LSM.List) then return end
                local names = LSM:List("font") or {}
                if #names == 0 then return end
                local driver = CreateFrame("Frame", nil, UIParent)
                local fs = driver:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
                fs:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -1000, 1000)  -- off-screen
                fs:SetText("AaBbCcGg 0123")   -- give it glyphs so the atlas warms too
                local i = 0
                driver:SetScript("OnUpdate", function(self)
                    local done = 0
                    while i < #names and done < 3 do   -- 3 fonts per frame
                        i = i + 1
                        done = done + 1
                        local path = LSM:Fetch("font", names[i], true)
                        if path then pcall(fs.SetFont, fs, path, 12) end
                    end
                    if i >= #names then
                        self:SetScript("OnUpdate", nil)
                        self:Hide()
                    end
                end)
            end)
        end

        print("|cff00CCFFOpulent Casting Bars|r v" .. SCB.VERSION ..
              " loaded. |cffffff00/ocb help|r for commands.")
    end
end)
