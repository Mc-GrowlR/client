local AutoFindCollectionCommand = class('AutoFindCollectionCommand', framework.SimpleCommand)


local function squLen( x, y )
  return x * x + y * y
end

function AutoFindCollectionCommand:ctor()
end

function AutoFindCollectionCommand:execute(notification)
    local player       = global.gamePlayerController:GetMainPlayer()
    if not player then
        return nil
    end
    
    local facade       = global.Facade
    local inputProxy   = facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
    local autoProxy    = facade:retrieveProxy( global.ProxyTable.Auto )
    local collectionID = inputProxy:GetTargetID()
    local target       = nil
    local pMapX        = player:GetMapX()
    local pMapY        = player:GetMapY()


    -- check current target's race
    if collectionID then
        target = global.actorManager:GetActor( collectionID )
        if not target or not target:IsCollection() then
            collectionID = nil
            target       = nil
        end
    end

    -- collecting current select
    if not target then
        local cost = global.MMO.MAX_CONST
        local monsterVec, nMonster = global.monsterManager:FindMonsterInCurrViewFieldByRace( global.MMO.ACTOR_RACE_COLLECTION ) 
        for i = 1, nMonster do
            local monster = monsterVec[i]
            if not monster:IsDie() then
                local len = squLen( monster:GetMapX() - pMapX, monster:GetMapY() - pMapY )
                if len < cost then
                    target = monster
                    cost   = len
                end
            end
        end
    end

    -- oh, can't find collection
    -- wait
    if not target then
        -- clear auto state
        facade:sendNotification(global.NoticeTable.ClearAllInputState)
        facade:sendNotification(global.NoticeTable.ClearAllAutoState)
        facade:sendNotification(global.NoticeTable.InputIdle)
        autoProxy:ClearAllState()
        return 
    end

    -- change target
    inputProxy:SetTargetID( target:GetID(), global.MMO.SELETE_TARGET_TYPE_FIND )

    -- check range
    local targetX = target:GetMapX()
    local targetY = target:GetMapY()
    local len     = squLen( targetX - pMapX, targetY - pMapY )
    local range   = (SL:GetMetaValue("GAME_DATA","AutoMoveRange_Collection") or 0) + 1
    local rangeSq = range * range
    if len < rangeSq then
        -- input idle
        facade:sendNotification(global.NoticeTable.ClearAllInputState)
        facade:sendNotification(global.NoticeTable.ClearAllAutoState)
        facade:sendNotification(global.NoticeTable.InputIdle)
        autoProxy:ClearAllState()

        inputProxy:RequestCollect()
    else
        local moveData = 
        {
            x            = targetX,
            y            = targetY,
            targetType   = global.MMO.ACTOR_COLLECTION,
            autoMoveType = global.MMO.AUTO_MOVE_TYPE_TARGET
        }
        facade:sendNotification( global.NoticeTable.AutoMoveBegin, moveData )
    end
end


return AutoFindCollectionCommand
