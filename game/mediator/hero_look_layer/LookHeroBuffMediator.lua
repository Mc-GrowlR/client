local BaseUIMediator = requireMediator( "BaseUIMediator" )
local LookHeroBuffMediator = class('LookHeroBuffMediator', BaseUIMediator )
LookHeroBuffMediator.NAME  = "LookHeroBuffMediator"

function LookHeroBuffMediator:ctor()
    LookHeroBuffMediator.super.ctor( self )
end

function LookHeroBuffMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Look_Buff_Attach_Hero,
        noticeTable.Layer_Look_Player_Child_Del_Hero,
    }
end

function LookHeroBuffMediator:handleNotification(notification)
    local noticeID    = notification:getName()
    local noticeTable = global.NoticeTable
    local data        = notification:getBody()

    if noticeTable.Layer_Look_Buff_Attach_Hero == noticeID then
        self:OpenLayer(data)

    elseif noticeTable.Layer_Look_Player_Child_Del_Hero == noticeID then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF == data then
            self:CloseLayer()
        end
    end
end

function LookHeroBuffMediator:OpenLayer(noticeData)
    if not self._layer then
        self._layer = requireLayerUI("hero_look_layer/HeroBuffLayer").create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF
        data.init = data and data.init

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        SL:onLUAEvent(LUA_EVENT_HERO_LOOK_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerBuffO_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end    
end

function LookHeroBuffMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerBuffO_hero
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

return LookHeroBuffMediator