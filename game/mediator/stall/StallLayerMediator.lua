local BaseUIMediator     = requireMediator("BaseUIMediator")
local StallLayerMediator = class('StallLayerMediator', BaseUIMediator)
StallLayerMediator.NAME  = "StallLayerMediator"


function StallLayerMediator:ctor()
    StallLayerMediator.super.ctor(self)
end

function StallLayerMediator:InitMultiPanel()
    self.GROUP_ID = 38
    self.super.InitMultiPanel(self)
end

function StallLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_StallLayer_Open,
        noticeTable.Layer_StallLayer_Close,
        noticeTable.Layer_StallLayer_ItemChange,
        noticeTable.Layer_StallLayer_SelfItemChange,
        noticeTable.Layer_StallLayer_StatusChange
    }
end

function StallLayerMediator:handleNotification(notification)
    local notices  = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_StallLayer_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_StallLayer_Close then
        self:CloseLayer()
    elseif noticeName == notices.Layer_StallLayer_ItemChange then
        self:UpdateBuyInfo()
    elseif noticeName == notices.Layer_StallLayer_SelfItemChange then
        self:UpdateStallLayerInfo()
    elseif noticeName == notices.Layer_StallLayer_StatusChange then
        self:OnStallStateDataChange(noticeData)
    end
end

function StallLayerMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "stall_layer/StallLayer"
        self._layer = requireLayerUI(path).create(noticeData)
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.StallLayerGUI

        StallLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI(noticeData)
        global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, {pos = {x = 0, y = 0}})

        LoadLayerCUIConfig(global.CUIKeyTable.BAITAN, self._layer)
    else
        local nowOpened = self._layer:GetNowStatus()
        local openStatus = noticeData and noticeData.buy or false
        if openStatus ~= nowOpened then
            self:CloseLayer(true)
            self:OpenLayer(noticeData)
        end
    end
end

function StallLayerMediator:CloseLayer(isReOpen)
    if self._layer then
        local nowOpened = self._layer:GetNowStatus()
        if nowOpened == false and not isReOpen then
            local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
            StallProxy:CleanNowData()
        end
    end
    StallLayerMediator.super.CloseLayer(self)
end

function StallLayerMediator:UpdateStallLayerInfo()
    if self._layer then
        self._layer:UpdateStallLayerInfo()
    end
end

function StallLayerMediator:UpdateBuyInfo()
    if self._layer then
        self._layer:UpdateStallLayerInfo()
    end
end

function StallLayerMediator:OnStallStateDataChange(data)
    local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
    StallProxy:OnStallStateDataChange(data)
end

return StallLayerMediator

--endregion
