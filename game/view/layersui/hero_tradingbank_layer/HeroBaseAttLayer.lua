
local BaseLayer = requireLayerUI("BaseLayer")
local HeroBaseAttLayer = class("HeroBaseAttLayer", BaseLayer)

function HeroBaseAttLayer:ctor()
    HeroBaseAttLayer.super.ctor(self)
end

function HeroBaseAttLayer:Init(data)
    return true
end

function HeroBaseAttLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_HERO_BASE_ATT)
    HeroBaseAtt_Look_TradingBank.main(data)
    self._root = HeroBaseAtt_Look_TradingBank._ui.Panel_1
end

function HeroBaseAttLayer:UpdateBaseAttriLayer(data)
    HeroBaseAtt_Look_TradingBank.UpdateBaseAttri()
end

return HeroBaseAttLayer