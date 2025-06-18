-- MobileChannelNotShow 手机端隐藏相关频道配置
MobileChannelNotShow = {}

local CHANNEL = {
    [1] = {name="系统", chat_channel=1},
    [2] = {name="喊话", chat_channel=2},
    [3] = {name="私聊", chat_channel=3},
    [4] = {name="行会", chat_channel=4},
    [5] = {name="组队", chat_channel=5},
    [6] = {name="附近", chat_channel=6},
    [7] = {name="世界", chat_channel=7},
    [8] = {name="国家", chat_channel=8},
    [9] = {name="联盟", chat_channel=9},
    [10]= {name="跨服", chat_channel=10},
    [11]= {name="掉落", chat_channel=100},
}


function MobileChannelNotShow.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/chat_chanel_not_show")

    MobileChannelNotShow._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    local tmpValue = value == "" and {} or string.split(value, "#")
    local tValue = {}
    for _, value in ipairs(tmpValue) do
        tValue[tonumber(value)] = 1
    end

    local ScrollView_items = MobileChannelNotShow._ui["ScrollView_items"]

    for i, v in ipairs(CHANNEL) do
        local index = v.chat_channel
        local value = v.name
        local clickCell = MobileChannelNotShow.createClickCell()
        GUI:addChild(ScrollView_items, clickCell)

        GUI:Text_setString(GUI:getChildByName(clickCell, "Text_desc"),  value)

        local enable = (tValue[index] or 0) == 1
        local CheckBox_able = GUI:getChildByName(clickCell, "CheckBox_able")
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)

        GUI:addOnClickEvent(clickCell, function()
            local enable = (tValue[index] or 0) == 1
            enable = not enable
            GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
            GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)
            tValue[index] = enable and 1 or nil
        end)
    end

    GUI:UserUILayout(ScrollView_items, { dir = 3, gap = {x = 33, l = 33},  addDir = 1, colnum = 2, autosize = true,})

    GUI:addOnClickEvent(MobileChannelNotShow._ui["Button_sure"], function()
        GUI:delayTouchEnabled(MobileChannelNotShow._ui["Button_sure"], 0.5)
        local valueKeys = table.keys(tValue)
        table.sort(valueKeys)
        local saveValue = table.concat(valueKeys, "#")
        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function MobileChannelNotShow.createClickCell()
    local parent = GUI:Node_Create(MobileChannelNotShow._ui["nativeUI"], "node", 0, 0)
    loadConfigSettingExport(parent, "game_data/click_cell")
    local clickCell = GUI:getChildByName(parent, "click_cell")
    GUI:removeFromParent(clickCell)
    GUI:removeFromParent(parent)
    return clickCell
end

return MobileChannelNotShow