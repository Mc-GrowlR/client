
local BaseLayer = requireLayerUI("BaseLayer")
local ButtonPosLayer = class("ButtonPosLayer", BaseLayer)


function ButtonPosLayer:ctor()
    ButtonPosLayer.super.ctor(self)
end

function ButtonPosLayer.create(data)
    local layer = ButtonPosLayer.new()
    if layer:Init(data) then
        return layer
    else
        return nil
    end
end

function ButtonPosLayer:Init()
    GUI:LoadInternalExport(self, "button_pos/button_pos_node")
    self._ui = ui_delegate(self)

    self._off_x = 0
    self._off_y = 0
    self._now_x = 0
    self._now_y = 0
    
    self:InitLayer()
    self:initEvent()
   
    return true
end

function ButtonPosLayer:InitLayer()
    local screenW = SL:GetMetaValue("SCREEN_WIDTH")
    local screenH = SL:GetMetaValue("SCREEN_HEIGHT")
    
    self._ui.Panel_1:setContentSize(cc.size(screenW, screenH))
    self._ui.Panel_touch:setContentSize(cc.size(screenW, screenH))

    self._Node_mes = self._ui.Panel_1:getChildByName("Node_mes")
    self._Node_mes:setTag(1)
    local imgBg = self._Node_mes:getChildByName("Image_bg")
    local bgWidth = imgBg:getContentSize().width
    local nodeX = screenW - bgWidth - 10
    self._Node_mes:setPosition(cc.p(nodeX, screenH))
    self._Text_X = imgBg:getChildByName("Text_X")
    self._Text_Y = imgBg:getChildByName("Text_Y")
    self._Text_type = imgBg:getChildByName("Text_type")
    self._Node_mes:getChildByName("Button_close"):addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_ButtonPos_Close)
    end)
    self._Node_mes:getChildByName("Button_switch"):addClickEventListener(function()
        local tag = self._Node_mes:getTag()
        if tag == 0 then
            self._Node_mes:setPosition(nodeX, screenH)
            self._Node_mes:setTag(1)
        else
            self._Node_mes:setPosition(0, screenH)
            self._Node_mes:setTag(0)
        end
    end)
    local activeSize = {width = 225, height = 280}
    local activePosY = 330
    if MainSkill and MainSkill._ui and MainSkill._ui["Panel_active"] then
        activeSize = MainSkill._ui["Panel_active"]:getContentSize()
        activePosY = MainSkill._ui["Panel_active"]:getWorldPosition().y
    end

    local offTab = {
        {0, screenH},
        {screenW, screenH},
        {0, 0},
        {screenW, 0},
        {0, screenH / 2},
        {screenW / 2, screenH},
        {screenW, screenH / 2},
        {screenW / 2, 0},
        {screenW - activeSize.width, activePosY},
    }
    for i = 1, 9 do
        local selBtn = self._Node_mes:getChildByName("Button_" .. i)
        selBtn.x = offTab[i][1]
        selBtn.y = offTab[i][2]
        selBtn:addClickEventListener(function()
            local btnStr = selBtn:getChildByName("Text_zi")
            self._Text_type:setString(btnStr:getString())
            self._off_x = selBtn.x
            self._off_y = selBtn.y
            self:SetShowPos()
        end)
    end
end

function ButtonPosLayer:initEvent()
	local function onTouchBegan(touch, event) 
        if self._now_x == nil then return end
        local ontouch = touch:getLocation()
        self._now_x = math.floor(ontouch.x)
        self._now_y = math.floor(ontouch.y)
        self:SetShowPos()
		return true
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    local Panel_touch = self._ui.Panel_1:getChildByName("Panel_touch")
    
	local eventDispatcher = Panel_touch:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, Panel_touch)
end

function ButtonPosLayer:SetShowPos()
    if self._Text_X == nil then return end
    self._Text_X:setString(self._now_x - self._off_x)
    self._Text_Y:setString(- self._now_y + self._off_y)
end

return ButtonPosLayer
