# Opulent Casting Bars

> **Highly visual casting bars with per‑school magic textures, particles and animations.**

![Interface](https://img.shields.io/badge/WoW-3.3.5a%20(WotLK)-blue)
![Version](https://img.shields.io/badge/version-0.1.4-green)
![Config](https://img.shields.io/badge/config-%2Focb-orange)

Opulent Casting Bars replaces the default casting bar with a fully visual experience
tied to your spell's **magic school**. Each school has its own unique frame, fill
texture, and particle system — **fire** rains embers, **frost** spreads mist,
**shadow** pulses with dark energy, **holy** glows with sacred light, and so on.

Spells are automatically detected and assigned to the right school, so the bar
changes look on the fly as you cast. Everything is configurable in‑game via `/ocb`.

> ℹ️ **This build** is a port/adaptation maintained for **World of Warcraft 3.3.5a
> (Wrath of the Lich King, Interface 30300)**. See [Credits](#credits) — the original
> addon and all of its beautiful art are by **SimonPdv**.

---

## 📸 Preview

| Mage schools | Monk (Chi‑Ji / Fists) & Water |
| :---: | :---: |
| ![Mage bars](https://media.forgecdn.net/attachments/1586/203/mages-ezgif-com-optimize-1-gif.gif) | ![Chi-Ji, Fists, Water](https://media.forgecdn.net/attachments/1586/665/chijifistswater-ezgif-com-optimize-gif.gif) |

| Gathering (Herbalism / Fishing) | Viking & Moon |
| :---: | :---: |
| ![Herbalism & Fishing](https://media.forgecdn.net/attachments/1560/384/herbalism-fishing-gif.gif) | ![Viking & Moon](https://media.forgecdn.net/attachments/1575/439/vikingmoon-ezgif-com-speed-gif.gif) |

| Horde & Alliance | Skinning / Void |
| :---: | :---: |
| ![Horde & Alliance](https://media.forgecdn.net/attachments/1560/385/horde-alliance-gif.gif) | ![Skinning & Void](https://media.forgecdn.net/attachments/1575/442/skinningvoid-ezgif-com-speed-gif.gif) |

*More screenshots on the [CurseForge gallery](https://www.curseforge.com/wow/addons/opulent-casting-bars/gallery).*

---

## ✨ Features

- **Per‑school casting bars** — a unique frame, fill and particle effect for every
  magic school (Fire, Frost, Shadow, Holy, Nature, Arcane, and many more).
- **Automatic school detection** — the bar picks the right style from the spell you
  cast; falls back to a configurable default when the school is unknown.
- **Live preview** — the Appearance tab shows the selected bar casting on a loop so
  you can see the exact look (particles included) before you commit.
- **Font picker with live previews** — powered by LibSharedMedia; every font in the
  dropdown is rendered in its own typeface (bundled custom fonts included).
- **Profiles** — familiar AceDB‑style profile manager: create, switch, **Copy From**,
  delete and reset. Each character remembers its own selection.
- **Theme Assignments** — map and preview schools in a compact two-column editor,
  or pin one style for everything.
- **Advanced spell‑ID overrides** — resolve spell icons and ranks by ID, then add,
  edit, preview, remove, or clear individual overrides.
- **Fully configurable text** — font, size, outline, colours and independent
  name/timer positioning. The **School** colour option gives every style its own
  matching text colour.
- **Spell‑icon styles** — Metal Icon, Honey, Mossy Stone, Viking and Engrenages show
  the icon of the spell being cast in a socket on the bar.
- **Resizable** — scale and width sliders; icons, runes and other socketed art follow
  the bar width.
- **Casts and channels** — cast bars fill, channelled spells drain, and pushback,
  interrupts and completed casts each get their own feedback.
- **Lightweight & standalone** — no external addon dependencies required.

---

## 📦 Installation

1. Download / copy the **`OpulentCastingBars`** folder.
2. Place it in your WoW directory under:
   ```
   World of Warcraft\Interface\AddOns\OpulentCastingBars
   ```
3. Make sure the folder name is exactly `OpulentCastingBars` (no version suffix).
4. Restart the game or type `/reload`, and enable it on the character‑select AddOns list.

---

## 🎮 Usage

Open the configuration window with:

```
/ocb
```

### Slash commands

| Command | Description |
| --- | --- |
| `/ocb` | Open the options window |
| `/ocb test [school] [seconds]` | Preview a cast (e.g. `/ocb test fire 5`) |
| `/ocb stop` | Stop the current test cast |
| `/ocb lock` / `/ocb unlock` | Lock or unlock the bar (unlock to drag‑move it) |
| `/ocb schools` | List every available style and the name to use with `/ocb test` |
| `/ocb debug` | Toggle debug output (prints cast events to chat) |
| `/ocb help` | Show the command help |

### Options tabs

- **General** – enable/detection mode, position, scale, width, strata, lock, hide Blizzard bar.
- **Appearance** – selection mode, default bar style, and the **live preview**.
- **Text** – font, size, outline, colours, and name/timer alignment & offsets.
- **Theme Assignments** – map and preview each school to a style, with rank-aware
  per-spell override editing and safe reset controls.
- **Profiles** – create / switch / copy / delete / reset profiles.
- **About** – version and command reference.

---

## 🎨 Bar styles

Automatic detection is the recommended mode, but you can also pick a fixed style for
everything. This build bundles **41 styles**:

| Group | Styles |
| --- | --- |
| Magic schools | Arcane · Arcaneum · Arctic · Chaos · Earth · Felfire · Fire · Frost · Frostfire · Holy · Inferno · Lava · Moon · Nature · Paladin · Sacred · Shadow · Thunder · Void · Water |
| Class themes | Aim · Bronze · Chi'ji · Fists of Fury · Mistweaver |
| Professions | Fishing · Herbalism · Mining · Skinning |
| Neutral & faction | Neutral · Neutral 2 · Neutral 3 · Metal · Mossy Stone · Alliance · Horde |
| With spell icon | Metal Icon · Honey · Mossy Stone (icon) · Viking · Engrenages |

Run `/ocb schools` in‑game for the exact name each style uses with `/ocb test`.

On the full (multi‑version) release the art set covers **39+ casting bars** across
the classes — Mages, Warlocks, Druids, Monks, Shaman, Evokers, Hunters, Demon
Hunters, Priests, Paladins, faction/neutral bars and the gathering professions.

---

## 🙏 Credits

**Original addon, concept and all artwork by [SimonPdv](https://www.curseforge.com/members/simonpdv).**
All the frames, fill textures and particle effects that make this addon shine are
his work — please support the original project:

- 🌐 **CurseForge:** https://www.curseforge.com/wow/addons/opulent-casting-bars
- 👤 **Author profile:** https://www.curseforge.com/members/simonpdv
- ☕ **Donate / support:** https://ko-fi.com/spadawan

This **3.3.5a (WotLK) port** — API compatibility shims, the Ace3 configuration UI,
the LibSharedMedia font picker, the profile system and the live preview — is
adapted and maintained by **Majed**.

Built with the excellent **Ace3** libraries and **LibSharedMedia‑3.0**.

---

## 📄 License

Please respect the original author's terms on the
[CurseForge project page](https://www.curseforge.com/wow/addons/opulent-casting-bars).
This port is distributed for use on 3.3.5a private/legacy clients and is **not**
affiliated with or endorsed by SimonPdv or CurseForge/Overwolf.
