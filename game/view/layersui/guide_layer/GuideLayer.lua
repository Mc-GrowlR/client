local BaseLayer = requireLayerUI("BaseLayer")
local GuideLayer = class("GuideLayer", BaseLayer)

local sformat       = string.format
local RichTextHelp  = requireUtil("RichTextHelp")
local SUILoader     = require("sui/SUILoader").new()
local LexicalHelper = require("sui/LexicalHelper")
GuideLayer._path = global.MMO.PATH_RES_PRIVATE .. "guide/"

function GuideLayer:ctor()
    GuideLayer.super.ctor(self)
end

function GuideLayer.create()
    local layer = GuideLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function GuideLayer:Init()
    return true
end

function GuideLayer:OnUpdate(task)
    self:stopAllActions()
    self:removeAllChildren()

    -- calc convert pos
    -- local parent        = task:GetParent()
    -- local nodePos       = cc.p(parent:getPositionX(), parent:getPositionY())
    -- local worldPos      = parent:convertToWorldSpace(nodePos)
    -- local pos = cc.p(self:getPosition())
    -- local convertOffset = self:convertToNodeSpace(cc.p(0, 0))
    -- self:setPosition(pos.x+convertOffset.x,pos.y+convertOffset.y)

    self._task = task and task or self._task --只刷新
    -- local config = self._task:GetConfig()

    -- if config.compel then
        
      self:ShowForceGuide()
    -- else
    --     self:ShowtSoftGuide()
    -- end
end

local function getShowEnable(config)
    if config.hide_tips == 1 then
        return false
    end
    return true
end

function GuideLayer:PerformAuto(remaining, callback)
    performWithDelay(self, callback, remaining)
end

function GuideLayer:ShowDesc(wid, hei, pos,desc)
    -- local path = sformat("guide/desc_dir_%s", config.dir)
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
    local windex = string.find(desc,"widget:")
    if windex and windex == 1 then 

        local function callback(data)
            local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
            SUIComponentProxy:SubmitAct(data)
        end

            local widgetstr = string.sub(desc,windex+7)
            local elements      = LexicalHelper:Parse(widgetstr)
            local rootRect      = cc.rect(0, 0, 0, 0)
            local trunk         = SUILoader:loadContent(elements, callback, nil, rootRect)
            local widget        = trunk.render
            nodeDesc:addChild(widget)
        else
            local richText = RichTextHelp:CreateRichTextWithXML(desc or "", 400, 16, "#ffffff")
            nodeDesc:addChild(richText)
        end
    

    -- local rootPosDisX = {-wid/2, -wid/2, 0, wid/2, wid/2, wid/2, 0, -wid/2}
    -- local rootPosDisY = {0, hei/2, hei/2, hei/2, 0, -hei/2, -hei/2, -hei/2}
    -- local endedPos = cc.pAdd(pos, {x=rootPosDisX[config.dir], y=rootPosDisY[config.dir]})
    local pWpos = self:convertToNodeSpace(pos)
    root:setPosition(pWpos.x+(isleft and -wid/2 or wid/2),pWpos.y)

    -- local moveByDisX = {-10, -10, 0, 10, 10, 10, 0, -10}
    -- local moveByDisY = {0, 10, 10, 10, 0, -10, -10, -10}
    local disX = isleft and  10 or -10--moveByDisX[config.dir]
    local disY = 0--moveByDisY[config.dir]
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

function GuideLayer:ShowRim(wid, hei, pos)
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
        local pWpos = self:convertToNodeSpace(pos)
        image:setPosition(pWpos.x + xPosScale[i] * (wid / 2), pWpos.y + yPosScale[i] * (hei / 2))
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

function GuideLayer:ShowtSoftGuide(data)
end

function GuideLayer:ShowForceGuide(data)
    local wid
    local hei
    local pos
    if self._task._position and self._task._contentSize then
        pos = self._task._position
        wid = self._task._contentSize.width
        hei = self._task._contentSize.height
    else
        local widget = self._task:GetWidget()
        dump(widget,"widget___")
        if tolua.isnull(widget) then
            return 
        end
        -- local worldPos 
        -- if widget.getWorldPosition then 
        --     worldPos = widget:getWorldPosition()
        -- else
        --     return
        local worldPos = widget:convertToWorldSpace(cc.p(0,0))
        -- end
        local content = widget:getContentSize()
        --local anchor = widget:getAnchorPoint()
        local scaleX = widget:getScaleX()
        local scaleY = widget:getScaleY()
        wid = content.width * scaleX
        hei = content.height * scaleY
        pos = {
            x = worldPos.x + 0.5 * wid,
            y = worldPos.y + 0.5 * hei
        }
        -- pos = worldPos
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
    local nodePos =  self:convertToNodeSpace(cc.p(0,0))
    clippingNode:setPosition(nodePos)




    local function touchCallback(_, eventType)
        local clipBox = layoutClip:getBoundingBox()
        if eventType == 0 then
            local beganPos = layoutBlack:getTouchBeganPosition()
            local isTouchedBox = cc.rectContainsPoint(clipBox, beganPos)
            layoutBlack:setSwallowTouches(not isTouchedBox)
            if self._task._clickCallback then--如果有自定义的触发条件就吞噬
                layoutBlack:setSwallowTouches(true)
            end
        elseif eventType == 2 then
            local endPos = layoutBlack:getTouchEndPosition()
            local isTouchedBox2 = cc.rectContainsPoint(clipBox, endPos)
            if isTouchedBox2 then

                local func = function ( )
                    if self._task._clickCallback then
                        self._task._clickCallback()
                    end
                    global.Facade:sendNotification(global.NoticeTable.GuideStop)
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
                
            end
        end
    end

    layoutBlack:addTouchEventListener(touchCallback)

    -- 不显示箭头和框框
    -- local enable = getShowEnable(config)
    -- if not enable then
    --     return false
    -- end

    -- 延迟显示
    -- local function callback()
        layoutBlack:setBackGroundColorOpacity(100)

        -- if config.size then
        --     local slices = string.split(config.size, "#")
        --     wid = tonumber(slices[1])
        --     hei = tonumber(slices[2])
        -- end
        -- if config.offset then
        --     local slices = string.split(config.offset, "#")
        --     pos.x = pos.x + tonumber(slices[1])
        --     pos.y = pos.y + tonumber(slices[2])
        -- end
        local desc = self._task._data.desc
        self:ShowRim(wid, hei, pos)
        self:ShowDesc(wid, hei, pos,desc)
    -- end
    -- callback()
    -- performWithDelay(self, callback, 0)
end

return GuideLayer
