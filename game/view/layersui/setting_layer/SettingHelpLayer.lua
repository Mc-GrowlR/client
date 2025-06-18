local BaseLayer = requireLayerUI("BaseLayer")
local SettingHelpLayer = class("SettingHelpLayer", BaseLayer)

local RichTextHelp = requireUtil("RichTextHelp")

function SettingHelpLayer:ctor()
    SettingHelpLayer.super.ctor(self)


end

function SettingHelpLayer.create(...)
    local layer = SettingHelpLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function SettingHelpLayer:init(data)
    return true
end

function SettingHelpLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_HELP)
    SettingHelp.main()
    self.ui = ui_delegate(self)
    self:InitUI()
end

function SettingHelpLayer:InitUI()
	GUI:LoadInternalExport(self, "set/setting_help")
    self.ui.Button_1:setVisible(false)
    self.ui.Text_1:setVisible(global.isWinPlayMode)
    self:CreatePrivacyButton()
    self:CreateDeleteAccountButton()
    self:CreateInformationButton()
    self:InitICP()
end

function SettingHelpLayer:InitICP()
    local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local icpFilingDesc = envProxy:GetCustomDataByKey("icpFilingDesc")
    local icpFilingUrl  = envProxy:GetCustomDataByKey("icpFilingUrl")
    -- icpFilingDesc = "ICP备案号:粤B2-123123123-123123"
    -- icpFilingUrl = "www.baidu.com"
    if icpFilingUrl and icpFilingUrl ~= "" and icpFilingDesc and icpFilingDesc ~= ""  then 
        self.ui.Panel_ICP:setVisible(true)
        self.ui.ICP_Desc:removeFromParent()
        self.ui.ICP_Desc = GUI:RichText_Create(self.ui.Panel_ICP, "ICP_Desc", 8.00, 9.00, icpFilingDesc, 250.00, 14, "#ffffff", 4, nil, "fonts/font2.ttf")
        local contentSize = self.ui.ICP_Desc:getContentSize()
        self.ui.ICP_Button:setPositionX(self.ui.ICP_Desc:getPositionX() + contentSize.width + 20)
        self.ui.ICP_Button:addClickEventListener(function ()
            cc.Application:getInstance():openURL(icpFilingUrl)
        end)
    else
        self.ui.Panel_ICP:setVisible(false)
    end
end

function SettingHelpLayer:refContent(content,showBackout)
    self.ui.ListView_1:removeAllChildren()
    if not content then
        return
    end

    local hTTPRequestCallback = function( httpStr )
        if not httpStr then
            return
        end
        HTTPRequest(httpStr, function(success,response)
            if success and response and string.len(response) > 0 then
                local SettingHelpMediator = global.Facade:retrieveMediator("SettingHelpMediator")
                if SettingHelpMediator and SettingHelpMediator._layer then 
                    self._click_url = true
                    table.insert( self._click_count_urls,httpStr )
                    self._click_count = #self._click_count_urls
                    self:refContent(response)
                end
            end
        end)
    end

    -- 内容RichText
    local innerSize     = {width=500,height=300}
    local richText      = RichTextHelp:CreateDefaultRichTextWithXML(content or "", innerSize.width, 18, "#FFFFFF", nil)
    richText:setTouchEnabled(true)
    richText:formatText()
    self.ui.ListView_1:pushBackCustomItem( richText )

    richText:setOpenUrlHandler( function(sender,str )
        hTTPRequestCallback(str)
    end)

    if showBackout then
        local Panel_bottom = ccui.Layout:create()
        Panel_bottom:setName( "Panel_bottom" )
        Panel_bottom:setContentSize(cc.size(innerSize.width,36))

        local btn = self:CreateBackOutBtn()
        btn:setPosition(560/2,36/2)
        Panel_bottom:addChild( btn )

        self.ui.ListView_1:pushBackCustomItem( Panel_bottom )
    end
end
-- 创建撤回隐私协议按钮
function SettingHelpLayer:CreateBackOutBtn()
    local Button_backout = ccui.Button:create()
    Button_backout:loadTextureNormal(global.MMO.PATH_RES_PUBLIC .. "1900001022.png")
    Button_backout:loadTexturePressed(global.MMO.PATH_RES_PUBLIC .. "1900001022.png")
    Button_backout:setScale9Enabled(true)
    Button_backout:setCapInsets({x = 10, y = 10, width = 75, height = 34})
    Button_backout:setContentSize( {width = 120, height = 35} )
    Button_backout:setTouchEnabled(true)
    Button_backout:setTitleFontName(global.MMO.PATH_FONT2)
    Button_backout:setTitleFontSize(18)
    Button_backout:setTitleText(GET_STRING(310000302))
    Button_backout:addClickEventListener(function()
        -- 是否撤回隐私协议
        local data = {
            str = GET_STRING(310000313),
            callback = function(atype,aData)
                if atype == 1 then
                    local NativeBridgeProxy = global.Facade:retrieveProxy( global.ProxyTable.NativeBridgeProxy )
                    NativeBridgeProxy:GN_Private_BackOut()
                end
            end,
            btnDesc = {GET_STRING(310000312), GET_STRING(1000)}
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    end)
    return Button_backout
end
-- 创建隐私按钮
function SettingHelpLayer:CreatePrivacyButton()
    local envProxy = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local btns = envProxy:GetCustomDataByKey("agreementUrl") or {}
    if btns and next(btns) then
        for i,v in ipairs(btns) do
            if v.name and v.url and v.url ~= "" then
                local backout = i==2
                local btn = self.ui.Button_1:cloneEx()
                btn:setVisible(true)
                btn:setTitleText( v.name or "" )
                btn:addClickEventListener(function()
                    HTTPRequest(v.url, function(success,response)
                        local SettingHelpMediator = global.Facade:retrieveMediator("SettingHelpMediator")
                        if SettingHelpMediator and SettingHelpMediator._layer then 
                            self:refContent(response,backout)
                        end
                    end)
                end)
                self.ui.ListView_2:pushBackCustomItem(btn)
            end
        end
    end
end
-- 创建注销账号
function SettingHelpLayer:CreateDeleteAccountButton()
    local envProxy = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local showDeleteAccount = tonumber(envProxy:GetCustomDataByKey("showInnerDeleteAccount")) == 1
    if showDeleteAccount then
        local deletAccountTips = function()
            local data = {
                str = GET_STRING(310000311),
                callback = function(atype,aData)
                    if atype == 1 then
                        global.L_NativeBridgeManager:GN_deleteAccount()
                    end
                end,
                btnDesc = {GET_STRING(310000310), GET_STRING(1000)},
                isLongText=true
            }
            global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        end

        local btn = self.ui.Button_1:cloneEx()
        btn:setVisible(true)
        btn:setTitleText(GET_STRING(310000300) )
        btn:addClickEventListener(function()
            deletAccountTips()
        end)
        self.ui.ListView_2:pushBackCustomItem(btn)
    end
end

-- 个人信息收集
function SettingHelpLayer:CreateInformationButton()
    local envProxy = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local showInformation = tonumber(envProxy:GetCustomDataByKey("showInformation")) == 1
    if showInformation then
        local btn = self.ui.Button_1:cloneEx()
        btn:setVisible(true)
        btn:setTitleText(GET_STRING(310000303) )
        btn:setTitleFontSize(12)
        btn:addClickEventListener(function()
            global.Facade:sendNotification( global.NoticeTable.Layer_SettingInformationCollect_Open )
        end)
        self.ui.ListView_2:pushBackCustomItem(btn)
    end
end
-- 举报
function SettingHelpLayer:CreateReportButton()
    local btn = self.ui.Button_1:cloneEx()
    btn:setVisible(true)
    btn:setTitleText(GET_STRING(600000305) )
    btn:addClickEventListener(function()
        local url = GetReportUrl()
        cc.Application:getInstance():openURL(url)
    end)
    self.ui.ListView_2:pushBackCustomItem(btn)
end

return SettingHelpLayer
