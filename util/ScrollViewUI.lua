-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local ScrollViewUI = class("ScrollViewUI", function() return ccui.Widget:create() end)

ScrollViewUI.SCROLLVIEW_DIR = {
    SCROLLVIEW_DIR_NONE = 0,
    SCROLLVIEW_DIR_VERTICAL = 1,
    SCROLLVIEW_DIR_HORIZONTAL = 2,
    SCROLLVIEW_DIR_BOTH = 3
}

function ScrollViewUI:ctor()
    self._scrollView = nil
    self._cellList = { }
    self._cellCount = 0
    self._spacing = 0
    self._innerWidth = 0
    self._innerHeight = 0
    self._fixHeight = 0
    
    self._bottomCallBack = nil
end

function ScrollViewUI:Init(scrollView)
    self._scrollView = scrollView
    if not self._scrollView then
        return false
    end


    self._direction = self._scrollView:getDirection()

    self._update = Schedule( function()
        if self._direction == ScrollViewUI.SCROLLVIEW_DIR.SCROLLVIEW_DIR_HORIZONTAL then
            self:_UpdateCellHorizontal()
        elseif self._direction == ScrollViewUI.SCROLLVIEW_DIR.SCROLLVIEW_DIR_VERTICAL then
            self:_UpdateCellVertical()
        end
    end , 0)

    -- 监听事件;
    self:registerScriptHandler( function(state)
        if state == "enter" then
            self:onEnter()
        elseif state == "exit" then
            self:onExit()
        end
    end )

    local parent = self._scrollView:getParent()
    if parent then
        parent:addChild(self)
    end
    
    local function bottom(sender, type)
      if sender:getInnerContainerPosition().y == 0 then
        self:_moveBottomCallBack()
      end
    end
    self._scrollView:addClickEventListener(bottom)

    return true
end

function ScrollViewUI:Create(...)
    local ui = ScrollViewUI.new()
    if ui and ui:Init(...) then
        return ui
    end
end

function ScrollViewUI:onEnter()

end

function ScrollViewUI:onExit()
    self:RemoveAllCell()

    if self._update then
        UnSchedule(self._update)
        self._update = nil
    end
end

function ScrollViewUI:InitPosition()
    if self._direction == ScrollViewUI.SCROLLVIEW_DIR.SCROLLVIEW_DIR_HORIZONTAL then
        self:_InitPositionHorizontal()
        self:_UpdateCellHorizontal()
    elseif self._direction == ScrollViewUI.SCROLLVIEW_DIR.SCROLLVIEW_DIR_VERTICAL then
        self:_InitPositionVertical()
        self:_UpdateCellVertical()
    end
end

function ScrollViewUI:_InitPositionVertical()
    local containerSize = self._scrollView:getInnerContainerSize()

    local totalHeight = self._fixHeight

    for i = self._cellCount, 1, -1 do
        local cell = self._cellList[i]
        local cellAnchorY = cell:GetAnchorPoint().y
        local cellHeight = cell:GetContentSize().height
        if cellAnchorY == 0 then
            cell.positionY = totalHeight
        elseif cellAnchorY == 0.5 then
            cell.positionY = totalHeight + cellHeight / 2
        elseif cellAnchorY == 1 then
            cell.positionY = totalHeight + cellHeight
        end

        totalHeight = totalHeight + cellHeight + self._spacing
    end

    local contentSizeHeight = self._scrollView:getContentSize().height
    if totalHeight < contentSizeHeight then
        local y = contentSizeHeight - totalHeight
        for i = 1, self._cellCount do
            local cell = self._cellList[i]
            cell.positionY = cell.positionY + y
        end
    end

    -- 记录原先的pos,防止插入cell后滚动位置跳动
    -- local pos = self._scrollView:getInnerContainerPosition()
    -- pos.y = pos.y - (totalHeight - containerSize.height)
    self._innerHeight = totalHeight
    self._innerWidth = containerSize.width
    self._scrollView:setInnerContainerSize(cc.size(containerSize.width, totalHeight))

    -- 恢复位置
    -- self._scrollView:setInnerContainerPosition(pos)
end

function ScrollViewUI:_InitPositionHorizontal()
    local containerSize = self._scrollView:getInnerContainerSize()

    local totalWidth = 0
    for i = 1, self._cellCount do
        local cell = self._cellList[i]
        local cellAnchorX = cell:GetAnchorPoint().x
        local cellWidth = cell:GetContentSize().width
        if cellAnchorX == 0 then
            cell.positionX = totalWidth
        elseif cellAnchorX == 0.5 then
            cell.positionX = totalWidth + cellWidth / 2
        elseif cellAnchorX == 1 then
            cell.positionX = totalWidth + cellWidth
        end

        totalWidth = totalWidth + cellWidth + self._spacing
    end

    self._innerHeight = containerSize.height
    self._innerWidth = totalWidth
    self._scrollView:setInnerContainerSize(cc.size(totalWidth, containerSize.height))
end

function ScrollViewUI:_UpdateCellVertical()
    local innerContainerPositionY = self._scrollView:getInnerContainerPosition().y
    local innercontainerHeight = self._scrollView:getInnerContainerSize().height
    local contentSize = self._scrollView:getContentSize()
    for key, cell in pairs(self._cellList) do
        local cellHeight = cell:GetContentSize().height

        -- 是否在显示范围
        if cell.positionY + innerContainerPositionY >= - cellHeight and
            cell.positionY + innerContainerPositionY <= contentSize.height then

            if not cell._entered then
                cell:Enter()
                if cell._widget then
                    self._scrollView:addChild(cell._widget)
                end
            end

            if cell._widget and not tolua.isnull(cell._widget) then
                cell._widget:setPosition(cc.p(0, cell.positionY))
            else
                local layerFacadeMediator = global.Facade:retrieveMediator("LayerFacadeMediator")
                local mediator = layerFacadeMediator._normalItems[#layerFacadeMediator._normalItems]
                if mediator then
                    if cell.__cname then
                        local bool1 = false
                        local bool2 = false

                        if cell._widget then
                            bool1 = true

                            if not tolua.isnull(cell._widget) then
                                bool1 = false
                            end
                        end
                    end
                end
            end

        else
            if cell._entered then
                cell:Exit()
            end
        end
    end
end

function ScrollViewUI:_UpdateCellHorizontal()
    local innerContainerPositionX = self._scrollView:getInnerContainerPosition().x
    local innercontainerWidth = self._scrollView:getInnerContainerSize().width
    local contentSize = self._scrollView:getContentSize()
    for key, cell in pairs(self._cellList) do
        local cellWidth = cell:GetContentSize().width

        -- 是否在显示范围
        if cell.positionX + innerContainerPositionX >= - cellWidth and
            cell.positionX + innerContainerPositionX <= contentSize.width + cellWidth then

            if not cell._entered then
                cell:Enter()
                self._scrollView:addChild(cell._widget)
            end
            cell._widget:setPosition(cc.p(cell.positionX, 100))
        else
            if cell._entered then
                cell:Exit()
            end
        end
    end
end

function ScrollViewUI:_moveBottomCallBack()
  if self._bottomCallBack then
    self._bottomCallBack()
  end
end

function ScrollViewUI:AddBottomCallBack(callBack)
   self._bottomCallBack = callBack
end

function ScrollViewUI:GetInnerWidth()
    return self._innerWidth
end

function ScrollViewUI:GetInnerHeight()
    return self._innerHeight
end

function ScrollViewUI:FixHeight(value)
    self._fixHeight = value or self._fixHeight
end

function ScrollViewUI:PushCell(cell)
    self._cellCount = self._cellCount + 1
    self._cellList[#self._cellList + 1] = cell
    self:InitPosition()
end

function ScrollViewUI:RemoveAllCell()
    for _, cell in pairs(self._cellList) do
        if cell._entered then
            cell:Exit()
        end
    end

    self._cellList = { }
    self._cellCount = 0
    self:InitPosition()
end

function ScrollViewUI:RemoveCellById(index)
    local cell = self._cellList[index]
    if not cell then
        return
    end

    if cell._entered then
        cell:Exit()
    end

    for i = index, self._cellCount - 1 do
        self._cellList[i] = self._cellList[i + 1]
    end

    self._cellList[self._cellCount] = nil
    self._cellCount = self._cellCount - 1
    self:InitPosition()
end

function ScrollViewUI:RemoveCell(cell)
    for index, value in pairs(self._cellList) do
        if value == cell then
            self:RemoveCellById(index)
            return
        end
    end
end

function ScrollViewUI:JumpToBottom()
    self._scrollView:jumpToBottom()
end

function ScrollViewUI:JumpToTop()
    self._scrollView:jumpToTop()
end

function ScrollViewUI:setInnerContainerPosition(pos)
    self._scrollView:setInnerContainerPosition(pos)
end

function ScrollViewUI:ScrollToBottom(timeInSec, attenuated)
    self._scrollView:scrollToBottom(timeInSec, attenuated)
end

return ScrollViewUI

-- endregion

