local ui = {}
function ui.init(parent)
	-- Create Layout_close
	local Layout_close = GUI:Layout_Create(parent, "Layout_close", 0.00, 0.00, 1136.00, 640.00, false)
	GUI:setTouchEnabled(Layout_close, true)
	GUI:setTag(Layout_close, -1)

	-- Create PMainUI
	local PMainUI = GUI:Layout_Create(parent, "PMainUI", 588.00, 300.00, 200.00, 530.00, false)
	GUI:Layout_setBackGroundColorType(PMainUI, 1)
	GUI:Layout_setBackGroundColor(PMainUI, "#000000")
	GUI:Layout_setBackGroundColorOpacity(PMainUI, 229)
	GUI:setAnchorPoint(PMainUI, 0.00, 0.50)
	GUI:setTouchEnabled(PMainUI, false)
	GUI:setTag(PMainUI, -1)

	-- Create Image_input_bg
	local Image_input_bg = GUI:Image_Create(PMainUI, "Image_input_bg", 100.00, 500.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(Image_input_bg, 74, 72, 16, 10)
	GUI:setContentSize(Image_input_bg, 180, 40)
	GUI:setIgnoreContentAdaptWithSize(Image_input_bg, false)
	GUI:setAnchorPoint(Image_input_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_input_bg, false)
	GUI:setTag(Image_input_bg, -1)

	-- Create TextInput
	local TextInput = GUI:TextInput_Create(PMainUI, "TextInput", 100.00, 500.00, 180.00, 35.00, 18)
	GUI:TextInput_setString(TextInput, "")
	GUI:TextInput_setPlaceHolder(TextInput, "")
	GUI:TextInput_setFontColor(TextInput, "#ffffff")
	GUI:setAnchorPoint(TextInput, 0.50, 0.50)
	GUI:setTouchEnabled(TextInput, true)
	GUI:setTag(TextInput, -1)

	-- Create ScrollView_items
	local ScrollView_items = GUI:ScrollView_Create(PMainUI, "ScrollView_items", 100.00, 475.00, 200.00, 410.00, 1)
	GUI:ScrollView_setInnerContainerSize(ScrollView_items, 200.00, 410.00)
	GUI:setAnchorPoint(ScrollView_items, 0.50, 1.00)
	GUI:setTouchEnabled(ScrollView_items, true)
	GUI:setTag(ScrollView_items, -1)

	-- Create Layout_line
	local Layout_line = GUI:Layout_Create(PMainUI, "Layout_line", 0.00, 65.00, 200.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(Layout_line, 1)
	GUI:Layout_setBackGroundColor(Layout_line, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(Layout_line, 255)
	GUI:setTouchEnabled(Layout_line, false)
	GUI:setTag(Layout_line, -1)

	-- Create Button_sure
	local Button_sure = GUI:Button_Create(PMainUI, "Button_sure", 100.00, 30.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_sure, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_sure, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(Button_sure, 75, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_sure, false)
	GUI:Button_setTitleText(Button_sure, "新 增")
	GUI:Button_setTitleColor(Button_sure, "#00ffff")
	GUI:Button_setTitleFontSize(Button_sure, 16)
	GUI:Button_titleEnableOutline(Button_sure, "#000000", 1)
	GUI:setAnchorPoint(Button_sure, 0.50, 0.00)
	GUI:setTouchEnabled(Button_sure, true)
	GUI:setTag(Button_sure, -1)

	-- Create Text_tips
	local Text_tips = GUI:Text_Create(PMainUI, "Text_tips", 100.00, 5.00, 16, "#ffffff", [[不支持装备类型增加]])
	GUI:setAnchorPoint(Text_tips, 0.50, 0.00)
	GUI:setTouchEnabled(Text_tips, false)
	GUI:setTag(Text_tips, -1)
	GUI:Text_enableOutline(Text_tips, "#000000", 1)

	-- Create Button_close
	local Button_close = GUI:Button_Create(PMainUI, "Button_close", 201.00, 488.00, "res/public/1900000510.png")
	GUI:Button_loadTexturePressed(Button_close, "res/public/1900000511.png")
	GUI:Button_loadTextureDisabled(Button_close, "res/public/1900000511.png")
	GUI:Button_setTitleText(Button_close, "")
	GUI:Button_setTitleColor(Button_close, "#ffffff")
	GUI:Button_setTitleFontSize(Button_close, 14)
	GUI:Button_titleEnableOutline(Button_close, "#000000", 1)
	GUI:setTouchEnabled(Button_close, true)
	GUI:setTag(Button_close, -1)
end
return ui