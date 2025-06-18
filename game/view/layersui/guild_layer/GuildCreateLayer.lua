local BaseLayer = requireLayerUI("BaseLayer")
local GuildCreateLayer = class("GuildCreateLayer", BaseLayer)

function GuildCreateLayer:ctor()
    GuildCreateLayer.super.ctor(self)
end

function GuildCreateLayer.create(...)
    local layer = GuildCreateLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function GuildCreateLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function GuildCreateLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GUILD_CREATE)
    GuildCreate.main()

    self._guildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    self._bagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)

    self:initEvent()

    self._guildProxy:RequestGuildCreateCost()
end

function GuildCreateLayer:checkItem()
    local cost = self._guildProxy:getCreateCost()
    if not cost or not next(cost) then
        return false
    end
    if not self._bagProxy:GetItemDataByItemName(cost.item) then
        return false
    end
    if string.len(cost.gold) > 0 then
        local str = string.split(cost.gold,"|")
        local currencyID = tonumber(str[1])
        local ncount = tonumber(str[2])
        if GetItemDataNumber(currencyID) < ncount then
            return false
        end
    end
    return true
end

function GuildCreateLayer:initEvent()
    self._quickUI.BtnCreate:addClickEventListener(function(sender, event)
        if IsForbidName(true) then
            return
        end
        if not self:checkItem() then
            return global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1023))
        end
        local guildName = self._quickUI.Input:getString()
        if guildName == "" then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000002))
        else
            -- 敏感字
            local proxySensitive = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
            local function handle_Func(state)
                if not state then
                    return global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1006))
                end
                self._guildProxy:RequestCreateGuild(guildName)
            end
            proxySensitive:IsHaveSensitiveAddFilter(guildName, handle_Func)
        end
    end)

    self._guildProxy:SetCreateAutoLevel(self._quickUI.Input_level:getString())
    self._quickUI.Input_level:addEventListener(function(sender,eventType)
        if eventType == 3 then
            self._guildProxy:SetCreateAutoLevel(self._quickUI.Input_level:getString())
        end
    end)

    self._quickUI.CheckBox:setSelected(true)
    self._guildProxy:SetCreateAutoApply(1)
    self._quickUI.CheckBox:addEventListener(function()
        self._guildProxy:SetCreateAutoApply(self._quickUI.CheckBox:isSelected() and 1 or 0)
    end)
end

function GuildCreateLayer:GetSUIParent()
    return self._quickUI.PMainUI
end

return GuildCreateLayer
