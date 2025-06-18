local RemoteProxy   = requireProxy( "remote/RemoteProxy" )
local HeroTitleProxy = class( "HeroTitleProxy", RemoteProxy )
HeroTitleProxy.NAME   = global.ProxyTable.HeroTitleProxy

function HeroTitleProxy:ctor()
    self._activateTitle = nil --激活的称号
    self._titleData = {}
    self._titleList = {}
    HeroTitleProxy.super.ctor( self )
end

function HeroTitleProxy:onRegister()
    HeroTitleProxy.super.onRegister(self)
end


--获取已激活的称号id
function HeroTitleProxy:getActivateTitle()
    return self._activateTitle
end

function HeroTitleProxy:getTitleList()
    return self._titleList
end


function HeroTitleProxy:getTitleIdByTypeId(id)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    return ItemConfigProxy:GetItemLooks(id)
end

function HeroTitleProxy:getTitleTime(id)
    if self._titleData[id] then
        return self._titleData[id].time
    end
    return nil
end

--称号界面 已激活的icon
function HeroTitleProxy:getTitleActivateImage(id)
    local titleId = self:getTitleIdByTypeId(id)
    if global.isWinPlayMode then
        return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId + 2)
    else
        return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId + 3)
    end
    return nil
end

--称号列表的图片
function HeroTitleProxy:getTitleListImage(id)
    local titleId = self:getTitleIdByTypeId(id)
    if global.isWinPlayMode then
        return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId + 1)
    else
        return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId + 2)
    end
    return nil
end

--场景中的图片
function HeroTitleProxy:getSceneTitleImage(id)
    local titleId = self:getTitleIdByTypeId(id)
    return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId)
end

--获取称号列表
function HeroTitleProxy:ResquestTitleList()
    LuaSendMsg( global.MsgType.MSG_CS_TITLE_REQUEST_HERO, 1)
end

--激活称号
function HeroTitleProxy:ResquestActivateTitle(id)
    LuaSendMsg( global.MsgType.MSG_CS_TITLE_REQUEST_HERO, 4, id)
end

--卸下称号
function HeroTitleProxy:ResquestDisboardTitle()
    LuaSendMsg( global.MsgType.MSG_CS_TITLE_REQUEST_HERO, 5)
end

function HeroTitleProxy:handle_MSG_SC_TITLE_REPONSE( msg )
    local header = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    if header.recog == 1 then
        --称号列表
        self._activateTitle = {}
        self._titleList = {}
        if not jsonData then return end
        if jsonData.data then
            for i,v in pairs(jsonData.data) do
                local id = v[1]
                local time = v[2]

                local data = {id = id, time = time, index = i}
                self._titleData[id] = data
                self._titleList[i] = data
            end
        end
        self._activateTitle = jsonData.active
        
    elseif header.recog == 2 then
        --增加称号
        local id = header.param1
        if id and id > 0 then
            local time = header.param2

            if not self._titleData[id] then
                local index = #self._titleList + 1
                local data = {id = id, time = time, index = index}
                self._titleData[id] = data
                self._titleList[index] = data

            else
                self._titleData[id].time = time
            end
        end
        
    elseif header.recog == 3 then
        --删除称号
        local id = header.param1
        local config = self._titleData[id]
        if config then
            local index = config.index
            if index and self._titleList[index] then
                self._titleList[index] = nil
            end
        end
        self._titleData[id] = nil

    elseif header.recog == 4 then
        --激活
        if header.param1 and header.param1 > 0 then
            self._activateTitle = header.param1
        end
    elseif header.recog == 5 then
        --卸下
        self._activateTitle = nil
    elseif header.recog == 6 then
        --清理全部称号
        self._activateTitle = nil
        self._titleList = {}
        self._titleData = {}
    end

    global.Facade:sendNotification( global.NoticeTable.Layer_Title_Refresh_Hero )
end

function HeroTitleProxy:RegisterMsgHandler()
    HeroTitleProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler( msgType.MSG_SC_TITLE_REPONSE_HERO, handler( self, self.handle_MSG_SC_TITLE_REPONSE) )
end

return HeroTitleProxy
