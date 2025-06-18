local RobotHeroMediator = class('RobotHeroMediator', framework.Mediator)
RobotHeroMediator.NAME  = "RobotHeroMediator"

local cjson         = require( "cjson" )
local proxyUtils    = requireProxy( "proxyUtils" )
local skillUtils    = requireProxy( "skillUtils" )

RobotHeroMediator.TIMER_INTERVAL = 0.1

function RobotHeroMediator:ctor()
    RobotHeroMediator.super.ctor( self, self.NAME )

    self._items                 = {}
    self._cdingTime             = {}

    self._cdingTime[51]         = 0

    self._launchTime            = 0
    self._trainingTime          = 0
    self._loginHeroDelayTime   = 1--召唤英雄的间隔
    self._loginHeroTime = 0--

    self._loginOutHeroDelayTime   = 1--收回英雄的间隔
    self._loginOutHeroTime = 0--
    
    self._cantips = {}
    self._cantips[3004] = true
    self._cantips[3005] = true
    self._cantips[3006] = true

    self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT1] = 0 
    self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT2] = 0
    self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT3] = 0 
    self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT4] = 0

    self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT1] = 0 
    self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT2] = 0
    self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT3] = 0 
    self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT4] = 0
end

function RobotHeroMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.PlayerPropertyInited,
        noticeTable.HeroBag_Oper_Data,
        noticeTable.PlayerManaChange_Hero
    }
end


function RobotHeroMediator:handleNotification(notification)
    local noticeID = notification:getName()
    local notices  = global.NoticeTable
    local data     = notification:getBody()

    if notices.PlayerPropertyInited == noticeID then
        self:Init()

    elseif notices.HeroBag_Oper_Data == noticeID then
        self:OnBagOperData(data)
    elseif notices.PlayerManaChange_Hero == noticeID then
        self:OnHeroBeAttacked()
    end
end
function RobotHeroMediator:OnHeroBeAttacked()
    -----------------------------残血收回
    if not self._PlayerPropertyProxy:getIsMakeHero() then
        return
    end
    if not self._HeroPropertyProxy:HeroIsLogin() then
        return
    end
    local value =  GET_SETTING(global.MMO.SETTING_IDX_HERO_AUTO_LOGINOUT, true)
    local enable    = value[1] == 1 
    if not enable then 
        return 
    end

    -- 人物或英雄可以复活时，不自动使用回城卷，随机卷，自动召回，不能复活时才自动使用
    if CHECK_SETTING(global.MMO.SETTING_IDX_REVIVE_PROTECT_HERO) == 1 and self._HeroPropertyProxy:IsCanRevive() then
        return
    end

    local p = (value[2] or 50)/100
    local HeroPropertyProxy = self._HeroPropertyProxy
    local curHp = HeroPropertyProxy:GetRoleCurrHP() or 1
    local maxHp = HeroPropertyProxy:GetRoleMaxHP() or 1
    local percent = curHp / maxHp
    if self._loginOutHeroTime >= self._loginOutHeroDelayTime and percent < p and percent >= 0 then
        self._loginOutHeroTime = 0
        self._HeroPropertyProxy:RequestHeroInOrOut()
    end
------------------------------
end
function RobotHeroMediator:OnBagOperData(data)
    if data.opera == global.MMO.Operator_Sub and data.operID and data.operID[1].item then
        proxyUtils.unpackDrugByIndex_Hero(data.operID[1].item.Index)
    end
end



function RobotHeroMediator:Init()
    local facade                = global.Facade
    self._HeroPropertyProxy     = facade:retrieveProxy( global.ProxyTable.HeroPropertyProxy )
    self._PlayerPropertyProxy   = facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    self._mapProxy              = facade:retrieveProxy( global.ProxyTable.Map )
    self._HeroEquipProxy            = facade:retrieveProxy( global.ProxyTable.HeroEquipProxy )
    self._itemUseProxy          = facade:retrieveProxy( global.ProxyTable.ItemUseProxy )
    self._bagProxy              = facade:retrieveProxy( global.ProxyTable.HeroBagProxy )
    self._autoProxy             = facade:retrieveProxy( global.ProxyTable.Auto )
    self._itemConfigProxy       = facade:retrieveProxy( global.ProxyTable.ItemConfigProxy )
    self._role                  = global.gamePlayerController:GetMainPlayer()
    -- 药品
    self._items[51]             = SL:GetMetaValue("GAME_DATA","fixItemDrug")
    self:TimerBegan()
end

function RobotHeroMediator:TimerBegan()
    if not self._timerID then
        local function callback( delta )
            self:Tick( delta )
        end
        self._timerID = Schedule( callback, self.TIMER_INTERVAL )
    end
end

function RobotHeroMediator:TimerEnded()
    if self._timerID then
        UnSchedule( self._timerID )
        self._timerID = nil
    end
end

function RobotHeroMediator:Tick( delta )
    -- 摆摊
    if false == CheckCanDoSomething(true) then
        return nil
    end
    
    if not self._HeroPropertyProxy:IsHeroOpen() then
        return nil
    end


    --自动召唤
    self:autoLogin(delta)

    --自动收回
    self:autoLoginOut(delta)--改成被攻击触发

    -- 自动释放相关
    self:autoLaunch(delta)

    -- -- 自动练功
    -- self:autoTraining(delta)

    -- -- 自动使用修复神水
    self:autoUseFIXItem(delta)

    --hp保护
    self:autoHpProtect(delta)

    --mp保护
    self:autoMpProtect(delta)

end
function RobotHeroMediator:autoMpProtect(delta)
    if not self._mapProxy then
        return nil
    end
    local hp     = self._HeroPropertyProxy:GetRoleCurrHP()
    if hp == 0 then
        return
    end

    self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT1] = self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT1] - delta
    self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT2] = self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT2] - delta
    self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT3] = self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT3] - delta
    self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT4] = self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT4] - delta

    -- 自动吃药相关
    local mppercent     = self._HeroPropertyProxy:GetRoleMPPercent()
    local maxMP         = self._HeroPropertyProxy:GetRoleMaxMP()
    -- mp保护1
    if self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT1] <= 0 then
        local value     = GET_SETTING(global.MMO.SETTING_IDX_HERO_MP_PROTECT1, true)
        local enable    = value[1] == 1
        local percent   = value[2] or 50
        if enable and maxMP > 0 and mppercent <= percent then
            local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
            local protectData =  GameSettingProxy:getRankData(global.MMO.SETTING_IDX_HERO_MP_PROTECT1)
            local used        = self:autoUseItem(protectData.indexs)
            if used then 
                self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT1] = (protectData.time or 1000)/1000
            end
        end
    end
    -- mp保护2
    if self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT2] <= 0  then
        local value     = GET_SETTING(global.MMO.SETTING_IDX_HERO_MP_PROTECT2, true)
        local enable    = value[1] == 1
        local percent   = value[2] or 50
        if enable and maxMP > 0 and mppercent <= percent then
            local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
            local protectData =  GameSettingProxy:getRankData(global.MMO.SETTING_IDX_HERO_MP_PROTECT2)
            local used        = self:autoUseItem(protectData.indexs)
            if used then 
                self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT2] = (protectData.time or 1000)/1000
            end
        end
    end
    -- mp保护3
    if self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT3] <= 0  then
        local value     = GET_SETTING(global.MMO.SETTING_IDX_HERO_MP_PROTECT3, true)
        local enable    = value[1] == 1
        local percent   = value[2] or 50
        if enable and maxMP > 0 and mppercent <= percent then
            local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
            local protectData =  GameSettingProxy:getRankData(global.MMO.SETTING_IDX_HERO_MP_PROTECT3)
            local used        = self:autoUseItem(protectData.indexs)
            if used then 
                self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT3] = (protectData.time or 1000)/1000
            end
        end
    end
    -- mp保护4
    if self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT4] <= 0  then
        local value     = GET_SETTING(global.MMO.SETTING_IDX_HERO_MP_PROTECT4, true)
        local enable    = value[1] == 1
        local percent   = value[2] or 50
        if enable and maxMP > 0 and mppercent <= percent then
            local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
            local protectData =  GameSettingProxy:getRankData(global.MMO.SETTING_IDX_HERO_MP_PROTECT4)
            local used        = self:autoUseItem(protectData.indexs)
            if used then 
                self._cdingTime[global.MMO.SETTING_IDX_HERO_MP_PROTECT4] = (protectData.time or 1000)/1000
            end
        end
    end

end

function RobotHeroMediator:autoHpProtect(delta)
    if not self._mapProxy then
        return nil
    end
    -- dead
    local hp     = self._HeroPropertyProxy:GetRoleCurrHP()
    if hp == 0 then
        return
    end

    self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT1] = self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT1] - delta
    self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT2] = self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT2] - delta
    self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT3] = self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT3] - delta
    self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT4] = self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT4] - delta
    -- 自动吃药相关
    local hppercent     = self._HeroPropertyProxy:GetRoleHPPercent()
    local maxHP         = self._HeroPropertyProxy:GetRoleMaxHP()
    
    -- hp保护1
    if self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT1] <= 0 then
        local value     = GET_SETTING(global.MMO.SETTING_IDX_HERO_HP_PROTECT1, true)
        local enable    = value[1] == 1
        local percent   = value[2] or 50
        if enable and maxHP > 0 and hppercent <= percent then
            local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
            local protectData =  GameSettingProxy:getRankData(global.MMO.SETTING_IDX_HERO_HP_PROTECT1)
            local used        = self:autoUseItem(protectData.indexs, true)
            if used then 
                self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT1] = (protectData.time or 1000)/1000
            end
        end
    end
    -- hp保护2
    if self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT2] <= 0  then
        local value     = GET_SETTING(global.MMO.SETTING_IDX_HERO_HP_PROTECT2, true)
        local enable    = value[1] == 1
        local percent   = value[2] or 50
        if enable and maxHP > 0 and hppercent <= percent then
            local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
            local protectData =  GameSettingProxy:getRankData(global.MMO.SETTING_IDX_HERO_HP_PROTECT2)
            local used        = self:autoUseItem(protectData.indexs, true)
            if used then 
                self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT2] = (protectData.time or 1000)/1000
            end
        end
    end
    -- hp保护3
    if self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT3] <= 0  then
        local value     = GET_SETTING(global.MMO.SETTING_IDX_HERO_HP_PROTECT3, true)
        local enable    = value[1] == 1
        local percent   = value[2] or 50
        if enable and maxHP > 0 and hppercent <= percent then
            local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
            local protectData =  GameSettingProxy:getRankData(global.MMO.SETTING_IDX_HERO_HP_PROTECT3)
            local used        = self:autoUseItem(protectData.indexs, true)
            if used then 
                self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT3] = (protectData.time or 1000)/1000
            end
        end
    end
    -- hp保护4
    if self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT4] <= 0  then
        local value     = GET_SETTING(global.MMO.SETTING_IDX_HERO_HP_PROTECT4, true)
        local enable    = value[1] == 1
        local percent   = value[2] or 50
        if enable and maxHP > 0 and hppercent <= percent then
            local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
            local protectData =  GameSettingProxy:getRankData(global.MMO.SETTING_IDX_HERO_HP_PROTECT4)
            local used        = self:autoUseItem(protectData.indexs, true)
            if used then 
                self._cdingTime[global.MMO.SETTING_IDX_HERO_HP_PROTECT4] = (protectData.time or 1000)/1000
            end
        end
    end
end
-------------------------自动召唤
function RobotHeroMediator:autoLogin(delay)
    if not self._PlayerPropertyProxy:getIsMakeHero() then
        return
    end
    if  self._HeroPropertyProxy:HeroIsLogin() then
        return
    end
    if CHECK_SETTING(global.MMO.SETTING_IDX_HERO_AUTO_LOGIN) == 0 then
        return 
    end
    if self._loginHeroTime >= self._loginHeroDelayTime and self._HeroPropertyProxy:getCD() == 0 then
        self._loginHeroTime = 0
        self._HeroPropertyProxy:RequestHeroInOrOut()
    else
        self._loginHeroTime = self._loginHeroTime + delay
    end
    
    
end
-----------------------
-- 修复神水
function RobotHeroMediator:autoUseFIXItem( delta )
    if not self._mapProxy then
        return nil
    end
    if self._role:IsDie() then
        return nil
    end
    if not self._PlayerPropertyProxy:getIsMakeHero() then
        return
    end
    if  not self._HeroPropertyProxy:HeroIsLogin() then
        return
    end
    local function isInvalidEquip(item)
        -- 祝福罐
        if item.StdMode == 96 then
            return true
        end
        -- 护身符
        if item.StdMode == 25 then
            return true
        end

        -- 气血石
        if item.StdMode == 7 and item.Shape == 1 then
            return true
        end
        -- 幻魔石
        if item.StdMode == 7 and item.Shape == 2 then
            return true
        end
        -- 魔血石
        if item.StdMode == 7 and item.Shape == 3 then
            return true
        end
    end

    -- cding
    self._cdingTime[51]     = self._cdingTime[51] - delta
    if self._cdingTime[51] <= 0 then
        if CHECK_SETTING(51) == 1 then
            -- 是否有损坏的装备
            local found     = false
            local equipData = self._HeroEquipProxy:GetEquipData()
            local articleType = self._itemConfigProxy:GetArticleType()
            local checkArticleType = {[articleType.TYPE_FIX]=true}
            for _, equip in pairs(equipData) do
                if equip.Dura < 1000 and not isInvalidEquip(equip) then
                    if not self._itemConfigProxy:GetItemArticle(equip.Index,checkArticleType) then
                        local fixValue = equip.Bind or 0
                        found = not CheckBit(fixValue,3) --是否已经修复过了
                    end
                end
            end
    
            -- 是否有
            if found then
                local items         = self._items[51]
                local result        = self:autoUseItem(items)
                local cdtime        = self._mapProxy:GetEatItemSpeed() or 1000
                self._cdingTime[51] = cdtime/1000
            end
        end
    end
end
-------------------------自动收回
function RobotHeroMediator:autoLoginOut(delay)
    self._loginOutHeroTime = self._loginOutHeroTime + delay
end
-----------------------
function RobotHeroMediator:autoUseItem(items, isHpProtect)
    local ItemManagerProxy  = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    if not ItemManagerProxy then 
        return false
    end
    for _, itemIndex in ipairs(items) do
        repeat
            if ItemManagerProxy:IsCityStoneByIndex(itemIndex) or ItemManagerProxy:IsRandStoneByIndex(itemIndex) then 
                if self._mapProxy:IsInSafeArea() then -- 安全区不使用
                    break
                end
                if isHpProtect then -- hp保护检查 复活
                    -- 复活戒指准备就绪，回城/随机保护不生效
                    if CHECK_SETTING(global.MMO.SETTING_IDX_REVIVE_PROTECT_HERO) == 1 and self._HeroPropertyProxy:IsCanRevive() then
                        break
                    end
                end
                local item = proxyUtils.findItemByIndex(itemIndex) -- 回城/随机保护不生效 得人物用
                if item then
                    self._itemUseProxy:UseItem(item)
                    return true
                end
                break
            else 
                local unpack = proxyUtils.unpackDrugByIndex_Hero(itemIndex)
                if unpack then
                    return true
                end
                local item = proxyUtils.findItemByIndex_Hero(itemIndex)
                if item then
                    self._itemUseProxy:HeroUseItem(item)
                    return true
                end
            end
        until true

    end
    return false
end

function RobotHeroMediator:cheakGoodItems(id)
    local value     = GET_SETTING(id, true)
    local enable    = value[1] == 1 
    if id == 3005 and not enable then 
        value     = GET_SETTING(3007, true)
        enable    = value[1] == 1 
    end
    local have = self:CheakItem(self._items[id])  
    return enable,have
end

function RobotHeroMediator:CheakItem(items)---检测有没有
    for _, itemIndex in ipairs(items) do
        local unpack = proxyUtils.unpackDrugByIndex_Hero(itemIndex,false,true)
        if unpack then
            return true
        end
        local item = proxyUtils.findItemByIndex_Hero(itemIndex)
        if item then
            return true
        end
        
    end
    
    return false
end
-------------------------------------------------------

function RobotHeroMediator:cheakAndTipsGoodItems( id )
    if not self._cantips[id] then 
        return 
    end
    function getString(itemName)
        local name = self._HeroPropertyProxy:GetName()
        return  string.format(GET_STRING(600000250),name,itemName)
    end
    local enable,have =  self:cheakGoodItems(id)
    if not have then 
        ShowSystemTips(getString(GET_STRING(600000251+id-3004)))
        self._cantips[id] = false
    end
end
-------------------------------------------------------


-------------------------------------------------------
-- 自动释放
function RobotHeroMediator:autoLaunch(delta)
    self._launchTime = self._launchTime + delta
    if self._launchTime <= 1 then
        return false
    end
    self._launchTime = 0

    local hp     = self._HeroPropertyProxy:GetRoleCurrHP()
    if hp == 0 then
        return
    end

    if not self._mapProxy then
        return nil
    end

    local PlayerInputProxy    = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if not PlayerInputProxy then 
        return nil
    end 
    local TargetID = PlayerInputProxy:GetTargetID()
    if not TargetID then 
        return nil
    end

    local actor = global.actorManager:GetActor(TargetID)
    if not actor then 
        return 
    end

    if self._mapProxy:IsInSafeArea() 
    and (not SL:GetMetaValue("ACTOR_IS_MONSTER", TargetID) and not SL:GetMetaValue("ACTOR_IS_HUMAN", TargetID))
    then --安全区不打人 可以打怪
        return nil
    end
    
    if not proxyUtils.checkLaunchTargetByID(TargetID) then
        return nil
    end


    if CHECK_SETTING(global.MMO.SETTING_IDX_HERO_AUTO_JOINT) == 1 then--自动释放
        local HeroSkillProxy    = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        local jointSkill        = HeroSkillProxy:haveHeroSkill()
        if not jointSkill  then
            return nil
        end
        -- if progressCD:getPercentage() > 0 then
        --     return 
        -- end
        if self._HeroPropertyProxy:getShan()  then--在闪的时候才能放合击
            self._HeroPropertyProxy:ReqJointAttack()--请求合击
        end
    end
end

return RobotHeroMediator
