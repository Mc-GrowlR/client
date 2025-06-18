local BaseUIMediator = requireMediator( "BaseUIMediator" )
local MainMonsterLayerMediator = class("MainMonsterLayerMediator", BaseUIMediator)
MainMonsterLayerMediator.NAME = "MainMonsterLayerMediator"

function MainMonsterLayerMediator:ctor()
	MainMonsterLayerMediator.super.ctor( self )
end

function MainMonsterLayerMediator:listNotificationInterests()
	local noticeTable = global.NoticeTable

	return {
		noticeTable.Layer_Main_Init,
		noticeTable.TargetChange,
		noticeTable.RefreshActorHP,
		noticeTable.ActorOwnerChange,
		noticeTable.Layer_UI_ROOT_Add_Child,
		noticeTable.SummonsAliveStatusChange,
	}
end

function MainMonsterLayerMediator:handleNotification( notification )
	local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

	if noticeTable.Layer_Main_Init == noticeID then
        self:OnOpen()
    elseif noticeTable.TargetChange == noticeID then
        self:OnTargetChange( data )
    elseif noticeTable.RefreshActorHP == noticeID then
    	self:OnRefreshHP( data )
	elseif noticeTable.ActorOwnerChange == noticeID then
        self:OnActorOwnerChange( data )
    elseif noticeTable.Layer_UI_ROOT_Add_Child == noticeID then
        self:OnRootAddChild( data )
      elseif noticeTable.SummonsAliveStatusChange == noticeID then
        self:OnSummonsAliveStatusChange(data)
    end
end

function MainMonsterLayerMediator:OnSummonsAliveStatusChange()
    if not self._layer then
        return
    end

    self._layer:OnSummonsAliveStatusChange()
end

function MainMonsterLayerMediator:OnTargetChange( data )
	local isShow = false
	if data and data.targetID then
		local actor = global.actorManager:GetActor(data.targetID)
		if actor and actor:IsMonster() and actor:GetBigTipIcon() then
			isShow = true
		end
	end

	if isShow then
		self:OnShow( data )
	else
		self:OnHide()
	end
end

function MainMonsterLayerMediator:OnOpen()
	if not self._layer then
        self._layer = requireLayerUI("main_monster/MainMonsterLayer").create()

		if self._layer then
			local childData = {}
			childData.child = self._layer
			childData.index = global.MMO.MAIN_NODE_MT
			global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, childData)

			self._layer:InitGUI({parent=self._layer})

			LoadLayerCUIConfig(global.CUIKeyTable.MAIN_MONSTER, self._layer)

			-- 默认隐藏
			self._layer:OnUpdateInitUI()
		end
    end
end

function MainMonsterLayerMediator:OnShow( data )
	if not self._layer then
        return
    end

	local isSucesse = self._layer:UpdateMonsterUI( data )

	if isSucesse then
		-- 自定义组件挂接  begin
		local componentData = {
			root  = self._layer._sui_root,
			index = global.SUIComponentTable.MainMonster
		}
		global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
		-- 自定义组件挂接   end
	end
end

function MainMonsterLayerMediator:OnHide()
	local componentData = {
		index = global.SUIComponentTable.MainMonster
	}
	global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

	if not self._layer then
		return
	end

	self._layer:OnHide()
end

function MainMonsterLayerMediator:OnRefreshHP( data )
	if not self._layer then
		return
	end
	self._layer:OnRefreshHP( data )
end

function MainMonsterLayerMediator:OnActorOwnerChange( data )
	if not self._layer then
		return
	end
	self._layer:UpdateTargetName( data )
end

function MainMonsterLayerMediator:OnRootAddChild( data )
    if not self._layer then
        return
    end

	local isShow = false
	if data and data.data and data.data.targetID then
		local actor = global.actorManager:GetActor(data.data.targetID)
		if actor and actor:IsMonster() and actor:GetBigTipIcon() then
			isShow = true
		end
	end

	if isShow and data and data.func then
		local parnet = nil
		if self._layer._ui then
			parnet = self._layer._ui.Image_bg
		end
		data.func( parnet , "MainMonster_Belong")
	end
end

return MainMonsterLayerMediator