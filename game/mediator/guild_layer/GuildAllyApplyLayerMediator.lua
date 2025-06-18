local BaseUIMediator = requireMediator("BaseUIMediator")
local GuildAllyApplyLayerMediator = class('GuildAllyApplyLayerMediator', BaseUIMediator)
GuildAllyApplyLayerMediator.NAME = "GuildAllyApplyLayerMediator"

function GuildAllyApplyLayerMediator:ctor()
    GuildAllyApplyLayerMediator.super.ctor(self)
end

function GuildAllyApplyLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Guild_Ally_Apply_Open,
            noticeTable.Layer_Guild_Ally_Apply_Close
        }
end

function GuildAllyApplyLayerMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local data = notification:getBody()
    
    if noticeTable.Layer_Guild_Ally_Apply_Open == noticeName then
        self:OpenLayer()
    elseif noticeTable.Layer_Guild_Ally_Apply_Close == noticeName then
        self:CloseLayer()
    end
end

function GuildAllyApplyLayerMediator:OpenLayer()
    if not (self._layer) then
        self._layer = requireLayerUI("guild_layer/GuildAllyApplyLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.GuildAllyApplyGUI

        GuildAllyApplyLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI()
    end
end

function GuildAllyApplyLayerMediator:CloseLayer()
    GuildAllyApplyLayerMediator.super.CloseLayer(self)
end

return GuildAllyApplyLayerMediator