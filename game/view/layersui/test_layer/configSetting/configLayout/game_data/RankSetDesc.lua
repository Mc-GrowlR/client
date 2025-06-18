-- 字段：RankDesc
-- 格式例子：1#级|2#级|3#级|4#级|5#转|6#级|7#级|8#级|9#级|10#转|11#富豪积分
-- 字段描述：排行榜排序数值的后缀字符（格式：面板ID#字符|面板ID#字符）
RankSetDesc = {}

function RankSetDesc.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/rank_desc")

    RankSetDesc._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    RankSetDesc._rankData = {}

    local data = SL:GetMetaValue("GAME_DATA", "RankDesc")
    if data then 
        local st1 = string.split(data, "|")
        for i, v in ipairs(st1) do
            local st2 = string.split(v, "#")
            local id = tonumber(st2[1])
            local desc = st2[2]
            RankSetDesc._rankData[i] = { id = id, desc = desc }
        end
    end 

    local rankId = RankSetDesc._rankData[1] and RankSetDesc._rankData[1].id or 1
    local rankDesc = RankSetDesc._rankData[1] and RankSetDesc._rankData[1].desc or "级"

    local input_id = RankSetDesc._ui["input_id"]
    local input_desc = RankSetDesc._ui["input_desc"]
    GUI:TextInput_setInputMode(input_id, 2)
    GUI:TextInput_setInputMode(input_desc, 1)
    GUI:TextInput_setString(input_id, rankId)
    GUI:TextInput_setString(input_desc, rankDesc)

    GUI:TextInput_addOnEvent(input_id, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_id)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("id不能为空")
                GUI:TextInput_setString(input_id, rankId)
                return
            end
        end
    end)

    GUI:TextInput_addOnEvent(input_desc, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_desc)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("文字不能为空")
                GUI:TextInput_setString(input_desc, rankDesc)
                return
            end
        end
    end)

    GUI:addOnClickEvent(RankSetDesc._ui["Button_add"], function()
        local strId = GUI:TextInput_getString(input_id)
        local strDesc = GUI:TextInput_getString(input_desc)
        if string.len(strId) == 0 or string.len(strDesc) == 0 then
            SL:ShowSystemTips("内容不能为空")
            return
        end

        for i, v in ipairs(RankSetDesc._rankData) do 
            if tonumber(strId) == v.id then 
                SL:ShowSystemTips("id重复")
                return 
            end 
        end 

        local data = {}
        data.id = tonumber(strId)
        data.desc = strDesc
        table.insert(RankSetDesc._rankData, data)

        RankSetDesc.refresRankDescList()
    end)

    GUI:addOnClickEvent(RankSetDesc._ui["Button_clear"], function()
        RankSetDesc._rankData = {}
        GUI:ListView_removeAllItems(RankSetDesc._ui["LV_item"])
    end)

    GUI:addOnClickEvent(RankSetDesc._ui["Button_sure"], function()
        GUI:delayTouchEnabled(RankSetDesc._ui["Button_sure"], 0.5)

        local saveValue = ""
        for i, v in ipairs(RankSetDesc._rankData) do 
            local str = v.id.."#"..v.desc
            saveValue = saveValue..str.."|"
        end 

        if string.len(saveValue) == 0 then 
            SL:ShowSystemTips("请添加")
            return 
        end 

        saveValue = string.sub(saveValue, 1, -2)
        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)

    RankSetDesc.refresRankDescList()
end

function RankSetDesc.refresRankDescList()
    GUI:ListView_removeAllItems(RankSetDesc._ui["LV_item"])
    GUI:setVisible(RankSetDesc._ui["panel_cell"], false)
    for i, v in ipairs(RankSetDesc._rankData) do 
        local cell = GUI:Clone(RankSetDesc._ui["panel_cell"])
        GUI:setVisible(cell, true)
        GUI:ListView_pushBackCustomItem(RankSetDesc._ui["LV_item"], cell)

        local ui_id = GUI:getChildByName(cell, "Text_id")
        GUI:Text_setString(ui_id, v.id)
        local ui_desc = GUI:getChildByName(cell, "Text_desc")
        GUI:Text_setString(ui_desc, v.desc)
    end
end

return RankSetDesc