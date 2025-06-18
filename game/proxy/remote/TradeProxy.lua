local RemoteProxy = requireProxy("remote/RemoteProxy")
local TradeProxy = class("TradeProxy", RemoteProxy)
TradeProxy.NAME = global.ProxyTable.TradeProxy

local sformat = string.format
local bubbleId = 4

local cjson = require("cjson")

function TradeProxy:ctor()
    TradeProxy.super.ctor(self)

    self._data = {}
    self._data.isTrading = false
    self.mySelfLockState = false
    self.mySureLockState = false --自己的确认状态
    self.otherSureLockState = false --对方的确认状态

    self._items_data_myself = {} -- 所有的交易中装备属性 包括对方的
    self._items_myself_num = 0
    self._items_data_other = {}
    self._tradeList = {}
    self._gold_myself = 0
    self._gold_other = 0

    self._move_trade_confirmed = true --移动取消交易确认
end

function TradeProxy:Tips(str)
    if true then
        return
    end
    -- 发送到滚屏
    global.Facade:sendNotification(global.NoticeTable.SystemTips, str)

    local proxyChat = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local CHANNEL = proxyChat.CHANNEL
    local data = {}
    data.Msg = str
    data.ChannelId = CHANNEL.System
    global.Facade:sendNotification(global.NoticeTable.AddChatItem, data)
end

function TradeProxy:onRegister()
    TradeProxy.super.onRegister(self)
end

function TradeProxy:Cleanup()
    self._data.trader = nil -- 名字、等级、好友、公会
    self.mySelfLockState = false
    self.mySureLockState = false
    self.otherSureLockState = false
    self._tradeMoney = nil
end

function TradeProxy:GetTrader()
    return self._data.trader
end

function TradeProxy:IsTrading()
    return self._data.isTrading
end

function TradeProxy:GetSelfItemDataByMadeIndex(itemId)
    if not itemId then
        return
    end
    return self._items_data_myself[itemId]
end

function TradeProxy:SetSelfItemDataByItemId(itemId, item)
    if not itemId then
        return
    end
    if not item then
        self._items_myself_num = math.max(self._items_myself_num - 1, 0)
    else
        if not self._items_data_myself[itemId] then
            self._items_myself_num = self._items_myself_num + 1
        end
    end
    self._items_data_myself[itemId] = item
end

function TradeProxy:GetOtherItemDataByMadeIndex(itemId)
    if not itemId then
        return
    end
    return self._items_data_other[itemId]
end

function TradeProxy:SetOtherItemDataByItemId(itemId, item)
    if not itemId then
        return
    end
    self._items_data_other[itemId] = item
end

function TradeProxy:SetMyselfGoldNum(num)
    self._gold_myself = num or 0
end

function TradeProxy:SetOtherGoldNum(num)
    self._gold_other = num or 0
end

function TradeProxy:ClearItemData()
    self._items_data_myself = {}
    self._items_myself_num = 0
    self._items_data_other = {}
    self._gold_myself = 0
    self._gold_other = 0
    self.mySureLockState = false
    self.otherSureLockState = false
end

function TradeProxy:GetOtherItemData()
    return clone(self._items_data_other)
end

function TradeProxy:GetSelfItemData()
    return clone(self._items_data_myself)
end

function TradeProxy:GetSelfItemNum()
    return self._items_myself_num
end

function TradeProxy:GetSelfItemDataCount()
    local data = self:GetSelfItemData()
    local count = 0
    if not data or next(data) == nil then
        return count
    end
    for k, v in pairs(data) do
        if v and next(v) then
            count = count + 1
        end
    end
    return count
end

function TradeProxy:GetSelfGoldNum()
    return clone(self._gold_myself)
end

function TradeProxy:GetOtherGoldNum()
    return clone(self._gold_other)
end

function TradeProxy:GetTradeMoneyID()
    return self._tradeMoney
end

function TradeProxy:BagItemQuickAdd(itemData)
    if not itemData then
        return
    end

    local state = self:GetLockState()
    if state then
        return
    end

    local myTradeDataCount = self:GetSelfItemDataCount()
    if myTradeDataCount >= global.MMO.TRADE_MAX_ITEM_NUMBER then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(90180001))
        return
    end

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local MakeIndex = itemData.MakeIndex
    local Name = itemData.Name
    local isBind, isSelf, isMeetType = CheckItemisBind(itemData, ItemConfigProxy:GetBindArticleType().TYPE_NOTRADE)
    if isMeetType then
        local data = {}
        data.str = string.format(GET_STRING(90020014), Name)
        data.btnType = 1
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    else
        self:RequestPutInItem(MakeIndex, Name)
    end
end

function TradeProxy:TradeItemQuickPutOut(itemData)
    if not itemData then
        return
    end

    local state = self:GetLockState()
    if state then
        return
    end

    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if BagProxy:isToBeFull(true) then
        return
    end

    local MakeIndex = itemData.MakeIndex
    local Name = itemData.Name
    self:RequestPutOutItem(MakeIndex, Name)
end

function TradeProxy:GetLockState(noTips)
    local state = self:GetMySureLockState()
    if not noTips and state then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(90180010))
    end
    return state
end

function TradeProxy:GetMySureLockState()
    return self.mySureLockState
end

function TradeProxy:GetOtherSureLockState()
    return self.otherSureLockState
end

function TradeProxy:SetMySureLockState(state)
    self.mySureLockState = state
    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_MyStatusChange)
end

function TradeProxy:SetOtherSureLockState(state)
    self.otherSureLockState = state
    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_StatusChange)
end

function TradeProxy:CheckTradeRequest()
    local myLockState = self:GetMySureLockState()
    local otherLockState = self:GetOtherSureLockState()
    if not otherLockState or not myLockState then
        return false
    end
    return true
end

function TradeProxy:RespTradeResult(msg)
    --交易失败即弹窗
    --[[        
        -1 自己正在交易
        -2 玩家不在线
        -3 对方正在交易
        -4 距离

        -1 //对方离线不能交易
        -2 //对方不满足交易条件
        -3 //自己不满足交易条件
        -4 //玩家在黑名单不能交易
        -5 //自己正在交易­
        -6 //对方正在交易
        -7 //不能和自己交易
        -8 //距离太远不能交易
        -9 //自己在战斗状态不允许交易
        -10 //对方在战斗状态不允许交易
        -11 //自己死亡不能交易
        -12 //对方死亡不能交易
        -13 //对方没有设置允许交易
    ]]
    local header = msg:GetHeader()
    if header and next(header) then
        local errorType = header.recog

        local errorStr = GET_STRING(90020003)
        if errorType == -1 then
            errorStr = GET_STRING(90180004)
        elseif errorType == -2 then
            errorStr = GET_STRING(90180017)
        elseif errorType == -3 then
            errorStr = GET_STRING(90180011)
        elseif errorType == -4 then
            errorStr = GET_STRING(90180016)
        elseif errorType == -5 then
            errorStr = GET_STRING(90180003)
        elseif errorType == -6 then
            errorStr = GET_STRING(90180005)
        elseif errorType == -7 then
            errorStr = GET_STRING(90180018)
        elseif errorType == -8 then
            errorStr = GET_STRING(90180006)
        elseif errorType == -9 then
            errorStr = GET_STRING(90180019)
        elseif errorType == -10 then
            errorStr = GET_STRING(90180020)
        elseif errorType == -11 then
            errorStr = GET_STRING(90180021)
        elseif errorType == -12 then
            errorStr = GET_STRING(90180022)
        elseif errorType == -13 then
            errorStr = GET_STRING(90180024)
        end

        global.Facade:sendNotification(global.NoticeTable.SystemTips, errorStr)

        -- 清除旧数据
        self:Cleanup()
        self:ClearItemData()
        self._data.isTrading = false
        global.Facade:sendNotification(global.NoticeTable.Layer_Trade_Close)
    end

    self._move_trade_confirmed = true
end

function TradeProxy:RespTradingInfo(msg)
    local len = msg:GetDataLength()
    if len <= 0 then
        return
    end

    local tradeData = ParseRawMsgToJson(msg)
    local header = msg:GetHeader()
    local whoGetMessage = header.recog

    --[[        
        负数为错误码
        -1;   //交易条件不满足
        -2;   //距离太远不能交易
        -3;   //战斗状态不允许交易
        -4;   //离线不能交易
        -5;  //死亡不能交易
        -6;   //玩家在黑名单不能交易
    ]]
    if whoGetMessage ~= 1 then
        local tipsStr = nil
        if whoGetMessage == -1 then
            tipsStr = 90180011
        elseif whoGetMessage == -2 then
            tipsStr = 90180012
        elseif whoGetMessage == -3 then
            tipsStr = 90180013
        elseif whoGetMessage == -4 then
            tipsStr = 90180014
        elseif whoGetMessage == -5 then
            tipsStr = 90180015
        elseif whoGetMessage == -6 then
            tipsStr = 90180016
        end
        if tipsStr then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(tipsStr))
            return
        end
    end

    if not tradeData or not next(tradeData) then
        return
    end

    if whoGetMessage == 1 then

        self._tradeList[tradeData.UserID] = tradeData
        self._tradeMoney = header.param3

        local function callback()
            local count = self:getInviteCouont()
            if count == 1 then
                local function CommonTipsCallBack(bType, custom)
                    if bType == 1 then
                        self:RequestTrade(tradeData.UserID, tradeData.Name)
                    end
                end

                local data    = {}
                data.str      = string.format(GET_STRING(90020010), tradeData.Name)
                data.btnType  = 2
                data.callback = CommonTipsCallBack
                global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
                global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, { id = bubbleId, status = false })
            elseif count > 1 then
                local tipsData = {}
                tipsData.list = {}
                for _, v in pairs(self:GetInviteItems()) do
                    local data = {}              
                    data.str = string.format(GET_STRING(90020011), v.Name)

                    data.agreeCall = function()
                        self:RequestTrade(v.UserID, v.Name)
                    end

                    data.disAgreeCall = function()
                        self:RequestTrade(v.UserID, v.Name, true)
                        self:ClearInviteItemsById(v.UserID)
                        if self:getInviteCouont() == 0 then
                            global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, { id = bubbleId, status = false })
                        end
                    end
                    table.insert(tipsData.list, data)
                end

                local MainPropertyMediator = global.Facade:retrieveMediator("MainPropertyMediator")
                if MainPropertyMediator then
                    local node = MainPropertyMediator:GetBubbleButtonByID(bubbleId)
                    if node and not tolua.isnull(node) then
                        tipsData.pos = node:getWorldPosition()
                    end
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_CommonBubbleInfo_Open, tipsData)
            end
        end

        local function cancelCallBack()
            for _, v in pairs(self:GetInviteItems()) do
                self:RequestTrade(v.UserID, v.Name, true)
            end
            self:ClearInviteItems()
        end

        local data = {}
        data.id = bubbleId
        data.time = 30
        data.status = true
        data.callback = callback
        data.timeOverCB = cancelCallBack
        global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, data)
    end
end

function TradeProxy:GetInviteItems()
    return self._tradeList
end

function TradeProxy:getInviteCouont()
    local count = 0
    for _, v in pairs(self._tradeList) do
        count = count + 1
    end
    return count
end

function TradeProxy:ClearInviteItemsById(UserId)
    self._tradeList[UserId] = nil
end

function TradeProxy:ClearInviteItems()
    self._tradeList = {}

    -- 气泡
    local tipsData = {}
    tipsData.status = false
    tipsData.id = bubbleId
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, tipsData)
end

function TradeProxy:RespAcceptAll(msg)
    local data = ParseRawMsgToJson(msg)
    local header = msg:GetHeader()
    if data then
        -- 清除旧数据
        self:Cleanup()

        -- 字符串：对方名字
        local trader = {}
        trader.name = data.UserName
        trader.userId = data.UserID
        self._data.trader = trader

        self._tradeMoney = header.param3

        self:ClearItemData()
        self._data.isTrading = true

        global.Facade:sendNotification(global.NoticeTable.Layer_Trade_Open)
    end
end

function TradeProxy:RespTradingCancel(msg)
    local header = msg:GetHeader()
    local data = self:GetSelfItemData()
    
    -- 清除旧数据
    self:Cleanup()
    self:ClearItemData()
    self._data.isTrading = false
    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_Close)

    self._move_trade_confirmed = true
end

function TradeProxy:RespTraderMoneyChange(msg)
    local header = msg:GetHeader()

    if not header or not next(header) then
        return
    end

    self:SetOtherGoldNum(header.recog)

    local data = {}
    data.count = header.recog
    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_MoneyChange, data)
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, { type = global.MMO.SND_TYPE_MONEY })
end

function TradeProxy:RespMyselfMoneyChange(msg)
    local header = msg:GetHeader()

    local tradingNum = header.recog
    local nowGoldNum = header.param1

    self:SetMyselfGoldNum(tradingNum)

    local data = {
        count = tradingNum
    }

    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_MyMoneyChange, data)
end

function TradeProxy:RespMyselfMoneyChangeFail(msg)
    local header = msg:GetHeader()

    if not header or not next(header) then
        return
    end
    local tradingNum = header.recog
    local nowGoldNum = header.param1

    self:SetMyselfGoldNum(tradingNum)

    local data = {
        count = tradingNum
    }

    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_MyMoneyChange, data)
end

function TradeProxy:RespTraderItemPutIn(msg)
    --对方放入物品消息
    local header = msg:GetHeader()

    local itemData = ParseRawMsgToJson(msg)
    itemData = ChangeItemServersSendDatas(itemData)
    if itemData then
        self:SetOtherItemDataByItemId(itemData.MakeIndex, itemData)
        local data = {}
        data.way = 1
        global.Facade:sendNotification(global.NoticeTable.Layer_Trade_TraderItemChange, data)
    end
end

function TradeProxy:RespTraderItemPutOut(msg)
    --对方取出物品消息
    local header = msg:GetHeader()

    local MakeIndex = header.recog
    if MakeIndex and MakeIndex ~= 0 then
        self:SetOtherItemDataByItemId(MakeIndex, nil)
        local data = {}
        data.way = 1
        global.Facade:sendNotification(global.NoticeTable.Layer_Trade_TraderItemChange, data)
    end
end

function TradeProxy:RespMyselfItemPutInSuccess(msg)
    --自己放入物品结果
    local header = msg:GetHeader()

    if not header.recog then
        return
    end
    local MakeIndex = header.recog
    local data = {}
    data.way = 0
    data.MakeIndex = header.recog

    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local itemData = BagProxy:GetItemDataByMakeIndex(MakeIndex)

    BagProxy:DelItemData(itemData, true)

    self:SetSelfItemDataByItemId(MakeIndex, itemData)

    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_MyselfItemChange, data)
end

function TradeProxy:RespMyselfItemPutInFail(msg)
    local header = msg:GetHeader()
    if not header or not header.recog then
        return
    end
    local data = {
        trading = {
            MakeIndex = header.recog,
            state = 1
        }
    }
    global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
end

function TradeProxy:RespMyselfItemPutOutSuccess(msg)
    --自己取出物品结果
    local header = msg:GetHeader()

    if not header.recog then
        return
    end
    -- 扣掉交易中的
    local MakeIndex = header.recog
    local data = {}
    data.way = 0
    data.MakeIndex = MakeIndex

    self:SetSelfItemDataByItemId(MakeIndex, nil)

    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_MyselfItemChange, data)

    -- 背包中的重新刷出来
    local data = {
        trading = {
            MakeIndex = MakeIndex,
            state = 1
        }
    }
    global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
end

function TradeProxy:RespMyselfItemPutOutFail(msg)
    local header = msg:GetHeader()
    local data = {}
    data.way = 0
    data.MakeIndex = header.recog

    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_MyselfItemChange, data)

end

function TradeProxy:RespTraderStatusChange(msg)
    -- 收到对方状态改变: 参数1是类型 0取消锁定，1锁定
    local len = msg:GetDataLength()
    if len <= 0 then
        return
    end
    local msgData = msg:GetData()
    local sliceStr = msgData:ReadString(len)

    local header = msg:GetHeader()

    local data = ParseRawMsgToJson(msg)

    if not data then
        return
    end

    local UserId = data.uid
    local state = data.status
    if not UserId then
        return
    end
    local otherData = self:GetTrader()

    local myUid = global.gamePlayerController:GetMainPlayerID()
    if otherData and otherData.userId and UserId == otherData.userId then
        local status = state == 1 and true or false
        if not status then
            self.mySelfLockState = false
        end
        self:SetOtherSureLockState(status)
    elseif myUid == UserId then
        local status = state == 1 and true or false
        if not status then
            self.mySelfLockState = false
        end
        self:SetMySureLockState(status)
    end
end

function TradeProxy:RespTradeSuccess(msg)
    local myTradeData = self._items_data_myself
    if myTradeData and next(myTradeData) then
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        for k, v in pairs(myTradeData) do
            if v and next(v) then
                BagProxy:DelItemData(v, true)
            end
        end
    end

    self:ClearItemData()
    self._data.isTrading = false
    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_Close)

    self._move_trade_confirmed = true
end

function TradeProxy:RegisterMsgHandler()

    local msgType = global.MsgType

    -- 请求交易结果
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADE_TRADER_RESULT, handler(self, self.RespTradeResult))
    -- xx请求和你交易
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADE_INFO_RESPONSE, handler(self, self.RespTradingInfo))
    -- 打开交易界面
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_ACCEPT_ALL, handler(self, self.RespAcceptAll))
    -- (回复): 取消交易,关闭界面
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_CANCEL, handler(self, self.RespTradingCancel))
    -- (回复): 对方货币数量改变
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_TRADER_CHANGE_MONEY, handler(self, self.RespTraderMoneyChange))
    -- (回复): 自己货币数量改变
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_MYSELF_CHANGE_MONEY, handler(self, self.RespMyselfMoneyChange))
    -- (回复): 自己货币数量改变失败
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_MYSELF_CHANGE_MONEY_FAIL, handler(self, self.RespMyselfMoneyChangeFail))
    -- (回复): 对方交易物品放入
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_TRADER_PUTIN_ITEM, handler(self, self.RespTraderItemPutIn))
    -- (回复): 对方交易物品取出
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_TRADER_PUTOUT_ITEM, handler(self, self.RespTraderItemPutOut))
    -- (回复): 自己放入物品成功
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_MYSELF_PUTIN_ITEM_SUCCESS, handler(self, self.RespMyselfItemPutInSuccess))
    -- (回复): 自己放入物品失败
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_MYSELF_PUTIN_ITEM_FAIL, handler(self, self.RespMyselfItemPutInFail))
    -- (回复): 自己取回物品成功
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_MYSELF_PUTOUT_ITEM_SUCCESS, handler(self, self.RespMyselfItemPutOutSuccess))
    -- (回复): 自己取回物品失败
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_MYSELF_PUTOUT_ITEM_FAIL, handler(self, self.RespMyselfItemPutOutFail))
    -- (回复): 双方状态改变
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_LOCK_CHANGE_STATUS, handler(self, self.RespTraderStatusChange))
    -- (回复): 交易成功
    LuaRegisterMsgHandler(msgType.MSG_SC_TRADING_SUCCESSFUL, handler(self, self.RespTradeSuccess))
end

function TradeProxy:RequestTrade(uid, name, refuse)
    if not refuse and not CheckCanDoSomething() then
        return
    end
    local tradeTargetUid = 0
    local targetLen = 0
    if uid then
        tradeTargetUid = uid
        targetLen = string.len(uid)
    end
    if not refuse then
        self:ClearInviteItems()
    end
    local refuseStatus = refuse and 1 or 0
    LuaSendMsg(global.MsgType.MSG_CS_TRADING_INFO_REQUEST, refuseStatus, 0, 0, 0, tradeTargetUid, targetLen)
end

function TradeProxy:SendTradeRequest(uid, name)
    if not CheckCanDoSomething() then
        return
    end

    if self:IsTrading() then
        return
    end

    local tradeTargetUid = 0
    local targetLen = 0
    if uid then
        tradeTargetUid = uid
        targetLen = string.len(uid)
    end
    if CHECK_SERVER_OPTION(global.MMO.SERVER_OPTION_TRADE_DEAL) == true then
        LuaSendMsg(global.MsgType.MSG_CS_TRADE_SEND_REQUEST)
    else
        LuaSendMsg(global.MsgType.MSG_CS_TRADE_SEND_REQUEST, 0, 0, 0, 0, tradeTargetUid, targetLen)
    end
end

function TradeProxy:RequestCancle()
    -- 请求取消交易
    LuaSendMsg(global.MsgType.MSG_CS_TRADING_CANCEL)
end

function TradeProxy:RequestChangeMoney(count)
    -- 请求修改货币 ，参数1：数量
    LuaSendMsg(global.MsgType.MSG_CS_TRADING_MYSELF_CHANGE_MONEY, count, 0, 0, 0)
end

function TradeProxy:RequestPutInItem(itemID, itemName)
    -- 请求放入物品
    LuaSendMsg(global.MsgType.MSG_CS_TRADING_MYSELF_PUTIN_ITEM, itemID, 0, 0, 0, itemName, string.len(itemName))
end

function TradeProxy:RequestPutOutItem(itemID, itemName)
    -- 请求取出物品
    LuaSendMsg(global.MsgType.MSG_CS_TRADING_MYSELF_PUTOUT_ITEM, itemID, 0, 0, 0, itemName, string.len(itemName))
end

function TradeProxy:RequestTradeEnd()
    self.mySelfLockState = true
    LuaSendMsg(global.MsgType.MSG_CS_TRADING_TRADE, 0, 0, 0, 0)
end

function TradeProxy:RequestChangeLock()
    local nowState = self:GetMySureLockState()
    -- 主动请求改变自己锁定状态
    local changeStatus = not nowState and 1 or 0
    LuaSendMsg(global.MsgType.MSG_CS_CHANGE_MY_TRADE_STATE, changeStatus, 0, 0, 0)
end

function TradeProxy:CheckPlayerOut(userId)
    if self:IsTrading() then
        local trader = self._data and self:GetTrader()
        if userId and trader and trader.userId and userId == trader.userId then
            self:RequestCancle()
        end
    end
end

-- 主玩家移动  如果正在交易   直接取消
function TradeProxy:CheckPlayerMove()
    if self._move_trade_confirmed and self:IsTrading() then
        self._move_trade_confirmed = false
        self:RequestCancle()
    end
end

return TradeProxy