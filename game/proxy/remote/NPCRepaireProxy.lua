local RemoteProxy = requireProxy("remote/RemoteProxy")
local NPCRepaireProxy = class("NPCRepaireProxy", RemoteProxy)
NPCRepaireProxy.NAME = global.ProxyTable.NPCRepaireProxy

NPCRepaireProxy.STEP = {
    Waiting = 1,
    AddItem = 2,
    GetPrice = 3,
    HadPrice = 4,
    Repairing = 5,
    Repaired = 6
}

function NPCRepaireProxy:ctor()
    NPCRepaireProxy.super.ctor(self)
    self.repaireStep = NPCRepaireProxy.STEP.Waiting
    self.repairePrice = nil
end

function NPCRepaireProxy:SetOnRepairingData(data)
    self.onRepairingData = data

    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if data then
        self:SetRepaireStep(NPCRepaireProxy.STEP.AddItem)
        BagProxy:SetOnSellOrRepaire(data.MakeIndex)
    else
        self:SetRepaireStep(NPCRepaireProxy.STEP.Waiting)
        self:SetRepaireStep(nil)
        BagProxy:CleanOnSellOrRepaire()
    end
end

function NPCRepaireProxy:SetRepaireStep(step)
    if step then
        self.repaireStep = step
    end
end

function NPCRepaireProxy:GetRepaireStep()
    return self.repaireStep
end

function NPCRepaireProxy:SetRepairingPrice(price)
    self.repairePrice = price
end

function NPCRepaireProxy:RequestNpcStoreRepairePre(data)
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local npcId = NPCProxy:GetCurrentNPCID()
    if not data or not npcId then
        return
    end

    local step = self:GetRepaireStep()
    if step ~= NPCRepaireProxy.STEP.AddItem then
        return
    end

    local Name = data.Name
    local MakeIndex = data.MakeIndex

    LuaSendMsg(global.MsgType.MSG_CS_NPC_STORE_REPAIRE_PRE, npcId, MakeIndex, 0, 0, Name, string.len(Name))
    self:SetRepaireStep(NPCRepaireProxy.STEP.GetPrice)
end

function NPCRepaireProxy:RequestNpcStoreRepaire()
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local npcId = NPCProxy:GetCurrentNPCID()
    if not self.onRepairingData or not npcId then
        return
    end

    local step = self:GetRepaireStep()
    if step ~= NPCRepaireProxy.STEP.HadPrice then
        return
    end

    if not self:CheckItemIsCanRepaire() then
        return
    end

    local data = self.onRepairingData
    local Name = data.Name
    local MakeIndex = data.MakeIndex

    LuaSendMsg(global.MsgType.MSG_CS_NPC_STORE_REPAIRE_ITEM, npcId, MakeIndex, 0, 0, Name, string.len(Name))
    self:SetRepaireStep(NPCRepaireProxy.STEP.Repairing)
end

function NPCRepaireProxy:CheckItemIsCanRepaire()
    if self.repairePrice and self.repairePrice > 0 then
        return true

    else
        local data = {}
        data.str = GET_STRING(90030004)
        data.btnType = 1
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        self:ResetRepairingState()
        return false
    end
end

function NPCRepaireProxy:RepaireEndChangeItemData(itemMakeIndex, drua, makeDrua)
    if not itemMakeIndex then
        return
    end

    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local data = BagProxy:GetItemDataByMakeIndex(itemMakeIndex)
    if data and next(data) then
        data.Drua = drua or data.Dura
        data.MaxDrua = makeDrua or data.MaxDrua
        BagProxy:ChangeItemData(data)
    end
end

function NPCRepaireProxy:ResetRepairingState()
    self:SetOnRepairingData(nil)

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local data = {
        way = NPCProxy.EVENT_TYPE.REPAIRE,
        reset = true
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_UpDate, data)
end

--修理价格返回
local function handle_MSG_SC_NPC_REPAIRE_ITEM_PRICE(msg)
    local head = msg:GetHeader()
    if not head then
        return
    end
    local price = head.recog

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    local NPCRepaireProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCRepaireProxy)
    NPCRepaireProxy:SetRepairingPrice(price)
    NPCRepaireProxy:SetRepaireStep(NPCRepaireProxy.STEP.HadPrice)
    local data = {
        way = EVENT_TYPE.REPAIRE,
        price = price
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_UpDate, data)
end

local function handle_MSG_SC_NPC_REPAIRE_ITEM_RESULT_SUCCESS(msg)
    local header = msg:GetHeader()
    if not header then
        return
    end

    local MakeIndex = header.param1
    local drua = header.param2
    local maxDrua = header.param3

    local NPCRepaireProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCRepaireProxy)
    NPCRepaireProxy:RepaireEndChangeItemData(MakeIndex, drua, maxDrua)

    NPCRepaireProxy:ResetRepairingState()
end

local function handle_MSG_SC_NPC_REPAIRE_ITEM_RESULT_FAIL(msg)
    local header    = msg:GetHeader()
    local errorCode = header.recog      --错误
    if errorCode == -1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(90030005))
    end

    local NPCRepaireProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCRepaireProxy)
    NPCRepaireProxy:ResetRepairingState()
end

local function handle_MSG_SC_NPC_REPAIRE_ITEM(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    local data = {
        type = EVENT_TYPE.REPAIRE
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_Open, data)
end

function NPCRepaireProxy:RegisterMsgHandler()
    NPCRepaireProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    -- NPC修理道具打开返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_REPAIRE_ITEM, handle_MSG_SC_NPC_REPAIRE_ITEM)
    -- NPC商店修理失败返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_REPAIRE_ITEM_RESULT_FAIL, handle_MSG_SC_NPC_REPAIRE_ITEM_RESULT_FAIL)
    -- NPC商店修理成功返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_REPAIRE_ITEM_RESULT_SUCCESS, handle_MSG_SC_NPC_REPAIRE_ITEM_RESULT_SUCCESS)
    -- NPC商店修理道具预显示价格返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_REPAIRE_ITEM_PRICE, handle_MSG_SC_NPC_REPAIRE_ITEM_PRICE)
end

return NPCRepaireProxy