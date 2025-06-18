local BaseLayer = requireLayerUI("BaseLayer")
local HeroFrameLayer = class("HeroFrameLayer", BaseLayer)

local RichTextHelper = requireUtil("RichTextHelp")

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
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_LOOK_FRAME)
    HeroFrame_Look.main(data)
end

function HeroFrameLayer:GetOpenedLayer()
    return HeroFrame_Look._pageid
end

function HeroFrameLayer:GetOpenedLookState()
    return true
end

function HeroFrameLayer:ChangeOpenedPage(id)
    HeroFrame_Look.ChangeOpenedPage(id)
end

function HeroFrameLayer:OnCloseMainLayer()
    HeroFrame_Look.OnCloseMainLayer()
end

function HeroFrameLayer:GetSUIParent()
    return self._ui.Panel_1
end

return HeroFrameLayer