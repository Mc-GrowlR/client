local ResolutionSizeChangeCommand = class('ResolutionSizeChangeCommand', framework.SimpleCommand)

local skillUtils = requireProxy("skillUtils")
local optionsUtils            = requireProxy("optionsUtils")

function ResolutionSizeChangeCommand:ctor()
end
-- 分辨率改变  游戏内调整
function ResolutionSizeChangeCommand:execute(notification)
    dump("ResolutionSizeChangeCommand___")
    local data = notification:getBody()
    local size = data.size
    local onlyAdapt = data.onlyAdapt
    local index = data.index
    if not onlyAdapt and not size then
        return
    end
    if not onlyAdapt and global.isWinPlayMode then
        local glview = cc.Director:getInstance():getOpenGLView()
        glview:setFrameSize(size.width, size.height)
        local frameSize    = size
        local frameFactor = frameSize.width / frameSize.height
        local designPolicy = cc.ResolutionPolicy.FIXED_HEIGHT
        if frameFactor > 1.8 then       -- 17:9 = 1.889
            designPolicy = cc.ResolutionPolicy.FIXED_HEIGHT
        else                            -- 16:9 = 1.778
            designPolicy = cc.ResolutionPolicy.FIXED_WIDTH
        end

        glview:setDesignResolutionSize(size.width, size.height, designPolicy)
        glview:setFrameZoomFactor(global.DeviceZoom_Win)
    end

    cc.Director:getInstance():setViewport()

    global.Facade:sendNotification(global.NoticeTable.WindowResized)
    SLBridge:onLUAEvent(LUA_EVENT_WINDOW_CHANGE)

    ---重新设置摄像机
    local camera = global.gameMapController:GetViewCamera()
    if camera then
        camera:autorelease()
        camera:removeFromParent()
        global.gameMapController:SetViewCamera(nil)
        local LayerFacadeMediator = global.Facade:retrieveMediator("LayerFacadeMediator")
        LayerFacadeMediator:InitGameWorldCamera()
        local SceneOptionsMediator = global.Facade:retrieveMediator("SceneOptionsMediator")
        local dieflag = SceneOptionsMediator:getDieFlag()
        if dieflag then
            SceneOptionsMediator:onMainPlayerRevive()
        end
        SceneOptionsMediator:Cleanup(true)
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        local newcamera = global.gameMapController:GetViewCamera()
        if mainPlayer and newcamera then
            local offset = global.gameMapController:GetViewCenterOffset()
            local playerPos = mainPlayer:getPosition()
            local tempPos = cc.pAdd(playerPos, offset)
            newcamera:setPosition(tempPos)
            global.sceneManager:SetCamera(newcamera)
            global.Facade:sendNotification(global.NoticeTable.BindMainPlayer, mainPlayer)
            -- global.Facade:sendNotification(global.NoticeTable.ReloadMap)
            if dieflag then
                SceneOptionsMediator:onMainPlayerDie()
            end
        end
    end

    --右键跑路区域 调整
    local RTouchLayerMediator = global.Facade:retrieveMediator("RTouchLayerMediator")
    if RTouchLayerMediator and RTouchLayerMediator._layer and RTouchLayerMediator._layer.panel then
        local sceneSize = cc.Director:getInstance():getVisibleSize()
        RTouchLayerMediator._layer.panel:setContentSize(sceneSize)
    end

    if not onlyAdapt and global.isWinPlayMode then
        global.DesignSize_Win = size
        global.L_GameEnvManager:SetGameEnvDataByKey("resolution", size.width .. "x" .. size.height)
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        GameSettingProxy:SetInnerChangedSize(true)

        --*登录器 的配置
        local ResolutionIni = global.L_GameEnvManager:GetEnvDataByKey("ResolutionIni")
        dump(ResolutionIni, "ResolutionIni__")
        if ResolutionIni and cc.FileUtils:getInstance():isFileExist(ResolutionIni) and index then
            local iniStr = cc.FileUtils:getInstance():getStringFromFile(ResolutionIni)
            local setStr = string.match(iniStr, "Resolution=%d")
            if setStr then
                iniStr = string.gsub(iniStr, setStr, "Resolution=" .. (index - 1))
                cc.FileUtils:getInstance():writeStringToFile(iniStr, ResolutionIni)
            end
        end
    end

    if size then
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        GameSettingProxy:RequestNotifySizeChange(size.width, size.height)
    end

end

return ResolutionSizeChangeCommand