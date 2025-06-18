local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 520.00, 170.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create bg_operate
	local bg_operate = GUI:Layout_Create(panel_bg, "bg_operate", 121.00, 138.00, 85.00, 28.00, false)
	GUI:Layout_setBackGroundImage(bg_operate, "res/public/1900015004.png")
	GUI:Layout_setBackGroundImageScale9Slice(bg_operate, 73, 74, 13, 14)
	GUI:setAnchorPoint(bg_operate, 0.50, 0.00)
	GUI:setTouchEnabled(bg_operate, true)
	GUI:setTag(bg_operate, -1)

	-- Create Text
	local Text = GUI:Text_Create(bg_operate, "Text", -5.00, 14.00, 14, "#ffffff", [[选择操作]])
	GUI:setAnchorPoint(Text, 1.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_operate
	local Text_operate = GUI:Text_Create(bg_operate, "Text_operate", 33.00, 14.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_operate, 0.50, 0.50)
	GUI:setTouchEnabled(Text_operate, false)
	GUI:setTag(Text_operate, -1)
	GUI:Text_enableOutline(Text_operate, "#000000", 1)

	-- Create arrow
	local arrow = GUI:Image_Create(bg_operate, "arrow", 75.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow, 0.50, 0.50)
	GUI:setTouchEnabled(arrow, false)
	GUI:setTag(arrow, -1)

	-- Create Layout_hide
	local Layout_hide = GUI:Layout_Create(panel_bg, "Layout_hide", -412.00, -24.00, 9360.00, 6400.00, false)
	GUI:setAnchorPoint(Layout_hide, 0.50, 0.50)
	GUI:setTouchEnabled(Layout_hide, true)
	GUI:setTag(Layout_hide, -1)
	GUI:setVisible(Layout_hide, false)

	-- Create Image_pulldown
	local Image_pulldown = GUI:Image_Create(panel_bg, "Image_pulldown", 121.00, -62.00, "res/public/1900000677.png")
	GUI:Image_setScale9Slice(Image_pulldown, 22, 21, 33, 34)
	GUI:setContentSize(Image_pulldown, 86, 200)
	GUI:setIgnoreContentAdaptWithSize(Image_pulldown, false)
	GUI:setAnchorPoint(Image_pulldown, 0.50, 0.00)
	GUI:setTouchEnabled(Image_pulldown, false)
	GUI:setTag(Image_pulldown, -1)
	GUI:setVisible(Image_pulldown, false)

	-- Create list_pulldown
	local list_pulldown = GUI:ListView_Create(Image_pulldown, "list_pulldown", 43.00, 197.00, 80.00, 194.00, 1)
	GUI:ListView_setGravity(list_pulldown, 2)
	GUI:setAnchorPoint(list_pulldown, 0.50, 1.00)
	GUI:setTouchEnabled(list_pulldown, true)
	GUI:setTag(list_pulldown, -1)
end
return ui