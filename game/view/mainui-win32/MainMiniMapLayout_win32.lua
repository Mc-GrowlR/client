local MainMiniMapLayout = class("MainMiniMapLayout", function() return cc.Node:create() end)

local Res_path    = global.MMO.PATH_RES_PRIVATE .. "main/"
local Res_Point_1 = Res_path .. "miniMap/point_1.png"
local Res_Point_2 = Res_path .. "miniMap/point_2.png"
local Res_Point_3 = Res_path .. "miniMap/point_3.png"

local TRemove = table.remove
local TInsert = table.insert

function MainMiniMapLayout:ctor()
    self._status        = 0         -- 0不显示 1玩家在中心点 2显示全地图 3打开小地图

    self._actorCounts   = {}        -- 位置ID 计数
    self._actorPoints   = {}        -- 位置点对象
    self._actorPosIDs   = {}        -- actorID = 位置ID

    self._pointCache    = {}
    self._released      = false
end

function MainMiniMapLayout.create(...)
    local layout = MainMiniMapLayout.new()
    if layout:Init(...) then
        return layout
    end
    return nil
end

function MainMiniMapLayout:Init()
    self._quickUI = ui_delegate(self)

    self:InitGUI()
    self:InitMiniMap()

    self:InitEditMode()

    return true
end

function MainMiniMapLayout:InitGUI()
    GUI.ATTACH_MAINMINIMAP = self

    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_MINIMAP_WIN32)
    local meta = {}
    meta.ChangeStatus = function (status)
        self:ChangeStatus(status)
    end
    meta.UpdateMapShow = function ()
        self:UpdateMiniMap()
        self:UpdateMiniMapPos()
        self:UpdateActorPoints()
    end
    meta.GetMiniMapSize = function ()
        return self._minimapSize
    end
    meta.__index = meta
    setmetatable(MainMiniMap, meta)
    MainMiniMap.main()
    
    self._miniScaleX = self._quickUI.Image_minimap:getScaleX()
    self._miniScaleY = self._quickUI.Image_minimap:getScaleY()

    self._quickUI.Image_minimap:setVisible(false)
    self._quickUI.Node_player:setVisible(false)
end

function MainMiniMapLayout:InitEditMode()
    local items = 
    {
        "Image_mapFlag",
        "Text_mouse_pos",
        "Panel_minimap",
    }
    for _, widgetName in ipairs(items) do
        if self._quickUI[widgetName] then
            self._quickUI[widgetName].editMode = 1
        end
    end
end

function MainMiniMapLayout:InitMiniMap()
    -- actor 白点 闪烁
    local actorPoint = ccui.ImageView:create()
    self._quickUI.Node_player:addChild(actorPoint)
    actorPoint:loadTexture(Res_path .. "miniMap/point_main.png")
    actorPoint:ignoreContentAdaptWithSize(false)
    actorPoint:setContentSize(cc.size(4, 4))
    actorPoint:runAction(cc.RepeatForever:create(cc.Blink:create(0.8, 1)))

end

function MainMiniMapLayout:ChangeStatus(status)
    self._status = status
    self._limitSize = MainMiniMap._minimapSize[self._status] or cc.size(110, 110)
    SLBridge:onLUAEvent(LUA_EVENT_PCMINIMAP_STATUS_CHANGE, status)
end

function MainMiniMapLayout:OnEventTag()
    local status = MainMiniMap and MainMiniMap.GetNextStatus()
    self:ChangeStatus(status)
end

function MainMiniMapLayout:IsEnableMiniMap()
    local MapProxy  = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local miniMapID = MapProxy:GetMiniMapID()
    if not miniMapID or miniMapID == 0 then
        return false
    end
    return MapProxy:CheckMiniMapAble()
end

function MainMiniMapLayout:UpdateMiniMap()
    if self._status == 0 or self._status == 3 then
        return nil
    end

    local isEnable = MainMiniMap.IsEnableMiniMap()
    self._quickUI.Panel_minimap:setVisible(isEnable)
    if not isEnable then
        return nil
    end

    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local miniMapFile = MapProxy:GetMiniMapFile()
    self._quickUI.Image_minimap:loadTexture(miniMapFile)
    self._quickUI.Image_minimap:ignoreContentAdaptWithSize(true)
    self._quickUI.Image_minimap:setVisible(true)
    self._quickUI.Node_player:setVisible(true)
    
    if self._status == 2 then
        self._quickUI.Image_minimap:ignoreContentAdaptWithSize(false)
        self._quickUI.Image_minimap:setContentSize(self._limitSize)
    end
    self._minimapSize = self._quickUI.Image_minimap:getContentSize()
end

function MainMiniMapLayout:UpdateMiniMapPos()
    if self._status == 0 or self._status == 3 then
        return nil
    end
    local isEnable = MainMiniMap.IsEnableMiniMap()
    if not isEnable then
        return nil
    end
    local actor = global.gamePlayerController:GetMainPlayer()
    if not actor then
        return nil
    end
    local mapWidth = global.sceneManager:GetMapWidthInPixel()
    local mapHeight = global.sceneManager:GetMapHeightInPixel()
    if not self._minimapSize then
        return nil
    end
    
    local worldPos = actor:getPosition()
    local worldX = worldPos.x
    local worldY = -worldPos.y
    local ratioX = self._minimapSize.width / mapWidth
    local ratioY = self._minimapSize.height / mapHeight
    
    local function calcMiniMap()
        local minimapX = worldX * -ratioX
        local minimapY = (mapHeight - worldY) * -ratioY
        minimapX = minimapX + self._limitSize.width / 2
        minimapY = minimapY + self._limitSize.height / 2
        minimapX = math.max(minimapX, -(self._minimapSize.width - self._limitSize.width))
        minimapX = math.min(minimapX, 0)
        minimapY = math.max(minimapY, -(self._minimapSize.height - self._limitSize.height))
        minimapY = math.min(minimapY, 0)
        self._quickUI.Image_minimap:setPosition({x = minimapX, y = minimapY})
    end
    
    local function calcPlayerPos()
        local playerX = self._limitSize.width / 2
        local playerY = self._limitSize.height / 2
        local minimapX = worldX * ratioX
        local minimapY = (mapHeight - worldY) * ratioY
        
        -- 校正X
        if minimapX < self._limitSize.width / 2 then
            playerX = minimapX
        elseif minimapX > self._minimapSize.width - self._limitSize.width / 2 then
            playerX = self._limitSize.width - (self._minimapSize.width - minimapX)
        end
        
        -- 校正Y
        if minimapY < self._limitSize.height / 2 then
            playerY = minimapY
        elseif minimapY > self._minimapSize.height - self._limitSize.height / 2 then
            playerY = self._limitSize.height - (self._minimapSize.height - minimapY)
        end
        
        self._quickUI.Node_player:setPosition({x = playerX, y = playerY})
    end
    
    calcMiniMap()
    calcPlayerPos()
end

function MainMiniMapLayout:OnChangeScene()
    self:UpdateMiniMap()
    self:UpdateMiniMapPos()
    self:CleanupActorPoints()
    self:InitActorPoints()
end

function MainMiniMapLayout:OnPlayerMoveCompleted()
    self:UpdateMiniMapPos()
end

function MainMiniMapLayout:OnMainPlayerInit()
    self:ChangeStatus(self._status)
end

function MainMiniMapLayout:OnMinimapDownloadSuccess(dMinimapID)
    local MapProxy  = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local minimapID = MapProxy:GetMiniMapID()

    if minimapID == dMinimapID and MapProxy:CheckMiniMapAble() then
        self:UpdateMiniMap()
        self:UpdateMiniMapPos()
    end
end

function MainMiniMapLayout:CalcMiniMapPos(mapPos)
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData or not self._minimapSize then
        return cc.p(0, 0)
    end
    local scaleX = self._miniScaleX
    local scaleY = self._miniScaleY
    local posX   = mapPos.x / mapData:getMapDataCols() * (self._minimapSize.width / 1)
    local posY   = (1 - mapPos.y / mapData:getMapDataRows()) * (self._minimapSize.height / 1)
    
    return cc.p(posX, posY)
end

function MainMiniMapLayout:CleanupActorPoints()
    for i,v in ipairs(self._quickUI.Node_actors:getChildren()) do
        v:retain()
        v:removeFromParent()
        table.insert(self._pointCache, v)
    end
    self._actorPoints = {}
    self._actorCounts = {}
    self._actorPosIDs = {}
end

function MainMiniMapLayout:InitActorPoints()
    local playerList, nPlayer = global.playerManager:FindPlayerIDInCurrViewField()
    for i = 1, nPlayer do
        local actor = global.actorManager:GetActor(playerList[i])
        if actor then
            self:AddActorPoint(actor)
        end
    end

    local npcList, nNpc = global.npcManager:FindNpcIDInCurrViewField()
    for i = 1, nNpc do
        local actor = global.actorManager:GetActor(npcList[i])
        if actor then
            self:AddActorPoint(actor)
        end
    end

    local monsterList, nMonster = global.monsterManager:FindMonsterIDInCurrViewField(true)
    for i = 1, nMonster do
        local actor = global.actorManager:GetActor(monsterList[i])
        if actor then
            self:AddActorPoint(actor)
        end
    end
end

function MainMiniMapLayout:UpdateActorPoints()
    for actorID, posID in pairs(self._actorPosIDs) do
        local actor = global.actorManager:GetActor(actorID)
        if actor then
            local actorPoint = self._actorPoints[posID]
            if actorPoint then
                local mapPos = cc.p(actor:GetMapX(), actor:GetMapY())
                local miniMapPos = self:CalcMiniMapPos(mapPos)
                actorPoint:setPosition(miniMapPos)
            end
        end
    end
end

function MainMiniMapLayout:UpdateActorPoint(actor)
    -- 移除上个位置
    self:RmvActorPoint(actor)

    -- 处理新位置
    local posID = self:GetActorPointPosID(actor)
    local actorID = actor:GetID()

    local actorPoint = self._actorPoints[posID]
    if actorPoint then
        if not self._actorCounts[posID] then
            self._actorCounts[posID] = 0
        end
        self._actorCounts[posID] = self._actorCounts[posID] + 1
        self._actorPosIDs[actorID] = posID
    else
        self:CreateActorPoint(actor, posID)
        self._actorCounts[posID] = 1
        self._actorPosIDs[actorID] = posID
    end
end

function MainMiniMapLayout:CreateActorPoint(actor, posID)
    local actorPoint = self:GetActorPointCache()
    self._actorPoints[posID] = actorPoint

    local path = actor:IsMonster() and Res_Point_1 or (actor:IsPlayer() and Res_Point_2 or Res_Point_3)
    actorPoint:loadTexture(path)

    local z = actor:IsMonster() and 1 or (actor:IsPlayer() and 2 or 3)

    actorPoint:ignoreContentAdaptWithSize(false)
    actorPoint:setContentSize(cc.size(5, 5))
    actorPoint:setLocalZOrder(z)
    self._quickUI.Node_actors:addChild(actorPoint)

    local mapPos = cc.p(actor:GetMapX(), actor:GetMapY())
    local miniMapPos = self:CalcMiniMapPos(mapPos)
    actorPoint:setPosition(miniMapPos)
end

function MainMiniMapLayout:UpdateActorPoint(actor)
    -- 移除上个位置
    self:RmvActorPoint(actor)

    -- 处理新位置
    local posID = self:GetActorPointPosID(actor)
    local actorID = actor:GetID()

    local actorPoint = self._actorPoints[posID]
    if actorPoint then
        if not self._actorCounts[posID] then
            self._actorCounts[posID] = 0
        end
        self._actorCounts[posID] = self._actorCounts[posID] + 1
        self._actorPosIDs[actorID] = posID
    else
        self:CreateActorPoint(actor, posID)
        self._actorCounts[posID] = 1
        self._actorPosIDs[actorID] = posID
    end
end

function MainMiniMapLayout:OnMainPlayerRevive()
    self:UpdateMiniMap()
    self:UpdateMiniMapPos()
end

function MainMiniMapLayout:AddActorPoint(actor)
    if nil == actor then
        return false
    end

    if not (actor:IsMonster() or actor:IsPlayer() or actor:IsNPC()) then
        return false
    end

    -- 死亡
    if actor:IsDie() or actor:IsDeath()then
        return false
    end

    -- 怪物 出生和钻回地下
    if actor:IsMonster() and (actor:IsBorn() or actor:IsCave()) then
        return false
    end

    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if nil == mainPlayerID then
        return false
    end

    if actor:GetID() == mainPlayerID then
        self:OnMainPlayerRevive()
        return false
    end

    -- 自己的宝宝不显示
    if actor:GetMasterID() == mainPlayerID then
        return false
    end

    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if false == MapProxy:CheckMiniMapAble() then
        return false
    end

    self:UpdateActorPoint(actor)    
end

function MainMiniMapLayout:GetActorPointPosID(actor)
    local px = actor:GetMapX()
    local py = actor:GetMapY()
    local z  = actor:IsMonster() and 1 or (actor:IsMonster() and 2 or 3)
    local posID = z * 10000000000 + KEY_MAP_XY(px, py)
    return posID
end

function MainMiniMapLayout:RmvActorPoint(actor)
    if nil == actor then
        return false
    end

    local actorID = actor:GetID()

    local posID = self._actorPosIDs[actorID]
    if not posID then
        return false
    end
    self._actorPosIDs[actorID] = nil

    if not self._actorCounts[posID] then
        return false
    end

    self._actorCounts[posID] = self._actorCounts[posID] - 1
    
    if self._actorCounts[posID] > 0 then
        return false
    end
    self._actorCounts[posID] = nil

    local actorPoint = self._actorPoints[posID]
    
    if not actorPoint then
        return false
    end

    if not tolua.isnull(actorPoint) then
        actorPoint:removeFromParent()
    end

    self._actorPoints[posID] = nil
end

function MainMiniMapLayout:GetActorPointCache()
    if #self._pointCache > 0 then
        return TRemove(self._pointCache, #self._pointCache)
    end

    local pointCell = ccui.ImageView:create()
    return pointCell
end

function MainMiniMapLayout:OnReleaseMemory()
    for key, value in pairs(self._pointCache) do
        value:autorelease()
    end
    self._pointCache = {}
    self._released   = true
end

return MainMiniMapLayout
