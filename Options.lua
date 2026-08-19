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

-- Ace3 handles (resolved in :Create, once the libs are loaded)
local AceConfig, AceConfigDialog, AceConfigRegistry

local function Notify()
    if AceConfigRegistry then AceConfigRegistry:NotifyChange(APP) end
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

local function CountTableEntries(src, meaningfulOnly)
    if type(src) ~= "table" then return 0 end
    local count = 0
    for _, value in pairs(src) do
        if not meaningfulOnly or (value and value ~= "none") then count = count + 1 end
    end
    return count
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
            type = "group", inline = true, order = 3, name = "Advanced: Spell ID overrides",
            desc = "Force one exact spell rank to use a specific style. Selecting a saved override loads it into the editor.",
            disabled = function() return not SCB.Config:Get("useThemeAssignments") end,
            args = {
                help = {
                    type = "description", order = 0, width = "full",
                    name = "Use the spell ID for the rank you actually cast. On 3.3.5a, "
                        .. "the addon matches the live localized spell name and rank.",
                },
                newID = {
                    type = "input", order = 1, width = "half", name = "Spell ID",
                    get = function() return _newSpellID end,
                    set = function(_, v)
                        local cleaned = tostring(v or ""):gsub("%D", "")
                        _newSpellID = cleaned
                        if _selOverride ~= cleaned then _selOverride = nil end
                        Notify()
                    end,
                },
                newIDName = {
                    type = "description", order = 2, width = "normal",
                    name = function()
                        local sid = tonumber(_newSpellID)
                        if not sid or sid <= 0 then
                            return "|cff888888Enter a numeric spell ID.|r"
                        end
                        local display = SpellDisplayName(sid)
                        local existing = GetSpellOverrideTheme(sid)
                        if display then
                            local suffix = existing and ("  |cffFFCC00Currently: "
                                .. (STYLE_LABELS[existing] or existing) .. "|r") or ""
                            return SpellIconMarkup(sid, 20) .. "Spell: |cff55ff55"
                                .. display .. "|r" .. suffix
                        end
                        return "|cffff5555Spell not found in the client cache.|r"
                    end,
                },
                newTheme = {
                    type = "select", order = 3, width = "double", name = "Assigned bar style",
                    values = StyleValues,
                    get = function() return _newSpellTheme end,
                    set = function(_, v) _newSpellTheme = v ; Notify() end,
                },
                addBtn = {
                    type = "execute", order = 4, width = "normal",
                    name = function()
                        return GetSpellOverrideTheme(_newSpellID) and "Update override" or "Add override"
                    end,
                    disabled = function()
                        local sid = tonumber(_newSpellID)
                        return not sid or sid <= 0 or not _newSpellTheme
                    end,
                    func = function()
                        local sid = tonumber(_newSpellID)
                        if sid and sid > 0 and OCBSpellOverrides
                           and OCBSpellOverrides.Set(sid, _newSpellTheme) then
                            _selOverride = tostring(sid)
                            Notify()
                        end
                    end,
                },
                clearEditor = {
                    type = "execute", order = 5, width = "normal", name = "New override",
                    desc = "Clear the editor without changing saved overrides.",
                    disabled = function() return _newSpellID == "" and not _selOverride end,
                    func = function()
                        _newSpellID = ""
                        _newSpellTheme = "neutral"
                        _selOverride = nil
                        Notify()
                    end,
                },
                savedHeader = {
                    type = "header", order = 9, name = "Saved overrides",
                },
                listSel = {
                    type = "select", order = 10, width = "double", name = "Select an override",
                    desc = "The list shows: spell ID, assigned style, localized spell name, and rank.",
                    values = function()
                        local src = SpellOverrides()
                        local t, any = {}, false
                        for sid, theme in pairs(src) do
                            any = true
                            local n = SpellDisplayName(tonumber(sid)) or "Unknown spell"
                            t[tostring(sid)] = string.format("%s%s  |cffAAAAAA(%s)|r  %s",
                                SpellIconMarkup(tonumber(sid), 18), tostring(sid),
                                STYLE_LABELS[theme] or theme, n)
                        end
                        if not any then t["__none"] = "(no overrides yet)" end
                        return t
                    end,
                    get = function()
                        if _selOverride and GetSpellOverrideTheme(_selOverride) then
                            return _selOverride
                        end
                        return "__none"
                    end,
                    set = function(_, v)
                        if v == "__none" then return end
                        local theme = GetSpellOverrideTheme(v)
                        if not theme then return end
                        _selOverride = tostring(v)
                        _newSpellID = tostring(v)
                        _newSpellTheme = theme
                        Notify()
                    end,
                },
                previewBtn = {
                    type = "execute", order = 11, width = "normal", name = "Preview",
                    disabled = function() return not GetSpellOverrideTheme(_selOverride) end,
                    func = function()
                        local theme = GetSpellOverrideTheme(_selOverride)
                        if theme then PreviewSchool(theme) end
                    end,
                },
                removeBtn = {
                    type = "execute", order = 12, width = "normal", name = "Remove",
                    disabled = function() return not GetSpellOverrideTheme(_selOverride) end,
                    confirm = true,
                    confirmText = "Remove the selected spell override?",
                    func = function()
                        if _selOverride and OCBSpellOverrides then
                            OCBSpellOverrides.Remove(tonumber(_selOverride))
                            _newSpellID = ""
                            _newSpellTheme = "neutral"
                            _selOverride = nil
                            Notify()
                        end
                    end,
                },
                clearAllBtn = {
                    type = "execute", order = 13, width = "normal", name = "Clear all overrides",
                    disabled = function() return CountTableEntries(SpellOverrides()) == 0 end,
                    confirm = true,
                    confirmText = "Remove every saved spell ID override? School mappings will be kept.",
                    func = function()
                        if OCBSpellOverrides and OCBSpellOverrides.Clear then
                            OCBSpellOverrides.Clear()
                            _newSpellID = ""
                            _newSpellTheme = "neutral"
                            _selOverride = nil
                            Notify()
                        end
                    end,
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

function SCB.Options:Create()
    AceConfig         = LibStub("AceConfig-3.0")
    AceConfigDialog   = LibStub("AceConfigDialog-3.0")
    AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

    AceConfig:RegisterOptionsTable(APP, BuildOptions())
    AceConfigDialog:SetDefaultSize(APP, 720, 580)

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
            AceConfigDialog:Open(APP)
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
        AceConfigDialog:Open(APP)
    end
end
