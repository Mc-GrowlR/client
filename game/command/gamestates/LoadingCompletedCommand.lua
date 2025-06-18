local LoadingCompletedCommand = class('LoadingCompletedCommand', framework.SimpleCommand)

function LoadingCompletedCommand:ctor()

end

function LoadingCompletedCommand:execute(note)
    global._loadingCost = os.clock() - global._loadingCost
    print( "LoadingCompleted", global._loadingCost )

    global.Facade:sendNotification(global.NoticeTable.Layer_GameWorldConfirm_Open)
end


return LoadingCompletedCommand
