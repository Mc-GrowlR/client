
local actorUtils = {
    mReLvColor      = nil,              -- 转身变色颜色
    mReLvChange     = nil,              -- 转身变色颜色时间间隔
    mReLvColorCount = 0,                -- 转身变色颜色的颜色数量
}

function SetActorProperty(actor, jsonData)
    -- jsonData.UserID

    if jsonData.race and actor.SetRace then
        actor:SetRace(jsonData.race)
    end

    if jsonData.RaceServer and actor.SetRaceServer then
        actor:SetRaceServer(jsonData.RaceServer)
    end

    if jsonData.raceImg and actor.SetRaceImg then
        actor:SetRaceImg(jsonData.raceImg)
    end

    if jsonData.sex and actor.SetSexID then
        actor:SetSexID(jsonData.sex)
    end

    if jsonData.Job and actor.SetJobID then
        actor:SetJobID(jsonData.Job)
    end

    if jsonData.type and actor.SetSubType then
        actor:SetSubType(jsonData.type)
    end

    if jsonData.nActorId and actor.SetTypeIndex then
        actor:SetTypeIndex(jsonData.nActorId)
    end

    if jsonData.WalkBaseSpeed and actor.SetWalkStepTime then
        -- max network delay.for smooth walk
        actor:SetWalkStepTime(jsonData.WalkBaseSpeed * 0.001)
    end

    if jsonData.WalkCurrSpeed and jsonData.WalkCurrSpeed > 0 and actor.SetWalkSpeed then
        if actor:IsPlayer() and actor:IsMainPlayer() then
            actor:SetWalkSpeed(actor:GetWalkStepTime() / (jsonData.WalkCurrSpeed * 0.001 + global.MMO.NETWORK_DELAY))
        else
            actor:SetWalkSpeed(actor:GetWalkStepTime() / (jsonData.WalkCurrSpeed * 0.001))
        end
    end
    
    if jsonData.RunBaseSpeed and actor.SetRunStepTime then
        -- max network delay.for smooth walk
        actor:SetRunStepTime(jsonData.RunBaseSpeed * 0.001)
    end

    if jsonData.RunCurrSpeed and jsonData.RunCurrSpeed > 0 and actor.SetRunSpeed then
        if actor:IsPlayer() and actor:IsMainPlayer() then
            actor:SetRunSpeed(actor:GetRunStepTime() / (jsonData.RunCurrSpeed * 0.001 + global.MMO.NETWORK_DELAY))
        else
            actor:SetRunSpeed(actor:GetRunStepTime() / (jsonData.RunCurrSpeed * 0.001))
        end
    end

    if jsonData.AttackBaseSpeed and actor.SetAttackStepTime then
        -- actor:SetAttackStepTime(jsonData.AttackBaseSpeed * 0.001)
    end

    if jsonData.AttackCurrSpeed and jsonData.AttackCurrSpeed > 0 and actor.SetAttackSpeed then
        actor:SetAttackSpeed(actor:GetAttackStepTime() / (jsonData.AttackCurrSpeed * 0.001))
    end

    if jsonData.MagicBaseSpeed and actor.SetMagicStepTime then
        -- actor:SetMagicStepTime(jsonData.MagicBaseSpeed * 0.001)
    end

    if jsonData.MagicCurrSpeed and jsonData.MagicCurrSpeed > 0 and actor.SetMagicSpeed then
        actor:SetMagicSpeed(actor:GetMagicStepTime() / (jsonData.MagicCurrSpeed * 0.001))
    end

    if jsonData.MasterId and actor.SetMasterID then
        actor:SetMasterID(jsonData.MasterId)
    end

    if jsonData.nLevel and actor.SetLevel then
        actor:SetLevel(jsonData.nLevel)
    end
    
    if jsonData.Hp and jsonData.MaxHp and actor.SetHPHUD then
        actor:SetHPHUD(jsonData.Hp, jsonData.MaxHp)
    end

    if jsonData.dun and jsonData.maxdun and actor.SetShieldHUD then
        actor:SetShieldHUD(jsonData.dun, jsonData.maxdun)
    end

    -- 内功
    if jsonData.InternalForce and jsonData.MaxInternalForce and actor.SetNGHUD then
        actor:SetNGHUD(jsonData.InternalForce, jsonData.MaxInternalForce)
    end

    if jsonData.Group and actor.SetTeamState then
        actor:SetTeamState(jsonData.Group)
    end

    if actor.SetStoneMode and jsonData.StoneMode then
        actor:SetStoneMode(jsonData.StoneMode == 1)
    end

    if actor.SetOwnerID and jsonData.OwnerID then
        actor:SetOwnerID(jsonData.OwnerID)
    end

    if actor.SetOwnerName and jsonData.OwnerName then
        actor:SetOwnerName(jsonData.OwnerName)
    end

    if actor.SetPKLv and jsonData.pklv then
        actor:SetPKLv(jsonData.pklv)
    end

    if actor.SetNearShow and jsonData.RangeCanFindMe then
        actor:SetNearShow(jsonData.RangeCanFindMe)
    end

    local mapX, mapY = jsonData.X, jsonData.Y
    if mapX and mapY and actor.SetInSafeZone then
        local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )
        actor:SetInSafeZone( MapProxy:GetInSafeArea(mapX, mapY) )
    end

    if actor.SetIsOffLine and jsonData.OffLine ~= nil then
        actor:SetIsOffLine(jsonData.OffLine)
    end

    if actor.SetIsThrough and jsonData.Through ~= nil then
        actor:SetIsThrough(jsonData.Through)
    end

    if actor.SetActionType and jsonData.ActionType then
        actor:SetActionType(jsonData.ActionType)
    end

    if actor.SetHuShen and jsonData.MagicShield then
        --设置护身状态
        actor:SetHuShen(jsonData.MagicShield)
    end

    if actor.SetShenMiRen and jsonData.ShenMiRen then
        -- 神秘人
        actor:SetShenMiRen(jsonData.ShenMiRen)
    end

    if actor.SetFaction then
        local Is = false
        local faction = jsonData.nCamp or jsonData.campid
        actor:SetFaction(faction)

        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        if mainPlayer and mainPlayer:GetID() ~= actor:GetID() then
            if faction and faction > 0 and faction == mainPlayer:GetFaction() then
                actor:SetCampValue("InCamp", true)
                requireProxy("optionsUtils"):InitHUDVisibleValue(actor, global.MMO.PLAYER_B_VISIBLE)
                Is = true
            end
        end
        if not Is and actor.SetCampValue then
            actor:SetCampValue("InCamp", false)
            actor:SetKeyValue(global.MMO.PLAYER_B_VISIBLE, false)
        end
    end

    if jsonData.nServerId and actor.SetServerID then -- 区服id
        actor:SetServerID(jsonData.nServerId)
    end

    if actor.SetNationID then --国家id
        actor:SetNationID( jsonData.nationid )
    end

    if actor.SetNationEnemyPK then --国家模式是否可被攻击
        actor:SetNationEnemyPK( jsonData.nPlayerPk )
    end

    if jsonData.bigtip and jsonData.bigtip > 0 and actor.SetBigTipIcon then -- 怪物大血条头像id
        actor:SetBigTipIcon( jsonData.bigtip )
    end

    if jsonData.me and actor.SetMoveEff then
        actor:SetMoveEff( jsonData.me )
    end

    if jsonData.noShowName and actor.SetNoShowName then
        actor:SetNoShowName(jsonData.noShowName)
    end

    if jsonData.noShowHPBar and actor.SetNoShowHPBar then
        actor:SetNoShowHPBar(jsonData.noShowHPBar)
    end

    if jsonData.Color and actor.SetNameColor then
        actor:SetNameColor( jsonData.Color )
    end
    
    if jsonData.WarZone and actor.SetWarZone then
        actor:SetWarZone( jsonData.WarZone )
    end

    if jsonData.STID and actor.SetSiTuID then
        actor:SetSiTuID( jsonData.STID )
    end

    if jsonData.DearID and actor.SetDearID then
        actor:SetDearID( jsonData.DearID )
    end

    if jsonData.caved ~= nil and actor.SetSleepInCave then
        local hide = jsonData.caved == true
        actor:SetSleepInCave( hide )
        actor:SetKeyValue(global.MMO.Is_Cave, hide)
    end

    if jsonData.IsBoss then
        actor:SetSubType(global.MMO.ACTOR_SUBTYPE_BOSS)
    end

    if jsonData.gmData and actor.SetGMData then
        actor:SetGMData(jsonData.gmData)
    end

    if jsonData.ReLv and actor.SetReLevel then
        actor:SetReLevel(jsonData.ReLv)
    end
end

if not global.ActorAttr then
    global.ActorAttr = {}
end


function SetActorAttrByID( actorID, key, value )
    if not actorID or not key then
        return nil
    end

    if not global.ActorAttr[actorID] then
        global.ActorAttr[actorID] = {}
    end

    global.ActorAttr[actorID][key] = value
end


function GetActorAttrByID( actorID, key )
    if not actorID or not key then
        return nil
    end
    
    if not global.ActorAttr[actorID] then
        return nil
    end
    
    return global.ActorAttr[actorID][key]
end


function SetActorAttr( actor, key, value )
    if not actor or not key then
        return nil
    end

    local actorID = actor:GetID()
    SetActorAttrByID( actorID, key, value )
end


function GetActorAttr( actor, key )
    if not actor or not key then
        return nil
    end

    local actorID = actor:GetID()
    return GetActorAttrByID( actorID, key )
end


function ClenupActorAttrByID( actorID )
    if not actorID then
        return nil
    end

    if global.ActorAttr[actorID] then
        global.ActorAttr[actorID] = nil
    end
end

function ClenupActorAttr( actor )
    if not actor then
        return nil
    end

    local actorID = actor:GetID()
    ClenupActorAttrByID( actorID )
end

function CalcActorDirByPos( currPos, destPos, defaultDir )
    local dx = destPos.x - currPos.x
    local dy = destPos.y - currPos.y
    local ret = defaultDir

    if dx == 0 and dy < 0 then        -- top
        ret = 0 
    elseif dx > 0  and dy < 0  then -- right top
        ret = 1
    elseif dx > 0  and dy == 0 then  -- right
        ret = 2
    elseif dx > 0  and dy > 0  then -- right bottom
        ret = 3
    elseif dx == 0 and  dy > 0 then  -- bottom
        ret = 4
    elseif dx < 0  and dy > 0  then -- left bottom
        ret = 5
    elseif dx < 0  and dy == 0 then  -- left
        ret = 6
    elseif dx < 0  and dy < 0  then -- left top
        ret = 7
    end

    return ret
end

function SetActorName(actor, hudParam)
    if not actor or not hudParam then
        return nil
    end

    if actor:IsPlayer() then
        local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )
        local isUnitveName = true
        local MasterID = actor:GetMasterID() or ""
        if actor:IsHumanoid() and MasterID == "" then
            isUnitveName = false
        end
        if isUnitveName and MapProxy:IsUnitiveName() then
            hudParam.Name = MapProxy:GetUnitiveName( true )
        end
        if isUnitveName and actor:IsShenMiRen() then
            hudParam.Name = GET_STRING(800720)
        end
        
    elseif actor:IsMonster() then
        if hudParam.Master then
            hudParam.Name = hudParam.Name .. " (" .. hudParam.Master .. ")"
        end
    end

    actor:SetONameStr(hudParam.Name)

    -- 拆分
    local spName = hudParam.Name or ""
    local nameStr = string.split(spName, "\\")
    local showName = nameStr[1]

    if actor:IsNPC() then
       local bubbleName = string.match(showName or "", "^$(.+)$$")
       if bubbleName then
            showName = ""
            actor:SetBubbleName(bubbleName)
       end
    end

    actor:SetName( showName or "" )

    -- set actor guild name
    local GuildID   = hudParam.GuildID
    if hudParam.GuildName then
        local GuildName = hudParam.GuildName
        if GuildID and string.len(GuildID) > 0 then
        else
            GuildID = hudParam.guildid or ""
        end
        if GuildName and string.len( GuildName ) > 0 then
            actor:SetGuildName( GuildName )
            local mainPlayer = global.gamePlayerController:GetMainPlayer()
            if mainPlayer and mainPlayer:GetGuildName() == GuildName then
                actor:SetCampValue("InGuild", true)
            end
        else
            actor:SetGuildName( "" )
            actor:SetCampValue("InGuild", false)
        end
    elseif actor:IsPlayer() then
        actor:SetGuildName("")
        actor:SetCampValue("InGuild", false)
    end

    if actor:IsPlayer() then
        actor:SetGuildID(GuildID)
    end

    -- record main player name/guild
    local actorID = actor:GetID()
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if (mainPlayerID == actorID ) then
        local PlayerProperty = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
        PlayerProperty:SetName( actor:GetName() )
        PlayerProperty:SetGuildName( actor:GetGuildName() )
        PlayerProperty:SetMainPlayerNameColor(hudParam.Color or global.MMO.HUD_COLOR_DEFAULT)
        ssr.ssrBridge:OnPlayerNameInited(actor:GetName())
    end
end

------------------------------------- player render order -------------------------------
local renderOrderIdle = 
{
    { 2, 3, 5, 0, 4, 1 },      -- weapon, cloth, wings, shield, hair, left-weapon
    { 4, 2, 5, 0, 3, 1 },
    { 5, 3, 2, 0, 4, 1 },
    { 5, 3, 2, 0, 4, 1 },
    { 2, 3, 0, 4, 5, 1 },
    { 1, 2, 0, 5, 3, 4 },
    { 0, 1, 3, 5, 2, 4 },
    { 0, 1, 3, 5, 2, 4 },
}

local renderOrderRun = 
{
    { 2, 3, 5, 0, 4, 1 },      -- weapon, cloth, wings, shield, hair
    { 4, 2, 5, 0, 3, 1 },
    { 4, 2, 5, 0, 3, 1 },
    { 5, 3, 2, 0, 4, 1 },
    { 5, 1, 0, 4, 2, 3 },
    { 1, 2, 0, 5, 3, 4 },
    { 0, 1, 3, 5, 2, 4 },
    { 0, 1, 3, 5, 2, 4 },
}
local renderOrderAttack = 
{
    { 2, 3, 5, 0, 4, 1 },      -- weapon, cloth, wings, shield, hair
    { 4, 2, 5, 0, 3, 1 },
    { 4, 2, 5, 0, 3, 1 },
    { 5, 3, 2, 0, 4, 1 },
    { 5, 1, 0, 4, 2, 3 },
    { 1, 2, 0, 5, 3, 4 },
    { 0, 1, 3, 5, 2, 4 },
    { 0, 1, 3, 5, 2, 4 },
}

local renderOrderDie = 
{
    { 3, 1, 0, 4, 2, 5 },      -- weapon, cloth, wings, shield, hair
    { 5, 3, 2, 0, 4, 1 },
    { 5, 3, 2, 0, 4, 1 },
    { 5, 3, 2, 0, 4, 1 },
    { 5, 1, 0, 3, 2, 4 },
    { 1, 2, 0, 4, 3, 5 },
    { 0, 1, 3, 4, 2, 5 },
    { 0, 1, 3, 4, 2, 5 },
}

local renderOrderStuck = 
{
    { 2, 0, 3, 4, 1, 5 },      -- weapon, cloth, wings, shield, hair, left-weapon
    { 4, 2, 5, 0, 3, 1 },
    { 2, 3, 5, 0, 4, 1 },
    { 2, 3, 5, 0, 4, 1 },
    { 5, 1, 0, 4, 2, 3 },
    { 1, 2, 0, 5, 3, 4 },
    { 0, 1, 3, 5, 2, 4 },
    { 0, 1, 3, 5, 2, 4 },
}


local PlayerRenderOrder = {
    [global.MMO.ANIM_IDLE]      = renderOrderIdle,
    [global.MMO.ANIM_WALK]      = renderOrderIdle,
    [global.MMO.ANIM_ATTACK]    = renderOrderAttack,
    [global.MMO.ANIM_SKILL]     = renderOrderAttack,
    [global.MMO.ANIM_DIE]       = renderOrderDie,
    [global.MMO.ANIM_RUN]       = renderOrderRun,
    [global.MMO.ANIM_STUCK]     = renderOrderStuck,
    [global.MMO.ANIM_SITDOWN]   = renderOrderAttack,
    [global.MMO.ANIM_BORN]      = renderOrderIdle,
    [global.MMO.ANIM_MINING]    = renderOrderAttack,
}
actorUtils.PlayerRenderOrder = PlayerRenderOrder

if SL:GetMetaValue("GAME_DATA", "WeaponLooksOrderUp") and next(SL:GetMetaValue("GAME_DATA", "WeaponLooksOrderUp")) then
    local PlayerRenderOrder = actorUtils.PlayerRenderOrder
    for _, param in ipairs(SL:GetMetaValue("GAME_DATA", "WeaponLooksOrderUp")) do
        if PlayerRenderOrder[param.act] and PlayerRenderOrder[param.act][param.dir + 1] then
            PlayerRenderOrder[param.act][param.dir + 1] = ReOrderPlayerRender(PlayerRenderOrder[param.act][param.dir + 1])
        end
    end
end

local renderWeaponOrder=
{
    [32*100+global.MMO.ANIM_IDLE] = {              -- 武器动画id*100 + 状态
        [5] = { 1, 2, 0, 5, 4, 3 }, -- weapon, cloth, wings, shield, hair
    },
    [32*100+global.MMO.ANIM_WALK] = {
        [5] = { 1, 2, 0, 5, 4, 3 }, -- weapon, cloth, wings, shield, hair
    },
    [32*100+global.MMO.ANIM_RUN] = {
        [5] = { 1, 2, 0, 5, 4, 3 }, -- weapon, cloth, wings, shield, hair
    },
    [32*100+global.MMO.ANIM_DIE] = {
        [5] = { 1, 2, 0, 5, 4, 3 }, -- weapon, cloth, wings, shield, hair
    }
}

actorUtils.PlayerWeaponRenderOrder = renderWeaponOrder
------------------------------------- player render order -------------------------------

function IsSmoothMove(actor)
    return not global.isWinPlayMode or 1 == CHECK_SETTING(global.MMO.SETTING_IDX_WINDOW_SMOOTH_VIEW)
end

function CheckRunStep()
    local PlayerProperty = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    local isRide = PlayerProperty:CheckIsRide()
    if not isRide and CHECK_SERVER_OPTION(global.MMO.SERVER_RUN_ONE) then
        return 1
    end
    return isRide and 3 or 2
end

function CheckRunAble()
    if global.ConstantConfig.gameOption_WalkOnly == 1 then
        return false
    end

    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)

    -- 721号消息禁跑/只能走
    if PlayerProperty:IsNotRun() then
        return false
    end

    -- 血量低于10不可以跑
    if PlayerProperty:GetRoleCurrHP() < 10 then
        return false
    end
    
    local buffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    return buffProxy:CheckRunEnable() == true
end

local moveActions = {
    [global.MMO.ACTION_WALK]                = true, -- 走
    [global.MMO.ACTION_RUN]                 = true, -- 跑
    [global.MMO.ACTION_RIDE_RUN]            = true, -- 坐骑跑
    [global.MMO.ACTION_DASH]                = true, -- 野蛮
    [global.MMO.ACTION_ZXC]                 = true, -- 追心刺
    [global.MMO.ACTION_ONPUSH]              = true, -- 被野蛮/被推开
    [global.MMO.ACTION_TELEPORT]            = true, -- 瞬移
    [global.MMO.ACTION_SBYS]                = true, -- 十步一杀
    [global.MMO.ACTION_ASSASSIN_SNEAK]      = true, -- 潜行
}
function IsMoveAction(act)
    if not act then
        return false
    end
   
    return moveActions[act] == true
end

local skillActions = {
    [global.MMO.ACTION_YTPD]                = true, -- 倚天辟地
    [global.MMO.ACTION_ZXC]                 = true, -- 追心刺
    [global.MMO.ACTION_SJS]                 = true, -- 三绝杀
    [global.MMO.ACTION_DYZ]                 = true, -- 断岳斩
    [global.MMO.ACTION_HSQJ]                = true, -- 横扫千军
    [global.MMO.ACTION_FWJ]                 = true, -- 凤舞祭
    [global.MMO.ACTION_JLB]                 = true, -- 惊雷爆
    [global.MMO.ACTION_BTXD]                = true, -- 冰天雪地
    [global.MMO.ACTION_SLP]                 = true, -- 双龙破
    [global.MMO.ACTION_HXJ]                 = true, -- 虎啸诀
    [global.MMO.ACTION_BGZ]                 = true, -- 八卦掌
    [global.MMO.ACTION_SYZ]                 = true, -- 三焰咒
    [global.MMO.ACTION_WJGZ]                = true, -- 万剑归宗

    [global.MMO.ACTION_ASSASSIN_RUN]        = true, -- 刺客跑步
    [global.MMO.ACTION_ASSASSIN_SNEAK]      = true, -- 刺客潜行
    [global.MMO.ACTION_ASSASSIN_SMITE]      = true, -- 刺客重击
    [global.MMO.ACTION_ASSASSIN_SKILL]      = true, -- 刺客施法
    [global.MMO.ACTION_ASSASSIN_SY]         = true, -- 刺客霜月
    [global.MMO.ACTION_ASSASSIN_UNKNOWN]    = true, -- 刺客未知动作 
    [global.MMO.ACTION_ASSASSIN_XFT]        = true, -- 旋风腿
    [global.MMO.ACTION_JY]                  = true, -- 箭雨1
    [global.MMO.ACTION_JY2]                 = true, -- 箭雨2
    [global.MMO.ACTION_TSZ]                 = true, -- 推山掌
    [global.MMO.ACTION_XLFH]                = true, -- 降龙伏虎
}
function CheckInSkillAction(action)
    if not action then
        return false
    end

    return skillActions[action] == true
end

local dashActions = {
    [global.MMO.ACTION_DASH]                = true, -- 野蛮
    [global.MMO.ACTION_ONPUSH]              = true, -- 被野蛮
    [global.MMO.ACTION_TELEPORT]            = true, -- 瞬移
    [global.MMO.ACTION_SBYS]                = true, -- 十步一杀
    [global.MMO.ACTION_DASH_FAIL]           = true, -- 野蛮失败
    [global.MMO.ACTION_DASH_WAITING]        = true, -- 追心刺
}
function actorUtils.CheckActionDashAble(act)
    if not act then
        return false
    end
    return dashActions[act] == nil
end

function actorUtils.actorZhuiXinCi(actor, mapX, mapY, dir, zxcTime)
    actor:SetAction(global.MMO.ACTION_IDLE, true)

    -- 加速中
    if actor:GetIsFullSpeedup() then
        zxcTime = zxcTime / global.MMO.DEFAULT_MUCH_FAST_TIME
    elseif actor:GetIsSpeedup() then
        zxcTime = zxcTime / global.MMO.DEFAULT_FAST_TIME_RATE
    end
    
    -- pos & dir
    local lastPos = actor:getPosition()
    actor:SetDirection(dir)
    actor:setPosition(lastPos.x, lastPos.y)
    global.actorManager:SetActorMapXY( actor, mapX, mapY )
    
    -- action & anim
    actor:SetCurrActTime(zxcTime)
    actor:SetAction(global.MMO.ACTION_ZXC, true)
end

function actorUtils.actorDash(actor, mapX, mapY, dir, dashTime)
    -- for move interrupt， force position
    actor:SetAction(global.MMO.ACTION_IDLE, true)

    -- 加速中
    if actor:GetIsFullSpeedup() then
        dashTime = dashTime / global.MMO.DEFAULT_MUCH_FAST_TIME
    elseif actor:GetIsSpeedup() then
        dashTime = dashTime / global.MMO.DEFAULT_FAST_TIME_RATE
    end
    
    -- pos & dir
    local lastPos = actor:getPosition()
    actor:SetDirection(dir)
    actor:setPosition(lastPos.x, lastPos.y)
    global.actorManager:SetActorMapXY( actor, mapX, mapY )
    
    -- action & anim
    actor:SetCurrActTime(dashTime)
    actor:SetDashWaiting(false)
    actor:SetAction(global.MMO.ACTION_DASH, true)
end

function actorUtils.actorOnDash(actor, mapX, mapY, dir, dashTime, idleTime)
    -- for move interrupt， force position
    actor:SetAction(global.MMO.ACTION_IDLE, true)

    -- 加速中
    if actor:GetIsFullSpeedup() then
        dashTime = dashTime / global.MMO.DEFAULT_MUCH_FAST_TIME
    elseif actor:GetIsSpeedup() then
        dashTime = dashTime / global.MMO.DEFAULT_FAST_TIME_RATE
    end
    if actor:GetIsFullSpeedup() then
        idleTime = idleTime / global.MMO.DEFAULT_MUCH_FAST_TIME
    elseif actor:GetIsSpeedup() then
        idleTime = idleTime / global.MMO.DEFAULT_FAST_TIME_RATE
    end

    -- pos & dir
    local lastPos = actor:getPosition()
    actor:SetDirection(dir)
    actor:setPosition(lastPos.x, lastPos.y, lastPos.z)
    global.actorManager:SetActorMapXY( actor, mapX, mapY )

    -- action & anim
    actor:SetCurrActTime(dashTime)
    actor:SetAction(global.MMO.ACTION_ONPUSH, true)

    -- 
    local buffData = 
    {
        actorID = actor:GetID(),
        buffID = global.MMO.BUFF_ID_ONDASH_IDLE,
        param = dashTime + idleTime,
        autoRemove = true,
    }
    global.Facade:sendNotification(global.NoticeTable.AddBuffEntity, buffData)
end

function actorUtils.actorSBYS(actor, mapX, mapY, dir)
    global.actorManager:SetActorMapXY( actor, mapX, mapY )
    
    actor:SetDirection(dir)
    actor:SetDashWaiting(false)
    actor:SetAction(global.MMO.ACTION_SBYS, true)
end

function actorUtils.actorQLS(actor, mapX, mapY, dir)
    global.actorManager:SetActorMapXY( actor, mapX, mapY )
    
    local worldPos = global.sceneManager:MapPos2WorldPos( mapX, mapY, true )
    actor:setPosition( worldPos.x, worldPos.y ) 
    actor:SetDirection(dir)
    actor:SetAction(global.MMO.ACTION_TELEPORT, true)
    actor:SetCurrActTime(0.01)
end

function actorUtils.calcMapDistance(sX, sY, dX, dY)
    return math.max(math.abs(sX - dX), math.abs(sY - dY))
end

function actorUtils.actorReLvData( data )
    data = data or {}
    actorUtils.mReLvColor   = data.RelvColor
    actorUtils.mReLvChange  = data.RelvChange / 1000

    if actorUtils.mReLvColor then
        actorUtils.mReLvColorCount = #actorUtils.mReLvColor
        actorUtils.mReLvColor[0] = actorUtils.mReLvColor[actorUtils.mReLvColorCount]
        actorUtils.mReLvColor[actorUtils.mReLvColorCount] = nil
    end
end

function actorUtils.actorIsReLvChange()
    return actorUtils.mReLvColor and actorUtils.mReLvChange
end

function actorUtils.actorReLvChange(actor, randomNum, timeCount)
    if timeCount >= 0 and timeCount < actorUtils.mReLvChange then
        return false
    end

    if not randomNum then
        return true
    end

    local hudParam = GetActorAttr( actor, global.MMO.ACTOR_ATTR_HUDPARAM )
    if hudParam and next(hudParam) then
        local index = (GetServerTime() + randomNum) % actorUtils.mReLvColorCount
        hudParam.Color         = actorUtils.mReLvColor[ index ] or actor:GetNameColor()
        global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actor:GetID(), hudParam = hudParam } )
    end
    return timeCount >= 0      -- <0时，hudParam可能还没值
end

return actorUtils


