
local BaseUIMediator = requireMediator("BaseUIMediator")
local GuildMainMediator = class('GuildMainMediator', BaseUIMediator)
GuildMainMediator.NAME = "GuildMainMediator"

function GuildMainMediator:ctor()
    GuildMainMediator.super.ctor(self)
end

function GuildMainMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Guild_Main_Open,
        noticeTable.Layer_Guild_Main_Close,
        noticeTable.Layer_Guild_Main_Refresh,
        noticeTable.BindMainPlayer,             -- 角色出现（语音出现角色未出现，行会信息已经有了）
    }
end

function GuildMainMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_Guild_Main_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_Guild_Main_Close == name then
        self:CloseLayer()
    elseif noticeTable.Layer_Guild_Main_Refresh == name then
        self:Refresh()
    elseif noticeTable.BindMainPlayer == name then
        self:OnBindMainPlayer()
    end
end

function GuildMainMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("guild_layer/GuildMainLayer").create()
        data.parent:addChild(self._layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.GuildMain
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function GuildMainMediator:CloseLayer()
    local componentData = 
    {
        index = global.SUIComponentTable.GuildMain
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:CloseLayer()
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function GuildMainMediator:Refresh()
    if self._layer then
        self._layer:Refresh()
    end
end

function GuildMainMediator:OnBindMainPlayer()
    local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
    GuildPlayerProxy:SetBindMainPlayerFininsh( true )
end

return GuildMainMediator
