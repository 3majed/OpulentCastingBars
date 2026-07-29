-- ============================================================
--  Opulent Casting Bars — Compat.lua
--  MaskTexture polyfill for clients without a working
--  CreateMaskTexture / AddMaskTexture (e.g. WotLK 3.3.5a).
--
--  The addon reveals its fill / light layers progressively by
--  growing a mask's width (left→right or right→left). Real mask
--  textures only exist on Legion+ clients, so here we emulate
--  the horizontal reveal with SetTexCoord + geometry. Full-width
--  layers are clipped to the revealed band; small decorative
--  textures (icons, runes) are left untouched.
-- ============================================================

local frameMeta  = getmetatable(UIParent)
local frameIndex = frameMeta and frameMeta.__index
local probe      = UIParent:CreateTexture()
local texMeta    = getmetatable(probe)
local texIndex   = texMeta and texMeta.__index
if probe.Hide then probe:Hide() end

-- If we cannot reach the shared widget method tables, bail out
-- quietly rather than risk breaking anything.
if type(frameIndex) ~= "table" or type(texIndex) ~= "table" then
	return
end

-- ============================================================
--  API shims for raw WotLK 3.3.5a (when the ClassicAPI compat
--  addon is absent). Independent of the mask emulation below,
--  so they run before the mask-specific early return. Each is
--  guarded so we never override a client that already has them.
-- ============================================================

-- FontString shared method table (SetShown is used on font strings).
local fsProbe = UIParent:CreateFontString(nil, "BACKGROUND")
local fsMeta  = getmetatable(fsProbe)
local fsIndex = fsMeta and fsMeta.__index
if fsProbe.Hide then fsProbe:Hide() end

-- Region:SetShown(shown) -- added in Cataclysm (4.0). Emulate with Show/Hide.
local function scbSetShown(self, shown)
	if shown then self:Show() else self:Hide() end
end
if not frameIndex.SetShown then frameIndex.SetShown = scbSetShown end
if not texIndex.SetShown then texIndex.SetShown = scbSetShown end
if type(fsIndex) == "table" and not fsIndex.SetShown then fsIndex.SetShown = scbSetShown end

-- Texture:SetColorTexture(r,g,b,a) -- added in Legion (7.0). On 3.3.5a the
-- classic form SetTexture(r,g,b,a) paints a solid colour instead.
if not texIndex.SetColorTexture then
	texIndex.SetColorTexture = function(self, r, g, b, a)
		return texIndex.SetTexture(self, r, g, b, a == nil and 1 or a)
	end
end

-- Button/EditBox:SetEnabled(enabled) -- added in Cataclysm (4.0). On 3.3.5a
-- buttons use Enable()/Disable(); edit boxes toggle keyboard/mouse instead.
local function scbSetEnabled(self, enabled)
	enabled = enabled and true or false
	if self.Enable and self.Disable then
		if enabled then self:Enable() else self:Disable() end
	elseif self.EnableKeyboard then          -- EditBox-style widgets
		self:EnableKeyboard(enabled)
		if self.EnableMouse then self:EnableMouse(enabled) end
		if not enabled and self.ClearFocus then self:ClearFocus() end
	elseif self.EnableMouse then
		self:EnableMouse(enabled)
	end
end
do
	local btnProbe = CreateFrame("Button")
	local btnIndex = getmetatable(btnProbe) and getmetatable(btnProbe).__index
	if type(btnIndex) == "table" and not btnIndex.SetEnabled then btnIndex.SetEnabled = scbSetEnabled end
	if btnProbe.Hide then btnProbe:Hide() end

	local ebProbe = CreateFrame("EditBox")
	local ebIndex = getmetatable(ebProbe) and getmetatable(ebProbe).__index
	if type(ebIndex) == "table" and not ebIndex.SetEnabled then ebIndex.SetEnabled = scbSetEnabled end
	if ebProbe.Hide then ebProbe:Hide() end
end
if not frameIndex.SetEnabled then frameIndex.SetEnabled = scbSetEnabled end

-- C_Timer.After(delay, func) -- added in MoP (5.0). OnUpdate-driven shim.
if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then
	C_Timer = C_Timer or {}
	local pending = {}
	local driver  = CreateFrame("Frame")
	driver:SetScript("OnUpdate", function()
		local n = #pending
		if n == 0 then return end
		local now = GetTime()
		local i = 1
		while i <= n do
			local t = pending[i]
			if now >= t.at then
				pending[i] = pending[n]
				pending[n] = nil
				n = n - 1
				pcall(t.func)
			else
				i = i + 1
			end
		end
	end)
	function C_Timer.After(delay, func)
		if type(func) ~= "function" then return end
		pending[#pending + 1] = { at = GetTime() + (tonumber(delay) or 0), func = func }
	end
end

-- Detect whether native mask textures actually work on this client. WotLK
-- compatibility addons may expose placeholder MaskTexture methods, but the
-- 3.3.5 client cannot render native masks, so force the emulated path there.
local _, _, _, buildInfo = GetBuildInfo()
local interfaceVersion = tonumber(buildInfo)
local forceMaskEmulation = (not interfaceVersion) or interfaceVersion < 70000
local nativeCreate = frameIndex.CreateMaskTexture
if nativeCreate and not forceMaskEmulation then
	local ok, nativeMask = pcall(nativeCreate, UIParent)
	if ok and nativeMask then
		if nativeMask.Hide then nativeMask:Hide() end
		return -- native masks are functional; no polyfill needed
	end
end

-- ---- Raw Texture geometry methods (never overridden) -------
local Tex_SetWidth       = texIndex.SetWidth
local Tex_SetHeight      = texIndex.SetHeight
local Tex_SetPoint       = texIndex.SetPoint
local Tex_ClearAllPoints = texIndex.ClearAllPoints
local Tex_SetAllPoints   = texIndex.SetAllPoints
local Tex_SetTexCoord    = texIndex.SetTexCoord
local Tex_GetWidth       = texIndex.GetWidth
local Tex_GetPoint       = texIndex.GetPoint
local nativeAddMask      = texIndex.AddMaskTexture
local nativeRemoveMask   = texIndex.RemoveMaskTexture

-- Re-apply the horizontal reveal for every texture a mask covers.
-- Geometry is derived from the mask's width + anchor offset (NOT screen
-- coordinates), so it stays correct even while the bar is still hidden or
-- mid-layout. The masked textures are converted once from SetAllPoints-style
-- full anchors to a managed 2-point anchor; later updates only move those
-- two points.
local function ReclipMask(mask)
	local frame = mask.__scbFrame
	if not frame then return end

	local frameW = frame:GetWidth()
	if not frameW or frameW <= 0 then return end

	local maskW = Tex_GetWidth(mask) or 0
	local point, _, _, xOff = Tex_GetPoint(mask, 1)
	if not point then return end
	xOff = xOff or 0

	-- Reveal band [revealL, revealR] in frame-local x (0 = frame's left edge).
	local revealL, revealR
	if point == "TOPRIGHT" or point == "BOTTOMRIGHT" or point == "RIGHT" then
		revealR = frameW + xOff      -- right-anchored (xOff is negative)
		revealL = revealR - maskW
	else
		revealL = xOff               -- left-anchored
		revealR = xOff + maskW
	end
	if revealL < 0 then revealL = 0 end
	if revealR > frameW then revealR = frameW end

	for tex, mode in pairs(mask.__scbMasked) do
		if mode == "fill" then
			if not tex.__scbClipManaged then
				Tex_ClearAllPoints(tex)
				tex.__scbClipManaged = true
			end
			if revealR <= revealL then
				Tex_SetPoint(tex, "TOPLEFT",     frame, "TOPLEFT", revealL, 0)
				Tex_SetPoint(tex, "BOTTOMRIGHT", frame, "BOTTOMLEFT", revealL, 0)
				Tex_SetTexCoord(tex, 0, 0, 0, 0) -- reveal nothing
			else
				Tex_SetPoint(tex, "TOPLEFT",     frame, "TOPLEFT",    revealL, 0)
				Tex_SetPoint(tex, "BOTTOMRIGHT", frame, "BOTTOMLEFT", revealR, 0)
				Tex_SetTexCoord(tex, revealL / frameW, revealR / frameW, 0, 1)
			end
		end
	end
end

-- ---- Override: create an emulated mask texture -------------
frameIndex.CreateMaskTexture = function(self, name, layer)
	local mask = self:CreateTexture(name, layer or "ARTWORK")
	mask:SetAlpha(0) -- invisible; used only as a geometry driver

	mask.__scbFakeMask = true
	mask.__scbFrame    = self
	mask.__scbMasked   = {}

	-- Re-clip whenever the mask's geometry changes.
	mask.SetWidth = function(s, w)
		Tex_SetWidth(s, w)
		ReclipMask(s)
	end
	mask.SetHeight = function(s, h)
		Tex_SetHeight(s, h)
	end
	mask.SetSize = function(s, w, h)
		Tex_SetWidth(s, w)
		Tex_SetHeight(s, h)
		ReclipMask(s)
	end
	mask.SetPoint = function(s, ...)
		Tex_SetPoint(s, ...)
		ReclipMask(s)
	end
	mask.SetAllPoints = function(s, ...)
		Tex_SetAllPoints(s, ...)
		ReclipMask(s)
	end
	mask.ClearAllPoints = function(s)
		Tex_ClearAllPoints(s)
	end
	-- Real masks accept special wrap/filter modes that a plain
	-- texture would reject; swallow SetTexture on emulated masks.
	mask.SetTexture = function() end

	return mask
end

-- ---- Override: register a texture with an emulated mask -----
texIndex.AddMaskTexture = function(self, mask)
	if mask and mask.__scbFakeMask then
		local frame  = mask.__scbFrame
		local frameW = (frame and frame:GetWidth()) or 0
		local texW   = self:GetWidth() or 0
		local _, relTo = Tex_GetPoint(mask, 1)
		-- Only reveal-clip textures that span (roughly) the whole
		-- bar and whose mask is anchored to that bar. Screen-space or
		-- vertical/decorative masks cannot be emulated with this fallback.
		local mode = "skip"
		if relTo == frame and (frameW <= 0 or texW <= 0 or texW >= frameW * 0.5) then
			mode = "fill"
		end
		mask.__scbMasked[self] = mode
		ReclipMask(mask)
		return
	end

	if nativeAddMask then
		return nativeAddMask(self, mask)
	end
end

texIndex.RemoveMaskTexture = function(self, mask)
	if mask and mask.__scbFakeMask then
		mask.__scbMasked[self] = nil
		return
	end

	if nativeRemoveMask then
		return nativeRemoveMask(self, mask)
	end
end
