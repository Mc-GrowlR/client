local DropItemOutOfViewCommand = class('DropItemOutOfViewCommand', framework.SimpleCommand)
requireProxy("actorUtils")

function DropItemOutOfViewCommand:ctor()
end

function DropItemOutOfViewCommand:execute(notification)
    local data = notification:getBody()
    local actorID = data.actorID
    
    -- clear auto pick item ID
    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if autoProxy:GetPickItemID() == actorID then
        autoProxy:SetPickItemID(nil)
        autoProxy:SetPickBeginTime(nil)

        -- 清理前往拾取物的路径
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        inputProxy:SetPathFindPoints({})
    end

    local dropActor = global.actorManager:GetActor(actorID)
    if dropActor then
        local mapX        = dropActor:GetMapX()
        local mapY        = dropActor:GetMapY()
        local dItems = global.dropItemManager:FindDropItemAllInMapXY(mapX, mapY)
        if dItems and next(dItems) then
            for _, dropItem in pairs(dItems) do
                dropItem:ResetPickState()
                dropItem:ResetPickTimeout()
            end
        end
    end


    -- cleanup actor attr
    ClenupActorAttrByID(actorID)
end


return DropItemOutOfViewCommand