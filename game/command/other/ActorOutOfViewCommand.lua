local ActorOutOfViewCommand = class('ActorOutOfViewCommand', framework.SimpleCommand)
local proxyUtils = requireProxy("proxyUtils")

requireProxy("actorUtils")

function ActorOutOfViewCommand:ctor()
end

function ActorOutOfViewCommand:execute(notification)
    local data = notification:getBody()
    local actorID = data.actorID
    local msgID = data.msgID
    
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    
    if inputProxy:GetTargetID() == actorID then
        inputProxy:ClearTarget()
        inputProxy:SetAttackState(false)
    end

    if inputProxy:GetAttackTargetID() == actorID then
        inputProxy:ClearAttackTargetID()
    end

    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if mainPlayer and  mainPlayer:GetHateID() == actorID then 
        mainPlayer:SetHateID(nil)
    end

    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end
    
    -- player
    if actor:IsPlayer() then
        local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
        TradeProxy:CheckPlayerOut(actor:GetID())

        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        StallProxy:OnStallStateDataChange({userid = actor:GetID(), status = 0})

        -- out of view sfx
        if msgID then
            if msgID == global.MsgType.MSG_SC_NET_PLAYER_FLY_OUT then
                local effectType = data.recog or 0
                local noShow = effectType == 1
                -- audio
                global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_FLY_OUT})
                
                -- effect
                if not noShow then
                    local effectId = effectType > 1 and effectType
                    global.Facade:sendNotification(global.NoticeTable.ActorFlyOut, actor, effectId or 0)
                end
            
            elseif msgID == global.MsgType.MSG_SC_NET_PLAYER_FLY_OUT_2 then
                local effectType = data.recog or 0
                local noShow = effectType == 1
                -- audio
                global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_FLY_OUT})
                
                -- effect
                if not noShow then
                    local effectId = effectType > 1 and effectType
                    global.Facade:sendNotification(global.NoticeTable.ActorFlyOut, actor, effectId or 1)
                end
            end
        end

        actor:SetKeyValue(global.MMO.HUD_BAR_SHOW_FULL_HP, false)

    elseif actor:IsMonster() then
        actor:SetKeyValue(global.MMO.HUD_BAR_SHOW_FULL_HP, false)
        
    elseif actor:IsNPC() then
        -- NPC
        global.Facade:sendNotification( global.NoticeTable.NpcOutOfView, actor:GetTypeIndex() )

    elseif global.MMO.ACTOR_RACE_COLLECTION == actor:GetRace() then
        -- collection
        inputProxy:SubCollectCount()
        local collectCount = inputProxy:GetCollectCount()
        if collectCount <= 0 then
            global.Facade:sendNotification(global.NoticeTable.CollectVisible, false)
        end
    end

    global.actorInViewController:DelActor(actor)
    
    global.HUDHPManager:DelActor(actor)

    -- cleanup actor attr
    ClenupActorAttr(actor)
end


return ActorOutOfViewCommand
