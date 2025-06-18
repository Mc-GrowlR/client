local DebugMediator = requireMediator("DebugMediator")
local SSRUIManager = class("SSRUIManager", DebugMediator)
SSRUIManager.NAME = "SSRUIManager"

function SSRUIManager:ctor()
    SSRUIManager.super.ctor(self, self.NAME)

    self._allITEMBOXWidgets     = {}
    self._ITEMBOXItems          = {}
    
end

function SSRUIManager:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.SSR_ITEMBOXWidget_Add,
        noticeTable.SSR_ITEMBOXWidget_Remove,
        noticeTable.SSR_ITEMBOXWidget_Update,
        noticeTable.ReleaseMemory,
    }
end

function SSRUIManager:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.SSR_ITEMBOXWidget_Add == noticeID then
        self:OnSUIITEMBOXWidgetAdd(data)

    elseif noticeTable.SSR_ITEMBOXWidget_Remove == noticeID then
        self:OnSUIITEMBOXWidgetRemove(data)

    elseif noticeTable.SSR_ITEMBOXWidget_Update == noticeID then
        self:OnSUIITEMBOXWidgetUpdate(data)

    elseif noticeTable.ReleaseMemory == noticeID then
        self:OnReleaseMemory(data)
    end
end

function SSRUIManager:OnReleaseMemory(data)
    self._ITEMBOXItems = {}
end

function SSRUIManager:GetItemDataByboxIndex( boxindex )
    if not boxindex then return nil end
    return self._ITEMBOXItems[boxindex]
end

----------------------------
function SSRUIManager:OnSUIITEMBOXWidgetAdd(data)
    local boxindex = data.boxindex
    local widget   = data.widget

    -- 监听事件;
    widget:registerScriptHandler( function(state)
        if state == "enter" then
            self._allITEMBOXWidgets[boxindex] = widget
            self:ReloadITEMBOXWidget(boxindex)

        elseif state == "exit" then
            self:ReturnItemToBag(boxindex)

            self._ITEMBOXItems[boxindex] = nil
            self:ReloadITEMBOXWidget(boxindex)
            self._allITEMBOXWidgets[boxindex] = nil

        end
    end )
end

function SSRUIManager:OnSUIITEMBOXWidgetRemove(data)
    local boxindex = data.boxindex
    self._ITEMBOXItems[boxindex] = nil

    self:ReloadITEMBOXWidget(boxindex)
end

function SSRUIManager:OnSUIITEMBOXWidgetUpdate(data)
    
    if not data  or not next(data) then
        return nil
    end
    local boxindex  = data.boxindex
    local itemData  = data.itemData
    local updateAttr = data.updateData
    if updateAttr then
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local oriItemData = self._ITEMBOXItems[boxindex]
        if oriItemData and oriItemData.MakeIndex then
            itemData = BagProxy:GetItemDataByMakeIndex(oriItemData.MakeIndex)
        end
    else
        self:ReturnItemToBag(boxindex)
    end

    self._ITEMBOXItems[boxindex] = itemData

    -- 
    self:ReloadITEMBOXWidget(boxindex)
end

function SSRUIManager:ReloadAllITEMBOXWidgets()
    for boxindex, itemboxWidget in pairs(self._allITEMBOXWidgets) do
        self:ReloadITEMBOXWidget(boxindex)
    end
end

function SSRUIManager:ReloadITEMBOXWidget(boxindex)
    local itemboxWidget = self._allITEMBOXWidgets[boxindex]
    if nil == itemboxWidget then
        return nil
    end
    local itemData      = self._ITEMBOXItems[boxindex]
    if nil == itemData then
        itemboxWidget:removeChildByName("item")
        return nil
    end

    local contentSize = itemboxWidget:getContentSize()
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    -- 
    local info = {}
    info.index      = itemData.Index
    info.itemData   = itemData
    info.movable    = true
    info.look       = true
    info.from       = ItemMoveProxy.ItemFrom.SSR_ITEM_BOX
    local goodItem  = GoodsItem:create(info)
    itemboxWidget:removeChildByName("item")
    itemboxWidget:addChild(goodItem)
    goodItem:setName("item")
    goodItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
end

function SSRUIManager:GetITEMBOXIndexByMakeIndex(makeindex)
    for k, v in pairs(self._ITEMBOXItems) do
        if v.MakeIndex == makeindex then
            return k
        end
    end
    return nil
end

-- 刷回背包
function SSRUIManager:ReturnItemToBag( boxindex , itemData)
    if not boxindex then
        return
    end
    if self._ITEMBOXItems[boxindex] and self._ITEMBOXItems[boxindex].MakeIndex then
        if itemData and itemData.MakeIndex == self._ITEMBOXItems[boxindex].MakeIndex then
            return
        end
        local data = {
            storage = {
                MakeIndex = self._ITEMBOXItems[boxindex].MakeIndex,
                state = 1
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
    end
end

function SSRUIManager:onRegister()
    SSRUIManager.super.onRegister(self)
end

return SSRUIManager
