local GameWorldInfoInitCommand = class('GameWorldInfoInitCommand', framework.SimpleCommand)

function GameWorldInfoInitCommand:ctor()
end

function GameWorldInfoInitCommand:execute(note)
    print( "====================================" )
    print( "GameWorldInfoInit" )
    print( "====================================" )

    local data = note:getBody()
    local jsonData = data and data.jsonData 
    local header = data and data.header
    dump(jsonData)

    -- 重连
    local disconnectProxy = global.Facade:retrieveProxy( global.ProxyTable.Disconnect )
    local isDisconnect    = disconnectProxy:IsDisconnect()
    
    --是否试玩模式
    local shiwan = global.L_GameEnvManager:GetEnvDataByKey("shiwan")
    if  shiwan and tonumber(shiwan) == 1 or global.IsReceiveRole then 
        global.IsVisitor = true
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy( global.ProxyTable.TradingBankLookPlayerProxy )
        TradingBankLookPlayerProxy:RequestPlayerData(global.playerManager:GetMainPlayerID())
        global.Facade:sendNotification( global.NoticeTable.ReconnectForbidden )
        global.Facade:sendNotification( global.NoticeTable.Layer_NPC_Talk_Close )
    end
    
    self:handle_game_state(jsonData, isDisconnect)

    self:handle_game_info(jsonData, isDisconnect, header)

end

function GameWorldInfoInitCommand:handle_game_state(jsonData, isDisconnect)
    if isDisconnect then
        global.Facade:sendNotification( global.NoticeTable.Reconnect )
    end
end

function GameWorldInfoInitCommand:handle_game_info(jsonData, isDisconnect, header)
    -- 重连
    if isDisconnect then
        return nil
    end

    -- set dispatch msg enable:true
    global.LuaBridgeCtl:SetModulesSwitch( global.MMO.Modules_Index_Enable_Disconnect_Msg, 1 )
    
    if jsonData then
        --kfday  开服天数
        --unixtime 当前时间戳
        --kfunixtime 开服时间戳
        local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
        ServerTimeProxy:SaveTimeData(jsonData)

        -- save 云端存储
        local CloudStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.CloudStorageProxy)
        CloudStorageProxy:RespCloudStorage(jsonData.save)

        -- 拍卖行数据
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        AuctionProxy:setQualities(jsonData.auctionby or {})
        AuctionProxy:setJobAble(jsonData.paimaijob or {})
        AuctionProxy:setLimitShelf(jsonData.paimaicount or 0)

        AuctionProxy:setLowBidPrice(jsonData.AuctionPrice)
        AuctionProxy:setLowBuyPrice(jsonData.OneBitePrice)
        AuctionProxy:setHighBidPrice(jsonData.MaxAuctionPrice)
        AuctionProxy:setHighBuyPrice(jsonData.MaxOneBitePrice)

        -- 转生颜色变色
        if jsonData.RelvColor and jsonData.RelvChange then
            local actorUtils = requireProxy( "actorUtils" )
            actorUtils.actorReLvData( {RelvColor=jsonData.RelvColor, RelvChange=jsonData.RelvChange} )
        end

        -- 拍卖行物品列表请求最小间隔
        if jsonData.PaiMaiQueryTime then
            AuctionProxy:SetRequestMinTime(jsonData.PaiMaiQueryTime)
        end

        -- 是否上报主界面txt按钮/图片点击事件
        if jsonData.LogCusBury then
            local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
            SUIComponentProxy:SetMainUIClickEvent(true)
        end

        -- 服务器开关
        local ServerOptionsProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerOptionsProxy)
        ServerOptionsProxy:setOptions(jsonData.gameoptions)

        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        EquipProxy:SetBestRingsOpenState(jsonData.SndaItemBoxOpened)
        EquipProxy:SetCustUserItem(jsonData.gameoptions.CustUserItem)

        -- 多开数量
        if global.isWindows and jsonData.maxClientCount then
            local luaBridgeCtl  = LuaBridgeCtl:Inst()
            local maxCount      = jsonData.maxClientCount
            if luaBridgeCtl.CheckClientCount and false == luaBridgeCtl:CheckClientCount(maxCount) then
                local function callback(bType, custom)
                    global.Director:endToLua()
                end
                local data = {}
                data.str = GET_STRING(1089)
                data.btnDesc = {GET_STRING(1001)}
                data.callback = callback
                global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)

                --客户端上限不允许联网
                global.gameEnvironment:GetNetClient():Disconnect()
                global.Facade:sendNotification( global.NoticeTable.ReconnectForbidden )
            end
        end

        -- 掉落光柱时间
        if jsonData.JPshuxingEquipEffect then
            SL:SetMetaValue("GAME_DATA","JPshuxingEquipEffect",jsonData.JPshuxingEquipEffect)
        end

        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login) --本地储存devicecode
        LoginProxy:SaveDeviceCode(jsonData.devicecode)

        --是否是 新版交易行
        if jsonData.gameoptions.IsNewBoxSellVersion then
            global.IsNewBoxSellVersion = true
        end

        if global.IsVisitor then
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankReceiveLayer_Open)
        end

        -- 禁止聊天开关
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        LoginProxy:SetForbidChat(jsonData.LimitChat == 1)

        --英雄召唤cd时间
        if jsonData.recallherotime then 
            dump(jsonData.recallherotime,"jsonData.recallherotime___")
            local HeroPropertyProxy = global.Facade:retrieveProxy("HeroPropertyProxy")
            HeroPropertyProxy:setCD(jsonData.recallherotime)
        end

        -- 连击格子加额外暴击几率
        local PlayerProperty = global.Facade:retrieveProxy("PlayerProperty")
        for i = 1, 4 do
            if jsonData["BJCommonRate" .. i] then
                PlayerProperty:SetComboExtraBJRate(jsonData["BJCommonRate" .. i], i)
            end 
        end

        -- 是否启用新版属性加点
        local reinAttrProxy = global.Facade:retrieveProxy(global.ProxyTable.ReinAttrProxy)
        reinAttrProxy:SetIsNewBouns(jsonData.gameoptions.NewBonus)

        -- 人物最大等级 [暂供行会申请等级使用]
        if jsonData.gameoptions.MaxLevel then
            PlayerProperty:SetMaxLevel(jsonData.gameoptions.MaxLevel)
        end

        -- 求购货币默认
        if jsonData.gameoptions.sQiugouDefaultGoldType then
            local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
            PurchaseProxy:SetCurrencies(jsonData.gameoptions.sQiugouDefaultGoldType)
        end
        
        -- 掉落格式
        if jsonData.DropItemHint then
            local data = {
                Msg     = global.isWinPlayMode and jsonData.PCDropItemHint or jsonData.DropItemHint,
                BColor  = jsonData.DropItemBC,
                FColor  = jsonData.DropItemFC,
            }
            local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
            ChatProxy:SetFakeDropParam(data)
        end

        -- 血魄一击技能配置消耗值不足耗血相关
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        SkillProxy:SetXPSpellParam(jsonData.XPSpellType, jsonData.XPSpellTypeValue, jsonData.XPMPType)
        SkillProxy:SetMooteboWithCD(jsonData.MooteboWithCD or 0)
    end

    -- config
    self:initConfig()

    -- ui
    self:initUI()

    -- 后台添加
    self:InitExAddUI(header, jsonData)

end

function GameWorldInfoInitCommand:initConfig()
    global.skillManager:LoadConfig()

    local SceneOptionsProxy = global.Facade:retrieveProxy(global.ProxyTable.SceneOptionsProxy)
    SceneOptionsProxy:LoadConfig()

    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    GameSettingProxy:LoadConfig()

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    BuffProxy:LoadConfig()

    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:LoadConfig()

    local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
    HeroSkillProxy:LoadConfig()

    local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
    AttrConfigProxy:LoadConfig()

    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    NPCStorageProxy:LoadConfig()

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    ItemConfigProxy:LoadConfig()
    
    local ThrowDamageNumProxy = global.Facade:retrieveProxy(global.ProxyTable.ThrowDamageNumProxy)
    ThrowDamageNumProxy:LoadConfig()

    local JumpLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.JumpLayerProxy)
    JumpLayerProxy:LoadConfig()

    local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
    ItemTipsProxy:LoadConfig()
    ItemTipsProxy:LoadCustAbilConfig()

    local MiniMapProxy = global.Facade:retrieveProxy(global.ProxyTable.MiniMapProxy)
    MiniMapProxy:LoadConfig()

    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    SUIComponentProxy:LoadConfig()

    local PageStoreProxy = global.Facade:retrieveProxy(global.ProxyTable.PageStoreProxy)
    PageStoreProxy:InitPageStoreData()

    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    HeroPropertyProxy:initConfig()

    local AuctionProxy  = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    AuctionProxy:InitItemConfig()

    local ColorStyleProxy = global.Facade:retrieveProxy(global.ProxyTable.ColorStyleProxy)
    ColorStyleProxy:LoadConfig()

    local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
    SummonsProxy:LoadConfig()

    local ReinAttrProxy = global.Facade:retrieveProxy(global.ProxyTable.ReinAttrProxy)
    ReinAttrProxy:LoadConfig()

    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    ChatProxy:LoadConfig()
    
end

function GameWorldInfoInitCommand:initUI()
    -- 
    SLBridge:onEnterWorld()
    
    global.Facade:sendNotification( global.NoticeTable.Layer_RTouch_Open)

    global.Facade:sendNotification( global.NoticeTable.Layer_Moved_Open)

    global.Facade:sendNotification( global.NoticeTable.Layer_Notice_Open)

    -- init main nodes
    global.Facade:sendNotification( global.NoticeTable.Layer_Main_Open )
    
    -- init main ui
    global.Facade:sendNotification(global.NoticeTable.Layer_Main_Init)

    global.Facade:sendNotification(global.NoticeTable.Layer_TopTouch_Open)

    -- 
    global.Facade:sendNotification(global.NoticeTable.GameWorldInitComplete)

    -- ssr
    ssr.ssrBridge:onWorldInfoInit()

    -- SL
    SLBridge:onLUAEvent(LUA_EVENT_ENTER_WORLD)
end

function GameWorldInfoInitCommand:InitExAddUI(header, jsonData)
    if header then
        local data = {}
        data.x = header.recog
        data.y = header.param1
        data.subid = header.param2
        data.scale = jsonData.ratio
        local openState = tonumber(header.param3) == 1
        if openState then
            global.Facade:sendNotification(global.NoticeTable.AddBoxDayBtnToScreen, data)
        end
    end

    local isOpen = jsonData.jyh_state and jsonData.jyh_state == 1 
    if isOpen then
        local btnData = {}
        btnData.x = jsonData.jyh_x_axis
        btnData.y = jsonData.jyh_y_axis
        btnData.subid = jsonData.jyh_hitch_point
        btnData.width = jsonData.jyh_width
        btnData.height= jsonData.jyh_height
        if next(btnData) then
            global.Facade:sendNotification(global.NoticeTable.AddTradingBankBtnToScreen, btnData)
        end
    end
end

return GameWorldInfoInitCommand
