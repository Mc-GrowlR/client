local sceneGraph = class("sceneGraph")

function sceneGraph:ctor()
    self.mC2dxScene = 0
    self.mFunctionalSceneNode = {}
end

function sceneGraph:destory()
end

function sceneGraph:Inst()
    if not sceneGraph.instance then
        sceneGraph.instance = sceneGraph.new()
    end

    return sceneGraph.instance
end
-----------------------------------------------------------------------------
function sceneGraph:LoadGraph(fileName)
    local scene = requireExport(fileName).create()
    if nil == scene or nil == scene.root then
        return -1
    end
    local rootNode = scene.root
    self.mC2dxScene = cc.Scene:create() --cocos2d::Scene::create()
    self.mC2dxScene:addChild( rootNode, 1, 9999 )

    self.mFunctionalSceneNode[global.MMO.NODE_ROOT]                     = rootNode

    self.mFunctionalSceneNode[global.MMO.NODE_GAME_WORLD]               = rootNode:getChildByTag( 10023 ) 
    self.mFunctionalSceneNode[global.MMO.NODE_MAP]                      = rootNode:getChildByTag( 10023 ):getChildByTag( 10003 )
    self.mFunctionalSceneNode[global.MMO.NODE_MAP_SLICE]                = rootNode:getChildByTag( 10023 ):getChildByTag( 10003 ):getChildByTag( 10006 )
    self.mFunctionalSceneNode[global.MMO.NODE_SKILL_BEHIND]             = rootNode:getChildByTag( 10023 ):getChildByTag( 10034 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR]                    = rootNode:getChildByTag( 10023 ):getChildByTag( 10004 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR_SHADOW]             = rootNode:getChildByTag( 10023 ):getChildByTag( 10004 ):getChildByTag( 10007 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR_CLONE_SHADOW]       = rootNode:getChildByTag( 10023 ):getChildByTag( 10004 ):getChildByTag( 10030 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR_NPC_SHADOW]         = rootNode:getChildByTag( 10023 ):getChildByTag( 10004 ):getChildByTag( 10030 ):getChildByTag( 10031 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR_MONSTER_SHADOW]     = rootNode:getChildByTag( 10023 ):getChildByTag( 10004 ):getChildByTag( 10030 ):getChildByTag( 10032 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR_PLAYER_SHADOW]      = rootNode:getChildByTag( 10023 ):getChildByTag( 10004 ):getChildByTag( 10030 ):getChildByTag( 10033 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR_SFX_BEHIND]         = rootNode:getChildByTag( 10023 ):getChildByTag( 10004 ):getChildByTag( 10016 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR_SPRITE]             = rootNode:getChildByTag( 10023 ):getChildByTag( 10004 ):getChildByTag( 10008 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR_SFX_FRONT]          = rootNode:getChildByTag( 10023 ):getChildByTag( 10004 ):getChildByTag( 10010 )
    self.mFunctionalSceneNode[global.MMO.NODE_MAP_OBJ]                  = rootNode:getChildByTag( 10023 ):getChildByTag( 10035 )
    self.mFunctionalSceneNode[global.MMO.NODE_SKILL]                    = rootNode:getChildByTag( 10023 ):getChildByTag( 10015 )
    self.mFunctionalSceneNode[global.MMO.NODE_ACTOR_HUD]                = rootNode:getChildByTag( 10023 ):getChildByTag( 10009 )
    self.mFunctionalSceneNode[global.MMO.NODE_DAMAGE]                   = rootNode:getChildByTag( 10023 ):getChildByTag( 10017 )
    self.mFunctionalSceneNode[global.MMO.NODE_UI]                       = rootNode:getChildByTag( 10005 )
    self.mFunctionalSceneNode[global.MMO.NODE_UI_NORMAL]                = rootNode:getChildByTag( 10005 ):getChildByTag( 10011 )
    self.mFunctionalSceneNode[global.MMO.NODE_UI_TOPMOST]               = rootNode:getChildByTag( 10005 ):getChildByTag( 10012 )

    -- init hud root
    global.HUDManager:Init()

    return 1
end


function sceneGraph:GetSceneNode(nodeID)
    if nodeID < global.MMO.NODE_NUM then
        return self.mFunctionalSceneNode[nodeID]
    end

    return nil
end

function sceneGraph:GetC2dxScene()
    return self.mC2dxScene
end


-- Some specialized functions
function sceneGraph:GetGameWorldRoot()
    return self:GetSceneNode( global.MMO.NODE_GAME_WORLD )
end
function sceneGraph:GetActorSpriteNode()
    return self:GetSceneNode( global.MMO.NODE_ACTOR_SPRITE )
end
function sceneGraph:GetMapSlice()
    return self:GetSceneNode( global.MMO.NODE_MAP_SLICE )
end
function sceneGraph:GetUiNormal()
    return self:GetSceneNode( global.MMO.NODE_UI_NORMAL )
end
function sceneGraph:Cleanup()
    self.mC2dxScene = 0
    self.mFunctionalSceneNode = {}
end

return sceneGraph
