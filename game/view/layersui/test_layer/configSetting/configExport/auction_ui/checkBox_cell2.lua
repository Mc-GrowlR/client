local ui = {}
function ui.init(parent)
	-- Create checkBox_cell
	local checkBox_cell = GUI:Layout_Create(parent, "checkBox_cell", 0.00, 0.00, 125.00, 36.00, false)
	GUI:setAnchorPoint(checkBox_cell, 0.00, 1.00)
	GUI:setTouchEnabled(checkBox_cell, true)
	GUI:setTag(checkBox_cell, -1)

	-- Create Text_name
	local Text_name = GUI:Text_Create(checkBox_cell, "Text_name", 10.00, 18.00, 13, "#10ff00", [[装备名称]])
	GUI:setAnchorPoint(Text_name, 0.00, 0.50)
	GUI:setTouchEnabled(Text_name, false)
	GUI:setTag(Text_name, -1)
	GUI:Text_enableOutline(Text_name, "#000000", 1)
end
return ui