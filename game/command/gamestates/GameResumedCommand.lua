local GameResumedCommand = class('GameResumedCommand', framework.SimpleCommand)

function GameResumedCommand:ctor()
end

function GameResumedCommand:execute(note)
    --debug
    print("OnGameResumed")

    global.Facade:sendNotification(global.NoticeTable.Audio_Resume_All)

    if global.MMO.GAME_STATE_WORLD == GET_GAME_STATE() then
        LuaSendMsg(global.MsgType.MSG_CS_SERVER_TIME_REQUEST)
    end

    ssr.ssrBridge:onGameResumed()
    if GetModListServerTime then 
        GetModListServerTime()--刷新cdn鉴权时间
    end
end

return GameResumedCommand