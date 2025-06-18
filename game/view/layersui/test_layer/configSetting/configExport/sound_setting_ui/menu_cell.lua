local ui = {}
function ui.init(parent)
	-- Create page_cell
	local page_cell = GUI:Layout_Create(parent, "page_cell", 260.00, 330.00, 460.00, 50.00, false)
	GUI:Layout_setBackGroundColorType(page_cell, 1)
	GUI:Layout_setBackGroundColor(page_cell, "#000000")
	GUI:Layout_setBackGroundColorOpacity(page_cell, 51)
	GUI:setTouchEnabled(page_cell, true)
	GUI:setTag(page_cell, -1)

	-- Create text_id
	local text_id = GUI:Text_Create(page_cell, "text_id", 50.00, 25.00, 16, "#ffffff", [[1]])
	GUI:setAnchorPoint(text_id, 0.00, 0.50)
	GUI:setTouchEnabled(text_id, false)
	GUI:setTag(text_id, -1)
	GUI:Text_disableOutLine(text_id)

	-- Create text_file
	local text_file = GUI:Text_Create(page_cell, "text_file", 150.00, 25.00, 16, "#ffffff", [[mp3]])
	GUI:setAnchorPoint(text_file, 0.00, 0.50)
	GUI:setTouchEnabled(text_file, false)
	GUI:setTag(text_file, -1)
	GUI:Text_enableOutline(text_file, "#000000", 1)

	-- Create text_desc
	local text_desc = GUI:Text_Create(page_cell, "text_desc", 300.00, 25.00, 16, "#ffffff", [[mp3]])
	GUI:setAnchorPoint(text_desc, 0.00, 0.50)
	GUI:setTouchEnabled(text_desc, false)
	GUI:setTag(text_desc, -1)
	GUI:Text_enableOutline(text_desc, "#000000", 1)
end
return ui