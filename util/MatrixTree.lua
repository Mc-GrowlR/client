
function mt_create(tree, data)
    data = data or {data = {}, val = 0}
    local childCount = tree[1]
    if not childCount then
        return
    end
    local rTree = {}
    for i = 2, #tree do
        table.insert(rTree, tree[i])
    end
    if childCount then
        local cData = {val = 0, data = {}}
        for i = 1, childCount do
            data.data[i] = clone(cData)
            mt_create(rTree, data.data[i])
        end
    end
    return data
end

function mt_newNode(val)
    return {
        val = val or 0,
        data = {}
    }
end

function mt_set(cache, tree, value)
    local childIdx = tree[1]
    local data = cache.data[childIdx]
    local rTree = {}
    for i = 2, #tree do
        table.insert(rTree, tree[i])
    end
    if #rTree == 0 then
        data.val = value
    else
        mt_set(data, rTree, value)
    end
end

function mt_addNode(data, key, node)
    data.data = data.data or {}
    data.data[key] = node
end

function mt_getVal(cache, tree)
    local childIdx = tree[1]
    local data = cache.data[childIdx]
    local rTree = {}
    for i = 2, #tree do
        table.insert(rTree, tree[i])
    end
    if #rTree == 0 then
        return data.val
    else
        return mt_getVal(data, rTree, value)
    end
end

function mt_getData(cache, tree)
    local childIdx = tree[1]
    local data = cache.data[childIdx]
    local rTree = {}
    for i = 2, #tree do
        table.insert(rTree, tree[i])
    end
    if #rTree == 0 then
        return data
    else
        return mt_getData(data, rTree)
    end
end

function mt_max(cache)
    local maxVal = 0
    for k,v in pairs(cache.data) do
        if v.data and next(v.data) then
            v.val = mt_max(v)
        end
        maxVal = math.max(v.val, maxVal)
    end
    cache.val = maxVal
    return maxVal
end

--endregion
