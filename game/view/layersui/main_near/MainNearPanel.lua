local BaseLayer = requireLayerUI("BaseLayer")
local MainNearPanel = class("MainNearPanel", BaseLayer)

local utf8 = require("util/utf8")
local proxyUtils = requireProxy("proxyUtils")
local RichTextHelp = requireUtil("RichTextHelp")

function MainNearPanel:ctor()
    MainNearPanel.super.ctor(self)

    self._type = nil

    self._typeBtnList = {}
    self._selectType = 1
end

function MainNearPanel.create(data)
    local layer = MainNearPanel.new()
    if layer:Init(data) then
        return layer
    else
        return nil
    end
end

function MainNearPanel:Init(data)
    self.ui = ui_delegate(self)

    return true
end

function MainNearPanel:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_NEAR)
    MainNear.main()

    if tonumber(SL:GetMetaValue("GAME_DATA","syshero")) == 1 then
        self._type = 3
    else
        self._type = 2
    end

    self._listView = self.ui.ListView_1

    self:InitNear()
    self:InitUI()
    self:InitEvent()    
end

function MainNearPanel:InitUI( ... )
    local Button_type = self.ui["Button_type"..self._type]
    if not Button_type then
        return
    end
    for i = 1, self._type do
        local btn = Button_type:cloneEx()
        btn:setVisible(true)
        btn:setTitleText(MainNear.titleList[i] or "")
        btn:addClickEventListener(function ( ... )
            if self._selectType == i then
                return
            end
            self._selectType = i
            self:OnRefreshBtnShow()
            self:OnShowContent()
        end)
        self.ui.ListView_title:pushBackCustomItem(btn)
        self._typeBtnList[i] = btn

        if i ~= self._type then
            local line = ccui.ImageView:create(MainNear.typeBtnCutLine)
            self.ui.ListView_title:pushBackCustomItem(line)
        end
    end

    local sizeW = 0
    for _, v in ipairs(self.ui.ListView_title:getChildren()) do
        sizeW = sizeW + v:getContentSize().width
    end
    self.ui.ListView_title:setContentSize(sizeW, self.ui.ListView_title:getContentSize().height)

    self:OnRefreshBtnShow()
    self:OnShowContent()
end

function MainNearPanel:OnRefreshBtnShow()
    for _, btn in pairs(self._typeBtnList) do
        btn:setBright(_ ~= self._selectType)
    end
end

function MainNearPanel:OnShowContent( ... )
    self:UpdateAllNear()
end

function MainNearPanel:InitEvent( ... )
    local minHeight = 171
    local touchBeganPos = nil
    local orBgHei = self.ui.Panel_bg:getContentSize().height
    local function touchCallback(sender, eventType)
        local visibleSize = global.Director:getVisibleSize()
        local worldPosY = sender:getWorldPosition().y
        local bgSize = self.ui.Panel_bg:getContentSize()
        local maxHeight = bgSize.height + worldPosY + 10
        if eventType == 0 then
            self.ui.Panel_1:setTouchEnabled(false)
            touchBeganPos = sender:getTouchBeganPosition()
        elseif eventType == 1 then
            if not touchBeganPos then
                return
            end
            
            local touchMovedPos = sender:getTouchMovePosition()
            local diffY = touchMovedPos.y - touchBeganPos.y
            local height = orBgHei - diffY 
            height = math.min(maxHeight, height)
            height = math.max(minHeight, height)

            local listSize = self.ui.ListView_1:getContentSize()
            self.ui.ListView_1:setContentSize({width=listSize.width, height=height})

            self.ui.Panel_bg:setContentSize({width=bgSize.width, height=height})
            
            local contentSize = self.ui.Panel_1:getContentSize() 
            self.ui.Panel_1:setContentSize({width=contentSize.width, height = height + 29})
            self.ui.Panel_title:setPositionY(height + 29)
            self.ui.Image_1:setPositionY(height + 29)

        elseif eventType == 2 or eventType == 3 then
            orBgHei = self.ui.Panel_bg:getContentSize().height
            self.ui.Panel_1:setTouchEnabled(true)
        end
    end
    self.ui.Panel_can_touch:addTouchEventListener(touchCallback)
    self.ui.Panel_can_touch:setSwallowTouches(false)

    self.ui.ListView_1:setSwallowTouches(false)
end

function MainNearPanel:InitNear()
    self._playerCells  = {}
    self._monsterCells = {}
    self._heroCells = {}

    self._checkHero = tonumber(SL:GetMetaValue("GAME_DATA","syshero")) == 1

    self._listView:removeAllItems()
    
    -- 1s检测一次
    schedule(self.ui.Panel_bg, function()
        self:CheckAllNear()
    end, 1)
end

function MainNearPanel:CheckAllNear()
    if not self._updateAble then
        return nil
    end
    self._updateAble = false

    if self._selectType == 1 then
        self:AutoAddMonster()
    
    elseif self._selectType == 2 then
        self:AutoAddPlayer()

    elseif self._selectType == 3 and self._checkHero then
        self:AutoAddHero()
    end
end

function MainNearPanel:UpdateAllNear()
    self._playerCells  = {}
    self._monsterCells = {}
    self._heroCells = {}
    self._listView:removeAllItems()

    if self._selectType == 1 then
        self:AutoAddMonster()
    
    elseif self._selectType == 2 then
        self:AutoAddPlayer()

    elseif self._selectType == 3 and self._checkHero then
        self:AutoAddHero()
    end
end

function MainNearPanel:CreateEnemyCell(data)
    local root = cc.Node:create()
    if MainNear and MainNear.CreateEnemyCell then
        local tData = {actorID = data.actorID}
        return MainNear.CreateEnemyCell(root, data)
    end
end

----OnEvent----------------------

function MainNearPanel:OnActorRevive(data)
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end

    self._updateAble = true
end

function MainNearPanel:OnActorInOfView(data)
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end
    
    self._updateAble = true
end

function MainNearPanel:OnActorOutOfView(data)
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end

    self._updateAble = true
    
    if actor:IsPlayer() then
        if actor:IsHero() then
            self:RmvHero(data)
        else
            self:RmvPlayer(data)
        end
        
    elseif actor:IsMonster() then
        self:RmvMonster(data)

    end
end

function MainNearPanel:OnActorDie(data)
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end

    self._updateAble = true
    
    if actor:IsPlayer() then
        if actor:IsHero() then
            self:RmvHero(data)
        else
            self:RmvPlayer(data)
        end

    elseif actor:IsMonster() then
        self:RmvMonster(data)

    end
end

function MainNearPanel:OnRefreshActorHP(data)
    local actorID = data.actorID
    local actor   = global.actorManager:GetActor(actorID)
    if not actor then
        return
    end
    if not ((self._selectType == 1 and actor:IsMonster()) or (self._selectType == 2 and actor:IsPlayer()) or (self._selectType == 3 and actor:IsHero())) then
        return
    end

    local cellList = {}
    if self._selectType == 1 then
        cellList = self._monsterCells
    elseif self._selectType == 2 then
        cellList = self._playerCells
    elseif self._selctType == 3 then
        cellList = self._heroCells
    end

    if not cellList[actorID] then
        return
    end

    local cell    = cellList[actorID]
    local curHP   = actor:GetHP()
    local maxHP   = actor:GetMaxHP()
    local percent = math.floor((curHP / maxHP * 100))
    cell.loadingBarHp:setPercent(percent)
end

function MainNearPanel:OnTargetChange(data)
    local targetID = data.targetID

    for k, v in pairs(self._playerCells) do
        v.imageTarget:setVisible(k == targetID)
    end
    for k, v in pairs(self._monsterCells) do
        v.imageTarget:setVisible(k == targetID)
    end
    for k, v in pairs(self._heroCells) do
        v.imageTarget:setVisible(k == targetID)
    end
end

function MainNearPanel:OnPlayerPKStateChange()
    if self._selectType ~= 2 then
        return nil
    end

    self._playerCells = {}
    self._listView:removeAllItems()
    self:AutoAddPlayer()
end

function MainNearPanel:OnMainNearRefresh( data )
    local actor   = data.actor
    local actorID = data.actorID

    if actorID == global.playerManager:GetMainPlayerID() then
        return
    end

    self._updateAble = true
    
    if actor:IsPlayer() then
        if actor:IsHero() then
            self:RmvHero(data)
        else
            self:RmvPlayer(data)
        end

    elseif actor:IsMonster() then
        self:RmvMonster(data)

    end
end
---------------------------------

-------Player--------------------
function MainNearPanel:AddPlayer(data)
    local actor   = data.actor
    local actorID = data.actorID

    if self._selectType ~= 2 then
        return
    end
    if self._playerCells[actorID] then
        return
    end
    if false == proxyUtils.checkLaunchTarget(actor) then
        -- enemy only
        return
    end

    local items = self._listView:getItems()
    if #items >= MainNear.PLAYER_COUNT then
        return
    end

    local insertIndex = #items
    for enemyID, enemyCell in pairs(self._playerCells) do
        local enemy = global.actorManager:GetActor(enemyID)

        if nil == enemy then
            print("ERRORRRRRRRRRRRRRRRRRRR AddPlayer")
            return 
        end

        if proxyUtils.checkEnemyTag(enemy) == 1 and proxyUtils.checkEnemyTag(actor) == 1 then
            -- 都可以攻击，判断等级
            if actor:GetLevel() > enemy:GetLevel() then
                insertIndex = math.min(insertIndex, self._listView:getIndex(enemyCell.layout))
            end

        elseif proxyUtils.checkEnemyTag(enemy) ~= 1 and proxyUtils.checkEnemyTag(actor) == 1 then
            -- 一个可攻击，一个不可以攻击，取可以攻击的
            insertIndex = math.min(insertIndex, self._listView:getIndex(enemyCell.layout))
        
        elseif proxyUtils.checkEnemyTag(enemy) ~= 1 and proxyUtils.checkEnemyTag(actor) ~= 1 then
            -- 都不可以攻击，判断等级
            if actor:GetLevel()  > enemy:GetLevel() then
                insertIndex = math.min(insertIndex, self._listView:getIndex(enemyCell.layout))
            end
        end
    end

    local cell = self:CreateEnemyCell(data)
    if cell and next(cell) then
        self._listView:insertCustomItem(cell.layout, insertIndex)
        self._playerCells[actorID] = cell
    end
end

function MainNearPanel:RmvPlayer(data)
    local actor   = data.actor
    local actorID = data.actorID

    if self._selectType ~= 2 then
        return
    end
    if not self._playerCells[actorID] then
        return
    end

    local cell  = self._playerCells[actorID]
    self._listView:removeItem(self._listView:getIndex(cell.layout))

    self._playerCells[actorID] = nil
end

function MainNearPanel:AutoAddPlayer()
    if self._selectType ~= 2 then
        return
    end
    
    local items = self._listView:getItems()
    if #items >= MainNear.PLAYER_COUNT then
        return
    end

    local actors, nActor = global.playerManager:GetPlayersInCurrViewField()
    for i = 1, nActor do
        local actor = actors[i]
        if actor and not actor:IsMainPlayer() and not actor:IsHero() and not actor:IsHumanoid() and not actor:GetValueByKey(global.MMO.ACT_SNEAK) then
            self:AddPlayer({actor = actor, actorID = actor:GetID()})
            self:AutoRmvPlayer()
        end
    end
end

function MainNearPanel:AutoRmvPlayer()
    if self._enemyIndex ~= 1 then
        return
    end
    
    local items = self._listView:getItems()
    if #items <= MainNear.PLAYER_COUNT then
        return
    end

    local rmved = nil
    for enemyID, enemyCell in pairs(self._playerCells) do
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

-------Monster--------------------
function MainNearPanel:AddMonster(data)
    local actor   = data.actor
    local actorID = data.actorID

    if self._selectType ~= 1 then
        return
    end
    if self._monsterCells[actorID] then
        return
    end
    if false == proxyUtils.checkLaunchTarget(actor) then
        -- enemy only
        return
    end

    local items = self._listView:getItems()
    if #items >= MainNear.MONSTER_COUNT and getWeight(actor) == 0 then
        return
    end

    -- 根据怪物权值找到插入位置
    local insertIndex = #items
    for enemyID, enemyCell in pairs(self._monsterCells) do
        local enemy = global.actorManager:GetActor(enemyID)
        if enemy and getWeight(actor) > getWeight(enemy) then
            insertIndex = math.min(self._listView:getIndex(enemyCell.layout), insertIndex)
        end
    end

    local cell = self:CreateEnemyCell(data)
    if cell and next(cell) then
        self._listView:insertCustomItem(cell.layout, insertIndex)
        self._monsterCells[actorID] = cell
    end
end

function MainNearPanel:RmvMonster(data)
    local actor   = data.actor
    local actorID = data.actorID

    if self._selectType ~= 1 then
        return
    end
    if not self._monsterCells[actorID] then
        return
    end

    local cell = self._monsterCells[actorID]
    self._listView:removeItem(self._listView:getIndex(cell.layout))

    self._monsterCells[actorID] = nil
end

function MainNearPanel:AutoAddMonster()
    if self._selectType ~= 1 then
        return
    end
    local items = self._listView:getItems()
    if #items >= MainNear.MONSTER_COUNT then
        return
    end

    local actors, nActor = global.monsterManager:FindMonsterInCurrViewField(true, true)

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

function MainNearPanel:AutoRmvMonster()
    if self._selectType ~= 1 then
        return
    end
    
    local items = self._listView:getItems()
    if #items <= MainNear.MONSTER_COUNT then
        return
    end

    local rmved = nil
    for enemyID, enemyCell in pairs(self._monsterCells) do
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

function MainNearPanel:OnActorMonsterBirth(data)
    self._updateAble = true
end

function MainNearPanel:OnActorMonsterCave(data)
    self._updateAble = true
end

-------Hero-----------------------
function MainNearPanel:AddHero(data)
    local actor   = data.actor
    local actorID = data.actorID

    if not (self._selectType == 3 and self._checkHero) then
        return
    end
    if self._heroCells[actorID] then
        return
    end
    if false == proxyUtils.checkLaunchTarget(actor) then
        -- enemy only
        return
    end

    local listview = self._listView
    local items = listview:getItems()
    if #items >= MainNear.HERO_COUNT then
        return
    end

    -- 找到插入位置
    local insertIndex = #items
    for heroID, heroCell in pairs(self._heroCells) do
        local hero = global.actorManager:GetActor(heroID)
        if nil == hero then
            print("ERRORRRRRRRRRRRRRRRRRRR AddHERO ")
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

function MainNearPanel:RmvHero(data)
    local actor   = data.actor
    local actorID = data.actorID

    if not (self._selectType == 3 and self._checkHero) then
        return
    end
    if not self._heroCells[actorID] then
        return
    end

    local cell  = self._heroCells[actorID]
    self._listView:removeItem(self._listView:getIndex(cell.layout))

    self._heroCells[actorID] = nil
end

function MainNearPanel:AutoAddHero()
    if not (self._selectType == 3 and self._checkHero) then
        return
    end

    local items = self._listView:getItems()
    if #items >= MainNear.HERO_COUNT then
        return
    end

    local actors, nActor = global.playerManager:FindHeroInCurrViewField()
    for i = 1, nActor do
        local actor = actors[i]
        self:AddHero({actor = actor, actorID = actor:GetID()})
        self:AutoRmvHero()
    end
end

function MainNearPanel:AutoRmvHero()
    if not (self._selectType == 3 and self._checkHero) then
        return
    end
    
    local items = self._listView:getItems()
    if #items <= MainNear.HERO_COUNT then
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

return MainNearPanel