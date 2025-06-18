local ActDef = {
    ["Print"] = function(...)
        SL:Print(...)
    end,
    ["BAG_REFRESH_ITEMS"] = function(p1, p2, p3)
        SL:ResetBagPos()
    end,
}

function ACT(k, ...)
    local func = ActDef[k]
    if not func then
        ACT("Print", "ACT ERROR: Can't find ", k)
        return nil
    end

    return func(...)
end

-- GUI:setPositionX(VALUE("X"), 0)