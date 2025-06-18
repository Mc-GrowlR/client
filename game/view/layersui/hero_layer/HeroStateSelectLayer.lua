local BaseLayer = requireLayerUI("BaseLayer")
local HeroStateSelectLayer = class("HeroStateSelectLayer", BaseLayer)


function HeroStateSelectLayer:ctor()
    HeroStateSelectLayer.super.ctor(self)
end

function HeroStateSelectLayer.create(data)
    local ui = HeroStateSelectLayer.new()

    if ui and ui:Init(data) then
        return ui
    end

    return nil
end
function HeroStateSelectLayer:Init(data)
    return true
end

function HeroStateSelectLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_STATE_SELECT)
    HeroStateSelect.main(data)
    self._root = HeroStateSelect._ui
end

function HeroStateSelectLayer:refState()
    HeroStateSelect.refState()
end
return HeroStateSelectLayer