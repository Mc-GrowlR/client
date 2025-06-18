local BaseLayer = requireLayerUI("BaseLayer")
local PlayDiceLayer = class("PlayDiceLayer", BaseLayer)

function PlayDiceLayer:ctor()
    PlayDiceLayer.super.ctor(self)
    self._data = {}
end

function PlayDiceLayer.create(...)
    local layer = PlayDiceLayer.new()
    if layer:Init(...) then
        return layer
    else
        return nil
    end
end

function PlayDiceLayer:Init(data)
    return true
end

function PlayDiceLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAY_DICE)
    PlayDice.main(data)

    self._data = data or {}
end

function PlayDiceLayer:OnClose()
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    SUIComponentProxy:SubmitAct({npcid = self._data.npcid, Act = self._data.callback})
end

return PlayDiceLayer
