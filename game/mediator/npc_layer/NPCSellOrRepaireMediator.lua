local BaseUIMediator = requireMediator("BaseUIMediator")
local NPCSellOrRepaireMediator = class("NPCSellOrRepaireMediator", BaseUIMediator)
NPCSellOrRepaireMediator.NAME = "NPCSellOrRepaireMediator"

function NPCSellOrRepaireMediator:ctor()
    NPCSellOrRepaireMediator.super.ctor(self)
    self._layer = nil
end

function NPCSellOrRepaireMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_NPC_Sell_Repaire_Open,
        noticeTable.Layer_NPC_Sell_Repaire_Close,
        noticeTable.Layer_NPC_Sell_Repaire_UpDate,
        noticeTable.Layer_NPC_Talk_Close,
        noticeTable.Layer_Moved_Begin,
        noticeTable.Bag_Oper_Data
    }
end

function NPCSellOrRepaireMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()
    if noticeName == notices.Layer_NPC_Sell_Repaire_Open then
        self:OpenLayer(noticeData)

    elseif noticeName == notices.Layer_NPC_Sell_Repaire_Close or noticeName == notices.Layer_NPC_Talk_Close then
        self:CloseLayer()

    elseif noticeName == notices.Layer_NPC_Sell_Repaire_UpDate then
        self:UpDateLayer(noticeData)

    elseif noticeName == notices.Layer_Moved_Begin then
        self:OnItemBeginMoving(noticeData)

    elseif noticeName == notices.Bag_Oper_Data then
        self:OnBagDataChange(noticeData)
    end
end

function NPCSellOrRepaireMediator:OpenLayer(noticeData)
    if not self._layer then
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Store_Close)
        self._layer = requireLayerUI("npc_layer/NpcSellOrRepaireLayer").create(noticeData)
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.NPCSellOrRepaire

        NPCSellOrRepaireMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

    local newBagPos = {
        x = 470,
        y = 20
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, {pos = newBagPos})
end

function NPCSellOrRepaireMediator:CloseLayer()
    if self._layer then
        local itemFrom = self._layer:GetLayerItemFrom()

        NPCSellOrRepaireMediator.super.CloseLayer(self)
        
        -- clean data
        local NPCSellProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCSellProxy)
        NPCSellProxy:ResetSellingState()
    
        local NPCRepaireProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCRepaireProxy)
        NPCRepaireProxy:ResetRepairingState()
    
        local NPCDoSomethingProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCDoSomethingProxy)
        NPCDoSomethingProxy:ResetDoSomethingState()
    
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel, { from = itemFrom })
        global.Facade:sendNotification(global.NoticeTable.Bag_Item_Pos_Change)
    end
end

function NPCSellOrRepaireMediator:UpDateLayer(data)
    if not data or not self._layer then
        return
    end
    self._layer:UpDateLayerParam(data)
end

function NPCSellOrRepaireMediator:OnItemBeginMoving(data)
    if data and next(data) and self._layer then
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        if data.from == ItemMoveProxy.ItemFrom.SELL
            or data.from == ItemMoveProxy.ItemFrom.REPAIRE
                or data.from == ItemMoveProxy.ItemFrom.NPC_DO_SOMETHING then
            self._layer:OnBeginMovingState()
        end
    end
end

function NPCSellOrRepaireMediator:OnBagDataChange(data)
    if not data or not next(data) or not self._layer then
        return
    end

    if data.opera == global.MMO.Operator_Sub then
        local itemList = data.operID or {}
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local makeIndex = BagProxy:GetOnSellOrRepaire()
        if makeIndex then
            for k, v in pairs(itemList) do
                if makeIndex == v.MakeIndex then
                    local NPCSellProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCSellProxy)
                    NPCSellProxy:ResetSellingState()

                    local NPCRepaireProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCRepaireProxy)
                    NPCRepaireProxy:ResetRepairingState()

                    local NPCDoSomethingProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCDoSomethingProxy)
                    NPCDoSomethingProxy:CleanOnDoData()
                end
            end
        end
    end
end

return NPCSellOrRepaireMediator