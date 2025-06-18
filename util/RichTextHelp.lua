local RichTextHelp = class('RichTextHelp')
local RTextHelper  = require("sui/RTextHelper")
local SRTextHelper = require("sui/SRTextHelper")

local default_width     = 100
local default_vspace    = global.ConstantConfig.DEFAULT_VSPACE
local default_fontSize  = global.ConstantConfig.DEFAULT_FONT_SIZE
local default_fontPath  = global.MMO.PATH_FONT2
local default_fontColor = "#FFFFFF"


function RichTextHelp:push_br(richText)
    richText:pushBackElement(ccui.RichElementNewLine:create(0, cc.c3b(0, 0, 0), 255))
end

function RichTextHelp:push_text(richText, text, colorParam, size, link, ttfConfig, fontName)
    local color = colorParam
    if type(colorParam) ~= "table" then
        if tonumber(colorParam) then
            color = GET_COLOR_BYID_C3B(tonumber(colorParam))
        elseif string.find(tostring(colorParam), "#") then
            color = GetColorFromHexString(colorParam)
        end
    end

    local outlineColor = ttfConfig.outlineColor or cc.c3b(0, 0, 0)
    local outlineSize = ttfConfig.outlineSize or 1
    local fontpath = fontName or global.MMO.PATH_FONT2
    local rich_element = nil
    if link then
        rich_element = ccui.RichElementText:create(0, color, 255, text, fontpath, size, 52, link)
    else
        rich_element = ccui.RichElementText:create(0, color, 255, text, fontpath, size, 32, "", outlineColor, outlineSize)
    end

    richText:pushBackElement(rich_element)
end

function RichTextHelp:set_auto_color(richText, richElement, colorParam)
    local auto_color = {
        colors = colorParam,
        idx = 1
    }


    if not richText.auto_color_elements then
        richText.auto_color_elements = {}

        local function callback()
            for a_rich_element, a_auto_color in pairs(richText.auto_color_elements) do
                local a_colorParam = a_auto_color.colors
                local a_idx = a_auto_color.idx + 1
                if a_idx > #a_colorParam then
                    a_idx = 1
                end

                a_auto_color.idx = a_idx
                local colorParam = a_colorParam[a_idx]
                local color = colorParam
                if tonumber(colorParam) then
                    color = GET_COLOR_BYID_C3B(tonumber(colorParam))
                elseif string.find(tostring(colorParam), "#") then
                    color = GetColorFromHexString(colorParam)
                end
                richText:setElementColor(a_rich_element, color)
            end
        end
        schedule(richText, callback, 1)
    end

    richText.auto_color_elements[richElement] = auto_color
end

function RichTextHelp:push_auto_text(richText, text, colorParam, size, link, ttfConfig, fontName)
    local color = colorParam[1]
    if tonumber(color) then
        color = GET_COLOR_BYID_C3B(tonumber(color))
    elseif string.find(tostring(color), "#") then
        color = GetColorFromHexString(color)
    end
    local outlineColor  = ttfConfig.outlineColor or cc.c3b(0, 0, 0)
    local outlineSize   = ttfConfig.outlineSize or 1
    local fontpath      = fontName or global.MMO.PATH_FONT2
    local rich_element  = nil
    if link then
        rich_element = ccui.RichElementText:create(0, color, 255, text, fontpath, size, 52, link)
    else
        rich_element = ccui.RichElementText:create(0, color, 255, text, fontpath, size, 32, "", outlineColor, outlineSize)
    end

    self:set_auto_color(richText, rich_element, colorParam)

    richText:pushBackElement(rich_element)
end

function RichTextHelp:CreateRichTextWithFCOLOR(str, width, defaultSize, defaultColor, ttfConfig, callback, vspace, defaultFontFace)
    local vspace = vspace or default_vspace
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(width, 0)
    richText:setAnchorPoint(0, 1)
    richText:setVerticalSpace(vspace)

    width        = width or 100
    defaultColor = defaultColor or cc.c3b(0, 0, 0)
    defaultSize = defaultSize or global.ConstantConfig.DEFAULT_FONT_SIZE
    ttfConfig    = ttfConfig or {}

    local elements = RTextHelper:Parse(str)
    if #elements > 0 then
        for _, element in ipairs(elements) do
            if element.type == RTextHelper.Type.NEW_LINE then
                self:push_br(richText)

            elseif element.type == RTextHelper.Type.TEXT then
                local text = element.content
                local color = defaultColor
                self:push_text(richText, text, color, defaultSize, nil, ttfConfig, defaultFontFace)

            elseif element.type == RTextHelper.Type.COLOR_TEXT then
                local text = element.content
                local colorID = element.attr[RTextHelper.Attr.COLOR]
                self:push_text(richText, text, colorID, defaultSize, nil, ttfConfig, defaultFontFace)

            elseif element.type == RTextHelper.Type.AUTO_COLOR_TEXT then
                local text = element.content
                local colors = element.attr[RTextHelper.Attr.AUTO_COLOR]
                self:push_auto_text(richText, text, colors, defaultSize, nil, ttfConfig, defaultFontFace)

            elseif element.type == RTextHelper.Type.LINK_COLOR_TEXT then
                local text = element.content
                local colorID = element.attr[RTextHelper.Attr.COLOR]
                local link = element.attr[RTextHelper.Attr.LINK]
                self:push_text(richText, text, colorID, defaultSize, link, ttfConfig, defaultFontFace)

            elseif element.type == RTextHelper.Type.LINK_AUTO_COLOR_TEXT then
                local text = element.content
                local colors = element.attr[RTextHelper.Attr.AUTO_COLOR]
                local link = element.attr[RTextHelper.Attr.LINK]
                self:push_auto_text(richText, text, colors, defaultSize, link, ttfConfig, defaultFontFace)

            end
        end
    end

    richText:setOpenUrlHandler(function(sender, str)
        if not sender.originScale then
            sender.originScale = sender:getScale()
        end
        local originScale = sender.originScale
        sender:setScale(originScale + 0.2)
        local function reback()
            sender:setScale(originScale)
        end
        performWithDelay(sender, reback, 0.03)

        if callback then
            callback(str)
        end
        
        ssr.ssrBridge:OnRichTextOpenUrl(str)
        SLBridge:onLUAEvent(LUA_EVENT_RICHTEXT_OPEN_URL, str)
    end)
    richText:formatText()


    -- refresh UnderLine positionY
    if global.isWinPlayMode then
        local children = richText:getChildren()
        for _, child in ipairs(children) do
            if tolua.iskindof(child, "ccui.Text") then
                local label = child:getVirtualRenderer()
                if label then
                    local labelChildren = label:getChildren()
                    for _, labelChild in ipairs(labelChildren) do
                        if tolua.iskindof(labelChild, "cc.DrawNode") then
                            labelChild:setPositionY(0)
                        end
                    end
                end
            end
        end
    end

    return richText
end

function RichTextHelp:CreateRichTextWidthSRText(str, width, defaultSize, defaultColor, defaultFontFace, callback, vspace)
    defaultSize     = defaultSize or global.ConstantConfig.DEFAULT_FONT_SIZE
    defaultColor    = defaultColor or "#FFFFFF"

    str = SRTextHelper:convertToRichText(str, defaultSize, defaultColor)
    str = string.format("<outline size='0'>%s</outline>", str)
    return self:CreateRichTextWithXML(str, width, defaultSize, defaultColor, defaultFontFace, callback, vspace)
end

function RichTextHelp:CreateRichTextWithXML(str, width, defaultSize, defaultColor, defaultFontFace, callback, vspace)
    -- defaultColor = "#FFFFFF" 颜色采用这种格式
    -- callback 将 a href = "" href中的参数传回
    if str == nil then
        return self:CreateRichTextWithXML("空富文本")
    end
    if width == 0 then
        width = nil
    end
    if defaultSize == 0 then
        defaultSize = default_fontSize
    end

    str = self:TextFormat(str)

    width           = width or 100
    vspace          = vspace or default_vspace
    defaultSize     = defaultSize or default_fontSize
    defaultColor    = defaultColor or default_fontColor
    defaultFontFace = defaultFontFace or default_fontPath

    local defaults = { KEY_FONT_SIZE = defaultSize, KEY_FONT_FACE = defaultFontFace, KEY_FONT_COLOR_STRING = defaultColor, KEY_ANCHOR_FONT_COLOR_STRING = defaultColor, KEY_ANCHOR_TEXT_LINE = "VALUE_TEXT_LINE_UNDER", KEY_ANCHOR_TEXT_OUTLINE_SIZE = 1 }
    local richText = ccui.RichText:createWithXML(str, defaults)
    if not richText then
        print("富文本错误：", str)
        return self:CreateRichTextWithXML("富文本错误")
    end

    richText:setOpenUrlHandler(function(sender, str)
        local tokens = string.split(str, "#")
        if tokens[1] == "jump" then
            local worldPos = sender:getParent():convertToWorldSpace(cc.p(sender:getPositionX(), sender:getPositionY()))
            local jumpProxy = global.Facade:retrieveProxy(global.ProxyTable.JumpProxy)
            local command = string.sub(str, string.find(str, "#") + 1, string.len(str))
            jumpProxy:ExecuteByParam(command, nil, worldPos)
        end

        if callback then
            callback(str, richText)
        else
            if string.len(str) > 0 and string.find(str, "@") then
                local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
                SUIComponentProxy:SubmitAct({ Act = str })
            end
        end

        ssr.ssrBridge:OnRichTextOpenUrl(str)
        SLBridge:onLUAEvent(LUA_EVENT_RICHTEXT_OPEN_URL, str)
    end)
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(width, 0)
    richText:setVerticalSpace(vspace)

    return richText
end

function RichTextHelp:TextFormat(str)
    -- 兼容一下原先的配置
    --str = string.gsub(str, "'", "\"")
    str = string.gsub(str, "\r\n", "<br>")
    str = string.gsub(str, "\n", "<br>")
    str = string.gsub(str, "<p>", "")
    str = string.gsub(str, "</p>", "<br>")
    str = string.gsub(str, "<br></br>", "<br>")
    str = string.gsub(str, "<strong>", "<big>")
    str = string.gsub(str, "</strong>", "</big>")
    str = string.gsub(str, "<br>", "<br></br>")

    -- 换行只会生效一个问题
    while true do
        if string.find(str, "<br></br><br></br>") then
            str = string.gsub(str, "<br></br><br></br>", "<br></br>　<br></br>")
        else
            break
        end
    end

    -- 元变量替换
    local metaValueProxy = global.Facade:retrieveProxy(global.ProxyTable.MetaValueProxy)
    str = metaValueProxy:MetaValueFormat(str)

    -- lua条件参数
    while true do
        local _, _, source, luaString = string.find(str, "(@(.-)@)")

        if not luaString then
            break
        end

        -- 不知道咋回事，策划那边的空格老有问题
        -- 在有function时，替换 ? 为 空格
        str = string.gsub(str, "%?", " ")
        luaString = string.gsub(luaString, "%?", " ")
        str = string.gsub(str, " ", " ")
        luaString = string.gsub(luaString, " ", " ")

        -- 中文，替换为英文,
        luaString = string.gsub(luaString, "，", ",")

        -- 将( ======> %(
        -- 将) ======> %)
        source = string.gsub(source, "%%", "%%%%")
        source = string.gsub(source, "%(", "%%(")
        source = string.gsub(source, "%)", "%%)")

        source = string.gsub(source, "%-", "%%-")
        source = string.gsub(source, "%+", "%%+")
        source = string.gsub(source, "%*", "%%*")


        local func = loadstring(luaString)
        if not func then
            break
        end

        local result = func()
        if result == nil then
            print("富文本错误lua执行错误:", luaString)
        end

        result = result or ""

        result = string.gsub(result, "%%", "%%%%")

        str = string.gsub(str, source, result)
    end

    return str
end

-- 原始字符串，不做处理
function RichTextHelp:CreateDefaultRichTextWithXML(str, width, defaultSize, defaultColor, callback)
    -- defaultColor = "#FFFFFF" 颜色采用这种格式
    -- callback 将 a href = "" href中的参数传回
    if str == nil then
        return self:CreateRichTextWithXML("空富文本")
    end

    width = width or 100
    defaultSize = defaultSize or 100
    defaultColor = defaultColor or "#FFFFFF"

    local richText = ccui.RichText:createWithXML(str, { KEY_FONT_SIZE = defaultSize, KEY_FONT_FACE = "fonts/font2.ttf", KEY_FONT_COLOR_STRING = defaultColor, KEY_ANCHOR_FONT_COLOR_STRING = "#FFFFFF", KEY_ANCHOR_TEXT_LINE = "VALUE_TEXT_LINE_UNDER", KEY_ANCHOR_TEXT_OUTLINE_SIZE = 1 })
    if not richText then
        print("富文本错误：", str)
        return self:CreateRichTextWithXML("富文本错误")
    end
    richText:ignoreContentAdaptWithSize(false)
    richText:setContentSize(width, 0)
    richText:setTouchEnabled(false)

    return richText
end

return RichTextHelp