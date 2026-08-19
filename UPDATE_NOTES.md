# Update Notes

## 0.1.3 - 2026-08-19

- Fixed live spell-ID overrides on WoW 3.3.5a by resolving configured IDs against
  the localized cast name and rank when cast events do not provide a usable ID.
- Preserved exact-ID override lookup for newer or backported clients and read from
  the active profile configuration to avoid stale override tables.
- Normalized numeric and string spell-ID keys when overrides are added or removed.
- Enhanced Theme Assignments with active-state messaging and live mapping/override
  counts.
- Added an inline preview for every school mapping and changed the school editor to
  a compact two-column layout.
- Added spell icons and rank-aware names to the spell-ID editor and saved override
  list.
- Added direct editing of selected overrides plus confirmed reset, remove, and
  clear-all actions.
- Improved button and dropdown sizing and replaced an unsupported title glyph with
  the ASCII-safe `School Styles` title.
- Bumped and synchronized the TOC, in-game, and README versions to `0.1.3`.

## 0.1.1 - 2026-07-29

- Converted the addon art package from `.tga` textures to `.blp` textures.
- Bumped the addon version to `0.1.1` in the TOC, in-game version string, and README badge.
- Forced the 3.3.5a client down the emulated mask path when compatibility shims expose placeholder native mask APIs.
- Stabilized emulated mask clipping by managing two-point anchors, adding mask `SetSize` support, and only clipping textures whose masks are anchored to the same frame.
- Reworked bar dimension handling so configured width/height and per-school `barScale` are applied through one shared path.
- Removed the default-width lock from icon-style bars, Engrenages, and Viking so their bar art and particle containers follow the width slider.
- Refreshed initialized particle subframes when the bar is resized so active casts and preview casts redraw against the current dimensions.
- Scaled text insets and text widths from the live bar width so spell names and timers stay aligned after resizing.
- Normalized frame-light school settings to `frameLight` and routed supported themes through the generic light clipping path.
- Reset Fire and Shadow overlay alpha, texcoord, vertex color, and blend state more aggressively to prevent stale animated layers between schools.
- Changed animated Fire/Shadow contour reveals to use full-frame masks instead of the inset fill mask.
- Reworked the Frost background reveal to scale from the live bar size and sit behind the main bar art.
- Rebalanced Inferno with more flame slots, random flame layers, background light layers, smoke layers, embers, sparks, ambient particles, and outside particles.
- Reworked Inferno progress lighting to use a full-frame mask tied to cast progress.
- Improved Water circles with faster spawning, larger ring sizing, progress clipping, and UV-rotated ring rendering.
- Updated Void frame-light handling to rely on the generic frame-light path when available.
- Made Void's orbiting stones more visible with a higher count and larger stone scale.
- Updated Chaos spike sizing to use the live bar dimensions instead of saved config fallbacks.
