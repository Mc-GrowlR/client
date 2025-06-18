local BaseLayer = requireLayerUI("BaseLayer")
local StoreFrameLayer = class("StoreFrameLayer", BaseLayer)

function StoreFrameLayer:ctor()
    StoreFrameLayer.super.ctor(self)
end

function StoreFrameLayer.create(...)
    local layer = StoreFrameLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function StoreFrameLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function StoreFrameLayer:InitGUI(index)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_STORE_FRAME)
    StoreFrame.main(index)

    self:InitEditMode()
end

function StoreFrameLayer:InitEditMode()
    local items = {
        "FrameLayout",
        "FrameBG",
        "DressIMG",
        "TitleText",
        "AttachLayout",
        "CloseButton",
    }

    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end

    for i = 1, 5 do
        if self._ui["page_cell_"..i] then
            self._ui["page_cell_"..i].editMode = 1
            local text = self._ui["page_cell_"..i]:getChildByName("PageText") 
            if text then
                text.editMode = 1
            end
        end
    end
end

function StoreFrameLayer:OnClose()
    if StoreFrame then
        StoreFrame.OnClose()
    end
end

function StoreFrameLayer:PageTo(data)
    if StoreFrame then
        local layerId = StoreFrame._pageIDs and StoreFrame._pageIDs[data or 1]
        StoreFrame.PageTo(layerId)
    end
end

return StoreFrameLayer
