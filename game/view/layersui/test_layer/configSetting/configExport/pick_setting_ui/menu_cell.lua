local ui = {}
function ui.init(parent)
	-- Create page_cell
	local page_cell = GUI:Layout_Create(parent, "page_cell", 260.00, 330.00, 400.00, 60.00, false)
	GUI:Layout_setBackGroundColorType(page_cell, 1)
	GUI:Layout_setBackGroundColor(page_cell, "#000000")
	GUI:Layout_setBackGroundColorOpacity(page_cell, 140)
	GUI:setTouchEnabled(page_cell, true)
	GUI:setTag(page_cell, -1)

	-- Create text_id
	local text_id = GUI:Text_Create(page_cell, "text_id", 80.00, 30.00, 16, "#ffffff", [[1]])
	GUI:setAnchorPoint(text_id, 0.00, 0.50)
	GUI:setTouchEnabled(text_id, false)
	GUI:setTag(text_id, -1)
	GUI:Text_disableOutLine(text_id)

	-- Create text_name
	local text_name = GUI:Text_Create(page_cell, "text_name", 220.00, 30.00, 16, "#ffffff", [[名字]])
	GUI:setAnchorPoint(text_name, 0.00, 0.50)
	GUI:setTouchEnabled(text_name, false)
	GUI:setTag(text_name, -1)
	GUI:Text_enableOutline(text_name, "#000000", 1)
end
return ui