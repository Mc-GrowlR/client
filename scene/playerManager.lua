local playerManager = class("playerManager")

function playerManager:ctor()
    self.mPlayersInCurrViewFieldMap = {}
    self.mPlayersInCurrViewField = {}
    self.mPlayersIndexMap = {}
    self.mMainPlayerID = -1 
    self.mPlayerCount = 0
end

function playerManager:destory()
    if playerManager.instance then
        playerManager.instance = nil
    end
end

function playerManager:Inst()
    if not playerManager.instance then
        playerManager.instance = playerManager.new()
    end

    return playerManager.instance
end

function playerManager:AddPlayer(player)
    if not player then
        return false
    end

    local playerID = player:GetID()

    if self.mPlayersInCurrViewFieldMap[playerID] then
        return false
    end

    self.mPlayerCount = self.mPlayerCount + 1

    local n = self.mPlayerCount

    self.mPlayersIndexMap[playerID] = n

    self.mPlayersInCurrViewField[n] = player

    self.mPlayersInCurrViewFieldMap[playerID] = player
end

function playerManager:RmvPlayer(playerID)
    local player = self.mPlayersInCurrViewFieldMap[playerID]

    if not player then
        return false
    end

    self.mPlayersInCurrViewFieldMap[playerID] = nil

    local index = self.mPlayersIndexMap[playerID]

    if index == self.mPlayerCount then
        self.mPlayersInCurrViewField[index] = nil
    else
        -- last index --> index
        local lastActor = self.mPlayersInCurrViewField[self.mPlayerCount]
        self.mPlayersInCurrViewField[index] = lastActor
        self.mPlayersIndexMap[lastActor:GetID()] = index

        -- reset last value
        self.mPlayersInCurrViewField[self.mPlayerCount] = nil
    end

    self.mPlayersIndexMap[playerID] = nil
    self.mPlayerCount = self.mPlayerCount - 1
end

function playerManager:FindPlayerIDInCurrViewField(noMainPlayer)
    if noMainPlayer == nil then 
        noMainPlayer = true 
    end

    local recvVec = {}
    local num = 0

    for i = 1, self.mPlayerCount do
        local m = self.mPlayersInCurrViewField[i]
        if m then
            if noMainPlayer and m:GetID() == self.mMainPlayerID then 
            else
                num = num + 1
                recvVec[num] = m:GetID()
            end
        end
    end

    return recvVec, num
end

function playerManager:FindPlayerInCurrViewField(noMainPlayer)
    if noMainPlayer == nil then 
        noMainPlayer = true 
    end

    local recvVec = {}
    local num = 0

    for i = 1, self.mPlayerCount do
        local m = self.mPlayersInCurrViewField[i]
        if m then
            if noMainPlayer and m:GetID() == self.mMainPlayerID then 
            else
                num = num + 1
                recvVec[num] = m
            end
        end 
    end

    return recvVec, num
end

function playerManager:FindHeroInCurrViewField()
    local recvVec = {}
    local num = 0

    for i = 1, self.mPlayerCount do
        local m = self.mPlayersInCurrViewField[i]
        if m and m:IsHero() then
            num = num + 1
            recvVec[num] = m
        end   
    end

    return recvVec, num
end

function playerManager:FindOnePlayerInCurrViewFieldById(playerID)
    return self.mPlayersInCurrViewFieldMap[playerID]
end

function playerManager:PlayerCountInView()
    return self.mPlayerCount
end

function playerManager:Cleanup()
    self.mPlayersInCurrViewFieldMap = {}
    self.mPlayersInCurrViewField = {}
    self.mPlayersIndexMap = {}
    self.mMainPlayerID = -1
    self.mPlayerCount = 0
end

function playerManager:CleanupMainPlayer()
    self.mMainPlayerID = -1
end

function playerManager:GetPlayersInCurrViewField()
    return self.mPlayersInCurrViewField, self.mPlayerCount
end

function playerManager:SetMainPlayerID(id)
    self.mMainPlayerID = id
end

function playerManager:GetMainPlayerID()
    return self.mMainPlayerID
end

return playerManager
