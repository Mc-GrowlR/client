local BaseUIMediator = requireMediator("BaseUIMediator")
local GuildCreateLayerMediator = class('GuildCreateLayerMediator', BaseUIMediator)
GuildCreateLayerMediator.NAME = "GuildCreateLayerMediator"

function GuildCreateLayerMediator:ctor()
    GuildCreateLayerMediator.super.ctor(self)
end

function GuildCreateLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Guild_Create_Open,
            noticeTable.Layer_Guild_Create_Close,
        }
end

function GuildCreateLayerMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local data          = notification:getBody()
    
    if noticeTable.Layer_Guild_Create_Open == noticeName then
        self:OpenLayer( data )
    elseif noticeTable.Layer_Guild_Create_Close == noticeName then
        self:CloseLayer()
    end
end

function GuildCreateLayerMediator:OpenLayer( data )
    if not (self._layer) then
        self._layer = requireLayerUI("guild_layer/GuildCreateLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.GuildCreateGUI

        GuildCreateLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI()

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.GuildCreate
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function GuildCreateLayerMediator:CloseLayer()
    local componentData = 
    {
        index = global.SUIComponentTable.GuildCreate
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    GuildCreateLayerMediator.super.CloseLayer(self)
end

return GuildCreateLayerMediator
