local RemoteProxy = requireProxy("remote/RemoteProxy")
local NPCDoSomethingProxy = class("NPCDoSomethingProxy", RemoteProxy)
NPCDoSomethingProxy.NAME = global.ProxyTable.NPCDoSomethingProxy

NPCDoSomethingProxy.STEP = {
    Waiting = 1,
    AddItem = 2,
    DoThings = 3,
    Done = 4
}

local cjson = require("cjson")

function NPCDoSomethingProxy:ctor()
    NPCDoSomethingProxy.super.ctor(self)
    self.onDoThingsData = nil
    self.sellStep = NPCDoSomethingProxy.STEP.Waiting
    self.sellPrice = nil
    self.doSomethingParam = {}
end

function NPCDoSomethingProxy:SetonDoThingsData(data)
    self.onDoThingsData = data

    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if data then
        self:SetDoThingsStep(NPCDoSomethingProxy.STEP.AddItem)
        BagProxy:SetOnSellOrRepaire(data.MakeIndex)

    else
        self:SetDoThingsStep(NPCDoSomethingProxy.STEP.Waiting)
        BagProxy:CleanOnSellOrRepaire()
    end
end

function NPCDoSomethingProxy:SetDoSomethingParam(data)
    if data and next(data) then
        self.doSomethingParam = data
    else
        self.doSomethingParam = {}
    end
end

function NPCDoSomethingProxy:GetDoSomethingParam()
    return self.doSomethingParam
end

function NPCDoSomethingProxy:SetDoThingsStep(step)
    if step then
        self.sellStep = step
    end
end

function NPCDoSomethingProxy:GetDoThingsStep()
    return self.sellStep
end

function NPCDoSomethingProxy:RequestNpcDoSomething()
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local npcId = NPCProxy:GetCurrentNPCID()
    if not self.onDoThingsData or not npcId then
        return
    end

    local step = self:GetDoThingsStep()
    if step ~= NPCDoSomethingProxy.STEP.AddItem then
        return
    end

    local param = self:GetDoSomethingParam()
    local flag = param.Flag or 0
    local recovery = param.Recovery
    local data = self.onDoThingsData
    local Name = data.Name
    local MakeIndex = data.MakeIndex
    local sendData = {
        Name = Name,
        Flag = flag,
        Recovery = recovery,
        MakeIndex = MakeIndex
    }
    local jsonStr = cjson.encode(sendData)
    LuaSendMsg(global.MsgType.MSG_CS_NPC_DOSOMETHING, npcId, 0, 0, 0, jsonStr, string.len(jsonStr))
end

function NPCDoSomethingProxy:ResetDoSomethingState()
    self:SetonDoThingsData(nil)
    self:SetDoSomethingParam(nil)

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    local data = {
        way = EVENT_TYPE.DOSOMETHING,
        reset = true
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_UpDate, data)
end

function NPCDoSomethingProxy:CleanOnDoData()
    self:SetonDoThingsData(nil)

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    local data = {
        way = EVENT_TYPE.DOSOMETHING,
        reset = true
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_UpDate, data)
end

local function handle_MSG_SC_NPC_DOSOMETHING(msg)
    local NPCDoSomethingProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCDoSomethingProxy)
   
    local header = msg:GetHeader()
    local param1 = header.param1
    if param1 > 0 then
        NPCDoSomethingProxy:CleanOnDoData()
        return
    end

    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    dump(jsonData)

    NPCDoSomethingProxy:SetDoSomethingParam(jsonData)
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    local data = {
        type = EVENT_TYPE.DOSOMETHING
    }
    if tonumber(jsonData.Flag) ~= EVENT_TYPE.DOSOMETHING then
        return
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_Open, data)
end

function NPCDoSomethingProxy:RegisterMsgHandler()
    NPCDoSomethingProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    -- NPC 自定义框
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_DOSOMETHING, handle_MSG_SC_NPC_DOSOMETHING)
end

return NPCDoSomethingProxy