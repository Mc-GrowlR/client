local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create Text_name1
	local Text_name1 = GUI:Text_Create(panel_bg, "Text_name1", 0.00, 350.00, 14, "#ffffff", [[属性：]])
	GUI:setTouchEnabled(Text_name1, false)
	GUI:setTag(Text_name1, -1)
	GUI:Text_enableOutline(Text_name1, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_name1, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_name
	local input_name = GUI:TextInput_Create(Text_name1, "input_name", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_name, "")
	GUI:TextInput_setPlaceHolder(input_name, "[基础属性]：")
	GUI:TextInput_setFontColor(input_name, "#ffffff")
	GUI:setTouchEnabled(input_name, true)
	GUI:setTag(input_name, -1)

	-- Create Text_name2
	local Text_name2 = GUI:Text_Create(panel_bg, "Text_name2", 0.00, 300.00, 14, "#ffffff", [[属性：]])
	GUI:setTouchEnabled(Text_name2, false)
	GUI:setTag(Text_name2, -1)
	GUI:Text_enableOutline(Text_name2, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_name2, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_name
	local input_name = GUI:TextInput_Create(Text_name2, "input_name", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_name, "")
	GUI:TextInput_setPlaceHolder(input_name, "[元素属性]：")
	GUI:TextInput_setFontColor(input_name, "#ffffff")
	GUI:setTouchEnabled(input_name, true)
	GUI:setTag(input_name, -1)

	-- Create Text_name3
	local Text_name3 = GUI:Text_Create(panel_bg, "Text_name3", 0.00, 250.00, 14, "#ffffff", [[属性：]])
	GUI:setTouchEnabled(Text_name3, false)
	GUI:setTag(Text_name3, -1)
	GUI:Text_enableOutline(Text_name3, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_name3, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_name
	local input_name = GUI:TextInput_Create(Text_name3, "input_name", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_name, "")
	GUI:TextInput_setPlaceHolder(input_name, "[附加属性]：")
	GUI:TextInput_setFontColor(input_name, "#ffffff")
	GUI:setTouchEnabled(input_name, true)
	GUI:setTag(input_name, -1)

	-- Create Text_name4
	local Text_name4 = GUI:Text_Create(panel_bg, "Text_name4", 0.00, 200.00, 14, "#ffffff", [[属性：]])
	GUI:setTouchEnabled(Text_name4, false)
	GUI:setTag(Text_name4, -1)
	GUI:Text_enableOutline(Text_name4, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_name4, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_name
	local input_name = GUI:TextInput_Create(Text_name4, "input_name", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_name, "")
	GUI:TextInput_setPlaceHolder(input_name, "[物品来源]：")
	GUI:TextInput_setFontColor(input_name, "#ffffff")
	GUI:setTouchEnabled(input_name, true)
	GUI:setTag(input_name, -1)

	-- Create Text_name5
	local Text_name5 = GUI:Text_Create(panel_bg, "Text_name5", 0.00, 150.00, 14, "#ffffff", [[属性：]])
	GUI:setTouchEnabled(Text_name5, false)
	GUI:setTag(Text_name5, -1)
	GUI:Text_enableOutline(Text_name5, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_name5, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_name
	local input_name = GUI:TextInput_Create(Text_name5, "input_name", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_name, "")
	GUI:TextInput_setPlaceHolder(input_name, "[宝石属性]：")
	GUI:TextInput_setFontColor(input_name, "#ffffff")
	GUI:setTouchEnabled(input_name, true)
	GUI:setTag(input_name, -1)

	-- Create Text_color1
	local Text_color1 = GUI:Text_Create(panel_bg, "Text_color1", 160.00, 350.00, 14, "#ffffff", [[颜色：]])
	GUI:setTouchEnabled(Text_color1, false)
	GUI:setTag(Text_color1, -1)
	GUI:Text_enableOutline(Text_color1, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_color1, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_color
	local input_color = GUI:TextInput_Create(Text_color1, "input_color", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_color, "")
	GUI:TextInput_setPlaceHolder(input_color, "255")
	GUI:TextInput_setFontColor(input_color, "#ffffff")
	GUI:setTouchEnabled(input_color, true)
	GUI:setTag(input_color, -1)

	-- Create Text_color2
	local Text_color2 = GUI:Text_Create(panel_bg, "Text_color2", 160.00, 300.00, 14, "#ffffff", [[颜色：]])
	GUI:setTouchEnabled(Text_color2, false)
	GUI:setTag(Text_color2, -1)
	GUI:Text_enableOutline(Text_color2, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_color2, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_color
	local input_color = GUI:TextInput_Create(Text_color2, "input_color", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_color, "")
	GUI:TextInput_setPlaceHolder(input_color, "255")
	GUI:TextInput_setFontColor(input_color, "#ffffff")
	GUI:setTouchEnabled(input_color, true)
	GUI:setTag(input_color, -1)

	-- Create Text_color3
	local Text_color3 = GUI:Text_Create(panel_bg, "Text_color3", 160.00, 250.00, 14, "#ffffff", [[颜色：]])
	GUI:setTouchEnabled(Text_color3, false)
	GUI:setTag(Text_color3, -1)
	GUI:Text_enableOutline(Text_color3, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_color3, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_color
	local input_color = GUI:TextInput_Create(Text_color3, "input_color", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_color, "")
	GUI:TextInput_setPlaceHolder(input_color, "255")
	GUI:TextInput_setFontColor(input_color, "#ffffff")
	GUI:setTouchEnabled(input_color, true)
	GUI:setTag(input_color, -1)

	-- Create Text_color4
	local Text_color4 = GUI:Text_Create(panel_bg, "Text_color4", 160.00, 200.00, 14, "#ffffff", [[颜色：]])
	GUI:setTouchEnabled(Text_color4, false)
	GUI:setTag(Text_color4, -1)
	GUI:Text_enableOutline(Text_color4, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_color4, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_color
	local input_color = GUI:TextInput_Create(Text_color4, "input_color", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_color, "")
	GUI:TextInput_setPlaceHolder(input_color, "255")
	GUI:TextInput_setFontColor(input_color, "#ffffff")
	GUI:setTouchEnabled(input_color, true)
	GUI:setTag(input_color, -1)

	-- Create Text_color5
	local Text_color5 = GUI:Text_Create(panel_bg, "Text_color5", 160.00, 150.00, 14, "#ffffff", [[颜色：]])
	GUI:setTouchEnabled(Text_color5, false)
	GUI:setTag(Text_color5, -1)
	GUI:Text_enableOutline(Text_color5, "#000000", 1)

	-- Create input_bg
	local input_bg = GUI:Image_Create(Text_color5, "input_bg", 50.00, -5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg, 74, 72, 16, 10)
	GUI:setContentSize(input_bg, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg, false)
	GUI:setTouchEnabled(input_bg, false)
	GUI:setTag(input_bg, -1)

	-- Create input_color
	local input_color = GUI:TextInput_Create(Text_color5, "input_color", 50.00, -5.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_color, "")
	GUI:TextInput_setPlaceHolder(input_color, "255")
	GUI:TextInput_setFontColor(input_color, "#ffffff")
	GUI:setTouchEnabled(input_color, true)
	GUI:setTag(input_color, -1)

	-- Create Button_sure
	local Button_sure = GUI:Button_Create(panel_bg, "Button_sure", 150.00, 24.00, "res/private/gui_edit/Button_Normal.png")
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
end
return ui