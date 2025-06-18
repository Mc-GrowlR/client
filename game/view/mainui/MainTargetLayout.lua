local MainTargetLayout = class("MainTargetLayout",
    function()
        return cc.Layer:create()
    end
)

function MainTargetLayout:ctor()
end

function MainTargetLayout.create()
    local layout = MainTargetLayout.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function MainTargetLayout:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function MainTargetLayout:InitGUI( ... )
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_TARGET)
    MainTarget.main()
    
    self:InitEditMode()
end

function MainTargetLayout:InitEditMode()
    local items = {
        "Panel_1",
        "LockBtn",
    }
    for _, widget in ipairs(items) do
        if self._quickUI[widget] then
            self._quickUI[widget].editMode = 1
        end
    end
end

return MainTargetLayout
