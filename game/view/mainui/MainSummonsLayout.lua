local MainSummonsLayout = class("MainSummonsLayout", function()
    return cc.Layer:create()
end)

function MainSummonsLayout:ctor()
end

function MainSummonsLayout.create()
    local layout = MainSummonsLayout.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function MainSummonsLayout:Init()
    self._ui = ui_delegate(self)

    return true
end

function MainSummonsLayout:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_SUMMONS)
    MainSummons.main()

    self:InitEditMode()
end

function MainSummonsLayout:InitEditMode()
    local items = 
    {
        "Image_icon",
        "Image_mode"
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

return MainSummonsLayout
