local BaseUIMediator = requireMediator( "BaseUIMediator" )
local MailMediator = class("MailMediator", BaseUIMediator)
MailMediator.NAME = "MailMediator"

local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)

function MailMediator:ctor()
    MailMediator.super.ctor( self )
end

function MailMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Mail_Attach,
        noticeTable.Layer_Mail_UnAttach,
        noticeTable.Layer_Mail_DelOneMailSucc,
        noticeTable.Layer_Mail_DelAllMailSucc,
    }
end

function MailMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    
    if noticeTable.Layer_Mail_Attach == noticeName then
        self:AttachLayer(noticeData)

    elseif noticeTable.Layer_Mail_UnAttach == noticeName then
        self:UnAttachLayer()

    elseif noticeTable.Layer_Mail_DelOneMailSucc == noticeName then
        self:DelOneMailSucc(noticeData)

    elseif noticeTable.Layer_Mail_DelAllMailSucc == noticeName then
        self:DelAllMailSucc()
    end
end

function MailMediator:AttachLayer(data)
    if not self._layer then
        local layer = requireLayerUI("mail_layer/MailLayer").create(data)
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
            root  = self._layer._ui.bg,
            index = global.SUIComponentTable.Mail
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        -- 自定义组件挂接
    end
end

function MailMediator:UnAttachLayer()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.Mail
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件挂接

    if self._layer then
        self._layer:CloseLayer()
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function MailMediator:DelOneMailSucc( mailId )
    if self._layer then
        self._layer:delOneMailSucc(mailId)
    end
end

function MailMediator:DelAllMailSucc( )
    if self._layer then
        self._layer:delAllMailSucc()
    end
end

return MailMediator