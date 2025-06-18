local ui = {}
function ui.init(parent)
	-- Create click_cell
	local click_cell = GUI:Layout_Create(parent, "click_cell", 0.00, 0.00, 100.00, 40.00, false)
	GUI:setTouchEnabled(click_cell, true)
	GUI:setTag(click_cell, -1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(click_cell, "Text_desc", 50.00, 20.00, 16, "#ffffff", [[开关：]])
	GUI:setAnchorPoint(Text_desc, 1.00, 0.50)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, -1)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create CheckBox_able
	local CheckBox_able = GUI:Layout_Create(click_cell, "CheckBox_able", 55.00, 19.00, 44.00, 18.00, false)
	GUI:setAnchorPoint(CheckBox_able, 0.00, 0.50)
	GUI:setTouchEnabled(CheckBox_able, false)
	GUI:setTag(CheckBox_able, -1)

	-- Create Panel_off
	local Panel_off = GUI:Layout_Create(CheckBox_able, "Panel_off", 0.00, 0.00, 44.00, 18.00, false)
	GUI:setTouchEnabled(Panel_off, false)
	GUI:setTag(Panel_off, -1)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_off, "Image_bg", 22.00, 9.00, "res/private/new_setting/clickbg2.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, -1)

	-- Create Image_circle
	local Image_circle = GUI:Image_Create(Panel_off, "Image_circle", 10.00, 8.00, "res/private/new_setting/click3.png")
	GUI:setAnchorPoint(Image_circle, 0.50, 0.50)
	GUI:setTouchEnabled(Image_circle, false)
	GUI:setTag(Image_circle, -1)

	-- Create Panel_on
	local Panel_on = GUI:Layout_Create(CheckBox_able, "Panel_on", 0.00, 0.00, 44.00, 18.00, false)
	GUI:setTouchEnabled(Panel_on, false)
	GUI:setTag(Panel_on, -1)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_on, "Image_bg", 22.00, 9.00, "res/private/new_setting/clickbg1.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, -1)

	-- Create Image_circle
	local Image_circle = GUI:Image_Create(Panel_on, "Image_circle", 33.00, 8.00, "res/private/new_setting/click3.png")
	GUI:setAnchorPoint(Image_circle, 0.50, 0.50)
	GUI:setTouchEnabled(Image_circle, false)
	GUI:setTag(Image_circle, -1)
end
return ui