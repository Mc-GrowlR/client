local tremove = table.remove
local tinsert = table.insert

local INFINITY_COST = 0xFFFFFF
local BIAS_VALUE    = 14
local LINE_VALUE    = 10



local PathNode = class("PathNode")
function PathNode:ctor()
    self.x          = 0
    self.y          = 0
    self.t          = "new"
    self.h          = 0
    self.k          = 0
    self.isObstacle = 0
    self.backpointer = nil
end

function PathNode:cost(node)
    if self.isObstacle == 1 or node.isObstacle == 1 then
        return INFINITY_COST
    end
    local line_value = ((self.x == node.x or self.y == node.y) and 10 or 14)
    return ((self.x-node.x)*(self.x-node.x) + (self.y-node.y)*(self.y-node.y)) + line_value
end


-- 
local PathFindAStar = class('PathFindAStar')

function PathFindAStar:ctor()
    self.mapNodes  = {}
    self.openlist  = {}
    self.mapData   = nil
end

function PathFindAStar:cleanup()
    self.startPathNode = nil
    self.endPathNode = nil

    self.mapNodes  = {}
    self.openlist  = {}
end

function PathFindAStar:updateLimits(begX, begY, endX, endY)
    local mapData = global.sceneManager:GetMapData2DPtr()
    self.mapRows  = mapData:getMapDataRows()
    self.mapCols  = mapData:getMapDataCols()

    local disX = 24
    local disY = 16
    self.minX  = math.min(math.max(begX - disX, 0), self.mapCols-1)
    self.maxX  = math.min(math.max(begX + disX, 0), self.mapCols-1)
    self.minY  = math.min(math.max(begY - disY, 0), self.mapRows-1)
    self.maxY  = math.min(math.max(begY + disY, 0), self.mapRows-1)

    local limits = {}
    for x = self.minX, self.maxX do
        limits[x] = {}
        for y = self.minY, self.maxY do
            limits[x][y] = mapData:isObstacle(x, y)
        end
    end
    return limits
end

function PathFindAStar:getPathNode(x, y)
    if not self.mapData[x] or not self.mapData[x][y] then
        return nil
    end
    if self.mapNodes[x] and self.mapNodes[x][y] then
        return self.mapNodes[x][y]
    end

    local node = PathNode.new()
    node.x = x
    node.y = y
    node.h = 0
    node.k = 0
    node.t = "new"
    node.backpointer = nil
    node.isObstacle = self.mapData[x][y]

    if not self.mapNodes[x] then
        self.mapNodes[x] = {}
    end
    self.mapNodes[x][y] = node

    return node
end

function PathFindAStar:getNeighbors(node)
    local neighbors = {}
    local around = 
    {
        { node.x + 1, node.y     }, -- right
        { node.x,     node.y + 1 }, -- bottom
        { node.x - 1, node.y     }, -- left
        { node.x,     node.y - 1 }, -- top
        { node.x + 1, node.y - 1 }, -- right up    
        { node.x + 1, node.y + 1 }, -- right bottom
        { node.x - 1, node.y + 1 }, -- left bottom
        { node.x - 1, node.y - 1 }, -- left top    
    }

    for i = 1, 8 do
        local x = around[i][1]
        local y = around[i][2]
    
        -- out of bounds
        if (x >= self.minX and x <= self.maxX and y >= self.minY and y <= self.maxY) and self.mapData[x][y] == 0 then
            local node = self:getPathNode(x, y)
            if node then
                tinsert(neighbors, node)
            end
        end
    end

    return neighbors
end

function PathFindAStar:getMinKNode()
    local node  = nil
    local k     = nil
    local index = nil
    for i, v in pairs(self.openlist) do
        if not node or v.k < node.k then
            node  = v
            k     = node.k
            index = i
        end
    end
    return node, k, index
end

function PathFindAStar:insert(node, h_new)
    if node.t == "new" then
        node.k = h_new
        node.h = h_new
        node.t = "open"
        tinsert(self.openlist, node)

    elseif node.t == "open" then
        node.k = math.min(node.k, h_new)

    elseif node.t == "closed" then
        node.k = math.min(node.h, h_new)
        node.h = h_new
        node.t = "open"
        tinsert(self.openlist, node)
    end

    return true
end

function PathFindAStar:process_state()
    if #self.openlist == 0 then
        return -1
    end

    local currentNode, currentK, index = self:getMinKNode()

    if currentK == currentNode.h then
        for _, neighbor in pairs(self:getNeighbors(currentNode)) do
            local cost = currentNode.h + currentNode:cost(neighbor)
            if (neighbor.t == "new") or (neighbor.backpointer == currentNode and neighbor.h ~= cost) or (neighbor.backpointer ~= currentNode and neighbor.h > cost) then
                neighbor.backpointer = currentNode
                self:insert(neighbor, cost)
            end
        end
    else
        for _, neighbor in pairs(self:getNeighbors(currentNode)) do
            local cost = neighbor.h + currentNode:cost(neighbor)
            if neighbor.h <= currentK and currentNode.h > cost then
                currentNode.backpointer = neighbor
                currentNode.h = cost
            end
        end
    end

    currentNode.t = "closed"
    table.remove(self.openlist, index)

    if #self.openlist == 0 then
        return -1
    end

    local currentNode, currentK, index = self:getMinKNode()
    return currentK, currentNode
end

function PathFindAStar:find_path(begX, begY, endX, endY)
    self:cleanup()
    
    local points = {}

    if true == global.PathFindController:IsImpass(cc.p(begX, begY)) then
        return points
    end
    if true == global.PathFindController:IsImpass(cc.p(endX, endY)) then
        return points
    end
    if false == global.PathFindController:CheckMoveAble(cc.p(endX, endY)) then
        return points
    end

    self.mapData        = self:updateLimits(begX, begY, endX, endY)
    self.endPathNode    = self:getPathNode(begX, begY)
    self.startPathNode  = self:getPathNode(endX, endY)
    if nil == self.startPathNode or nil == self.endPathNode then
        return points
    end


    -- start
    self:insert(self.endPathNode, 0)
    while true do
        local ret = self:process_state()
        if ret == -1 then
            return points
        elseif self.startPathNode.t == "closed" then
            break
        end
    end

    -- points
    tinsert(points, {x=self.startPathNode.x, y=self.startPathNode.y})
    local node = self.startPathNode.backpointer
    while node ~= self.endPathNode do
        tinsert(points, {x=node.x, y=node.y})
        node = node.backpointer

        if nil == node then
            points = {}
            break
        end
    end

    return points
end

return PathFindAStar
