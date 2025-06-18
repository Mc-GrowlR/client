local BaseLayer = requireLayerUI( "BaseLayer" )
local MailLayer = class( "MailLayer", BaseLayer )

function MailLayer:ctor()
    MailLayer.super.ctor( self )
end

function MailLayer.create(noticeData)
    local layer = MailLayer.new()
    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function MailLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function MailLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIL)
    Mail.main()
end

function MailLayer:CloseLayer()
    Mail.RemoveEvent()
end

--刷新左边的邮件列表
function MailLayer:refreshMailList()
    Mail.RefreshMailList()
end

function MailLayer:delOneMailSucc( mailId )
    Mail.DelOneMail(mailId)
end

function MailLayer:delAllMailSucc()
    self:refreshMailList()
end

return MailLayer