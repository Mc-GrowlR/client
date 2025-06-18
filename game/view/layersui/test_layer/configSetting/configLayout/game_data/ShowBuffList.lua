-- ShowBuffList BUFF图标显示位置 挂接点#坐标X#坐标Y#宽#高#显示个数#滑动方向#tips方向#倒计时X#倒计时Y#层数X#层数Y#倒计时字体色号#叠加层字体色号#图标大小(0默认)|PC端
ShowBuffList = {}

function ShowBuffList.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/show_buff_list")

    ShowBuffList._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    ShowBuffList.initData(key)
    ShowBuffList.initPullDownCells()
    ShowBuffList.initPageBtn()
    ShowBuffList.initInput()

    GUI:addOnClickEvent(ShowBuffList._ui["Button_sure"], function()
        GUI:delayTouchEnabled(ShowBuffList._ui["Button_sure"], 0.5)

        local idx = (ShowBuffList.selPage == 1) and 1 or 2

        ShowBuffList.nodeIndex[idx] = ShowBuffList.addNodeIndex
        ShowBuffList.buffPosX[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputX"]))
        ShowBuffList.buffPosY[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputY"]))
        ShowBuffList.buffW[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputW"]))
        ShowBuffList.buffH[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputH"]))
        ShowBuffList.showNum[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputNum"]))
        ShowBuffList.direction[idx] = ShowBuffList.scrollDir
        ShowBuffList.tipDir[idx] = ShowBuffList.tipDirIndex
        ShowBuffList.endOffSetX[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputEndX"]))
        ShowBuffList.endOffSetY[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputEndY"]))
        ShowBuffList.olOffSetX[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputOverlapX"]))
        ShowBuffList.olOffSetY[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputOverlapY"]))
        ShowBuffList.endColorID[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputEndColor"]))
        ShowBuffList.olColorID[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputOverlapColor"]))
        ShowBuffList.iconSizeW[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputIconW"]))
        ShowBuffList.iconSizeH[idx] = tonumber(GUI:TextInput_getString(ShowBuffList._ui["InputIconH"]))
        ShowBuffList.foldBtnDir[idx] = ShowBuffList.foldDirIndex

        local strValue = string.format("%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s*%s#%s|%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s*%s#%s",
            ShowBuffList.nodeIndex[1], ShowBuffList.buffPosX[1], ShowBuffList.buffPosY[1], ShowBuffList.buffW[1], ShowBuffList.buffH[1], 
            ShowBuffList.showNum[1], ShowBuffList.direction[1], ShowBuffList.tipDir[1], ShowBuffList.endOffSetX[1], ShowBuffList.endOffSetY[1], 
            ShowBuffList.olOffSetX[1], ShowBuffList.olOffSetY[1], ShowBuffList.endColorID[1], ShowBuffList.olColorID[1], ShowBuffList.iconSizeW[1], ShowBuffList.iconSizeH[1], ShowBuffList.foldBtnDir[1],

            ShowBuffList.nodeIndex[2], ShowBuffList.buffPosX[2], ShowBuffList.buffPosY[2], ShowBuffList.buffW[2], ShowBuffList.buffH[2], 
            ShowBuffList.showNum[2], ShowBuffList.direction[2], ShowBuffList.tipDir[2], ShowBuffList.endOffSetX[2], ShowBuffList.endOffSetY[2], 
            ShowBuffList.olOffSetX[2], ShowBuffList.olOffSetY[2], ShowBuffList.endColorID[2], ShowBuffList.olColorID[2], ShowBuffList.iconSizeW[2], ShowBuffList.iconSizeH[2], ShowBuffList.foldBtnDir[2]
        )

        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function ShowBuffList.initData(key)
    ShowBuffList.nodeIndex  = { 101, 101 }    -- 挂接点 默认主界面左上
    ShowBuffList.buffPosX   = { 0, 0 }        -- X坐标偏移 默认0
    ShowBuffList.buffPosY   = { 0, 0 }        -- Y坐标偏移 默认0
    ShowBuffList.buffW      = { 180, 180 }    -- 宽 默认180
    ShowBuffList.buffH      = { 40, 40 }      -- 高 默认40
    ShowBuffList.showNum    = { 4, 4 }        -- 显示数量 默认4
    ShowBuffList.direction  = { 2, 2 }        -- 滑动方向 默认2 横向， 1纵向 2横向 0 自动排列
    ShowBuffList.tipDir     = { 2, 2 }        -- tip显示方向 默认2，实际显示取2+1的锚点(0,0) 右上方， _anchorP = {cc.p(1,0), cc.p(0.5,0), cc.p(0,0), cc.p(0, 0.5), cc.p(0, 1), cc.p(0.5, 1), cc.p(1,1), cc.p(1, 0.5)}
    ShowBuffList.endOffSetX = { 0, 0 }        -- 倒计时X坐标 默认0
    ShowBuffList.endOffSetY = { 0, 0 }        -- 倒计时Y坐标 默认0
    ShowBuffList.olOffSetX  = { 0, 0 }        -- 叠加层数X坐标 默认0
    ShowBuffList.olOffSetY  = { 0, 0 }        -- 叠加层数Y坐标 默认0
    ShowBuffList.endColorID = { 251, 251 }    -- 倒计时颜色id 默认251 黄色
    ShowBuffList.olColorID  = { 255, 255 }    -- 叠加层数颜色id 默认255 白色
    ShowBuffList.iconSizeW  = { 40, 40 }      -- 图标宽度 默认40
    ShowBuffList.iconSizeH  = { 40, 40 }      -- 图标高度 默认40
    ShowBuffList.foldBtnDir = { 0, 0 }        -- 收缩按钮方向

    local value = SL:GetMetaValue("GAME_DATA", key)
    if value and string.len(value) > 0 then
        local set = string.split(value, "|")
        local paramMob = string.split(set[1], "#")
        local paramWin = string.split(set[2], "#")

        ShowBuffList.nodeIndex[1] = paramMob[1] and tonumber(paramMob[1]) or ShowBuffList.nodeIndex[1]
        ShowBuffList.nodeIndex[2] = paramWin[1] and tonumber(paramWin[1]) or ShowBuffList.nodeIndex[2]

        ShowBuffList.buffPosX[1] = paramMob[2] and tonumber(paramMob[2]) or ShowBuffList.buffPosX[1]
        ShowBuffList.buffPosX[2] = paramWin[2] and tonumber(paramWin[2]) or ShowBuffList.buffPosX[2]

        ShowBuffList.buffPosY[1] = paramMob[3] and tonumber(paramMob[3]) or ShowBuffList.buffPosY[1]
        ShowBuffList.buffPosY[2] = paramWin[3] and tonumber(paramWin[3]) or ShowBuffList.buffPosY[2]

        ShowBuffList.buffW[1] = paramMob[4] and tonumber(paramMob[4]) or ShowBuffList.buffW[1]
        ShowBuffList.buffW[2] = paramWin[4] and tonumber(paramWin[4]) or ShowBuffList.buffW[2]

        ShowBuffList.buffH[1] = paramMob[5] and tonumber(paramMob[5]) or ShowBuffList.buffH[1]
        ShowBuffList.buffH[2] = paramWin[5] and tonumber(paramWin[5]) or ShowBuffList.buffH[2]

        ShowBuffList.showNum[1] = paramMob[6] and tonumber(paramMob[6]) or ShowBuffList.showNum[1]
        ShowBuffList.showNum[2] = paramWin[6] and tonumber(paramWin[6]) or ShowBuffList.showNum[2]

        ShowBuffList.direction[1] = paramMob[7] and tonumber(paramMob[7]) or ShowBuffList.direction[1]
        ShowBuffList.direction[2] = paramWin[7] and tonumber(paramWin[7]) or ShowBuffList.direction[2]

        ShowBuffList.tipDir[1] = paramMob[8] and tonumber(paramMob[8]) or ShowBuffList.tipDir[1]
        ShowBuffList.tipDir[2] = paramWin[8] and tonumber(paramWin[8]) or ShowBuffList.tipDir[2]

        ShowBuffList.endOffSetX[1] = paramMob[9] and tonumber(paramMob[9]) or ShowBuffList.endOffSetX[1]
        ShowBuffList.endOffSetX[2] = paramWin[9] and tonumber(paramWin[9]) or ShowBuffList.endOffSetX[2]

        ShowBuffList.endOffSetY[1] = paramMob[10] and tonumber(paramMob[10]) or ShowBuffList.endOffSetY[1]
        ShowBuffList.endOffSetY[2] = paramWin[10] and tonumber(paramWin[10]) or ShowBuffList.endOffSetY[2]

        ShowBuffList.olOffSetX[1] = paramMob[11] and tonumber(paramMob[11]) or ShowBuffList.olOffSetX[1]
        ShowBuffList.olOffSetX[2] = paramWin[11] and tonumber(paramWin[11]) or ShowBuffList.olOffSetX[2]

        ShowBuffList.olOffSetY[1] = paramMob[12] and tonumber(paramMob[12]) or ShowBuffList.olOffSetY[1]
        ShowBuffList.olOffSetY[2] = paramWin[12] and tonumber(paramWin[12]) or ShowBuffList.olOffSetY[2]

        ShowBuffList.endColorID[1] = paramMob[13] and tonumber(paramMob[13]) or ShowBuffList.endColorID[1]
        ShowBuffList.endColorID[2] = paramWin[13] and tonumber(paramWin[13]) or ShowBuffList.endColorID[2]

        ShowBuffList.olColorID[1] = paramMob[14] and tonumber(paramMob[14]) or ShowBuffList.olColorID[1]
        ShowBuffList.olColorID[2] = paramWin[14] and tonumber(paramWin[14]) or ShowBuffList.olColorID[2]

        if paramMob[15] and string.find(paramMob[15], "*") then
            local data = string.split(paramMob[15], "*")
            ShowBuffList.iconSizeW[1] = data[1] and tonumber(data[1]) or ShowBuffList.iconSizeW[1]
            ShowBuffList.iconSizeH[1] = data[2] and tonumber(data[2]) or ShowBuffList.iconSizeH[1]
        end

        if paramWin[15] and string.find(paramWin[15], "*") then
            local data = string.split(paramWin[15], "*")
            ShowBuffList.iconSizeW[2] = data[1] and tonumber(data[1]) or ShowBuffList.iconSizeW[2]
            ShowBuffList.iconSizeH[2] = data[2] and tonumber(data[2]) or ShowBuffList.iconSizeH[2]
        end

        ShowBuffList.foldBtnDir[1] = paramMob[16] and tonumber(paramMob[16]) or ShowBuffList.foldBtnDir[1]
        ShowBuffList.foldBtnDir[2] = paramWin[16] and tonumber(paramWin[16]) or ShowBuffList.foldBtnDir[2]
    end
end

function ShowBuffList.initPageBtn()
    ShowBuffList.selPage = nil
    local function onClickPageBtn(page)
        if ShowBuffList.selPage == page then
            return
        end

        if ShowBuffList.selPage then
            local oldPage = ShowBuffList._ui["page_btn_" .. ShowBuffList.selPage]
            GUI:Layout_setBackGroundColor(oldPage, "#000000")
        end

        ShowBuffList.selPage = page

        local newPage = ShowBuffList._ui["page_btn_" .. ShowBuffList.selPage]
        GUI:Layout_setBackGroundColor(newPage, "#ffbf6b")

        ShowBuffList.updateContent(ShowBuffList.selPage == 1)
        ShowBuffList.hidePullDownCells()
    end

    for i = 1, 2 do
        local pageBtn = ShowBuffList._ui["page_btn_" .. i]
        GUI:addOnClickEvent(pageBtn, function()
            GUI:delayTouchEnabled(pageBtn, 0.5)
            onClickPageBtn(i)
        end)
    end

    onClickPageBtn(1)
end

local tAddNode = {
    [101] = "主界面左上", [102] = "主界面右上",
    [103] = "主界面左下", [104] = "主界面右下",
    [105] = "主界面左中", [106] = "主界面上中",
    [107] = "主界面右中", [108] = "主界面下中",
}

local tScrollDir = {
    [0] = "多行自动排列", [1] = "纵向", [2] = "横向",
}

local tTipDir = {
    [0] = "左上方", [1] = "正上方", [2] = "右上方", [3] = "正右方",
    [4] = "右下方", [5] = "正下方", [6] = "左下方", [7] = "正左方",
}

local foldDir = {
    [0] = "不需要", [1] = "往左收缩", [2] = "往右收缩", [3] = "往上收缩", [4] = "往下收缩",
}

function ShowBuffList.updateContent(isMobile)
    local idx = isMobile and 1 or 2

    ShowBuffList.addNodeIndex = ShowBuffList.nodeIndex[idx]
    GUI:Text_setString(ShowBuffList._ui["Text_node_index"], tAddNode[ShowBuffList.addNodeIndex])
    GUI:setRotation(ShowBuffList._ui["arrow"], 0)

    GUI:TextInput_setString(ShowBuffList._ui["InputX"], ShowBuffList.buffPosX[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputY"], ShowBuffList.buffPosY[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputW"], ShowBuffList.buffW[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputH"], ShowBuffList.buffH[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputNum"], ShowBuffList.showNum[idx])

    ShowBuffList.scrollDir = ShowBuffList.direction[idx]
    GUI:setRotation(ShowBuffList._ui["arrow_dir"], 0)
    GUI:Text_setString(ShowBuffList._ui["Text_dir"], tScrollDir[ShowBuffList.scrollDir])

    ShowBuffList.tipDirIndex = ShowBuffList.tipDir[idx]
    GUI:Text_setString(ShowBuffList._ui["Text_dir_tips"], tTipDir[ShowBuffList.tipDirIndex])
    GUI:setRotation(ShowBuffList._ui["arrow_dir_tips"], 0)

    GUI:TextInput_setString(ShowBuffList._ui["InputEndX"], ShowBuffList.endOffSetX[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputEndY"], ShowBuffList.endOffSetY[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputOverlapX"], ShowBuffList.olOffSetX[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputOverlapY"], ShowBuffList.olOffSetY[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputEndColor"], ShowBuffList.endColorID[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputOverlapColor"], ShowBuffList.olColorID[idx])
    GUI:Layout_setBackGroundColor(ShowBuffList._ui["Layout_end_color"], SL:GetHexColorByStyleId(ShowBuffList.endColorID[idx]))
    GUI:Layout_setBackGroundColor(ShowBuffList._ui["Layout_overlap_color"], SL:GetHexColorByStyleId(ShowBuffList.olColorID[idx]))
    GUI:TextInput_setString(ShowBuffList._ui["InputIconW"], ShowBuffList.iconSizeW[idx])
    GUI:TextInput_setString(ShowBuffList._ui["InputIconH"], ShowBuffList.iconSizeH[idx])

    ShowBuffList.foldDirIndex = ShowBuffList.foldBtnDir[idx]
    GUI:Text_setString(ShowBuffList._ui["Text_dir_fold"], foldDir[ShowBuffList.foldDirIndex])
    GUI:setRotation(ShowBuffList._ui["arrow_dir_fold"], 0)
end

function ShowBuffList.initInput()
    if not ShowBuffList.inputs then
        ShowBuffList.inputs = {
            { name = "InputX" }, { name = "InputY" },
            { name = "InputEndX" }, { name = "InputEndY" },
            { name = "InputOverlapX" }, { name = "InputOverlapY" },
            { name = "InputW", min = 0,}, { name = "InputH", min = 0,},
            { name = "InputNum", min = 0, onlyNum = true,},
            { name = "InputEndColor", min = 0, inclueMin = true, max = 255, inclueMax = true, onlyNum = true,},
            { name = "InputOverlapColor", min = 0, inclueMin = true, max = 255, inclueMax = true, onlyNum = true,},
            { name = "InputIconW", min = 0,}, { name = "InputIconH", min = 0 },
        }
    end

    for _, v in ipairs(ShowBuffList.inputs or {}) do
        local textInput = ShowBuffList._ui[v.name]
        local srcInput = GUI:TextInput_getString(textInput)
        if v.onlyNum then
            GUI:TextInput_setInputMode(textInput, 2)
        end
        GUI:TextInput_addOnEvent(textInput, function(_, eventType)
            if eventType == 1 then
                local strInput = GUI:TextInput_getString(textInput)
                if string.len(strInput) == 0 then
                    GUI:TextInput_setString(textInput, srcInput)
                    SL:ShowSystemTips("请输入内容")
                    return
                else
                    local numInput = tonumber(strInput)
                    if not numInput then
                        GUI:TextInput_setString(textInput, srcInput)
                        SL:ShowSystemTips("请输入数字")
                        return
                    else
                        if v.min and numInput == v.min then
                            if not v.inclueMin then
                                GUI:TextInput_setString(textInput, srcInput)
                                 SL:ShowSystemTips("请输入大于" .. v.min .. "的数字")
                                return
                            end
                        elseif v.min and numInput < v.min then
                            GUI:TextInput_setString(textInput, srcInput)
                             SL:ShowSystemTips("请输入大于" .. (v.inclueMin and "等于" or "") .. v.min .. "的数字")
                            return
                        elseif v.max and numInput == v.max then
                            if not v.inclueMax then
                                GUI:TextInput_setString(textInput, srcInput)
                                 SL:ShowSystemTips("请输入小于" .. v.max .. "的数字")
                                return
                            end
                        elseif v.max and numInput > v.max then
                            GUI:TextInput_setString(textInput, srcInput)
                             SL:ShowSystemTips("请输入小于" .. (v.inclueMax and "等于" or "") .. v.max .. "的数字")
                            return
                        end
                    end

                    srcInput = numInput
                    if v.name == "InputEndColor" then
                        GUI:Layout_setBackGroundColor(ShowBuffList._ui["Layout_end_color"], SL:GetHexColorByStyleId(numInput))
                    elseif v.name == "InputOverlapColor" then
                        GUI:Layout_setBackGroundColor(ShowBuffList._ui["Layout_overlap_color"], SL:GetHexColorByStyleId(numInput))
                    end
                end
            end
        end)
    end
end

function ShowBuffList.initPullDownCells()
    ShowBuffList.Image_pulldown_bg = ShowBuffList._ui["Image_pulldown_bg"]
    ShowBuffList.ListView_pulldown = GUI:getChildByName(ShowBuffList.Image_pulldown_bg, "ListView_pulldown")
    ShowBuffList.Layout_hide_pullDownList = ShowBuffList._ui["Layout_hide_pullDownList"]
    GUI:setSwallowTouches(ShowBuffList.Layout_hide_pullDownList, false)
    GUI:addOnClickEvent(ShowBuffList.Layout_hide_pullDownList, function()
        ShowBuffList.hidePullDownCells()
    end)

    local function showItems(items, callBackFunc, maxHeight)
        GUI:ListView_removeAllItems(ShowBuffList.ListView_pulldown)

        local keys = table.keys(items)
        table.sort(keys)
        for _, key in ipairs(keys) do
            local Image_bg = GUI:Image_Create(ShowBuffList.ListView_pulldown, "Image_bg"..key, 0, 0, "res/public/1900000668.png")
            GUI:Image_setScale9Slice(Image_bg, 51, 51, 10, 10)
            GUI:setContentSize(Image_bg, 98, 28)
            GUI:setIgnoreContentAdaptWithSize(Image_bg, false)
            GUI:setTouchEnabled(Image_bg, true)

            local text_name = GUI:Text_Create(Image_bg, "text_name", 49, 14, 14, "#FFFFFF", items[key])
            GUI:setAnchorPoint(text_name, 0.5, 0.5)

            GUI:addOnClickEvent(Image_bg, function()
                callBackFunc(key)
                ShowBuffList.hidePullDownCells()
            end)
        end

        local width, height = 98, math.min(28 * #keys, maxHeight or 9999999)

        GUI:setContentSize(ShowBuffList.ListView_pulldown, width, height)
        GUI:setContentSize(ShowBuffList.Image_pulldown_bg, width + 2, height + 2)
        GUI:setPositionY(ShowBuffList.ListView_pulldown, height + 1)
    end

    local bg_node_index = ShowBuffList._ui["bg_node_index"]
    GUI:addOnClickEvent(bg_node_index, function()
        showItems(tAddNode, function(index)
            ShowBuffList.addNodeIndex = index
            GUI:Text_setString(ShowBuffList._ui["Text_node_index"], tAddNode[ShowBuffList.addNodeIndex])
        end)
        local node_pos = GUI:getPosition(bg_node_index)
        GUI:setPosition(ShowBuffList.Image_pulldown_bg, node_pos.x, node_pos.y)
        GUI:setVisible(ShowBuffList.Image_pulldown_bg, true)
        GUI:setSwallowTouches(ShowBuffList.Layout_hide_pullDownList, false)
        GUI:setVisible(ShowBuffList.Layout_hide_pullDownList, true)
        GUI:setRotation(ShowBuffList._ui["arrow"], 180)
    end)

    local bg_dir = ShowBuffList._ui["bg_dir"]
    GUI:addOnClickEvent(bg_dir, function()
        showItems(tScrollDir, function(index)
            ShowBuffList.scrollDir = index
            GUI:Text_setString(ShowBuffList._ui["Text_dir"], tScrollDir[ShowBuffList.scrollDir])
        end)
        local node_pos = GUI:getPosition(bg_dir)
        GUI:setPosition(ShowBuffList.Image_pulldown_bg, node_pos.x, node_pos.y)
        GUI:setVisible(ShowBuffList.Image_pulldown_bg, true)
        GUI:setVisible(ShowBuffList.Layout_hide_pullDownList, true)
        GUI:setRotation(ShowBuffList._ui["arrow_dir"], 180)
    end)

    local bg_dir_tips = ShowBuffList._ui["bg_dir_tips"]
    GUI:addOnClickEvent(bg_dir_tips, function()
        showItems(tTipDir, function(index)
            ShowBuffList.tipDirIndex = index
            GUI:Text_setString(ShowBuffList._ui["Text_dir_tips"], tTipDir[ShowBuffList.tipDirIndex])
        end, 168)
        local node_pos = GUI:getPosition(bg_dir_tips)
        GUI:setPosition(ShowBuffList.Image_pulldown_bg, node_pos.x, node_pos.y)
        GUI:setVisible(ShowBuffList.Image_pulldown_bg, true)
        GUI:setVisible(ShowBuffList.Layout_hide_pullDownList, true)
        GUI:setRotation(ShowBuffList._ui["arrow_dir_tips"], 0)
    end)

    local bg_dir_fold = ShowBuffList._ui["bg_dir_fold"]
    GUI:addOnClickEvent(bg_dir_fold, function()
        showItems(foldDir, function(index)
            ShowBuffList.foldDirIndex = index
            GUI:Text_setString(ShowBuffList._ui["Text_dir_fold"], foldDir[ShowBuffList.foldDirIndex])
        end)
        local node_pos = GUI:getPosition(bg_dir_fold)
        GUI:setPosition(ShowBuffList.Image_pulldown_bg, node_pos.x, node_pos.y)
        GUI:setVisible(ShowBuffList.Image_pulldown_bg, true)
        GUI:setVisible(ShowBuffList.Layout_hide_pullDownList, true)
        GUI:setRotation(ShowBuffList._ui["arrow_dir_fold"], 180)
    end)
end

function ShowBuffList.hidePullDownCells()
    GUI:setVisible(ShowBuffList.Image_pulldown_bg, false)
    GUI:setVisible(ShowBuffList.Layout_hide_pullDownList, false)
    GUI:ListView_removeAllItems(ShowBuffList.ListView_pulldown)

    GUI:setRotation(ShowBuffList._ui["arrow"], 0)
    GUI:setRotation(ShowBuffList._ui["arrow_dir"], 0)
    GUI:setRotation(ShowBuffList._ui["arrow_dir_tips"], 0)
    GUI:setRotation(ShowBuffList._ui["arrow_dir_fold"], 0)
end

return ShowBuffList