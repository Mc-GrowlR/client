local DelSkillCommand = class('DelSkillCommand', framework.SimpleCommand)

function DelSkillCommand:ctor()
end

function DelSkillCommand:execute(note)
    local data = note:getBody()
    -- dump(data,"data____")
    local skillID = data.MagicID
    -- 内挂 单体技能  清除设置
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    local settingID = global.MMO.SETTING_IDX_AUTO_SIMPSKILL 
    local rankData = GameSettingProxy:getRankData(settingID)
    table.removebyvalue(rankData.indexs, skillID)
    GameSettingProxy:setRankData(settingID, rankData)
    --群体
    settingID = global.MMO.SETTING_IDX_AUTO_GROUPSKILL
    rankData = GameSettingProxy:getRankData(settingID)
    table.removebyvalue(rankData.indexs, skillID)
    GameSettingProxy:setRankData(settingID, rankData)
end

return DelSkillCommand
