local BaseLayer = requireLayerUI("BaseLayer")
local PlayerFrameLayer = class("PlayerFrameLayer", BaseLayer)

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
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_FRAME)
    PlayerFrame.main(data)
    self._root = self._ui.Panel_1 --交易行截图用 

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

    if PlayerFrame._pageIDs then
        for _, id in ipairs(PlayerFrame._pageIDs) do
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
    return PlayerFrame._pageid
end

function PlayerFrameLayer:GetOpenedLookState()
    return false
end

function PlayerFrameLayer:ChangeOpenedPage(id)
    PlayerFrame.ChangeOpenedPage(id)
end

function PlayerFrameLayer:OnCloseMainLayer()
    PlayerFrame.OnCloseMainLayer()
end

function PlayerFrameLayer:GetOpenedType()
    return PlayerFrame._showType
end

function PlayerFrameLayer:ChangeType(i)
    if PlayerFrame.ChangeShowType then
        PlayerFrame.ChangeShowType(i)
    end
end

function PlayerFrameLayer:GetSUIParent()
    return self._ui.Panel_1
end

return PlayerFrameLayer