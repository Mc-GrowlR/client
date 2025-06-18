local QuickSelectMediator = class('QuickSelectMediator', framework.Mediator)
QuickSelectMediator.NAME  = "QuickSelectMediator"
local proxyUtils          = requireProxy( "proxyUtils" )
local tSort               = table.sort
local imgTag              = 778

local mMin = math.min
local mMax = math.max
local mAbs = math.abs

local function squLen( x, y )
    return x * x + y * y
end

local function sort_player( e1, e2 )
    if e1.selectCount == e2.selectCount then
        return e1.len < e2.len
    end

    return e1.selectCount < e2.selectCount
end

local function sort_monster( e1, e2 )
    if e1.selectCount == e2.selectCount then
        return e1.len < e2.len
    end

    return e1.selectCount < e2.selectCount
end


function QuickSelectMediator:ctor()
    QuickSelectMediator.super.ctor( self, self.NAME )

    self._selectPlayer  = {}
    self._selectMonster = {}
    self._selectHero    = {}
end

function QuickSelectMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.QuickSelectTarget,
        noticeTable.ActorOutOfView
    }
end


function QuickSelectMediator:handleNotification(notification)
    local noticeID = notification:getName()
    local notices  = global.NoticeTable
    local data     = notification:getBody()

    if notices.QuickSelectTarget == noticeID then
        self:onSelect( data )
        
    elseif notices.ActorOutOfView == noticeID then
        self:onActorOutOfView(data)

    end
end

function QuickSelectMediator:onSelect( data )
    local targetType = data.type
    local imgNotice  = data.imgNotice
    local systemTips = data.systemTips

    if global.MMO.ACTOR_PLAYER == targetType then
        self:selectPlayer( imgNotice, systemTips )
        
    elseif global.MMO.ACTOR_MONSTER == targetType then
        self:selectMonster( imgNotice, systemTips )

    elseif global.MMO.ACTOR_HERO == targetType then
        self:selectHero( imgNotice, systemTips )
    end
end

function QuickSelectMediator:selectPlayer( imgNotice, systemTips )
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return nil
    end


    local playerVec, nPlayer = global.playerManager:GetPlayersInCurrViewField() 
    local enemyVec   = {}
    local enemyCount = 0
    local pMapX      = mainPlayer:GetMapX()
    local pMapY      = mainPlayer:GetMapY()

    for i = 1, nPlayer do
        local player = playerVec[i]
        if player and not player:IsHero() and not player:IsHumanoid() and not player:GetValueByKey(global.MMO.HUD_SNEAK) and proxyUtils.checkAutoTargetEnableByID( player:GetID() )  then
            local fMapX       = player:GetMapX()
            local fMapY       = player:GetMapY()
            local selectCount = self._selectPlayer[player:GetID()]
            local enemy       = {}
            enemy.actor       = player
            enemy.len         = squLen( fMapX - pMapX, fMapY - pMapY ) 
            enemy.selectCount = selectCount and selectCount or 0

            enemyCount = enemyCount + 1
            enemyVec[enemyCount] = enemy
        end
    end

    if enemyCount > 0 then
        tSort( enemyVec, sort_player )
        
        local enemy    = enemyVec[1]
        local target   = enemy.actor
        local targetID = target:GetID()

        self._selectPlayer[targetID] = enemy.selectCount + 1

        local inputProxy = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
        inputProxy:SetTargetID( targetID, global.MMO.SELETE_TARGET_TYPE_FIND )
    else
        if systemTips then
            global.Facade:sendNotification( global.NoticeTable.SystemTips, GET_STRING( 800400 ) )
        end

        if imgNotice then
            self:createCircle( "player.png" )
        end
    end
end

function QuickSelectMediator:selectMonster( imgNotice, systemTips )
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return nil
    end

    
    local monsterVec, ncount = global.monsterManager:GetMonstersInCurrViewField()
    local num        = ncount
    local enemyVec   = {}
    local enemyCount = 0
    local pMapX      = mainPlayer:GetMapX()
    local pMapY      = mainPlayer:GetMapY()
    local fMapX      = 0
    local fMapY      = 0
    
    -- 人形怪
    local playerVec, nPlayer = global.playerManager:FindPlayerInCurrViewField()
    for i = 1, nPlayer do
        local player = playerVec[i]
        if player:IsHumanoid() then
            num = num + 1
            monsterVec[num] = player
        end
    end

    local selectCount   = 0
    for _, value in pairs(self._selectMonster) do
        selectCount     = mMin(selectCount, value)
    end

    for i = 1, num do
        local monster = monsterVec[i]
        if monster then
            fMapX = monster:GetMapX()
            fMapY = monster:GetMapY()
            if mMax(mAbs(fMapX - pMapX), mAbs(fMapY - pMapY)) <= 8 and proxyUtils.checkAutoTargetEnableByID(monster:GetID()) then
                local enemy         = {}
                enemy.actor         = monster
                enemy.len           = squLen( fMapX - pMapX, fMapY - pMapY )
                enemy.selectCount   = selectCount == 0 and (self._selectMonster[monster:GetID()] or 0) or 1
                
                enemyCount          = enemyCount + 1
                enemyVec[enemyCount] = enemy
            end
        end
    end

    if enemyCount > 0 then
        tSort( enemyVec, sort_monster )
        
        local enemy         = enemyVec[1]
        local target        = enemy.actor
        local inputProxy    = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
        if inputProxy:GetTargetID() ~= target:GetID() then
            local targetID  = target:GetID()
            self._selectMonster[targetID] = enemy.selectCount+1
            inputProxy:SetTargetID( targetID, global.MMO.SELETE_TARGET_TYPE_FIND )
        end
    else
        if systemTips then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING( 800401 ) )
        end
        if imgNotice then
            self:createCircle( "monster.png" )
        end
    end
end

function QuickSelectMediator:selectHero( imgNotice, systemTips )
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return nil
    end

    local playerVec, nPlayer = global.playerManager:GetPlayersInCurrViewField() 
    local enemyVec   = {}
    local enemyCount = 0
    local pMapX      = mainPlayer:GetMapX()
    local pMapY      = mainPlayer:GetMapY()
    for i = 1, nPlayer do
        local player = playerVec[i]
        if player and player:IsHero() and proxyUtils.checkAutoTargetEnableByID( player:GetID() )  then

            local fMapX       = player:GetMapX()
            local fMapY       = player:GetMapY()
            local selectCount = self._selectHero[player:GetID()]
            local enemy       = {}
            enemy.actor       = player
            enemy.len         = squLen( fMapX - pMapX, fMapY - pMapY ) 
            enemy.selectCount = selectCount and selectCount or 0

            enemyCount = enemyCount + 1
            enemyVec[enemyCount] = enemy
        end
    end

    if enemyCount > 0 then
        tSort( enemyVec, sort_player )
        
        local enemy    = enemyVec[1]
        local target   = enemy.actor
        local targetID = target:GetID()

        self._selectHero[targetID] = enemy.selectCount + 1

        local inputProxy = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
        inputProxy:SetTargetID( targetID, global.MMO.SELETE_TARGET_TYPE_FIND )
    else
        if systemTips then
            global.Facade:sendNotification( global.NoticeTable.SystemTips, GET_STRING( 800403 ) )
        end

        if imgNotice then
            self:createCircle( "player.png" )
        end
    end

end

function QuickSelectMediator:onClear()
    self._selectPlayer  = {}
    self._selectMonster = {}
    self._selectHero    = {}
end

function QuickSelectMediator:onActorOutOfView(data)
    local actorID = data.actorID

    self._selectPlayer[actorID]  = nil
    self._selectMonster[actorID] = nil
    self._selectHero[actorID]    = nil
end

function QuickSelectMediator:createCircle( imgName )
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    local lastImg = mainPlayer:GetNode():getChildByTag( imgTag )
    if not lastImg then
        local img = ccui.ImageView:create()
        img:loadTexture( global.MMO.PATH_RES_PRIVATE .. "quick_select/" .. imgName , 0 )

        img:setScale( 1.8 )
        img:setTag( imgTag )
        img:runAction( cc.Sequence:create(  cc.Repeat:create( cc.Sequence:create( cc.FadeTo:create( 0.4, 70 ), cc.FadeTo:create( 0.4, 255 ) ), 1 ), 
                                            cc.FadeTo:create( 0.4, 0 ),
                                            cc.RemoveSelf:create() ) )
        mainPlayer:GetNode():addChild( img, -1 )
    end
end


return QuickSelectMediator
