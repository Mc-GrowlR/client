local SRTextHelper = class("SRTextHelper")

function SRTextHelper:ctor()
end

function SRTextHelper:convertToRichText(source, defaultSize, defaultColor)
    local PCFontConfig = SL:GetMetaValue("GAME_DATA", "PCFontConfig")
    defaultSize    = (PCFontConfig and PCFontConfig[2]) or defaultSize or SL:GetMetaValue("GAME_DATA", "DEFAULT_FONT_SIZE") or 16
    defaultColor    = defaultColor or "#FFFFFF"

    local find_info = nil
    local begin_pos = 0
    local end_pos   = 0
    local font_text_table = {}
    while string.len(source) > 0 do
        find_info = {string.find( source, "{(.-)|(.-)}")}
        begin_pos = find_info[1]
        end_pos   = find_info[2]

        if begin_pos and end_pos then
            if begin_pos > 1 then
                local prefix = string.sub(source, 1, begin_pos-1)
                self:convertToFontText(font_text_table, prefix, nil, defaultSize, defaultColor)
            end
            self:convertToFontText(font_text_table, find_info[3], find_info[4], defaultSize, defaultColor)

            source = string.sub(source, end_pos + 1, string.len(source))
        else
            self:convertToFontText(font_text_table, source, nil, defaultSize, defaultColor)
            source = ""
        end
    end

    local fontText = table.concat(font_text_table, "")
    return fontText
end

function SRTextHelper:convertToFontText(font_text_table, content, attr, defaultSize, defaultColor)
    local styleColor    = nil
    local styleType     = nil   -- 0背景 1描边
    if attr and string.len(attr) > 0 then
        local slices    = string.split(attr, ':')
        defaultColor    = GET_COLOR_BYID(tonumber(slices[1]))
        styleColor      = tonumber(slices[2])
        styleType       = tonumber(slices[3])
    end
    if styleType and styleType == 1 then
        local color = GET_COLOR_BYID(styleColor)
        content = string.format("<font size='%s' color='%s'><outline size='%s' color='%s'>%s</outline></font>", defaultSize, defaultColor, 1, color, content)
    else
        local PCFontConfig = SL:GetMetaValue("GAME_DATA", "PCFontConfig")
        content = string.format("<font size='%s' color='%s'>%s</font>", (PCFontConfig and PCFontConfig[2]) or defaultSize, defaultColor, content)
    end

    table.insert(font_text_table, content)
end

return SRTextHelper