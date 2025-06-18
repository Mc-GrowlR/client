local BaseLayer = requireLayerUI("BaseLayer")
local HeroFrameLayer = class("HeroFrameLayer", BaseLayer)

function HeroFrameLayer:ctor()
    HeroFrameLayer.super.ctor(self)
end

function HeroFrameLayer.create()
    local ui = HeroFrameLayer.new()

    if ui and ui:Init() then
        return ui
    end

    return nil
end

function HeroFrameLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function HeroFrameLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_FRAME_WIN32)
    HeroFrame.main(data)
    self._root = self._ui.Panel_1 --交易行截图用 
    refPositionByParent(self)

    self:InitEditMode()
    
end

function HeroFrameLayer:InitEditMode()
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

    if HeroFrame._pageIDs then
        for _, id in ipairs(HeroFrame._pageIDs) do
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

function HeroFrameLayer:GetOpenedLayer()
    return HeroFrame._pageid
end

function HeroFrameLayer:GetOpenedLookState()
    return false
end

function HeroFrameLayer:ChangeOpenedPage(id)
    HeroFrame.ChangeOpenedPage(id)
end

function HeroFrameLayer:OnCloseMainLayer()
    HeroFrame.OnCloseMainLayer()
end

function HeroFrameLayer:GetOpenedType()
    return HeroFrame._showType
end

function HeroFrameLayer:ChangeType(i)
    if HeroFrame.ChangeShowType then
        HeroFrame.ChangeShowType(i)
    end
end

function HeroFrameLayer:GetSUIParent()
    return self._ui.Panel_1
end

return HeroFrameLayer