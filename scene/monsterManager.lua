local monsterManager = class('gameActorMonster')

function monsterManager:ctor()
    self.mPetOfMainAlive = false

    self.mMonstersInCurrViewFieldMap = {}
    self.mMonstersInCurrViewField = {}
    self.mMonstersIndexMap = {}
    self.mMonsterCount = 0
end

function monsterManager:destory()
    if monsterManager.instance then
        monsterManager.instance = nil
    end
end

function monsterManager:Inst()
    if not monsterManager.instance then
        monsterManager.instance = monsterManager.new()
    end

    return monsterManager.instance
end

function monsterManager:AddMonster(monster)
    if not monster then
        return false
    end

    local monsterID = monster:GetID()
    
    if self.mMonstersInCurrViewFieldMap[monsterID] then
        return false
    end

    self.mMonsterCount = self.mMonsterCount + 1

    local n = self.mMonsterCount

    self.mMonstersIndexMap[monsterID] = n

    self.mMonstersInCurrViewField[n] = monster

    self.mMonstersInCurrViewFieldMap[monsterID] = monster

    -- A pet/clone/hero of main player ?
    local playerID = global.gamePlayerController:GetMainPlayerID()
    if playerID == monster:GetMasterID() then
        -- issue: mPetOfMainPlayerID maybe mainplayer pet or hero pet
        self.mPetOfMainPlayerID = monsterID
    end
end

function monsterManager:RmvMonster(monsterID)
    local monster = self.mMonstersInCurrViewFieldMap[monsterID]

    if not monster then
        return false
    end

    self.mMonstersInCurrViewFieldMap[monsterID] = nil

    local index = self.mMonstersIndexMap[monsterID]

    if index == self.mMonsterCount then
        self.mMonstersInCurrViewField[index] = nil
    else
        -- last index --> index
        local lastActor = self.mMonstersInCurrViewField[self.mMonsterCount]
        self.mMonstersInCurrViewField[index] = lastActor
        self.mMonstersIndexMap[lastActor:GetID()] = index

        -- reset last value
        self.mMonstersInCurrViewField[self.mMonsterCount] = nil
    end

    self.mMonstersIndexMap[monsterID] = nil
    self.mMonsterCount = self.mMonsterCount - 1
end

function monsterManager:GetMonstersInCurrViewField()
    return self.mMonstersInCurrViewField, self.mMonsterCount
end

function monsterManager:FindMonsterIDInCurrViewField(noPetOfMainPlayer, noPetOfNetPlayer)
    if nil == noPetOfMainPlayer then 
        noPetOfMainPlayer = false 
    end
    
    if nil == noPetOfNetPlayer then 
        noPetOfNetPlayer = true 
    end

    local playerID = global.gamePlayerController:GetMainPlayerID()
    local recvVec  = {}
    local num = 0

    for i = 1, self.mMonsterCount do
        local m = self.mMonstersInCurrViewField[i]
        if m then
            if (noPetOfMainPlayer and playerID == m:GetMasterID()) or (noPetOfNetPlayer and m:IsHaveMaster()) then
            else
                num = num + 1
                recvVec[num] = m:GetID()
            end
        end
    end

    return recvVec, num
end

function monsterManager:FindMonsterInCurrViewField(noPetOfMainPlayer, noPetOfNetPlayer)
    if nil == noPetOfMainPlayer then 
        noPetOfMainPlayer = false 
    end
    
    if nil == noPetOfNetPlayer then 
        noPetOfNetPlayer = true 
    end

    local playerID = global.gamePlayerController:GetMainPlayerID()
    local recvVec  = {}
    local num = 0

    for i = 1, self.mMonsterCount do
        local m = self.mMonstersInCurrViewField[i]
        if m then
            if (noPetOfMainPlayer and playerID == m:GetMasterID()) or (noPetOfNetPlayer and m:IsHaveMaster()) then
            else
                num = num + 1
                recvVec[num] = m
            end
        end
    end

    return recvVec, num
end

function monsterManager:FindMonsterInCurrViewFieldByTypeIndex(typeIndex, noPetOfMainPlayer, noPetOfNetPlayer)
    if nil == noPetOfMainPlayer then 
        noPetOfMainPlayer = false 
    end
    
    if nil == noPetOfNetPlayer then 
        noPetOfNetPlayer = true 
    end

    local playerID = global.gamePlayerController:GetMainPlayerID()
    local recvVec  = {}
    local num = 0

    for i = 1, self.mMonsterCount do
        local m = self.mMonstersInCurrViewField[i]
        if m and m:GetTypeIndex() == typeIndex then
            if (noPetOfMainPlayer and playerID == m:GetMasterID()) or (noPetOfNetPlayer and m:IsHaveMaster()) then
            else
                num = num + 1
                recvVec[num] = m
            end
        end
    end

    return recvVec, num
end

function monsterManager:FindMonsterInCurrViewFieldByTypeIndexTable(typeIndexTable, noPetOfMainPlayer, noPetOfNetPlayer)
    if nil == noPetOfMainPlayer then 
        noPetOfMainPlayer = false 
    end
    
    if nil == noPetOfNetPlayer then 
        noPetOfNetPlayer = true 
    end

    local playerID = global.gamePlayerController:GetMainPlayerID()
    local recvVec  = {}
    local num = 0

    for i = 1, self.mMonsterCount do
        local m = self.mMonstersInCurrViewField[i]
        if m then
            for _, typeIndex in pairs(typeIndexTable) do
                if m:GetTypeIndex() == typeIndex then
                    if (noPetOfMainPlayer and playerID == m:GetMasterID()) or (noPetOfNetPlayer and m:IsHaveMaster()) then
                    else
                        num = num + 1
                        recvVec[num] = m
                    end
                end
            end
        end
    end

    return recvVec, num
end

function monsterManager:FindMonsterInCurrViewFieldByRace(race)
    local recvVec = {}
    local num = 0

    for i = 1, self.mMonsterCount do
        local m = self.mMonstersInCurrViewField[i]
        if m and m:GetRace() == race then
            num = num + 1
            recvVec[num] = m
        end
    end

    return recvVec, num
end

function monsterManager:Cleanup(clearPet)
    if clearPet == nil then clearPet = true end
    if clearPet then self.mPetOfMainAlive = false end

    self.mMonstersInCurrViewFieldMap = {}
    self.mMonstersInCurrViewField = {}
    self.mMonstersIndexMap = {}
    self.mMonsterCount = 0
end

function monsterManager:MonsterCountInView()
    return self.mMonsterCount
end

function monsterManager:IsPetOfMainAlive()
    return self.mPetOfMainAlive
end

function monsterManager:SetPetOfMainAlive( alive )
    self.mPetOfMainAlive = alive
end

return monsterManager
