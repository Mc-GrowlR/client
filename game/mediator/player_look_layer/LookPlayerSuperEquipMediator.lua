local BaseUIMediator = requireMediator("BaseUIMediator")
local LoookPlayerSuperEquipMediator = class("LoookPlayerSuperEquipMediator", BaseUIMediator)
LoookPlayerSuperEquipMediator.NAME = "LoookPlayerSuperEquipMediator"

function LoookPlayerSuperEquipMediator:ctor()
    LoookPlayerSuperEquipMediator.super.ctor(self)
    self._layer = nil
end

function LoookPlayerSuperEquipMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Look_Player_Super_Equip_Open,
        noticeTable.Layer_Look_Player_Child_Del,
    }
end

function LoookPlayerSuperEquipMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Look_Player_Super_Equip_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Look_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function LoookPlayerSuperEquipMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "player_look_layer/PlayerSuperEquipLayer"
        if global.isWinPlayMode then
            path = "player_look_layer/PlayerSuperEquipLayer_win32"
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

        SL:onLUAEvent(LUA_EVENT_PLAYER_LOOK_FRAME_PAGE_ADD, data)

        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerSuperEquipO
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        local componentData = {
            root = global.isWinPlayMode and self._layer._root:getChildByName("Image_equippanel") or self._layer._root:getChildByName("Image_20"),
            index = global.SUIComponentTable.PlayerSuperEquipBO
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        self._layer:UpdateEquipSettingShowSUI()
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end


function LoookPlayerSuperEquipMediator:CloseLayer()
    local componentData = {
        index = global.SUIComponentTable.PlayerSuperEquipO
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    local componentData = {
        index = global.SUIComponentTable.PlayerSuperEquipBO
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

return LoookPlayerSuperEquipMediator