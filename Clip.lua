-- ============================================================
--  Opulent Casting Bars — Clip.lua
--  ScrollFrame-based progressive clip for WoW 3.3.5a.
--
--  Native mask textures don't exist on 3.3.5a. Compat.lua emulates
--  them but can only do a simple left→right reveal on a full-width,
--  NON-animated fill. It fails for the FX overlays these styles use:
--    · textures narrower than half the bar are left unclipped, and
--    · its reveal overwrites SetTexCoord, so any overlay that animates
--      its own texcoords (a rotating vortex, a scrolling rune fill)
--      fights the reveal and ends up showing fully / in the wrong place.
--
--  A ScrollFrame DOES clip its scroll child on 3.3.5a, so this helper
--  wraps an animated overlay in a ScrollFrame "window" that grows
--  left→right with cast progress. The overlay keeps its own texcoord
--  animation; the window does the clipping.
--
--  Anchor the window INSET to the fill region so it never reaches the
--  ornate border — that way its draw order (above the border) doesn't
--  matter visually and we avoid restructuring the bar's frame layers.
-- ============================================================

SCB.Clip = SCB.Clip or {}
local ClipMT = { __index = SCB.Clip }

-- Create a clip strip. `parent` is the frame it lives in (draw order
-- follows the parent's frame level). Returns a strip object.
function SCB.Clip:New(parent)
    local host  = CreateFrame("ScrollFrame", nil, parent or UIParent)
    local child = CreateFrame("Frame", nil, host)
    child:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
    host:SetScrollChild(child)
    host:Hide()
    return setmetatable({ host = host, child = child, _w = 0, _h = 0 }, ClipMT)
end

-- The frame to parent your (animated) overlay textures into. It spans
-- the whole fill region, so anchor overlays relative to it (e.g. CENTER
-- for a swirl) and they'll sit in a stable coordinate space.
function SCB.Clip:GetChild() return self.child end

-- Position/size the window over the bar's fill region and reveal
-- `revealFrac` (0..1) of it, left→right. Everything is frame-relative
-- to `bar`, so it's immune to the bar's scale (unlike screen anchors).
--   fillLeftPx : left edge of the fill, in bar-local px from bar's LEFT
--   fillW      : fill region width in px
--   yOff       : vertical offset from bar's vertical centre (px)
--   fillH      : window height in px
function SCB.Clip:Layout(bar, fillLeftPx, fillW, yOff, fillH, revealFrac)
    fillW = math.max(1, fillW or 1)
    fillH = math.max(1, fillH or 1)
    revealFrac = math.max(0, math.min(revealFrac or 0, 1))
    local revealW = math.max(1, fillW * revealFrac)

    -- Scroll child spans the FULL fill region (stable coords); the host
    -- window clips to [0, revealW].
    if self._w ~= fillW or self._h ~= fillH then
        self.child:SetSize(fillW, fillH)
        self._w, self._h = fillW, fillH
    end
    self.host:ClearAllPoints()
    self.host:SetPoint("LEFT", bar, "LEFT", fillLeftPx or 0, yOff or 0)
    self.host:SetSize(revealW, fillH)
    self.host:SetHorizontalScroll(0)
    self.host:SetVerticalScroll(0)
    self.host:Show()
end

function SCB.Clip:SetFrameLevel(lvl) self.host:SetFrameLevel(lvl) end
function SCB.Clip:Show() self.host:Show() end
function SCB.Clip:Hide() self.host:Hide() end
