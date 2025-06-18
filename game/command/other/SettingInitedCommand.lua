local SettingInitedCommand = class('SettingInitedCommand', framework.SimpleCommand)

local skillUtils = requireProxy("skillUtils")

function SettingInitedCommand:ctor()
end

function SettingInitedCommand:execute(notification)
    local data = notification:getBody()

    -- 简装
    global.Facade:sendNotification(global.NoticeTable.SetChange_SimpleDressPlayer)
    global.Facade:sendNotification(global.NoticeTable.SetChange_SimpleDressMonster)
end

return SettingInitedCommand
