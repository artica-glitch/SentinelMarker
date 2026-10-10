-- Aura restrictions can remain active after death and after combat lockdown ends.
function SentinelAurasRestricted()
 if InCombatLockdown() then return true end
 if C_Secrets and C_Secrets.ShouldAurasBeSecret then
  local ok,value=pcall(C_Secrets.ShouldAurasBeSecret)
  if not ok or (issecretvalue and issecretvalue(value)) then return true end
  return value == true
 end
 return false
end
function SentinelAuraFrameAccessible(host)
 local ok,allowed=pcall(function()
  if host.CanBeAccessedInContext then return host:CanBeAccessedInContext() end
  return true
 end)
 if not ok or (issecretvalue and issecretvalue(allowed)) then return false end
 return allowed == true
end
-- Mover is a sibling, never an ancestor of native aura frames.
function SentinelCreateNativeMover(anchor, positionKey)
 local mover=CreateFrame('Frame',nil,UIParent,'BackdropTemplate')
 mover:SetAllPoints(anchor)
 mover:SetFrameStrata('DIALOG')
 mover:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8'})
 mover:SetBackdropColor(.12,.06,.18,.45)
 if positionKey=='nativePosition' then
  -- Independent input layer: never parent the restricted aura to the mover.
  mover:SetFrameStrata('FULLSCREEN_DIALOG')
  mover:SetFrameLevel(anchor:GetFrameLevel()+20)
  mover:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=2})
  mover:SetBackdropColor(.12,.06,.18,.45)
  mover:SetBackdropBorderColor(.1,.8,1,1)
 end
 mover:EnableMouse(true);mover:RegisterForDrag('LeftButton')
 anchor:SetMovable(true)
 mover:SetScript('OnDragStart',function()
  if not SentinelAurasRestricted() then anchor:StartMoving() end
 end)
 mover:SetScript('OnDragStop',function()
  if SentinelAurasRestricted() then return end
  anchor:StopMovingOrSizing()
  local p,_,rp,x,y=anchor:GetPoint()
  SentinelMarkersDB=SentinelMarkersDB or {}
  SentinelMarkersDB[positionKey]={p,rp,x,y}
 end)
 mover:Hide()
 return mover
end
