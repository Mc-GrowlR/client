local MainMiniMapLayout = class("MainMiniMapLayout", function() return cc.Node:create() end)

local Res_path    = global.MMO.PATH_RES_PRIVATE .. "main/"
local Res_Point_1 = Res_path .. "miniMap/point_1.png"
local Res_Point_2 = Res_path .. "miniMap/point_2.png"
local Res_Point_3 = Res_path .. "miniMap/point_3.png"

local function squLen( x, y )
    local maxv = math.max(math.abs(x), math.abs(y))
    return maxv * maxv
end

local TRemove = table.remove
local TInsert = table.insert

function MainMiniMapLayout:ctor()
    self._isHide        = false
    self._released      = false
    
    self._actorCounts   = {}        -- 位置ID 计数
    self._actorPoints   = {}        -- 位置点对象
    self._actorPosIDs   = {}        -- actorID = 位置ID
    self._pointCache    = {}

    -- 右上角小地图进入范围显示相关的提示
    self._portals       = {} -- 提示数据
    self._protalRange   = tonumber(SL:GetMetaValue("GAME_DATA","minimap_title_range")) or 60 --检测的格子数
    self._markPortalIdx = nil -- 标记当前正在显示的提示下标
end

function MainMiniMapLayout.create()
    local layout = MainMiniMapLayout.new()
    if layout:Init() then
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

    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_MINIMAP)
    local meta = {}
    meta.CalcMiniMapPos = function(x, y)
        return self:CalcMiniMapPos(cc.p(x, y))
    end
    meta.__index = meta
    setmetatable(MainMiniMap, meta)
    MainMiniMap.main()

    self._miniScaleX = self._quickUI.Image_minimap:getScaleX()
    self._miniScaleY = self._quickUI.Image_minimap:getScaleY()
end

function MainMiniMapLayout:InitMiniMap()
    local icon = ccui.ImageView:create()
    icon:setVisible(false)
    self._icon = icon
    self._quickUI.Node_path:addChild(icon)

    local textName = ccui.Text:create()
    textName:setFontSize(16)
    textName:setFontName(global.MMO.PATH_FONT2)
    textName:setAnchorPoint(cc.p(0.5,0.5))
    self._textName = textName
    self._quickUI.Node_path:addChild(textName)

    -- actor白点
    local actorPoint = ccui.ImageView:create()
    self._quickUI.Node_player:addChild(actorPoint)
    actorPoint:loadTexture(Res_path .. "miniMap/point_main.png")
    actorPoint:ignoreContentAdaptWithSize(false)
    actorPoint:setContentSize(cc.size(4, 4))

    -- 打开小地图
    self._quickUI.Panel_minimap:addClickEventListener(function()
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        if false == MapProxy:CheckMiniMapAble() then
            return false
        end
        local MiniMapMediator = global.Facade:retrieveMediator("MiniMapMediator")
        if MiniMapMediator._layer then
            SL:CloseMiniMap()
        else 
            SL:OpenMiniMap()
        end 
    end)
    self._limitSize = self._quickUI.Panel_minimap:getContentSize()
    self._minimapSize = {width=0, height=0}
    
    
    self:UpdateMapPos()
    self:UpdateMiniMap()
    self:UpdateMiniMapPos()
end

function MainMiniMapLayout:InitEditMode()
    local items = 
    {
        "LayoutClip",
        "Node",
        "Map",
        "MapBG",
        "MapName",
        "MapStatusBG",
        "MapStatus",
        "PlayerPos",
        "MapButton",
        "MapButtonText",
        "PKModelCell",
        "PKModelButton",
        "PKModelButtonText"
    }
    for _, widgetName in ipairs(items) do
        if self._quickUI[widgetName] then
            self._quickUI[widgetName].editMode = 1
        end
    end
end

function MainMiniMapLayout:InitAdapet()
    self:setPositionY(-30)
end

function MainMiniMapLayout:OnMainMiniMapChange(show)
    if MainMiniMap.ChangeShowState then
        MainMiniMap.ChangeShowState(not show)
    end
end

function MainMiniMapLayout:CalcMiniMapPos(mapPos)
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return cc.p(0, 0)
    end

    local posX = mapPos.x / mapData:getMapDataCols() * self._minimapSize.width
    local posY = (1 - mapPos.y / mapData:getMapDataRows()) * self._minimapSize.height
    
    return cc.p(posX, posY)
end

function MainMiniMapLayout:OnChangeScene()
    self:UpdateMapPos()
    self:UpdateMiniMap()
    self:UpdateMiniMapPos()
    self:CleanupActorPoints()
    self:InitActorPoints()
    -- debug
    if _DEBUG and SL:GetMetaValue("GAME_DATA","DebugMapInfoShow") then
        self:SetMapInfoInDebug()
    end
end

function MainMiniMapLayout:SetMapInfoInDebug()
    local MapProxy  = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local mapID     = MapProxy:GetMapID()
    local mapDataID = MapProxy:GetMapDataID()

    if not self._quickUI.Panel_map:getChildByName("DEBUG_MAP_SHOW") then
        local text = ccui.Text:create()
        text:setAnchorPoint(cc.p(0.5, 0.5))
        text:setString(string.format("地图.%s\n资源.%s", mapID, mapDataID))
        text:setTextColor(cc.c3b(255, 255, 0))
        text:setFontSize(18)
        text:setFontName(global.MMO.PATH_FONT2)     
        text:setPosition(cc.p(self._quickUI.Panel_map:getContentSize().width/2, self._quickUI.Panel_map:getContentSize().height/2))
        text:setName("DEBUG_MAP_SHOW")
        text:addTo(self._quickUI.Panel_map)
    else
        local text = self._quickUI.Panel_map:getChildByName("DEBUG_MAP_SHOW")
        text:setString(string.format("地图.%s\n资源.%s", mapID, mapDataID))
    end
end

function MainMiniMapLayout:OnMinimapDownloadSuccess(dMinimapID)
    local MapProxy  = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local minimapID = MapProxy:GetMiniMapID()

    if minimapID == dMinimapID and MapProxy:CheckMiniMapAble() then
        self:UpdateMapPos()
        self:UpdateMiniMap()
        self:UpdateMiniMapPos()
    end
end

function MainMiniMapLayout:UpdateMiniMap()
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local MiniMapProxy = global.Facade:retrieveProxy(global.ProxyTable.MiniMapProxy)
    self._portals = MiniMapProxy:getPortals()
    self._markPortalIdx = nil

    if false == MapProxy:CheckMiniMapAble() then
        self._quickUI.Image_empty:setVisible(true)
        self._quickUI.Node_player:setVisible(false)
        self._quickUI.Image_minimap:setVisible(false)
    else
        self._quickUI.Image_empty:setVisible(false)
        self._quickUI.Node_player:setVisible(true)
        self._quickUI.Image_minimap:setVisible(true)

        self._quickUI.Image_minimap:loadTexture(MapProxy:GetMiniMapFile())
        self._quickUI.Image_minimap:ignoreContentAdaptWithSize(true)

        local contentSize = self._quickUI.Image_minimap:getContentSize()
        if contentSize.width < self._limitSize.width or contentSize.height < self._limitSize.height then
            contentSize.width = math.max(contentSize.width, self._limitSize.width)
            contentSize.height = math.max(contentSize.height, self._limitSize.height)
            GUI:setContentSize(self._quickUI.Image_minimap, contentSize)
        end
        local scaleX = self._miniScaleX
        local scaleY = self._miniScaleY
        self._minimapSize = {width = contentSize.width*scaleX, height = contentSize.height*scaleY}

        self._quickUI.Node_path:setPosition(cc.p(0, 0))
        self._quickUI.Node_actors:setPosition(cc.p(0, 0))
    end

    if MainMiniMap and MainMiniMap.UpdatePortal then
        MainMiniMap.UpdatePortal(true)
    else
        self:UpdatePortal()
    end
end

function MainMiniMapLayout:UpdateMiniMapPos()
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if false == MapProxy:CheckMiniMapAble() then
        return false
    end
    local actor = global.gamePlayerController:GetMainPlayer()
    if not actor then
        return false
    end
    local mapWidth  = global.sceneManager:GetMapWidthInPixel()
    local mapHeight = global.sceneManager:GetMapHeightInPixel()
    
    local worldPos  = actor:getPosition()
    local worldX    = worldPos.x
    local worldY    = -worldPos.y
    local ratioX    = self._minimapSize.width / mapWidth
    local ratioY    = self._minimapSize.height / mapHeight
    
    local function calcMiniMap()
        local minimapX = worldX * -ratioX
        local minimapY = (mapHeight - worldY) * -ratioY
        minimapX = minimapX + self._limitSize.width/2
        minimapY = minimapY + self._limitSize.height/2
        minimapX = math.max(minimapX, -(self._minimapSize.width-self._limitSize.width))
        minimapX = math.min(minimapX, 0)
        minimapY = math.max(minimapY, -(self._minimapSize.height-self._limitSize.height))
        minimapY = math.min(minimapY, 0)
        self._quickUI.Image_minimap:setPosition({x=minimapX, y=minimapY})
    end

    local function calcPlayerPos()
        local playerX   = self._limitSize.width/2
        local playerY   = self._limitSize.height/2
        local minimapX  = worldX * ratioX
        local minimapY  = (mapHeight - worldY) * ratioY

        -- 校正X
        if minimapX < self._limitSize.width/2 then
            playerX = minimapX
        elseif minimapX > self._minimapSize.width-self._limitSize.width/2 then
            playerX = self._limitSize.width - (self._minimapSize.width - minimapX)
        end

        -- 校正Y
        if minimapY < self._limitSize.height/2 then
            playerY = minimapY
        elseif minimapY > self._minimapSize.height-self._limitSize.height/2 then
            playerY = self._limitSize.height - (self._minimapSize.height - minimapY)
        end
        
        self._quickUI.Node_player:setPosition({x=playerX, y=playerY})
    end

    calcMiniMap()
    calcPlayerPos()
end

function MainMiniMapLayout:OnPlayerMoved()
    self:UpdateMapPos()
    if MainMiniMap and MainMiniMap.UpdatePortal then
        MainMiniMap.UpdatePortal()
    else
        self:UpdatePortal()
    end
    self:UpdateMiniMapPos()
end

function MainMiniMapLayout:UpdateMapPos()
    if not self._quickUI.PlayerPos then
        return false
    end
    local actor = global.gamePlayerController:GetMainPlayer()
    if not actor then
        return false
    end
    local mapX = actor:GetMapX()
    local mapY = actor:GetMapY()
    self._quickUI.PlayerPos:setString(string.format("%s:%s", mapX, mapY))
end

-- 更新相关提示
function MainMiniMapLayout:UpdatePortal()
    if not self._protalRange then
        return
    end

    local actor = global.gamePlayerController:GetMainPlayer()
    if not actor then
        return false
    end
    local mapX = actor:GetMapX()
    local mapY = actor:GetMapY()

    local showNameIndex = nil
    local mixRange = (self._protalRange+1) * (self._protalRange+1)
    for i, v in ipairs(self._portals) do
        local destMapX = tonumber(v.X) or 1
        local destMapY = tonumber(v.Y) or 1

        local len  = math.abs( squLen( mapX - destMapX, mapY - destMapY ) )
        if len < mixRange then
            mixRange = len
            showNameIndex = i
        end
    end
    
    if showNameIndex then
        if self._markPortalIdx ~= showNameIndex then
            self._markPortalIdx = showNameIndex
            local showName = self._portals[showNameIndex] or {}

            local miniMapPos = self:CalcMiniMapPos( cc.p(tonumber(showName.X) or 1,tonumber(showName.Y) or 1) )
            self._textName:setPosition(miniMapPos.x,miniMapPos.y+13)
            self._icon:setPosition(miniMapPos.x,miniMapPos.y)

            local color = (showName.nColor and tonumber(showName.nColor) == nil) and GetColorFromHexString(showName.nColor) or GET_COLOR_BYID_C3B(tonumber(showName.nColor) or 1)
            self._textName:setTextColor(color)
            self._textName:enableOutline(cc.Color4B.BLACK, tonumber(showName.bOutLine) or 0)
            self._textName:setString( showName.sShowName )

            local path = showName.sImgPath or "icon_xdtzy_04.png"
            self._icon:loadTexture( global.MMO.PATH_RES_PRIVATE .. "minimap/" .. path)

            self._icon:setVisible( true )
        end
    else
        self._markPortalIdx = nil
        self._textName:setString("")
        self._icon:setVisible( false )
    end
end

function MainMiniMapLayout:CleanupActorPoints()
    for i,v in ipairs(self._quickUI.Node_actors:getChildren()) do
        v:retain()
        v:removeFromParent()
        table.insert(self._pointCache,v)
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

function MainMiniMapLayout:OnMainPlayerRevive()
    self:UpdateMapPos()
    self:UpdateMiniMap()
    self:UpdateMiniMapPos()
end

function MainMiniMapLayout:AddActorPoint(actor)
    if nil == actor then
        return false
    end

    -- 死亡
    if actor:IsDie() or actor:IsDeath() then
        return false
    end
    -- 怪物石化和地下，等出生状态
    if actor:IsMonster() and (actor:IsBorn() or actor:IsCave()) then
        return false
    end

    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if nil == mainPlayerID then
        return false
    end

    local actorID = actor:GetID()

    if actorID == mainPlayerID then
        self:OnMainPlayerRevive()
        return false
    end

    -- 自己的宝宝不显示
    if actor:GetMasterID() == mainPlayerID then
        return false
    end

    if not (actor:IsMonster() or actor:IsPlayer() or actor:IsNPC()) then
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
