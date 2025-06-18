local sformat = string.format
local sgsub   = string.gsub
local Type    = type

local datas   = nil

local SVarMask = {
    ["<H>"] = "HUMAN(%s)",
    ["<G>"] = "GLOBAL(%s)",
    ["<U>"] = "GUILD(%s)",
    ["<N>"] = "NATION(%s)",
    ["<O>"] = "%s"
}

local function GetDatas()
    local data = {}
    for _, v in ipairs(SL:Require("GUIValue/GUIValueInit", true) or {}) do
        if type(v) == "table" then
            if next(data) then
                table.merge(data, v)
            else
                data = v
            end
        end
    end
    return data
end

function UpateGUIValueCfg()
    datas = GetDatas()
end

function VALUE(key, ...)
    if not datas then
        datas = GetDatas()
    end

    local value = ...

    if key == "<H>" or key == "<G>" or key == "<U>" or key == "<N>" or key == "<O>" then
        key, value = "TXT_VALUE", string.format(SVarMask[key], value)
    end

    local valueCustom = datas[key]

    if not valueCustom then
        local _, Is = sgsub(key, "<T_(.-)>", function ( )
            key, value = "TXT_VALUE", key
        end)

        if Is == 0 then
            sgsub(key, "<V_(.-)>", function ( ) 
                key, value = "TXT_VALUE", key
            end)
        end

        return SL:GetMetaValue(key, value)
    end

    if Type(valueCustom) == "table" then
        local func = valueCustom[value]
        if Type(func) == "function" then
            local T = {}
            T[value] = func()
            return T
        else
            return valueCustom
        end

        return valueCustom
    end

    if Type(valueCustom) == "function" then
        return valueCustom(value)
    end

    return valueCustom
end

function SET_VALUE(key, value)
    SL:SetMetaValue(key, value)
end

function L_VALUE(key, ...)

    local CodeDOMUIProxy = global.Facade:retrieveProxy(global.ProxyTable.CodeDOMUIProxy)
    local uiData = CodeDOMUIProxy:GetCurTxtUIData()

    if uiData and uiData[key] then
        return uiData[key]
    end
    
    return key
end