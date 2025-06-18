local RemoteProxy = requireProxy("remote/RemoteProxy")
local NoticeProxy = class("NoticeProxy", RemoteProxy)
NoticeProxy.NAME = global.ProxyTable.NoticeProxy

local cjson = require("cjson")

function NoticeProxy:ctor()
    NoticeProxy.super.ctor(self)

    self._isDelete = false
end

function NoticeProxy:handle_MSG_SC_SERVICE_TIPS(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return false
    end
    dump(jsonData)

    -- close
    if not next(jsonData) or (not jsonData.Msg) or (jsonData.Msg == "") then
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Close)
        return false
    end

    local btn = {}
    if jsonData.Btn1 and string.len(jsonData.Btn1) > 1 then
        table.insert(btn, {name = GET_STRING(1001), act = jsonData.Btn1})
    end
    if jsonData.Btn2 and string.len(jsonData.Btn2) > 1 then
        table.insert(btn, {name = GET_STRING(1000), act = jsonData.Btn2})
    end

    local tips    = string.gsub(jsonData.Msg, "\\", "<br>") 
    local data    = {}
    data.str      = tips
    data.btnDesc  = #btn > 0 and {btn[1].name, btn[2] and btn[2].name or nil} or {GET_STRING(1001)}
    data.callback = function(eventIndex)
        if #btn > 0 then
            local cdata    = {}
            cdata.UserID   = jsonData.UserID
            cdata.newIndex = jsonData.newIndex
            cdata.Act      = btn[eventIndex].act
            local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
            NPCProxy:ExecuteWithJsonData(cdata)
        end
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

function NoticeProxy:handle_MSG_SC_SYSTEM_INFO(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return
    end

    local msgHdr = msg:GetHeader()
    -- 掉落组别 1 - 10
    local dropGroup = msgHdr.param3 > 0 and msgHdr.param3 or nil
    -- print("------------------------------------")
    -- print(" into here to get system info ")
    -- dump(jsonData,"handle_MSG_SC_SYSTEM_INFO__")
    -- print("dropGroup======", dropGroup)
    -- print("------------------------------------")

    -- Type:
        -- 1  系统频道
        -- 2  行会频道
        -- 3  组队频道
        -- 4  顶部跑马灯公告
        -- 5  屏幕跑马灯公告 可控制Y轴
        -- 6  聊天上方公告
        -- 7  服务器说是怪物说话?什么鬼
        -- 8  固定聊天
        -- 9  systemtips
        -- 10 可控制xy坐标广播
        -- 11 屏幕跑马灯公告 系统公告
        -- 12 系统频道 带超链
        -- 13 系统公告缩放
        -- 14 倒计时提示 可配置X坐标
        -- 15 物品掉落在屏幕最上方公告 
    -- Msg:提示内容
    -- FColor:文字色值ID
    -- BColor:背景色值ID
    -- Y:坐标Y
    -- Count:播放次数
    -- Time:倒计时
    -- Label:响应Link
    -- Prefix: 聊天消息前缀

    -- 用于区分PC端/手机端不同内容 
    if global.isWinPlayMode and jsonData.Msg1 then
        jsonData.Msg = jsonData.Msg1
    end

    if jsonData.Type == 1 or jsonData.Type == 0 or not jsonData.Type then
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        local setChannelID = dropGroup and ChatProxy.CHANNEL.Drop
        local mdata     = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            ChannelId   = setChannelID or (jsonData.Type == 0 and ChatProxy.CHANNEL.World or ChatProxy.CHANNEL.System),
            SendName    = jsonData.SendName,
            SendId      = jsonData.SendId,
            mt          = jsonData.mt and jsonData.mt or ChatProxy.MSG_TYPE.SRText,
            Prefix      = jsonData.Prefix,
            dropType    = dropGroup
        }
        global.Facade:sendNotification(global.NoticeTable.AddChatItem, mdata)

    elseif jsonData.Type == 12 then
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        local setChannelID = dropGroup and ChatProxy.CHANNEL.Drop
        local mdata     = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            ChannelId   = setChannelID or ChatProxy.CHANNEL.System,
            mt          = ChatProxy.MSG_TYPE.SystemTips,
            Prefix      = jsonData.Prefix,
            dropType    = dropGroup
        }
        global.Facade:sendNotification(global.NoticeTable.AddChatItem, mdata)

    elseif jsonData.Type == 2 then
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        local mdata     = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            ChannelId   = ChatProxy.CHANNEL.Guild,
            mt          = ChatProxy.MSG_TYPE.SystemTips,
            Prefix      = jsonData.Prefix
        }
        global.Facade:sendNotification(global.NoticeTable.AddChatItem, mdata)
    
    elseif jsonData.Type == 3 then
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        local mdata     = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            ChannelId   = ChatProxy.CHANNEL.Team,
            mt          = ChatProxy.MSG_TYPE.SystemTips,
            Prefix      = jsonData.Prefix
        }
        global.Facade:sendNotification(global.NoticeTable.AddChatItem, mdata)

    elseif jsonData.Type == 4 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowServerNotice, data)

    elseif jsonData.Type == 5 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            Y           = jsonData.Y,
            Count       = jsonData.Count,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowSystemNotice, data)

    elseif jsonData.Type == 6 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            Time        = jsonData.Time,
            Label       = jsonData.Label,
            X           = jsonData.X,
            Y           = jsonData.Y
        }
        global.Facade:sendNotification(global.NoticeTable.ShowTimerNotice, data)

    elseif jsonData.Type == 8 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            Time        = jsonData.Time,
            Label       = jsonData.Label,
            SendId      = jsonData.SendId,
            SendName    = jsonData.SendName,

        }
        global.Facade:sendNotification(global.NoticeTable.AddChatExItem, data)

    elseif jsonData.Type == 9 then
        ShowSystemTips(jsonData.Msg)

    elseif jsonData.Type == 10 then
        local data      = {
            X           = jsonData.X,
            Y           = jsonData.Y,
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowSystemNoticeXY, data)

    elseif jsonData.Type == 11 then
        local data      = {
            Type        = jsonData.Type,
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
        }
        global.Facade:sendNotification(global.NoticeTable.ServerNoticeEvent, data)
    elseif jsonData.Type == 13 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            Y           = jsonData.Y,
            Count       = jsonData.Count,
            ShowTime    = jsonData.time,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowSystemNoticeScale, data)
    elseif jsonData.Type == 14 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            Time        = jsonData.Time,
            Label       = jsonData.Label,
            X           = jsonData.X,
            isDelete    = jsonData.isDelete,
        }
        self._isDelete = data.isDelete
        global.Facade:sendNotification(global.NoticeTable.ShowTimerNoticeXY, data)
    elseif jsonData.Type == 15 then
        local data      = {
            Type        = jsonData.Type,
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowItemDropNotice, data)
    end
end

function NoticeProxy:getIsDeleteByType14()
    return self._isDelete
end

function NoticeProxy:handle_MSG_SC_PLAY_AUDIO(msg)
    local jsonData = ParseRawMsgToJson(msg)
    dump(jsonData)
    if not jsonData then
        return nil
    end
    if not jsonData.id or not jsonData.playcount then
        return nil
    end

    local audio_data = {}
    audio_data.id    = jsonData.id
    audio_data.times = jsonData.playcount or 1
    audio_data.loop  = false
    audio_data.type  = global.MMO.SUD_TYPE_SERVER
    global.Facade:sendNotification(global.NoticeTable.Audio_Play_EffectId, audio_data)
end

function NoticeProxy:handle_MSG_SC_REMOVE_TIMER_NOTICE(msg)
    global.Facade:sendNotification(global.NoticeTable.DeleteTimerNotice)
end

function NoticeProxy:handle_MSG_SC_OPENUI(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return
    end
    dump(jsonData)

    local id        = jsonData.id
    local param     = jsonData.param
    local param2    = tonumber(jsonData.param2) or 0
    
    local JumpProxy = global.Facade:retrieveProxy(global.ProxyTable.JumpProxy)
    JumpProxy:JumpTo(id, param, param2)
end

function NoticeProxy:handle_MSG_SC_PLAY_DICE(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return
    end
    dump(jsonData)

    global.Facade:sendNotification(global.NoticeTable.Layer_PlayDice_Open, jsonData)
end

function NoticeProxy:handle_MSG_SC_CLIPBOARD_TEXT(msg)
    local msgLen = msg:GetDataLength()
    if msgLen > 0 then
        local dataString = msg:GetData():ReadString(msgLen)
        if global.isWindows then
            if Win32BridgeCtl then
                Win32BridgeCtl:Inst():copyToClipboard(dataString)
            end
        else
            global.L_NativeBridgeManager:GN_setClipboardText(dataString)
        end
    end
end

function NoticeProxy:handle_MSG_SC_REMOVE_TIMER_NOTICEXY(msg)
    local header = msg:GetHeader()
    -- dump(header.param1) 

    if tonumber(header.param1) and tonumber(header.param1) == 14 then
        global.Facade:sendNotification(global.NoticeTable.DeleteTimerNoticeXY)
    end
end

function NoticeProxy:handle_MSG_SC_START_APP(msg)
    local header = msg:GetHeader()

    if header.recog == 1 then
        -- 拉起qq
        if global.L_NativeBridgeManager.GN_startQQ then
            global.L_NativeBridgeManager:GN_startQQ()
        end
        
    elseif header.recog == 2 then
        -- 加qq好友
        local jsonData = ParseRawMsgToJson(msg)
        if jsonData and jsonData.qqKey then
            if global.L_NativeBridgeManager.GN_joinQQ then
                global.L_NativeBridgeManager:GN_joinQQ({qqKey = jsonData.qqKey})
            end
        end
    
    elseif header.recog == 3 then
        -- 加qq群
        local jsonData = ParseRawMsgToJson(msg)
        if jsonData and jsonData.qqGroupUin and jsonData.qqGroupKey then
            if global.L_NativeBridgeManager.GN_joinQQGroup then
                global.L_NativeBridgeManager:GN_joinQQGroup({qqGroupUin = jsonData.qqGroupUin, qqGroupKey = jsonData.qqGroupKey})
            end
        end

    elseif header.recog == 4 then
        -- 拉微信
        if global.L_NativeBridgeManager.GN_startWX then
            global.L_NativeBridgeManager:GN_startWX()
        end

    elseif header.recog == 5 then
        -- todo
        -- 拉微信公众号
    end
end

function NoticeProxy:handle_MSG_SC_SERVER_GAME_ERROR(msg)
    -- 健康游戏提醒
    local function callback(bType, custom)
        -- PC上默认退出，方便获取新的登录信息以及更新exe
        if global.isWindows then
            global.Director:endToLua()
		else
			global.L_NativeBridgeManager:GN_accountLogout()
			global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
        end
    end

    -- 提醒内容
    local msgLen = msg:GetDataLength()
    local dataString = msgLen > 0 and  msg:GetData():ReadString(msgLen) or ""
    local data = {}
    data.str = dataString
    data.btnDesc = { GET_STRING(1001)}
    data.callback = callback
    data.hideCloseBtn = true
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)

    -- 重连禁用
    global.Facade:sendNotification(global.NoticeTable.ReconnectForbidden)
end

function NoticeProxy:handle_MSG_SC_LIMIT_CHAT(msg)
    local header = msg:GetHeader()
    local forbidSay = header.recog

    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    LoginProxy:SetForbidChat(forbidSay == 1)
end

-- 自定义事件数据上报
function NoticeProxy:handle_MSG_SC_CUSTOM_EVENT_REPORT(msg)
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return
    end
    local dataString = msg:GetData():ReadString(msgLen)

    local NativeBridgeProxy = global.Facade:retrieveProxy(global.ProxyTable.NativeBridgeProxy)
    NativeBridgeProxy:GN_ReportCustomEvent(dataString)
end

function NoticeProxy:RegisterMsgHandlerAfterEnterWorld()
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_SERVICE_TIPS, handler(self, self.handle_MSG_SC_SERVICE_TIPS))
    LuaRegisterMsgHandler(msgType.MSG_SC_SYSTEM_INFO, handler(self, self.handle_MSG_SC_SYSTEM_INFO))    -- 接收到的系统消息
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAY_AUDIO, handler(self, self.handle_MSG_SC_PLAY_AUDIO))      -- 播放音乐
    LuaRegisterMsgHandler(msgType.MSG_SC_REMOVE_TIMER_NOTICE, handler(self, self.handle_MSG_SC_REMOVE_TIMER_NOTICE))    -- 删除定时系统消息
    LuaRegisterMsgHandler(msgType.MSG_SC_OPENUI, handler(self, self.handle_MSG_SC_OPENUI))      -- 打开界面
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAY_DICE, handler(self, self.handle_MSG_SC_PLAY_DICE))      -- 播放骰子
    LuaRegisterMsgHandler(msgType.MSG_SC_CLIPBOARD_TEXT, handler(self, self.handle_MSG_SC_CLIPBOARD_TEXT))      -- 播放骰子
    LuaRegisterMsgHandler(msgType.MSG_SC_REMOVE_TIMER_NOTICEXY, handler(self, self.handle_MSG_SC_REMOVE_TIMER_NOTICEXY))
    LuaRegisterMsgHandler(msgType.MSG_SC_START_APP, handler(self, self.handle_MSG_SC_START_APP))
    LuaRegisterMsgHandler(msgType.MSG_SC_SERVER_GAME_ERROR, handler(self, self.handle_MSG_SC_SERVER_GAME_ERROR))
    LuaRegisterMsgHandler(msgType.MSG_SC_LIMIT_CHAT, handler(self, self.handle_MSG_SC_LIMIT_CHAT))
    LuaRegisterMsgHandler(msgType.MSG_SC_CUSTOM_EVENT_REPORT, handler(self, self.handle_MSG_SC_CUSTOM_EVENT_REPORT))
end

return NoticeProxy
