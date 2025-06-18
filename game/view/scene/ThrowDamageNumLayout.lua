local ThrowDamageNumLayout = class("ThrowDamageNumLayout")
local Queue = requireUtil("queue")
local DamagePath = global.MMO.PATH_RES_PRIVATE .. "damage_num/"

----------------------------- param ThrowDamageNumProxy.PARAM_TYPE ---------------------------------
local TIME_PARAM     = 1
local ANCHOR_PARAM   = 2
local MOVEBY_ACTION  = 3
local SCALETO_ACTION = 4
local FADETO_ACTION  = 5
local DELAY_ACTION   = 6
----------------------------- param ---------------------------------

local zero_pos = cc.p(0, 0)

function ThrowDamageNumLayout:ctor()
    self._offsetDatas = {}
end

function ThrowDamageNumLayout.create()
    local layout = ThrowDamageNumLayout.new()
    if layout:Init() then
        return layout
    else
        return nil
    end
end

function ThrowDamageNumLayout:Init()
    self._labelCache = Queue.new()
    self._spriteCache = Queue.new()

    return true
end

function ThrowDamageNumLayout:OnClose()
    local function releaseCache(cache)
        if not cache:empty() then
            local size = cache:size()
            for i = 1, size do
                local node = cache:pop()
                node:autorelease()
            end

            cache:clear()
        end
    end

    releaseCache(self._labelCache)
    releaseCache(self._spriteCache)
end

function ThrowDamageNumLayout:createLabel(type, cfg)
    if not cfg.res or not cfg.width or not cfg.height then
        return nil
    end

    local displayNode = nil
    local cache = self._labelCache
    if cache:empty() then
        displayNode = ccui.TextAtlas:create()
    else
        displayNode = cache:pop()
        displayNode:autorelease()
    end

    if displayNode then
        displayNode:setAnchorPoint(cc.p(0, 0))
        displayNode:setProperty("", DamagePath .. cfg.res, cfg.width, cfg.height, "/")
    end

    return displayNode
end

function ThrowDamageNumLayout:createSprite(type, cfg)
    if not cfg.res or cfg.res == "" then
        return nil
    end

    local path = DamagePath .. cfg.res
    if not global.FileUtilCtl:isFileExist(path) then
        return nil
    end

    local displayNode = nil
    local cache = self._spriteCache
    if cache:empty() then
        displayNode = cc.Sprite:create()
    else
        displayNode = cache:pop()
        displayNode:autorelease()
    end

    if displayNode then
        local tex = global.TextureCache:addImage(path)
        if tex then
            displayNode:initWithTexture(tex)
        end
        displayNode:setAnchorPoint(cc.p(0, 0))
    end

    return displayNode
end

function ThrowDamageNumLayout:ThrowDamageNum(param, config, actionsDatas, offsetDatas)
    local type      = param.type
    local originNum = param.originNum
    local originPos = param.originPos
    local parent    = param.parentNode
    local speed     = 1 / param.speed

    -- 1.create node
    local displayNode = self:createLabel(type, config)
    if not displayNode then
        return nil
    end

    -- 2.setting node
    local prefix = config.prefix or ""
    displayNode:setString(prefix .. tostring(originNum))
    displayNode:setPosition(originPos)
    parent:addChild(displayNode, config.zOrder)

    -- 3.offset
    local offset = self:traceOffset(type, displayNode, offsetDatas)

    -- 4.create animation
    self:createActions(type, displayNode, actionsDatas, speed, offset)
end

function ThrowDamageNumLayout:ThrowDamagePoint(param, config, actionsDatas, offsetDatas)
    local type      = param.type
    local originNum = param.originNum
    local originPos = param.originPos
    local parent    = param.parentNode
    local speed     = 1 / param.speed

    -- 1.create node
    local displayNode = self:createLabel(type, config)
    if not displayNode then
        return nil
    end

    -- 2.setting node
    local afterfix = config.afterfix or ""
    originNum = tostring(originNum)
    local charLen = string.len(originNum)
    local charStr = ""
    local sampNum = ""
    local poinNum = ""
    local unit    = 1
    if charLen >= 17 then
        unit = 10000000000000000
        charStr = string.sub(afterfix, 8, 9)
        sampNum = string.sub(originNum, 1, charLen - 16)
        poinNum = string.sub(originNum, charLen - 15, charLen)
    elseif charLen >= 13 then
        unit = 1000000000000
        charStr = string.sub(afterfix, 6, 7)
        sampNum = string.sub(originNum, 1, charLen - 12)
        poinNum = string.sub(originNum, charLen - 11, charLen)
    elseif charLen >= 9 then
        unit = 100000000
        charStr = string.sub(afterfix, 4, 5)
        sampNum = string.sub(originNum, 1, charLen - 8)
        poinNum = string.sub(originNum, charLen - 7, charLen)
    elseif charLen >= 5 then
        unit = 10000
        charStr = string.sub(afterfix, 2, 3)
        sampNum = string.sub(originNum, 1, charLen - 4)
        poinNum = string.sub(originNum, charLen - 3, charLen)
    else
        sampNum = originNum
    end

    local unitFunc = function(num)
        local pointBit = 2
        if pointBit == 0 then
            return math.floor(num)
        end
        local iNum, fNum = math.modf(num)
        local fDecimal = math.pow(10, tostring(pointBit))
        local newFNum = math.floor(tostring(fNum * fDecimal))
        local newINum = iNum + (newFNum / fDecimal)
        return newINum
    end

    poinNum = tonumber(poinNum)
    if poinNum and poinNum > 0 then
        poinNum = unitFunc(poinNum/unit)
        if tonumber(sampNum) then
            poinNum = poinNum + tonumber(sampNum)
        end
        sampNum = ""
        poinNum = string.gsub(poinNum.."", "%." , string.sub(afterfix, 1, 1))
    else
        poinNum = ""
    end

    local prefix = config.prefix or ""
    displayNode:setString( prefix .. sampNum .. poinNum .. charStr)
    displayNode:setPosition(originPos)
    parent:addChild(displayNode, config.zOrder)

    -- 3.offset
    local offset = self:traceOffset(type, displayNode, offsetDatas)

    -- 4.create animation
    self:createActions(type, displayNode, actionsDatas, speed, offset)
end

function ThrowDamageNumLayout:ThrowSprite(param, config, actionsDatas, offsetDatas)
    local type      = config.type
    local originPos = param.originPos
    local parent    = param.parentNode
    local speed     = 1 / param.speed

    -- 1.create node
    local displayNode = self:createSprite(type, config)
    if not displayNode or not type then
        return nil
    end

    -- 2.setting node
    displayNode:setPosition(originPos)
    parent:addChild(displayNode, config.zOrder)

    -- 3.offset
    local offset = self:traceOffset(type, displayNode, offsetDatas)

    -- 4.create animation
    self:createActions(type, displayNode, actionsDatas, speed, offset)
end

function ThrowDamageNumLayout:ThrowDamageText(param, config, actionsDatas, offsetDatas)
    local type      = param.type
    local originNum = ""
    local originPos = param.originPos
    local parent    = param.parentNode
    local speed     = 1 / param.speed

    -- 1.create node
    local displayNode = self:createLabel(type, config)
    if not displayNode then
        return nil
    end

    -- 2.setting node
    local prefix = string.gsub(config.prefix, "/", "") or ""
    displayNode:setString(prefix .. tostring(originNum))
    displayNode:setPosition(originPos)
    parent:addChild(displayNode, config.zOrder)

    -- 3.offset
    local offset = self:traceOffset(type, displayNode, offsetDatas)

    -- 4.create animation
    self:createActions(type, displayNode, actionsDatas, speed, offset)
end

local function _createActionToTable(node, action_table, action_param, speed, isInit, offset)
    if not action_param then
        return false
    end

    local action_type = action_param.type

    local action = nil
    local action_time = action_param.duration or 0.2
    action_time = action_time * speed
    if action_type == MOVEBY_ACTION then
        local value = cc.p(action_param.x or 0, action_param.y or 0)
        if isInit and action_time <= 0 then
            node:setPositionX(node:getPositionX() + value.x + offset.x)
            node:setPositionY(node:getPositionY() + value.y + offset.y)
        else
            action = cc.MoveBy:create(action_time, value)
        end
    elseif action_type == SCALETO_ACTION then
        local value = action_param.value or 1
        if isInit and action_time <= 0 then
            node:setScale(value)
        else
            action = cc.ScaleTo:create(action_time, value, value)
        end
    elseif action_type == FADETO_ACTION then
        local value = (action_param.value or 1) * 255
        if isInit and action_time <= 0 then
            node:setOpacity(value)
        else
            action = cc.FadeTo:create(action_time, value)
        end
    elseif action_type == DELAY_ACTION then
        local value = action_param.value or 0.2
        action = cc.DelayTime:create(value * speed)
    elseif action_type == ANCHOR_PARAM then
        local value = cc.p(action_param.x or 0, action_param.y or 0)
        if isInit then
            node:setAnchorPoint(value)
        else
            local function setAnchor()
                node:setAnchorPoint(value)
            end
            action = cc.CallFunc:create(setAnchor)
        end
    end

    if action then
        action_table[#action_table + 1] = action
    end
end

function ThrowDamageNumLayout:createActions(type, node, actionsDatas, speed, offset)
    if nil == offset then
        offset = zero_pos
    end

    local all_actions = {}

    for i, actionsData in ipairs(actionsDatas) do
        local step_actions = {}
        for _, actionData in ipairs(actionsData) do
            _createActionToTable(node, step_actions, actionData, speed, 1 == i, offset)
        end

        if #step_actions > 0 then
            all_actions[#all_actions + 1] = cc.Spawn:create(step_actions)
        end
    end

    -- 回收阶段
    local function callback()
        self:onAnimationEnd(type, node)
    end
    all_actions[#all_actions + 1] = cc.CallFunc:create(callback)

    if #all_actions > 0 then
        local action = cc.Sequence:create(all_actions)
        node:runAction(action)
    end
end

function ThrowDamageNumLayout:onAnimationEnd(type, targetNode)
    targetNode:setScale(1)
    targetNode:setOpacity(255)
    targetNode:stopAllActions()
    targetNode:retain()
    targetNode:removeFromParent()

    -- push to cache
    if iskindof(targetNode, "ccui.TextAtlas") then
        self._labelCache:push(targetNode)
    else
        self._spriteCache:push(targetNode)
    end

    self:unTraceOffset(type, targetNode)
end

function ThrowDamageNumLayout:CreateAnim(animID, originPos, parentNode)
    if animID and originPos and parentNode then
        local anim = global.FrameAnimManager:CreateSFXAnim(animID)
        anim:SetAnimEventCallback(function()
            anim:removeFromParent()
        end)
        anim:Play(0, 0, false)

        local offsetX     = 0
        local offsetY     = 0
        local actorOffset = global.MMO.PLAYER_AVATAR_OFFSET
        anim:setPosition(originPos.x + offsetX + actorOffset.x, originPos.y + offsetY + actorOffset.y)

        parentNode:addChild(anim, animID)
    end
end

function ThrowDamageNumLayout:traceOffset(type, node, offsetParams)
    if not offsetParams or #offsetParams <= 0 then
        return zero_pos
    end

    local offsetData = self._offsetDatas[type]
    if not offsetData then
        offsetData = {
            ref       = 0,
            freeIndex = 1,
            indexes = {}
        }
        self._offsetDatas[type] = offsetData
    end

    offsetData.ref = offsetData.ref + 1
    offsetData.indexes[offsetData.freeIndex] = true
    node.idx = offsetData.freeIndex

    local offsetCount = #offsetParams
    if offsetData.ref >= offsetCount then
        offsetData.freeIndex = (offsetData.ref % offsetCount) + 1
    else
        for i = offsetData.freeIndex, offsetCount do
            if not offsetData.indexes[i] then
                offsetData.freeIndex = i
                break
            end
        end
    end

    return offsetParams[node.idx]
end

function ThrowDamageNumLayout:unTraceOffset(type, node)
    local offsetData = self._offsetDatas[type]
    if offsetData then
        offsetData.ref = offsetData.ref - 1
        if node.idx then
            if node.idx < offsetData.freeIndex then
                offsetData.freeIndex = node.idx
            end

            offsetData.indexes[node.idx] = false
            node.idx = nil
        end
    end
end

return ThrowDamageNumLayout