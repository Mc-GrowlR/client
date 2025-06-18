-- 被攻击时选择
BeDamaged = {}

local tOperate = { [0] = "不处理", [1] = "反击", [2] = "逃跑" }

function BeDamaged.main(parent, data)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "setup/bedamaged")

    BeDamaged._ui = GUI:ui_delegate(parent)

    BeDamaged.Image_pulldown = BeDamaged._ui["Image_pulldown"]
    BeDamaged.list_pulldown = BeDamaged._ui["list_pulldown"]
    BeDamaged.Layout_hide = BeDamaged._ui["Layout_hide"]

    GUI:setSwallowTouches(BeDamaged.Layout_hide, false)
    GUI:addOnClickEvent(BeDamaged.Layout_hide, function()
        BeDamaged.hidePullDownCells()
    end)

    BeDamaged._index = data.default or 0

    local bg_operate = BeDamaged._ui["bg_operate"]
    GUI:addOnClickEvent(bg_operate, function()
        BeDamaged.showItems(tOperate, function(index)
            BeDamaged._index = index
            GUI:Text_setString(BeDamaged._ui["Text_operate"], tOperate[index])
        end)
    
        local node_pos = GUI:getPosition(BeDamaged._ui["bg_operate"])
        GUI:setAnchorPoint(BeDamaged.Image_pulldown, 0.5, 1)
        GUI:setPosition(BeDamaged.Image_pulldown, node_pos.x, node_pos.y)
        GUI:setVisible(BeDamaged.Image_pulldown, true)
        GUI:setVisible(BeDamaged.Layout_hide, true)
        GUI:setRotation(BeDamaged._ui["arrow"], 180)          
    end)

    GUI:Text_setString(BeDamaged._ui["Text_operate"], tOperate[BeDamaged._index])
end

function BeDamaged.showItems(items, callBackFunc, maxHeight)
    GUI:ListView_removeAllItems(BeDamaged.list_pulldown)

    local keys = table.keys(items)
    table.sort(keys)

    local maxWidth = 80

    for _, key in ipairs(keys) do
        local Image_bg = GUI:Image_Create(BeDamaged.list_pulldown, "Image_bg"..key, 0, 0, "res/public/1900000668.png")
        GUI:Image_setScale9Slice(Image_bg, 51, 51, 10, 10)
        GUI:setContentSize(Image_bg, 80, 28)
        GUI:setIgnoreContentAdaptWithSize(Image_bg, false)
        GUI:setTouchEnabled(Image_bg, true)

        local text_name = GUI:Text_Create(Image_bg, "text_name", 40, 14, 14, "#FFFFFF", items[key])
        GUI:setAnchorPoint(text_name, 0.5, 0.5)
        local width = GUI:getContentSize(text_name).width
        width = math.max(width, 80)
        maxWidth = math.max(maxWidth, width)

        GUI:addOnClickEvent(Image_bg, function()
            callBackFunc(key)
            BeDamaged.hidePullDownCells()
        end)
    end

    local height = math.min(28 * #keys, maxHeight or 9999999)

    GUI:setContentSize(BeDamaged.list_pulldown, maxWidth, height)
    GUI:setContentSize(BeDamaged.Image_pulldown, maxWidth + 2, height + 2)
    GUI:setPositionY(BeDamaged.list_pulldown, height + 1)

    for _, item in ipairs(GUI:ListView_getItems(BeDamaged.list_pulldown)) do
        GUI:setContentSize(item, maxWidth, 28)
        GUI:setPositionX(GUI:getChildByName(item, "text_name"), maxWidth / 2)
    end
end

function BeDamaged.hidePullDownCells()
    GUI:setVisible(BeDamaged.Image_pulldown, false)
    GUI:setVisible(BeDamaged.Layout_hide, false)
    GUI:ListView_removeAllItems(BeDamaged.list_pulldown)
    GUI:setRotation(BeDamaged._ui["arrow"], 0)
end

-- 外部调用，返回当前界面处理数据结果
function BeDamaged.getValue()
    local ret = {}
    ret.default = BeDamaged._index or 1
    
    return ret
end

return BeDamaged