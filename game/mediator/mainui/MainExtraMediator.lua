local MainExtraMediator = class("", framework.Mediator)
MainExtraMediator.NAME = "MainExtraMediator"

function MainExtraMediator:ctor()
    MainExtraMediator.super.ctor(self, self.NAME)
    self._tipDir = nil
    self._anchorP = {cc.p(1,0), cc.p(0.5,0), cc.p(0,0), cc.p(0, 0.5), cc.p(0, 1), cc.p(0.5, 1), cc.p(1,1), cc.p(1, 0.5)}
end

function MainExtraMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.AddBoxDayBtnToScreen,
        noticeTable.AddTradingBankBtnToScreen,
    }
end

function MainExtraMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnOpen()
    elseif noticeTable.AddBoxDayBtnToScreen == noticeID then
        self:OnAddBoxDayBtnToScreen(data)
    elseif noticeTable.AddTradingBankBtnToScreen == noticeID then
        self:OnAddTradingBankBtnToScreen(data)
    end
end

function MainExtraMediator:OnOpen()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_BUFFLIST)
    MainBuffList.main()
end

local function checkPos(widget, parent, pos)
    local touchNodeSize = widget:getContentSize()
    local touchNodeAnchor = widget:getAnchorPoint()
    local worldPos = widget:getWorldPosition()
    local winSize = global.Director:getWinSize()
    local scale = widget:getScale()

    local afterPos = worldPos
    if worldPos.x - touchNodeSize.width*(touchNodeAnchor.x)*scale < 0 then -- 超左边
        afterPos.x = afterPos.x - (worldPos.x - touchNodeSize.width*(touchNodeAnchor.x)*scale)
    end

    if worldPos.x + touchNodeSize.width*(1-touchNodeAnchor.x)*scale > winSize.width then -- 超右边
        afterPos.x = afterPos.x - (worldPos.x + touchNodeSize.width*(1-touchNodeAnchor.x)*scale - winSize.width)
    end

    if worldPos.y + touchNodeSize.height*(1-touchNodeAnchor.y)*scale > winSize.height then -- 超上边
        afterPos.y = afterPos.y - (worldPos.y + touchNodeSize.height*(1-touchNodeAnchor.y)*scale - winSize.height)
    end

    if worldPos.y - touchNodeSize.height*(touchNodeAnchor.y)*scale < 0 then   --超下边
        afterPos.y = afterPos.y - (worldPos.y - touchNodeSize.height*(touchNodeAnchor.y)*scale)
    end

    local nodePos = parent:convertToNodeSpace(afterPos)
    if nodePos.x ~= pos.x or nodePos.y ~= pos.y then
        return nodePos
    end

    return false
end

function MainExtraMediator:OnAddBoxDayBtnToScreen( data )
    if not data.subid or not (data.subid >= 101 and data.subid <= 108) then
        return
    end
    local scale = tonumber(data.scale) and tonumber(data.scale)/100 or 1

    local panel = ccui.Layout:create()
    panel:setContentSize(cc.size(50, 50))
    panel:setAnchorPoint(cc.p(0, 1))
    
    local sfx = global.FrameAnimManager:CreateSFXAnim(5109)
    sfx:Play(0,0,true)
    local offset = cc.p(22*scale, (-42)*scale)
    panel:setTouchEnabled(true)
    panel:addClickEventListener(function ()
        global.Facade:sendNotification(global.NoticeTable.Layer_Box996Main_Open)
    end)

    local attachData = {
        index = data.subid,
        subid = "996OfficalEveryDayPanel",
        content = panel
    }

    local y = 0 - data.y
    panel:setPosition(data.x, y)
    panel:setScale(scale)
    global.Facade:sendNotification(global.NoticeTable.SUIComponentAttachBySSR, attachData)

    local attachData = {
        index = data.subid,
        subid = "996OfficalEveryDaySfx",
        content = sfx
    }

    sfx:setPosition(data.x + offset.x, y + offset.y)
    global.Facade:sendNotification(global.NoticeTable.SUIComponentAttachBySSR, attachData)

    local pos = checkPos(panel, ssr.GUI:GetSUIParent(data.subid), cc.p(data.x, y))
    if pos then
        panel:setPosition(pos.x, pos.y)
        sfx:setPosition(pos.x + offset.x, pos.y + offset.y)
    end
end

function MainExtraMediator:OnAddTradingBankBtnToScreen( data )
    if not data.subid or not (data.subid >= 101 and data.subid <= 108) then
        return
    end

    local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    if OtherTradingBankProxy:getPublishOpen() == 1 then
        return
    end

    local btn = ccui.Button:create()
    btn:setAnchorPoint(cc.p(0, 1))
    btn:loadTextureNormal(global.MMO.PATH_RES_PRIVATE.."trading_bank/jiaoyihang.png")
    btn:setTouchEnabled(true)
    btn:ignoreContentAdaptWithSize(false)
    btn:setContentSize(cc.size(data.width, data.height))
    btn:addClickEventListener(function ()
        JUMPTO(35)
    end)

    local attachData = {
        index = data.subid,
        subid = "996OfficalTradingBankBtn",
        content = btn
    }

    local y = 0 - data.y
    btn:setPosition(data.x, y)
    global.Facade:sendNotification(global.NoticeTable.SUIComponentAttachBySSR, attachData)

    local pos = checkPos(btn, ssr.GUI:GetSUIParent(data.subid), cc.p(data.x, y))
    if pos then
        btn:setPosition(pos.x, pos.y)
    end
end

-------------------
function MainExtraMediator:CreateBuffPanel(panelWid, panelHei, showNum, direction)
    panelWid = panelWid or 180
    panelHei = panelHei or 40
    showNum = showNum or 4
    direction = direction or 2

    local buffList = ccui.ListView:create()
    buffList:setName("996OfficalBuffList")
    buffList:setContentSize(cc.size(panelWid, panelHei))
    buffList:setClippingEnabled(true)
    buffList:setClippingType(0)
    buffList:setTouchEnabled(true)
    buffList:setSwallowTouches(false)
    buffList:setDirection(direction)

    self._buffList = buffList
    self._buffList:removeAllItems()

    if direction == 2 then -- 横
        self._cellWid = math.ceil(panelWid / showNum)
        self._cellHei = panelHei
    elseif direction == 1 then -- 竖
        self._cellWid = panelWid
        self._cellHei = math.ceil(panelHei / showNum)
    end
    
    local items = global.BuffManager:GetDataByUID(global.gamePlayerController:GetMainPlayerID())
    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    for _, v in pairs(items) do
        local config = BuffProxy:GetConfigByID(v.id)
        if config and config.icon and string.len(config.icon) > 0 then
            local cell = self:CreateBuffCell(v)
            self._buffList:pushBackCustomItem(cell.nativeUI)
        end
    end

end

function MainExtraMediator:CreateBuffCell( data )
    local cellWid =  self._cellWid or 45
    local cellHei = self._cellHei or 40
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(cellWid, cellHei))
    layout:setTouchEnabled(true)
    local icon = ccui.ImageView:create()
    icon:setName("icon")
    icon:setAnchorPoint(0.5, 0.5)
    icon:setPosition(cellWid/2, cellHei/2)
    icon:ignoreContentAdaptWithSize(true)
    icon:addTo(layout)
    local Text_param = ccui.Text:create()
    Text_param:setName("Text_param")
    Text_param:setFontName(global.MMO.PATH_FONT)
    Text_param:setFontSize(SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16)
    Text_param:setTextColor({r = 255, g = 255, b = 0})
    Text_param:setAnchorPoint(0.5, 0.5)
    local offsetX = self._endOffset and self._endOffset.x or 0
    local offsetY = self._endOffset and self._endOffset.y or 0
    Text_param:setPosition(cellWid/2 + offsetX, cellHei*0.20 + offsetY)
    Text_param:enableOutline(cc.Color3B.BLACK, 1 )
    Text_param:addTo(layout)
    if self._endColorID then
        Text_param:setTextColor(GET_COLOR_BYID_C3B(self._endColorID))
    end

    --叠加
    local Text_ol = ccui.Text:create()
    Text_ol:setName("Text_ol")
    Text_ol:setFontName(global.MMO.PATH_FONT)
    Text_ol:setFontSize(SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16)
    Text_ol:setTextColor({r = 255, g = 255, b = 255})
    Text_ol:enableOutline(cc.Color3B.BLACK, 1 )
    Text_ol:setAnchorPoint(1, 1)
    Text_ol:addTo(icon)
    if self._olColorID then
        Text_ol:setTextColor(GET_COLOR_BYID_C3B(self._olColorID))
    end

    local ui = ui_delegate(layout)
    -- 
    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local config = BuffProxy:GetConfigByID(data.id)
    if config then
        -- 说明
        ui.nativeUI:addClickEventListener(function(sender)
            local pos = sender:getTouchEndPosition()
            local str = config.name or ""
            if config.tips then
                if string.len(str) > 0 then
                    str = str .. "\\".. config.tips
                else
                    str = config.tips
                end
            end
            if string.len(str) == 0 then
                return
            end
            str  = string.gsub(str, "%^", "\\")
            local anchorPoint = self._tipDir and self._anchorP[self._tipDir + 1] or cc.p(0,0)
            global.Facade:sendNotification(global.NoticeTable.Layer_Common_Desc_Open, {str = str,worldPos = pos, width = 400, anchorPoint = anchorPoint})
        end)

        -- icon
        local path = string.format("%s%s.png", global.MMO.PATH_RES_BUFF_ICON, config.icon)
        ui.icon:loadTexture(path)
        if self._iconSize then
            ui.icon:ignoreContentAdaptWithSize(false)
            ui.icon:setContentSize(self._iconSize)
        end

        local iconS = ui.icon:getContentSize()
        local offsetX = self._olOffset and self._olOffset.x or 0
        local offsetY = self._olOffset and self._olOffset.y or 0
        ui.Text_ol:setPosition(iconS.width + offsetX, iconS.height + offsetY)

        ui.Text_param:setVisible(false)
        ui.Text_ol:setVisible(false)
        -- param
        if data.param and data.param > 0 and data.id > 10000 then
            -- 时间
            ui.Text_param:setVisible(true)
            local function callback()
                local remaining = math.max(data.endTime - GetServerTime(), 0)
                local t = SecondToHMS(remaining)
                local str = string.format("%ss", remaining)
                if t.h > 0 or t.d > 0 then
                    str = string.format("%sh", t.d*24 + t.h)
                elseif t.m > 0 then
                    str = string.format("%sm", t.m)
                else
                    str = string.format("%ss", t.s)
                end
                ui.Text_param:setString(str)
                
    
                if remaining <= 0 then
                    ui.Text_param:stopAllActions()
                    ui.Text_param:setVisible(false)
                end
            end
            ui.Text_param:stopAllActions()
            schedule(ui.Text_param, callback, 1)
            callback()
            
        end

        if data.ol and data.ol > 0 then
            -- 叠加性
            ui.Text_ol:setVisible(true)
            ui.Text_ol:setString(data.ol)
        end
    end

    return ui
end

function MainExtraMediator:OnUpdateBuff( data )
    if not global.gamePlayerController:GetMainPlayerID() then
        return
    end
    if data.actorID ~= global.gamePlayerController:GetMainPlayerID() then
        return
    end
    if not self._buffList or tolua.isnull(self._buffList) then
        return
    end

    self._buffList:removeAllItems()
    local items = global.BuffManager:GetDataByUID(global.gamePlayerController:GetMainPlayerID())
    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    for _, v in pairs(items) do
        local config = BuffProxy:GetConfigByID(v.id)
        if config and config.icon and string.len(config.icon) > 0 then
            local cell = self:CreateBuffCell(v)
            self._buffList:pushBackCustomItem(cell.nativeUI)
        end
    end
end

return MainExtraMediator
