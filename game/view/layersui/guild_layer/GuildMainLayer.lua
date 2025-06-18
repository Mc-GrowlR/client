local BaseLayer = requireLayerUI("BaseLayer")
local GuildMainLayer = class("GuildMainLayer", BaseLayer)

function GuildMainLayer:ctor()
    GuildMainLayer.super.ctor(self)
end

function GuildMainLayer.create(...)
    local layer = GuildMainLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function GuildMainLayer:Init()
    self._guildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
    self._guildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    self._quickUI = ui_delegate(self)
    return true
end

function GuildMainLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GUILD_MAIN)
    GuildMain.main()

    self:InitEvent()
    self._guildProxy:RequestGuildInfo()
end

function GuildMainLayer:InitEvent()
    local function editEvent(ref, eventType)
        if eventType == ccui.TextFiledEventType.detach_with_ime then   
            -- 后台控制不可聊天
            if IsForbidSay(true) then
                return
            end
            
            local str = self._quickUI.EditInput:getString()
            if not str or str == "" then
                -- 空的公告
                local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
                GuildProxy:RequestEditNotice(str)
                return
            end

            -- 敏感字
            local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
            SensitiveWordProxy:fixSensitiveTalkAddFilter(str, function(status, content)
                local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
                GuildProxy:RequestEditNotice(content)
            end)
        end
    end
    self._quickUI.EditInput:addEventListener(editEvent)
end

function GuildMainLayer:CloseLayer()
    GuildMain.RemoveEvent()
end

function GuildMainLayer:GetSUIParent()
    return self._quickUI.PMainUI
end

return GuildMainLayer
