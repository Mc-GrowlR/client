local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroEquipLayerMediator = class("HeroEquipLayerMediator", BaseUIMediator)
HeroEquipLayerMediator.NAME = "HeroEquipLayerMediator"

function HeroEquipLayerMediator:ctor()
    HeroEquipLayerMediator.super.ctor(self)
    self._layer = nil
end

function HeroEquipLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Equip_Open_Hero,
        noticeTable.Layer_Player_Child_Del_Hero,
    }
end

function HeroEquipLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Equip_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function HeroEquipLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "hero_layer/HeroEquipLayer"
        if global.isWinPlayMode then
            path = "hero_layer/HeroEquipLayer_win32"
        end
        local HeroEquipLayer = requireLayerUI(path)
        local layer = HeroEquipLayer.create(noticeData)
        self._layer = layer

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP
        data.init = noticeData and noticeData.init
        
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_EQUIP, self._layer)
        self._layer:RefreshInitPos()
        
        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        if not noticeData or not noticeData.lookPlayer then
            local componentData = {
                root = self._layer._root,
                index = global.SUIComponentTable.PlayerEquip_hero
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
            local componentData = {
                root = global.isWinPlayMode and self._layer._root:getChildByName("Image_equippanel") or self._layer._root:getChildByName("Image_20"),
                index = global.SUIComponentTable.PlayerEquipB_hero
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        else
            local componentData = {
                root = self._layer._root,
                index = global.SUIComponentTable.PlayerEquipO_hero
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
            local componentData = {
                root = global.isWinPlayMode and self._layer._root:getChildByName("Image_equippanel") or self._layer._root:getChildByName("Image_20"),
                index = global.SUIComponentTable.PlayerEquipBO_hero
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        end
        -- 自定义组件挂接

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function HeroEquipLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.PlayerEquip_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    local componentData = {
        index = global.SUIComponentTable.PlayerEquipB_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    local componentData = {
        index = global.SUIComponentTable.PlayerEquipO_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    local componentData = {
        index = global.SUIComponentTable.PlayerEquipBO_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件挂接

    if self._layer then
        self._layer:OnClose()
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return HeroEquipLayerMediator