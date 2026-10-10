local L = SentinelMarkerL
-- User preferences; aura values are never used here.
function SentinelDisplayEnabled(key)
 return not SentinelMarkersDB or SentinelMarkersDB[key] ~= false
end
local function UpdateDisplays()
 if SentinelRefreshPersonal then SentinelRefreshPersonal() end
 if SentinelRefreshRaid then SentinelRefreshRaid() end
end
local controls={}
local function BuildControls(parent)
 local title=parent:CreateFontString(nil,'OVERLAY','GameFontNormalLarge')
 title:SetPoint('TOPLEFT',18,-20);title:SetText(SentinelMarkerInfo.displayName)
 for i,item in ipairs({{'showRaid',L.SHOW_RAID},{'showPersonal',L.SHOW_SELF}}) do
  local key,label=item[1],item[2]
  local check=CreateFrame('CheckButton',nil,parent,'ChatConfigCheckButtonTemplate')
  check:SetPoint('TOPLEFT',18,-74-(i-1)*34);check.Text:SetWidth(390);check.Text:SetJustifyH('LEFT');check.Text:SetText(label)
  check:SetChecked(SentinelDisplayEnabled(key));controls[#controls+1]={check,key}
  check:SetScript('OnClick',function(self)
   if InCombatLockdown() then self:SetChecked(SentinelDisplayEnabled(key));return end
   SentinelMarkersDB=SentinelMarkersDB or {};SentinelMarkersDB[key]=self:GetChecked() and true or false
   UpdateDisplays()
  end)
 end
 for i,item in ipairs({{L.MOVE_RAID,'SENTINELRAID'},{L.MOVE_SELF,'SENTINELDISPLAY'}}) do
  local command=item[2]
  local b=CreateFrame('Button',nil,parent,'UIPanelButtonTemplate')
  b:SetSize(400,26);b:SetPoint('TOPLEFT',22,-151-(i-1)*33);b:SetText(item[1])
  b:SetScript('OnClick',function()
   if not InCombatLockdown() and SlashCmdList[command] then SlashCmdList[command]() end
  end)
 end
 local note=parent:CreateFontString(nil,'OVERLAY','GameFontNormalSmall')
 note:SetPoint('TOPLEFT',22,-230);note:SetWidth(410);note:SetJustifyH('LEFT');note:SetText(L.MOVE_HINT)
 parent:SetScript('OnShow',function()
  for _,item in ipairs(controls) do item[1]:SetChecked(SentinelDisplayEnabled(item[2])) end
 end)
end
local popup=CreateFrame('Frame','SentinelOptionsPanel',UIParent,'BackdropTemplate')
popup:SetSize(460,310);popup:SetPoint('CENTER');popup:SetFrameStrata('DIALOG')
popup:EnableMouse(true)
popup:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'});popup:SetBackdropColor(.025,.04,.07,.98)
BuildControls(popup)
local close=CreateFrame('Button',nil,popup,'UIPanelCloseButton');close:SetPoint('TOPRIGHT');close:SetScript('OnClick',function() popup:Hide() end)
popup:Hide()
function SentinelOpenOptions()
 if InCombatLockdown() then print(L.OOC);return end
 popup:Show()
end
SLASH_SENTINELOPTIONS1='/smconfig'
SlashCmdList.SENTINELOPTIONS=SentinelOpenOptions
local event=CreateFrame('Frame')
event:RegisterEvent('PLAYER_LOGIN')
event:SetScript('OnEvent',function()
 SentinelMarkersDB=SentinelMarkersDB or {}
 if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
  local page=CreateFrame('Frame');page.name='Sentinel Marker';BuildControls(page)
  local category=Settings.RegisterCanvasLayoutCategory(page,'Sentinel Marker')
  Settings.RegisterAddOnCategory(category)
 end
end)
