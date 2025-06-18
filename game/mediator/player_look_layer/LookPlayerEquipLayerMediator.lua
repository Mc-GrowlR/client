local BaseUIMediator = requireMediator("BaseUIMediator")
local LookPlayerEquipLayerMediator = class("LookPlayerEquipLayerMediator", BaseUIMediator)
LookPlayerEquipLayerMediator.NAME  = "LookPlayerEquipLayerMediator"

function LookPlayerEquipLayerMediator:ctor()
    LookPlayerEquipLayerMediator.super.ctor( self )
    self._layer = nil
end

function LookPlayerEquipLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
            noticeTable.Layer_Look_Player_Equip_Open,
            noticeTable.Layer_Look_Player_Child_Del,
    }
end

function LookPlayerEquipLayerMediator:handleNotification(notification)
    local notices  = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()
    
    if noticeName == notices.Layer_Look_Player_Equip_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Look_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function LookPlayerEquipLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "player_look_layer/PlayerEquipLayer"
        if global.isWinPlayMode then
            path = "player_look_layer/PlayerEquipLayer_win32"
        end
        local PlayerEquipLayer = requireLayerUI( path )
        local layer = PlayerEquipLayer.create(noticeData)
        self._layer = layer

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP
        data.init = noticeData and noticeData.init
        
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.PLAYER_EQUIP, self._layer)
        self._layer:RefreshInitPos()

        SL:onLUAEvent(LUA_EVENT_PLAYER_LOOK_FRAME_PAGE_ADD, data)
        -- 自定义组件挂接
        local componentData = {
            root  = self._layer._root,
            index = global.SUIComponentTable.PlayerEquipO
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        local componentData = {
            root  = global.isWinPlayMode and self._layer._root:getChildByName("Image_equippanel") or self._layer._root:getChildByName("Image_20"),
            index = global.SUIComponentTable.PlayerEquipBO
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        -- 自定义组件挂接

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function LookPlayerEquipLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.PlayerEquipO
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    local componentData = {
        index = global.SUIComponentTable.PlayerEquipBO
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件挂接

    if self._layer then
        self._layer:OnClose()
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return LookPlayerEquipLayerMediator
