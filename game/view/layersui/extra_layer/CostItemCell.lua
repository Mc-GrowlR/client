local CacheWidget = requireUtil("CacheWidget")
local CostItemCell = class("CostItemCell", CacheWidget)

local ssplit = string.split
local sformat = string.format
local RichTextHelp = requireUtil("RichTextHelp")

function CostItemCell:ctor()
    CostItemCell.super.ctor(self)

    self._status = true
end

function CostItemCell:create(data, extra)
    local layer = CostItemCell.new()
    if layer:Init(data, extra) then
        return layer
    end
    return nil
end

function CostItemCell:Init(data, extra)
    self:InitWidgetConfig("extra/cost_cell.lua")

    self._layoutBG = self._widget:getChildByName("Panel_bg")

    -- calc contentSize、position
    local content = self._layoutBG:getContentSize()
    self:setContentSize(content)
    self._layoutBG:setPosition({x = content.width / 2, y = content.height / 2})

    --
    self._nodeTitle = self._layoutBG:getChildByName("Node_title")
    self._nodeIcon  = self._layoutBG:getChildByName("Node_icon")
    self._nodeCount = self._layoutBG:getChildByName("Node_count")

    -- click item tips
    self._layoutBG:setTouchEnabled(false)
    RemoveAllWidgetClickEventListener(self._layoutBG)

    self:Cleanup()

    -- data update
    self:Update(data, extra)

    return true
end

function CostItemCell:OnEnter()
    -- addTo manager
    global.Facade:sendNotification(global.NoticeTable.AddCostItemCell, self)
end

function CostItemCell:OnExit()
    -- remove
    global.Facade:sendNotification(global.NoticeTable.RmvCostItemCell, self)
end

function CostItemCell:Cleanup()
    self._data = nil
    self._extra = nil
    self._status = true
    self._updateCallback = nil

    self:setAnchorPoint({x = 0.5, y = 0.5})
    self:setPositionX(0)
    self:setPositionY(0)
end

function CostItemCell:GetStatus()
    return self._status
end

function CostItemCell:addUpdateCallback(callback)
    self._updateCallback = callback
end

function CostItemCell:Update(data, extra)
    self._data = data or "1#1"
    self._extra = extra or {}

    -- default auto size
    self._extra.autoSize = ((self._extra.autoSize == nil) and true or self._extra.autoSize)

    -- update cells
    self:OnUpdate()
end

function CostItemCell:OnUpdate()
    local proxyPay = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
    local proxyItemConfig = global.Facade:retrieveProxy(global.ProxyTable.ItemConfig)

    local sItems = ssplit(self._data, "#")
    local id = tonumber(sItems[1]) or 1
    local count = tonumber(sItems[2]) or 1

    self._notRefresh = self._extra and self._extra.notRefesh
    
    local goodsData = {}
    goodsData.index = id
    goodsData.count = self._extra.showItemCount
    goodsData.noMouseTips = self._extra.noMouseTips
    goodsData.mouseCheckTimes = self._extra.mouseCheckTimes
    local goodsItem = GoodsItem:create(goodsData)
    self._nodeIcon:removeAllChildren()
    self._nodeIcon:addChild(goodsItem)
    goodsItem:setScale(0.5)

    --bOneID :cost Equivalent replacement
    local bOneID = true
    if self._extra and self._extra.bOneID == false then
        bOneID = self._extra.bOneID
    end

    local itemCount = proxyPay:GetItemCount(id, bOneID)

    if self._extra and self._extra.speicalYuanBao then
        local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
        local typeConfig = MoneyProxy:GetMoneyType()
        if id == typeConfig.BindYuanBao then
            itemCount = itemCount + proxyPay:GetItemCount(typeConfig.YuanBao, false)
        end
    end

    if self._extra and self._extra.moreID then 
        for i, v in ipairs(self._extra.moreID) do
            itemCount = proxyPay:GetItemCount(v, bOneID)
        end
    end
    local contentStr = ""
    local colorIdEnough = "#28ef01"
    local colorIdLess = "#ff0500"
    if self._extra and (self._extra.cutLineData) then
        colorIdEnough = "#28ef01"
        colorIdLess = "#ff0500"
    end

    if not (self._extra and self._extra.touchEnbaled) then
        -- click item tips
        self._layoutBG:setTouchEnabled(true)
        RemoveAllWidgetClickEventListener(self._layoutBG)
        self._layoutBG:addClickEventListener(
            function()
                local items = ssplit(self._data, "#")
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, {typeId = tonumber(items[1]), pos=self._layoutBG:getTouchEndPosition()})
            end
        )
    else
        self._layoutBG:setTouchEnabled(false)
    end

    if self._extra and self._extra.limit then
        local countStr = count
        local itemCountStr = itemCount
        if self._extra.lessNum then
            local pointBit = self._extra.pointBit or 0 --保留小数点后的位数
            local placeholderFunc = function(countNum)
                local nDecimal = math.pow(10, pointBit)
                local nTemp = math.floor(countNum * nDecimal)
                local nRet = nTemp / nDecimal
                return nRet;
            end
            if self._extra.lessNum == 2 then
                if count >= 10000000 then
                    countStr = placeholderFunc(count / 10000) .. GET_STRING(1005)
                    if self._extra.showItemLess then
                        itemCountStr = placeholderFunc(itemCount / 10000)
                        if itemCount >= 10000000 then
                            itemCountStr = itemCountStr .. GET_STRING(1005)
                        end
                    end
                end
            else
                if count >= 100000000 then
                    countStr = placeholderFunc(count / 100000000) .. GET_STRING(1045)
                    if self._extra.showItemLess then
                        itemCountStr = placeholderFunc(itemCount / 100000000)
                        if itemCount >= 100000000 then
                            itemCountStr = itemCountStr .. GET_STRING(1045)
                        end
                    end
                elseif count >= 10000 then
                    countStr = placeholderFunc(count / 10000) .. GET_STRING(1005)
                    if self._extra.showItemLess then
                        itemCountStr = placeholderFunc(itemCount / 10000)
                        if itemCount >= 10000 then
                            itemCountStr = itemCountStr .. GET_STRING(1005)
                        end
                    end
                end
            end
        end

        if self._extra.showItemLess then
            contentStr =
                sformat(
                "<font color='%s'>%s</font>/%s",
                itemCount >= count and colorIdEnough or colorIdLess,
                itemCountStr,
                countStr
            )
        else
            contentStr =
                sformat(
                "<font color='%s'>%s</font>",
                itemCount >= count and colorIdEnough or colorIdLess,
                countStr
            )
        end
    else
        contentStr =
            sformat(
            "<font color='%s'>%s</font>/%s",
            itemCount >= count and colorIdEnough or colorIdLess,
            itemCount,
            count
        )
    end

    -- calc status
    self._status = itemCount >= count

    local richTextSize = SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16
    local richTextColor = "#ffffff"
    local richText = RichTextHelp:CreateRichTextWithXML(contentStr, 400, richTextSize, richTextColor)
    richText:setAnchorPoint({x = 0, y = 0.5})
    self._nodeCount:removeAllChildren()
    self._nodeCount:addChild(richText)

    local hasTitle =  not self._extra or not self._extra.noTitle
    -- title
    local title = nil
    if self._extra and self._extra.titlePath then
        title = ccui.ImageView:create()
        title:loadTexture(self._extra.titlePath)
    elseif self._extra and self._extra.titleText then
        title = ccui.Text:create()
        title:setFontName("fonts/font2.ttf")
        title:setFontSize(SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16)
        title:setString(self._extra.titleText)
        GUI:Text_setTextColor(title, self._extra.titleColor or "#ffffff")
        GUI:Text_enableOutline(title, "#111111", 1)
    else
        title = ccui.Text:create()
        title:setFontName("fonts/font2.ttf")
        title:setFontSize(SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16)
        title:setString(GET_STRING(1081))
        GUI:Text_setTextColor(title, "#ffffff")
        GUI:Text_enableOutline(title, "#111111", 1)
    end
    self._nodeTitle:removeAllChildren()
    if hasTitle then
        self._nodeTitle:addChild(title)
        title:setAnchorPoint({x=0, y=0.5})
    end
    
    -- calc contentSize、position again
    if self._extra and self._extra.autoSize then
        richText:ignoreContentAdaptWithSize(false)
        richText:formatText()

        local dis = 1
        -- width
        local wid = 0
        wid = wid + title:getContentSize().width + dis
        wid = wid + goodsItem:getContentSize().width / 2 + dis
        wid = wid + richText:getContentSize().width
        local content = self._layoutBG:getContentSize()
        content.width = wid

        self._layoutBG:setContentSize(content)

        local x = 0
        self._nodeTitle:setPositionX(x)
        x = x + title:getContentSize().width + goodsItem:getContentSize().width / 4 + dis
        self._nodeIcon:setPositionX(x)
        x = x + goodsItem:getContentSize().width / 4 + 3 + dis
        self._nodeCount:setPositionX(x)

        self:setContentSize(content)
        self._layoutBG:setPosition({x = content.width / 2, y = content.height / 2})
    end

    if self._updateCallback then
        self._updateCallback()
    end

    if self._extra and self._extra.cutLineData then
        local lineData = self._extra.cutLineData
        local cutLineSize = lineData.size or 3
        local cutLineBeginPos = lineData.beginPos or cc.p(-3, 0)
        local cutLineEndPos = lineData.beginPos or cc.p(richText:getContentSize().width + 3, 0)
        local cutLineColor = lineData.color or cc.c4f(1, 0, 0, 0.5)
        local cutLinePos = lineData.pos or cc.p(0, 0)
        local drawLine = CreateDrawLine(cutLineSize, cutLineBeginPos, cutLineEndPos, cutLineColor)
        drawLine:setPosition(cutLinePos)
        self._nodeCount:addChild(drawLine)
    end
end

return CostItemCell
