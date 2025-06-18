local BaseLayer = requireLayerUI("BaseLayer")
local LoadingBarLayer = class("LoadingBarLayer", BaseLayer)

function LoadingBarLayer:ctor()
    LoadingBarLayer.super.ctor(self)
end

function LoadingBarLayer.create()
    local layer = LoadingBarLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function LoadingBarLayer:Init()
    self._root = CreateExport("loading/loadingbar.lua")
    if not self._root then
        return false
    end
    self:addChild(self._root)
    self._imageBar = self._root:getChildByName("Image_bar")

    return true
end

function LoadingBarLayer:InitBar(delayTime, rotation)
    self._imageBar:stopAllActions()
    self._imageBar:runAction(cc.Sequence:create(cc.Hide:create(), cc.DelayTime:create(0.1), cc.Show:create()))
    self._imageBar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.04), cc.RotateBy:create(0, 30))))

    if delayTime then
        local function callback()
            global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)
        end
        self._imageBar:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(callback)))
    end
end

return LoadingBarLayer
