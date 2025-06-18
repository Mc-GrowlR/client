local RemoteProxy = requireProxy("remote/RemoteProxy")
local GoldBoxProxy = class("GoldBoxProxy", RemoteProxy)
GoldBoxProxy.NAME = global.ProxyTable.GoldBoxProxy

local cjson = require("cjson")

function GoldBoxProxy:ctor()
    GoldBoxProxy.super.ctor(self)
    self._CostConfig = {} --消耗数据
    self._ItemIndexData = {} --服务器发送的宝箱物品数据
    self._ItemData = {} --宝箱物品数据
    self._Config = {} --宝箱数据
    self._boxStdMode = 1 --宝箱的stdmode
    self._TotalopenTime = 1 --总的开启次数
    self._rewardIndex = 1 --奖励的index
    self._openTime = 0 --开启次数
    self._itemShow = {}
    self._StdMode = 110 
    self._SameBoxItem = {} --背包中相同宝箱的数据
    self._isHaveOpen = false
    self._boxClose = false
    self._boxMakeIndex = nil
    self._BoxData = {}
end

function GoldBoxProxy:RandomConfig(config )
    -- body
    local data = {}
    local index = 1
    while #config~=0 do
        local n=math.random(1,#config)
        if config[n]~=nil then
            if config[n].Index == 0 then 
                data[0] = config[n]
                table.remove(config,n)

            else
                data[index]=config[n]
                table.remove(config,n)
                index=index+1
            end
        end
    end
    return data
end

--获取开启总次数
function GoldBoxProxy:GetTotalOpenTime(  )  
    return self._TotalopenTime
end

--获取开启次数
function GoldBoxProxy:GetOpenTime( ... )
    -- body
    return self._openTime
end

--设置开启次数
function GoldBoxProxy:SetOpenTime( openTime )
    -- body
    self._openTime = openTime
end

--获取物品信息
function GoldBoxProxy:GetItemShow( index )
    -- body
    -- dump(self._itemShow)
    return self._itemShow[index]
end


--获取宝箱中物品的数据
function GoldBoxProxy:GetBoxItem( )
    -- body
    self._itemShow = {}
    local itemData = {}
    for i,v in ipairs(self._ItemData) do
        local data = string.split(v.reward,"#")
        table.insert(itemData,{id =tonumber(data[1]),number = tonumber(data[2]),isJipin = tonumber(data[3]) })
    end
    self._itemShow = itemData
end

--获取奖励
function GoldBoxProxy:GetRewardIndex( ... )
    -- body
    return self._rewardIndex
end

function GoldBoxProxy:IsHaveOpen( ... )
    -- body
    return self._isHaveOpen
end

function GoldBoxProxy:CheckMuchTime( ... )
    -- body
    if self._TotalopenTime - self._openTime >1 then 
        return true
    else 
        return false
    end
end

function GoldBoxProxy:CheckHaveOpenTime( ... )
    -- body
    print("可重摇次数 === ",self._TotalopenTime)
    print("已重摇次数 === ",self._openTime)
    if self._TotalopenTime - self._openTime >=1 then 
        return true
    else 
        return false
    end
end

function GoldBoxProxy:getLeftOpenTime( ... )
    -- body
    return self._TotalopenTime - self._openTime
end

function GoldBoxProxy:setBoxItemData(data)
    self._BoxData = data
end

function GoldBoxProxy:setRefreshBoxItemData(data)
    self._newBoxData = data
end

function GoldBoxProxy:RequsetOpenBoxAgain( ... )
    LuaSendMsg( global.MsgType.MSG_SC_OPEN_TREASUREBOX_AGAIN)
end

function GoldBoxProxy:RequsetGetBoxReward( ... )
    LuaSendMsg( global.MsgType.MSG_SC_TREASUREBOX_REWARD)
end

function GoldBoxProxy:ResponsGetBoxItemInfo( msg )
    -- body
    print("===========MSG_CS_TREASUREBOX_INFO===============")
    local msgheader = msg:GetHeader()
    dump(msg:GetHeader())
    local data = ParseRawMsgToJson(msg)
    if msgheader.param1 == 1 then
        -- dump(data)
        if self._BoxData and next(self._BoxData)~=nil then 
            -- dump(self._BoxData)
            local bagdata = {
                    storage = {
                        MakeIndex = self._BoxData.MakeIndex,
                        state = 1
                    }
                }
            
            global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, bagdata)
            self._BoxData = {}
        end
        if msgheader.param2 == 0 then 
            self._TotalopenTime = 1
        else
            self._TotalopenTime = msgheader.param2
        end
        self._Config = self:RandomConfig(data)
        -- global.Facade:sendNotification(global.NoticeTable.Layer_Treasure_Box_Close)
        global.Facade:sendNotification(global.NoticeTable.Layer_Treasure_Box_Refresh,self._Config)
    elseif msgheader.param1 == 2 then 
        if msgheader.recog == 0 then
            self._openTime = self._openTime+1
            local rewardindex = 1
            for k,v in pairs(self._Config) do
                if msgheader.param2 == v.Index then 
                    rewardindex = k
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_Gold_Box_Open_Anim,rewardindex)
        end
    elseif msgheader.param1 == 3 then 
        if msgheader.recog == 0 then 
            self._BoxData = {}
            self._openTime = 0
            global.Facade:sendNotification(global.NoticeTable.Layer_Gold_Box_Close)
            if self._newBoxData and next(self._newBoxData) then
                self._BoxData = self._newBoxData
                self._newBoxData = nil
            end
        end
    end
end

function GoldBoxProxy:onRegister()
    GoldBoxProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler( msgType.MSG_CS_TREASUREBOX_INFO,handler( self, self.ResponsGetBoxItemInfo))
end
return GoldBoxProxy