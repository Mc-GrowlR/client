local RefreshGuildActorColorCommand = class('RefreshGuildActorColorCommand', framework.SimpleCommand)

function RefreshGuildActorColorCommand:ctor()
end

function RefreshGuildActorColorCommand:execute(notification)
    local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )
    local isMapWar = MapProxy:IsMapWar()
    if not isMapWar and tonumber(global.ConstantConfig.check_guild_color) == 1 then
        isMapWar = true
    end

    local data = notification:getBody()
    local guilds = data and data.guilds
    local players, nPlayer = global.playerManager:FindPlayerInCurrViewField(false)
    for i = 1, nPlayer do
        local player = players[i]
        local guild = player:GetGuildID()
        if isMapWar or player:IsHaveMaster() or (guild and guild ~= "" and guild ~= 0 and (not guilds or guilds[guild])) then
            global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, {actor = player, actorID = player:GetID()})
        end
    end

    local monsters, nMonster = global.monsterManager:FindMonsterInCurrViewField()
    for i = 1, nMonster do
        local monster = monsters[i]
        global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, {actor = monster, actorID = monster:GetID()})
    end
end

return RefreshGuildActorColorCommand
