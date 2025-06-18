local AutoFightEndCommand = class('AutoFightEndCommand', framework.SimpleCommand)

function AutoFightEndCommand:ctor()
end

function AutoFightEndCommand:execute(notification)
    local facade             = global.Facade
    local autoProxy          = facade:retrieveProxy( global.ProxyTable.Auto )
    local inputProxy         = facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )

    print("---------------------- auto fight end")

    -- model:
    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)

    -- tips
    autoProxy:ClearAutoTarget()

    --
    facade:sendNotification( global.NoticeTable.AutoFightEndTips )
    SLBridge:onLUAEvent(LUA_EVENT_AUTOFIGHT_TIPS_SHOW, false)
    
    --取消无怪使用随机 定时器
    local AssistProxy = global.Facade:retrieveProxy(global.ProxyTable.AssistProxy)
    AssistProxy:resetNoMonsterSchedule()

    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if mainPlayer and  mainPlayer:GetHateID() then 
        mainPlayer:SetHateID(nil)
    end
end


return AutoFightEndCommand
