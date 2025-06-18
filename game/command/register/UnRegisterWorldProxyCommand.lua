local UnRegisterWorldProxyCommand = class('UnRegisterWorldProxyCommand', framework.SimpleCommand)

function UnRegisterWorldProxyCommand:ctor()
end

function UnRegisterWorldProxyCommand:execute(note)
    self:removeProxy()
end

function UnRegisterWorldProxyCommand:removeProxy()
    local requireProxy    = requireProxy
    local registerTable   = requireCommand("register/WorldProxyTable")
    local facade          = global.Facade

    for k, v in pairs(registerTable) do
        package.loaded[v] = nil
        local Proxy = requireProxy(v)
        facade:removeProxy(Proxy.NAME)
        
    end
end

return UnRegisterWorldProxyCommand
