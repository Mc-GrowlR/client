local ui = {}
function ui.init(parent)
	-- Create Layout_cell
	local Layout_cell = GUI:Layout_Create(parent, "Layout_cell", 0.00, 119.00, 300.00, 45.00, false)
	GUI:setTouchEnabled(Layout_cell, false)
	GUI:setTag(Layout_cell, -1)

	-- Create Text_job
	local Text_job = GUI:Text_Create(Layout_cell, "Text_job", 5.00, 45.00, 14, "#ffffff", [[战士]])
	GUI:setAnchorPoint(Text_job, 0.00, 1.00)
	GUI:setTouchEnabled(Text_job, false)
	GUI:setTag(Text_job, -1)
	GUI:Text_enableOutline(Text_job, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout_cell, "input_bg", 85.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg, "input_prefix", 0.00, 13.00, 14, "#ffffff", [[武器外观ID：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create input_weapon
	local input_weapon = GUI:TextInput_Create(input_bg, "input_weapon", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input_weapon, "")
	GUI:TextInput_setFontColor(input_weapon, "#ffffff")
	GUI:setTouchEnabled(input_weapon, true)
	GUI:setTag(input_weapon, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout_cell, "input_bg_1", 240.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create input_cloth
	local input_cloth = GUI:TextInput_Create(input_bg_1, "input_cloth", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input_cloth, "")
	GUI:TextInput_setFontColor(input_cloth, "#ffffff")
	GUI:setTouchEnabled(input_cloth, true)
	GUI:setTag(input_cloth, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg_1, "input_prefix", 0.00, 13.00, 14, "#ffffff", [[衣服外观ID：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)
end
return ui