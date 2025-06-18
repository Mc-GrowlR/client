local RefreshActorHPCommand = class('RefreshActorHPCommand', framework.SimpleCommand)

function RefreshActorHPCommand:ctor()
end

function RefreshActorHPCommand:execute(notification)
    local data      = notification:getBody()
    local actorID   = data.actorID
    local isDamage  = data.isDamage
    local HP        = data.HP
    local MP        = data.MP
    local maxHP     = data.maxHP
    local maxMP     = data.maxMP
    local unAattack = data.unAattack -- 受到攻击
    local level     = data.level or 0

    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return false
    end

    if not (actor:IsPlayer() or actor:IsMonster()) then
        return false
    end

    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    local HeroID = HeroPropertyProxy:GetRoleUID()
    if mainPlayerID == actorID then
        local propertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        propertyProxy:SetRoleMana(HP, maxHP, MP, maxMP)

        if isDamage then
            global.Facade:sendNotification(global.NoticeTable.PlayerBeDamaged) 
        end
    elseif HeroID == actorID then
        HeroPropertyProxy:SetRoleMana(HP, maxHP, MP, maxMP)
        
        if isDamage then
            global.Facade:sendNotification(global.NoticeTable.HeroBeDamaged) 
        end
    end

    if actor.SetDamage and unAattack then
        actor:SetDamage(unAattack)
        --设置护身状态
        local huShen = data.huShen
        if huShen and actor.SetHuShen then
            local lastStatus = actor:IsHuShen()
            actor:SetHuShen(huShen)
            if lastStatus ~= actor:IsHuShen() then
                if global.gamePlayerController:GetMainPlayerID() == actor:GetID() then
                    SL:onLUAEvent(LUA_EVENT_PLAYER_HUSHEN_STATUS_CHANGE)
                else
                    SL:onLUAEvent(LUA_EVENT_NET_PLAYER_HUSHEN_STATUS_CHANGE, {id = actor:GetID()})
                end
            end
        end
        
    end

    local lastLevel = actor:GetLevel()
    if level > 0 and level ~= lastLevel then
        actor:SetLevel(level)
    end

    if actor:IsPlayer() then
        actor:SetShieldHUD(MP, maxMP)
    end

    actor:SetHPHUD(HP, maxHP)
end


return RefreshActorHPCommand
