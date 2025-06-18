local DropItemInOfViewCommand = class('DropItemInOfViewCommand', framework.SimpleCommand)
local proxyUtils              = requireProxy( "proxyUtils" )


function DropItemInOfViewCommand:ctor()
end

function DropItemInOfViewCommand:execute(notification)
    local data    = notification:getBody()
    local actorID = data.actorID
    local name  = data.itemName
    local color = data.color or 255
    local count = data.count
    if count and count > 1 then
        name = name .. "x" .. count
    end

    local actor = global.actorManager:GetActor( actorID )
    if not actor then
        return 
    end

    actor:SetKeyValue("InView", true)

    SetActorAttrByID( actorID, global.MMO.ACTOR_ATTR_PICK, true )
    
    -- hud
    local hudParam = {}
    hudParam.Name  = name
    hudParam.Color = string.gsub(GET_COLOR_BYID(color), "#", "0x") or global.MMO.DefaultColor 
    SetActorName(actor, hudParam)
    global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actor:GetID(), hudParam = hudParam } )

    local pickEnable = proxyUtils:AutoPickItemEnable( actor, nil )
    if pickEnable then
        local autoProxy = global.Facade:retrieveProxy( global.ProxyTable.Auto )
        autoProxy:SetPickItemFlag( true )
    end

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local typeIndex = actor:GetTypeIndex()
    local guangzhu,front = ItemConfigProxy:GetItemGuangZhu(typeIndex)
    if tonumber(guangzhu) and tonumber(guangzhu) > 0 then
        local data =
        {
            actorID = actorID,
            sfxID   = tonumber(guangzhu),
            frame   = 0,
            speed   = 1,
            count   = 0,
            front   = front,
        }
        global.ActorEffectManager:AddEffect(data)
    end

    if data.jipin == 1 then
        local data =
        {
            actorID = actorID,
            sfxID   = global.MMO.SFX_DROP_ITEM_JP,
            frame   = 0,
            speed   = 1,
            count   = 0,
            front   = true,
        }
        global.ActorEffectManager:AddEffect(data)
    end

    -- 默认闪光特效
    local data =
    {
        actorID = actorID,
        sfxID   = global.MMO.SFX_DROP_ITEM_NORAML,
        frame   = 0,
        speed   = 1,
        count   = 0,
        front   = true,
    }
    global.ActorEffectManager:AddEffect(data)
end

return DropItemInOfViewCommand
