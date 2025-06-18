local BaseUIMediator = requireMediator("BaseUIMediator")
local AuctionWorldMediator = class('AuctionWorldMediator', BaseUIMediator)
AuctionWorldMediator.NAME = "AuctionWorldMediator"

function AuctionWorldMediator:ctor()
    AuctionWorldMediator.super.ctor(self)
end

function AuctionWorldMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AuctionWorld_Open,
        noticeTable.Layer_AuctionWorld_Close,
        noticeTable.AuctionItemListResp,
        noticeTable.AuctionItemListClear,
        noticeTable.AuctionWorldItemDel,
        noticeTable.AuctionWorldItemChange,
        noticeTable.AuctionWorldItemSearch,
    }
end

function AuctionWorldMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_AuctionWorld_Open == noticeID then
        self:OnOpen(data)

    elseif noticeTable.Layer_AuctionWorld_Close == noticeID then
        self:OnClose()

    elseif noticeTable.AuctionItemListResp == noticeID then
        self:OnAuctionItemListResp(data)
        
    elseif noticeTable.AuctionItemListClear == noticeID then
        self:OnAuctionItemListClear(data)

    elseif noticeTable.AuctionWorldItemDel == noticeID then
        self:OnAuctionWorldItemDel(data)

    elseif noticeTable.AuctionWorldItemChange == noticeID then
        self:OnAuctionWorldItemChange(data)

    elseif noticeTable.AuctionWorldItemSearch == noticeID then
        self:OnAuctionWorldItemSearchByName(data)
    end
end

function AuctionWorldMediator:OnOpen(data)
    if not (self._layer) then
        self._layer = requireLayerUI("auction_layer/AuctionWorldLayer").create(data)
        data.parent:addChild(self._layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.Panel_1,
            index = data.source == 0 and global.SUIComponentTable.AuctionWorld or global.SUIComponentTable.AuctionGuild
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function AuctionWorldMediator:OnClose()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionWorld
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionGuild
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    
    if not self._layer then
        return false
    end

    self._layer:removeFromParent()
    self._layer = nil
end

function AuctionWorldMediator:OnAuctionItemListResp(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionItemListResp(data)
end

function AuctionWorldMediator:OnAuctionItemListClear(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionItemListClear(data)
end

function AuctionWorldMediator:OnAuctionWorldItemDel(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionItemDel(data)
end

function AuctionWorldMediator:OnAuctionWorldItemChange(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionItemChange(data)
end

function AuctionWorldMediator:OnAuctionWorldItemSearchByName(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionWorldItemSearchByName(data)
end

return AuctionWorldMediator
