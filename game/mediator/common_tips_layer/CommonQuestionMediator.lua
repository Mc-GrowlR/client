local BaseUIMediator = requireMediator( "BaseUIMediator" )
local CommonQuestionMediator = class("CommonQuestionMediator", BaseUIMediator)
CommonQuestionMediator.NAME = "CommonQuestionMediator"

function CommonQuestionMediator:ctor()
    CommonQuestionMediator.super.ctor( self )
end

function CommonQuestionMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
            noticeTable.QuestionLayer_Open,
            noticeTable.QuestionLayer_Close,
            }
end

function CommonQuestionMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.QuestionLayer_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.QuestionLayer_Close == noticeName then 
        self:CloseLayer(noticeData)
        
    end
end

function CommonQuestionMediator:OpenLayer(data)
    if not ( self._layer ) then
        local layer = requireLayerUI( "common_tips_layer/CommonQuestionLayer" ).create(data)
        self._layer         = layer
        self._type          = global.UIZ.UI_TOBOX
        self._hideMain      = false
        CommonQuestionMediator.super.OpenLayer( self )

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        LoadLayerCUIConfig(global.CUIKeyTable.COMMON_QUESTION, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root  = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.CommonQuestion
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        self._layer:InitUI( data )
    end
end

function CommonQuestionMediator:CloseLayer()
     -- 自定义组件移除
     local componentData = {
        index = global.SUIComponentTable.CommonQuestion
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    CommonQuestionMediator.super.CloseLayer( self )
end

return CommonQuestionMediator