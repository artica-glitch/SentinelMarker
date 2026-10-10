-- The TOC is the single source of truth for UI and version-check addons.
local addonName = ...
SentinelMarkerInfo = {
    name = addonName,
    title = "Sentinel Marker",
    version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "unknown",
}

SentinelMarkerInfo.displayName = SentinelMarkerInfo.title .. " " .. SentinelMarkerInfo.version
SentinelMarkerInfo.icon = "Interface\\AddOns\\" .. addonName .. "\\Media\\Logo"
