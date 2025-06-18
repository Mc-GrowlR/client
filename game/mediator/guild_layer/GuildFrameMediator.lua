local BaseUIMediator = requireMediator("BaseUIMediator")
local GuildFrameMediator = class("GuildFrameMediator", BaseUIMediator)
GuildFrameMediator.NAME = "GuildFrameMediator"

function GuildFrameMediator:ctor()
    GuildFrameMediator.super.ctor( self )
end

function GuildFrameMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.Layer_GuildFrame_Open,
        noticeTable.Layer_GuildFrame_Close,
        noticeTable.Layer_GuildFrame_Refresh,
    }
end

function GuildFrameMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_GuildFrame_Open == id then
        self:OpenLayer(data)
    elseif noticeTable.Layer_GuildFrame_Close == id then
        self:CloseLayer()
    elseif noticeTable.Layer_GuildFrame_Refresh == id then
        self:OnRefresh(data)
    end
end

function GuildFrameMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer    = requireLayerUI("guild_layer/GuildFrameLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.GuildFrameGUI

        GuildFrameMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)

        LoadLayerCUIConfig(global.CUIKeyTable.GUILD_FRAME, self._layer)

        local componentData = 
        {
            root  = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.GuildBg
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    else
        self._layer:PageTo(data)
    end
end

function GuildFrameMediator:CloseLayer()
    -- 自定义组件移除
    local componentData = 
    {
        index = global.SUIComponentTable.GuildBg
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:OnClose()
    end
    GuildFrameMediator.super.CloseLayer(self)
end

function GuildFrameMediator:OnRefresh(data)
    if self._layer then
        self._layer:OnRefresh(data)
    end
end

return GuildFrameMediator
