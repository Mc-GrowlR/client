local RedDotLayer = class( "RedDotLayer" )
local SUIHelper     = require("sui/SUIHelper")
function  RedDotLayer:ctor()
end

function RedDotLayer.create(noticeData)
    local layer = RedDotLayer.new()

    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function RedDotLayer:Init(data)
    -- dump(data,"Init___")
    self._GuideWidgetConfig = requireConfig("GuideWidgetConfig.lua")
    self._data = data
    function func( )
         if data.add == 1 then
            self:addRedDot()
        else
            self:removeRedDot()
        end
    end
   PerformWithDelayGlobal(func,0.3) 
end

-- 基础指引：
-- 1 NPC面板组件            辅助参数.组件id  
-- 2 主界面技能模块按钮      辅助参数.组件id   挂节点.109
-- 3 任务                   辅助参数.任务id
-- 4 任务 tips              辅助参数.超链id
-- 5 主界面左上挂节点        辅助参数.组件id  挂节点.101
-- 6 主界面右上挂节点        辅助参数.组件id  挂节点.102
-- 7 主界面左下挂节点        辅助参数.组件id  挂节点.103
-- 8 主界面右下挂节点        辅助参数.组件id  挂节点.104
-- 9 主界面左中挂节点        辅助参数.组件id  挂节点.105
-- 10主界面上中挂节点        辅助参数.组件id  挂节点.106
-- 11主界面右中挂节点        辅助参数.组件id  挂节点.107
-- 12主界面下中挂节点        辅助参数.组件id  挂节点.108
function RedDotLayer:findNode()
    local idx = tonumber(self._data.mainId)
    -- dump(self._data,"_data")

    -- local indext = {
    --     [0]   = 1,--npc
    --     [101] = 5,
    --     [102] = 6,
    --     [103] = 7,
    --     [104] = 8,
    --     [105] = 9,
    --     [106] = 10,
    --     [107] = 11,
    --     [108] = 11,
    --     [109] = 2,
    --     [110] = 3,--任务
    -- }
    -- dump(indext[idx],"ssss___")
    local getNodesFunc = self._GuideWidgetConfig[idx]
    if not getNodesFunc then
        return 
    end
    local temp = { typeassist = self._data.uiId }
    self._widget, self._parent = getNodesFunc(temp)
   
    if (not self._widget) or (not self._parent) then
        -- dump(self._widget,"控件:")
        -- dump(self._parent,"父节点:")
        return nil
    end

    return self._widget
end
function RedDotLayer:addRedDot()
    local widget = self:findNode()
    --local worldPos = widget:getWorldPosition()
    if not widget then
        return
    end
    local content = widget:getBoundingBox()
    local anchor = widget:getAnchorPoint()
    local wid = content.width 
    local hei = content.height
   -- local pos = {
     --   x = worldPos.x + (0.5 - anchor.x) * wid,
      --  y = worldPos.y + (0.5 - anchor.y) * hei
   -- }
    local x = self._data.x
    local y =hei- self._data.y
    local reddot = widget:getChildByName("_RedDot_")
    if reddot then
        reddot:removeFromParent()
    end
    local strs = string.split(SL:GetMetaValue("GAME_DATA","Redtips"),"|")
    local path = strs[global.isWinPlayMode and 1 or 2]
    if not self._data.mode or (self._data.mode and self._data.mode == 0) then  -- 图片模式
        if self._data.mode and self._data.res and string.len(self._data.res) > 0 then
            path = self._data.res
        end
        path = SUIHelper.fixImageFileName(path)
        reddot = cc.Sprite:create(path)
        if reddot then
            reddot:setName("_RedDot_")
            widget:addChild(reddot)
            reddot:setPosition(x,y)
        end

    elseif self._data.mode and self._data.mode == 1 then  -- 特效模式
        local sfxID = self._data.res and tonumber(self._data.res)
        if sfxID then
            reddot = global.FrameAnimManager:CreateSFXAnim(sfxID)
            if reddot then
                reddot:Play(0, 0, true)
                reddot:setName("_RedDot_")
                widget:addChild(reddot)
                reddot:setPosition(x,y)
                reddot.sfxID = sfxID
            end
        end
    end  
    
end
function RedDotLayer:removeRedDot()
    local widget = self:findNode()
    if not widget then
        return
    end
    local reddot = widget:getChildByName("_RedDot_")
    if reddot then
        reddot:removeFromParent()
    end
end

return RedDotLayer