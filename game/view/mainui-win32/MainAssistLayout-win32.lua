local MainAssistLayout = class("MainAssistLayout", function()
        return cc.Node:create()
    end
)

function MainAssistLayout:ctor()
end

function MainAssistLayout.create()
    local layout = MainAssistLayout.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function MainAssistLayout:Init()
    self._ui = ui_delegate(self)

    return true
end

function MainAssistLayout:InitGUI( ... )
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_ASSIST_WIN32)
    MainAssist.main()

    self._listviewCells = self._ui.ListView_mission
    
    self:InitAssist()

    self:InitEditMode()

    return true
end

function MainAssistLayout:InitEditMode()
    local items = 
    {
        "Panel_assist",
        "Panel_hide",
        "Image_24",
        "Button_hide",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

function MainAssistLayout:InitAssist()
    local Button_near = self._ui.Button_near
    Button_near:addClickEventListener(function()
        JUMPTO(116)
    end)
    DelayTouchEnabled(Button_near)
end

function MainAssistLayout:ChangeHideStatus(data)
    MainAssist.ChangeHideStatus(data)
end

function MainAssistLayout:ReloadCUISetWidget( ... )
    if self._ui["Panel_assist"] then
        MainAssist._assistPos = GUI:getPosition(self._ui["Panel_assist"])
    end
    if self._ui["Panel_hide"] then
        MainAssist._hidePos = GUI:getPosition(self._ui["Panel_hide"])
    end
end

return MainAssistLayout