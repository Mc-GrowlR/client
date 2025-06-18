local ShakeSceneCommand = class('ShakeSceneCommand', framework.SimpleCommand)

local ShakeActionTag = 1234

function ShakeSceneCommand:ctor()
end

function ShakeSceneCommand:execute(notification)
    local world_node = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_GAME_WORLD )

    local data = notification:getBody()
    data = data or {}

    self:checkOriginPos( world_node )
    world_node:runAction( self:createAction(data) )
end

function ShakeSceneCommand:checkOriginPos(node)
    if node:getActionByTag( ShakeActionTag ) then
        node:stopActionByTag(ShakeActionTag)
        if node.aShakeOriginPos then
            node:setPosition( node.aShakeOriginPos )
        end

    else
        node.aShakeOriginPos = cc.p( node:getPosition() )
    end
end

function ShakeSceneCommand:createAction(data)
    local time = data.time and data.time * 0.001 or 0.7
    local x = data.distance or 10
    local y = data.distance or 10

    local shake = cc.ActionShake:create( time, x, y )
    shake:setTag( ShakeActionTag )

    return shake
end


return ShakeSceneCommand
