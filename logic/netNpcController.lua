local netNpcController = class("netNpcController")

function netNpcController:ctor()
end

function netNpcController:destory()
    if netNpcController.instance then
        netNpcController.instance = nil
    end
end

function netNpcController:Inst()
    if not netNpcController.instance then
        netNpcController.instance = netNpcController.new()
    end

    return netNpcController.instance
end
-----------------------------------------------------------------------------
function netNpcController:handleMessage(msg)

    return -99
end
-----------------------------------------------------------------------------
function netNpcController:AddNetNpcToWorld(param)
    local id     = param.actorID
    local netNpc = global.actorManager:CreateActor(id, global.MMO.ACTOR_NPC, param)
    if nil == netNpc then
        return nil
    end

    netNpc:SetDirection(param.dir or global.MMO.ORIENT_U)
    netNpc:SetAction(param.action or global.MMO.ACTION_IDLE)
    netNpc:SetClothID(param.clothID or 0)

    -- feature
    global.Facade:sendNotification( global.NoticeTable.DelayDirtyFeature, {actorID = id, actor = netNpc})

    return netNpc
end


function netNpcController:Cleanup()
end

return netNpcController