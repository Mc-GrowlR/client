local Element = class("Element")
function Element:ctor()
    self.type    = nil
    self.content = nil
    self.attr    = nil
end



local RTextHelper = class("RTextHelper")
RTextHelper.Type = 
{
    NEW_LINE             = "NEW_LINE",
    TEXT                 = "TEXT",
    COLOR_TEXT           = "COLOR_TEXT",
    AUTO_COLOR_TEXT      = "AUTO_COLOR_TEXT",
    LINK_COLOR_TEXT      = "LINK_COLOR_TEXT",
    LINK_AUTO_COLOR_TEXT = "LINK_AUTO_COLOR_TEXT",
}

RTextHelper.Attr = 
{
    COLOR      = "COLOR",
    AUTO_COLOR = "AUTO_COLOR",
    LINK       = "LINK",
}

function RTextHelper:ctor()
end

function RTextHelper:push_newline( elements )
    local element = Element.new()
    element.type  = RTextHelper.Type.NEW_LINE

    table.insert( elements, element )
end

function RTextHelper:parse_text( content )
    local element   = Element.new()
    element.type    = RTextHelper.Type.TEXT
    element.content = content

    return element
end

function RTextHelper:parse_color_text( params_table )
    if not params_table[3] or not params_table[4] then
        return nil
    end


    local element   = Element.new()
    element.type    = RTextHelper.Type.COLOR_TEXT
    element.content = params_table[3]
    element.attr    = {
        [RTextHelper.Attr.COLOR] = params_table[4]
    }

    return element
end

function RTextHelper:parse_auto_color_text( params_table )
    if not params_table[3] or not params_table[4] then
        return nil
    end


    local element   = Element.new()
    element.type    = RTextHelper.Type.AUTO_COLOR_TEXT
    element.content = params_table[3]
    element.attr    = {
        [RTextHelper.Attr.AUTO_COLOR] = string.split( params_table[4], "," )
    }

    return element
end

function RTextHelper:parse_red_color_text( params_table )
    if not params_table[3] then
        return nil
    end


    local element   = Element.new()
    element.type    = RTextHelper.Type.LINK_COLOR_TEXT
    element.content = params_table[3]
    element.attr    = {
        [RTextHelper.Attr.COLOR] = 249,
    }

    return element
end

function RTextHelper:parse_link_color_text( params_table )
    if not params_table[3] or not params_table[4] or not params_table[5] then
        return nil
    end


    local element   = Element.new()
    element.type    = RTextHelper.Type.LINK_COLOR_TEXT
    element.content = params_table[3]
    element.attr    = {
        [RTextHelper.Attr.COLOR] = params_table[4],
        [RTextHelper.Attr.LINK] = params_table[5],
    }

    return element
end

function RTextHelper:parse_link_auto_color_text( params_table )
    if not params_table[3] or not params_table[4] or not params_table[5] then
        return nil
    end


    local element   = Element.new()
    element.type    = RTextHelper.Type.LINK_AUTO_COLOR_TEXT
    element.content = params_table[3]
    element.attr    = {
        [RTextHelper.Attr.AUTO_COLOR] = string.split( params_table[4], "," ),
        [RTextHelper.Attr.LINK] = params_table[5],
    }

    return element
end

function RTextHelper:parse_link_default_color_text( params_table )
    if not params_table[3] or not params_table[4] then
        return nil
    end


    local element   = Element.new()
    element.type    = RTextHelper.Type.LINK_COLOR_TEXT
    element.content = params_table[3]
    element.attr    = {
        [RTextHelper.Attr.COLOR] = 151,
        [RTextHelper.Attr.LINK] = params_table[4],
    }

    return element
end

function RTextHelper:Parse( source )
    local elements = {}
    if not source or source == "" then
        return elements
    end

    source = string.gsub(source, ">", ">\n")
    source = string.gsub(source, "}", "}\n")
    local slices = string.split(source, "\n")
    for _, slice in ipairs(slices) do
        local source_lines = string.split( slice, "\\" )
        local oneline_size = 0
        for l, content_line in ipairs( source_lines ) do
            if l > 1 then
                self:push_newline( elements )
            end
    
            oneline_size = string.len( content_line )
            if oneline_size > 0 then
                self:parse_oneline( elements, content_line, oneline_size )
            end
        end
    end


    return elements
end

function RTextHelper:parse_oneline( element_table, content_line, oneline_size )
    local element        = nil
    local begin_pos      = 0
    local end_pos        = 0
    local find_info      = nil
    local element_str    = content_line
    local pattern_finded = false
    local content_size   = oneline_size
    local parster        = nil

    while oneline_size > 0 and end_pos < content_size do
        pattern_finded = false
        for _, pattern_info in ipairs( self.Pattern ) do
            find_info = { string.find( element_str, pattern_info[1] ) }
            begin_pos = find_info[1]
            end_pos   = find_info[2]
            if begin_pos and end_pos then
                parster = pattern_info[2]
                pattern_finded = true
                break
            end
        end


        if pattern_finded then
            -- pattern pref text
            if begin_pos ~= 1 then
                local content = string.sub( element_str, 1, begin_pos - 1 )
                self:parse_oneline( element_table, content, string.len(content) )
            end

            -- finded, parse one element
            element = parster( self, find_info )
            if element then
                table.insert( element_table, element )
            end

            -- pattern suff text
            if end_pos < oneline_size then
                content_size = string.len( element_str )
                element_str = string.sub( element_str, end_pos + 1 )
            end

        else
            -- push text
            element = self:parse_text( element_str )
            if element then
                table.insert( element_table, element )
            end

            break
        end
    end
end


RTextHelper.Pattern = 
{
    { "<(.-)/FCOLOR=(.-)>", RTextHelper.parse_color_text },
    { "<(.-)/AUTOCOLOR=(.-)>", RTextHelper.parse_auto_color_text },
    { "<(.-){FCOLOR=(.-)}/(@.-)>", RTextHelper.parse_link_color_text },
    { "<(.-){AUTOCOLOR=(.-)}/(@.-)>", RTextHelper.parse_link_auto_color_text },
    { "<(.-)/(@.-)>", RTextHelper.parse_link_default_color_text },
    { "<(.-)>", RTextHelper.parse_red_color_text },
    
    { "{(.-)/FCOLOR=(.-)}", RTextHelper.parse_color_text },
    { "{(.-)/AUTOCOLOR=(.-)}", RTextHelper.parse_auto_color_text },
    { "{(.-){FCOLOR=(.-)}/(@.-)}", RTextHelper.parse_link_color_text },
    { "{(.-){AUTOCOLOR=(.-)}/(@.-)}", RTextHelper.parse_link_auto_color_text },
    { "{(.-)/(@.-)}", RTextHelper.parse_link_default_color_text },
    { "{(.-)}", RTextHelper.parse_red_color_text },
}

return RTextHelper
