local ChangePlayerFeatureCommand = class('ChangePlayerFeatureCommand', framework.SimpleCommand)

function ChangePlayerFeatureCommand:ctor()
end

function ChangePlayerFeatureCommand:execute(notification)
    local data  = notification:getBody()
    if not data then
        return false
    end
    if not data.actorID then
        return false
    end
    local actor = global.actorManager:GetActor(data.actorID)
    if not actor then
        return false
    end

    local actorID = actor:GetID()
    local feature = TransformFeatureByJson( data )

    local mainPlyayerID = global.gamePlayerController:GetMainPlayerID()
    if actorID == mainPlyayerID then
        self:onChangeMainPlayerFeature( feature )
    end
    
    local HeroPropertyProxy = global.Facade:retrieveProxy( global.ProxyTable.HeroPropertyProxy )
    local heroID     = HeroPropertyProxy:GetRoleUID()
    if actorID == heroID then
        self:onChangeMainPlayerFeature_Hero( feature )
    end

    local specialSign = data.show
    -- -- 新出的时装与原有发型，头盔斗笠，翅膀不兼容的屏蔽
    if specialSign and specialSign > 0 then
        feature.hairID = 0
        feature.wingsID = 0
        feature.capID = 0
    end

    local fData = clone( feature )
    fData.actor = actor
    global.Facade:sendNotification( global.NoticeTable.SetPlayerFeature, fData )
    global.Facade:sendNotification( global.NoticeTable.RefreshOneActorCloth, actor )
end


function ChangePlayerFeatureCommand:onChangeMainPlayerFeature( feature )
    local playerPropertyProxy = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    
    playerPropertyProxy:SetFeature( feature )
end

function ChangePlayerFeatureCommand:onChangeMainPlayerFeature_Hero( feature )
    local HeroPropertyProxy = global.Facade:retrieveProxy( global.ProxyTable.HeroPropertyProxy )
    
    HeroPropertyProxy:SetFeature( feature )
end

return ChangePlayerFeatureCommand
