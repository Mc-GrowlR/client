local CustomCache = class("CustomCache")
local Queue                     = requireUtil( "queue" )
function CustomCache:ctor()
    self._ImageCache = {}
    self._SFXCache = {}
    self._NodeCache = nil
end

function CustomCache:resetWidget(node)
    node:retain()
    if node:getParent() then 
        node:removeFromParent()
    end
    node:setScale(1)
    node:setName("")
    node:setTag(-1)
    node:setPosition(cc.p(0,0))
    node:setAnchorPoint(cc.p(0.5,0.5))
    node:setOpacity(255)
    node:setVisible(true)
end

function CustomCache:GetImage(path)
    if not path or (path == "") then 
        return nil
    end 
    if not self._ImageCache[path] then
        self._ImageCache[path] = Queue.new()
    end
    local img = nil
    if self._ImageCache[path]:size() == 0 then 
        img = ccui.ImageView:create(path)
        img._CachePath = path
    else
        img = self._ImageCache[path]:pop()
        img:autorelease()
        img:removeAllChildren()
    end
    return img
end

function CustomCache:RmImage(img)
    local path = img._CachePath
    if self._ImageCache[path] then 
        if self._ImageCache[path]:size() >= 10 then
            if img:getParent() then 
                img:removeFromParent()
            end
        else
            self:resetWidget(img)
            self._ImageCache[path]:push(img)
        end 
    end
end

function CustomCache:GetSFXAnim(id)
    if not id then 
        return nil
    end 
    if not self._SFXCache[id] then
        self._SFXCache[id] = Queue.new()
    end
    local sfx = nil
    if self._SFXCache[id]:size() == 0 then 
        sfx = global.FrameAnimManager:CreateSFXAnim(id)
        sfx._ChacheId = id
    else
        sfx = self._SFXCache[id]:pop()
        sfx:autorelease()
        sfx:removeAllChildren()
    end
    return sfx
end
function CustomCache:RmSFXAnim(sfx)
    local id = sfx._ChacheId
    sfx:Stop()
    sfx:SetAnimEventCallback(nil)
    if self._SFXCache[id] then 
        if  self._SFXCache[id]:size() >= 10 then
            if sfx:getParent() then 
                sfx:removeFromParent()
            end
        else
            self:resetWidget(sfx)
            self._SFXCache[id]:push(sfx)
        end 
    end
end

function CustomCache:GetNode()
    if not self._NodeCache then
        self._NodeCache = Queue.new()
    end
    local node = nil
    if self._NodeCache:size() == 0 then 
        node = cc.Node:create()
    else
        node = self._NodeCache:pop()
        node:autorelease()
        node:removeAllChildren()
    end
    return node
end

function CustomCache:RmNode(node)
    node:setContentSize(0,0)
    if self._NodeCache then 
        if  self._NodeCache:size() >= 300 then
            if node:getParent() then 
                node:removeFromParent()
            end
        else
            self:resetWidget(node)
            self._NodeCache:push(node)
        end 
    end
end

function CustomCache:Clear()
    local node
    for k,vec in pairs(self._ImageCache) do
        for i = 1,vec:size() do
            node = vec:pop()
            node:release()
        end
    end
    self._ImageCache = {}

    local sfx = nil
    for k,vec in pairs(self._SFXCache) do
        for i = 1,vec:size() do
            node = vec:pop()
            node:release()
        end
    end
    self._SFXCache = {}
    if self._NodeCache then 
        for i = 1,self._NodeCache:size() do
            node = self._NodeCache:pop()
            node:release()
        end
    end
    self._NodeCache = nil
end

return CustomCache
