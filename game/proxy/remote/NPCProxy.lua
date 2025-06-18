local RemoteProxy = requireProxy("remote/RemoteProxy")
local NPCProxy = class("NPCProxy", RemoteProxy)
NPCProxy.NAME = global.ProxyTable.NPC

-- NPC打开出售修理
NPCProxy.EVENT_TYPE = {
    SELL        = 1,
    REPAIRE     = 2,
    DOSOMETHING = 3,
    NEWTYPE     = 4,
}

function NPCProxy:ctor()
    NPCProxy.super.ctor(self)

    self._currClickNPCID     = nil  --当前点击的npc id,  跨服之后服务端发送的Useid是本地的, 导致找不到npc, 只好本地记录一下
    self._currentBackground  = nil
    self._currentNPCTalkData = nil
    self._timerWidgets       = {}
    self._isClickCD          = false
end

function NPCProxy:CheckNpcTalkLayerClose(npcTypeIndex)
    if self:GetCurrentNPCIndex() == npcTypeIndex then
        self:Cleanup()
    end
end

function NPCProxy:GetCurrentNPCTalkData()
    return self._currentNPCTalkData
end

function NPCProxy:GetCurrentNPCID()
    if not self._currentNPCTalkData then
        return nil
    end
    return self._currentNPCTalkData.npcID
end

function NPCProxy:GetCurrentNPCIndex()
    if not self._currentNPCTalkData then
        return nil
    end
    return self._currentNPCTalkData.index
end

function NPCProxy:GetCurrentClickNPCID()
    return self._currClickNPCID
end

function NPCProxy:SetCurrentNPCTalkData(data)
    self._currentNPCTalkData = data
end

function NPCProxy:GetCurrentBackground()
    return self._currentBackground
end

function NPCProxy:SetCurrentBackground(data)
    self._currentBackground = data
end

function NPCProxy:ResetCurrentBackground()
    self._currentBackground = nil
end

function NPCProxy:Cleanup()
    self._currClickNPCID = nil
    self:ResetCurrentBackground()
    global.Facade:sendNotification(global.NoticeTable.SUIITEMBOXPutoutAll)
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Talk_Close)
end

function NPCProxy:ExecuteWithCommonInput(jsonData)
    local sendData = {
        UserID      = jsonData.UserID,
        Act         = jsonData.Act,
        commonInput = jsonData.commonInput,
        inputID     = jsonData.inputID,
    }
    self:ExecuteWithJsonData(sendData)
end

function NPCProxy:ExecuteWithJsonData(jsonData)
    local currNpcData = self:GetCurrentNPCTalkData()
    if currNpcData and currNpcData.index then
        jsonData.index = currNpcData.index
    end

    if jsonData.newIndex then
        jsonData.index = jsonData.newIndex
    end

    dump(jsonData)
    NPCEXECUTE_CLOCK = os.clock()
    SendTableToServer(global.MsgType.MSG_CS_NPC_TASK_CLICK, jsonData)
end

function NPCProxy:RequestNpcStoreItemList(data)
    local sendData = {
        UserID = self._currentNPCTalkData.npcID,
        Name = data.Name,
    }
    SendTableToServer(global.MsgType.MSG_CS_NPC_STORE_ITEM_LIST, sendData)
end

function NPCProxy:RequestNpcStoreBuy(data)
    local sendData = {
        UserID = self._currentNPCTalkData.npcID,
        Name = data.Name,
        MakeIndex = data.MakeIndex or 0
    }
    SendTableToServer(global.MsgType.MSG_CS_NPC_STORE_BUY, sendData)
end

function NPCProxy:RequestNpcMakeDrug(data)
    local sendData = {
        userid = self._currentNPCTalkData.npcID,
        name = data.name,
    }
    SendTableToServer(global.MsgType.MSG_CS_NPC_MAKE_DRUG, sendData)
end

local function handle_MSG_SC_NPC_TALK(msg)
    if NPCEXECUTE_CLOCK then
        print("NPC TALK RESP cost", os.clock() - NPCEXECUTE_CLOCK)
    end

    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    if not jsonData or not jsonData.sMsg then
        return
    end

    -- dump(jsonData)

    local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local nData    = {}
    nData.content = jsonData.sMsg
    nData.npcName = jsonData.Name
    nData.npcID    = jsonData.UserID
    nData.index    = jsonData.index

    -- Timer:id:remaining:content:x:y:anchor:colorID
    -- Timer:1:7200:秘境倒计时：%s:10:10:0:255
    -- Timer:1:0:秘境倒计时:%s
    if nData.content == "CloseNpcLayer" then
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Talk_Close)
        return
    end

    if string.find(nData.content, "<JumpTo:.->") then
        local find_info = { string.find(nData.content, "<JumpTo:(.-)>") }
        if find_info[1] and find_info[2] then
            local slices = string.split(find_info[3], ":")
            local jumpID = tonumber(slices[1])
            local close = (tonumber(slices[2]) == nil or tonumber(slices[2]) == 0)

            -- close npc talk
            if close then
                global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Talk_Close)
            end

            JUMPTO(jumpID)
        end

    else
        npcProxy:SetCurrentNPCTalkData(nData)
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Talk_Open)

        -- 同步至 SL框架
        SLBridge:onLUAEvent(LUA_EVENT_NPC_TALK, {id = jsonData.UserID, index = jsonData.index, name = jsonData.Name})
    end
end

local function handle_MSG_SC_NPC_TALK_BACKGROUND(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    dump(jsonData)

    local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    npcProxy:SetCurrentBackground(jsonData)
end

local function handle_MSG_SC_NPC_TALK_CLOSE(msg)
    print("local function handle_MSG_SC_NPC_TALK_CLOSE(msg) 644")
    local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    npcProxy:Cleanup()
end

local function handle_MSG_SC_NPC_STORE_OPEN(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Store_Open, jsonData)
end

local function handle_MSG_SC_NPC_STORE_ITEM_LIST(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    local itemList = {}
    for _, v in ipairs(jsonData) do
        local data = ChangeItemServersSendDatas(v)
        table.insert(itemList, data)
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Store_Open, {Items = itemList})
end

local function handle_MSG_SC_NPC_STORE_BUY_RESULT_FAIL(msg)
    local head = msg:GetHeader()
    if not head then
        return
    end

    if head.recog then
        local str = GET_STRING(90160009)
        if head.recog == 2 then
            str = GET_STRING(90160007)
        elseif head.recog == 3 then
            str = GET_STRING(90160008)
        elseif head.recog == 1 then
            str = GET_STRING(90160006)
        end

        local data   = {}
        data.str     = str
        data.btnDesc = { GET_STRING(1002) }
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    end
end

local function handle_MSG_SC_NPC_STORE_BUY_RESULT_SUCCESS(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    dump(jsonData)

    local MakeIndex = jsonData.MakeIndex
    if MakeIndex and MakeIndex ~= 0 then
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Store_Item_Remove, MakeIndex)
    end
end

local function handle_MSG_SC_NPC_MAKE_DRUG_LIST(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Make_Drug_Open, jsonData)
end

local function handle_MSG_SC_NPC_MAKE_DRUG_SUCCESS(msg)
    local head = msg:GetHeader()
    if not head then
        return
    end

    local data   = {}
    data.str     = GET_STRING(90160001)
    data.btnDesc = { GET_STRING(1002) }
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

local function handle_MSG_SC_NPC_MAKE_DRUG_FAILED(msg)
    local head = msg:GetHeader()
    if not head then
        return
    end

    if head.recog then
        local tips = true
        local data = {}
        data.btnDesc = { GET_STRING(1002) }
        if head.recog == 1 then
            data.str = GET_STRING(90160002)
        elseif head.recog == 2 then
            data.str = GET_STRING(90160003)
        elseif head.recog == 3 then
            data.str = GET_STRING(90160004)
        elseif head.recog == 4 then
            data.str = GET_STRING(90160005)
        else
            tips = false
        end

        if tips then
            global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        end
    end
end

function NPCProxy:handle_MSG_SC_PROGRESS_BAR(msg)
    global.Facade:sendNotification(global.NoticeTable.Layer_ProgressBar_Close)

    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_ProgressBar_Open, jsonData)
end

function NPCProxy:RequestTalk(npcID)
    print("talk to NPC", npcID)
    NPCEXECUTE_CLOCK = os.clock()

    self:ResetCurrentBackground()

    local npc = global.npcManager:FindOneNpcInCurrViewFieldById(npcID)
    if npc then
        self._currClickNPCID = npcID

        local typeIndex = npc:GetTypeIndex()

        local sendData = {
            UserID = npcID,
            index = typeIndex,
        }
        SendTableToServer(global.MsgType.MSG_CS_NPC_CLICK, sendData)

        dump(sendData)

        global.Facade:sendNotification(global.NoticeTable.Audio_Play, { type = global.MMO.SND_TYPE_NPC_TALK, index = typeIndex })

        -- SL
        local talkData = 
        {
            UserID = npcID,
            index = typeIndex,
            name = npc:GetName()
        }
        SLBridge:onLUAEvent(LUA_EVENT_TALKTONPC, talkData)
    end
end

function NPCProxy:CheckTalk(npcID, isAuto)
    -- 摆摊
    if false == CheckCanDoSomething() then
        return nil
    end

    -- NPC点击间隔，只有手动生效
    if not isAuto then
        if self._isClickCD then
            return nil
        end

        local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        local clickInterval = mapProxy:GetClickNpcSpeed() * 0.001
        if clickInterval and clickInterval > 0 then
            self._isClickCD = true
            PerformWithDelayGlobal(function()
                self._isClickCD = false
            end, clickInterval)
        end
    end

    -- 现在点击即可打开NPC
    local npc = global.npcManager:FindOneNpcInCurrViewFieldById(npcID)
    if npc then
        self:RequestTalk(npcID)
    end
end

function NPCProxy:RequestNotifyTalkOpen(talkLayerID)
    if not talkLayerID or "" == talkLayerID then
        return nil
    end

    print("---------------RequestNotifyTalkOpen", talkLayerID)

    SendTableToServer(global.MsgType.MSG_CS_NPC_TALK_OPEN_NOTIFY, {layerid = talkLayerID})
end

function NPCProxy:RequestNotifyTalkClose(talkLayerID)
    if not talkLayerID or "" == talkLayerID then
        return nil
    end

    print("---------------RequestNotifyTalkClose", talkLayerID)

    SendTableToServer(global.MsgType.MSG_CS_NPC_TALK_CLOSE_NOTIFY, {layerid = talkLayerID})
end

function NPCProxy:RegisterMsgHandler()
    NPCProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    -- NPC 对话数据(以及任务)
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_TALK, handle_MSG_SC_NPC_TALK)
    -- NPC 对话框背景数据
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_TALK_BACKGROUND, handle_MSG_SC_NPC_TALK_BACKGROUND)
    -- NPC 关闭NPC面板
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_TALK_CLOSE, handle_MSG_SC_NPC_TALK_CLOSE)
    -- 打开NPC商店
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_STORE_OPEN, handle_MSG_SC_NPC_STORE_OPEN)
    -- NPC商店道具列表返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_STORE_ITEM_LIST, handle_MSG_SC_NPC_STORE_ITEM_LIST)
    -- NPC商店购买失败返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_STORE_BUY_RESULT_FAIL, handle_MSG_SC_NPC_STORE_BUY_RESULT_FAIL)
    -- NPC商店购买成功返回
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_STORE_BUY_RESULT_SUCCESS, handle_MSG_SC_NPC_STORE_BUY_RESULT_SUCCESS)
    -- 打开NPC 炼药
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_MAKE_DRUG_LIST, handle_MSG_SC_NPC_MAKE_DRUG_LIST)
    -- NPC 炼药成功
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_MAKE_DRUG_SUCCESS, handle_MSG_SC_NPC_MAKE_DRUG_SUCCESS)
    -- NPC 炼药失败
    LuaRegisterMsgHandler(msgType.MSG_SC_NPC_MAKE_DRUG_FAILED, handle_MSG_SC_NPC_MAKE_DRUG_FAILED)
    -- NPC 进度条
    LuaRegisterMsgHandler(msgType.MSG_SC_PROGRESS_BAR, handler(self, self.handle_MSG_SC_PROGRESS_BAR))
end

return NPCProxy