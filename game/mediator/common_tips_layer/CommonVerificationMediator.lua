local BaseUIMediator = requireMediator( "BaseUIMediator" )
local CommonVerificationMediator = class("CommonVerificationMediator", BaseUIMediator)
CommonVerificationMediator.NAME = "CommonVerificationMediator"

function CommonVerificationMediator:ctor()
    CommonVerificationMediator.super.ctor( self )
end

function CommonVerificationMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
            noticeTable.VerificationLayer_Open,
            noticeTable.VerificationLayer_Close,
            }
end

function CommonVerificationMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.VerificationLayer_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.VerificationLayer_Close == noticeName then 
        self:CloseLayer(noticeData)
        
    end
end

function CommonVerificationMediator:OpenLayer(data)
    if not ( self._layer ) then
        local layer = requireLayerUI( "common_tips_layer/CommonVerificationLayer" ).create(data)
        self._layer         = layer
        self._type          = global.UIZ.UI_NOTICE
        self._hideMain      = false
        CommonVerificationMediator.super.OpenLayer( self )

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        LoadLayerCUIConfig(global.CUIKeyTable.COMMON_VERIFICATION, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root  = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.CommonVerification
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        self._layer:updateUI( data )
    end
end

function CommonVerificationMediator:CloseLayer()
    -- 自定义组件移除
    local componentData = {
        index = global.SUIComponentTable.CommonVerification
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    CommonVerificationMediator.super.CloseLayer( self )
end

return CommonVerificationMediator