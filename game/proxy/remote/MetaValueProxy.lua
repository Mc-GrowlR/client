local RemoteProxy = requireProxy("remote/RemoteProxy")
local MetaValueProxy = class("RemoteProxy", RemoteProxy)
MetaValueProxy.NAME = global.ProxyTable.MetaValueProxy

local MetaValueGetDef = require("config/MetaValueGetDef")
local MetaValueSetDef = require("config/MetaValueSetDef")

function MetaValueProxy:ctor()
    MetaValueProxy.super.ctor(self)
    self._cacheMeta = {}
end

-- 元变量替换,将本地元变量替换
function MetaValueProxy:MetaValueFormat(str)
    local source = str

    local results = {}

    while true do
        local sIdx, eIdx, oriStr,param = string.find(source, "(&<(.-)>&)")
        if not (oriStr and  param) then
            break
        end
        if self._cacheMeta[oriStr] then 
            results[oriStr] = self._cacheMeta[oriStr]
        else
            -- 本地取元变量
            local tokens = string.split(param, "/")
            local metaKey = tokens[1]
            local successFunc = loadstring(string.format(
            [[
                local metaValueProxy = global.Facade:retrieveProxy(global.ProxyTable.MetaValueProxy)
                return metaValueProxy:GetValueByKey('%s', '%s') or ""
            ]], metaKey, tokens[2]))

            if successFunc then
                self._cacheMeta[oriStr] = successFunc
                results[oriStr] = successFunc
            end
        end

        local s1 = string.sub(source, 1, sIdx - 1)
        local s2 = string.sub(source, eIdx + 1, string.len(source))
        source = s1 .. s2
    end

    -- 本地替换一波
    for key, result in pairs(results) do
        local sIdx, eIdx = string.find(str, key, 1, true)
        str = string.sub(str, 1, sIdx - 1) .. tostring(result()) .. string.sub(str, eIdx + 1, string.len(str))
    end

    return str
end

function MetaValueProxy:GetValueByKey(key, ...)
    if not key then
        return global.MMO.MeTaInvalidKey
    end
    
    local func = MetaValueGetDef[key]
    if not func then
        return global.MMO.MeTaInvalidValue
    end

    return func(...)
end

function MetaValueProxy:PrintMetaKey()
    print("---------------------------------------------")
    SL:print(" Meta Value Get begin --------------------")
    for key, func in pairs(MetaValueGetDef) do
        SL:print(" -----> " .. key)
    end
    SL:print(" Meta Value Get end ----------------------")

    -- Set
    print("")
    print("---------------------------------------------")
    SL:print(" Meta Value Set begin --------------------")
    for key, func in pairs(MetaValueSetDef) do
        SL:print(" -----> " .. key)
    end
    SL:print(" Meta Value Set end ----------------------")
end

function MetaValueProxy:PrintAllMetaValue()
    SL:print(" Meta Value Get begin --------------------")
    for key, func in pairs(MetaValueGetDef) do
        SL:print(key, " -----> ", func())
    end
    SL:print(" Meta Value Get end ----------------------")
end

function MetaValueProxy:SetValueByKey(key, ...)
    if not key then
        return global.MMO.MeTaInvalidKey
    end

    local func = MetaValueSetDef[key]
    if not func then
        return global.MMO.MeTaInvalidValue
    end

    return func(...)
end

return MetaValueProxy
