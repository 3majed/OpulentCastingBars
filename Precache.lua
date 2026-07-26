-- ============================================================
--  Opulent Casting Bars — Precache.lua
--
--  Warms the addon's HD textures into VRAM a short moment after
--  login, spread over many frames, so the first cast of a heavy
--  school (Fire, Inferno, Lava, …) doesn't stutter while the
--  client streams the uncompressed .tga files on demand.
--
--  How it works: a texture is only uploaded to VRAM the first time
--  it is actually *rendered*.  We render every school texture once
--  on a hidden, near-invisible 1×1 warmer — a few per frame — so
--  the upload cost is paid up-front and evenly instead of all at
--  once on the first real cast.
-- ============================================================

SCB.Precache = {}

-- How many textures to upload per frame.  Small = smoother warming
-- (each frame only pays for a couple of uploads) at the cost of a
-- slightly longer total warm-up.
local BATCH_PER_FRAME = 3

function SCB.Precache:Start()
    if self._started then return end
    self._started = true
    if not (SCB.Schools and SCB.Schools.data) then return end

    local base = SCB.TEX_PATH
    if not base then return end

    -- ── 1) Collect every unique OCB texture path in the school data ──
    -- Recursive walk: schools store texture paths in many differently
    -- named fields (bg, fill, frame, frames[], bgRed, contours[],
    -- fillEffects[], particles[], rocks[], …), so we just gather any
    -- string that points into our own texture folder.
    local seen, list = {}, {}
    local function collect(v)
        local t = type(v)
        if t == "string" then
            if not seen[v] and v:find(base, 1, true) then
                seen[v] = true
                list[#list + 1] = v
            end
        elseif t == "table" then
            for _, vv in pairs(v) do collect(vv) end
        end
    end
    collect(SCB.Schools.data)
    if #list == 0 then return end

    -- Warm the default school's textures first, so the most likely
    -- first cast is already resident even if warming is still running.
    local ds = SCB.Config and SCB.Config:Get("defaultSchool")
    if ds and ds ~= "" then
        local tag = "\\" .. ds .. "\\"
        table.sort(list, function(a, b)
            local pa = a:find(tag, 1, true) and 0 or 1
            local pb = b:find(tag, 1, true) and 0 or 1
            if pa ~= pb then return pa < pb end
            return a < b
        end)
    end

    -- ── 2) Hidden, near-invisible warmer frame + texture pool ──
    local warmer = CreateFrame("Frame", nil, UIParent)
    warmer:SetFrameStrata("BACKGROUND")
    warmer:SetSize(1, 1)
    warmer:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    warmer:SetAlpha(0.004)   -- > 0 so children truly render, but imperceptible

    local pool = {}
    for i = 1, BATCH_PER_FRAME do
        local tex = warmer:CreateTexture(nil, "ARTWORK")
        tex:SetSize(1, 1)
        tex:SetPoint("BOTTOMLEFT", warmer, "BOTTOMLEFT", 0, 0)
        tex:Hide()
        pool[i] = tex
    end

    -- ── 3) Upload a few textures per frame ──
    -- Each batch is rendered for one frame (which performs the VRAM
    -- upload) then hidden on the next, keeping every frame cheap.
    local idx = 0
    warmer:SetScript("OnUpdate", function(self)
        for i = 1, BATCH_PER_FRAME do pool[i]:Hide() end
        if idx >= #list then
            self:SetScript("OnUpdate", nil)
            self:Hide()
            SCB.Precache._done = true
            return
        end
        for i = 1, BATCH_PER_FRAME do
            if idx >= #list then break end
            idx = idx + 1
            pool[i]:SetTexture(list[idx])
            pool[i]:Show()
        end
    end)
end
