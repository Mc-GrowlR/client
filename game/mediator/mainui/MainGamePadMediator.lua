local MainGamePadMediator = class('MainGamePadMediator', framework.Mediator)
MainGamePadMediator.NAME = "MainGamePadMediator"

function MainGamePadMediator:ctor()
    MainGamePadMediator.super.ctor(self, self.NAME)
    
    self._debugDir = cc.p(0, 0)
end

function MainGamePadMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.Layer_Main_JoystickUpdate,
        noticeTable.GameSettingChange,
        noticeTable.Rocker_Show_Distance_Change,
    }
end

function MainGamePadMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_Main_Init == noticeID then
        self:OnMainInit()

    elseif noticeTable.Layer_Main_JoystickUpdate == noticeID then
        self:OnJoystickUpdate(data)

    elseif noticeTable.GameSettingChange == noticeID then
        self:OnGameSettingChange(data)
        
    elseif noticeTable.Rocker_Show_Distance_Change == noticeID then 
        self:OnRocker_Show_Distance_Change(data)
    end
end

function MainGamePadMediator:OnMainInit()
    if not (self._nodeRun) then
        local layout = requireMainUI("MainGamePadLayout")

        self._nodeRun = layout.create(2)
        self._nodeRun:setLocalZOrder(-1)
        local data = {}
        data.child = self._nodeRun
        data.index = global.MMO.MAIN_NODE_EXTRA_LB
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)
        
        self._nodeWalk = layout.create(1)
        self._nodeWalk:setLocalZOrder(-1)
        local data = {}
        data.child = self._nodeWalk
        data.index = global.MMO.MAIN_NODE_EXTRA_LB
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)
    end
    
    
    -- for debug
    if global.isDebugMode or global.isGMMode then
        local function released_callback(keycode, evt)
            if keycode == cc.KeyCode.KEY_D then
                self._debugDir.x = self._debugDir.x - 1
            elseif keycode == cc.KeyCode.KEY_A then
                self._debugDir.x = self._debugDir.x + 1
            elseif keycode == cc.KeyCode.KEY_W then
                self._debugDir.y = self._debugDir.y - 1
            elseif keycode == cc.KeyCode.KEY_S then
                self._debugDir.y = self._debugDir.y + 1
            end
            
            if self._nodeRun:isVisible() then
                self._nodeRun:SetDir(self._debugDir)
            else
                self._nodeWalk:SetDir(self._debugDir)
            end
        end
        
        local function pressed_callback(keycode, evt)
            if keycode == cc.KeyCode.KEY_D then
                self._debugDir.x = self._debugDir.x + 1
            elseif keycode == cc.KeyCode.KEY_A then
                self._debugDir.x = self._debugDir.x - 1
            elseif keycode == cc.KeyCode.KEY_W then
                self._debugDir.y = self._debugDir.y + 1
            elseif keycode == cc.KeyCode.KEY_S then
                self._debugDir.y = self._debugDir.y - 1
            end
            
            if self._nodeRun:isVisible() then
                self._nodeRun:SetDir(self._debugDir)
            else
                self._nodeWalk:SetDir(self._debugDir)
            end
        end
        
        local listener = cc.EventListenerKeyboard:create()
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        listener:registerScriptHandler(released_callback, cc.Handler.EVENT_KEYBOARD_RELEASED)
        listener:registerScriptHandler(pressed_callback, cc.Handler.EVENT_KEYBOARD_PRESSED)
        eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    end
end

function MainGamePadMediator:GetGamePadMove()
    if not self._nodeRun or not self._nodeWalk then
        return 0xff, 1
    end

    local runAngle  = self._nodeRun:GetGamePadAngle()
    local walkAngle = self._nodeWalk:GetGamePadAngle()
    local angle     = 0xff
    local step      = 1
    if runAngle ~= 0xff then
        angle = runAngle
        step  = (SL:GetMetaValue("GAME_DATA","gameOption_WalkOnly") == 1) and 1 or 2

    elseif walkAngle ~= 0xff then
        angle = walkAngle
        step  = 1
    end

    -- 1走 2跑
    -- local move  = (walkAngle ~= 0xff and 1 or step)
    -- local angle = (walkAngle ~= 0xff and walkAngle or runAngle)

    local ret = 0xff
    if (angle > -22.5 and angle <= 22.5) then -- right
        ret = global.MMO.ORIENT_R
    
    elseif (angle > 22.5 and angle <= 67.5) then -- right up
        ret = global.MMO.ORIENT_RU
    
    elseif (angle > 67.5 and angle <= 112.5) then -- up
        ret = global.MMO.ORIENT_U
    
    elseif (angle > 112.5 and angle <= 157.5) then -- left up
        ret = global.MMO.ORIENT_LU
    
    elseif ((angle > 157.5 and angle <= 180) or (angle <= -157.5 and angle > -180)) then -- left
        ret = global.MMO.ORIENT_L
    
    elseif (angle <= -112.5 and angle > -157.5) then -- left down
        ret = global.MMO.ORIENT_LB
    
    elseif (angle <= -67.5 and angle > -112.5) then -- down
        ret = global.MMO.ORIENT_B
    
    elseif (angle <= -22.5 and angle > -67.5) then --right down
        ret = global.MMO.ORIENT_RB
    end
    return ret, step
end

function MainGamePadMediator:OnJoystickUpdate(data)
    if not self._nodeRun or not self._nodeWalk then
        return nil
    end
    self._nodeRun:UpdateJoystickMode(data)
    self._nodeWalk:UpdateJoystickMode(data)
end

function MainGamePadMediator:OnGameSettingChange(data)
    if not self._nodeRun or not self._nodeWalk then
        return nil
    end
    if data.id == 6 then
        self._nodeRun:UpdateJoystickMode(data)
        self._nodeWalk:UpdateJoystickMode(data)
    end
end

function MainGamePadMediator:OnRocker_Show_Distance_Change(data)
    if not self._nodeRun or not self._nodeWalk then
        return nil
    end
    self._nodeRun:OnRocker_Show_Distance_Change(data)
    self._nodeWalk:OnRocker_Show_Distance_Change(data)
end

return MainGamePadMediator
