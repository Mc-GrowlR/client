
Boxtexiao = {}

--boxtexiao 15#4530#4511#4512|16#4531#4513#4514|17#4532#4515#4516|18#4533#4517#4518|18#4534#4519#4520|    
--宝箱Shape值#宝箱默认特效#宝箱开启动画特效#宝箱转动特效|Shape值#宝箱默认特效#宝箱开启动画特效#宝箱转动特效

function Boxtexiao.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/box_texiao")

    Boxtexiao._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local value = SL:GetMetaValue("GAME_DATA", key)
    local list = {}
    if type(value) == "string"  and string.len(value) > 0 then 
        local slices = string.split(value, "|")
        for _, v in ipairs(slices) do
            if string.len(v) > 0 then
                local params = string.split(v, "#")
                if #params >= 4 then
                    for i, t in ipairs(params) do
                        params[i] = tonumber(t)
                    end
                    table.insert(list, params)
                end
            end
        end
    end
    Boxtexiao._list = list

    for _, data in ipairs(list) do
        local cell = Boxtexiao.CreateItemCell(_)
        GUI:ListView_pushBackCustomItem(Boxtexiao._ui.ListView_items, cell)
    end

    GUI:addOnClickEvent(Boxtexiao._ui["Button_add"], function()
        GUI:delayTouchEnabled(Boxtexiao._ui["Button_add"], 0.5)

        local totalNum = #Boxtexiao._list
        print(totalNum)
        dump(Boxtexiao._list[totalNum])
        for i = 1, 4 do
            if not Boxtexiao._list[totalNum][i] then
                SL:ShowSystemTips("已有配置填写完毕再新增!")
                return
            end
        end

        table.insert(Boxtexiao._list, {})
        local cell = Boxtexiao.CreateItemCell(totalNum + 1)
        GUI:ListView_pushBackCustomItem(Boxtexiao._ui.ListView_items, cell)

        local idx = GUI:ListView_getItemIndex(Boxtexiao._ui.ListView_items, cell)
        GUI:ListView_jumpToItem(Boxtexiao._ui.ListView_items, idx)

    end)

    GUI:addOnClickEvent(Boxtexiao._ui["Button_sure"], function()
        GUI:delayTouchEnabled(Boxtexiao._ui["Button_sure"], 0.5)

        local saveValue = ""
        for _, params in ipairs(Boxtexiao._list) do
            if #params >= 4 then
                if saveValue == "" then
                    saveValue = table.concat(params, "#")
                else
                    saveValue = string.format("%s|%s", saveValue, table.concat(params, "#"))
                end
            end
        end

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
        
    end)
end

function Boxtexiao.CreateItemCell(i)
    local widget = GUI:Widget_Create(-1, "node_" .. i, 0, 0, 0, 0)
    loadConfigSettingExport(widget, "game_data/box_texiao_cell")
    local cell = GUI:getChildByName(widget, "Panel_cell")

    local ui = GUI:ui_delegate(cell)
    if Boxtexiao._list[i] then
        for t = 1, 4 do
            GUI:TextInput_setString(ui["Input_" .. t], Boxtexiao._list[i][t])
            GUI:TextInput_addOnEvent(ui["Input_" .. t], function(sender, eventType)
                if eventType == 1 then
                    local inputStr = GUI:TextInput_getString(sender)
                    if not tonumber(inputStr) then
                        inputStr = ""
                        GUI:TextInput_setString(sender, "")
                    end
                    if string.len(inputStr) == 0 then
                        SL:ShowSystemTips("该参数不能为空!")
                    end
                    if not Boxtexiao._list[i] then
                        return
                    end
                    Boxtexiao._list[i][t] = tonumber(inputStr)
                end
            end)
        end
    end

    GUI:removeFromParent(cell)
    return cell
end

return Boxtexiao