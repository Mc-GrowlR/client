local BaseLayer = requireLayerUI("BaseLayer")
local SocialFrameLayer = class("SocialFrameLayer", BaseLayer)

function SocialFrameLayer:ctor()
    SocialFrameLayer.super.ctor(self)
end

function SocialFrameLayer.create(...)
    local layer = SocialFrameLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function SocialFrameLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function SocialFrameLayer:InitGUI(index)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SOCIAL_FRAME)
    SocialFrame.main(index)

    self:InitEditMode()
end

function SocialFrameLayer:InitEditMode()
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

    for i = 1, 4 do
        if self._ui["page_cell_"..i] then
            self._ui["page_cell_"..i].editMode = 1
            local text = self._ui["page_cell_"..i]:getChildByName("PageText") 
            if text then
                text.editMode = 1
            end
        end
    end
end

function SocialFrameLayer:OnClose()
    if SocialFrame then
        SocialFrame.OnClose()
    end
end

function SocialFrameLayer:PageTo(data)
    if SocialFrame then
        local layerId = SocialFrame._pageIDs and SocialFrame._pageIDs[data or 1]
        SocialFrame.PageTo(layerId)
    end
end

return SocialFrameLayer
