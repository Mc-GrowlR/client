local gameActor = require( "actor/gameActor")
local gameActorMoveable = class('gameActorMoveable', gameActor)

function gameActorMoveable:ctor()
    gameActorMoveable.super.ctor(self)

end

function gameActorMoveable:init()
    gameActorMoveable.super.init(self)

    self.mIsArrived         = true
    self.mIsConfirmed       = true

    self.mWalkStepTime      = global.MMO.DEFAULT_WALK_TIME
    self.mWalkSpeedRate     = 1
    self.mRunStepTime       = global.MMO.DEFAULT_RUN_TIME
    self.mRunSpeedRate      = 1
    self.mIsSpeedup            = nil 
    self.mIsFullSpeedup        = nil
    
    self.mAttackStepTime    = global.MMO.DEFAULT_ATTACK_TIME
    self.mAttackSpeedRate   = 1
    self.mMagicStepTime     = global.MMO.DEFAULT_MAGIC_TIME
    self.mMagicSpeedRate    = 1

    self.mGuildID           = ""
    self.mGuildName         = ""
    self.mMasterID          = global.MMO.ACTOR_ID_INVALID
    self.mFaction           = 0
    self.pklv               = 0
    self.inSafeZone         = nil
    self.mOwnerID           = ""
    self.mOwnerName         = ""
    self.mServerID          = ""

    self.mAdditionZorder    = 0

    self.mCover             = {}

    self.mNameColor         = nil       -- 名字颜色
    self.mWarZone           = 0         -- 行会战标志

    self.mGMData            = {}        -- gm自定义数据，和服务器约定暂定为5个int
end

function gameActorMoveable:destory()
    gameActorMoveable.super.destory(self)
end

function gameActorMoveable:GetFaction()
    return self.mFaction
end
function gameActorMoveable:SetFaction(faction)
    self.mFaction = faction
end

function gameActorMoveable:SetMoveTo( pos )
end

function gameActorMoveable:SetGuildID( id )
    self.mGuildID = id
end
function gameActorMoveable:GetGuildID()
    return self.mGuildID
end

function gameActorMoveable:SetGuildName( name )
    self.mGuildName = name
end
function gameActorMoveable:GetGuildName()
    return self.mGuildName
end

function gameActorMoveable:GetMasterID()
    return self.mMasterID
end
function gameActorMoveable:SetMasterID(id)
    self.mMasterID = id
end
function gameActorMoveable:IsHaveMaster()
    return self.mMasterID ~= global.MMO.ACTOR_ID_INVALID
end

function gameActorMoveable:SetPKLv(lv)
    self.pklv = lv
end

function gameActorMoveable:GetPKLv()
    return self.pklv
end

function gameActorMoveable:SetHPHUD(HP, maxHP)
end

function gameActorMoveable:SetIsSpeedup( fast )
    self.mIsSpeedup = fast
end

function gameActorMoveable:GetIsSpeedup()
    return self.mIsSpeedup
end

function gameActorMoveable:SetIsFullSpeedup( fast )
    self.mIsFullSpeedup = fast
end

function gameActorMoveable:GetIsFullSpeedup()
    return self.mIsFullSpeedup
end

function gameActorMoveable:SetWalkStepTime( time )
    self.mWalkStepTime = time
end

function gameActorMoveable:GetWalkStepTime()
    return self.mWalkStepTime
end

function gameActorMoveable:SetWalkSpeed( speed )
    self.mWalkSpeedRate = speed
end

function gameActorMoveable:GetWalkSpeed()
    if self:GetIsFullSpeedup() then
        return self.mWalkSpeedRate * global.MMO.DEFAULT_MUCH_FAST_TIME
    end
    if self:GetIsSpeedup() then
        return self.mWalkSpeedRate * global.MMO.DEFAULT_FAST_TIME_RATE
    end
    return self.mWalkSpeedRate
end

function gameActorMoveable:SetRunStepTime( time )
    self.mRunStepTime = time
end

function gameActorMoveable:GetRunStepTime()
    return self.mRunStepTime
end

function gameActorMoveable:SetRunSpeed( speed )
    self.mRunSpeedRate = speed
end

function gameActorMoveable:GetRunSpeed()
    if self:GetIsFullSpeedup() then
        return self.mRunSpeedRate * global.MMO.DEFAULT_MUCH_FAST_TIME
    end
    if self:GetIsSpeedup() then
        return self.mRunSpeedRate * global.MMO.DEFAULT_FAST_TIME_RATE
    end
    return self.mRunSpeedRate
end

function gameActorMoveable:SetAttackStepTime( time )
    self.mAttackStepTime = time
end

function gameActorMoveable:GetAttackStepTime()
    return self.mAttackStepTime
end

function gameActorMoveable:SetAttackSpeed( speed )
    self.mAttackSpeedRate = speed
end

function gameActorMoveable:GetAttackSpeed()
    if self:GetIsFullSpeedup() then
        return self.mAttackSpeedRate * global.MMO.DEFAULT_MUCH_FAST_TIME
    end
    if self:GetIsSpeedup() then
        return self.mAttackSpeedRate * global.MMO.DEFAULT_FAST_TIME_RATE
    end
    return self.mAttackSpeedRate
end

function gameActorMoveable:GetAttackAnimSpeed( action )
    return self:GetAttackSpeed()
end

function gameActorMoveable:SetMagicStepTime( time )
    self.mMagicStepTime = time
end

function gameActorMoveable:GetMagicStepTime()
    return self.mMagicStepTime
end

function gameActorMoveable:SetMagicSpeed( speed )
    self.mMagicSpeedRate = speed
end

function gameActorMoveable:GetMagicSpeed()
    if self:GetIsFullSpeedup() then
        return self.mMagicSpeedRate * global.MMO.DEFAULT_MUCH_FAST_TIME
    end
    if self:GetIsSpeedup() then
        return self.mMagicSpeedRate * global.MMO.DEFAULT_FAST_TIME_RATE
    end
    return self.mMagicSpeedRate
end

function gameActorMoveable:GetMagicAnimSpeed( action )
    return self:GetMagicSpeed()
end

function gameActorMoveable:SetGameActorActionHandler(handler)
end

function gameActorMoveable:GetGameActorActionHandler()
end

function gameActorMoveable:dirtyAnimFlag()
end

function gameActorMoveable:stopAnimToFrame( frameIndex )
end

function gameActorMoveable:SetAdditionZorder( zorder )
    self.mAdditionZorder = zorder
end
function gameActorMoveable:GetAdditionZorder()
    return self.mAdditionZorder
end

function gameActorMoveable:SetInSafeZone(inSafe)
    self.inSafeZone = inSafe
end
function gameActorMoveable:GetInSafeZone()
    return self.inSafeZone
end

function gameActorMoveable:SetIsThrough(through)
    self.isThrough = through
end
function gameActorMoveable:IsThroughAble()
    return self.isThrough == 1
end

function gameActorMoveable:SetOwnerName(name)
    self.mOwnerName = name
end
function gameActorMoveable:GetOwnerName()
    return self.mOwnerName
end

function gameActorMoveable:SetOwnerID(id)
    self.mOwnerID = id
end
function gameActorMoveable:GetOwnerID()
    return self.mOwnerID
end

function gameActorMoveable:SetServerID(id)
    self.mServerID = id
end
function gameActorMoveable:GetServerID()
    return self.mServerID
end

function gameActorMoveable:Bright()
    if not self.mIsBright then
        self.mIsBright = true

        local actorAnim = self:GetAnimation()
        global.Facade:sendNotification(global.NoticeTable.HighLightNodeShader, actorAnim, global.MMO.SHADER_TYPE_HIGHTLIGHT)
    end
end
function gameActorMoveable:UnBright()
    if self.mIsBright then
        self.mIsBright = false

        local actorAnim = self:GetAnimation()
        global.Facade:sendNotification( global.NoticeTable.NormalNodeShader, { node = actorAnim } )
    end
end
function gameActorMoveable:IsBright()
    return self.mIsBright
end

function gameActorMoveable:IsArrived()
    return self.mIsArrived
end
function gameActorMoveable:SetIsArrived(b)
    self.mIsArrived = b
end

function gameActorMoveable:GetConfirmed()
    return self.mIsConfirmed
end
function gameActorMoveable:SetConfirmed(b)
    self.mIsConfirmed = b
end

function gameActorMoveable:SetNameColor(state)
    self.mNameColor = state
end
function gameActorMoveable:GetNameColor(state)
    return self.mNameColor
end

function gameActorMoveable:SetWarZone(state)
    self.mWarZone = state
end
function gameActorMoveable:IsWarZone()
    return self.mWarZone == 1
end

function gameActorMoveable:SetGMData(data)
    self.mGMData = data
end
function gameActorMoveable:GetGMData()
    return self.mGMData
end

function gameActorMoveable:SetShaBaKeZone(value)
    self.mShabakeZone = value
end

function gameActorMoveable:GetShaBaKeZone()
    return self.mShabakeZone
end

return gameActorMoveable
