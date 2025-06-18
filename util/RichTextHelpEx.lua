local RichTextHelpEx = class("RichTextHelpEx")
local RTextHelperEx = require("util/RTextHelperEx")
local RichTextHelp = require("util/RichTextHelp")

local default_width = 100
local default_vspace = SL:GetMetaValue("GAME_DATA","DEFAULT_VSPACE")
local default_fontSize = SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE")
local default_fontPath = global.MMO.PATH_FONT2
local default_fontColor = "#FFFFFF"

function RichTextHelpEx:addElementBr(richText)
    richText:pushBackElement(ccui.RichElementNewLine:create(0, cc.c3b(0, 0, 0), 255))
end

function RichTextHelpEx:addElementItem(richText, attr)
    local itemID = attr.itemID
    local bgVisible = attr.bgVisible == 1
    local size = attr.size or {width = 60, height = 60}

    local nWidth = size.width + 5
    local node = ccui.Layout:create()
    node:setContentSize({width = nWidth, height = size.height})

    local goodItem = GoodsItem:create({index = itemID, look = true, bgVisible = bgVisible})
    node:addChild(goodItem)

    local realSize = goodItem:getContentSize()
    goodItem:setScaleX(size.width / realSize.width)
    goodItem:setScaleY(size.height / realSize.height)
    goodItem:setPosition({x = nWidth / 2, y = size.height / 2})

    richText:pushBackElement(ccui.RichElementCustomNode:create(0, cc.c3b(0, 0, 0), 255, node))
end

function RichTextHelpEx:addElementEffect(richText, attr)
    local sfxID = attr.sfxID
    local scale = (attr.scale or 100) / 100
    local speed = attr.speed or 1
    local x = attr.x
    local y = attr.y

    local node = cc.Node:create()

    local effect = global.FrameAnimManager:CreateSFXAnim(sfxID)
    effect:Play(0, 0, true, speed)
    node:addChild(effect)

    local bBox = effect:GetBoundingBox()
    local width = scale * bBox.width + 5
    local height = scale * bBox.height
    if not x then
        x = width / 2
    end
    if not y then
        y = height / 2
    end

    node:setContentSize({width = width, height = height})

    effect:setPosition({x = x, y = y})
    effect:setScale(scale)

    richText:pushBackElement(ccui.RichElementCustomNode:create(0, cc.c3b(0, 0, 0), 255, node))
end

function RichTextHelpEx:addElementText(richText, text, attr)
    local outlineColor = cc.c3b(255, 255, 255)
    local outlineSize = 0
    local color = attr.color or default_fontColor
    local size = attr.size or default_fontSize
    local font = attr.fpath or default_fontPath
    local link = attr.link

    local rich_element = nil
    if link then
        rich_element = ccui.RichElementText:create(0, GetColorFromHexString(color), 255, text, font, size, 52, link)
    else
        rich_element = ccui.RichElementText:create(0, GetColorFromHexString(color), 255, text, font, size, 32, "", outlineColor, outlineSize)
    end
    richText:pushBackElement(rich_element)
end

function RichTextHelpEx:CreateRichTextWithCustom(str, width, vspace)
    if string.len(str or "") < 1 then
        return false
    end

    width = width or default_width
    vspace = vspace or default_vspace

    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(width, 0)
    richText:setAnchorPoint(0, 1)
    richText:setVerticalSpace(vspace)

    str = RichTextHelpEx:TextFormat(str)

    local elements = RTextHelperEx:ParseCustomRText(str)
    for _, element in ipairs(elements) do
        if element.type == RTextHelperEx.Type.NEW_LINE then
            self:addElementBr(richText)
        elseif element.type == RTextHelperEx.Type.TEXT then
            self:addElementText(richText, element.content, element.attr)
        elseif element.type == RTextHelperEx.Type.ITEM then
            self:addElementItem(richText, element.attr)
        elseif element.type == RTextHelperEx.Type.EFFECT then
            self:addElementEffect(richText, element.attr)
        end
    end

    richText:formatText()

    return richText
end

return RichTextHelpEx
