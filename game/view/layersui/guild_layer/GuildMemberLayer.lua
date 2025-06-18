local BaseLayer = requireLayerUI("BaseLayer")
local GuildMemberLayer = class("GuildMemberLayer", BaseLayer)

function GuildMemberLayer:ctor()
    self._memberCell = {}
    self._memberList  = {}
    self._filterLevel = 1
    self._filterRank  = 0
    self._filterJob   = 0
    self._maxMember = 0
    GuildMemberLayer.super.ctor(self)
end

function GuildMemberLayer.create(...)
    local layer = GuildMemberLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function GuildMemberLayer:Init()
    self._quickUI = ui_delegate(self)
    self._guildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
    self._guildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)

    return true
end

function GuildMemberLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GUILD_MEMBER)
    GuildMember.main()

    self:InitEvent()

    self._guildProxy:RequestMemberList()
end

function GuildMemberLayer:InitEvent()
    self._quickUI.BtnDissolve:addClickEventListener(function ()
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, 
        {
            str = GET_STRING(50000004), 
            btnType = 2, 
            callback = function(tag)
                if tag == 1 then
                    self._guildPlayerProxy:RequestDissolveGuild()
                end
            end})
    end)

    self._quickUI.BtnQuit:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, {str = GET_STRING(50000005),
        btnType = 2, 
        callback = function(tag)
            if tag == 1 then
                self._guildPlayerProxy:RequestGuildExit()
            end
        end})
    end)
    
    self._quickUI.BtnLevel:addClickEventListener(function()
        self._filterLevel = self._filterLevel ==  1 and 2 or 1
        self._quickUI.BtnLevel:setRotation(self._filterLevel == 1 and 0 or 180)
        self:Refresh(true)
    end)

    self._quickUI.BtnLevel:setRotation(self._filterLevel == 1 and 0 or 180)
    self._quickUI.Text_level:addClickEventListener(function() self:showFilterLevel() end)
    self._quickUI.BtnJob:addClickEventListener(function() self:showFilterJob() end)
    self._quickUI.BtnOfficial:addClickEventListener(function() self:showFilterOfficial() end)

    for i=1,2 do
        local image = self._quickUI.FilterLevel
        local item = image:getChildByName("ListView_filter"):getChildByName("filter"..i)
        if item then
            item:setTag(i)
            item:addClickEventListener(function()
                image:setVisible(false)
                self._filterLevel = i
                self:Refresh()
            end)
        end
    end

    for i=0,3 do
        local image = self._quickUI.FilterJob
        local item = image:getChildByName("ListView_filter"):getChildByName("filter"..i)
        if item then
            item:setTag(i)
            item:addClickEventListener(function()
                image:setVisible(false)
                self._filterJob = i
                self:Refresh()
            end)
        end
    end

    for i=0,5 do
        local image = self._quickUI.FilterOfficial
        local item = image:getChildByName("ListView_filter"):getChildByName("filter"..i)
        if item then
            item:setTag(i)
            item:addClickEventListener(function()
                image:setVisible(false)
                self._filterRank = i
                self:Refresh()
            end)
        end
    end

    self._quickUI.BtnEditTitle:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_Guild_EditTitle_Open)
    end)

    self:refreshInfo()
end

function GuildMemberLayer:compareJob(job, info)
    if job == 0 then
        return true
    end
    return job == (info.Job + 1)
end

function GuildMemberLayer:compareRank(rank, info)
    if rank == 0 then
        return true
    end

    if rank == 1 then
        return self._guildPlayerProxy:IsMaster(info.Rank)
    else
        return rank == info.Rank
    end
end

function GuildMemberLayer:Refresh(levelSort)
    self._memberList  = {}
    self._memberCell = {}
    local tempData = {}
    for i,v in pairs(self._guildProxy:GetMemberList()) do
        if self:compareJob(self._filterJob, v) and self:compareRank(self._filterRank, v) then
            table.insert( self._memberList, v )
        end
    end

    table.sort(self._memberList, function(a, b)
        if not levelSort then
            if a.Online ~= b.Online then
                return a.Online == 1
            end
    
            if a.Rank ~= b.Rank then
                return a.Rank < b.Rank
            end
        end
        
        if self._filterLevel > 0 and a.Level ~= b.Level then
            if self._filterLevel == 1 then
                return a.Level > b.Level
            elseif self._filterLevel == 2 then
                return a.Level < b.Level
            end
        end
        
        return a.Name < b.Name
    end)

    GuildMember.RefreshMemberList(self._memberList, self._memberCell)

    self:refreshInfo()
    self:refreshMemberCount()
end

function GuildMemberLayer:refreshInfo()
    self._quickUI.BtnDissolve:setVisible(self._guildPlayerProxy:IsMaster())
    self._quickUI.BtnQuit:setVisible(not self._guildPlayerProxy:IsMaster())
    self._quickUI.BtnApplyList:setVisible(self._guildPlayerProxy:HaveGuildPower())
    self._quickUI.BtnEditTitle:setVisible(self._guildPlayerProxy:IsChairman())
end

function GuildMemberLayer:refreshMemberCount()
    local online = 0
    local count  = 0
    for _,v in pairs(self._memberList) do
        count = count + 1
        if v.Online == 1 then
            online = online + 1
        end
    end
    self._quickUI.LabelOnline:setString(string.format(GET_STRING(50000009), online, count))
    self._maxMember = count
end

function GuildMemberLayer:refreshCellRank( data )
    if not data or not data.UserID then return end
    local cell = self._memberCell[data.UserID]
    if cell then
        cell:Exit()
    end
end

--成员排序
function GuildMemberLayer:showFilterLevel()
    local isShow = not self._quickUI.FilterLevel:isVisible()
    self._quickUI.FilterLevel:setVisible(isShow)

    if isShow then
        for _,v in pairs(self._quickUI.FilterLevel:getChildByName("ListView_filter"):getChildren()) do
            v:getChildByName("Image_select"):setVisible(self._filterLevel == v:getTag())
        end
    end
end

function GuildMemberLayer:showFilterJob()
    local isShow = not self._quickUI.FilterJob:isVisible()
    self._quickUI.FilterJob:setVisible(isShow)
    if isShow then
        for _,v in pairs(self._quickUI.FilterJob:getChildByName("ListView_filter"):getChildren()) do
            v:getChildByName("Image_select"):setVisible(self._filterJob == v:getTag())
        end
    end
end

function GuildMemberLayer:showFilterOfficial()
    local isShow = not self._quickUI.FilterOfficial:isVisible()
    self._quickUI.FilterOfficial:setVisible(isShow)
    if isShow then
        for _,v in pairs(self._quickUI.FilterOfficial:getChildByName("ListView_filter"):getChildren()) do
            local tag = v:getTag()
            v:getChildByName("Image_select"):setVisible(self._filterRank == tag)
            if tag > 0 then
                v:getChildByName("Text"):setString(self._guildProxy:getGuildTitleByRank(tag))
            end
        end
    end
end

function GuildMemberLayer:GetSUIParent()
    return self._quickUI.PMainUI
end

function GuildMemberLayer:removeMember()
    local FuncDockProxy = global.Facade:retrieveProxy(global.ProxyTable.FuncDockProxy)
    local uid = FuncDockProxy:GetTargetId()
    local cell = self._memberCell[uid]
    if cell then
        self._quickUI.MemberList:removeChild(cell, true)
        self._memberCell[uid] = nil
        for i, v in pairs(self._memberList) do 
            if v.UserID == uid then 
                self._memberList[i] = nil
                self:refreshMemberCount()
                self._quickUI.MemberList:jumpToPercentVertical(i / self._maxMember * 100)
                return 
            end 
        end
    end
end

return GuildMemberLayer
