local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankCaptureLayer = class("TradingBankCaptureLayer", BaseLayer)

local cjson = require("cjson")

function TradingBankCaptureLayer:ctor()
    TradingBankCaptureLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankCaptureLayer.create(...)
    local ui = TradingBankCaptureLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankCaptureLayer:Init(data)
    GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_capture")
    self._root = ui_delegate(self)
    self:InitAdapt()
    self:InitUI(data)
    self.m_files = {}
    self.m_serverPath = {}
    self.m_progress = 0
    self.m_data = data
    return true
end

function TradingBankCaptureLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")

    GUI:setContentSize(self._root.Panel_2, winSizeW, winSizeH)
    GUI:setPosition(self._root.Panel_2, winSizeW / 2, winSizeH / 2)
    GUI:setPosition(self._root.Image_bg, winSizeW / 2, winSizeH / 2)

    GUI:setContentSize(self._root.Panel_1_3, winSizeW, winSizeH)
    GUI:setPosition(self._root.Panel_3, winSizeW / 2, winSizeH / 2)

end

function TradingBankCaptureLayer:InitUI(data)
    self._root.Button_3:addTouchEventListener(handler(self, self.onButtonClick))
    for i = 1, 3 do
        local node = self._root["Image_show" .. i]
        node:setTag(i)
        node:addTouchEventListener(handler(self, self.onImageClic2))
        self:setPanel(i, false)
    end
    for i = 1, 5 do
        local node = self._root["Button_" .. i]
        node:addTouchEventListener(handler(self, self.onButtonClick))
    end

    local contentSize = self._root.Image_rotate:getContentSize()
    local progresssp = cc.Sprite:create(global.MMO.PATH_RES_PRIVATE .. "trading_bank/progress.png")
    self._progress = cc.ProgressTimer:create(progresssp)
    self._progress:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
    self._progress:setMidpoint(cc.p(0.48, 0.5))
    self._progress:setScaleX(-1)
    self._progress:setPercentage(0)
    self._progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self._progress:addTo(self._root.Image_rotate)
    self._root.Text_pp:setString("0%")
    self._root.Image_cp:setVisible(false)
    self:setPanel(1, true)
end

--设置显示的视图
function TradingBankCaptureLayer:setPanel(idx, isshow)
    local node = self._root["Panel_1_" .. idx]
    node:setVisible(isshow)
    if idx < 3 and isshow then
        self.m_selIndex = idx
        self._root.Button_2:setTitleText(GET_STRING(600000127 + idx))
    end
end
--
function TradingBankCaptureLayer:HeroisCD()
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    if HeroPropertyProxy:IsHeroOpen() then
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        if PlayerPropertyProxy:getIsMakeHero() then
            if not HeroPropertyProxy:HeroIsLogin() and HeroPropertyProxy:getCD() > 0 then
                return true
            end
        end
    end
    return false
end

--检测上架条件
function TradingBankCaptureLayer:PublishAccountCheck(val, func)
    self.OtherTradingBankProxy:publishAccountCheck(self, val, function(code, data, msg)
        if code == 200 then
            func()
        elseif code == 30048 then--有在售货币
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, {
                callback = function(code)
                    if code == 1 then
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankFrame_Open_other, { id = global.LayerTable.TradingBankGoodsLayer })
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureLayer_Close_other)
                    end
                end,
                notcancel = true, txt = GET_STRING(600000180), btntext = { GET_STRING(600000182), GET_STRING(600000139) }
            })
        elseif code == 30307 then --等级 充值 不满足条件
            local params = {}
            params.type = 1
            params.btntext = GET_STRING(600000476)
            params.text = msg or ""
            params.titleImg = self._tipsImgPath
            params.callback = function(res)
                if res == 1 then
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
        elseif code == 30315 then --寄售锁失效重新验证phone
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other, { callback = function(code)
                if code == 1 then--
                    self:PublishAccountCheck(val, func)
                end
            end, checkPhone = true, openLock = true })
        else
            ShowSystemTips(msg)
        end
    end)
end

function TradingBankCaptureLayer:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "Button_2" then--下一步
        if self.m_selIndex == 1 then --截图
            if self:HeroisCD() then
                ShowSystemTips(GET_STRING(600000265))
                return
            end
            self:setPanel(1, false)
            self:setPanel(2, true)
            self:CaptureImg()
        elseif self.m_selIndex == 2 then--上传图片
            if self.m_data.minPriceTips then 
                ShowSystemTips(self.m_data.minPriceTips)
                return 
            end
            --检测上架条件
            self:PublishAccountCheck(self.m_data,function()
                if self.m_finish then
                    self:uploadImg()
                else
                    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000159))
                end
            end)
        end
    elseif name == "Button_1" then--上一步
        if self.m_selIndex == 1 then
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureLayer_Close_other)
        elseif self.m_selIndex == 2 then
            self:setPanel(1, true)
            self:setPanel(2, false)
        end
    elseif name == "Button_4" then
        if self.m_finish then
            if self:HeroisCD() then
                ShowSystemTips(GET_STRING(600000265))
                return
            end
            self:CaptureImg()
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000159))
        end
    elseif name == "Button_3" then--提示
        self.OtherTradingBankProxy:reqHelpText(self, {}, function(help)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
                if code == 3 or code == 1 or code == 0 then
                    dump("提示退出")
                end
            end, title = help.title, notcancel = true, canmove = true, txt = help.data, btntext = { GET_STRING(600000139) } })
        end)


    elseif name == "Button_5" then-- 关闭
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
            if code == 2 then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureLayer_Close_other)
            end
        end, notcancel = true, txt = GET_STRING(600000162) })

    end

end

function TradingBankCaptureLayer:onImageClic2(sender, type)
    if type ~= 2 then
        return
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankLookTexture_Open_other, sender)
end
-------------------

-------------------
function TradingBankCaptureLayer:uploadImg()
    self:setPanel(3, true)
    self:setProgress(0)
    local FileUtils = cc.FileUtils:getInstance()
    self.m_uploadImgIndex = 1
    self.m_serverPath = {}
    self.m_uploadImageList = {}
    for position, vec in pairs(self.m_files) do
        for i, path in ipairs(vec) do
            local val = {
                position = position,
                path = path
            }
            table.insert(self.m_uploadImageList, val)
        end
    end
    self.OtherTradingBankProxy:uploadImg2(self, self.m_uploadImageList[self.m_uploadImgIndex] or {}, handler(self, self.ResUploadImg))
end
function TradingBankCaptureLayer:ResUploadImg(code, data, msg)
    local curPositionData = self.m_uploadImageList[self.m_uploadImgIndex] or {}
    local position = curPositionData.position
    if code == 200 then
        if data then
            local path = data
            if not self.m_serverPath[position] then
                self.m_serverPath[position] = {}
            end
            table.insert(self.m_serverPath[position], path)
            --下一张
            local maxLen = #self.m_uploadImageList
            local max = maxLen == 0 and 1 or maxLen
            local progress = math.ceil(self.m_uploadImgIndex / max * 90)
            self:setProgress(progress)
            if self.m_uploadImgIndex == maxLen then
                self:onSellRole()
            else
                self.m_uploadImgIndex = self.m_uploadImgIndex + 1
                self.OtherTradingBankProxy:uploadImg2(self, self.m_uploadImageList[self.m_uploadImgIndex] or {}, handler(self, self.ResUploadImg))
            end
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, msg or "")
            self:setPanel(3, false)
        end

    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, msg or "")
        self:setPanel(3, false)
    end
end
function TradingBankCaptureLayer:onSellRole()
    for k, v in pairs(self.m_files) do
        if not self.m_serverPath[k] then--有图片上传失败
            ShowSystemTips(GET_STRING(600000194))
            self:setPanel(3, false)
            return
        end
    end
    local t = {}
    for k, v in pairs(self.m_data) do
        t[k] = v
    end
    for k, v in pairs(self.m_serverPath) do
        t[k] = v
    end
    self.OtherTradingBankProxy:sellRole(self, t, handler(self, self.ResSellRole))
end
function TradingBankCaptureLayer:ResSellRole(code, data, msg)
    dump({ code, data, msg }, "ResSellRole___")
    if code == 200 then 
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingRoleSell,
                    {
                        properities = {
                            goods_price = self.m_data.price,
                            result = "成功",
                            
                        }
                    })
    else
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingRoleSell,
                    {
                        properities = {
                            goods_price = self.m_data.price,
                            result = "失败",
                        }
                    })
    end
    if code == 200 then--寄售成功
        --网络不好的时候可能已经被服务器提下线了   就客户端自己弹了
        local outtime = self.OtherTradingBankProxy:getOutTime()
        local tipsStr = string.format(GET_STRING(600000457), outtime, "%s")
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(res)
            if res == 1 then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Close_other)
                global.gameWorldController:OnGameLeaveWorld()
            end
        end, notcancel = true, exitTime = 5, txt = tipsStr, btntext = { GET_STRING(800802) } })
    elseif code == 30105 then --xx分钟之内有取回操作
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function()
        end, notcancel = true, txt = data.msg or GET_STRING(600000051), btntext = { GET_STRING(600000139) } })

    elseif code == 30315 then --寄售锁失效重新验证phone
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other, { callback = function(code)
            if code == 1 then--
                self:onSellRole()
            end
        end, checkPhone = true , openLock = true})
    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, msg or "")
    end
    self.m_progress = 0
    self:setProgress(100)
    performWithDelay(self._root.Text_pp, function()
        self:setPanel(3, false)
    end, 0.1)
end
function TradingBankCaptureLayer:setProgress(val)
    dump(val, "setProgress______")
    self._root.Text_pp:setString(val .. "%")
    self._progress:setPercentage(val)
end

function TradingBankCaptureLayer:CaptureNode(filename, node, pos)
    global.RenderTextureManager:AddDrawFuncOnce({func = function ()
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
    end})
    return true        
end

--截图
function TradingBankCaptureLayer:CaptureImg()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Open_other)
    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    NPCStorageProxy:RequestStorageData()--请求仓库数据
    local NT = global.NoticeTable

    local message = {
        { open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP }, mediator = "PlayerFrameMediator", position = "equip" },
        { open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI }, mediator = "PlayerFrameMediator", position = "status" },
        { open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO }, mediator = "PlayerFrameMediator", position = "attribute" },
        { open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL }, mediator = "PlayerFrameMediator", position = "skill" },
        { open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE }, mediator = "PlayerFrameMediator", position = "title" },
        { open = NT.Layer_Player_Open, close = NT.Layer_Player_Close, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP }, mediator = "PlayerFrameMediator", position = "clothes" },
    -- {open = NT.Layer_Bag_Open, close = NT.Layer_Bag_Close,  extent = {pos = {x = 0, y = 0}},mediator = "BagLayerMediator",node = "panel",position = "bag"},
    --{ open = NT.Layer_NPC_Storage_Open, close = NT.Layer_NPC_Storage_Close, extent = { noShowBag = true }, mediator = "NPCStorageMediator", position = "warehouse" },

    }
    -----------------------------------------------------
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local data = EquipProxy:GetEquipData()
    self.m_files = {}
    self.m_finish = false
    self._root.Panel_p:removeAllChildren()
    self._root.Panel_p:stopAllActions()
    -------------------------------------------------------背包多页
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local bagmax = BagProxy:GetMaxBag()
    local pagenum = math.ceil(bagmax / global.MMO.MAX_ITEM_NUMBER)
    for i = 1, pagenum do
        table.insert(message,
        { open = NT.Layer_Bag_Open, close = NT.Layer_Bag_Close, extent = { pos = { x = 0, y = 0 }, bag_page = i }, mediator = "BagLayerMediator", node = "panel", position = "bag" })
    end
    -------------------------------------------------------仓库
    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    local storemax = NPCStorageProxy:GetMaxPage()
    for i = 1, storemax do
        local ebs = { open = NT.Layer_NPC_Storage_Open, close = NT.Layer_NPC_Storage_Close, extent = { noShowBag = true, initPage = i }, mediator = "NPCStorageMediator", position = "warehouse" }
        table.insert(message, ebs)
    end

    -----------------------------------------------生肖
    local activeState = EquipProxy:GetBestRingsOpenState()
    if activeState then
        -- global.Facade:sendNotification(global.NoticeTable.Layer_PlayerBestRing_Open,{param={lookPlayer = self._playerLook}})
        local ebs = { open = NT.Layer_PlayerBestRing_Open, close = NT.Layer_PlayerBestRing_Close, extent = {
            id = global.LayerTable.PlayerBestRingLayer,
            param = {
                lookPlayer = false
            }
        }, mediator = "PlayerBestRingLayerMediator", position = "equip" }
        table.insert(message, ebs)
    end


    -----------------------------------------------------itemTips
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    for k, v in pairs(data) do
        local val = {}
        val.itemData = v
        val.pos = cc.p(0, 0)--equipPanel:getWorldPosition()
        val.from = ItemMoveProxy.ItemFrom.PALYER_EQUIP

        local t = { open = NT.Layer_ItemTips_Open, close = NT.Layer_ItemTips_Close, extent = val, mediator = "ItemTipsMediator", node = "_CaptureNode", position = "equip" }
        table.insert(message, t)
    end
    -----------------------------------------------------hero
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    if HeroPropertyProxy:IsHeroOpen() then
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        if PlayerPropertyProxy:getIsMakeHero() then
            if not HeroPropertyProxy:HeroIsLogin() then
                HeroPropertyProxy:RequestHeroInOrOut()
            end
            local heromessage = {
                { open = NT.Layer_Player_Open_Hero, close = NT.Layer_Player_Close_Hero, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP }, mediator = "HeroFrameMediator", position = "hero_equip" },
                { open = NT.Layer_Player_Open_Hero, close = NT.Layer_Player_Close_Hero, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI }, mediator = "HeroFrameMediator", position = "hero_status" },
                { open = NT.Layer_Player_Open_Hero, close = NT.Layer_Player_Close_Hero, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO }, mediator = "HeroFrameMediator", position = "hero_attribute" },
                { open = NT.Layer_Player_Open_Hero, close = NT.Layer_Player_Close_Hero, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL }, mediator = "HeroFrameMediator", position = "hero_skill" },
                { open = NT.Layer_Player_Open_Hero, close = NT.Layer_Player_Close_Hero, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE }, mediator = "HeroFrameMediator", position = "hero_title" },
                { open = NT.Layer_Player_Open_Hero, close = NT.Layer_Player_Close_Hero, extent = { extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP }, mediator = "HeroFrameMediator", position = "hero_clothes" },
                { open = NT.Layer_HeroBag_Open, close = NT.Layer_HeroBag_Close, extent = { pos = { x = 0, y = 0 } }, mediator = "HeroBagLayerMediator", node = "panel", position = "hero_bag" },
            }
            for i, v in ipairs(heromessage) do
                table.insert(message, v)
            end
        end
    end
    -----------------------------------------------hero生肖
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    local herodata = HeroEquipProxy:GetEquipData()
    local activeState = HeroEquipProxy:GetBestRingsOpenState()
    if activeState then
        -- global.Facade:sendNotification(global.NoticeTable.Layer_PlayerBestRing_Open,{param={lookPlayer = self._playerLook}})
        local ebs = { open = NT.Layer_PlayerBestRing_Open_Hero, close = NT.Layer_PlayerBestRing_Close_Hero, extent = {
            id = global.LayerTable.PlayerBestRingLayer,
            param = {
                lookPlayer = false
            }
        }, mediator = "HeroBestRingLayerMediator", position = "hero_equip" }
        table.insert(message, ebs)
    end


    -----------------------------------------------------hero   itemTips
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    for k, v in pairs(herodata) do
        local val = {}
        val.itemData = v
        val.pos = cc.p(0, 0)--equipPanel:getWorldPosition()
        val.from = ItemMoveProxy.ItemFrom.HERO_EQUIP

        local t = { open = NT.Layer_ItemTips_Open, close = NT.Layer_ItemTips_Close, extent = val, mediator = "ItemTipsMediator", node = "_CaptureNode", position = "hero_equip" }
        table.insert(message, t)
    end
    --------------------------------------------------单面板特殊处理
    if HeroPropertyProxy:getIsMergePanelMode() then
        for i, v in ipairs(message) do
            if v.mediator == "BagLayerMediator" or v.mediator == "HeroBagLayerMediator" then
                v.mediator = "MergeBagLayerMediator"
            elseif v.mediator == "PlayerFrameMediator" or v.mediator == "HeroFrameMediator" then
                v.mediator = "MergePlayerLayerMediator"
                v.node = "_CaptureNode"
            end
        end
    end
    self.m_max = #message
    local size = self._root.Image_cp:getContentSize()
    local yy = math.ceil(self.m_max / 5)
    local H = (yy + 1) * 18.7 + yy * size.height
    self._root.Panel_p:setInnerContainerSize(cc.size(680, H))
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
            self.m_finish = true
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close_other)
            return
        end
        local val = message[repIndex]
        local position = val.position or "equip"
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
            performWithDelay(self._root.Panel_p, function()
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
                    performWithDelay(self._root.Panel_p, function()
                        if FileUtils:isFileExist(path) then
                        else
                            CloseFunc()
                            return
                        end
                        local Image_cp = self._root.Image_cp:cloneEx()
                        Image_cp:loadTexture(path)
                        Image_cp.path = path
                        Image_cp:setVisible(true)
                        Image_cp:addTo(self._root.Panel_p)
                        local x = (index - 1) % 5 + 1
                        local y = math.ceil(index / 5)
                        Image_cp:setPosition(18.7 * x + (x - 0.5) * size.width, H - (18.7 * y + (y - 0.5) * size.height))
                        Image_cp:addTouchEventListener(handler(self, self.onImageClic2))
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

function TradingBankCaptureLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end

return TradingBankCaptureLayer