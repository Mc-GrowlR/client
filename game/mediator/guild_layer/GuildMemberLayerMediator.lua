local BaseUIMediator = requireMediator("BaseUIMediator")
local GuildMemberLayerMediator = class('GuildMemberLayerMediator', BaseUIMediator)
GuildMemberLayerMediator.NAME = "GuildMemberLayerMediator"

function GuildMemberLayerMediator:ctor()
    GuildMemberLayerMediator.super.ctor(self)
end

function GuildMemberLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Guild_Member_Open,
            noticeTable.Layer_Guild_Member_Close,
            noticeTable.Layer_Guild_Member_Refresh,
            noticeTable.Layer_Guild_Member_Rank_Refresh,
            noticeTable.Layer_Guild_Member_Remove,
            noticeTable.GuildInfo_Refresh,
        }
end

function GuildMemberLayerMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local data = notification:getBody()
    
    if noticeTable.Layer_Guild_Member_Open == noticeName then
        self:OpenLayer( data )
    elseif noticeTable.Layer_Guild_Member_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.Layer_Guild_Member_Refresh == noticeName then
        self:Refresh()
    elseif noticeTable.Layer_Guild_Member_Rank_Refresh == noticeName then
        self:RefreshCellRank(data)
    elseif noticeTable.Layer_Guild_Member_Remove == noticeName then
        self:OnRemoveMember()
    elseif noticeTable.GuildInfo_Refresh == noticeName then
        self:RefreshGuildInfo()
    end
end

function GuildMemberLayerMediator:OpenLayer( data )
    if not (self._layer) then
        self._layer = requireLayerUI("guild_layer/GuildMemberLayer").create()
        data.parent:addChild(self._layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.GuildMembers
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function GuildMemberLayerMediator:CloseLayer()
    local componentData = 
    {
        index = global.SUIComponentTable.GuildMembers
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function GuildMemberLayerMediator:Refresh()
    if self._layer then
        self._layer:Refresh()
    end
end

function GuildMemberLayerMediator:RefreshCellRank(data)
    if self._layer then
        self._layer:refreshCellRank(data)
    end
end

function GuildMemberLayerMediator:RefreshGuildInfo()
    if self._layer then
        self._layer:refreshInfo()
    end
end

function GuildMemberLayerMediator:OnRemoveMember()
    if self._layer then
        self._layer:removeMember()
    end
end

return GuildMemberLayerMediator
