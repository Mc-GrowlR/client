local utils = {}

local ProxyTable    = global.ProxyTable
local Facade        = global.Facade
local MMO           = global.MMO

-- GAME_DATA
local MonsterPaperback = global.ConstantConfig.MonsterPaperback

-- 称号
local hudTitleSpriteID = {
    [0] = MMO.HUD_SPRITE_TITLE_1,
    [1] = MMO.HUD_SPRITE_TITLE_2,
    [2] = MMO.HUD_SPRITE_TITLE_3
}

local hudTitleLableID  = {
    [0] = MMO.HUD_LABEL_TITLE_1,
    [1] = MMO.HUD_LABEL_TITLE_2,
    [2] = MMO.HUD_LABEL_TITLE_3
}

-- 顶戴
local hudTipsID         = {
    [0]  = MMO.HUD_SPRITE_ICON_1,
    [1]  = MMO.HUD_SPRITE_ICON_2,
    [2]  = MMO.HUD_SPRITE_ICON_3,
    [3]  = MMO.HUD_SPRITE_ICON_4,
    [4]  = MMO.HUD_SPRITE_ICON_5,
    [5]  = MMO.HUD_SPRITE_ICON_6,
    [6]  = MMO.HUD_SPRITE_ICON_7,
    [7]  = MMO.HUD_SPRITE_ICON_8,
    [8]  = MMO.HUD_SPRITE_ICON_9,
    [9]  = MMO.HUD_SPRITE_ICON_10,
    [10] = MMO.HUD_SPRITE_ICON_11
}

local animHudID         = {
    [0]  = MMO.HUD_NODE_TITLE_1,
    [1]  = MMO.HUD_NODE_TITLE_2,
    [2]  = MMO.HUD_NODE_TITLE_3,
    [3]  = MMO.HUD_NODE_TITLE_4,
    [4]  = MMO.HUD_NODE_TITLE_5,
    [5]  = MMO.HUD_NODE_TITLE_6,
    [6]  = MMO.HUD_NODE_TITLE_7,
    [7]  = MMO.HUD_NODE_TITLE_8,
    [8]  = MMO.HUD_NODE_TITLE_9,
    [9]  = MMO.HUD_NODE_TITLE_10,
    [10] = MMO.HUD_NODE_TITLE_11
}

-- 不显示的类型
local NoShowHpType      = {
    [MMO.ACTOR_NPC]         = 1,
    [MMO.ACTOR_SEFFECT]     = 1,
    [MMO.ACTOR_DROPITEM]    = 1,
    [MMO.ACTOR_COLLECTION]  = 1
}

------------------------------------------------------------------------------------------
function utils:CheckSet_Npc_name()
    return CHECK_SERVER_OPTION(MMO.SERVER_OPTION_NPC_NAME) ~= 1
end

-- 人名显示
function utils:CheckSet_Show_name()
    return CHECK_SETTING(MMO.SETTING_IDX_PLAYER_NAME) == 1
end

-- 只显人名
function utils:CheckSet_OnlyShow_name()
    return CHECK_SETTING(MMO.SETTING_IDX_ONLY_NAME) == 1
end

------------------------------------------------------------------------------------------
-- 是否副驾
function utils:IsHoreseCopilot(actor)
    return actor:IsPlayer() and actor:IsHoreseCopilot()
end

-- 屏蔽小怪
function utils:IsHideMonster(actor)
    return actor:GetValueByKey(MMO.MONSTER_NORMAL) and CHECK_SETTING(MMO.SETTING_IDX_MONSTER_VISIBLE) == 1
end

-- 正常怪
function utils:IsNormalMonster(actor)
    if actor:IsHaveMaster() then
        return true
    end

    if actor:IsDefender() then
        return false
    end

    if actor:IsEscort() then
        return false
    end

    if actor:IsCollection() then
        return false
    end

    return true
end

-- 只清理怪物和人形怪
function utils:IsClearMonster(actor)
    if actor:IsMonster() or (actor:IsPlayer() and actor:IsHumanoid()) then
        return true
    end
    return false
end

-- 可清理
function utils:IsCanClearMonster(actor)
    local IsCan = self:IsClearMonster(actor) and CHECK_SETTING(MMO.SETTING_IDX_HIDE_MONSTER_BODY) == 1 and self:ActorIsDie(actor)
    return IsCan
end

-- 是否视野内
function utils:ActorInView(actor)
    return actor:GetValueByKey("InView")
end

-- 是否死亡
function utils:ActorIsDie(actor)
    return actor:IsDie() or actor:IsDeath()    
end

-- 是否是自己的英雄
function utils:IsMyHero(actor)
    local HeroPropertyProxy = Facade:retrieveProxy(ProxyTable.HeroPropertyProxy)
    return actor:GetID() == HeroPropertyProxy:GetRoleUID()
end

-- 是否是城门怪
function utils:IsGate(actor)
    return actor:GetValueByKey(MMO.Is_Gate)
end

-- 是否是城墙怪
function utils:IsWall(actor)
    return actor:GetValueByKey(MMO.Is_Wall)
end

-- 是否钻地怪状态
function utils:IsSleepInCave(actor)
    return actor:GetValueByKey(MMO.Is_Cave)
end

-- 拾取小精灵隐藏显血
function utils:IsHideHpSprite(actor)
    if actor:IsPickUpSprite() and global.ConstantConfig.hideSpriteHp == 1 then
        return true
    end
    return false
end
------------------------------------------------------------------------------------------

-- 获得怪物简装形象
function utils:get_MonsterSimpleDress(monster)
    if not self:checkMonsterFeatureEnable(monster:GetAnimationID(), monster) then
        return MonsterPaperback
    end

    -- Boss 不简装
    if monster:IsBoss() and CHECK_SETTING(MMO.SETTING_IDX_BOSS_NO_SIMPLE_DRESS) == 1 then
        return false
    end

    if CHECK_SETTING(MMO.SETTING_IDX_MONSTER_SIMPLE_DRESS) == 1 and (not monster:IsHaveMaster()) and monster:GetValueByKey(MMO.MONSTER_NORMAL) then
        return MonsterPaperback
    end

    return false
end

-- 判断玩家简装形象
function utils:check_PlayerSimpleDress()
    if CHECK_SETTING(MMO.SETTING_IDX_PLAYER_SIMPLE_DRESS) == 1 then
        return true
    end

    return false
end

function utils:checkFeatureEnable(SFANIM_TYPE, ID, sex, actor)
    -- no thing
    if 0 == ID then
        return true
    end
    if 9999 == ID then
        return true
    end

    -- check param
    if not SFANIM_TYPE or not ID or not sex or SFANIM_TYPE < MMO.SFANIM_TYPE_PLAYER or SFANIM_TYPE > MMO.SFANIM_TYPE_NUM then
        return false
    end

    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return true
    end

    if actor:IsMainPlayer() then
        return  true
    end

    -- 屏蔽所有玩家
    if CHECK_SETTING(MMO.SETTING_IDX_PLAYER_SHOW) == 1 and self:CheckPlayer(actor) then
        return false
    end
    
    -- 屏蔽己方玩家
    if CHECK_SETTING(MMO.SETTING_IDX_PLAYER_SHOW_FRIEND) == 1 and self:CheckPlayerB(actor) then
        return false
    end

    return true
end

function utils:checkMonsterFeatureEnable(ID, actor)
    -- no thing
    if 0 == ID then
        return true
    end
    if 9999 == ID then
        return true
    end

    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if not mainPlayerID then
        return true
    end

    -- ignore main player pet
    if actor:GetMasterID() == mainPlayerID then
        return true
    end

    return true
end

------------------------------------------------------------------------------------------

-- 骑马状态的labelName更新
function utils:refreshLabelName(actor)
    if not actor then
        return false
    end

    if not actor:IsPlayer() then
        return false
    end

    local nameHUD = global.HUDManager:GetHUD(actor:GetID(), MMO.HUD_TYPE_BATCH_LABEL, MMO.HUD_LABEL_NAME)
    if not nameHUD then
        return false
    end
    
    -- 有副驾
    local copilotid = actor:GetHorseCopilotID()
    local masterid  = actor:GetHorseMasterID()
    if copilotid and masterid then
        local playerManager = global.playerManager
        local masterActor   = playerManager:FindOnePlayerInCurrViewFieldById(masterid)
        local copilotActor  = playerManager:FindOnePlayerInCurrViewFieldById(copilotid)
        if masterActor and copilotActor then
            local name = string.format("%s  %s", masterActor:GetName(), copilotActor:GetName())
            nameHUD:setString(name)
            return false
        end
    end

    local name = actor:GetName()
    nameHUD:setString(name or "")
end

------------------------------------------------------------------------------------------
-- 检测血条
function utils:CheckHUDHp(actor)
    if self:ActorIsDie(actor) then
        return false
    end
    
    -- 小精灵不显示血条
    if self:IsHideHpSprite(actor) then
        return false
    end

    if actor:IsMonster() and actor:IsNoShowHPBar() then
        return false
    end

    -- 空血不显示
    if actor:GetValueByKey(MMO.HUD_Hp_Null) then
        return false
    end
    
    if self:IsHoreseCopilot(actor) then
        return false
    end

    return true
end

-- 检测蓝条
function utils:CheckHUDMp(actor)
    if self:ActorIsDie(actor) then
        return false
    end

    if actor:IsMonster() then
        return false
    end

    if actor:IsNPC() then
        return false
    end

    -- 服务器开关
    if CHECK_SERVER_OPTION(MMO.PLAYER_BLUE_BLOOD) ~= 0 then
        return false
    end

    -- 没有护身
    if actor.IsHuShen and not actor:IsHuShen() then
        return false
    end

    -- 没有受到伤害
    if actor.IsDamage and not actor:IsDamage() then
        return false
    end

    if actor:GetValueByKey(MMO.HUD_Hp_Null) then
        return false
    end

    -- 是否是副驾位
    if self:IsHoreseCopilot(actor) then
        return false
    end

    return true
end

-- 检测内功条
function utils:CheckHUDNG(actor)
    if not actor then
        return false
    end 

    if actor:IsMonster() then
        return false
    end

    if actor:IsNPC() then
        return false
    end

    -- 本地开关
    if tonumber(SL:GetMetaValue("GAME_DATA", "OpenNGUI")) ~= 1 then
        return false
    end

    -- 单控开关
    if tonumber(SL:GetMetaValue("GAME_DATA", "HideNGHUD")) == 1 then
        return false
    end

    -- 代码开关
    local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
    if not MeridianProxy:GetNGHudShow() then
        return false
    end

    -- 服务端开关
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    local HeroPropertyProxy = global.Facade:retrieveProxy( global.ProxyTable.HeroPropertyProxy )
    local HeroID = HeroPropertyProxy:GetRoleUID()
    if actor:IsHero() then
        if HeroID == actor:GetID() and not SL:GetMetaValue("H.IS_LEARNED_INTERNAL") then
            return false
        end
    elseif actor:IsPlayer() then
        if mainPlayerID == actor:GetID() and not SL:GetMetaValue("IS_LEARNED_INTERNAL") then
            return false
        end
    end
    if actor:GetMaxForce() == 0 then
        return false
    end

    return true
end

-- 检测血量文本
function utils:CheckHUDHMPLabel(actor)
    if self:ActorIsDie(actor) then
        return false
    end

    if CHECK_SETTING(MMO.SETTING_IDX_HP_NUM) ~= 1 then
        return false
    end
    
    if actor:IsMonster() and actor:IsNoShowHPBar() then
        return false
    end

    -- 小精灵不显示血条
    if self:IsHideHpSprite(actor) then
        return false
    end
    
    if NoShowHpType[actor:GetType()] then
        return false
    end

    local actorID = actor:GetID()

    -- 自己的英雄空血 不显示 血量文本
    local HeroPropertyProxy = Facade:retrieveProxy(ProxyTable.HeroPropertyProxy)
    local isMyHero = HeroPropertyProxy:GetRoleUID() == actorID
    if isMyHero then
        if actor:GetValueByKey(MMO.HUD_Hp_Null) then
            return false
        end
    end

    -- 空血/满血 排除主玩家 和自己的英雄
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if actorID ~= mainPlayerID and (not isMyHero) then
        if actor:GetValueByKey(MMO.HUD_Hp_Null) or actor:GetValueByKey(MMO.HUD_Hp_Full) then
            return false
        end
        if not actor:GetValueByKey(MMO.HUD_BAR_SHOW_FULL_HP) then
            return false
        end
    end

    if self:IsHoreseCopilot(actor) then
        return false
    end

    return true
end

function utils:checkPlayerName(actor)
    if not actor:IsPlayer() then
        return true
    end

    -- 活动统一名字
    local mapProxy = Facade:retrieveProxy(ProxyTable.Map)
    if mapProxy:IsUnitiveName() then
        return false
    end

    -- 神秘人
    if actor:IsShenMiRen() then
        return false
    end

    -- 人名显示
    if not self:CheckSet_Show_name() then
        return false
    end
    -- 只显人名
    if self:CheckSet_OnlyShow_name() then
        return false
    end

    if self:IsHoreseCopilot(actor) then
        return false
    end

    -- 潜行
    if actor:GetValueByKey(MMO.HUD_SNEAK) then
        return false
    end
    
    return true
end

-- 人名
function utils:CheckHUDLabelName(actor)
    local funcName = {
        [MMO.ACTOR_PLAYER] = function (actor)
            if actor:IsHumanoid() then
                -- 死亡不显示
                if self:ActorIsDie(actor) then
                    return false
                end

                -- 隐藏小怪
                if self:IsHideMonster(actor) then
                    return false
                end

                -- 怪物显名
                if actor:GetValueByKey(MMO.MONSTER_NORMAL) and CHECK_SETTING(MMO.SETTING_IDX_MONSTER_NAME) ~= 1 then
                    return false
                end

                return true
            end

            if CHECK_SETTING(MMO.SETTING_IDX_LEVEL_SHOW_NAME_HUD) == 1 then
                local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
                local actorID      = actor:GetID()
                local isMain       = mainPlayerID and actorID == mainPlayerID
                local inputProxy   = Facade:retrieveProxy(ProxyTable.PlayerInputProxy)
                if not isMain and inputProxy:GetTargetID() ~= actorID then
                    local defaultValues = GET_SETTING(MMO.SETTING_IDX_LEVEL_SHOW_NAME_HUD,true)
                    local needLevel     = defaultValues and tonumber(defaultValues[2])
                    local roleLevel     = actor:GetLevel() or 0
                    if needLevel and roleLevel < needLevel then         
                        return false
                    end
                end
            end

            if self:IsHoreseCopilot(actor) then
                return false
            end

            -- 潜行
            if actor:GetValueByKey(MMO.HUD_SNEAK) then
                return false
            end

            return utils:CheckSet_Show_name()
        end,
        [MMO.ACTOR_MONSTER] = function (actor)
            if self:IsSleepInCave(actor) then
                return false
            end
            
            -- 死亡不显示
            if self:ActorIsDie(actor) then
                return false
            end

            if actor:IsNoShowName() then
                return false
            end
            
            -- 隐藏小怪
            if self:IsHideMonster(actor) and SL:GetMetaValue("GAME_DATA", "mon_hide_visible_name") ~= 1 then
                return false
            end

            -- 怪物显名
            if actor:GetValueByKey(MMO.MONSTER_NORMAL) and CHECK_SETTING(MMO.SETTING_IDX_MONSTER_NAME) ~= 1 then
                return false
            end

            return true
        end,
        [MMO.ACTOR_DROPITEM] = function (actor)
            local typeIndex = actor:GetTypeIndex()
            if typeIndex == 0 then
                typeIndex = 1
            end
            return CHECK_ITEM_DROP_SHOW(typeIndex)
        end,
        [MMO.ACTOR_NPC] = function ()
            return utils:CheckSet_Npc_name()
        end
    }

    if funcName[actor:GetType()] then
        return funcName[actor:GetType()] (actor)
    end

    return true
end

-- 行会名
function utils:CheckHUDLabelGuild(actor)
    return self:checkPlayerName(actor)
end

-- 封号名
function utils:CheckHUDLabelTitle(actor)
    local funcTitle = {
        [MMO.ACTOR_PLAYER] = function (actor)
            return utils:checkPlayerName(actor)
        end,
        [MMO.ACTOR_MONSTER] = function (actor)
            if actor:IsEscort() then
                return false
            end

            local curHP = actor:GetHP() or 0
            if curHP < 1 then
                return false
            end

            return true
        end,
        [MMO.ACTOR_DROPITEM] = function ()
            return false
        end,
        [MMO.ACTOR_NPC] = function ()
            return true
        end
    }

    if funcTitle[actor:GetType()] then
        return funcTitle[actor:GetType()] (actor)
    end

    return true
end

-- 检测 称号/顶戴
function utils:CheckHUDTitle(actor)
    if not actor then
        return false
    end

    -- 镖车
    if actor:IsEscort() then
        return true
    end

    -- npc
    if actor:IsNPC() then
        return true
    end

    -- 掉落物
    if actor:IsDropItem() then
        local TypeIndex = actor:GetTypeIndex()
        if TypeIndex == 0 then
            TypeIndex = 1
        end
        return CHECK_ITEM_DROP_SHOW(TypeIndex)
    end

    -- 怪物
    if actor:IsMonster() or actor:IsHumanoid() then
        -- 死亡不显示
        if self:ActorIsDie(actor) then
            return false
        end
        
        -- 隐藏小怪
        if self:IsHideMonster(actor) then
            return false
        end

        if actor:IsElite() and CHECK_SETTING(MMO.SETTING_IDX_MONSTER_VISIBLE) == 1 then
            return false
        end
        
        -- 血量显示死亡不显示
        if actor:GetHP() < 1 then
            return false
        end
        
        return true
    end

    if not actor:IsPlayer() then
        return true
    end

    -- 摆摊
    if actor:IsStallStatus() then
        return false
    end

    -- -- 神秘人
    -- if actor:IsShenMiRen() then
    --     return false
    -- end

    -- 隐藏称号
    if CHECK_SETTING(MMO.SETTING_IDX_TITLE_VISIBLE) == 1 then
        return false
    end
    
    if self:IsHoreseCopilot(actor) then
        return false
    end

    -- 潜行
    if actor:GetValueByKey(MMO.HUD_SNEAK) then
        return false
    end

    return true
end

------------------------------------------------------------------------------------------
function utils:SetHUDHpBarVisible(actor, visible)
    local hpBar = actor.mHUDUI[MMO.HUDHPUI_BAR]
    if hpBar then
        hpBar:setVisible(visible)
    end

    local hpBorder = actor.mHUDUI[MMO.HUDHPUI_BORDER]
    if hpBorder then
        hpBorder:setVisible(visible)
    end
end

-- 血条
function utils:CheckHUDHpBarVisible(actor)
    local visible = false
    if not self:IsSleepInCave(actor) then
        visible = self:ActorInView(actor) and CHECK_SETTING(MMO.SETTING_IDX_HP_HUD) == 1 and actor:GetValueByKey(MMO.HUD_HPBAR_VISIBLE)
    end

    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end

    -- 副驾
    if visible and self:IsHoreseCopilot(actor) then
        visible = false
    end
    
    self:SetHUDHpBarVisible(actor, visible)
end

function utils:SetHUDMpBarVisible(actor, visible)
    local mpBar = actor.mHUDUI[MMO.HUDMPUI_BAR]
    if mpBar then
        mpBar:setVisible(visible)
    end

    local mpBorder = actor.mHUDUI[MMO.HUDMPUI_BORDER]
    if mpBorder then
        mpBorder:setVisible(visible)
    end
end

-- 蓝条
function utils:CheckHUDMpBarVisible(actor)
    local visible = self:ActorInView(actor) and actor:GetValueByKey(MMO.HUD_MPBAR_VISIBLE)

    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end

    -- 副驾
    if visible and self:IsHoreseCopilot(actor) then
        visible = false
    end

    self:SetHUDMpBarVisible(actor, visible)
end

function utils:refreshHUDHMpLabelVisible(actor)
    local visible = false
    if not self:IsSleepInCave(actor) then
        visible = actor:IsVisibleServerHpLabel() or (actor:GetValueByKey(MMO.HUD_PC_MOUSE_SHOW) and (not self:ActorIsDie(actor))) or (self:ActorInView(actor) and actor:GetValueByKey(MMO.HUD_HMPLabel_VISIBLE))
    end

    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end

    -- 副驾
    if visible and self:IsHoreseCopilot(actor) then
        visible = false
    end

    self:SetHMPLabelVisible(actor, visible)
end

function utils:SetHUDNGBarVisible(actor, visible)
    local ngBar = actor.mHUDUI[MMO.HUDNGUI_BAR]
    if ngBar then
        ngBar:setVisible(visible)
    end

    local ngBorder = actor.mHUDUI[MMO.HUDNGUI_BORDER]
    if ngBorder then
        ngBorder:setVisible(visible)
    end
end

-- 内功条显示
function utils:CheckHUDNGBarVisible(actor)
    local visible = self:ActorInView(actor) and actor:GetValueByKey(MMO.HUD_NGBAR_VISIBLE)

    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end

    -- 副驾
    if visible and self:IsHoreseCopilot(actor) then
        visible = false
    end

    self:SetHUDNGBarVisible(actor, visible)
end

-- 血量文本
function utils:SetHMPLabelVisible(actor, visible)
    local sprite = global.HUDManager:GetHUD(actor:GetID(), global.MMO.HUD_TYPE_BATCH_LABEL, global.MMO.HUD_LABEL_HP)
    if not sprite then
        return false
    end
    sprite:setVisible(visible)
end

-- HUD Name -------------------------------------------------------------------------------------------------
function utils:SetHUDLabelNameVisible(actor, visible)
    global.HUDManager:setVisible(actor:GetID(), MMO.HUD_TYPE_BATCH_LABEL, MMO.HUD_LABEL_NAME, visible)
end

-- 检测名字
function utils:refreshHUDLabelNameVisible(actor)
    local visible = actor:GetValueByKey(MMO.HUD_PC_MOUSE_SHOW) or (self:ActorInView(actor) and actor:GetValueByKey(MMO.HUD_NAMELabel_VISIBLE))

    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end

    -- 副驾
    if self:IsHoreseCopilot(actor) then
        visible = false
    end

    self:SetHUDLabelNameVisible(actor, visible)
end

-- HUD Guild -------------------------------------------------------------------------------------------------
function utils:SetHUDLabelGuildVisible(actor, visible)
    global.HUDManager:setVisible(actor:GetID(), MMO.HUD_TYPE_BATCH_LABEL, MMO.HUD_LABEL_GUILD, visible)
end

-- 检测行会
function utils:refreshHUDLabelGuildVisible(actor)
    local visible = actor:GetValueByKey(MMO.HUD_PC_MOUSE_SHOW) or (self:ActorInView(actor) and actor:GetValueByKey(MMO.HUD_GUILDLabel_VISIBLE))
    
    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end

    -- 副驾
    if visible and self:IsHoreseCopilot(actor) then
        visible = false
    end

    self:SetHUDLabelGuildVisible(actor, visible)
end

-- HUD Title -------------------------------------------------------------------------------------------------
function utils:SetHUDTitleLabelVisible(actor, visible)
    local actorID = actor:GetID()
    local hudType = MMO.HUD_TYPE_BATCH_LABEL
    local hudMin  = MMO.HUD_LABEL_PRE_NAME1
    for i = 0, 11 do
        global.HUDManager:setVisible(actorID, hudType, hudMin + i, visible) 
    end
end

-- 检测Title
function utils:refreshHUDLabelTitleVisible(actor)
    local visible = actor:GetValueByKey(MMO.HUD_PC_MOUSE_SHOW) or (self:ActorInView(actor) and actor:GetValueByKey(MMO.HUD_TITLELabel_VISIBLE))
    
    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end

    -- 副驾
    if visible and self:IsHoreseCopilot(actor) then
        visible = false
    end

    self:SetHUDTitleLabelVisible(actor, visible)
end

-- 刷新 名字、行会名、顶戴
function utils:refreshLabelVisible(actor)
    self:InitHUDVisibleValue(actor, global.MMO.HUD_NAMELabel_VISIBLE)
    self:InitHUDVisibleValue(actor, global.MMO.HUD_GUILDLabel_VISIBLE)
    self:InitHUDVisibleValue(actor, global.MMO.HUD_TITLELabel_VISIBLE)
    self:InitHUDVisibleValue(actor, global.MMO.HUD_TITLE_VISIBLE)
    self:refreshHUDLabelNameVisible(actor)
    self:refreshHUDLabelGuildVisible(actor)
    self:refreshHUDLabelTitleVisible(actor)
    self:refreshHUDTitleVisible(actor)
end

-- 顶戴、称号
function utils:SetHUDTitleVisible(actor, visible, isHorseUpdate)
    local HUDManager = global.HUDManager
    local actorID    = actor:GetID()

    if isHorseUpdate then
        local actorID = actor:GetID()
        for i = 0, 2 do
            if hudTitleSpriteID[i] then
                HUDManager:setVisible(actorID, MMO.HUD_TYPE_SPRITE, hudTitleSpriteID[i], visible)
            end

            if hudTitleLableID[i] then
                HUDManager:setVisible(actorID, MMO.HUD_TYPE_BATCH_LABEL, hudTitleLableID[i], visible)
            end
        end
    else
        local Box996Proxy = Facade:retrieveProxy(ProxyTable.Box996Proxy)
        
        for i = 0, 10 do
            local hudSprite = HUDManager:GetHUD(actorID, MMO.HUD_TYPE_SPRITE, hudTipsID[i])

            local hudAnim = HUDManager:GetHUD(actorID, MMO.HUD_TYPE_ANIM, animHudID[i])

            if hudSprite and hudSprite.isBox996 then  --盒子称号 有自己的开关
                local hzVisible = Box996Proxy:isShowTitleByActor(actor)
                -- 潜行
                if hzVisible and actor:GetValueByKey(MMO.HUD_SNEAK) then
                    hzVisible = false
                end
                HUDManager:setVisible(actorID, MMO.HUD_TYPE_SPRITE, hudTipsID[i], hzVisible)
            elseif hudAnim and hudAnim.isBox996 then  --盒子称号 有自己的开关
                local hzVisible = Box996Proxy:isShowTitleByActor(actor)
                -- 潜行
                if hzVisible and actor:GetValueByKey(MMO.HUD_SNEAK) then
                    hzVisible = false
                end
                HUDManager:setVisible(actorID, MMO.HUD_TYPE_ANIM, animHudID[i], hzVisible)
            else
                HUDManager:setVisible(actorID, MMO.HUD_TYPE_SPRITE, hudTipsID[i], visible)
                HUDManager:setVisible(actorID, MMO.HUD_TYPE_ANIM, animHudID[i], visible)
            end

            if hudTitleSpriteID[i] then
                HUDManager:setVisible(actorID, MMO.HUD_TYPE_SPRITE, hudTitleSpriteID[i], visible)
            end

            if hudTitleLableID[i] then
                HUDManager:setVisible(actorID, MMO.HUD_TYPE_BATCH_LABEL, hudTitleLableID[i], visible)
            end
        end
    end
end

-- 刷新 称号、顶戴
function utils:refreshHUDTitleVisible(actor, isHorseUpdate)
    local visible = self:ActorInView(actor) and actor:GetValueByKey(MMO.HUD_TITLE_VISIBLE)

    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end

    -- 副驾
    if visible and self:IsHoreseCopilot(actor) then
        visible = false
    end

    self:SetHUDTitleVisible(actor, visible, isHorseUpdate)
end

---------------------------------------------------------------------------------------------------------------------
-- 英雄（非主玩家）
-- 检测英雄显示状态
function utils:CheckHero(actor)
    return not self:IsMyHero(actor)
end

-- 设置状态
function utils:SetHeroVisible(actor, visible)
    local node = actor:GetNode()--GetAvatarNode()
    if node then
        node:setVisible(visible)
    end
end

-- 刷新
function utils:refreshHeroVisible(actor)
    local visible = self:IsMyHero(actor) or (self:ActorInView(actor) and CHECK_SETTING(MMO.SETTING_IDX_HERO_HIDE) ~= 1 and actor:GetValueByKey(MMO.HERO_VISIBLE))
    self:SetHeroVisible(actor, visible)
end

------------------
-- 玩家
function utils:CheckPlayer(actor)
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if not mainPlayerID then
        return false
    end

    if actor:IsMainPlayer() then
        return true
    end

    if self:IsHoreseCopilot(actor) then
        return false
    end

    -- 清理怪
    if self:IsCanClearMonster(actor) then
        return false
    end

    return true
end

function utils:SetPlayerVisible(actor, visible)
    local node = actor:GetNode()--GetAvatarNode()
    if node then
        node:setVisible(visible)
    end
end

-- 刷新
function utils:refreshPlayerVisible(actor)
    local visible = actor:IsMainPlayer() or (self:ActorInView(actor) and CHECK_SETTING(MMO.SETTING_IDX_PLAYER_SHOW) ~= 1 and actor:GetValueByKey(MMO.PLAYER_VISIBLE))
    
    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end
    
    -- 副驾
    if visible and self:IsHoreseCopilot(actor) then
        visible = false
    end

    self:SetPlayerVisible(actor, visible)
end

-- 检测乙方阵营
function utils:CheckPlayerB(actor)
    return actor:IsSameCamp()
end

function utils:CheckSamePlayer(actor)
    if (not actor:IsMainPlayer()) and actor:GetValueByKey(MMO.PLAYER_B_VISIBLE) and CHECK_SETTING(MMO.SETTING_IDX_PLAYER_SHOW_FRIEND) == 1 then
        return false
    end
    return true
end

function utils:refreshPlayerBVisible(actor)
    local visible = actor:IsMainPlayer() or (self:ActorInView(actor) and self:CheckSamePlayer(actor) and CHECK_SETTING(MMO.SETTING_IDX_PLAYER_SHOW) ~= 1)
    
    -- 潜行
    if visible and actor:GetValueByKey(MMO.HUD_SNEAK) then
        visible = false
    end

    -- 副驾
    if visible and self:IsHoreseCopilot(actor) then
        visible = false
    end

    self:SetPlayerVisible(actor, visible)
end

---------------------------------------------------------------------------------------------------------------------
function utils:CheckMonster(actor)
    if not actor then
        return false
    end

    -- 清理尸体
    if self:IsCanClearMonster(actor) then
        return false
    end

    -- 隐藏怪
    if not actor:IsHaveMaster() and self:IsHideMonster(actor) then
        return false
    end

    -- 召唤物
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if CHECK_SETTING(MMO.SETTING_IDX_MONSTER_PET_VISIBLE) == 1 and actor:IsHaveMaster() and actor:GetMasterID() ~= mainPlayerID then
        return false
    end

    return true
end

function utils:SetMonsterVisible(actor, visible)
    local node = actor:GetNode()--GetAvatarNode()
    if node then
        node:setVisible(visible==true)
    end
end

function utils:refreshMonsterVisible(actor)
    local visible = false
    if not self:IsSleepInCave(actor) then
        visible = self:IsGate(actor) or self:IsWall(actor) or (self:ActorInView(actor) and actor:GetValueByKey(MMO.MONSTER_VISIBLE))
    end
    self:SetMonsterVisible(actor, visible)
end

--  Init HUD visible -------------------------------------------------------------------------------------------------
local KeyFunc = {
    [MMO.HUD_HPBAR_VISIBLE]      = function (actor) return utils:CheckHUDHp(actor)            end,
    [MMO.HUD_MPBAR_VISIBLE]      = function (actor) return utils:CheckHUDMp(actor)            end,
    [MMO.HUD_NGBAR_VISIBLE]      = function (actor) return utils:CheckHUDNG(actor)            end,
    [MMO.HUD_HMPLabel_VISIBLE]   = function (actor) return utils:CheckHUDHMPLabel(actor)      end,
    [MMO.HUD_TITLE_VISIBLE]      = function (actor) return utils:CheckHUDTitle(actor)         end,
    [MMO.HUD_NAMELabel_VISIBLE]  = function (actor) return utils:CheckHUDLabelName(actor)     end,
    [MMO.HUD_GUILDLabel_VISIBLE] = function (actor) return utils:CheckHUDLabelGuild(actor)    end,
    [MMO.HUD_TITLELabel_VISIBLE] = function (actor) return utils:CheckHUDLabelTitle(actor)    end,

    [MMO.HERO_VISIBLE]           = function (actor) return utils:CheckHero(actor)             end,
    [MMO.MONSTER_VISIBLE]        = function (actor) return utils:CheckMonster(actor)          end,
    [MMO.PLAYER_VISIBLE]         = function (actor) return utils:CheckPlayer(actor)           end,
    [MMO.PLAYER_B_VISIBLE]       = function (actor) return utils:CheckPlayerB(actor)          end,

    [MMO.MONSTER_NORMAL]         = function (actor) return utils:IsNormalMonster(actor)       end,
    [MMO.MONSTER_CLEAR]          = function (actor) return utils:IsClearMonster(actor)        end,
}

-- 初始化 actor 显示数据
function utils:InitHUDVisibleValue(actor, key)
    if KeyFunc[key] then
        actor:SetKeyValue(key, KeyFunc[key](actor))
    end
end
-----------------------------------------------------------------------------------------------------------------------

return utils