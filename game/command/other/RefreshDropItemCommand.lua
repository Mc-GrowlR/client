local RefreshDropItemCommand = class('RefreshDropItemCommand', framework.SimpleCommand)

function RefreshDropItemCommand:ctor()
end

function RefreshDropItemCommand:execute(notification)
    local itemID = notification:getBody()
    if not itemID then
        return nil
    end

    local dropItem = global.actorManager:GetActor(itemID)
    if not dropItem then
        return nil
    end

    local ownerID = dropItem:GetOwnerID()
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if dropItem:CheckOwnerID(mainPlayerID) then
        local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        autoProxy:SetPickItemFlag(true)
    end
end


return RefreshDropItemCommand