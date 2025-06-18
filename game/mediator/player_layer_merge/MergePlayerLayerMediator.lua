local BaseUIMediator        = requireMediator("BaseUIMediator")
local MergePlayerLayerMediator = class('MergePlayerLayerMediator', BaseUIMediator)
MergePlayerLayerMediator.NAME = "MergePlayerLayerMediator"


function MergePlayerLayerMediator:ctor()
    MergePlayerLayerMediator.super.ctor(self)
end

function MergePlayerLayerMediator:InitMultiPanel()
    self.super.InitMultiPanel(self)
end

function MergePlayerLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Open,
        noticeTable.Layer_Player_Open_Hero,
        noticeTable.Layer_Player_Close,
        noticeTable.Layer_Player_Close_Hero,
    }
end

function MergePlayerLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Open then
        if IsForbidOpenBagOrEquip() then
            return
        end
        self:OpenLayer(noticeData, 1)
    elseif noticeName == notices.Layer_Player_Open_Hero then
        self:OpenLayer(noticeData, 2)
    elseif noticeName == notices.Layer_Player_Close or noticeName == notices.Layer_Player_Close_Hero then
        self:CloseLayer()
    end
end

function MergePlayerLayerMediator:OpenLayer(noticeData, showtype)
    if showtype == 2 then
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)--没英雄
        if not PlayerPropertyProxy:getIsMakeHero() then
            ShowSystemTips(GET_STRING(600000208))
            return
        end
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)--没召唤
        if not HeroPropertyProxy:HeroIsLogin() then
            ShowSystemTips(GET_STRING(600000209))
            return
        end
    end
    if not (self._layer) then
        local path = "player_layer_merge/MergePlayerFrameLayer"
        self._layer = requireLayerUI(path).create(showtype)
        self._type = global.UIZ.UI_NORMAL

        self._GUI_ID = SLDefine.LAYERID.MergePlayerMainGUI
        self._type = global.UIZ.UI_NORMAL
        MergePlayerLayerMediator.super.OpenLayer(self)
        
        self._layer:InitGUI(noticeData,showtype)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_MERGE_FRAME, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.PlayerMain
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
        if showtype == 1 then 
            global.Facade:sendNotification(global.NoticeTable.Layer_PlayerFrame_Load_Success)
        else 
            global.Facade:sendNotification(global.NoticeTable.Layer_HeroFrame_Load_Success)
        end
    else
        local extent = noticeData and noticeData.extent or 1
        local type = noticeData and noticeData.type or 1
        local openedLayer = self._layer:GetOpenedLayer()
        local openedType = self._layer:GetOpenedType()      -- 内功/基础
        local openedShowType = self._layer:GetOpenedShowType()  -- 人物/英雄
        if openedShowType == showtype then
            if openedType == type then
                if extent == openedLayer then
                    self:CloseLayer()
                else
                    self._layer:ChangeOpenedPage(extent)
                end
            else                -- 基础/内功切换
                self._layer:ChangeType(type)
                self._layer:ChangeOpenedPage(extent)
            end
        else                     -- 人物/英雄切换
            self._layer:ChangeShowType(showtype, type, extent)
        end
    end

end

function MergePlayerLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerMain
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:OnCloseMainLayer()
    end
    MergePlayerLayerMediator.super.CloseLayer(self)
end

return MergePlayerLayerMediator