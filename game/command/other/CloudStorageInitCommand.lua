local CloudStorageInitCommand = class('CloudStorageInitCommand', framework.SimpleCommand)

function CloudStorageInitCommand:ctor()
end

function CloudStorageInitCommand:execute(note)
    -- 设置
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    GameSettingProxy:readLocalData()
    GameSettingProxy:readLocalPickData()
    
    -- 技能
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:ReadLocalKey()
end

return CloudStorageInitCommand
