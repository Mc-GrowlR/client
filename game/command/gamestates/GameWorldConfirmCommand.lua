local GameWorldConfirmCommand = class('GameWorldConfirmCommand', framework.SimpleCommand)

function GameWorldConfirmCommand:ctor()

end

function GameWorldConfirmCommand:execute(note)
    print( "GameWorldConfirm" )

    local facade = global.Facade
    
    -- goto world
    global.Facade:sendNotification(global.NoticeTable.ChangeGameState, global.MMO.GAME_STATE_WORLD)
end

return GameWorldConfirmCommand
