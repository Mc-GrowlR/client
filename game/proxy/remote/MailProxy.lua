local RemoteProxy = requireProxy("remote/RemoteProxy")
local MailProxy = class("MailProxy", RemoteProxy)
MailProxy.NAME = global.ProxyTable.MailProxy

function MailProxy:ctor()
    self.mailIdList = {}        --服务器发过来的邮件列表
    self.mailCount = 0          --邮件个数
    self.newMailCount = 0       --新邮件个数
    self.curMailId = 0          --当前打开的邮件
    MailProxy.super.ctor(self)
end

function MailProxy:resetList()
    self.mailIdList = {}
    self.mailCount = 0
    self.newMailCount = 0
end

--获取邮件的邮件列表
function MailProxy:getMailList()
    return self.mailIdList
end

--根据邮件的mailId得到邮件
function MailProxy:getMailByMailId(mailId)
    return self.mailIdList[mailId]
end

--添加邮件
function MailProxy:addMail(mail)
    if mail == nil then
        return
    end

    -- {"Id":"1","btType":"1","sChrName":"张三","sSendName":"系统","sLable":"测试邮件","sMemo":"这是正文","sItem":[{"Index":6,"Count":30,"Bind":false}],"dCreateTime":"2010-01-00 00:00:00","btReadFlag","0","btRecvFlag","0"}
    -- btType:邮件类型，1：系统，2：战报，3：团队，4：行会
    -- dCreateTime:发送时间
    -- btReadFlag：读标志：0未读，1已读
    -- btRecvFlag：附件领取标志：0：未领取，1：已领取

    self.mailCount = self.mailCount + 1

    mail.Id = tonumber(mail.Id)
    mail.btType = tonumber(mail.btType)
    mail.btReadFlag = tonumber(mail.btReadFlag)
    mail.btRecvFlag = tonumber(mail.btRecvFlag)
    mail.sItem = mail.sItem or {}
    mail.index = self.mailCount
    self.mailIdList[mail.Id] = mail
end

--设置当前打开的邮件
function MailProxy:setCurMailId(mailId)
    if mailId == nil then
        return
    end
    self.curMailId = mailId
end

function MailProxy:getCurMailId()
    return self.curMailId
end

--获取邮件数量
function MailProxy:getMailCount()
    return self.mailCount
end

--获取新邮件数量
function MailProxy:getNewMailCount()
    return self.newMailCount
end

--获取邮件状态
function MailProxy:getMailState(mailId)
    if self.mailIdList[mailId] == nil then
        return false
    end
    return self.mailIdList[mailId].btReadFlag
end

--是否有未读邮件
function MailProxy:haveUnread()
    for k, v in pairs(self.mailIdList) do
        if v.btReadFlag == 0 or (#v.sItem > 0 and v.btRecvFlag == 0) then
            return true
        end
    end
    return false
end

--是否有邮件可以删除
function MailProxy:isHaveDeleteMail()
    for k, v in pairs(self.mailIdList) do
        if v.btReadFlag == 1 and (#v.sItem == 0 or (#v.sItem > 0 and v.btRecvFlag == 1)) then
            return true
        end
    end
    return false
end

--左下角显示未读邮件的提醒
function MailProxy:showMainToolsBar(flag)
    local show = false
    if flag ~= nil then
        show = flag
    else
        show = self:haveUnread()
    end

    local function callback()
        JUMPTO(16)
    end
    local bubbleTips = {}
    bubbleTips.id = 2
    bubbleTips.status = show
    bubbleTips.callback = callback
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, bubbleTips)
end

--读邮件
function MailProxy:readMail(mailId)
    if self.mailIdList[mailId] == nil then
        return false
    end

    LuaSendMsg(global.MsgType.MSG_CS_EMAIL_READ_REQUEST, mailId)
    self.mailIdList[mailId].btReadFlag = 1

    self:showMainToolsBar()
end

--提取附件
function MailProxy:getMailItems(mailId)
    if self.mailIdList[mailId] == nil then
        return false
    end
    LuaSendMsg(global.MsgType.MSG_CS_EMAIL_GET_REQUEST, 1, mailId)
end

--全部提取
function MailProxy:getAllMailItems()
    LuaSendMsg(global.MsgType.MSG_CS_EMAIL_GET_REQUEST, 2)
end

--删除邮件
function MailProxy:deleteMail(mailId)
    if self.mailIdList[mailId] == nil then
        return false
    end
    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000409))
    LuaSendMsg(global.MsgType.MSG_CS_EMAIL_DELETE_REQUEST, mailId)

    self.mailIdList[mailId] = nil
    self.mailCount = self.mailCount - 1

    if self.mailIdList == nil then
        self.mailIdList = {}
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Mail_DelOneMailSucc, mailId)
end

--删除已读
function MailProxy:deleteReadMail()
    if self.mailIdList and next(self.mailIdList) then
        LuaSendMsg(global.MsgType.MSG_CS_EMAIL_DELETE_ALL_REQUEST)
    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000410))
    end
end

--请求获取邮件列表 一次十条
function MailProxy:RequestMailList()
    self:resetList()
    LuaSendMsg(global.MsgType.MSG_CS_EMAIL_LIST_REQUEST)
end

function MailProxy:handle_MSG_SC_EMAIL_LIST_RESPONSE(msg)
    local header = msg:GetHeader()
    local len = msg:GetDataLength()
    local page = header.recog
    local data = msg:GetData()
    if len > 0 then
        local sliceStr = data:ReadString(len)
        local cjson = require("cjson")
        local jsonData = cjson.decode(sliceStr)

        for _, mail in pairs(jsonData) do
            self:addMail(mail)
        end

        global.Facade:sendNotification(global.NoticeTable.Layer_Mail_DelAllMailSucc)

    else
        self:resetList()
        global.Facade:sendNotification(global.NoticeTable.Layer_Mail_DelAllMailSucc)
    end

    self:showMainToolsBar()
end

function MailProxy:handle_MSG_SC_EMAIL_DELETE_ALL_RESPONSE(msg)
    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000409))
    self:RequestMailList()
end

function MailProxy:handle_MSG_SC_EMAIL_GET_RESPONSE(msg)
    local header = msg:GetHeader()
    if header.recog == 1 then
        local mailId = header.param1
        if self.mailIdList[mailId] then
            self.mailIdList[mailId].btRecvFlag = 1
        end
        SLBridge:onLUAEvent(LUA_EVENT_MAIL_UPDATE)
        self:showMainToolsBar()
    end

    if header.recog == 2 then
        self:RequestMailList()
    end
end

function MailProxy:handle_MSG_SC_EMAIL_NEW_NOTI(msg)
    self.newMailCount = self.newMailCount + 1
    self:showMainToolsBar(true)
end

function MailProxy:RegisterMsgHandler()
    MailProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    LuaRegisterMsgHandler(msgType.MSG_SC_EMAIL_LIST_RESPONSE, handler(self, self.handle_MSG_SC_EMAIL_LIST_RESPONSE)) -- 邮件列表
    LuaRegisterMsgHandler(msgType.MSG_SC_EMAIL_DELETE_ALL_RESPONSE, handler(self, self.handle_MSG_SC_EMAIL_DELETE_ALL_RESPONSE)) -- 删除已读的邮件
    LuaRegisterMsgHandler(msgType.MSG_SC_EMAIL_GET_RESPONSE, handler(self, self.handle_MSG_SC_EMAIL_GET_RESPONSE)) --提取附件成功
    LuaRegisterMsgHandler(msgType.MSG_SC_EMAIL_NEW_NOTI, handler(self, self.handle_MSG_SC_EMAIL_NEW_NOTI)) -- 新邮件到来
end

return MailProxy