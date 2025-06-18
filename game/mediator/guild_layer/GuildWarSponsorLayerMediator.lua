local BaseUIMediator = requireMediator("BaseUIMediator")
local GuildWarSponsorLayerMediator = class('GuildWarSponsorLayerMediator', BaseUIMediator)
GuildWarSponsorLayerMediator.NAME = "GuildWarSponsorLayerMediator"

function GuildWarSponsorLayerMediator:ctor()
    GuildWarSponsorLayerMediator.super.ctor(self)
end

function GuildWarSponsorLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Guild_WarSponsor_Open,
            noticeTable.Layer_Guild_WarSponsor_Close
        }
end

function GuildWarSponsorLayerMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local data = notification:getBody()
    
    if noticeTable.Layer_Guild_WarSponsor_Open == noticeName then
        self:OpenLayer( data )
    elseif noticeTable.Layer_Guild_WarSponsor_Close == noticeName then
        self:CloseLayer()
    end
end

function GuildWarSponsorLayerMediator:OpenLayer( data )
    if not (self._layer) then
        self._layer = requireLayerUI("guild_layer/GuildWarSponsorLayer").create(data)
        self._type = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.GuildWarSponsorGUI

        GuildWarSponsorLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI()
    end
end

function GuildWarSponsorLayerMediator:CloseLayer()
    GuildWarSponsorLayerMediator.super.CloseLayer(self)
end

return GuildWarSponsorLayerMediator
