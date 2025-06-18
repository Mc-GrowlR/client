local BaseLayer = requireLayerUI("BaseLayer")
local PageStoreLayer = class("PageStoreLayer", BaseLayer)

function PageStoreLayer:ctor()
    PageStoreLayer.super.ctor(self)
    self.page = 1
end

function PageStoreLayer.create( ... )
    local layer = PageStoreLayer.new()
    if layer:Init( ... ) then
        return layer
    else
        return nil
    end
end

function PageStoreLayer:Init( data )
    self.page = data.extent
    self._ui = ui_delegate(self)

    return true
end

function PageStoreLayer:InitUI()
    self:ChangePage({page = self.page, init = true})
end

function PageStoreLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_STORE_PAGE)
    StorePage.main()

    self.itemList = self._ui.ScrollView_list

    self:InitUI()
end

function PageStoreLayer:GetNowPage()
    return self.page
end

function PageStoreLayer:ChangePage( param )
    local lastPage = self.page
    local isInit = param.init
    local page = param.page
    if not isInit and (not page or lastPage == page)  then
        return
    end

    self.page = page
    self._ui.ScrollView_list:removeAllChildren()

    global.Facade:sendNotification(global.NoticeTable.Layer_StoreBuy_Close)

    local PageStoreProxy = global.Facade:retrieveProxy(global.ProxyTable.PageStoreProxy)
    PageStoreProxy:RequestPageData(self.page)
end

function PageStoreLayer:UpdatePageLayer(data)
    if not data or not data.page or data.page ~= self.page then
        return
    end
    local PageStoreProxy = global.Facade:retrieveProxy(global.ProxyTable.PageStoreProxy)
    local page = self.page
    local pageData = PageStoreProxy:GetPageData(page)

    StorePage.refreshStorePageUI(pageData)
    StorePage.InitMoneyCell()
end

function PageStoreLayer:CloseLayer()
    global.Facade:sendNotification(global.NoticeTable.Layer_PageStore_Close)
end

function PageStoreLayer:GetSUIParent()
    return self._ui.Panel_1
end

return PageStoreLayer
