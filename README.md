# Opulent Casting Bars

> **Highly visual casting bars with per‑school magic textures, particles and animations.**

![Interface](https://img.shields.io/badge/WoW-3.3.5a%20(WotLK)-blue)
![Version](https://img.shields.io/badge/version-0.1.0-green)
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
- **Theme Assignments** — map any magic school to a specific bar style, or pin one
  style for everything.
- **Advanced spell‑ID overrides** — force a specific school/style for individual spells.
- **Fully configurable text** — font, size, outline, colours and independent
  name/timer positioning.
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
| `/ocb schools` | List the available magic schools |
| `/ocb help` | Show the command help |

### Options tabs

- **General** – enable/detection mode, position, scale, strata, lock, hide Blizzard bar.
- **Appearance** – selection mode, default bar style, and the **live preview**.
- **Text** – font, size, outline, colours, and name/timer alignment & offsets.
- **Theme Assignments** – map each school → style, plus per‑spell overrides.
- **Profiles** – create / switch / copy / delete / reset profiles.
- **About** – version and command reference.

---

## 🎨 Bar styles

Automatic detection is the recommended mode, but you can also pick a fixed style for
everything. Styles bundled in this build include:

> **Neutral** · Neutral 2 · Neutral 3 · Metal · Metal Icon · Engrenages · Honey ·
> Mossy Stone · Viking · Alliance · Horde · **Aim** · **Arcane** · Arcaneum ·
> **Arctic** · **Earth** · **Felfire** · **Fire** · **Fishing** · **Frost** ·
> **Frostfire** · **Herbalism** · **Holy** · **Inferno** · **Lava** · **Mining** ·
> **Moon** · **Nature** · **Paladin** · **Sacred** · **Shadow** · **Skinning** ·
> **Thunder** · **Water**

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
