local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroSuperEquipMediator = class("HeroSuperEquipMediator", BaseUIMediator)
HeroSuperEquipMediator.NAME = "HeroSuperEquipMediator"

function HeroSuperEquipMediator:ctor()
    HeroSuperEquipMediator.super.ctor(self)
    self._layer = nil
end

function HeroSuperEquipMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Super_Equip_Open_Hero,
        noticeTable.PlayEquip_Oper_Data_Hero,
        noticeTable.Layer_Player_Child_Del_Hero,
        noticeTable.Layer_Player_Equip_State_Change_Hero,
        noticeTable.Layer_Super_Equip_Setting_Refresh_Hero,
        noticeTable.PlayerSexChange_Hero,
    }
end

function HeroSuperEquipMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Super_Equip_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.PlayEquip_Oper_Data_Hero then
        self:UpdateEquipLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP == noticeData then
            self:CloseLayer()
        end
    elseif noticeName == notices.Layer_Player_Equip_State_Change_Hero then
        self:ResetEquipPanelState(noticeData)
    elseif noticeName == notices.Layer_Super_Equip_Setting_Refresh_Hero then
        self:RefreshSetting()
    elseif noticeName == notices.PlayerSexChange_Hero then
        self:RefreshModelView()
    end
end

function HeroSuperEquipMediator:OpenLayer(noticeData)
    if not self._layer then
        local isWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
        local path = "hero_layer/HeroSuperEquipLayer"
        if isWinPlayMode then 
            path = "hero_layer/HeroSuperEquipLayer_win32"
        end
        local HeroSuperEquipLayer = requireLayerUI(path)
        local layer = HeroSuperEquipLayer.create(noticeData)

        local data = {}
        data.child = layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP
        data.init = noticeData and noticeData.init
        self._layer = layer
        
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_SUPEREQUIP, self._layer)
        self._layer:RefreshInitPos()
        
        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD,data)
        
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerSuperEquip_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function HeroSuperEquipMediator:UpdateEquipLayer(noticeData)
    if self._layer then
        self._layer:UpdateEquipLayer(noticeData)
    end
end

function HeroSuperEquipMediator:ResetEquipPanelState(noticeData)
    if self._layer then
        self._layer:ResetEquipPanelState(noticeData)
    end
end

function HeroSuperEquipMediator:CloseLayer()
    local componentData = {
        index = global.SUIComponentTable.PlayerSuperEquip_hero
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

function HeroSuperEquipMediator:RefreshSetting()
    if self._layer then
    end
end

function HeroSuperEquipMediator:RefreshModelView()
    if self._layer then
        self._layer:UpdatePlayerView()
    end
end

return HeroSuperEquipMediator