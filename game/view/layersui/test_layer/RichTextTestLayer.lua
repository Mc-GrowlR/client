-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local BaseLayer = requireLayerUI("BaseLayer")
local RichTextTestLayer = class("RichTextTestLayer", BaseLayer)

local RichTextHelper = requireUtil("RichTextHelp")

function RichTextTestLayer:ctor()
    RichTextTestLayer.super.ctor(self)

    self._typeList      = {}
    self._typeData      = {}

    self._typeCells     = {}
    self._curType       = 1
    self._selectEdit    = 1

    self:LoadConfig()
end

function RichTextTestLayer:Init()
    self._root = CreateExport("rich_test_layer/rich_test_layer")
    if not self._root then
        return false
    end
    self:addChild(self._root)
    self.ui = ui_delegate(self._root)

    -- close
    local function closeCallback()
        global.Facade:sendNotification( global.NoticeTable.Layer_RichTextTest_Close )
    end
    local layoutClose = UIGetChildByName(self._root,"Panel_close")
    layoutClose:addClickEventListener(closeCallback)

    -- 
    self._root = UIGetChildByName(self._root, "Panel_bg")

    self:InitUI()

    refPositionByParent(self)
    return true
end

function RichTextTestLayer:Create()
    local ui = RichTextTestLayer.new()
    if ui and ui:Init() then
        return ui
    end
end

function RichTextTestLayer:InitUI()
    local node = UIGetChildByName(self.ui.Panel_func, "Panel_1")
    local contentSize = node:getContentSize()
    self._edit = ccui.EditBox:create(contentSize, global.MMO.PATH_RES_ALPHA)
    self._edit:setFont(global.MMO.PATH_FONT2, 20)
    self._edit:setMaxLength(1000000)
    node:addChild(self._edit)
    self._edit:setAnchorPoint(cc.p(0, 0.5))
    self._edit:setPosition(cc.p(0, contentSize.height/2))

    
    -- 富文本创建
    local textInputWidth = UIGetChildByName(self.ui.Panel_func, "TextField_width")
    textInputWidth = CreateEditBoxByTextField(textInputWidth)
    local createButton = UIGetChildByName(self.ui.Panel_func, "Button_rich")
    createButton:addClickEventListener(function()
        local node = UIGetChildByName(self._root, "Node_rich")
        node:removeAllChildren()

        local input = textInputWidth:getString()
        local width = tonumber(input) or 400
        local richText = RichTextHelper:CreateRichTextWithXML( self._edit:getText(), width )
        if richText then
            node:addChild(richText)
            richText:setAnchorPoint(cc.p(0.5, 1))
        end
    end)

    -- 加速
    local timer_scaled = 1
    local function slider_touch_listener( sender, eventType )
        if 0 == eventType then
            local percent = sender:getPercent()
            local timerScale = 1 + percent * timer_scaled * 0.01
            global.Director:getScheduler():setTimeScale( timerScale )
            self.ui.Text_2:setString("加速" .. timerScale);
        end
    end
    self.ui.Slider_1:addEventListener( slider_touch_listener )
    local percent = (global.Director:getScheduler():getTimeScale() - 1) / timer_scaled * 100
    self.ui.Slider_1:setPercent( percent )
    self.ui.Text_2:setPositionX(self.ui.Text_2:getPosition() - 20)

    -- 执行测试代码
    self.ui.Button_runcode:addClickEventListener(function()
        local dostring_content = self._edit:getText()
        if dostring_content and string.len( dostring_content ) > 0 then
            loadstring( dostring_content )()
        end
    end )

    -- 查看资源占有
    self.ui.Button_ui:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_CacheTest_Open)
    end)

    -- 查看网络消息日志
    local buttonRecvIdx = 0
    local buttonRecvLogs = GUI:Button_Create(self.ui.Panel_func, "buttonRecvLogs", 34, 260, "Default/Button_Normal.png")
    GUI:Button_setTitleText(buttonRecvLogs, "开始统计Recv")
    GUI:Button_setTitleColor(buttonRecvLogs, "#000000")
    GUI:Button_setTitleFontSize(buttonRecvLogs, 14)
    GUI:Button_titleDisableOutLine(buttonRecvLogs)
    GUI:setContentSize(buttonRecvLogs, 90, 30)
    buttonRecvLogs:addClickEventListener(function()
        if buttonRecvIdx == 0 then
            buttonRecvIdx = 1
            _LOG_RECV_ABLE = true
            _LOG_RECV_NET_MSG = {}
            GUI:Button_setTitleText(buttonRecvLogs, "结束统计Recv")
        elseif buttonRecvIdx == 1 then
            buttonRecvIdx = 2
            _LOG_RECV_ABLE = false
            GUI:Button_setTitleText(buttonRecvLogs, "消息统计Recv")
        elseif buttonRecvIdx == 2 then
            buttonRecvIdx = 0
            _LOG_RECV_ABLE = false
            GUI:Button_setTitleText(buttonRecvLogs, "开始统计Recv")
            self:ShowRecvNetWorkLog()
        end
    end)

    local buttonSendIdx = 0
    local buttonSendLogs = GUI:Button_Create(self.ui.Panel_func, "buttonSendLogs", 158, 260, "Default/Button_Normal.png")
    GUI:Button_setTitleText(buttonSendLogs, "开始统计Send")
    GUI:Button_setTitleColor(buttonSendLogs, "#000000")
    GUI:Button_setTitleFontSize(buttonSendLogs, 14)
    GUI:Button_titleDisableOutLine(buttonSendLogs)
    GUI:setContentSize(buttonSendLogs, 90, 30)
    buttonSendLogs:addClickEventListener(function()
        if buttonSendIdx == 0 then
            buttonSendIdx = 1
            _LOG_SEND_ABLE = true
            _LOG_SEND_NET_MSG = {}
            GUI:Button_setTitleText(buttonSendLogs, "结束统计Send")
        elseif buttonSendIdx == 1 then
            buttonSendIdx = 2
            _LOG_SEND_ABLE = false
            GUI:Button_setTitleText(buttonSendLogs, "消息统计Send")
        elseif buttonSendIdx == 2 then
            buttonSendIdx = 0
            _LOG_SEND_ABLE = false
            GUI:Button_setTitleText(buttonSendLogs, "开始统计Send")
            self:ShowSendNetWorkLog()
        end
    end)

    local buttonActors = GUI:Button_Create(self.ui.Panel_func, "buttonActors", 34, 210, "Default/Button_Normal.png")
    GUI:Button_setTitleText(buttonActors, "视野内ACTOR")
    GUI:Button_setTitleColor(buttonActors, "#000000")
    GUI:Button_setTitleFontSize(buttonActors, 14)
    GUI:Button_titleDisableOutLine(buttonActors)
    GUI:setContentSize(buttonActors, 90, 30)
    buttonActors:addClickEventListener(function()
        self:ShowInViewActorLog()
    end)

    -- 查看TXT按钮位置
    local posButton = GUI:Button_Create(self.ui.Panel_func, "posButton", 158, 210, "Default/Button_Normal.png")
    GUI:Button_setTitleText(posButton, "TXT按钮位置")
    GUI:Button_setTitleColor(posButton, "#000000")
    GUI:Button_setTitleFontSize(posButton, 14)
    GUI:Button_titleDisableOutLine(posButton)
    GUI:setContentSize(posButton, 90, 30)
    GUI:addOnClickEvent(posButton, function()
        global.Facade:sendNotification( global.NoticeTable.Layer_RichTextTest_Close)
        global.Facade:sendNotification(global.NoticeTable.CUIEditorClose)
        global.Facade:sendNotification(global.NoticeTable.Layer_ButtonPos_Open)
    end)


    self.ui.Button_type:setVisible(false)
    self.ui.Panel_cell:setVisible(false)
    self:InitPanel()
end

function RichTextTestLayer:InitPanel()
    self.ui.ListView_type:removeAllChildren()
    local function refreshTypeShow( ... )
        for i, btn in pairs(self._typeCells) do
            if self._curType == i then
                btn:setColor({r = 127, g = 127, b = 127})
            else
                btn:setColor({r = 255, g = 255, b = 255})
            end
        end
    end

    for id, typeName in ipairs(self._typeList) do
        local btn = self.ui.Button_type:cloneEx()
        btn:setVisible(true)
        btn:setTitleText(typeName)
        btn:addClickEventListener(function()
            self._curType = id
            refreshTypeShow()
            self:ShowEditPanel()
        end)
        self._typeCells[id] = btn
        self.ui.ListView_type:pushBackCustomItem(btn)
    end

    refreshTypeShow()
    self:ShowEditPanel()
end

function RichTextTestLayer:ShowEditPanel()
    self.ui.ListView_editUI:removeAllChildren()
    local data = self._typeData[self._curType] or {}

    for i, v in ipairs(data) do
        local cell = self.ui.Panel_cell:cloneEx()
        cell:setVisible(true)
        local ui = ui_delegate(cell)
        ui.Text_editUI:setString(v.name)
        cell:setSwallowTouches(false)
        cell:addClickEventListener(function()
            global.Facade:sendNotification( global.NoticeTable.Layer_RichTextTest_Close )
            local editData = v.func()
            if editData then
                global.Facade:sendNotification(global.NoticeTable.CUIEditorOpen, editData)
            end
        end)
        self.ui.ListView_editUI:pushBackCustomItem(cell)
    end
end

local function OpenHeroBagEdit(level)
    local mediator = global.Facade:retrieveMediator("HeroBagLayerMediator")
    if not mediator then return end
    if mediator._layer then
        global.Facade:sendNotification(global.NoticeTable.Layer_HeroBag_Close)
    end
    if not mediator._layer then
        global.Facade:sendNotification(global.NoticeTable.Layer_HeroBag_Open, {level = level})
    end
    
    return {rootKey = global.CUIKeyTable["HERO_BAGLEVEL"..level], root = mediator._layer}
end

function RichTextTestLayer:LoadConfig()
    self._typeList = {
        [1] = "主界面",
        [2] = "按钮类",
        [3] = "角色类",
        [4] = "系统类",
        [5] = "功能类",
        [6] = "英雄类",
    }

    self._typeData = {
        [1] = {
            [1] = {
                name = "主界面控件",
                func = function()
                    if global.isWinPlayMode then
                        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
                        if GameSettingProxy:IsInnerChangedSize() then
                            ShowSystemTips("退出游戏重试!")
                            return
                        end
                    end
                    local mediator = global.Facade:retrieveMediator("MainPropertyMediator")
                    return {rootKey = global.CUIKeyTable.PROPERTY, root = mediator._layer}
                end
            },
            [2] = {
                name = "技能位置",
                func = function()
                    if global.isWinPlayMode then
                        return nil
                    end
                    local mediator = global.Facade:retrieveMediator("MainSkillMediator")
                    return {rootKey = global.CUIKeyTable.MOBILE_SKILL, root = mediator._layer}
                end
            },
            [3] = {
                name = "任务面板",
                func = function()
                    local mediator = global.Facade:retrieveMediator("MainAssistMediator")
                    return {rootKey = global.CUIKeyTable.ASSIST, root = mediator._layer}
                end
            },
            [4] = {
                name = "主界面小地图",
                func = function()
                    local mediator = global.Facade:retrieveMediator("MainMiniMapMediator")
                    return {rootKey = global.CUIKeyTable.MAINMINIMAP, root = mediator._layer}
                end
            },
            [5] = {
                name = "手机信号栏",
                func = function()
                    if global.isWinPlayMode then
                        return nil
                    end
                    local mediator = global.Facade:retrieveMediator("MainTopMediator")
                    return {rootKey = global.CUIKeyTable.MAINTOP, root = mediator._layer}
                end
            },
            [6] = {
                name = "目标信息页",
                func = function()
                    if global.isWinPlayMode then
                        return nil
                    end
                    local mediator = global.Facade:retrieveMediator("MainTargetMediator")
                    return {rootKey = global.CUIKeyTable.MAINTARGET, root = mediator._layer}
                end
            },
        },
        [2] = {
            [1] = {
                name = "召唤按钮",
                func = function()
                    if global.isWinPlayMode then
                        return nil
                    end
                    local mediator = global.Facade:retrieveMediator("MainSummonsMediator")
                    return {rootKey = global.CUIKeyTable.MOBILE_SUMMONS, root = mediator._layer}
                end
            },
            [2] = {
                name = "挖掘按钮",
                func = function()
                    if global.isWinPlayMode then
                        return nil
                    end
                    local mediator = global.Facade:retrieveMediator("MainDigMediator")
                    return {rootKey = global.CUIKeyTable.MOBILE_DIG, root = mediator._layer}
                end
            },
            [3] = {
                name = "提升按钮",
                func = function()
                    local mediator = global.Facade:retrieveMediator("BeStrongUpMediator")
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.BESTRONG, root = mediator._layer}
                end
            },
        },
        [3] = {
            [1] = {
                name ="角色外框",
                func = function() 
                    local mediator = global.Facade:retrieveMediator("PlayerFrameMediator")
                    if not mediator then return end
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP})
                    end
                    
                    return {rootKey = global.CUIKeyTable.PLAYER_FRAME, root = mediator._layer}
                end
            },
            [2] = {
                name = "角色装备",
                func = function()
                    local mediator = global.Facade:retrieveMediator("PlayerEquipLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP})
                    end
                
                    return {rootKey = global.CUIKeyTable.PLAYER_EQUIP, root = mediator._layer}
                end
            },
            [3] = {
                name = "角色状态",
                func = function ()
                    -- 基础属性 （状态
                    local mediator = global.Facade:retrieveMediator("PlayerBaseAttLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI})
                    end
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.PLAYER_BASEATTR, root = mediator._layer}
                end
            },
            [4] = {
                name = "角色属性",
                func = function ()
                    -- 额外属性 （属性
                    local mediator = global.Facade:retrieveMediator("PlayerExtraAttLayerMediator")
                    if not mediator._layer then 
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO})
                    end
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.PLAYER_EXTRAATTR, root = mediator._layer}
                end
            },
            [5] = {
                name = "角色技能",
                func = function()
                    local mediator = global.Facade:retrieveMediator("PlayerSkillLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open,{extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL})
                    end
                    
                    return {rootKey = global.CUIKeyTable.PLAYER_SKILL, root = mediator._layer}
                end
            },
            [6] = {
                name = "角色称号",
                func = function()
                    local mediator = global.Facade:retrieveMediator("PlayerTitleLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open,{extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE})
                    end
                    
                    return {rootKey = global.CUIKeyTable.PLAYER_TITLE, root = mediator._layer}
                end
            },
            [7] = {
                name = "角色时装",
                func = function()
                    local mediator = global.Facade:retrieveMediator("PlayerSuperEquipMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open,{extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP})
                    end
                    
                    return {rootKey = global.CUIKeyTable.PLAYER_SUPEREQUIP, root = mediator._layer}
                end
            },
            [8] = {
                name = "角色首饰盒",
                func = function()
                    local mediator = global.Facade:retrieveMediator("PlayerBestRingLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_PlayerBestRing_Open, {param = {}})
                    end
                    return {rootKey = global.CUIKeyTable.BEST_RING, root = mediator._layer}
                end
            },
            [9] = {
                name ="他人角色外框",
                func = function() 
                    local mediator = global.Facade:retrieveMediator("LookPlayerFrameMediator")
                    if not mediator then return end
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Open, {id = global.LayerTable.PlayerLayer, lookPlayer = true})
                    end
                    
                    return {rootKey = global.CUIKeyTable.LOOKPLAYER_FRAME, root = mediator._layer}
                end
            },
            [10] = {
                name = "他人角色外框[交易行]",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("TradingBankPlayerPanel")
                    if not mediator._layer then
                        local size = global.Director:getWinSize()
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Open, {parent= GUI:Attach_LeftBottom(), position = cc.p(size.width/2, size.height/2)})
                    end
                    if mediator._layer then
                        return {rootKey = global.CUIKeyTable.TRADE_PLAYER_FRAME, root = mediator._layer}
                    end
                end
            }
        },
        [4] = {
            [1] = {
                name = "背包",
                func = function()
                    local mediator = global.Facade:retrieveMediator("BagLayerMediator")
                    if not mediator then
                        mediator = global.Facade:retrieveMediator("MergeBagLayerMediator")
                        if not mediator._layer then
                            global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, {})
                        end
                        
                        return {rootKey = global.CUIKeyTable.BAG_MERGE, root = mediator._layer}
                    else
                        if not mediator._layer then
                            global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, {})
                        end
                        
                        return {rootKey = global.CUIKeyTable.BAG, root = mediator._layer}
                    end
                end
            },
            [2] = {
                name = "仓库",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("NPCStorageMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Open, {noShowBag = true})
                    end
                    return {rootKey = global.CUIKeyTable.NPC_STORAGE, root = mediator._layer}
                end
            },
            [3] = {
                name = "摆摊",
                func = function()
                    local mediator = global.Facade:retrieveMediator("StallLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_Open)
                    end
                    return {rootKey = global.CUIKeyTable.BAITAN, root = mediator._layer}
                end
            },
            [4] = {
                name = "大地图",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("MiniMapMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_MiniMap_Open)
                    end
                    return {rootKey = global.CUIKeyTable.MINIMAP, root = mediator._layer}
                end
            },
            [5] = {
                name = "排行榜",
                func = function()
                    local mediator = global.Facade:retrieveMediator("RankLayerMediator")
                    if mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Rank_Close)
                    end
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Rank_Open)
                    end
                    return {rootKey = global.CUIKeyTable.RANK, root = mediator._layer}
                end
            },
            [6] = {
                name = "怪物大血条",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("MainMonsterLayerMediator")
                    if mediator._layer then
                        return {rootKey = global.CUIKeyTable.MAIN_MONSTER, root = mediator._layer}
                    end
                end
            },
            [7] = {
                name = "归属头像 [目标]",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("MonsterBelongNetPlayerMediator")
                    if mediator._layer and not global.isWinPlayMode then
                        local type = mediator._layer.type 
                        if type == "MainTarget_Belong" then
                            return {rootKey = global.CUIKeyTable.MAINTARGET_BELONG, root = mediator._layer}
                        end
                    end
                end
            },
            [8] = {
                name = "归属头像 [大血条]",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("MonsterBelongNetPlayerMediator")
                    if mediator._layer then
                        local type = mediator._layer.type 
                        if type == "MainMonster_Belong" then
                            return {rootKey = global.CUIKeyTable.MAINMONSTER_BELONG, root = mediator._layer}
                        end
                    end
                end
            },
        },
        [5] = {
            [1] = {
                name = "合成面板",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("CompoundItemLayerMediator")
                    if not mediator._layer then
                        JUMPTO(2201)
                    end
                    if mediator._layer then
                        return {rootKey = global.CUIKeyTable.COMPOUND_ITEMS, root = mediator._layer}
                    end
                end
            },
            [2] = {
                name = "验证面板",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("CommonVerificationMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.VerificationLayer_Open, {})
                    end
                    if mediator._layer then
                        return {rootKey = global.CUIKeyTable.COMMON_VERIFICATION, root = mediator._layer}
                    end
                end
            },
            [3] = {
                name = "答题面板",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("CommonQuestionMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.QuestionLayer_Open, {isEdit = true, time = 9999, question = "问题示例xxxxxx?"})
                    end
                    return {rootKey = global.CUIKeyTable.COMMON_QUESTION, root = mediator._layer}
                end
            },
            [4] = {
                name = "行会面板外框",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("GuildFrameMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_GuildFrame_Open)
                    end
                    return {rootKey = global.CUIKeyTable.GUILD_FRAME, root = mediator._layer}
                end
            },
            [5] = {
                name = "社交面板外框",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("SocialFrameMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Social_Open)
                    end
                    return {rootKey = global.CUIKeyTable.SOCIAL_FRAME, root = mediator._layer}
                end
            },
            [6] = {
                name = "商店面板外框",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("StoreFrameMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_StoreFrame_Open)
                    end
                    return {rootKey = global.CUIKeyTable.STORE_FRAME, root = mediator._layer}
                end
            },
            [7] = {
                name = "设置面板外框",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("SettingFrameMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_SettingFrame_Open)
                    end
                    return {rootKey = global.CUIKeyTable.SETTING_FRAME, root = mediator._layer}
                end
            },
            [8] = {
                name = "拍卖行面板外框",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("AuctionMainMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_AuctionMain_Open)
                    end
                    return {rootKey = global.CUIKeyTable.AUCTION_FRAME, root = mediator._layer}
                end
            }
        },
        [6] = {
            [1] = {
            name = "英雄信息栏",
            func = function ()
                local mediator = global.Facade:retrieveMediator("HeroStateLayerMediator")
                if not mediator._layer then
                    return nil
                end
                return {rootKey = global.CUIKeyTable.HERO_STATE, root = mediator._layer}
            end
            },
            [2] = {
                name = "英雄角色2合一外框",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("MergePlayerLayerMediator")
                    if not mediator or global.isWinPlayMode then
                        return nil
                    end
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open_Hero, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP})
                    end
                    
                    if not mediator._layer then return end
                    return {rootKey = global.CUIKeyTable.HERO_MERGE_FRAME, root = mediator._layer}
                    
                end
            },
            [3] = {
                name = "英雄装备",
                func = function()
                    local mediator = global.Facade:retrieveMediator("HeroEquipLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open_Hero, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP})
                    end
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.HERO_EQUIP, root = mediator._layer}
                end
            },
            [4] = {
                name = "英雄技能",
                func = function()
                    local mediator = global.Facade:retrieveMediator("HeroSkillLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open_Hero, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL})
                    end
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.HERO_SKILL, root = mediator._layer}
                end
            },
            [5] = {
                name = "英雄称号",
                func = function()
                    local mediator = global.Facade:retrieveMediator("HeroTitleLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open_Hero, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE})
                    end
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.HERO_TITLE, root = mediator._layer}
                end
            },
            [6] = {
                name = "英雄时装",
                func = function()
                    local mediator = global.Facade:retrieveMediator("HeroSuperEquipMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open_Hero, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP})
                    end
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.HERO_SUPEREQUIP, root = mediator._layer}
                end
            },
            [7] = {
                name = "英雄状态",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("HeroBaseAttLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open_Hero, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI})
                    end
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.HERO_BASEATTR, root = mediator._layer}
                end
            },
            [8] = {
                name = "英雄属性",
                func = function ()
                    local mediator = global.Facade:retrieveMediator("HeroExtraAttLayerMediator")
                    if not mediator._layer then 
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open_Hero, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO, id = 100 + SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO})
                    end
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.HERO_EXTRAATTR , root = mediator._layer}
                end
            },
            [9] = {
                name = "英雄首饰盒",
                func = function()
                    local mediator = global.Facade:retrieveMediator("HeroBestRingLayerMediator")
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_PlayerBestRing_Open_Hero, {param = {}})
                    end
                    if not mediator._layer then
                        return nil
                    end
                    return {rootKey = global.CUIKeyTable.HERO_BEST_RING, root = mediator._layer}
                end
            },
            [10] = {
                name = "英雄单独角色外框",
                func = function()
                    local mediator = global.Facade:retrieveMediator("HeroFrameMediator")
                    if not mediator then return end
                    if not mediator._layer then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open_Hero, {extent = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP})
                    end
                    
                    return {rootKey = global.CUIKeyTable.HERO_FRAME, root = mediator._layer}
                    
                end
            },
            [11] = {
                name = "1级背包",
                func = function()
                    return OpenHeroBagEdit(1)
                end
            },
            [12] = {
                name = "2级背包",
                func = function()
                    return OpenHeroBagEdit(2)
                end
            },
            [13] = {
                name = "3级背包",
                func = function()
                    return OpenHeroBagEdit(3)
                end
            },
            [14] = {
                name = "4级背包",
                func = function()
                    return OpenHeroBagEdit(4)
                end
            },
            [15] = {
                name = "5级背包",
                func = function()
                    return OpenHeroBagEdit(5)
                end
            }
        }
    }
end

function RichTextTestLayer:ShowRecvNetWorkLog()
    local visibleSize = global.Director:getVisibleSize()
    local layout = GUI:Layout_Create(self, "network_log", 0, 0, visibleSize.width, visibleSize.height)
    GUI:Layout_setBackGroundColor(layout, "#000000")
    GUI:Layout_setBackGroundColorType(layout, 1)
    GUI:Layout_setBackGroundColorOpacity(layout, 230)
    GUI:setTouchEnabled(layout, true)
    GUI:addOnClickEvent(layout, function()
        layout:removeFromParent()
    end)

    local logs = _LOG_RECV_NET_MSG
    local items = HashToSortArray(logs, function(a, b)
        return a.hits > b.hits
    end)

    local listview = GUI:ListView_Create(layout, "listview", visibleSize.width/2, visibleSize.height/2, 400, 600, 1)
    GUI:Layout_setBackGroundColor(listview, "#ff0000")
    GUI:Layout_setBackGroundColorType(listview, 1)
    GUI:Layout_setBackGroundColorOpacity(listview, 100)
    GUI:setAnchorPoint(listview, 0.5, 0.5)
    GUI:Layout_setClippingEnabled(listview, true)
    for i, v in ipairs(items) do
        local str = string.format("消息号: %s,    命中次数: %s,    消息体长度: %s", v.msgId, v.hits, v.dataLen)
        local text = GUI:Text_Create(listview, "text_" .. i, 0, 0, 14, "#ffffff", str)
    end
end

function RichTextTestLayer:ShowSendNetWorkLog()
    local visibleSize = global.Director:getVisibleSize()
    local layout = GUI:Layout_Create(self, "network_log", 0, 0, visibleSize.width, visibleSize.height)
    GUI:Layout_setBackGroundColor(layout, "#000000")
    GUI:Layout_setBackGroundColorType(layout, 1)
    GUI:Layout_setBackGroundColorOpacity(layout, 230)
    GUI:setTouchEnabled(layout, true)
    GUI:addOnClickEvent(layout, function()
        layout:removeFromParent()
    end)

    local logs = _LOG_SEND_NET_MSG
    local items = HashToSortArray(logs, function(a, b)
        return a.hits > b.hits
    end)

    local listview = GUI:ListView_Create(layout, "listview", visibleSize.width/2, visibleSize.height/2, 400, 560, 1)
    GUI:Layout_setBackGroundColor(listview, "#ff0000")
    GUI:Layout_setBackGroundColorType(listview, 1)
    GUI:Layout_setBackGroundColorOpacity(listview, 100)
    GUI:setAnchorPoint(listview, 0.5, 0.5)
    GUI:Layout_setClippingEnabled(listview, true)
    for i, v in ipairs(items) do
        local str = string.format("消息号: %s,    命中次数: %s,    消息体长度: %s", v.msgId, v.hits, v.dataLen or 0)
        local text = GUI:Text_Create(listview, "text_" .. i, 0, 0, 14, "#ffffff", str)
    end
end

function RichTextTestLayer:ShowInViewActorLog()
    local visibleSize = global.Director:getVisibleSize()
    local layout = GUI:Layout_Create(self, "network_log", 0, 0, visibleSize.width, visibleSize.height)
    GUI:Layout_setBackGroundColor(layout, "#000000")
    GUI:Layout_setBackGroundColorType(layout, 1)
    GUI:Layout_setBackGroundColorOpacity(layout, 230)
    GUI:setTouchEnabled(layout, true)
    GUI:addOnClickEvent(layout, function()
        layout:removeFromParent()
    end)

    local filePath  = cc.FileUtils:getInstance():getWritablePath() .. "ACTOR_Logs.txt"
    filePath        = global.FileUtilCtl:getSuitableFOpen(filePath)
    local io_file   = io.open(filePath, "w")

    -- NPC
    io_file:write("--------------------------------------------\n")
    io_file:write("NPC\n")
    local actors = global.npcManager:GetNpcInCurrViewField()
    local listviewNPC = GUI:ListView_Create(layout, "listviewNPC", 0, visibleSize.height/2, 200, 560, 1)
    GUI:Layout_setBackGroundColor(listviewNPC, "#ff0000")
    GUI:Layout_setBackGroundColorType(listviewNPC, 1)
    GUI:Layout_setBackGroundColorOpacity(listviewNPC, 100)
    GUI:setAnchorPoint(listviewNPC, 0, 0.5)
    GUI:Layout_setClippingEnabled(listviewNPC, true)
    for i, v in pairs(actors) do
        local str = string.format("名: %s, (%s,%s), ID: %s", v:GetName(), v:GetMapX(), v:GetMapY(), v:GetID())
        local text = GUI:Text_Create(listviewNPC, "text_" .. i, 0, 0, 12, "#ffffff", str)

        io_file:write(str)
        io_file:write("\n")
    end
    io_file:write("\n")
    io_file:write("\n")

    -- 玩家
    io_file:write("--------------------------------------------\n")
    io_file:write("玩家\n")
    local actors = global.playerManager:GetPlayersInCurrViewField()
    local listviewPlayer = GUI:ListView_Create(layout, "listviewPlayer", 200, visibleSize.height/2, 300, 560, 1)
    GUI:Layout_setBackGroundColor(listviewPlayer, "#00ff00")
    GUI:Layout_setBackGroundColorType(listviewPlayer, 1)
    GUI:Layout_setBackGroundColorOpacity(listviewPlayer, 100)
    GUI:setAnchorPoint(listviewPlayer, 0, 0.5)
    GUI:Layout_setClippingEnabled(listviewPlayer, true)
    for i, v in pairs(actors) do
        local str = string.format("名: %s, (%s,%s), ID: %s", v:GetName(), v:GetMapX(), v:GetMapY(), v:GetID())
        local text = GUI:Text_Create(listviewPlayer, "text_" .. i, 0, 0, 12, "#ffffff", str)

        io_file:write(str)
        io_file:write("\n")
    end
    io_file:write("\n")
    io_file:write("\n")

    -- 怪物
    io_file:write("--------------------------------------------\n")
    io_file:write("怪物\n")
    local actors = global.monsterManager:GetMonstersInCurrViewField()
    local listviewMonster = GUI:ListView_Create(layout, "listviewMonster", 500, visibleSize.height/2, 200, 560, 1)
    GUI:Layout_setBackGroundColor(listviewMonster, "#0000ff")
    GUI:Layout_setBackGroundColorType(listviewMonster, 1)
    GUI:Layout_setBackGroundColorOpacity(listviewMonster, 100)
    GUI:setAnchorPoint(listviewMonster, 0, 0.5)
    GUI:Layout_setClippingEnabled(listviewMonster, true)
    for i, v in pairs(actors) do
        local str = string.format("名: %s, (%s,%s), ID: %s", v:GetName(), v:GetMapX(), v:GetMapY(), v:GetID())
        local text = GUI:Text_Create(listviewMonster, "text_" .. i, 0, 0, 12, "#ffffff", str)

        io_file:write(str)
        io_file:write("\n")
    end
    io_file:write("\n")
    io_file:write("\n")

    -- 掉落物
    io_file:write("--------------------------------------------\n")
    io_file:write("掉落物\n")
    local actors = global.dropItemManager:FindDropItemInCurrViewFieldAll()
    local listviewDropItem = GUI:ListView_Create(layout, "listviewDropItem", 700, visibleSize.height/2, 200, 560, 1)
    GUI:Layout_setBackGroundColor(listviewDropItem, "#ffff00")
    GUI:Layout_setBackGroundColorType(listviewDropItem, 1)
    GUI:Layout_setBackGroundColorOpacity(listviewDropItem, 100)
    GUI:setAnchorPoint(listviewDropItem, 0, 0.5)
    GUI:Layout_setClippingEnabled(listviewDropItem, true)
    for i, v in pairs(actors) do
        local str = string.format("名: %s, (%s,%s), ID: %s", v:GetName(), v:GetMapX(), v:GetMapY(), v:GetID())
        local text = GUI:Text_Create(listviewDropItem, "text_" .. i, 0, 0, 12, "#ffffff", str)

        io_file:write(str)
        io_file:write("\n")
    end


    io_file:close()
end

return RichTextTestLayer

-- endregion
