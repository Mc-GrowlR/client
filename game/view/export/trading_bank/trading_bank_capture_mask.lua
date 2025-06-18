local ui = {}
function ui.init(parent)
	-- Create Scene
	local Scene = GUI:Node_Create(parent, "Scene", 0.00, 0.00)
	GUI:setAnchorPoint(Scene, 0.50, 0.50)
	GUI:setTag(Scene, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Scene, "Panel_1", 568.00, 320.00, 1136.00, 640.00, false)
	GUI:setAnchorPoint(Panel_1, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_1, true)
	GUI:setTag(Panel_1, 311)

	-- Create Image_tips
	local Image_tips = GUI:Image_Create(Scene, "Image_tips", 573.00, 335.00, "res/private/trading_bank/1900000677.png")
	GUI:Image_setScale9Slice(Image_tips, 22, 21, 33, 34)
	GUI:setContentSize(Image_tips, 200, 100)
	GUI:setIgnoreContentAdaptWithSize(Image_tips, false)
	GUI:setAnchorPoint(Image_tips, 0.50, 0.50)
	GUI:setTouchEnabled(Image_tips, false)
	GUI:setTag(Image_tips, -1)

	-- Create Text_tips
	local Text_tips = GUI:Text_Create(Image_tips, "Text_tips", 101.00, 51.00, 16, "#ffffff", [[寄售中]])
	GUI:setAnchorPoint(Text_tips, 0.50, 0.50)
	GUI:setTouchEnabled(Text_tips, false)
	GUI:setTag(Text_tips, -1)
	GUI:Text_enableOutline(Text_tips, "#000000", 1)
end
return ui