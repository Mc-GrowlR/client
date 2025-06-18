local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local GoldBoxMediator = class('GoldBoxMediator', BaseUIMediator )
GoldBoxMediator.NAME  = "GoldBoxMediator"

function GoldBoxMediator:ctor()
    GoldBoxMediator.super.ctor( self )
end

function GoldBoxMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Gold_Box_Open,
        noticeTable.Layer_Gold_Box_Close,
        noticeTable.Layer_Gold_Box_Open_Anim,
        noticeTable.Layer_Gold_Box_Refresh,
    }
end

function GoldBoxMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_Gold_Box_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_Gold_Box_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.Layer_Gold_Box_Open_Anim == noticeName then 
        self:ShowOpenAnim(noticeData)
    elseif noticeTable.Layer_Gold_Box_Refresh == noticeName then
        self:Refresh(noticeData)
    end
end
--依附节点
function GoldBoxMediator:OpenLayer(Data)
    if not ( self._layer ) then
        self._layer = requireLayerUI("gold_box_layer/GoldBoxLayer").create(Data)
        self._type  = global.UIZ.UI_FUNC
        self._action = false
        GoldBoxMediator.super.OpenLayer(self)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(Data)
        self._moveBg, self._panel = self._layer:GetMoveTouch()
    end
    local function ontouch(sender, event)
        if event == ccui.TouchEventType.began then
            GoldBoxMediator.basePosX, GoldBoxMediator.basePosy = self._layer:getPosition()
        elseif event == ccui.TouchEventType.moved then
            local sPos      = sender:getTouchBeganPosition()
            local ePos      = sender:getTouchMovePosition()
            local x         = GoldBoxMediator.basePosX + ePos.x - sPos.x
            local y         = GoldBoxMediator.basePosy + ePos.y - sPos.y
            local frameSize = global.Director:getWinSize()
            local size      = self._panel:getContentSize()
            if x >= frameSize.width / 2 - size.width / 2 then 
                x = frameSize.width / 2 - size.width / 2
            elseif x <= size.width / 2 - frameSize.width / 2 then 
                x = size.width / 2 - frameSize.width / 2
            end
            if y >= frameSize.height / 2 - size.height / 2 then 
                y = frameSize.height / 2 - size.height / 2
            elseif y <= size.height / 2 - frameSize.height / 2 then 
                y = size.height / 2 - frameSize.height / 2
            end
            self._layer:setPosition(x, y)
        elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
            local endPosX, endPosY = self._layer:getPosition()
            self._layer:GetMoveLayerPos(endPosX, endPosY)
        end
    end
    self._moveBg:addTouchEventListener(ontouch)
end

function GoldBoxMediator:ShowOpenAnim(data)
    if self._layer then 
        self._layer:OpenBoxAnim(data)
    end
end

function GoldBoxMediator:Refresh(data)
    if self._layer then 
        self._layer:RefreshLayer(data)
    end 
end

function CheckGoldBoxCanUse()
    local mediator = global.Facade:retrieveMediator("GoldBoxMediator")
    if mediator and mediator._layer and not GoldBox._canClose then
        return false
    end
    return true
end

function GoldBoxMediator:CloseLayer()
    GoldBoxMediator.super.CloseLayer(self)
end


return GoldBoxMediator