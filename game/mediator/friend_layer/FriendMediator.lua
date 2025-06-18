
local BaseUIMediator = requireMediator("BaseUIMediator")
local FriendMediator = class("FriendMediator", BaseUIMediator)
FriendMediator.NAME = "FriendMediator"

function FriendMediator:ctor()
    FriendMediator.super.ctor( self )
end

function FriendMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Friend_Attach,
        noticeTable.Layer_Friend_UnAttach,
    }
end

function FriendMediator:handleNotification( notification )
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()

    if noticeTable.Layer_Friend_Attach == noticeName then
        self:AttachLayer( noticeData )

    elseif noticeTable.Layer_Friend_UnAttach == noticeName then
        self:UnAttachLayer()
    end
end

function FriendMediator:AttachLayer( data )
    if not self._layer then
        local layer = requireLayerUI("friend_layer/FriendLayer").create( data )
        if layer and data and data.parent then
            data.parent:addChild(layer)
            self._layer = layer

            -- for GUI
            GUI.ATTACH_PARENT = self._layer
            self._layer:InitGUI(data)
        end

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._ui.Panel_1,
            index = global.SUIComponentTable.Friend
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function FriendMediator:UnAttachLayer()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.Friend
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:CloseLayer()
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return FriendMediator