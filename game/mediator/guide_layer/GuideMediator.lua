local BaseUIMediator = requireMediator("BaseUIMediator")
local GuideMediator = class("GuideMediator", BaseUIMediator)
GuideMediator.NAME = "GuideMediator"

function GuideMediator:ctor()
    GuideMediator.super.ctor(self)
end

function GuideMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Guide_Open,
        noticeTable.Layer_Guide_Close,
        noticeTable.Layer_Bag_ResetPos,
        noticeTable.GuideLayerResetPos
    }
end

function GuideMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Guide_Open == id then
        self:OnOpen(data)
    elseif noticeTable.Layer_Guide_Close == id then
        self:OnClose()
    elseif noticeTable.Layer_Bag_ResetPos == id or noticeTable.GuideLayerResetPos == id then
        self:OnUpdate()
    end
end
function GuideMediator:OnUpdate()
    if tolua.isnull(self._layer) then
        self._layer = nil
    end
    if self._layer then
        self._layer:OnUpdate()
    end
    
end
function GuideMediator:OnOpen(task)
     if tolua.isnull(self._layer) then
        self._layer = nil
    end
    if (not self._layer) then
        self._layer = requireLayerUI("guide_layer/GuideLayer").create()
        task:GetParent():addChild(self._layer, 99)
        -- self._type = global.UIZ.UI_FUNC
       
        -- GuideMediator.super.OpenLayer(self)
    end
    self._layer:OnUpdate(task)

    global.userInputController:setKeyboardAble(false)
end

function GuideMediator:OnClose()
    if not self._layer then
        return false
    end
    if tolua.isnull(self._layer) then
        self._layer = nil
        global.userInputController:setKeyboardAble(true)
        return false
    end

    -- remove
    self._layer:removeFromParent()
    self._layer = nil
    
    global.userInputController:setKeyboardAble(true)
end

return GuideMediator
