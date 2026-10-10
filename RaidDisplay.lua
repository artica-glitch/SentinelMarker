local L = SentinelMarkerL
-- Raid aura display using Blizzard-owned application count rendering.
-- Unit tokens are bound before combat. No aura values are read by Lua.
local addonName = ...
local panel, formatter, mover
local rows = {}
local pendingRoster = false
local ready, active, preview, failed = false, false, false, false
local function Secret(v) return issecretvalue and issecretvalue(v) end
local function Info(s) print('|cff3399ffSentinel Marker:|r '..s) end
local function RefreshVisibility()
 if ready then
  mover:SetShown(SentinelDisplayEnabled("showRaid") and preview and not active)
  panel:SetShown(SentinelDisplayEnabled("showRaid") and (active or preview))
 end
end
SentinelRefreshRaid = RefreshVisibility
local function RefreshRoster()
 if not ready then return end
 if SentinelAurasRestricted() then pendingRoster=true;return end
 pendingRoster=false
 local count = IsInRaid() and GetNumGroupMembers() or 0
 if Secret(count) then pendingRoster=true;return end
 for i,row in ipairs(rows) do
  for _,parts in ipairs(row.parts) do
  if SentinelAuraFrameAccessible(parts.host) then
   local applied=pcall(function()
  -- Names are display-only, just like the numeric aura text.
  if i <= count then
   local ok,name = pcall(UnitName, 'raid'..i)
   if ok then
    if Secret(name) then parts.label:SetText(name)
    else parts.label:SetText(name or (L.RAID..' '..i)) end
   else parts.label:SetText(L.RAID..' '..i) end
  else parts.label:SetText('') end
  if not InCombatLockdown() and i <= count then
   parts.label:SetTextColor(1,1,1)
   if UnitClass and RAID_CLASS_COLORS then
    local ok,_,class=pcall(UnitClass,'raid'..i)
    if ok and not Secret(class) and type(class)=='string' then
     local color=RAID_CLASS_COLORS[class]
     if color then parts.label:SetTextColor(color.r,color.g,color.b) end
    end
   end
   parts.role:SetTexture(nil)
   if UnitGroupRolesAssigned then
    local ok,role=pcall(UnitGroupRolesAssigned,'raid'..i)
    if ok and not Secret(role) then
     local atlas=({TANK='roleicon-tiny-tank',HEALER='roleicon-tiny-healer',DAMAGER='roleicon-tiny-dps'})[role]
     if atlas then parts.role:SetAtlas(atlas) end
    end
   end
  end
   end)
   if not applied then pendingRoster=true end
  else pendingRoster=true end
  end
  -- Never change native container layout during combat.
  if not InCombatLockdown() then row:SetShown(i <= count) end
 end
 if not InCombatLockdown() then
  panel:SetHeight(math.max(1, count)*24)
 end
end
local function Initialize()
 if ready or failed or SentinelAurasRestricted() then return end
 if not C_StringUtil or not C_StringUtil.CreateNumericRuleFormatter or not AuraContainerSortMethod or not AuraContainerSortDirection then
  failed=true;Info(L.API);return
 end
 local ok=pcall(function()
  panel=CreateFrame('Frame','SentinelRaidAuraPanel',UIParent)
  panel:SetSize(320,480)
  panel:SetPoint('CENTER',UIParent,'CENTER',330,0)
  panel:SetClampedToScreen(true)
  mover=SentinelCreateNativeMover(panel,'raidPosition')
  local pos=SentinelMarkersDB and SentinelMarkersDB.raidPosition
  if type(pos)=='table' and type(pos[1])=='string' and type(pos[2])=='string' and type(pos[3])=='number' and type(pos[4])=='number' then
   panel:ClearAllPoints();panel:SetPoint(pos[1],UIParent,pos[2],pos[3],pos[4])
  end
  formatter=C_StringUtil.CreateNumericRuleFormatter()
  formatter:SetBreakpoints({{threshold=0,format=''},{threshold=1,format='%d'}})
  for i=1,40 do
   local row=CreateFrame('Frame',nil,panel)
   row:SetSize(320,22)
   row:SetPoint('TOPLEFT',panel,'TOPLEFT',0,0)
   row.parts={}
   local c=CreateFrame('AuraContainer',nil,row,'CustomAuraContainerTemplate,DisableUntrustedLayoutScriptsTemplate')
   c:SetUnit('raid'..i)
   c:AddAuraGroup('sentinelraid','HARMFUL|IMPORTANT',{
    maxFrameCount=1,sortMethod=AuraContainerSortMethod.ExpirationOnly,
    sortDirection=AuraContainerSortDirection.Normal,candidateFilters={},
    layout={elementWidth=320,elementHeight=25,elementSpacing=0,lineSpacing=0},
    initializeFrame=function(button)
     button:SetSize(320,25);button:SetCollapsesLayout(true)
     button:SetMouseClickEnabled(false);button:SetMouseMotionEnabled(false)
     -- All visible pieces belong to the native aura button. The client
     -- hides them together when its filtered aura disappears.
     local bg=button:CreateTexture(nil,'BACKGROUND')
     bg:SetPoint('TOPLEFT',button,'TOPLEFT',0,0);bg:SetSize(320,22);bg:SetColorTexture(.10,.025,.12,.88)
     local nameLayer=CreateFrame('Frame',nil,button)
     nameLayer:SetAllPoints(button);nameLayer:SetFrameLevel(button:GetFrameLevel()+20)
     local parts={host=button}
     parts.label=nameLayer:CreateFontString(nil,'OVERLAY','GameFontNormal')
     parts.label:SetPoint('LEFT',46,0);parts.label:SetWidth(234);parts.label:SetJustifyH('LEFT')
     parts.label:SetFont(STANDARD_TEXT_FONT,16,'OUTLINE')
     parts.role=nameLayer:CreateTexture(nil,'ARTWORK')
     parts.role:SetSize(15,15);parts.role:SetPoint('LEFT',27,0)
     row.parts[#row.parts+1]=parts
     local bar=CreateFrame('StatusBar',nil,button)
     bar:SetPoint('TOPLEFT',button,'TOPLEFT',24,0);bar:SetSize(296,22)
     bar:SetStatusBarTexture('Interface\\Buttons\\WHITE8X8');bar:SetStatusBarColor(.68,.08,.78,.85)
     button:SetApplicationBar(bar,{maxApplications=4,interpolation=Enum.StatusBarInterpolation.Immediate})
     local icon=button:CreateTexture(nil,'BACKGROUND');icon:SetSize(22,22);icon:SetPoint('LEFT',0,0)
     button:SetIcon(icon)
     local overlay=CreateFrame('Frame',nil,button);overlay:SetAllPoints(button);overlay:SetFrameLevel(button:GetFrameLevel()+5)
     local text=overlay:CreateFontString(nil,'OVERLAY','GameFontNormalLarge')
     text:SetFont(STANDARD_TEXT_FONT,20,'OUTLINE');text:SetPoint('RIGHT',button,'RIGHT',-3,1.5)
     button:SetApplicationCount(text,{formatter=formatter})
    end,
   })
   c:SetFlowLayoutAnchorPoint('TOPLEFT');c:SetFlowLayoutPadding(0,0,0,0);c:SetFlowLayoutMaximumLineSize(320)
   -- Native empty containers collapse to their minimal layout height.
   -- Chain the next container to that bottom edge, not to a fixed row slot.
   if i==1 then c:SetPoint('TOPLEFT',panel,'TOPLEFT',0,0)
   else c:SetPoint('TOPLEFT',rows[i-1].container,'BOTTOMLEFT',0,1) end
   c:SetEnabled(true)
   row.container=c;rows[i]=row
  end
  ready=true
 end)
 if not ok then
  failed=true;if panel then panel:Hide() end
  Info(L.INIT);return
 end
 RefreshRoster();RefreshVisibility()
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','GROUP_ROSTER_UPDATE','PLAYER_REGEN_ENABLED','ENCOUNTER_START','ENCOUNTER_END','PLAYER_ENTERING_WORLD','PLAYER_ALIVE','PLAYER_UNGHOST'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function(_,event,id)
 if event=='PLAYER_LOGIN' then Initialize()
 elseif event=='GROUP_ROSTER_UPDATE' then RefreshRoster()
 elseif event=='PLAYER_ALIVE' or event=='PLAYER_UNGHOST' then
  RefreshRoster()
 elseif event=='PLAYER_REGEN_ENABLED' then
  if not ready and not failed then Initialize() end
  RefreshRoster();RefreshVisibility()
 elseif event=='ENCOUNTER_START' then
  if Secret(id) then return end
  active=id==3445;preview=false;RefreshRoster();RefreshVisibility()
 elseif event=='ENCOUNTER_END' or event=='PLAYER_ENTERING_WORLD' then
  active=false;preview=false;RefreshRoster();RefreshVisibility()
 end
end)
-- Retry only the deferred roster; never read or poll aura values.
local retryElapsed=0
events:SetScript('OnUpdate',function(_,elapsed)
 if not pendingRoster then return end
 retryElapsed=retryElapsed+elapsed
 if retryElapsed<.5 then return end
 retryElapsed=0
 if not SentinelAurasRestricted() then RefreshRoster() end
end)
SLASH_SENTINELRAID1='/smraid'
SlashCmdList.SENTINELRAID=function()
 if not ready then Info(L.RELOAD);return end
 if SentinelAurasRestricted() then Info(L.RESTRICTED);return end
 if not SentinelDisplayEnabled('showRaid') then Info(L.ENABLE_RAID);return end
 preview=not preview;RefreshRoster();RefreshVisibility()
 if preview and not IsInRaid() then Info(L.JOIN) end
end
