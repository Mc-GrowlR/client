local DebugMediator  = requireMediator( "DebugMediator" )
local tileSceneManagerHelper = class("tileSceneManagerHelper", DebugMediator)
local SceneDefine = require("scene/sceneDefine")

tileSceneManagerHelper.Name = "tileSceneManagerHelper"

local AtlasSplitConfigs = SceneDefine.AtlasSplitConfigs
local FrameOffset     = SceneDefine.FrameOffset
local ObjMaxOffsetY   = SceneDefine.ObjMaxOffsetY

local MapGridWidth  = global.MMO.MapGridWidth
local MapGridHeight = global.MMO.MapGridHeight

function tileSceneManagerHelper:ctor()
    tileSceneManagerHelper.super.ctor(self)

    self._mapDataPath = nil
end

function tileSceneManagerHelper:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.InitedWorldTree,
        noticeTable.BindMainPlayer,
        noticeTable.MainPlayerActionEnded,
        noticeTable.MainPlayerActionProcess,
        noticeTable.ReleaseMemory,
        noticeTable.ChangeScene,
        noticeTable.ReloadMap,
        noticeTable.SceneFollowMainPlayer,
    }
end

function tileSceneManagerHelper:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData  = notification:getBody()

    if noticeTable.InitedWorldTree == noticeName then
        self:onInitedWorldTree()

    elseif noticeTable.BindMainPlayer == noticeName then
        self:onBindMainPlayer( noticeData )

    elseif noticeTable.MainPlayerActionEnded == noticeName then
        self:onMainPlayerActionEnded( noticeData )

    elseif noticeTable.MainPlayerActionProcess == noticeName then
        self:onMainPlayerActionProcess( noticeData )

    elseif noticeTable.ChangeScene == noticeName then
        self:onEnterMap( noticeData )

    elseif noticeTable.SceneFollowMainPlayer == noticeName then
        self:onSceneFollowMainPlayer( noticeData )

    elseif noticeTable.ReloadMap == noticeName then
        self:reloadAllTile()

    elseif noticeTable.ReleaseMemory == noticeName then
        self:Cleanup()
    end
end

function tileSceneManagerHelper:onInitedWorldTree()
    if global.sceneManager then
        local sceneManager = global.sceneManager

        local mapRoot = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_MAP )
        local actRoot = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_ACTOR_SPRITE )
        local objRoot = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_MAP_OBJ )
        local tileRootNode   = cc.Node:create()
        local smtileRootNode = cc.Node:create()
        local objRootNode    = actRoot
        local miniRootNode   = cc.Node:create()
        local debugRootNode  = cc.Node:create()
        mapRoot:addChild(tileRootNode)
        mapRoot:addChild(smtileRootNode)
        mapRoot:addChild(miniRootNode, -1)
        objRoot:addChild(debugRootNode)
        sceneManager:SetRootNode(tileRootNode, smtileRootNode, objRootNode, miniRootNode, debugRootNode)


        local camera = global.gameMapController:GetViewCamera()
        sceneManager:SetCamera(camera)


        if AtlasSplitConfigs then
            for atlasType, splitConfig in pairs(AtlasSplitConfigs) do
                for area, splitSize in pairs(splitConfig) do
                    sceneManager:SetAtlasSplit( atlasType - 1, area, splitSize )
                end
            end
        end

        if ObjMaxOffsetY then
            for mapID, enlargeY in pairs(ObjMaxOffsetY) do
                sceneManager:SetObjEnlargeY(mapID, enlargeY)
            end
        end

        if FrameOffset then
            for area, offsets in pairs(FrameOffset) do
                for imgIdx, offset in pairs(offsets) do
                    sceneManager:SetFrameAnimOffset(area, imgIdx, offset.x, offset.y)
                end
            end
        end

        sceneManager:SetLoadParam(1, 180)
        sceneManager:SetLoadMapDataCallback(handler(self, self.onLoadMapDataCallback))
        sceneManager:SetLoadMiniCallback(handler(self, self.onLoadMiniCallback))
        sceneManager:SetOnOpenDoorFunc(handler(self, self.onOpenDoorCallback))
        sceneManager:SetOnCloseDoorFunc(handler(self, self.onCloseDoorCallback))
    end
end

function tileSceneManagerHelper:onBindMainPlayer(player)
    self:followPlayer( player)
end

function tileSceneManagerHelper:onSceneFollowMainPlayer()
    self:followMainPlayer()
end

function tileSceneManagerHelper:onMainPlayerActionEnded(act)
    if IsMoveAction(act) then
        local player = global.gamePlayerController:GetMainPlayer()
        self:followPlayer( player )
    end
end

function tileSceneManagerHelper:onMainPlayerActionProcess(action)
    local mmo = global.MMO
    if mmo.ACTION_DASH == action or mmo.ACTION_ONPUSH == action or mmo.ACTION_TELEPORT == action or mmo.ACTION_ZXC then
        self:followMainPlayer()
    end
end

function tileSceneManagerHelper:onEnterMap(mapID)
    if global.sceneManager then
        if global.L_GameEnvManager:GetEnvDataByKey("isCloudLogin") then 
            if global.sceneManager.UnloadAllAtlas then
                global.sceneManager:UnloadAllAtlas() 
            end

            if global.sceneManager.UnloadSpriteCache then
                global.sceneManager:UnloadSpriteCache() 
            end
        end
        local mapDataPath = string.format("scene/map/%s.map", tostring(mapID))
        local mapMiniPath = ""
        local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        if mapProxy then
            local miniFile = mapProxy:GetMiniMapFile()
            if miniFile then
                mapMiniPath = miniFile
            end

            local mapDataID = mapProxy:GetMapDataID()
            print("mapDataIDDDDDDDDDDDDDDD", mapDataID)
            if mapDataID then
                mapDataPath = string.format("scene/map/%s.map", tostring(mapDataID))
            end
        end

        if self._mapDataPath ~= mapDataPath then
            --清理光圈  因为changeScene 和 Load_Success不一定哪个先 所以放这
            global.darkNodeManager:clearAllNodes(true)
            global.sceneManager:LoadMap(mapID, mapDataPath, mapMiniPath)
        end
        self._mapDataPath = mapDataPath
    end

    self:followMainPlayer()
end

function tileSceneManagerHelper:reloadAllTile()
    if global.sceneManager then
        global.sceneManager:reloadAllTile()

        self:followMainPlayer()
    end
end

function tileSceneManagerHelper:Cleanup()
    if global.sceneManager then
        global.sceneManager:Cleanup()
    end
end

function tileSceneManagerHelper:followMainPlayer()
    local player = global.gamePlayerController:GetMainPlayer()
    self:followPlayer(player)
end

function tileSceneManagerHelper:followPlayer(player)
    if global.sceneManager and player then
        global.sceneManager:followPlayer(cc.p(player:getPosition()))
    end
    if global.darkNodeManager and player then 
        global.darkNodeManager:followPlayer(cc.p(player:getPosition()))
    end
end

function tileSceneManagerHelper:onLoadMapDataCallback(mapID, mapWidthInPixel, mapHeightInPixel)
    print("onLoadMapDataCallback", mapID, mapWidthInPixel, mapHeightInPixel)

    global.gameMapController:calcMapFollowParam( mapWidthInPixel, mapHeightInPixel )
    self:followMainPlayer()

    global.Facade:sendNotification(global.NoticeTable.MapData_Load_Success)
end
function tileSceneManagerHelper:onLoadMiniCallback(mapID, miniName)
    print("onLoadMiniCallback", mapID, miniName)

    local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if mapProxy then
        local miniMapID = mapProxy:GetMiniMapID()
        global.Facade:sendNotification(global.NoticeTable.MiniMap_Download_Success, miniMapID)
    end
end
function tileSceneManagerHelper:onOpenDoorCallback(mapX, mapY)
    print("onOpenDoorCallback", mapX, mapY)
end
function tileSceneManagerHelper:onCloseDoorCallback(mapX, mapY)
    print("onCloseDoorCallback", mapX, mapY)
end
--------------------------------------------------------------

local tileSceneManager = tileSceneManager
if tileSceneManager then
    function tileSceneManager:destory()
        global.Facade:removeMediator( tileSceneManagerHelper.NAME )
    end

    function tileSceneManager:WorldPos2MapPos(worldPos )
        return math.floor(worldPos.x / MapGridWidth), math.floor(-worldPos.y / MapGridHeight)
    end

    function tileSceneManager:MapPos2WorldPos(mapX, mapY, centerOfGrid )
        local worldPos = cc.p( mapX * MapGridWidth, -mapY * MapGridHeight )

        if centerOfGrid then
            worldPos.x = worldPos.x + MapGridWidth * 0.5
            worldPos.y = worldPos.y - MapGridHeight * 0.5
        end

        return worldPos
    end
end

return tileSceneManagerHelper
