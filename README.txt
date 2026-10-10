Sentinel Marker 0.8.2
Owner: Artica (Acheron) — Pozzo dell’eternità

INSTALL: Close WoW and replace Interface/AddOns/SentinelMarker. Restart WoW.
Remove the old EntombedBlue addon folder if upgrading from that name.
To migrate old settings with WoW closed, back up WTF/Account/<account>/SavedVariables/
EntombedBlue.lua and copy it to SentinelMarker.lua in that same directory.
Do this once only; do not overwrite newer settings.

The UI follows your WoW client language automatically. Supported: English,
Italian, German, French, Spanish (Spain/Latin America), Portuguese, Russian,
Korean, Simplified Chinese and Traditional Chinese. Unknown locales use English.
All in-game settings, tooltips, keybindings and diagnostic messages are localized.
Commands remain identical in every locale:
/sm: open manual marker buttons outside combat, before pulling.
/sm config or /smconfig: settings; right-click the minimap logo also opens them.
/sm version: installed version. NSRT Addon Name: SentinelMarker.
/sm setup: reconnect ESMark1/2/3 macros. /sm reset: reset manual panel position.
/smraid: position raid list. /smview: position personal counter.
/smauto: experimental diagnostic status; automatic mode is disabled by default.

Independent saved toggles and positions for the personal counter and raid list.
Native aura displays activate for encounter 3445. Blizzard renders the first
HARMFUL|IMPORTANT aura, not exclusively spell 1284590. Other important debuffs
may therefore appear. Aura graphics disappear with their aura and raid rows
use native collapsing layout. Raid units only, not party1..4.
Protected aura values are not read back from the native display. No automatic
selection of a marker or macro is based on its displayed count. Identity
updates are deferred while the client restricts access to native aura frames.
Manual macros: 1 blue square, 2 green triangle, 3 red cross. Client restrictions
on chat and protected actions still apply.

Proprietary license: see LICENSE.txt. All rights reserved, subject to the
third-party and AI-generated asset provisions in that file.
Local checks do not replace testing in the live WoW client.

0.8.2: All slash commands now begin with /sm. Language is detected each time
the addon loads. Restart the game after changing the client language.

0.8.2: Personal counter and drag handle appear above settings. The cyan
border marks the draggable area even without an aura. Click Position again
to hide the handle. Position is saved when dragging stops.
