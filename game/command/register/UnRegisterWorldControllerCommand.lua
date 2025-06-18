local UnRegisterWorldControllerCommand = class('UnRegisterWorldControllerCommand', framework.SimpleCommand)

function UnRegisterWorldControllerCommand:ctor()
end

function UnRegisterWorldControllerCommand:execute(note)
    local requireCommand    = requireCommand
    local registerTable     = requireCommand("register/WorldControllerTable")
    local facade            = global.Facade
    for k, v in pairs(registerTable) do
        package.loaded[v] = nil
        facade:removeCommand(k)
    end
end

return UnRegisterWorldControllerCommand
