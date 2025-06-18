local RemoteProxy = requireProxy("remote/RemoteProxy")
local ReinAttrProxy = class("ReinAttrProxy", RemoteProxy)
ReinAttrProxy.NAME = global.ProxyTable.ReinAttrProxy

local cjson = require("cjson")

function ReinAttrProxy:ctor()
    ReinAttrProxy.super.ctor(self)

    self.m_nBonusPoint  = nil
    self._data          = {}
    self._nData         = {}        -- 新版各属性加点数据
    self._isNewBouns    = false     -- 是否启用新版
    self._bounsConfig   = {}        -- 新版属性点配置表
end

function ReinAttrProxy:RespReinData(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return false
    end
    -- dump(jsonData)
    self._data = jsonData
    self.m_nBonusPoint = jsonData.m_nBonusPoint

    global.Facade:sendNotification(global.NoticeTable.Player_Rein_Attr_Change)
    SLBridge:onLUAEvent(LUA_EVENT_REIN_ATTR_CHANGE)
end

function ReinAttrProxy:ResAddReinAttr(data, m_nBonusPoint)
    local jsonStr = cjson.encode(data)
    if not jsonStr then
        return nil
    end

    LuaSendMsg(global.MsgType.MSG_CS_REIN_ATTR_CONFIRM, m_nBonusPoint, 0, 0, 0, jsonStr, string.len(jsonStr))
end

function ReinAttrProxy:GetData()
    return self._data
end

function ReinAttrProxy:GetBonusAbilData()
    return self._data.BonusAbil
end

function ReinAttrProxy:GetBonusTickData()
    return self._data.BonusTick
end

function ReinAttrProxy:GetNakedAbilData()
    return self._data.NakedAbil
end

function ReinAttrProxy:GetAdjustAbilData()
    return self._data.m_AdjustAbil 
end

function ReinAttrProxy:GetBonusPoint()
    return self.m_nBonusPoint
end

------------------------------------- 新版 --------------------------------
function ReinAttrProxy:SetIsNewBouns(value)
    self._isNewBouns = value == true
end

function ReinAttrProxy:IsNewBouns()
    return self._isNewBouns
end

function ReinAttrProxy:LoadConfig()
    local GameConfigMgrProxy = global.Facade:retrieveProxy(global.ProxyTable.GameConfigMgrProxy)
    self._bounsConfig = GameConfigMgrProxy:getConfigByKey("cfg_bonus") or {}
end

function ReinAttrProxy:GetConfig()
    return self._bounsConfig
end

function ReinAttrProxy:GetNewAddData()
    return self._nData
end

function ReinAttrProxy:GetNewAddPointsById(id)
    if not self._nData or not id then
        return 0
    end
    for _, data in ipairs(self._nData) do
        if data.id == id then
            return data.value or 0
        end
    end
    return 0
end

function ReinAttrProxy:RespAddAttrData(msg)
    local msgHdr = msg:GetHeader()
    self.m_nBonusPoint = msgHdr.recog
    
    local jsonData = ParseRawMsgToJson(msg)
    if jsonData then
        dump(jsonData, "______RespAddAttrData")
        self._nData = jsonData
    end

    SLBridge:onLUAEvent(LUA_EVENT_REIN_ATTR_CHANGE)
end

function ReinAttrProxy:RequestAddReinAttr_N(data, m_nBonusPoint)
    local jsonStr = cjson.encode(data)
    if not jsonStr then
        return nil
    end

    print(jsonStr, "_____RequestAddReinAttr_N")
    LuaSendMsg(global.MsgType.MSG_CS_ADD_ATTR_CONFIRM, m_nBonusPoint, 0, 0, 0, jsonStr, string.len(jsonStr))
end

---------------------------------------------------------------------------

function ReinAttrProxy:RegisterMsgHandler()
    ReinAttrProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    LuaRegisterMsgHandler( msgType.MSG_SC_REIN_ATTR_RESPONSE, handler(self, self.RespReinData))
    LuaRegisterMsgHandler( msgType.MSG_SC_ADD_ATTR_RESPONSE, handler(self, self.RespAddAttrData))

end

return ReinAttrProxy
