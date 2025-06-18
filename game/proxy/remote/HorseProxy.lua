local RemoteProxy = requireProxy("remote/RemoteProxy")
local HorseProxy = class("HorseProxy", RemoteProxy)
HorseProxy.NAME = global.ProxyTable.HorseProxy

local optionsUtils = requireProxy("optionsUtils")

function HorseProxy:ctor()
    HorseProxy.super.ctor( self )
end

-- 是否能施法
function HorseProxy:IsLaunch( skillID )
    local player = global.gamePlayerController:GetMainPlayer()
    if player and player:GetHorseMasterID() then
        if SL:GetMetaValue("GAME_DATA", "off_horse_launch") == 1 then
            return false
        end
        --魔法盾除外
        if skillID ~= 31 then
            return false
        end
    end
    return true
end

-- 请求下马
function HorseProxy:RequestHorseDown()
    if SL:GetMetaValue("GAME_DATA", "horse_down") == 1 then
        LuaSendMsg(global.MsgType.MSG_CS_HROSEDOWN)
        return true
    end
    return false
end

-- 邀请上马
function HorseProxy:RequestHorseUpInvite(uid)
    LuaSendMsg(global.MsgType.MSG_CS_HORSE_INVITE,0,0,0,0,uid,string.len(uid))
end

-- 同意上马邀请
function HorseProxy:RequestHorseUpInviteAgree(uid)
    LuaSendMsg( global.MsgType.MSG_CS_HORSE_AGREE,0,0,0,0,uid,string.len(uid))
end

-- 显示气泡
function HorseProxy:ShowHorseInviteBubbleTips( isShow,uid)
    local callback = function()
        self:RequestHorseUpInviteAgree(uid)

        self:ShowHorseInviteBubbleTips(false)
    end

    local data = {}
    data.id = 14
    data.status = isShow == true
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, data)
end

--------------服务端返回的数据--------------------------------------
-- 邀请上马
function HorseProxy:handle_MSG_SC_HORSE_INVITE(msg)
    local msgLen = msg:GetDataLength()
    if msgLen > 0 then
        local dataString = msg:GetData():ReadString( msgLen)
        local actor = global.playerManager:FindOnePlayerInCurrViewFieldById(dataString)
        if actor then
            local str = string.format(GET_STRING(310000800),actor:GetName())
            ShowSystemTips(str)
        end
        self:ShowHorseInviteBubbleTips(true,dataString)
    end
end

-- 上马  参数1：外观，参数2：特效，字符串：|分割，|前是马主，后面是副驾
function HorseProxy:handle_MSG_SC_HORSE_UP(msg)
    local msgHdr = msg:GetHeader()
    local msgLen = msg:GetDataLength()
    if msgLen > 0 then
        local dataString = msg:GetData():ReadString(msgLen)
        local horseid = string.split(dataString or "", "|")
        
        for i,id in ipairs(horseid) do
            if id and id ~= "" then
                local actor = global.actorManager:GetActor(id)
                if actor then
                    actor:SetDoubleHorse(msgHdr.param2)
                    actor:SetKeyValue(global.MMO.HORSE_MAIN, horseid[1])
                    actor:SetKeyValue(global.MMO.HORSE_COPILOT, horseid[2])
                    
                    local buffData = 
                    {
                        actorID = actor:GetID(),
                        buffID  = global.MMO.BUFF_ID_HORSE,
                        param   = {
                            feature = {
                                mountID     = msgHdr.recog,
                                mountEff    = msgHdr.param1,
                                mountCloth  = msgHdr.param3,
                                hairID      = actor:GetAnimationHairID()
                            },
                        }
                    }

                    global.Facade:sendNotification(global.NoticeTable.AddBuffEntity, buffData)
                end
            end
        end
    end
end

-- 下马  参数1：方向，参数2：坐标X，参数3：坐标Y,字符串，玩家id
function HorseProxy:handle_MSG_SC_HORSE_DOWN(msg)
    local msgLen = msg:GetDataLength()
    local jsondata = ParseRawMsgToJson(msg)

    if jsondata and jsondata.UserID then
        local actor = global.playerManager:FindOnePlayerInCurrViewFieldById(jsondata.UserID)
        if actor then
            
            local msgHdr = msg:GetHeader()
            local actorid = {
                actor:GetValueByKey(global.MMO.HORSE_MAIN),
                actor:GetValueByKey(global.MMO.HORSE_COPILOT)
            }

            local isMainHorse = jsondata.UserID == actorid[1]
            for i,v in ipairs(actorid) do
                local actor = v and global.playerManager:FindOnePlayerInCurrViewFieldById(v) or nil
                if actor then
                    local isExit = v == jsondata.UserID
                    actor:SetKeyValue(global.MMO.HORSE_COPILOT, nil)

                    if isMainHorse or isExit then
                        actor:SetDoubleHorse()
                        actor:SetKeyValue(global.MMO.HORSE_MAIN, nil)
                    end

                    if isExit then
                        local posOfAccepted = global.sceneManager:MapPos2WorldPos(msgHdr.param1, msgHdr.param2, true)
                        if not actor:IsDie() and not actor:IsDeath() then
                            actor:SetAction(global.MMO.ACTION_IDLE, true)
                            global.actorManager:SetActorMapXY( actor, msgHdr.param1, msgHdr.param2 )
                            actor:SetDirection(msgHdr.recog)
                            actor:setPosition(posOfAccepted.x, posOfAccepted.y)
                        end
                    end

                    local buffData = 
                    {
                        actorID     = actor:GetID(),
                        buffID      = global.MMO.BUFF_ID_HORSE,
                        param       = {
                            isExit = isExit,
                            feature = {
                                mountID     = actor:GetMonsterFeatureID(),
                                mountEff    = actor:GetMonsterEffectID(),
                                mountCloth  = actor:GetMonsterClothID(),
                                hairID      = actor:GetAnimationHairID(),
                                isDown      = actorid[2] and true or false
                            }
                        }
                    }

                    global.Facade:sendNotification(global.NoticeTable.AddBuffEntity, buffData)

                end

            end
        end
    end
end

function HorseProxy:RegisterMsgHandler()
    HorseProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    LuaRegisterMsgHandler(msgType.MSG_SC_HORSE_UP, handler(self, self.handle_MSG_SC_HORSE_UP))
    LuaRegisterMsgHandler(msgType.MSG_SC_HORSE_DOWN, handler(self, self.handle_MSG_SC_HORSE_DOWN))
    LuaRegisterMsgHandler(msgType.MSG_SC_HORSE_INVITE, handler(self, self.handle_MSG_SC_HORSE_INVITE))
end

return HorseProxy