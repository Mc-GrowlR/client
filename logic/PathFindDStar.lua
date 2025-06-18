local tremove = table.remove
local tinsert = table.insert

local INFINITY_COST = 0xFFFFFF

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



-- local PPoint = class("PPoint")
-- function PPoint:ctor()
--     self._currentCost = 0
--     self._minimumCost = 0
--     self.x          = 0
--     self.y          = 0
--     self.t          = "new"
--     self.h          = 0
--     self.k          = 0
--     self.isObstacle = 0
--     self.nextPoint  = nil
-- end
-- function PPoint:cost(point)
--     if self.isObstacle == 1 or point.isObstacle == 1 then
--         return 0xFFFFFF
--     end
--     -- local line_value = ((self.x == point.x or self.y == point.y) and 10 or 14)
--     local line_value = ((self.x == point.x or self.y == point.y) and 10 or 10)
--     return ((self.x-point.x)*(self.x-point.x) + (self.y-point.y)*(self.y-point.y)) + line_value
-- end
-- function PPoint:costVia(point)
--     if self.isObstacle == 1 or point.isObstacle == 1 then
--         return 0xFFFFFF
--     end
--     return self._currentCost + self:cost(point)
-- end
-- function PPoint:setNextPointAndUpdateCost(p)
--     self.nextPoint = p

--     self._currentCost = self:cost(p)
--     self._minimumCost = (self._minimumCost == 0 and cost or math.min(self._minimumCost, self._currentCost))
-- end

-- function PPoint:get_neighbors()
--     local neighbors = {}
--     local around = 
--     {
--         { self.x + 1, self.y     }, -- right
--         { self.x,     self.y + 1 }, -- bottom
--         { self.x - 1, self.y     }, -- left
--         { self.x,     self.y - 1 }, -- top
--         { self.x + 1, self.y - 1 }, -- right up    
--         { self.x + 1, self.y + 1 }, -- right bottom
--         { self.x - 1, self.y + 1 }, -- left bottom
--         { self.x - 1, self.y - 1 }, -- left top    
--     }

--     for i = 1, 8 do
--         local x = around[i][1]
--         local y = around[i][2]
    
--         -- out of bounds
--         if not (x < 0 or x >= 9999 or y < 0 or y >= 9999) then
--             local point = PPoint.new()
--             point.x = x
--             point.y = y
--             tinsert(neighbors, point)
--         end
--     end

--     return neighbors
-- end



-- 
local PathFindDStar = class('PathFindDStar', framework.Mediator)
PathFindDStar.NAME = "PathFindDStar"

function PathFindDStar:ctor()
    PathFindDStar.super.ctor(self, self.NAME)

    self.mapNodes  = {}
    self.openlist  = {}
    self.mapData   = nil
    self.location  = nil
    self.isMoving  = false
end

function PathFindDStar:cleanup()
    self.startPathNode = nil
    self.endPathNode = nil

    self.mapNodes  = {}
    self.openlist  = {}
    self.location  = nil
    self.isMoving  = false
end

function PathFindDStar:onRegister()
    PathFindDStar.super.onRegister(self)

    local function actCallback(actor, act)
        if actor and (global.MMO.ACTION_WALK == act or global.MMO.ACTION_RUN == act or act == global.MMO.ACTION_RIDE_RUN) then
            local x = actor:GetMapX()
            local y = actor:GetMapY()
            -- local aiManager = aiManager:Inst()
            -- local ret = aiManager:OnMainPlayerMoved( x, y, self.mapData )
            -- print("retretretretretretretretretretretretretretretretretret", ret)
            -- if ret == 1 then
            --     local findPoints = aiManager:GetPathFind():GetPathPoints()
            --     local inputProxy = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
            --     inputProxy:SetPathFindPoints( findPoints )
            -- end
            self.location = self:getPathNode(x, y)

            if self.location and self.location.t == "closed" and self.location.backpointer and self.location.backpointer.isObstacle == 1 then
                self:find_path_modify()
            end
        end
    end
    global.gamePlayerController:AddHandleOnActCompleted(actCallback)
end

function PathFindDStar:UpdateMapData(mapData)
    self.mapNodes = {}

    self.mapData  = mapData
    self.mapRows  = self.mapData:getMapDataCols()
    self.mapCols  = self.mapData:getMapDataRows()
end

function PathFindDStar:getPathNode(x, y)
    if self.mapNodes[x] and self.mapNodes[x][y] then
        return self.mapNodes[x][y]
    end

    local node = PathNode.new()
    node.x = x
    node.y = y
    node.h = 0
    node.k = 0
    node.t = "new"
    node.backpointer     = nil
    node.isObstacle = self.mapData:isObstacle(x, y)

    if not self.mapNodes[x] then
        self.mapNodes[x] = {}
    end
    self.mapNodes[x][y] = node

    return node
end

function PathFindDStar:updateMapNode(x, y, isObstacle)
    -- local aiManager = aiManager:Inst()
    -- local ret = aiManager:DynamicObstacle( x, y, isObstacle, self.mapData )

    if not (self.mapNodes[x] and self.mapNodes[x][y]) then
        return -1
    end
    self.mapNodes[x][y].isObstacle = isObstacle

    -- next pointer is obstacle
    -- if self.location and self.location.t == "closed" and self.location.backpointer and self.location.backpointer.isObstacle == 1 then
    --     self:find_path_modify()
    -- end
end


function PathFindDStar:getNeighbors(node)
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
        if not (x < 0 or x >= self.mapRows or y < 0 or y >= self.mapCols) then
            local node = self:getPathNode(x, y)
            tinsert(neighbors, node)
        end
    end

    return neighbors
end

function PathFindDStar:getMinKNode()
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

function PathFindDStar:insert(node, h_new)
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

function PathFindDStar:process_state()
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
        -- for _, neighbor in pairs(self:getNeighbors(currentNode)) do
        --     local cost = neighbor.h + currentNode:cost(neighbor)
        --     -- if neighbor.h <= currentK and currentNode.h > cost then
        --     if currentNode.h > cost then
        --         currentNode.backpointer = neighbor
        --         currentNode.h = cost
        --     end
        -- end
    end

    currentNode.t = "closed"
    table.remove(self.openlist, index)

    if #self.openlist == 0 then
        return -1
    end

    local currentNode, currentK, index = self:getMinKNode()
    return currentK, currentNode
end

function PathFindDStar:modify_cost(node)
    if node.t == "closed" then
        self:insert(node, node.backpointer.h + node:cost(node.backpointer))
    end
end

function PathFindDStar:modify(node)

    print(" node    x " .. node.x .. "  y " .. node.y .. "   k " .. node.k .. "  h " .. node.h) 
    self._count = 0
    self:modify_cost(node)
    print(" node modify    x " .. node.x .. "  y " .. node.y .. "   k " .. node.k .. "  h " .. node.h) 
    while true do
        self._count = self._count + 1
        local currentNode, currentK, index = self:getMinKNode()
        print("x " .. currentNode.x .. "  y " .. currentNode.y .. "   k " .. currentNode.k .. "  h " .. currentNode.h) 

        local k_min = self:process_state()
        print("k_min", k_min)
        print(" node progressstate    x " .. node.x .. "  y " .. node.y .. "   k " .. node.k .. "  h " .. node.h) 
        print("-------------------------------------")
        if self._count >= 5 then
            return -1
        end
        if k_min == -1 then
            return -1
        end
        if k_min >= node.h then
            break
        end
    end
    return 0
end

function PathFindDStar:find_path(begX, begY, endX, endY)
    print("*********************************** find path D*")
    self._isModify = false
    self:cleanup()

    
    self.startPathNode = self:getPathNode(begX, begY)
    self.endPathNode = self:getPathNode(endX, endY)


    -- impass
    if self.endPathNode.isObstacle == 1 or self.startPathNode.isObstacle == 1 then
        return {}
    end
    local neighbors = self:getNeighbors(self.startPathNode)
    local impass = true
    for k, v in pairs(neighbors) do
        if v.isObstacle == 0 then
            impass = false
            break
        end
    end
    if impass then
        return {}
    end
    local neighbors = self:getNeighbors(self.endPathNode)
    local impass = true
    for k, v in pairs(neighbors) do
        if v.isObstacle == 0 then
            impass = false
            break
        end
    end
    if impass then
        return {}
    end



    -- 开始搜寻
    self:insert(self.endPathNode, 0)
    while true do
        local ret = self:process_state()
        if ret == -1 then
            return {}
        elseif self.startPathNode.t == "closed" then
            break
        end
    end

    -- points
    local points = {}
    local node = self.startPathNode.backpointer
    while node ~= self.endPathNode do
        tinsert(points, 1, {x=node.x, y=node.y})
        node = node.backpointer
    end
    tinsert(points, 1, {x=self.endPathNode.x, y=self.endPathNode.y})

    self.isMoving = true
    return points
end

function PathFindDStar:find_path_modify()
    if not self.isMoving then
        return -1
    end
    if not self.location then
        return -1
    end
    if self.location.isObstacle == 1 then
        return -1
    end
    if not self.location.backpointer then
        return -1
    end
    if self.location.backpointer.isObstacle == 1 and self.location.backpointer == self.endPathNode then
        return -1
    end
    local neighbors = self:getNeighbors(self.location)
    local impass = true
    for k, v in pairs(neighbors) do
        if v.isObstacle == 0 then
            impass = false
            break
        end
    end
    if impass then
        return -1
    end
    

    print("--------------------modify")
    local temp = self.location
    while true do
        if temp.backpointer.isObstacle == 1 then
            local r = self:modify(temp)
            print("rrrrrrrrrrrrrrrrr", r)
            if r == -1 then
                break
            end
        end
        break

        -- if not temp or temp.isObstacle == 0 then
        --     break
        -- end
    end
    print("--------------------modify end")

    -- points
    local points = {}
    local temp = self.location.backpointer
    while temp do
        tinsert(points, 1, {x=temp.x, y=temp.y})
        temp = temp.backpointer
    end
    if #points > 0 then
        -- 更新路径
        local inputProxy = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
        inputProxy:SetPathFindPoints( points )
    else
        -- 更新路径
        local inputProxy = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
        inputProxy:SetPathFindPoints( {} )
    end
    print("*********************modify end")
end




-- function PathFindDStar:dstar_init()
--     self._dstarOpenlist = {}
-- end

-- function PathFindDStar:dstar_add_to_openlist(p)
--     table.insert(self._dstarOpenlist, p)
-- end

-- function PathFindDStar:dstar_find_path()
--     while next(self._dstarOpenlist) do
--         local p = self._dstarOpenlist[1]

--     end
-- end

-- function PathFindDStar:dstar_expand(p)
--     local isRaise = self:dstar_is_raise(p)
--     local cost    = 0
--     for _, neighbor in pairs(p:get_neighbors()) do
--         if isRaise then
--             if neighbor.nextPoint == p then
--                 neighbor:setNextPointAndUpdateCost(p)
--                 self:dstar_add_to_openlist(neighbor)
--             else
--                 cost = neighbor:cost(p)
--                 -- if 
--             end
            
--         end
--     end
-- end

-- function PathFindDStar:dstar_is_raise(p)
--     local cost = 0
--     if p._currentCost > p._minimumCost then
--         for _, neighbor in pairs(p:get_neighbors()) do
--             cost = p:costVia(neighbor)
--             if cost < p._currentCost then
--                 p:setNextPointAndUpdateCost(neighbor)
--             end
--         end
--     end
--     return p._currentCost > p._minimumCost
-- end

return PathFindDStar
