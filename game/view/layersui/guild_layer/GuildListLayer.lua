local BaseLayer = requireLayerUI( "BaseLayer" )
local GuildListLayer = class("GuildListLayer", BaseLayer)

function GuildListLayer:ctor()
    GuildListLayer.super.ctor( self )
end

function GuildListLayer.create(...)
    local layer = GuildListLayer.new()
    if layer:Init(...) then
        return layer
    end

    return nil
end

function GuildListLayer:Init()
    self._ui = ui_delegate(self)

    return true
end

function GuildListLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GUILD_LIST)
    GuildList.main()

    local meta = {}
    meta.clickBtnJoin = handler(self, self.clickBtnJoin)
    meta.clickBtnWar = handler(self, self.clickBtnWar)
    meta.clickBtnAlly = handler(self, self.clickBtnAlly)
    meta.clickBtnCancel = handler(self, self.clickBtnCancel)
    meta.__index = meta
    setmetatable(GuildList, meta)

    GuildList.InitGuildListUI()
    
    self.GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
    self.GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)

end

function GuildListLayer:clickBtnJoin(info)
    self.GuildPlayerProxy:RequestApplyGuild(info.GuildID)
end 

function GuildListLayer:clickBtnWar(info)
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_WarSponsor_Open, {type=1, guildId=info.GuildID, guildName=info.GuildName})
end 

function GuildListLayer:clickBtnAlly(info)
    --是否是盟友
    local allyTime = info.AllyTime
    local isAlly = allyTime and allyTime > 0 and allyTime > GetServerTime()

    local isChairman = self.GuildPlayerProxy:IsChairman()
    if not isChairman then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(50001413)))
        return
    elseif isAlly then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(50001422)))
        return
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_WarSponsor_Open, {type=2, guildId=info.GuildID, guildName=info.GuildName})
end 

function GuildListLayer:clickBtnCancel(info)
    --是否有宣战
    local warTime = info.WarTime
    local isWar = warTime and warTime > 0 and warTime > GetServerTime()
    --是否是盟友
    local allyTime = info.AllyTime
    local isAlly = allyTime and allyTime > 0 and allyTime > GetServerTime()

    local _type = 0
    if isAlly then
        _type = 1
    elseif isWar then
        _type = 2
    end
    if _type == 0 then
        return
    end
    local data    = {}
    data.str = string.format(GET_STRING(_type == 1 and 50001453 or 50001454), SL:GetMetaValue("GAME_DATA", "DEFAULT_FONT_SIZE"), info.GuildName)
    data.btnType  = 2
    data.callback = function(type ,custom)
        if 1 == type then
            if _type == 1 then
                self.GuildProxy:RequestGuildCancelAlly(info.GuildID)
            elseif _type == 2 then       
                self.GuildProxy:RequestGuildCancelWar(info.GuildID)
            end
        end
    end
    global.Facade:sendNotification( global.NoticeTable.Layer_CommonTips_Open, data )
end 

function GuildListLayer:CloseLayer()
    GuildList.RemoveEvent()
end

function GuildListLayer:GetSUIParent()
    return self._ui.PMainUI
end

return GuildListLayer
