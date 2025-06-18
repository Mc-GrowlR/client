local AutoFightBeginCommand = class('AutoFightBeginCommand', framework.SimpleCommand)

function AutoFightBeginCommand:ctor()
end

function AutoFightBeginCommand:execute(notification)
    local facade             = global.Facade
    local priority           = notification:getBody()

    local autoProxy          = facade:retrieveProxy( global.ProxyTable.Auto )
    local inputProxy         = facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
    priority                 = priority and priority or autoProxy:GetAutoInputPriority()

    print("---------------------- auto fight begin")
    
    -- clear all state
    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    autoProxy:ClearAllState()


    autoProxy:SetAutoInputPriority( priority )

    -- set auto fight default target
    if global.MMO.ACTOR_NONE == autoProxy:GetTargetType() then
        autoProxy:SetTargetType( global.MMO.ACTOR_MONSTER )
    end

    -- auto target state:running
    if global.MMO.ACTOR_NPC == autoProxy:GetTargetType() then
        autoProxy:SetTargetState( global.MMO.AUTO_TARGET_STATE_RUNNING )
    end

    -- tips
    if not autoProxy:IsAutoFightState() then  -- must confirm state
        autoProxy:SetIsAutoFightState( true )

        if autoProxy:IsTargetTypeLaunchEnable() then
            SLBridge:onLUAEvent(LUA_EVENT_AUTOFIGHT_TIPS_SHOW, true)
        end
    end
    
    -- auto on skill banyue
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    if not SkillProxy:IsOnSkill(25) and CHECK_SETTING(18) == 1 then
        SkillProxy:RequestSkillOnoff(25)
    end

    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    if not SkillProxy:IsOnSkill(12) and CHECK_SETTING(15) == 1 then
        SkillProxy:RequestSkillOnoff(12)
    end
end


return AutoFightBeginCommand
