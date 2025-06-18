local SetPlayerFeatureCommand = class('SetPlayerFeatureCommand', framework.SimpleCommand)
local optionsUtils            = requireProxy( "optionsUtils" )

function SetPlayerFeatureCommand:ctor()
end

function SetPlayerFeatureCommand:execute(notification)
    local data  = notification:getBody()
    if not data then
        return false
    end

    local actor = data.actor
    if not actor then
        return false
    end

    local sex       = actor:GetSexID()
    local job       = actor:GetJobID()
    local actorID   = actor:GetID()

    -- set and check actual feature
    local clothID     = data.clothID
    local weaponID    = data.weaponID
    local shieldID    = data.shieldID
    local wingsID     = data.wingsID
    local hairID      = data.hairID
    local capID       = data.capID
    local weaponEffID = data.weaponEff
    local mountID     = data.mountID
    local mountEff    = data.mountEff
    local mountCloth  = data.mountCloth
    local shieldEffID = data.shieldEffect
    local leftWeaponID      = data.leftWeaponID
    local leftWeaponEffID   = data.leftWeaponEff
    local sceneOptionsProxy = global.Facade:retrieveProxy( global.ProxyTable.SceneOptionsProxy )
    local tempFeature = sceneOptionsProxy:GetTempFeatureByJob( job )

    if clothID then
        actor:SetClothID( clothID )
    end
    if tempFeature and tempFeature.clothID and not optionsUtils:checkFeatureEnable( global.MMO.SFANIM_TYPE_PLAYER, actor:GetClothID(), sex, actor ) then
        -- temp
        actor:SetShowClothID(tempFeature.clothID)
    else
        actor:SetShowClothID(0)
    end

    if weaponID then
        actor:SetWeaponID( weaponID )
    end
    if tempFeature and tempFeature.weaponID and not optionsUtils:checkFeatureEnable( global.MMO.SFANIM_TYPE_WEAPON, actor:GetWeaponID(), sex, actor ) then
        -- temp
        actor:SetShowWeaponID(tempFeature.weaponID)
    else
        actor:SetShowWeaponID(0)
    end

    if leftWeaponID then
        actor:SetLeftWeaponID( leftWeaponID )
    end
    if tempFeature and tempFeature.leftWeaponID and not optionsUtils:checkFeatureEnable( global.MMO.SFANIM_TYPE_WEAPON, actor:GetLeftWeaponID(), sex, actor ) then
        -- temp
        actor:SetShowLeftWeaponID(tempFeature.leftWeaponID)
    else
        actor:SetShowLeftWeaponID(0)
    end

    if shieldID then
        actor:SetShieldID( shieldID )
    end
    if tempFeature and tempFeature.shieldID and not optionsUtils:checkFeatureEnable( global.MMO.SFANIM_TYPE_SHIELD, actor:GetShieldID(), sex, actor ) then
        -- temp
        actor:SetShowShieldID( tempFeature.shieldID )
    else
        actor:SetShowShieldID( 0 )
    end

    if wingsID then
        actor:SetWingsID( wingsID )
    end
    if tempFeature and tempFeature.wingsID and not optionsUtils:checkFeatureEnable( global.MMO.SFANIM_TYPE_WINGS, actor:GetWingsID(), sex, actor ) then
        -- temp
        actor:SetShowWingsID( tempFeature.wingsID )
    else
        actor:SetShowWingsID( 0 )
    end

    if capID or hairID then
        actor:SetHairID( capID or hairID )
    end
    if tempFeature and tempFeature.hairID and not optionsUtils:checkFeatureEnable( global.MMO.SFANIM_TYPE_HAIR, actor:GetHairID(), sex, actor ) then
        -- temp
        actor:SetShowHairID( tempFeature.hairID )
    else
        actor:SetShowHairID( 0 )
    end

    actor:SetRealHairID( hairID or 0 )


    if weaponEffID then
        actor:SetWeaponEffectID( weaponEffID )
    end
    if tempFeature and tempFeature.weaponEffID and not optionsUtils:checkFeatureEnable( global.MMO.SFANIM_TYPE_WEAPON, actor:GetWeaponEffectID(), sex, actor ) then
        -- temp
        actor:SetShowWeaponEffectID( tempFeature.weaponEffID )
    else
        actor:SetShowWeaponEffectID( 0 )
    end

    if leftWeaponEffID then
        actor:SetLeftWeaponEffectID( leftWeaponEffID )
    end
    if tempFeature and tempFeature.leftWeaponEffID and not optionsUtils:checkFeatureEnable( global.MMO.SFANIM_TYPE_WEAPON, actor:GetLeftWeaponEffectID(), sex, actor ) then
        -- temp
        actor:SetShowLeftWeaponEffectID( tempFeature.leftWeaponEffID )
    else
        actor:SetShowLeftWeaponEffectID( 0 )
    end

    if shieldEffID then
        actor:SetShieldEffectID( shieldEffID )
    end
    if tempFeature and tempFeature.shieldEffID and not optionsUtils:checkFeatureEnable( global.MMO.SFANIM_TYPE_SHIELD, actor:GetShieldEffectID(), sex, actor ) then
        -- temp
        actor:SetShowShieldEffectID( tempFeature.shieldEffID )
    else
        actor:SetShowShieldEffectID( 0 )
    end

    -- 检测buff是否存在变形
    mountID = mountID or 0
    local cfgAvatar = global.BuffManager:CheckBuffAvatar(actorID)
    if global.BuffManager:CheckRmvBuffAvatar(actorID,cfgAvatar) then
        actor:SetMonsterFeatureID(0)
        actor:updateMonster(0)
    end
    if mountID == 0 and cfgAvatar then
        mountID = cfgAvatar.avatarID
    end

    if actor:IsPlayer() then
        actor:SetMonsterFeatureID( mountID or 0 )   --骑马
        actor:SetMonsterEffectID( mountEff or 0 )
        actor:SetMonsterClothID ( mountCloth or 0 )

        if not actor:GetNode():isVisible() and not actor:IsHoreseCopilot() then
            actor:GetNode():setVisible( true )
        end
    end

    global.Facade:sendNotification(global.NoticeTable.DelayDirtyFeature, {actorID = actorID, actor = actor})
end


return SetPlayerFeatureCommand
