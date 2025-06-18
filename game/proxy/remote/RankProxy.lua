local RemoteProxy = requireProxy("remote/RemoteProxy")
local RankProxy = class("RankProxy", RemoteProxy)
RankProxy.NAME = global.ProxyTable.RankProxy

function RankProxy:ctor()
    RankProxy.super.ctor(self)
    self.rankData = {}
    self._game_data_RankList = nil --cfg_game_data的RankingList
end

function RankProxy:SetListRankData(rankID, data)
    self.rankData[rankID] = data
    SLBridge:onLUAEvent(LUA_EVENT_RANK_DATA_UPDATE, rankID)
end

function RankProxy:GetRankingPlayers(rankID)
    if not rankID or not self.rankData or not next(self.rankData) then
        return nil
    end
    return self.rankData[rankID]
end

--获取cfg_game_data表的RankingList字段的数据
function RankProxy:GetRankListGameData()
    if not self._game_data_RankList then
        if not self._game_data_RankList then
            self._game_data_RankList = {}
        end
        local rankingList = SL:GetMetaValue("GAME_DATA","RankingList")
        if rankingList and string.len(rankingList) > 0 then
            local rankListArray = string.split(rankingList, "|")
            for i, v in ipairs(rankListArray) do
                if v and string.len(v) > 0 then
                    local valueArray = string.split(v, "#")
                    if valueArray[1] then
                        table.insert(self._game_data_RankList, {
                            RankType = tonumber(valueArray[1]),
                            BtnName = valueArray[2]
                        })
                    end
                end
            end
        end
    end
    return self._game_data_RankList
end

function RankProxy:RequestListData(rankType)
    LuaSendMsg(global.MsgType.MSG_CS_RANK_LIST_DATA_REQUEST, rankType, 0, 0, 0)
end

function RankProxy:RequestPlayerShowData(playerUid, type)
    LuaSendMsg(global.MsgType.MSG_CS_RANK_PLAYER_DATA_REQUEST, type, 0, 0, 0, playerUid, string.len(playerUid))
end

function RankProxy:RequestNotifyClickRankType(type)
    -- 0玩家 1英雄
    type = type - 1 
    LuaSendMsg(global.MsgType.MSG_CS_CLICK_RANK_TYPE, type)
end

function RankProxy:RequestNotifyClickRankValue(rank)
    LuaSendMsg(global.MsgType.MSG_CS_CLICK_RANK_VALUE, rank)
end

function RankProxy:handle_MSG_SC_RANK_LIST_DATA_RESPONSE(msg)
    local data = ParseRawMsgToJson(msg)
    local header = msg:GetHeader()
    if not data or not header then
        return
    end
    local rankID = header.recog
    local rankData = data
    self:SetListRankData(rankID, rankData)
end

function RankProxy:handle_MSG_SC_RANK_PLAYER_DATA_RESPONSE(msg)
    local data = ParseRawMsgToJson(msg)
    if not data then
        return
    end
    SLBridge:onLUAEvent(LUA_EVENT_RANK_PLAYER_UPDATE, data)
end

function RankProxy:handle_MSG_SC_CUSTOM_RANK_LIST_DATA_RESPONSE(msg)
    local data = ParseRawMsgToJson(msg)
    local header = msg:GetHeader()
    if not data or not header then
        return
    end

    local rankID = header.recog
    local rankData = data
    self:SetListRankData(rankID, rankData)
end

function RankProxy:RegisterMsgHandler()
    RankProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_RANK_LIST_DATA_RESPONSE, handler(self, self.handle_MSG_SC_RANK_LIST_DATA_RESPONSE))
    LuaRegisterMsgHandler(msgType.MSG_SC_RANK_PLAYER_DATA_RESPONSE, handler(self, self.handle_MSG_SC_RANK_PLAYER_DATA_RESPONSE))
    LuaRegisterMsgHandler(msgType.MSG_SC_CUSTOM_RANK_LIST_DATA_RESPONSE, handler(self, self.handle_MSG_SC_CUSTOM_RANK_LIST_DATA_RESPONSE))
end

return RankProxy