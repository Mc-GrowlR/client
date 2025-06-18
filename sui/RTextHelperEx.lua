local RTextHelperEx = class("RTextHelperEx")
RTextHelperEx.Type  = 
{
    NEW_LINE      = "NEW_LINE",
    TEXT          = "TEXT",
    ITEM          = "ITEM",
    EFFECT        = "EFFECT"
}

function RTextHelperEx:ctor()
end

-- 换行元素
function RTextHelperEx:SetBrAttr( elements )
    table.insert( elements, { type = RTextHelperEx.Type.NEW_LINE })
end

-- 文本元素
function RTextHelperEx:SetTextAttr( content, attr )
    return { type = RTextHelperEx.Type.TEXT, content = content, attr = attr }
end

-- 道具元素
function RTextHelperEx:SetItemAttr(attr)
    return { type = RTextHelperEx.Type.ITEM, attr = attr }
end

-- 特效元素
function RTextHelperEx:SetEffectAttr(attr)
    return { type = RTextHelperEx.Type.EFFECT, attr = attr }
end

function RTextHelperEx:ParseCustomRText(source)
    local elements = {}
    source = string.gsub(source, "<br></br>", "\\")
    source = string.gsub(source, "<(%s-)/(%s-)font(%s-)>", "</font>")
    source = string.gsub(source, "<(%s-)font", "<font")
    source = string.gsub(source, "</font>", "</font>\n")
    local slices = string.split(source, "\\")

    for k, content_one in ipairs(slices) do
        if k > 1 then
            self:SetBrAttr( elements )
        end

        for _, content in ipairs(string.split(content_one, "\n")) do
            local len = string.len(content)
            if len > 0 then
                self:ParseOneLine(elements, content)
            end
        end
    end
    return elements
end

function RTextHelperEx:ParseOneLine(elements, content)
	local i, j, var = string.find(content, "<font(.-)</font>")

    if var and i > 1 then
        self:ParseCustomText(elements, string.sub(content, 1, i-1))
    end

    if not var then
        return self:ParseCustomText(elements, content)
    end

    -- 解析富文本
    local _,__,t,v = string.find(var, "(.-)>(.+)")

    t = string.gsub(t, "'", "")
    t = string.gsub(t, "#", "")
    t = string.gsub(t, "\"", "")
    t = string.gsub(t, "(%s+)=(%s+)", "=")

    local attr = {}
    if t then
        for k1,v1 in string.gmatch(t, "(%w+)=(%w+)") do
            if k1 == "color" then
                v1 = "#"..v1
            end
            attr[k1] = v1
        end
    end

    if string.len(v or "") > 0 then
        table.insert(elements, self:SetTextAttr(v, attr))
    end
end

-- 解析道具
function RTextHelperEx:ParseCustomText(elements, content)
    local len = string.len(content)
    local i, j, var = string.find(content, "{{(.-)}}")

    if var and i > 1 then
        table.insert(elements, self:SetTextAttr(string.sub(content, 1, i-1), {}))
    end

    if not var then
        table.insert(elements, self:SetTextAttr(content, {}))
        return false
    end

    local strs = string.split(var, ",")
    local type = string.lower(strs[1])
    local params = {}
    for i,v in ipairs(strs) do
        if i > 1 then
            for key,value in string.gmatch(string.gsub(v, "(%s+)=(%s+)", "="), "(%w+)=(%w+)") do
                params[string.lower(key)] = tonumber(value)
            end
        end
    end

    if type == "item" then              -- itemID, width, height, bgVisible
        local data = {itemID = params.id, size = {width = params.width, height = params.height}, bgVisible = params.bgvisible}
        table.insert(elements, self:SetItemAttr(data))
    elseif type == "effect" then        -- sfxID, scale, speed    
        local data = {sfxID = params.id, x = params.x, y = params.y, scale = params.scale, speed = params.speed}
        table.insert(elements, self:SetEffectAttr(data))
    end

    if len > j then
        self:ParseCustomText(elements, string.sub(content, j+1, len))
    end
end

return RTextHelperEx
