local RegisterWorldProxyCommand = class('RegisterWorldProxyCommand', framework.SimpleCommand)

function RegisterWorldProxyCommand:ctor()
end

function RegisterWorldProxyCommand:execute(note)
    self:registerProxy()
end

function RegisterWorldProxyCommand:registerProxy()
    local requireProxy    = requireProxy
    local registerTable   = requireCommand("register/WorldProxyTable")
    local facade          = global.Facade
    local size            = #registerTable
    local loadingUnit     = 89/size
    local function callback(param)
        local Proxy     = requireProxy(param)
        local proxyInst = Proxy.new()
        facade:registerProxy(proxyInst)
    end

    -- add loading task
    global.LoadingHelper:AddLoadingTask( registerTable, callback, loadingUnit, 200 )
end


return RegisterWorldProxyCommand
