local BaseLayer = requireLayerUI("BaseLayer")
local TopTouchLayer = class("TopTouchLayer", BaseLayer)
local cjson = require( "cjson" )

TopTouchLayer.OFFLINE_CHECK_INTERVAL = 15

function TopTouchLayer:ctor()
    TopTouchLayer.super.ctor(self)

    self._touchBeginListener = {}
end

function TopTouchLayer.create()
    local layout = TopTouchLayer.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function TopTouchLayer:Init()
    --
    local viewSize = global.Director:getVisibleSize()
    local layoutFill = ccui.Layout:create()
    self:addChild(layoutFill)
    layoutFill:setContentSize(viewSize)

    local sfx = global.FrameAnimManager:CreateSFXAnim(global.MMO.SFX_TOUCH_VIEW)
    layoutFill:addChild(sfx)
    sfx:Stop()
    sfx:setVisible(false)
    sfx:SetAnimEventCallback(function()
        sfx:Stop()
        sfx:setVisible(false)
    end)

    local function touchCallback(sender, eventType)
        if eventType == 0 then
            global.userInputController:onEventUserInput()
            global.userInputController:setIsTouching(true)

            sfx:setVisible(true)
            sfx:Stop()
            sfx:Play(0, 0, true)
            sfx:setPosition(sender:getTouchBeganPosition())
            
        elseif eventType == 2 or eventType == 3 then
            global.userInputController:onEventUserInput()
            global.userInputController:setIsTouching(false)
        end
    end
    layoutFill:addTouchEventListener(touchCallback)
    layoutFill:setTouchEnabled(true)
    layoutFill:setSwallowTouches(false)

    local  NPCallBack = function()
        local jData = {}
        local jsonString = (jData and cjson.encode(jData))
        local methodName = "GN_CheckNp"
        NativeBridgeCtl:Inst():sendMessage2Native(methodName, jsonString)
    end

    if global.isWindows then
        --增加一个定时器，每1秒查询一次NP是否正常运行。
        schedule(self,NPCallBack,1)
    end

    return true
end

return TopTouchLayer
