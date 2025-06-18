local BaseLayer = requireLayerUI("BaseLayer")
local GuildApplyListLayer = class("GuildApplyListLayer", BaseLayer)

function GuildApplyListLayer:ctor()
    GuildApplyListLayer.super.ctor(self)
end

function GuildApplyListLayer.create(...)
    local layer = GuildApplyListLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function GuildApplyListLayer:Init()
    self._guildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    self._quickUI = ui_delegate(self)
    return true
end

function GuildApplyListLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GUILD_APPLY_LIST)
    GuildApplyList.main()

    local meta = {}
    meta.clickBtnAgree = handler(self, self.clickBtnAgree)
    meta.clickBtnDisagree = handler(self, self.clickBtnDisagree)
    meta.__index = meta
    setmetatable(GuildApplyList, meta)

    self:initEvent()

    self._guildProxy:RequestGuildInfo()
    self._guildProxy:RequestApplyGuildList()
end

function GuildApplyListLayer:initEvent()
    self._quickUI.BtnAll:addClickEventListener(function()
        self._quickUI.ListView:removeAllItems()
        self._cells = {}
        self._guildProxy:RequestAllAddMember()
    end)

    self._quickUI.CheckBox:setSelected(self._guildProxy:getAutoJoin())

    self._quickUI.CheckBox:addEventListener(function()
        self._guildProxy:RequestAutoAddMember(self._quickUI.CheckBox:isSelected() and 1 or 0, self._quickUI.Input:getString())
        self._guildProxy:RequestGuildInfo()
    end)

    self._quickUI.Input:setString(self._guildProxy:getJoinLevel())
    self._quickUI.Input:addEventListener(function(sender,eventType)
        local input = tonumber(GUI:TextInput_getString(sender)) or 0
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local maxLevel = PlayerPropertyProxy:GetMaxLevel()
        if maxLevel then
            input = math.min(input, maxLevel)
            self._quickUI.Input:setString(input)
        end
        if eventType == 3 then
            self._guildProxy:RequestAutoAddMember(self._quickUI.CheckBox:isSelected() and 1 or 0, self._quickUI.Input:getString())
            self._guildProxy:RequestGuildInfo()
        end
    end)
end

function GuildApplyListLayer:clickBtnAgree(userID)
    self._guildProxy:RequestAddMember(userID)
end 

function GuildApplyListLayer:clickBtnDisagree(userID)
    self._guildProxy:RequestRefuseMember(userID)
end 

return GuildApplyListLayer
