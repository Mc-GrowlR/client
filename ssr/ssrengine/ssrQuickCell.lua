local ssrQuickCell = class("ssrQuickCell", function() 
    return ccui.Widget:create() 
end)

-- self._data.wid               default 100
-- self._data.hei               default 50
-- self._data.anchor            default {x=0, y=0}
-- self._data.tick_interval     default 0.02
-- self._data.activeEvent       default inview
-- self._data.createCell        default nil

function ssrQuickCell:ctor()
    self._entered = false
    self._active = true
end

function ssrQuickCell:Create( data )
    local cell = ssrQuickCell.new()
    if cell and cell:Init( data ) then
        return cell
    end

    return nil
end

function ssrQuickCell:Init( data )
    self._data = data

    local wid = self._data.wid or 100
    local hei = self._data.hei or 50
    local anchor = self._data.anchor or {x=0, y=0}

    self:setContentSize( {width = wid, height = hei} )
    self:setAnchorPoint( anchor )

    self:Active()

    return true
end

function ssrQuickCell:Update( data )
    local createCell = data.createCell
    self._data.createCell = createCell

    -- 执行以下退出，方便立即刷新
    self:Exit()
end

function ssrQuickCell:Enter()
    if self._entered then
        return false
    end
    self._entered = true

    local createCell = self._data.createCell
    local wid = self._data.wid or 100
    local hei = self._data.hei or 50

    if not createCell then
        return false
    end

    local cell = createCell(self)
    cell:setAnchorPoint({x=0.5, y=0.5})
    cell:setPosition({x=wid/2, y=hei/2})
    refPositionByParent(cell)
end

function ssrQuickCell:Exit()
    if not self._entered then
        return false
    end
    self._entered = false

    self:removeAllChildren()
end

function ssrQuickCell:Refresh()
    if not self._active then
        return false
    end

    local active = true

    local activeEvent = self._data.activeEvent
    if activeEvent then
        active = activeEvent()
    elseif self._data.eventX then
        local viewSize = global.Director:getVisibleSize()
        local pos = self:getWorldPosition()
        
        local wid = self._data.wid or 100
        local hei = self._data.hei or 50
        active = not ( pos.x >= viewSize.width + wid or pos.x <= -wid )
    else
        local viewSize = global.Director:getVisibleSize()
        local pos = self:getWorldPosition()
        
        local wid = self._data.wid or 100
        local hei = self._data.hei or 50
        active = not ( pos.y >= viewSize.height + hei or pos.y <= -hei )
    end

    if active then
        self:Enter()
    else
        self:Exit()
    end
end

function ssrQuickCell:Active()
    self._active = true

    local tick_interval = self._data.tick_interval or 0.02
    self:stopAllActions()
    schedule(self, function()
        self:Refresh()      
    end, tick_interval)
end

function ssrQuickCell:Sleep()
    self._active = false
    self:stopAllActions()
end


return ssrQuickCell
