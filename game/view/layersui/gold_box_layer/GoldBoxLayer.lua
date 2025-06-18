local BaseLayer = requireLayerUI("BaseLayer")

local GoldBoxLayer = class("GoldBoxLayer", BaseLayer)


function GoldBoxLayer:ctor()
    GoldBoxLayer.super.ctor(self)

    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.GoldBoxProxy)
    self._rewardIndex = 0
    self._itemData = nil
    self._startPosx = 0
    self._startPosy = 0
    self._animId = {[1] = 4521, [2] = 4522, [3] = 4523, [4] = 4524, [5] = 4525, [6] = 4526, [7] = 4527, [8] = 4528, [9] = 4529}
    self._showAnimId = 4521
    self._startIndex = 0
    self._showWinAnimId = 4510

end

function GoldBoxLayer.create(data)
    local layer = GoldBoxLayer.new()
    if layer and layer:Init(data) then
        return layer
    end
    
    return nil
end

function GoldBoxLayer:Init(data)

    self._ui = ui_delegate(self)
    return true
end

function GoldBoxLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GOLD_BOX)
    GoldBox.main(data)

end


function GoldBoxLayer:GetMoveTouch()
    return self._ui.Image_bg, self._ui.Panel_main
end

function GoldBoxLayer:GetMoveLayerPos(posx, posy)
    self._startPosx = posx
    self._startPosy = posy
    return self._startPosx, self._startPosy
end

--开启动画
function GoldBoxLayer:OpenBoxAnim(itemIndex)
    if GoldBox and GoldBox.OpenBoxAnim then
        GoldBox.OpenBoxAnim(itemIndex)
    end
end

function GoldBoxLayer:RefreshLayer(data)
    if GoldBox._canClose then 
        local GoldBoxProxy = global.Facade:retrieveProxy(global.ProxyTable.GoldBoxProxy)
        GoldBoxProxy:RequsetGetBoxReward()
        GoldBoxProxy:setRefreshBoxItemData(data)
    end
end

return GoldBoxLayer
