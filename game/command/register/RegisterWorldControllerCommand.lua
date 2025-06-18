local RegisterWorldControllerCommand = class('RegisterWorldControllerCommand', framework.SimpleCommand)

function RegisterWorldControllerCommand:ctor()
end

function RegisterWorldControllerCommand:execute(note)
    local requireCommand    = requireCommand
    local registerTable     = requireCommand("register/WorldControllerTable")
    local facade            = global.Facade
    for k, v in pairs(registerTable) do
        local cmd = requireCommand(v)
        facade:registerCommand(k, cmd)
    end
end

return RegisterWorldControllerCommand
