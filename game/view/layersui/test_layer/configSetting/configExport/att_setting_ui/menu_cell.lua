local ui = {}
function ui.init(parent)
	-- Create page_cell
	local page_cell = GUI:Layout_Create(parent, "page_cell", 260.00, 330.00, 480.00, 65.00, false)
	GUI:Layout_setBackGroundColorType(page_cell, 1)
	GUI:Layout_setBackGroundColor(page_cell, "#000000")
	GUI:Layout_setBackGroundColorOpacity(page_cell, 140)
	GUI:setTouchEnabled(page_cell, true)
	GUI:setTag(page_cell, -1)

	-- Create text_id
	local text_id = GUI:Text_Create(page_cell, "text_id", 20.00, 33.00, 16, "#ffffff", [[1]])
	GUI:setAnchorPoint(text_id, 0.50, 0.50)
	GUI:setTouchEnabled(text_id, false)
	GUI:setTag(text_id, -1)
	GUI:Text_disableOutLine(text_id)

	-- Create text_name
	local text_name = GUI:Text_Create(page_cell, "text_name", 110.00, 33.00, 16, "#ffffff", [[攻击]])
	GUI:setAnchorPoint(text_name, 0.50, 0.50)
	GUI:setTouchEnabled(text_name, false)
	GUI:setTag(text_name, -1)
	GUI:Text_enableOutline(text_name, "#000000", 1)

	-- Create text_type
	local text_type = GUI:Text_Create(page_cell, "text_type", 200.00, 33.00, 16, "#ffffff", [[类型]])
	GUI:setAnchorPoint(text_type, 0.50, 0.50)
	GUI:setTouchEnabled(text_type, false)
	GUI:setTag(text_type, -1)
	GUI:Text_enableOutline(text_type, "#000000", 1)

	-- Create text_show
	local text_show = GUI:Text_Create(page_cell, "text_show", 280.00, 33.00, 16, "#ffffff", [[tips]])
	GUI:setAnchorPoint(text_show, 0.50, 0.50)
	GUI:setTouchEnabled(text_show, false)
	GUI:setTag(text_show, -1)
	GUI:Text_enableOutline(text_show, "#000000", 1)

	-- Create text_sort
	local text_sort = GUI:Text_Create(page_cell, "text_sort", 360.00, 33.00, 16, "#ffffff", [[排序]])
	GUI:setAnchorPoint(text_sort, 0.50, 0.50)
	GUI:setTouchEnabled(text_sort, false)
	GUI:setTag(text_sort, -1)
	GUI:Text_enableOutline(text_sort, "#000000", 1)

	-- Create text_yuansu
	local text_yuansu = GUI:Text_Create(page_cell, "text_yuansu", 440.00, 33.00, 16, "#ffffff", [[否]])
	GUI:setAnchorPoint(text_yuansu, 0.50, 0.50)
	GUI:setTouchEnabled(text_yuansu, false)
	GUI:setTag(text_yuansu, -1)
	GUI:Text_enableOutline(text_yuansu, "#000000", 1)
end
return ui