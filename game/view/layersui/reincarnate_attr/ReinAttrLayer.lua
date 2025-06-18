local BaseLayer = requireLayerUI("BaseLayer")
local ReinAttrLayer = class("ReinAttrLayer", BaseLayer)

function ReinAttrLayer:ctor()
    ReinAttrLayer.super.ctor(self)

    self._dataCells = {}
    self._addAttrPoint = {}
    self._addCustNums = {}

    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.ReinAttrProxy)
    self._key = {"DC", "MC", "SC", "AC", "MAC", "HP", "MP", "Hit", "Speed"}

    self._canAttrPointN = self._proxy.m_nBonusPoint

    --服务器传的已加点数
    self._BonusAbilList = self._proxy:GetBonusAbilData()
    --加点基底
    self._BonusTickList = self._proxy:GetBonusTickData()
    --用于计算五属性加值
    self._NakedAbilList = self._proxy:GetNakedAbilData()

    -- 计算前的基础属性值
    self._AdjustList = self._proxy:GetAdjustAbilData()

    --------------------------- 新版
    self._isNew = self._proxy:IsNewBouns()

end

function ReinAttrLayer.create(data)
    local layer = ReinAttrLayer.new()
    if layer:Init(data) then
        return layer
    else
        return nil
    end
end

function ReinAttrLayer:Init(data)
    self.ui = ui_delegate(self)

    return true
end

function ReinAttrLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_REIN_ATTR)
    ReinAttr.main()

    self.ui.Text_tip:setString(GET_STRING(700000001))

    self.ui.btn_close:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_Rein_Attr_Close)
    end)

    -- 旧版保持原状
    if not self._isNew then
        self:InitUI()
    end
end

function ReinAttrLayer:InitUI()

    if not self._proxy:GetData() or not next(self._proxy:GetData()) then
        return
    end
    dump(self._proxy:GetData())
    
    self.ui.btn_agree:addClickEventListener(function()
        --同意 
        local data = {}
        data.BonusAbil = {}
        for i = 1, 9 do
            if self._addCustNums[i] then
                data.BonusAbil[self._key[i]] = self._addCustNums[i]
            else
                data.BonusAbil[self._key[i]] = 0
            end
        end

        self._proxy:ResAddReinAttr(data, self._canAttrPointN)

        --清空
        self._addCustNums = {}

        global.Facade:sendNotification(global.NoticeTable.Layer_Rein_Attr_Close)

    end)

    self.ui.attr_pointN:setString(self._canAttrPointN)
    
    self:InitDataPanel()

    self:UpdateData()

    if nil == self._timer then
        self._timer = Schedule(handler(self, self.Tick), 2.0)
    end
end

function ReinAttrLayer:getAttValue(key)
    local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)

    if not self._proxy:GetData() or not next(self._proxy:GetData()) then
        return
    end

    local abil = self._NakedAbilList[self._key[key]]

    local lowN, highN = 0,0
    if  self._addAttrPoint[key]  and key >= 1 and key <= 5 then
        lowN, highN = AdjustAb(abil ,self._addAttrPoint[key])
    end

    local addNum = 0
    if key > 5 and key <= 9 and self._addAttrPoint[key] then
        addNum = self._addAttrPoint[key]
    end

    local str = ""
    local min = 0
    local max = 0
    if key >= 1 and key <= 5 then
        min = self._AdjustList[self._key[key].."1"] + lowN
        max = self._AdjustList[self._key[key].."2"] + highN
        str = string.format(GET_STRING(1055), min, max)
    elseif key == 6 then
        min = PlayerPropertyProxy:GetRoleCurrHP()
        max = self._AdjustList[self._key[key]] + addNum
        str = string.format(GET_STRING(1053), min, max)
    elseif key == 7 then
        min = PlayerPropertyProxy:GetRoleCurrMP()
        max = self._AdjustList[self._key[key]] + addNum
        str = string.format(GET_STRING(1053), min, max)
    else -- 准确、敏捷得到的不是基础值
        str = self._AdjustList[self._key[key]] + addNum
    end

    return str
end

function ReinAttrLayer:InitDataPanel()
    self.ui.Panel_cell:setVisible(false)

    local max = 9
    for i= 1, max do
        local data_cell = self.ui.Panel_cell:cloneEx()
        local cell_ui = ui_delegate(data_cell)
        self:InitAssignPoint(cell_ui, i)
        cell_ui.btn_add:addClickEventListener(function()
            local str = cell_ui.Text_num:getString()
            local num1 = tonumber(string.split(str, "/")[1])
            local num2 = tonumber(string.split(str, "/")[2])

            local curAdd = 0
            if self._canAttrPointN >= 10 and global.isWinPlayMode and global.userInputController._isPressedCtrl then --CTRL+ 10
                num1 = num1 + 10
                curAdd = 10
            else
                num1 = num1 + 1
                curAdd = 1
            end

            if  self._canAttrPointN < 1 then
                return false
            end
            if num1 >= tonumber(num2) then
                local addRealPoint = math.floor(num1 / num2)
                num1 = num1 % num2
                if nil == self._addAttrPoint[i] then
                    self._addAttrPoint[i] = addRealPoint
                else
                    self._addAttrPoint[i] = self._addAttrPoint[i] + addRealPoint
                end
                cell_ui.Text_data:setString(self:getAttValue(i))
            end

            if nil ==  self._addCustNums[i] then
                self._addCustNums[i] = curAdd
            else
                self._addCustNums[i] = self._addCustNums[i] + curAdd
            end
            
            self._canAttrPointN = self._canAttrPointN - curAdd
            cell_ui.Text_num:setString(num1 .. "/" .. num2)
            self.ui.attr_pointN:setString(self._canAttrPointN)
        end)

        cell_ui.btn_sub:addClickEventListener(function()
            local str = cell_ui.Text_num:getString()
            local num1 = tonumber(string.split(str, "/")[1])
            local num2 = tonumber(string.split(str, "/")[2])

            local curSub = 0
            if num1 >= 10 and global.isWinPlayMode and global.userInputController._isPressedCtrl then --CTRL- 10
                num1 = num1 - 10
                curSub = 10
            else
                num1 = num1 - 1
                curSub = 1
            end
            
            if num1 < 0 then
                return false
            end
            if not self._addCustNums[i] or self._addCustNums[i] <= 0 then
                return 
            end
            self._addCustNums[i] = self._addCustNums[i] - curSub

            self._canAttrPointN = self._canAttrPointN + curSub
            cell_ui.Text_num:setString(num1 .. "/" .. num2)
            self.ui.attr_pointN:setString(self._canAttrPointN)
        end)
        cell_ui.Text_data:setString(self:getAttValue(i))

        data_cell:setPositionY((max-i) * (data_cell:getContentSize().height + (ReinAttr._interval or 4)))
        data_cell:setVisible(true)
        self._dataCells[i] = data_cell
        self.ui.Panel_data:addChild(data_cell)
    end

end

function ReinAttrLayer:InitAssignPoint(cell_ui, index)

    if not self._proxy:GetData() or not next(self._proxy:GetData()) then
        return
    end

    local serverAdd = self._BonusAbilList[self._key[index]]

    local max = self._BonusTickList[self._key[index]]
    local add = serverAdd%max
    local str = string.format(GET_STRING(1053), add, max)
    cell_ui.Text_num:setString(str)

end

function ReinAttrLayer:Tick()

    for i,v in ipairs(self._dataCells) do
        v:getChildByName("Text_data"):setString(self:getAttValue(i))
    end

end

function ReinAttrLayer:OnClose()
    if self._timer then
        UnSchedule(self._timer)
        self._timer = nil
    end
end

function ReinAttrLayer:UpdateData()
    
    self._canAttrPointN = self._proxy.m_nBonusPoint
    self.ui.attr_pointN:setString(self._canAttrPointN)

    self._BonusAbilList = self._proxy:GetBonusAbilData()
    self._BonusTickList = self._proxy:GetBonusTickData()
    self._NakedAbilList = self._proxy:GetNakedAbilData()
    self._AdjustList = self._proxy:GetAdjustAbilData()

    for i= 1, 9 do
        local curNum = tonumber(self._BonusAbilList[self._key[i]])
        local baseNum = tonumber(self._BonusTickList[self._key[i]])
        self._addAttrPoint[i] = math.floor(curNum / baseNum)

        if i == 8 or i == 9 then
            self._addAttrPoint[i] = 0
        end
    end

    self:Tick()
end

return  ReinAttrLayer