local DebugMediator  = requireMediator( "DebugMediator" )
local DebugMapMediator = class('DebugMapMediator', DebugMediator)
DebugMapMediator.NAME = "DebugMapMediator"

function DebugMapMediator:ctor()
    DebugMapMediator.super.ctor(self)

    self._timer = nil
    self._lastFollowPos = cc.p( 0, 0 )

    self._visible = false
end

function DebugMapMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.DebugMapOpen,
        noticeTable.DebugMapClose,
        noticeTable.DebugMapSwitch,
        noticeTable.ChangeScene,
        noticeTable.PickerChange,
    }
end

function DebugMapMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData  = notification:getBody()

    if noticeTable.DebugMapSwitch == noticeName then
        self:VisibleSwitch()

    elseif noticeTable.DebugMapOpen == noticeName then
        self:Open()

    elseif noticeTable.DebugMapClose == noticeName then
        self:Close()

    elseif noticeTable.ChangeScene == noticeName then
        local lastVisible = self._visible
        self:Close()

        if lastVisible then
            self:Open()
        end

    elseif noticeTable.PickerChange == noticeName then
        self:onPickerChange( noticeData )

    end
end


function DebugMapMediator:calcAreaRect( pos )
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return
    end


    local mapSliceCols = mapData:getMapDataCols()
    local mapSliceRows = mapData:getMapDataRows()
    local winSize = global.Director:getWinSize()
    local camera  = global.gameMapController:GetViewCamera()
    if camera then
        local scaleX, scaleY = CalcCameraZoom( camera )
        winSize.width = winSize.width * scaleX
        winSize.height = winSize.height * scaleY
    end


    -- calc area
    local centerOfView = cc.size( winSize.width * 0.5, winSize.height * 0.5 )
    local area = cc.rect( pos.x - centerOfView.width, -pos.y - centerOfView.height, winSize.width, winSize.height )
    local minX = math.floor( area.x / global.MMO.MapGridWidth )
    local minY = math.floor( area.y / global.MMO.MapGridHeight )
    local maxX = math.floor( cc.rectGetMaxX( area ) / global.MMO.MapGridWidth )
    local maxY = math.floor( cc.rectGetMaxY( area ) / global.MMO.MapGridHeight )


    -- for enlage area
    minX = math.max( 0, minX - 10 )
    minY = math.max( 0, minY - 10 )
    maxX = math.min( maxX + 10, mapSliceCols )
    maxY = math.min( maxY + 10, mapSliceRows )

    if self._layer then
        self._layer:Draw( mapData, minX, minY, maxX, maxY )
    end
end

function DebugMapMediator:Open()
    if not self._layer then
        self._layer = requireView("scene/DebugMapLayout").create()
        local mapRoot = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_MAP_OBJ )
        mapRoot:addChild( self._layer, 9999 )

        -- start timer, to follow player
        if nil == self._timer then
            self._timer = Schedule( handler( self, self.Tick ), 2.0 )
        end

        local player = global.gamePlayerController:GetMainPlayer()
        if player then
            local playerPos = player:getPosition()
            self:followPos( playerPos )
        end

        self._visible = true
    end
end

function DebugMapMediator:Close()
    if self._layer then
        self._layer:OnClose()
        self._layer:removeFromParent()

        self._layer   = nil

        -- stop timer
        if self._timer then
            UnSchedule( self._timer )
            self._timer = nil
        end
        self._visible = false
    end

end

function DebugMapMediator:VisibleSwitch()
    if not self._layer then
        self:Open()
    else
        self:Close()
    end
end

function DebugMapMediator:onPickerChange( pick )
    if self._layer then
        self._layer:debugPick( pick.xGridPicked, pick.yGridPicked )
    end
end

function DebugMapMediator:followPos( playerPos )
    if self._layer then
        self:calcAreaRect( playerPos )
        self._lastFollowPos = clone( playerPos )
    end
end

function DebugMapMediator:Tick()
    local player = global.gamePlayerController:GetMainPlayer()
    if not player then
        return
    end

    local playerPos = player:getPosition()
    if self._lastFollowPos.x == playerPos.x and self._lastFollowPos.y == playerPos.y then
        return
    end

    self:followPos( playerPos )
end

function DebugMapMediator.OnUnloaded()
    local facade = global.Facade
    facade:sendNotification( global.NoticeTable.DebugMapClose )
    facade:removeMediator( DebugMapMediator.NAME )

    DebugMapMediator.super.OnUnloaded()
end

function DebugMapMediator.Onloaded()
    local mediator = DebugMapMediator.new()
    global.Facade:registerMediator( mediator )

    global.Facade:sendNotification( global.NoticeTable.DebugMapOpen )

    DebugMapMediator.super.Onloaded()
end


return DebugMapMediator
