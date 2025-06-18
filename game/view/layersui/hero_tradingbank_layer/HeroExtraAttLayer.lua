
local BaseLayer = requireLayerUI("BaseLayer")
local HeroExtraAttLayer = class("HeroExtraAttLayer", BaseLayer)

function HeroExtraAttLayer:ctor()
    HeroExtraAttLayer.super.ctor(self)
end


function HeroExtraAttLayer.create(...)
    local ui = HeroExtraAttLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end
function HeroExtraAttLayer:Init(data)
    return true
end

function HeroExtraAttLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_HERO_EXTRA_ATT)
    HeroExtraAtt_Look_TradingBank.main(data)
    self._root = HeroExtraAtt_Look_TradingBank._ui.Panel_1
end
--刷新 属性
function HeroExtraAttLayer:OnRefreshAttri()
    HeroExtraAtt_Look_TradingBank.UpdateBaseAttri()
end
-- 刷新HP MP属性
function HeroExtraAttLayer:OnRefreshHPMP()
    HeroExtraAtt_Look_TradingBank.OnRefreshHPMP()
end
-- 刷新HP MP属性
function HeroExtraAttLayer:OnClose()
    HeroExtraAtt_Look_TradingBank.CloseCallback()
end
return HeroExtraAttLayer