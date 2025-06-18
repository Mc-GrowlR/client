local RemoteProxy = requireProxy("remote/RemoteProxy")
local ConditionProxy = class("ConditionProxy", RemoteProxy)
ConditionProxy.NAME = global.ProxyTable.ConditionProxy

function ConditionProxy:ctor()
    ConditionProxy.super.ctor(self)
    self._cacheCondition = {}
end

---$(LEVEL)
function ConditionProxy:CheckCondition(conditionStr)
    if not conditionStr or conditionStr == "" then
        return true
    end

    if self._cacheCondition[conditionStr] then --取缓存
        return self._cacheCondition[conditionStr]()
    end

    local convertStr = string.gsub(conditionStr, "($%b())", function(valueStr)
        local metaParam = string.match(valueStr, "$%((.*)%)")
        local index = string.find(metaParam, ",")
        local metaKey = ""
        if index then
            metaKey = string.sub(metaParam, 1, index - 1)
            metaParam = string.sub(metaParam, index + 1)
        else
            metaKey = metaParam
            metaParam = nil
        end
        local str = ""
        if metaParam then
            str = string.format("metaValueProxy:GetValueByKey('%s',%s)", metaKey, metaParam)
        else
            str = string.format("metaValueProxy:GetValueByKey('%s')", metaKey)
        end
        return str or ""
    end)
    --args todo
    local successFunc = loadstring(string.format(
    [[
        local metaValueProxy = global.Facade:retrieveProxy(global.ProxyTable.MetaValueProxy)
        if (%s) then 
            return true 
        else
            return false
        end
    ]], convertStr))

    if not successFunc then
        SL:Print(string.format("error：条件错误！！ %s", conditionStr))
        return false
    end

    self._cacheCondition[conditionStr] = successFunc

    return successFunc()
end

return ConditionProxy