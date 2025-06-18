local BaseUIMediator = requireMediator("BaseUIMediator")
local GuildEditTitleLayerMediator = class('GuildEditTitleLayerMediator', BaseUIMediator)
GuildEditTitleLayerMediator.NAME = "GuildEditTitleLayerMediator"

function GuildEditTitleLayerMediator:ctor()
    GuildEditTitleLayerMediator.super.ctor(self)
end

function GuildEditTitleLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Guild_EditTitle_Open,
            noticeTable.Layer_Guild_EditTitle_Close
        }
end

function GuildEditTitleLayerMediator:handleNotification(notification)
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local data = notification:getBody()
    
    if noticeTable.Layer_Guild_EditTitle_Open == noticeName then
        self:OpenLayer()
    elseif noticeTable.Layer_Guild_EditTitle_Close == noticeName then
        self:CloseLayer()
    end
end

function GuildEditTitleLayerMediator:OpenLayer()
    if not (self._layer) then
        self._layer = requireLayerUI("guild_layer/GuildEditTitleLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.GuildEditTitleGUI

        GuildEditTitleLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI()
    end
end

function GuildEditTitleLayerMediator:CloseLayer()
    GuildEditTitleLayerMediator.super.CloseLayer(self)
end

return GuildEditTitleLayerMediator
