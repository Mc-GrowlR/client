local BaseLayer = requireLayerUI("BaseLayer")
local MonsterBelongNetPlayerLayer = class("MonsterBelongNetPlayerLayer", BaseLayer)

local proxyUtils = requireProxy("proxyUtils")
local utf8 = require("util/utf8")

function MonsterBelongNetPlayerLayer:ctor()
    MonsterBelongNetPlayerLayer.super.ctor(self)

    self._targetID = nil
    self._targetOwnID = nil
    self._basePath = global.MMO.PATH_RES_PRIVATE .. "monster_belong_netplayer/"
end

function MonsterBelongNetPlayerLayer.create(data)
    local layer = MonsterBelongNetPlayerLayer.new()
    if layer and layer:Init(data) then
        return layer
    end
    return nil
end

function MonsterBelongNetPlayerLayer:Init(data)
    self._targetID = data.targetID
    return true
end

function MonsterBelongNetPlayerLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_MONSTER_BELONG)
    MonsterBelongNetPlayer.main(data)

    self:InitUI(data)
end

function MonsterBelongNetPlayerLayer:InitUI(data)
    data = data or {}
    self._ui = ui_delegate(self)
    self._ui.Text_name:setString("")

    self:SetClickEvent()

    self:UpdateUI(data.targeData)
    self:UpdateHP(data.targeData)
    self:UpdateSelectTx(data.targeData)

    self:InitEditMode()
end

function MonsterBelongNetPlayerLayer:InitEditMode()
    local items = {
        "Image_icon",
        "Image_icon_bg",
        "Node_tx",
        "Image_hp_bg",
        "LoadingBar_hp",
        "Text_name",
        "Panel_click",
        "Panel_1",
        "Image_name"
    }
    for _, widget in ipairs(items) do
        if self._ui[widget] then
            self._ui[widget].editMode = 1
        end
    end
end

--- 更新名字UI
---@param name string 名字
function MonsterBelongNetPlayerLayer:UpdateUIName(name)
    MonsterBelongNetPlayer.UpdateUIName(name or "")
end

--- 更新Icon
---@param name string 名字
function MonsterBelongNetPlayerLayer:UpdateUIIcon(iconPath)
    MonsterBelongNetPlayer.UpdateUIIcon(iconPath)
end

--- 点击选中事件
function MonsterBelongNetPlayerLayer:SetClickEvent()
    local clickPanel = self._ui.Panel_click
    clickPanel:addClickEventListener(function()
        if not self._targetID then
            return
        end
        local actor = global.actorManager:GetActor(self._targetID)
        if not actor then
            return
        end
        local ownerID = self:GetOwnerID(actor)
        if not ownerID then
            return
        end
        if proxyUtils.checkEnemyTag(actor) ~= 1 then
            return
        end
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:SetOwnerPlayerID(ownerID)
        PlayerInputProxy:SetTraceOwnerPlayerState(true)
    end)
end

--- 更新UI显示
function MonsterBelongNetPlayerLayer:UpdateUIVisible()
    local ownerID = self:GetOwnerID(self._targetID)
    local playerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local pkMode = playerPropertyProxy:GetPKMode()
    if ownerID and pkMode ~= global.MMO.HAM_PEACE then -- 和平模式也不显示
        self:setVisible(true)
    else
        self:setVisible(false)
    end
end

-- 归属id
function MonsterBelongNetPlayerLayer:GetOwnerID(actorID)
    if not actorID then
        return nil
    end
    local actor = global.actorManager:GetActor(actorID)
    if actor then
        local ownerID = actor:GetOwnerID()
        if not ownerID or ownerID == "" or ownerID == -1 then
            return nil
        end
        return ownerID
    end
    return nil
end

--- 刷新UI
---@param data table 刷新UI数据
function MonsterBelongNetPlayerLayer:UpdateUI(data)
    self:UpdateUIVisible()
    if not data or not data.targetID then
        return
    end

    local ownerID = data.ownerPlayerID or self:GetOwnerID(data.targetID)
    local actor = global.actorManager:GetActor(ownerID)
    if not actor then
        return
    end

    if not actor:IsPlayer() then -- 归属不是玩家
        return
    end

    if ownerID ~= self._targetOwnID then -- 更换了归属
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        inputProxy:SetOwnerPlayerID(nil)
        inputProxy:SetTraceOwnerPlayerState(false)
    end

    self._targetOwnID = ownerID

    local sex = actor:GetSexID()
    local job = actor:GetJobID()
    local iconPath = string.format(self._basePath .. "job_%s_%s.png", sex, job)
    self:UpdateUIIcon(iconPath)

    local name = actor:GetName() or ""
    self:UpdateUIName(name)
end

--- 刷新血量
---@param data table 刷新血量数据
function MonsterBelongNetPlayerLayer:UpdateHP(data)
    if not data or not data.targetID then
        return
    end

    local ownerID = data.ownerPlayerID or self:GetOwnerID(data.actorID)
    local actor = global.actorManager:GetActor(ownerID)
    if not actor then
        return
    end

    if not actor:IsPlayer() then -- 归属不是玩家
        return
    end

    -- 血量刷新
    local curHP = actor:GetHP()
    local maxHP = actor:GetMaxHP()
    local percent = math.ceil(curHP / maxHP * 100)
    self._ui.LoadingBar_hp:setPercent(percent)

    if curHP <= 0 then
        global.Facade:sendNotification(global.NoticeTable.TargetChange_After)
    end
end

function MonsterBelongNetPlayerLayer:UpdateSelectTx()
    local txNode = self._ui.Node_tx
    txNode:removeAllChildren()
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if inputProxy:GetOwnerPlayerID() and inputProxy:IsTraceOwnerPlayer() then
        local animId = 7300
        local anim = global.FrameAnimManager:CreateSFXAnim(animId)
        if anim then
            anim:Play(0, 0, true)
            txNode:addChild(anim)
        end
    end
end

--- 更新选中
function MonsterBelongNetPlayerLayer:OnSelectRefresh()
    self:UpdateSelectTx()
end

--- 出视野更改刷新
---@param data table 出视野数据
function MonsterBelongNetPlayerLayer:OnActorOwnerChange(data)
    if not data or not (data.actorID and self._targetID == data.actorID) then
        return nil
    end

    self:UpdateUI({
        targetID = self._targetID
    })
end

return MonsterBelongNetPlayerLayer
