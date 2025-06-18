local BaseLayer = requireLayerUI("BaseLayer")
local Box996SVIPLayer = class("Box996SuperLayer", BaseLayer)

local RichTextHelp = require("util/RichTextHelp")

function Box996SVIPLayer:ctor()
    Box996SVIPLayer.super.ctor(self)

    self._svip_level = 0
    self._show_svip_level = 1
    self._isBoxOpen = false
end

function Box996SVIPLayer.create(data)
    local layer = Box996SVIPLayer.new()
    if layer and layer:Init(data) then
        return layer
    end
    return nil
end

function Box996SVIPLayer:Init(data)
    self._root = CreateExport("box996_ui/box996_svip_layer.lua")
    if not self._root then
        return false
    end

    self:addChild(self._root)

    self._root:setPosition(-60, -25)

    self._ui = ui_delegate(self._root)

    self._attr_panel_pos = cc.p(self._ui.Panel_svip_attr:getPosition())
    self._libao_panel_pos = cc.p(self._ui.Panel_svip_libao:getPosition())

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    local svipData = proxy:getSVIPData()
    self._isBoxOpen = proxy:isBoxOpen()

    self._ui.Text_svip_level_t:setVisible(false)
    self._ui.Text_svip_level:setVisible(false)
    self._ui.Panel_svip_attr:setVisible(false)
    self._ui.Panel_svip_libao:setVisible(false)
    self._ui.Panel_svip_libao:getChildByName("Text_get_title"):setVisible(false)

    proxy:joinSvipUpdateSvipState()
    if svipData then
        self:UpdateSVIPList(svipData)
    end

    -- 一键激活 属性
    self._ui.Button_jihuo:addClickEventListener(function(sender)
        --
        print("===一键激活")
        if not self._svip_level then
            return
        end
        local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
        local svipState = proxy:getSVIPState(self._svip_level)
        if not svipState then
            return
        end
        -- 请求激活
        if svipState.propState == 2 then
            proxy:requestSVIPReward(self._show_svip_level, proxy.SVIP_REWARD_TYPE.TYPE_ATTR)
            proxy:requestLogUp(proxy.SVIP_BOX_UP_UP[3])
            DelayTouchEnabled(sender, 1) -- 延迟一秒
        end
    end)

    -- 解锁 属性
    self._ui.Button_jiesuo1:addClickEventListener(function(sender)
        -- 跳转
        print("===解锁 属性")
    end)

    -- 领取  礼包
    self._ui.Button_get:addClickEventListener(function(sender)
        --
        print("===一键激活 礼包")

        local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
        local svipState = proxy:getSVIPState(self._show_svip_level)
        if not svipState then
            return
        end
        -- 请求领取
        if svipState.giftState == 2 then
            proxy:requestSVIPReward(self._show_svip_level, proxy.SVIP_REWARD_TYPE.TYPE_LIBAO)
            proxy:requestLogUp(proxy.SVIP_BOX_UP_UP[2])
            DelayTouchEnabled(sender, 1) -- 延迟一秒
        end
    end)

    -- 解锁 礼包
    self._ui.Button_jiesuo2:addClickEventListener(function(sender)
        --
        print("===解锁 礼包")
        -- 跳转
    end)

    -- 下载盒子
    self._ui.Button_download:addClickEventListener(function(sender)
        -- 下载盒子    
        proxy:getBox996DownloadURL( 7 )
        proxy:requestLogUp(proxy.SVIP_BOX_UP_UP[1])
    end)

    -- 开启/未开启
    self._ui.Panel_switch:addClickEventListener(function(sender)
        local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
        local svipState = proxy:getSVIPState(self._show_svip_level)
        if not svipState then
            return
        end

        local state = proxy:getSvipRemindFlag()
        proxy:requestSVIPRemindOnOff(not state)
        DelayTouchEnabled(sender, 1) -- 延迟一秒
    end)

    local animId = 5110
    local anim = self:addAnim(self._ui.Button_jihuo, animId)
    self._ui.Image_jihuo:setVisible(false)
    if anim then
        anim:setPosition(45, -8)
        anim:setScale(1)
    end

    local anim = self:addAnim(self._ui.Button_jiesuo1, animId)
    if anim then
        anim:setPosition(28, -13)
        anim:setScale(1)
    end

    local anim = self:addAnim(self._ui.Button_get, animId)
    self._ui.Image_get:setVisible(false)
    if anim then
        anim:setPosition(45, -8)
        anim:setScale(1)
    end

    local anim = self:addAnim(self._ui.Button_jiesuo2, animId)
    if anim then
        anim:setPosition(28, -13)
        anim:setScale(1)
    end

    local anim = self:addAnim(self._ui.Button_download, animId)
    if anim then
        anim:setPosition(45, -8)
        anim:setScale(1)
    end

    return true
end

-- 添加特效
function Box996SVIPLayer:addAnim(parentNode, animId)
    if not animId then
        return
    end

    parentNode:removeChildByTag(animId)
    local anim = global.FrameAnimManager:CreateSFXAnim(animId)
    if anim then
        anim:setTag(animId)
        anim:Play(0, 0, true)
        parentNode:addChild(anim)
    end
    return anim
end

-- 更新svip等级 list
function Box996SVIPLayer:UpdateSVIPList(data)
    data = data or {}
    local maxLevel = tonumber(data.levelNum) or 0
    local list = self._ui.ListView_svip_title
    list:removeAllChildren()

    for i = 1, maxLevel, 1 do
        local item = self:CreateSVIPItem({
            svip = i
        })
        list:pushBackCustomItem(item)
    end

    -- 请求当前等级
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    proxy:requestSVIPLevel()
end

-- 更新svip等级提示
function Box996SVIPLayer:UpdateSVIPTitle(level)
    self._ui.Text_svip_level_t:setVisible(true)
    self._ui.Text_svip_level:setVisible(true)
    self._ui.Text_svip_level:setString("SVIP" .. (level or 0))
end

function Box996SVIPLayer:CreateSVIPItem(data)
    local item = self._ui.Panel_default:getChildByName("Button_tips"):cloneEx()
    item:setTitleText("VIP" .. (data.svip or 1))
    item:setTag(data.svip or 1)
    item:addClickEventListener(function()
        self:OpenSVIPItem(data.svip or 1)
        local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
        if data.svip == self._svip_level then
            proxy:requestLogUp(proxy.SVIP_BOX_UP_UP[4])
        else
            proxy:requestLogUp(proxy.SVIP_BOX_UP_UP[5])
        end
    end)

    return item
end

-- svip level title
function Box996SVIPLayer:OpenSVIPItem(svip)
    local items = self._ui.ListView_svip_title:getItems()

    for i, item in ipairs(items) do
        if svip == item:getTag() then
            item:setBright(false)
            self:OpenSVIPShowPanel(svip)
        else
            item:setBright(true)
        end
    end
end

-- 打开svip面板
function Box996SVIPLayer:OpenSVIPShowPanel(svip)
    self._show_svip_level = svip
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    local svipData = proxy:getSVIPData()
    local data = svipData and svipData.data and svipData.data[svip]

    if not data then
        return
    end

    local isShowAttrPanel = data.props and data.props[1] and true or false
    local isShowLiBaoPanel = data.gifts and data.gifts[1] and true or false

    self._ui.Panel_svip_attr:setVisible(false)
    self._ui.Panel_svip_libao:setVisible(false)
    if isShowAttrPanel then
        local posX = isShowLiBaoPanel and self._attr_panel_pos.x or (self._attr_panel_pos.x + 160)
        self._ui.Panel_svip_attr:setPositionX(posX)
    end

    if isShowLiBaoPanel then
        local posX = isShowAttrPanel and self._libao_panel_pos.x or (self._libao_panel_pos.x - 100)
        self._ui.Panel_svip_libao:setPositionX(posX)
    end

    local svipState = proxy:getSVIPState(svip)
    if svipData then
        self:UpdateSVTIPAttrPanel(svip)
        self:UpdateSVTIPLiBaoPanel(svip)
        self:UpdateSwitchShowState()
        self:UpdateSwitchState()
        self:UpdateOtherSeverGetTitle()
    end
end

-- 更新属性面板
function Box996SVIPLayer:UpdateSVTIPAttrPanel(svip)
    if not svip then
        svip = self._show_svip_level
    end

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    local svipData = proxy:getSVIPData()
    local data = svipData and svipData.data and svipData.data[svip]

    if not data then
        return
    end

    local isShowAttrPanel = data.props and data.props[1] and true or false
    self._ui.Panel_svip_attr:setVisible(isShowAttrPanel)
    if not isShowAttrPanel then
        return
    end

    local svipState = proxy:getSVIPState(svip)
    local showLv = data.svipLevel
    local isShowLock = false
    if showLv > self._svip_level then -- or svipState.rightBanFlag then
        isShowLock = true
    end

    self._ui.Panel_svip_attr:getChildByName("Image_suo1"):setVisible(isShowLock)
    if showLv == self._svip_level + 1 then
        self._ui.Panel_svip_attr:getChildByName("Image_suo2"):setVisible(false)
    else
        self._ui.Panel_svip_attr:getChildByName("Image_suo2"):setVisible(isShowLock)
    end

    local list = self._ui.ListView_attr_list
    list:removeAllChildren()
    if not isShowLock or showLv == self._svip_level + 1 then
        -- 显示属性
        local outlineStr = "%s" -- "<outline color='#000000' size='2' >%s</outline>"
        for k, v in ipairs(data.props or {}) do
            local item = self._ui.Panel_default:getChildByName("Panel_attr_item"):cloneEx()
            local size = SL:GetMetaValue("GAME_DATA", "DEFAULT_FONT_SIZE") or 16
            local str = string.format("<font color='%s' size='%s'>%s</font>","#28ef01", size, v.propName)
            local textRich = RichTextHelp:CreateRichTextWithXML(str, 280, size, "#ffffff")
            local itemSize = item:getContentSize()
            textRich:setPosition(itemSize.width / 2, itemSize.height / 2)
            item:addChild(textRich)
            item:getChildByName("Text_2"):setVisible(false)
            list:pushBackCustomItem(item)
        end
    end

    if not self._isBoxOpen then
        self._ui.Panel_svip_attr:getChildByName("Image_jihuo"):setVisible(false)
        self._ui.Panel_svip_attr:getChildByName("Image_jiesuo1"):setVisible(false)
        self._ui.Panel_svip_attr:getChildByName("Text_attr_svip"):setVisible(false)
        return
    end

    self._ui.Panel_svip_attr:getChildByName("Text_attr_svip"):setVisible(false)
    if svip < self._svip_level then
        self._ui.Panel_svip_attr:getChildByName("Image_jihuo"):setVisible(false)
        self._ui.Panel_svip_attr:getChildByName("Image_jiesuo1"):setVisible(false)
        self._ui.Panel_svip_attr:getChildByName("Text_attr_svip"):setVisible(true)

        local titleStr = string.format(GET_STRING(310000429), self._svip_level)
        self._ui.Panel_svip_attr:getChildByName("Text_attr_svip"):setString(titleStr)
        return
    elseif svip > self._svip_level then
        self._ui.Panel_svip_attr:getChildByName("Image_jihuo"):setVisible(false)
        self._ui.Panel_svip_attr:getChildByName("Image_jiesuo1"):setVisible(true)
        return
    end

    -- 按钮状态
    self:UpdateAttrState(svip)
end

-- 更新属性状态  按钮
function Box996SVIPLayer:UpdateAttrState(svip)
    if not self._isBoxOpen then
        return
    end
    if not svip then
        svip = self._show_svip_level
    end

    if svip < self._svip_level then
        self._ui.Panel_svip_attr:getChildByName("Image_jihuo"):setVisible(false)
        self._ui.Panel_svip_attr:getChildByName("Image_jiesuo1"):setVisible(false)
        self._ui.Panel_svip_attr:getChildByName("Text_attr_svip"):setVisible(true)

        local titleStr = string.format("可享受SVIP%s等级收益", self._svip_level)
        self._ui.Panel_svip_attr:getChildByName("Text_attr_svip"):setString(titleStr)
        return
    end

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    local svipState = proxy:getSVIPState(svip)
    if not svipState then
        return
    end

    if svipState.propState == 0 then
        self._ui.Panel_svip_attr:getChildByName("Image_jihuo"):setVisible(false)
        self._ui.Panel_svip_attr:getChildByName("Image_jiesuo1"):setVisible(false)
        return
    end

    if svipState.propState ~= 3 then
        self._ui.Panel_svip_attr:getChildByName("Image_jihuo"):setVisible(true)
        self._ui.Panel_svip_attr:getChildByName("Image_jiesuo1"):setVisible(false)
        local isBright = svipState.propState == 1
        local jihuoBtn = self._ui.Panel_svip_attr:getChildByName("Image_jihuo"):getChildByName("Button_jihuo")
        -- jihuoBtn:setBright(not isBright)
        jihuoBtn:setVisible(not isBright)
        self._ui.Panel_svip_attr:getChildByName("Image_jihuo"):getChildByName("Image_yjh"):setVisible(isBright)


        local animId = 5110
        local anim = jihuoBtn:getChildByTag(animId)
        if anim then
            anim:setVisible(not isBright)
        end
        if isBright then
            Shader_Grey(self._ui.Panel_svip_attr:getChildByName("Image_jihuo"))
            Shader_Grey(jihuoBtn)
        else
            Shader_Normal(self._ui.Panel_svip_attr:getChildByName("Image_jihuo"))
            Shader_Normal(jihuoBtn)
        end
        jihuoBtn:ignoreContentAdaptWithSize(true)

    else
        self._ui.Panel_svip_attr:getChildByName("Image_jiesuo1"):setVisible(true)
        self._ui.Panel_svip_attr:getChildByName("Image_jihuo"):setVisible(false)
    end
end

-- 更新礼包面板
function Box996SVIPLayer:UpdateSVTIPLiBaoPanel(svip)
    if not svip then
        svip = self._show_svip_level
    end

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    local svipData = proxy:getSVIPData()
    local data = svipData and svipData.data and svipData.data[svip]

    if not data then
        return
    end

    local isShowLiBaoPanel = data.gifts and data.gifts[1] and true or false
    self._ui.Panel_svip_libao:setVisible(isShowLiBaoPanel)
    if not isShowLiBaoPanel then
        return
    end

    local svipState = proxy:getSVIPState(svip)
    local showLv = data.svipLevel
    local isShowLock = false
    if showLv > self._svip_level or svipState.rightBanFlag then
        isShowLock = true
    end

    self._ui.Panel_svip_libao:getChildByName("Image_suo4"):setVisible(isShowLock)
    if showLv == self._svip_level + 1 then
        self._ui.Panel_svip_libao:getChildByName("Image_suo3"):setVisible(false)
    else
        self._ui.Panel_svip_libao:getChildByName("Image_suo3"):setVisible(isShowLock)
    end

    local list = self._ui.Panel_svip_libao:getChildByName("ListView_libao_list")
    list:removeAllChildren()
    if not isShowLock or showLv == self._svip_level + 1 then
        -- 显示礼包
        local gifts = data.gifts or {}
        local maxCount = #gifts
        local offX = 0
        if maxCount < 4 then
            offX = 272 / 2 - (maxCount * 68 / 2)
        end
        local maxH = math.ceil(maxCount / 4) * 68
        for k, v in ipairs(gifts) do
            local row = math.ceil(k / 4)
            local col = k % 4
            if col == 0 then
                col = 4
            end
            local item = list:getItem(row - 1)
            if not item then
                item = self:CreateSVIPLiBaoItem(v)
                list:pushBackCustomItem(item)
            end

            local rewardItem = self:CreateSVIPLiBaoRewardItem(v)
            local posx = (col - 1) * 68 + 68 / 2
            -- local posy = row * 68 / 2
            rewardItem:setPosition(posx + offX, 100 / 2)
            item:addChild(rewardItem)
        end
    end

    if not self._isBoxOpen then
        self._ui.Panel_svip_libao:getChildByName("Image_get"):setVisible(false)
        self._ui.Panel_svip_libao:getChildByName("Image_jiesuo2"):setVisible(false)
        return
    end

    if svip > self._svip_level then
        self._ui.Panel_svip_libao:getChildByName("Image_get"):setVisible(false)
        self._ui.Panel_svip_libao:getChildByName("Image_jiesuo2"):setVisible(true)
        return
    end

    self:UpdateLiBaoState(svip)
end

-- 刷新礼包状态  按钮
function Box996SVIPLayer:UpdateLiBaoState(svip)
    if not self._isBoxOpen then
        return
    end
    if not svip then
        svip = self._show_svip_level
    end
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    local svipState = proxy:getSVIPState(svip)
    if not svipState then
        return
    end

    if svipState.giftState == 0 then
        self._ui.Panel_svip_libao:getChildByName("Image_get"):setVisible(false)
        self._ui.Panel_svip_libao:getChildByName("Image_jiesuo2"):setVisible(false)
        return
    end

    if svipState.giftState ~= 3 then
        self._ui.Panel_svip_libao:getChildByName("Image_get"):setVisible(true)
        self._ui.Panel_svip_libao:getChildByName("Image_jiesuo2"):setVisible(false)
        local isBright = svipState.giftState == 1

        local getBtn = self._ui.Panel_svip_libao:getChildByName("Image_get"):getChildByName("Button_get")
        -- getBtn:setBright(not isBright)
        getBtn:setVisible(not isBright)
        self._ui.Panel_svip_libao:getChildByName("Image_get"):getChildByName("Image_ylq"):setVisible(isBright)

        local animId = 5110
        local anim = getBtn:getChildByTag(animId)
        if anim then
            anim:setVisible(not isBright)
        end
        if isBright then
            Shader_Grey(self._ui.Panel_svip_libao:getChildByName("Image_get"))
            Shader_Grey(getBtn)
        else
            Shader_Normal(self._ui.Panel_svip_libao:getChildByName("Image_get"))
            Shader_Normal(getBtn)
        end

        getBtn:ignoreContentAdaptWithSize(true)

    else
        self._ui.Panel_svip_libao:getChildByName("Image_jiesuo2"):setVisible(true)
        self._ui.Panel_svip_libao:getChildByName("Image_get"):setVisible(false)
    end
end

-- 更新下载面板
function Box996SVIPLayer:UpdateDownloadPanel(svip)
    if self._isBoxOpen then
        return
    end
    self._ui.Panel_svip_download:setVisible(true)
end

-- 更新是否提醒
function Box996SVIPLayer:UpdateSwitchShowState()
    local proxy  = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    local svipLv = proxy:getSvipLevel()
    local svipState = proxy:getSVIPState(self._show_svip_level) or {}
    local isShow = svipLv == self._show_svip_level and svipState.giftState == 1 --已领取才显示
    self._ui.Panel_svip_libao:getChildByName("Panel_switch"):getChildByName("Image_open"):setVisible(isShow)
    self._ui.Panel_svip_libao:getChildByName("Panel_switch"):getChildByName("Image_close"):setVisible(isShow)
    self._ui.Panel_svip_libao:getChildByName("Panel_switch"):getChildByName("Text_open_title"):setVisible(isShow)
    self._ui.Panel_svip_libao:getChildByName("Panel_switch"):getChildByName("Text_other_sever_title"):setVisible(self._show_svip_level == svipLv)
end
-- 更新开启/未开启
function Box996SVIPLayer:UpdateSwitchState()
    local proxy  = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    local svipLv = proxy:getSvipLevel()
    local svipState = proxy:getSVIPState(self._show_svip_level) or {}
    local isShow = svipLv == self._show_svip_level and svipState.giftState == 1 --已领取才显示
    if not isShow then
        return
    end
    local switchState = proxy:getSvipRemindFlag()
    self._ui.Panel_svip_libao:getChildByName("Panel_switch"):getChildByName("Image_open"):setVisible(switchState==true)
    self._ui.Panel_svip_libao:getChildByName("Panel_switch"):getChildByName("Image_close"):setVisible(not switchState)
end

-- 更新其他区服礼包领取的天数提示
function Box996SVIPLayer:UpdateOtherSeverGetTitle()
    local proxy  = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    local str = proxy:getSvipUseMessage(self._show_svip_level)
    self._ui.Panel_svip_libao:getChildByName("Panel_switch"):getChildByName("Text_other_sever_title"):setString(str)
end

-- 创建礼包item
function Box996SVIPLayer:CreateSVIPLiBaoItem(data)
    local item = self._ui.Panel_default:getChildByName("Panel_libao_item"):cloneEx()
    return item
end

-- 创建奖励item
function Box996SVIPLayer:CreateSVIPLiBaoRewardItem(data)
    local panel = self._ui.Panel_default:getChildByName("Panel_reward_item"):cloneEx()
    data = data or {}

    local goodsItem = GoodsItem:create({
        index = data.giftId,
        count = data.giftValue,
        bgVisible = true,
        look = true
    })

    local newSz = {
        width = 68,
        height = 68
    }
    goodsItem:setPosition(newSz.width / 2, newSz.height / 2 + 10)
    panel:addChild(goodsItem, -1)
    panel:setTouchEnabled(false)

    panel:getChildByName("Text_reward_name"):setString(data.giftName or "")

    local sfx = self:addAnim(panel, 5111)

    sfx:setScale(1)

    sfx:setPosition(newSz.width / 2 - 2, 20)

    return panel
end

-- 数据变化刷新
function Box996SVIPLayer:OnRefresh(rData)
    local data = rData.data
    if rData.isTitleList then
        self:UpdateSVIPList(data)
    end

    if rData.isSvipLevel then
        self._svip_level = tonumber(data.svipLevel) or 0
        if self._svip_level >= 1 then
            self._show_svip_level = self._svip_level
            self._ui.ListView_svip_title:jumpToItem(self._svip_level - 1, cc.p(0, 0), cc.p(0, 0))
        end
        self:UpdateSVIPTitle(self._svip_level)
        self:OpenSVIPItem(self._show_svip_level)
        self:UpdateDownloadPanel(self._show_svip_level)
    end

    if rData.isState and rData.svip == self._show_svip_level then
        self:UpdateSVTIPAttrPanel(self._show_svip_level)
        self:UpdateSVTIPLiBaoPanel(self._show_svip_level)
        self:UpdateDownloadPanel(self._show_svip_level)
        rData.isRemindFlag = true
    end

    if rData.isGetState and rData.svip == self._show_svip_level then
        self:UpdateAttrState(self._show_svip_level)
        self:UpdateLiBaoState(self._show_svip_level)
    end

    if rData.isRemindFlag then
       self:UpdateSwitchShowState()
       self:UpdateSwitchState()
       self:UpdateOtherSeverGetTitle()
    end
end

return Box996SVIPLayer
