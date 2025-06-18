
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerExtraAttLayer = class("PlayerExtraAttLayer", BaseLayer)

function PlayerExtraAttLayer:ctor()
    PlayerExtraAttLayer.super.ctor(self)
end


function PlayerExtraAttLayer.create(...)
    local ui = PlayerExtraAttLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end
function PlayerExtraAttLayer:Init(data)
    return true
end

function PlayerExtraAttLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_PLAYER_EXTRA_ATT)
    PlayerExtraAtt_Look_TradingBank.main(data)
    self._root = PlayerExtraAtt_Look_TradingBank._ui.Panel_1
end
--刷新 属性
function PlayerExtraAttLayer:OnRefreshAttri()
    PlayerExtraAtt_Look_TradingBank.UpdateBaseAttri()
end
-- 刷新HP MP属性
function PlayerExtraAttLayer:OnRefreshHPMP()
    PlayerExtraAtt_Look_TradingBank.OnRefreshHPMP()
end
-- 刷新HP MP属性
function PlayerExtraAttLayer:OnClose()
    PlayerExtraAtt_Look_TradingBank.CloseCallback()
end
return PlayerExtraAttLayer