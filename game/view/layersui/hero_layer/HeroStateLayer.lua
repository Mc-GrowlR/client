local BaseLayer = requireLayerUI("BaseLayer")
local HeroStateLayer = class("HeroStateLayer", BaseLayer)

function HeroStateLayer:ctor()
    HeroStateLayer.super.ctor(self)
end

function HeroStateLayer.create(data)
    local ui = HeroStateLayer.new()

    if ui and ui:Init(data) then
        return ui
    end

    return nil
end

function HeroStateLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function HeroStateLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_STATE)
    HeroState.main(data)
    self._root = self._ui.Panel_1

    ------------拖进背包---------------------------------------------------
    local function addItemIntoBag()
        -- dump("addItemIntoBag___")
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = ItemMoveProxy.ItemGoTo.HERO_BAG
            local data = {}
            data.target = goToName
            ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end
    GUI:addMouseButtonEvent(self._ui.Image_head,{OnSpecialRFunc = addItemIntoBag})
    ---------------------------------------------------------------------

    self:InitEditMode()
end

function HeroStateLayer:InitEditMode( ... )
    local items = {
        "Panel_1",
        "Image_z2",
        "Text_z",
        "Text_name",
        "Button_state",
        "Button_bag",
        "Button_hero",
        "Panel_ng"
    }

    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

function HeroStateLayer:refOriginalPos()
    if HeroState.refOriginalPos then 
        HeroState.refOriginalPos()
    end
end

function HeroStateLayer:Hero_Die(b)
    HeroState.Hero_Die(b)
end

function HeroStateLayer:refLevel(level)
    HeroState.refLevel(level)
end
--召唤按钮显示与否
function HeroStateLayer:HeroBtnShowOrHide(isshow)
    HeroState.HeroBtnShowOrHide(isshow)
end
--英雄召唤
function HeroStateLayer:HeroLogin()
    HeroState.HeroLogin()
end
--英雄收回
function HeroStateLayer:HeroLogOut()
    HeroState.HeroLogOut()
end
--英雄属性刷新
function HeroStateLayer:refProperty(noticeData)
    HeroState.refProperty(noticeData)
end
--状态改变
function HeroStateLayer:refState(noticeData)
    HeroState.refState(noticeData)
end

return HeroStateLayer