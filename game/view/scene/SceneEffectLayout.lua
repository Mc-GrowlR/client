local SceneEffectLayout = class( "SceneEffectLayout" )

function  SceneEffectLayout:ctor()
end


function SceneEffectLayout.create()
	local layout = SceneEffectLayout.new()
	if layout:Init() then
		return layout
	else
		return nil
	end
end

function SceneEffectLayout:Init()
	return true
end

function SceneEffectLayout:OnClose()
	if self._selectCursor then
		self._selectCursor:removeFromParent()
		self._selectCursor:autorelease()
		self._selectCursor = nil
	end
end

function SceneEffectLayout:OnMapPickCursorShow(x, y)
	local b_actor_node = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ACTOR_SFX_BEHIND)
	if not self._selectCursor then
		self._selectCursor = global.FrameAnimManager:CreateSFXAnim(global.MMO.SFX_CURSOR)
		self._selectCursor:retain()
		self._selectCursor:SetAnimEventCallback(function()
			if self._selectCursor and self._selectCursor:getParent() then
				self._selectCursor:setVisible(false)
				self._selectCursor:Stop()
			end
		end)
	end

	self._selectCursor:setVisible(true)
	self._selectCursor:Stop()
	self._selectCursor:Play(0, 0, true)
	self._selectCursor:setPosition(x, y)

	if not self._selectCursor:getParent() then
		b_actor_node:addChild(self._selectCursor)
	end
end

return SceneEffectLayout