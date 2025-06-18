
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerBuffLayer = class("PlayerBuffLayer", BaseLayer)

function PlayerBuffLayer:ctor()
    PlayerBuffLayer.super.ctor(self)
end

function PlayerBuffLayer.create(...)
    local ui = PlayerBuffLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function PlayerBuffLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function PlayerBuffLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_LOOK_BUFF)
    PlayerBuff_Look.main(data)

    self._root = self._ui.Panel_1
end

function PlayerBuffLayer:OnClose()
    if PlayerBuff_Look and PlayerBuff_Look.OnClose then
        PlayerBuff_Look.OnClose()
    end
end


return PlayerBuffLayer

