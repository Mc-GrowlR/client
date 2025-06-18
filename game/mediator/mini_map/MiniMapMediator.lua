local BaseUIMediator = requireMediator("BaseUIMediator")
local MiniMapMediator = class("MiniMapMediator", BaseUIMediator)
MiniMapMediator.NAME = "MiniMapMediator"

function MiniMapMediator:ctor()
    MiniMapMediator.super.ctor(self)
end

function MiniMapMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_MiniMap_Open,
        noticeTable.Layer_MiniMap_Close,
        noticeTable.FindPathPointsBegin,
        noticeTable.FindPathPointsEnd,
        noticeTable.ReleaseMemory,
        noticeTable.MapInfoChange,
        noticeTable.ChangeScene,
    }
end

function MiniMapMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_MiniMap_Open == id then
        self:OpenLayer(data)

    elseif noticeTable.Layer_MiniMap_Close == id then
        self:CloseLayer()
        
    elseif noticeTable.FindPathPointsBegin == id then
        self:OnFindPathPointsBegin()
        
    elseif noticeTable.FindPathPointsEnd == id then
        self:OnFindPathPointsEnd()
        
    elseif noticeTable.ReleaseMemory == id then
        self:OnReleaseMemory()

    elseif noticeTable.MapInfoChange == id then
        self:OnMapInfoChange()

    elseif noticeTable.ChangeScene == id then
        self:OnChangeScene(data)
    end
end

function MiniMapMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("mini_map/MiniMapLayer").create()
        self._type  = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.MiniMapGUI
        MiniMapMediator.super.OpenLayer(self)

        self._layer:InitGUI()

        LoadLayerCUIConfig(global.CUIKeyTable.MINIMAP, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root  = self._layer._layout,
            index = global.SUIComponentTable.MiniMap
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function MiniMapMediator:CloseLayer()
    local componentData = {
        index = global.SUIComponentTable.MiniMap
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:OnClose()
    end

    MiniMapMediator.super.CloseLayer(self)
end

function MiniMapMediator:OnFindPathPointsBegin()
    if not self._layer then
        return nil
    end
    SLBridge:onLUAEvent("LUA_EVENT_MINIMAP_FIND_PATH")
    --self._layer:UpdateFindPath()
end

function MiniMapMediator:OnFindPathPointsEnd()
    if not self._layer then
        return nil
    end
    SLBridge:onLUAEvent("LUA_EVENT_MINIMAP_FIND_PATH")
    --self._layer:UpdateFindPath()
end

function MiniMapMediator:OnReleaseMemory()
    if not self._layer then
        return nil
    end
    SLBridge:onLUAEvent("LUA_EVENT_MINIMAP_RELEASE")
    --self._layer:OnReleaseMemory()
end

function MiniMapMediator:OnChangeScene(data)
    if not self._layer then
        return
    end
    SLBridge:onLUAEvent("LUA_EVENT_MINIMAP_PLAYER")
    --self._layer:AddPlayerPosAnimation()
end

function MiniMapMediator:OnMapInfoChange()
    global.Facade:sendNotification(global.NoticeTable.Layer_MiniMap_Close)
end

return MiniMapMediator
