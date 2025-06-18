local RemoteProxy   = requireProxy( "remote/RemoteProxy" )
local PlayerTitleProxy = class( "PlayerTitleProxy", RemoteProxy )
PlayerTitleProxy.NAME   = global.ProxyTable.PlayerTitleProxy

function PlayerTitleProxy:ctor()
    self._activateTitle = nil --激活的称号
    self._titleData = {}
    self._titleList = {}
    PlayerTitleProxy.super.ctor( self )
end

function PlayerTitleProxy:onRegister()
    PlayerTitleProxy.super.onRegister(self)
end

--获取已激活的称号id
function PlayerTitleProxy:getActivateTitle()
    return self._activateTitle
end

function PlayerTitleProxy:getTitleList()
    return self._titleList
end

function PlayerTitleProxy:getTitleData()
    return self._titleData
end

function PlayerTitleProxy:getTitleIdByTypeId(id)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    return ItemConfigProxy:GetItemLooks(id)
end

function PlayerTitleProxy:getTitleTime(id)
    if self._titleData[id] then
        return self._titleData[id].time
    end
    return nil
end

--称号界面 已激活的icon
function PlayerTitleProxy:getTitleActivateImage(id)
    local titleId = self:getTitleIdByTypeId(id)
    if global.isWinPlayMode then
        return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId + 2)
    else
        return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId + 3)
    end
    return nil
end

--称号列表的图片
function PlayerTitleProxy:getTitleListImage(id)
    local titleId = self:getTitleIdByTypeId(id)
    if global.isWinPlayMode then
        return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId + 1)
    else
        return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId + 2)
    end
    return nil
end

--场景中的图片
function PlayerTitleProxy:getSceneTitleImage(id)
    local titleId = self:getTitleIdByTypeId(id)
    return string.format("%s%s%s.png", global.MMO.PATH_RES_PRIVATE, "title_icon/", titleId)
end

--获取称号列表
function PlayerTitleProxy:ResquestTitleList()
    LuaSendMsg( global.MsgType.MSG_CS_TITLE_REQUEST, 1)
end

--激活称号
function PlayerTitleProxy:ResquestActivateTitle(id)
    LuaSendMsg( global.MsgType.MSG_CS_TITLE_REQUEST, 4, id)
end

--卸下称号
function PlayerTitleProxy:ResquestDisboardTitle()
    LuaSendMsg( global.MsgType.MSG_CS_TITLE_REQUEST, 5)
end

function PlayerTitleProxy:handle_MSG_SC_TITLE_REPONSE( msg )
    local header = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    -- dump(header)
    -- dump(jsonData)

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

    global.Facade:sendNotification( global.NoticeTable.Layer_Title_Refresh )
    SLBridge:onLUAEvent(LUA_EVENT_PLAYER_TITLE_CHANGE, {oper = header.recog})
end

function PlayerTitleProxy:RegisterMsgHandler()
    PlayerTitleProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler( msgType.MSG_SC_TITLE_REPONSE, handler( self, self.handle_MSG_SC_TITLE_REPONSE) )
end

return PlayerTitleProxy
