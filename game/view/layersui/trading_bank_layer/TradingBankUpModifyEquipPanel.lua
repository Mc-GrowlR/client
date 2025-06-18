local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankUpModifyEquipPanel = class("TradingBankUpModifyEquipPanel", BaseLayer)
local cjson = require("cjson")
local QuickCell = requireUtil("QuickCell")
local RichTextHelp = require("util/RichTextHelp")

function TradingBankUpModifyEquipPanel:ctor()
    TradingBankUpModifyEquipPanel.super.ctor(self)
    self._tradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
end

function TradingBankUpModifyEquipPanel.create(...)
    local ui = TradingBankUpModifyEquipPanel.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankUpModifyEquipPanel:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_up_modify_equip_panel")
    self._root = ui_delegate(self)

    self._data = data
    self:InitUI()
    self:ReqSellConfig()

    return true
end

function TradingBankUpModifyEquipPanel:InitUI()
    self._root.Button_next:addClickEventListener(function()
        local price = self._root.TextField_price:getString()

        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingSellEquipUpClick)

        if not self:IsGoodNumber(price) then--价格
            ShowSystemTips(GET_STRING(600000116))
            return
        end

        if string.find(price, "%.") then--价格必须为整数
            ShowSystemTips(GET_STRING(600000196))
            return
        end
        price = tonumber(price)
        if price < self._equip_min_price then
            ShowSystemTips(GET_STRING(600000615))
            return
        end
        local target_rolename = self._root.TextField_target_equip:getString()
        if string.len(target_rolename) == 0 then
            self:CaptureImg()
        else 
            self:GetRoleInfo(target_rolename, handler(self, self.CaptureImg))
        end
    end)

    self._root.Button_close:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankUpModifyEquipPanel_Close)
    end)

    self._root.Button_cancel:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankUpModifyEquipPanel_Close)

        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingSellEquipUpCancelClick)

    end)

    self._root.TextField_price:onEditHandler(function(event)
        if event.name == "changed" then
            local s = event.target:getString()
            s = string.gsub(s, "%s", "")
            s = string.gsub(s, "[^%d]", "")
            event.target:setString(s)
        end
    end)
    self._tradingBankProxy:cancelEmpty(self._root.TextField_target_equip)
    -------买家是否可以还价
    self:InitBargain(self._root.Panel_bargain_equip)
    -------
    self._root.Text_min_price:setVisible(false)
    self._root.Text_sxf:setVisible(false)
    self._root.Text_svip_desc:setVisible(false)

    local itemData = self._data.itemData
    local goodsItem = GoodsItem:create({ index = itemData.Index, itemData = itemData, look = true })
    dump(itemData,"itemData")
    self._root.Image_equipBg:addChild(goodsItem)
    local size = self._root.Image_equipBg:getContentSize()
    goodsItem:setPosition(size.width / 2, size.height / 2)

    local color = (itemData.Color and itemData.Color > 0) and itemData.Color or 255
    local name = itemData.Name or ""
    -- 道具名字
    self._root.Text_equip_name:setString(name)
    self._root.Text_equip_name:setTextColor(SL:GetColorByStyleId(color))
end

function TradingBankUpModifyEquipPanel:GetRoleInfo(name, func)
    self._tradingBankProxy:reqRoleInfo(self, { role_name = name }, function(success, response, code)
        dump({ success, response, code }, "getRoleInfo___")
        if success then
            local resData = cjson.decode(response)
            if resData.code == 200 then
                func()
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, { callback = function(code)
                end, notcancel = true, txt = GET_STRING(600000175), btntext = { GET_STRING(600000139) } })
            end
        end
    end)
end

function TradingBankUpModifyEquipPanel:InitBargain(node)
    node._isSelect = true
    local CheckBox_true = node:getChildByName("CheckBox_true")
    local CheckBox_false = node:getChildByName("CheckBox_false")
    CheckBox_true:setSelected(true)
    CheckBox_true:addEventListener(function()
        node._isSelect = true
        local select = CheckBox_true:isSelected()
        if select then
            CheckBox_false:setSelected(false)
        end
    end)
    CheckBox_false:addEventListener(function()
        node._isSelect = false
        local select = CheckBox_false:isSelected()
        if select then
            CheckBox_true:setSelected(false)
        end
    end)
end

function TradingBankUpModifyEquipPanel:ReqSellConfig()
    self._tradingBankProxy:reqSellConfig(self, {}, function(success, response, code)
        dump({ success, response, code }, "ReqSellRoleConfig___")
        if success then
            local resData = cjson.decode(response)
            if resData.code == 200 then
                resData = resData.data
                self._service_percent = resData.service_percent --手续费
                self._equip_min_price = tonumber(resData.equip_min_price) or 0 --最低价格
                self:InitChargeAndMinPrice()
            elseif resData.code >= 50000 and resData.code <= 50020 then--token失效
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { noclose = 1,
                callback = function(code)
                    if code == 1 then
                        self:ReqSellConfig()
                    end
                end
                })
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, resData.msg or "")
            end
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000137))
        end
    end)
end

--初始化手续费 和 最低价格
function TradingBankUpModifyEquipPanel:InitChargeAndMinPrice()
    self._root.Text_min_price:setVisible(true)
    local str = string.format(GET_STRING(600000610), self._equip_min_price)
    self._root.Text_min_price:setString(str)
    local sxf = string.format(GET_STRING(600000189), self._service_percent)
    self._root.Text_sxf:setString(sxf)
    self._root.Text_sxf:setVisible(true)
    self:OnRefreshSVIPTitle()--请求svip
end

function TradingBankUpModifyEquipPanel:CaptureNode(fileName, node)
    local res = true
    if tolua.isnull(node) then
        return
    end
    local size = global.Director:getWinSize()
    local size2 = node:getContentSize()
    local anchorPos = cc.p(node:getAnchorPoint())
    local pos = cc.p(node:getPosition())
    local nodeSize = node:getContentSize()
    local offsetx = pos.x + anchorPos.x * nodeSize.width
    local offsety = pos.y - anchorPos.y * nodeSize.height
    local maxH = math.max(size2.height,size.height)
    
    local rt = cc.RenderTexture:create(size.width, maxH, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
    rt:begin()
    local defaultCamera =  cc.Camera:getDefaultCamera()
    defaultCamera:initOrthographic(size.width, maxH,-1024,1024)
    defaultCamera:getViewProjectionMatrix()
    node:visit()
    defaultCamera:initOrthographic(size.width, size.height,-1024,1024)
    rt:endToLua()
    
    local rt2 = cc.RenderTexture:create(size2.width, size2.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
    local sp = rt:getSprite()
    sp:setAnchorPoint(0, 0)
    sp:setPosition(-offsetx, -offsety)
    rt2:begin()
    sp:visit()
    rt2:endToLua()
    res = rt2:saveToFile(fileName, cc.IMAGE_FORMAT_PNG, true)
    return res        
end

function TradingBankUpModifyEquipPanel:CaptureImg()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Open, { TipsStr = GET_STRING(600000627) })
    self._captureImag = {}
    local fileName = "trading_bank_equip_logo.png"
    local FileUtils = cc.FileUtils:getInstance()
    local WritablePath = FileUtils:getWritablePath()
    local path = WritablePath .. fileName
    if FileUtils:isFileExist(path) then
        FileUtils:removeFile(path)
    end
    if self:CaptureNode(fileName, self._root.Image_equipBg) then
        self._captureImag["equip_logo"] = path
    end
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local itemData = self._data.itemData
    local data = {
        itemData = itemData,
        pos = self._root.Image_equipBg:getWorldPosition(),
        from = ItemMoveProxy.ItemFrom.Bag
    }

    local getTipsNode = function()
        global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, data)
        local mediator = global.Facade:retrieveMediator("ItemTipsMediator")
        if mediator._layer then
            local node = mediator._layer._CaptureNode or mediator._layer._root
            local ui = ui_delegate(node)
            local scrollView = ui.scrollView
            local InnerContainerSize = scrollView:getInnerContainerSize()
            local scrollViewSize = scrollView:getContentSize()
            if InnerContainerSize.height > scrollViewSize.height then
                scrollView:setInnerContainerSize(InnerContainerSize)
                scrollView:setContentSize(InnerContainerSize)
                local p = scrollView:getParent()
                local pSize =  p:getContentSize()
                p:setContentSize(pSize.width, pSize.height + InnerContainerSize.height - scrollViewSize.height)
                local y = p:getPositionY()
                p:setPositionY(y+ InnerContainerSize.height - scrollViewSize.height)
                node = p
                if ui.bottom_arrow then 
                    ui.bottom_arrow:setVisible(false)
                end
                if ui.top_arrow then 
                    ui.top_arrow:setVisible(false)
                end
            end
            return node
        end
        return nil
    end
    fileName = "trading_bank_equip_detail.png"
    self._captureImag["equip_detail_images"] = {}
    local node = getTipsNode()

    if node then 
        path = WritablePath .. fileName
        if FileUtils:isFileExist(path) then
            FileUtils:removeFile(path)
        end
        if self:CaptureNode(fileName, node) then
            table.insert(self._captureImag["equip_detail_images"], path)
        end
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)

    performWithDelay(self._root.Image_equipBg, function()
        self:UpLoadImg()
    end, 0.1)

end
function TradingBankUpModifyEquipPanel:UpLoadImg()
    self._uploadImageList = {}
    local logoPath = self._captureImag["equip_logo"]
    local detailTabel = self._captureImag["equip_detail_images"]
    local FileUtils = cc.FileUtils:getInstance()
    if not logoPath then
        ShowSystemTips(GET_STRING(600000612))
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)
        return
    else
        if FileUtils:isFileExist(logoPath) then
            local fileData = FileUtils:getDataFromFileEx(logoPath)
            table.insert(self._uploadImageList, { position = "equip_logo", file = fileData })
        end

    end

    if not detailTabel or #detailTabel == 0 then
        ShowSystemTips(GET_STRING(600000612))
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)
        return
    else
        for i, path in ipairs(detailTabel) do
            dump(path, "path___")
            if FileUtils:isFileExist(path) then
                local fileData = FileUtils:getDataFromFileEx(path)
                table.insert(self._uploadImageList, { position = "equip_detail_images", file = fileData })
            end
        end
    end
    if #self._uploadImageList == 0 then
        ShowSystemTips(GET_STRING(600000612))
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)
        return
    end
    self._serverPath = {}
    self._uploadImgIndex = 1
    self._tradingBankProxy:uploadImg(self, self._uploadImageList[self._uploadImgIndex] or {}, handler(self, self.ResUploadImg))
end

function TradingBankUpModifyEquipPanel:ResUploadImg(success, response, code)
    local curPositionData = self._uploadImageList[self._uploadImgIndex] or {}
    local position = curPositionData.position
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            local path = data.info.url
            local position = data.info.position
            if not self._serverPath[position] then
                self._serverPath[position] = {}
            end
            table.insert(self._serverPath[position], path)

            local maxLen = #self._uploadImageList
            if self._uploadImgIndex == maxLen then
                self:SellEquip()
            else
                self._uploadImgIndex = self._uploadImgIndex + 1
                self._tradingBankProxy:uploadImg(self, self._uploadImageList[self._uploadImgIndex] or {}, handler(self, self.ResUploadImg))
            end
        else
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)
            ShowSystemTips(data.msg or "")
        end
    else
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)
        ShowSystemTips(GET_STRING(600000613))
    end
end

--上架装备
function TradingBankUpModifyEquipPanel:SellEquip()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)
    local logoPath = self._serverPath["equip_logo"] and self._serverPath["equip_logo"][1]
    local detailServer = self._serverPath["equip_detail_images"]
    local detailLocal = self._captureImag["equip_detail_images"]
    if not logoPath then
        ShowSystemTips(GET_STRING(600000613))
        return
    end

    if not detailServer or #detailServer ~= #detailLocal then
        ShowSystemTips(GET_STRING(600000612))
        return
    end

    local price = self._root.TextField_price:getString()
    local bargain_switch = self._root.Panel_bargain_equip._isSelect and 1 or 0
    local target_rolename = self._root.TextField_target_equip:getString()
    if string.len(target_rolename) == 0 then
        target_rolename = nil
    end
    local itemData = self._data.itemData
    self._sellParams = {
        title = itemData.Name or "",
        equip_id = itemData.Index,
        equip_model = itemData.StdMode,
        equip_index = itemData.MakeIndex,
        equip_logo = logoPath,
        equip_detail_images = detailServer,
        bargain_switch = bargain_switch,
        target_rolename = target_rolename,
        price = price,
        equip_num = itemData.OverLap
    }
    dump(self._sellParams, "self._sellParams_____")
    self._tradingBankProxy:ReqCheckEquipIsCanSell(itemData.MakeIndex)
end

function TradingBankUpModifyEquipPanel:CheckSuccess()
    dump("CheckSuccess___")
    self._tradingBankProxy:sellEquip(self, self._sellParams, function(success, response, code)
        if success then
            local data = cjson.decode(response)
            if data.code == 200 then

                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankSellLayer_RefGoodList)
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankUpModifyEquipPanel_Close)

            else
                ShowSystemTips(data.msg or "")
            end
        else
            ShowSystemTips(GET_STRING(600000614))
        end
    end)
end


function TradingBankUpModifyEquipPanel:IsGoodNumber(str)
    if not (string.len(str) > 0) then
        return false
    end
    if not self:IsNumber(str) then
        return false
    end
    if not tonumber(str) then
        return false
    end
    if tonumber(str) <= 0 then
        return false
    end
    return true
end
--是否纯数字
function TradingBankUpModifyEquipPanel:IsNumber(str)
    if string.find(str, "[^%d%%.]") then
        return false
    end
    return true
end


function TradingBankUpModifyEquipPanel:ExitLayer()
    self._tradingBankProxy:removeLayer(self)
end

function TradingBankUpModifyEquipPanel:OnRefreshSVIPTitle(data)
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    if not data then
        if proxy:IsShowSVIP() then
            proxy:requestSVIPLevel()
        end
        return
    end

    if data.isSvipLevel then
        local svipData = data.data
        local svipLevel = tonumber(svipData.svipLevel) or 0
        if svipLevel >= 1 and svipData.state == 1 then
            local desc = string.format(GET_STRING(600000611), svipLevel)
            self._root.Text_svip_desc:setString(desc)
            self._root.Text_svip_desc:setVisible(true)
        end
    end
end

return TradingBankUpModifyEquipPanel