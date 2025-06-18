local BaseUIMediator = requireMediator("BaseUIMediator")
local GuildApplyListLayerMediator = class('GuildApplyListLayerMediator', BaseUIMediator)
GuildApplyListLayerMediator.NAME = "GuildApplyListLayerMediator"

function GuildApplyListLayerMediator:ctor()
    GuildApplyListLayerMediator.super.ctor(self)
end

function GuildApplyListLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Guild_ApplyList_Open,
            noticeTable.Layer_Guild_ApplyList_Close,
            noticeTable.Layer_Guild_ApplyList_Refresh,
            noticeTable.Cross_Server_Status_Change,
        }
end

function GuildApplyListLayerMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local data          = notification:getBody()
    
    if noticeTable.Layer_Guild_ApplyList_Open == noticeName then
        self:OpenLayer()
    elseif noticeTable.Layer_Guild_ApplyList_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.Layer_Guild_ApplyList_Refresh == noticeName then
        self:RefreshLayer()
    elseif noticeTable.Cross_Server_Status_Change == noticeName then
        self:RefreshData()
    end
end

function GuildApplyListLayerMediator:OpenLayer( data )
    if not (self._layer) then
        self._layer = requireLayerUI("guild_layer/GuildApplyListLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.GuildApplyListGUI

        GuildApplyListLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI()
    end
end

function GuildApplyListLayerMediator:CloseLayer()
    GuildApplyListLayerMediator.super.CloseLayer(self)
end

function GuildApplyListLayerMediator:RefreshLayer()
    if not self._layer then 
        return 
    end 

    SLBridge:onLUAEvent(LUA_EVENT_GUILD_APPLYLIST)
end

function GuildApplyListLayerMediator:RefreshData()
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    GuildProxy:RequestWorldGuildList()
    GuildProxy:RequestGuildAllyApplyList()    
end

return GuildApplyListLayerMediator
