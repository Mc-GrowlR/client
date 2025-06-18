-- WeaponLooksOrderUp 武器外观层级配置
WeaponLooksOrderUp = {}

local tDir = {
    [global.MMO.ORIENT_U]  = "正上",
    [global.MMO.ORIENT_RU] = "右上",
    [global.MMO.ORIENT_R]  = "正右",
    [global.MMO.ORIENT_RB] = "右下",
    [global.MMO.ORIENT_B]  = "正下",
    [global.MMO.ORIENT_LB] = "左下",
    [global.MMO.ORIENT_L]  = "正左",
    [global.MMO.ORIENT_LU] = "左上",
}

local tAct = {
    [global.MMO.ANIM_IDLE]      = "待机",
    [global.MMO.ANIM_WALK]      = "走路",
    [global.MMO.ANIM_ATTACK]    = "攻击",
    [global.MMO.ANIM_SKILL]     = "施法",
    [global.MMO.ANIM_DIE]       = "死亡",
    [global.MMO.ANIM_RUN]       = "跑步",
    [global.MMO.ANIM_STUCK]     = "受击",
    [global.MMO.ANIM_SITDOWN]   = "蹲下",
    [global.MMO.ANIM_BORN]      = "出生",
    [global.MMO.ANIM_MINING]    = "挖矿",
}

function WeaponLooksOrderUp.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/weapon_looks_order_up")
    WeaponLooksOrderUp.parent = parent

    WeaponLooksOrderUp._ui = GUI:ui_delegate(parent)

    WeaponLooksOrderUp._dir = nil
    WeaponLooksOrderUp._act = nil

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    WeaponLooksOrderUp.ListView_items = WeaponLooksOrderUp._ui["ListView_items"]
    WeaponLooksOrderUp.panel_item = WeaponLooksOrderUp._ui["panel_item"]
    
    WeaponLooksOrderUp._tValue = SL:GetMetaValue("GAME_DATA", key)

    WeaponLooksOrderUp.initEvent(key)

    WeaponLooksOrderUp.initPullDownCells()

    WeaponLooksOrderUp.initList()
end

local function isInList(dir, act)
    if not dir or not act then
        return false
    end

    for k, v in ipairs(WeaponLooksOrderUp._tValue or {}) do
        if v.dir == tonumber(dir) and v.act == tonumber(act) then
            return true
        end
    end

    return false
end

function WeaponLooksOrderUp.initEvent(key)
    GUI:addOnClickEvent(WeaponLooksOrderUp._ui["btn_del"], function()
        if not next(WeaponLooksOrderUp._tValue) then
            return
        end

        for i = WeaponLooksOrderUp._selIdx, #WeaponLooksOrderUp._tValue - 1 do
            WeaponLooksOrderUp._tValue[i] = WeaponLooksOrderUp._tValue[i + 1]
        end

        table.remove(WeaponLooksOrderUp._tValue, #WeaponLooksOrderUp._tValue)

        WeaponLooksOrderUp._selIdx = nil
        WeaponLooksOrderUp.initList()
        
        SL:ShowSystemTips("删除成功")
    end)

    GUI:addOnClickEvent(WeaponLooksOrderUp._ui["btn_add"], function()
        if not WeaponLooksOrderUp._dir then
            SL:ShowSystemTips("请选择方向")
            return
        end

        if not WeaponLooksOrderUp._act then
            SL:ShowSystemTips("请选择动作")
            return
        end

        if isInList(WeaponLooksOrderUp._dir, WeaponLooksOrderUp._act) then
            SL:ShowSystemTips("新增项在列表中已存在，请检查列表")
            return
        end

        local tmp = {
            dir = WeaponLooksOrderUp._dir,
            act = WeaponLooksOrderUp._act,
        }
        table.insert(WeaponLooksOrderUp._tValue, tmp)
        
        WeaponLooksOrderUp.initList()
        
        SL:ShowSystemTips("新增成功")
    end)

    GUI:addOnClickEvent(WeaponLooksOrderUp._ui["Button_sure"], function()
        GUI:delayTouchEnabled(WeaponLooksOrderUp._ui["Button_sure"], 0.5)
        local saveValue = WeaponLooksOrderUp._tValue
        SL:SetMetaValue("GAME_DATA", key, saveValue)
        local saveStr = ""
        for k, v in ipairs(saveValue) do
            saveStr = saveStr .. v.dir .. "#" .. v.act .. (k == #saveValue and "" or "|")
        end
        SAVE_GAME_DATA(key, saveStr)
        SL:ShowSystemTips("修改成功")
    end)
end

function WeaponLooksOrderUp.initPullDownCells()
    WeaponLooksOrderUp.Image_pulldown_bg = WeaponLooksOrderUp._ui["Image_pulldown_bg"]
    WeaponLooksOrderUp.ListView_pulldown = WeaponLooksOrderUp._ui["ListView_pulldown"]
    WeaponLooksOrderUp.Layout_hide_pullDownList = WeaponLooksOrderUp._ui["Layout_hide_pullDownList"]

    GUI:setSwallowTouches(WeaponLooksOrderUp.Layout_hide_pullDownList, false)
    GUI:addOnClickEvent(WeaponLooksOrderUp.Layout_hide_pullDownList, function()
        WeaponLooksOrderUp.hidePullDownCells()
    end)

    local function showItems(items, callBackFunc, maxHeight)
        GUI:ListView_removeAllItems(WeaponLooksOrderUp.ListView_pulldown)

        local keys = table.keys(items)
        table.sort(keys)
        for _, key in ipairs(keys) do
            local Image_bg = GUI:Image_Create(WeaponLooksOrderUp.ListView_pulldown, "Image_bg"..key, 0, 0, "res/public/1900000668.png")
            GUI:Image_setScale9Slice(Image_bg, 51, 51, 10, 10)
            GUI:setContentSize(Image_bg, 80, 28)
            GUI:setIgnoreContentAdaptWithSize(Image_bg, false)
            GUI:setTouchEnabled(Image_bg, true)

            local text_name = GUI:Text_Create(Image_bg, "text_name", 40, 14, 14, "#FFFFFF", items[key])
            GUI:setAnchorPoint(text_name, 0.5, 0.5)

            GUI:addOnClickEvent(Image_bg, function()
                callBackFunc(key)
                WeaponLooksOrderUp.hidePullDownCells()
            end)
        end

        local width, height = 80, math.min(28 * #keys, maxHeight or 9999999)

        GUI:setContentSize(WeaponLooksOrderUp.ListView_pulldown, width, height)
        GUI:setContentSize(WeaponLooksOrderUp.Image_pulldown_bg, width + 2, height + 2)
        GUI:setPositionY(WeaponLooksOrderUp.ListView_pulldown, height + 1)
    end

    local bg_node_dir = WeaponLooksOrderUp._ui["bg_node_dir"]
    GUI:addOnClickEvent(bg_node_dir, function()
        showItems(tDir, function(index)
            if isInList(index, WeaponLooksOrderUp._act) then
                SL:ShowSystemTips("列表中已存在，请检查列表")
                return
            end

            WeaponLooksOrderUp._dir = index
            GUI:Text_setString(WeaponLooksOrderUp._ui["Text_dir"], tDir[WeaponLooksOrderUp._dir])
        end)
        local node_pos = GUI:getPosition(bg_node_dir)
        GUI:setPosition(WeaponLooksOrderUp.Image_pulldown_bg, node_pos.x, node_pos.y)
        GUI:setVisible(WeaponLooksOrderUp.Image_pulldown_bg, true)
        GUI:setVisible(WeaponLooksOrderUp.Layout_hide_pullDownList, true)
        GUI:setRotation(WeaponLooksOrderUp._ui["arrow_dir"], 180)
    end)

    local bg_node_act = WeaponLooksOrderUp._ui["bg_node_act"]
    GUI:addOnClickEvent(bg_node_act, function()
        showItems(tAct, function(index)
            if isInList(WeaponLooksOrderUp._dir, index) then
                SL:ShowSystemTips("列表中已存在，请检查列表")
                return
            end

            WeaponLooksOrderUp._act = index
            GUI:Text_setString(WeaponLooksOrderUp._ui["Text_act"], tAct[WeaponLooksOrderUp._act])
        end)
        local node_pos = GUI:getPosition(bg_node_act)
        GUI:setPosition(WeaponLooksOrderUp.Image_pulldown_bg, node_pos.x, node_pos.y)
        GUI:setVisible(WeaponLooksOrderUp.Image_pulldown_bg, true)
        GUI:setVisible(WeaponLooksOrderUp.Layout_hide_pullDownList, true)
        GUI:setRotation(WeaponLooksOrderUp._ui["arrow_act"], 180)
    end)
end

function WeaponLooksOrderUp.hidePullDownCells()
    GUI:setVisible(WeaponLooksOrderUp.Image_pulldown_bg, false)
    GUI:setVisible(WeaponLooksOrderUp.Layout_hide_pullDownList, false)
    GUI:ListView_removeAllItems(WeaponLooksOrderUp.ListView_pulldown)

    GUI:setRotation(WeaponLooksOrderUp._ui["arrow_dir"], 0)
    GUI:setRotation(WeaponLooksOrderUp._ui["arrow_act"], 0)
end

function WeaponLooksOrderUp.initList()
    GUI:ListView_removeAllItems(WeaponLooksOrderUp.ListView_items)

    for k, v in ipairs(WeaponLooksOrderUp._tValue) do
        local item = GUI:Clone(WeaponLooksOrderUp.panel_item)
        local itemUI = GUI:ui_delegate(item)
        
        GUI:Text_setString(itemUI["idx"], k)
        GUI:Text_setString(itemUI["dir"], tDir[v.dir] or "")
        GUI:Text_setString(itemUI["act"], tAct[v.act] or "")
        GUI:Win_SetParam(item, v)

        GUI:addOnClickEvent(item, function()
            WeaponLooksOrderUp.onClickItem(k)
        end)

        GUI:setVisible(item, true)
        GUI:ListView_pushBackCustomItem(WeaponLooksOrderUp.ListView_items, item)
    end

    WeaponLooksOrderUp.onClickItem(WeaponLooksOrderUp._selIdx or 1)
end

function WeaponLooksOrderUp.onClickItem(k)
    WeaponLooksOrderUp.hidePullDownCells()
    GUI:Text_setString(WeaponLooksOrderUp._ui["Text_dir"], "")
    GUI:Text_setString(WeaponLooksOrderUp._ui["Text_act"], "")
    
    WeaponLooksOrderUp._dir = nil
    WeaponLooksOrderUp._act = nil

    WeaponLooksOrderUp._selIdx = k

    for k, v in ipairs(GUI:ListView_getItems(WeaponLooksOrderUp.ListView_items)) do
        if k == WeaponLooksOrderUp._selIdx then
            GUI:Layout_setBackGroundColor(v, "#ffbf6b")
            local data = GUI:Win_GetParam(v)
            GUI:Text_setString(WeaponLooksOrderUp._ui["Text_dir"], tDir[data.dir])
            GUI:Text_setString(WeaponLooksOrderUp._ui["Text_act"], tAct[data.act])
            WeaponLooksOrderUp._dir = data.dir
            WeaponLooksOrderUp._act = data.act
        else
            GUI:Layout_setBackGroundColor(v, "#000000")
        end
    end
end

return WeaponLooksOrderUp