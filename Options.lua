-- ============================================================
--  Opulent Casting Bars — Options.lua
--  Ace3 configuration UI (AceConfig-3.0 + AceConfigDialog-3.0)
--
--  The panel is a standalone AceConfigDialog window (opened with
--  /ocb).  It reads/writes through the existing SCB.Config backend
--  so the rest of the addon (Bar, Schools, Profiles) is untouched.
-- ============================================================

SCB.Options = SCB.Options or {}

local APP = "OpulentCastingBars"
local OPTIONS_MIN_WIDTH = 800
local OPTIONS_DEFAULT_HEIGHT = 580

-- Ace3 handles (resolved in :Create, once the libs are loaded)
local AceConfig, AceConfigDialog, AceConfigRegistry

local function Notify()
    if AceConfigRegistry then AceConfigRegistry:NotifyChange(APP) end
end

-- This client skin strips the normal StaticPopup background. Spell override
-- removal uses an addon-owned confirmation frame with a solid texture instead,
-- so the prompt remains readable regardless of which AceConfig copy is active.
local optionsConfirmFrame
local optionsConfirmAction
local optionsConfirmOwner

local function CreateOptionsConfirmFrame()
    local frame = CreateFrame("Frame", "OCBOptionsConfirmDialog", UIParent)
    frame:SetSize(460, 150)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(100)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:EnableKeyboard(true)
    frame:Hide()

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(frame)
    background:SetTexture(0.025, 0.025, 0.025, 0.98)

    local function AddBorder(point1, point2, width, height)
        local border = frame:CreateTexture(nil, "BORDER")
        border:SetTexture(0.65, 0.65, 0.65, 1)
        border:SetPoint(unpack(point1))
        border:SetPoint(unpack(point2))
        if width then border:SetWidth(width) end
        if height then border:SetHeight(height) end
    end
    AddBorder({ "TOPLEFT", 1, -1 }, { "TOPRIGHT", -1, -1 }, nil, 2)
    AddBorder({ "BOTTOMLEFT", 1, 1 }, { "BOTTOMRIGHT", -1, 1 }, nil, 2)
    AddBorder({ "TOPLEFT", 1, -1 }, { "BOTTOMLEFT", 1, 1 }, 2, nil)
    AddBorder({ "TOPRIGHT", -1, -1 }, { "BOTTOMRIGHT", -1, 1 }, 2, nil)

    local message = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    message:SetPoint("TOPLEFT", 24, -24)
    message:SetPoint("TOPRIGHT", -24, -24)
    message:SetHeight(54)
    message:SetJustifyH("CENTER")
    message:SetJustifyV("MIDDLE")
    frame.message = message

    local accept = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    accept:SetSize(170, 28)
    accept:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -8, 22)
    accept:SetText(ACCEPT or "Accept")
    accept:SetScript("OnClick", function()
        local action = optionsConfirmAction
        optionsConfirmAction = nil
        frame:Hide()
        if action then action() end
    end)

    local cancel = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    cancel:SetSize(170, 28)
    cancel:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 8, 22)
    cancel:SetText(CANCEL or "Cancel")
    cancel:SetScript("OnClick", function()
        optionsConfirmAction = nil
        frame:Hide()
    end)

    frame:SetScript("OnHide", function()
        optionsConfirmAction = nil
        optionsConfirmOwner = nil
    end)
    frame:SetScript("OnUpdate", function(self)
        -- The confirmation is parented to UIParent so it can sit above the
        -- AceConfig window. Dismiss it explicitly when that owning window is
        -- closed; otherwise it would outlive the options UI.
        if optionsConfirmOwner and not optionsConfirmOwner:IsShown() then
            self:Hide()
        end
    end)
    frame:SetScript("OnKeyDown", function(self, key)
        -- Treat Escape exactly like Cancel. Handling it on the keyboard-enabled
        -- prompt consumes the key before FrameXML can close the options window.
        if key == "ESCAPE" then self:Hide() end
    end)
    return frame
end

local function ShowOptionsConfirmation(message, onAccept)
    if not optionsConfirmFrame then
        optionsConfirmFrame = CreateOptionsConfirmFrame()
    end
    optionsConfirmAction = onAccept
    local dialog = AceConfigDialog and AceConfigDialog.OpenFrames[APP]
    optionsConfirmOwner = dialog and dialog.frame or nil
    optionsConfirmFrame.message:SetText(message)
    optionsConfirmFrame:Show()
end

-- ============================================================
--  STYLE / SCHOOL LISTS
-- ============================================================
local STYLE_ORDER = {
    "neutral", "neutral2", "neutral3", "metal", "metal_icon", "engrenages",
    "honey_icon", "mossystone_icon", "mossystone", "viking", "alliance", "horde",
    "aim", "arcane", "arcaneum", "arctic", "earth", "felfire", "fire", "fishing",
    "frost", "frostfire", "herbalism", "holy", "inferno", "lava", "mining", "moon",
    "nature", "paladin", "sacred", "shadow", "skinning", "thunder", "water",
    -- Restored custom styles
    "chaos", "fists", "mistweaver", "chiji", "bronze", "void",
}
local STYLE_LABELS = {
    neutral = "Neutral", neutral2 = "Neutral 2", neutral3 = "Neutral 3",
    metal = "Neutral - Metal", metal_icon = "Metal Icon", engrenages = "Engrenages",
    honey_icon = "Honey - Icons", mossystone_icon = "Mossy Stone - Icons",
    mossystone = "Mossy Stone", viking = "Viking Icon", alliance = "Alliance",
    horde = "Horde", aim = "Aim", arcane = "Arcane", arcaneum = "Arcaneum",
    arctic = "Arctic", earth = "Earth", felfire = "Felfire", fire = "Fire",
    fishing = "Fishing", frost = "Frost", frostfire = "Frostfire",
    herbalism = "Herbalism", holy = "Holy", inferno = "Inferno", lava = "Lava",
    mining = "Mining", moon = "Moon", nature = "Nature", paladin = "Paladin",
    sacred = "Sacred", shadow = "Shadow", skinning = "Skinning", thunder = "Thunder",
    water = "Water",
    chaos = "Chaos", fists = "Fists of Fury", mistweaver = "Mistweaver",
    chiji = "Chi'ji", bronze = "Bronze", void = "Void",
}

local function StyleValues()
    local v = {}
    for _, k in ipairs(STYLE_ORDER) do v[k] = STYLE_LABELS[k] end
    return v
end
local function StyleSorting() return STYLE_ORDER end

-- Assignment list = None + Blizzard UI + every style
local ASSIGN_ORDER = { "none", "blizzard" }
for _, k in ipairs(STYLE_ORDER) do ASSIGN_ORDER[#ASSIGN_ORDER + 1] = k end
local function AssignStyleValues()
    local v = { none = "— None (no override) —", blizzard = "— Blizzard UI —" }
    for _, k in ipairs(STYLE_ORDER) do v[k] = STYLE_LABELS[k] end
    return v
end
local function AssignStyleSorting() return ASSIGN_ORDER end

-- Detected school -> chosen style (Theme Assignments tab)
local ASSIGN_ROWS = {
    { key = "inferno",   label = "Fire",         icon = "Spell_Fire_FireBolt02" },
    { key = "arctic",    label = "Frost",        icon = "Spell_Frost_FrostBolt02" },
    { key = "arcaneum",  label = "Arcane",       icon = "Spell_Arcane_Blink" },
    { key = "nature",    label = "Nature",       icon = "Spell_Nature_Lightning" },
    { key = "shadow",    label = "Shadow",       icon = "Spell_Shadow_ShadowBolt" },
    { key = "paladin",   label = "Paladin",      icon = "spell_holy_avenginewrath" },
    { key = "sacred",    label = "Sacred",       icon = "Spell_Holy_HolyBolt" },
    { key = "earth",     label = "Earth",        icon = "Spell_Nature_StrengthOfEarthTotem02" },
    { key = "thunder",   label = "Thunder",      icon = "Spell_Nature_ChainLightning" },
    { key = "moon",      label = "Arcane Druid", icon = "Spell_Nature_StarFall" },
    { key = "felfire",   label = "Felfire",      icon = "Spell_Fire_FelFire" },
    { key = "frostfire", label = "Frostfire",    iconFull = SCB.TEX_PATH .. "frostfire\\Logo_Frostfire" },
    { key = "misc",      label = "Misc",         icon = "INV_Misc_QuestionMark" },
    { key = "fishing",   label = "Fishing",      icon = "Trade_Fishing" },
    { key = "mining",    label = "Mining",       icon = "Trade_Mining" },
    { key = "herbalism", label = "Herbalism",    icon = "Trade_Herbalism" },
    { key = "skinning",  label = "Skinning",     icon = "INV_Misc_Pelt_Wolf_01" },
    { key = "water",     label = "Water",        icon = "Spell_Frost_SummonWaterElemental" },
}

-- ============================================================
--  FONT LIST (LibSharedMedia — previewed in the LSM30_Font picker)
--  Values are name -> path so the LSM30_Font dropdown renders each
--  entry in its own font (like UFI).  All of OCB's bundled fonts are
--  registered with LSM in Core.lua, so they show here with friendly
--  names alongside any external LSM fonts.
-- ============================================================
local function FontValues()
    local v = {}
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM and LSM.HashTable then
        for name, path in pairs(LSM:HashTable("font") or {}) do
            v[name] = path   -- name -> path : each entry previews in its own font
        end
    end
    -- Always offer the Blizzard UI font, even if LSM didn't seed it.
    if not v["Friz Quadrata TT"] then v["Friz Quadrata TT"] = "Fonts\\FRIZQT__.TTF" end
    return v
end

-- Map legacy semantic fontFace keys to their LibSharedMedia equivalents so an
-- existing save still shows the right entry selected in the picker.
local FONT_LEGACY_ALIAS = {
    DEFAULT      = "Kenyan Coffee",
    BLIZZARD     = "Friz Quadrata TT",
    GAME_CHINESE = "Game Chinese",
}

-- ============================================================
--  STATIC OPTION VALUE TABLES
-- ============================================================
local STRATA = {
    BACKGROUND = "Background", LOW = "Low", MEDIUM = "Medium", HIGH = "High",
    DIALOG = "Dialog", FULLSCREEN = "Fullscreen",
    FULLSCREEN_DIALOG = "Fullscreen Dialog", TOOLTIP = "Tooltip",
}
local STRATA_ORDER = {
    "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP",
}
local ALIGN = { LEFT = "Left", CENTER = "Center", RIGHT = "Right" }
local ALIGN_ORDER = { "LEFT", "CENTER", "RIGHT" }

-- ============================================================
--  APPLY HELPERS (push a live setting into the running bar)
-- ============================================================
local function RepositionBar()
    local a = SCB.Config:Get("anchor") or "CENTER"
    SCB.Bar.frame:ClearAllPoints()
    SCB.Bar.frame:SetPoint(a, UIParent, a, SCB.Config:Get("x") or 0, SCB.Config:Get("y") or -250)
end

local function ApplyStrata()
    local s = SCB.Config:Get("barStrata") or "MEDIUM"
    SCB.Bar.frame:SetFrameStrata(s)
    if SCB.Bar.frameInner then SCB.Bar.frameInner:SetFrameStrata(s) end
end

local function TestCast()
    local school = SCB.Config:Get("defaultSchool") or "neutral"
    if SCB.Bar.isActive or SCB.Bar.isFading then SCB.Bar:StopCast(false) end
    SCB.Bar:Resize(SCB.Config:Get("barWidth"), SCB.Config:Get("barHeight"))
    SCB.Bar.frame:SetScale(SCB.Config:Get("scale") or 0.8)
    SCB.Bar:ApplyTextPrefs()
    SCB.Bar.frame:SetFrameStrata("TOOLTIP")
    SCB.Bar:StartCast("Test Cast", 5, school)
    SCB.Bar.frame:SetScript("OnHide", function(self)
        self:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM")
        self:SetScript("OnHide", nil)
    end)
end

local function PreviewSchool(key, dur)
    if not key or key == "none" or key == "blizzard" then
        key = SCB.Config:Get("defaultSchool") or "neutral"
    end
    if SCB.Bar.isActive or SCB.Bar.isFading then SCB.Bar:StopCast(false) end
    SCB.Bar.frame:SetFrameStrata("TOOLTIP")
    SCB.Bar:StartCast("Preview", dur or 3, key)
    SCB.Bar.frame:SetScript("OnHide", function(self)
        self:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM")
        self:SetScript("OnHide", nil)
    end)
end

local function ResetDefaults()
    SCB.Config:Reset()
    SCB.Bar.frame:SetScale(SCB.Config:Get("scale"))
    SCB.Bar:Resize(SCB.Config:Get("barWidth"), SCB.Config:Get("barHeight"))
    RepositionBar()
    SCB.Bar.frame:EnableMouse(not SCB.Config:Get("locked"))
    ApplyStrata()
    SCB.ApplyHideBlizzardBar(SCB.Config:Get("hideBlizzardBar"))
    SCB.Bar:ApplyTextPrefs()
    Notify()
    print("|cff00CCFFOpulent Casting Bars|r — Settings reset to defaults.")
end

-- Shared get/set for options whose arg key == config key and that only
-- need SCB.Bar:ApplyTextPrefs() applied.
local function GetCfg(info) return SCB.Config:Get(info[#info]) end
local function SetText(info, val)
    SCB.Config:Set(info[#info], val)
    SCB.Bar:ApplyTextPrefs()
end

-- Guarded spell lookup (3.3.5a has no C_Spell). Rank matters on the legacy
-- client because each rank has its own spell ID while cast events expose only
-- the localized name/rank pair.
local function SpellInfo(sid)
    if not sid then return nil end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(sid)
        if info then return info.name, info.subName or info.rank, info.iconID end
    end
    if GetSpellInfo then
        local name, rank, icon = GetSpellInfo(sid)
        if name then return name, rank, icon end
    end
    if C_Spell and C_Spell.GetSpellName then
        local n = C_Spell.GetSpellName(sid)
        if n then return n end
    end
    return nil
end

local function SpellDisplayName(sid)
    local name, rank = SpellInfo(sid)
    if not name then return nil end
    if rank and rank ~= "" then return name .. " (" .. rank .. ")" end
    return name
end

local function SpellIconMarkup(sid, size)
    local _, _, icon = SpellInfo(sid)
    if not icon then return "" end
    size = size or 18
    return "|T" .. tostring(icon) .. ":" .. size .. ":" .. size .. ":0:0|t "
end

-- Transient editor state (spell overrides)
local _newSpellID    = ""
local _newSpellTheme = "neutral"
local _selOverride   = nil
local _spellInputError = nil
local _applyAllRanks = false
local _overrideSearch = ""
local _overrideSort = "name"
local _overrideStyleFilter = "all"
local _overrideSchoolFilter = "all"
local _savedRankSelection = {}
local _overrideUndo = nil
local _showOverrideTransfer = false
local _overrideTransferText = ""
local DEFAULT_PROFILE = "Default"

local function SpellOverrides()
    local src = SCB.Config:Get("spellThemeOverrides")
    return type(src) == "table" and src or {}
end

local function GetSpellOverrideTheme(spellID)
    local id = tonumber(spellID)
    if not id then return nil end
    local src = SpellOverrides()
    return src[id] or src[tostring(id)]
end

local function ExtractSpellID(value)
    local text = tostring(value or "")
    local linkedID = text:match("|Hspell:(%d+)") or text:match("spell:(%d+)")
    if linkedID then return tonumber(linkedID) end
    if text:match("^%s*%d+%s*$") then return tonumber(text:match("%d+")) end
    return nil
end

local function CountTableEntries(src, meaningfulOnly)
    if type(src) ~= "table" then return 0 end
    local count = 0
    for _, value in pairs(src) do
        if not meaningfulOnly or (value and value ~= "none") then count = count + 1 end
    end
    return count
end

local function StyleDisplayName(key)
    if key == "blizzard" then return "Blizzard UI" end
    if key == "misc" then return "Misc / default" end
    return STYLE_LABELS[key] or tostring(key or "Unknown")
end

local function SnapshotSpellOverrides()
    local snapshot = {}
    for key, value in pairs(SpellOverrides()) do snapshot[key] = value end
    return snapshot
end

local function CaptureOverrideUndo(label)
    _overrideUndo = { label = label, snapshot = SnapshotSpellOverrides() }
end

local function RestoreOverrideUndo()
    if not _overrideUndo then return end
    local snapshot = {}
    for key, value in pairs(_overrideUndo.snapshot or {}) do snapshot[key] = value end
    SCB.Config:Set("spellThemeOverrides", snapshot)
    if OCBSpellOverrides and OCBSpellOverrides.Sync then OCBSpellOverrides.Sync() end
    _overrideUndo = nil
    _savedRankSelection = {}
    if _selOverride then
        local restoredTheme = GetSpellOverrideTheme(_selOverride)
        if restoredTheme then
            _newSpellTheme = restoredTheme
        else
            _newSpellID = ""
            _newSpellTheme = "neutral"
            _selOverride = nil
            _spellInputError = nil
        end
    end
end

-- Report what automatic detection would choose before the per-spell override
-- is applied. This makes it clear whether an override is actually necessary.
local function GetAutomaticSpellStyle(spellID)
    local sid = tonumber(spellID)
    local name = sid and SpellInfo(sid)
    if not name or not SCB.Schools then return nil, nil end

    local detected = SCB.Schools.GetNaturalSchoolForSpell
        and SCB.Schools:GetNaturalSchoolForSpell(sid, name) or nil

    local automatic
    if detected and SCB.Schools._applyThemeAssignment then
        automatic = SCB.Schools:_applyThemeAssignment(detected)
    elseif SCB.Schools._firstAvailable then
        automatic = SCB.Schools:_firstAvailable()
    end
    return detected or "misc", automatic
end

local function ClearOverrideEditor()
    _newSpellID = ""
    _newSpellTheme = "neutral"
    _selOverride = nil
    _spellInputError = nil
end

local function LoadOverrideIntoEditor(spellID, theme)
    local sid = tonumber(spellID)
    if not sid then return end
    theme = theme or GetSpellOverrideTheme(sid)
    _newSpellID = tostring(sid)
    _newSpellTheme = theme or "neutral"
    _selOverride = theme and tostring(sid) or nil
    _spellInputError = nil
end

local function GetKnownSpellRanks(spellID)
    if SCB.Events and SCB.Events.GetKnownSpellRanks then
        local ranks = SCB.Events:GetKnownSpellRanks(spellID)
        if #ranks > 0 then return ranks end
    end
    local sid = tonumber(spellID)
    local name, rank, icon = SpellInfo(sid)
    return sid and name and { { id = sid, name = name, rank = rank, icon = icon } } or {}
end

local function UseLastCastInEditor()
    local sid = SCB.Events and tonumber(SCB.Events.lastCastSpellID)
    if not sid then return end

    local existing = GetSpellOverrideTheme(sid)
    local _, automatic = GetAutomaticSpellStyle(sid)
    LoadOverrideIntoEditor(sid, existing)
    if not existing and automatic and automatic ~= "blizzard" and SCB.Schools:Exists(automatic) then
        _newSpellTheme = automatic
    end
end

local function EditorSpellStatus()
    if _spellInputError then return "|cffff5555" .. _spellInputError .. "|r" end
    local sid = tonumber(_newSpellID)
    if not sid or sid <= 0 then
        return "|cff888888Enter a numeric spell ID, or cast a spell and click Use last cast.|r"
    end

    local display = SpellDisplayName(sid)
    if not display then
        return "|cffff5555Unknown spell ID. The spell is not available in this client cache.|r"
    end

    local existing = GetSpellOverrideTheme(sid)
    local detected, automatic = GetAutomaticSpellStyle(sid)
    local state
    if existing then
        state = "|cffffcc00Override exists: " .. StyleDisplayName(existing) .. ". Saving will update it.|r"
    else
        state = "|cff55ff55Valid spell ID. Ready to add.|r"
    end
    return SpellIconMarkup(sid, 22) .. "|cffffffff" .. display .. "|r\n"
        .. state .. "\n|cffaaaaaaDetected school:|r " .. StyleDisplayName(detected)
        .. "  |cffaaaaaaAutomatic style:|r " .. StyleDisplayName(automatic)
end

local function RelatedRanksStatus()
    local sid = tonumber(_newSpellID)
    if not sid or not SpellDisplayName(sid) then return "" end
    local ranks = GetKnownSpellRanks(sid)
    if #ranks <= 1 then return "|cff888888No other known ranks found for this spell.|r" end

    local parts = {}
    for index, row in ipairs(ranks) do
        if index > 10 then
            parts[#parts + 1] = string.format("+%d more", #ranks - 10)
            break
        end
        local rank = row.rank and row.rank ~= "" and row.rank or "No rank"
        local theme = GetSpellOverrideTheme(row.id)
        parts[#parts + 1] = string.format("%s (%d)%s", rank, row.id,
            theme and (" |cffffcc00" .. StyleDisplayName(theme) .. "|r") or "")
    end
    return "|cffaaaaaaKnown ranks:|r " .. table.concat(parts, "  |cff666666/|r  ")
end

local function GetOverrideRows(includeAll)
    local byID = {}
    for rawID, theme in pairs(SpellOverrides()) do
        local sid = tonumber(rawID)
        if sid and sid > 0 then
            local spellName, spellRank = SpellInfo(sid)
            local detected = GetAutomaticSpellStyle(sid)
            byID[sid] = {
                id = sid,
                theme = theme,
                name = SpellDisplayName(sid) or ("Unknown spell " .. sid),
                baseName = spellName or ("Unknown spell " .. sid),
                rank = spellRank,
                icon = SpellIconMarkup(sid, 20),
                school = detected or "misc",
            }
        end
    end

    local allRows = {}
    for _, row in pairs(byID) do allRows[#allRows + 1] = row end
    local total = #allRows
    local query = tostring(_overrideSearch or ""):lower()
    local rows = {}
    for _, row in ipairs(allRows) do
        local haystack = (row.name .. " " .. row.id .. " " .. StyleDisplayName(row.theme)):lower()
        local searchMatches = query == "" or haystack:find(query, 1, true)
        local styleMatches = _overrideStyleFilter == "all" or row.theme == _overrideStyleFilter
        local schoolMatches = _overrideSchoolFilter == "all" or row.school == _overrideSchoolFilter
        if includeAll or (searchMatches and styleMatches and schoolMatches) then
            rows[#rows + 1] = row
        end
    end

    table.sort(rows, function(a, b)
        local av, bv
        if _overrideSort == "id" then
            av, bv = a.id, b.id
        elseif _overrideSort == "style" then
            av, bv = StyleDisplayName(a.theme):lower(), StyleDisplayName(b.theme):lower()
        else
            av, bv = a.name:lower(), b.name:lower()
        end
        if av == bv then return a.id < b.id end
        return av < bv
    end)
    return rows, total
end

local function OverrideStyleFilterValues()
    local values = { all = "All assigned styles" }
    local rows = GetOverrideRows(true)
    for _, row in ipairs(rows) do values[row.theme] = StyleDisplayName(row.theme) end
    if _overrideStyleFilter ~= "all" then
        values[_overrideStyleFilter] = StyleDisplayName(_overrideStyleFilter)
    end
    return values
end

local function OverrideSchoolFilterValues()
    local values = { all = "All detected schools" }
    local rows = GetOverrideRows(true)
    for _, row in ipairs(rows) do values[row.school] = StyleDisplayName(row.school) end
    if _overrideSchoolFilter ~= "all" then
        values[_overrideSchoolFilter] = StyleDisplayName(_overrideSchoolFilter)
    end
    return values
end

local function GetOverrideFamilies()
    local filteredRows, totalRanks = GetOverrideRows()
    local visibleFamilies = {}
    for _, row in ipairs(filteredRows) do visibleFamilies[row.baseName] = true end

    local allRows = GetOverrideRows(true)
    local byName = {}
    for _, row in ipairs(allRows) do
        local family = byName[row.baseName]
        if not family then
            family = { key = row.baseName, name = row.baseName, icon = row.icon, ranks = {} }
            byName[row.baseName] = family
        end
        family.ranks[#family.ranks + 1] = row
    end

    local families, totalFamilies = {}, 0
    for key, family in pairs(byName) do
        totalFamilies = totalFamilies + 1
        table.sort(family.ranks, function(a, b)
            local ar = tonumber(tostring(a.rank or ""):match("(%d+)")) or 0
            local br = tonumber(tostring(b.rank or ""):match("(%d+)")) or 0
            if ar == br then return a.id < b.id end
            return ar < br
        end)
        family.firstID = family.ranks[1].id
        if visibleFamilies[key] then families[#families + 1] = family end
    end

    table.sort(families, function(a, b)
        local av, bv
        if _overrideSort == "id" then
            av, bv = a.firstID, b.firstID
        elseif _overrideSort == "style" then
            av = StyleDisplayName(a.ranks[#a.ranks].theme):lower()
            bv = StyleDisplayName(b.ranks[#b.ranks].theme):lower()
        else
            av, bv = a.name:lower(), b.name:lower()
        end
        if av == bv then return a.firstID < b.firstID end
        return av < bv
    end)
    return families, totalFamilies, totalRanks, #filteredRows
end

local function GetSelectedFamilyRank(family)
    local wanted = tonumber(_savedRankSelection[family.key]) or tonumber(_selOverride)
    if wanted then
        for _, row in ipairs(family.ranks) do
            if row.id == wanted then return row end
        end
    end
    return family.ranks[#family.ranks]
end

local function FamilyRankValues(family)
    local values = {}
    for _, row in ipairs(family.ranks) do
        local rank = row.rank and row.rank ~= "" and row.rank or "No rank"
        values[tostring(row.id)] = string.format("%s - ID %d - %s",
            rank, row.id, StyleDisplayName(GetSpellOverrideTheme(row.id) or row.theme))
    end
    return values
end

local function ExportOverrides()
    local rows = GetOverrideRows(true)
    table.sort(rows, function(a, b) return a.id < b.id end)
    local lines = {}
    for _, row in ipairs(rows) do
        lines[#lines + 1] = tostring(row.id) .. "=" .. tostring(row.theme)
    end
    return table.concat(lines, "\n")
end

local function ParseOverrideImport(text)
    local result = { records = {}, errors = {}, valid = 0, new = 0, replacements = 0 }
    local seen = {}
    local lineNumber = 0
    for line in tostring(text or ""):gmatch("[^\r\n;]+") do
        lineNumber = lineNumber + 1
        if line:match("%S") then
            local rawID, theme = line:match("^%s*(%d+)%s*[=:,]%s*([%w_]+)%s*$")
            local sid = tonumber(rawID)
            theme = theme and theme:lower() or nil
            local reason
            if not sid then
                reason = "expected spellID=style"
            elseif seen[sid] then
                reason = "duplicate spell ID in import"
            elseif not SpellDisplayName(sid) then
                reason = "unknown spell ID"
            elseif not SCB.Schools:Exists(theme) then
                reason = "unknown style"
            end

            if reason then
                result.errors[#result.errors + 1] = string.format("Line %d: %s", lineNumber, reason)
            else
                seen[sid] = true
                local existing = GetSpellOverrideTheme(sid)
                result.records[#result.records + 1] = { id = sid, theme = theme }
                result.valid = result.valid + 1
                if existing then
                    result.replacements = result.replacements + 1
                else
                    result.new = result.new + 1
                end
            end
        end
    end
    return result
end

local function ImportPreviewText()
    if not tostring(_overrideTransferText or ""):match("%S") then
        return "|cff888888Paste override data above to validate it before importing.|r"
    end
    local parsed = ParseOverrideImport(_overrideTransferText)
    local summary = string.format(
        "|cff55ff55Valid: %d|r  |cffaaaaaaNew: %d|r  |cffffcc00Replace: %d|r  |cffff5555Invalid: %d|r",
        parsed.valid, parsed.new, parsed.replacements, #parsed.errors)
    if #parsed.errors > 0 then
        local shown = {}
        for index = 1, math.min(#parsed.errors, 4) do shown[#shown + 1] = parsed.errors[index] end
        summary = summary .. "\n|cffff7777" .. table.concat(shown, "  /  ")
        if #parsed.errors > 4 then summary = summary .. "  /  ..." end
        summary = summary .. "|r"
    end
    return summary
end

local function ApplyOverrideImport(parsed)
    if not parsed or parsed.valid == 0 or not OCBSpellOverrides then return end
    CaptureOverrideUndo("import")
    for _, record in ipairs(parsed.records) do
        OCBSpellOverrides.Set(record.id, record.theme)
    end
    Notify()
end

local function CastRecordIcon(record)
    if record.id then return SpellIconMarkup(record.id, 20) end
    if record.icon then return "|T" .. tostring(record.icon) .. ":20:20:0:0|t " end
    return ""
end

local function LoadCastRecord(record)
    if not record or not record.id then return end
    local existing = GetSpellOverrideTheme(record.id)
    LoadOverrideIntoEditor(record.id, existing)
    if not existing then
        local _, automatic = GetAutomaticSpellStyle(record.id)
        if automatic and automatic ~= "blizzard" and SCB.Schools:Exists(automatic) then
            _newSpellTheme = automatic
        end
    end
end

local function AddRecentCastRow(args, record, index)
    local key = "cast_" .. tostring(record.serial or index)
    local order = index * 3
    local identity = record.id and ("ID: " .. record.id) or "ID unresolved"
    local result
    if record.overrideTheme then
        result = "|cff55ff55Matched override " .. tostring(record.overrideID or record.id)
            .. " -> " .. StyleDisplayName(record.overrideTheme) .. "|r"
    elseif record.finalStyle then
        result = "|cff888888No override matched; final style: "
            .. StyleDisplayName(record.finalStyle) .. "|r"
    else
        result = "|cff888888Waiting for cast resolution.|r"
    end
    args[key .. "_info"] = {
        type = "description", order = order, width = "double", fontSize = "medium",
        name = CastRecordIcon(record) .. "|cffffffff" .. tostring(record.name or "Unknown spell")
            .. (record.rank and record.rank ~= "" and (" (" .. record.rank .. ")") or "")
            .. "|r\n|cffaaaaaa" .. identity .. "|r  " .. result,
    }
    args[key .. "_use"] = {
        type = "execute", order = order + 1, width = "normal", name = "Use",
        disabled = not record.id,
        func = function() LoadCastRecord(record) ; Notify() end,
    }
end

local function BuildRecentCastArgs()
    local args = {}
    local history = SCB.Events and SCB.Events.recentCasts or {}
    if #history == 0 then
        args.empty = {
            type = "description", order = 1, width = "full",
            name = "|cff888888Cast a spell to populate recent history.|r",
        }
    else
        for index = 1, math.min(#history, 5) do
            AddRecentCastRow(args, history[index], index)
        end
        args.clear = {
            type = "execute", order = 100, width = "normal", name = "Clear cast history",
            func = function()
                SCB.Events.recentCasts = {}
                SCB.Events.lastResolution = nil
                SCB.Events.lastCastRecord = nil
                Notify()
            end,
        }
    end
    return args
end

local function AddSavedOverrideFamily(args, family, index)
    local key = "family_" .. tostring(family.firstID)
    local order = 100 + (index - 1) * 10
    local selectedRow = GetSelectedFamilyRank(family)
    local selected = _selOverride == tostring(selectedRow.id) and "  |cff55ff55Editing|r" or ""

    args[key .. "_info"] = {
        type = "description", order = order, width = "normal", fontSize = "medium",
        name = family.icon .. "|cffffffff" .. family.name .. "|r\n"
            .. "|cffaaaaaa" .. (#family.ranks == 1 and "1 saved override"
                or (#family.ranks .. " saved ranks")) .. "|r" .. selected,
    }
    if #family.ranks > 1 then
        args[key .. "_rank"] = {
            type = "select", order = order + 1, width = "normal", name = "Rank to edit",
            values = function() return FamilyRankValues(family) end,
            get = function() return tostring(GetSelectedFamilyRank(family).id) end,
            set = function(_, spellID)
                _savedRankSelection[family.key] = tostring(spellID)
                Notify()
            end,
        }
    else
        local rank = selectedRow.rank and selectedRow.rank ~= "" and selectedRow.rank or "No ranks"
        args[key .. "_rankInfo"] = {
            type = "description", order = order + 1, width = "normal", fontSize = "medium",
            name = "|cffaaaaaa" .. rank .. "|r\n|cff777777ID " .. selectedRow.id .. "|r",
        }
    end
    args[key .. "_style"] = {
        type = "select", order = order + 2, width = "normal", name = "Assigned style",
        values = StyleValues,
        get = function()
            local row = GetSelectedFamilyRank(family)
            return GetSpellOverrideTheme(row.id) or row.theme
        end,
        set = function(_, theme)
            if OCBSpellOverrides then
                local row = GetSelectedFamilyRank(family)
                CaptureOverrideUndo("inline style change")
                OCBSpellOverrides.Set(row.id, theme)
                if _selOverride == tostring(row.id) then _newSpellTheme = theme end
                Notify()
            end
        end,
    }
    args[key .. "_actionBreak"] = {
        type = "description", order = order + 3, width = "full", name = "",
    }
    args[key .. "_preview"] = {
        type = "execute", order = order + 4, width = "half", name = "Preview",
        func = function()
            local row = GetSelectedFamilyRank(family)
            PreviewSchool(GetSpellOverrideTheme(row.id) or row.theme)
        end,
    }
    args[key .. "_edit"] = {
        type = "execute", order = order + 5, width = "normal", name = "Load in editor",
        func = function()
            local row = GetSelectedFamilyRank(family)
            LoadOverrideIntoEditor(row.id, GetSpellOverrideTheme(row.id) or row.theme)
            Notify()
        end,
    }
    args[key .. "_remove"] = {
        type = "execute", order = order + 6, width = "half", name = "Remove",
        desc = "Delete the selected rank override and return that rank to its automatic school style.",
        func = function()
            local row = GetSelectedFamilyRank(family)
            ShowOptionsConfirmation("Remove the override for " .. row.name .. "?", function()
                if OCBSpellOverrides then
                    CaptureOverrideUndo("remove " .. row.name)
                    OCBSpellOverrides.Remove(row.id)
                    _savedRankSelection[family.key] = nil
                    if _selOverride == tostring(row.id) then ClearOverrideEditor() end
                    Notify()
                end
            end)
        end,
    }
    args[key .. "_break"] = {
        type = "description", order = order + 7, width = "full", name = "",
    }
end

local function BuildSavedOverrideArgs()
    local families, totalFamilies, totalRanks, matchingRanks = GetOverrideFamilies()
    local args = {
        search = {
            type = "input", order = 1, width = "double", name = "Search saved overrides",
            desc = "Filter by localized spell name, spell ID, or assigned style.",
            get = function() return _overrideSearch end,
            set = function(_, value)
                _overrideSearch = tostring(value or "")
                Notify()
            end,
        },
        sort = {
            type = "select", order = 2, width = "normal", name = "Sort by",
            values = { name = "Spell name", id = "Spell ID", style = "Assigned style" },
            get = function() return _overrideSort end,
            set = function(_, value) _overrideSort = value ; Notify() end,
        },
        searchRowBreak = {
            type = "description", order = 2.5, width = "full", name = "",
        },
        styleFilter = {
            type = "select", order = 3, width = "normal", name = "Assigned style filter",
            values = OverrideStyleFilterValues,
            get = function() return _overrideStyleFilter end,
            set = function(_, value) _overrideStyleFilter = value ; Notify() end,
        },
        schoolFilter = {
            type = "select", order = 4, width = "normal", name = "Detected school filter",
            values = OverrideSchoolFilterValues,
            get = function() return _overrideSchoolFilter end,
            set = function(_, value) _overrideSchoolFilter = value ; Notify() end,
        },
        filterRowBreak = {
            type = "description", order = 4.5, width = "full", name = "",
        },
        undo = {
            type = "execute", order = 5, width = "normal", name = "Undo last change",
            disabled = function() return not _overrideUndo end,
            desc = function()
                return _overrideUndo and ("Restore the list from before: " .. _overrideUndo.label)
                    or "No saved-override change is available to undo."
            end,
            func = function() RestoreOverrideUndo() ; Notify() end,
        },
        summary = {
            type = "description", order = 6, width = "full",
            name = string.format(
                "|cffaaaaaaShowing %d of %d spells (%d matching rank overrides, %d total).|r",
                #families, totalFamilies, matchingRanks, totalRanks),
        },
    }

    if #families == 0 then
        args.empty = {
            type = "description", order = 20, width = "full",
            name = totalRanks == 0
                and "|cff888888No spell overrides have been saved yet.|r"
                or "|cffffcc00No saved overrides match this search.|r",
        }
    else
        for index, family in ipairs(families) do AddSavedOverrideFamily(args, family, index) end
    end

    args.clearAll = {
        type = "execute", order = 9000, width = "normal", name = "Clear all overrides",
        disabled = totalRanks == 0,
        func = function()
            ShowOptionsConfirmation(
                "Remove every saved spell ID override? School mappings will be kept.",
                function()
                    if OCBSpellOverrides and OCBSpellOverrides.Clear then
                        CaptureOverrideUndo("clear all overrides")
                        OCBSpellOverrides.Clear()
                        _savedRankSelection = {}
                        ClearOverrideEditor()
                        Notify()
                    end
                end
            )
        end,
    }
    args.transferToggle = {
        type = "toggle", order = 9001, width = "normal", name = "Show import / export",
        get = function() return _showOverrideTransfer end,
        set = function(_, value) _showOverrideTransfer = value and true or false ; Notify() end,
    }
    args.transferText = {
        type = "input", order = 9002, width = "full", name = "Override data",
        desc = "One entry per line in the form spellID=style. Import merges with existing overrides.",
        multiline = 6,
        hidden = function() return not _showOverrideTransfer end,
        get = function() return _overrideTransferText end,
        set = function(_, value) _overrideTransferText = tostring(value or "") ; Notify() end,
    }
    args.importPreview = {
        type = "description", order = 9003, width = "full", name = ImportPreviewText,
        hidden = function() return not _showOverrideTransfer end,
    }
    args.export = {
        type = "execute", order = 9004, width = "normal", name = "Export current overrides",
        hidden = function() return not _showOverrideTransfer end,
        disabled = totalRanks == 0,
        func = function()
            _overrideTransferText = ExportOverrides()
            Notify()
        end,
    }
    args.import = {
        type = "execute", order = 9005, width = "normal",
        name = function()
            local parsed = ParseOverrideImport(_overrideTransferText)
            return "Import " .. parsed.valid .. " valid"
        end,
        hidden = function() return not _showOverrideTransfer end,
        disabled = function() return ParseOverrideImport(_overrideTransferText).valid == 0 end,
        func = function()
            local parsed = ParseOverrideImport(_overrideTransferText)
            local function apply()
                ApplyOverrideImport(parsed)
                print(string.format(
                    "|cff00CCFFOpulent Casting Bars|r - imported |cff55ff55%d|r override(s); |cffff5555%d|r invalid line(s) skipped.",
                    parsed.valid, #parsed.errors))
            end
            if parsed.replacements > 0 then
                ShowOptionsConfirmation(
                    "Import " .. parsed.valid .. " overrides and replace "
                        .. parsed.replacements .. " existing assignment(s)?",
                    apply)
            else
                apply()
            end
        end,
    }
    return args
end

-- ============================================================
--  CUSTOM AceGUI WIDGET — live bar preview (Appearance)
--  Referenced via dialogControl = "OCBBarPreview".  Instead of
--  faking the render, it HOSTS the real casting bar (SCB.Bar) over
--  the preview box while the tab is open, so every per-school
--  particle/animation effect is shown.  It loops a cast and
--  restores the bar's parent state (position/scale/strata) on
--  release (tab switch / dialog close / refresh).
-- ============================================================
do
    local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
    if AceGUI then
        local WType, WVersion = "OCBBarPreview", 4
        local HOST_W, HOST_H, FRAME_H = 300, 150, 176

        local function clamp(v, lo, hi)
            if v < lo then return lo elseif v > hi then return hi else return v end
        end

        -- Exactly one widget instance may host the singleton bar at a time.
        -- Tracked at closure scope (shared by every pooled widget) so an odd
        -- acquire/release ordering can never leave a stale per-widget flag
        -- that blocks re-hosting and hides the bar.
        local hostedBy

        -- Float the (top-level) bar over the widget's preview placeholder.
        -- Called every frame so it tracks the box through scrolling, window
        -- moves and AceGUI's post-OnAcquire relayout (a one-time SetPoint goes
        -- stale; refreshing each frame never does).
        local function AnchorToHost(self)
            local wrapper = SCB.Bar and SCB.Bar.frame
            local host = self.host
            if not wrapper or not host then return end
            wrapper:ClearAllPoints()
            wrapper:SetPoint("CENTER", host, "CENTER", 0, 0)
        end

        -- Return the real bar to its configured place.  Everything is derived
        -- from config; we deliberately do NOT snapshot live anchor points
        -- (they can reference a released host frame and error on restore).
        local function RestoreBar()
            hostedBy = nil
            local bar = SCB.Bar
            local wrapper = bar and bar.frame
            if not wrapper then return end
            if bar.isActive or bar.isFading then bar:StopCast(false) end

            local strata = SCB.Config:Get("barStrata") or "MEDIUM"
            local anchor = SCB.Config:Get("anchor") or "CENTER"
            wrapper:SetParent(UIParent)
            wrapper:SetClampedToScreen(true)
            wrapper:ClearAllPoints()
            wrapper:SetPoint(anchor, UIParent, anchor,
                SCB.Config:Get("x") or 0, SCB.Config:Get("y") or -250)
            wrapper:SetScale(SCB.Config:Get("scale") or 0.8)
            wrapper:SetFrameStrata(strata)
            if bar.frameInner then bar.frameInner:SetFrameStrata(strata) end
            wrapper:SetAlpha(1)
            wrapper:EnableMouse(not SCB.Config:Get("locked"))
            wrapper:Hide()
        end

        -- Pull the real bar over THIS widget's preview box.  Idempotent: safe
        -- to call again on a re-acquired (pooled) widget or when another widget
        -- was hosting — it simply takes over and floats over self.host.
        local function HijackBar(self)
            local bar = SCB.Bar
            local wrapper = bar and bar.frame
            if not wrapper or not self.host then return end
            hostedBy = self

            local bw = SCB.Config:Get("barWidth") or 400
            self._scale   = clamp(HOST_W / bw, 0.2, 0.6)
            self._lastKey = nil

            -- Keep the bar TOP-LEVEL (child of UIParent) so it is NOT clipped
            -- by the options window's scroll frame (AceConfigDialog wraps group
            -- content in a real WoW ScrollFrame, which clips its children).
            -- Float it above the dialog at TOOLTIP strata and anchor it over
            -- the preview placeholder; OnUpdate refreshes the anchor each frame.
            wrapper:EnableMouse(false)
            wrapper:SetClampedToScreen(false)
            wrapper:SetParent(UIParent)
            wrapper:SetScale(self._scale)
            wrapper:SetFrameStrata("TOOLTIP")
            if bar.frameInner then bar.frameInner:SetFrameStrata("TOOLTIP") end
            wrapper:SetAlpha(1)
            AnchorToHost(self)
            wrapper:Show()
        end

        local function StartLoopCast(self)
            local bar = SCB.Bar
            if not bar or not bar.frame then return end
            local key = SCB.Config:Get("defaultSchool") or "neutral"
            bar:StartCast("Preview", 3, key)
            bar.frame:SetScale(self._scale or 0.5)   -- override StartCast's config scale
            bar.frame:Show()                          -- show now, don't wait for the deferred show
            self._lastKey = key
        end

        local function OnUpdate(frame)
            local self = frame.obj
            if hostedBy ~= self then return end
            AnchorToHost(self)                            -- track the box (scroll / move / relayout)
            local key = SCB.Config:Get("defaultSchool") or "neutral"
            if key ~= self._lastKey then
                StartLoopCast(self)                       -- instant on selection change
            elseif not SCB.Bar.isActive and not SCB.Bar.isFading then
                StartLoopCast(self)                       -- loop while idle
            end
        end

        local function OnAcquire(self)
            self:SetWidth(HOST_W + 20)
            self:SetHeight(FRAME_H)
            self.frame:Show()
            pcall(HijackBar, self)
            pcall(StartLoopCast, self)                    -- kick off immediately
            self.frame:SetScript("OnUpdate", OnUpdate)
        end

        local function OnRelease(self)
            self.frame:SetScript("OnUpdate", nil)
            if hostedBy == self then pcall(RestoreBar) end
            self.frame:Hide()
        end

        local noop = function() end

        local function Constructor()
            local frame = CreateFrame("Frame", nil, UIParent)
            frame:SetSize(HOST_W + 20, FRAME_H)

            local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            lbl:SetPoint("TOP", frame, "TOP", 0, -2)
            lbl:SetText("Live preview")

            local host = CreateFrame("Frame", nil, frame)
            host:SetSize(HOST_W, HOST_H)
            host:SetPoint("TOP", lbl, "BOTTOM", 0, -6)

            local widget = {
                type = WType, frame = frame, host = host,
                OnAcquire = OnAcquire, OnRelease = OnRelease,
                SetLabel = noop, SetText = noop, SetDisabled = noop,
            }
            frame.obj = widget
            return AceGUI:RegisterAsWidget(widget)
        end

        AceGUI:RegisterWidgetType(WType, Constructor, WVersion)
    end
end

-- ============================================================
--  THEME ASSIGNMENTS ARGS (built once)
-- ============================================================
local function BuildThemeArgs()
    local map = {}
    for i, row in ipairs(ASSIGN_ROWS) do
        local key = row.key
        local iconStr = row.iconFull
            and ("|T" .. row.iconFull .. ":18|t ")
            or  ("|TInterface\\Icons\\" .. (row.icon or "INV_Misc_QuestionMark") .. ":18|t ")
        map["assign_" .. key] = {
            -- One normal dropdown + one half-width preview button = half a
            -- row, allowing two complete school controls per line.
            type = "select", order = i * 2, width = "normal",
            name = iconStr .. row.label,
            values = AssignStyleValues,
            get = function()
                local m = SCB.Config:Get("themeAssignments") or {}
                return m[key] or "none"
            end,
            set = function(_, v)
                local m = SCB.Config:Get("themeAssignments") or {}
                -- Do not persist explicit "none" entries; absence already means
                -- automatic detection and keeps profiles compact/readable.
                m[key] = v ~= "none" and v or nil
                SCB.Config:Set("themeAssignments", m)
                if v == "blizzard" and not SCB._blizzardDynamic then
                    print("|cff00CCFFOpulent Casting Bars|r — |cffffff00ReloadUI required|r"
                        .. " for the Blizzard bar to appear for this school.")
                end
                Notify()
            end,
        }
        map["preview_" .. key] = {
            type = "execute", order = i * 2 + 1, width = "half", name = "Preview",
            desc = "Preview the mapped style, or the natural style when no mapping is set.",
            disabled = function()
                local m = SCB.Config:Get("themeAssignments") or {}
                return m[key] == "blizzard"
            end,
            func = function()
                local m = SCB.Config:Get("themeAssignments") or {}
                local style = m[key]
                if not style or style == "none" then
                    style = key == "misc"
                        and (SCB.Config:Get("defaultSchool") or "neutral") or key
                end
                PreviewSchool(style)
            end,
        }
        if i % 2 == 0 and i < #ASSIGN_ROWS then
            -- AceGUI's Flow layout otherwise adds a third school when the
            -- window grows. An empty full-width control creates a deterministic
            -- row boundary after every second selector/preview pair.
            map["rowBreak_" .. i] = {
                type = "description", order = i * 2 + 1.5,
                width = "full", name = "",
            }
        end
    end

    map.mappingSummary = {
        type = "description", order = 100, width = "full",
        name = function()
            local count = CountTableEntries(SCB.Config:Get("themeAssignments"), true)
            return string.format("|cffAAAAAA%d of %d schools currently customized.|r",
                count, #ASSIGN_ROWS)
        end,
    }
    map.resetMappings = {
        type = "execute", order = 101, width = "normal", name = "Reset school mappings",
        desc = "Return every school to automatic style detection. Spell overrides are kept.",
        disabled = function()
            return CountTableEntries(SCB.Config:Get("themeAssignments"), true) == 0
        end,
        confirm = true,
        confirmText = "Reset every school-to-style mapping? Spell ID overrides will be kept.",
        func = function()
            SCB.Config:Set("themeAssignments", {})
            Notify()
        end,
    }

    return {
        enable = {
            type = "toggle", order = 0, width = "full",
            name = "Use custom assignments",
            desc = "Enable school mappings and per-spell style overrides while using Automatic selection mode.",
            get = function() return SCB.Config:Get("useThemeAssignments") or false end,
            set = function(_, v)
                SCB.Config:Set("useThemeAssignments", v and true or false)
                Notify()
            end,
        },
        status = {
            type = "description", order = 1,
            name = function()
                local mappings = CountTableEntries(SCB.Config:Get("themeAssignments"), true)
                local spells = CountTableEntries(SpellOverrides())
                if not SCB.Config:Get("useSchoolDetection") then
                    return "|cffffcc00Inactive: Appearance > Selection mode is Fixed. "
                        .. "Choose Automatic to use assignments.|r"
                end
                if not SCB.Config:Get("useThemeAssignments") then
                    return string.format("|cffAAAAAAInactive — %d school mappings and %d spell overrides saved.|r",
                        mappings, spells)
                end
                return string.format("|cff55ff55Active|r  •  %d school mappings  •  %d spell overrides",
                    mappings, spells)
            end,
        },
        mapGroup = {
            type = "group", inline = true, order = 2, name = "School Styles",
            desc = "Override an automatically detected school, or leave it as None to use its natural style.",
            disabled = function() return not SCB.Config:Get("useThemeAssignments") end,
            args = map,
        },
        spellGroup = {
            type = "group", inline = true, order = 3,
            name = function()
                local _, total = GetOverrideRows(true)
                return "Advanced: Spell ID overrides (" .. total .. ")"
            end,
            desc = "Force one exact spell rank to use a specific style.",
            disabled = function() return not SCB.Config:Get("useThemeAssignments") end,
            args = {
                help = {
                    type = "description", order = 0, width = "full",
                    name = "Use the spell ID for the rank you actually cast. On 3.3.5a, "
                        .. "the addon matches the live localized spell name and rank. "
                        .. "Cast the spell once and Use last cast can fill the exact learned rank automatically.",
                },
                newID = {
                    type = "input", order = 1, width = "double", name = "Spell ID or spell link",
                    desc = "Enter a numeric ID or paste a spell link; OCB extracts the spell ID automatically.",
                    get = function() return _newSpellID end,
                    set = function(_, v)
                        local raw = tostring(v or "")
                        local extracted = ExtractSpellID(raw)
                        local cleaned = extracted and tostring(extracted) or ""
                        _newSpellID = cleaned
                        _spellInputError = raw:match("%S") and not extracted
                            and "No spell ID was found in that value or link." or nil
                        local existing = GetSpellOverrideTheme(extracted)
                        if existing then
                            _selOverride = cleaned
                            _newSpellTheme = existing
                        elseif _selOverride ~= cleaned then
                            _selOverride = nil
                        end
                        Notify()
                    end,
                },
                useLastCast = {
                    type = "execute", order = 2, width = "normal", name = "Use last cast",
                    desc = function()
                        local events = SCB.Events
                        if events and events.lastCastSpellID then
                            return "Load " .. (SpellDisplayName(events.lastCastSpellID)
                                or tostring(events.lastCastSpellID)) .. " into the editor."
                        end
                        if events and events.lastCastName then
                            return "The last cast was " .. events.lastCastName
                                .. ", but its exact rank ID could not be resolved."
                        end
                        return "Cast a player spell first, then click this button."
                    end,
                    disabled = function()
                        return not (SCB.Events and SCB.Events.lastCastSpellID)
                    end,
                    func = function() UseLastCastInEditor() ; Notify() end,
                },
                editorStatus = {
                    type = "description", order = 3, width = "full", fontSize = "medium",
                    name = EditorSpellStatus,
                },
                relatedRanks = {
                    type = "description", order = 3.5, width = "full",
                    name = RelatedRanksStatus,
                },
                applyAllRanks = {
                    type = "toggle", order = 4, width = "normal",
                    name = function()
                        local ranks = GetKnownSpellRanks(_newSpellID)
                        return "Apply to all known ranks (" .. #ranks .. ")"
                    end,
                    desc = "Create or update an override for every known rank with the same localized spell name.",
                    disabled = function() return #GetKnownSpellRanks(_newSpellID) <= 1 end,
                    get = function() return _applyAllRanks end,
                    set = function(_, value) _applyAllRanks = value and true or false ; Notify() end,
                },
                newTheme = {
                    type = "select", order = 5, width = "normal", name = "Assigned bar style",
                    values = StyleValues,
                    get = function() return _newSpellTheme end,
                    set = function(_, v) _newSpellTheme = v ; Notify() end,
                },
                editorPreview = {
                    type = "execute", order = 6, width = "half", name = "Preview",
                    desc = "Preview the style currently selected in the editor.",
                    disabled = function() return not _newSpellTheme end,
                    func = function() PreviewSchool(_newSpellTheme) end,
                },
                editorStyleBreak = {
                    type = "description", order = 6.5, width = "full", name = "",
                },
                addBtn = {
                    type = "execute", order = 7, width = "normal",
                    name = function()
                        if _applyAllRanks then
                            return "Apply to " .. #GetKnownSpellRanks(_newSpellID) .. " ranks"
                        end
                        return GetSpellOverrideTheme(_newSpellID) and "Update override" or "Add override"
                    end,
                    disabled = function()
                        local sid = tonumber(_newSpellID)
                        return not sid or sid <= 0 or not SpellDisplayName(sid) or not _newSpellTheme
                    end,
                    func = function()
                        local sid = tonumber(_newSpellID)
                        if not sid or sid <= 0 or not OCBSpellOverrides then return end
                        local ranks = _applyAllRanks and GetKnownSpellRanks(sid)
                            or { { id = sid } }
                        local previous = GetSpellOverrideTheme(sid)
                        if #ranks > 1 then
                            CaptureOverrideUndo("apply style to all ranks")
                        else
                            CaptureOverrideUndo(previous and "update override" or "add override")
                        end
                        local saved = false
                        for _, row in ipairs(ranks) do
                            if OCBSpellOverrides.Set(row.id, _newSpellTheme) then saved = true end
                        end
                        if saved then
                            _selOverride = tostring(sid)
                            Notify()
                        end
                    end,
                },
                clearEditor = {
                    type = "execute", order = 8, width = "normal", name = "Clear editor",
                    desc = "Clear the editor without changing saved overrides.",
                    disabled = function() return _newSpellID == "" and not _selOverride end,
                    func = function() ClearOverrideEditor() ; Notify() end,
                },
                editorButtonsBreak = {
                    type = "description", order = 8.5, width = "full", name = "",
                },
                recentGroup = {
                    type = "group", inline = true, order = 9, width = "full",
                    name = function()
                        local history = SCB.Events and SCB.Events.recentCasts or {}
                        return "Recent casts (" .. math.min(#history, 5) .. ")"
                    end,
                    args = BuildRecentCastArgs(),
                },
                savedGroup = {
                    type = "group", inline = true, order = 10, width = "full",
                    name = function()
                        local _, totalFamilies, totalRanks = GetOverrideFamilies()
                        return string.format("Saved overrides (%d spells / %d ranks)",
                            totalFamilies, totalRanks)
                    end,
                    args = BuildSavedOverrideArgs(),
                },
            },
        },
    }
end

-- ============================================================
--  ROOT OPTIONS TABLE
-- ============================================================
local function BuildOptions()
    return {
        type = "group",
        name = "Opulent Casting Bars",
        childGroups = "tree",
        args = {

            -- ---- GENERAL ------------------------------------------
            general = {
                type = "group", order = 1, name = "General",
                args = {
                    scale = {
                        type = "range", order = 1, width = "full", name = "Bar scale",
                        min = 0.5, max = 2.0, step = 0.05, isPercent = false,
                        get = GetCfg,
                        set = function(_, v) SCB.Config:Set("scale", v) ; SCB.Bar.frame:SetScale(v) end,
                    },
                    barWidth = {
                        type = "range", order = 2, width = "full", name = "Bar width (px)",
                        min = 200, max = 700, step = 10,
                        get = GetCfg,
                        set = function(_, v) SCB.Bar:Resize(v, SCB.Config:Get("barHeight")) end,
                    },
                    locked = {
                        type = "toggle", order = 3, name = "Lock bar position",
                        get = GetCfg,
                        set = function(_, v)
                            SCB.Config:Set("locked", v)
                            SCB.Bar.frame:EnableMouse(not v)
                        end,
                    },
                    hideBlizzardBar = {
                        type = "toggle", order = 4, name = "Hide default Blizzard cast bar",
                        get = GetCfg,
                        set = function(_, v)
                            SCB.Config:Set("hideBlizzardBar", v)
                            SCB.ApplyHideBlizzardBar(v)
                        end,
                    },
                    barStrata = {
                        type = "select", order = 5, name = "Frame strata",
                        values = STRATA,
                        get = GetCfg,
                        set = function(_, v) SCB.Config:Set("barStrata", v) ; ApplyStrata() end,
                    },
                    posHeader = { type = "header", order = 10, name = "Position" },
                    x = {
                        type = "range", order = 11, width = "full", name = "Position X",
                        min = -800, max = 800, step = 1,
                        get = GetCfg,
                        set = function(_, v) SCB.Config:Set("x", v) ; RepositionBar() end,
                    },
                    y = {
                        type = "range", order = 12, width = "full", name = "Position Y",
                        min = -600, max = 600, step = 1,
                        get = GetCfg,
                        set = function(_, v) SCB.Config:Set("y", v) ; RepositionBar() end,
                    },
                    actionsHeader = { type = "header", order = 20, name = "Actions" },
                    test = {
                        type = "execute", order = 21, name = "Test cast (5s)", func = TestCast,
                    },
                    reset = {
                        type = "execute", order = 22, name = "Reset to defaults",
                        confirm = true,
                        confirmText = "Reset all Opulent Casting Bars settings to defaults?",
                        func = ResetDefaults,
                    },
                },
            },

            -- ---- APPEARANCE ---------------------------------------
            appearance = {
                type = "group", order = 2, name = "Appearance",
                args = {
                    mode = {
                        type = "select", order = 1, width = "full", name = "Selection mode",
                        desc = "Automatic picks a bar from the spell's magic school. "
                            .. "Fixed always uses one bar.",
                        values = {
                            auto  = "Automatic — by spell school (recommended)",
                            fixed = "Fixed — one bar for all spells",
                        },
                        get = function() return SCB.Config:Get("useSchoolDetection") and "auto" or "fixed" end,
                        set = function(_, v) SCB.Config:Set("useSchoolDetection", v == "auto") end,
                    },
                    defaultSchool = {
                        type = "select", order = 2, width = "full",
                        name = function()
                            return SCB.Config:Get("useSchoolDetection")
                                and "Default bar (used when the school is unknown)"
                                or  "Bar style for all spells"
                        end,
                        values = StyleValues,
                        get = function() return SCB.Config:Get("defaultSchool") or "neutral" end,
                        set = function(_, v) SCB.Config:Set("defaultSchool", v) end,
                    },
                    previewBar = {
                        type = "input", order = 3, width = "full", name = "",
                        dialogControl = "OCBBarPreview",
                        get = function() return "" end,
                        set = function() end,
                    },
                    tip = {
                        type = "description", order = 4, fontSize = "medium",
                        name = "\nTip: change the bar above to preview it live. Use Theme "
                            .. "Assignments to map each magic school to a specific style.",
                    },
                },
            },

            -- ---- TEXT ---------------------------------------------
            text = {
                type = "group", order = 3, name = "Text",
                args = {
                    fontGroup = {
                        type = "group", inline = true, order = 1, name = "Font & Style",
                        args = {
                            fontFace = {
                                type = "select", order = 1, width = "full", name = "Font",
                                dialogControl = "LSM30_Font",
                                values = FontValues,
                                get = function()
                                    local f = SCB.Config:Get("fontFace") or "DEFAULT"
                                    return FONT_LEGACY_ALIAS[f] or f
                                end,
                                set = function(_, v)
                                    SCB.Config:Set("fontFace", v)
                                    if SCB.Bar.isActive or SCB.Bar.isFading then SCB.Bar:StopCast(false) end
                                    SCB.Bar:ApplyTextPrefs()
                                    Notify()
                                end,
                            },
                            textOutline = {
                                type = "toggle", order = 2, name = "Outline",
                                get = GetCfg, set = SetText,
                            },
                            textCentered = {
                                type = "toggle", order = 3, name = "Center both (name | timer)",
                                get = GetCfg, set = SetText,
                            },
                        },
                    },
                    nameGroup = {
                        type = "group", inline = true, order = 2, name = "Spell Name",
                        args = {
                            textNameShow = {
                                type = "toggle", order = 1, name = "Show spell name",
                                get = GetCfg,
                                set = function(_, v)
                                    SCB.Config:Set("textNameShow", v)
                                    SCB.Config:Set("showSpellName", v)
                                    SCB.Bar.spellNameText:SetShown(v)
                                    SCB.Bar:ApplyTextPrefs()
                                end,
                            },
                            textNameTruncate = {
                                type = "toggle", order = 2, name = "Truncate long names (>30 chars)",
                                get = GetCfg, set = SetText,
                            },
                            textNameSize = {
                                type = "range", order = 3, name = "Size",
                                min = 7, max = 22, step = 1, get = GetCfg, set = SetText,
                            },
                            textNameAlign = {
                                type = "select", order = 4, name = "Alignment",
                                values = ALIGN, get = GetCfg, set = SetText,
                            },
                            textNamePosX = {
                                type = "range", order = 5, name = "X offset",
                                min = -80, max = 80, step = 1, get = GetCfg, set = SetText,
                            },
                            textNamePosY = {
                                type = "range", order = 6, name = "Y offset",
                                min = -40, max = 40, step = 1, get = GetCfg, set = SetText,
                            },
                        },
                    },
                    timerGroup = {
                        type = "group", inline = true, order = 3, name = "Timer",
                        args = {
                            textTimerShow = {
                                type = "toggle", order = 1, name = "Show cast timer",
                                get = GetCfg,
                                set = function(_, v)
                                    SCB.Config:Set("textTimerShow", v)
                                    SCB.Config:Set("showCastTime", v)
                                    SCB.Bar.castTimerText:SetShown(v)
                                    SCB.Bar:ApplyTextPrefs()
                                end,
                            },
                            textTimerSize = {
                                type = "range", order = 2, name = "Size",
                                min = 7, max = 22, step = 1, get = GetCfg, set = SetText,
                            },
                            textTimerAlign = {
                                type = "select", order = 3, name = "Alignment",
                                values = ALIGN, get = GetCfg, set = SetText,
                            },
                            textTimerPosX = {
                                type = "range", order = 4, name = "X offset",
                                min = -80, max = 80, step = 1, get = GetCfg, set = SetText,
                            },
                            textTimerPosY = {
                                type = "range", order = 5, name = "Y offset",
                                min = -40, max = 40, step = 1, get = GetCfg, set = SetText,
                            },
                        },
                    },
                    colorGroup = {
                        type = "group", inline = true, order = 4, name = "Text Color",
                        args = {
                            textColor = {
                                type = "color", order = 1, name = "Name & timer color", hasAlpha = false,
                                get = function()
                                    local c = SCB.Config:Get("textCustomColor") or { r = 1, g = 1, b = 1 }
                                    return c.r or 1, c.g or 1, c.b or 1
                                end,
                                set = function(_, r, g, b)
                                    SCB.Config:Set("textCustomColor", { r = r, g = g, b = b })
                                    SCB.Config:Set("textNameColor", "custom")
                                    SCB.Config:Set("textTimerColor", "custom")
                                    SCB.Bar:ApplyTextPrefs()
                                end,
                            },
                        },
                    },
                },
            },

            -- ---- THEME ASSIGNMENTS --------------------------------
            themes = {
                type = "group", order = 4, name = "Theme Assignments",
                args = BuildThemeArgs(),
            },

            -- ---- PROFILES (mirrors the standard AceDB / UFI screen) -------
            profiles = {
                type = "group", order = 5, name = "Profiles",
                args = {
                    desc = {
                        order = 1, type = "description",
                        name = "You can change the active database profile, so you can "
                            .. "have different settings for every character.\n",
                    },
                    descreset = {
                        order = 9, type = "description",
                        name = "Reset the current profile back to its default values, in "
                            .. "case your configuration is broken, or you simply want to "
                            .. "start over.",
                    },
                    reset = {
                        order = 10, type = "execute",
                        name = "Reset Profile", desc = "Reset the current profile to the default",
                        func = function()
                            SCB.Profiles:Reset(SCB.Profiles:GetCurrent())
                            Notify()
                        end,
                    },
                    current = {
                        order = 11, type = "description", width = "default",
                        name = function()
                            return "Current Profile: |cffffd200"
                                .. SCB.Profiles:GetCurrent() .. "|r"
                        end,
                    },
                    choosedesc = {
                        order = 20, type = "description",
                        name = "\nYou can either create a new profile by entering a name "
                            .. "in the editbox, or choose one of the already existing profiles.",
                    },
                    new = {
                        order = 30, type = "input",
                        name = "New", desc = "Create a new empty profile.",
                        get = function() return "" end,
                        set = function(_, v)
                            if not v or v == "" then return end
                            local exists = false
                            for _, n in ipairs(SCB.Profiles:GetAll()) do
                                if n == v then exists = true break end
                            end
                            if exists then
                                SCB.Profiles:Switch(v)
                            else
                                local ok, err = SCB.Profiles:New(v, false)
                                if not ok then print("|cffFF4444OCB Profiles:|r " .. (err or "error")) end
                            end
                            Notify()
                        end,
                    },
                    choose = {
                        order = 40, type = "select",
                        name = "Existing Profiles",
                        desc = "Select one of your currently available profiles.",
                        get = function() return SCB.Profiles:GetCurrent() end,
                        set = function(_, v) SCB.Profiles:Switch(v) ; Notify() end,
                        values = function()
                            local t = {}
                            for _, n in ipairs(SCB.Profiles:GetAll()) do t[n] = n end
                            return t
                        end,
                    },
                    copydesc = {
                        order = 50, type = "description",
                        name = "\nCopy the settings from one existing profile into the "
                            .. "currently active profile.",
                    },
                    copyfrom = {
                        order = 60, type = "select",
                        name = "Copy From",
                        desc = "Copy the settings from one existing profile into the "
                            .. "currently active profile.",
                        get = false,
                        set = function(_, v)
                            local ok, err = SCB.Profiles:Copy(v)
                            if not ok then print("|cffFF4444OCB Profiles:|r " .. (err or "error")) end
                            Notify()
                        end,
                        values = function()
                            local t, cur = {}, SCB.Profiles:GetCurrent()
                            for _, n in ipairs(SCB.Profiles:GetAll()) do
                                if n ~= cur then t[n] = n end
                            end
                            return t
                        end,
                        disabled = function()
                            local cur = SCB.Profiles:GetCurrent()
                            for _, n in ipairs(SCB.Profiles:GetAll()) do
                                if n ~= cur then return false end
                            end
                            return true
                        end,
                    },
                    deldesc = {
                        order = 70, type = "description",
                        name = "\nDelete existing and unused profiles from the database to "
                            .. "save space, and cleanup the SavedVariables file.",
                    },
                    delete = {
                        order = 80, type = "select",
                        name = "Delete a Profile",
                        desc = "Deletes a profile from the database.",
                        get = false,
                        set = function(_, v)
                            local ok, err = SCB.Profiles:Delete(v)
                            if not ok then print("|cffFF4444OCB Profiles:|r " .. (err or "error")) end
                            Notify()
                        end,
                        values = function()
                            local t, cur = {}, SCB.Profiles:GetCurrent()
                            for _, n in ipairs(SCB.Profiles:GetAll()) do
                                if n ~= cur and n ~= DEFAULT_PROFILE then t[n] = n end
                            end
                            return t
                        end,
                        disabled = function()
                            local cur = SCB.Profiles:GetCurrent()
                            for _, n in ipairs(SCB.Profiles:GetAll()) do
                                if n ~= cur and n ~= DEFAULT_PROFILE then return false end
                            end
                            return true
                        end,
                        confirm = true,
                        confirmText = "Are you sure you want to delete the selected profile?",
                    },
                },
            },

            -- ---- ABOUT --------------------------------------------
            about = {
                type = "group", order = 6, name = "About",
                args = {
                    title = {
                        type = "description", order = 1, fontSize = "large",
                        name = "|cff00CCFFOpulent Casting Bars|r  v" .. (SCB.VERSION or "?"),
                    },
                    desc = {
                        type = "description", order = 2,
                        name = "Highly visual casting bars with per-school magic textures and animations.",
                    },
                    cmds = {
                        type = "description", order = 3, fontSize = "medium",
                        name = "\nSlash commands:\n"
                            .. "|cffffff00/ocb|r  — open this panel\n"
                            .. "|cffffff00/ocb test [school] [seconds]|r  — preview a cast\n"
                            .. "|cffffff00/ocb lock|r / |cffffff00unlock|r  — lock or unlock the bar\n"
                            .. "|cffffff00/ocb schools|r  — list available schools\n"
                            .. "|cffffff00/ocb help|r  — show help",
                    },
                },
            },
        },
    }
end

-- ============================================================
--  PUBLIC ENTRY POINTS
-- ============================================================

-- Close the Blizzard Interface Options / Settings window (if it is open) so the
-- standalone AceConfigDialog window isn't left hidden behind it on this client.
local function CloseBlizzardOptions()
    local function hide(f)
        if f and f.IsShown and f:IsShown() then
            if HideUIPanel then HideUIPanel(f) else f:Hide() end
        end
    end
    hide(InterfaceOptionsFrame)
    hide(SettingsPanel)
    -- Hidden last: closing the interface options can re-reveal the game menu
    -- (the Esc menu) it was opened from, which would otherwise sit behind us.
    hide(GameMenuFrame)
end

local function OpenOptionsWindow()
    if not AceConfigDialog then return end
    AceConfigDialog:Open(APP)

    local dialog = AceConfigDialog.OpenFrames[APP]
    if not (dialog and dialog.frame) then return end

    -- Two school controls require 510 px inside the Theme Assignments group.
    -- Accounting for the frame, tree navigation, and inline-group insets makes
    -- 800 px the smallest safe outer width. This prevents the grid collapsing
    -- to one column while explicit row breaks prevent a third column.
    dialog.frame:SetMinResize(OPTIONS_MIN_WIDTH, 200)
    if dialog.frame:GetWidth() < OPTIONS_MIN_WIDTH then
        dialog:SetWidth(OPTIONS_MIN_WIDTH)
    end
end

function SCB.Options:Create()
    AceConfig         = LibStub("AceConfig-3.0")
    AceConfigDialog   = LibStub("AceConfigDialog-3.0")
    AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

    -- Generate on demand so saved-override rows can be added, filtered, sorted,
    -- edited, and removed without maintaining a second mutable options tree.
    AceConfig:RegisterOptionsTable(APP, BuildOptions)
    AceConfigDialog:SetDefaultSize(APP, OPTIONS_MIN_WIDTH, OPTIONS_DEFAULT_HEIGHT)

    -- Hooks used by Profiles.lua to refresh the panel after a profile change
    SCB.Options.RefreshFromConfig = Notify
    if SCB.Profiles then SCB.Profiles._refreshUI = Notify end

    -- Minimal Blizzard Interface Options entry: a button that opens the dialog.
    -- (No embedded dropdowns here, avoiding this HD client's options-strata quirks.)
    local panel = CreateFrame("Frame")
    panel.name = "Opulent Casting Bars"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Opulent Casting Bars")

    local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    sub:SetText("v" .. (SCB.VERSION or "?") .. "  —  per-school magic casting bars")

    local open = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    open:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -34)
    open:SetSize(200, 26)
    open:SetText("Open Configuration")
    -- Opening the standalone window: close the Blizzard options first so the
    -- config window isn't hidden behind them, then reveal it.
    open:SetScript("OnClick", function()
        CloseBlizzardOptions()
        if AceConfigDialog and not AceConfigDialog.OpenFrames[APP] then
            OpenOptionsWindow()
        end
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local cat = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(cat)
        SCB.Options.category = cat
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
    SCB.Options.panel = panel
end

function SCB.Options:Toggle()
    if not AceConfigDialog then return end
    if AceConfigDialog.OpenFrames[APP] then
        AceConfigDialog:Close(APP)
    else
        CloseBlizzardOptions()
        OpenOptionsWindow()
    end
end
