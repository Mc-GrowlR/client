local ssrBaseObj = require("ssr/ssrengine/ssrcore/ssrBaseObj")
local ssrBaseObjUI = class("ssrBaseObjUI", ssrBaseObj)
ssrBaseObjUI.NAME = "ssrBaseObjUI"

function ssrBaseObjUI:ctor()
    ssrBaseObjUI.super.ctor(self)

    self._ltype = nil
    self._layer = nil
    self._voice = true
    self._hideMain = false
    self._hideLast = false
    self._responseMoved = nil
    self._resetPostion = nil
    self._mouseBtnEvent = true
    self._escClose = true
    self._mainIdx = nil
end

function ssrBaseObjUI:OpenLayer()
    if self._ltype and self._layer then
        if self._ltype == ssr.define.UI_MAIN then
            ssr.ssrBridge:addToUIMain(self._layer, self._mainIdx)

        elseif self._ltype == ssr.define.UI_NORMAL then
            ssr.ssrBridge:addToUINormal(self._layer, self)

            if self._hideMain then
                global.Facade:sendNotification(global.NoticeTable.Layer_Main_Hide)
            end

        elseif self._ltype == ssr.define.UI_TIPS then
            ssr.ssrBridge:addToUITips(self._layer)

        elseif self._ltype == ssr.define.UI_NOTICE then
            ssr.ssrBridge:addToUINotice(self._layer)
        end
    end
end

function ssrBaseObjUI:CloseLayer()
    if self._ltype and self._layer then
        if self._ltype == ssr.define.UI_NORMAL then
            if self._hideMain then 
                global.Facade:sendNotification(global.NoticeTable.Layer_Main_Show)
                self._hideMain = false
            end

            local LayerFacadeMediator = global.Facade:retrieveMediator("LayerFacadeMediator")
            if LayerFacadeMediator then
                LayerFacadeMediator:RemoveSSROBJNormalMediator(self)
            end
        end

        self._layer:removeFromParent()

        self._ltype = nil
        self._layer = nil
    end
end

function ssrBaseObjUI:SetLocalZOrder(zOrder)
    if not self._ltype or not self._layer then
        return false
    end

    self._layer:setLocalZOrder(zOrder)
end

return ssrBaseObjUI
