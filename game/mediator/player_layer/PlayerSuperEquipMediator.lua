local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerSuperEquipMediator = class("PlayerSuperEquipMediator", BaseUIMediator)
PlayerSuperEquipMediator.NAME = "PlayerSuperEquipMediator"

function PlayerSuperEquipMediator:ctor()
    PlayerSuperEquipMediator.super.ctor(self)
    self._layer = nil
end

function PlayerSuperEquipMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Super_Equip_Open,
        noticeTable.PlayEquip_Oper_Data,
        noticeTable.Layer_Player_Child_Del,
        noticeTable.Layer_Player_Equip_State_Change,
        noticeTable.PlayerSexChange
    }
end

function PlayerSuperEquipMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Super_Equip_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.PlayEquip_Oper_Data then
        self:UpdateEquipLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP == noticeData then
            self:CloseLayer()
        end
    elseif noticeName == notices.Layer_Player_Equip_State_Change then
        self:ResetEquipPanelState(noticeData)
    elseif noticeName == notices.PlayerSexChange then
        self:RefreshModelView()
    end
end

function PlayerSuperEquipMediator:OpenLayer(noticeData)
    if not self._layer then
        local isWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
        local path = "player_layer/PlayerSuperEquipLayer"
        if isWinPlayMode then 
            path = "player_layer/PlayerSuperEquipLayer_win32"
        end
        local PlayerEquipLayer = requireLayerUI(path)
        local layer = PlayerEquipLayer.create(noticeData)

        local data = {}
        data.child = layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP
        data.init = noticeData and noticeData.init
        self._layer = layer

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.PLAYER_SUPEREQUIP, self._layer)
        self._layer:RefreshInitPos()

        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD,data)

        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerSuperEquip
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        local componentData = {
            root = global.isWinPlayMode and self._layer._root:getChildByName("Image_equippanel") or self._layer._root:getChildByName("Image_20"),
            index = global.SUIComponentTable.PlayerSuperEquipB
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function PlayerSuperEquipMediator:UpdateEquipLayer(noticeData)
    if self._layer then
        self._layer:UpdateEquipLayer(noticeData)
    end
end

function PlayerSuperEquipMediator:ResetEquipPanelState(noticeData)
    if self._layer then
        self._layer:ResetEquipPanelState(noticeData)
    end
end

function PlayerSuperEquipMediator:CloseLayer()
    local componentData = {
        index = global.SUIComponentTable.PlayerSuperEquip
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    local componentData = {
        index = global.SUIComponentTable.PlayerSuperEquipB
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil

        -- 异常处理
        if not global.isWinPlayMode then
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel, { from = ItemMoveProxy.ItemFrom.PALYER_EQUIP })
        end
    end
end

function PlayerSuperEquipMediator:RefreshModelView()
    if self._layer then
        self._layer:UpdatePlayerView()
    end
end

return PlayerSuperEquipMediator