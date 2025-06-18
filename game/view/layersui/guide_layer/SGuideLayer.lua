local BaseLayer = requireLayerUI("BaseLayer")
local SGuideLayer = class("SGuideLayer", BaseLayer)

local sformat       = string.format
local RichTextHelp  = requireUtil("RichTextHelp")

function SGuideLayer:ctor()
    SGuideLayer.super.ctor(self)
    self._path = global.MMO.PATH_RES_PRIVATE .. "guide/"
end

function SGuideLayer.create()
    local layer = SGuideLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function SGuideLayer:Init()
    return true
end

function SGuideLayer:OnUpdate(task)
    self:stopAllActions()
    self:removeAllChildren()

    -- calc convert pos
    -- local parent        = task:GetParent()
    -- local nodePos       = cc.p(parent:getPositionX(), parent:getPositionY())
    -- local worldPos      = parent:convertToWorldSpace(nodePos)

    local pos = cc.p(self:getPosition())
    local convertOffset = self:convertToNodeSpace(cc.p(0, 0))
    self:setPosition(pos.x+convertOffset.x,pos.y+convertOffset.y)

    self._task = task and task or self._task 
    local config = self._task:GetConfig()
    self:ShowForceOrSoftGuide(config.isForce)

end

local function getShowEnable(config)
    if config.hide_tips == 1 then
        return false
    end
    return true
end

function SGuideLayer:PerformAuto(remaining, callback)
    performWithDelay(self, callback, remaining)
end

function SGuideLayer:ShowDesc(wid, hei, pos,desc)
    local config = self._task:GetConfig()
    if not config.dir then
        local path = "guide/desc_"
        local size = cc.size(186,59)
        local isleft = false
        if pos.x - wid/2 - size.width > 0 then
            isleft = true
        end
        path = path..(isleft and "1" or "2")
        local root = CreateExport(path)
        self:addChild(root)

        local nodeDesc = root:getChildByName("Panel_1"):getChildByName("Node_desc")
        local richText = RichTextHelp:CreateRichTextWithXML(desc or "", 400, 16, "#ffffff")
        nodeDesc:addChild(richText)
        root:setPosition(pos.x+(isleft and -wid/2 or wid/2),pos.y)

        local disX = isleft and  10 or -10
        local disY = 0
        root:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.MoveBy:create(0.5, {x = -disX, y = -disY}),
                    cc.MoveBy:create(0.5, {x = disX, y = disY})
                )
            )
        )

        root:setVisible(false)
        local delay =  0
        performWithDelay(root, function()
            root:setVisible(true)
        end, delay)

    else 
        local path = sformat("guide/desc_dir_%s", config.dir)
        local root = CreateExport(path)
        self:addChild(root)

        local nodeDesc = root:getChildByName("Node_desc")
        local richText = RichTextHelp:CreateRichTextWithXML(desc or "", 400, 16, "#ffffff")
        nodeDesc:addChild(richText)

        -- 2 4 6 8
        local rootPosDisX = {-wid/2, -(wid/2+10), 0, wid/2+10, wid/2, wid/2+10, 0, -(wid/2+10)}
        local rootPosDisY = {0, hei/2+10, hei/2, hei/2+10, 0, -(hei/2+10), -hei/2, -(hei/2+10)}
        local endedPos = cc.pAdd(pos, {x = rootPosDisX[config.dir], y = rootPosDisY[config.dir]})
        root:setPosition(endedPos)

        local moveByDisX = {-10, -10, 0, 10, 10, 10, 0, -10}
        local moveByDisY = {0, 10, 10, 10, 0, -10, -10, -10}
        local disX = moveByDisX[config.dir]
        local disY = moveByDisY[config.dir]
        root:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.MoveBy:create(0.5, {x = -disX, y = -disY}),
                    cc.MoveBy:create(0.5, {x = disX, y = disY})
                )
            )
        )

        root:setVisible(false)
        local delay =  0
        performWithDelay(root, function()
            root:setVisible(true)
        end, delay)
    end
    
end

function SGuideLayer:ShowRim(wid, hei, pos)
    -- 外框
    local moveDis = 5
    local xPosScale = {-1, 1, -1, 1}
    local yPosScale = {1, 1, -1, -1}
    for i = 1, 4 do
        local image = ccui.ImageView:create(self._path .. "dec_else_3.png")
        self:addChild(image)
        if i == 2 then
            image:setFlippedX(true)
        elseif i == 3 then
            image:setFlippedY(true)
        elseif i == 4 then
            image:setFlippedY(true)
            image:setFlippedX(true)
        end

        image:setPosition(pos.x + xPosScale[i] * (wid / 2), pos.y + yPosScale[i] * (hei / 2))
        local disX = xPosScale[i] * moveDis
        local disY = yPosScale[i] * moveDis
        image:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.MoveBy:create(0.5, cc.p(-disX, -disY)),
                    cc.MoveBy:create(0.5, cc.p(disX, disY))
                )
            )
        )
    end
end

function SGuideLayer:ShowForceOrSoftGuide(isForce)
    local wid
    local hei
    local pos
    if self._task._position and self._task._contentSize then
        pos = self._task._position
        wid = self._task._contentSize.width
        hei = self._task._contentSize.height
    else
        local widget = self._task:GetWidget()
        if not widget or tolua.isnull(widget) then
            return 
        end
        local worldPos 
        if widget.getWorldPosition then 
            worldPos = widget:getWorldPosition()
        else
            return
        end

        local pX               = 0
        local pY               = 0
        -- if self._task._mainType then
        --     if self._task._mainType == 1 then --左上
        --         pY = global.Director:getVisibleSize().height
        --     elseif self._task._mainType == 2 then   -- 中上
        --         pX = global.Director:getVisibleSize().width/2
        --         pY = global.Director:getVisibleSize().height
        --     elseif self._task._mainType == 3 then   -- 右上
        --         pX = global.Director:getVisibleSize().width
        --         pY = global.Director:getVisibleSize().height
        --     elseif self._task._mainType == 4 then   -- 左下

        --     elseif self._task._mainType == 5 then   -- 中下
        --         pX = global.Director:getVisibleSize().width/2
        --     elseif self._task._mainType == 6 then   -- 右下
        --         pX = global.Director:getVisibleSize().width
        --     end
        -- end

        local content = widget:getContentSize()
        local anchor = widget:getAnchorPoint()
        local scaleX = widget:getScaleX()
        local scaleY = widget:getScaleY()
        wid = content.width * scaleX
        hei = content.height * scaleY
        pos = {
            x = pX + worldPos.x + (0.5 - anchor.x) * wid,
            y = pY + worldPos.y + (0.5 - anchor.y) * hei
        }
    end


    -- 裁剪背景
    local layoutBlack = ccui.Layout:create()
    layoutBlack:setContentSize(global.Director:getVisibleSize())
    layoutBlack:setBackGroundColorType(1)
    layoutBlack:setBackGroundColorOpacity(0)
    layoutBlack:setBackGroundColor({r = 0, g = 0, b = 0})
    layoutBlack:setTouchEnabled(true)
    layoutBlack:setMouseEnabled(true)
    global.mouseEventController:registerMouseButtonEvent(layoutBlack, {})

    -- 裁剪模板
    local layoutClip = ccui.Layout:create()
    layoutBlack:addChild(layoutClip)
    layoutClip:setBackGroundColorType(1)
    layoutClip:setAnchorPoint(cc.p(0.5, 0.5))
    layoutClip:setPosition(pos)
    layoutClip:setContentSize({width = wid, height = hei})

    -- 裁剪
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setStencil(layoutClip)
    clippingNode:setInverted(true)
    clippingNode:setAlphaThreshold(1)
    self:addChild(clippingNode)
    clippingNode:addChild(layoutBlack)

    local function touchCallback(_, eventType)
        local clipBox = layoutClip:getBoundingBox()
        if eventType == 0 then
            local beganPos = layoutBlack:getTouchBeganPosition()
            if isForce then  -- 强制指引
                local isTouchedBox = cc.rectContainsPoint(clipBox, beganPos)
                layoutBlack:setSwallowTouches(not isTouchedBox)
                if self._task._clickCallback then--如果有自定义的触发条件就吞噬
                    layoutBlack:setSwallowTouches(true)
                end
            else
                layoutBlack:setSwallowTouches(false)
                if self._task._clickCallback and cc.rectContainsPoint(clipBox, beganPos) then
                    layoutBlack:setSwallowTouches(true)
                end
            end
        elseif eventType == 2 then
            local endPos = layoutBlack:getTouchEndPosition()
            local isTouchedBox2 = cc.rectContainsPoint(clipBox, endPos)
            if isTouchedBox2 then

                local func = function ()
                    local notExit = false
                    if self._task._clickCallback then
                        notExit = self._task._clickCallback(self._task)
                    end
                    if type(notExit) == "boolean" and notExit then
                        return
                    end
                    if self._task then
                        self._task:Exit()
                    end
                end
                if (self._task._mainID == 1 or self._task._mainID == 47) and self._task._uiID ~= -1 then -- 背包的双击使用
                    if layoutBlack._clicking then
                        func()
                        layoutBlack:stopAllActions()
                        layoutBlack._clicking = false
                    else
                        layoutBlack._clicking = true
                        performWithDelay(layoutBlack,function ()
                            layoutBlack._clicking = false
                            
                        end,global.MMO.CLICK_DOUBLE_TIME)
                    end
                else
                    func()
                end
            else -- 不在指引区域内
                if not isForce then
                    if self._task._hideMask then
                        layoutBlack:setSwallowTouches(false)
                    else
                        if self._task then
                            self._task:Exit()
                        end
                    end
                end
            end
        end
    end

    layoutBlack:addTouchEventListener(touchCallback)

    if self._task._autoExcute then
        local widget = self._task:GetWidget()
        performWithDelay(layoutBlack, function ( ... )
            local notExit = false
            if self._task._clickCallback then
                notExit = self._task._clickCallback(self._task)
            elseif widget and not tolua.isnull(widget) then
                local touchCB = global.ScriptHandlerMgr:getObjectHandler(widget)
                if tolua.type(touchCB) == "function" then
                    touchCB(widget, 2)
                end
            end
            if type(notExit) == "boolean" and notExit then
                return
            end
            if self._task then
                self._task:Exit()
            end
        end, self._task._autoExcute)
    end

    -- 不显示箭头和框框
    -- local enable = getShowEnable(config)
    -- if not enable then
    --     return false
    -- end

    layoutBlack:setBackGroundColorOpacity(100)
    if self._task._hideMask and not self._task._isForce then
        layoutBlack:setBackGroundColorOpacity(0)
    end

    local desc = self._task._desc
    self:ShowRim(wid, hei, pos)
    self:ShowDesc(wid, hei, pos,desc)
   
end

return SGuideLayer
