local L = SentinelMarkerL
-- Experimental supported-API probe; never unwrap secret values or retry a blocked call.
local addonName = ...
local ENCOUNTER, SPELL = 3445, 1284590
local messages = {"{rt6} 1 {rt6}", "{rt4} 2 {rt4}", "{rt7} 3 {rt7}"}
local enabled, active, stopped = false, false, false
local status = L.WAIT
local lastStack, lastAttempt, attempts = nil, -100, 0
local elapsed = 0
local function Secret(value)
    return issecretvalue and issecretvalue(value)
end
local function Info(text)
    print("|cff3399ffSentinel Marker " .. L.AUTO .. ":|r " .. text)
end
local function Stop(reason)
    if stopped then return end
    stopped = true
    status = reason
    Info(reason .. " " .. L.STOP)
end
local function Check()
    if not enabled or not active or stopped then return end
    if not C_UnitAuras or not C_UnitAuras.GetPlayerAuraBySpellID then
        Stop(L.API); return
    end
    local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, SPELL)
    if not ok then Stop(L.AURA_DENIED); return end
    if stopped then return end
    if Secret(aura) then Stop(L.SECRET_AURA); return end
    if aura == nil then
        lastStack = nil
        status = L.ABSENT
        return
    end
    -- Access can itself be rejected for a protected structure.
    local readOK, stack = pcall(function() return aura.applications end)
    if not readOK then Stop(L.STACK_DENIED); return end
    if Secret(stack) then Stop(L.SECRET_STACK); return end
    if type(stack) ~= "number" then status = L.NO_STACK; return end
    if stack ~= 1 and stack ~= 2 and stack ~= 3 then
        lastStack = nil
        status = L.OTHER_STACK
        return
    end
    if stack == lastStack then return end
    -- Rate cap. No repeating an unchanged stack, no queue of stale numbers.
    local now = GetTime()
    if now - lastAttempt < 5 then return end
    local send = C_ChatInfo and C_ChatInfo.SendChatMessage
    if not send then Stop(L.CHAT_API); return end
    lastStack, lastAttempt = stack, now
    attempts = attempts + 1
    local sentOK = pcall(send, messages[stack], "YELL")
    if not sentOK then Stop(L.YELL_DENIED); return end
    if not stopped then
        status = L.DELIVERY:format(stack)
    end
end
local frame = CreateFrame("Frame")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_ACTION_BLOCKED")
frame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
frame:SetScript("OnEvent", function(_, event, arg)
    if event == "ENCOUNTER_START" then
        if Secret(arg) then Stop(L.SECRET_ID); return end
        active = arg == ENCOUNTER
        lastStack, elapsed = nil, 0
        if active and enabled and not stopped then
            status = L.SCAN
            Info(status)
        end
    elseif event == "ENCOUNTER_END" or event == "PLAYER_ENTERING_WORLD" then
        active = false
        lastStack = nil
        if not stopped then status = status .. " | " .. L.OUTSIDE end
    elseif not Secret(arg) and arg == addonName and active and enabled then
        Stop(L.BLOCKED:format(event))
    end
end)
frame:SetScript("OnUpdate", function(_, dt)
    if not enabled or not active or stopped then return end
    elapsed = elapsed + dt
    if elapsed < 0.5 then return end
    elapsed = 0
    Check()
end)
SLASH_SENTINELMARKERSAUTO1 = "/smauto"
SlashCmdList.SENTINELMARKERSAUTO = function(text)
    text = (text or ""):lower():match("^%s*(.-)%s*$")
    if text == "off" then
        enabled = false
        Info(L.OFF)
    elseif text == "on" then
        if InCombatLockdown() then Info(L.OOC); return end
        enabled, stopped = true, false
        lastStack, lastAttempt = nil, -100
        status = L.ON
        Info(status)
    else
        Info(status .. " | " .. L.STATS:format(attempts, enabled and not stopped and L.YES or L.NO))
    end
end
