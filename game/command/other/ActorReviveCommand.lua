local ActorReviveCommand = class('ActorReviveCommand', framework.SimpleCommand)

local optionsUtils = requireProxy("optionsUtils")

function ActorReviveCommand:ctor()
end

function ActorReviveCommand:execute(notification)
    local data = notification:getBody()
    local actor = data.actor
    if not actor then
        return false
    end
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    if HeroPropertyProxy:IsHeroOpen() and HeroPropertyProxy:HeroIsLogin() and HeroPropertyProxy:getAlive() == false and data.actorID == HeroPropertyProxy:GetRoleUID() then
        HeroPropertyProxy:setAlive(true)
    end
    global.Facade:sendNotification(global.NoticeTable.RefreshActorSceneOptions, actor)
end

return ActorReviveCommand