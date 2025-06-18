local SettingChangeCommand = class('SettingChangeCommand', framework.SimpleCommand)

local optionsUtils = requireProxy( "optionsUtils" )
local skillUtils   = requireProxy("skillUtils")

function SettingChangeCommand:ctor()
end

function SettingChangeCommand:execute(notification)
    local data = notification:getBody()
    local id   = data.id
    local value = data.value or 0

    dump(data)

    if id == global.MMO.SETTING_IDX_PLAYER_NAME then -- 人物显名
        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor then
                local hudParam = GetActorAttr( actor, global.MMO.ACTOR_ATTR_HUDPARAM )
                if hudParam and next(hudParam) then
                    global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actor:GetID(), hudParam = hudParam })
                end
            end
        end

        local monsters, ncount = global.monsterManager:GetMonstersInCurrViewField()
        for i = 1, ncount do
            local actor = monsters[i]
            if actor and actor:IsHaveMaster() then
                optionsUtils:refreshLabelVisible(actor)
            end
        end
    elseif id == global.MMO.SETTING_IDX_ONLY_NAME then -- 只显人名
        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor then
                local hudParam = GetActorAttr( actor, global.MMO.ACTOR_ATTR_HUDPARAM )
                if hudParam and next(hudParam) then
                    global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actor:GetID(), hudParam = hudParam })
                end
            end
        end
    elseif id == global.MMO.SETTING_IDX_HP_NUM then -- 数字显血
        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor then
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_HMPLabel_VISIBLE)
                optionsUtils:refreshHUDHMpLabelVisible( actor )
            end
        end

        local monsters, ncount = global.monsterManager:GetMonstersInCurrViewField()
        for i = 1, ncount do
            local actor = monsters[i]
            if actor then
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_HMPLabel_VISIBLE)
                optionsUtils:refreshHUDHMpLabelVisible( actor )
            end
        end
    elseif id == global.MMO.SETTING_IDX_HP_HUD then -- 显示血条
        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor then
                optionsUtils:CheckHUDHpBarVisible( actor )
                optionsUtils:CheckHUDMpBarVisible( actor )
            end
        end

        local monsters, ncount = global.monsterManager:GetMonstersInCurrViewField()
        for i = 1, ncount do
            local actor = monsters[i]
            if actor then
                optionsUtils:CheckHUDHpBarVisible( actor )
                optionsUtils:CheckHUDMpBarVisible( actor )
            end
        end
    elseif id == global.MMO.SETTING_IDX_MONSTER_NAME then -- 怪物显名
        local monsters, ncount = global.monsterManager:GetMonstersInCurrViewField()
        for i = 1, ncount do
            local actor = monsters[i]
            if actor then
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_NAMELabel_VISIBLE)
                optionsUtils:refreshHUDLabelNameVisible( actor )
            end
        end

        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor and actor:IsHumanoid() then
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_NAMELabel_VISIBLE)
                optionsUtils:refreshHUDLabelNameVisible( actor )

                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_GUILDLabel_VISIBLE)
                optionsUtils:refreshHUDLabelGuildVisible( actor )
            end
        end

    elseif id == global.MMO.SETTING_IDX_MONSTER_PET_VISIBLE then -- 屏蔽召唤物
        global.Facade:sendNotification(global.NoticeTable.SetChange_MonsterPet)

    elseif id == global.MMO.SETTING_IDX_EFFECT_SHOW then -- 屏蔽特效设置（技能除外）
        global.Facade:sendNotification(global.NoticeTable.SetChange_AllEffect)

    elseif id == global.MMO.SETTING_IDX_SKILL_EFFECT_SHOW then -- 屏蔽技能特效设置
        global.Facade:sendNotification(global.NoticeTable.SetChange_SkillEffect)
        
    elseif id == global.MMO.SETTING_IDX_PLAYER_SHOW_FRIEND then -- 屏蔽己方玩家设置
        global.Facade:sendNotification(global.NoticeTable.SetChange_OwnSidePlayer)

    elseif id == global.MMO.SETTING_IDX_PLAYER_SHOW then -- 屏蔽玩家设置
        global.Facade:sendNotification(global.NoticeTable.SetChange_AllPlayer)

    elseif id == global.MMO.SETTING_IDX_MONSTER_VISIBLE then -- 屏蔽怪物设置
        global.Facade:sendNotification(global.NoticeTable.SetChange_NormalMonster)

        local monsters, ncount = global.monsterManager:GetMonstersInCurrViewField()
        for i = 1, ncount do
            local actor = monsters[i]
            if actor then
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_NAMELabel_VISIBLE)
                optionsUtils:refreshHUDLabelNameVisible( actor )
            end
        end

        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor and actor:IsHumanoid() then
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_NAMELabel_VISIBLE)
                optionsUtils:refreshHUDLabelNameVisible( actor )
            end
        end
    elseif id == global.MMO.SETTING_IDX_IGNORE_STALL then -- 屏蔽摆摊
        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor then
                global.Facade:sendNotification(global.NoticeTable.RefreshActorBooth, {actorID = actor:GetID(), actor = actor})
            end
        end
    elseif id == global.MMO.SETTING_IDX_TITLE_VISIBLE then -- 显示称号设置
        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor then
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_TITLE_VISIBLE)
                optionsUtils:refreshHUDTitleVisible( actor )
            end
        end
    elseif id == global.MMO.SETTING_IDX_FRAME_RATE_TYPE_HIGH then -- 高帧率模式设置
        value = value or {}
        value = value[1]
        local newvalue = 1 - value
        local CheckOptions = 
        {
            [global.MMO.SETTING_IDX_MONSTER_PET_VISIBLE] = newvalue,     -- 屏蔽召唤物
            [global.MMO.SETTING_IDX_EFFECT_SHOW] = newvalue,             -- 屏蔽特效
            [global.MMO.SETTING_IDX_SKILL_EFFECT_SHOW] = newvalue,       -- 屏蔽技能特效
            [global.MMO.SETTING_IDX_PLAYER_SHOW_FRIEND] = newvalue,      -- 屏蔽玩家设置
            [global.MMO.SETTING_IDX_PLAYER_SHOW] = newvalue,             -- 屏蔽玩家设置
            [global.MMO.SETTING_IDX_MONSTER_VISIBLE] = newvalue,         -- 屏蔽怪物设置
            [global.MMO.SETTING_IDX_TITLE_VISIBLE] = newvalue,           -- 隐藏称号
        }
        for k, v in pairs(CheckOptions) do
            CHANGE_SETTING(k, {v})
        end

    elseif id == global.MMO.SETTING_IDX_PLAYER_JOB_LEVEL then -- 血量刷新设置
        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor then
                global.HUDHPManager:UpdateNow(actor)
            end
        end
    elseif id == global.MMO.SETTING_IDX_HIDE_MONSTER_BODY then -- 清理尸体设置
        local monsters, ncount = global.monsterManager:GetMonstersInCurrViewField()
        for i = 1, ncount do
            local actor = monsters[i]
            if actor then
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_NAMELabel_VISIBLE)
                optionsUtils:refreshHUDLabelNameVisible(actor)
    
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.MONSTER_VISIBLE)
                optionsUtils:refreshMonsterVisible(actor)
    
                -- global.Facade:sendNotification( global.NoticeTable.RefreshBuffVisible, actor )
            end
        end

        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor and actor:IsHumanoid() then
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_NAMELabel_VISIBLE)
                optionsUtils:refreshHUDLabelNameVisible(actor)
                
                optionsUtils:InitHUDVisibleValue(actor, global.MMO.PLAYER_VISIBLE)
                optionsUtils:refreshPlayerVisible(actor)

                -- global.Facade:sendNotification( global.NoticeTable.RefreshBuffVisible, actor )
            end
        end
    elseif id == global.MMO.SETTING_IDX_PLAYER_SIMPLE_DRESS then -- 人物简装
        global.Facade:sendNotification(global.NoticeTable.SetChange_SimpleDressPlayer)

    elseif id == global.MMO.SETTING_IDX_MONSTER_SIMPLE_DRESS then -- 怪物简装
        global.Facade:sendNotification(global.NoticeTable.SetChange_SimpleDressMonster)

        local monsters, ncount = global.monsterManager:GetMonstersInCurrViewField()
        for i = 1, ncount do
            local actor = monsters[i]
            if actor then
                global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDTitle, { actor = actor,  actorID = actor:GetID()} )
            end
        end
    elseif id == global.MMO.SETTING_IDX_BOSS_NO_SIMPLE_DRESS then
        global.Facade:sendNotification(global.NoticeTable.SetChange_SimpleDressMonsterBoss)

        local monsters, ncount = global.monsterManager:GetMonstersInCurrViewField()
        for i = 1, ncount do
            local actor = monsters[i]
            if actor and actor:IsBoss() then
                global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDTitle, { actor = actor,  actorID = actor:GetID()} )
            end
        end
    elseif id == global.MMO.SETTING_IDX_HERO_HIDE then -- 屏蔽英雄
        global.Facade:sendNotification(global.NoticeTable.SetChange_AllHero)--英雄屏蔽

    elseif id == global.MMO.SETTING_IDX_ROCKER_SHOW_DISTANCE then --轮盘侧边距
        global.Facade:sendNotification( global.NoticeTable.Rocker_Show_Distance_Change, value )

    elseif id == global.MMO.SETTING_IDX_SKILL_SHOW_DISTANCE then --技能侧边距
        SL:onLUAEvent(LUA_EVENT_SKILLBUTTON_DISTANCE_CHANGE)

    elseif id == global.MMO.SETTING_IDX_NO_MONSTAER_USE then --多少秒没怪物使用   
        local AssistProxy = global.Facade:retrieveProxy(global.ProxyTable.AssistProxy)
        AssistProxy:resetNoMonsterSchedule()

    elseif id == global.MMO.SETTING_IDX_HP_UNIT then --血量单位转换
        local monsters, ncount = global.monsterManager:GetMonstersInCurrViewField()
        for i = 1, ncount do
            local actor = monsters[i]
            if actor and actor:IsBoss() then
                global.HUDHPManager:UpdateNow(actor)
            end
        end

        local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
        for i = 1, ncount do
            local actor = actors[i]
            if actor then
                global.HUDHPManager:UpdateNow(actor)
            end
        end
    end
end

return SettingChangeCommand
