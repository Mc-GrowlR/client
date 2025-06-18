local SetPlayerFeatureEXCommand = class('SetPlayerFeatureEXCommand', framework.SimpleCommand)
local optionsUtils              = requireProxy("optionsUtils")

function SetPlayerFeatureEXCommand:ctor()
end

function SetPlayerFeatureEXCommand:execute(notification)
    local data = notification:getBody()
    if not data then
        return false
    end
    
    local actor = data.actor
    if not actor then
        return false
    end

    local showClothID           = data.showClothID
    local showWeaponID          = data.showWeaponID
    local showShieldID          = data.showShieldID
    local showWingsID           = data.showWingsID
    local showHairID            = data.showHairID
    local showWeaponEffID       = data.showWeaponEffID
    local showShieldEffID       = data.showShieldEffID
    local showLeftWeaponID      = data.showLeftWeaponID
    local showLeftWeaponEffID   = data.showLeftWeaponEffID

    local checkDirty = false
    local actorID    = actor:GetID()
    local sex        = actor:GetSexID()
    if actor.SetShowClothID and showClothID then
        checkDirty = self:SetCloth(showClothID, sex, actor) or checkDirty
    end

    if actor.SetShowWeaponID and showWeaponID then
        checkDirty = self:SetWeapon(showWeaponID, sex, actor) or checkDirty
    end

    if actor.SetShowShieldID and showShieldID then
        checkDirty = self:SetShield(showShieldID, sex, actor) or checkDirty
    end

    if actor.SetShowWingsID and showWingsID then
        checkDirty = self:SetWings(showWingsID, sex, actor) or checkDirty
    end

    if actor.SetShowHairID and showHairID then
        checkDirty = self:SetHair(showHairID, sex, actor) or checkDirty
    end

    if actor.SetShowWeaponEffectID and showWeaponEffID then
        checkDirty = self:SetWeaponEff(showWeaponEffID, sex, actor) or checkDirty
    end

    if actor.SetShowShieldEffectID and showShieldEffID then
        checkDirty = self:SetShieldEff(showShieldEffID, sex, actor) or checkDirty
    end

    if actor.SetShowLeftWeaponID and showLeftWeaponID then
        checkDirty = self:SetLeftWeapon(showLeftWeaponID, sex, actor) or checkDirty
    end

    if actor.SetShowLeftWeaponEffectID and showLeftWeaponEffID then
        checkDirty = self:SetLeftWeaponEff(showLeftWeaponEffID, sex, actor) or checkDirty
    end

    if checkDirty then
        global.Facade:sendNotification(global.NoticeTable.DelayDirtyFeature, {actorID = actorID, actor = actor})
    end
end

function SetPlayerFeatureEXCommand:SetCloth(showID, sex, actor)
    if showID < 1 then    -- cleanup show
        local clothID = actor:GetClothID()
        if optionsUtils:checkFeatureEnable(global.MMO.SFANIM_TYPE_PLAYER, clothID, sex, actor) then
            actor:SetShowClothID(0)
            return true
        end
    else                        -- show
        actor:SetShowClothID(showID)
        return true
    end
    return false
end

function SetPlayerFeatureEXCommand:SetWeapon(showID, sex, actor)
    if showID < 1 then    -- cleanup show
        local weaponID = actor:GetWeaponID()
        if optionsUtils:checkFeatureEnable(global.MMO.SFANIM_TYPE_WEAPON, weaponID, sex, actor) then
            actor:SetShowWeaponID(0)
            return true
        end
    else                        -- show
        actor:SetShowWeaponID(showID)
        return true
    end
    return false
end

function SetPlayerFeatureEXCommand:SetLeftWeapon(showID, sex, actor)
    if showID < 1 then    -- cleanup show
        local LeftWeaponID = actor:GetLeftWeaponID()
        if optionsUtils:checkFeatureEnable(global.MMO.SFANIM_TYPE_WEAPON, LeftWeaponID, sex, actor) then
            actor:SetShowLeftWeaponID(0)
            return true
        end
    else                        -- show
        actor:SetShowLeftWeaponID(showID)
        return true
    end
    return false
end

function SetPlayerFeatureEXCommand:SetShield(showID, sex, actor)
    if showID < 1 then    -- cleanup show
        local shieldID = actor:GetShieldID()
        if optionsUtils:checkFeatureEnable(global.MMO.SFANIM_TYPE_SHIELD, shieldID, sex, actor) then
            actor:SetShowShieldID(0)
            return true
        end
    else                        -- show
        actor:SetShowShieldID(showID)
        return true
    end
    return false
end

function SetPlayerFeatureEXCommand:SetWings(showID, sex, actor)
    if showID < 1 then    -- cleanup show
        local wingsID = actor:GetWingsID()
        if optionsUtils:checkFeatureEnable(global.MMO.SFANIM_TYPE_WINGS, wingsID, sex, actor) then
            actor:SetShowWingsID(0)
            return true
        end
    else                        -- show
        actor:SetShowWingsID(showID)
        return true
    end
    return false
end

function SetPlayerFeatureEXCommand:SetHair(showID, sex, actor)
    if showID < 1 then    -- cleanup show
        local hairID = actor:GetHairID()
        if optionsUtils:checkFeatureEnable(global.MMO.SFANIM_TYPE_HAIR, hairID, sex, actor) then
            actor:SetShowHairID(0)
            return true
        end
    else                        -- show
        actor:SetShowHairID(showID)
        return true
    end
    return false
end

function SetPlayerFeatureEXCommand:SetWeaponEff(showID, sex, actor)
    if showID < 1 then    -- cleanup show
        local weaponEff = actor:GetWeaponEffectID()
        if optionsUtils:checkFeatureEnable(global.MMO.SFANIM_TYPE_WEAPON, weaponEff, sex, actor) then
            actor:SetShowWeaponEffectID(0)
            return true
        end
    else                        -- show
        actor:SetShowWeaponEffectID(showID)
        return true
    end
    return false
end

function SetPlayerFeatureEXCommand:SetLeftWeaponEff(showID, sex, actor)
    if showID < 1 then    -- cleanup show
        local leftWeaponEff = actor:GetLeftWeaponEffectID()
        if optionsUtils:checkFeatureEnable(global.MMO.SFANIM_TYPE_WEAPON, leftWeaponEff, sex, actor) then
            actor:SetShowLeftWeaponEffectID(0)
            return true
        end
    else                        -- show
        actor:SetShowLeftWeaponEffectID(showID)
        return true
    end
    return false
end

function SetPlayerFeatureEXCommand:SetShieldEff(showID, sex, actor)
    if showID < 1 then    -- cleanup show
        local shieldEff = actor:GetShieldEffectID()
        if optionsUtils:checkFeatureEnable(global.MMO.SFANIM_TYPE_SHIELD, shieldEff, sex, actor) then
            actor:SetShowShieldEffectID(0)
            return true
        end
    else                        -- show
        actor:SetShowShieldEffectID(showID)
        return true
    end
    return false
end

return SetPlayerFeatureEXCommand
