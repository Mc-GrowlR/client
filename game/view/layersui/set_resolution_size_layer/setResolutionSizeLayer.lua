local BaseLayer = requireLayerUI("BaseLayer")
local setResolutionSizeLayer = class("setResolutionSizeLayer", BaseLayer)

function setResolutionSizeLayer:ctor()
    setResolutionSizeLayer.super.ctor(self)
end

function setResolutionSizeLayer.create(...)
    local layer = setResolutionSizeLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function setResolutionSizeLayer:Init()
    self._quickUI = ui_delegate(self)
    self.curSize = global.DesignSize_Win

    return true
end

function setResolutionSizeLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SET_WINSIZE_POP)
    SetWinSizePop.main()

    self:InitUI()
end

function setResolutionSizeLayer:InitUI()

    self._quickUI.Text_Resolution:setString(self.curSize.width.."x"..self.curSize.height)
    self:InitShowList()
    ------------
    self._quickUI.Button_close:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_setResolutionSize_Close )
    end)

    self._quickUI.Panel_cancel:addClickEventListener(function()
        if self._quickUI.Panel_show:isVisible() then 
            self:HideList()
        end
    end)
    self._quickUI.Panel_cancel:setSwallowTouches(false)
    self._quickUI.Image_show:addClickEventListener(function()
        if not self._quickUI.Panel_show:isVisible() then 
            self:ShowList()
        end
    end)

    self._quickUI.Button_ok:addClickEventListener(function()
        if self.curSize.width ~= global.DesignSize_Win.width or self.curSize.height ~= global.DesignSize_Win.height then 
            local index = 1
            for i,v in ipairs(SetWinSizePop._resolutions) do
                if self.curSize.width == v.width and self.curSize.height == v.height then 
                    index = i 
                    break
                end
            end
            global.Facade:sendNotification( global.NoticeTable.ResolutionSizeChange,{size = self.curSize,index = index} )
        end
    end)
    
    return true
end

function setResolutionSizeLayer:InitShowList()
    self._quickUI.Panel_show:setVisible(false)
    self._quickUI.Panel_item:setVisible(false)
    local itemSize = self._quickUI.Panel_item:getContentSize() 
    local viewheight = itemSize.height * #SetWinSizePop._resolutions
    local viewSize =  self._quickUI.Panel_show:getContentSize()
    self._quickUI.Panel_show:setContentSize(viewSize.width, viewheight)
    self._quickUI.ListView_1:setContentSize(viewSize.width, viewheight)
    self._quickUI.ListView_1:setPosition(viewSize.width / 2, viewheight)
    ccui.Helper:doLayout(self._quickUI.Panel_show)
    for i,v in ipairs(SetWinSizePop._resolutions) do
        local item = self._quickUI.Panel_item:cloneEx()
        item:setVisible(true)
        local Text_1 = item:getChildByName("Text_1")
        Text_1:setString(v.width.."x"..v.height)
        item:addClickEventListener(function()
            self._quickUI.Text_Resolution:setString(v.width.."x"..v.height)
            self.curSize = v
            self:HideList()
        end)
        self._quickUI.ListView_1:pushBackCustomItem(item)
    end
end

function setResolutionSizeLayer:ShowList()
    self._quickUI.Panel_show:setVisible(true)
    local items = self._quickUI.ListView_1:getItems()
    for i,v in ipairs(items) do
        local Resolution = SetWinSizePop._resolutions[i]
        local Image_select = v:getChildByName("Image_select")
        if Resolution.width == self.curSize.width and Resolution.height == self.curSize.height then 
            Image_select:setVisible(true)
        else
            Image_select:setVisible(false)
        end
    end
end

function setResolutionSizeLayer:HideList()
    self._quickUI.Panel_show:setVisible(false)
end

return setResolutionSizeLayer
