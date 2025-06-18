local LoadingBeginCommand = class('LoadingBeginCommand', framework.SimpleCommand)

function LoadingBeginCommand:ctor()
end

function LoadingBeginCommand:execute(note)
    print( "LoadingBegin" )

    -- for debug loading time
    global._loadingCost = os.clock()

    self:preload()
    self:registerLogic()

    local facade = global.Facade

    -- release
    global.Facade:sendNotification(global.NoticeTable.LeaveRole)
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Role_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Version_Close)
end

function LoadingBeginCommand:preload()
    -- create loading helper
    if not global.LoadingHelper then
        local LoadingHelper  = requireUtil( "LoadingHelper" )
        global.LoadingHelper = LoadingHelper.new()
        global.LoadingHelper:setForEnterWorldLoading( true )
    end

    global.Facade:sendNotification( global.NoticeTable.PreloadBegin )
end

function LoadingBeginCommand:registerLogic()
    -- json proto
    local JsonProtoHelper       = require( "network/jsonproto/JsonProtoHelper" )
    global.JsonProtoHelper      = JsonProtoHelper.new()
    
    -- WidgetCacheManager
    local WidgetCacheManager    = requireUtil("WidgetCacheManager")
    global.WidgetCacheManager   = WidgetCacheManager.new()

    -- register 
    local RegisterWorldController = requireCommand( "register/RegisterWorldControllerCommand" )
    local RegisterWorldMediator   = requireCommand( "register/RegisterWorldMediatorCommand" )
    local RegisterWorldProxy      = requireCommand( "register/RegisterWorldProxyCommand" )
    local cmd = nil
    cmd = RegisterWorldController.new()
    global.Facade:registerCommand( global.NoticeTable.RegisterWorldController, cmd )
    cmd = RegisterWorldMediator.new()
    global.Facade:registerCommand( global.NoticeTable.RegisterWorldMediator, cmd )
    cmd = RegisterWorldProxy.new()
    global.Facade:registerCommand( global.NoticeTable.RegisterWorldProxy, cmd )
    global.Facade:sendNotification( global.NoticeTable.RegisterWorldController )
    global.Facade:sendNotification( global.NoticeTable.RegisterWorldProxy )
    global.Facade:sendNotification( global.NoticeTable.RegisterWorldMediator )
end


return LoadingBeginCommand
