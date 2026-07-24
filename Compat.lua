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

-- Detect whether native mask textures actually work on this client.
local nativeCreate = frameIndex.CreateMaskTexture
if nativeCreate then
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
-- mid-layout. The masked textures keep a stable 2-point anchor (no
-- ClearAllPoints churn) to avoid flicker / full-size flashes.
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
			if revealR <= revealL then
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
		-- Only reveal-clip textures that span (roughly) the whole
		-- bar; small decorative textures are left as-is.
		local mode = "skip"
		if frameW <= 0 or texW <= 0 or texW >= frameW * 0.5 then
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
