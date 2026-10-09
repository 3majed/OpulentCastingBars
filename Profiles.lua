-- ============================================================
--  Opulent Casting Bars — Profiles.lua
--
--  Lightweight profile system built on the raw SavedVariables.
--  Profile data is shared across all characters (OpulentCastingBarsDB);
--  which profile is active is stored per-character (OpulentCastingBarsCharDB)
--  so each character remembers their own selection independently.
--
--  OpulentCastingBarsDB:
--    __profiles = {
--        ["Default"]    = { main={...}, modules={...} },
--        ["My Layout"]  = { main={...}, modules={...} },
--    }
--    __activeProfiles = {
--        ["Character-Realm"] = "ProfileName",
--    }
--
--  OpulentCastingBarsCharDB (per-character):
--    __currentProfile  = "Default"
--
--  "modules" captures the settings of any installed OCB modules
--  (Instant Cast, Spell Overrides, Unit Frame Cast Bars).
--
--  The profile UI itself lives in Options.lua (Profiles tab).
--  Call Init() after SCB.Config:Init().
-- ============================================================

SCB.Profiles = {}

-- ── storage keys ────────────────────────────────────────────
local PROFILE_KEY    = "__currentProfile"
local PROFILES_KEY   = "__profiles"
local ACTIVE_MAP_KEY = "__activeProfiles"
local DEFAULT        = "Default"

-- ── OCBInstantCastDB flat keys (overrides table copied separately)
local IC_KEYS = { "enabled", "disableWhileMounted", "disableWhileDruidFlightForm" }

-- ── OCBUnitFrameCastBarsDB keys (mirrors DEFAULT_CFG in that module)
-- Also includes per-unit override keys (targetScale, etc.) which are not
-- in DEFAULT_CFG but are set as overrides and cleared by Reset().
local UF_KEYS = {
    "enabled", "scale", "barWidth", "barHeight",
    "targetEnabled", "focusEnabled", "bossEnabled",
    "targetPos", "focusPos", "boss1Pos", "boss2Pos", "boss3Pos", "boss4Pos", "boss5Pos",
    "hideBlizzTarget", "hideBlizzFocus",
    "targetShowFriendly", "targetShowHostile", "focusShowFriendly", "focusShowHostile",
    "showSpellName", "showCastTime", "showShield", "defaultSchool",
    "textFont", "textNameSize", "textNameAnchor", "textNameX", "textNameY",
    "textTimerSize", "textTimerAnchor", "textTimerX", "textTimerY",
    "textOutline", "textShadow",
    "textNameColor", "textTimerColor",
    "textNameColorCustomR", "textNameColorCustomG", "textNameColorCustomB",
    "textTimerColorCustomR", "textTimerColorCustomG", "textTimerColorCustomB",
    -- Per-unit overrides (may be nil; captured when set, cleared on apply when absent)
    "targetScale", "focusScale", "bossScale",
    "targetWidth", "focusWidth", "bossWidth",
}

-- ── helpers ──────────────────────────────────────────────────
local function DeepCopy(t)
    if type(t) ~= "table" then return t end
    local c = {}
    for k, v in pairs(t) do c[k] = DeepCopy(v) end
    return c
end

-- ── snapshot: read live settings into a plain table ──────────
-- DeepCopy is used for every value so that table-typed settings
-- (e.g. textCustomColor) are stored as independent copies and
-- cannot mutate each other across profile slots.
local function SnapMain()
    local s = {}
    for k in pairs(SCB.Config.defaults) do s[k] = DeepCopy(SCB.Config:Get(k)) end
    return s
end

local function SnapModules()
    local m = {}
    if OCBInstantCastDB then
        local ic = {}
        for _, k in ipairs(IC_KEYS) do ic[k] = OCBInstantCastDB[k] end
        -- overrides may be nil on first-run (seeded by the module's own PLAYER_LOGIN
        -- which fires after ours); fall back to an empty table instead of nil.
        ic.overrides = DeepCopy(OCBInstantCastDB.overrides) or {}
        m.instantcast = ic
    end
    if OCBUnitFrameCastBarsDB then
        local uf = {}
        for _, k in ipairs(UF_KEYS) do uf[k] = OCBUnitFrameCastBarsDB[k] end
        m.unitframes = uf
    end
    return m
end

-- ── apply: push a snapshot into the live DB / modules ────────
local function ApplyLive()
    SCB.Bar:Resize(SCB.Config:Get("barWidth"), SCB.Config:Get("barHeight"))
    SCB.Bar.frame:SetScale(SCB.Config:Get("scale"))
    SCB.Bar.frame:ClearAllPoints()
    SCB.Bar.frame:SetPoint(
        SCB.Config:Get("anchor"), UIParent, SCB.Config:Get("anchor"),
        SCB.Config:Get("x"), SCB.Config:Get("y"))
    SCB.Bar.frame:EnableMouse(not SCB.Config:Get("locked"))
    SCB.Bar.frame:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM")
    if SCB.Bar.frameInner then SCB.Bar.frameInner:SetFrameStrata(SCB.Config:Get("barStrata") or "MEDIUM") end
    SCB.ApplyHideBlizzardBar(SCB.Config:Get("hideBlizzardBar"))
    SCB.Bar:ApplyTextPrefs()
    -- Sync the Options panel UI widgets if they have been built already
    if SCB.Options.RefreshFromConfig then SCB.Options.RefreshFromConfig() end
end

local function ApplyMain(snap)
    if not snap then return end
    -- DeepCopy each value so restoring a profile doesn't share table
    -- references between the snapshot and the live DB.
    for k, v in pairs(snap) do SCB.Config:Set(k, DeepCopy(v)) end
    -- Back-fill keys that exist in defaults but are absent from this snapshot
    -- (profiles saved before a new key was added).  Prevents new settings from
    -- bleeding across profiles instead of resetting to their default value.
    for k, v in pairs(SCB.Config.defaults) do
        if snap[k] == nil then
            SCB.Config:Set(k, type(v) == "table" and DeepCopy(v) or v)
        end
    end
end

local function ApplyModules(mods)
    if not mods then return end
    -- Instant Cast
    if mods.instantcast and OCBInstantCastDB then
        for _, k in ipairs(IC_KEYS) do
            if mods.instantcast[k] ~= nil then OCBInstantCastDB[k] = mods.instantcast[k] end
        end
        if mods.instantcast.overrides then
            OCBInstantCastDB.overrides = DeepCopy(mods.instantcast.overrides)
        end
    end
    -- Re-sync OCBSpellOverridesDB to the table that ApplyMain just restored into config.
    if OCBSpellOverrides and OCBSpellOverrides.Sync then OCBSpellOverrides.Sync() end
    -- Unit Frame Cast Bars
    if mods.unitframes and OCBUnitFrameCastBarsDB then
        if mods.unitframes.__resetToDefaults then
            -- Blank profile: Reset() deferred to apply time (not snapshot time)
            if OCBUnitFrameCastBars and OCBUnitFrameCastBars.Reset then
                OCBUnitFrameCastBars.Reset()
            end
        else
            -- Clear per-unit overrides first so a profile that never set them
            -- doesn't carry stale values forward from a previous profile.
            OCBUnitFrameCastBarsDB.targetScale = nil
            OCBUnitFrameCastBarsDB.focusScale  = nil
            OCBUnitFrameCastBarsDB.bossScale   = nil
            OCBUnitFrameCastBarsDB.targetWidth = nil
            OCBUnitFrameCastBarsDB.focusWidth  = nil
            OCBUnitFrameCastBarsDB.bossWidth   = nil
            OCBUnitFrameCastBarsDB.bossPos     = nil  -- legacy single-key
            -- Restore snapshot values (non-nil only; nil keys were cleared above)
            for _, k in ipairs(UF_KEYS) do
                if mods.unitframes[k] ~= nil then OCBUnitFrameCastBarsDB[k] = mods.unitframes[k] end
            end
            if OCBUnitFrameCastBars and OCBUnitFrameCastBars.ApplyAllSettings then
                OCBUnitFrameCastBars.ApplyAllSettings()
            end
        end
    end
end

-- ============================================================
--  PUBLIC API
-- ============================================================

local function GetCharKey()
    local name = UnitName and UnitName("player") or "Unknown"
    local realm = GetRealmName and GetRealmName() or "UnknownRealm"
    return tostring(name) .. "-" .. tostring(realm)
end

local function ValidProfileName(name)
    return type(name) == "string" and name ~= ""
end

local function EnsureProfile(name, sourceName)
    if not ValidProfileName(name) then return end

    local db = OpulentCastingBarsDB
    if not db then return end

    db[PROFILES_KEY] = db[PROFILES_KEY] or {}
    local profiles = db[PROFILES_KEY]
    if profiles[name] then return end

    local source = ValidProfileName(sourceName) and profiles[sourceName] or nil
    source = source or profiles[DEFAULT]

    if source then
        profiles[name] = DeepCopy(source)
    else
        profiles[name] = { main = SnapMain(), modules = SnapModules() }
    end
end

local function EnsureKnownCharacterProfiles()
    local db = OpulentCastingBarsDB
    if not db then return end

    db[ACTIVE_MAP_KEY] = db[ACTIVE_MAP_KEY] or {}

    EnsureProfile(DEFAULT)

    -- Only guarantee the profiles characters are actually USING. A profile
    -- named after a character is created once, on that character's first
    -- login (see Init); re-creating it here would undo a deliberate delete.
    for _, activeProfile in pairs(db[ACTIVE_MAP_KEY]) do
        EnsureProfile(activeProfile, DEFAULT)
    end
end

local function SetCurrentProfile(name)
    OpulentCastingBarsCharDB = OpulentCastingBarsCharDB or {}
    OpulentCastingBarsCharDB[PROFILE_KEY] = name
    OpulentCastingBarsDB[ACTIVE_MAP_KEY] = OpulentCastingBarsDB[ACTIVE_MAP_KEY] or {}
    OpulentCastingBarsDB[ACTIVE_MAP_KEY][GetCharKey()] = name
end

function SCB.Profiles:Init()
    -- Shared DB: stores all profile snapshots
    local db = OpulentCastingBarsDB
    if not db[PROFILES_KEY] then db[PROFILES_KEY] = {} end
    -- Seed the Default profile from current (first-run) settings
    if not db[PROFILES_KEY][DEFAULT] then
        db[PROFILES_KEY][DEFAULT] = { main = SnapMain(), modules = SnapModules() }
    end
    db[ACTIVE_MAP_KEY] = db[ACTIVE_MAP_KEY] or {}

    -- Per-character DB: stores which profile this character uses
    OpulentCastingBarsCharDB = OpulentCastingBarsCharDB or {}

    -- Fallback: if per-character SavedVariables were reset for any reason,
    -- recover the last known profile selection from shared DB.
    -- First login on this character: give it its own profile (a copy of
    -- Default). This is the only place a character-named profile is created.
    local charKey = GetCharKey()
    if not OpulentCastingBarsCharDB[PROFILE_KEY] then
        local name = db[ACTIVE_MAP_KEY][charKey] or charKey
        OpulentCastingBarsCharDB[PROFILE_KEY] = name
        EnsureProfile(name, DEFAULT)
    end

    EnsureKnownCharacterProfiles()

    -- Apply this character's saved profile.  If the profile was deleted on
    -- another character, fall back to Default gracefully.
    local charProfile = OpulentCastingBarsCharDB[PROFILE_KEY]
    local snap = db[PROFILES_KEY][charProfile]
    if not snap then
        SetCurrentProfile(DEFAULT)
        charProfile = DEFAULT
        snap = db[PROFILES_KEY][DEFAULT]
    end
    if snap then
        SetCurrentProfile(charProfile)
        self._suspendAutosave = true
        local ok, err = pcall(function()
            ApplyMain(snap.main)
            ApplyModules(snap.modules)
            ApplyLive()
        end)
        self._suspendAutosave = nil
        if not ok then geterrorhandler()(err) end
    end
end

function SCB.Profiles:OnSettingChanged()
    if self._suspendAutosave then return end
    if not OpulentCastingBarsDB or not OpulentCastingBarsDB[PROFILES_KEY] then return end
    if not OpulentCastingBarsCharDB then return end
    self:SaveCurrent()
end

function SCB.Profiles:GetCurrent()
    return OpulentCastingBarsCharDB[PROFILE_KEY] or DEFAULT
end

function SCB.Profiles:GetAll()
    EnsureKnownCharacterProfiles()

    local list = {}
    for name in pairs(OpulentCastingBarsDB[PROFILES_KEY] or {}) do
        list[#list + 1] = name
    end
    table.sort(list, function(a, b)
        if a == DEFAULT then return true end
        if b == DEFAULT then return false end
        return a < b
    end)
    return list
end

-- Persist live settings into the currently active profile snapshot.
function SCB.Profiles:SaveCurrent()
    local name = self:GetCurrent()
    local db   = OpulentCastingBarsDB[PROFILES_KEY]
    db[name]         = db[name] or {}
    SetCurrentProfile(name)
    db[name].main    = SnapMain()
    db[name].modules = SnapModules()
end

-- Switch to an existing profile (saves current first).
function SCB.Profiles:Switch(name)
    local db = OpulentCastingBarsDB
    EnsureProfile(name, DEFAULT)
    if not db[PROFILES_KEY][name] then return false end
    self:SaveCurrent()
    local snap = db[PROFILES_KEY][name]
    SetCurrentProfile(name)
    self._suspendAutosave = true
    local ok, err = pcall(function()
        ApplyMain(snap.main)
        ApplyModules(snap.modules)
        ApplyLive()
    end)
    self._suspendAutosave = nil
    if not ok then geterrorhandler()(err) end
    return true
end

-- Builds a "fresh" modules snapshot for a blank profile:
--   • Instant Cast  : enabled, default GCD overrides only (no user entries)
--   • Spell Overrides : empty (all cleared)
--   • Unit Frame Bars : reset to module defaults via the public Reset() API
local function BlankModules()
    local m = {}
    if OCBInstantCastDB then
        m.instantcast = {
            enabled                     = true,
            disableWhileMounted         = false,
            disableWhileDruidFlightForm = false,
            -- Mirrors the DEFAULT_OVERRIDES table hardcoded in OCB_InstantCast.lua
            overrides = {
                [188196] = { base = 1.5 },  -- Lightning Bolt (Shaman)
                [768]    = { base = 1.0 },  -- Cat Form (Druid)
                [452201] = { base = 1.5 },  -- Tempest (Shaman)
            },
        }
    end
    if OCBSpellOverridesDB then
        m.spelloverride = {}  -- clears every user override on apply
    end
    if OCBUnitFrameCastBarsDB then
        -- Store a sentinel so ApplyModules calls Reset() at apply time.
        -- This avoids mutating live UF state during profile creation/snapshot.
        m.unitframes = { __resetToDefaults = true }
    end
    return m
end

-- Create a new profile, then switch to it.
--   copyFromCurrent = true  → copy live settings
--   copyFromCurrent = false → blank: main defaults + clean module state
function SCB.Profiles:New(name, copyFromCurrent)
    local db = OpulentCastingBarsDB
    if db[PROFILES_KEY][name] then return false, "Profile already exists" end
    if copyFromCurrent then
        self:SaveCurrent()
        db[PROFILES_KEY][name] = DeepCopy(db[PROFILES_KEY][self:GetCurrent()])
    else
        local blank = {}
        for k, v in pairs(SCB.Config.defaults) do blank[k] = v end
        -- BlankModules() stores a sentinel for UF; ApplyModules (called below)
        -- defers the actual UF Reset() to apply time, keeping live state clean.
        db[PROFILES_KEY][name] = { main = blank, modules = BlankModules() }
    end
    SetCurrentProfile(name)
    self._suspendAutosave = true
    local ok, err = pcall(function()
        ApplyMain(db[PROFILES_KEY][name].main)
        ApplyModules(db[PROFILES_KEY][name].modules)
        ApplyLive()
    end)
    self._suspendAutosave = nil
    if not ok then geterrorhandler()(err) end
    return true
end

-- Delete a named profile.  Switches to Default if it was active.
-- NOTE: we do NOT call Switch() here because Switch() calls SaveCurrent() first,
-- which would re-create the just-deleted profile slot.
function SCB.Profiles:Delete(name)
    if name == DEFAULT then return false, "Cannot delete the Default profile" end
    local profiles = OpulentCastingBarsDB[PROFILES_KEY]
    if not profiles[name] then return false, "Profile not found" end
    profiles[name] = nil
    local activeMap = OpulentCastingBarsDB[ACTIVE_MAP_KEY]
    if activeMap then
        activeMap[name] = nil
        for charKey, profileName in pairs(activeMap) do
            if profileName == name then activeMap[charKey] = DEFAULT end
        end
    end
    if self:GetCurrent() == name then
        -- Manually apply Default without saving to the now-gone profile.
        local snap = profiles[DEFAULT]
        SetCurrentProfile(DEFAULT)
        if snap then
            self._suspendAutosave = true
            local ok, err = pcall(function()
                ApplyMain(snap.main)
                ApplyModules(snap.modules)
                ApplyLive()
            end)
            self._suspendAutosave = nil
            if not ok then geterrorhandler()(err) end
        end
    end
    return true
end

-- Reset a profile to addon defaults (current profile if name omitted).
function SCB.Profiles:Reset(name)
    name = name or self:GetCurrent()
    local blank = {}
    for k, v in pairs(SCB.Config.defaults) do blank[k] = v end
    local blankMods = BlankModules()  -- resets IC, SpellOverrides, and UF (via sentinel)
    OpulentCastingBarsDB[PROFILES_KEY][name] = { main = blank, modules = blankMods }
    if self:GetCurrent() == name then
        self._suspendAutosave = true
        local ok, err = pcall(function()
            ApplyMain(blank)
            ApplyModules(blankMods)
            ApplyLive()
        end)
        self._suspendAutosave = nil
        if not ok then geterrorhandler()(err) end
    end
end

-- Copy the settings FROM another existing profile INTO the current profile.
-- Mirrors AceDB's CopyProfile: the active profile stays active, but its stored
-- data is replaced by a copy of the source, then applied live.
function SCB.Profiles:Copy(sourceName)
    local db = OpulentCastingBarsDB[PROFILES_KEY]
    if not db then return false, "No profiles" end
    local current = self:GetCurrent()
    if not sourceName or sourceName == current then
        return false, "Choose a different profile to copy from"
    end
    local src = db[sourceName]
    if not src then return false, "Source profile not found" end

    db[current] = DeepCopy(src)
    self._suspendAutosave = true
    local ok, err = pcall(function()
        ApplyMain(db[current].main)
        ApplyModules(db[current].modules)
        ApplyLive()
    end)
    self._suspendAutosave = nil
    if not ok then geterrorhandler()(err) end
    return true
end
