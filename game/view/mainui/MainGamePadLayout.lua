local MainGamePadLayout = class("MainGamePadLayout", function()
    return cc.Layer:create()
end)

local enableSizeWalk        = cc.size(150, 160)     -- 双摇杆 走
local enableSizeRun         = cc.size(370, 370)     -- 双摇杆 跑
local enableSizeAll         = cc.size(290, 335)     -- 单摇杆 走 跑

local originPosWalk         = cc.p(100, 105)        -- 双摇杆 走
local originPosRun          = cc.p(200, 205)        -- 双摇杆 跑
local originPosAll          = cc.p(150, 155)        -- 双摇杆 跑

function MainGamePadLayout:ctor()
    self._path = global.MMO.PATH_RES_PRIVATE .. "main/Rocker/"

    self._angle             = 0xff  -- joystick 方向(度数)
    self._joystickType      = 1     -- 1走摇杆  2跑摇杆
    self._curTouchId        = nil
end

function MainGamePadLayout.create(...)
    local layout = MainGamePadLayout.new()
    if layout:Init(...) then
        return layout
    end
    return nil
end

function MainGamePadLayout:Init(pType)
    self._joystickType      = pType
    self._enableSize        = (self._joystickType == 1 and enableSizeWalk or enableSizeRun) -- 触摸有效区

    -- 背景
    local path              = (self._joystickType == 1 and self._path .. "1900012073.png" or self._path .. "1900012073.png")
    self._bg                = cc.Sprite:create(path) -- 背景

    local bgSize            = self._bg:getContentSize()
    self._bgSize            = bgSize
    self._bgOrigin          = (self._joystickType == 1 and originPosWalk or originPosRun)  -- 背景默认位置
    self._limitRadius       = bgSize.width * 0.3 -- joystick限制半径
    self._limitRadiusSq     = self._limitRadius * self._limitRadius -- 半径的平方
    self._joystickOrigin    = cc.p(bgSize.width * 0.5, bgSize.height * 0.5) -- joystick 原点

    self:setContentSize(self._enableSize)
    self._bg:setPosition(self._bgOrigin)
    self._bg:setCascadeOpacityEnabled(true)
    self:addChild(self._bg)

    -- 摇杆
    self._gamePad       = cc.Sprite:create(self._path .. "1900012070.png")
    self:addChild(self._gamePad)
    self._gamePad:setPosition(cc.p(self._bgSize.width / 2, self._bgSize.height / 2))

    -- 走跑提醒
    local contentSize   = self._gamePad:getContentSize()
    local fileName      = self._joystickType == 1 and "1900012076.png" or "1900012075.png"
    self._joystickTips  = cc.Sprite:create(self._path .. fileName)
    self._gamePad:addChild(self._joystickTips)
    self._joystickTips:setPosition(cc.p(contentSize.width/2, contentSize.height/2))

    -- 箭头
    self._arrowTips     = cc.Sprite:create(self._path .. "1900012074.png")
    self._bg:addChild(self._arrowTips)

    -- 走/跑切换
    self._buttonMode = ccui.Button:create()
    self:addChild(self._buttonMode)
    self._buttonMode:setAnchorPoint(cc.p(0, 0))
    self._buttonMode:setPosition(cc.p(0, 28))
    self._buttonMode:loadTextureNormal(self._path .. "bg_jindutiao_16.png")
    self._buttonMode:addClickEventListener(function()
        local joystickMode = GET_CLOUD_DATA("joystick_mode") or 2
        SET_CLOUD_DATA("joystick_mode", 3-joystickMode)

        global.Facade:sendNotification(global.NoticeTable.Layer_Main_JoystickUpdate)
    end)

    self:gamePadVisible(false)
    self:gamePadTipsVisible(false)
    self:registerTouchListener()
    self:UpdateJoystickMode()

    -- self:InitTouchLayout() -- for debug
    self:OnRocker_Show_Distance_Change()
    return true
end

function MainGamePadLayout:onTouchBegan(touch, event)
    if not self:isVisible() then
        return false
    end

    if not self:CheckTouch(touch) then -- 是否是当前触摸对象
        return false
    end

    if not self:checkGamePadRect(touch) then -- 是否在点击rect
        return false
    end

    self._curTouchId = touch:getId()

    self:gamePadVisible(true)
    self:gamePadTipsVisible(false)
    self:JoystickLogic(touch)

    return true
end

function MainGamePadLayout:onTouchMoved(touch, event)
    if not self:CheckTouch(touch) then
        return
    end

    self:JoystickLogic(touch)
end

function MainGamePadLayout:onTouchEnded(touch, event)
    if not self:CheckTouch(touch) then
        return
    end

    self:Ray2Scene(touch)

    self:ResetGamePad()
end

function MainGamePadLayout:Ray2Scene(touch)
    -- 只响应在盲区的
    if self._angle ~= 0xFF then
        return
    end

    local worldPos = self:convertTouchToNodeSpace(touch)

    local touchPos  = worldPos
    local touchWay  = global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L
    local eventType = cc.Handler.EVENT_TOUCH_BEGAN
    global.gamePlayerController:HandleTouchEndEvent(touchPos, touchWay, eventType)
end

function MainGamePadLayout:CheckTouch(touch)
    if (self._curTouchId ~= nil and self._curTouchId ~= touch:getId()) then
        return false
    end

    return true
end

function MainGamePadLayout:checkGamePadRect(touch)
    local bOutSide    = true
    local touchPoint  = self:convertTouchToNodeSpace(touch)
    local gamePadRect = cc.rect(0, 0, self._enableSize.width, self._enableSize.height)

    if (cc.rectContainsPoint(gamePadRect, touchPoint)) then
        self._bg:setPosition(touchPoint)
        bOutSide = false
    end

    return not bOutSide
end

function MainGamePadLayout:gamePadVisible(visible)
    self._bg:setVisible(visible)
end

function MainGamePadLayout:gamePadTipsVisible(visible)
    self._arrowTips:setVisible(visible)
end

function MainGamePadLayout:JoystickLogic(touch)
    -- swallow touch
    self._listener:setSwallowTouches(true)

    local touchPoint    = self._bg:convertTouchToNodeSpace(touch)
    local targPos, step = self:calcTargPos(touchPoint)
    local bgOriginPos   = cc.p(self._bg:getPositionX()-self._bgSize.width/2, self._bg:getPositionY()-self._bgSize.height/2)
    self._gamePad:setPosition(cc.pAdd(bgOriginPos, targPos))
    self._gamePad:stopAllActions()

    self:SetGamePadDir(cc.pSub(targPos, self._joystickOrigin), step)
end

function MainGamePadLayout:calcTargPos(movePos)
    local diff = cc.pSub(movePos, self._joystickOrigin)
    local distSq = cc.pLengthSQ(diff)

    if (distSq <= self._limitRadiusSq) then
        return movePos, 1
    end

    -- out of bound, clamp it.
    diff = cc.pNormalize(diff)
    diff = cc.pMul(diff, self._limitRadius)

    return cc.pAdd(self._joystickOrigin, diff), 2
end

function MainGamePadLayout:SetGamePadDir(vec, step)
    local dis = cc.pLengthSQ(vec)
    if (dis <= 50) then --// 触摸盲区
        self._angle = 0xff
        self._step  = 1

        self:gamePadTipsVisible(false)
    else
        self._angle = math.deg(cc.pToAngleSelf(vec))
        self._step  = step

        self:checkArrowTips()
    end
end

function MainGamePadLayout:checkArrowTips()
    local angle    = 90 - self._angle
    self._arrowTips:setRotation(angle)
    
    local radius   = self._bgSize.width/2 + 10
    local sinValue = math.sin(self._angle/57.29577951)
    local cosValue = math.cos(self._angle/57.29577951)
    local offsetX  = radius * cosValue
    local offsetY  = radius * sinValue
    self._arrowTips:setPosition(cc.p(self._bgSize.width / 2 + offsetX, self._bgSize.height / 2 + offsetY))

    self:gamePadTipsVisible(true)
end

function MainGamePadLayout:ResetGamePad()
    if (self._listener) then
        self._listener:setSwallowTouches(false)
    end

    self._angle      = 0xFF
    self._move       = 1
    self._curTouchId = nil
    self:gamePadVisible(false)
    self:gamePadTipsVisible(false)
    self._bg:setPosition(self._bgOrigin)
    self._gamePad:stopAllActions()
    self._gamePad:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.3, self._bgOrigin)))
end

function MainGamePadLayout:GetGamePadAngle()
    return self._angle
end

function MainGamePadLayout:GetGamePadStep()
    return self._step
end

function MainGamePadLayout:InitTouchLayout()
    -- init touch layer
    -- init touch layer
    if self._touchLayout then
        self._touchLayout:removeFromParent()
        self._touchLayout = nil
    end
    self._touchLayout = ccui.Layout:create()
    local viewSize = global.Director:getVisibleSize()
    self._touchLayout:setContentSize(self._enableSize.width, self._enableSize.height)
    self._touchLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    self._touchLayout:setBackGroundColor(self._ctrlMode == 2 and cc.Color3B.GREEN or cc.Color3B.RED)
    self._touchLayout:setAnchorPoint(0, 0)
    self._touchLayout:setOpacity(100)
    self:addChild(self._touchLayout, 0)
end

function MainGamePadLayout:registerTouchListener()
    local function began(touch, event)
        return self:onTouchBegan(touch, event)
    end
    local function moved(touch, event)
        return self:onTouchMoved(touch, event)
    end
    local function ended(touch, event)
        return self:onTouchEnded(touch, event)
    end
    local function cancelled(touch, event)
        return self:onTouchEnded(touch, event)
    end

    self:setTouchEnabled(true)
    local listener = cc.EventListenerTouchOneByOne:create()
    local eventDispatcher = global.Director:getEventDispatcher()
    listener:registerScriptHandler(began, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(moved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(ended, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(cancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self._listener = listener
end

function MainGamePadLayout:SetDir(dir)
    if not dir or not dir.x or not dir.y then
        return
    end

    local targPos1      = cc.p((dir.x + 1) * self._bgSize.width * 0.5, (dir.y + 1) * self._bgSize.height * 0.5)
    local targPos       = self:calcTargPos(targPos1)
    local bgOriginPos   = cc.p(self._bg:getPositionX()-self._bgSize.width/2, self._bg:getPositionY()-self._bgSize.height/2)
    self._gamePad:stopAllActions()
    self._gamePad:setPosition(cc.pAdd(bgOriginPos, targPos))

    self:SetGamePadDir(cc.pSub(targPos, self._joystickOrigin))
    self:checkArrowTips()

    if 0 == dir.x and 0 == dir.y then
        self:ResetGamePad()
    else
        self:gamePadVisible(true)
        self:gamePadTipsVisible(true)
    end
end

function MainGamePadLayout:UpdateJoystickMode()
    if CHECK_SETTING(6) ~= 1 or (SL:GetMetaValue("GAME_DATA","gameOption_WalkOnly") == 1) then
        -- 单摇杆

        -------------------------
        self._enableSize        = enableSizeAll     -- 触摸有效区
        self._bgOrigin          = originPosAll      -- 背景默认位置
        self:setContentSize(self._enableSize)
        self._bg:setPosition(self._bgOrigin)

        -- 摇杆背景
        self._bg:setTexture(self._path .. "1900012073.png")
        local bgSize            = self._bg:getContentSize()
        self._limitRadius       = bgSize.width * 0.3 -- joystick限制半径
        self._limitRadiusSq     = self._limitRadius * self._limitRadius -- 半径的平方
        self._joystickOrigin    = cc.p(bgSize.width * 0.5, bgSize.height * 0.5) -- joystick 原点
        self._bgSize            = bgSize

        -- 摇杆中间球
        self._gamePad:setTexture(self._path .. "1900012070.png")
        self._gamePad:setPosition(cc.p(0,0))
        local gamePadSize       = self._gamePad:getContentSize()
        self._joystickTips:setPosition(cc.p(gamePadSize.width/2, gamePadSize.height/2))
        -------------------------

        -- 摇杆
        local joystickMode      = GET_CLOUD_DATA("joystick_mode") or 2
        if joystickMode == 1 then
            -- 走
            self:setVisible(self._joystickType == 1)
            self._buttonMode:loadTextureNormal(self._path .. "bg_jindutiao_17.png")
            self._buttonMode:setVisible(true)
        else
            -- 跑
            self:setVisible(self._joystickType == 2)
            self._buttonMode:loadTextureNormal(self._path .. "bg_jindutiao_16.png")
            self._buttonMode:setVisible(true)
        end

        -- 走 -> 跑
        if (SL:GetMetaValue("GAME_DATA","gameOption_WalkOnly") == 1) then
            self:setVisible(self._joystickType == 2)
            self._buttonMode:setVisible(false)
        end
    else
        -- 双摇杆

        -------------------------
        -- 响应区域
        self._enableSize        = (self._joystickType == 1 and enableSizeWalk or enableSizeRun) -- 触摸有效区
        self._bgOrigin          = (self._joystickType == 1 and originPosWalk or originPosRun)  -- 背景默认位置
        self:setContentSize(self._enableSize)
        self._bg:setPosition(self._bgOrigin)
        
        -- 背景
        self._bg:setTexture(self._path .. (self._joystickType == 1 and "1900012072.png" or "1900012073.png"))
        local bgSize            = self._bg:getContentSize()
        self._bgSize            = bgSize
        self._limitRadius       = bgSize.width * 0.5 -- joystick限制半径
        self._limitRadiusSq     = self._limitRadius * self._limitRadius -- 半径的平方
        self._joystickOrigin    = cc.p(bgSize.width * 0.5, bgSize.height * 0.5) -- joystick 原点


        -- 摇杆中间球
        self._gamePad:setTexture(self._path .. (self._joystickType == 1 and "1900012070.png" or "1900012071.png"))
        self._gamePad:setPosition(cc.p(self._bgSize.width / 2, self._bgSize.height / 2))
        local gamePadSize       = self._gamePad:getContentSize()
        self._joystickTips:setPosition(cc.p(gamePadSize.width/2, gamePadSize.height/2))
        -------------------------

        -- 遥感显示隐藏
        self:setVisible(true)
        self._buttonMode:setVisible(false)
    end

    self:ResetGamePad()

    -- self:InitTouchLayout()
end
function MainGamePadLayout:OnRocker_Show_Distance_Change()
    local distance = CHECK_SETTING(global.MMO.SETTING_IDX_ROCKER_SHOW_DISTANCE) or 0
    originPosWalk         = cc.p(100+distance, 105)        -- 双摇杆 走
    originPosRun          = cc.p(200+distance, 205)        -- 双摇杆 跑
    originPosAll          = cc.p(150+distance, 155)        -- 双摇杆 跑
    self._bgOrigin        = (self._joystickType == 1 and originPosWalk or originPosRun)  -- 背景默认位置
    if CHECK_SETTING(6) ~= 1 or (SL:GetMetaValue("GAME_DATA","gameOption_WalkOnly") == 1) then
        self._bgOrigin = originPosAll
    end
    self._bg:setPosition(self._bgOrigin)
    self:ResetGamePad()
end

return MainGamePadLayout
