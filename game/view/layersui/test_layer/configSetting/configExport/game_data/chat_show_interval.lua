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

	-- Create Layout_pc
	local Layout_pc = GUI:Layout_Create(panel_bg, "Layout_pc", 0.00, 220.00, 300.00, 60.00, false)
	GUI:setTouchEnabled(Layout_pc, false)
	GUI:setTag(Layout_pc, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_pc, "Text", 10.00, 50.00, 14, "#ffffff", [[电脑端配置：]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_bgChat
	local input_bgChat = GUI:Image_Create(Layout_pc, "input_bgChat", 80.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgChat, 74, 72, 16, 10)
	GUI:setContentSize(input_bgChat, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgChat, false)
	GUI:setTouchEnabled(input_bgChat, false)
	GUI:setTag(input_bgChat, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgChat, "text_info", -3.00, 13.00, 14, "#ffffff", [[聊天行间距]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_pc_chat
	local input_pc_chat = GUI:TextInput_Create(input_bgChat, "input_pc_chat", 0.00, 0.00, 45.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_chat, "")
	GUI:TextInput_setPlaceHolder(input_pc_chat, "0")
	GUI:TextInput_setFontColor(input_pc_chat, "#ffffff")
	GUI:setTouchEnabled(input_pc_chat, true)
	GUI:setTag(input_pc_chat, -1)

	-- Create input_bgText
	local input_bgText = GUI:Image_Create(Layout_pc, "input_bgText", 250.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgText, 74, 72, 16, 10)
	GUI:setContentSize(input_bgText, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgText, false)
	GUI:setTouchEnabled(input_bgText, false)
	GUI:setTag(input_bgText, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgText, "text_info", -3.00, 13.00, 14, "#ffffff", [[富文本行间距]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_pc_rich
	local input_pc_rich = GUI:TextInput_Create(input_bgText, "input_pc_rich", 0.00, 0.00, 45.00, 25.00, 16)
	GUI:TextInput_setString(input_pc_rich, "")
	GUI:TextInput_setPlaceHolder(input_pc_rich, "0")
	GUI:TextInput_setFontColor(input_pc_rich, "#ffffff")
	GUI:setTouchEnabled(input_pc_rich, true)
	GUI:setTag(input_pc_rich, -1)

	-- Create Layout_mobile
	local Layout_mobile = GUI:Layout_Create(panel_bg, "Layout_mobile", 0.00, 300.00, 300.00, 60.00, false)
	GUI:setTouchEnabled(Layout_mobile, false)
	GUI:setTag(Layout_mobile, -1)

	-- Create Text
	local Text = GUI:Text_Create(Layout_mobile, "Text", 10.00, 50.00, 14, "#ffffff", [[手机端配置：]])
	GUI:setAnchorPoint(Text, 0.00, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create input_bgChat
	local input_bgChat = GUI:Image_Create(Layout_mobile, "input_bgChat", 80.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgChat, 74, 72, 16, 10)
	GUI:setContentSize(input_bgChat, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgChat, false)
	GUI:setTouchEnabled(input_bgChat, false)
	GUI:setTag(input_bgChat, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgChat, "text_info", -3.00, 13.00, 14, "#ffffff", [[聊天行间距]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_mob_chat
	local input_mob_chat = GUI:TextInput_Create(input_bgChat, "input_mob_chat", 0.00, 0.00, 45.00, 25.00, 16)
	GUI:TextInput_setString(input_mob_chat, "")
	GUI:TextInput_setPlaceHolder(input_mob_chat, "0")
	GUI:TextInput_setFontColor(input_mob_chat, "#ffffff")
	GUI:setTouchEnabled(input_mob_chat, true)
	GUI:setTag(input_mob_chat, -1)

	-- Create input_bgText
	local input_bgText = GUI:Image_Create(Layout_mobile, "input_bgText", 250.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgText, 74, 72, 16, 10)
	GUI:setContentSize(input_bgText, 45, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgText, false)
	GUI:setTouchEnabled(input_bgText, false)
	GUI:setTag(input_bgText, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgText, "text_info", -3.00, 13.00, 14, "#ffffff", [[富文本行间距]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_mob_rich
	local input_mob_rich = GUI:TextInput_Create(input_bgText, "input_mob_rich", 0.00, 0.00, 45.00, 25.00, 16)
	GUI:TextInput_setString(input_mob_rich, "")
	GUI:TextInput_setPlaceHolder(input_mob_rich, "0")
	GUI:TextInput_setFontColor(input_mob_rich, "#ffffff")
	GUI:setTouchEnabled(input_mob_rich, true)
	GUI:setTag(input_mob_rich, -1)
end
return ui