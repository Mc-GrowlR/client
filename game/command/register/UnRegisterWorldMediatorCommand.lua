local UnRegisterWorldMediatorCommand = class('UnRegisterWorldMediatorCommand', framework.SimpleCommand)

function UnRegisterWorldMediatorCommand:ctor()
end

function UnRegisterWorldMediatorCommand:execute(note)
    self:UnRegisterOtherMediator()
    self:RemoveNormalLayerMediator()
end

function UnRegisterWorldMediatorCommand:UnRegisterOtherMediator()
    local facade = global.Facade

    -- debug map
    if global.isDebugMode or global.isGMMode then
        local DebugMapMediator = requireMediator( "debug_map/DebugMapMediator" )
        facade:removeMediator(DebugMapMediator.NAME)
    end
end

function UnRegisterWorldMediatorCommand:RemoveNormalLayerMediator()
    local requireMediator   = requireMediator
    local registerTable     = requireCommand("register/WorldMediatorTable")
    local facade            = global.Facade

    for k, v in pairs(registerTable) do
        package.loaded[v] = nil
        local Mediator = requireMediator(v)
        facade:removeMediator(Mediator.NAME)
    end
end

return UnRegisterWorldMediatorCommand
