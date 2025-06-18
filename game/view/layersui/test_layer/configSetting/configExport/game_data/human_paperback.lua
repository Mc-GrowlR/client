local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create Button_sure
	local Button_sure = GUI:Button_Create(panel_bg, "Button_sure", 263.00, 24.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_sure, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_sure, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_sure, 16, 14, 13, 11)
	GUI:setContentSize(Button_sure, 60, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_sure, false)
	GUI:Button_setTitleText(Button_sure, "保 存")
	GUI:Button_setTitleColor(Button_sure, "#00ff00")
	GUI:Button_setTitleFontSize(Button_sure, 16)
	GUI:Button_titleEnableOutline(Button_sure, "#000000", 1)
	GUI:setAnchorPoint(Button_sure, 0.50, 0.50)
	GUI:setTouchEnabled(Button_sure, true)
	GUI:setTag(Button_sure, -1)

	-- Create ListView
	local ListView = GUI:ListView_Create(panel_bg, "ListView", 0.00, 50.00, 300.00, 300.00, 1)
	GUI:ListView_setGravity(ListView, 5)
	GUI:ListView_setItemsMargin(ListView, 20)
	GUI:setTouchEnabled(ListView, true)
	GUI:setTag(ListView, -1)

	-- Create Layout1
	local Layout1 = GUI:Layout_Create(ListView, "Layout1", 0.00, 255.00, 300.00, 45.00, false)
	GUI:setTouchEnabled(Layout1, false)
	GUI:setTag(Layout1, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout1, "Text", 5.00, 45.00, 14, "#ffffff", [[战士]])
	GUI:setAnchorPoint(Text, 0.00, 1.00)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout1, "input_bg", 85.00, 0.00, "res/public/1900015004.png")
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

	-- Create input1_2
	local input1_2 = GUI:TextInput_Create(input_bg, "input1_2", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input1_2, "")
	GUI:TextInput_setFontColor(input1_2, "#ffffff")
	GUI:setTouchEnabled(input1_2, true)
	GUI:setTag(input1_2, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout1, "input_bg_1", 240.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create input1_1
	local input1_1 = GUI:TextInput_Create(input_bg_1, "input1_1", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input1_1, "")
	GUI:TextInput_setFontColor(input1_1, "#ffffff")
	GUI:setTouchEnabled(input1_1, true)
	GUI:setTag(input1_1, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg_1, "input_prefix", 0.00, 13.00, 14, "#ffffff", [[衣服外观ID：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create Layout2
	local Layout2 = GUI:Layout_Create(ListView, "Layout2", 0.00, 190.00, 300.00, 45.00, false)
	GUI:setTouchEnabled(Layout2, false)
	GUI:setTag(Layout2, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout2, "Text", 5.00, 45.00, 14, "#ffffff", [[法师]])
	GUI:setAnchorPoint(Text, 0.00, 1.00)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout2, "input_bg", 85.00, 0.00, "res/public/1900015004.png")
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

	-- Create input2_2
	local input2_2 = GUI:TextInput_Create(input_bg, "input2_2", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input2_2, "")
	GUI:TextInput_setFontColor(input2_2, "#ffffff")
	GUI:setTouchEnabled(input2_2, true)
	GUI:setTag(input2_2, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout2, "input_bg_1", 240.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create input2_1
	local input2_1 = GUI:TextInput_Create(input_bg_1, "input2_1", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input2_1, "")
	GUI:TextInput_setFontColor(input2_1, "#ffffff")
	GUI:setTouchEnabled(input2_1, true)
	GUI:setTag(input2_1, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg_1, "input_prefix", 0.00, 13.00, 14, "#ffffff", [[衣服外观ID：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)

	-- Create Layout3
	local Layout3 = GUI:Layout_Create(ListView, "Layout3", 0.00, 125.00, 300.00, 45.00, false)
	GUI:setTouchEnabled(Layout3, false)
	GUI:setTag(Layout3, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout3, "Text", 5.00, 45.00, 14, "#ffffff", [[道士]])
	GUI:setAnchorPoint(Text, 0.00, 1.00)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Layout3, "input_bg", 85.00, 0.00, "res/public/1900015004.png")
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

	-- Create input3_2
	local input3_2 = GUI:TextInput_Create(input_bg, "input3_2", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input3_2, "")
	GUI:TextInput_setFontColor(input3_2, "#ffffff")
	GUI:setTouchEnabled(input3_2, true)
	GUI:setTag(input3_2, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout3, "input_bg_1", 240.00, 0.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 55, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create input3_1
	local input3_1 = GUI:TextInput_Create(input_bg_1, "input3_1", 0.00, 0.00, 55.00, 25.00, 16)
	GUI:TextInput_setString(input3_1, "")
	GUI:TextInput_setFontColor(input3_1, "#ffffff")
	GUI:setTouchEnabled(input3_1, true)
	GUI:setTag(input3_1, -1)

	-- Create input_prefix
	local input_prefix = GUI:Text_Create(input_bg_1, "input_prefix", 0.00, 13.00, 14, "#ffffff", [[衣服外观ID：]])
	GUI:setAnchorPoint(input_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(input_prefix, false)
	GUI:setTag(input_prefix, -1)
	GUI:Text_enableOutline(input_prefix, "#000000", 1)
end
return ui