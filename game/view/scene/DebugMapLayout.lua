local DebugMapLayout = class( "DebugMapLayout", function ()
  return cc.Node:create()
end)

local UnitMapDataWidth  = global.MMO.MapGridWidth
local UnitMapDataHeight = global.MMO.MapGridHeight
local LineColor         = cc.c4f( 1, 0, 0, 0.5 )
local CoverColor        = cc.c4f( 0, 1, 0, 0.2 )
local ObstacleColor     = cc.c4f( 1, 0, 0, 0.2 )

function DebugMapLayout:ctor()
    self._drawNode = nil
end


function DebugMapLayout.create()
  local layout = DebugMapLayout.new()
  if layout:Init() then
    return layout
  else
    return nil
  end
end

function DebugMapLayout:Init()
  self._drawNode  = cc.DrawNode:create( 1 )
  self:addChild( self._drawNode )

  self._pointNode = cc.Node:create()
  self:addChild(self._pointNode)

  return true
end

function DebugMapLayout:Draw( mapData, minX, minY, maxX, maxY )
    self:clear()
    self:drawLine( minX, minY, maxX, maxY )
    self:drawCoverAndObstacle( mapData, minX, minY, maxX, maxY )
end

function DebugMapLayout:clear()
    self._drawNode:clear()
    self._pointNode:removeAllChildren()
end

function DebugMapLayout:drawLine( minX, minY, maxX, maxY )
  local maxXPixel = maxX * UnitMapDataWidth
  local maxYPixel = maxY * UnitMapDataHeight
  local currX = 0
  local currY = 0
  for i = minX, maxX do
    currX = i * UnitMapDataWidth
    self._drawNode:drawLine( cc.p( currX, 0 ), cc.p( currX, -maxYPixel ), LineColor )
  end


  for i = minY, maxY do
    currY = i * UnitMapDataHeight
    self._drawNode:drawLine( cc.p( 0, -currY ), cc.p( maxXPixel, -currY ), LineColor )
  end
end

function DebugMapLayout:drawCoverAndObstacle( mapData, minX, minY, maxX, maxY )
  local currX   = 0
  local currY   = 0

  for col = minX, maxX - 1 do
    for row = minY, maxY - 1 do
      currX = col * UnitMapDataWidth
      currY = -row * UnitMapDataHeight
      -- if 0 ~= mapData:isCover( col, row ) then
      --   self._drawNode:drawSolidRect( cc.p( currX, currY ), cc.p( currX + UnitMapDataWidth, currY - UnitMapDataHeight ), CoverColor )
      -- end

      if 0 ~= mapData:isObstacle( col, row ) then
        self._drawNode:drawSolidRect( cc.p( currX, currY ), cc.p( currX + UnitMapDataWidth, currY - UnitMapDataHeight ), ObstacleColor )
      end
    --   self:debugPoint(col, row)
    end
  end
end

function DebugMapLayout:debugPick( mapX, mapY )
    if not self._debugPickLayout then
        local Layout = ccui.Layout:create()
        Layout:setContentSize(UnitMapDataWidth, UnitMapDataHeight)
        Layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        Layout:setBackGroundColor(cc.Color3B.GRAY)
        Layout:setAnchorPoint(0.5, 0.5)
        self._debugPickLayout = Layout

        self:addChild( Layout )
    end

    self._debugPickLayout:stopAllActions()
    self._debugPickLayout:setVisible( true )
    self._debugPickLayout:setPosition(global.sceneManager:MapPos2WorldPos(mapX, mapY, true))
    self._debugPickLayout:runAction( cc.Sequence:create( cc.Blink:create( 0.5, 3 ), cc.Hide:create() ) )

    self:debugPoint(mapX, mapY)
end

function DebugMapLayout:debugPoint(mapX, mapY)
    local textPoint = ccui.Text:create()
    self._pointNode:addChild(textPoint)
    textPoint:setString(string.format("%s\n%s", mapX, mapY))
    textPoint:setFontSize(12)
    textPoint:setTextColor(cc.c3b(0,0,0))
    textPoint:setPosition(global.sceneManager:MapPos2WorldPos(mapX, mapY, true))
    performWithDelay(textPoint, function()
        textPoint:enableOutline(cc.c3b(0,0,0), 0)
    end, 0.1)
end

function DebugMapLayout:OnOpen()
end

function DebugMapLayout:OnClose()

end

return DebugMapLayout
