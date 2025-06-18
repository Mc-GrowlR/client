local BaseUIMediator = requireMediator("BaseUIMediator")
local PageStoreLayerMediator = class("PageStoreLayerMediator", BaseUIMediator)
PageStoreLayerMediator.NAME = "PageStoreLayerMediator"

function PageStoreLayerMediator:ctor()
    PageStoreLayerMediator.super.ctor(self)
    self._layer = nil
end

function PageStoreLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.Layer_PageStore_Open,
        noticeTable.Layer_PageStore_Close,
        noticeTable.Layer_PageStore_Refresh,
        noticeTable.PlayerMoneyChange,
    }
end

function PageStoreLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == noticeTable.Layer_PageStore_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == noticeTable.Layer_PageStore_Close then
        self:CloseLayer()
    elseif noticeName == noticeTable.Layer_PageStore_Refresh then
        self:UpdateStoreLayerByPage(noticeData)
    elseif noticeName == noticeTable.PlayerMoneyChange then
        self:RefreshMoney(noticeData)
    end
end

function PageStoreLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "page_store_layer/PageStoreLayer"
        if global.isWinPlayMode then
            path = "page_store_layer/PageStoreLayer_win32"
        end
        local layer = requireLayerUI(path).create(noticeData)
        self._type = global.UIZ.UI_NORMAL
        self._layer = layer

        noticeData.parent:addChild(layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        if noticeData.extent then
            self:DetachAllSUI(noticeData.extent)
        end
    else
        local nowPage = self._layer:GetNowPage()
        if noticeData.extent and noticeData.extent ~= nowPage then
            self._layer:ChangePage({ page = noticeData.extent })
            self:DetachAllSUI(noticeData.extent)
        end
    end
end

function PageStoreLayerMediator:CloseLayer()
    self:DetachAllSUI()

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function PageStoreLayerMediator:UpdateStoreLayerByPage(data)
    if self._layer then
        self._layer:UpdatePageLayer(data)
    end
end

function PageStoreLayerMediator:RefreshMoney(data)
    if self._layer then
        StorePage.RefreshMoney(data)
    end
end

function PageStoreLayerMediator:DetachAllSUI(attachId)
    for i = 1, 4 do
        local componentData =        {
            index = global.SUIComponentTable["PageStore" .. i]
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    end
    if attachId then
        local componentData =        {
            root = self._layer:GetSUIParent(),
            index = global.SUIComponentTable["PageStore" .. attachId]
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

return PageStoreLayerMediator