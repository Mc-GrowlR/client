local RemoteProxy = requireProxy("remote/RemoteProxy")
local PickupSpriteProxy = class("PickupSpriteProxy", RemoteProxy)
PickupSpriteProxy.NAME = global.ProxyTable.PickupSpriteProxy
local cjson    = require("cjson")



function PickupSpriteProxy:ctor()
    PickupSpriteProxy.super.ctor(self)
    self._tickTime = 0
    self._mainID = 0
    self._uiID = 0
    self._posCahce = {}
    self._metaPos = nil
end

function PickupSpriteProxy:setMetaPositon(x, y)
    x = x or 0
    y = y or 0
    self._metaPos = cc.p(x, y)
end

function PickupSpriteProxy:getMetaPositon()
    return self._metaPos
end

function PickupSpriteProxy:onRegister()
    PickupSpriteProxy.super.onRegister(self)
end

function PickupSpriteProxy:handle_MSG_SC_PICKUP_SPRITE(msg)
    local header = msg:GetHeader()
    -- dump(header,"handle_MSG_SC_PICKUP_SPRITE__")
    self._pickSprite = header.recog == 1 --是否开启
    self._pickSpriteDelay = header.param1 -- 时间间隔
    self._pickSpriteRange = header.param2--拾取范围
    self._pickSpriteMode = header.param3 -- 拾取模式 1 小精灵附近   0 自己附近  2（自己附近）一个个拾取  3（小精灵附近）一个个拾取
    local len = msg:GetDataLength()
    if len > 0 then
        local jsdata = msg:GetData():ReadString(len)
        self._pickSpriteID = jsdata
    end

    if self._pickSprite then
        self._tickTime = 0
    end
end

function PickupSpriteProxy:FindWidget(mainID, uiID)
    local GuideWidgetConfig = requireConfig("GuideWidgetConfig.lua")
    mainID = tonumber(mainID)
    local getNodesFunc = GuideWidgetConfig[mainID]
    if not getNodesFunc then
        return
    end
    local temp = { typeassist = uiID }
    local widget, parent = getNodesFunc(temp)
    return widget
end

function PickupSpriteProxy:handle_MSG_CS_PICKSPRITE_PICKUP_ANI(msg)
    local header = msg:GetHeader()
    local len = msg:GetDataLength()

    if self._mainID == 0 or self._uiID == 0 then
        return
    end

    if len > 0 then
        -----------------
        local items = {}
        local dd = msg:GetData():ReadString(len)
        local all = string.split(dd, ";")
        for i, v in ipairs(all) do
            local param = string.split(v, ",")
            table.insert(items, { id = param[1], mapX = param[2], mapY = param[3] })
        end
        -----------------
        local targetPos
        if self._metaPos then --优先使用原变量设置的坐标
            targetPos = self._metaPos
        else
            local widget = self:FindWidget(self._mainID, self._uiID)
            if not widget then
                if self._posCahce[self._mainID] and self._posCahce[self._mainID][self._uiID] then
                    self._posCahce[self._mainID][self._uiID] = nil
                end
            else
                if self._posCahce[self._mainID] and self._posCahce[self._mainID][self._uiID] then
                    targetPos = self._posCahce[self._mainID][self._uiID]
                else
                    targetPos    = widget:getWorldPosition()
                    local box    = widget:getBoundingBox()
                    local anchor = widget:getAnchorPoint()
                    local sub    = cc.pSub(cc.p(0.5, 0.5), anchor)
                    targetPos.x  = sub.x * box.width + targetPos.x
                    targetPos.y  = sub.y * box.height + targetPos.y
                    self._posCahce[self._mainID] = self._posCahce[self._mainID] or {}
                    self._posCahce[self._mainID][self._uiID] = targetPos
                end
            end
        end

        if targetPos then
            ShowFakeDropItemsJustFly2(targetPos, items)
        end
    end
end

function PickupSpriteProxy:handle_MSG_SC_SET_PICKSPRITE_FLY_DST(msg)
    local header = msg:GetHeader()
    self._mainID = header.recog --主界面id
    self._uiID = header.param1 -- 控件id
end

function PickupSpriteProxy:getPickSpriteMode()
    return self._pickSpriteMode
end

function PickupSpriteProxy:getMainID()
    return self._mainID
end

function PickupSpriteProxy:getUIID()
    return self._uiID
end

function PickupSpriteProxy:getPickSpriteID()
    return self._pickSpriteID
end

function PickupSpriteProxy:getDelayTime()
    return self._pickSpriteDelay
end

function PickupSpriteProxy:getTickTime()
    return self._tickTime
end

function PickupSpriteProxy:setTickTime(TIME)
    self._tickTime = TIME
end

function PickupSpriteProxy:getPickupRange()
    return self._pickSpriteRange
end

function PickupSpriteProxy:getPickupSpriteState()
    return self._pickSprite
end

function PickupSpriteProxy:ReqPickUpSomething(Names)
    --自动捡取
    LuaSendMsg(global.MsgType.MSG_CS_PICKSPRITE_PICKUP, 0, 0, 0, 0, Names, string.len(Names))
end

function PickupSpriteProxy:RegisterMsgHandler()
    PickupSpriteProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_PICKUP_SPRITE,                 handler(self, self.handle_MSG_SC_PICKUP_SPRITE))            -- 拾取精灵
    LuaRegisterMsgHandler(msgType.MSG_CS_PICKSPRITE_PICKUP_ANI,         handler(self, self.handle_MSG_CS_PICKSPRITE_PICKUP_ANI))   -- 拾取精灵动画
    LuaRegisterMsgHandler(msgType.MSG_SC_SET_PICKSPRITE_FLY_DST,        handler(self, self.handle_MSG_SC_SET_PICKSPRITE_FLY_DST))   -- 拾取精灵动画
end

return PickupSpriteProxy