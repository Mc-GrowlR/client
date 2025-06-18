local ui = {}
function ui.init(parent)
	-- Create Panel_cell
	local Panel_cell = GUI:Layout_Create(parent, "Panel_cell", 0.00, 0.00, 300.00, 140.00, false)
	GUI:setTouchEnabled(Panel_cell, false)
	GUI:setTag(Panel_cell, -1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_cell, "Text_1", 8.00, 110.00, 14, "#ffffff", [[宝箱Shape：]])
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Panel_cell, "input_bg_1", 130.00, 106.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 73, 74, 13, 14)
	GUI:setContentSize(input_bg_1, 120, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create Input_1
	local Input_1 = GUI:TextInput_Create(input_bg_1, "Input_1", 2.00, 0.00, 116.00, 25.00, 16)
	GUI:TextInput_setInputMode(Input_1, 2)
	GUI:TextInput_setString(Input_1, "")
	GUI:TextInput_setFontColor(Input_1, "#ffffff")
	GUI:setTouchEnabled(Input_1, true)
	GUI:setTag(Input_1, -1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Panel_cell, "Text_2", 8.00, 78.00, 14, "#ffffff", [[宝箱默认特效ID：]])
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, -1)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create input_bg_2
	local input_bg_2 = GUI:Image_Create(Panel_cell, "input_bg_2", 130.00, 74.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_2, 73, 74, 13, 14)
	GUI:setContentSize(input_bg_2, 120, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_2, false)
	GUI:setTouchEnabled(input_bg_2, false)
	GUI:setTag(input_bg_2, -1)

	-- Create Input_2
	local Input_2 = GUI:TextInput_Create(input_bg_2, "Input_2", 2.00, 0.00, 116.00, 25.00, 16)
	GUI:TextInput_setInputMode(Input_2, 2)
	GUI:TextInput_setString(Input_2, "")
	GUI:TextInput_setFontColor(Input_2, "#ffffff")
	GUI:setTouchEnabled(Input_2, true)
	GUI:setTag(Input_2, -1)

	-- Create Text_3
	local Text_3 = GUI:Text_Create(Panel_cell, "Text_3", 8.00, 46.00, 14, "#ffffff", [[宝箱开启特效ID：]])
	GUI:setTouchEnabled(Text_3, false)
	GUI:setTag(Text_3, -1)
	GUI:Text_enableOutline(Text_3, "#000000", 1)

	-- Create input_bg_3
	local input_bg_3 = GUI:Image_Create(Panel_cell, "input_bg_3", 130.00, 42.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_3, 73, 74, 13, 14)
	GUI:setContentSize(input_bg_3, 120, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_3, false)
	GUI:setTouchEnabled(input_bg_3, false)
	GUI:setTag(input_bg_3, -1)

	-- Create Input_3
	local Input_3 = GUI:TextInput_Create(input_bg_3, "Input_3", 2.00, 0.00, 116.00, 25.00, 16)
	GUI:TextInput_setInputMode(Input_3, 2)
	GUI:TextInput_setString(Input_3, "")
	GUI:TextInput_setFontColor(Input_3, "#ffffff")
	GUI:setTouchEnabled(Input_3, true)
	GUI:setTag(Input_3, -1)

	-- Create Text_4
	local Text_4 = GUI:Text_Create(Panel_cell, "Text_4", 8.00, 14.00, 14, "#ffffff", [[宝箱转动特效ID：]])
	GUI:setTouchEnabled(Text_4, false)
	GUI:setTag(Text_4, -1)
	GUI:Text_enableOutline(Text_4, "#000000", 1)

	-- Create input_bg_4
	local input_bg_4 = GUI:Image_Create(Panel_cell, "input_bg_4", 130.00, 10.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_4, 73, 74, 13, 14)
	GUI:setContentSize(input_bg_4, 120, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_4, false)
	GUI:setTouchEnabled(input_bg_4, false)
	GUI:setTag(input_bg_4, -1)

	-- Create Input_4
	local Input_4 = GUI:TextInput_Create(input_bg_4, "Input_4", 2.00, 0.00, 116.00, 25.00, 16)
	GUI:TextInput_setInputMode(Input_4, 2)
	GUI:TextInput_setString(Input_4, "")
	GUI:TextInput_setFontColor(Input_4, "#ffffff")
	GUI:setTouchEnabled(Input_4, true)
	GUI:setTag(Input_4, -1)

	-- Create Image_line
	local Image_line = GUI:Image_Create(Panel_cell, "Image_line", 150.00, 2.00, "res/public/1900000667.png")
	GUI:Image_setScale9Slice(Image_line, 77, 76, 1, 0)
	GUI:setContentSize(Image_line, 320, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_line, false)
	GUI:setAnchorPoint(Image_line, 0.50, 0.00)
	GUI:setTouchEnabled(Image_line, false)
	GUI:setTag(Image_line, -1)
end
return ui