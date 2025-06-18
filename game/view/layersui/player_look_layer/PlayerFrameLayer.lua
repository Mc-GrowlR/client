local BaseLayer = requireLayerUI("BaseLayer")
local PlayerFrameLayer = class("PlayerFrameLayer", BaseLayer)

local RichTextHelper = requireUtil("RichTextHelp")

function PlayerFrameLayer:ctor()
    PlayerFrameLayer.super.ctor(self)
end

function PlayerFrameLayer.create()
    local ui = PlayerFrameLayer.new()

    if ui and ui:Init() then
        return ui
    end

    return nil
end

function PlayerFrameLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function PlayerFrameLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_LOOK_FRAME)
    PlayerFrame_Look.main(data)

    self:InitEditMode()
end

function PlayerFrameLayer:InitEditMode()
    local items = 
    {
        "Text_Name",
        "ButtonClose",
        "Image_bg",
        "Node_panel",
        "Panel_btnList",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end

    if PlayerFrame_Look._pageIDs then
        for _, id in ipairs(PlayerFrame_Look._pageIDs) do
            if self._ui["Button_"..id] then
                self._ui["Button_"..id].editMode = 1 
                local btnText = self._ui["Button_"..id]:getChildByName("Text_name")
                if btnText then
                    btnText.editMode = 1
                end
            end
        end
    end
end

function PlayerFrameLayer:GetOpenedLayer()
    return PlayerFrame_Look._pageid
end

function PlayerFrameLayer:GetOpenedLookState()
    return true
end

function PlayerFrameLayer:ChangeOpenedPage(id)
    PlayerFrame_Look.ChangeOpenedPage(id)
end

function PlayerFrameLayer:OnCloseMainLayer()
    PlayerFrame_Look.OnCloseMainLayer()
end

function PlayerFrameLayer:GetSUIParent()
    return self._ui.Panel_1
end

return PlayerFrameLayer