local MainAssistLayout = class("MainAssistLayout", function()
    return cc.Node:create()
end)

local utf8 = require("util/utf8")
local proxyUtils = requireProxy("proxyUtils")

function MainAssistLayout:ctor()
    self._path = global.MMO.PATH_RES_PRIVATE .. "main/"

    -- 提高进出视野效率
    self._updateActorAble   = false
    self._updateHeroAble    = false
    self._checkHero         = false
end

function MainAssistLayout.create()
    local layout = MainAssistLayout.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function MainAssistLayout:Init()
    self._ui = ui_delegate(self)
    return true
end

function MainAssistLayout:InitGUI( ... )
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_ASSIST)
    MainAssist.main()

    self:InitAssist()
    self:InitEnemy()
    self:InitHero()

    self:InitEditMode()

    return true
end

function MainAssistLayout:InitEditMode()
    local items = 
    {
        "Panel_assist",
        "Panel_hide",
        "Image_24",
        "Button_hide",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

function MainAssistLayout:ChangeHideStatus(data)
    MainAssist.ChangeHideStatus(data)
end

function MainAssistLayout:ReloadCUISetWidget( ... )
    if self._layoutAssist then
        MainAssist._assistPos = GUI:getPosition(self._layoutAssist)
    end
    if self._ui["Panel_hide"] then
        MainAssist._hidePos = GUI:getPosition(self._ui["Panel_hide"])
    end
end

function MainAssistLayout:InitAssist()
    self._assistGroup   = 0     -- 活动 2任务组队 1附近列表  3英雄
    self._contentIndex  = 0     -- 任务组队显示索引 1任务 2组队
    self._enemyIndex    = 0     -- 人物怪物显示索引 1玩家 2怪物

    self._layoutAssist = self._ui.Panel_assist

    -- group
    self._layoutGroup = self._layoutAssist:getChildByName("Panel_group")
    self._ui_group = ui_delegate(self._layoutGroup)
    if not self._ui_group then
        return
    end
    self._ui_group.Button_change:addClickEventListener(function()
        local maxGroup = 2
        local group = self._assistGroup == 1 and maxGroup or self._assistGroup - 1
        if tonumber(SL:GetMetaValue("GAME_DATA","syshero") or 0) == 1 then
            maxGroup = 3
            if self._assistGroup == 1 then
                group = maxGroup
            elseif self._assistGroup == 2 then
                group = maxGroup - self._assistGroup
            elseif self._assistGroup == 3 then
                group = 2
            end
        end
        self:ChangeAssistGroup(group)
        self:CalcAssistShow()

        global.Facade:sendNotification(global.NoticeTable.GuideEventEnded, {name = "GUIDE_ASSIST_MISSION_END"})
    end)

    -- 任务/组队
    self._ui_group.Button_mission:addClickEventListener(function()
        self:ChangeContentIndex(1)
        self:CalcAssistShow()
    end)
    self._ui_group.Button_team:addClickEventListener(function()
        self:ChangeContentIndex(2)
        self:CalcAssistShow()
    end)

    -- 人物/怪物
    self._ui_group.Button_player:addClickEventListener(function()
        self:ChangeEnemyIndex(1)
        self:CalcAssistShow()
    end)
    self._ui_group.Button_monster:addClickEventListener(function()
        self:ChangeEnemyIndex(2)
        self:CalcAssistShow()
    end)

    -- content
    self._layoutContent = self._layoutAssist:getChildByName("Panel_content")
    self._ui_content = ui_delegate(self._layoutContent)
    self._listviewCells = self._ui_content.ListView_mission

    -- enemy
    self._layoutEnemy = self._layoutAssist:getChildByName("Panel_enemy")
    self._ui_enemy = ui_delegate(self._layoutEnemy)

    -- hero
    self._layoutHero = self._layoutAssist:getChildByName("Panel_hero")
    self._ui_hero = ui_delegate(self._layoutHero)

    self:ChangeAssistGroup(2)
    self:ChangeContentIndex(1)
    self:ChangeEnemyIndex(1)
    self:CalcAssistShow()
end

function MainAssistLayout:ChangeAssistGroup(g)
    self._assistGroup = g

    self._ui_group.BtnG_content:setVisible(self._assistGroup == 2)
    self._ui_group.BtnG_enemy:setVisible(self._assistGroup == 1)
    self._ui_group.BtnG_hero:setVisible(self._assistGroup == 3)
end

function MainAssistLayout:ChangeContentIndex(index)
    self._contentIndex = index

    self._ui_group.Button_mission:setTouchEnabled(self._contentIndex == 2)
    self._ui_group.Button_mission:setBright(self._contentIndex == 1)
    self._ui_group.Button_team:setTouchEnabled(self._contentIndex == 1)
    self._ui_group.Button_team:setBright(self._contentIndex == 2)
    
    if not (self._contentIndex == 1) then
        global.Facade:sendNotification(global.NoticeTable.GuideEventEnded, {name = "GUIDE_ASSIST_MISSION_END"})
    end
end

function MainAssistLayout:ChangeEnemyIndex(index)
    self._enemyIndex = index

    self._ui_group.Button_player:setTouchEnabled(self._enemyIndex == 2)
    self._ui_group.Button_player:setBright(self._enemyIndex == 1)
    self._ui_group.Button_monster:setTouchEnabled(self._enemyIndex == 1)
    self._ui_group.Button_monster:setBright(self._enemyIndex == 2)

    self:UpdateAllEnemy()
end

function MainAssistLayout:CalcAssistShow()
    self._ui_content.nativeUI:setVisible(self._assistGroup == 2)
    self._ui_enemy.nativeUI:setVisible(self._assistGroup == 1)
    self._ui_hero.nativeUI:setVisible(self._assistGroup == 3)

    -- 任务组队
    self._ui_content.Panel_mission:setVisible(self._contentIndex == 1)
    self._ui_content.Panel_team:setVisible(self._contentIndex == 2)
    
    -- 附近列表
    self._ui_enemy.Panel_player:setVisible(self._enemyIndex == 1)
    self._ui_enemy.Panel_monster:setVisible(self._enemyIndex == 2)
end

---------------------------------Enemy begin------------------------------------
function MainAssistLayout:InitEnemy()
    self._enemyCells   = {}
    self._playerCells  = {}
    self._monsterCells = {}

    self._ui_enemy.ListView_player:removeAllItems()
    self._ui_enemy.ListView_monster:removeAllItems()

    -- 1s检测一次
    schedule(self._layoutEnemy, function()
        self:CheckAllEnemy()
    end, 1)
end

function MainAssistLayout:CheckAllEnemy()
    if not self._updateActorAble then
        return nil
    end
    self._updateActorAble = false

    if self._enemyIndex == 1 then
        self:AutoAddPlayer() 
    elseif self._enemyIndex == 2 then
        self:AutoAddMonster()
    end
end

function MainAssistLayout:CreateEnemyCell(data)
    local root = cc.Node:create()
    local tData = {
        actorID = data.actorID
    }
    if MainAssist and MainAssist.CreateEnemyCell then
        return MainAssist.CreateEnemyCell(root, tData)
    end
end

function MainAssistLayout:UpdateAllEnemy()
    self._enemyCells = {}
    self._ui_enemy.ListView_player:removeAllItems()
    self._ui_enemy.ListView_monster:removeAllItems()

    if self._enemyIndex == 1 then
        self:AutoAddPlayer()
        
    elseif self._enemyIndex == 2 then
        self:AutoAddMonster()
    end
end

function MainAssistLayout:OnMainNearRefresh(data)
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end
    
    if actor:IsPlayer() then
        if actor:IsHero() then
            self:RmvHero(data)
        else
            self:RmvPlayer(data)
        end

        if self._enemyIndex == 1 then
            self:AutoAddPlayer()
        end

    elseif actor:IsMonster() then
        self:RmvMonster(data)

        if self._enemyIndex == 2 then
            self:AutoAddMonster()
        end

    end
end

function MainAssistLayout:OnActorRevive(data)
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end

    self._updateActorAble = true
    self._updateHeroAble = true
end

function MainAssistLayout:OnActorInOfView(data)
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end
    
    self._updateActorAble = true
    self._updateHeroAble = true
end

function MainAssistLayout:OnActorOutOfView(data)
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end

    self._updateActorAble = true
    self._updateHeroAble = true
    
    if actor:IsPlayer() then
        if actor:IsHero() then
            self:RmvHero(data)
        elseif actor:IsHumanoid() then
            self:RmvMonster(data)
        else
            self:RmvPlayer(data)
        end
    elseif actor:IsMonster() then
        self:RmvMonster(data)
    end
end

function MainAssistLayout:OnActorDie(data)
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end

    self._updateActorAble = true
    self._updateHeroAble = true
    
    if actor:IsPlayer() then
        if actor:IsHero() then
            self:RmvHero(data)
        elseif actor:IsHumanoid() then
            self:RmvMonster(data)
        else
            self:RmvPlayer(data)
        end
    elseif actor:IsMonster() then
        self:RmvMonster(data)
    end
end

function MainAssistLayout:OnRefreshActorHP(data)
    self:UpdateEnemy(data)
    self:UpdateHero(data)
end

function MainAssistLayout:OnTargetChange(data)
    local targetID = data.targetID
    for k, v in pairs(self._enemyCells) do
        v.imageTarget:setVisible(k == targetID)
    end
end

function MainAssistLayout:OnPlayerPKStateChange()
    -- 切模式，刷新附近列表
    if self._enemyIndex ~= 1 then
        return nil
    end

    self._enemyCells = {}
    self._ui_enemy.ListView_player:removeAllItems()
    self:AutoAddPlayer()
end

function MainAssistLayout:AddPlayer(data)
    local actor   = data.actor
    local actorID = data.actorID

    if self._enemyIndex ~= 1 then
        return
    end
    if self._enemyCells[actorID] then
        return
    end
    if false == proxyUtils.checkLaunchTarget(actor) then
        -- enemy only
        return
    end

    local listview = self._ui_enemy.ListView_player
    local items = listview:getItems()
    if #items >= MainAssist.PLAYER_COUNT then
        return
    end

    -- 找到插入位置
    local insertIndex = #items
    for enemyID, enemyCell in pairs(self._enemyCells) do
        local enemy = global.actorManager:GetActor(enemyID)

        -- 我日，出错了，啥错啊，难搞
        if nil == enemy then
            print("ERRORRRRRRRRRRRRRRRRRRR AddPlayer")
            return 
        end

        if proxyUtils.checkEnemyTag(enemy) == 1 and proxyUtils.checkEnemyTag(actor) == 1 then
            -- 都可以攻击，判断等级
            if actor:GetLevel() > enemy:GetLevel() then
                insertIndex = math.min(insertIndex, listview:getIndex(enemyCell.layout))
            end

        elseif proxyUtils.checkEnemyTag(enemy) ~= 1 and proxyUtils.checkEnemyTag(actor) == 1 then
            -- 一个可攻击，一个不可以攻击，取可以攻击的
            insertIndex = math.min(insertIndex, listview:getIndex(enemyCell.layout))
        
        elseif proxyUtils.checkEnemyTag(enemy) ~= 1 and proxyUtils.checkEnemyTag(actor) ~= 1 then
            -- 都不可以攻击，判断等级
            if actor:GetLevel()  > enemy:GetLevel() then
                insertIndex = math.min(insertIndex, listview:getIndex(enemyCell.layout))
            end
        end
    end

    local cell = self:CreateEnemyCell(data)
    if cell and next(cell) then
        listview:insertCustomItem(cell.layout, insertIndex)
        self._enemyCells[actorID] = cell
    end
end

function MainAssistLayout:RmvPlayer(data)
    local actor   = data.actor
    local actorID = data.actorID

    if self._enemyIndex ~= 1 then
        return
    end
    if not self._enemyCells[actorID] then
        return
    end

    local listview  = self._ui_enemy.ListView_player
    local cell      = self._enemyCells[actorID]
    listview:removeItem(listview:getIndex(cell.layout))

    self._enemyCells[actorID] = nil
end

function MainAssistLayout:AutoAddPlayer()
    if self._enemyIndex ~= 1 then
        return
    end
    local listview = self._ui_enemy.ListView_player
    local items = listview:getItems()
    if #items >= MainAssist.PLAYER_COUNT then
        return
    end

    local actors, nActor = global.playerManager:GetPlayersInCurrViewField()
    for i = 1, nActor do
        local actor = actors[i]
        if actor and not actor:IsMainPlayer() and not actor:IsHero() and not actor:IsHumanoid() and not actor:GetValueByKey(global.MMO.HUD_SNEAK) then
            self:AddPlayer({actor = actor, actorID = actor:GetID()})
            self:AutoRmvPlayer()
        end
    end
end

function MainAssistLayout:AutoRmvPlayer()
    if self._enemyIndex ~= 1 then
        return
    end
    local listview = self._ui_enemy.ListView_player
    local items = listview:getItems()
    if #items <= MainAssist.PLAYER_COUNT then
        return
    end

    local rmved = nil
    for enemyID, enemyCell in pairs(self._enemyCells) do
        local enemy = global.actorManager:GetActor(enemyID)

        -- 出错了吧
        if nil == enemy then
            print("ERRORRRRRRRRRRRRRRRRRRR AutoRmvPlayer")
            break
        end
        
        if nil == rmved then
            rmved = enemy

        elseif proxyUtils.checkEnemyTag(enemy) == 1 and proxyUtils.checkEnemyTag(rmved) == 1 then
            -- 都可以攻击，判断等级
            if rmved:GetLevel() > enemy:GetLevel() then
                rmved = enemy
            end

        elseif proxyUtils.checkEnemyTag(enemy) == 1 and proxyUtils.checkEnemyTag(rmved) ~= 1 then
            -- 一个可攻击，一个不可以攻击，取可以攻击的
            rmved = enemy
        
        elseif proxyUtils.checkEnemyTag(enemy) ~= 1 and proxyUtils.checkEnemyTag(rmved) ~= 1 then
            -- 都不可以攻击，判断等级
            if rmved:GetLevel() > enemy:GetLevel() then
                rmved = enemy
            end
        end
    end
    if rmved then
        self:RmvPlayer({actorID = rmved:GetID(), actor = rmved})
    end
end

local function getWeight(actor)
    local weight = 0

    if actor:IsEscort() then
        weight = 4

    elseif actor:IsBoss() then
        weight = 3
    
    elseif actor:IsElite() then
        weight = 2
    
    elseif actor:IsMonster() and false == actor:IsHaveMaster() then
        weight = 1
    end
    return weight
end

function MainAssistLayout:AddMonster(data)
    local actor   = data.actor
    local actorID = data.actorID

    if self._enemyIndex ~= 2 then
        return
    end
    if self._enemyCells[actorID] then
        return
    end
    if false == proxyUtils.checkLaunchTarget(actor) then
        -- enemy only
        return
    end

    local listview = self._ui_enemy.ListView_monster
    local items = listview:getItems()
    if #items >= MainAssist.MONSTER_COUNT and getWeight(actor) == 0 then
        return
    end

    -- 根据怪物权值找到插入位置
    local insertIndex = #items
    for enemyID, enemyCell in pairs(self._enemyCells) do
        local enemy = global.actorManager:GetActor(enemyID)
        if enemy and getWeight(actor) > getWeight(enemy) then
            insertIndex = math.min(listview:getIndex(enemyCell.layout), insertIndex)
        end
    end

    local cell = self:CreateEnemyCell(data)
    if cell and next(cell) then
        listview:insertCustomItem(cell.layout, insertIndex)
        self._enemyCells[actorID] = cell
    end
end

function MainAssistLayout:RmvMonster(data)
    local actor   = data.actor
    local actorID = data.actorID

    if self._enemyIndex ~= 2 then
        return
    end
    if not self._enemyCells[actorID] then
        return
    end

    local listview = self._ui_enemy.ListView_monster
    local cell     = self._enemyCells[actorID]
    listview:removeItem(listview:getIndex(cell.layout))

    self._enemyCells[actorID] = nil
end

function MainAssistLayout:AutoAddMonster()
    if self._enemyIndex ~= 2 then
        return
    end
    local listview = self._ui_enemy.ListView_monster
    local items = listview:getItems()
    if #items >= MainAssist.MONSTER_COUNT then
        return
    end

    local actors, nActor = global.monsterManager:FindMonsterInCurrViewField(true)
    
    local playerVec, nPlayer = global.playerManager:FindPlayerInCurrViewField()
    for i = 1, nPlayer do
        local player = playerVec[i]
        if player:IsHumanoid() then
            nActor = nActor + 1
            actors[nActor] = player
        end
    end

    for i = 1, nActor do
        local actor = actors[i]
        if actor then
            self:AddMonster({actor = actor, actorID = actor:GetID()})
            self:AutoRmvMonster()
        end
    end
end

function MainAssistLayout:AutoRmvMonster()
    if self._enemyIndex ~= 2 then
        return
    end
    local listview = self._ui_enemy.ListView_monster
    local items = listview:getItems()
    if #items <= MainAssist.MONSTER_COUNT then
        return
    end

    local rmved = nil
    for enemyID, enemyCell in pairs(self._enemyCells) do
        local enemy = global.actorManager:GetActor(enemyID)

        -- 出错了吧
        if nil == enemy then
            print("ERRORRRRRRRRRRRRRRRRRRR AutoRmvMonster")
            break
        end

        -- 根据权重，移除
        if getWeight(enemy) == 0 then
            rmved = enemy
            break
        end
        if nil == rmved or getWeight(enemy) < getWeight(rmved) then
            rmved = enemy
        end
    end
    if rmved then
        self:RmvMonster({actorID = rmved:GetID(), actor = rmved})
    end
end

function MainAssistLayout:OnActorMonsterBirth(data)
    local actor   = data.actor
    local actorID = data.actorID
    self._updateActorAble = true
end

function MainAssistLayout:OnActorMonsterCave(data)
    local actor   = data.actor
    local actorID = data.actorID
    self._updateActorAble = true
end

function MainAssistLayout:UpdateEnemy(data)
    local actorID = data.actorID
    local actor   = global.actorManager:GetActor(actorID)
    if not actor then
        return
    end
    if not ((self._enemyIndex == 1 and actor:IsPlayer()) or (self._enemyIndex == 2 and actor:IsMonster())) then
        return
    end
    if not self._enemyCells[actorID] then
        return
    end

    local cell    = self._enemyCells[actorID]
    local curHP   = actor:GetHP()
    local maxHP   = actor:GetMaxHP()
    local percent = math.floor((curHP / maxHP * 100))
    cell.loadingBarHp:setPercent(percent)
end
----------------------------------Enemy end-------------------------------------

function MainAssistLayout:InitHero()
    self._checkHero = tonumber(SL:GetMetaValue("GAME_DATA","syshero")) == 1
    if self._checkHero then
        self._heroCells   = {}
        self._ui_hero.ListView_hero:removeAllItems()

        schedule(self._layoutHero, function()
            self:CheckAllHero()
        end, 1)
    end
end

function MainAssistLayout:CheckAllHero( ... )
    if not self._updateHeroAble then
        return nil
    end
    self._updateHeroAble = false

    if self._assistGroup == 3 and self._checkHero then
        local items = self._ui_hero.ListView_hero:getItems()
        if #items >= MainAssist.HERO_COUNT then
            return
        end
        
        local actors, nActor = global.playerManager:FindHeroInCurrViewField()
        for i = 1, nActor do
            local actor = actors[i]
            self:AddHero({actor = actor, actorID = actor:GetID()})
            self:AutoRmvHero()
        end
    end
end

function MainAssistLayout:AddHero(data)
    local actor   = data.actor
    local actorID = data.actorID

    if not (self._assistGroup == 3 and self._checkHero) then
        return
    end
    if self._heroCells[actorID] then
        return
    end
    if false == proxyUtils.checkLaunchTarget(actor) then
        -- enemy only
        return
    end

    local listview = self._ui_hero.ListView_hero
    local items = listview:getItems()
    if #items >= MainAssist.HERO_COUNT then
        return
    end

    -- 找到插入位置
    local insertIndex = #items
    for heroID, heroCell in pairs(self._heroCells) do
        local hero = global.actorManager:GetActor(heroID)
        if nil == hero then
            print("ERRORRRRRRRRRRRRRRRRRRR AddHERO BY ASSIST")
            break 
        end

        if proxyUtils.checkEnemyTag(hero) == 1 and proxyUtils.checkEnemyTag(actor) == 1 then
            -- 都可以攻击，判断等级
            if actor:GetLevel() > hero:GetLevel() then
                insertIndex = math.min(insertIndex, listview:getIndex(heroCell.layout))
            end

        elseif proxyUtils.checkEnemyTag(hero) ~= 1 and proxyUtils.checkEnemyTag(actor) == 1 then
            -- 一个可攻击，一个不可以攻击，取可以攻击的
            insertIndex = math.min(insertIndex, listview:getIndex(heroCell.layout))
        
        elseif proxyUtils.checkEnemyTag(hero) ~= 1 and proxyUtils.checkEnemyTag(actor) ~= 1 then
            -- 都不可以攻击，判断等级
            if actor:GetLevel()  > hero:GetLevel() then
                insertIndex = math.min(insertIndex, listview:getIndex(heroCell.layout))
            end
        end
    end

    local cell = self:CreateEnemyCell(data)
    if cell and next(cell) then
        listview:insertCustomItem(cell.layout, insertIndex)
        self._heroCells[actorID] = cell
    end
end

function MainAssistLayout:AutoRmvHero()
    if not (self._assistGroup == 3 and self._checkHero) then
        return
    end
    local listview = self._ui_hero.ListView_hero
    local items = listview:getItems()
    if #items <= MainAssist.HERO_COUNT then
        return
    end

    local rmved = nil
    for heroID, heroCell in pairs(self._heroCells) do
        local hero = global.actorManager:GetActor(heroID)

        if nil == hero then
            print("ERRORRRRRRRRRRRRRRRRRRR AutoRmvHERO ")
            break
        end
        
        if nil == rmved then
            rmved = hero

        elseif proxyUtils.checkEnemyTag(hero) == 1 and proxyUtils.checkEnemyTag(rmved) == 1 then
            -- 都可以攻击，判断等级
            if rmved:GetLevel() > hero:GetLevel() then
                rmved = hero
            end

        elseif proxyUtils.checkEnemyTag(hero) == 1 and proxyUtils.checkEnemyTag(rmved) ~= 1 then
            -- 一个可攻击，一个不可以攻击，取可以攻击的
            rmved = hero
        
        elseif proxyUtils.checkEnemyTag(hero) ~= 1 and proxyUtils.checkEnemyTag(rmved) ~= 1 then
            -- 都不可以攻击，判断等级
            if rmved:GetLevel() > hero:GetLevel() then
                rmved = hero
            end
        end
    end
    if rmved then
        self:RmvHero({actorID = rmved:GetID(), actor = rmved})
    end
end

function MainAssistLayout:RmvHero(data)
    local actor   = data.actor
    local actorID = data.actorID

    if not (self._assistGroup == 3 and self._checkHero) then
        return
    end
    if not self._heroCells[actorID] then
        return
    end

    local listview  = self._ui_hero.ListView_hero
    local cell      = self._heroCells[actorID]
    listview:removeItem(listview:getIndex(cell.layout))

    self._heroCells[actorID] = nil
end

function MainAssistLayout:UpdateHero(data)
    local actorID = data.actorID
    local actor   = global.actorManager:GetActor(actorID)
    if not actor then
        return
    end
    if not (self._assistGroup == 3 and self._checkHero) then
        return
    end
    if not self._heroCells[actorID] then
        return
    end

    local cell    = self._heroCells[actorID]
    local curHP   = actor:GetHP()
    local maxHP   = actor:GetMaxHP()
    local percent = math.floor((curHP / maxHP * 100))
    cell.loadingBarHp:setPercent(percent)
end

return MainAssistLayout