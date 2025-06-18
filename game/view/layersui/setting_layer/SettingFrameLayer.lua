local BaseLayer = requireLayerUI("BaseLayer")
local SettingFrameLayer = class("SettingFrameLayer", BaseLayer)

function SettingFrameLayer:ctor()
    SettingFrameLayer.super.ctor(self)
end

function SettingFrameLayer.create(...)
    local layer = SettingFrameLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function SettingFrameLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function SettingFrameLayer:InitGUI(Index)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTINGFRAME)
    SettingFrame.main(Index)

    self:InitEditMode()
end

function SettingFrameLayer:InitEditMode()
    local items = {
        "PMainUI",
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

    for i = 1, 6 do
        if self._ui["page_cell_"..i] then
            self._ui["page_cell_"..i].editMode = 1
            local text = self._ui["page_cell_"..i]:getChildByName("PageText") 
            if text then
                text.editMode = 1
            end
        end
    end
end

function SettingFrameLayer:OnClose()
    if SettingFrame then
        SettingFrame.OnClose()
    end
end

function SettingFrameLayer:PageTo(data)
    if SettingFrame then
        local layerId = SettingFrame._pageIDs and SettingFrame._pageIDs[data or 1]
        SettingFrame.PageTo(layerId)
    end
end

function SettingFrameLayer:GetCurPageID()
    return SettingFrame.GetCurPageID()
end
return SettingFrameLayer
