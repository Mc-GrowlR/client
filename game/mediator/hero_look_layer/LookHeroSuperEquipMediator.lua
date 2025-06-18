local BaseUIMediator = requireMediator("BaseUIMediator")
local LookHeroSuperEquipMediator = class("LookHeroSuperEquipMediator", BaseUIMediator)
LookHeroSuperEquipMediator.NAME  = "LookHeroSuperEquipMediator"

function LookHeroSuperEquipMediator:ctor()
    LookHeroSuperEquipMediator.super.ctor( self )
    self._layer = nil
end

function LookHeroSuperEquipMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
            noticeTable.Layer_Look_Player_Super_Equip_Open_Hero,
            noticeTable.Layer_Look_Player_Child_Del_Hero,
        }
end

function LookHeroSuperEquipMediator:handleNotification(notification)
    local notices  = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()
    
    if noticeName == notices.Layer_Look_Player_Super_Equip_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Look_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function LookHeroSuperEquipMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "hero_look_layer/HeroSuperEquipLayer"
        if global.isWinPlayMode then
            path = "hero_look_layer/HeroSuperEquipLayer_win32"
        end
        local HeroSuperEquip = requireLayerUI(path )
        local layer = HeroSuperEquip.create(noticeData)

        local data = {}
        data.child = layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP
        data.init = noticeData and noticeData.init
        self._layer = layer
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_SUPEREQUIP, self._layer)
        self._layer:RefreshInitPos()
        
        SL:onLUAEvent(LUA_EVENT_HERO_LOOK_FRAME_PAGE_ADD,data)
        
        local componentData = {
            root  = self._layer._root,
            index = global.SUIComponentTable.PlayerSuperEquipO_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        self._layer:UpdateEquipSettingShowSUI()
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end


function LookHeroSuperEquipMediator:CloseLayer()
    local componentData = {
        index = global.SUIComponentTable.PlayerSuperEquipO_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil

        -- 异常处理
        if not global.isWinPlayMode then
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel, {from = ItemMoveProxy.ItemFrom.PALYER_EQUIP})
        end
    end
end

return LookHeroSuperEquipMediator
