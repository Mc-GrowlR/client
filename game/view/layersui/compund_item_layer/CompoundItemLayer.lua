local BaseLayer = requireLayerUI("BaseLayer")
local CompoundItemLayer = class("CompoundItemLayer", BaseLayer)

function CompoundItemLayer:ctor()
    CompoundItemLayer.super.ctor(self)
end

function CompoundItemLayer.create(...)
    local layer = CompoundItemLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function CompoundItemLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function CompoundItemLayer:InitGUI(id)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_COMPOUND_ITEM)
    CompoundItem.main()

    self._layout_bg = self._ui.Panel_bg
    self:InitEditMode()
end

function CompoundItemLayer:InitEditMode()
    local items = 
    {
        "Image_bg",
        "ListView_list1",
        "Image_line1",
        "Image_line2",
        "ListView_list2",
        
        "ListView_2",
        "ListView_get",
        "ListView_money",

        "Button_help",
        "Button_compound",

        "Image_frame_bg",
        "Image_frame_bg2",
        "Text_frame_title",
        "Button_close",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

return CompoundItemLayer
