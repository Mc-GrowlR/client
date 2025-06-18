local GuideEventConfig = require("config/GuideEventConfig.lua")
local MetaValueSetDef = {
    -- 设置当前邮件ID param1=邮件ID
    ["MAIL_CURRENT_ID"] = function(param1)
        local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
        MailProxy:setCurMailId(param1)
    end,

    -- 设置当前选中的背包页
    ["BAG_PAGE_CUR"] = function(param1)
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        BagProxy:SetCurPage(param1)
    end,

    -- 设置当前选中的背包页
    ["STORGE_PAGE_CUR"] = function(param1)
        local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
        NPCStorageProxy:SetStoragePageIndex(param1)
    end,

    ["GAME_DATA"] = function(key, value)
        global.ConstantConfig[key] = value
    end,

    -- 切换聊天频道接收状态  param1=聊天频道
    ["CHAT_CHANNEL_RECEIVIND"] = function(param1, param2)
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        local isReceiving = ChatProxy:isReceiving(param1)
        if type(param2) == "boolean" then
            ChatProxy:setReceiving(param1, param2)
        else
            ChatProxy:setReceiving(param1, not isReceiving)
        end
    end,
    -- 当前聊天频道
    ["CUR_CHAT_CHANNEL"] = function(param1)
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        ChatProxy:setChannel(param1)
    end,
    -- 
    -- 设置的数据 param1=设置ID  param2=设置值 table
    ["SETTING_VALUE"] = function(param1, param2)
        CHANGE_SETTING(param1, param2)
    end,
    -- 设置捡物品数据 param1=设置ID  param2=值
    ["SETTING_PICK_VALUE"] = function(param1, param2)
        CHANGE_SETTING_PICK(param1, param2)
    end,
    -- 设置捡物品 组 数据 param1=设置ID  param2=值
    ["SETTING_PICK_GROUP_VALUE"] = function(param1, param2)
        CHANGE_GROUPSETTING_PICK(param1, param2)
    end,
    --设置 排序的设置相关数据（param1: ID, param2: data）
    ["SETTING_RANK_DATA"] = function(param1, param2)
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        return GameSettingProxy:setRankData(param1, param2)
    end,
    --设置boss提示类型
    ["BOSS_REMIND_TYPE"] = function(param1)
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        return GameSettingProxy:SetBossType(param1)
    end,
    --设置boss提示值 
    ["BOS_REMIND_VALUE"] = function(param1)
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        GameSettingProxy:SetBossTipsValues(param1)
    end,
    ---角色面板时装显示开关 
    ["SUPEREQUIP_SHOW"] = function(param1)
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return PlayerProperty:SetShowSetting(param1)
    end,
    --技能快捷键
    ["SKILL_KEY"] = function(param1, param2)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:SetSkillKey(param1, param2)
    end,
    --是否点击了英雄守护按钮 
    ["HERO_GUARD_ISCLICK"] = function(param1)
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:setGuardBtnState(param1)
    end,
    --英雄激活的状态
    ["HERO_ACTIVES_STATES"] = function(param1)
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:setStates(param1)
    end,
    --英雄设置技能快捷键
    ["H.SKILL_KEY"] = function(param1, param2)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:SetSkillKey(param1, param2)
    end,
    ---英雄面板时装显示开关 
    ["HERO_SUPEREQUIP_SHOW"] = function(param1)
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        return HeroPropertyProxy:SetShowSetting(param1)
    end,
    --合成打开的id
    ["COMPOUND_OPEN_ID"] = function(param1)
        local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
        ItemCompoundProxy:SetOnCompoundIndex(param1)
    end,
    -- 开始自动挂机
    ["BATTLE_AFK_BEGIN"] = function()
        local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        if AutoProxy:IsAFKState() then
            return
        end
        LuaSendMsg(global.MsgType.MSG_CS_AUTOPLAYGAME_REQUEST, 1)
        global.Facade:sendNotification(global.NoticeTable.AFKBegin)
    end,
    -- 结束自动挂机
    ["BATTLE_AFK_END"] = function()
        LuaSendMsg(global.MsgType.MSG_CS_AUTOPLAYGAME_REQUEST, 2)
        global.Facade:sendNotification(global.NoticeTable.AFKEnd)
    end,
    -- 开始自动捡物
    ["BATTLE_PICK_BEGIN"] = function()
        global.Facade:sendNotification(global.NoticeTable.AutoPickBegin)
    end,
    -- 结束自动捡物
    ["BATTLE_PICK_END"] = function()
        global.Facade:sendNotification(global.NoticeTable.AutoPickEnd)
    end,
    -- 开始自动寻路
    ["BATTLE_MOVE_BEGIN"] = function(mapID, mapX, mapY, target, type)
        local movePos =    {
            mapID = mapID,
            x    = mapX,
            y    = mapY,
            autoMoveType = type or global.MMO.AUTO_MOVE_TYPE_MINIMAP
        }
        global.Facade:sendNotification(global.NoticeTable.AutoMoveBegin, movePos)
    
        -- auto target
        if target then
            local targetType  = target.type == 0 and global.MMO.ACTOR_MONSTER or global.MMO.ACTOR_NPC
            local targetIndex = target.index
            local moveType    = global.MMO.AUTO_MOVE_TYPE_TARGET
            local autoTarget  =        
            {
                x             = mapX,
                y             = mapY,
                mapID         = mapID,
                targetType    = targetType,
                targetIndex   = targetIndex,
                priority      = global.MMO.INPUT_PRIORITY_USER,
                autoMoveType  = moveType
            }
            local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
            AutoProxy:SetAutoTarget(autoTarget)
        end
    end,
    -- 结束自动寻路
    ["BATTLE_MOVE_END"] = function()
        global.Facade:sendNotification(global.NoticeTable.AutoMoveEnd)
    end,
    -- 选择目标ID
    ["SELECT_TARGET_ID"] = function(targetID)
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        return PlayerInputProxy:SetTargetID(targetID)
    end,
    -- PC持续攻击目标
    ["SELECT_SHIFT_ATTACK_ID"] = function(attachID)
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        return PlayerInputProxy:SetAttackTargetID(attachID)
    end,
    -- 设置战斗状态
    ["ATTACK_STATE"] = function(state)
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:SetAttackState(state)
    end,
    -- 设置转向方向
    ["TURN_DIR"] = function(dir)
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:SetMouseTurnDir(dir)
    end,
    -- 设置功能菜单参数
    ["FUNCDOCK_PARAM"] = function(data)
        if data then
            local FuncDockProxy = global.Facade:retrieveProxy(global.ProxyTable.FuncDockProxy)
            FuncDockProxy:clean()
            FuncDockProxy:SetTargetName(data.targetName)
            FuncDockProxy:SetTargetId(data.targetId)
            FuncDockProxy:SetTargetType(data.type)
            FuncDockProxy:SetPlayerBasic(data.basic)
        end
    end,
    -- 设置剪贴板文本
    ["CLIPBOARD_TEXT"] = function(str)
        if str then
            if global.isWindows then
                if Win32BridgeCtl then
                    Win32BridgeCtl:Inst():copyToClipboard(str)
                end
            else
                global.L_NativeBridgeManager:GN_setClipboardText(str)
            end
        end
    end,
    --掉落物 飞向的世界坐标 优先级比txt设置的高
    ["DROPITEM_FLY_WORLD_POSITION"] = function(x, y)
        local PickupSpriteProxy = global.Facade:retrieveProxy(global.ProxyTable.PickupSpriteProxy)
        PickupSpriteProxy:setMetaPositon(x, y)
    end,
    -- 内功技能开关
    ["INTERNAL_SKILL_ONOFF"] = function(param1, param2, param3)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        return SkillProxy:SetNGSkillOnOff(param1, param2, param3)
    end,
    ["H.INTERNAL_SKILL_ONOFF"] = function(param1, param2, param3)
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        return HeroSkillProxy:SetNGSkillOnOff(param1, param2, param3)
    end,
    -- 设置快捷栏个数
    ["QUICK_USE_NUM"] = function(size)
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        QuickUseProxy:SetQuickUseSize(size)
    end,
    -- 通知引导事件开始
    ["GUIDE_EVENT_BEGAN"] = function(guideID, needResetPos)
        local eventName = GuideEventConfig[guideID] and GuideEventConfig[guideID].startEventTag
        if eventName then
            global.Facade:sendNotification(global.NoticeTable.GuideEventBegan, { name = eventName })
            if needResetPos then
                global.Facade:sendNotification(global.NoticeTable.GuideLayerResetPos)
            end
        end
    end,
    -- 通知引导事件结束
    ["GUIDE_EVENT_END"] = function(guideID)
        local eventName = GuideEventConfig[guideID] and GuideEventConfig[guideID].closeEventTag
        if eventName then
            global.Facade:sendNotification(global.NoticeTable.GuideEventEnded, { name = eventName })
        end
    end,
    -- 修改屏幕分辨率，只能在PC端使用
    ["WIN_DEVICE_SIZE"] = function(width, height)
        if not global.isWinPlayMode then
            return
        end
        width                   = ConvertToEven(width)
        height                  = ConvertToEven(height)
        local designSize        = cc.size(width, height)

        local glview            = global.Director:getOpenGLView()
        glview:setFrameSize(designSize.width, designSize.height)

        local resolutionData    = {}
        resolutionData.rType    = global.DesignPolicy
        resolutionData.size     = designSize
        global.Facade:sendNotification(global.NoticeTable.ChangeResolution, resolutionData)
    end,
    -- 摆摊设置选中物品唯一ID
    ["STALL_SELECT_ID"] = function(makeIndex)
        local stallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        stallProxy:SetSelectItem(makeIndex)
    end,
    -- 设置PC聊天输入框内容
    ["PC_CHAT_INPUT_FILL"] = function(str)
        if type(str) == "string" then
            global.Facade:sendNotification(global.NoticeTable.PCFillChatInput, str)
        end
    end,
    -- 设置允许组队状态
    ["TEAM_STATUS_PERMIT"] = function(status)
        if not status then
            return
        end
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        TeamProxy:SetPermitStatus(status)
        TeamProxy:RequestPermit()
    end,
    -- 设置允许添加状态
    ["ADD_STATUS_PERMIT"] = function(status)
        if not status then
            return
        end
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        TeamProxy:SetAddStatus(status)
        TeamProxy:RequestPermit()
    end,
    -- 设置允许交易状态
    ["DEAL_STATUS_PERMIT"] = function(status)
        if not status then
            return
        end
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        TeamProxy:SetDealStatus(status)
        TeamProxy:RequestPermit()
    end,
    -- 设置允许显示状态
    ["SHOW_STATUS_PERMIT"] = function(status)
        if not status then
            return
        end
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        TeamProxy:SetShowStatus(status)
        TeamProxy:RequestPermit()
    end,
    -- 手动发起移动 way: 1点击地板 2摇杆 
    ["USER_TO_MOVE"] = function(destPos, moveDir, moveStep, way)
        if not destPos or not next(destPos) then
            return
        end
        if not way or way == 1 then
            way = global.MMO.INPUT_MOVE_TYPE_GRID
        elseif way == 2 then
            way = global.MMO.INPUT_MOVE_TYPE_JOYSTICK
        end
        local dest          = {}
        dest.x              = destPos.x
        dest.y              = destPos.y
        dest.moveDir        = moveDir
        dest.moveStep       = moveStep
        dest.type           = way
        global.Facade:sendNotification(global.NoticeTable.UserInputMove, dest)
    end, 
    -- 是否接收该分类掉落
    ["DROP_TYPE_ISRECEIVE"] = function(type, value)
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        return ChatProxy:SetDropTypeSwitch(type, value)
    end,
    -- 自动使用弹窗 添加物品唯一ID param1: 类型 1: 人物 2: 英雄 param2: 装备位 param3: makeIndex
    ["AUTOUSE_MAKEINDEX_BY_POS"] = function(param1, param2, param3)
        local AutoUseItemProxy = global.Facade:retrieveProxy(global.ProxyTable.AutoUseItemProxy)
        return AutoUseItemProxy:SetMakeIndexByPos(param1, param2, param3)
    end,
}

return MetaValueSetDef