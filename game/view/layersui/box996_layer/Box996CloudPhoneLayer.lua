local BaseLayer = requireLayerUI( "BaseLayer" )
local Box996CloudPhoneLayer = class( "Box996CloudPhoneLayer", BaseLayer )

local RichTextHelp  = require("util/RichTextHelp")

local SHOW_PANEL = {
    GET_PANEL = 1,                      -- 领取界面        
    ALREADY_GET_PANEL = 2,              -- 已领取界面
    NOT_GET_PANEL = 3,                  -- 不满足领取界面(暂时没用到)
}

function Box996CloudPhoneLayer:ctor()
    Box996CloudPhoneLayer.super.ctor( self )

    self._proxy = global.Facade:retrieveProxy( global.ProxyTable.Box996Proxy )

    self.mGeting = false   -- 是否领取ing
end

function Box996CloudPhoneLayer.create( data )
    local layer = Box996CloudPhoneLayer.new()
    if layer and layer:Init(data) then
        return layer
    end
    return nil
end

function Box996CloudPhoneLayer:Init( data )
    self._root = CreateExport( "box996_ui/box996_cloud_phone_layer.lua" )
    if not self._root then
        return false
    end

    self:addChild( self._root )
    
    self._ui = ui_delegate( self._root )

    -- 领取按钮
    self._ui.Button_get.invalidZoomScale = true
    self._ui.Button_get:setZoomScale(1)
    self._ui.Button_get:addClickEventListener( function( sender )
        if self.mGeting then
            return
        end
        if self._proxy:getCloudPhoneReceiveFlag() then
            self:showGetRewardTips()
            return
        end
        self.mGeting = true
        self._proxy:requestCloudPhoneReceive()
        self._proxy:requestLogUp(self._proxy.BOX_UP_YUN_PHONE[3])
    end)

    -- 下载盒子
    self._ui.Button_download:addClickEventListener(function()
        -- 下载盒子        
        self._proxy:getBox996DownloadURL( 8 )
        self._proxy:requestLogUp(self._proxy.BOX_UP_YUN_PHONE[4])
    end)

    -- 已领取 知道按钮
    self._ui.Button_ok:addClickEventListener(function()
        local showIndex = SHOW_PANEL.GET_PANEL 
        self:updateShowPanel(showIndex)
    end)
    -- 不能领取  知道按钮
    self._ui.Button_konw:addClickEventListener(function()
    end)

    self._ui.Image_di:setTouchEnabled(true)
    self._ui.Image_di:addClickEventListener(function()
    end)

    local animId = 5110
    local anim = self:addAnim( self._ui.Button_get,animId )
    if anim then
        anim:setPosition( 112,6)
        anim:setScale(1.3)
    end

    local anim1 = self:addAnim( self._ui.Button_download,animId )
    if anim1 then
        anim1:setPosition( 85,6)
        anim1:setScale(1)
    end

    local anim2 = self:addAnim( self._ui.Button_ok,animId )
    if anim2 then
        anim2:setPosition( 112,6)
        anim2:setScale(1.3)
    end

    local isBoxOpen = self._proxy:isBoxOpen() == true
    self._ui.Button_download:setVisible(isBoxOpen ~= true)

    if isBoxOpen then
        local offSetX = -120
        local offSetXX = -75
        self._ui.Button_get:setPositionX(self._ui.Button_get:getPositionX() + offSetX)
        self._ui.Text_4:setPositionX(self._ui.Text_4:getPositionX() + offSetXX)
        self._ui.Text_get_time:setPositionX(self._ui.Text_get_time:getPositionX() + offSetXX)
    end


    local showIndex = SHOW_PANEL.GET_PANEL
    self:updateGetRewardButton()
    self:updateShowPanel(showIndex)

    if self._proxy:getCloudPhoneShow() then
        self._proxy:requestLogUp(self._proxy.BOX_UP_YUN_PHONE[2])
    end

    return true
end

function Box996CloudPhoneLayer:addAnim(parentNode,animId)
    if not animId then
        return
    end
    
    parentNode:removeChildByTag(animId)
    local anim = global.FrameAnimManager:CreateSFXAnim( animId )
    if anim then
        anim:setTag(animId)
        anim:Play( 0, 0, true )
        parentNode:addChild( anim )
    end
    return anim
end

function Box996CloudPhoneLayer:updateShowPanel( showIndex )
    showIndex = showIndex or SHOW_PANEL.GET_PANEL

    self._ui.Panel_get:setVisible( showIndex == SHOW_PANEL.GET_PANEL )
    self._ui.Panel_get_already:setVisible( showIndex == SHOW_PANEL.ALREADY_GET_PANEL )
    self._ui.Panel_get_not:setVisible( showIndex == SHOW_PANEL.NOT_GET_PANEL )

    if showIndex == SHOW_PANEL.GET_PANEL then
        self:updateCloudPhoneRewardTime()
        self:updateCloudPhoneGetTime()
    elseif showIndex == SHOW_PANEL.ALREADY_GET_PANEL then
        self:updateCloudPhoneAlreadyGet()
    end

    local showState = showIndex == SHOW_PANEL.ALREADY_GET_PANEL and 0 or 1
    global.Facade:sendNotification( global.NoticeTable.Layer_Box996Main_Refresh, {list_view_show_state = showState} )
end

function Box996CloudPhoneLayer:updateCloudPhoneRewardTime()
    -- 显示限时奖励时间

    -- AtlasLabel_time
    local time = self._proxy:getCloudPhoneRewardTime() or 0
    self._ui.AtlasLabel_time:setString( math.floor(time/60/60) )
end

function Box996CloudPhoneLayer:updateCloudPhoneGetTime()
    -- 领取倒计时
    -- Text_get_time

    self._ui.Text_get_time:stopAllActions()

    local time = self._proxy:getCloudPhoneRewardGetDownTime() or 0
    time = time - GetServerTime()
    if time < 0 then
        time = 0
    end

    self._ui.Text_get_time:setString( SecondToHMS(time, true) )

    schedule(self._ui.Text_get_time, function()
        time = time - 1
        if time < 0 then
            time = 0
            self._ui.Text_get_time:stopAllActions()
        end
        self._ui.Text_get_time:setString( SecondToHMS(time, true) )
    end, 1)
end

function Box996CloudPhoneLayer:showGetRewardTips()
    local isBoxOpen = self._proxy:isBoxOpen() == true
    if isBoxOpen then
        ShowSystemTips(GET_STRING(310000431))
        return false
    end

    local function callback(bType)
        if bType == 1 then
            local url = "https://996box.com"
            cc.Application:getInstance():openURL(url)
            self._proxy:requestLogUp(self._proxy.BOX_UP_YUN_PHONE[4])
        end
    end
    local time = self._proxy:getCloudPhoneRewardTime() or 0
    local data = {}
    data.str = GET_STRING(310000430)
    data.btnDesc = {GET_STRING(1002), GET_STRING(1000)}
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    return true
end

-- 已领取界面
function Box996CloudPhoneLayer:updateCloudPhoneAlreadyGet()
    -- 显示限时奖励时间

    -- AtlasLabel_time
    local time = self._proxy:getCloudPhoneRewardTime() or 0
    self._ui.AtlasLabel_time_2:setString( math.floor(time/60/60) )
end

function Box996CloudPhoneLayer:updateGetRewardButton()
    local isGetReceive = self._proxy:getCloudPhoneReceiveFlag()
    local imgPath = string.format("%sbox_996_ui/%s.png", global.MMO.PATH_RES_PRIVATE, isGetReceive and "hz_ylq" or "yun_phone_liji_lingqu")
    self._ui.Button_get:loadTextureNormal(imgPath)
    self._ui.Button_get:loadTexturePressed(imgPath)
end

function Box996CloudPhoneLayer:OnRefresh( data )
    
    if data.rewardTime then
        self:updateCloudPhoneRewardTime()
    end

    if data.getTime then
        self:updateCloudPhoneGetTime()
    end

    if data.getFinish then
        self.mGeting = false
        local showIndex = SHOW_PANEL.GET_PANEL 
        if self._proxy:getCloudPhoneReceiveFlag() then
            showIndex = SHOW_PANEL.ALREADY_GET_PANEL
        end
        self:updateGetRewardButton()
        self:updateShowPanel(showIndex)
    end
    
end

return Box996CloudPhoneLayer