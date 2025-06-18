local BaseLayer = requireLayerUI("BaseLayer")
local TopTouchEventLayer = class("TopTouchEventLayer", BaseLayer)

function TopTouchEventLayer:ctor()
    TopTouchEventLayer.super.ctor(self)

    self._path  = global.MMO.PATH_RES_PRIVATE .. "main/"
    self._skill_cloud_data = nil
end

function TopTouchEventLayer.create()
    local layer = TopTouchEventLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function TopTouchEventLayer:Init()
    self._root = CreateExport("moved_layer/top_touch_layer.lua")
    if not self._root then
        return false
    end
    self:addChild(self._root)

    self.panel = self._root:getChildByName("Panel_1")
    
    self.panel:setSwallowTouches(false)

    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_SKILL_WIN32)
    MainSkill_win32.main()

    TopTouchEventLayer:RegisterEvent()

    self:InitLocalShow()

    return true
end

function TopTouchEventLayer:RegisterEvent()
    SL:RegisterLUAEvent(LUA_EVENT_SKILL_ADD_TO_UI_WIN32, "TOP_TOUCH_EVNT_LAYER", handler(self, self.AddSkillToUI))
    SL:RegisterLUAEvent(LUA_EVENT_SKILL_REMOVE_TO_UI_WIN32, "TOP_TOUCH_EVNT_LAYER", handler(self, self.RemoveSkillToUI))
    SL:RegisterLUAEvent(LUA_EVENT_SKILL_POSITION_UPDATE_WIN32, "TOP_TOUCH_EVNT_LAYER", handler(self, self.SkillUIPostionUpdate))
end

function TopTouchEventLayer:InitLocalShow()
    local data = self:ReadLocalData()
    if not global.isWinPlayMode then
        return
    end
    if data and next(data) then
        for _, v in pairs(data) do
            if v and v.skill and v.pos then
                SLBridge:onLUAEvent(LUA_EVENT_SKILL_ADD_TO_UI_WIN32, {skill = v.skill, pos = v.pos})
            end
        end
    end
end

function TopTouchEventLayer:GetIndexBySkillID( skillID )
    if not self._skill_cloud_data then
        return nil
    end

    local skillIndex = nil
    for k, v in pairs(self._skill_cloud_data) do
        if v.skill == skillID then
            skillIndex = k
            break
        end
    end

    return skillIndex
end

function TopTouchEventLayer:AddSkillToUI(data)
    if data.skill and tonumber(data.skill) then

        if not self._skill_cloud_data then
            self._skill_cloud_data = {}
        end

        if self:GetIndexBySkillID(data.skill) then
            return
        end

        table.insert(self._skill_cloud_data, {skill = data.skill, pos = data.pos})
        self:WriteLocalData()
    end
end

function TopTouchEventLayer:SkillUIPostionUpdate(data)
    if not data or not self._skill_cloud_data then
        return
    end

    local Index = self:GetIndexBySkillID(data.skill)
    if Index then
        self._skill_cloud_data[Index] = data
    end
    self:WriteLocalData()
end

function TopTouchEventLayer:RemoveSkillToUI(data)
    if data and data.skill and self._skill_cloud_data then
        local Index = self:GetIndexBySkillID(data.skill)
        if Index then
            table.remove(self._skill_cloud_data, Index)
        end
        self:WriteLocalData()
    end
    
end


function TopTouchEventLayer:LaunchSkillEvent(sender, skillID)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)

    -- 开关技能
    if SkillProxy:IsOnoffSkill(skillID) then
        SkillProxy:RequestSkillOnoff(skillID)
        return
    end

    local destPos = inputProxy:getCursorMapPosition()
    global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, destPos = destPos})

end

function TopTouchEventLayer:WriteLocalData()
    if not global.isWinPlayMode then
        return
    end
    local key = "main_skill_pc" 
    SET_CLOUD_DATA(key, self._skill_cloud_data or {})
end

function TopTouchEventLayer:ReadLocalData()
    if not global.isWinPlayMode then
        return
    end
    local key  = "main_skill_pc" 
    local data = GET_CLOUD_DATA(key)
    return data or {}
end


return TopTouchEventLayer
