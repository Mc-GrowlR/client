local RemoteProxy = requireProxy("remote/RemoteProxy")
local NPCNewTypeOkProxy = class("NPCNewTypeOkProxy", RemoteProxy)
NPCNewTypeOkProxy.NAME = global.ProxyTable.NPCNewTypeOkProxy

NPCNewTypeOkProxy.STEP = {
    Waiting = 1,
    AddItem = 2,
    DoThings = 3,
    Done = 4
}

function NPCNewTypeOkProxy:ctor()
    NPCNewTypeOkProxy.super.ctor(self)
    self.onDoNewData = nil
    self.sellStep = NPCNewTypeOkProxy.STEP.Waiting
    self.sellPrice = nil
    self.doSomethingParam = {}
end

function NPCNewTypeOkProxy:SetonDoThingsData(data)
    self.onDoNewData = data

    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if data then
        self:SetDoThingsStep(NPCNewTypeOkProxy.STEP.AddItem)
        BagProxy:SetOnSellOrRepaire(data.MakeIndex)
    else
        self:SetDoThingsStep(NPCNewTypeOkProxy.STEP.Waiting)
        BagProxy:CleanOnSellOrRepaire()
    end
end

function NPCNewTypeOkProxy:SetDoSomethingParam(data)
    if data and next(data) then
        self.doSomethingParam = data
    else
        self.doSomethingParam = {}
    end
end

function NPCNewTypeOkProxy:GetDoSomethingParam()
    return self.doSomethingParam
end

function NPCNewTypeOkProxy:SetDoThingsStep(step)
    if step then
        self.sellStep = step
    end
end

function NPCNewTypeOkProxy:GetDoThingsStep()
    return self.sellStep
end

function NPCNewTypeOkProxy:RequestNpcNewTypeOk()
    if not self.onDoNewData then
        return
    end
    
    local step = self:GetDoThingsStep()
    if step ~= NPCNewTypeOkProxy.STEP.AddItem then
        return
    end

    local data = self.onDoNewData
    local MakeIndex = data.MakeIndex

    dump(MakeIndex)

    LuaSendMsg(global.MsgType.MSG_CS_NPC_NEWTYPE_OK, MakeIndex, 0, 0, 0)
end

function NPCNewTypeOkProxy:CleanOnDoData()
    self:SetonDoThingsData(nil)
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    local data = {
        way = EVENT_TYPE.NEWTYPE,
        reset = true
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_UpDate, data)
end

local function handle_MSG_SC_NPC_NEWTYPE_OK(msg)
    local NPCNewTypeOkProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCNewTypeOkProxy)
    
    local header = msg:GetHeader()
    if header.param1 > 0 then
        NPCNewTypeOkProxy:CleanOnDoData()
        return
    end

    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    dump(jsonData)

    NPCNewTypeOkProxy:SetDoSomethingParam(jsonData)

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local EVENT_TYPE = NPCProxy.EVENT_TYPE
    if tonumber(jsonData.Flag) ~= EVENT_TYPE.NEWTYPE then
        return
    end

    local data = {
        type = EVENT_TYPE.NEWTYPE
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_Open, data)
end

function NPCNewTypeOkProxy:RegisterMsgHandler()
    NPCNewTypeOkProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    -- NPC 自定义框
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_DOSOMETHING, handle_MSG_SC_NPC_NEWTYPE_OK)
end

return NPCNewTypeOkProxy