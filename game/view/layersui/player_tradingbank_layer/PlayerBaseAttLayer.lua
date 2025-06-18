
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerBaseAttLayer = class("PlayerBaseAttLayer", BaseLayer)

function PlayerBaseAttLayer:ctor()
    PlayerBaseAttLayer.super.ctor(self)
end

function PlayerBaseAttLayer:Init(data)
    return true
end

function PlayerBaseAttLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_PLAYER_BASE_ATT)
    PlayerBaseAtt_Look_TradingBank.main(data)
    self._root = PlayerBaseAtt_Look_TradingBank._ui.Panel_1
end

function PlayerBaseAttLayer:UpdateBaseAttriLayer(data)
    PlayerBaseAtt_Look_TradingBank.UpdateBaseAttri()
end

return PlayerBaseAttLayer