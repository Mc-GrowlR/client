local MainTopLayout = class("MainTopLayout", function()
    return cc.Node:create()
end)

function MainTopLayout:ctor()
end

function MainTopLayout.create()
    local layout = MainTopLayout.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function MainTopLayout:Init()
    self.ui = ui_delegate(self)
    self:InitGUI()

    return true
end

function MainTopLayout:InitGUI()
    ssr.GUI.ATTACH_MAINTOP = self
    GUI.ATTACH_MAINTOP = self

    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_TOP)
    MainTop.main()

    self:InitEditMode()
end

function MainTopLayout:InitEditMode()
    local items = {
        "Image_1",
        "Image_2",
        "Image_net",
        "Image_battery",
        "LoadingBar_battery"
    }
    for _, widget in ipairs(items) do
        if self.ui[widget] then
            self.ui[widget].editMode = 1 
        end
    end
end

return MainTopLayout