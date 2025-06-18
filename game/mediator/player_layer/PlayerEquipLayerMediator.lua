local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerEquipLayerMediator = class("PlayerEquipLayerMediator", BaseUIMediator)
PlayerEquipLayerMediator.NAME = "PlayerEquipLayerMediator"

function PlayerEquipLayerMediator:ctor()
    PlayerEquipLayerMediator.super.ctor(self)
    self._layer = nil
end

function PlayerEquipLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Equip_Open,
        noticeTable.Layer_Player_Child_Del,
    }
end

function PlayerEquipLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Equip_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function PlayerEquipLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "player_layer/PlayerEquipLayer"
        if global.isWinPlayMode then
            path = "player_layer/PlayerEquipLayer_win32"
        end
        local PlayerEquipLayer = requireLayerUI(path)
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
        
        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerEquip
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        local componentData = {
            root = global.isWinPlayMode and self._layer._root:getChildByName("Image_equippanel") or self._layer._root:getChildByName("Image_20"),
            index = global.SUIComponentTable.PlayerEquipB
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function PlayerEquipLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerEquip
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    local componentData = {
        index = global.SUIComponentTable.PlayerEquipB
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    
    if self._layer then
        self._layer:OnClose()
    end
    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return PlayerEquipLayerMediator