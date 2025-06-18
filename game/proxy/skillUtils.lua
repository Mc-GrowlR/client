local skillUtils = {}

local proxyUtils = requireProxy("proxyUtils")

local SKILL_ID_PuGong           = 0     --普攻
local SKILL_ID_ShiDuShu         = 6     --施毒术
local SKILL_ID_GongSha          = 7     --攻杀
local SKILL_ID_KJHuoHuan        = 8     --抗拒火环
local SKILL_ID_CiSha            = 12    --刺杀
local SKILL_ID_YouLingDun       = 14    --幽灵顿
local SKILL_ID_SSZhanJia        = 15    --神圣战甲术
local SKILL_ID_ZHKuLou          = 17    --召唤骷髅
local SKILL_ID_YinShenShu       = 18    --隐身术
local SKILL_ID_HuoQiang         = 22    --火墙
local SKILL_ID_DYLeiGuang       = 24    --地狱雷光
local SKILL_ID_BanYue           = 25    --半月
local SKILL_ID_LieHuo           = 26    --烈火
local SKILL_ID_QTZhiYuShu       = 29    --群体治愈术
local SKILL_ID_ZHShenShou       = 30    --召唤神兽
local SKILL_ID_MoFaDun          = 31    --魔法盾
local SKILL_ID_HuoYanBing       = 36    --火焰冰
local SKILL_ID_ShuangLongZhan   = 40    --双龙斩
local SKILL_ID_LYJianFa         = 42    --龙影剑法
local SKILL_ID_LTJianFa         = 43    --雷霆剑法
local SKILL_ID_HanBingZhang     = 44    --寒冰掌
local SKILL_ID_WuJiZhenQi       = 50    --无极真气
local SKILL_ID_QTShiDuShu       = 51    --群体施毒术
local SKILL_ID_ZHYueLing        = 55    --召唤月灵
local SKILL_ID_ZhuRi            = 56    --逐日
local SKILL_ID_ShiXueShu        = 57    --嗜血术
local SKILL_ID_KaiTian          = 66    --开天
local SKILL_ID_DaoLiDun         = 73    --道力盾
local SKILL_ID_ZHShengShou      = 76    --召唤圣兽
local SKILL_ID_ZHJianShu        = 81    --纵横剑术
local SKILL_ID_BingLianShu      = 83    --冰镰术
local SKILL_ID_BSQunYu          = 84    --冰霜群雨
local SKILL_ID_LieShenFu        = 85    --裂神服
local SKILL_ID_SWZhiYan         = 86    --死亡之眼
local SKILL_ID_WuLiDun          = 87    --武力盾
local SKILL_ID_XPYiJi           = 115   --血泊一击
local SKILL_ID_ShiZiHou         = 41    --狮子吼

local AUTO_SETTING_KEY_VALUE = {
    [SKILL_ID_MoFaDun]      = global.MMO.SETTING_IDX_AUTO_MOFADUN,          -- 自动魔法盾
    [SKILL_ID_HuoQiang]     = global.MMO.SETTING_IDX_AUTO_FIRE_WALL,        -- 自动火墙
    [SKILL_ID_ShiDuShu]     = global.MMO.SETTING_IDX_AUTO_DU,               -- 自动施毒术
    [SKILL_ID_YouLingDun]   = global.MMO.SETTING_IDX_AUTO_YOULINGDUN,       -- 自动幽灵盾
    [SKILL_ID_SSZhanJia]    = global.MMO.SETTING_IDX_AUTO_SSZJS,            -- 自动神圣战甲术
    [SKILL_ID_WuJiZhenQi]   = global.MMO.SETTING_IDX_AUTO_WJZQ,             -- 自动无极真气
    [SKILL_ID_YinShenShu]   = global.MMO.SETTING_IDX_AUTO_CLOAKING,         -- 自动隐身
    [SKILL_ID_HanBingZhang] = global.MMO.SETTING_IDX_AUTO_ICE_PALM,         -- 自动寒冰掌
    [SKILL_ID_ShiXueShu]    = global.MMO.SETTING_IDX_AUTO_BLOODTHIRSTY_S,   -- 自动嗜血术
    [SKILL_ID_LieShenFu]    = global.MMO.SETTING_IDX_AUTO_BREACH_NERVE_FU,  -- 自动裂神符
    [SKILL_ID_BingLianShu]  = global.MMO.SETTING_IDX_AUTO_ICE_SICKLE_S,     -- 自动冰镰术
    [SKILL_ID_HuoYanBing]   = global.MMO.SETTING_IDX_AUTO_FLAME_ICE,        -- 自动火焰冰
    [SKILL_ID_BSQunYu]      = global.MMO.SETTING_IDX_AUTO_ICE_GROUP_RAIN,   -- 自动冰霜群雨
    [SKILL_ID_SWZhiYan]     = global.MMO.SETTING_IDX_AUTO_DEATH_EYE,        -- 自动死亡之眼
    [SKILL_ID_ShiZiHou]     = global.MMO.SETTING_IDX_AUTO_SHI_ZI_HOU,       -- 自动狮子吼
    [SKILL_ID_ZHJianShu]    = global.MMO.SETTING_IDX_AUTO_FREELY_JS,        -- 自动纵横剑术
}

-- 内挂检测技能
local SETTING_SKILL = {
    SKILL_ID_KaiTian,
    SKILL_ID_ZhuRi,
    SKILL_ID_LYJianFa,
    SKILL_ID_LTJianFa,
    SKILL_ID_ZHJianShu,
    SKILL_ID_ShiDuShu,
    SKILL_ID_HuoQiang,
    SKILL_ID_HanBingZhang,
    SKILL_ID_ShiXueShu,
    SKILL_ID_LieShenFu,
    SKILL_ID_SWZhiYan,
    SKILL_ID_BingLianShu,
    SKILL_ID_HuoYanBing,
    SKILL_ID_BSQunYu,
    SKILL_ID_LieHuo,
}


skillUtils.calcLaunchDirection = function(dstPos, srcPos)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return global.MMO.ORIENT_U
    end
    if not srcPos or not dstPos then
        return mainPlayer:GetDirection()
    end
    if srcPos.x == dstPos.x and srcPos.y == dstPos.y then
        return mainPlayer:GetDirection()
    end
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    return inputProxy:calcMapDirection(dstPos, srcPos)
end

--------------------------- 技能检测 begin -------------------------------
skillUtils.CHECK_SKILL = {
    -- 武力盾
    [SKILL_ID_WuLiDun] = function(target)
        local skillID = SKILL_ID_WuLiDun
        -- exist shield
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if global.BuffManager:IsHaveShield(mainPlayerID) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 魔法盾
    [SKILL_ID_MoFaDun] = function(target)
        local skillID = SKILL_ID_MoFaDun
        -- exist shield
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if global.BuffManager:IsHaveShield(mainPlayerID) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 道力盾
    [SKILL_ID_DaoLiDun] = function(target)
        local skillID = SKILL_ID_DaoLiDun
        -- exist shield
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if global.BuffManager:IsHaveShield(mainPlayerID) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 无极真气
    [SKILL_ID_WuJiZhenQi] = function(target)
        local skillID = SKILL_ID_WuJiZhenQi
        -- exit shield
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if global.BuffManager:IsHaveOneBuff(mainPlayerID, global.MMO.BUFF_ID_WUJI_SHIELD) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 幽灵盾
    [SKILL_ID_YouLingDun] = function(target)
        local skillID = SKILL_ID_YouLingDun
        -- exist shield
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if global.BuffManager:IsHaveGhostShield(mainPlayerID) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 神圣战甲术
    [SKILL_ID_SSZhanJia] = function(target)
        local skillID = SKILL_ID_SSZhanJia
        -- exist shield
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if global.BuffManager:IsHaveAngelShield(mainPlayerID) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 召唤月灵
    [SKILL_ID_ZHYueLing] = function(target)
        local skillID = SKILL_ID_ZHYueLing
        local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        if not SummonsProxy:canSummons(skillID) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 召唤神兽
    [SKILL_ID_ZHShenShou] = function(target)
        local skillID = SKILL_ID_ZHShenShou
        local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        if not SummonsProxy:canSummons(skillID) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 召唤圣兽
    [SKILL_ID_ZHShengShou] = function(target)
        local skillID = SKILL_ID_ZHShengShou
        local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        if not SummonsProxy:canSummons(skillID) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 召唤骷髅
    [SKILL_ID_ZHKuLou] = function(target)
        local skillID = SKILL_ID_ZHKuLou
        local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        if not SummonsProxy:canSummons(skillID) then
            return nil
        end
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 火墙
    [SKILL_ID_HuoQiang] = function(target)
        if not target then
            return nil
        end
        local skillID = SKILL_ID_HuoQiang
        -- check fire is existed
        local dstX = target:GetMapX()
        local dstY = target:GetMapY()
        if global.sceneEffectManager:IsExistedFireInMapXY(dstX, dstY) then
            return nil
        end

        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        -- check launchTime
        local lastLaunchTime = skillProxy:GetSkillCustomData(skillID)
        local currTime = os.time()
        if lastLaunchTime and currTime - lastLaunchTime < 3 then
            return nil
        end
        skillProxy:SetSkillCustomData(skillID, currTime)

        return skillID, cc.p(target:GetMapX(), target:GetMapY())
    end,

    -- 施毒术
    [SKILL_ID_ShiDuShu] = function(target)
        if not target then
            return nil
        end

        local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        if not autoProxy:CheckDu() then
            return nil
        end

        local skillID = SKILL_ID_ShiDuShu
        -- 红绿毒
        local res = 0
        if global.BuffManager:IsPoisoningRed(target:GetID()) then
            res = res + 1
        end
        if global.BuffManager:IsPoisoningGreen(target:GetID()) then
            res = res + 2
        end

        local assistProxy = global.Facade:retrieveProxy(global.ProxyTable.AssistProxy)
        if res == 0 then
            local skillProxy = global.Facade:retrieveProxy( global.ProxyTable.Skill )
            if skillProxy:CheckAbleToLaunch(skillID) == 1 then
                autoProxy:UpdateDuTime()
            end
            return skillID
        elseif res == 1 and assistProxy:CheckDu(1) then
            return skillID
        elseif res == 2 and assistProxy:CheckDu(2) then
            return skillID
        end
        return nil
    end,

    -- 群体施毒术
    [SKILL_ID_QTShiDuShu] = function(target)
        if not target then
            return nil
        end

        local skillID = SKILL_ID_QTShiDuShu
        if global.BuffManager:IsPoisoning(target:GetID()) then
            return nil
        end
        return skillID
    end,

    -- 隐身术
    [SKILL_ID_YinShenShu] = function(target)
        local skillID = SKILL_ID_YinShenShu
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if global.BuffManager:IsHaveOneBuff(mainPlayerID, global.MMO.BUFF_ID_HIDDEN) then
            return nil
        end

        -- 根据模式来确定是否判断符毒
        -- （0：穿戴，1:背包，2：无）
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        local AssistProxy = global.Facade:retrieveProxy(global.ProxyTable.AssistProxy)
        local skillAmuleType = MapProxy:GetUseAmuletType()
        if skillAmuleType == 2 then
            return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
        end
        if not ((skillAmuleType == 0 or skillAmuleType == 1) and
            (AssistProxy:checkDressEquipSkillID(skillID) or AssistProxy:checkBagEquipSkillID(skillID))) then
            return nil
        end

        return skillID, cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    end,

    -- 半月
    [SKILL_ID_BanYue] = function(target)
        local skillID = SKILL_ID_BanYue
        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        local ret = skillProxy:CheckAbleToLaunch(skillID)
        if ret ~= 1 and CHECK_SETTING(SLDefine.SETTINGID.SETTING_IDX_SMART_BANYUE) ~= 1 then
            return nil
        end

        if not target then
            return nil
        end

        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        local monsterID = target:GetTypeIndex()
        if not skillProxy:CheckAbleToAttack(skillID, monsterID) then
            return nil
        end

        local around = {
            [global.MMO.ORIENT_U] = {{-1, -1}, {0, -1}, {1, -1}, {1, 0}},
            [global.MMO.ORIENT_RU] = {{0, -1}, {1, -1}, {1, 0}, {1, 1}},
            [global.MMO.ORIENT_R] = {{1, -1}, {1, 0}, {1, 1}, {0, 1}},
            [global.MMO.ORIENT_RB] = {{1, 0}, {1, 1}, {0, 1}, {-1, 1}},
            [global.MMO.ORIENT_B] = {{1, 1}, {0, 1}, {-1, 1}, {-1, 0}},
            [global.MMO.ORIENT_LB] = {{0, 1}, {-1, 1}, {-1, 0}, {-1, -1}},
            [global.MMO.ORIENT_L] = {{-1, 1}, {-1, 0}, {-1, -1}, {0, -1}},
            [global.MMO.ORIENT_LU] = {{-1, 0}, {-1, -1}, {0, -1}, {1, -1}}
        }

        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        local pmapX = mainPlayer:GetMapX()
        local pmapY = mainPlayer:GetMapY()
        local mainPlayerDir = mainPlayer:GetDirection()
        local count = 0
        local targetID = target:GetID()
        local isTargetAround = false
        for k, v in pairs(around[mainPlayerDir] or {}) do
            local monsters = global.actorManager:GetMonsterActorByMapXY(pmapX + v[1], pmapY + v[2], true)
            if monsters then
                for i, mon in ipairs(monsters) do
                    if proxyUtils.checkLaunchTargetByID(mon:GetID()) and
                        skillProxy:CheckIgnoreMon(skillID, mon:GetTypeIndex()) then
                        count = count + 1

                        if not isTargetAround then
                            isTargetAround = targetID == mon:GetID()
                        end
                    end
                end
            end

            if not isTargetAround or count < 2 then
                local players = global.actorManager:GetPlayerActorByMapXY(pmapX + v[1], pmapY + v[2], true)
                if players then
                    for i, player in ipairs(players) do
                        if proxyUtils.checkLaunchTargetByID(player:GetID()) and
                            skillProxy:CheckIgnoreMon(skillID, player:GetTypeIndex()) then
                            count = count + 1

                            if not isTargetAround then
                                isTargetAround = targetID == player:GetID()
                            end
                        end
                    end
                end
            end

            if count >= 2 and isTargetAround then
                break
            end
        end

        if not isTargetAround then
            count = 0
        end

        -- 自动打开/关闭
        if CHECK_SETTING(SLDefine.SETTINGID.SETTING_IDX_SMART_BANYUE) == 1 then
            local isOnSkill = skillProxy:IsOnSkill(skillID)
            if isOnSkill and count < 2 then
                skillProxy:SkillOff(skillID)
                return nil
            elseif not isOnSkill and count >= 2 then
                skillProxy:SkillOn(skillID)
                return nil
            end
        end

        return count >= 2 and skillID or nil, target and cc.p(target:GetMapX(), target:GetMapY()) or nil, false
    end,

    -- 双龙斩
    [SKILL_ID_ShuangLongZhan] = function(target)
        local skillID = SKILL_ID_ShuangLongZhan
        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        local ret = skillProxy:CheckAbleToLaunch(skillID)
        if ret ~= 1 and CHECK_SETTING(SLDefine.SETTINGID.SETTING_IDX_SMART_BANYUE) ~= 1 then
            return nil
        end

        if not target then
            return nil
        end

        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        local monsterID = target:GetTypeIndex()
        if not skillProxy:CheckAbleToAttack(skillID, monsterID) then
            return nil
        end

        local around = {
            [global.MMO.ORIENT_U] = {{-1, 0}, {-1, -1}, {0, -1}, {1, -1}, {1, 0}},
            [global.MMO.ORIENT_RU] = {{-1, -1}, {0, -1}, {1, -1}, {1, 0}, {1, 1}},
            [global.MMO.ORIENT_R] = {{0, -1}, {1, -1}, {1, 0}, {1, 1}, {0, 1}},
            [global.MMO.ORIENT_RB] = {{1, -1}, {1, 0}, {1, 1}, {0, 1},{-1, 1}},
            [global.MMO.ORIENT_B] = {{1, 0}, {1, 1}, {0, 1}, {-1, 1},{0, -1}},
            [global.MMO.ORIENT_LB] = {{1, 1}, {0, 1}, {-1, 1}, {-1, 0},{-1, -1}},
            [global.MMO.ORIENT_L] = {{0, 1}, {-1, 1}, {-1, 0}, {-1, -1},{0, -1}},
            [global.MMO.ORIENT_LU] = {{-1, 1}, {-1, 0}, {-1, -1}, {0, -1},{1, -1}}
        }

        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        local pmapX = mainPlayer:GetMapX()
        local pmapY = mainPlayer:GetMapY()
        local mainPlayerDir = mainPlayer:GetDirection()
        local count = 0
        local targetID = target:GetID()
        local isTargetAround = false
        local aroundT = targetID and around[mainPlayerDir] or {}
        for k, v in pairs(aroundT) do
            local monsters = global.actorManager:GetMonsterActorByMapXY(pmapX + v[1], pmapY + v[2], true)
            if monsters then
                for i, mon in ipairs(monsters) do
                    if proxyUtils.checkLaunchTargetByID(mon:GetID()) and
                        skillProxy:CheckIgnoreMon(skillID, mon:GetTypeIndex()) then
                        count = count + 1

                        if not isTargetAround then
                            isTargetAround = targetID == mon:GetID()
                        end
                    end
                end
            end

            if not isTargetAround or count < 2 then
                local players = global.actorManager:GetPlayerActorByMapXY(pmapX + v[1], pmapY + v[2], true)
                if players then
                    for i, player in ipairs(players) do
                        if proxyUtils.checkLaunchTargetByID(player:GetID()) and
                            skillProxy:CheckIgnoreMon(skillID, player:GetTypeIndex()) then
                            count = count + 1

                            if not isTargetAround then
                                isTargetAround = targetID == player:GetID()
                            end
                        end
                    end
                end
            end

            if count >= 2 and isTargetAround then
                break
            end
        end

        if not isTargetAround then
            count = 0
        end

        -- 自动打开/关闭
        if CHECK_SETTING(SLDefine.SETTINGID.SETTING_IDX_SMART_BANYUE) == 1 then
            local isOnSkill = skillProxy:IsOnSkill(skillID)
            if isOnSkill and count < 2 then
                skillProxy:SkillOff(skillID)
                return nil
            elseif not isOnSkill and count >= 2 then
                skillProxy:SkillOn(skillID)
                return nil
            end
        end

        return count >= 2 and skillID or nil, target and cc.p(target:GetMapX(), target:GetMapY()) or nil, false
    end,

    -- 群体治愈术
    [SKILL_ID_QTZhiYuShu] = function(target)
        local skillID = SKILL_ID_QTZhiYuShu
        if not target then
            return nil
        end
        if proxyUtils.checkEnemyTag(target) == 1 then
            return nil
        end
        return skillID
    end,

    -- 刺杀
    [SKILL_ID_CiSha] = function(target)
        local skillID = SKILL_ID_CiSha
        if target then
            local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
            local monsterID = target:GetTypeIndex()
            if not skillProxy:CheckAbleToAttack(skillID, monsterID) then
                return nil
            end
        end
        return skillID
    end
}

-- 检测技能内挂开关
skillUtils.checkAutoSetting = function(skillID)
    local settingID = nil
    if skillID and skillID > 1000 then  --自定义技能
        settingID = 10000 + skillID
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        local config = skillProxy:FindConfigBySkillID(skillID)
        if (config and config.skilltype == 4) or GameSettingProxy:GetConfigByID(settingID) == nil then
            settingID = nil
        end
    else
        settingID = AUTO_SETTING_KEY_VALUE[skillID]
    end

    if not settingID then
        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        settingID = skillProxy:GetMagicSettingID(skillID)
    end
    
    if not settingID then
        return true
    end
    return CHECK_SETTING(settingID) == 1
end

-- 检测技能释放
skillUtils.checkSkillLaunch = function(skillID, target, isNotCheckSetting)
    if not isNotCheckSetting and not skillUtils.checkAutoSetting(skillID) then
        return nil
    end
    local destPos = nil
    local checkSkill = skillUtils.CHECK_SKILL[skillID]
    if checkSkill then
        local skillIDT, destPosT = checkSkill(target)
        if not skillIDT then
            return nil
        end
        destPos = destPosT
    end

    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    if skillID and skillProxy:CheckAbleToLaunch(skillID) ~= 1 then
        return nil
    end

    return skillID, destPos
end

-- 检测自动战斗技能释放
skillUtils.checkAbleToAutoLaunch = function(skillID, target, multiJob)
    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local roleJob = PlayerProperty:GetRoleJob()
    if multiJob and roleJob ~= global.MMO.ACTOR_PLAYER_JOB_FIGHTER and roleJob ~= global.MMO.ACTOR_PLAYER_JOB_WIZZARD and roleJob ~= global.MMO.ACTOR_PLAYER_JOB_TAOIST then
    else
        if not skillUtils.checkAutoSetting(skillID) then
            return nil
        end
    end

    local skillID, destPos = skillUtils.checkSkillLaunch(skillID, target)
    if not skillID then
        return nil
    end

    if target then
        local monsterID = target:GetTypeIndex()
        if not skillProxy:CheckAbleToAttack(skillID, monsterID) then
            return nil
        end
    end

    -- 召唤
    local config = skillProxy:FindConfigBySkillID(skillID)
    local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
    if config and config.skilltype == 4 and not SummonsProxy:canSummons(skillID) then
        return nil
    end

    -- 根据模式来确定是否判断符毒
    -- （0：穿戴，1:背包，2：无）
    local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )
    local AssistProxy = global.Facade:retrieveProxy( global.ProxyTable.AssistProxy )
    local skillAmuleType = MapProxy:GetUseAmuletType()

    -- 无
    if not skillAmuleType or skillAmuleType == 2 then
        return skillID, destPos
    end

    if (skillAmuleType == 0 or skillAmuleType == 1) and (AssistProxy:checkDressEquipSkillID(skillID) or AssistProxy:checkBagEquipSkillID(skillID)) then
        return skillID, destPos
    end

    return nil
end

-- 飞行技能被阻挡
skillUtils.checkSkillBlocked = function(skillID, srcPos, dstPos)
    if not (skillID == 1 or skillID == 5 or skillID == 13) then
        return false
    end
    if srcPos.x == dstPos.x and srcPos.y == dstPos.y then
        return false
    end
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if not inputProxy:GetTargetID() then
        return false
    end

    local isMiss = inputProxy:GetTargetID() == global.GameActorSkillController:getHitMissUserID()
    global.GameActorSkillController:resetHitMissUserID()
    return isMiss
end

skillUtils.checkTarget = function(skillID)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)

    local targetID = inputProxy:GetTargetID()
    if nil == targetID then
        return nil, nil
    end

    local targetActor = global.actorManager:GetActor(targetID)
    if nil == targetActor then
        return nil, nil
    end

    -- 是否是增益技能
    if skillID and SkillProxy:IsAdditionSkill(skillID) then
        -- 是友方
        if proxyUtils.checkMemberByID(targetID) then
            return targetID, targetActor
        end
        return nil, nil
    end

    -- 是否可攻击
    if false == proxyUtils.checkLaunchTarget(targetActor) then
        return nil, nil
    end

    return targetID, targetActor
end

-- 检测目标范围群怪
skillUtils.checkTargetNeighbors = function(target, count)
    -- body
    if not target or target:IsDie() or target:IsDeath() then
        return {}
    end

    local neighbors = {}
    local mapX = target:GetMapX()
    local mapY = target:GetMapY()
    local targetID = target:GetID()
    local around = {{1, 0}, {1, 1}, {1, -1}, {-1, 0}, {-1, 1}, {-1, -1}, {0, 1}, {0, -1}, {0, 0}}
    for i, v in ipairs(around) do
        if count and #neighbors >= count then
            break
        end

        if target:IsMonster() then
            local monsters = global.actorManager:GetMonsterActorByMapXY(mapX + v[1], mapY + v[2], true)
            if monsters then
                for i, _mon in ipairs(monsters) do
                    if targetID ~= _mon:GetID() and true == proxyUtils.checkAutoTargetEnableByID(_mon:GetID()) then
                        table.insert(neighbors, _mon)
                    end
                end
            end
        elseif target:IsPlayer() then
            local players = global.actorManager:GetPlayerActorByMapXY(mapX + v[1], mapY + v[2], true)
            if players then
                for i, _player in ipairs(players) do
                    if targetID ~= _player:GetID() and target:GetType() == _player:GetType() and true ==
                        proxyUtils.checkAutoTargetEnableByID(_player:GetID()) then
                        table.insert(neighbors, _player)
                    end
                end
            end
        end
    end

    return neighbors
end

--------------------------- 技能检测 end -------------------------------
-- 自动找目标，只会找可攻击的
skillUtils.findTarget = function()
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local targetID = inputProxy:GetTargetID()

    -- auto select monster
    if not targetID then
        global.Facade:sendNotification(global.NoticeTable.AutoFindPlayer)
        targetID = inputProxy:GetTargetID()
    end

    -- auto select player
    if not targetID then
        local sData = {}
        sData.type = global.MMO.ACTOR_PLAYER
        sData.imgNotice = false
        sData.systemTips = false
        global.Facade:sendNotification(global.NoticeTable.QuickSelectTarget, sData)
    end

    -- found
    if nil == inputProxy:GetTargetID() then
        return nil, nil
    end

    -- 2.check target actor
    local targetActor = global.actorManager:GetActor(inputProxy:GetTargetID())
    if nil == targetActor then
        return nil, nil
    end

    return inputProxy:GetTargetID(), targetActor
end

-- 技能释放位置
skillUtils.findBestLaunchPos = function(skillID, targetID, srcX, srcY, dstX, dstY)
    if not skillID then
        return srcX, srcY, srcX, srcY
    end
    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local minLaunchDis = skillProxy:GetMinDistance(skillID)
    local maxLaunchDis = skillProxy:GetMaxDistance(skillID)

    local launchBestX = srcX
    local launchBestY = srcY
    local moveBestX = srcX
    local moveBestY = srcY
    if skillProxy:IsLineSlopeSkill(skillID) then
        if not (srcX == dstX and srcY == dstY and targetID == nil) then
            launchBestX, launchBestY = inputProxy:FindBestAttackPos(srcX, srcY, dstX, dstY, maxLaunchDis, minLaunchDis)
            moveBestX = launchBestX
            moveBestY = launchBestY
            if skillID == SKILL_ID_CiSha then
            elseif targetID then
                local target = global.actorManager:GetActor(targetID)
                if target and (target:IsPlayer() and target:GetAction() == global.MMO.ACTION_WALK) then
                    local srcPos = cc.p(target:GetMapX(), target:GetMapY())
                    local moveDir = target:GetDirection()
                    local moveStep = 1
                    local destPos = global.PathFindController:FindDestPosJoystick(srcPos, moveDir, moveStep)
                    if destPos then
                        moveBestX, moveBestY = inputProxy:FindBestAttackPos(srcX, srcY, destPos.x, destPos.y,
                            maxLaunchDis, minLaunchDis)
                    end
                end
            end
        end
    else
        launchBestX, launchBestY = inputProxy:FindBestSkillPos(srcX, srcY, dstX, dstY, maxLaunchDis, minLaunchDis)
        moveBestX = launchBestX
        moveBestY = launchBestY

        -- 自动走位多走一步
        if minLaunchDis > 1 and (srcX ~= launchBestX or srcY ~= launchBestY) then
            moveBestX, moveBestY = inputProxy:FindBestSkillPos(srcX, srcY, dstX, dstY, maxLaunchDis, minLaunchDis + 1)
        end
    end
    return launchBestX, launchBestY, moveBestX, moveBestY
end

skillUtils.findRobotLaunchSkill = function()
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayerID or not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    local destPos = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())

    -- 魔法盾
    local skillID = SKILL_ID_MoFaDun
    if skillUtils.checkAbleToAutoLaunch(skillID) then
        return skillID, destPos
    end

    -- 武力盾
    skillID = SKILL_ID_WuLiDun
    if skillUtils.checkAbleToAutoLaunch(skillID) then
        return skillID, destPos
    end

    -- 道力盾
    skillID = SKILL_ID_DaoLiDun
    if skillUtils.checkAbleToAutoLaunch(skillID) then
        return skillID, destPos
    end

    -- 幽灵盾
    skillID = SKILL_ID_YouLingDun
    if skillUtils.checkAbleToAutoLaunch(skillID) then
        return skillID, destPos
    end

    -- 神圣战甲术
    skillID = SKILL_ID_SSZhanJia
    if skillUtils.checkAbleToAutoLaunch(skillID) then
        return skillID, destPos
    end

    -- 自动隐身术
    skillID = SKILL_ID_YinShenShu
    if skillUtils.checkAbleToAutoLaunch(skillID) then
        return skillID, destPos
    end

    -- 自动无极真气
    skillID = SKILL_ID_WuJiZhenQi
    if skillUtils.checkAbleToAutoLaunch(skillID) then
        return skillID, destPos
    end

    -- 自动招怪
    if CHECK_SETTING(global.MMO.SETTING_IDX_AUTO_SUMMON) == 1 then
        local value = GET_SETTING(global.MMO.SETTING_IDX_AUTO_SUMMON)
        local value1 = value[1]
        skillID = value[2]
        if value1 == 1 and skillID then
            local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
            local newAutoSummon = SL:GetMetaValue("SERVER_OPTION", "CallMobSet")
            if newAutoSummon and skillID == -1 then 
                skillID = SummonsProxy:autoSummon()
                if skillID ~= -1 then 
                    return skillID,destPos
                end
            else
                if skillUtils.checkAbleToAutoLaunch(skillID) and SummonsProxy:canSummons(skillID) then
                    return skillID, destPos
                end
            end
        end
    end

    -- 自动治愈术
    if CHECK_SETTING(global.MMO.SETTING_IDX_HP_LOW_USE_SKILL) == 1 then
        local value = GET_SETTING(global.MMO.SETTING_IDX_HP_LOW_USE_SKILL)
        local value2 = value[2]
        skillID = tonumber(value[3])
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        if value2 and tonumber(value2) and skillID and PlayerProperty:GetRoleHPPercent() <= value2 then
            if skillID and skillUtils.checkAbleToAutoLaunch(skillID) then
                return skillID, destPos
            end
        end
    end

    return nil
end

skillUtils.findFirstLaunchSkill = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    local skillID, destPos, stamp = autoProxy:GetLaunchFirstSkill()
    if not skillID then
        return nil
    end

    local skillProxy   = global.Facade:retrieveProxy( global.ProxyTable.Skill )
    if not (skillProxy:CheckAbleToLaunch(skillID) == 1) then
        return nil
    end

    autoProxy:ClearLaunchFirstSkill()

    if stamp and GetServerTime() - stamp > 2 then
        return nil
    end

    return skillID, destPos
end

-- 闪避
skillUtils.findAvoidDangerSkill = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    if mainPlayer:GetJobID() == global.MMO.ACTOR_PLAYER_JOB_FIGHTER then
        return nil
    end

    -- 未开启自动走位
    if CHECK_SETTING(global.MMO.SETTING_IDX_AUTO_MOVE) ~= 1 then
        return nil
    end

    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    local avoidStamp = autoProxy:GetLaunchAvoidStamp()
    if GetServerTime() - avoidStamp < 3 then
        return nil
    end

    -- 检测躲避怪
    local around = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}}
    local pMapX = mainPlayer:GetMapX()
    local pMapY = mainPlayer:GetMapY()
    local avoidMonster = false
    for i, v in ipairs(around) do
        local monsters = global.actorManager:GetMonsterActorByMapXY(pMapX + v[1], pMapY + v[2], true)
        if monsters then
            for k, mon in pairs(monsters) do
                if proxyUtils.checkAutoTargetEnableByID(mon:GetID()) then
                    avoidMonster = true
                    break
                end
            end
            if avoidMonster then
                break
            end
        end
    end

    if not avoidMonster then
        return nil
    end

    -- 抗拒火环    地图雷光     隐身术
    local skillProxy    = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local autoMoveSkills = {SKILL_ID_KJHuoHuan, SKILL_ID_DYLeiGuang, SKILL_ID_YinShenShu}
    local launchSkill = nil
    for i, _skill in ipairs(autoMoveSkills) do
        local priority  = skillProxy:GetPriorityBySkillID(_skill)
        if priority > 0 and skillUtils.checkSkillLaunch(_skill) then
            launchSkill = _skill
            break
        end
    end

    return launchSkill, launchSkill and cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY()) or nil
end

-- 内挂自动技能
skillUtils.findAutoSettingLaunchSkill = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local targetID = inputProxy:GetTargetID()
    if not targetID then
        return nil
    end

    local target = global.actorManager:GetActor(targetID)
    if not target then
        return nil
    end

    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local distance = nil
    if target then
        distance = inputProxy:calcMapDistance(cc.p(target:GetMapX(), target:GetMapY()),
            cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY()))
    end

    local isGeWei = false
    if CHECK_SETTING(global.MMO.SETTING_IDX_MOVE_GEWEI_CISHA) == 1 or CHECK_SETTING(global.MMO.SETTING_IDX_GEWEICISHA) == 1 then
        isGeWei = true
    end

    -- 内挂技能
    --刺杀12  烈火剑法26  半月25  开天斩66  逐日56     双龙斩40  龙影剑法42  雷霆剑法43  纵横剑术81 
    --施毒6   火墙22  寒冰掌44   噬血术57   裂神符85   死亡之眼86  冰镰术83  火焰冰36   冰霜群雨84
    --自动连击
    local skillID = nil
    local destPos = nil
    local skillIDT = nil
    local destPosT = nil
    local priority = 0
    local priorityT = nil

    -- 自定义技能
    local skillCount = #SETTING_SKILL
    local settingCustomSkills = {}
    local customSkill = skillProxy:GetAllCustomSkill()
    for k, v in pairs(customSkill) do
        local priority = skillProxy:GetLocalPriorityBySkillID(v)
        if priority > 0 and skillUtils.checkAutoSetting(v) then
            skillCount = skillCount + 1
            settingCustomSkills[skillCount] = v
        end
    end

    for i = 1, skillCount, 1 do
        local id = SETTING_SKILL[i] or settingCustomSkills[i]
        priority = skillProxy:GetLocalPriorityBySkillID(id)
        if not priorityT or (priority > priorityT) then
            skillIDT, destPosT = skillUtils.checkAbleToAutoLaunch(id, target)
            if skillIDT then
                if skillIDT == SKILL_ID_LieHuo and CHECK_SETTING(global.MMO.SETTING_IDX_NEAR_LIEHUO) ~= 1 then
                    if 2 == distance and skillUtils.checkAbleToAutoLaunch(SKILL_ID_CiSha, target) then
                        skillIDT = nil
                    end
                end
                priorityT   = priority
                skillID     = skillIDT
                destPos     = destPosT
            end
        end
    end

    return skillID, destPos or cc.p(target:GetMapX(), target:GetMapY())
end

-- 自动释放技能
skillUtils.findAutoLaunchSkill = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local targetID = inputProxy:GetTargetID()
    if not targetID then
        return nil
    end

    local target = global.actorManager:GetActor(targetID)
    if not target then
        inputProxy:ClearTarget()
        return nil
    end

    local targetdestPos   = cc.p(target:GetMapX(), target:GetMapY())
    -- 自动连击
    local destPos = nil
    local skillID,destPos = skillUtils.findAutoComboLaunchSkill()
    if skillID then
        return skillID, destPos or targetdestPos or inputProxy:getCursorMapPosition()
    end

    skillID,destPos = skillUtils.findRobotLaunchSkill()
    if skillID then
        return skillID, destPos or inputProxy:getCursorMapPosition()
    end

    local srcPos = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    -- 施毒术
    skillID,destPos = skillUtils.checkAbleToAutoLaunch(global.MMO.SKILL_INDEX_SDS, target)
    if skillID and not skillUtils.checkSkillBlocked(skillID, srcPos, destPos) then
        return skillID, destPos or inputProxy:getCursorMapPosition()
    end

    -- 火墙
    skillID,destPos = skillUtils.checkAbleToAutoLaunch(SKILL_ID_HuoQiang, target)
    if skillID and not skillUtils.checkSkillBlocked(skillID, srcPos, destPos) then
        return skillID, destPos or inputProxy:getCursorMapPosition()
    end

    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    -- 内挂 群、单体技能
    local neighbors = skillUtils.checkTargetNeighbors(target, 1)
    local isSample = not neighbors[1]
    local settingID = isSample and global.MMO.SETTING_IDX_AUTO_SIMPSKILL or global.MMO.SETTING_IDX_AUTO_GROUPSKILL
    local optionValue = GameSettingProxy:getRankData(settingID)
    local sttingSkills = optionValue.indexs or {}

    local isBlocked = false
    -- 单群体技能检测
    local isNeighbors = false
    local destPosT = nil
    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    for k, _skillid in ipairs(sttingSkills) do
        if not isNeighbors and skillProxy:IsLearned(_skillid) then --职业变更后内挂的单群体技能还没改变的情况
            isNeighbors = true
        end

        local isNotCheckSetting = _skillid == SKILL_ID_YinShenShu
        skillID,destPosT = skillUtils.checkSkillLaunch(_skillid, target, isNotCheckSetting)
        if skillID then
            destPos = destPosT
            if not isBlocked and skillUtils.checkSkillBlocked(skillID, srcPos, targetdestPos) then
                isBlocked = true
            end
            break
        end
    end

    if skillID then
        return skillID, destPos or targetdestPos or inputProxy:getCursorMapPosition()
    end

    -- 单群体施法检测开关
    local isSkillSN = tonumber(global.ConstantConfig.check_skill_neighbors) == 1
    if not isSkillSN then
        sttingSkills = {}
    end

    -- 自动战斗检测先检测内挂技能， 然后再检测其它技能
    local ngSkillPriority = 0
    local checkAutoNGLauncher = function(skillID, priority)
        if SETTING_SKILL[skillID] then
            return priority > ngSkillPriority, true
        end
        if skillID and skillID > 1000 then
            local settingID = 10000 + skillID
            local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
            if GameSettingProxy:GetConfigByID(settingID) then
                return priority > ngSkillPriority, true
            end
        end

        if ngSkillPriority == 0 then
            return true, false
        end
        return false, false
    end

    skillID,destPos = skillUtils.findAutoSettingLaunchSkill()
    if skillID then
        return skillID, destPos or targetdestPos or inputProxy:getCursorMapPosition()
    end

    local skills = isNeighbors and {} or skillProxy:GetSkills(true)
    local priorityT = 0
    local skillIDT = nil
    local distance = nil
    if target then
        distance = inputProxy:calcMapDistance(cc.p(target:GetMapX(), target:GetMapY()),
            cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY()))
    end
    local isGeWei = CHECK_SETTING(global.MMO.SETTING_IDX_MOVE_GEWEI_CISHA) == 1 or
                        CHECK_SETTING(global.MMO.SETTING_IDX_GEWEICISHA) == 1
    
    local skillSNCount     = 0                    
    local skillSNPriorityT = 0
    local skillSNSkillT = nil
    local ignoreSkills = {[SKILL_ID_BanYue]=true, [SKILL_ID_ShuangLongZhan] = true, [SKILL_ID_CiSha]=true, [SKILL_ID_LieHuo]=true}
    for k, v in pairs(skills) do
        if not sttingSkills[v.MagicID] and not ignoreSkills[v.MagicID] then
            local priority = skillProxy:GetPriorityBySkillID(v.MagicID)
            local config = skillProxy:FindConfigBySkillID(v.MagicID)
            local isCheckSkillSN = false
            local isLuanch = not (config and config.skilltype == 4 or false)
            if isSkillSN and config then
                if isSample and 1 == config.skilltype then
                    if priority > 0 then
                        skillSNCount = skillSNCount + 1
                    end
                    isCheckSkillSN = true
                elseif not isSample and 2 == config.skilltype then
                    if priority > 0 then
                        skillSNCount = skillSNCount + 1
                    end
                    isCheckSkillSN = true
                end
            end

            local isMarkNGProiority = false
            isLuanch,isMarkNGProiority = isLuanch and checkAutoNGLauncher(v.MagicID, priority)
            if isMarkNGProiority then
                priority = (priorityT or 0) + priority
            end

            if isLuanch and priority > 0 and ((skillSNCount == 0 and priority > priorityT) or (skillSNCount > 0 and priority > skillSNPriorityT)) then
                skillIDT,destPosT = skillUtils.checkAbleToAutoLaunch(v.MagicID, target)
                if skillIDT then
                    if not isBlocked and skillUtils.checkSkillBlocked(skillIDT, srcPos, targetdestPos) then
                        isBlocked = true
                    end

                    if isCheckSkillSN then
                        skillSNSkillT = skillIDT
                        skillSNPriorityT = priority
                    end

                    if isMarkNGProiority then
                        ngSkillPriority = priority - (priorityT or 0)
                    end

                    skillID = skillIDT
                    priorityT = priority 
                    destPos = destPosT
                end
            end
        end
    end

    if skillSNCount > 0 then
        skillID = skillSNSkillT
    end

    if (not skillID or isBlocked) and skillProxy:CheckAbleToLaunch(0) == 1 then
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local roleJob = PlayerProperty:GetRoleJob()
        if roleJob == global.MMO.ACTOR_PLAYER_JOB_FIGHTER then
            skillID = 0
        elseif roleJob == global.MMO.ACTOR_PLAYER_JOB_WIZZARD then
            local skills = not isBlocked and skillProxy:GetSkills(true, true, true) or {}
            if CHECK_SETTING(global.MMO.SETTING_IDX_SKILL_NEXT_ATTACK) == 1 or isBlocked or not next(skills) then
                skillID = 0
            end
        elseif roleJob == global.MMO.ACTOR_PLAYER_JOB_TAOIST then
            local skills = not isBlocked and skillProxy:GetSkills(true, true, true) or {}
            if CHECK_SETTING(global.MMO.SETTING_IDX_SKILL_NEXT_ATTACK) == 1 or isBlocked or not next(skills) then
                skillID = 0
            end
        else
            local skillSNCount     = 0                    
            local skillSNPriorityT = 0
            local skillSNSkillT = nil
            for k, v in pairs(skills) do
                if not sttingSkills[v.MagicID] and not ignoreSkills[v.MagicID] then
                    local priority = skillProxy:GetPriorityBySkillID(v.MagicID)
                    local config = skillProxy:FindConfigBySkillID(v.MagicID)
                    local isCheckSkillSN = false
                    local isLaunch = not (config and config.skilltype == 4 or false)
                    if isSkillSN and config then
                        if isSample and 1 == config.skilltype then
                            if priority > 0 then
                                skillSNCount = skillSNCount + 1
                            end
                            isCheckSkillSN = true
                        elseif not isSample and 2 == config.skilltype then
                            if priority > 0 then
                                skillSNCount = skillSNCount + 1
                            end
                            isCheckSkillSN = true
                        end
                    end
        
                    if isLaunch and priority > 0 and ((skillSNCount == 0 and priority > priorityT) or (skillSNCount > 0 and priority > skillSNPriorityT)) then
                        skillIDT,destPosT = skillUtils.checkAbleToAutoLaunch(v.MagicID, target, config and config.job == roleJob or false)
                        if skillIDT then
                            if not isBlocked and skillUtils.checkSkillBlocked(skillIDT, srcPos, targetdestPos) then
                                isBlocked = true
                            end
        
                            if isCheckSkillSN then
                                skillSNSkillT = skillIDT
                                skillSNPriorityT = priority
                            end
        
                            skillID = skillIDT
                            priorityT = priority 
                            destPos = destPosT
                        end
                    end
                end
            end

            if skillSNCount > 0 then
                skillID = skillSNSkillT
            end

            if not skillID then
                skillID = SKILL_ID_PuGong
            end
        end
    end

    if not skillID or skillID == SKILL_ID_PuGong then
        local newSkillID, newDestPos = skillUtils.findAttackExLaunchSkill()
        if newSkillID then
            skillID = newSkillID
            destPos = newDestPos
        end
    end

    return skillID, destPos or targetdestPos or inputProxy:getCursorMapPosition()
end

-- 闪避走位
skillUtils.findAvoidDangerPos = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    -- 战士不生效
    if mainPlayer:GetJobID() == global.MMO.ACTOR_PLAYER_JOB_FIGHTER then
        return nil
    end

    -- 未开启自动走位
    if CHECK_SETTING(global.MMO.SETTING_IDX_AUTO_MOVE) ~= 1 then
        return nil
    end

    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return nil
    end

    local matrixAround = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}}

    local pMapX = mainPlayer:GetMapX()
    local pMapY = mainPlayer:GetMapY()
    local mMapX = 0
    local mMapY = 0
    local monsterMatrix = {}
    for i, v in ipairs(matrixAround) do
        local monsters = global.actorManager:GetMonsterActorByMapXY(pMapX + v[1], pMapY + v[2], true)
        if monsters then
            for k, mon in pairs(monsters) do
                if proxyUtils.checkAutoTargetEnableByID(mon:GetID()) then
                    mMapX = mon:GetMapX()
                    mMapY = mon:GetMapY()
                    monsterMatrix[mMapX] = monsterMatrix[mMapX] or {}
                    monsterMatrix[mMapX][mMapY] = mon
                end
            end
        end
    end

    if not next(monsterMatrix) then
        return nil
    end

    local mapRows = mapData:getMapDataRows()
    local mapCols = mapData:getMapDataCols()
    local around = {{pMapX + 1, pMapY}, -- right
    {pMapX, pMapY + 1}, -- bottom
    {pMapX - 1, pMapY}, -- left
    {pMapX, pMapY - 1}, -- top
    {pMapX + 1, pMapY - 1}, -- right up    
    {pMapX + 1, pMapY + 1}, -- right bottom
    {pMapX - 1, pMapY + 1}, -- left bottom
    {pMapX - 1, pMapY - 1} -- left top    
    }

    local avoidDangerPos = nil
    for _, p in ipairs(around) do
        if p[1] < 0 or p[1] >= mapCols or p[2] < 0 or p[2] >= mapRows then
        elseif mapData:isObstacle(p[1], p[2]) == 1 then
        elseif monsterMatrix[p[1]] and monsterMatrix[p[1]][p[2]] then
        else
            avoidDangerPos = cc.p(p[1], p[2])
            break
        end
    end

    return avoidDangerPos
end

-- 自动连击
skillUtils.findAutoComboLaunchSkill = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local isAttackState = global.isWinPlayMode and inputProxy:IsAttackState() or false
    if not isAttackState and not autoProxy:IsAutoLockState() and not autoProxy:IsAFKState() and not autoProxy:IsAutoFightState() then
        return nil
    end

    if tonumber(SL:GetMetaValue("GAME_DATA", "OpenNGUI")) ~= 1 then
        return nil
    end

    if CHECK_SETTING(global.MMO.SETTING_IDX_AUTO_COMBO) ~= 1 then
        return nil
    end

    local targetID = inputProxy:GetTargetID()
    if nil == targetID then
        return nil
    end

    local target = global.actorManager:GetActor(targetID)
    if not target then
        return nil
    end

    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    if not skillProxy:GetlaunchComboStatus() then
        return nil
    end

    local setComboSkill = skillProxy:haveSetComboSkill()
    local skillID = setComboSkill and setComboSkill[1]
    if not skillID then
        return nil
    end

    local destPos = nil
    skillID, destPos = skillUtils.checkAbleToAutoLaunch(skillID, target)
    return skillID, destPos or inputProxy:getCursorMapPosition()
end

-- 连击技能
skillUtils.findComboLaunchSkill = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local skillID = skillProxy:GetComboLanunchID()
    local destPos = nil
    local isAuto = false
    if not skillID then
        skillID, destPos = skillUtils.findAutoComboLaunchSkill()
        isAuto = skillID and true or false
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    return skillID, destPos or inputProxy:getCursorMapPosition(), isAuto
end

-- 自定义技能
skillUtils.findAutoCustomLaunchSkill = function(priority)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local targetID = inputProxy:GetTargetID()
    if not targetID then
        return nil
    end

    local target = global.actorManager:GetActor(targetID)
    if not target then
        return nil
    end

    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)

    local isProiority = CHECK_SETTING(global.MMO.SETTING_IDX_ALWAYS_ATTACK) == 1 or global.isWinPlayMode
    local priorityT = priority or 0
    local skillID = nil
    local destPos = nil
    local skillIDT = nil
    local destPosT = nil
    local customSkill = skillProxy:GetAllCustomSkill()
    for k, v in pairs(customSkill) do
        skillIDT, destPosT = skillUtils.checkSkillLaunch(v, target)
        if skillIDT then
            if not isProiority then
                break
            end

            local priority = skillProxy:GetLocalPriorityBySkillID(v)
            if not priorityT or priority > priorityT then
                priorityT = priority
                skillID, destPos = skillIDT, destPosT
            end

        end
    end

    if skillID then
        return skillID, destPos or inputProxy:getCursorMapPosition()
    end

    return nil
end

-- 锁定释放技能
skillUtils.findLockLaunchSkill = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local targetID = inputProxy:GetTargetID()
    if not targetID then
        return nil
    end

    local target = global.actorManager:GetActor(targetID)
    if not target then
        return nil
    end

    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local distance = nil
    if target then
        distance = inputProxy:calcMapDistance(cc.p(target:GetMapX(), target:GetMapY()),
            cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY()))
    end
    local isGeWei = CHECK_SETTING(global.MMO.SETTING_IDX_MOVE_GEWEI_CISHA) == 1 or
                        CHECK_SETTING(global.MMO.SETTING_IDX_GEWEICISHA) == 1

    -- 逐日 56  开天 66 烈火 26  刺杀 12  双龙斩 40  半月 25   攻杀 7  纵横剑术 81  龙影剑法 42 雷霆剑法 43  血魄一击(战) 115  刺杀 12 普攻 0  
    local skills = {
            SKILL_ID_ZhuRi, 
            SKILL_ID_KaiTian, 
            SKILL_ID_LieHuo,
            SKILL_ID_ShuangLongZhan,
            SKILL_ID_BanYue, 
            SKILL_ID_ZHJianShu, 
            SKILL_ID_LYJianFa,
            SKILL_ID_LTJianFa,
            SKILL_ID_XPYiJi,
            SKILL_ID_CiSha,
    }
    local priorityT = nil
    local skillID = nil
    local destPos = nil
    local skillIDT = nil
    local destPosT = nil
    for i, id in ipairs(skills) do
        local priority = skillProxy:GetLocalPriorityBySkillID(id)
        if not skillID and id == SKILL_ID_PuGong then
            priorityT = nil
        end
        if not priorityT or (priority > priorityT) or (isGeWei and id == SKILL_ID_CiSha and CHECK_SETTING(global.MMO.SETTING_IDX_DAODAOCISHA) == 1) then
            skillIDT, destPosT = skillUtils.checkAbleToAutoLaunch(id, target)
            if skillIDT then
                if skillIDT == SKILL_ID_CiSha then -- 刺杀位
                    if 2 == distance and skillID and (skillID ~= SKILL_ID_LieHuo or CHECK_SETTING(global.MMO.SETTING_IDX_NEAR_LIEHUO) == 1) then
                        break
                    end
                    if 2 ~= distance and skillID and priorityT and priority < priorityT then
                        break
                    end
                end
                priorityT   = priority
                skillID     = skillIDT
                destPos     = destPosT
            end
        end
    end

    -- 攻杀处理
    if 1 == distance and skillID == SKILL_ID_CiSha and skillProxy:IsLockTargetSkill(SKILL_ID_GongSha, true) then
        local srcPos = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
        local distance = inputProxy:calcMapDistance(cc.p(target:GetMapX(), target:GetMapY()), srcPos)
        local newSkillID, newDestPos = skillUtils.checkSkillLaunch(SKILL_ID_GongSha, target)
        if newSkillID then
            skillID, destPos = newSkillID, newDestPos
        end
    end

    local newSkillID, newDestPos = skillUtils.findAutoCustomLaunchSkill(priorityT)
    if newSkillID then
        skillID = newSkillID
        destPos = newDestPos
    end

    if not skillID and skillUtils.checkSkillLaunch(SKILL_ID_GongSha) then
        skillID = SKILL_ID_GongSha
    end

    if not skillID and skillUtils.checkSkillLaunch(SKILL_ID_PuGong) then
        skillID = SKILL_ID_PuGong
    end

    return skillID, destPos or inputProxy:getCursorMapPosition()
end

skillUtils.findSimpleLaunchSkill = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    -- 自动连击
    local skillID, destPos = skillUtils.findAutoComboLaunchSkill()
    if skillID then
        return skillID, destPos
    end

    -- 自动释放技能
    skillID, destPos = skillUtils.findRobotLaunchSkill()
    if skillID then
        return skillID, destPos
    end

    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    skillID         = autoProxy:GetAutoLockSkillID()
    if not skillID then
        return nil
    end

    -- 普攻
    skillID, destPos = skillUtils.findAutoSettingLaunchSkill()

    if not skillID then
        skillID, destPos = skillUtils.findAutoCustomLaunchSkill()
    end

    if skillID then
        return skillID, destPos
    end

    skillID, destPos = skillUtils.findAttackExLaunchSkill()
    if skillID then
        return skillID, destPos
    end

    skillID = autoProxy:GetAutoLockSkillID()

    if skillID == SKILL_ID_PuGong and skillUtils.checkSkillLaunch(SKILL_ID_GongSha) then
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        return SKILL_ID_GongSha, inputProxy:getCursorMapPosition()
    end

    if skillID and skillUtils.checkSkillLaunch(skillID) then
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        return skillID, inputProxy:getCursorMapPosition()
    end

    local isPugong  = CHECK_SETTING(global.MMO.SETTING_IDX_SKILL_NEXT_ATTACK) == 1
    if isPugong and skillUtils.checkSkillLaunch(SKILL_ID_PuGong) then
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        return SKILL_ID_PuGong, inputProxy:getCursorMapPosition()
    end
    return nil
end

skillUtils.findAttackExLaunchSkill = function(target)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local targetID = inputProxy:GetTargetID()
    local target = nil
    if targetID then
        target = global.actorManager:GetActor(targetID)
    end
    
    -- 半月
    local skillID, destPos = skillUtils.checkAbleToAutoLaunch(SKILL_ID_BanYue, target)
    if not skillID then
        skillID, destPos = skillUtils.checkAbleToAutoLaunch(SKILL_ID_ShuangLongZhan, target)
    end

    if not skillID then
        skillID, destPos = skillUtils.checkAbleToAutoLaunch(SKILL_ID_CiSha)

        local distance = nil
        if target then
            distance = inputProxy:calcMapDistance(cc.p(target:GetMapX(), target:GetMapY()),
                cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY()))
        end
        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        -- 攻杀处理
        if 1 == distance and skillID == SKILL_ID_CiSha and skillProxy:IsLockTargetSkill(SKILL_ID_GongSha, true) then
            local srcPos = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
            local distance = inputProxy:calcMapDistance(cc.p(target:GetMapX(), target:GetMapY()), srcPos)
            local newSkillID, newDestPos = skillUtils.checkSkillLaunch(SKILL_ID_GongSha, target)
            if newSkillID then
                skillID, destPos = newSkillID, newDestPos
            end
        end
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    return skillID, destPos or inputProxy:getCursorMapPosition()
end

skillUtils.findAttackLaunchSkill = function()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer or mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return nil
    end

    -- 刺杀
    local skillID, destPos = skillUtils.checkSkillLaunch(SKILL_ID_CiSha)
    if not skillID then
        -- 普攻
        skillID, destPos = skillUtils.checkSkillLaunch(SKILL_ID_PuGong)
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    return skillID, destPos or inputProxy:getCursorMapPosition()
end

-- 技能优先级检测
skillUtils.findSkills = function(skilltype, filterJob, filterLearned, noBasic)
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local roleJob = PlayerProperty:GetRoleJob()
    local allSkills = SkillProxy:FindAllSkillsByJob(filterJob)
    local items = {}
    for i, v in ipairs(allSkills) do
        if (v.MagicID ~= 0 or not noBasic) and (skilltype == -1 or v.skilltype == skilltype) and
            (filterJob == 3 or roleJob == filterJob) then
            if (not filterLearned or (SkillProxy:IsLearned(v.MagicID) and not SkillProxy:IsComboSkill(v.MagicID))) then
                items[v.MagicID] = v
            end
        end
    end
    return items
end

return skillUtils
