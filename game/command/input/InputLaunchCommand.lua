local InputLaunchCommand = class('InputLaunchCommand', framework.SimpleCommand)

function InputLaunchCommand:ctor()

end

function InputLaunchCommand:execute(note)
    local facade        = global.Facade
    
    local data          = note:getBody()
    local skillID       = data.skillID
    local destPos       = data.destPos
    local targetID      = data.targetID
    local priority      = data.priority
    local launchType    = data.launchType

    if not skillID then
        return nil
    end

    local inputProxy    = facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )

    inputProxy:SetLaunchSkillID(skillID, priority, launchType)
    inputProxy:SetLaunchTargetID(targetID)
    inputProxy:SetLaunchTargetPos(destPos)
end

return InputLaunchCommand
