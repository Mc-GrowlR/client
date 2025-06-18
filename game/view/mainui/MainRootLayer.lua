local BaseLayer = requireLayerUI("BaseLayer")
local MainRootLayer = class("MainRootLayer", BaseLayer)

function MainRootLayer:ctor()
    MainRootLayer.super.ctor(self)
end

function MainRootLayer.create()
    local layer = MainRootLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function MainRootLayer:Init()
    self._root = requireExport("main/main_root.lua").create().root
    if not self._root then
        return false
    end
    self:addChild(self._root)

    self:InitNodes()
    self:InitGUI()
    self:UpdateAdapet()

    return true
end

function MainRootLayer:InitNodes()
    self._nodes = {}

    -- adapet
    self._layoutAdapet = self._root:getChildByName("Panel_adapet")
    self._layoutAdapet:setClippingType(0)
    self._nodes[global.MMO.MAIN_NODE_LT] = self._layoutAdapet:getChildByName("Node_lt")
    self._nodes[global.MMO.MAIN_NODE_MT] = self._layoutAdapet:getChildByName("Node_mt")
    self._nodes[global.MMO.MAIN_NODE_RT] = self._layoutAdapet:getChildByName("Node_rt")
    self._nodes[global.MMO.MAIN_NODE_LB] = self._layoutAdapet:getChildByName("Node_lb")
    self._nodes[global.MMO.MAIN_NODE_MB] = self._layoutAdapet:getChildByName("Node_mb")
    self._nodes[global.MMO.MAIN_NODE_RB] = self._layoutAdapet:getChildByName("Node_rb")

    -- extra
    self._layoutExtra = self._root:getChildByName("Panel_extra")
    self._layoutExtra:setClippingType(0)
    self._nodes[global.MMO.MAIN_NODE_EXTRA_LT] = self._layoutExtra:getChildByName("Node_lt")
    self._nodes[global.MMO.MAIN_NODE_EXTRA_RT] = self._layoutExtra:getChildByName("Node_rt")
    self._nodes[global.MMO.MAIN_NODE_EXTRA_LB] = self._layoutExtra:getChildByName("Node_lb")
    self._nodes[global.MMO.MAIN_NODE_EXTRA_MT] = self._layoutExtra:getChildByName("Node_mt")

    -- chat
    self._layoutChat = self._root:getChildByName("Panel_chat")
    self._layoutChat:setClippingType(0)
    self._nodes[global.MMO.MAIN_NODE_CHAT_MAIN] = self._layoutChat:getChildByName("Node_chat_main")
    self._nodes[global.MMO.MAIN_NODE_CHAT_MINI] = self._layoutChat:getChildByName("Node_chat_mini")

    -- sui
    self._layoutSUI = self._root:getChildByName("Panel_sui")
    self._nodeSUIBM = self._root:getChildByName("Node_sui_bm")
    self._layoutExtra:setClippingType(0)
    self._nodes[global.MMO.MAIN_NODE_SUI_LT] = self._layoutSUI:getChildByName("Node_lt")
    self._nodes[global.MMO.MAIN_NODE_SUI_RT] = self._layoutSUI:getChildByName("Node_rt")
    self._nodes[global.MMO.MAIN_NODE_SUI_LB] = self._layoutSUI:getChildByName("Node_lb")
    self._nodes[global.MMO.MAIN_NODE_SUI_RB] = self._layoutSUI:getChildByName("Node_rb")
    self._nodes[global.MMO.MAIN_NODE_SUI_LM] = self._layoutSUI:getChildByName("Node_lm")
    self._nodes[global.MMO.MAIN_NODE_SUI_TM] = self._layoutSUI:getChildByName("Node_tm")
    self._nodes[global.MMO.MAIN_NODE_SUI_RM] = self._layoutSUI:getChildByName("Node_rm")
    self._nodes[global.MMO.MAIN_NODE_SUI_BM] = self._nodeSUIBM

    self._layoutTop = self._root:getChildByName("Panel_top")
    self._layoutTop:setClippingType(0)
    self._nodes[global.MMO.MAIN_NODE_TOP_LT] = self._layoutTop:getChildByName("Node_lt")
    self._nodes[global.MMO.MAIN_NODE_TOP_RT] = self._layoutTop:getChildByName("Node_rt")
    self._nodes[global.MMO.MAIN_NODE_TOP_LB] = self._layoutTop:getChildByName("Node_lb")
    self._nodes[global.MMO.MAIN_NODE_TOP_MT] = self._layoutTop:getChildByName("Node_mt")

    -- SUI TOP BOTTOM
    self._layoutBottom = self._root:getChildByName("Panel_bottom_sui")
    self._layoutBottom:setClippingType(0)
    self._nodes[global.MMO.MAIN_NODE_BOTTOM_LT] = self._layoutBottom:getChildByName("Node_lt")
    self._nodes[global.MMO.MAIN_NODE_BOTTOM_RT] = self._layoutBottom:getChildByName("Node_rt")
    self._nodes[global.MMO.MAIN_NODE_BOTTOM_LB] = self._layoutBottom:getChildByName("Node_lb")
    self._nodes[global.MMO.MAIN_NODE_BOTTOM_RB] = self._layoutBottom:getChildByName("Node_rb")

    self._layoutSUITop = self._root:getChildByName("Panel_top_sui")
    self._layoutSUITop:setClippingType(0)
    self._nodes[global.MMO.MAIN_NODE_SUI_TOP_LT] = self._layoutSUITop:getChildByName("Node_lt")
    self._nodes[global.MMO.MAIN_NODE_SUI_TOP_RT] = self._layoutSUITop:getChildByName("Node_rt")
    self._nodes[global.MMO.MAIN_NODE_SUI_TOP_LB] = self._layoutSUITop:getChildByName("Node_lb")
    self._nodes[global.MMO.MAIN_NODE_SUI_TOP_RB] = self._layoutSUITop:getChildByName("Node_rb")

    -- guide
    self._nodes[global.MMO.MAIN_NODE_GUIDE]  = self._root:getChildByName("Node_guide")
    
    
    -- adapet
    local visibleSize = global.Director:getVisibleSize()
    self._layoutAdapet:setContentSize(visibleSize)
    self._layoutExtra:setContentSize(visibleSize)
    self._layoutChat:setContentSize(visibleSize)
    self._layoutSUI:setContentSize(visibleSize)
    self._layoutTop:setContentSize(visibleSize)
    self._layoutBottom:setContentSize(visibleSize)
    self._layoutSUITop:setContentSize(visibleSize)
    ccui.Helper:doLayout(self._layoutAdapet)
    ccui.Helper:doLayout(self._layoutExtra)
    ccui.Helper:doLayout(self._layoutChat)
    ccui.Helper:doLayout(self._layoutSUI)
    ccui.Helper:doLayout(self._layoutTop)
    ccui.Helper:doLayout(self._layoutBottom)
    ccui.Helper:doLayout(self._layoutSUITop)
end

function MainRootLayer:InitGUI()
    ssr.GUI.ATTACH_LEFTTOP      = self._nodes[global.MMO.MAIN_NODE_SUI_LT]
    ssr.GUI.ATTACH_RIGHTTOP     = self._nodes[global.MMO.MAIN_NODE_SUI_RT]
    ssr.GUI.ATTACH_LEFTBOTTOM   = self._nodes[global.MMO.MAIN_NODE_SUI_LB]
    ssr.GUI.ATTACH_RIGHTBOTTOM  = self._nodes[global.MMO.MAIN_NODE_SUI_RB]
    GUI.ATTACH_LEFTTOP          = self._nodes[global.MMO.MAIN_NODE_SUI_LT]
    GUI.ATTACH_RIGHTTOP         = self._nodes[global.MMO.MAIN_NODE_SUI_RT]
    GUI.ATTACH_LEFTBOTTOM       = self._nodes[global.MMO.MAIN_NODE_SUI_LB]
    GUI.ATTACH_RIGHTBOTTOM      = self._nodes[global.MMO.MAIN_NODE_SUI_RB]
    -- bottom
    GUI.ATTACH_LEFTTOP_B        = self._nodes[global.MMO.MAIN_NODE_BOTTOM_LT]
    GUI.ATTACH_RIGHTTOP_B       = self._nodes[global.MMO.MAIN_NODE_BOTTOM_RT]
    GUI.ATTACH_LEFTBOTTOM_B     = self._nodes[global.MMO.MAIN_NODE_BOTTOM_LB]
    GUI.ATTACH_RIGHTBOTTOM_B    = self._nodes[global.MMO.MAIN_NODE_BOTTOM_RB]
    -- top
    GUI.ATTACH_LEFTTOP_T        = self._nodes[global.MMO.MAIN_NODE_SUI_TOP_LT]
    GUI.ATTACH_RIGHTTOP_T       = self._nodes[global.MMO.MAIN_NODE_SUI_TOP_RT]
    GUI.ATTACH_LEFTBOTTOM_T     = self._nodes[global.MMO.MAIN_NODE_SUI_TOP_LB]
    GUI.ATTACH_RIGHTBOTTOM_T    = self._nodes[global.MMO.MAIN_NODE_SUI_TOP_RB]

    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_LEFTTOP)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_RIGHTTOP)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_LEFTBOTTOM)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_RIGHTBOTTOM)
    local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    if OtherTradingBankProxy:getPublishOpen() ~= 1 then
        MainLeftTop.main()
    end
    MainRightTop.main()
    MainLeftBottom.main()
    MainRightBottom.main()

    local ui = ui_delegate(self._root)

    local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    if OtherTradingBankProxy:getPublishOpen() ~= 1 then
        if not ui.tradingBtn then 
            ui.tradingBtn = GUI:Button_Create(GUI.ATTACH_LEFTTOP, "tradingBtn", 270, -94, "res/private/main/bottom/jiaoyihang.png")
        end 
        ui.tradingBtn:setVisible(false)
        if global.OtherTradingBank then
            local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
            OtherTradingBankProxy:getTradingBankStatus({}, function(code, data, msg)
                local isShowEntrance = false
                if code == 200 then 
                    if data and data.isShowEntrance == 1 then
                        isShowEntrance = true
                    end
                end
                if isShowEntrance then
                    ui.tradingBtn:setVisible(true)
                    ui.tradingBtn:addClickEventListener(function ()
                        JUMPTO(35)
                    end)
                end
            end)
        end 
    end
end

function MainRootLayer:UpdateAdapet()
    local visibleSize   = global.Director:getVisibleSize()
    local glView        = global.Director:getOpenGLView()
    local viewRect      = glView:getVisibleRect() 
    local safeRect      = global.Director:getSafeAreaRect()
    releasePrint( string.format( "#################safeRect:[%d, %d  %d, %d]", safeRect.x, safeRect.y, safeRect.width, safeRect.height )  )
    releasePrint( string.format( "#################visibleRect:[%d, %d  %d, %d]", viewRect.x, viewRect.y, viewRect.width, viewRect.height )  )

    local _, rect = checkNotchPhone(true)

    -- 
    self._layoutAdapet:setContentSize(rect)
    self._layoutAdapet:setPositionX(rect.x)
    ccui.Helper:doLayout(self._layoutAdapet)

    -- 
    self._layoutChat:setContentSize(rect)
    self._layoutChat:setPositionX(rect.x)
    ccui.Helper:doLayout(self._layoutChat)

    -- 
    self._layoutSUI:setContentSize(rect)
    self._layoutSUI:setPositionX(rect.x)
    ccui.Helper:doLayout(self._layoutSUI)

    self._nodeSUIBM:setPositionX(visibleSize.width / 2)

    self._layoutTop:setContentSize(rect)
    self._layoutTop:setPositionX(rect.x)
    ccui.Helper:doLayout(self._layoutTop)

    self._layoutBottom:setContentSize(rect)
    self._layoutBottom:setPositionX(rect.x)
    ccui.Helper:doLayout(self._layoutBottom)

    self._layoutSUITop:setContentSize(rect)
    self._layoutSUITop:setPositionX(rect.x)
    ccui.Helper:doLayout(self._layoutSUITop)

    self._layoutExtra:setContentSize(visibleSize)
    ccui.Helper:doLayout(self._layoutExtra)
end

function MainRootLayer:AddChild(data)
    local parent = (data.index and self._nodes[data.index] or self._root)

    parent:addChild(data.child)
end

function MainRootLayer:GetNode(id)
    return self._nodes[id]
end

function MainRootLayer:ShowFunc()
    local _, rect   = checkNotchPhone(true)
    local destX     = rect.x
    local destY     = 78

    self._layoutAdapet:stopAllActions()
    self._layoutChat:stopAllActions()
    self._layoutAdapet:runAction(cc.MoveTo:create(0.3, cc.p(destX, destY)))
    self._layoutChat:runAction(cc.MoveTo:create(0.3, cc.p(destX, destY)))

    self._layoutExtra:stopAllActions()
    self._layoutExtra:runAction(cc.MoveTo:create(0.3, cc.p(0, destY)))
end

function MainRootLayer:HideFunc()
    local _, rect   = checkNotchPhone(true)
    local destX     = rect.x
    local destY     = 0

    self._layoutAdapet:stopAllActions()
    self._layoutChat:stopAllActions()
    self._layoutAdapet:runAction(cc.MoveTo:create(0.3, cc.p(destX, destY)))
    self._layoutChat:runAction(cc.MoveTo:create(0.3, cc.p(destX, destY)))

    self._layoutExtra:stopAllActions()
    self._layoutExtra:runAction(cc.MoveTo:create(0.3, cc.p(0, destY)))
end

return MainRootLayer
