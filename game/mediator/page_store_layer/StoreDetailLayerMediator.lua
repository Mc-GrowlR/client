local BaseUIMediator = requireMediator("BaseUIMediator")
local StoreDetailLayerMediator = class("StoreDetailLayerMediator", BaseUIMediator)
StoreDetailLayerMediator.NAME  = "StoreDetailLayerMediator"

function StoreDetailLayerMediator:ctor()
    StoreDetailLayerMediator.super.ctor( self )
    self._layer = nil
end

function StoreDetailLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
             noticeTable.Layer_StoreBuy_Open,
             noticeTable.Layer_PageStore_Close,
             noticeTable.Layer_StoreBuy_Close,
            }
end

function StoreDetailLayerMediator:handleNotification(notification)
    local notices  = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()
    
    if noticeName == notices.Layer_StoreBuy_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_PageStore_Close or noticeName == notices.Layer_StoreBuy_Close then
        self:CloseLayer()
    end
end

function StoreDetailLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "page_store_layer/StoreDetailLayer"
        if global.isWinPlayMode then
            path = "page_store_layer/StoreDetailLayer_win32"
        end
        local layer = requireLayerUI(path).create(noticeData)
        self._type = global.UIZ.UI_NORMAL
        self._layer = layer
        self._resetPostion = {x=0,y=0}
        self._hideLast = false
        self._GUI_ID = SLDefine.LAYERID.StoreDetailGUI

        if noticeData and noticeData.adapet then
            self._adapet = true
        end

        StoreDetailLayerMediator.super.OpenLayer(self)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function StoreDetailLayerMediator:CloseLayer()
    StoreDetailLayerMediator.super.CloseLayer( self )
end

return StoreDetailLayerMediator
