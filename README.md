# SentinelMarker
Raid and personal debuff stack displays for World of Warcraft.

Sentinel Marker provides compact raid and personal debuff displays for the Entombed Sentinels encounter.

### Features
- Personal stack counter with a minimal square display.
- Raid list with player names, role icons, debuff icons and stack counts.
- Collapsing raid rows to avoid empty spaces when auras disappear.
- Independent visibility settings and saved positions.
- Personal counter positioning above the settings window.
- Manual announcement buttons: 1 — blue square, 2 — green triangle, 3 — red cross.
- Custom minimap icon.
- Automatic language selection based on your WoW client.
- Version metadata compatible with NSRT's addon version check.

### Languages
English, Italian, German, French, Spanish (Spain and Latin America), Brazilian Portuguese, Russian, Korean, Simplified Chinese and Traditional Chinese.

### Commands
- `/sm` — Toggle the manual announcement panel outside combat.
- `/smconfig` — Open settings.
- `/smraid` — Toggle raid-list positioning.
- `/smview` — Toggle personal-counter positioning.
- `/sm setup` — Reconnect the announcement macros.
- `/sm reset` — Reset the manual panel position.
- `/sm version` — Show the installed version.

### Important information
The native aura displays use Blizzard's HARMFUL|IMPORTANT filter. They are not restricted exclusively to Helical Toxins: another qualifying debuff may appear.

Stack rendering is handled by Blizzard's native aura containers. The addon does not read back protected stack values or automatically select an announcement button based on them.

Open the manual announcement panel before combat. Chat announcements remain subject to Blizzard's restrictions and may be blocked during encounters.

The raid list supports raid groups, not normal parties. The experimental automatic module is disabled by default.

### Installation
Extract the SentinelMarker folder into World of Warcraft's Interface/AddOns directory and restart the game.

If upgrading from an older EntombedBlue release, remove the old addon folder to avoid loading both copies.

### Version checks
In NSRT, select Addon and enter:
`SentinelMarker`

### Author and license
Artica (Acheron) — Pozzo dell’eternità

All Rights Reserved. See LICENSE.txt for permissions and terms.

### Compatibility
Designed for WoW Retail Midnight. Encounter behavior and client restrictions require in-game verification.
