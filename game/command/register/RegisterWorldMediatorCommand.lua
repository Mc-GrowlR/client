local RegisterWorldMediatorCommand = class('RegisterWorldMediatorCommand', framework.SimpleCommand)


function RegisterWorldMediatorCommand:ctor()
end

function RegisterWorldMediatorCommand:execute(note)
    self:RegisterOtherMediator()
    self:RegisterNormalLayerMediator()
end

function RegisterWorldMediatorCommand:RegisterOtherMediator()
    local facade = global.Facade

    -- debug map
    if global.isDebugMode or global.isGMMode then
        local DebugMapMediator = requireMediator( "debug_map/DebugMapMediator" )
        local debugMapMediator = DebugMapMediator.new()
        facade:registerMediator( debugMapMediator )
    end
end

function RegisterWorldMediatorCommand:RegisterNormalLayerMediator()
    local requireMediator   = requireMediator
    local registerTable     = requireCommand("register/WorldMediatorTable")
    local facade            = global.Facade

    local function callback(param)
        local Mediator      = requireMediator(param)
        local mediatorInst  = Mediator.new()
        facade:registerMediator(mediatorInst)
    end

    local nSize       = #registerTable
    local loadingUnit = 10 / (nSize)

    -- add loading task
    global.LoadingHelper:AddLoadingTask( registerTable, callback, loadingUnit, 200 )
end

return RegisterWorldMediatorCommand
