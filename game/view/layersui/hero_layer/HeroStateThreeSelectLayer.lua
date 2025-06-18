local BaseLayer = requireLayerUI("BaseLayer")
local HeroStateThreeSelectLayer = class("HeroStateThreeSelectLayer", BaseLayer)


function HeroStateThreeSelectLayer:ctor()
    HeroStateThreeSelectLayer.super.ctor(self)
end

function HeroStateThreeSelectLayer.create(data)
    local ui = HeroStateThreeSelectLayer.new()

    if ui and ui:Init(data) then
        return ui
    end

    return nil
end
function HeroStateThreeSelectLayer:Init(data)
    return true
end

function HeroStateThreeSelectLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_STATE_THREE_SELECT)
    HeroStateThreeSelect.main(data)
    self._root = HeroStateThreeSelect._ui
end

function HeroStateThreeSelectLayer:refSelect(select)
    HeroStateThreeSelect.refSelect(select)
end

function HeroStateThreeSelectLayer:refState()
    HeroStateThreeSelect.refState()
end
return HeroStateThreeSelectLayer