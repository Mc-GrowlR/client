local TradingBankCaptureOtherCommand = class('TradingBankCaptureOtherCommand', framework.SimpleCommand)

function TradingBankCaptureOtherCommand:ctor()
end

function TradingBankCaptureOtherCommand:execute(notification)
    local type = nil
    self.tableDataUrl = {}
    local databody = notification:getBody()
    if databody then
        type = databody.type
        local otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
        self.tableDataUrl = otherTradingBankProxy:getPublishTableData()
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Open)
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
    local data = {}
    data = EquipProxy:GetEquipData()

    self.m_files = {}
    -------------------------------------------------------背包多页
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local bagmax = BagProxy:GetMaxBag()
    local pagenum = math.ceil(bagmax / global.MMO.MAX_ITEM_NUMBER)
    for i = 1, pagenum do
        table.insert(message,
        { open = NT.Layer_Bag_Open, close = NT.Layer_Bag_Close, extent = {pos = { x = 0, y = 0 }, bag_page = i }, mediator = "BagLayerMediator", node = "panel", position = "bag" })
    end
    -------------------------------------------------------仓库
    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    local storemax = NPCStorageProxy:GetMaxPage()
    for i = 1,storemax do
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
    --筛选寄售装备
    -- if type == 1 then
    --     local bagProxy      = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    --     local quickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    --     local quickData     = quickUseProxy:GetQuickUseData()
    --     local bagData       = bagProxy:GetBagData()
    --     local itemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)

    --     local articleType       = itemConfigProxy:GetArticleType()
    --     local checkArticleType  = {[articleType.TYPE_TRADE_AUCTIONA] = true}
    --     for _, vItem in pairs(quickData) do
    --         if not itemConfigProxy:GetItemArticle(vItem.Index, checkArticleType)
    --         and self:CheckConditions(vItem) then
    --             table.insert(data, vItem)
    --         end
    --     end
    --     for _, vItem in pairs(bagData) do
    --         if not itemConfigProxy:GetItemArticle(vItem.Index, checkArticleType)
    --         and self:CheckConditions(vItem) then
    --             table.insert(data, vItem)
    --         end
    --     end
    -- end

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
                { open = NT.Layer_HeroBag_Open, close = NT.Layer_HeroBag_Close, extent = {pos = { x = 0, y = 0 }}, mediator = "HeroBagLayerMediator", node = "panel", position = "hero_bag" },
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


    -----------------------------------------------------
    --冻结角色
    local LockPublishRole = function()
        local otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
        local params = {
            prePublishLockId = otherTradingBankProxy:getPublishLockID()
        }
        otherTradingBankProxy:lockPublishRole(self, params, function(code, data, msg)
            if code == 200 then
                if data then
                    SL:print("冻结成功")
                    --SL:SetMetaValue("CLIPBOARD_TEXT", otherTradingBankProxy:getPublishKey())
                    --ShowSystemTips(GET_STRING(600000419))
                    self:uploadImg() -- app上传图片流程
                else
                    --如果冻结失败让玩家重新获取一下寄售码 保证流程畅通
                    otherTradingBankProxy:setPublishKeyValidTime(0)
                    otherTradingBankProxy:setPublishKey("")
                    ShowSystemTips(GET_STRING(700000136))--冻结失败 请稍后再试    备注：服务器处理异常情况
                end
            else
                ShowSystemTips(msg)
            end
        end)
    end

    -------------------------------------------------------
    local index = 1
    local FileUtils = cc.FileUtils:getInstance()
    local WritablePath = FileUtils:getWritablePath()
    local textureCache  = global.Director:getTextureCache()
    local repIndex = 0
    local repFunc
    repFunc = function()
        repIndex = repIndex + 1
        if repIndex > #message then --end
            dump(self.m_files,"m_files")
            if type ~= 1 then--h5 上传图片流程
                local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
                OtherTradingBankProxy:captureResult(self.m_files)
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)
            else
                --self:uploadImg() -- app上传图片流程
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)
                LockPublishRole()
            end
            return 
        end
        local val = message[repIndex]
        local position = val.position or "equip"
        local path = WritablePath..position..repIndex..".png"
        if FileUtils:isFileExist(path) then
            FileUtils:removeFile(path)
        end

        global.Facade:sendNotification(val.open, val.extent)
        local mediator = global.Facade:retrieveMediator(val.mediator)
        if mediator._layer then
            local node = val.node and mediator._layer[val.node] or  mediator._layer._root
            local time = 0.5
            local CloseFunc = function()
                global.Facade:sendNotification(val.close)
                repFunc()
            end
            PerformWithDelayGlobal (function ()
                if val.mediator == "BagLayerMediator" then--背包
                    if node then
                        local size2 = node:getContentSize()
                        node:setContentSize(size2.width+20,size2.height+60)
                        for i,v in ipairs(node:getChildren()) do
                            v:setPositionY(v:getPositionY()+60)
                        end
                    end 
                end
                --截图
                if node and self:CaptureNode(position..repIndex..".png",node) then
                    if not self.m_files[position] then
                        self.m_files[position] = {}
                    end
                    table.insert(self.m_files[position],path)
                    PerformWithDelayGlobal(function ()
                        index = index+1
                        CloseFunc()
                    end,0.1)
                else
                    CloseFunc()
                end
            end,time)

        else
            --异常 比如英雄未召唤
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureMaskLayer_Close)     
        end
    end
    repFunc()
end

function TradingBankCaptureOtherCommand:CaptureNode(filename, node, pos)
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

function TradingBankCaptureOtherCommand:CheckConditions(itemData)
    local res = true
    --30天内寄售过的不能寄售
    if itemData.AddValues then
        for k, v in pairs(itemData.AddValues) do
            if v.Id == 15 then
                if GetServerTime() < v.Value then
                    res = false
                end
                break
            end
        end
    end
    local itemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local bindArticleType       = itemConfigProxy:GetBindArticleType()
    local isBind, isSelf, isMeetType = CheckItemisBind(itemData, bindArticleType.TYPE_NOSTALL)
    
    if  isMeetType then 
        res = false
    end
    return res
end

-------------------
function TradingBankCaptureOtherCommand:uploadImg()
    SL:onLUAEvent(LUA_EVENT_OPEN_SETTING_HELP_UP_LOAD_TIPS)
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

    --服务器和客户端的标识字段
    self.tableType = {["attribute"]=0,["bag"]=0,["clothes"]=0,["equip"]=0,["hero_attribute"]=0,["hero_bag"]=0,["hero_clothes"]=0,["hero_equip"]=0,
    ["hero_skill"]=0,["hero_status"]=0,["hero_title"]=0,["skill"]=0,["status"]=0,["title"]=0,["warehouse"]=0}

    local posname = self.m_uploadImageList[self.m_uploadImgIndex].position --找到列表中的图片类型
    local path    = self.m_uploadImageList[self.m_uploadImgIndex].path     --找到列表中的图片路径
    self.tableType[posname] = self.tableType[posname] + 1
    local otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    if self.tableDataUrl.imagePrefix and self.tableDataUrl[posname][self.tableType[posname]] then
        local serverurl = self.tableDataUrl.imagePrefix .. self.tableDataUrl[posname][self.tableType[posname]]--确定列表中有 根据posname类型 再去找index
        otherTradingBankProxy:uploadImg3(self, serverurl, path, handler(self, self.ResUploadImg))
    else
        ShowSystemTips(GET_STRING(700000143))--服务器图片地址错误
        global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)
        SL:onLUAEvent(LUA_EVENT_CLOSE_SETTING_HELP_UP_LOAD_TIPS)
        self.timerOne = SL:Schedule(function()
            SL:UnSchedule(self.timerOne)
            self.timerOne = nil
            global.gameWorldController:OnGameLeaveWorld()
        end, 0.5)
    end
end
function TradingBankCaptureOtherCommand:ResUploadImg(code, data, msg)
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
            if self.m_uploadImgIndex == maxLen then
                dump(self.tableType,"tableType")
                self:onSellRole()
            else
                self.m_uploadImgIndex = self.m_uploadImgIndex + 1
                local posname = self.m_uploadImageList[self.m_uploadImgIndex].position --找到列表中的图片类型
                local path    = self.m_uploadImageList[self.m_uploadImgIndex].path     --找到列表中的图片路径
                self.tableType[posname] = self.tableType[posname] + 1

                local otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
                if self.tableDataUrl.imagePrefix and self.tableDataUrl[posname][self.tableType[posname]] then
                    local serverurl = self.tableDataUrl.imagePrefix .. self.tableDataUrl[posname][self.tableType[posname]]--确定列表中有 根据posname类型 再去找index
                    otherTradingBankProxy:uploadImg3(self, serverurl, path, handler(self, self.ResUploadImg))
                else
                    ShowSystemTips(GET_STRING(700000143))--服务器图片地址错误
                    global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)
                    SL:onLUAEvent(LUA_EVENT_CLOSE_SETTING_HELP_UP_LOAD_TIPS)
                    self.timerOne = SL:Schedule(function()
                        SL:UnSchedule(self.timerOne)
                        self.timerOne = nil
                        global.gameWorldController:OnGameLeaveWorld()
                    end, 0.5)
                end
            end
            
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, msg or "")
            global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)
            SL:onLUAEvent(LUA_EVENT_CLOSE_SETTING_HELP_UP_LOAD_TIPS)
            self.timerOne = SL:Schedule(function()
                SL:UnSchedule(self.timerOne)
                self.timerOne = nil
                global.gameWorldController:OnGameLeaveWorld()
            end, 0.5)
        end

    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, msg or "")
        global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)
        SL:onLUAEvent(LUA_EVENT_CLOSE_SETTING_HELP_UP_LOAD_TIPS)
        self.timerOne = SL:Schedule(function()
            SL:UnSchedule(self.timerOne)
            self.timerOne = nil
            global.gameWorldController:OnGameLeaveWorld()
        end, 0.5)
    end
end

function TradingBankCaptureOtherCommand:onSellRole()
    SL:onLUAEvent(LUA_EVENT_CLOSE_SETTING_HELP_UP_LOAD_TIPS)
    global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)
    local uploadSuccess = true
    for k, v in pairs(self.m_files) do
        if not self.m_serverPath[k] then--图片上传失败
            uploadSuccess = false
            ShowSystemTips(GET_STRING(600000130))
            break
        end
    end
    if uploadSuccess then
        ShowSystemTips(GET_STRING(600000419))--复制成功
        local otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
        SL:SetMetaValue("CLIPBOARD_TEXT", otherTradingBankProxy:getPublishKey())
    end

    self.timerOne = SL:Schedule(function()
        SL:UnSchedule(self.timerOne)
        self.timerOne = nil
        global.gameWorldController:OnGameLeaveWorld()
    end, 0.5)

    -- for k, v in pairs(self.m_files) do
    --     if not self.m_serverPath[k] then--有图片上传失败   提示玩家重新上传
    --         ShowSystemTips(GET_STRING(600000194))
    --         global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)
    --         SL:onLUAEvent(LUA_EVENT_CLOSE_SETTING_HELP_UP_LOAD_TIPS)
    --         return
    --     end
    -- end
    -- SL:onLUAEvent(LUA_EVENT_CLOSE_SETTING_HELP_UP_LOAD_TIPS)

    --  --600000457"寄售成功，角色被冻结，如需解冻取回，请在角色选择页面取回,商品%s小时未售出将自动下架，请在角色选择页面取回，%sS后自动登出",
    --  local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    --  local outtime = OtherTradingBankProxy:getOutTime()
    --  local tipsStr = string.format(GET_STRING(600000457), outtime, "%s")
    --  global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(res)
    --      if res == 1 then
    --          global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Close_other)
    --          global.gameWorldController:OnGameLeaveWorld()
    --      end
    --  end, notcancel = true, exitTime = 5, txt = tipsStr, btntext = { GET_STRING(800802) } })

    --  global.Facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)
end

return TradingBankCaptureOtherCommand