local LexicalHelper = class("LexicalHelper")

local slen      = string.len
local ssub      = string.sub
local sgsub     = string.gsub
local sfind     = string.find
local strim     = string.trim
local rtrim     = string.rtrim
local tinsert   = table.insert
local sgmatch   = string.gmatch

local _XmlUiNames   = 
{
    ["dialog"]      = true,
    ["Image"]       = true,
    ["Text"]        = true,
    ["Input"]       = true,
    ["Button"]      = true,
    ["Layout"]      = true,
    ["ScrollView"]  = true,
    ["ListView"]    = true,
    ["RichText"]    = true,
    ["TextAtlas"]   = true,
    ["CircleBar"]   = true,
    ["LoadingBar"]  = true,
    ["CheckBox"]    = true
}

function LexicalHelper:ctor()
end

function LexicalHelper:tbTransform( tb )
	local newtb = {}
	for i,v in ipairs(tb) do
		local _,_,key = sfind(v, "(.+)=")
		local _,_,val = sfind(v, "=(.+)")
		newtb[key] = strim(val)
	end
	return newtb
end

function LexicalHelper:parseCell(celldata)
    celldata = celldata.." "
    local tb = {}
    for v in sgmatch(celldata, "(.-) (.-)") do
        tinsert(tb, v)
    end

    local js = {}
    local t  = 1
    for i,v in ipairs(tb) do
        local _b, _e = sfind(v, "(%a)=")
        if _b and _e then
            js[t] = v
            t = t + 1
        else
            if js[t-1] then
                js[t-1] = js[t-1].." "..v
            end
        end
    end
    return self:tbTransform(js)
end

function LexicalHelper:GetValidData( type, data )
    if not _XmlUiNames[tostring(type)] then
        SL:Print("Xml Parse ERROR , type: ", tostring(type))
        return false
    end
	local attrData = sgsub(data, "<(.-) ", "")
    attrData = sgsub(attrData, "(%s+)=", "=")
    return self:push_element(type, self:parseCell(attrData))
end

function LexicalHelper:ParseDialog(data)
	data = sgsub(data, "(/%s-)>", ">")
	data = sgsub(data, "\"", "")
    data = sgsub(data, "<(%s+)", "<")

	local node = {}
	local tWnd = {}
	local startWnd = false
	for v in sgmatch(data, "(.-)>") do
		if v then
			v = strim(v)
			local _, _, jType = sfind(v, "<(.-) ")

			if jType == "dialog" then
                local _data = self:GetValidData(jType, v)
                if _data then
				    tinsert(node, 1, _data)
                end
			else
				local _, _, isdialogWnd = sfind(v, "</dialog(.-)")
				if isdialogWnd then
					break
				end

				if jType == "ScrollView" or jType == "ListView" then
					startWnd = true
                    local _data = self:GetValidData(jType, v)
                    if _data then
                        tinsert(tWnd, 1, _data)
                    end
				else
                    local _, _, isEndWnd = sfind(v, "</ScrollView(.-)")
                    if not isEndWnd then
                        _, _, isEndWnd = sfind(v, "</ListView(.-)")
                    end
					if isEndWnd then
                        tinsert(node, tWnd)
						startWnd = false
                        tWnd = {}
					else
                        local _data = self:GetValidData(jType, v)
                        if _data then
                            if startWnd == true then
                                tinsert(tWnd, _data)
                            else
                                tinsert(node, _data)
                            end
                        end
					end
				end
			end
		end
	end
    return node
end

-- 解析注释
function LexicalHelper:ParseNote(source)
    -- 解析 --[[ xxx ]] 格式
    source = sgsub(source, "%-%-%[%[(.+)%]%]", "")
    -- 解析 -- 格式
    local newSource = ""
    source = source .."\n"
    for content in sgmatch(source, "(.-)[\n]") do
        local t1 = sfind(content, "\"(.-)%-%-") or sfind(content, "\'(.-)%-%-") 
        local t2 = sfind(content, "%-%-")
        if t2 and not t1 then
            content = sgsub(content, "%-%-(.+)", "\n")
        end
        newSource = newSource .."\n".. content
    end

    if slen(newSource) < 1 then
        newSource = source
    end

    return newSource
end

function LexicalHelper:Parse(source, root)
    local function _IsNilResult(_t)
        return (_t and _t[1] and _t[2] and slen(_t[3] or "") > 0)
    end

    local xmls = {}
    local script = ""
    if source then
        source = self:ParseNote(source)
        if root then
            -- 不带script和dialog的子控件
            source = strim(source)
            return {xmls = self:ParseDialog(source)}
        end
        local scriptStr = {
            sfind(source, "<script>(.*)</script>")
        }
        local xmlStr = {
            sfind(source, "<dialog(.+)</dialog>")
        }
        if _IsNilResult(xmlStr) then
            local data = xmlStr[3]
            data = rtrim(data)
            data = "<dialog "..data.."</dialog>"
            xmls = self:ParseDialog(data)
    
            if _IsNilResult(scriptStr) then
                script = scriptStr[3]
            end
        else
            if _IsNilResult(scriptStr) then
                script = scriptStr[3]
            else
                script = source
            end
        end
    end
    return {script = script, xmls = xmls}
end

function LexicalHelper:push_element(type, kvmap)
    return {
        type = type, attr = kvmap
    }
end

return LexicalHelper
