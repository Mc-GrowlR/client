local BaseLayer = requireLayerUI("BaseLayer")
local GuildWarSponsorLayer = class("GuildWarSponsorLayer", BaseLayer)

function GuildWarSponsorLayer:ctor()
    GuildWarSponsorLayer.super.ctor(self)
end

function GuildWarSponsorLayer.create(...)
    local layer = GuildWarSponsorLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function GuildWarSponsorLayer:Init(data)
    self._quickUI = ui_delegate(self)

    self._data = data

    return true
end

function GuildWarSponsorLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GUILD_WAR_SPONSOR)
    GuildWarSponsor.main()

    self:InitUI()
end

function GuildWarSponsorLayer:InitUI()
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)

    self._quickUI.BtnOk:addClickEventListener(function()
        if self._data.type == 1 then
            GuildProxy:RequestGuildSponsor(self._data.guildId, GuildWarSponsor._select)
        elseif self._data.type == 2 then
            GuildProxy:RequestGuildAlly(self._data.guildId, GuildWarSponsor._select)
        end
        SL:CloseGuildWarSponsorUI()
    end)

    GuildWarSponsor.InitWarSponsorUI(self._data)
end

return GuildWarSponsorLayer

