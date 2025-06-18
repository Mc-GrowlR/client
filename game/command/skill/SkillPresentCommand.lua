local SkillPresentCommand = class('SkillPresentCommand', framework.SimpleCommand)

function SkillPresentCommand:ctor()
end

function SkillPresentCommand:execute(note)
    local data = note:getBody()

    global.skillManager:LaunchSkillPresent( data )
end

return SkillPresentCommand
