local GUIHelper = {}
local RichTextHelp = requireUtil("RichTextHelp")

local strim     = string.trim
local sgsub     = string.gsub
local ssplit    = string.split
local sformat   = string.format
local sfind     = string.find

local formats = {
    ["H"] = "HUMAN(%s)",
    ["G"] = "GLOBAL(%s)",
    ["U"] = "GUILD(%s)",
    ["N"] = "NATION(%s)",
    ["O"] = "(%s)"
}

-- VALUE("<H>", "测试变量")  -->  $(<H>, 测试变量)
GUIHelper.ConvertToShowFormart = function (str, sepratator)
    sepratator = sepratator or ","
    local matchs = {
        {src = "L_VALUE%(%s*\"%s*(.-)%s*\"%s*%)",                                                               dst = "$[%1]"},
        {src = "VALUE%(%s*\"%s*<%s*V_(.-)%s*>%s*\"%s*"      .. sepratator ..    "%s*(.-)%s*%)%[%s*(.-)%s*%]",   dst = "$<V_%1>"}, 
        {src = "VALUE%(%s*\"%s*<%s*C_(.-)%s*>%s*\"%s*"      .. sepratator ..    "%s*(.-)%s*%)%[%s*(.-)%s*%]",   dst = "$<C_%1>"}, 
        {src = "VALUE%(%s*\"%s*<%s*V_(.-)%s*>%s*\"%s*%)",                                                       dst = "$<V_%1>"}, 
        {src = "VALUE%(%s*\"%s*<%s*T_(.-)%s*>%s*\"%s*%)",                                                       dst = "$<T_%1>"}, 
        {src = "VALUE%(%s*\"%s*<%s*C_(.-)%s*>%s*\"%s*%)",                                                       dst = "$<C_%1>"}, 
        {src = "VALUE%(%s*\"%s*<%s*(%u)%s*>%s*\"%s*"        .. sepratator ..    "%s*\"%s*(.-)%s*\"%s*%)%s*",    dst = "$(<%1>, %2)"},
        {src = "VALUE%(%s*\"%s*(.-)%s*\"%s*"                .. sepratator ..    "%s*\"%s*(.-)%s*\"%s*%)",       dst = "$(%1, %2)"},
        {src = "VALUE%(%s*\"%s*(.-)%s*\"%s*%)",                                                                 dst = "$(%1)"}
    }

    if not str then
        return nil
    end

    if type(str) ~= "string" then
        return str
    end

    str = strim(str)

    local isMatch = false
    local k = 0
    for _,m in ipairs(matchs) do
        str, k = sgsub(str, m.src, m.dst)
        if k == 1 then
            isMatch = true
        end
    end

    return str, isMatch
end

-- $(<H>, 测试变量)  -->  VALUE("<H>", "测试变量")
GUIHelper.ConvertToRunFormart = function (str)
    local matchs = {
        {src = "$<%s*V_(.-)%s*>",                       dst = "VALUE(\"<V_%1>\", i)[i]"}, 
        {src = "$<%s*C_(.-)%s*>",                       dst = "VALUE(\"<C_%1>\", i)[i]"}, 
        {src = "$<%s*T_(.-)%s*>",                       dst = "VALUE(\"<T_%1>\")"}, 
        {src = "$%(%s*<%s*(%u)%s*>%s*,%s*(.-)%s*%)",    dst = "VALUE(\"<%1>\", \"%2\")"},
        -- {src = "$%(%s*(.-)%s*,%s*(.-)%s*%)",            dst = "VALUE(\"%1\", \"%2\")"},
        -- {src = "$%(%s*(.-)%s*%)",                       dst = "VALUE(\"%1\")"}, 
        {src = "$%[%s*(.-)%s*%]",                       dst = "L_VALUE(\"%1\")"}
    }

    if not str then
        return nil
    end

    if type(str) ~= "string" then
        return str
    end

    str = strim(str)

    local isMatch = false
    local k = 0
    for _,m in ipairs(matchs) do
        str, k = sgsub(str, m.src, m.dst)
        if k == 1 then
            isMatch = true
        end
    end

    sgsub(str, "$%(%s*(.-)%s*%)", function ( s )
        if sfind(s, ",") then
            str, k = sgsub(str, "$%(%s*(.-)%s*,%s*(.-)%s*%)", "VALUE(\"%1\", \"%2\")")
            if k == 1 then
                isMatch = true
            end
        else
            str, k = sgsub(str, "$%(%s*(.-)%s*%)", "VALUE(\"%1\")")
            if k == 1 then
                isMatch = true
            end
        end
    end)

    return str, isMatch
end

GUIHelper.Format1 = function (str)
    local machs = {
        {src = "VALUE%(%s*\"%s*<%s*V_(.-)%s*>%s*\"%s*,%s*(.-)%s*%)%[%s*(.-)%s*%]", dst = "VALUE(\"<V_%1>\")"},
        {src = "VALUE%(%s*\"%s*<%s*C_(.-)%s*>%s*\"%s*,%s*(.-)%s*%)%[%s*(.-)%s*%]", dst = "VALUE(\"<C_%1>\")"},
        {src = "VALUE%(%s*\"%s*<%s*T_(.-)%s*>%s*\"%s*%)"                         , dst = "VALUE(\"<T_%1>\")"},
        {src = "VALUE%(%s*\"%s*<%s*(%u)%s*>%s*\"%s*,%s*\"%s*(.-)%s*\"%s*%)%s*"   , dst = "VALUE(\"<%1>\", \"%1\")"}
    }
    return str
end

-- 从VALUE检测替换服务器变量
GUIHelper.FormatServerVarVALUE = function (str, names)
    str = sgsub(str, "VALUE%(%s*\"%s*<%s*V_(.-)%s*>%s*\"%s*,%s*(.-)%s*%)%[%s*(.-)%s*%]", function (a)
        names[a] = 1
        return sformat("VALUE(\"<V_%s>\")", a)
    end)

    str = sgsub(str, "VALUE%(%s*\"%s*<%s*T_(.-)%s*>%s*\"%s*%)", function (a)
        names[a] = 1
        return sformat("VALUE(\"<T_%s>\")", a)
    end)

    str = sgsub(str, "VALUE%(%s*\"%s*<%s*C_(.-)%s*>%s*\"%s*,%s*(.-)%s*%)%[%s*(.-)%s*%]", "VALUE(\"<C_%1>\")")

    str = sgsub(str, "VALUE%(%s*\"%s*<%s*(%u)%s*>%s*\"%s*,%s*\"%s*(.-)%s*\"%s*%)", function (a, b)
        if formats[a] then
            local name = sformat(formats[a], b)
            names[name] = 1
            return sformat("VALUE(\"<%s>\"@￥@\"%s\")", a, b)
        end
    end)

    str = sgsub(str, "VALUE%(%s*\"%s*(.-)%s*\"%s*,%s*\"%s*(.-)%s*\"%s*%)", "VALUE(\"%1\"@￥@\"%2\")")

    return str
end

GUIHelper.GetSerVarName = function (str)
    local name = nil
    sgsub(str, "$<%s*V_(.-)%s*>", function (a) name = "V_" .. a end)

    if name then
        return name
    end

    sgsub(str, "$<%s*T_(.-)%s*>", function (a) name = "T_" .. a end)

    if name then
        return name
    end

    str = sgsub(str, "$%(%s*<%s*(%u)%s*>%s*,%s*(.-)%s*%s*%)", function (a, b)
        if formats[a] then
            name = sformat(formats[a], b)
        end
    end)

    return name
end

-- 从$检测替换服务器变量
GUIHelper.FormatServerVarSHOW = function (str)
    local value, isMatch = GUIHelper.ConvertToRunFormart(str)
    return isMatch, value
end

-- 提示
GUIHelper.CteateShowTips = function (self, cache, str)
    local visibleSize  = global.Director:getVisibleSize()

    local node = cc.Node:create()
    node:setAnchorPoint(0.5, 0.5)
    node:setCascadeOpacityEnabled(true)
    self:addChild(node)
    node:setLocalZOrder(9999)
    node:setPositionX(visibleSize.width/2)

    local imageBG = ccui.ImageView:create(sformat("%s%s", global.MMO.PATH_RES_PUBLIC, "bg_hhzy_01_2.png"))
    node:addChild(imageBG)
    imageBG:setScale9Enabled(true)
    imageBG:setCapInsets({x = 184, y = 11, width = 190, height = 13})

    local text = RichTextHelp:CreateRichTextWithXML(str, visibleSize.width - 20)
    node:addChild(text)
    text:setCascadeOpacityEnabled(true)

    text:formatText()
    local size = cc.size(text:getContentSize().width, 30)
    imageBG:setContentSize(cc.size(size.width+20, size.height))

    cache:push(node)

    if cache:size() > 5 then
        cache:front():removeFromParent()
        cache:pop()
    end

    -- 移除
    local function callback()
        node:removeFromParent()
        cache:pop()
    end
    node:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.FadeOut:create(0.8), cc.CallFunc:create(callback)))

    -- 位置
    local actionTag = 999
    for index = 1, cache:size() do
        local node = cache:at(index)
        local y = visibleSize.height/2 + size.height * (cache:size() - index - 0.5)
        local action = cc.MoveTo:create(0.15, cc.p(visibleSize.width/2, y))
        action:setTag(actionTag)
        node:stopActionByTag(actionTag)
        node:setPositionY(y)
        node:runAction(action)
    end
end

function GUIHelper:format(str)
    return sgsub(sgsub(strim(str), "^[\"\"]", ""), "[\"\"]$", "")
end

function GUIHelper:GetStatus(status, default_status)
    if type(status) == "boolean" then
        return status
    end

    local _status = status or default_status

    if _status == "true" then
        return true
    end

    if _status == "false" then
        return false
    end

    return _status
end

return GUIHelper