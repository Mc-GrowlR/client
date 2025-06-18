local gameActorMoveable = require( "actor/gameActorMoveable")
local gameActorPlayer = class('gameActorPlayer', gameActorMoveable)

local gameActorStatePlayerIdle          = require( "actor/gameActorStatePlayerIdle" )
local gameActorStatePlayerWalk          = require( "actor/gameActorStatePlayerWalk" )
local gameActorStatePlayerRun           = require( "actor/gameActorStatePlayerRun" )
local gameActorStatePlayerAttack        = require( "actor/gameActorStatePlayerAttack" )
local gameActorStatePlayerSkill         = require( "actor/gameActorStatePlayerSkill" )
local gameActorStatePlayerDie           = require( "actor/gameActorStatePlayerDie" )
local gameActorStatePlayerStuck         = require( "actor/gameActorStatePlayerStuck" )
local gameActorStatePlayerReady         = require( "actor/gameActorStatePlayerReady" )
local gameActorStatePlayerMining        = require( "actor/gameActorStatePlayerMining" )
local gameActorStatePlayerSitdown       = require( "actor/gameActorStatePlayerSitdown" )
local gameActorStatePlayerRideRun       = require( "actor/gameActorStatePlayerRideRun" )
local gameActorStatePlayerDash          = require( "actor/gameActorStatePlayerDash" )
local gameActorStatePlayerDashWaiting   = require( "actor/gameActorStatePlayerDashWaiting" )
local gameActorStatePlayerOnPush        = require( "actor/gameActorStatePlayerOnPush" )
local gameActorStatePlayerTeleport      = require( "actor/gameActorStatePlayerTeleport" )
local gameActorStatePlayerIdleLock      = require( "actor/gameActorStatePlayerIdleLock" )
local gameActorStatePlayerTurn          = require( "actor/gameActorStatePlayerTurn" )
local gameActorStatePlayerYTPD          = require( "actor/gameActorStatePlayerYTPD" )
local gameActorStatePlayerZXC           = require( "actor/gameActorStatePlayerZXC" )
local gameActorStatePlayerSJS           = require( "actor/gameActorStatePlayerSJS" )
local gameActorStatePlayerDYZ           = require( "actor/gameActorStatePlayerDYZ" )
local gameActorStatePlayerHSQJ          = require( "actor/gameActorStatePlayerHSQJ" )
local gameActorStatePlayerFWJ           = require( "actor/gameActorStatePlayerFWJ" )
local gameActorStatePlayerJLB           = require( "actor/gameActorStatePlayerJLB" )
local gameActorStatePlayerBTXD          = require( "actor/gameActorStatePlayerBTXD" )
local gameActorStatePlayerSLP           = require( "actor/gameActorStatePlayerSLP" )
local gameActorStatePlayerHXJ           = require( "actor/gameActorStatePlayerHXJ" )
local gameActorStatePlayerBGZ           = require( "actor/gameActorStatePlayerBGZ" )
local gameActorStatePlayerSYZ           = require( "actor/gameActorStatePlayerSYZ" )
local gameActorStatePlayerWJGZ          = require( "actor/gameActorStatePlayerWJGZ" )
local gameActorStatePlayerDashFail      = require( "actor/gameActorStatePlayerDashFail" )
local gameActorStatePlayerSBYS          = require( "actor/gameActorStatePlayerSBYS" )
local gameActorStatePlayerAssassinRun       = require( "actor/gameActorStatePlayerAssassinRun" ) 
local gameActorStatePlayerAssassinSneak     = require( "actor/gameActorStatePlayerAssassinSneak" ) 
local gameActorStatePlayerAssassinSmite     = require( "actor/gameActorStatePlayerAssassinSmite" ) 
local gameActorStatePlayerAssassinSkill     = require( "actor/gameActorStatePlayerAssassinSkill" ) 
local gameActorStatePlayerAssassinSY        = require( "actor/gameActorStatePlayerAssassinSY" ) 
local gameActorStatePlayerAssassinUnknown   = require( "actor/gameActorStatePlayerAssassinUnknown" ) 
local gameActorStatePlayerAssassinXFT       = require( "actor/gameActorStatePlayerAssassinXFT" ) 
local gameActorStatePlayerJY                = require( "actor/gameActorStatePlayerJY" ) 
local gameActorStatePlayerJY2               = require( "actor/gameActorStatePlayerJY2" ) 
local gameActorStatePlayerTSZ               = require( "actor/gameActorStatePlayerTSZ" ) 
local gameActorStatePlayerXLFH              = require( "actor/gameActorStatePlayerXLFH" ) 
local gameActorStatePlayerCustom            = require( "actor/gameActorStatePlayerCustom" )

local actorFeatureID             = require( "actor/actorFeatureID" )
local optionsUtils               = requireProxy( "optionsUtils" )
local actorUtils                 = requireProxy( "actorUtils" )

function gameActorPlayer:checkAndCreateAvatarNode(avatar, tag)
    local node = avatar:getChildByTag( tag )
    if not node then
        node = cc.Node:create()
        node:setCascadeColorEnabled( true )
        node:setCascadeOpacityEnabled( true )
        avatar:addChild( node, 0, tag )
    end

    return node
end

local walkOnly = SL:GetMetaValue("GAME_DATA","gameOption_WalkOnly") == 1
local horseHair= SL:GetMetaValue("GAME_DATA","horse_hair") == 1

local mmo = global.MMO
local mapActAnim_WalkOnly = {
    [mmo.ACTION_IDLE]           = mmo.ANIM_IDLE,
    [mmo.ACTION_WALK]           = walkOnly and mmo.ANIM_RUN or mmo.ANIM_WALK,
    [mmo.ACTION_ATTACK]         = mmo.ANIM_ATTACK,
    [mmo.ACTION_SKILL]          = mmo.ANIM_SKILL,
    [mmo.ACTION_DIE]            = mmo.ANIM_DIE,
    [mmo.ACTION_RUN]            = mmo.ANIM_RUN,
    [mmo.ACTION_STUCK]          = mmo.ANIM_STUCK,
    [mmo.ACTION_READY]          = mmo.ANIM_READY,
    [mmo.ACTION_MINING]         = mmo.ANIM_MINING,
    [mmo.ACTION_SITDOWN]        = mmo.ANIM_SITDOWN,
    [mmo.ACTION_DEATH]          = mmo.ANIM_DEATH,
    [mmo.ACTION_TURN]           = mmo.ANIM_IDLE,
    [mmo.ACTION_RIDE_RUN]       = mmo.ANIM_RUN,
    [mmo.ACTION_DASH]           = mmo.ANIM_RUN,
    [mmo.ACTION_ONPUSH]         = mmo.ANIM_RUN,
    [mmo.ACTION_DASH_WAITING]   = mmo.ANIM_IDLE,
    [mmo.ACTION_TELEPORT]       = mmo.ANIM_IDLE,
    [mmo.ACTION_IDLE_LOCK]      = mmo.ANIM_IDLE,
    [mmo.ACTION_YTPD]           = mmo.ANIM_YTPD,
    [mmo.ACTION_ZXC]            = mmo.ANIM_ZXC,
    [mmo.ACTION_SJS]            = mmo.ANIM_SJS,
    [mmo.ACTION_DYZ]            = mmo.ANIM_DYZ,
    [mmo.ACTION_HSQJ]           = mmo.ANIM_HSQJ,
    [mmo.ACTION_FWJ]            = mmo.ANIM_FWJ,
    [mmo.ACTION_JLB]            = mmo.ANIM_JLB,
    [mmo.ACTION_BTXD]           = mmo.ANIM_BTXD,
    [mmo.ACTION_SLP]            = mmo.ANIM_SLP,
    [mmo.ACTION_HXJ]            = mmo.ANIM_HXJ,
    [mmo.ACTION_BGZ]            = mmo.ANIM_BGZ,
    [mmo.ACTION_SYZ]            = mmo.ANIM_SYZ,
    [mmo.ACTION_WJGZ]           = mmo.ANIM_WJGZ,
    [mmo.ACTION_DASH_FAIL]      = mmo.ANIM_RUN,
    [mmo.ACTION_SBYS]           = mmo.ANIM_IDLE,
    [mmo.ACTION_ASSASSIN_RUN]     = mmo.ANIM_ASSASSIN_RUN,      -- 刺客跑步
	[mmo.ACTION_ASSASSIN_SNEAK]   = mmo.ANIM_ASSASSIN_SNEAK,    -- 刺客潜行
	[mmo.ACTION_ASSASSIN_SMITE]   = mmo.ANIM_ASSASSIN_SMITE,    -- 刺客重击
	[mmo.ACTION_ASSASSIN_SKILL]   = mmo.ANIM_ASSASSIN_SKILL,    -- 刺客施法
	[mmo.ACTION_ASSASSIN_SY]      = mmo.ANIM_ASSASSIN_SY,       -- 刺客霜月
	[mmo.ACTION_ASSASSIN_UNKNOWN] = mmo.ANIM_ASSASSIN_UNKNOWN,  -- 刺客未知动作 
	[mmo.ACTION_ASSASSIN_XFT]     = mmo.ANIM_ASSASSIN_XFT,      -- 旋风腿
	[mmo.ACTION_JY]               = mmo.ANIM_JY,                -- 箭雨1
	[mmo.ACTION_JY2]              = mmo.ANIM_JY2,               -- 箭雨2
	[mmo.ACTION_TSZ]              = mmo.ANIM_TSZ,               -- 推山掌
	[mmo.ACTION_XLFH]             = mmo.ANIM_XLFH,              -- 降龙伏虎
}

-- 自定义
for i = mmo.ACTION_CUSTOM_MIN, mmo.ACTION_CUSTOM_MAX, 1 do
    mapActAnim_WalkOnly[i] = mmo.ANIM_CUSTOM_MIN + (i - mmo.ACTION_CUSTOM_MIN)
end

local mapActAnim = {
    [mmo.ACTION_IDLE]           = mmo.ANIM_IDLE,
    [mmo.ACTION_WALK]           = mmo.ANIM_WALK,
    [mmo.ACTION_ATTACK]         = mmo.ANIM_ATTACK,
    [mmo.ACTION_SKILL]          = mmo.ANIM_SKILL,
    [mmo.ACTION_DIE]            = mmo.ANIM_DIE,
    [mmo.ACTION_RUN]            = mmo.ANIM_RUN,
    [mmo.ACTION_STUCK]          = mmo.ANIM_STUCK,
    [mmo.ACTION_READY]          = mmo.ANIM_READY,
    [mmo.ACTION_MINING]         = mmo.ANIM_MINING,
    [mmo.ACTION_SITDOWN]        = mmo.ANIM_SITDOWN,
    [mmo.ACTION_DEATH]          = mmo.ANIM_DEATH,
    [mmo.ACTION_TURN]           = mmo.ANIM_IDLE,
    [mmo.ACTION_RIDE_RUN]       = mmo.ANIM_RUN,
    [mmo.ACTION_DASH]           = mmo.ANIM_RUN,
    [mmo.ACTION_ONPUSH]         = mmo.ANIM_RUN,
    [mmo.ACTION_DASH_WAITING]   = mmo.ANIM_IDLE,
    [mmo.ACTION_TELEPORT]       = mmo.ANIM_IDLE,
    [mmo.ACTION_IDLE_LOCK]      = mmo.ANIM_IDLE,
    [mmo.ACTION_YTPD]           = mmo.ANIM_YTPD,
    [mmo.ACTION_ZXC]            = mmo.ANIM_ZXC,
    [mmo.ACTION_SJS]            = mmo.ANIM_SJS,
    [mmo.ACTION_DYZ]            = mmo.ANIM_DYZ,
    [mmo.ACTION_HSQJ]           = mmo.ANIM_HSQJ,
    [mmo.ACTION_FWJ]            = mmo.ANIM_FWJ,
    [mmo.ACTION_JLB]            = mmo.ANIM_JLB,
    [mmo.ACTION_BTXD]           = mmo.ANIM_BTXD,
    [mmo.ACTION_SLP]            = mmo.ANIM_SLP,
    [mmo.ACTION_HXJ]            = mmo.ANIM_HXJ,
    [mmo.ACTION_BGZ]            = mmo.ANIM_BGZ,
    [mmo.ACTION_SYZ]            = mmo.ANIM_SYZ,
    [mmo.ACTION_WJGZ]           = mmo.ANIM_WJGZ,
    [mmo.ACTION_DASH_FAIL]      = mmo.ANIM_RUN,
    [mmo.ACTION_SBYS]           = mmo.ANIM_IDLE,
    [mmo.ACTION_ASSASSIN_RUN]     = mmo.ANIM_ASSASSIN_RUN,      -- 刺客跑步
	[mmo.ACTION_ASSASSIN_SNEAK]   = mmo.ANIM_ASSASSIN_SNEAK,    -- 刺客潜行
	[mmo.ACTION_ASSASSIN_SMITE]   = mmo.ANIM_ASSASSIN_SMITE,    -- 刺客重击
	[mmo.ACTION_ASSASSIN_SKILL]   = mmo.ANIM_ASSASSIN_SKILL,    -- 刺客施法
	[mmo.ACTION_ASSASSIN_SY]      = mmo.ANIM_ASSASSIN_SY,       -- 刺客霜月
	[mmo.ACTION_ASSASSIN_UNKNOWN] = mmo.ANIM_ASSASSIN_UNKNOWN,  -- 刺客未知动作 
	[mmo.ACTION_ASSASSIN_XFT]     = mmo.ANIM_ASSASSIN_XFT,      -- 旋风腿
	[mmo.ACTION_JY]               = mmo.ANIM_JY,                -- 箭雨1
	[mmo.ACTION_JY2]              = mmo.ANIM_JY2,               -- 箭雨2
	[mmo.ACTION_TSZ]              = mmo.ANIM_TSZ,               -- 推山掌
	[mmo.ACTION_XLFH]             = mmo.ANIM_XLFH,              -- 降龙伏虎
}

-- 自定义
for i = mmo.ACTION_CUSTOM_MIN, mmo.ACTION_CUSTOM_MAX, 1 do
    mapActAnim[i] = mmo.ANIM_CUSTOM_MIN + (i - mmo.ACTION_CUSTOM_MIN)
end

local featureMapActAnic = {
    [mmo.P_F_MONSTER_EFF] = {
        [mmo.ANIM_IDLE]         = mmo.ANIM_RIDE_IDLE,
        [mmo.ANIM_WALK]         = mmo.ANIM_RIDE_WALK,
        [mmo.ANIM_RUN]          = mmo.ANIM_RIDE_RUN,
        [mmo.ANIM_DIE]          = mmo.ANIM_RIDE_DIE,
        [mmo.ACTION_ATTACK]     = mmo.ANIM_RIDE_IDLE,
        [mmo.ACTION_SKILL]      = mmo.ANIM_RIDE_IDLE,
    },
    [mmo.P_F_HAIR] = {
        [mmo.ANIM_IDLE]         = mmo.ANIM_RIDE_IDLE,
        [mmo.ANIM_WALK]         = mmo.ANIM_RIDE_WALK,
        [mmo.ANIM_RUN]          = mmo.ANIM_RIDE_RUN,
        [mmo.ANIM_DIE]          = mmo.ANIM_RIDE_DIE,
        [mmo.ANIM_ATTACK]       = mmo.ANIM_RIDE_IDLE,
        [mmo.ANIM_SKILL]        = mmo.ANIM_RIDE_IDLE,
    }
}

local actSpeedFunc = {
    [mmo.ANIM_ATTACK]           = gameActorPlayer.GetAttackAnimSpeed,
    [mmo.ANIM_SKILL]            = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_MINING]           = gameActorPlayer.GetAttackAnimSpeed,
    [mmo.ANIM_YTPD]             = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_ZXC]              = gameActorPlayer.GetAttackAnimSpeed,
    [mmo.ANIM_SJS]              = gameActorPlayer.GetAttackAnimSpeed,
    [mmo.ANIM_DYZ]              = gameActorPlayer.GetAttackAnimSpeed,
    [mmo.ANIM_HSQJ]             = gameActorPlayer.GetAttackAnimSpeed,
    [mmo.ANIM_FWJ]              = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_JLB]              = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_BTXD]             = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_SLP]              = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_HXJ]              = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_BGZ]              = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_SYZ]              = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_WJGZ]             = gameActorPlayer.GetMagicAnimSpeed,
    [mmo.ANIM_SITDOWN]          = gameActorPlayer.GetAttackAnimSpeed,
    [mmo.ANIM_ASSASSIN_SMITE]   = gameActorPlayer.GetAttackAnimSpeed,  -- 刺客重击
    [mmo.ANIM_ASSASSIN_SKILL]   = gameActorPlayer.GetAttackAnimSpeed,  -- 刺客施法
    [mmo.ANIM_ASSASSIN_SY]      = gameActorPlayer.GetAttackAnimSpeed,  -- 刺客霜月
    [mmo.ANIM_ASSASSIN_UNKNOWN] = gameActorPlayer.GetAttackAnimSpeed,  -- 刺客未知动作 
    [mmo.ANIM_ASSASSIN_XFT]     = gameActorPlayer.GetAttackAnimSpeed,  -- 旋风腿
    [mmo.ANIM_JY]               = gameActorPlayer.GetMagicAnimSpeed,   -- 箭雨1
    [mmo.ANIM_JY2]              = gameActorPlayer.GetMagicAnimSpeed,   -- 箭雨2
    [mmo.ANIM_TSZ]              = gameActorPlayer.GetAttackAnimSpeed,  -- 推山掌
    [mmo.ANIM_XLFH]             = gameActorPlayer.GetAttackAnimSpeed,  -- 降龙伏虎
}

local configActSpeedFunc = {
    [mmo.ANIM_YTPD]             = true,
    [mmo.ANIM_ZXC]              = true,
    [mmo.ANIM_SJS]              = true,
    [mmo.ANIM_DYZ]              = true,
    [mmo.ANIM_HSQJ]             = true,
    [mmo.ANIM_FWJ]              = true,
    [mmo.ANIM_JLB]              = true,
    [mmo.ANIM_BTXD]             = true,
    [mmo.ANIM_SLP]              = true,
    [mmo.ANIM_HXJ]              = true,
    [mmo.ANIM_BGZ]              = true,
    [mmo.ANIM_SYZ]              = true,
    [mmo.ANIM_WJGZ]             = true,
    [mmo.ANIM_ASSASSIN_SMITE]   = true,  -- 刺客重击
    [mmo.ANIM_ASSASSIN_SKILL]   = true,  -- 刺客施法
    [mmo.ANIM_ASSASSIN_SY]      = true,  -- 刺客霜月
    [mmo.ANIM_ASSASSIN_UNKNOWN] = true,  -- 刺客未知动作 
    [mmo.ANIM_ASSASSIN_XFT]     = true,  -- 旋风腿
    [mmo.ANIM_JY]               = true,  -- 箭雨1
    [mmo.ANIM_JY2]              = true,  -- 箭雨2
    [mmo.ANIM_TSZ]              = true,  -- 推山掌
    [mmo.ANIM_XLFH]             = true,  -- 降龙伏虎
}

-- 自定义
for i = mmo.ANIM_CUSTOM_MIN, mmo.ANIM_CUSTOM_MAX, 1 do
    configActSpeedFunc[i] = true
end


local isStateInited = false
local actState      = {}


function gameActorPlayer:getPlayerActionState(act)
    if act > mmo.ACTION_MAX then
        return nil
    end

    if not isStateInited  then
        actState[mmo.ACTION_IDLE]            = gameActorStatePlayerIdle.new()
        actState[mmo.ACTION_WALK]            = gameActorStatePlayerWalk.new()
        actState[mmo.ACTION_RUN]             = gameActorStatePlayerRun.new()
        actState[mmo.ACTION_ATTACK]          = gameActorStatePlayerAttack.new()
        actState[mmo.ACTION_SKILL]           = gameActorStatePlayerSkill.new()
        actState[mmo.ACTION_DIE]             = gameActorStatePlayerDie.new()
        actState[mmo.ACTION_STUCK]           = gameActorStatePlayerStuck.new()
        actState[mmo.ACTION_READY]           = gameActorStatePlayerReady.new()
        actState[mmo.ACTION_MINING]          = gameActorStatePlayerMining.new()
        actState[mmo.ACTION_SITDOWN]         = gameActorStatePlayerSitdown.new()
        actState[mmo.ACTION_DEATH]           = gameActorStatePlayerDie.new()
        actState[mmo.ACTION_TURN]            = gameActorStatePlayerTurn.new()
        actState[mmo.ACTION_RIDE_RUN]        = gameActorStatePlayerRideRun.new()
        actState[mmo.ACTION_DASH]            = gameActorStatePlayerDash.new()
        actState[mmo.ACTION_ONPUSH]          = gameActorStatePlayerOnPush.new()
        actState[mmo.ACTION_DASH_WAITING]    = gameActorStatePlayerDashWaiting.new()
        actState[mmo.ACTION_TELEPORT]        = gameActorStatePlayerTeleport.new()
        actState[mmo.ACTION_IDLE_LOCK]       = gameActorStatePlayerIdleLock.new()
        actState[mmo.ACTION_YTPD]            = gameActorStatePlayerYTPD.new()
        actState[mmo.ACTION_ZXC]             = gameActorStatePlayerZXC.new()
        actState[mmo.ACTION_SJS]             = gameActorStatePlayerSJS.new()
        actState[mmo.ACTION_DYZ]             = gameActorStatePlayerDYZ.new()
        actState[mmo.ACTION_HSQJ]            = gameActorStatePlayerHSQJ.new()
        actState[mmo.ACTION_FWJ]             = gameActorStatePlayerFWJ.new()
        actState[mmo.ACTION_JLB]             = gameActorStatePlayerJLB.new()
        actState[mmo.ACTION_BTXD]            = gameActorStatePlayerBTXD.new()
        actState[mmo.ACTION_SLP]             = gameActorStatePlayerSLP.new()
        actState[mmo.ACTION_HXJ]             = gameActorStatePlayerHXJ.new()
        actState[mmo.ACTION_BGZ]             = gameActorStatePlayerBGZ.new()
        actState[mmo.ACTION_SYZ]             = gameActorStatePlayerSYZ.new()
        actState[mmo.ACTION_WJGZ]            = gameActorStatePlayerWJGZ.new()
        actState[mmo.ACTION_DASH_FAIL]       = gameActorStatePlayerDashFail.new()
        actState[mmo.ACTION_SBYS]            = gameActorStatePlayerSBYS.new()
        actState[mmo.ACTION_ASSASSIN_RUN]     = gameActorStatePlayerAssassinRun.new()      -- 刺客跑步
        actState[mmo.ACTION_ASSASSIN_SNEAK]   = gameActorStatePlayerAssassinSneak.new()    -- 刺客潜行
        actState[mmo.ACTION_ASSASSIN_SMITE]   = gameActorStatePlayerAssassinSmite.new()    -- 刺客重击
        actState[mmo.ACTION_ASSASSIN_SKILL]   = gameActorStatePlayerAssassinSkill.new()    -- 刺客施法
        actState[mmo.ACTION_ASSASSIN_SY]      = gameActorStatePlayerAssassinSY.new()       -- 刺客霜月
        actState[mmo.ACTION_ASSASSIN_UNKNOWN] = gameActorStatePlayerAssassinUnknown.new()  -- 刺客未知动作 
        actState[mmo.ACTION_ASSASSIN_XFT]     = gameActorStatePlayerAssassinXFT.new()      -- 旋风腿
        actState[mmo.ACTION_JY]               = gameActorStatePlayerJY.new()               -- 箭雨1
        actState[mmo.ACTION_JY2]              = gameActorStatePlayerJY2.new()              -- 箭雨2
        actState[mmo.ACTION_TSZ]              = gameActorStatePlayerTSZ.new()              -- 推山掌
        actState[mmo.ACTION_XLFH]             = gameActorStatePlayerXLFH.new()             -- 降龙伏虎

        -- 自定义
        for i = mmo.ACTION_CUSTOM_MIN, mmo.ACTION_CUSTOM_MAX, 1 do
            actState[i] = gameActorStatePlayerCustom.new(i, i - mmo.ACTION_CUSTOM_MIN + mmo.ANIM_CUSTOM_MIN)
        end

        isStateInited = true
    end

    return actState[act]
end


function gameActorPlayer:ctor()
    gameActorPlayer.super.ctor(self)
end

function gameActorPlayer:init()
    gameActorPlayer.super.init(self)

    self.mCurrentState  = self:getPlayerActionState( self.mAction )
    self.mIsArrived     = true
    self.mIsConfirmed   = true
    self.mActionHandler = nil
    self.mCurrentActT   = 0
    self.mDashWaiting   = false         -- 野蛮等待

    self.mAnimPrepare       = 0.0
    self.mMoveOrient        = cc.p( 0.0, 0.0 )
    self.mTargePos          = cc.p( 0.0, 0.0 )
    self.mDistanceToTarget  = 0.0

    self.mAnimAct                   = mmo.ANIM_IDLE
    self.mIsAnimNeedToUpdate        = false
    self.mCurrPlayerAvatarNode      = nil
    self.mAnimationWeapon           = nil
    self.mAnimationShield           = nil
    self.mAnimationWings            = nil
    self.mAnimationHair             = nil
    self.mAnimationMonster          = nil
    self.mAnimationWeaponEff        = nil
    self.mAnimationShieldEffect     = nil
    self.mAnimationLeftWeapon       = nil
    self.mAnimationLeftWeaponEff    = nil
    self.mStopAnimFrameIndex        = nil
    self.mAnimationElapsed          = nil

    self.mFeatureDirty              = false
    self.mFeature = {}
    self.mFeature[mmo.P_F_CLOTH]  = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_WEAPON] = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_SHIELD] = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_WINGS]  = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_HAIR]   = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_MONSTER] = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_WEAPON_EFF] = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_MONSTER_EFF] = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_MONSTER_CLOTH] = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_SHIELD_EFF] = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_LEFT_WEAPON] = actorFeatureID.new( -1 )
    self.mFeature[mmo.P_F_LEFT_WEAPON_EFF] = actorFeatureID.new( -1 )

    self.mHP           = 0
    self.mMaxHP        = 0
    self.mMP           = 0
    self.mMaxMP        = 0
    self.mHUDUI        = {}
    self.mForce        = 0
    self.mMaxForce     = 0

    self.mSex          = mmo.ACTOR_PLAYER_SEX_F
    self.mJobID        = mmo.ACTOR_PLAYER_JOB_FIGHTER
    self.mLevel        = 0
    self.mTeamState    = 0
    self.isOffLine     = nil

    self.mNearShow     = 0

    self.mAttacked     = false      -- 是否被攻击过   没被攻击过  刚刚进视野要是满血状态 2021-11-6 文华提的需求
    self.mMouleHorse   = nil        -- 坐骑状态区分（0：单人   1：双人  2：连体）

    self.mMoveEff      = nil        -- 移动足迹特效
    self.mMoveEffSkip  = nil        -- 移动足迹特效跳过一步走
    self.mIsSkip       = nil        -- 移动足迹特效 是否跳过一步（0：跳过 1：不跳过）

    self.mDearID       = ""         -- 夫妻ID
    self.mSiTuID       = ""         -- 师徒ID

    self.mReLevel      = 0          -- 转生颜色变色，转生等级
    self.mReLvRadom    = nil        -- 转生颜色变色，取actor的ID的后5位数值用作随机数
    self.mReLvTimeCount= -1         -- 转生颜色变色，记录间隔时间

    self.mCamps = {
        InTeam = false, InGuild = false, InCamp = false
    }

    self.mHateID     = nil          -- 仇恨
end

function gameActorPlayer:destory()
    gameActorPlayer.super.destory(self)
    
    -- remove hud
    global.HUDManager:RemoveActorAllHUD( self.mID )
end

function gameActorPlayer:Tick(dt)
    gameActorPlayer.super.Tick(self, dt)
    
    if not self.skipOneTick then
        self.mCurrentState:Tick( dt, self )
    else
        self.skipOneTick = nil
    end

    if self.mFeatureDirty then
        self.mFeatureDirty = false
        self:checkFeature()
    end

    if self.mIsAnimNeedToUpdate then
        self:updateAnimation()
        self.mIsAnimNeedToUpdate = false
    end

    if self.mReLevel > 0 and actorUtils.actorIsReLvChange()  then
        if not self.mReLvRadom then
            self.mReLvRadom = tonumber( string.sub(self:GetID() or "", -6) )
        end
        
        if actorUtils.actorReLvChange(self, self.mReLvRadom, self.mReLvTimeCount) then
            self.mReLvTimeCount = 0
        end
        self.mReLvTimeCount = self.mReLvTimeCount + dt
    end
end

function gameActorPlayer:setPosition(x, y)
    gameActorPlayer.super.setPosition(self, x, y)

    -- refresh zOrder
    if self.mAction == mmo.ACTION_DIE then
        self:GetNode():setLocalZOrder( -(y) + self:GetAdditionZorder() + mmo.DieAddZorder )
    else
        self:GetNode():setLocalZOrder( -(y) + self:GetAdditionZorder())
    end

    -- update hud pos
    local hudTop = self:GetHUDTop()
    global.HUDManager:setPosition( self.mID, x, y + hudTop )

    -- update buff pos
    global.BuffManager:setPosition(self:GetID(), x, y)
    global.ActorEffectManager:setPosition(self:GetID(), x, y)
    --update light pos
    local light = self:GetLightID()
    if light  then 
        global.darkNodeManager:updateNode(light, {x = x, y = y, offset = cc.p(0, global.MMO.PLAYER_AVATAR_OFFSET.y)})
    end
end

function gameActorPlayer:SetMoveTo( pos )
    self.mMoveTo = pos 
end

function gameActorPlayer:SetAction(newAction, isTerminate)
    if not isTerminate then isTerminate = false end

    local   stateNew  = self:getPlayerActionState( newAction )
    local   stateOld  = self.mCurrentState
    local   oldAction = self.mAction

    if self.mCurrentState:ChangeState( stateNew, self, isTerminate ) then    
        if 0 ~= stateOld then
            stateOld:OnExit( self )
        end

        self.mAction = newAction    

        if 0 ~= stateNew then
            stateNew:OnEnter( self )
        end

        if (isTerminate or oldAction ~= newAction) and self:GetAnimPrepare() <= 0 then
            local actAnim = (walkOnly and not (self:IsHumanoid() or self:IsHero())) and mapActAnim_WalkOnly[newAction] or mapActAnim[newAction]
            self:SetAnimAct( actAnim )

            -- 
            if stateNew ~= mmo.ACTION_IDLE then
                self.skipOneTick = true
            end
        end
    end
end

function gameActorPlayer:SetAnimAct(newAnim)
    if self.mAnimAct ~= newAnim then
        self.mAnimAct = newAnim

        -- in die anim, zOrder is lowest
        if newAnim == mmo.ANIM_DIE then
            self:GetNode():setLocalZOrder( -self:getPosition().y + self:GetAdditionZorder() + mmo.DieAddZorder )
        end
    end
end

function gameActorPlayer:SetHPHUD(HP, maxHP)
    local preHp = self.mHP
    
    self:SetHP(HP)
    self:SetMaxHP(maxHP)

    self:SetKeyValue(mmo.HUD_Hp_Full, self.mHP >= self.mMaxHP and self.mMaxHP > 0)
    self:SetKeyValue(mmo.HUD_Hp_Null, self.mHP < 1 or self.mMaxHP < 1)
    
    local bar = self.mHUDUI[mmo.HUDHPUI_BAR]
    if not bar then
        return false
    end

    if preHp > HP then
        self:SetKeyValue(mmo.HUD_BAR_SHOW_FULL_HP, true)
    end

    local hpPerc = HP / maxHP
    if global.ConstantConfig.showFewHp == 1 and not self:GetValueByKey(mmo.HUD_BAR_SHOW_FULL_HP) then
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        local heroActor  = HeroPropertyProxy:GetHeroActor()
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        if self ~= heroActor and self ~= mainPlayer then 
            hpPerc = 1
        end
    end

    global.HUDManager:SetHUDBarPercent( bar, hpPerc )

    optionsUtils:InitHUDVisibleValue(self, mmo.HUD_HPBAR_VISIBLE)
    optionsUtils:InitHUDVisibleValue(self, mmo.HUD_HMPLabel_VISIBLE)
    optionsUtils:CheckHUDHpBarVisible(self)

    global.HUDHPManager:Update(self)
end

function gameActorPlayer:SetShieldHUD(MP, maxMP)
    self:SetMP( MP )
    self:SetMaxMP( maxMP )

    if maxMP < 1 then
        return false
    end

    if not self.mHUDUI[mmo.HUDMPUI_BAR] then
        return false
    end

    local bar = self.mHUDUI[mmo.HUDMPUI_BAR]
    local percent = MP / maxMP
    global.HUDManager:SetHUDBarPercent( bar, percent )

    optionsUtils:InitHUDVisibleValue(self, mmo.HUD_MPBAR_VISIBLE)
    optionsUtils:CheckHUDMpBarVisible(self)
end

function gameActorPlayer:SetHP(HP)
	self.mHP = HP or 0
end

function gameActorPlayer:SetMaxHP(maxHP)
	self.mMaxHP = maxHP or 0
end

function gameActorPlayer:GetHP() 
    return self.mHP
end
function gameActorPlayer:GetMaxHP()
    return self.mMaxHP
end

function gameActorPlayer:SetMP(MP)
	self.mMP = MP or 0
end
function gameActorPlayer:GetMP()
    return self.mMP
end

function gameActorPlayer:SetMaxMP(maxMP)
	self.mMaxMP = maxMP or 0
end
function gameActorPlayer:GetMaxMP()
	return self.mMaxMP
end

-- 内力值
function gameActorPlayer:SetForce(value)
	self.mForce = value
end
function gameActorPlayer:GetForce()
    return self.mForce
end

function gameActorPlayer:SetMaxForce(value)
	self.mMaxForce = value
end
function gameActorPlayer:GetMaxForce()
	return self.mMaxForce
end

function gameActorPlayer:SetNGHUD(force, maxForce)
    self:SetForce(force)
    self:SetMaxForce(maxForce)

    if not maxForce or maxForce <= 0 then
        return nil
    end

    if not self.mHUDUI[global.MMO.HUDNGUI_BAR] then
        return
    end

    local bar = self.mHUDUI[mmo.HUDNGUI_BAR]
    local percent = force / maxForce
    global.HUDManager:SetHUDBarPercent( bar, percent )

    optionsUtils:InitHUDVisibleValue(self, mmo.HUD_NGBAR_VISIBLE)
    optionsUtils:CheckHUDNGBarVisible(self)
end

function gameActorPlayer:InitParam()
    self.mCurrActorNode        = cc.Node:create()
    self.mCurrPlayerAvatarNode = cc.Node:create()
    self.mCurrActorNode:addChild( self.mCurrPlayerAvatarNode )
    self.mCurrPlayerAvatarNode:setTag( mmo.PLAYER_AVATAR_TAG )
    self.mCurrPlayerAvatarNode:setCascadeColorEnabled( true )
    self.mCurrPlayerAvatarNode:setCascadeOpacityEnabled( true )
    self.mCurrPlayerAvatarNode:setPosition( mmo.PLAYER_AVATAR_OFFSET )

    self.mCurrMountNode = cc.Node:create()
    self.mCurrActorNode:addChild(self.mCurrMountNode)
    self.mCurrMountNode:setTag(mmo.PLAYER_MOUNT_TAG)
    self.mCurrMountNode:setPosition(mmo.PLAYER_AVATAR_OFFSET)

    return 1
end

function gameActorPlayer:animDisplay( anim, isParentzOrer, act, dir, isLoop, zOrder, visible )
    if not anim then
        return 
    end

    if isParentzOrer then
        local parent = anim:getParent()
        if parent then
            parent:setLocalZOrder( zOrder )
        end
    else
        anim:setLocalZOrder( zOrder )
    end

    anim:setVisible( visible )
    if visible then
        local speed = 1
        local needStop = true

        if act == mmo.ANIM_IDLE then
            needStop = false
        elseif act == mmo.ANIM_WALK or act == mmo.ANIM_ASSASSIN_SNEAK then
            speed = self:GetWalkSpeed()
            -- needStop = false
        elseif act == mmo.ANIM_RUN or act == mmo.ANIM_ASSASSIN_RUN then
            local runOneSpeed = self:GetValueByKey(global.MMO.IS_RUN_ONE) and 2 or 1
            speed = (walkOnly and runOneSpeed == 1 and not (self:IsHumanoid() or self:IsHero())) and self:GetWalkSpeed() / 2 or self:GetRunSpeed() / runOneSpeed
            needStop = ((not walkOnly and runOneSpeed == 1) or (self:IsHumanoid() or self:IsHero()))
        elseif configActSpeedFunc[act] then
            local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
            local actoionSpeed  = SkillPoxy:GetSkillActionSpeed(act)
            if actoionSpeed == 0 then
                speed = self:GetAttackAnimSpeed()
            elseif actoionSpeed == 1 then
                speed = self:GetMagicAnimSpeed()
            elseif actSpeedFunc[act] then
                local getSpeedFunc = actSpeedFunc[act]
                speed = getSpeedFunc(self)
            end

        elseif actSpeedFunc[act] then
            local getSpeedFunc = actSpeedFunc[act]
            speed = getSpeedFunc(self)
        end

        if needStop then
            anim:Stop()
        end
        anim:SyncElapsed( self.mAnimationElapsed )
        anim:Play( act, dir, isLoop, speed )
    else
        anim:Stop()
    end
end

function gameActorPlayer:stopAnimToFrame( frameIndex )
    self.mStopAnimFrameIndex = frameIndex
end

function gameActorPlayer:StopAllAnimation( frameIndex )
    if self.mAnimation then
        self.mAnimation:Stop( frameIndex, self.mAnimAct, self.mOrient )
    end

    if self.mAnimationWeapon then
        self.mAnimationWeapon:Stop( frameIndex, self.mAnimAct, self.mOrientx )
    end

    if self.mAnimationShield then
        self.mAnimationShield:Stop( frameIndex, self.mAnimAct, self.mOrient )
    end

    if self.mAnimationWings then
        self.mAnimationWings:Stop( frameIndex, self.mAnimAct, self.mOrient )
    end

    if self.mAnimationHair then
        self.mAnimationHair:Stop( frameIndex, self.mAnimAct, self.mOrient )
    end
    
    if self.mAnimationMonster then
        self.mAnimationMonster:Stop( frameIndex, self.mAnimAct, self.mOrient )
    end
    
    if self.mAnimationWeaponEff then
        self.mAnimationWeaponEff:Stop( frameIndex, self.mAnimAct, self.mOrient )
    end

    if self.mAnimationShieldEffect then
        self.mAnimationShieldEffect:Stop( frameIndex, self.mAnimAct, self.mOrient )
    end

    if self.mAnimationLeftWeapon then
        self.mAnimationLeftWeapon:Stop( frameIndex, self.mAnimAct, self.mOrientx )
    end

    if self.mAnimationLeftWeaponEff then
        self.mAnimationLeftWeaponEff:Stop( frameIndex, self.mAnimAct, self.mOrientx )
    end
end

function gameActorPlayer:updateAnimation()
    -- render order by act
    local renderOrder = actorUtils.PlayerRenderOrder[self.mAnimAct]
    if nil == renderOrder then
        renderOrder = actorUtils.PlayerRenderOrder[mmo.ANIM_IDLE]
    end


    local isLoop = self.mAnimAct == mmo.ANIM_IDLE or self.mAnimAct == mmo.ANIM_WALK or self.mAnimAct == mmo.ANIM_RUN
    local showMonster = self.mAnimationMonster ~= nil
    local showCloth  = not showMonster
    local showWeapon = not showMonster
    local showShield = not showMonster
    local showWings  = not showMonster
    local showHair   = not showMonster
    local showMonsterCloth = showMonster

    local showMapActAnic = false
    if self:GetHorseMasterID() then
        showMapActAnic = true
        if self:IsDoubleHorse() or self:IsBodyHorse() then
            showMonsterCloth = false
        else
            showHair = horseHair
        end
    end

    local newOrient = self.mOrient
    local weaponID = self:GetAnimationWeaponID()
    local renderWeaponOrder = actorUtils.PlayerWeaponRenderOrder
    if weaponID and renderWeaponOrder and renderWeaponOrder[weaponID*100+self.mAnimAct] then
        if renderWeaponOrder[weaponID*100+self.mAnimAct][newOrient+1] then
            renderOrder = renderWeaponOrder[weaponID*100+self.mAnimAct]
        end
    end
    
    -- cloth
    self:animDisplay( self.mAnimation, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][2], showCloth )

    -- weapon
    self:animDisplay( self.mAnimationWeapon, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][1], showWeapon )

    -- shield
    self:animDisplay( self.mAnimationShield, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][4], showShield )

    -- wings
    self:animDisplay( self.mAnimationWings, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][3], showWings )

    -- hair
    self:animDisplay( self.mAnimationHair, true, showMapActAnic and featureMapActAnic[mmo.P_F_HAIR][self.mAnimAct] or self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][5], showHair )

    -- monster
    self:animDisplay( self.mAnimationMonster, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][2], showMonster )

    --weaponEffect
    self:animDisplay( self.mAnimationWeaponEff, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][1], showWeapon )

    --monsterEffect
    self:animDisplay( self.mAnimationMonsterEff, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][2]+1, showMonster )

    --moster cloth
    self:animDisplay( self.mAnimationMonsterCloth, true, showMapActAnic and featureMapActAnic[mmo.P_F_MONSTER_EFF][self.mAnimAct] or self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][2], showMonsterCloth )

    --shield effect
    self:animDisplay( self.mAnimationShieldEffect, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][4], showShield )

    --left weapon
    self:animDisplay( self.mAnimationLeftWeapon, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][6], showWeapon )

    --left weaponEffect
    self:animDisplay( self.mAnimationLeftWeaponEff, true, self.mAnimAct, self.mOrient, isLoop, renderOrder[newOrient+1][6], showWeapon )

    -- stop
    if self.mStopAnimFrameIndex then
        self:StopAllAnimation( self.mStopAnimFrameIndex )
    end

    -- 
    global.Facade:sendNotification(global.NoticeTable.ActorBuffPresentUpdate, self:GetID())

    self.mAnimationElapsed = nil
end

function gameActorPlayer:onSequAnimLoadCompleted(animType, playerID, animID, seqAnim)
    if animType == mmo.SFANIM_TYPE_PLAYER or --replay animation to make sure animations are synchronous
        animType == mmo.SFANIM_TYPE_WEAPON or 
        animType == mmo.SFANIM_TYPE_SHIELD or 
        animType == mmo.SFANIM_TYPE_WINGS then

        local player = global.actorManager:GetActor(playerID)
        if nil == player then
            return 
        end

        -- refresh HUD TOP
        if mmo.SFANIM_TYPE_PLAYER == animType then
            local pos = cc.p( player:getPosition() )
            player:setPosition( pos.x, pos.y )
        end
    end 
end

function gameActorPlayer:IsCloaking()
    return (self.mCover[2] == true)
end

function gameActorPlayer:setCloaking(isCloaking, index)
    -- 隐身术
    self.mCover[index] = isCloaking
    self:CalcCover()
end

function gameActorPlayer:CalcCover()
    local isInCover = false
    for k, v in pairs(self.mCover) do
        if v then
            isInCover = true
            break
        end
    end

    local opacityV = ( isInCover ) and 155 or 255 
    self.mCurrPlayerAvatarNode:setOpacity( opacityV )
end

function gameActorPlayer:SetLevel(level)
	self.mLevel = level
end


function gameActorPlayer:createAnim( ID, animType, lastAnim, tag, parentNode )
    local function addTexture(animID, seqAnim)
        self:onSequAnimLoadCompleted( animType, self:GetID(), animID, seqAnim )
    end

    local newAnim = nil
    if ID and ID > 0 then
        if lastAnim then
            if animType == mmo.SFANIM_TYPE_PLAYER then
                local sex = self:GetValueByKey( mmo.BUFF_PLAYER_AVATAR_SEX ) or self.mSex
                newAnim = global.FrameAnimManager:ResetActorPlayerAnim(lastAnim, ID, sex, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_WEAPON then
                newAnim = global.FrameAnimManager:ResetActorPlayerWeaponAnim(lastAnim, ID, self.mSex, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_SHIELD then
                newAnim = global.FrameAnimManager:ResetActorPlayerShieldAnim(lastAnim, ID, mmo.ACTOR_PLAYER_SEX_M, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_WINGS then
                newAnim = global.FrameAnimManager:ResetActorPlayerWingsAnim(lastAnim, ID, self.mSex, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_HAIR then
                newAnim = global.FrameAnimManager:ResetActorPlayerHairAnim(lastAnim, ID, self.mSex, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_MONSTER then
                local sex = self:GetValueByKey(global.MMO.HORSE_SEX)
                newAnim = global.FrameAnimManager:ResetActorMonsterAnim(lastAnim, ID, self.mAnimAct, addTexture,sex)
            end
        else
            if animType == mmo.SFANIM_TYPE_PLAYER then
                local sex = self:GetValueByKey( mmo.BUFF_PLAYER_AVATAR_SEX ) or self.mSex
                newAnim = global.FrameAnimManager:CreateActorPlayerAnim(ID, sex, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_WEAPON then
                newAnim = global.FrameAnimManager:CreateActorPlayerWeaponAnim(ID, self.mSex, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_SHIELD then
                newAnim = global.FrameAnimManager:CreateActorPlayerShieldAnim(ID, mmo.ACTOR_PLAYER_SEX_M, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_WINGS then
                newAnim = global.FrameAnimManager:CreateActorPlayerWingsAnim(ID, self.mSex, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_HAIR then
                newAnim = global.FrameAnimManager:CreateActorPlayerHairAnim(ID, self.mSex, self.mAnimAct, addTexture)
            elseif animType == mmo.SFANIM_TYPE_MONSTER then
                local sex = self:GetValueByKey(global.MMO.HORSE_SEX)
                newAnim = global.FrameAnimManager:CreateActorMonsterAnim(ID, self.mAnimAct, addTexture, sex)
            end
        end
    end 

    if newAnim then
        newAnim:Stop()
    end

    if not lastAnim and newAnim then
        if nil == tag then
            tag = 0
        end
        if nil == parentNode then
            parentNode = self:checkAndCreateAvatarNode( self.mCurrPlayerAvatarNode, tag )
        end

        parentNode:addChild( newAnim, 0, tag )
    end

    if lastAnim and not newAnim then
        lastAnim:removeFromParent()
    end

    self:dirtyAnimFlag()

    return newAnim
end

function gameActorPlayer:updateCloth(ID)
    if 0 == ID then
        local jobData = SL:GetMetaValue("GAME_DATA", "MultipleJobSetMap")[self.mJobID]
        local isOpenJob = jobData and jobData.isOpen
        ID =  isOpenJob and jobData.clothFeatureShowID or 9999
    end
    self.mAnimation = self:createAnim( ID, mmo.SFANIM_TYPE_PLAYER, self.mAnimation, mmo.PLAYER_BODY_TAG )
end

function gameActorPlayer:updateWeapon(ID)
    if ID == 9999 then
        ID = nil
    end
    self.mAnimationWeapon = self:createAnim( ID, mmo.SFANIM_TYPE_WEAPON, self.mAnimationWeapon, mmo.PLAYER_WEAPON_TAG )
end

function gameActorPlayer:updateLeftWeapon(ID)
    if ID == 9999 then
        ID = nil
    end
    self.mAnimationLeftWeapon = self:createAnim( ID, mmo.SFANIM_TYPE_WEAPON, self.mAnimationLeftWeapon, mmo.PLAYER_LEFT_WEAPON_TAG )
end  

function gameActorPlayer:updateShield(ID)
    if ID == 9999 then
        ID = nil
    end
    self.mAnimationShield = self:createAnim( ID, mmo.SFANIM_TYPE_SHIELD, self.mAnimationShield, mmo.PLAYER_SHIELD_TAG )
end

function gameActorPlayer:updateWings(ID)
    if ID == 9999 then
        ID = nil
    end
    self.mAnimationWings = self:createAnim( ID, mmo.SFANIM_TYPE_WINGS, self.mAnimationWings, mmo.PLAYER_WINGS_TAG )
end

function gameActorPlayer:updateHair(ID)
    if 0 == ID then
        ID = 9999
    end
    self.mAnimationHair = self:createAnim( ID, mmo.SFANIM_TYPE_HAIR, self.mAnimationHair, mmo.PLAYER_HAIR_TAG )
end

function gameActorPlayer:updateMonster(ID)
    local animType = self:GetValueByKey( mmo.BUFF_PLAYER_AVATAR_SEX ) and mmo.SFANIM_TYPE_PLAYER or mmo.SFANIM_TYPE_MONSTER
    self.mAnimationMonster = self:createAnim( ID, animType, self.mAnimationMonster, mmo.PLAYER_MONSTER_TAG )
end

function gameActorPlayer:updateWeaponEffect(ID)
    if ID == 9999 then
        ID = nil
    end
    self.mAnimationWeaponEff = self:createAnim( ID, mmo.SFANIM_TYPE_WEAPON, self.mAnimationWeaponEff, mmo.PLAYER_WEAPON_EFF_TAG )
end

function gameActorPlayer:updateLeftWeaponEffect(ID)
    if ID == 9999 then
        ID = nil
    end
    self.mAnimationLeftWeaponEff = self:createAnim( ID, mmo.SFANIM_TYPE_WEAPON, self.mAnimationLeftWeaponEff, mmo.PLAYER_LEFT_WEAPON_EFF_TAG )
end

function gameActorPlayer:updateMonsterEffect(ID)
    self.mAnimationMonsterEff = self:createAnim( ID, mmo.SFANIM_TYPE_MONSTER, self.mAnimationMonsterEff, mmo.PLAYER_MONSTER_EFF_TAG )
end

function gameActorPlayer:updateMonsterCloth(ID)
    self.mAnimationMonsterCloth = self:createAnim( ID, mmo.SFANIM_TYPE_PLAYER, self.mAnimationMonsterCloth, mmo.PLAYER_MONSTER_CLOTH_TAG )
end

function gameActorPlayer:updateShieldEffect(ID)
    if ID == 9999 then
        ID = nil
    end
    self.mAnimationShieldEffect = self:createAnim( ID, mmo.SFANIM_TYPE_SHIELD, self.mAnimationShieldEffect, mmo.PLAYER_SHIELD_TAG )
end

function gameActorPlayer:dirtyFeature()
    self.mFeatureDirty = true
end

function gameActorPlayer:checkFeature()
    self.mAnimationElapsed = self.mAnimation and self.mAnimation:GetElapsed() or nil
    local mFe = nil
    local needUpdate = false
    for i = 1, mmo.P_F_MAX do
        mFe = self.mFeature[i]
        if mFe:isDirty() then
            if i == mmo.P_F_CLOTH then
                self:updateCloth( mFe:getFeatureID() )
            elseif i == mmo.P_F_WEAPON then
                self:updateWeapon( mFe:getFeatureID() )
            elseif i == mmo.P_F_SHIELD then
                self:updateShield( mFe:getFeatureID() )
            elseif i == mmo.P_F_WINGS then
                self:updateWings( mFe:getFeatureID() )
            elseif i == mmo.P_F_HAIR then
                self:updateHair( mFe:getShowID() == 9999 and self.mHiarID or mFe:getFeatureID() )
            elseif i == mmo.P_F_MONSTER then
                self:updateMonster( mFe:getFeatureID() )
            elseif i == mmo.P_F_WEAPON_EFF then
                self:updateWeaponEffect( mFe:getFeatureID() )
            elseif i == mmo.P_F_MONSTER_EFF then
                self:updateMonsterEffect( mFe:getFeatureID() )
            elseif i == mmo.P_F_MONSTER_CLOTH then
                self:updateMonsterCloth( mFe:getFeatureID() )
            elseif i == mmo.P_F_SHIELD_EFF then
                self:updateShieldEffect( mFe:getFeatureID())
            elseif i == mmo.P_F_LEFT_WEAPON then
                self:updateLeftWeapon( mFe:getFeatureID() )
            elseif i == mmo.P_F_LEFT_WEAPON_EFF then
                self:updateLeftWeaponEffect( mFe:getFeatureID() )
            end
            mFe:setDirty( false )
            needUpdate = true
        end
    end

    self.mAnimationElapsed = needUpdate == true and self.mAnimationElapsed or nil
end

function gameActorPlayer:GetType()
    return mmo.ACTOR_PLAYER
end

function gameActorPlayer:GetAvatarNode()
    return self.mCurrPlayerAvatarNode
end

function gameActorPlayer:GetAnimationID()
    return self.mFeature[mmo.P_F_CLOTH]:getFeatureID()
end

function gameActorPlayer:GetAnimationWeapon()
    return self.mAnimationWeapon
end
function gameActorPlayer:GetAnimationWeaponID()
    return self.mFeature[mmo.P_F_WEAPON]:getFeatureID()
end

function gameActorPlayer:GetAnimationLeftWeapon()
    return self.mAnimationLeftWeapon
end
function gameActorPlayer:GetAnimationLeftWeaponID()
    return self.mFeature[mmo.P_F_LEFT_WEAPON]:getFeatureID()
end

function gameActorPlayer:GetAnimationShield()
    return self.mAnimationShield
end
function gameActorPlayer:GetAnimationShieldID()
    return self.mFeature[mmo.P_F_SHIELD]:getFeatureID()
end

function gameActorPlayer:GetAnimationWings()
    return self.mAnimationWings
end
function gameActorPlayer:GetAnimationWingsID()
    return self.mFeature[mmo.P_F_WINGS]:getFeatureID()
end

function gameActorPlayer:GetAnimationMonster()
    return self.mAnimationMonster
end

function gameActorPlayer:GetAnimationHair()
    return self.mAnimationHair
end
function gameActorPlayer:GetAnimationHairID()
    return self.mFeature[mmo.P_F_HAIR]:getFeatureID()
end

function gameActorPlayer:GetAnimationMount()
    return nil
end

function gameActorPlayer:GetAnimAct()
    return self.mAnimAct
end

-- 前摇，暂不影响任何动作(仅仅为了表现)
function gameActorPlayer:GetAnimPrepare()
    return self.mAnimPrepare
end

function gameActorPlayer:SetAnimPrepare(t)
    self.mAnimPrepare = t
end

function gameActorPlayer:GetDashWaiting()
    return self.mDashWaiting
end

function gameActorPlayer:SetDashWaiting(b)
    self.mDashWaiting = b
end

function gameActorPlayer:IsStallStatus()
    return self:GetSellStatus() == 1
end

function gameActorPlayer:SetSellStatus(status)
    self.mSellStatus = status
end

function gameActorPlayer:GetSellStatus()
    return self.mSellStatus
end

function gameActorPlayer:SetStallName(name)
    self.mStallName = name
end

function gameActorPlayer:GetStallName()
    return self.mStallName
end

function gameActorPlayer:SetIsOffLine(state)
    self.isOffLine = state
end

function gameActorPlayer:GetIsOffLine()
    return self.isOffLine == 1
end

function gameActorPlayer:SetGameActorActionHandler(handler)
    self.mActionHandler = handler
end

function gameActorPlayer:GetGameActorActionHandler()
    return self.mActionHandler
end

function gameActorPlayer:SetTeamState(state)
    self.mTeamState = state
end

function gameActorPlayer:GetTeamState()
    return self.mTeamState
end


function gameActorPlayer:SetClothID(id)
    return self.mFeature[mmo.P_F_CLOTH]:setID( id )
end
function gameActorPlayer:GetClothID()
    return self.mFeature[mmo.P_F_CLOTH]:getID()
end
function gameActorPlayer:SetShowClothID(id)
    return self.mFeature[mmo.P_F_CLOTH]:setShowID( id )
end
function gameActorPlayer:GetShowClothID()
    return self.mFeature[mmo.P_F_CLOTH]:getShowID()
end
function gameActorPlayer:dirtyCloth()
    self.mFeature[mmo.P_F_CLOTH]:setDirty(true)
end

function gameActorPlayer:SetWeaponID(id)
    return self.mFeature[mmo.P_F_WEAPON]:setID( id )
end
function gameActorPlayer:GetWeaponID()
    return self.mFeature[mmo.P_F_WEAPON]:getID()
end
function gameActorPlayer:SetShowWeaponID(id)
    return self.mFeature[mmo.P_F_WEAPON]:setShowID( id )
end
function gameActorPlayer:GetShowWeaponID()
    return self.mFeature[mmo.P_F_WEAPON]:getShowID()
end

function gameActorPlayer:SetLeftWeaponID(id)
    return self.mFeature[mmo.P_F_LEFT_WEAPON]:setID( id )
end
function gameActorPlayer:GetLeftWeaponID()
    return self.mFeature[mmo.P_F_LEFT_WEAPON]:getID()
end
function gameActorPlayer:SetShowLeftWeaponID(id)
    return self.mFeature[mmo.P_F_LEFT_WEAPON]:setShowID( id )
end
function gameActorPlayer:GetShowLeftWeaponID()
    return self.mFeature[mmo.P_F_LEFT_WEAPON]:getShowID()
end

function gameActorPlayer:SetShieldID(id)
    return self.mFeature[mmo.P_F_SHIELD]:setID( id )
end
function gameActorPlayer:GetShieldID()
    return self.mFeature[mmo.P_F_SHIELD]:getID()
end
function gameActorPlayer:SetShowShieldID(id)
    return self.mFeature[mmo.P_F_SHIELD]:setShowID(id)
end
function gameActorPlayer:GetShowShieldID()
    return self.mFeature[mmo.P_F_SHIELD]:getShowID()
end

function gameActorPlayer:SetWingsID(id)
    return self.mFeature[mmo.P_F_WINGS]:setID( id )
end
function gameActorPlayer:GetWingsID()
    return self.mFeature[mmo.P_F_WINGS]:getID()
end
function gameActorPlayer:SetShowWingsID(id)
    return self.mFeature[mmo.P_F_WINGS]:setShowID( id )
end
function gameActorPlayer:GetShowWingsID()
    return self.mFeature[mmo.P_F_WINGS]:getShowID()
end

function gameActorPlayer:SetRealHairID(id)
    self.mHiarID = id
end

function gameActorPlayer:SetHairID(id)
    return self.mFeature[mmo.P_F_HAIR]:setID( id )
end
function gameActorPlayer:GetHairID()
    return self.mFeature[mmo.P_F_HAIR]:getID()
end
function gameActorPlayer:SetShowHairID(id)
    return self.mFeature[mmo.P_F_HAIR]:setShowID( id )
end
function gameActorPlayer:GetShowHairID()
    return self.mFeature[mmo.P_F_HAIR]:getShowID()
end
function gameActorPlayer:dirtyHair()
    self.mFeature[mmo.P_F_HAIR]:setDirty(true)
end

function gameActorPlayer:SetMonsterFeatureID(id)
    return self.mFeature[mmo.P_F_MONSTER]:setID( id )
end
function gameActorPlayer:GetMonsterFeatureID()
    return self.mFeature[mmo.P_F_MONSTER]:getID()
end

function gameActorPlayer:SetWeaponEffectID(id)
    return self.mFeature[mmo.P_F_WEAPON_EFF]:setID( id )
end
function gameActorPlayer:GetWeaponEffectID()
    return self.mFeature[mmo.P_F_WEAPON_EFF]:getID()
end
function gameActorPlayer:SetShowWeaponEffectID(id)
    return self.mFeature[mmo.P_F_WEAPON_EFF]:setShowID( id )
end
function gameActorPlayer:GetShowWeaponEffectID()
    return self.mFeature[mmo.P_F_WEAPON_EFF]:getShowID()
end

function gameActorPlayer:SetLeftWeaponEffectID(id)
    return self.mFeature[mmo.P_F_LEFT_WEAPON_EFF]:setID( id )
end
function gameActorPlayer:GetLeftWeaponEffectID()
    return self.mFeature[mmo.P_F_LEFT_WEAPON_EFF]:getID()
end
function gameActorPlayer:SetShowLeftWeaponEffectID(id)
    return self.mFeature[mmo.P_F_LEFT_WEAPON_EFF]:setShowID( id )
end
function gameActorPlayer:GetShowLeftWeaponEffectID()
    return self.mFeature[mmo.P_F_LEFT_WEAPON_EFF]:getShowID()
end

function gameActorPlayer:SetShieldEffectID( id )
    return self.mFeature[mmo.P_F_SHIELD_EFF]:setID( id )
end
function gameActorPlayer:GetShieldEffectID()
    return self.mFeature[mmo.P_F_SHIELD_EFF]:getID()
end
function gameActorPlayer:SetShowShieldEffectID( id )
    return self.mFeature[mmo.P_F_SHIELD_EFF]:setShowID( id )
end
function gameActorPlayer:GetShowShieldEffectID()
    return self.mFeature[mmo.P_F_SHIELD_EFF]:getShowID()
end

function gameActorPlayer:SetMonsterEffectID(id)
    return self.mFeature[mmo.P_F_MONSTER_EFF]:setID( id )
end
function gameActorPlayer:GetMonsterEffectID()
    return self.mFeature[mmo.P_F_MONSTER_EFF]:getID()
end

function gameActorPlayer:SetMonsterClothID(id)
    return self.mFeature[mmo.P_F_MONSTER_CLOTH]:setID( id )
end
function gameActorPlayer:GetMonsterClothID()
    return self.mFeature[mmo.P_F_MONSTER_CLOTH]:getID()
end

function gameActorPlayer:SetSexID( sex )
    self.mSex = sex
end
function gameActorPlayer:GetSexID()
    return self.mSex
end

function gameActorPlayer:GetJobID()
    return self.mJobID
end
function gameActorPlayer:SetJobID(job)
    self.mJobID = job
end

function gameActorPlayer:GetLevel()
    return self.mLevel
end

function gameActorPlayer:GetMasterID()
    return self.mMasterID
end
function gameActorPlayer:SetMasterID(id)
    self.mMasterID = id
end

function gameActorPlayer:GetCurrActTime()
    return self.mCurrentActT
end
function gameActorPlayer:SetCurrActTime(t)
    self.mCurrentActT = t
end

function gameActorPlayer:dirtyAnimFlag()
    if self.mStopAnimFrameIndex then
        return
    end
    self.mIsAnimNeedToUpdate = true
end

function gameActorPlayer:Bright()
    if not self.mIsBright then
        self.mIsBright = true

        local isInCover = false
        for k, v in pairs(self.mCover) do
            if v then
                isInCover = true
                break
            end
        end
        local actorAnim = self:GetAnimation()
        if isInCover then
            global.Facade:sendNotification(global.NoticeTable.HighLightNodeShader, actorAnim, mmo.SHADER_TYPE_HIGHTLIGHT_COVER)
        else
            global.Facade:sendNotification(global.NoticeTable.HighLightNodeShader, actorAnim, mmo.SHADER_TYPE_HIGHTLIGHT)
        end
    end
end

function gameActorPlayer:SetNearShow(state)
    self.mNearShow = state
end

function gameActorPlayer:IsNearShow()
    return self.mNearShow == 1
end

--神秘人状态(戴斗笠) 1是神秘人状态
function gameActorPlayer:SetShenMiRen(value)
    -- body
    self.mShenMiRen = value
end

function gameActorPlayer:IsShenMiRen()
    -- body
    return self.mShenMiRen == 1
end

--护身
function gameActorPlayer:SetHuShen(value)
    -- body
    self.mHuShen = value
end
function gameActorPlayer:IsHuShen()
    -- body
    return self.mHuShen == 1
end

function gameActorPlayer:SetCampValue(key, value)
    if self.mCamps[key] == value then
        return false
    end
    self.mCamps[key] = value
end

-- 是否己方成员
function gameActorPlayer:IsSameCamp()
    local isCamp = self.mCamps.InTeam or self.mCamps.InGuild or self.mCamps.InCamp
    return isCamp
end

--受到攻击
function gameActorPlayer:SetDamage(value)
    -- body
    self.mDamage = value
end

function gameActorPlayer:IsDamage()
    -- body
    return self.mDamage
end

-- 是否是主玩家
function gameActorPlayer:SetIsMainPlayer(value)
    self.mIsMainPlayer = value
end

function gameActorPlayer:IsMainPlayer()
    return self.mIsMainPlayer
end

-- 设置国家id
function gameActorPlayer:SetNationID( id )
    self._nationid = id
end

function gameActorPlayer:GetNationID()
    return self._nationid
end

function gameActorPlayer:GetHUDTop()
    if not self.mAnimation then
        return 20
    end
    return self.mAnimation:GetHUDTop() or 20
end

-- 获取主驾id
function gameActorPlayer:GetHorseMasterID()
    return self:GetValueByKey(global.MMO.HORSE_MAIN)
end

-- 获取副驾id
function gameActorPlayer:GetHorseCopilotID()
    return self:GetValueByKey(global.MMO.HORSE_COPILOT)
end

-- 是否是副驾
function gameActorPlayer:IsHoreseCopilot()
    return self:GetValueByKey(global.MMO.HORSE_COPILOT) == self:GetID()
end

-- 双人坐骑
function gameActorPlayer:SetDoubleHorse( value )
    self.mMouleHorse = value
end

-- 是否是双人坐骑
function gameActorPlayer:IsDoubleHorse()
    return self.mMouleHorse == 1
end

-- 是否是连体坐骑
function gameActorPlayer:IsBodyHorse()
    return self.mMouleHorse == 2
end

function gameActorPlayer:SetMoveEff( value )
    self.mMoveEff = value
end

function gameActorPlayer:GetMoveEff()
    return self.mMoveEff
end

function gameActorPlayer:IsMoveEff()
    return self.mMoveEff ~= nil
end

function gameActorPlayer:SetMoveEffSkipWalk( value )
    self.mMoveEffSkip = value
end

function gameActorPlayer:GetMoveEffSkipWalk()
    return self.mMoveEffSkip
end

function gameActorPlayer:SetEffSkipWalkSwitch( value )
    self.mIsSkip = value
end

function gameActorPlayer:GetEffSkipWalkSwitch()
    return self.mIsSkip
end

function gameActorPlayer:SetDearID( value )
    self.mDearID = value
end

function gameActorPlayer:GetDearID()
    return self.mDearID
end

function gameActorPlayer:SetSiTuID( value )
    self.mSiTuID = value
end

function gameActorPlayer:GetSiTuID()
    return self.mSiTuID
end

function gameActorPlayer:GetHateID()
    return self.mHateID
end

function gameActorPlayer:SetHateID(id)
    self.mHateID = id
end

function gameActorPlayer:GetReLevel()
    return self.mReLevel
end

function gameActorPlayer:SetReLevel( value )
    self.mReLevel = value
end

return gameActorPlayer
