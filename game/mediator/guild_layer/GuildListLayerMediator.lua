
local BaseUIMediator = requireMediator("BaseUIMediator")
local GuildListLayerMediator = class('GuildListLayerMediator', BaseUIMediator)
GuildListLayerMediator.NAME = "GuildListLayerMediator"

function GuildListLayerMediator:ctor()
    GuildListLayerMediator.super.ctor(self)
end

function GuildListLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Guild_List_Open,
        noticeTable.Layer_Guild_List_Close
    }
end

function GuildListLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_Guild_List_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_Guild_List_Close == name then
        self:CloseLayer()
    end
end

function GuildListLayerMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("guild_layer/GuildListLayer").create()
        data.parent:addChild(self._layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.GuildList
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
    end
end

function GuildListLayerMediator:CloseLayer()
    local componentData = 
    {
        index = global.SUIComponentTable.GuildList
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:CloseLayer()
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return GuildListLayerMediator
