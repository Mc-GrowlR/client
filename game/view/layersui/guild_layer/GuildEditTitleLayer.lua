local BaseLayer = requireLayerUI("BaseLayer")
local GuildEditTitleLayer = class("GuildEditTitleLayer", BaseLayer)

function GuildEditTitleLayer:ctor()
    GuildEditTitleLayer.super.ctor(self)
end

function GuildEditTitleLayer.create(...)
    local layer = GuildEditTitleLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function GuildEditTitleLayer:Init()
    self._guildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    self._quickUI = ui_delegate(self)
    return true
end

function GuildEditTitleLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GUILD_EDITTITLE)
    local meta = {
        _GetGuildTitleData = function ()
            return self._guildProxy:getGuildTitleList()
        end,
        _GetTitleNameByIndex = function (index)
            return self._guildProxy:getGuildTitleByRank(index)
        end,
        _SaveOpt = function (editList)
            if SL:GetMetaValue("M2_FORBID_SAY", true) then
                return false
            end

            local data = {}
            for k,edit in ipairs(editList) do
                local inputStr = edit:getString()
                data["rank"..k] = inputStr
            end

            local strList = {}
            for _, v in pairs(data) do
                table.insert(strList, v)
            end
            local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
            SensitiveWordProxy:IsHaveSensitiveEx(strList, function(state)
                if not state then
                    SL:ShowSystemTips(GET_STRING(1006))
                    return
                end

                self._guildProxy:RequestSetGuildTitle(data)
                self:OnClose()
            end)
        end
    }
    meta.__index = meta
    setmetatable(GuildEditTitle, meta)
    GuildEditTitle.main()
end

function GuildEditTitleLayer:OnClose()
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_EditTitle_Close)
end

return GuildEditTitleLayer
