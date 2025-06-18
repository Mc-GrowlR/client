local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankReceiveLayer = class("TradingBankReceiveLayer", BaseLayer)
local cjson = require("cjson")
local RichTextHelp = require("util/RichTextHelp")
function TradingBankReceiveLayer:ctor()
    TradingBankReceiveLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)

end

function TradingBankReceiveLayer.create(...)
    local ui = TradingBankReceiveLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end
function TradingBankReceiveLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_receive")
    self._root = ui_delegate(self)

    if global.isBoxLogin then
        self._root.Button_2:setVisible(true)
    else
        local pSizeW = self._root.Panel_2:getContentSize().width
        self._root.Button_1:setPositionX(pSizeW / 2)
        self._root.Button_2:setVisible(false)
    end
    if global.IsReceiveRole then -- 收货模式 
        self:GetTime()
    else
        if global.IsVisitor then --试玩模式
            self._root.Image_1:setVisible(false)
            self._root.Button_3:setVisible(false)
            self._root.Button_4:setVisible(false)
        end
    end


    -- local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    -- local selectRole = LoginProxy:GetSelectedRole()
    -- selectRole.ORDER
    for i = 1, 4 do
        self._root["Button_" .. i]:addTouchEventListener(handler(self, self.onButtonClick))
    end

    return true
end

function TradingBankReceiveLayer:CreateTimeRichText(time)
    self._root.Image_1:stopAllActions()

    self.time = (time or self.endTime) - GetServerTime()
    -- dump(GetServerTime() ,"serverTime")
    -- dump(self.time)
    local timefunc = function()
        if self.time <= 0 then
            return
        end
        local day, hour, min, sce = TimeFormat(self.time)
        local timestring = string.format(GET_STRING(600000054), hour, min, sce)
        local richText = RichTextHelp:CreateRichTextWithXML(timestring, 460, 16, "#ffffff")
        if richText then
            self._root.Image_1:removeAllChildren()
            richText:formatText()
            richText:setAnchorPoint(0.5, 0.5)
            self._root.Image_1:addChild(richText)
            richText:setPosition(self._root.Image_1:getContentSize().width / 2, self._root.Image_1:getContentSize().height / 2)
        end
    end
    timefunc()
    schedule(self._root.Image_1, function()
        timefunc()
        self.time = self.time - 1
        if self.time <= 0 then
            self._root.Image_1:removeAllChildren()
            self._root.Image_1:stopAllActions()
            self:OverTime()
        end
    end, 1)
end

function TradingBankReceiveLayer:GetTime()
    self.OtherTradingBankProxy:reqGetReceivingCountdown(self, {}, function(success, response, code)
        if success then
            local data = cjson.decode(response)
            if data.code == 200 then
                local time = data.data
                dump(data, "获取收货倒计时")
                self.endTime = time
                self:CreateTimeRichText(time)
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
            end

            if not self.endTime then
                self._root.Image_1:setVisible(false)
                self._root.Button_3:setVisible(false)
                self._root.Button_4:setVisible(false)
            end
        end
    end)
end
function TradingBankReceiveLayer:OverTime()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
        if code == 1 then
            global.gameWorldController:OnGameLeaveWorld()

        end
    end, notcancel = true, txt = GET_STRING(600000055), btntext = { GET_STRING(800802) } })

    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankReceiveLayer_Close)
end
function TradingBankReceiveLayer:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "Button_1" then-- 个人信息
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Open_other, { position = cc.p(150, 60) })
    elseif name == "Button_2" then --返回盒子
        if global.isBoxLogin and global.L_NativeBridgeManager.GN_finishGame then
            global.L_NativeBridgeManager:GN_finishGame()
        end
    elseif name == "Button_3" then --拒绝收货
        local data = {}
        data.callback = function(res, Reason)
            if res == 1 then
                self:Refuse(Reason)
            end
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankRefuseLayer_Open, data)
    elseif name == "Button_4" then --确认收货
        -- 滑动收货
        local function sliderReceive()
            local data = {}
            data.type = 2
            data.text = GET_STRING(600000063)
            data.callback = function(res)
                if res == 1 then
                    self:Receive()
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open, data)
        end

        local data = {}
        data.type = 1
        data.btntext = GET_STRING(600000052)
        data.text = GET_STRING(600000053)
        data.callback = function(res)
            if res == 1 then
                -- self:Receive()
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close)
                PerformWithDelayGlobal(function()
                    sliderReceive()
                end, 0.1)

            end
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open, data)
    end

end
function TradingBankReceiveLayer:Refuse(Reason)--拒绝收货
    self._root.Image_1:removeAllChildren()
    self._root.Image_1:stopAllActions()
    local richText = RichTextHelp:CreateRichTextWithXML(GET_STRING(600000057), 460, 16, "#ffffff")
    if richText then
        richText:formatText()
        richText:setAnchorPoint(0.5, 0.5)
        self._root.Image_1:addChild(richText)
        richText:setPosition(self._root.Image_1:getContentSize().width / 2, self._root.Image_1:getContentSize().height / 2)
    end
    self:CaptureImg()
    self.ReceivingRolefunc = function()
        self:reqReceivingRole(2, Reason)
    end
end

function TradingBankReceiveLayer:reqReceivingRole(type, Reason) -- 1接受2拒绝
    local data = {}
    for k, v in pairs(self.m_serverPath) do
        data[k] = v
    end
    data.type = type
    if type == 2 then
        data.refuse_reason = Reason
    end
    self.OtherTradingBankProxy:reqReceivingRole(self, data, function(success, response, code)
        if success then
            local data = cjson.decode(response)
            HideLoadingBar()
            self:CreateTimeRichText()
            if data.code == 200 then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
                    if code == 1 or code == 3 then
                        global.gameWorldController:OnGameLeaveWorld()
                    end
                end, notcancel = true, txt = GET_STRING(type == 1 and 600000062 or 600000061), btntext = { GET_STRING(800802) }, onlyTime = 3 })
            elseif data.code >= 50000 and data.code <= 50020 then--token失效
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other, { noclose = true, callback = function(code)
                    if code == 1 then
                        self:reqReceivingRole(type, Reason)
                    end
                end })
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
            end
        end
    end)
end
function TradingBankReceiveLayer:Receive()--收货
    self._root.Image_1:removeAllChildren()
    self._root.Image_1:stopAllActions()
    local richText = RichTextHelp:CreateRichTextWithXML(GET_STRING(600000056), 460, 16, "#ffffff")
    if richText then
        richText:formatText()
        richText:setAnchorPoint(0.5, 0.5)
        self._root.Image_1:addChild(richText)
        richText:setPosition(self._root.Image_1:getContentSize().width / 2, self._root.Image_1:getContentSize().height / 2)
    end
    self:CaptureImg()
    self.ReceivingRolefunc = function()
        self:reqReceivingRole(1)
    end
end
function TradingBankReceiveLayer:uploadImg()
    ShowLoadingBar()
    local FileUtils = cc.FileUtils:getInstance()
    self.TradingBankCaptureLayer_coroutine1 = coroutine.create(function(val)
        self.m_serverPath = {}
        for k, v in pairs(self.m_files) do
            for i, v2 in ipairs(v) do
                if FileUtils:isFileExist(v2) then
                    local file = FileUtils:getDataFromFileEx(v2)
                    local val = {
                        position = k,
                        file = file
                    }
                    coroutine.yield(self.OtherTradingBankProxy:uploadImg(self, val, handler(self, self.ResUploadImg)))
                end
            end
        end
        self.ReceivingRolefunc()
        return
    end)
    coroutine.resume(self.TradingBankCaptureLayer_coroutine1)
end
function TradingBankReceiveLayer:ResUploadImg(success, response, code)
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            local path = data.info.url
            local position = data.info.position
            if not self.m_serverPath[position] then
                self.m_serverPath[position] = {}
            end
            table.insert(self.m_serverPath[position], path)
            if self.TradingBankCaptureLayer_coroutine1 and coroutine.status(self.TradingBankCaptureLayer_coroutine1) == "suspended" then
                coroutine.resume(self.TradingBankCaptureLayer_coroutine1)
            end
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
        end

    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000130))
    end


end
function TradingBankReceiveLayer:CaptureNode(filename, node, pos)
    local res = true
    if tolua.isnull(node) then
        return
    end
    local size = node:getContentSize()
    node:setPosition(cc.p(0, 0))
    node:setAnchorPoint(cc.p(0, 0))


    -- performWithDelay(node,function ()
    local rt = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
    rt:begin()
    node:visit()
    rt:endToLua()
    -- dump(filename,"filename")
    local FileUtils = cc.FileUtils:getInstance()
    local WritablePath = FileUtils:getWritablePath()
    local path = WritablePath .. filename
    if FileUtils:isFileExist(path) then
        FileUtils:removeFile(path)
    end
    res = rt:saveToFile(filename, cc.IMAGE_FORMAT_PNG, true)
    -- end,0.02)
    return res        
end
--截图
function TradingBankReceiveLayer:CaptureImg()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Open_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Open_other, { position = cc.p(150, 60) })

    local NT = global.NoticeTable
    local message = {
        { open = NT.Layer_TradingBank_Look_Player_LookShowPanel, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP, mediator = "TradingBankPlayerPanel", position = "equip_images", node = "_CaptureNode" },
        { open = NT.Layer_TradingBank_Look_Player_LookShowPanel, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI, mediator = "TradingBankPlayerPanel", position = "status_images", node = "_CaptureNode" },
        { open = NT.Layer_TradingBank_Look_Player_LookShowPanel, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO, mediator = "TradingBankPlayerPanel", position = "attribute_images", node = "_CaptureNode" },
        { open = NT.Layer_TradingBank_Look_Player_LookShowPanel, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL, mediator = "TradingBankPlayerPanel", position = "skill_images", node = "_CaptureNode" },
        { open = NT.Layer_TradingBank_Look_Player_LookShowPanel, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE, mediator = "TradingBankPlayerPanel", position = "title_images", node = "_CaptureNode" },
        { open = NT.Layer_TradingBank_Look_Player_LookShowPanel, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP, mediator = "TradingBankPlayerPanel", position = "clothes_images", node = "_CaptureNode" }
    }
    -----------------------------------------------------
    local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
    local data = TradingBankLookPlayerProxy:GetLookPlayerItemPosData()
    self.m_files = {}
    -------------------------------------------------------背包
    table.insert(message, { open = NT.Layer_TradingBank_Look_Player_LookShowPanel, extent = global.MMO.MAIN_PLAYER_LAYER_BAG, mediator = "TradingBankPlayerPanel", position = "bag_images", node = "_CaptureNode" })
    -------------------------------------------------------仓库
    table.insert(message, { open = NT.Layer_TradingBank_Look_Player_LookShowPanel, extent = global.MMO.MAIN_PLAYER_LAYER_STORAGE, mediator = "TradingBankPlayerPanel", position = "warehouse_images", node = "_CaptureNode" })
    -----------------------------------------------生肖
    local activeState = TradingBankLookPlayerProxy:GetBestRingsOpenState()
    if activeState then
        local ebs = { open = NT.Layer_TradingBank_Look_PlayerBestRing_Open, close = NT.Layer_TradingBank_Look_PlayerBestRing_Close, extent = {
            id = global.LayerTable.PlayerBestRingLayer,
            param = {
                lookPlayer = true
            }
        }, mediator = "TradingBankLookPlayerBestRingLayerMediator", position = "equip_images", node = "_CaptureNode" }
        table.insert(message, ebs)
    end    
    -----------------------------------------------------itemTips
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    for k, v in pairs(data) do
        local val = {}
        val.itemData = v
        val.pos = cc.p(0, 0)--equipPanel:getWorldPosition()
        val.from = ItemMoveProxy.ItemFrom.PALYER_EQUIP
        local t = { open = NT.Layer_ItemTips_Open, close = NT.Layer_ItemTips_Close, extent = val, mediator = "ItemTipsMediator", node = "_CaptureNode", position = "equip_images" }
        table.insert(message, t)
    end
    -----------------------------------------------------hero
    if TradingBankLookPlayerProxy:haveData_Hero() then
        local heromessage = {
            { open = NT.Layer_TradingBank_Look_Player_LookShowPanel_Hero, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP, mediator = "TradingBankPlayerPanel",    position = "hero_equip_images", node = "_CaptureNode" },
            { open = NT.Layer_TradingBank_Look_Player_LookShowPanel_Hero, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI, mediator = "TradingBankPlayerPanel", position = "hero_status_images", node = "_CaptureNode" },
            { open = NT.Layer_TradingBank_Look_Player_LookShowPanel_Hero, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO, mediator = "TradingBankPlayerPanel", position = "hero_attribute_images", node = "_CaptureNode" },
            { open = NT.Layer_TradingBank_Look_Player_LookShowPanel_Hero, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL, mediator = "TradingBankPlayerPanel",    position = "hero_skill_images", node = "_CaptureNode" },
            { open = NT.Layer_TradingBank_Look_Player_LookShowPanel_Hero, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE, mediator = "TradingBankPlayerPanel",    position = "hero_title_images", node = "_CaptureNode" },
            { open = NT.Layer_TradingBank_Look_Player_LookShowPanel_Hero, extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP, mediator = "TradingBankPlayerPanel", position = "hero_clothes_images", node = "_CaptureNode" },
            { open = NT.Layer_TradingBank_Look_Player_LookShowPanel_Hero, extent = global.MMO.MAIN_PLAYER_LAYER_BAG, mediator = "TradingBankPlayerPanel", position = "hero_bag_images", node = "_CaptureNode" }
        }
        for i, v in ipairs(heromessage) do
            table.insert(message, v)
        end

        -----------------------------------------------hero生肖
        activeState = TradingBankLookPlayerProxy:GetBestRingsOpenState_Hero()
        if activeState then
            local ebs = { open = NT.Layer_TradingBank_Look_PlayerBestRing_Open_Hero, close = NT.Layer_TradingBank_Look_PlayerBestRing_Close_Hero, extent = {
                id = global.LayerTable.PlayerBestRingLayer,
                param = {
                    lookPlayer = true
                }
            }, mediator = "TradingBankLookHeroBestRingLayerMediator", position = "hero_equip_images", node = "_CaptureNode" }
            table.insert(message, ebs)
        end
        -----------------------------------------------------hero   itemTips
        local herodata = TradingBankLookPlayerProxy:GetLookPlayerItemPosData_Hero()
        for k, v in pairs(herodata) do
            local val = {}
            val.itemData = v
            val.pos = cc.p(0, 0)--equipPanel:getWorldPosition()
            val.from = ItemMoveProxy.ItemFrom.HERO_EQUIP

            local t = { open = NT.Layer_ItemTips_Open, close = NT.Layer_ItemTips_Close, extent = val, mediator = "ItemTipsMediator", node = "_CaptureNode", position = "hero_equip_images" }
            table.insert(message, t)
        end
    end
    -----------------------------------------------------------------
    self.m_max = #message
    -------------------------------------------------------
    local index = 1
    local FileUtils = cc.FileUtils:getInstance()
    local WritablePath = FileUtils:getWritablePath()
    local textureCache = global.Director:getTextureCache()
    local repIndex = 0
    local repFunc
    repFunc = function()
        repIndex = repIndex + 1
        if repIndex > #message then --end
            self.m_max = index - 1
            self.m_finish = true
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Close_other)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Close_other)
            self:uploadImg()
            return
        end
        local val = message[repIndex]
        local position = val.position or "equip_images"
        local path = WritablePath .. position .. repIndex .. ".png"
        if FileUtils:isFileExist(path) then
            FileUtils:removeFile(path)
        end
        if textureCache:getTextureForKey(path) then
            textureCache:removeTextureForKey(path)
        end
        global.Facade:sendNotification(val.open, val.extent)
        local mediator = global.Facade:retrieveMediator(val.mediator)
        if mediator._layer then
            local node = val.node and mediator._layer[val.node] or mediator._layer._root
            local time = 0.5
            local CloseFunc = function()
                global.Facade:sendNotification(val.close)
                repFunc()
            end
            performWithDelay(self._root.Button_4, function()
                if val.mediator == "BagLayerMediator" then--背包
                    if node then
                        local size2 = node:getContentSize()
                        node:setContentSize(size2.width + 20, size2.height + 60)
                        for i, v in ipairs(node:getChildren()) do
                            v:setPositionY(v:getPositionY() + 60)
                        end
                    end            
                end
                --截图
                if node and self:CaptureNode(position .. repIndex .. ".png", node) then
                    if not self.m_files[position] then
                        self.m_files[position] = {}
                    end
                    table.insert(self.m_files[position], path)
                    performWithDelay(self._root.Button_4, function()
                        --立即读取防作弊
                        table.insert(self.m_files[position], path)
                        index = index + 1
                        CloseFunc()
                    end, 0.1)
                else
                    CloseFunc()
                end
            end, time)
        end
    end
    repFunc()
end
function TradingBankReceiveLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end
return TradingBankReceiveLayer