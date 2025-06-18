--[[
    author:yzy
    time:2022-02-25 09:52:04
    desc: 受攻击后自动反击
]]
local AutoFightBackCommand = class('AutoFightBackCommand', framework.SimpleCommand)

local proxyUtils    = requireProxy("proxyUtils")

function AutoFightBackCommand:ctor()
end

function AutoFightBackCommand:execute(notification)
    local data          = notification:getBody() or {}

    local attackActorID = data.attackActorID
    local actorID       = data.actorID or global.gamePlayerController:GetMainPlayerID()

    local setValues = GET_SETTING(global.MMO.SETTING_IDX_BEDAMAGED_PLAYER, true)  -- 被玩家攻击 1不处理 2反击 3逃跑
    if not setValues or not setValues[1] or not (setValues[1] == 2 or setValues[1] == 3) then
        return
    end

    if not attackActorID then  -- 没有攻击者id
        return
    end

    local attackActor = global.actorManager:GetActor(attackActorID)
    if not attackActor then
        return
    end

    local attackMasterID = attackActor:GetMasterID()
    if (attackActor:IsHumanoid() or attackActor:IsMonster()) and not (attackMasterID and attackMasterID ~= "") then
        return 
    end

    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return
    end
    
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    local heroActorID = HeroPropertyProxy:GetRoleUID() or -1
    local masterID = actor:GetMasterID() or -1

    -- 攻击 我的宠物/元神/主角
    if not (masterID == mainPlayerID or actorID == heroActorID or actorID == mainPlayerID) then
        return
    end

    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then 
        return
    end

    -- 挂机
    local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if not AutoProxy:IsAFKState() and not AutoProxy:IsAutoFightState() then
        return
    end
    
    local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if setValues[1] == 2 then
        local attackBackID = nil -- 要反击的对象id
        if attackMasterID and attackMasterID ~= "" then
            local attackActorMaster = global.actorManager:GetActor(attackMasterID)
            local value = GET_SETTING(global.MMO.SETTING_IDX_FIRST_ATTACK_MASTER)  -- 优先打主人
            if attackActorMaster and value[1] == 1 and attackActorMaster:IsPlayer() and not attackActorMaster:IsHumanoid() then 
                attackBackID = attackMasterID
            end
        end

        if not attackBackID then 
            attackBackID = attackActorID
        end

        local hateID = mainPlayer:GetHateID()
        if hateID and global.actorManager:GetActor(hateID) then
            return 
        end

        -- 没仇恨对象
        PlayerInputProxy:ClearAttackTargetID()
        PlayerInputProxy:ClearTarget()
        PlayerInputProxy:ClearMove()
        PlayerInputProxy:SetTargetID(attackBackID)
        mainPlayer:SetHateID(attackBackID)
            
    -- 攻击者必须是玩家  不是我的宠物/元神/主角
    elseif setValues[1] == 3 and (not attackActor:IsPlayer() or not attackActor:IsMainPlayer()) and attackMasterID ~= mainPlayerID then
        PlayerInputProxy:ClearAttackTargetID()
        PlayerInputProxy:ClearTarget()
        PlayerInputProxy:SetTargetID(nil)
        local AssistProxy = global.Facade:retrieveProxy(global.ProxyTable.AssistProxy)
        AssistProxy:checkAimlessMove()
    end
end


return AutoFightBackCommand