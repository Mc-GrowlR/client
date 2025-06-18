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

	-- Create bg_job
	local bg_job = GUI:Image_Create(panel_bg, "bg_job", 70.00, 343.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_job, 73, 74, 13, 14)
	GUI:setContentSize(bg_job, 120, 28)
	GUI:setIgnoreContentAdaptWithSize(bg_job, false)
	GUI:setAnchorPoint(bg_job, 0.50, 0.00)
	GUI:setTouchEnabled(bg_job, true)
	GUI:setTag(bg_job, -1)

	-- Create job_prefix
	local job_prefix = GUI:Text_Create(bg_job, "job_prefix", -3.00, 13.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(job_prefix, 1.00, 0.50)
	GUI:setTouchEnabled(job_prefix, false)
	GUI:setTag(job_prefix, -1)
	GUI:Text_enableOutline(job_prefix, "#000000", 1)

	-- Create Text_select_job
	local Text_select_job = GUI:Text_Create(bg_job, "Text_select_job", 5.00, 14.00, 14, "#ffffff", [[自定义职业5]])
	GUI:setAnchorPoint(Text_select_job, 0.00, 0.50)
	GUI:setTouchEnabled(Text_select_job, false)
	GUI:setTag(Text_select_job, -1)
	GUI:Text_enableOutline(Text_select_job, "#000000", 1)

	-- Create arrow_job
	local arrow_job = GUI:Image_Create(bg_job, "arrow_job", 108.00, 14.00, "res/public/1900000624.png")
	GUI:setAnchorPoint(arrow_job, 0.50, 0.50)
	GUI:setTouchEnabled(arrow_job, false)
	GUI:setTag(arrow_job, -1)

	-- Create Node_open
	local Node_open = GUI:Node_Create(panel_bg, "Node_open", 160.00, 332.00)
	GUI:setTag(Node_open, -1)

	-- Create Layout_line
	local Layout_line = GUI:Layout_Create(panel_bg, "Layout_line", 0.00, 330.00, 300.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(Layout_line, 1)
	GUI:Layout_setBackGroundColor(Layout_line, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(Layout_line, 255)
	GUI:setTouchEnabled(Layout_line, false)
	GUI:setTag(Layout_line, -1)

	-- Create Layout_1_2
	local Layout_1_2 = GUI:Layout_Create(panel_bg, "Layout_1_2", 0.00, 282.00, 300.00, 36.00, false)
	GUI:setTouchEnabled(Layout_1_2, false)
	GUI:setTag(Layout_1_2, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout_1_2, "input_bg_1", 75.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 100, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bg_1, "text_info", -4.00, 13.00, 14, "#ffffff", [[职业名称:]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_name
	local input_name = GUI:TextInput_Create(input_bg_1, "input_name", 0.00, 1.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(input_name, "")
	GUI:TextInput_setPlaceHolder(input_name, "未命名职业")
	GUI:TextInput_setFontColor(input_name, "#ffffff")
	GUI:setTouchEnabled(input_name, true)
	GUI:setTag(input_name, -1)

	-- Create input_bgText
	local input_bgText = GUI:Image_Create(Layout_1_2, "input_bgText", 244.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgText, 74, 72, 16, 10)
	GUI:setContentSize(input_bgText, 50, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgText, false)
	GUI:setTouchEnabled(input_bgText, false)
	GUI:setTag(input_bgText, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgText, "text_info", -5.00, 13.00, 14, "#ffffff", [[字母标识:]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_hud_str
	local input_hud_str = GUI:TextInput_Create(input_bgText, "input_hud_str", 0.00, 0.00, 50.00, 25.00, 16)
	GUI:TextInput_setString(input_hud_str, "")
	GUI:TextInput_setPlaceHolder(input_hud_str, "Z/F/D")
	GUI:TextInput_setFontColor(input_hud_str, "#ffffff")
	GUI:setTouchEnabled(input_hud_str, true)
	GUI:setTag(input_hud_str, -1)

	-- Create Layout_1
	local Layout_1 = GUI:Layout_Create(panel_bg, "Layout_1", 0.00, 248.00, 300.00, 36.00, false)
	GUI:setTouchEnabled(Layout_1, false)
	GUI:setTag(Layout_1, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout_1, "input_bg_1", 140.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bg_1, "text_info", -32.00, 13.00, 14, "#ffffff", [[创建模型特效ID]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create text_info_1
	local text_info_1 = GUI:Text_Create(input_bg_1, "text_info_1", -5.00, 13.00, 14, "#ffffff", [[男:]])
	GUI:setAnchorPoint(text_info_1, 1.00, 0.50)
	GUI:setTouchEnabled(text_info_1, false)
	GUI:setTag(text_info_1, -1)
	GUI:Text_enableOutline(text_info_1, "#000000", 1)

	-- Create input_create_id_m
	local input_create_id_m = GUI:TextInput_Create(input_bg_1, "input_create_id_m", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_create_id_m, "")
	GUI:TextInput_setPlaceHolder(input_create_id_m, "4121")
	GUI:TextInput_setFontColor(input_create_id_m, "#ffffff")
	GUI:setTouchEnabled(input_create_id_m, true)
	GUI:setTag(input_create_id_m, -1)

	-- Create input_bgText
	local input_bgText = GUI:Image_Create(Layout_1, "input_bgText", 235.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgText, 74, 72, 16, 10)
	GUI:setContentSize(input_bgText, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgText, false)
	GUI:setTouchEnabled(input_bgText, false)
	GUI:setTag(input_bgText, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgText, "text_info", -5.00, 13.00, 14, "#ffffff", [[女:]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_create_id_f
	local input_create_id_f = GUI:TextInput_Create(input_bgText, "input_create_id_f", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_create_id_f, "")
	GUI:TextInput_setPlaceHolder(input_create_id_f, "4127")
	GUI:TextInput_setFontColor(input_create_id_f, "#ffffff")
	GUI:setTouchEnabled(input_create_id_f, true)
	GUI:setTag(input_create_id_f, -1)

	-- Create Layout_1_1
	local Layout_1_1 = GUI:Layout_Create(panel_bg, "Layout_1_1", 0.00, 214.00, 300.00, 36.00, false)
	GUI:setTouchEnabled(Layout_1_1, false)
	GUI:setTag(Layout_1_1, -1)

	-- Create input_bg_1
	local input_bg_1 = GUI:Image_Create(Layout_1_1, "input_bg_1", 140.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bg_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bg_1, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bg_1, false)
	GUI:setTouchEnabled(input_bg_1, false)
	GUI:setTag(input_bg_1, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bg_1, "text_info", -32.00, 13.00, 14, "#ffffff", [[创建石化特效ID]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create text_info_1
	local text_info_1 = GUI:Text_Create(input_bg_1, "text_info_1", -5.00, 13.00, 14, "#ffffff", [[男:]])
	GUI:setAnchorPoint(text_info_1, 1.00, 0.50)
	GUI:setTouchEnabled(text_info_1, false)
	GUI:setTag(text_info_1, -1)
	GUI:Text_enableOutline(text_info_1, "#000000", 1)

	-- Create input_g_id_m
	local input_g_id_m = GUI:TextInput_Create(input_bg_1, "input_g_id_m", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_g_id_m, "")
	GUI:TextInput_setPlaceHolder(input_g_id_m, "4122")
	GUI:TextInput_setFontColor(input_g_id_m, "#ffffff")
	GUI:setTouchEnabled(input_g_id_m, true)
	GUI:setTag(input_g_id_m, -1)

	-- Create input_bgText
	local input_bgText = GUI:Image_Create(Layout_1_1, "input_bgText", 235.00, 5.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgText, 74, 72, 16, 10)
	GUI:setContentSize(input_bgText, 60, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgText, false)
	GUI:setTouchEnabled(input_bgText, false)
	GUI:setTag(input_bgText, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgText, "text_info", -5.00, 13.00, 14, "#ffffff", [[女:]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_g_id_f
	local input_g_id_f = GUI:TextInput_Create(input_bgText, "input_g_id_f", 0.00, 0.00, 60.00, 25.00, 16)
	GUI:TextInput_setString(input_g_id_f, "")
	GUI:TextInput_setPlaceHolder(input_g_id_f, "4128")
	GUI:TextInput_setFontColor(input_g_id_f, "#ffffff")
	GUI:setTouchEnabled(input_g_id_f, true)
	GUI:setTag(input_g_id_f, -1)

	-- Create Layout_2
	local Layout_2 = GUI:Layout_Create(panel_bg, "Layout_2", 0.00, 100.00, 300.00, 100.00, false)
	GUI:setTouchEnabled(Layout_2, false)
	GUI:setTag(Layout_2, -1)

	-- Create input_bgChat
	local input_bgChat = GUI:Image_Create(Layout_2, "input_bgChat", 111.00, 4.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgChat, 74, 72, 16, 10)
	GUI:setContentSize(input_bgChat, 120, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgChat, false)
	GUI:setTouchEnabled(input_bgChat, false)
	GUI:setTag(input_bgChat, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgChat, "text_info", -4.00, 13.00, 14, "#ffffff", [[女裸模内观图片]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_model_f
	local input_model_f = GUI:TextInput_Create(input_bgChat, "input_model_f", 0.00, 0.00, 120.00, 25.00, 16)
	GUI:TextInput_setString(input_model_f, "")
	GUI:TextInput_setPlaceHolder(input_model_f, "00000470")
	GUI:TextInput_setFontColor(input_model_f, "#ffffff")
	GUI:setTouchEnabled(input_model_f, true)
	GUI:setTag(input_model_f, -1)

	-- Create sel_btn_2
	local sel_btn_2 = GUI:Button_Create(input_bgChat, "sel_btn_2", 122.00, 1.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(sel_btn_2, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(sel_btn_2, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(sel_btn_2, 68, 24)
	GUI:setIgnoreContentAdaptWithSize(sel_btn_2, false)
	GUI:Button_setTitleText(sel_btn_2, "选择图片")
	GUI:Button_setTitleColor(sel_btn_2, "#39b5ef")
	GUI:Button_setTitleFontSize(sel_btn_2, 14)
	GUI:Button_titleEnableOutline(sel_btn_2, "#000000", 1)
	GUI:setTouchEnabled(sel_btn_2, true)
	GUI:setTag(sel_btn_2, -1)

	-- Create input_bgChat_1
	local input_bgChat_1 = GUI:Image_Create(Layout_2, "input_bgChat_1", 111.00, 36.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgChat_1, 74, 72, 16, 10)
	GUI:setContentSize(input_bgChat_1, 120, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgChat_1, false)
	GUI:setTouchEnabled(input_bgChat_1, false)
	GUI:setTag(input_bgChat_1, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgChat_1, "text_info", -4.00, 13.00, 14, "#ffffff", [[男裸模内观图片]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_model_m
	local input_model_m = GUI:TextInput_Create(input_bgChat_1, "input_model_m", 0.00, 0.00, 120.00, 25.00, 16)
	GUI:TextInput_setString(input_model_m, "")
	GUI:TextInput_setPlaceHolder(input_model_m, "00000460")
	GUI:TextInput_setFontColor(input_model_m, "#ffffff")
	GUI:setTouchEnabled(input_model_m, true)
	GUI:setTag(input_model_m, -1)

	-- Create sel_btn_1
	local sel_btn_1 = GUI:Button_Create(input_bgChat_1, "sel_btn_1", 122.00, 1.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(sel_btn_1, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(sel_btn_1, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(sel_btn_1, 68, 24)
	GUI:setIgnoreContentAdaptWithSize(sel_btn_1, false)
	GUI:Button_setTitleText(sel_btn_1, "选择图片")
	GUI:Button_setTitleColor(sel_btn_1, "#39b5ef")
	GUI:Button_setTitleFontSize(sel_btn_1, 14)
	GUI:Button_titleEnableOutline(sel_btn_1, "#000000", 1)
	GUI:setTouchEnabled(sel_btn_1, true)
	GUI:setTag(sel_btn_1, -1)

	-- Create input_bgChat_2
	local input_bgChat_2 = GUI:Image_Create(Layout_2, "input_bgChat_2", 111.00, 68.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(input_bgChat_2, 74, 72, 16, 10)
	GUI:setContentSize(input_bgChat_2, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(input_bgChat_2, false)
	GUI:setTouchEnabled(input_bgChat_2, false)
	GUI:setTag(input_bgChat_2, -1)

	-- Create text_info
	local text_info = GUI:Text_Create(input_bgChat_2, "text_info", -4.00, 13.00, 14, "#ffffff", [[玩家裸模外观ID]])
	GUI:setAnchorPoint(text_info, 1.00, 0.50)
	GUI:setTouchEnabled(text_info, false)
	GUI:setTag(text_info, -1)
	GUI:Text_enableOutline(text_info, "#000000", 1)

	-- Create input_feature_id
	local input_feature_id = GUI:TextInput_Create(input_bgChat_2, "input_feature_id", 0.00, 0.00, 80.00, 25.00, 16)
	GUI:TextInput_setString(input_feature_id, "")
	GUI:TextInput_setPlaceHolder(input_feature_id, "9999")
	GUI:TextInput_setFontColor(input_feature_id, "#ffffff")
	GUI:setTouchEnabled(input_feature_id, true)
	GUI:setTag(input_feature_id, -1)

	-- Create Layout_hide_pullDownList
	local Layout_hide_pullDownList = GUI:Layout_Create(panel_bg, "Layout_hide_pullDownList", 0.00, 0.00, 300.00, 380.00, false)
	GUI:setTouchEnabled(Layout_hide_pullDownList, true)
	GUI:setTag(Layout_hide_pullDownList, -1)
	GUI:setVisible(Layout_hide_pullDownList, false)

	-- Create Image_pulldown_bg
	local Image_pulldown_bg = GUI:Image_Create(panel_bg, "Image_pulldown_bg", 81.00, 316.00, "res/public/1900000677.png")
	GUI:Image_setScale9Slice(Image_pulldown_bg, 22, 21, 33, 34)
	GUI:setContentSize(Image_pulldown_bg, 100, 200)
	GUI:setIgnoreContentAdaptWithSize(Image_pulldown_bg, false)
	GUI:setAnchorPoint(Image_pulldown_bg, 0.50, 1.00)
	GUI:setTouchEnabled(Image_pulldown_bg, false)
	GUI:setTag(Image_pulldown_bg, -1)
	GUI:setVisible(Image_pulldown_bg, false)

	-- Create ListView_pulldown
	local ListView_pulldown = GUI:ListView_Create(Image_pulldown_bg, "ListView_pulldown", 50.00, 199.00, 98.00, 198.00, 1)
	GUI:ListView_setGravity(ListView_pulldown, 5)
	GUI:setAnchorPoint(ListView_pulldown, 0.50, 1.00)
	GUI:setTouchEnabled(ListView_pulldown, true)
	GUI:setTag(ListView_pulldown, -1)
end
return ui