local TWidget = class("TWidget")

local Element   = require("sui/Element")
local SUIHelper = require("sui/SUIHelper")


function TWidget:ctor()
    self.element  = nil
    self.render   = nil
    self.trunk    = nil
    self.branches = {}
    self.index    = 1               -- Z轴
    self.depth    = 1               -- 深度
    self.content  = nil
end

function TWidget:cleanup()
    self.element  = nil
    self.render   = nil
    self.trunk    = nil
    self.branches = {}
    self.index    = 1               -- Z轴
    self.depth    = 1               -- 深度
    self.content  = nil
end

function TWidget:addBranch(branch)
    table.insert(self.branches, branch)

    branch.index  = #self.branches
    branch.trunk  = self
    branch.depth  = self.depth + 1
end

function TWidget:insertBranch(branch, index)
    table.insert(self.branches, index, branch)

    branch.index  = index
    branch.trunk  = self
    branch.depth  = self.depth + 1

    -- update index
    for index, branch in ipairs(self.branches) do
        branch.index = index
        if branch.render then
            branch.render:setLocalZOrder(branch.index)
        end
    end
end

function TWidget:removeBranch(branch)
    table.remove(self.branches, branch.index)

    if branch.render then
        if not global.TWidgetCache:cachingRender(branch) then
            branch.render:retain()
            if self.element.type == "ListView" then
                self.render:removeItem(self.render:getIndex(branch.render))
            else
                branch.render:removeFromParent()
            end
            branch.render:autorelease()
        end
    end

    -- update index
    for index, branch in ipairs(self.branches) do
        branch.index = index
        if branch.render then
            branch.render:setLocalZOrder(branch.index)
        end
    end
end

function TWidget:addBranchRender(branch)
    if not branch then
        print("ERROR function TWidget:addBranchRender(branch), branch arge error")
        return false
    end

    local content = ""
    if self.element.type == "ListView" then
        content = replace([[
        ${parentName}:insertCustomItem(${childName},${index})
        ]],{parentName = self.name, childName = branch.realname or branch.name, index = branch.index-1})
    else
        content = replace([[
            ${parentName}:addChild(${childName})
            ${childName}:setLocalZOrder(${index})
        ]], {parentName = self.name, childName = branch.realname or branch.name, index = branch.index})
        
    end
    return content
end

function TWidget:replaceRender(newrender)
    local children = self.render:getChildren()
    for _, branch in ipairs(self.branches) do
        branch.render:retain()
        branch.render:autorelease()
        branch.render:removeFromParent()
        newrender:addChild(branch.render)
        branch.render:setLocalZOrder(branch.index)
    end

    self.render:removeFromParent()
    self.render = newrender
    self.trunk.render:addChild(self.render)
    self.render:setLocalZOrder(self.index)
end

return TWidget