local PetsEquipData = class( "PetsEquipData" )

function PetsEquipData:ctor()
    self.dataByMakeIndex  = {}
    self.dataByPos = {}     --MakeIndex
end

function PetsEquipData:GetData()
    return self.dataByMakeIndex
end

function PetsEquipData:GetPetsPosData(petsIdx, pos) 
    local posData = self.dataByPos[petsIdx] or {}
    if posData and next(posData) then
        return posData[pos]
    end
    return nil
end

function PetsEquipData:GetDataByMakeIndex(MakeIndex)
    if self.dataByMakeIndex[MakeIndex] then
        return self.dataByMakeIndex[MakeIndex]
    end
    return nil
end

function PetsEquipData:GetDataByPos(petIdx, pos)
    local item = nil
    if self.dataByPos[petIdx] and self.dataByPos[petIdx][pos] then
            
        local MakeIndex = self.dataByPos[petIdx][pos].MakeIndex
        if MakeIndex then
            item = self:GetDataByMakeIndex(MakeIndex)
        end
    end
    return item
end

function PetsEquipData:ClearData()
    self.dataByMakeIndex  = {}
    self.dataByPos = {}
end

function PetsEquipData:AddEquipData(item, petIdx)
    local MakeIndex = item.MakeIndex
    local Where = item.Where
    self.dataByMakeIndex[MakeIndex] = item
    if not self.dataByPos[petIdx] then
        self.dataByPos[petIdx]= {}
    end

    if not self.dataByPos[petIdx][Where] then
        self.dataByPos[petIdx][Where] = {}
    end
    self.dataByPos[petIdx][Where].MakeIndex = MakeIndex
    if self.dataByPos[petIdx][Where] and next(self.dataByPos[petIdx][Where]) then

    end

end

function PetsEquipData:DelEquipData(item, petIdx)
    local equip = self:GetDataByMakeIndex(item.MakeIndex)
    if equip then
        local Where = equip.Where
        self.dataByPos[petIdx][Where] = nil
        self.dataByMakeIndex[item.MakeIndex] = nil
    end
end

function PetsEquipData:ChangeItem(item)
    local MakeIndex = item.MakeIndex
    if self.dataByMakeIndex[MakeIndex] then
        self.dataByMakeIndex[MakeIndex] = item
    end
end

function PetsEquipData:ClearDataByPetIdx(petIdx)
    local needClearList = {} 
    if self.dataByPos[petIdx] then
        for _, data in pairs(self.dataByPos[petIdx]) do
            if data.MakeIndex then
                self.dataByMakeIndex[data.MakeIndex] = nil
            end
        end
    end

    self.dataByPos[petIdx] = {}
end

return PetsEquipData 