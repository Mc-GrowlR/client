-- tips_star_custom 配置强化星星样式  图片或特效#资源1&资源2...资源n#星星横向间隔#纵向间隔#星星宽#星星高|pc
TipsStarCustom = {}

local pathRes = "res/private/item_tips/"

function TipsStarCustom.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/tips_star_custom")

    TipsStarCustom._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    TipsStarCustom.initData(key)
    TipsStarCustom.initPullDownCells()
    TipsStarCustom.initPageBtn()
    TipsStarCustom.initInput()

    GUI:addOnClickEvent(TipsStarCustom._ui["Button_sure"], function()
        GUI:delayTouchEnabled(TipsStarCustom._ui["Button_sure"], 0.5)

        local strResMob = ""
        if TipsStarCustom.resType[1] == 1 then
            for i = 1, 3 do
                if TipsStarCustom["star_img_"..i][1] and TipsStarCustom["star_img_"..i][1] ~= "" then
                    strResMob = strResMob .. TipsStarCustom["star_img_"..i][1] .. (i ~= 3 and "&" or "")
                end
            end
            if string.len(strResMob) == 0 then
                SL:ShowSystemTips("请配置手机端星星图片")
                return
            end
        else
            for i = 1, 3 do
                if TipsStarCustom["star_sfx_"..i][1] then
                    strResMob = strResMob .. TipsStarCustom["star_sfx_"..i][1] .. (i ~= 3 and "&" or "")
                end
            end
            if string.len(strResMob) == 0 then
                SL:ShowSystemTips("请配置手机端星星特效")
                return
            end
        end

        local strResPC = ""
        if TipsStarCustom.resType[2] == 1 then
            for i = 1, 3 do
                if TipsStarCustom["star_img_"..i][2] and TipsStarCustom["star_img_"..i][2] ~= "" then
                    strResPC = strResPC .. TipsStarCustom["star_img_"..i][2] .. (i ~= 3 and "&" or "")
                end
            end
            if string.len(strResPC) == 0 then
                SL:ShowSystemTips("请配置PC端星星图片")
                return
            end
        else
            for i = 1, 3 do
                if TipsStarCustom["star_sfx_"..i][2] then
                    strResPC = strResPC .. TipsStarCustom["star_sfx_"..i][2] .. (i ~= 3 and "&" or "")
                end
            end
            if string.len(strResPC) == 0 then
                SL:ShowSystemTips("请配置PC端星星特效")
                return
            end
        end


        local strValue = string.format("%s#%s#%s#%s#%s#%s|%s#%s#%s#%s#%s#%s",
            TipsStarCustom.resType[1], strResMob, TipsStarCustom.resSpaceX[1], TipsStarCustom.resSpaceY[1], TipsStarCustom.starW[1], TipsStarCustom.starH[1],
            TipsStarCustom.resType[2], strResPC, TipsStarCustom.resSpaceX[2], TipsStarCustom.resSpaceY[2], TipsStarCustom.starW[2], TipsStarCustom.starH[2]
        )

        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function TipsStarCustom.initData(key)
    TipsStarCustom.resType   = {1, 1}        -- 资源类型 1图片 2特效 默认显示图片
    TipsStarCustom.star_sfx_1 = {}           -- 个位星星特效
    TipsStarCustom.star_sfx_2 = {}           -- 十位星星特效
    TipsStarCustom.star_sfx_3 = {}           --  百位星星特效
    TipsStarCustom.star_img_1 = {"bg_tipszyxx_05", "bg_tipszyxx_05"}  -- 个位星星图片
    TipsStarCustom.star_img_2 = {"bg_tipszyxx_04", "bg_tipszyxx_04"}  -- 十位星星图片
    TipsStarCustom.star_img_3 = {"bg_tipszyxx_04", "bg_tipszyxx_04"}  -- 百位星星图片
    TipsStarCustom.resSpaceX = { 0, 0 }     -- 横向间隔 默认0
    TipsStarCustom.resSpaceY = { 0, 0 }     -- 纵向间隔 默认0
    TipsStarCustom.starW     = { 25, 25 }   -- 星星宽度 默认25
    TipsStarCustom.starH     = { 25, 25 }   -- 星星高度 默认25

    local value = SL:GetMetaValue("GAME_DATA", key)
    if value and string.len(value) > 0 then
        local set = string.split(value, "|")
        local paramMob = string.split(set[1], "#")
        local paramWin = string.split(set[2], "#")

        TipsStarCustom.resType[1] = paramMob[1] and tonumber(paramMob[1]) or TipsStarCustom.resType[1]
        TipsStarCustom.resType[2] = paramWin[1] and tonumber(paramWin[1]) or TipsStarCustom.resType[2]

        local resPathMob = string.split(paramMob[2] or "", "&")
        if resPathMob ~= "" then
            for i = 1, 3 do
                if resPathMob[i] and string.len(resPathMob[i]) > 0 then
                    local key = "star_" .. (TipsStarCustom.resType[1] == 1 and "img_" or "sfx_") .. i
                    TipsStarCustom[key][1] = resPathMob[i]
                end
            end
        end

        local resPathPC = string.split(paramWin[2] or "", "&")
        if resPathPC ~= "" then
            for i = 1, 3 do
                if resPathPC[i] and string.len(resPathPC[i]) > 0 then
                    local key = "star_" .. (TipsStarCustom.resType[2] == 1 and "img_" or "sfx_") .. i
                    TipsStarCustom[key][2] = resPathPC[i]
                end
            end
        end

        TipsStarCustom.resSpaceX[1] = paramMob[3] and tonumber(paramMob[3]) or TipsStarCustom.resSpaceX[1]
        TipsStarCustom.resSpaceX[2] = paramWin[3] and tonumber(paramWin[3]) or TipsStarCustom.resSpaceX[2]

        TipsStarCustom.resSpaceY[1] = paramMob[4] and tonumber(paramMob[4]) or TipsStarCustom.resSpaceY[1]
        TipsStarCustom.resSpaceY[2] = paramWin[4] and tonumber(paramWin[4]) or TipsStarCustom.resSpaceY[2]

        TipsStarCustom.starW[1] = paramMob[5] and tonumber(paramMob[5]) or TipsStarCustom.starW[1]
        TipsStarCustom.starW[2] = paramWin[5] and tonumber(paramWin[5]) or TipsStarCustom.starW[2]

        TipsStarCustom.starH[1] = paramMob[6] and tonumber(paramMob[6]) or TipsStarCustom.starH[1]
        TipsStarCustom.starH[2] = paramWin[6] and tonumber(paramWin[6]) or TipsStarCustom.starH[2]
    end
end

function TipsStarCustom.initPageBtn()
    TipsStarCustom.selPage = nil
    local function onClickPageBtn(page)
        if TipsStarCustom.selPage == page then
            return
        end

        if TipsStarCustom.selPage then
            local oldPage = TipsStarCustom._ui["page_btn_" .. TipsStarCustom.selPage]
            GUI:Layout_setBackGroundColor(oldPage, "#000000")
        end

        TipsStarCustom.selPage = page

        local newPage = TipsStarCustom._ui["page_btn_" .. TipsStarCustom.selPage]
        GUI:Layout_setBackGroundColor(newPage, "#ffbf6b")

        TipsStarCustom.updateContent()
        TipsStarCustom.hidePullDownCells()
    end

    for i = 1, 2 do
        local pageBtn = TipsStarCustom._ui["page_btn_" .. i]
        GUI:addOnClickEvent(pageBtn, function()
            GUI:delayTouchEnabled(pageBtn, 0.5)
            onClickPageBtn(i)
        end)
    end

    onClickPageBtn(1)
end

local tResType = {
    [1] = "图片", [2] = "特效",
}

function TipsStarCustom.updateContent()
    local idx = TipsStarCustom.selPage

    GUI:Text_setString(TipsStarCustom._ui["Text_res_type"], tResType[TipsStarCustom.resType[idx]])
    GUI:setRotation(TipsStarCustom._ui["arrow"], 0)

    TipsStarCustom.updateResState()

    GUI:TextInput_setString(TipsStarCustom._ui["InpuResSpaceX"], TipsStarCustom.resSpaceX[idx])
    GUI:TextInput_setString(TipsStarCustom._ui["InpuResSpaceY"], TipsStarCustom.resSpaceY[idx])

    GUI:TextInput_setString(TipsStarCustom._ui["InputStarW"], TipsStarCustom.starW[idx])
    GUI:TextInput_setString(TipsStarCustom._ui["InputStarH"], TipsStarCustom.starH[idx])
end

function TipsStarCustom.updateResState()
    if TipsStarCustom.resType[TipsStarCustom.selPage] == 1 then
        for i = 1, 3 do
            GUI:TextInput_setString(TipsStarCustom._ui["InputSfx" .. i], "")
            GUI:setVisible(TipsStarCustom._ui["mask_sfx" .. i], true)
            GUI:setVisible(TipsStarCustom._ui["mask_img" .. i], false)
            GUI:removeAllChildren(TipsStarCustom._ui["Node_sfx" .. i])
            local imgName = TipsStarCustom["star_img_" .. i][TipsStarCustom.selPage]
            GUI:TextInput_setString(TipsStarCustom._ui["InputImg" .. i], imgName)
            local imgPath = string.format("res/private/item_tips/%s.png", imgName)
            local node_img = TipsStarCustom._ui["Node_img" .. i]
            GUI:removeAllChildren(node_img)
            local img = GUI:Image_Create(node_img, "img"..i, 0, 0, imgPath)
            if img then
                GUI:setAnchorPoint(img, 0.5, 0.5)
            end
        end
    else
        for i = 1, 3 do
            GUI:TextInput_setString(TipsStarCustom._ui["InputImg" .. i], "")
            GUI:setVisible(TipsStarCustom._ui["mask_img" .. i], true)
            GUI:setVisible(TipsStarCustom._ui["mask_sfx" .. i], false)
            GUI:removeAllChildren(TipsStarCustom._ui["Node_img" .. i])
            local sfxId = TipsStarCustom["star_sfx_" .. i][TipsStarCustom.selPage]
            GUI:TextInput_setString(TipsStarCustom._ui["InputSfx" .. i], sfxId or "")
            local node_sfx = TipsStarCustom._ui["Node_sfx" .. i]
            GUI:removeAllChildren(node_sfx)
            if sfxId then
                GUI:Effect_Create(node_sfx, "sfx"..i, 0, 0, 0, sfxId)
            end
        end
    end
end

function TipsStarCustom.initInput()
    for i = 1, 3 do
        local inputImg = TipsStarCustom._ui["InputImg" .. i]
        GUI:setTouchEnabled(inputImg, false)

        local selImg = TipsStarCustom._ui["sel_img" .. i]
        GUI:addOnClickEvent(selImg, function()
            local function callFunc(res)
                if not res or res == "" then
                    return
                end
    
                if not string.find(res, pathRes) then
                    return
                end
    
                local name = string.gsub(res, pathRes, "")
                name = string.gsub(name, "(.png)$", "")
                TipsStarCustom["star_img_"..i][TipsStarCustom.selPage] = name
                local node_img = TipsStarCustom._ui["Node_img" .. i]
                GUI:removeAllChildren(node_img)
                local img = GUI:Image_Create(node_img, "img"..i, 0, 0, res)
                if img then
                    GUI:setAnchorPoint(img, 0.5, 0.5)
                end

                GUI:TextInput_setString(TipsStarCustom._ui["InputImg" .. i], name)
            end

            local imgName = TipsStarCustom["star_img_" .. i][TipsStarCustom.selPage]
            local resPath = (imgName and imgName ~= "") and pathRes .. imgName or pathRes .. "bg_tipszyxx_05"
            global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, { res = resPath .. ".png", callfunc = callFunc })
        end)

        local inputSfx = TipsStarCustom._ui["InputSfx" .. i]
        GUI:TextInput_setInputMode(inputSfx, 2)
        local srcInputSfx = GUI:TextInput_getString(inputSfx)
        GUI:TextInput_addOnEvent(inputSfx, function(_, eventType)
            if eventType == 1 then
                local strInput = GUI:TextInput_getString(inputSfx)
                if string.len(strInput) == 0 then
                    GUI:TextInput_setString(inputSfx, srcInputSfx)
                    SL:ShowSystemTips("请输入特效ID")
                else
                    local node_sfx = TipsStarCustom._ui["Node_sfx" .. i]
                    GUI:removeAllChildren(node_sfx)
                    GUI:Effect_Create(node_sfx, "sfx"..i, 0, 0, 0, tonumber(strInput))
                    TipsStarCustom["star_sfx_"..i][TipsStarCustom.selPage] = tonumber(strInput)
                end
            end
        end)
    end

    TipsStarCustom.inputs = {
        { name = "InpuResSpaceX", key = "resSpaceX" }, { name = "InpuResSpaceY", key = "resSpaceY" },
        { name = "InputStarW", min = 0, onlyNum = true, key = "starW"},
        { name = "InputStarH", min = 0, onlyNum = true, key = "starH"},
    }

    for _, v in ipairs(TipsStarCustom.inputs) do
        local textInput = TipsStarCustom._ui[v.name]
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
                        if v.min and numInput <= v.min then
                            GUI:TextInput_setString(textInput, srcInput)
                            SL:ShowSystemTips("请输入大于" .. v.min .. "的数字")
                            return
                        end
                    end
                    TipsStarCustom[v.key][TipsStarCustom.selPage] = strInput
                end
            end
        end)
    end
end

function TipsStarCustom.initPullDownCells()
    TipsStarCustom.Image_pulldown_bg = TipsStarCustom._ui["Image_pulldown_bg"]
    TipsStarCustom.ListView_pulldown = GUI:getChildByName(TipsStarCustom.Image_pulldown_bg, "ListView_pulldown")
    TipsStarCustom.Layout_hide_pullDownList = TipsStarCustom._ui["Layout_hide_pullDownList"]
    GUI:setSwallowTouches(TipsStarCustom.Layout_hide_pullDownList, false)
    GUI:addOnClickEvent(TipsStarCustom.Layout_hide_pullDownList, function()
        TipsStarCustom.hidePullDownCells()
    end)

    local function showItems(items, callBackFunc, maxHeight)
        GUI:ListView_removeAllItems(TipsStarCustom.ListView_pulldown)

        local keys = table.keys(items)
        table.sort(keys)
        for _, key in ipairs(keys) do
            local Image_bg = GUI:Image_Create(TipsStarCustom.ListView_pulldown, "Image_bg"..key, 0, 0, "res/public/1900000668.png")
            GUI:Image_setScale9Slice(Image_bg, 51, 51, 10, 10)
            GUI:setContentSize(Image_bg, 98, 28)
            GUI:setIgnoreContentAdaptWithSize(Image_bg, false)
            GUI:setTouchEnabled(Image_bg, true)

            local text_name = GUI:Text_Create(Image_bg, "text_name", 49, 14, 14, "#FFFFFF", items[key])
            GUI:setAnchorPoint(text_name, 0.5, 0.5)

            GUI:addOnClickEvent(Image_bg, function()
                callBackFunc(key)
                TipsStarCustom.hidePullDownCells()
            end)
        end

        local width, height = 98, math.min(28 * #keys, maxHeight or 9999999)

        GUI:setContentSize(TipsStarCustom.ListView_pulldown, width, height)
        GUI:setContentSize(TipsStarCustom.Image_pulldown_bg, width + 2, height + 2)
        GUI:setPositionY(TipsStarCustom.ListView_pulldown, height + 1)
    end

    local bg_res_type = TipsStarCustom._ui["bg_res_type"]
    GUI:addOnClickEvent(bg_res_type, function()
        showItems(tResType, function(index)
            TipsStarCustom.resType[TipsStarCustom.selPage] = index
            GUI:Text_setString(TipsStarCustom._ui["Text_res_type"], tResType[index])
            TipsStarCustom.updateResState()
        end)
        local node_pos = GUI:getPosition(bg_res_type)
        GUI:setPosition(TipsStarCustom.Image_pulldown_bg, node_pos.x, node_pos.y)
        GUI:setVisible(TipsStarCustom.Image_pulldown_bg, true)
        GUI:setSwallowTouches(TipsStarCustom.Layout_hide_pullDownList, false)
        GUI:setVisible(TipsStarCustom.Layout_hide_pullDownList, true)
        GUI:setRotation(TipsStarCustom._ui["arrow"], 180)
    end)
end

function TipsStarCustom.hidePullDownCells()
    GUI:setVisible(TipsStarCustom.Image_pulldown_bg, false)
    GUI:setVisible(TipsStarCustom.Layout_hide_pullDownList, false)
    GUI:ListView_removeAllItems(TipsStarCustom.ListView_pulldown)

    GUI:setRotation(TipsStarCustom._ui["arrow"], 0)
end

return TipsStarCustom