SLBridge = {}

SLBridge.LUAEvent = {}
function SLBridge:onLUAEvent(eventID, eventData)
    if not SLBridge.LUAEvent[eventID] then
        return
    end

    for eventTag, eventCB in pairs(SLBridge.LUAEvent[eventID]) do
        eventCB(eventData, eventTag)
    end
end

function SLBridge:onEnterWorld()
    SL.NetworkUtil = require("GUI/GUINetworkUtil").new()

    local rootB = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL_BEHIND)
    local rootF = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL)
    GUI._sceneRootNodeB = cc.Node:create()
    rootB:addChild(GUI._sceneRootNodeB)
    GUI._sceneRootNodeB:retain()
    GUI._sceneRootNodeF = cc.Node:create()
    rootF:addChild(GUI._sceneRootNodeF)
    GUI._sceneRootNodeF:retain()
    
    require("GUI/GUINetwork")
    require("GUILayout/GUIUtil")
end

function SLBridge:onLeaveWorld()
    SLBridge:onLUAEvent(LUA_EVENT_LEAVE_WORLD)
    
    package.loaded["GUILayout/GUIUtil"] = nil
    package.loaded["GUI/GUINetwork"] = nil

    GUI.WinLayers = {} -- GUI 界面管理
    GUI.Mediators = {} -- GUI 界面管理

    SLBridge.LUAEvent = {}

    SLHandlerEvent.Events = {}
    SLHandlerEvent.EventDesc = {}
    SLHandlerEvent.PropertyEvents = {}

    SL.FormParam = {}
    SL.LocalStringCache = {}
    SL.LocalStringTimerID = nil
    SL.DigitChangeTimerID = nil

    -- note: 无需removeFromParent，父节点已经被清理了
    GUI._sceneRootNodeB:autorelease()
    GUI._sceneRootNodeB = nil
    GUI._sceneRootNodeF:autorelease()
    GUI._sceneRootNodeF = nil
    GUI._actorRootNode = nil

    local files = SLDefine.LUAFile
    for k, v in pairs(files) do
        package.loaded[v] = nil
    end
end

function SLBridge:CheckLuaEventCleaned()
    if not SLBridge.LUAEvent or not next(SLBridge.LUAEvent) then
        return true
    end
    
    return false
end