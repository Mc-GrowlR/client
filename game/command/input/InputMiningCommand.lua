local InputMiningCommand = class('InputMiningCommand', framework.SimpleCommand)

function InputMiningCommand:ctor()

end

function InputMiningCommand:execute(note)
    local facade        = global.Facade
    local data          = note:getBody()
    
    local dest          = data.dest
    local dir           = data.dir

    local skillProxy    = facade:retrieveProxy(global.ProxyTable.Skill)
    local inputProxy    = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)

    -- 判断是否可以挖矿
    if 1 ~= skillProxy:CheckAbleToLaunch(global.MMO.SKILL_INDEX_DIG) then
        return
    end

    inputProxy:SetMiningDir(dir)
    inputProxy:SetMiningDest(dest)
end

return InputMiningCommand
