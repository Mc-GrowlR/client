local BaseLayer = requireLayerUI( "BaseLayer" )
local CommunityLayer = class( "CommunityLayer", BaseLayer )

function CommunityLayer:ctor()
    CommunityLayer.super.ctor( self )
end

function CommunityLayer.create(noticeData)
    local layer = CommunityLayer.new()

    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function CommunityLayer:Init()
    self._ui = ui_delegate(self)
    local view = ccexp.CustomView or ccexp.WebView
    if not view then 
        ShowSystemTips(GET_STRING(600000900))
        return 
    end
    local device = "unknow"
    if global.isIOS then
        device= "ios"
    elseif global.isAndroid then 
        device = "android"
    elseif global.isWindows then 
        device = "pc"
        if not view.setWebToGameFunc then --老ie版本  打不开
            ShowSystemTips(GET_STRING(600000900))
            return 
        end
    end
    local offsetx = 10
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local gameid = AuthProxy:getGameId()
    local gameToken = AuthProxy:GetToken()
    local uid = AuthProxy:GetUID()
    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv = currentModule:GetGameEnv()
    local communityDetailsUrl = moduleGameEnv:GetCustomDataByKey("sqtz") or ""
    
    local url = string.format("%s&fromGameId=%s&gameToken=%s&device=%s&gameUid=%s",communityDetailsUrl,gameid,gameToken,device,uid) 
    dump(url,"url___")
    local winSize = global.Director:getWinSize()
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(cc.p(0,0))
    layout:setContentSize(winSize.width/3,winSize.height)
    layout:setPosition(offsetx ,0)
    layout:setBackGroundColor(cc.c3b(0xff, 0xff, 0xff))
    layout:setBackGroundColorType(1)
    layout:setBackGroundColorOpacity(50)
    self:addChild(layout)
    local webView = view:create()
    webView:setAnchorPoint(cc.p(0,0))
    webView:setContentSize(winSize.width/3,winSize.height)
    webView:setPosition(offsetx ,0)
    webView:loadURL(url)
    webView:setName("webView")
    self:addChild(webView)
    local Button_close = ccui.Button:create()
    Button_close:ignoreContentAdaptWithSize(false)
    Button_close:loadTextureNormal(global.MMO.PATH_RES_PUBLIC.."1900000510.png",0)
    Button_close:loadTexturePressed(global.MMO.PATH_RES_PUBLIC.."1900000511.png",0)
    Button_close:setAnchorPoint(cc.p(0,1))
    Button_close:setName("Button_close")
    Button_close:setPosition(winSize.width/3+offsetx, winSize.height)
    Button_close:addClickEventListener(function ()
        SL:CloseCommunityUI()
    end)
    self:addChild(Button_close)
    
    return true
end


return CommunityLayer