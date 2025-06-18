local AutoMoveBeginCommand = class('AutoMoveBeginCommand', framework.SimpleCommand)

function AutoMoveBeginCommand:ctor()
end

function AutoMoveBeginCommand:execute(notification)
    local facade        = global.Facade
    local data          = notification:getBody()

    print("---------------------- auto move begin")

    local mapProxy      = facade:retrieveProxy(global.ProxyTable.Map)
    local autoProxy     = facade:retrieveProxy(global.ProxyTable.Auto)
    local inputProxy    = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)


    local destMapID     = data.mapID or mapProxy:GetMapID()
    local destX         = data.x
    local destY         = data.y
    local priority      = data.priority or global.MMO.INPUT_PRIORITY_SYSTEM
    local autoMoveType  = data.autoMoveType or global.MMO.AUTO_MOVE_TYPE_TARGET

    -- check param error
    if nil == destX or nil == destY then
        return nil
    end
    if destMapID ~= mapProxy:GetMapID() then
        return nil
    end

    -- clear state
    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    autoProxy:ClearAutoLock()
    autoProxy:ClearAllState()
    autoProxy:ClearAFKState()
    autoProxy:ClearPickState()
    
    -- mark auto move state
    autoProxy:SetIsAutoMoveState(true)
    autoProxy:SetAutoInputPriority(priority)
    
    -- check auto target
    data.targetType     = data.targetType or global.MMO.ACTOR_NONE
    data.targetIndex    = data.targetIndex or global.MMO.AUTO_FIND_TARGET_NONE
    autoProxy:SetAutoTarget(data)
    
    
    -- check auto find target
    local fixRange      = nil
    if data.targetType ~= global.MMO.ACTOR_NONE then
        -- fix move by target type
        if global.MMO.ACTOR_NPC == data.targetType then
            fixRange    = SL:GetMetaValue("GAME_DATA","AutoMoveRange_NPC")
        
        elseif global.MMO.ACTOR_MONSTER == data.targetType then
            fixRange    = SL:GetMetaValue("GAME_DATA","AutoMoveRange_Monster")
        
        elseif global.MMO.ACTOR_COLLECTION == data.targetType then
            fixRange    = SL:GetMetaValue("GAME_DATA","AutoMoveRange_Collection")
        end
    end
    
    if data.autoMoveType == global.MMO.AUTO_MOVE_TYPE_CHAT then 
        fixRange = 2
    end
    
    -- tips
    SLBridge:onLUAEvent(LUA_EVENT_AUTOMOVE_TIPS_SHOW, true)
    SLBridge:onLUAEvent(LUA_EVENT_AUTOMOVEBEGIN, {mapID = destMapID, x = destX, y = destY})
    ssr.ssrBridge:OnAutoMoveBegin({mapID = destMapID, x = destX, y = destY})
    
    -- push last
    autoProxy:PushMove({mapID = destMapID, x = destX, y = destY, range = fixRange})
    
    -- input front move pos
    local movePos       = autoProxy:PopMove()
    facade:sendNotification(global.NoticeTable.InputMove, movePos)
    
    -- auto target state:begin
    autoProxy:SetTargetState(global.MMO.AUTO_TARGET_STATE_BEGIN)

    -- 通知服务器
    local autoTarget = autoProxy:GetAutoTarget()
    if autoTarget.autoMoveType == global.MMO.AUTO_MOVE_TYPE_MINIMAP or autoTarget.autoMoveType == global.MMO.AUTO_MOVE_TYPE_SERVER then
        if inputProxy:GetPathPointSize() > 0 then
            autoProxy:RequestAutoMoveNotify(global.MMO.AUTO_MOVE_START, destX, destY)
        end
    end
end


return AutoMoveBeginCommand
