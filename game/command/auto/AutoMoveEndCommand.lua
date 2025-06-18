local AutoMoveEndCommand = class('AutoMoveEndCommand', framework.SimpleCommand)

function AutoMoveEndCommand:ctor()
end

function AutoMoveEndCommand:execute(notification)
    local data        = notification:getBody()
    local facade      = global.Facade
    local autoProxy   = facade:retrieveProxy( global.ProxyTable.Auto )
    local inputProxy  = facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
    local assistProxy = facade:retrieveProxy( global.ProxyTable.AssistProxy )

    print("---------------------- auto move end")

    -- 通知服务器
    local autoTarget = autoProxy:GetAutoTarget()
    if autoTarget.autoMoveType == global.MMO.AUTO_MOVE_TYPE_MINIMAP or autoTarget.autoMoveType == global.MMO.AUTO_MOVE_TYPE_SERVER then
        if autoProxy:IsMoveCompleted() and inputProxy:GetCurrPathPoint() == 0 then
            autoProxy:RequestAutoMoveNotify(global.MMO.AUTO_MOVE_FINISH)
        else
            autoProxy:RequestAutoMoveNotify(global.MMO.AUTO_MOVE_ABORT)
        end
    end

    -- reset assist state
    assistProxy:resetOfflineState()
    assistProxy:resetFindMapMonster()
    
    -- reset auto move state
    autoProxy:ClearAutoMove()

    -- clear current movint data
    if inputProxy:IsMoveDirty() or inputProxy:GetPathPointSize() > 0 then
        inputProxy:ClearMove()
    end

    local autoTarget = autoProxy:GetAutoTarget()
    -- tips
    SLBridge:onLUAEvent(LUA_EVENT_AUTOMOVE_TIPS_SHOW, false)
    SLBridge:onLUAEvent(LUA_EVENT_AUTOMOVEEND, {isMoveFail = autoTarget and autoTarget.isPauseAutoTarget})
    ssr.ssrBridge:OnAutoMoveEnd()

    -- set current auto target
    if autoTarget and autoTarget.targetType ~= global.MMO.ACTOR_NONE then
        -- clear current input target
        inputProxy:ClearTarget()
        
        if not autoProxy:GetAutoTargetInterruptFlag() then
            facade:sendNotification( global.NoticeTable.AutoFightBegin )
            ssr.ssrBridge:OnAutoFightBegin()
        end
    else
        -- auto move end, nothing todo, so clear auto target
        autoProxy:ClearAutoTarget()
    end
end


return AutoMoveEndCommand
