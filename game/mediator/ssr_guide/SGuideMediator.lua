local BaseUIMediator = requireMediator("BaseUIMediator")
local SGuideMediator = class("SGuideMediator", BaseUIMediator)
SGuideMediator.NAME = "SGuideMediator"

function SGuideMediator:ctor()
    SGuideMediator.super.ctor(self)

    self._task = nil
end

function SGuideMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_SGuide_Open,
        noticeTable.Layer_SGuide_Close,
        noticeTable.Layer_Bag_ResetPos,
        noticeTable.GuideLayerResetPos
    }
end

function SGuideMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_SGuide_Open == name then
        self:OnOpen(data)
    elseif noticeTable.Layer_SGuide_Close == name then
        self:OnClose()
    elseif noticeTable.Layer_Bag_ResetPos == name or noticeTable.GuideLayerResetPos == name then
        self:OnUpdate()
    end
end
function SGuideMediator:OnUpdate()
    if tolua.isnull(self._layer) then
        self._layer = nil
    end
    if self._layer then
        self._layer:OnUpdate()
    end
    
end
function SGuideMediator:OnOpen(task)
     if tolua.isnull(self._layer) then
        self._layer = nil
    end
    if (not self._layer) then
        self._layer = requireLayerUI("guide_layer/SGuideLayer").create()
        if task._mainType then
            local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
            if not MainRootMediator._layer then
                return nil
            end
            local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
            parent:addChild(self._layer, 999)
        else
            task:GetParent():addChild(self._layer, 999)
            self._layer:setGlobalZOrder(999)
        end
        -- self._type = global.UIZ.UI_MOUSE
        -- SGuideMediator.super.OpenLayer(self)
    end
    self._layer:OnUpdate(task)

    global.userInputController:setKeyboardAble(false)
end

function SGuideMediator:OnClose()
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

return SGuideMediator
