--[[
    author:yzy
    time:2021-03-12 14:28:06
]]

local RemoteProxy = requireProxy( "remote/RemoteProxy" )
local SceneImprisonEffectProxy   = class( "SceneImprisonEffectProxy", RemoteProxy )
SceneImprisonEffectProxy.NAME    = global.ProxyTable.SceneImprisonEffectProxy


function SceneImprisonEffectProxy:ctor()
    SceneImprisonEffectProxy.super.ctor( self )

    self._effect_imprison = {}
end

--检测禁锢
function SceneImprisonEffectProxy:CheckImprison(x,y)
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if global.BuffManager:IsHaveOneBuff(mainPlayerID, global.MMO.BUFF_ID_UN_IMPRISON) then --已经有了防禁锢buff
        return false
    end

    local player                    = global.gamePlayerController:GetMainPlayer()
    local playerMapX, playerMapY    = player:GetMapX(), player:GetMapY()

    for _,data in pairs(self._effect_imprison) do
        local rect = {x=data.cPoint.x, y = data.cPoint.y, width = data.range, height = data.range}
        if math.abs( rect.x - playerMapX ) < rect.width and math.abs( rect.y - playerMapY ) < rect.height then --在框内
            if ( math.abs(x - rect.x) >= rect.width ) or ( math.abs(y - rect.y) >= rect.height ) then
                return true
            end
        else
            if ( math.abs(x - rect.x) < rect.width) and ( math.abs(y - rect.y) < rect.height ) then
                return true
            end
        end
    end
    return false
end

function SceneImprisonEffectProxy:AddImprison(data)
    if data and data.eventID then
        self._effect_imprison[data.eventID] = data
    end
end

function SceneImprisonEffectProxy:RmImprison(event_id)
    if event_id then
        self._effect_imprison[event_id] = nil
    end
end

function SceneImprisonEffectProxy:handle_MSG_SM_DURANCE_RESPONSE(msg)
    local msgHdr = msg:GetHeader()

    local nRecog = msgHdr.recog
    local msgLen = msg:GetDataLength()
    if msgLen > 0 then
        local dataString = msg:GetData():ReadString(msgLen)
        nRecog = tonumber(dataString)
    end
    local data = {}
    data.eventID            = nRecog
    data.cPoint             = {x = msgHdr.param1, y = msgHdr.param2}
    data.range              = msgHdr.param3

    self:AddImprison( data )
end

function SceneImprisonEffectProxy:onRegister()
    local msgType = global.MsgType

    LuaRegisterMsgHandler( msgType.MSG_SM_DURANCE_RESPONSE, handler( self, self.handle_MSG_SM_DURANCE_RESPONSE ) )

    SceneImprisonEffectProxy.super.onRegister( self )
end

return SceneImprisonEffectProxy