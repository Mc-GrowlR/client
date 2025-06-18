local MainDigLayout = class("MainDigLayout",
    function()
        return cc.Node:create()
    end
)

function MainDigLayout:ctor()
    self._targetID = nil
end

function MainDigLayout.create()
    local layout = MainDigLayout.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function MainDigLayout:Init()
    return true
end

function MainDigLayout:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_DIG)
    MainDig.main()
    
    -- 挖肉按钮
    local function dig()
        if not self._targetID then
            return nil
        end
        local targetActor = global.actorManager:GetActor(self._targetID)
        if not targetActor then
            return nil
        end

        global.Facade:sendNotification(global.NoticeTable.ClearAllInputState)
        global.Facade:sendNotification(global.NoticeTable.ClearAllAutoState)
        global.Facade:sendNotification(global.NoticeTable.InputIdle)

        local authProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        authProxy:ClearAutoLock()
        authProxy:ClearAllState()
        authProxy:ClearAFKState()

        local worldPos   = global.sceneManager:MapPos2WorldPos(targetActor:GetMapX(), targetActor:GetMapY(), true)
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        inputProxy:SetDigDest(worldPos)
    end
    self._buttonDig = MainDig.Button_dig
    self._buttonDig:addTouchEventListener(function(_, eventType)
        if eventType == 0 then
            self._buttonDig:stopAllActions()
            schedule(self._buttonDig, dig, 0.5)
            dig()

        elseif eventType == 2 or eventType == 3 then
            self._buttonDig:stopAllActions()
        end
    end)

    self:HideDig()

    self:InitEditMode()
end

function MainDigLayout:InitEditMode()
    self._buttonDig.editMode = 1
end

function MainDigLayout:ShowDig(targetID)
    self._buttonDig:setVisible(true)
    self._targetID = targetID
end

function MainDigLayout:HideDig()
    self._buttonDig:setVisible(false)
    self._targetID = nil
end

return MainDigLayout
