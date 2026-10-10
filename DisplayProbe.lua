local L = SentinelMarkerL
-- Native aura presentation. Blizzard owns aura selection and stack text.
-- No aura getters, text readback, stack comparisons, or chat dispatch.
local panel, container, mover
local ready, active, preview = false, false, false
local function Info(text) print('|cff3399ffSentinel:|r '..text) end
local function Secret(v) return issecretvalue and issecretvalue(v) end
local function Refresh()
 if ready then
  mover:SetShown(SentinelDisplayEnabled("showPersonal") and preview and not active)
  panel:SetShown(SentinelDisplayEnabled("showPersonal") and (active or preview))
 end
end
SentinelRefreshPersonal = Refresh
local function Initialize()
 if ready then return end
 if SentinelAurasRestricted() then return end
 if not C_StringUtil or not C_StringUtil.CreateNumericRuleFormatter or not AuraContainerSortMethod or not AuraContainerSortDirection then
  Info(L.API);return
 end
 local ok=pcall(function()
  panel=CreateFrame('Frame','SentinelNativeAuraPanel',UIParent)
  -- Set before creating restricted descendants; keep the counter above settings.
  panel:SetFrameStrata('FULLSCREEN_DIALOG')
  panel:SetSize(48,48)
  panel:SetPoint('CENTER',UIParent,'CENTER',0,110)
  panel:SetClampedToScreen(true)
  mover=SentinelCreateNativeMover(panel,'nativePosition')
  local pos=SentinelMarkersDB and SentinelMarkersDB.nativePosition
  if type(pos)=='table' and type(pos[1])=='string' and type(pos[2])=='string' and type(pos[3])=='number' and type(pos[4])=='number' then
   panel:ClearAllPoints();panel:SetPoint(pos[1],UIParent,pos[2],pos[3],pos[4])
  end
  local format=C_StringUtil.CreateNumericRuleFormatter()
  format:SetBreakpoints({{threshold=0,format=''},{threshold=1,format='%d'}})
  container=CreateFrame('AuraContainer',nil,panel,'CustomAuraContainerTemplate,DisableUntrustedLayoutScriptsTemplate')
  container:SetUnit('player')
  container:AddAuraGroup('sentinel','HARMFUL|IMPORTANT',{
   maxFrameCount=1,
   sortMethod=AuraContainerSortMethod.ExpirationOnly,
   sortDirection=AuraContainerSortDirection.Normal,
   candidateFilters={},
   layout={elementWidth=48,elementHeight=48,elementSpacing=0,lineSpacing=0},
   initializeFrame=function(button)
    button:SetSize(48,48);button:SetCollapsesLayout(true)
    button:SetMouseClickEnabled(false);button:SetMouseMotionEnabled(false)
    local background=button:CreateTexture(nil,'BACKGROUND')
    background:SetAllPoints(button);background:SetColorTexture(0,0,0,.85)
    local overlay=CreateFrame('Frame',nil,button)
    overlay:SetAllPoints(button);overlay:SetFrameLevel(button:GetFrameLevel()+2)
    local count=overlay:CreateFontString(nil,'OVERLAY','GameFontNormalHuge')
    count:SetFont(STANDARD_TEXT_FONT,32,'OUTLINE')
    count:SetPoint('CENTER',button,'CENTER',0,0)
    button:SetApplicationCount(count,{formatter=format})
   end,
  })
  container:SetFlowLayoutAnchorPoint('TOPLEFT')
  container:SetFlowLayoutPadding(0,0,0,0)
  container:SetFlowLayoutMaximumLineSize(48)
  container:SetPoint('TOPLEFT',panel,'TOPLEFT',0,0)
  container:SetEnabled(true)
  ready=true
 end)
 if not ok then
  if panel then panel:Hide() end
  Info(L.INIT)
  return
 end
 Refresh()
end
local events=CreateFrame('Frame')
for _,event in ipairs({'PLAYER_LOGIN','ENCOUNTER_START','ENCOUNTER_END','PLAYER_ENTERING_WORLD','PLAYER_REGEN_ENABLED'}) do events:RegisterEvent(event) end
events:SetScript('OnEvent',function(_,event,id)
 if event=='PLAYER_LOGIN' then Initialize()
 elseif event=='ENCOUNTER_START' then
  if Secret(id) then return end
  active=id==3445;preview=false;Refresh()
 elseif event=='ENCOUNTER_END' or event=='PLAYER_ENTERING_WORLD' then
  active=false;preview=false;Refresh()
 elseif event=='PLAYER_REGEN_ENABLED' then Refresh() end
end)
SLASH_SENTINELDISPLAY1='/smview'
SlashCmdList.SENTINELDISPLAY=function()
 if not ready then Info(L.RELOAD);return end
 if SentinelAurasRestricted() then Info(L.RESTRICTED);return end
 if not SentinelDisplayEnabled('showPersonal') then Info(L.ENABLE_SELF);return end
 preview=not preview;Refresh()
 if preview then Info(L.PREVIEW) end
end
