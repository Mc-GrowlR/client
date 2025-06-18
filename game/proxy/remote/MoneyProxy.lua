local RemoteProxy = requireProxy( "remote/RemoteProxy" )
local MoneyProxy = class( "MoneyProxy", RemoteProxy )
MoneyProxy.NAME = global.ProxyTable.MoneyProxy

local MoneyType = {
    Gold = 1,
    YuanBao = 2,
    BindYuanBao = 4,
    Exp = 6
}

function MoneyProxy:ctor()
    MoneyProxy.super.ctor( self )
    self.isInit = true
    self.moneyConfig = {}
    self.moneyData = {}
    self.GoldType = 1 -- 金币类型ID 唯一值
    self.noShowList = {}
    self.noSoundList = {}
end

function MoneyProxy:onRegister()
    MoneyProxy.super.onRegister(self)
end

function MoneyProxy:InitMoneyConfig( data )
    for k,v in pairs(data) do
        self.moneyConfig[v.Id] = v
        self.moneyData[v.Id] = v
    end
end

function MoneyProxy:GetMoneyConfigById( id )
    return self.moneyConfig[id]
end

function MoneyProxy:GetMoneyNameById( id )
    local data = self:GetMoneyConfigById( id )
    local name = data and data.Name
    return name
end

function MoneyProxy:GetMoneyIdByName( name )
    local id = nil
    for k,v in pairs(self.moneyConfig) do
        if v.Name == name then
            id = v.Id
            break
        end
    end
    return id
end

function MoneyProxy:GetMoneyDataById( id )
    return self.moneyData[id]
end

function MoneyProxy:GetMoneyCountById( id , famlilar)
    local data = self:GetMoneyDataById( id )
    if not data then
        print("*************************")
        print("  money Type is nil ")
        print("*************************")
        return 0
    end
    local count = data.Count or 0
    if famlilar then 
        local ItemConfigProxy = global.Facade:retrieveProxy( global.ProxyTable.ItemConfigProxy )
        local moneys =  ItemConfigProxy:GetSameReservedByMoneyIndex(id)
        for i, v in ipairs(moneys) do
            local otherMoney  = self:GetMoneyDataById( v )
            count = count + (otherMoney.Count or 0)
        end
    end
    return count
end

function MoneyProxy:GetGoldType()
    return self.GoldType
end

function MoneyProxy:GetMoneyType()
    return MoneyType
end

function MoneyProxy:UpdateMoneyData( data, init)
    for k,v in pairs(data) do
        if self.moneyData[v.ID] then
            v.Value =  v.Value or 0
            local baseValue = self.moneyData[v.ID].Count or 0
            local diff = v.Value - baseValue
            if diff ~= 0 or self.isInit then
                self.moneyData[v.ID].Count = v.Value
                local changeData = {
                    id = v.ID,
                    count = v.Value
                }
                if v.ID ~= MoneyType.Exp then -- 经验就不广播了
                    global.Facade:sendNotification( global.NoticeTable.PlayerMoneyChange, changeData )
                    ssr.ssrBridge:OnPlayerMoneyChange(changeData)
                    SLBridge:onLUAEvent(LUA_EVENT_MONEYCHANGE, changeData)
                end
                -- init 外部加载数据
                if not init and not self.isInit and not self.noShowList[v.ID] then
                    local nData = {}
                    nData.name = self:GetMoneyDataById(v.ID).Name
                    nData.num   = math.abs(diff)
                    local notice = global.NoticeTable.ShowCostItem
                    if diff > 0 then
                        notice = global.NoticeTable.ShowGetBagItem
                    end
                    global.Facade:sendNotification( notice, nData )
                end

                if not init and not self.isInit and not self.noSoundList[v.ID] then
                    global.Facade:sendNotification( global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_MONEY} )
                end
            end
        end
    end
end

function MoneyProxy:InitNoShowItemList()
    local noShowString = SL:GetMetaValue("GAME_DATA","currency_shield") and string.split(SL:GetMetaValue("GAME_DATA","currency_shield"), "#")
    if noShowString and noShowString[1] and noShowString[1] ~= "" then
        local shield_list = string.split(noShowString[1],"|")
        for k,v in pairs(shield_list) do
            if tonumber(v) then
                self.noShowList[tonumber(v)] = 1
            end
        end
    end

    -- no sound 
    if noShowString and noShowString[2] and noShowString[2] ~= "" then
        local no_sound_list = string.split(noShowString[2],"|")
        for k,v in pairs(no_sound_list) do
            if tonumber(v) then
                self.noSoundList[tonumber(v)] = 1
            end
        end
    end
end

function MoneyProxy:handle_MSG_SC_INIT_MONEY_INFO(msg)
    local data = ParseRawMsgToJson(msg)
    if not data then
        return
    end
    self:InitMoneyConfig(data)
    -- 不能在注册的时候加载配置  因为注册时还没有拉到最新配置
    self:InitNoShowItemList()
end

function MoneyProxy:handle_MSG_SC_UPDATA_MONEY_NUMBER( msg )
    local data = ParseRawMsgToJson(msg)
    if not data then
        return
    end

    self:UpdateMoneyData(data)

    if self.isInit then
        self.isInit = false
    end
end

function MoneyProxy:ResetInitStatus()
    self.isInit = true
end

function MoneyProxy:RegisterMsgHandler()
    MoneyProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    -- 根据页签返回页签数据
    LuaRegisterMsgHandler( msgType.MSG_SC_INIT_MONEY_INFO, handler( self, self.handle_MSG_SC_INIT_MONEY_INFO) )
    -- 刷新角色货币
    LuaRegisterMsgHandler( msgType.MSG_SC_UPDATA_MONEY_NUMBER,  handler( self, self.handle_MSG_SC_UPDATA_MONEY_NUMBER) )    
end

return MoneyProxy