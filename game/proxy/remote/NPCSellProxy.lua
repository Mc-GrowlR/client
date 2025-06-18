local RemoteProxy = requireProxy("remote/RemoteProxy")
local NPCSellProxy = class("NPCSellProxy", RemoteProxy)
NPCSellProxy.NAME = global.ProxyTable.NPCSellProxy

NPCSellProxy.STEP = {
    Waiting = 1,
    AddItem = 2,
    GetPrice = 3,
    HadPrice = 4,
    Selling = 5,
    Selled = 6
}

function NPCSellProxy:ctor()
    NPCSellProxy.super.ctor(self)
    self.onSellingData = nil
    self.sellStep = NPCSellProxy.STEP.Waiting
    self.sellPrice = nil
    self.itemFrom = nil
end

function NPCSellProxy:SetOnSellingData(data)
    self.onSellingData = data

    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if data then
        self:SetSellingStep(NPCSellProxy.STEP.AddItem)
        BagProxy:SetOnSellOrRepaire(data.MakeIndex)
    else
        self:SetSellingStep(NPCSellProxy.STEP.Waiting)
        self:SetSellingFrom(nil)
        BagProxy:CleanOnSellOrRepaire()
    end
end

function NPCSellProxy:SetSellingStep(step)
    if step then
        self.sellStep = step
    end
end

function NPCSellProxy:GetSellingStep()
    return self.sellStep
end

function NPCSellProxy:SetSellingFrom(from)
    self.itemFrom = from
end

function NPCSellProxy:GetSellingFrom()
    return self.itemFrom
end

function NPCSellProxy:SetSellingPrice(price)
    self.sellPrice = price
end

function NPCSellProxy:RequestNpcStoreSellPre(data)
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local npcId = NPCProxy:GetCurrentNPCID()
    if not data or not npcId then
        return
    end
    local step = self:GetSellingStep()
    if step ~= NPCSellProxy.STEP.AddItem then
        return
    end
    local Name = data.Name
    local MakeIndex = data.MakeIndex

    LuaSendMsg(global.MsgType.MSG_CS_NPC_STORE_SELL_PRE, npcId, MakeIndex, 0, 0, Name, string.len(Name))
    self:SetSellingStep(NPCSellProxy.STEP.GetPrice)
end

function NPCSellProxy:RequestNpcStoreSell()
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local npcId = NPCProxy:GetCurrentNPCID()
    if not self.onSellingData or not npcId then
        return
    end
    local step = self:GetSellingStep()
    if step ~= NPCSellProxy.STEP.HadPrice then
        return
    end
    if not self:CheckItemIsCanSell() then
        return
    end
    local data = self.onSellingData
    local Name = data.Name
    local MakeIndex = data.MakeIndex

    LuaSendMsg(global.MsgType.MSG_CS_NPC_STORE_SELL_ITEM, npcId, MakeIndex, 0, 0, Name, string.len(Name))
    self:SetSellingStep(NPCSellProxy.STEP.Selling)
end

function NPCSellProxy:CheckItemIsCanSell()
    if self.sellPrice and self.sellPrice > 0 then
        return true
    else
        local data = {}
        data.str = GET_STRING(90030003)
        data.btnType = 1
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        self:ResetSellingState()
        return false
    end
end

function NPCSellProxy:ResetSellingState()
    self:SetOnSellingData(nil)
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    local data = {
        way = EVENT_TYPE.SELL,
        reset = true
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_UpDate, data)
end

-- 出售价格返回
local function handle_MSG_SC_NPC_STORE_SELL_PRICE(msg)
    local head = msg:GetHeader()
    if not head then
        return
    end

    local price = head.recog
    local NPCSellProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCSellProxy)
    NPCSellProxy:SetSellingPrice(price)
    NPCSellProxy:SetSellingStep(NPCSellProxy.STEP.HadPrice)

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    local data = {
        way = EVENT_TYPE.SELL,
        price = price
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_UpDate, data)
end

local function handle_MSG_SC_NPC_STORE_SELL_RESULT_FAIL(msg)
    local NPCSellProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCSellProxy)
    NPCSellProxy:ResetSellingState()
end

local function handle_MSG_SC_NPC_STORE_SELL_RESULT_SUCCESS(msg)
    local NPCSellProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCSellProxy)
    NPCSellProxy:ResetSellingState()
end

local function handle_MSG_SC_NPC_SELL(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    local data = {
        type = EVENT_TYPE.SELL
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_Open, data)
end

function NPCSellProxy:RegisterMsgHandler()
    NPCSellProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    -- NPC出售
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_SELL, handle_MSG_SC_NPC_SELL)
    -- NPC商店出售道具预显示价格返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_STORE_SELL_PRICE, handle_MSG_SC_NPC_STORE_SELL_PRICE)
    -- NPC商店出售失败返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_STORE_SELL_RESULT_FAIL, handle_MSG_SC_NPC_STORE_SELL_RESULT_FAIL)
    -- NPC商店出售成功返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_STORE_SELL_RESULT_SUCCESS, handle_MSG_SC_NPC_STORE_SELL_RESULT_SUCCESS)
end

return NPCSellProxy