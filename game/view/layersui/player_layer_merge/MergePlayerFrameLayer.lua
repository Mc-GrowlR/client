local BaseLayer = requireLayerUI("BaseLayer")
local MergePlayerFrameLayer = class("MergePlayerFrameLayer", BaseLayer)

function MergePlayerFrameLayer:ctor()
    MergePlayerFrameLayer.super.ctor(self)
end

function MergePlayerFrameLayer.create()
    local ui = MergePlayerFrameLayer.new()

    if ui and ui:Init() then
        return ui
    end

    return nil
end

function MergePlayerFrameLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function MergePlayerFrameLayer:InitGUI(data,showtype)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MERGE_PLAYER_MAIN)
    data = data or {}
    data.showtype = showtype
    MergePlayerFrame.main(data)
    self._CaptureNode =  MergePlayerFrame._ui.Panel_1

    self:InitEditMode()
end

function MergePlayerFrameLayer:InitEditMode()
    local items = 
    {
        "Text_Name",
        "ButtonClose",
        "Button_player",
        "Button_hero",
        "Image_1",
        "Node_panel",
        "Panel_btnList",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end

    if MergePlayerFrame._pageIDs then
        for _, id in ipairs(MergePlayerFrame._pageIDs) do
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

function MergePlayerFrameLayer:GetOpenedLayer()
    return MergePlayerFrame._pageid
end

function MergePlayerFrameLayer:GetOpenedLookState()
    return false
end

function MergePlayerFrameLayer:ChangeOpenedPage(id)
    MergePlayerFrame.ChangeOpenedPage(id)
end

function MergePlayerFrameLayer:OnCloseMainLayer()
    MergePlayerFrame.OnCloseMainLayer()
end

function MergePlayerFrameLayer:GetOpenedType()
    return MergePlayerFrame._pageWay
end

function MergePlayerFrameLayer:ChangeType(i)
    if MergePlayerFrame.ChangePageWay then
        MergePlayerFrame.ChangePageWay(i)
    end
end

function MergePlayerFrameLayer:GetOpenedShowType()
    return MergePlayerFrame._showtype
end

function MergePlayerFrameLayer:ChangeShowType(i, pageWay, pageId)
    if MergePlayerFrame.ChangeShowType then
        MergePlayerFrame.ChangeShowType(i, pageWay, pageId)
    end
end

function MergePlayerFrameLayer:GetSUIParent()
    return self._ui.Panel_1
end

return MergePlayerFrameLayer