local skillUtils = requireProxy("skillUtils")
local proxyUtils = requireProxy("proxyUtils")

-- param: actor / actorID
local GetActor = function(param)
    if not param then
        return nil
    end
    if type(param) == "table" then
        return param
    end

    local actor = global.actorManager:GetActor(param)
    if not actor then
        return nil
    end
    return actor
end

local MetaValueGetDef = {
    -- 游戏基础信息
    ["SCREEN_WIDTH"] = function()
        return SL.OpenGUITXTEditor and 1136 or cc.Director:getInstance():getVisibleSize().width
    end,
    ["SCREEN_HEIGHT"] = function()
        return SL.OpenGUITXTEditor and 640 or cc.Director:getInstance():getVisibleSize().height
    end,
    ["SCREEN_SIZE"] = function()
        return cc.Director:getInstance():getVisibleSize()
    end,
    -- 刘海屏信息 返回参数1：是否是刘海屏 返回参数2：{x=坐标x,y=坐标y,width=刘海宽,height=刘海高}
    ["NOTCH_PHONE_INFO"] = function()
        return checkNotchPhone()
    end,
    ["PLATFORM"] = function()
        return global.Platform
    end,
    ["PLATFORM_ANDROID"] = function()
        return global.isAndroid
    end,
    ["PLATFORM_IOS"] = function()
        return global.isIOS
    end,
    ["PLATFORM_WINDOWS"] = function()
        return global.isWindows
    end,
    ["PLATFORM_MOBILE"] = function()
        return global.isMobile
    end,
    ["WINPLAYMODE"] = function()
        return global.isWinPlayMode
    end,
    ["IS_PC_PLAY_MODE"] = function()
        return global.isWinPlayMode
    end,
    ["CURRENT_OPERMODE"] = function()
        return global.CURRENT_OPERMODE
    end,
    ["GAME_ID"] = function()
        return global.L_ModuleManager:GetCurrentModule():GetOperID()
    end,
    ["CHANNEL_ID"] = function()
        local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
        return envProxy:GetChannelID()
    end,
    ["PROMOTE_ID"] = function()
        -- 推广员ID
        return global.L_GameEnvManager:GetGMName()
    end,
    ["PACKAGE_NAME"] = function()
        local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
        return envProxy:GetAPKPackageName()
    end,
    ["VERSION_NAME"] = function()
        local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
        return envProxy:GetAPKVersionName()
    end,
    ["VERSION_CODE"] = function()
        local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
        return envProxy:GetAPKVersionCode()
    end,
    ["IS_EMULATOR"] = function()
        return global.L_GameEnvManager:IsEmulator()
    end,
    ["FPS"] = function()
        return global.Director:getFrameRate()
    end,
    ["NET_TYPE"] = function()
        local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
        return envProxy:GetNetType() == 0 and 0 or 1
    end,
    ["BATTERY"] = function()
        local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
        return envProxy:GetBatteryLevel()
    end,
    ["996BOX_LOGIN"] = function()
        return global.L_GameEnvManager:GetEnvDataByKey("isBoxLogin") == 1
    end,
    ["996BOX_APPVERSION"] = function()
        local appVersion = tostring(global.L_GameEnvManager:GetEnvDataByKey("boxVersion"))
        if appVersion then
            local stringArr = string.split(appVersion,".")
            if #stringArr >= 3 then
                return tostring(stringArr[1]) .. "." .. tostring(stringArr[2]) .. "." .. tostring(stringArr[3])
            end
        end
        return "0"
    end,
    ["996_CLOUD_DEVICE"] = function()
        return global.L_GameEnvManager:GetEnvDataByKey("isCloudLogin")
    end,
    ["YIDUN_DATA"] = function()
        return global.L_GameEnvManager:GetEnvDataByKey("yd_data")
    end,
    ["SERVER_OPTION"] = function(param)
        return CHECK_SERVER_OPTION(param)
    end,
    ["GAME_DATA"] = function(param)
        return global.ConstantConfig[param]
    end,
    ["IS_SDK_LOGIN"] = function(param)
        local bSDKLogin = false
        local loginData = global.L_ModuleManager:GetCurrentModule():GetGameEnv():GetLoginData()
        if loginData and loginData.username and loginData.password then
            bSDKLogin = true
        end

        return bSDKLogin
    end,
    ["LOCAL_RES_VERSION"] = function()
        local currModule = global.L_ModuleManager:GetCurrentModule()
        return currModule:GetOriginVersion()
    end,
    ["REMOTE_RES_VERSION"] = function()
        local currModule = global.L_ModuleManager:GetCurrentModule()
        return currModule:GetRemoteVersion()
    end,
    ["REMOTE_GM_RES_VERSION"] = function()
        local currModule = global.L_ModuleManager:GetCurrentModule()
        local currentSubMod = currModule:GetCurrentSubMod()
        local versionStr = currentSubMod.GetRemoteVersion and currentSubMod:GetRemoteVersion() or ""
        return versionStr
    end,
    ["GAME_NAME"] = function()
        local currModule = global.L_ModuleManager:GetCurrentModule()
        if not currModule then
            return ""
        end 
        local currentSubMod = currModule:GetCurrentSubMod()
        if not currentSubMod then
            return ""
        end 
        local game_name = currentSubMod.GetName and currentSubMod:GetName() or ""
        return game_name
    end,
    ["DEVICE_UNIQUE_ID"] = function()
        if getMac then
            return getMac()
        end
    end,
    ["IOS_SUPPORT_SPINE"] = function()
        return global.LuaBridgeCtl:GetModulesSwitch(global.MMO.Modules_Index_Cpp_Version) >= global.MMO.CPP_VERSION_IOS_SPINE
    end,
    ----

    -- 服务器信息
    ["SERVER_ID"] = function()
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        return LoginProxy:GetSelectedServerId()
    end,
    ["SERVER_NAME"] = function()
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        return LoginProxy:GetSelectedServerName()
    end,
    ["MAIN_SERVER_ID"] = function()
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        return LoginProxy:GetMainSelectedServerId()
    end,
    ["RES_VERSION"] = function()
        return global.L_ModuleManager:GetCurrentModule():GetRemoteVersion()
    end,
    ["UID"] = function()
        local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
        return AuthProxy:GetUID()
    end,
    -- 登录角色信息
    ["LOGIN_DATA"] = function()
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        return LoginProxy:GetRoles()
    end,
    -- 可恢复角色信息
    ["RESTORE_ROLES"] = function()
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        return LoginProxy:getRestoreRoleDatas()
    end,
    -- M2是否禁止说话
    ["M2_FORBID_SAY"] = function(param)
        return IsForbidSay(param)
    end,
    ---

    -- 查看他人角色信息
    ["LOOK_USER_ID"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerUid()
    end,
    ["LOOK_USER_NAME"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerName()
    end,
    --他人名字颜色
    ["LOOK_USER_NAME_COLOR"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerNameColor()
    end,
    ---
    --英雄名字颜色
    ["HERO_NAME_COLOR"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetHeroNameColor()
    end,
    ---
    -- 当前地图信息
    ["MAP_ID"] = function()
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return MapProxy:GetMapID()
    end,
    ["MAP_NAME"] = function()
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return MapProxy:GetMapName()
    end,
    ["MAP_DATA_ID"] = function()
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return MapProxy:GetMapDataID()
    end,
    ["MINIMAP_ID"] = function()
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return MapProxy:GetMiniMapID()
    end,
    ["MINIMAP_ABLE"] = function()
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return MapProxy:CheckMiniMapAble()
    end,
    ["IN_SAFE_AREA"] = function()
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return MapProxy:IsInSafeArea()
    end,
    ["MAP_FORBID_LEVEL_AND_JOB"] = function()
        local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return mapProxy:IsForbidLvJob()
    end,
    -- 是否禁止说话
    ["MAP_FORBID_SAY"] = function()
        local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return mapProxy:IsForbidSay()
    end,
    -- 血量显示百分比
    ["MAP_SHOW_HPPER"] = function()
        local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return mapProxy:IsHPPercent()
    end,
    -- 是否禁止查看
    ["MAP_FORBID_LOOK"] = function()
        local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return mapProxy:IsForbidVisitPlayer()
    end,
    -- 是否禁止释放某技能
    ["MAP_FORBID_LAUNCH_SKILL"] = function(skillID)
        local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return mapProxy:IsForbidLaunchSkill(skillID)
    end,
    -- 地图 map 文件是否加载
    ["MAP_DATA_LOADED"] = function()
        local mapData = global.sceneManager:GetMapData2DPtr()
        return mapData ~= nil
    end,
    -- 地图横向格子数
    ["MAP_ROWS"] = function()
        local mapData = global.sceneManager:GetMapData2DPtr()
        if mapData then
            return mapData:getMapDataRows()
        end
    end,
    -- 地图纵向格子数
    ["MAP_COLS"] = function()
        local mapData = global.sceneManager:GetMapData2DPtr()
        if mapData then
            return mapData:getMapDataCols()
        end
    end,
    -- 获取地图文件
    ["MINIMAP_FILE"] = function()
        local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return mapProxy:GetMiniMapFile()
    end,
    -- 地图获取宽度像素
    ["MAP_SIZE_WIDTH_PIXEL"] = function()
        return global.sceneManager:GetMapWidthInPixel()
    end,
    -- 地图获取高度像素
    ["MAP_SIZE_HEIGHT_PIXEL"] = function()
        return global.sceneManager:GetMapHeightInPixel()
    end,
    -- 地图格子是否是阻挡
    ["MAP_IS_OBSTACLE"] = function(mapX, mapY)
        local mapData = global.sceneManager:GetMapData2DPtr()
        if mapData then
            return mapData:isObstacle(mapX, mapY) ~= 0
        end
    end,
    -- 地图计算起点到终点X或者Y 变化最大的差值
    ["MAP_PATH_SIZE"] = function()
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        return PlayerInputProxy:GetPathPointSize()
    end,
    -- 地图计算路径坐标 返回table
    ["MAP_PATH_POINTS"] = function()
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        return PlayerInputProxy:GetPathFindPoints() or {}
    end,
    -- 地图获取当前路径坐标index
    ["MAP_CURRENT_PATH_INDEX"] = function()
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        return PlayerInputProxy:GetCurrPathPoint()
    end,
    -- 地图获取人物坐标
    ["MAP_PLAYER_POS"] = function()
        local player = global.gamePlayerController:GetMainPlayer()
        if not player then
            return cc.p(0, 0)
        end
        return cc.p(player:getPosition())
    end,
    -- 地图获取怪物
    ["MAP_GET_MONSTERS"] = function()
        local MiniMapProxy = global.Facade:retrieveProxy(global.ProxyTable.MiniMapProxy)
        return MiniMapProxy:getMonsters()
    end,
    -- 地图获取NPC坐标
    ["MAP_GET_PORTALS"] = function()
        local MiniMapProxy = global.Facade:retrieveProxy(global.ProxyTable.MiniMapProxy)
        return MiniMapProxy:getPortals()
    end,
    -- 地图获取组队成员坐标信息
    ["MAP_GET_TEAMS"] = function()
        local MiniMapProxy = global.Facade:retrieveProxy(global.ProxyTable.MiniMapProxy)
        return MiniMapProxy:getTeams()
    end,
    -- 是否在攻城区域
    ["IN_SIEGE_AREA"] = function()
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        return MapProxy:IsInSiegeArea()
    end,
    ---

    -- 聊天
    -- 获取聊天表情包
    ["CHAT_EMOJI"] = function()
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return clone(ChatProxy:GetEmoji())
    end,
    -- 获取聊天输入历史记录缓存
    ["CHAT_INPUT_CACHE"] = function()
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return clone(ChatProxy:getInputCache())
    end,
    -- 获取聊天显示的道具
    ["CHAT_SHOW_ITEMS"] = function()
        local items         = {}
        local EquipProxy    = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local BagProxy      = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local equipData     = EquipProxy:GetEquipData()
        local bagData       = BagProxy:GetBagData()
        for k, v in pairs(equipData) do
            if v.chatshow ~= 1 then
                local item = clone(v)
                item.wore  = true
                table.insert(items, item)
            end
        end
        for k, v in pairs(bagData) do
            if v.chatshow ~= 1 then
                local item = clone(v)
                table.insert(items, item)
            end
        end
        return items
    end,
    -- 是否接收该频道聊天
    ["CHAT_CHANNEL_ISRECEIVE"] = function(channelID)
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return ChatProxy:isReceiving(channelID)
    end,
    -- 是否接收该分类掉落
    ["DROP_TYPE_ISRECEIVE"] = function(type)
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return ChatProxy:GetDropTypeSwitch(type)
    end,
    --聊天 tips 使用的字体
    ["CHATANDTIPS_USE_FONT"] = function()
        return global.ChatAndTips_Use_Font
    end,
    -- 聊天消息类型
    ["CHAT_MSGTYPE_ENUM"] = function()
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return clone(ChatProxy.MSG_TYPE)
    end,
    -- 聊天频道
    ["CHAT_CHANNEL_ENUM"] = function()
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return clone(ChatProxy.CHANNEL)
    end,
    -- 当前聊天频道
    ["CUR_CHAT_CHANNEL"] = function()
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return ChatProxy:getChannel()
    end,
    -- 聊天目标 table {{name = 玩家名, uid = 玩家ID}, ..}
    ["CHAT_TARGETS"] = function()
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return ChatProxy:getTargets()
    end,
    -- 当前频道聊天CD时间
    ["CHAT_CUR_CDTIME"] = function()
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return ChatProxy:GetCurrCDTime()
    end,
    -- 是否关闭假掉落
    ["IS_CLOSE_FAKEDROP"] = function()
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return ChatProxy:IsCloseFakeDrop()
    end,

    --------------------------------------------
    ["REDKEY"] = function(param)
        if param and string.len(param) > 0 then
            local RedPointProxy = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
            local value = RedPointProxy:TransValueByKey(param)
            return value
        end
        return param
    end,
    -- 脚本拉杆组件提供
    ["SLIDERV"] = function(param)
        local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
        return SUIComponentProxy:GetSUISliderValueById(param)
    end,

    -- PK模式
    ["PKMODE"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetPKMode()
    end,
    ["PKMODE_CAN_USE"] = function(param)
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerPropertyProxy:IsShowCurMode(param)
    end,

    -- 宝宝模式
    ["PET_PKMODE"] = function()
        local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        return SummonsProxy:GetMode()
    end,

    -- 宝宝模式
    ["PET_ALIVE"] = function()
        local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        return SummonsProxy:IsAlived()
    end,

    ["PET_LOCK_ID"] = function()
        local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        return SummonsProxy:GetLockTargetID()
    end,

    -- 在跨服状态
    ["KFSTATE"] = function()
        local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
        return ServerTimeProxy:IsKfState()
    end,
    -- 
    ["SERVER_TIME"] = function()
        return GetServerTime()
    end,
    -- 开服天数
    ["KFDAY"] = function()
        local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
        return ServerTimeProxy:GetOpenDay()
    end,

    -- 是否开启英雄
    ["USEHERO"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:IsHeroOpen()
    end,
    -- 是否召唤英雄
    ["HERO_IS_ALIVE"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:HeroIsLogin()
    end,
    -- 是否激活英雄
    ["HERO_IS_ACTIVE"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:getIsMakeHero()
    end,
    -- 英雄ID
    ["HERO_ID"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleUID()
    end,
    --英雄状态系统 能设置的值3个或四个
    ["HERO_STATES_SYS_VALUES"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getStatesSysSet()
    end,
    --英雄激活的状态列表
    ["HERO_ACTIVES_STATES"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getStates()
    end,
    --英雄状态
    ["HERO_STATE"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getHeroState()
    end,
    --英雄守护状态
    ["HERO_GUARDSTATE"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        local state = HeroPropertyProxy:getHeroGuardState()
        return tonumber(state) == 1
    end,
    --是否点击了英雄守护按钮 
    ["HERO_GUARD_ISCLICK"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getGuardBtnState()
    end,
    -- 道具信息
    ["MONEY"] = function(param)
        local itemIndex = nil
        if not param then
            return "ERROR MONEY "
        end
        if not tonumber(param) and string.find(param, ",") then
            local indexList = string.split(param, ",")
            local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
            local totalCount = 0
            for _, index in ipairs(indexList) do
                if index and tonumber(index) then
                    totalCount = totalCount + PayProxy:GetItemCount(tonumber(index))
                end
            end
            return tostring(totalCount)
        end
        if not tonumber(param) then
            local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
            itemIndex = MoneyProxy:GetMoneyIdByName(param)
        end
        if tonumber(param) then
            itemIndex = tonumber(param)
        end
        if not itemIndex then
            return "ERROR MONEY " .. param
        end
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        local count    = PayProxy:GetItemCount(itemIndex)
        return tostring(count)
    end,
    ["MONEYEX"] = function(param)
        local itemIndex = nil
        if not param then
            return "ERROR MONEYEX "
        end
        if not tonumber(param) and string.find(param, ",") then
            local indexList = string.split(param, ",")
            local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
            local totalCount = 0
            for _, index in ipairs(indexList) do
                if index and tonumber(index) then
                    totalCount = totalCount + PayProxy:GetItemCount(tonumber(index))
                end
            end
            return string.formatnumberthousands(totalCount)
        end
        if not tonumber(param) then
            local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
            itemIndex = MoneyProxy:GetMoneyIdByName(param)
        end
        if tonumber(param) then
            itemIndex = tonumber(param)
        end
        if not itemIndex then
            return "ERROR MONEYEX " .. param
        end
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        local count    = PayProxy:GetItemCount(itemIndex)
        return string.formatnumberthousands(count)
    end,
    ["MONEY_ASSOCIATED"] = function(param)
        local itemIndex = nil
        if not param then
            return "ERROR MONEY "
        end
        if not tonumber(param) and string.find(param, ",") then
            local indexList = string.split(param, ",")
            local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
            local totalCount = 0
            for _, index in ipairs(indexList) do
                if index and tonumber(index) then
                    totalCount = totalCount + PayProxy:GetItemCount(tonumber(index), true)
                end
            end
            return tostring(totalCount)
        end
        if not tonumber(param) then
            local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
            itemIndex = MoneyProxy:GetMoneyIdByName(param)
        end
        if tonumber(param) then
            itemIndex = tonumber(param)
        end
        if not itemIndex then
            return "ERROR MONEY " .. param
        end
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        local count    = PayProxy:GetItemCount(itemIndex, true)
        return tostring(count)
    end,
    ["STD_ITEMS"] = function()
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        return ItemConfigProxy:GetItemGMConfigData()
    end,
    ["ITEM_DATA"] = function(param)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        return ItemConfigProxy:GetItemDataByIndex(param)
    end,
    -- 道具框默认缩放
    ["ITEM_SCALE"] = function()
        return global.isWinPlayMode and global.MMO.GOODSITEM_SCALE_WIN or global.MMO.GOODSITEM_SCALE
    end,
    -- 脚本用
    ["ITEMCOUNT"] = function(param)
        local itemIndex = nil
        if not param then
            return "ERROR ITEM COUNT "
        end
        if not tonumber(param) then
            local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
            itemIndex = ItemConfigProxy:GetItemIndexByName(param)
        end
        if tonumber(param) then
            itemIndex = tonumber(param)
        end
        if not itemIndex then
            return "ERROR ITEM COUNT " .. param
        end
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        local count    = PayProxy:GetItemCount(itemIndex)
        return tostring(count)
    end,
    ["ITEM_COUNT"] = function(param)
        local itemIndex = nil
        if not tonumber(param) then
            local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
            itemIndex = ItemConfigProxy:GetItemIndexByName(param)
        end
        if tonumber(param) then
            itemIndex = tonumber(param)
        end
        if not itemIndex then
            return 0
        end
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        return PayProxy:GetItemCount(itemIndex)
    end,
    ["ITEM_NAME"] = function(param)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local itemInfo = ItemConfigProxy:GetItemDataByIndex(tonumber(param))
        return itemInfo.Name or "ERROR_ITEM_NAME"
    end,
    ["ITEM_INDEX_BY_NAME"] = function(param)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        return ItemConfigProxy:GetItemIndexByName(param)
    end,
    ["ITEM_NAME_COLOR"] = function(param)
        local itemIndex = tonumber(param)
        if not itemIndex then
            return "ERROR_ITEM_COLOR_INDEX"
        end
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local itemInfo = ItemConfigProxy:GetItemDataByIndex(itemIndex)
        if not itemInfo or not next(itemInfo) then
            return "ERROR_ITEM_NAME"
        end

        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local itemName = ItemConfigProxy:GetItemNameByIndex(itemIndex)
        local colorhex = ItemConfigProxy:GetItemNameColor(itemIndex)
        return "<font color ='" .. colorhex .. "'  >" .. itemName .. "</font>"
    end,
    --道具名字颜色
    ["ITEM_NAME_COLOR_VALUE"] = function(param)
        local itemIndex = tonumber(param)
        if not itemIndex then
            return "ERROR_ITEM_COLOR_INDEX"
        end
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local itemInfo = ItemConfigProxy:GetItemDataByIndex(itemIndex)
        if not itemInfo or not next(itemInfo) then
            return "ERROR_ITEM_NAME"
        end
        return ItemConfigProxy:GetItemNameColor(itemIndex)
    end,
    ["ITEM_NAME_COLORID"] = function(param)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        return ItemConfigProxy:GetItemNameColorId(tonumber(param))
    end,
    ["ITEM_PROMPT_DATA"] = function()
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local tipsData = BagProxy:GetPromptGameData()
        return clone(tipsData)
    end,
    ["ITEM_CUSTOM_ATTR"] = function(param)
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        return BagProxy:GetCustomAttrData(param)
    end,
    -- 检查物品是否绑定
    ["ITEM_IS_BIND"] = function(param1, param2)
        return CheckItemisBind(param1, param2)
    end,
    ["TMONEY"] = function(param)
        if not param then
            return "ERROR TMONEY "
        end
        if not tonumber(param) and string.find(param, ",") then
            local indexList = string.split(param, ",")
            local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
            local totalCount = 0
            for _, index in ipairs(indexList) do
                if index and tonumber(index) then
                    totalCount = totalCount + PayProxy:GetItemCount(tonumber(index))
                end
            end
            return tostring(totalCount)
        end
        local itemIndex = nil
        if not tonumber(param) then
            local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
            itemIndex = MoneyProxy:GetMoneyIdByName(param)
        end
        if tonumber(param) then
            itemIndex = tonumber(param)
        end
        if not itemIndex then
            return "ERROR TMONEY " .. param
        end
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        local count    = PayProxy:GetItemCount(itemIndex)
        return tostring(count)
    end,
    ["TITEMCOUNT"] = function(param)
        if not param then
            return "ERROR TITEM COUNT "
        end
        local itemIndex = nil
        if not tonumber(param) then
            local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
            itemIndex = ItemConfigProxy:GetItemIndexByName(param)
        end
        if tonumber(param) then
            itemIndex = tonumber(param)
        end
        if not itemIndex then
            return "ERROR TITEM COUNT " .. param
        end
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        local count    = PayProxy:GetItemCount(itemIndex)
        return tostring(count)
    end,

    -- 角色信息
    ["USER_ID"] = function()
        return global.gamePlayerController:GetMainPlayerID()
    end,
    ["MAIN_ACTOR_ID"] = function()
        return global.gamePlayerController:GetMainPlayerID()
    end,
    ["USER_NAME"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetName()
    end,
    ["JOB"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleJob()
    end,
    ["LEVEL"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleLevel()
    end,
    ["RELEVEL"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleReinLv()
    end,
    -- 获取职业名称
    ["JOB_NAME"] = function(job)
        if not job then
            local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
            return PlayerProperty:GetRoleJobName()
        end
        return GetJobName(tonumber(job))
    end,
    ["SEX"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleSex()
    end,
    --玩家真实名字
    ["REAL_USER_NAME"] = function()
        local loginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        return loginProxy:GetSelectedRoleName()
    end,
    --玩家名字颜色
    ["USER_NAME_COLOR"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetMainPlayerNameColor()
    end,
    -- 角色是否死亡
    ["USER_IS_DIE"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return not PlayerProperty:IsAlive()
    end,
    -- 角色是否能复活
    ["USER_IS_CANREVIVE"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:IsCanRevive()
    end,
    ["DIR"] = function()
        local player = global.gamePlayerController:GetMainPlayer()
        if not player then
            return global.MMO.ORIENT_INVAILD
        end
        return player:GetDirection()
    end,
    ["HP"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleCurrHP()
    end,
    ["MP"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleCurrMP()
    end,
    ["AC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Min_DEF)
        return value
    end,
    ["MAXAC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Max_DEF)
        return value
    end,
    ["MAC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Min_MDF)
        return value
    end,
    ["MAXMAC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Max_MDF)
        return value
    end,
    ["DC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Min_ATK)
        return value
    end,
    ["MAXDC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Max_ATK)
        return value
    end,
    ["MC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Min_MAT)
        return value
    end,
    ["MAXMC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Max_MAT)
        return value
    end,
    ["SC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Min_Daoshu)
        return value
    end,
    ["MAXSC"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Max_Daoshu)
        return value
    end,
    ["HIT"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Hit_Point)
        return value
    end,
    ["SPD"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Speed_Point)
        return value
    end,
    ["HITSPD"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Hit_Speed)
        return value
    end,
    ["BURST"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleAttByAttType(GUIFunction:PShowAttType().Double_Rate)
    end,
    ["BURST_DAM"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleAttByAttType(GUIFunction:PShowAttType().Double_Damage)
    end,
    ["IMM_ATT"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleAttByAttType(GUIFunction:PShowAttType().ATK_Defence)
    end,
    ["IMM_MAG"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleAttByAttType(GUIFunction:PShowAttType().MAT_Defence)
    end,
    ["MAXHP"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local value = PlayerProperty:GetRoleMaxHP()
        return value
    end,
    ["MAXMP"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local value = PlayerProperty:GetRoleMaxMP()
        return value
    end,
    ["EXP"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local value = PlayerProperty:GetCurrExp()
        return value
    end,
    ["MAXEXP"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local value = PlayerProperty:GetNeedExp()
        return value
    end,
    ["HW"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Hand_Weight)
        return value
    end,
    ["MAXHW"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Max_Hand_Weight)
        return value
    end,
    ["BW"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Weight)
        return value
    end,
    ["MAXBW"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Max_Weight)
        return value
    end,
    ["WW"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Wear_Weight)
        return value
    end,
    ["MAXWW"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Max_Wear_Weight)
        return value
    end,
    ["HUNGER"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Health_Recover)
        return value
    end,
    ["LUCK"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local AttrType = GUIFunction:PShowAttType()
        local value    = PlayerProperty:GetRoleAttByAttType(AttrType.Lucky)
        return value
    end,
    ["DRESS"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_Dress)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["WEAPON"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_Weapon)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["RIGHTHAND"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_RightHand)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["HELMET"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_Helmet)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["NECKLACE"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_Necklace)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["RINGR"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_RingR)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["RINGL"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_RingL)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["ARMRINGR"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_ArmRingR)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["ARMRINGL"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_ArmRingL)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["BUJUK"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_Bujuk)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["BELT"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_Belt)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["BOOTS"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_Boots)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["CHARM"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local posConfig = EquipProxy:GetEquipTypeConfig()
        local edata = EquipProxy:GetEquipDataByPos(posConfig.Equip_Type_Charm)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["X"] = function()
        local player = global.gamePlayerController:GetMainPlayer()
        if not player then
            return "invalid"
        end
        return player:GetMapX()
    end,
    ["Y"] = function()
        local player = global.gamePlayerController:GetMainPlayer()
        if not player then
            return "invalid"
        end
        return player:GetMapY()
    end,
    ["EQUIPBYPOS"] = function(param)
        if not param then
            return "ERROR EQUIP BY POS "
        end
        if not tonumber(param) then
            return "ERROR EQUIP BY POS " .. param
        end
        local pos = tonumber(param)
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local edata = EquipProxy:GetEquipDataByPos(pos)
        if not edata then
            return ""
        end
        return edata.Name
    end,
    ["EX_ATTR"] = function()--脚本变量额外属性
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetVariableInfo()
    end,
    ["ATT_BY_TYPE"] = function(param)--根据类型获取属性值
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleAttByAttType(tonumber(param))
    end,
    ["EQUIP_DATA"] = function(param1, param2)
        if not param1 then
            return
        end
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        if tonumber(param1) then
            return EquipProxy:GetEquipDataByPos(param1, param2)
        else
            return EquipProxy:GetEquipDataByName(param1)
        end
    end,
    ["EQUIP_DATA_LIST"] = function(param1)
        if not param1 then
            return
        end
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        return EquipProxy:GetEquipDataPosDataList(param1)
    end,
    -- 法阵
    ["EMBATTLE"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        return EquipProxy:GetEmbattle()
    end,
    --外观
    ["FEATURE"] = function()
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerPropertyProxy:GetFeature()
    end,
    --发型
    ["HAIR"] = function()
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerPropertyProxy:GetFeature().hairID
    end,
    --装备位数据Makeindex
    ["EQUIP_POS_DATAS"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        return EquipProxy:GetEquipPosData()
    end,
    ---获取激活的称号
    ["ACTIVATE_TITLE"] = function()
        local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
        return PlayerTitleProxy:getActivateTitle()
    end,
    -- 获取当前查看玩家的称号
    ["TITLES"] = function()
        local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
        return PlayerTitleProxy:getTitleList()
    end,
    -- 获取对应ID的称号数据
    ["TITLE_DATA_BY_ID"] = function(id)
        if not id then
            return
        end
        local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
        return PlayerTitleProxy:getTitleData()[id]
    end,
    -- 内功
    ["INTERNAL_FORCE"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetInternalData().force
    end,
    ["INTERNAL_MAXFORCE"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetInternalData().maxForce
    end,
    ["INTERNAL_EXP"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetInternalData().exp
    end,
    ["INTERNAL_MAXEXP"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetInternalData().maxExp
    end,
    ["INTERNAL_LEVEL"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetInternalData().level
    end,
    ["INTERNAL_DZ_CURVALUE"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetRoleAttByAttType(GUIFunction:PShowAttType().Internal_DZValue)
    end,
    ["INTERNAL_DZ_MAXVALUE"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetInternalData().maxDZValue
    end,
    ["INTERNAL_SKILLS"] = function()
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetNGSkillsList()
    end,
    ["INTERNAL_SKILL_DATA"] = function(skillID, skillType)
        if not skillID or not skillType then
            return nil
        end
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetNGSkillData(skillID, skillType)
    end,
    --获取内功技能等级熟练度数据
    ["INTERNAL_SKILL_TRAIN_DATA"] = function(skillID, skillType)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetNGSkillTrainData(skillID, skillType)
    end,
    --获取内功技能开关
    ["INTERNAL_SKILL_ONOFF"] = function(skillID, skillType)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetNGSkillOnOff(skillID, skillType)
    end,
    -- 内功技能矩形图标
    ["INTERNAL_SKILL_RECT_ICON_PATH"] = function(skillID, skillType)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetNGIconRectPath(skillID, skillType)
    end,
    -- 内功技能名字
    ["INTERNAL_SKILL_NAME"] = function(skillID, skillType)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetNGSkillName(skillID, skillType) or ""
    end,
    -- 内功技能描述
    ["INTERNAL_SKILL_DESC"] = function(skillID, skillType)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetNGSkillDesc(skillID, skillType)
    end,
    -- 内功-经络(穴位描述)
    ["MERIDIAN_DESC"] = function()
        local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
        return MeridianProxy:GetTipsConfig()
    end,
    -- 内功- 经络 穴位是否激活列表
    ["MERIDIAN_AUCPOINT_STATE"] = function(param1)
        local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
        return MeridianProxy:GetAucPointStateByType(param1)
    end,
    -- 内功- 经络 各个开关状态列表
    ["MERIDIAN_OPEN_LIST"] = function()
        local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
        return MeridianProxy:GetMeridianOpenList()
    end,
    -- 内功- 经络 获取对应等级
    ["MERIDIAN_LV"] = function(type)
        local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
        return MeridianProxy:GetMeridianLvByType(type)
    end,
    -- 内功- 所有拥有连击技能
    ["HAVE_COMBO_SKILLS"] = function()
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetComboSkills()
    end,
    -- 对应连击技能数据
    ["COMBO_SKILL_DATA"] = function(param1)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetComboSkillByID(param1)
    end,
    -- 连击技能等级熟练度数据
    ["COMBO_SKILL_TRAIN_DATA"] = function(skillID)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetComboSkillTrainData(skillID)
    end,
    -- 内功- 设置连击技能
    ["SET_COMBO_SKILLS"] = function()
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:haveSetComboSkill()
    end,
    ["OPEN_COMBO_NUM"] = function()
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetComboOpenNum()
    end,
    -- 可释放连击状态
    ["CAN_LAUNCH_COMBO"] = function()
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetlaunchComboStatus()
    end,
    -- 连击格子额外加暴击几率
    ["EXTRA_COMBO_BJRATE"] = function(index)
        local PlayerProperty = global.Facade:retrieveProxy("PlayerProperty")
        return PlayerProperty:GetComboExtraBJRate(index)
    end,
    -- 玩家属性初始化完成
    ["PLAYER_INITED"] = function()
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerPropertyProxy:IsInited()
    end,

    -- 英雄
    ["H.ATT_BY_TYPE"] = function(param)--根据类型获取属性值
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(param)
    end,
    -- 获取当前查看玩家的称号
    ["H.TITLES"] = function()
        local HeroTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroTitleProxy)
        return HeroTitleProxy:getTitleList()
    end,
    ---获取激活的称号
    ["H.ACTIVATE_TITLE"] = function()
        local HeroTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroTitleProxy)
        return HeroTitleProxy:getActivateTitle()
    end,
    -- 技能名字
    ["H.SKILL_NAME"] = function(param)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetSkillNameByID(param) or ""
    end,
    --获取技能等级熟练度数据
    ["H.SKILL_TRAIN_DATA"] = function(param1)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetSkillTrainData(param1)
    end,
    --已学技能(noBasicSkill, activeOnly)
    ["H.LEARNED_SKILLS"] = function(param1, param2)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetSkills(param1, param2)
    end,
    --获取技能数据
    ["H.SKILL_DATA"] = function(param1)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetSkillByID(param1)
    end,
    --获取技能快捷键
    ["H.SKILL_KEY"] = function(param1)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetSkillKey(param1)
    end,
    ["H.ANGER"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getCurAnger()
    end,
    ["H.MAXANGER"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getMaxAnger()
    end,
    ["H.USERNAME"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetName()
    end,
    ["H.LEVEL"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleLevel()
    end,
    ["H.RELEVEL"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleReinLv()
    end,
    ["H.EXP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetCurrExp()
    end,
    ["H.MAXEXP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetNeedExp()
    end,
    ["H.JOBNAME"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleJobName()
    end,
    ["H.JOB"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleJob()
    end,
    ["H.SEX"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleSex()
    end,
    ["H.HAIR"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetFeature().hairID
    end,
    ["H.MAXHP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleMaxHP()
    end,
    ["H.MAXMP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleMaxMP()
    end,
    ["H.HP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleCurrHP()
    end,
    ["H.MP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleCurrMP()
    end,
    ["H.HPPercent"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleHPPercent()
    end,
    ["H.MPPercent"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleMPPercent()
    end,
    ["H.EXPPercent"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleEXPPercent()
    end,
    ["H.MIN_ATK"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Min_ATK)
    end,
    ["H.MAX_ATK"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_ATK)
    end,
    ["H.MIN_MAT"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Min_MAT)
    end,
    ["H.MAX_MAT"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_MAT)
    end,
    ["H.MIN_DAO"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Min_Daoshu)
    end,
    ["H.MAX_DAO"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Daoshu)
    end,
    ["H.MIN_DEF"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MIN_DEF)
    end,
    ["H.MAX_DEF"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MAX_DEF)
    end,
    ["H.MIN_MDF"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MIN_MDF)
    end,
    ["H.MAX_MDF"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MAX_MDF)
    end,
    ["H.HIT"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Hit_Point)
    end,
    ["H.HITSPD"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Hit_Speed)
    end,
    ["H.BURST"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Double_Rate)
    end,
    ["H.BURST_DAM"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Double_Damage)
    end,
    ["H.IMM_ATT"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().ATK_Defence)
    end,
    ["H.IMM_MAG"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MAT_Defence)
    end,
    ["H.SUCK_HP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Monster_Suck_HP_Rate)
    end,
    ["H.LUCK"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetHeroLuck()
    end,
    ["H.DROP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Mon_Bj_Power_Rate)
    end,
    -- 腕力
    ["H.HW"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Hand_Weight)
    end,
    ["H.MAXHW"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Hand_Weight)
    end,
    ["H.BW"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Weight)
    end,
    ["H.MAXBW"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Weight)
    end,
    ["H.WW"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Wear_Weight)
    end,
    ["H.MAXWW"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Wear_Weight)
    end,
    ["H.SHAN"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getShan()
    end,
    ["H.SPEED"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getSpeed()
    end,
    ["H.DELAYT"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getDelayTime()
    end,
    ["H.EQUIP_DATA"] = function(param1, param2)
        if not param1 then
            return
        end
        local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        if tonumber(param1) then
            return HeroEquipProxy:GetEquipDataByPos(param1, param2)
        else
            return HeroEquipProxy:GetEquipDataByName(param1)
        end
    end,
    -- 法阵
    ["H.EMBATTLE"] = function()
        local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        return HeroEquipProxy:GetEmbattle()
    end,
    ["H.EQUIP_DATA_LIST"] = function(param1)
        if not param1 then
            return
        end
        local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        return HeroEquipProxy:GetEquipDataPosDataList(param1)
    end,
    --装备位数据Makeindex
    ["H.EQUIP_POS_DATAS"] = function()
        local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        return HeroEquipProxy:GetEquipPosData()
    end,
    -- 英雄 技能图标
    ["H.SKILL_ICON_PATH"] = function(param, isCombo)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetIconPathByID(param, isCombo)
    end,
    -- 英雄技能矩形图标
    ["H.SKILL_RECT_ICON_PATH"] = function(skillID, isCombo)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetIconRectPathByID(skillID, isCombo)
    end,
    -- 内功
    ["H.INTERNAL_FORCE"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetInternalData().force
    end,
    ["H.INTERNAL_MAXFORCE"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetInternalData().maxForce
    end,
    ["H.INTERNAL_EXP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetInternalData().exp
    end,
    ["H.INTERNAL_MAXEXP"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetInternalData().maxExp
    end,
    ["H.INTERNAL_LEVEL"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetInternalData().level
    end,
    ["H.INTERNAL_DZ_CURVALUE"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Internal_DZValue)
    end,
    ["H.INTERNAL_DZ_MAXVALUE"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetInternalData().maxDZValue
    end,
    ["H.INTERNAL_SKILLS"] = function()
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetNGSkillsList()
    end,
    ["H.INTERNAL_SKILL_DATA"] = function(skillID, skillType)
        if not skillID or not skillType then
            return nil
        end
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetNGSkillData(skillID, skillType)
    end,
    --获取内功技能等级熟练度数据
    ["H.INTERNAL_SKILL_TRAIN_DATA"] = function(skillID, skillType)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetNGSkillTrainData(skillID, skillType)
    end,
    --获取内功技能开关
    ["H.INTERNAL_SKILL_ONOFF"] = function(skillID, skillType)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetNGSkillOnOff(skillID, skillType)
    end,
    -- 内功技能矩形图标
    ["H.INTERNAL_SKILL_RECT_ICON_PATH"] = function(skillID, skillType)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetNGIconRectPath(skillID, skillType)
    end,
    -- 内功技能名字
    ["H.INTERNAL_SKILL_NAME"] = function(skillID, skillType)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetNGSkillName(skillID, skillType) or ""
    end,
    -- 内功技能描述
    ["H.INTERNAL_SKILL_DESC"] = function(skillID, skillType)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetNGSkillDesc(skillID, skillType)
    end,
    -- 内功- 经络 穴位是否激活列表
    ["H.MERIDIAN_AUCPOINT_STATE"] = function(param1)
        local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
        return MeridianProxy:GetAucPointStateByType(param1, true)
    end,
    -- 内功- 经络 各个开关状态列表
    ["H.MERIDIAN_OPEN_LIST"] = function()
        local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
        return MeridianProxy:GetMeridianOpenList(true)
    end,
    -- 内功- 经络 获取对应等级
    ["H.MERIDIAN_LV"] = function(type)
        local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
        return MeridianProxy:GetMeridianLvByType(type, true)
    end,
    -- 内功- 所有拥有连击技能
    ["H.HAVE_COMBO_SKILLS"] = function()
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetComboSkills()
    end,
    -- 对应连击技能数据
    ["H.COMBO_SKILL_DATA"] = function(param1)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetComboSkillByID(param1)
    end,
    -- 连击技能等级熟练度数据
    ["H.COMBO_SKILL_TRAIN_DATA"] = function(skillID)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetComboSkillTrainData(skillID)
    end,
    -- 内功- 设置连击技能
    ["H.SET_COMBO_SKILLS"] = function()
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:haveSetComboSkill()
    end,
    ["H.OPEN_COMBO_NUM"] = function()
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:GetComboOpenNum()
    end,
    -- 英雄属性初始化完成
    ["HERO_INITED"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:IsInited()
    end,
    -- 英雄锁定ACTORID
    ["H.LOCK_TARGET_ID"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:getLockID()
    end,


    -- 交易行玩家
    --交易行他人名字颜色
    ["T.M.USERNAME_COLOR"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerNameColor()
    end,
    -- 获取当前查看玩家的称号
    ["T.M.TITLES"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerTitle()
    end,
    -- 获取当前查看玩家激活的称号
    ["T.M.ACTIVATE_TITLE"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerTitleActive()
    end,
    --获取技能等级熟练度数据
    ["T.M.SKILL_TRAIN_DATA"] = function(param1)
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetSkillTrainData(param1)
    end,
    --获取技能数据
    ["T.M.SKILL_DATA"] = function(param1)
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetSkillByID(param1)
    end,
    --已学技能(noBasicSkill, activeOnly)
    ["T.M.LEARNED_SKILLS"] = function(param1, param2)
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetSkills(param1, param2)
    end,
    ["T.M.ATT_BY_TYPE"] = function(param)--根据类型获取属性
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(param)
    end,
    -- 获取正在查看玩家的装备位数据
    ["T.M.EQUIP_POS_DATAS"] = function(param1)
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerItemPosData()
    end,
    ["T.M.EQUIP_DATA"] = function(param1, param2)
        if not param1 then
            return
        end
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        if tonumber(param1) then
            return TradingBankLookPlayerProxy:GetLookPlayerItemDataByPos(param1, param2)
        else
            return TradingBankLookPlayerProxy:GetEquipDataByName(param1)
        end
    end,
    ["T.M.EQUIP_DATA_LIST"] = function(param1)
        if not tonumber(param1) then
            return
        end
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerItemDataList(param1)
    end,
    -- 通过MakeIndex获取查看交易行他人装备数据 
    ["T.M.EQUIP_DATA_BY_MAKEINDEX"] = function(param1)
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerItemDataByMakeIndex(param1)
    end,

    ["T.M.GUILD_INFO"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        local data = {}
        data.rankName = TradingBankLookPlayerProxy:GetLookPlayerGuildRankName()       -- 职位
        data.guildName = TradingBankLookPlayerProxy:GetLookPlayerGuildName()      -- 行会名字
        return data
    end,
    ["T.M.HAIR"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerHair()
    end,
    ["T.M.SEX"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerSex()
    end,
    ["T.M.USERNAME"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerName()
    end,
    ["T.M.LEVEL"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleLevel()
    end,
    ["T.M.RELEVEL"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleReinLv()
    end,
    ["T.M.EXP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetCurrExp()
    end,
    ["T.M.MAXEXP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetNeedExp()
    end,
    ["T.M.JOB"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleJobName()
    end,
    ["T.M.MAXHP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleMaxHP()
    end,
    ["T.M.MAXMP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleMaxMP()
    end,
    ["T.M.HP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleCurrHP()
    end,
    ["T.M.MP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleCurrMP()
    end,
    ["T.M.MIN_ATK"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Min_ATK)
    end,
    ["T.M.MAX_ATK"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_ATK)
    end,
    ["T.M.MIN_MAT"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Min_MAT)
    end,
    ["T.M.MAX_MAT"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_MAT)
    end,
    ["T.M.MIN_DAO"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Min_Daoshu)
    end,
    ["T.M.MAX_DAO"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Daoshu)
    end,
    ["T.M.MIN_DEF"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MIN_DEF)
    end,
    ["T.M.MAX_DEF"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MAX_DEF)
    end,
    ["T.M.MIN_MDF"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MIN_MDF)
    end,
    ["T.M.MAX_MDF"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MAX_MDF)
    end,
    ["T.M.HIT"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Hit_Point)
    end,
    ["T.M.HITSPD"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Hit_Speed)
    end,
    ["T.M.BURST"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Double_Rate)
    end,
    ["T.M.BURST_DAM"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Double_Damage)
    end,
    ["T.M.IMM_ATT"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().ATK_Defence)
    end,
    ["T.M.IMM_MAG"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MAT_Defence)
    end,
    ["T.M.SUCK_HP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Monster_Suck_HP_Rate)
    end,
    ["T.M.LUCK"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Lucky)
    end,
    -- 腕力
    ["T.M.HW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Hand_Weight)
    end,
    ["T.M.MAXHW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Hand_Weight)
    end,
    ["T.M.BW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Weight)
    end,
    ["T.M.MAXBW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Weight)
    end,
    ["T.M.WW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Wear_Weight)
    end,
    ["T.M.MAXWW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Wear_Weight)
    end,

    -- 交易行英雄
    -- 获取当前查看玩家的称号
    ["T.H.TITLES"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerTitle_Hero()
    end,
    -- 获取当前查看玩家激活的称号
    ["T.H.ACTIVATE_TITLE"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerTitleActive_Hero()
    end,
    --获取技能等级熟练度数据
    ["T.H.SKILL_TRAIN_DATA"] = function(param1)
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetSkillTrainData_Hero(param1)
    end,
    --获取技能数据
    ["T.H.SKILL_DATA"] = function(param1)
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetSkillByID_Hero(param1)
    end,
    --已学技能(noBasicSkill, activeOnly)
    ["T.H.LEARNED_SKILLS"] = function(param1, param2)
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetSkills_Hero(param1, param2)
    end,
    ["T.H.ATT_BY_TYPE"] = function(param)--根据类型获取属性
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(param)
    end,
    ["T.H.HAIR"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerHair_Hero()
    end,
    ["T.H.SEX"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerSex_Hero()
    end,
    -- 获取交易行英雄的装备位数据
    ["T.H.EQUIP_POS_DATAS"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerItemPosData_Hero()
    end,
    ["T.H.EQUIP_DATA"] = function(param1, param2)
        if not param1 then
            return
        end
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        if tonumber(param1) then
            return TradingBankLookPlayerProxy:GetLookPlayerItemDataByPos_Hero(param1, param2)
        else
            return TradingBankLookPlayerProxy:GetEquipDataByName_Hero(param1)
        end
    end,
    ["T.H.EQUIP_DATA_BY_MAKEINDEX"] = function(param1)
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerItemDataByMakeIndex_Hero(param1)
    end,
    ["T.H.EQUIP_DATA_LIST"] = function(param1)
        if not tonumber(param1) then
            return
        end
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerItemDataList_Hero(param1)
    end,
    ["T.H.USERNAME"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetLookPlayerName_Hero()
    end,
    ["T.H.LEVEL"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleLevel_Hero()
    end,
    ["T.H.RELEVEL"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleReinLv_Hero()
    end,
    ["T.H.EXP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetCurrExp_Hero()
    end,
    ["T.H.MAXEXP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetNeedExp_Hero()
    end,
    ["T.H.JOB"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleJobName_Hero()
    end,
    ["T.H.MAXHP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleMaxHP_Hero()
    end,
    ["T.H.MAXMP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleMaxMP_Hero()
    end,
    ["T.H.HP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleCurrHP_Hero()
    end,
    ["T.H.MP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleCurrMP_Hero()
    end,
    ["T.H.MIN_ATK"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().Min_ATK)
    end,
    ["T.H.MAX_ATK"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().Max_ATK)
    end,
    ["T.H.MIN_DAO"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().Min_Daoshu)
    end,
    ["T.H.MAX_DAO"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().Max_Daoshu)
    end,
    ["T.H.MIN_DEF"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().MIN_DEF)
    end,
    ["T.H.MAX_DEF"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().MAX_DEF)
    end,
    ["T.H.MIN_MDF"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().MIN_MDF)
    end,
    ["T.H.MAX_MDF"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().MAX_MDF)
    end,
    ["T.H.HIT"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().Hit_Point)
    end,
    ["T.H.HITSPD"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().Hit_Speed)
    end,
    ["T.H.BURST"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Double_Rate)
    end,
    ["T.H.BURST_DAM"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Double_Damage)
    end,
    ["T.H.IMM_ATT"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().ATK_Defence)
    end,
    ["T.H.IMM_MAG"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().MAT_Defence)
    end,
    ["T.H.SUCK_HP"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().Monster_Suck_HP_Rate)
    end,
    ["T.H.LUCK"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().Lucky)
    end,
    -- 腕力
    ["T.H.HW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Hand_Weight)
    end,
    ["T.H.MAXHW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Hand_Weight)
    end,
    ["T.H.BW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Weight)
    end,
    ["T.H.MAXBW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Weight)
    end,
    ["T.H.WW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Wear_Weight)
    end,
    ["T.H.MAXWW"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Wear_Weight)
    end,
    ----------
    ["QUICKUSE_DATA"] = function()
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        return QuickUseProxy:GetQuickUseData()
    end,
    ["BUBBLETIPS_INFO"] = function(param)
        local BubbleTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.BubbleTipsProxy)
        return BubbleTipsProxy:GetConfigByID(param)
    end,
    ["BONUSPOINT"] = function()
        local ReinAttrProxy = global.Facade:retrieveProxy(global.ProxyTable.ReinAttrProxy)
        return ReinAttrProxy:GetBonusPoint()
    end,
    ["IS_PICK_STATE"] = function()
        local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        return AutoProxy:IsPickState()
    end,

    -- 组队
    -- 附近队伍列表
    ["TEAM_NEAR"] = function()
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:GetNearTeamItems()
    end,
    -- 队伍成员列表
    ["TEAM_MEMBER_LIST"] = function()
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:GetTeamMember()
    end,
    -- 队伍人数
    ["TEAM_COUNT"] = function()
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:GetMemberCount()
    end,
    -- 队伍最大人数
    ["TEAM_MAC_COUNT"] = function()
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:GetMemberMax()
    end,
    -- 是否是队伍成员
    ["TEAM_IS_MEMBER"] = function(uid)
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:IsTeamMember(uid)
    end,
    -- 允许组队状态
    ["TEAM_STATUS_PERMIT"] = function()
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:GetPermitStatus()
    end,
    -- 允许添加状态
    ["ADD_STATUS_PERMIT"] = function()
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:GetAddStatus()
    end,
    -- 允许交易状态
    ["DEAL_STATUS_PERMIT"] = function()
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:GetDealStatus()
    end,
    -- 允许显示状态
    ["SHOW_STATUS_PERMIT"] = function()
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:GetShowStatus()
    end,
    -- 入队申请列表
    ["TEAM_APPLY"] = function()
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        return TeamProxy:GetApplyItems()
    end,

    -- 邮件
    -- 邮件列表
    ["MAIL_LIST"] = function()
        local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
        return MailProxy:getMailList()
    end,
    -- 邮件id获取邮件
    ["MAIL_BY_ID"] = function(mailId)
        local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
        return MailProxy:getMailByMailId(mailId)
    end,
    -- 是否有邮件可以删除
    ["MAIL_HAVE_DEL_ITEM"] = function()
        local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
        return MailProxy:isHaveDeleteMail()
    end,
    ["MAIL_CURRENT_ID"] = function()
        local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
        return MailProxy:getCurMailId()
    end,

    -- 商城
    -- 充值商品信息列表
    ["RECHARGE_PRODUCTS"] = function()
        local RechargeProxy = global.Facade:retrieveProxy(global.ProxyTable.RechargeProxy)
        local products = RechargeProxy:GetProducts() or {}
        return products
    end,

    -- 通过商品Id获取商品信息
    ["RECHARGE_PRODUCT_BY_ID"] = function(id)
        local RechargeProxy = global.Facade:retrieveProxy(global.ProxyTable.RechargeProxy)
        local product = RechargeProxy:GetProductByID(id) or nil
        return product
    end,

    -- 是否接入三方SDK
    ["IS_SDK_PAY"] = function()
        local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
        local bSDKPay = AuthProxy:IsSDKPay()
        return bSDKPay
    end,

    -- 拍卖行
    -- 默认最低竞拍价
    ["AUCTION_BIDPRICE_MIN"] = function()
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:GetLowBidPrice()
    end,
    -- 默认最高竞拍价
    ["AUCTION_BIDPRICE_MAX"] = function()
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:GetHighBidPrice()
    end,
    -- 默认最低一口价
    ["AUCTION_BUYPRICE_MIN"] = function()
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:GetLowBuyPrice()
    end,
    -- 默认最高一口价
    ["AUCTION_BUYPRICE_MAX"] = function()
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:GetHighBuyPrice()
    end,
    -- 默认货架数量
    ["AUCTION_DEFAULT_SHELF"] = function()
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:getLimitShelf()
    end,
    -- 上架列表数量
    ["AUCTION_PUT_LIST_CNT"] = function()
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:GetPutListCount()
    end,
    -- 拍卖行货币
    ["AUCTION_MONEY"] = function()
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:getCurrencies()
    end,
    -- 是否有我的竞拍物品
    ["AUCTION_HAVE_MY_BIDDING"] = function()
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:IsExistAcquireItem()
    end,
    -- 拍卖行物品状态 返回参数1：状态 0.未知 2.竞拍中 3.已超时，参数2：剩余时间
    ["AUCTION_ITEM_STATE"] = function(item)
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:calcItemStatus(item)
    end,
    -- 是否可竞价
    ["AUCTION_CAN_BID"] = function(item)
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:checkBidAble(item)
    end,
    -- 是否可一口价
    ["AUCTION_CAN_BUY"] = function(item)
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:checkBuyAble(item)
    end,
    -- 获取拍卖行我的展示可寄售道具
    ["AUCTION_MY_SHOW_LIST"] = function()
        local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
        return AuctionProxy:GetShowBagItems()
    end,
    -------

    -- 好友最大人数
    ["FRIEND_MAX_COUNT"] = function()
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        return FriendProxy:getMaxFriendNum()
    end,
    -- 好友信息，通过UID获取
    ["FRIEND_INFO_BY_UID"] = function(param)
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        return FriendProxy:getFriendDataByUid(param)
    end,
    -- 好友信息，通过NAME获取
    ["FRIEND_INFO_BY_NAME"] = function(param)
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        return FriendProxy:getFriendDataByUname(param)
    end,
    -- 是我的好友
    ["SOCIAL_IS_FRIEND"] = function(param)
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        return FriendProxy:getFriendDataByUname(param) ~= nil
    end,
    -- 是黑名单
    ["SOCIAL_IS_BLICKLIST"] = function(param)
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        return FriendProxy:getBlacklistDataByUName(param) ~= nil
    end,
    -- 好友列表
    ["FRIEND_LIST"] = function()
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        return FriendProxy:getFriendData()
    end,
    -- 黑名单
    ["FRIEND_BLACKLIST"] = function()
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        return FriendProxy:getBlacklistData()
    end,
    -- 好友申请列表
    ["FRIEND_APPLYLIST"] = function()
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        return FriendProxy:getApplyData()
    end,

    -- 行会成员列表
    ["GUILD_MEMBER_LIST"] = function()
        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        return GuildProxy:GetMemberList()
    end,
    -- 获取行会职位
    ["GUILD_OFFICIAL"] = function(param)
        return GetGuildOfficialName(param)
    end,
    -- 行会申请列表
    ["GUILD_APPLY_LIST"] = function()
        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        return GuildProxy:GetApplyGuildList()
    end,
    -- 行会结盟申请列表
    ["GUILD_ALLY_APPLY_LIST"] = function()
        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        return GuildProxy:getAllyApplyList()
    end,
    -- 获取世界行会列表 page: 分页id
    ["GUILD_WORLD_LIST"] = function(page)
        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        return GuildProxy:GetWorldGuildList(page)
    end,
    -- 获取世界行会列表总页数
    ["GUILD_WORLD_TOTAL_PAGES"] = function()
        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        return GuildProxy:GetTotalListPage()
    end,
    -- 获取创建公会信息
    ["GUILD_CREATE"] = function()
        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        return GuildProxy:getCreateCost()
    end,
    -- 我的行会信息
    ["GUILD_INFO"] = function()
        local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        local data = {}
        data.rank = GuildPlayerProxy:GetRank()                          -- 职位
        data.contribute = GuildPlayerProxy:GetContribute()              -- 贡献
        data.todayDonateGold = GuildPlayerProxy:GetDonateNum()          -- 当天捐钱
        data.isJoinGuild = GuildPlayerProxy:IsJoinGuild()               -- 是否加入公会
        data.guildName = GuildPlayerProxy:GetGuildName()                -- 行会名字
        data.guildId = GuildPlayerProxy:GetGuildId()                    -- 行会ID
        data.isChairMan = GuildPlayerProxy:IsChairman(data.rank)        -- 是否是会长或者副会长
        data.guidMaster = GuildProxy:GetGuildInfo().GuildMaster         -- 行会会长
        data.notice = GuildProxy:GetGuildInfo().Notice                  -- 行会公告
        return data
    end,
    -- 行会成员信息 uid
    ["GUILD_MEMBER_INFO"] = function(uid)
        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        return GuildProxy:getMemberByUID(uid)
    end,
    -- 获取目标Target ID
    ["TARGET_ID"] = function()
        local FuncDockProxy = global.Facade:retrieveProxy(global.ProxyTable.FuncDockProxy)
        return FuncDockProxy:GetTargetId() or nil
    end,
    -- 获取目标Target 名字
    ["TARGET_NAME"] = function()
        local FuncDockProxy = global.Facade:retrieveProxy(global.ProxyTable.FuncDockProxy)
        return FuncDockProxy:GetTargetName() or nil
    end,

    -- 玩家交易
    ["TRADE_DATA"] = function()
        local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
        return TradeProxy:GetTrader()
    end,
    -- 交易自己锁定状态
    ["TRADE_MY_LOCK_STATUS"] = function()
        local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
        return TradeProxy:GetMySureLockState()
    end,
    -- 交易对方锁定状态
    ["TRADE_OTHER_LOCK_STATUS"] = function()
        local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
        return TradeProxy:GetOtherSureLockState()
    end,
    -- 交易物品是否禁止
    ["TRADE_ITEM_IS_FORBID"] = function(param)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local isBind,isSelf,isMeetType = CheckItemisBind(param, ItemConfigProxy:GetBindArticleType().TYPE_NOTRADE)
        return isMeetType==true
    end,


    -- 排行榜数据
    ["RANK_DATA_BY_TYPE"] = function(param)
        local RankProxy = global.Facade:retrieveProxy(global.ProxyTable.RankProxy)
        return RankProxy:GetRankingPlayers(param) or {}
    end,

    -- 任务排序
    ["MISSION_ITEM_ORDER"] = function(param)
        if not param then
            SL:Print("[GUI ERROR] SL:GetMissionItemOrder missionID is empty")
            return 0
        end
        local MissionProxy = global.Facade:retrieveProxy(global.ProxyTable.MissionProxy)
        return MissionProxy:CalcMissionOrderByID(param)
    end,

    -- 筛选技能数据
    ["SKILL_INFO_FILTER"] = function(skilltype, filterJob, filterLearned, noBasic)
        return skillUtils.findSkills(skilltype, filterJob, filterLearned, noBasic)
    end,
    -- 技能名字
    ["SKILL_NAME"] = function(param)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetSkillNameByID(param) or ""
    end,
    -- 技能图标
    ["SKILL_ICON_PATH"] = function(param, isCombo)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetIconPathByID(param, isCombo)
    end,
    -- 技能矩形图标
    ["SKILL_RECT_ICON_PATH"] = function(param, isCombo)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetIconRectPathByID(param, isCombo)
    end,
    -- 是否可以开关技能
    ["SKILL_IS_ONOFF_SKILL"] = function(param)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:IsOnoffSkill(param)
    end,
    -- 技能是否开启
    ["SKILL_IS_ON_SKILL"] = function(param)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:IsOnSkill(param)
    end,
    --已学技能(noBasicSkill, activeOnly)
    ["LEARNED_SKILLS"] = function(param1, param2)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetSkills(param1, param2)
    end,
    --是否主动技能
    ["SKILL_IS_ACTIVE"] = function(param1)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:IsActiveSkill(param1)
    end,
    --获取技能数据
    ["SKILL_DATA"] = function(param1)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetSkillByID(param1)
    end,
    --获取技能等级熟练度数据
    ["SKILL_TRAIN_DATA"] = function(param1)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetSkillTrainData(param1)
    end,
    --获取技能配置
    ["SKILL_CONFIG"] = function(param1)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:FindConfigBySkillID(param1)
    end,
    --获取技能快捷键
    ["SKILL_KEY"] = function(param1)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetSkillKey(param1)
    end,
    --获取技能等级
    ["SKILL_LEVEL"] = function(param1)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:GetLevel(param1)
    end,
    -- 背包所有物品
    ["BAG_DATA"] = function()
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        return BagProxy:GetBagData()
    end,
    ["H.BAG_DATA"] = function()
        local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
        return HeroBagProxy:GetBagData()
    end,
    -- 背包满了
    ["BAG_IS_FULL"] = function(param)
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        return BagProxy:isToBeFull(param)
    end,
    -- 获取物品背包是否有富余格子
    ["BAG_CHECK_NEED_SPACE"] = function(param1, param2, param3)
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        return BagProxy:CheckNeedSpace(param1, param2, param3)
    end,
    -- 当前选中的背包页
    ["BAG_PAGE_CUR"] = function()
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        return BagProxy:GetCurPage()
    end,
    -- 背包最大格子数量
    ["MAX_BAG"] = function()
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        return BagProxy:GetMaxBag()
    end,
    ["H_MAX_BAG"] = function()
        local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
        return HeroBagProxy:getBagMaxNum()
    end,
    ["N_MAX_BAG"] = function()
        local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
        return NPCStorageProxy:GetOpenSize()
    end,
    ["BAG_REMAIN_COUNT"] = function()
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local bagItemNum = BagProxy:GetTotalItemCount()
        local maxBag = BagProxy:GetMaxBag()
        local remainCount = math.max(maxBag - bagItemNum, 0)
        return remainCount
    end,
    ["BAG_USED_COUNT"] = function()
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        return BagProxy:GetTotalItemCount()
    end,
    -- 快捷栏个数
    ["QUICK_USE_NUM"] = function()
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        return QuickUseProxy:GetQuickUseSize()
    end,
    -- 背包物品唯一ID --param: 背包位置
    ["BAG_MAKEINDEX_BY_POS"] = function(param, isHero)
        local BagProxy = isHero and global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy) or global.Facade:retrieveProxy(global.ProxyTable.Bag)
        return BagProxy:GetMakeIndexByBagPos(param)
    end,

    ----------- 内挂设置 ------------
    -- 设置是否生效
    ["SETTING_ENABLED"] = function(param1)
        return CHECK_SETTING(param1)
    end,
    -- 设置的数据
    ["SETTING_VALUE"] = function(param1)
        return GET_SETTING(param1)
    end,
    -- 设置的配置
    ["SETTING_CONFIG"] = function(param1)
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        return GameSettingProxy:GetConfigByID(param1)
    end,
    -- 获取拾取的设置值
    ["SETTING_PICK_VALUE"] = function(param1)
        return CHECK_SETTING_PICK(param1)
    end,
    -- 物品是否可以勾选
    ["SETTING_IS_ITEM_PICK_CAN_SET"] = function(param1)
        return CHECK_ITEM_PICK_CANSET(param1)
    end,
    -- 捡物品配置
    ["SETTING_PICK_CONFIG"] = function(param1)
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        return GameSettingProxy:GetPickConfig()
    end,
    --获取拾取组的数据
    ["SETTING_PICK_GROUP_VALUE"] = function(param1)
        return CHECK_GROUPSETTING_PICK(param1)
    end,
    --获取排序的设置相关数据,param1: ID
    ["SETTING_RANK_DATA"] = function(param1)
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        return GameSettingProxy:getRankData(param1)
    end,
    --获取boss提示类型
    ["BOSS_REMIND_TYPE"] = function()
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        return GameSettingProxy:GetBossType()
    end,
    --获取boss提示值 
    ["BOS_REMIND_VALUE"] = function()
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        return GameSettingProxy:GetBossTipsValues()
    end,
    -- 通过值获取地图缩放对应百分比
    ["MAPSCALE_PER"] = function(param1)
        if not param1 then
            return nil
        end
        return ((param1 - 0.7) / (2.3 - 0.7)) * 100
    end,
    -- 通过百分比获取地图缩放值
    ["MAPSCALE_VALUE"] = function(param1)
        if not param1 then
            return nil
        end
        return 0.7 + (2.3 - 0.7) * (param1 / 100)
    end,
    -------------------------------

    -- 物品类型枚举
    ["ITEMTYPE_ENUM"] = function()
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        return ItemManagerProxy:GetItemSettingType()
    end,
    -- 物品类型
    ["ITEMTYPE"] = function(param1)
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        return ItemManagerProxy:GetItemType(param1)
    end,
    -- 物品来自(界面位置)
    ["ITEMFROMUI_ENUM"] = function()
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        return clone(ItemMoveProxy.ItemFrom)
    end,
    -- 物品规则枚举 
    ["ITEM_ARTICLE_ENUM"] = function ()
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        return ItemConfigProxy:GetArticleType()
    end,
    -- 装备Map
    ["EQUIPMAP_BY_STDMODE"] = function()
        local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
        return AttrConfigProxy:GetItemsConfigEquipMapByStdMode()
    end,
    -- 除装备Map 显示持久的stdmode
    ["EX_SHOWLAST_MAP"] = function()
        local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
        return AttrConfigProxy:GetItemsExtraShowLasting()
    end,
    -- 获取装备对比属性
    ["EQUIP_COMPARISON"] = function(param1)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        return ItemConfigProxy:GetItemComparison(param1)
    end,
    -- 通过stdmode获取装备位
    ["EQUIP_POS_BY_STDMODE"] = function(param1)
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        return EquipProxy:GetEquipPosByStdMode(param1)
    end,
    -- 通过stdmode获取装备列表
    ["EQUIP_POSLIST_BY_STDMODE"] = function(param1, param2)
        local proxy = param2 and global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy) or global.Facade:retrieveProxy(global.ProxyTable.Equip)
        return clone(proxy:GetEquipPosByStdModeList(param1))
    end,
    -- 通过stdmode获取TIP装备Pos列表
    ["TIP_POSLIST_BY_STDMODE"] = function(param1, param2)
        local proxy = param2 and global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy) or global.Facade:retrieveProxy(global.ProxyTable.Equip)
        return clone(proxy:GetTipsEquipPosByStdModeList(param1))
    end,
    -- 装备战力(param1: equipData； param2: param; param3: isHero)
    ["EQUIP_POWER"] = function(param1, param2, param3)
        if GUIFunction.GetEquipPower then
            return GUIFunction:GetEquipPower(param1, param2, param3)
        end
        return 0
    end,
    -- 通过MakeIndex获取装备数据 isHero:是否英雄
    ["EQUIP_DATA_BY_MAKEINDEX"] = function(param1, param2)
        local proxy = param2 and global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy) or global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local itemData = proxy:GetEquipDataByMakeIndex(param1)
        return clone(itemData)
    end,
    -- 通过MakeIndex获取背包数据 isHero:是否英雄
    ["ITEM_DATA_BY_MAKEINDEX"] = function(param1, param2)
        local proxy = param2 and global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy) or global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local itemData = proxy:GetItemDataByMakeIndex(param1)
        return clone(itemData)
    end,
    -- 通过MakeIndex获取仓库数据
    ["STORAGE_DATA_BY_MAKEINDEX"] = function(param1)
        local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
        local itemData = NPCStorageProxy:GetStorageDataByMakeIndex(param1)
        return clone(itemData)
    end,
    -- 通过MakeIndex获取快捷栏数据
    ["QUICKUSE_DATA_BY_MAKEINDEX"] = function(param1)
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        local itemData = QuickUseProxy:GetQucikUseDataByMakeIndex(param1)
        return clone(itemData)
    end,
    -- 通过MakeIndex获取查看他人装备数据
    ["LOOKPLAYER_DATA_BY_MAKEINDEX"] = function(param1)
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        local itemData = LookPlayerProxy:GetLookPlayerItemDataByMakeIndex(param1)
        return clone(itemData)
    end,  

    -- 是否是该性别装备
    ["IS_SAMESEX_EQUIP"] = function(param1, param2)
        local proxy = param2 and global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy) or global.Facade:retrieveProxy(global.ProxyTable.Equip)
        return proxy:CheckEquipNeedSex(param1)
    end,

    -- 获取对应id描述（cfg_custpro_caption表）
    ["CUSTOM_DESC"] = function(param1)
        if not param1 then
            return nil
        end
        local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
        return ItemTipsProxy:getCustomDesc(param1)
    end,
    -- 获取对应id配置icon（cfg_custpro_caption表）
    ["CUSTOM_ICON"] = function(param1)
        if not param1 then
            return nil
        end
        local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
        return ItemTipsProxy:getCustomIcon(param1)
    end,
    -- 根据属性 ID 获取属性配置(cfg_att_score表)
    ["ATTR_CONFIG"] = function(param1)
        if not param1 then
            return nil
        end
        local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
        local config = AttrConfigProxy:GetAttConfigByAttId(param1)
        return config
    end,
    -- 获取属性配置(cfg_att_score表)
    ["ATTR_CONFIGS"] = function()
        local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
        return AttrConfigProxy:GetAttConfig()
    end,
    -- 自定义属性ID映射Map
    ["CUST_ABIL_MAP"] = function()
        local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
        return ItemTipsProxy:GetCustAbilMap()
    end,
    -- 检查禁止使用物品buff 返回能否使用, buffID
    ["CHECK_USE_ITEM_BUFF"] = function(itemIndex)
        if not itemIndex then
            return false
        end
        local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        local ret, buffID = BuffProxy:CheckUseItemEnable(itemIndex)
        return ret, buffID
    end,
    -- 物品能否自动使用
    ["ITEM_CAN_AUTOUSE"] = function(item)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        return ItemConfigProxy:CheckItemAutoUse(item)
    end,
    -- 技能书能否使用
    ["SKILLBOOK_CAN_USE"] = function(itemName, isHero)
        local SkillProxy = isHero and global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy) or global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:CheckAbleToUseBookByName(itemName)
    end,
    -- 物品归属
    ["ITEM_BELONG_BY_MAKEINDEX"] = function(param1)
        if not param1 then
            return
        end
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        return ItemManagerProxy:GetItemBelong(param1)
    end,
    
    -- 获取正在查看玩家的某一装备位数据
    ["L.M.EQUIP_DATA"] = function(param1, param2)
        if not param1 then
            return
        end
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        if tonumber(param1) then
            return LookPlayerProxy:GetLookPlayerItemDataByPos(param1, param2)
        else
            return LookPlayerProxy:GetEquipDataByName(param1)
        end
    end,
    ["L.M.EQUIP_DATA_LIST"] = function(param1)
        if not tonumber(param1) then
            return
        end
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerItemDataList(param1)
    end,
    -- 获取正在查看玩家的装备位数据
    ["L.M.EQUIP_POS_DATAS"] = function(param1)
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerItemPosData()
    end,  
    -- 当前查看玩家数据
    ["L.M.PLAYER_DATA"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerData()
    end,
    -- 当前查看玩家职业
    ["L.M.JOB"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        local data = LookPlayerProxy:GetLookPlayerData()
        return data and data.Job
    end,
    -- 当前查看玩家发型
    ["L.M.HAIR"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        local data = LookPlayerProxy:GetLookPlayerData()
        return data and data.Hair
    end,
    -- 当前查看玩家等级
    ["L.M.LEVEL"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerLevel()
    end,
    -- 当前查看玩家性别
    ["L.M.SEX"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerSex()
    end,
    -- 当前查看玩家行会信息
    ["L.M.GUILD_INFO"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        local data = {}
        data.rankName = LookPlayerProxy:GetLookPlayerGuildRankName()       -- 职位
        data.guildName = LookPlayerProxy:GetLookPlayerGuildName()      -- 行会名字
        return data
    end,
    -- 获取当前查看玩家的称号
    ["L.M.TITLES"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerTitle()
    end,
    -- 获取当前查看玩家激活的称号
    ["L.M.ACTIVATE_TITLE"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetLookPlayerTitleActive()
    end,
    ["L.M.EMBATTLE"] = function()
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        return LookPlayerProxy:GetEmbattle()
    end,

    -- 获取对应套装id配置（cfg_suitex表）
    ["SUITEX_CONFIG"] = function(param1)
        if not param1 then
            return nil
        end
        local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
        return ItemTipsProxy:GetNewSuitConfigById(param1)
    end,
    -- 获取对应套装id配置（cfg_suit表）
    ["SUIT_CONFIG"] = function(param1)
        if not param1 then
            return nil
        end
        local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
        if tonumber(param1) then
            return ItemTipsProxy:getSuitConfigById(param1)
        else
            return ItemTipsProxy:getSuitConfigByName(param1)
        end
    end,
    -- 服务器开关
    ["SERVER_OPTIONS"] = function(key)
        local ServerOptionsProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerOptionsProxy)
        return ServerOptionsProxy:checkOption(key)
    end,
    ---获取主角切页开关
    ["USERINFO_PAGE_ON"] = function(param1, param2)
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetMainPlayerPageSwitch(param1, param2)
    end,
    ---激活称号的图片
    ["TITLE_IMAGE"] = function(param1)
        local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
        return PlayerTitleProxy:getTitleActivateImage(param1)
    end,
    ---称号列表的图片
    ["TITLE_LIST_IMAGE"] = function(param1)
        local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
        return PlayerTitleProxy:getTitleListImage(param1)
    end,
    ---称号剩余时间
    ["TITLE_TIME"] = function(param1)
        local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
        return PlayerTitleProxy:getTitleTime(param1)
    end,
    ---角色面板时装显示开关 
    ["SUPEREQUIP_SHOW"] = function()
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:GetShowSetting()
    end,
    ---英雄面板时装显示开关 
    ["HERO_SUPEREQUIP_SHOW"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:GetShowSetting()
    end,
    --获取合成打开的id
    ["COMPOUND_OPEN_ID"] = function()
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:GetOnCompoundIndex()
    end,
    --获取合成配置通过index
    ["COMPOUND_CONFIG_BY_INDEX"] = function(index)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:GetCompoundConfigByIndex(index)
    end,
    --获取合成页签通过id
    ["COMPOUND_PAGE_BY_ID"] = function(id)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:GetPageIndexByID(id)
    end,
    --获取合成数据
    ["COMPOUND_LIST_DATA"] = function()
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:GetShowItemList()
    end,
    --获取合成数据通过页签id
    ["COMPOUND_LIST_DATA_BY_INDEX"] = function(pageId)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:GetShowItemListByIndex(pageId)
    end,
    --检测合成是否显示
    ["COMPOUND_CHECK_LIST_IS_SHOW"] = function(page1, page2)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:CheckListIsShow(page1, page2)
    end,
    --检测合成红点 page1:第一页签 page2: 第二页签
    ["COMPOUND_CHECK_LIST_RED_POINT"] = function(page1, page2)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:CheckCompoudListState(page1, page2)
    end,
    --获取合成页签名字
    ["COMPOUND_PAGE_NAME"] = function(index)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:GetPageName(index)
    end,
    --判断合成条件是否显示
    ["COMPOUND_SHOW_CONDITION"] = function(condition)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:CheckStrConditions(condition)
    end,
    --合成红点状态通过道具Index
    ["COMPOUND_RED_POINT_BY_ID"] = function(id)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:GetCompoundStateByIndex(id)
    end,
    --检测是否可以合成
    ["COMPOUND_CHECK_OK"] = function(config, isShowTips)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        return ItemCompoundProxy:CheckIsCanCompoud(config, isShowTips)
    end,
    -- func dock enum
    ["DOCKTYPE_NENUM"] = function()
        local FuncDockProxy = global.Facade:retrieveProxy(global.ProxyTable.FuncDockProxy)
        return clone(FuncDockProxy.FuncDockType)
    end,

    -- actor
    ["ACTOR_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        return actor:GetID()
    end,
    ["ACTOR_DATA"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        return actor:GetID()
    end,
    ["ACTOR_NAME"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        return actor:GetName()
    end,
    ["ACTOR_LEVEL"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:GetLevel()
    end,
    ["ACTOR_JOB_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        if not actor:IsPlayer() then
            return 0
        end
        return actor:GetJobID()
    end,
    ["ACTOR_SEX"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        if not actor:IsPlayer() then
            return 0
        end
        return actor:GetSexID()
    end,
    -- actor是 玩家
    ["ACTOR_IS_PLAYER"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsPlayer()
    end,
    -- actor是 怪物
    ["ACTOR_IS_MONSTER"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsMonster()
    end,
    -- actor是 NPC
    ["ACTOR_IS_NPC"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsNPC()
    end,
    -- actor是 掉落物
    ["ACTOR_IS_DROPITEM"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsDropItem()
    end,
    -- actor是 特效
    ["ACTOR_IS_EFFECT"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsSEffect()
    end,
    -- actor是 人形怪
    ["ACTOR_IS_HUMAN"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsHumanoid()
    end,
    -- actor是 英雄
    ["ACTOR_IS_HERO"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsHero()
    end,
    -- actor是 网络玩家
    ["ACTOR_IS_NETPLAYER"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsNetPlayer()
    end,
    -- actor是 镖车
    ["ACTOR_IS_ESCORT"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsEscort()
    end,
    -- actor是 采集物
    ["ACTOR_IS_COLLECTION"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsCollection()
    end,
    -- actor是 守卫
    ["ACTOR_IS_DEFENDER"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsDefender()
    end,
    -- actor是 捡物小精灵
    ["ACTOR_IS_PICKUPSPRITE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsPickUpSprite()
    end,
    -- actor是 宠物
    ["ACTOR_IS_PET"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsPet()
    end,
    -- actor是 沙巴克大门
    ["ACTOR_IS_GATE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsGate()
    end,
    -- actor是 沙巴克城墙
    ["ACTOR_IS_WALL"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsWall()
    end,
    -- actor 死亡
    ["ACTOR_IS_DIE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsDie()
    end,
    -- actor 骨头
    ["ACTOR_IS_DEATH"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsDeath()
    end,
    -- actor 出生
    ["ACTOR_IS_BORN"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsBorn()
    end,
    -- actor 钻回洞穴
    ["ACTOR_IS_CAVE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        return actor:IsCave()
    end,
    ["ACTOR_HP"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:GetHP()
    end,
    ["ACTOR_MAXHP"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:GetMaxHP()
    end,
    ["ACTOR_MP"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:GetMP()
    end,
    ["ACTOR_MAXMP"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:GetMaxMP()
    end,
    -- actor归属ID
    ["ACTOR_OWNER_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsMonster() or actor:IsPlayer() or actor:IsNPC() or actor:IsDropItem()) then
            return nil
        end
        local ownerID = actor:GetOwnerID()
        if not ownerID or ownerID == "" or ownerID == -1 then
            return nil
        end
        return ownerID
    end,
    -- actor归属名字
    ["ACTOR_OWNER_NAME"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return ""
        end
        if not (actor:IsMonster() or actor:IsPlayer() or actor:IsNPC() or actor:IsDropItem()) then
            return nil
        end
        return actor:GetOwnerName()
    end,
    ["ACTOR_BIGICON_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not actor:IsMonster() then
            return nil
        end
        return actor:GetBigTipIcon()
    end,
    -- 获取组队状态 返回 0未组队, 1组队中
    ["ACTOR_TEAM_STATE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:GetTeamState()
    end,
    -- 行会ID
    ["ACTOR_GUILD_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return ""
        end
        return actor:GetGuildID()
    end,
    -- 行会名字
    ["ACTOR_GUILD_NAME"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return ""
        end
        return actor:GetGuildName()
    end,
    -- typeIndex，对应怪物表/NPC表 ID
    ["ACTOR_TYPE_INDEX"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        if not (actor:IsMonster() or actor:IsNPC() or actor:IsHumanoid() or actor:IsDropItem()) then
            return 0
        end
        return actor:GetTypeIndex()
    end,
    -- 方向
    ["ACTOR_DIR"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:GetDirection()
    end,
    -- 地图坐标X
    ["ACTOR_MAP_X"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:GetMapX()
    end,
    -- 地图坐标Y
    ["ACTOR_MAP_Y"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:GetMapY()
    end,
    -- 世界坐标X
    ["ACTOR_POSITION_X"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:getPosition().x
    end,
    -- 世界坐标Y
    ["ACTOR_POSITION_Y"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        return actor:getPosition().y
    end,
    -- 主人ID
    ["ACTOR_MASTER_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return ""
        end
        if not (actor:IsPlayer() or actor:IsMonster() or actor:IsNPC()) then
            return ""
        end
        return actor:GetMasterID()
    end,
    -- 有主人
    ["ACTOR_HAVE_MASTER"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer() or actor:IsMonster() or actor:IsNPC()) then
            return false
        end
        return actor:IsHaveMaster()
    end,
    -- 阵营，大于0且相等是同阵营
    ["ACTOR_FACTION"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        if not (actor:IsPlayer() or actor:IsMonster() or actor:IsNPC()) then
            return 0
        end
        return actor:GetFaction()
    end,
    -- 是否在安全区
    ["ACTOR_IN_SAFE_ZONE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer() or actor:IsMonster() or actor:IsNPC()) then
            return false
        end
        return actor:GetInSafeZone()
    end,
    -- 外观ID
    ["ACTOR_APPR_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer() or actor:IsMonster() or actor:IsNPC()) then
            return false
        end
        return actor:GetAnimationID()
    end,
    -- 武器ID
    ["ACTOR_WEAPON_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not actor:IsPlayer() then
            return nil
        end
        return actor:GetAnimationWeaponID()
    end,
    -- 左手武器ID
    ["ACTOR_LEFT_WEAPON_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not actor:IsPlayer() then
            return nil
        end
        return actor:GetAnimationLeftWeaponID()
    end,
    -- shield
    ["ACTOR_SHIELD_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not actor:IsPlayer() then
            return nil
        end
        return actor:GetAnimationShieldID()
    end,
    -- wing
    ["ACTOR_WINGS_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not actor:IsPlayer() then
            return nil
        end
        return actor:GetAnimationWingsID()
    end,
    -- hair
    ["ACTOR_HAIR_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not actor:IsPlayer() then
            return nil
        end
        return actor:GetAnimationHairID()
    end,

    -- actor挂接点
    ["ACTOR_MOUNT_NODE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer() or actor:IsMonster() or actor:IsNPC() or actor:IsDropItem()) then
            return false
        end
        return actor:GetMountNode()
    end,

    -- 英雄选中的目标是否能锁定
    ["ACTOR_CAN_LOCK_BY_HERO"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        local proxyUtils = requireProxy("proxyUtils")
        return proxyUtils:checkHeroLockTargetEnable(actor)
    end,
    ----------------------------------------------------------
    -- player
    -- 红名灰名 白=0  咖啡=1  红=2  灰=3
    ["ACTOR_PKLV"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return 0
        end
        if not (actor:IsPlayer()) then
            return 0
        end
        return actor:GetPKLv()
    end,
    -- 区服ID，跨服时使用
    ["ACTOR_SERVER_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return ""
        end
        if not (actor:IsPlayer() or actor:IsMonster() or actor:IsNPC()) then
            return ""
        end
        return actor:GetServerID()
    end,
    -- 是否在摆摊
    ["ACTOR_IS_IN_STALL"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer()) then
            return false
        end
        return actor:IsStallStatus()
    end,
    -- 摆摊名字
    ["ACTOR_STALL_NAME"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return ""
        end
        if not (actor:IsPlayer()) then
            return ""
        end
        return actor:GetStallName()
    end,
    -- 是否是离线状态玩家
    ["ACTOR_IS_OFFLINE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer()) then
            return false
        end
        return actor:GetIsOffLine()
    end,
    -- 是否是神秘人
    ["ACTOR_IS_MYSTERY_MAN"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer()) then
            return false
        end
        return actor:IsShenMiRen()
    end,
    -- 是否拥有护身
    ["ACTOR_IS_HUSHEN"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer()) then
            return false
        end
        return actor:IsHuShen()
    end,
    -- 是否是主玩家
    ["ACTOR_IS_MAINPLAYER"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer()) then
            return false
        end
        return actor:IsMainPlayer()
    end,
    -- 是否是骑马状态
    ["ACTOR_IS_HORSEBACK_RADING"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer()) then
            return false
        end
        return global.BuffManager:IsHaveOneBuff(param, global.MMO.BUFF_ID_HORSE)
    end,
    -- 国家ID
    ["ACTOR_NATION_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer()) then
            return nil
        end
        return actor:GetNationID()
    end,
    -- 坐骑 主驾ID
    ["ACTOR_HORSE_MASTER_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer()) then
            return nil
        end
        return actor:GetHorseMasterID()
    end,
    -- 坐骑 副驾ID
    ["ACTOR_HORSE_COPILOT_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer()) then
            return nil
        end
        return actor:GetHorseCopilotID()
    end,
    -- 是否是坐骑 副驾
    ["ACTOR_IS_HORSE_COPILOT"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer()) then
            return nil
        end
        return actor:IsHoreseCopilot()
    end,
    -- 是否是双人坐骑
    ["ACTOR_IS_DOUBLE_HORSE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer()) then
            return false
        end
        return actor:IsDoubleHorse()
    end,
    -- 是否是连体坐骑
    ["ACTOR_IS_BODY_HORSE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsPlayer()) then
            return false
        end
        return actor:IsBodyHorse()
    end,
    -- 足迹特效 脚印特效
    ["ACTOR_MOVE_EFFECT"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer()) then
            return nil
        end
        return actor:GetMoveEff()
    end,
    -- 夫妻 ID
    ["ACTOR_DEAR_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer()) then
            return nil
        end
        return actor:GetDearID()
    end,
    -- 师徒 ID
    ["ACTOR_MENTOR_ID"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer()) then
            return nil
        end
        return actor:GetSiTuID()
    end,
    -- 是否在附近显示
    ["ACTOR_NEAR_SHOW"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer()) then
            return nil
        end
        return actor:IsNearShow()
    end,
    -- 是否移动状态
    ["ACTOR_IS_MOVE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer()) then
            return nil
        end
        return IsMoveAction(actor:GetAction())
    end,

    --------------------------------------------------------------------
    -- monster
    -- 怪物 是否是石化状态
    ["ACTOR_STOME_MODE"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsMonster()) then
            return nil
        end
        return actor:GetStoneMode()
    end,
    -- 怪物 RACE SERVER
    ["ACTOR_RACE_SERVER"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsMonster()) then
            return nil
        end
        return actor:GetRaceServer()
    end,
    -- 怪物 RACEIMG
    ["ACTOR_RACE_IMG"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsMonster()) then
            return nil
        end
        return actor:GetRaceImg()
    end,
    -- 怪物 不显示名字
    ["ACTOR_HIDE_NAME"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsMonster()) then
            return false
        end
        return actor:IsNoShowName()
    end,
    -- 怪物 不显示血条
    ["ACTOR_HIDE_HP_BAR"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsMonster()) then
            return false
        end
        return actor:IsNoShowHPBar()
    end,
    -- 怪物 国家模式是否可被攻击
    ["ACTOR_NATION_ENEMY_PK"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return false
        end
        if not (actor:IsMonster()) then
            return false
        end
        return actor:IsNationEnemyPK()
    end,
    -- ACTOR GM数据
    ["ACTOR_GM_DATA"] = function(param)
        local actor = GetActor(param)
        if not actor then
            return nil
        end
        if not (actor:IsPlayer() or actor:IsMonster()) then
            return nil
        end
        return actor:GetGMData()
    end,

    --------------------------------------------------------------------
    -- 当前选择ACTOR, 附近 人/怪/NPC 等
    ["SELECT_TARGET_ID"] = function()
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        if not PlayerInputProxy then
            return nil
        end
        return PlayerInputProxy:GetTargetID()
    end,
    -- 附近人
    ["FIND_IN_VIEW_PLAYER_LIST"] = function()
        if not global.playerManager then
            return {}
        end
        return global.playerManager:FindPlayerIDInCurrViewField()
    end,
    -- 附近怪物, param1=noPetOfMainPlayer, param2=noPetOfNetPlayer
    ["FIND_IN_VIEW_MONSTER_LIST"] = function(param1, param2)
        if not global.monsterManager then
            return {}
        end
        return global.monsterManager:FindMonsterIDInCurrViewField(param1, param2)
    end,
    ["FIND_IN_VIEW_NPC_LIST"] = function()
        if not global.npcManager then
            return {}
        end
        return global.npcManager:FindNpcIDInCurrViewField()
    end,
    -- 掉落物 param1=range, param2=sortNearToFarFromPlayer, param3=ownerID
    ["FIND_IN_VIEW_DROPITEM_LIST"] = function(param1, param2, param3)
        if not global.dropItemManager then
            return {}
        end
        return global.dropItemManager:FindDropIDInCurrViewField(param1, param2, param3)
    end,
    ["CURRENT_TALK_NPC_ID"] = function()
        local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
        if not NPCProxy then
            return nil
        end
        return NPCProxy:GetCurrentNPCID()
    end,
    ["CURRENT_TALK_NPC_TYPEINDEX"] = function()
        local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
        if not NPCProxy then
            return nil
        end
        return NPCProxy:GetCurrentNPCIndex()
    end,
    ["CURRENT_TALK_NPC_LAYER"] = function()
        local NPCLayerMediator = global.Facade:retrieveMediator("NPCLayerMediator")
        if not NPCLayerMediator._layer then
            return nil
        end
        return NPCLayerMediator._layer
    end,
    ["TARGET_ATTACK_ENABLE"] = function(value)
        if not value then
            return false
        end
        return proxyUtils.checkLaunchTargetByID(value)
    end,
    ["SELECT_SHIFT_ATTACK_ID"] = function()
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        if not PlayerInputProxy then
            return nil
        end
        return PlayerInputProxy:GetAttackTargetID()
    end,
    -- 按坐标选择Actor ID
    ["PICK_ACTORID_BY_POS"] = function(pos)
        local actor = global.actorManager:Pick(pos)
        if not actor then
            return nil
        end
        return actor:GetID()
    end,
    --------------------------------------------------------------------


    --交易行查看他人 是否有英雄数据
    ["TRADINGBANK_HAVEDATA_HERO"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:haveData_Hero()
    end,
    --交易行查看他人 获取英雄背包数据
    ["TRADINGBANK_BAGDATA_HERO"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:getBagItems_Hero()
    end,
    --交易行查看他人 获取背包数据
    ["TRADINGBANK_BAGDATA"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:getBagItems()
    end,
    --交易行查看他人 获取仓库
    ["TRADINGBANK_STOREDATA"] = function()
        local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
        return TradingBankLookPlayerProxy:getStoreItems()
    end,

    -- PCY轴适配
    ["PC_POS_Y"] = function()
        local visibleSize = global.Director:getVisibleSize()
        return visibleSize.height - ((visibleSize.height - 150) / 2)
    end,

    -- 获取buff数据; param1:目标UserID
    ["ACTOR_BUFF_DATA"] = function(param1)
        local targetID = param1
        if not targetID then
            targetID = global.gamePlayerController:GetMainPlayerID()
        end
        if not targetID then
            return {}
        end

        local Buff = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        local data = global.BuffManager:GetDataByUID(targetID)
        local items = {}
        for _, v in ipairs(data) do
            local config = Buff:GetConfigByID(v.id)

            local item  = {}
            item.id         = v.id
            item.endTime    = v.endTime
            item.ol         = v.ol
            item.param      = v.param
            item.config     = config
            item.name       = config.name
            item.tips       = config.tips
            item.icon       = config.icon
            item.sort       = config.sort
            item.other_look = config.other_look
            table.insert(items, item)
        end

        return items
    end,
    -- 目标是否拥有某BUFF param1:目标UserID, param2: buffID
    ["ACTOR_HAS_ONE_BUFF"] = function(param1, param2)
        local targetID = param1
        if not targetID then
            targetID = global.gamePlayerController:GetMainPlayerID()
        end
        if not targetID then
            return false
        end

        return global.BuffManager:IsHaveOneBuff(targetID, param2)
    end,
    -- 获取对应buff数据; param1:目标UserID param2: buffID
    ["ACTOR_BUFF_DATA_BY_ID"] = function(param1, param2)
        local targetID = param1
        local buffID = param2
        if not targetID then
            targetID = global.gamePlayerController:GetMainPlayerID()
        end
        if not targetID or not buffID then
            return {}
        end

        local Buff = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        local item = global.BuffManager:GetItem(targetID, buffID)
        local config = Buff:GetConfigByID(buffID)
        if item then
            local bdata     = item:GetData()
            local endTime   = item:GetEndTime()
            local ol        = item:GetOl()
            local param     = item:GetParam()

            local data      = {}
            data.id         = buffID
            data.endTime    = endTime
            data.ol         = ol
            data.config     = config
            data.name       = config.name
            data.tips       = config.tips
            data.icon       = config.icon
            data.sort       = config.sort
            data.other_look = config.other_look

            return data
        end

        return nil
    end,
    -- 获取BUFFID的配置数据
    ["BUFF_CONFIG"] = function(param1)
        local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        if param1 then
            return clone(BuffProxy:GetConfigByID(param1))
        end
        return clone(BuffProxy:GetConfig())
    end,

    -- 战斗
    -- 是否自动挂机中
    ["BATTLE_IS_AFK"] = function()
        local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        return AutoProxy:IsAFKState()
    end,

    -- 是否自动寻路中
    ["BATTLE_IS_AUTO_MOVE"] = function()
        local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        return AutoProxy:IsAutoMoveState()
    end,
    -- 是否自动捡物
    ["BATTLE_IS_AUTO_PICK"] = function()
        local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        return AutoProxy:IsPickState()
    end,
    -- 红点 服务器下发的变量
    ["SERVER_VALUE"] = function(param)
        if not param then
            return nil
        end
        local RedPointProxy = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
        local value = RedPointProxy:getOriginValueByKey(param)
        return value
    end,
    ["TXT_VALUE"] = function(param)
        if not param then
            return nil
        end
        local RedPointProxy = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
        local value = RedPointProxy:getTXTValueByKey(param)
        return value
    end,
    -- 检测红点表对应id是否满足条件
    ["CHECK_REDPOINT_ID"] = function(param)
        if not param then
            return false
        end
        local RedPointProxy = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
        local value = RedPointProxy:CheckRedPointID(param)
        return value
    end,
    -- 黑夜状态
    ["DARK_STATE"] = function()
        local DarkLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
        local value = DarkLayerProxy:getCurState()
        return value
    end,
    -- 内观头发偏移配置
    ["UIMODEL_HAIR_OFFSET"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        return EquipProxy:GetModelHairOffSet()
    end,
    -- 内观装备偏移配置
    ["UIMODEL_EQUIP_OFFSET"] = function()
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        return EquipProxy:GetEquipModelOffSet()
    end,
    -- 点击状态
    ["TOUCH_STATE"] = function()
        return global.userInputController:isTouching()
    end,
    -- 首饰盒页面是否打开 
    -- param: 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄、21：交易行人物、22：交易行英雄
    ["BEST_RING_WIN_ISOPEN"] = function(param)
        local mediator = nil
        if param == 1 then
            mediator = global.Facade:retrieveMediator("PlayerBestRingLayerMediator")
        elseif param == 2 then
            mediator = global.Facade:retrieveMediator("HeroBestRingLayerMediator")
        elseif param == 11 then
            mediator = global.Facade:retrieveMediator("LookPlayerBestRingLayerMediator")
        elseif param == 12 then
            mediator = global.Facade:retrieveMediator("LookHeroBestRingLayerMediator")
        elseif param == 21 then
            mediator = global.Facade:retrieveMediator("TradingBankLookPlayerBestRingLayerMediator")
        elseif param == 22 then
            mediator = global.Facade:retrieveMediator("TradingBankLookHeroBestRingLayerMediator")
        end
        if mediator and mediator._layer then
            return true
        end
        return false
    end,
    ---首饰盒开启状态
    -- param: 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄、21：交易行人物、22：交易行英雄
    ["BEST_RING_OPENSTATE"] = function(param)
        if param == 1 then
            local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
            return EquipProxy:GetBestRingsOpenState()
        elseif param == 2 then
            local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
            return HeroEquipProxy:GetBestRingsOpenState()
        elseif param == 11 then
            local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
            return LookPlayerProxy:GetBestRingsOpenState()
        elseif param == 12 then
            local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
            return LookPlayerProxy:GetBestRingsOpenState()
        elseif param == 21 then
            local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
            return TradingBankLookPlayerProxy:GetBestRingsOpenState()
        elseif param == 22 then
            local TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
            return TradingBankLookPlayerProxy:GetBestRingsOpenState_Hero()
        end
    end,
    -- 检查当前类别功能菜单的某按钮是否显示
    ["CHECK_FUNCBTN_SHOW"] = function(param1, param2)
        local FuncDockProxy = global.Facade:retrieveProxy(global.ProxyTable.FuncDockProxy)
        return FuncDockProxy:IsShowBtn(param1, param2)
    end,
    -- 鼠标位置
    ["MOUSE_MOVE_POS"] = function()
        return global.userInputController and global.userInputController:GetCursorPos()
    end,
    -- 检查小地图是否打开
    ["CHECK_MINIMAP_OPEN"] = function()
        local MiniMapMediator = global.Facade:retrieveMediator("MiniMapMediator")
        if MiniMapMediator._layer then
            return true
        else
            return false
        end
    end,

    ["BESTRONG_DATA"] = function()
        local RemindUpgradeProxy = global.Facade:retrieveProxy(global.ProxyTable.RemindUpgradeProxy)
        return RemindUpgradeProxy:getButtonData()
    end,
    --掉落物 飞向的世界坐标 优先级比txt设置的高 
    ["DROPITEM_FLY_WORLD_POSITION"] = function()
        local PickupSpriteProxy = global.Facade:retrieveProxy(global.ProxyTable.PickupSpriteProxy)
        return PickupSpriteProxy:getMetaPositon()
    end,
    -- 是否学习内功
    ["IS_LEARNED_INTERNAL"] = function()
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local level = PlayerPropertyProxy:GetInternalData().level
        if level and level > 0 then
            return true
        end
        return false
    end,
    -- 英雄 是否学习内功
    ["H.IS_LEARNED_INTERNAL"] = function()
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        local level = HeroPropertyProxy:GetInternalData().level
        if level and level > 0 then
            return true
        end
        return false
    end,
    -- 交易行开启状态
    ["TRADINGBANK_OPENSTATUS"] = function()
        local TradingBankProxy = nil
        if global.OtherTradingBank then -- 三方 交易行
            TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
        else
            TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        end
        return TradingBankProxy:getOpenStatus()
    end,
    -- 开服时间戳
    ["OPEN_SERVER_TIME"] = function()
        local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
        return ServerTimeProxy:GetOpenTime()
    end,
    -- 开服天数
    ["OPEN_SERVER_DAY"] = function()
        local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
        return ServerTimeProxy:GetOpenDay()
    end,
    -- 合服次数
    ["MERGE_SERVER_COUNT"] = function()
        local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
        return ServerTimeProxy:GetMergeCount()
    end,
    -- 合服时间戳
    ["MERGE_SERVER_TIME"] = function()
        local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
        return ServerTimeProxy:GetMergeTime()
    end,
    -- 合区天数
    ["MERGE_SERVER_DAY"] = function()
        local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
        return ServerTimeProxy:GetMergeDay()
    end,
    ----------------------------------------------------------
    -- 摆摊
    -- 获取购买摊位的物品信息
    ["ONSELL_DATA_BY_MAKEINDEX"] = function(makeIndex)
        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        return StallProxy:GetOnSellDataByMakeIndex(makeIndex)
    end,
    -- 获取我的摊位的物品信息
    ["MYSELL_DATA_BY_MAKEINDEX"] = function(makeIndex)
        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        return StallProxy:GetMySellDataByMakeIndex(makeIndex)
    end,
    -- 购买摊位名字
    ["SELL_SHOW_NAME"] = function()
        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        return StallProxy:GetShowStoreName()
    end,
    -- 购买摊位物品数据
    ["ONSELL_DATA"] = function()
        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        return StallProxy:GetOnSellData()
    end,
    -- 我的摊位物品数据
    ["MYSELL_DATA"] = function()
        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        return StallProxy:GetMySellData()
    end,
    ----------------------------------------------------------
    -- 宝箱
    -- 检查是否还有重摇/开启次数
    ["HAVE_GOLDBOX_OPENTIME"] = function()
        local GoldBoxProxy = global.Facade:retrieveProxy(global.ProxyTable.GoldBoxProxy)
        return GoldBoxProxy:CheckHaveOpenTime()
    end,
    ----------------------------------------------------------
    -- MapPos 目标位置到初始位置 方向
    ["TARGET_MAPPOS_DIR"] = function(srcPos, destPos)
        local inputProxy    = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local dir           = inputProxy:calcMapDirection(destPos, srcPos)
        return dir
    end,
    -- 跑步移动格数
    ["RUN_STEP"] = function()
        return CheckRunStep()
    end,
    -- 能否跑
    ["CAN_RUN_ABLE"] = function()
        return CheckRunAble()
    end,
    -- 游戏摇杆移动参数
    ["GAMEPAD_MOVE_PARAM"] = function()
        local GamePadMediator   = requireMediator("mainui/MainGamePadMediator")
        local gamePadController = global.Facade:retrieveMediator(GamePadMediator.NAME)
        return gamePadController:GetGamePadMove()
    end,
    -- CTRL键按下
    ["CTRL_PRESSED"] = function ()
        return global.userInputController._isPressedCtrl
    end,
    ----------------------------------------------------------
    -- 属性加点
    -- 是否启用新版属性加点
    ["IS_NEW_BOUNS"] = function()
        local ReinAttrProxy = global.Facade:retrieveProxy(global.ProxyTable.ReinAttrProxy)
        return ReinAttrProxy:IsNewBouns()
    end,
    -- 新版属性加点配置数据
    ["NEW_BOUNS_CONFIG"] = function()
        local ReinAttrProxy = global.Facade:retrieveProxy(global.ProxyTable.ReinAttrProxy)
        return ReinAttrProxy:GetConfig()
    end,
    -- 新版属性已加点数据
    ["NEW_BOUNS_ADD_DATA"] = function()
        local ReinAttrProxy = global.Facade:retrieveProxy(global.ProxyTable.ReinAttrProxy)
        return ReinAttrProxy:GetNewAddData()
    end,
    ----------------------------------------------------------

    --掉落物是否可拾取 param=掉落物    param1=归属id
    ["IS_PICKABLE_DROPITEM"] = function(param, param1)
        local dropItem = GetActor(param)
        if not dropItem then
            return false
        end

        if not dropItem:IsDropItem() then
            return false
        end

        if dropItem:IsIngored() then
            return false
        end

        local bagProxy  = global.Facade:retrieveProxy( global.ProxyTable.Bag )
        if bagProxy:isToBeFull() and dropItem:GetTypeIndex() ~= 0 then -- 背包满可以捡金币
            return false
        end

        -- check pick state
        if dropItem:GetPickState() >= 1 or dropItem:IsPickTimeout() then
            return false
        end

        -- check owner
        if not proxyUtils:AutoPickItemEnable( dropItem, param1 ) then
            return false
        end

        return true
    end,

    ------------------NP反外挂-----------------------
    ["PC_NP_STATUS"] = function ()
        if not global.isWindows then
            return false
        end
        if global.isDebugMode or global.isGMMode then
            return false
        end
        if not NPProtect or not NPProtect.Inst or not NPProtect.GetNp then
            return false
        end
        return NPProtect:Inst():GetNp() and NPProtect:Inst():GetNpStatusFromCmd()
    end,

    ----------------------------------------------------------
    -- 求购
    -- 菜单列表
    ["PURCHASE_FILTER_LIST"] = function()
        local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
        return PurchaseProxy:GetFirstFilterItem()
    end,
    -- 对应ID 菜单栏配置
    ["PURCHASE_MENU_CONFIG_BY_ID"] = function(id)
        local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
        return PurchaseProxy:GetCTypeByID(id)
    end,
    -- 分类物品列表 key 一级菜单id_二级菜单id
    ["PURCHASE_ITEM_LIST_BY_TYPE"] = function(param1, param2)
        local key = string.format("%s_%s", param1, param2)
        local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
        return PurchaseProxy:GetItemListByType(key)
    end,
    ["PURCHASE_CURRENCIES"] = function()
        local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
        return clone(PurchaseProxy:getCurrencies())
    end,
    ----------------------------------------------------------
    -- 自动使用弹窗
    -- 已添加的弹窗物品唯一ID param1: 类型 1: 人物 2: 英雄 param2: 装备位
    ["AUTOUSE_MAKEINDEX_BY_POS"] = function(param1, param2)
        local AutoUseItemProxy = global.Facade:retrieveProxy(global.ProxyTable.AutoUseItemProxy)
        return AutoUseItemProxy:GetMakeIndexByPos(param1, param2)
    end,
    ----------------------------------------------------------
    -- 是否在引导中 [SGuide]
    ["CHECK_IN_GUIDE"] = function()
        local SGuideMediator = global.Facade:retrieveMediator("SGuideMediator")
        if SGuideMediator and SGuideMediator._layer then
            return true
        end
        return false
    end,
    
    -- 是否开启996客服
    ["IS_SHOW_MAUNAL_SERVICE"] = function()
        local ManualService996Proxy = global.Facade:retrieveProxy(global.ProxyTable.ManualService996Proxy)
        return ManualService996Proxy:IsShow()
    end,

    -- 是否开启996客服
    ["IS_SHOW_MAUNAL_SERVICE"] = function()
        local ManualService996Proxy = global.Facade:retrieveProxy(global.ProxyTable.ManualService996Proxy)
        return ManualService996Proxy:IsShow()
    end,
}


return MetaValueGetDef