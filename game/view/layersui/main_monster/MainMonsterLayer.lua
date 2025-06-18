local BaseLayer = requireLayerUI("BaseLayer")
local MainMonsterLayer = class("MainMonsterLayer", BaseLayer)

local SUMMONS_STATE = {
    NO_ALIVED = 1, -- 没有复活
    NO_LOCK = 2, -- 没有锁定
    LOCK = 3 -- 已锁定
}

function MainMonsterLayer:ctor()
    MainMonsterLayer.super.ctor(self)
    self._hpUnit = tonumber(SL:GetMetaValue("GAME_DATA","monster_hp_count")) -- 一条血条的血量配置
    self._hpTubeCount = 1 -- 血条总数
    self._currHpTube = -1 -- 当前显示的血条
    self._selectActorID = nil -- 目标actor id
    self._monsterOwnerName = "" -- 归属
    self._barHpLocalZ = 99 -- 血条层级
    self._showTubeAction = false -- 血量文本是否正在进行动画
    self._tubeTipOringPos = cc.p(0, 0) -- 记录血量文本初始位置
    self._hpActions = {} -- 血量变化记录
    self._lastHP = 0 -- 记录最后一次的血量
    self._runActioning = false -- 记录是否正在进行血量文本加载
    self._tubeActions = {} -- 血量文本变化记录
    self._hpBasePath = global.MMO.PATH_RES_PRIVATE .. "main_monster_ui/hp/" -- 资源位置
    self._monsterBasePath = global.MMO.PATH_RES_PRIVATE .. "main_monster_ui/monster/" -- 资源位置
end

function MainMonsterLayer.create(data)
    local layer = MainMonsterLayer.new()
    if layer and layer:Init(data) then
        return layer
    end
    return nil
end

function MainMonsterLayer:Init(data)
    return true
end

function MainMonsterLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_MONSTER)
    MainMonster.main(data)

    self:InitUI(data)

    self:InitEditMode()
end

function MainMonsterLayer:InitEditMode()
    local items = {
        "Panel_1",
        "Image_bg",
        "Image_icon",
        "Text_lv",
        "Text_belong",
        "Text_belong_name",
        "Text_monster_name",
        "Image_loading_bg",
        "LoadingBar_hp_bar",
        "Text_hp_tip",
        "Node_bar_tip",
        "Text_hp",
        "Button_close",
        "Panel_hp_tip",
        "Panel_bar_hp_tx",
        "Panel_loding_hp_tx",
        "LockBtn",
    }
    for _, widget in ipairs(items) do
        if self._ui[widget] then
            self._ui[widget].editMode = 1
        end
    end
end

function MainMonsterLayer:InitUI(data)
    self._ui = ui_delegate(self)

    local hpTipText = self._ui.Text_hp_tip
    local posx, posy = hpTipText:getPosition()
    self._tubeTipOringPos.x = posx
    self._tubeTipOringPos.y = posy

    self._ui.Text_belong_name:setString("")
    self._ui.Text_monster_name:setString("")

    self._ui.Text_hp:setLocalZOrder(self._barHpLocalZ + self._barHpLocalZ)
    self._ui.Panel_hp_tip:setLocalZOrder(self._barHpLocalZ + self._barHpLocalZ)

    self._sui_root = cc.Node:create()
	self._sui_root:setPosition(self._ui.Node_bar_tip:getPosition())
	self._sui_root:setLocalZOrder( 999 )
	self._ui.Panel_1:addChild(self._sui_root)

    self:SetIconEvent()
    self:SetCloseEvent()
    self:SetLockEvent()
end

--- 头像点击事件
function MainMonsterLayer:SetIconEvent()
    local iconImage = self._ui.Image_icon
    iconImage:setTouchEnabled(true)
    iconImage:setSwallowTouches(true)
    iconImage:addTouchEventListener(function(sender, state)
        if state == 0 then -- 开始点击  图片置灰
            Shader_Grey(sender)
        elseif state == 1 then -- 移动
        else -- 松开  图片恢复
            Shader_Normal(sender)
            if state == 2 then -- 图片内松开
                if not self._selectActorID then
                    return
                end
                local actor = global.actorManager:GetActor(self._selectActorID)
                if actor and actor:IsMonster() then
                    local actorIDX = actor:GetTypeIndex()
                    local actorUserID = actor:GetID()
                    LuaSendMsg(global.MsgType.MSG_CS_BIGTIP_CLICK, actorIDX, 0, 0, 0, actorUserID, string.len(actorUserID))
                end
            end
        end
    end)
end

--- 关闭按钮点击事件
function MainMonsterLayer:SetCloseEvent()
    local closeButton = self._ui.Button_close
    closeButton:addClickEventListener(function()
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:SetTargetID(nil)
    end)
end

--- 锁定按钮点击事件
function MainMonsterLayer:SetLockEvent()
    local lockButton = self._ui.LockBtn
    lockButton:setVisible(false)

    lockButton:addClickEventListener(function()

    end)
    lockButton:addClickEventListener(function()
        self:UpdateLockBtn(function(summonsState)
            local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
            if summonsState == SUMMONS_STATE.LOCK then
                SummonsProxy:ReqUnLockActorByID(self._selectActorID)
                DelayTouchEnabled(lockButton) -- 按钮延迟0.2s才能重新激活触摸
            elseif summonsState == SUMMONS_STATE.NO_LOCK then
                SummonsProxy:ReqLockActorByID(self._selectActorID)
                DelayTouchEnabled(lockButton) -- 按钮延迟0.2s才能重新激活触摸
            end
        end)
    end)
end

--- 锁定改变
function MainMonsterLayer:OnSummonsAliveStatusChange()
    self:UpdateLockBtn()
end

--- 刷新锁定按钮
---@param callfunc function 回调函数
function MainMonsterLayer:UpdateLockBtn(callfunc)
    if not self._selectActorID then
        return
    end
    local actor = global.actorManager:GetActor(self._selectActorID)
    if not actor then
        return
    end
    local lockButton = self._ui.LockBtn
    local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
    if not SummonsProxy:IsAlived() then
        if callfunc then
            callfunc(SUMMONS_STATE.NO_ALIVED)
            return
        end
        lockButton:setVisible(false)
        return
    end
    lockButton:setVisible(true)
    local lockID = SummonsProxy:GetLockTargetID()
    if lockID == self._selectActorID then -- 已锁定
        lockButton:loadTextureNormal(global.MMO.PATH_RES_PRIVATE .. "player_hero/btn_heji_05_1.png")
        lockButton:loadTexturePressed(global.MMO.PATH_RES_PRIVATE .. "player_hero/btn_heji_05_1.png")
        lockButton:loadTextureDisabled(global.MMO.PATH_RES_PRIVATE .. "player_hero/btn_heji_05_1.png")
    else
        lockButton:loadTextureNormal(global.MMO.PATH_RES_PRIVATE .. "player_hero/btn_heji_05.png")
        lockButton:loadTexturePressed(global.MMO.PATH_RES_PRIVATE .. "player_hero/btn_heji_05.png")
        lockButton:loadTextureDisabled(global.MMO.PATH_RES_PRIVATE .. "player_hero/btn_heji_05.png")
    end
    if callfunc then
        callfunc(lockID == self._selectActorID and SUMMONS_STATE.LOCK or SUMMONS_STATE.NO_LOCK)
    end
end

--- 刷新UI初始化
function MainMonsterLayer:OnUpdateInitUI()
    self._ui.Panel_1:setVisible(false)
    self._ui.Panel_1:stopAllActions()
    self._ui.Node_bar_tip:stopAllActions()
    self._ui.Text_hp_tip:stopAllActions()
    self._ui.Text_hp_tip:setString("")
    self._ui.Text_hp:setString("")
    self._showTubeAction = false
end

--- 隐藏UI
function MainMonsterLayer:OnHide()
    if self._selectActorID then
        self._runActioning = false
        local actionData = self._hpActions[#self._hpActions] -- 执行最后的数据
        if actionData then
            actionData.timeP = 0
            self:CheckRunBarAction(actionData)
        end
        self._hpActions = {}
        self._tubeActions = {}
        self._selectActorID = nil
        self._currHpTube = -1

        self._ui.Node_bar_tip:stopAllActions()
        self:ChangeHPBarTX(self._ui.Image_loading_bg)
        self:ChangeHPBarTX(self._ui.LoadingBar_hp_bar)
        self:ShowHideAction(true, function()
            self._ui.Panel_1:setVisible(false)
        end)
    end
end

--- 刷新UI
---@param data table 刷新数据
function MainMonsterLayer:UpdateMonsterUI(data)
    data = data or {}
    if self._selectActorID == data.targetID then
        return false
    end

    self:OnUpdateInitUI()

    self._currHpTube = -1
    self._selectActorID = data.targetID

    self:UpdateLockBtn()

    if not self._selectActorID then
        return false
    end

    local actor = global.actorManager:GetActor(self._selectActorID)
    if not actor then
        self:OnHide()
        return false
    end

    if not actor:IsMonster() then
        self:OnHide()
        return false
    end

    -- 宝宝怪
    if actor:IsHaveMaster() then
        self:OnHide()
        return false
    end

    local currHp = actor:GetHP()
    local maxHP = actor:GetMaxHP()
    self._hpUnit = tonumber(SL:GetMetaValue("GAME_DATA","monster_hp_count")) or maxHP
    self._hpTubeCount = math.ceil(maxHP / self._hpUnit)
    self._lastHP = currHp

    if maxHP < self._hpUnit then
        self._hpUnit = math.ceil(maxHP / self._hpTubeCount)
    end

    local hpTipText = self._ui.Text_hp_tip
    local currTube = math.ceil(currHp / self._hpUnit)
    self._currHpTube = currTube
    hpTipText:setPosition(self._tubeTipOringPos.x, self._tubeTipOringPos.y)

    self:UpdateUIHpTip(currTube)
    self:UpdateUIIcon(actor)
    self:UpdateUIName(actor)
    self:UpdateUILevel(actor)
    self:UpdateBelongName({
        actorID = actor:GetID()
    })

    self:OnRefreshHP({
        actorID = self._selectActorID,
        isinitui = true
    })
    self:ShowHideAction()
    return true
end

function MainMonsterLayer:UpdateUIHpTip(tube)
    MainMonster.UpdateUIHpTip(tube)
end

-- 刷新UI 头像
--- 刷新UI 头像
---@param actor userdata actor对象
function MainMonsterLayer:UpdateUIIcon(actor)
    local actorRace = actor and actor:GetBigTipIcon() or 0
    local iconImagePath = string.format(self._monsterBasePath .. "%05d.png", actorRace)
    MainMonster.UpdateUIIcon(iconImagePath)
end

--- 刷新UI 怪物名字
---@param actor userdata actor对象
function MainMonsterLayer:UpdateUIName(actor)
    local monsterName = actor and actor:GetName() or ""
    MainMonster.UpdateUIName(monsterName)
end

--- 刷新UI 怪物等级
---@param actor userdata actor对象
function MainMonsterLayer:UpdateUILevel(actor)
    local level = actor and actor:GetLevel() or ""
    MainMonster.UpdateUILevel(level)
end

function MainMonsterLayer:UpdateUIHp(hpPercent)
    MainMonster.UpdateUIHp(hpPercent or 0)
end

--- 刷新UI  归属名
---@param data table 归属数据
function MainMonsterLayer:UpdateBelongName(data)
    data = data or {}
    local actor = nil
    if data.actorID then
        actor = global.actorManager:GetActor(data.actorID)
    end
    local playerName = actor and actor.GetOwnerName and actor:GetOwnerName() or ""
    MainMonster.UpdateBelongName(playerName)
end

--- 血量刷新
---@param data table 血量变化数据
function MainMonsterLayer:OnRefreshHP(data)
    if not self._selectActorID then
        return
    end
    data = data or {}
    if self._selectActorID ~= data.actorID then
        return
    end

    if not data.actorID then
        return
    end

    local actor = global.actorManager:GetActor(data.actorID)
    if not actor then
        self:OnHide()
        return
    end

    local currHp = actor:GetHP(actor)
    local maxHP = actor:GetMaxHP(actor)
    local currTube = math.ceil(currHp / self._hpUnit)
    local hpPercent = math.ceil(currHp / maxHP * 100)
    self:UpdateUIHp(hpPercent)

    local showHp = currHp - self._hpUnit * (currTube - 1) -- 显示血条管的loading的血量
    local percent = math.max(showHp / self._hpUnit * 100, 0) -- 血条管的百分比

    if self._currHpTube < 0 then -- 是否是重置后的数据，需要重新赋值
        self._currHpTube = currTube
        self._lastHP = currHp
        self._ui.LoadingBar_hp_bar:setPercent(100)
    end

    local hpBar = self._ui.LoadingBar_hp_bar
    local isRestore = currHp > self._lastHP -- 是否是回血状态
    local actionT = self._hpActions[#self._hpActions] -- 读取血量变化的最后一次的记录
    local fristP = hpBar:getPercent() -- 读取记录开始的bar的百分比
    if actionT and actionT.endP then
        fristP = actionT.endP
    end

    local isCheck = true
    if not data.isinitui and self._currHpTube ~= currTube and currTube > 0 then
        isCheck = false
        local startTube = self._currHpTube
        local tubeNums = math.abs(startTube - currTube)
        local startIndex = 1
		if tubeNums > 4 then
			startIndex = tubeNums - 4
		end
        for i = startIndex, tubeNums do
            local showHPTube = isRestore and (startTube + i) or (startTube - i)
            self:AddLoadingActionData({
                startP = i == startIndex and fristP or (isRestore and 0 or 100),
                endP = i == tubeNums and percent or (isRestore and 100 or 0),
                timeP = 0.2,
                showHPTube = showHPTube,
                isRestore = isRestore,
                isChangeBar = true
            })
        end
    end

    if isCheck and (data.isinitui or self._lastHP ~= currHp) then
        local isChangeBar = data.isinitui or (actionT and actionT.showHPTube ~= currTube or false)
        self:AddLoadingActionData({
            startP = data.isinitui and percent or fristP,
            endP = percent,
            timeP = 0.5,
            showHPTube = currTube,
            isRestore = isRestore,
            isChangeBar = isChangeBar
        })
    end

    self._lastHP = currHp
    self._currHpTube = currTube

    self:CheckLoadingAction()
end

--- 动作变化数据添加
---@param data table 动作变化数据
function MainMonsterLayer:AddLoadingActionData(data)
    if #self._hpActions > 5 then
        table.remove(self._hpActions, 1)
    end
    table.insert(self._hpActions, data)
end

--- 检测进度条动作
---@param data table 动作变化数据
function MainMonsterLayer:CheckRunBarAction(data)
    if data.isChangeBar then
        table.insert(self._tubeActions, {
            tube = data.showHPTube or 0,
            timeP = data.timeP or 0.1
        })
        self:ShowTubeAction()
        self:ChangeHPLoadingShow(data.showHPTube or 0, data.isRestore and 0 or 100)
    end
    self:RunBarAction(self._ui.LoadingBar_hp_bar, data)
end

--- 血条更换资源
---@param showHPTube number 更换的血条数
---@param percent number 进度
function MainMonsterLayer:ChangeHPLoadingShow(showHPTube, percent)
    -- 资源下标
    local barTube = showHPTube % 10
    if showHPTube > 0 then
        barTube = barTube == 0 and 10 or barTube
    end

    local loadingBgImage = self._ui.Image_loading_bg
    local hpBarLoadingBar = self._ui.LoadingBar_hp_bar

    local animId = nil
    local bgPath = nil
    if showHPTube > 1 then
        local newBarTube = barTube == 1 and 10 or (barTube - 1)
        bgPath = string.format(self._hpBasePath .. "%02d.png", newBarTube)
        loadingBgImage:loadTexture(bgPath)
        loadingBgImage:setLocalZOrder(self._barHpLocalZ + 2)
        animId = 7300 + newBarTube
    end
    self:ChangeHPBarTX(loadingBgImage, animId)
    loadingBgImage:setVisible(showHPTube > 1)

    hpBarLoadingBar:setVisible(true)
    hpBarLoadingBar:setLocalZOrder(self._barHpLocalZ + 3)
    local loadingImagePath = string.format(self._hpBasePath .. "%02d.png", barTube)
    hpBarLoadingBar:loadTexture(loadingImagePath)
    hpBarLoadingBar:setPercent(50)

    local animId = 7300 + barTube
    self:ChangeHPBarTX(hpBarLoadingBar, animId, function(sender)
        local animBar = self._ui.LoadingBar_hp_bar:getChildByName("HP_BAR_TX")
        if not self._runActioning and animBar and animBar.frameScale then
            local scalex = animBar.frameScale.x or 1
            local currPercent = self._ui.LoadingBar_hp_bar:getPercent()
            animBar:setScaleX(currPercent / 100 * scalex)
        end
    end)
end

--- 更换血条特效
---@param parentNode userdata 父节点控件
---@param animId number 特效id
---@param func function 回调接口
function MainMonsterLayer:ChangeHPBarTX(parentNode, animId, func)
    local anim = parentNode:getChildByName("HP_BAR_TX")
    if anim then
        anim:removeFromParent()
        anim = nil
    end
    if not animId then
        return
    end
    local anim = global.FrameAnimManager:CreateSFXAnim(animId)
    if anim then
        local sz = parentNode:getContentSize()
        anim:setName("HP_BAR_TX")
        anim:setPositionY(sz.height)
        anim:setTag(animId)
        anim:setVisible(false)
        anim:Play(0, 0, true)
        parentNode:addChild(anim)

        anim.frameScale = {}
        performWithDelay(anim, function()
            local boundBox = anim:GetFrameBox()
            anim.frameBox = boundBox
            anim.frameScale = {
                x = boundBox.width / sz.width,
                y = boundBox.height / sz.height
            }
            anim:setScaleX(anim.frameScale.x)
            anim:setScaleY(anim.frameScale.y)
            anim:setVisible(true)
            if func then
                func()
            end
        end, 0.5)
    end
end

--- 检测加载动作
function MainMonsterLayer:CheckLoadingAction()
    if self._runActioning or #self._hpActions <= 0 then
        return
    end
    local actionData = table.remove(self._hpActions, 1)
    if actionData then
        self:CheckRunBarAction(actionData)
    end
end

--- 血条变化动作
---@param barNode userdata loadingbar控件
---@param data table 动作变化数据
function MainMonsterLayer:RunBarAction(barNode, data)
    data = data or {}

    if not next(data) then
        return
    end

    self._runActioning = true
    local actionT = 0.2 -- 动作时间0.2
    local times = 20 --
    local startP = data.startP or 100
    local endP = data.endP or 0
    local hpStand = (endP - startP) / times
    local actionFunc = function(sender)
        if times <= 0 then
            barNode:stopAllActions()
            self._runActioning = false
            self:CheckLoadingAction()
            return
        end
        times = times - 1
        startP = startP + hpStand
        sender:setPercent(startP)
        local animBar = sender:getChildByName("HP_BAR_TX")
        if animBar and animBar.frameScale then
            local scalex = animBar.frameScale.x or 1
            animBar:setScaleX(startP / 100 * scalex)
        end
    end
    schedule(barNode, actionFunc, 0.01)
end

--- 血条数文本提示动画
function MainMonsterLayer:ShowTubeAction()
    if self._showTubeAction then
        return
    end
    local tubeData = table.remove(self._tubeActions, 1)
    if not tubeData then
        return
    end
    local tube = tubeData.tube
    local delayTime = tubeData.timeP
    if delayTime > 0.2 then
        delayTime = 0.2
    end
    self._showTubeAction = true
    local hpTipPanel = self._ui.Panel_hp_tip
    local clipSz = hpTipPanel:getContentSize()
    -- 往上移动
    local move1 = cc.MoveBy:create(delayTime / 2, cc.p(0, clipSz.height / 2))
    -- 往上移动结束的位置位于底部
    local callback1 = cc.CallFunc:create(function()
        self:UpdateUIHpTip(tube)
        self._ui.Text_hp_tip:setPositionY(-(clipSz.height / 2))
    end)
    -- 往上移动
    local move2 = cc.MoveTo:create(delayTime / 2, cc.p(self._tubeTipOringPos.x, self._tubeTipOringPos.y))
    -- 结束的回调
    local callback2 = cc.CallFunc:create(function()
        self._showTubeAction = false
        self:ShowTubeAction()
    end)
    local action = cc.Sequence:create(move1, callback1, move2, callback2)
    self._ui.Text_hp_tip:runAction(action)
end

--- 显示隐藏时的动画
---@param isHide boolean 是否是隐藏
---@param func function 动画执行完的回调
function MainMonsterLayer:ShowHideAction(isHide, func)
    local panelRoot = self._ui.Panel_1
    local startScale = isHide and 1 or 0.1
    local startOpacity = isHide and 255 or 0
    local endScale = isHide and 0 or 1
    local endOpacity = isHide and 0 or 255
    local action1 = cc.Spawn:create(cc.ScaleTo:create(0.15, endScale), cc.FadeTo:create(0.15, endOpacity))
    local action2 = cc.Sequence:create(action1, cc.CallFunc:create(function()
        if func then
            func()
        end
    end))

    panelRoot:setVisible(true)
    panelRoot:setScale(startScale)
    panelRoot:setOpacity(startOpacity)
    panelRoot:runAction(action2)
end

--- 更新归属
---@param data table 归属数据
function MainMonsterLayer:UpdateTargetName(data)
    if not self._selectActorID then
        return
    end
    data = data or {}
    if self._selectActorID ~= data.actorID then
        return
    end
    self:UpdateBelongName(data)
end

return MainMonsterLayer
