local ui = {}
function ui.init(parent)
	-- Create item_cell
	local item_cell = GUI:Layout_Create(parent, "item_cell", 300.00, 400.00, 460.00, 65.00, false)
	GUI:setTouchEnabled(item_cell, true)
	GUI:setTag(item_cell, -1)

	-- Create Layout_index
	local Layout_index = GUI:Layout_Create(item_cell, "Layout_index", 15.00, 33.00, 50.00, 50.00, false)
	GUI:Layout_setBackGroundColorType(Layout_index, 1)
	GUI:Layout_setBackGroundColor(Layout_index, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_index, 140)
	GUI:setAnchorPoint(Layout_index, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_index, false)
	GUI:setTag(Layout_index, -1)

	-- Create Text_index
	local Text_index = GUI:Text_Create(Layout_index, "Text_index", 25.00, 25.00, 18, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_index, 0.50, 0.50)
	GUI:setTouchEnabled(Text_index, false)
	GUI:setTag(Text_index, -1)
	GUI:Text_enableOutline(Text_index, "#000000", 1)

	-- Create Image_new
	local Image_new = GUI:Image_Create(Layout_index, "Image_new", 6.00, 36.00, "res/public/btn_npcfh_04.png")
	GUI:setAnchorPoint(Image_new, 0.50, 0.00)
	GUI:setTouchEnabled(Image_new, false)
	GUI:setTag(Image_new, -1)

	-- Create Layout_bg
	local Layout_bg = GUI:Layout_Create(item_cell, "Layout_bg", 70.00, 33.00, 390.00, 65.00, false)
	GUI:Layout_setBackGroundColorType(Layout_bg, 1)
	GUI:Layout_setBackGroundColor(Layout_bg, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_bg, 140)
	GUI:setAnchorPoint(Layout_bg, 0.00, 0.50)
	GUI:setTouchEnabled(Layout_bg, false)
	GUI:setTag(Layout_bg, -1)

	-- Create Text_key
	local Text_key = GUI:Text_Create(Layout_bg, "Text_key", 195.00, 46.00, 16, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_key, 0.50, 0.50)
	GUI:setTouchEnabled(Text_key, false)
	GUI:setTag(Text_key, -1)
	GUI:Text_enableOutline(Text_key, "#000000", 1)

	-- Create Text_name
	local Text_name = GUI:Text_Create(Layout_bg, "Text_name", 195.00, 21.00, 16, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_name, 0.50, 0.50)
	GUI:setTouchEnabled(Text_name, false)
	GUI:setTag(Text_name, -1)
	GUI:Text_enableOutline(Text_name, "#000000", 1)
end
return ui