local ui = {}
function ui.init(parent)
	-- Create Layer
	local Layer = GUI:Node_Create(parent, "Layer", 0.00, 0.00)
	GUI:setAnchorPoint(Layer, 0.50, 0.50)
	GUI:setTag(Layer, -1)

	-- Create Panel_main
	local Panel_main = GUI:Layout_Create(Layer, "Panel_main", 0.00, 0.00, 936.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_main, 1)
	GUI:Layout_setBackGroundColor(Panel_main, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_main, 76)
	GUI:setTouchEnabled(Panel_main, false)
	GUI:setTag(Panel_main, 4)

	-- Create Panel_menu1
	local Panel_menu1 = GUI:Layout_Create(Panel_main, "Panel_menu1", 0.00, 0.00, 300.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_menu1, 1)
	GUI:Layout_setBackGroundColor(Panel_menu1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_menu1, 76)
	GUI:setTouchEnabled(Panel_menu1, false)
	GUI:setTag(Panel_menu1, -1)

	-- Create ListView_menu1
	local ListView_menu1 = GUI:ListView_Create(Panel_menu1, "ListView_menu1", 0.00, 0.00, 300.00, 640.00, 1)
	GUI:ListView_setGravity(ListView_menu1, 2)
	GUI:ListView_setItemsMargin(ListView_menu1, 2)
	GUI:setTouchEnabled(ListView_menu1, true)
	GUI:setTag(ListView_menu1, -1)

	-- Create Panel_model
	local Panel_model = GUI:Layout_Create(Panel_main, "Panel_model", 300.00, 0.00, 300.00, 640.00, false)
	GUI:setTouchEnabled(Panel_model, false)
	GUI:setTag(Panel_model, -1)

	-- Create Node_behind
	local Node_behind = GUI:Node_Create(Panel_model, "Node_behind", 120.00, 300.00)
	GUI:setTag(Node_behind, -1)

	-- Create Node_model
	local Node_model = GUI:Node_Create(Panel_model, "Node_model", 120.00, 300.00)
	GUI:setTag(Node_model, -1)

	-- Create img_red
	local img_red = GUI:Image_Create(Node_model, "img_red", 25.00, -25.00, "res/public/btn_npcfh_04.png")
	GUI:setAnchorPoint(img_red, 0.50, 0.50)
	GUI:setScaleX(img_red, 0.80)
	GUI:setScaleY(img_red, 0.80)
	GUI:setTouchEnabled(img_red, false)
	GUI:setTag(img_red, -1)

	-- Create Node_buff
	local Node_buff = GUI:Node_Create(Panel_model, "Node_buff", 120.00, 300.00)
	GUI:setTag(Node_buff, -1)

	-- Create img_searchBg
	local img_searchBg = GUI:Image_Create(Panel_model, "img_searchBg", 100.00, 580.00, "res/public/1900015004.png")
	GUI:setContentSize(img_searchBg, 180, 30)
	GUI:setIgnoreContentAdaptWithSize(img_searchBg, false)
	GUI:setAnchorPoint(img_searchBg, 0.50, 0.50)
	GUI:setTouchEnabled(img_searchBg, false)
	GUI:setTag(img_searchBg, -1)

	-- Create Input_search
	local Input_search = GUI:TextInput_Create(Panel_model, "Input_search", 100.00, 580.00, 180.00, 30.00, 16)
	GUI:TextInput_setString(Input_search, "")
	GUI:TextInput_setPlaceHolder(Input_search, "请输入Buff ID.......")
	GUI:TextInput_setFontColor(Input_search, "#ffffff")
	GUI:setAnchorPoint(Input_search, 0.50, 0.50)
	GUI:setTouchEnabled(Input_search, true)
	GUI:setTag(Input_search, -1)

	-- Create Button_search
	local Button_search = GUI:Button_Create(Panel_model, "Button_search", 240.00, 580.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_search, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_search, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_search, 0, 0, 0, 0)
	GUI:setContentSize(Button_search, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_search, false)
	GUI:Button_setTitleText(Button_search, "搜索")
	GUI:Button_setTitleColor(Button_search, "#39b5ef")
	GUI:Button_setTitleFontSize(Button_search, 14)
	GUI:Button_titleEnableOutline(Button_search, "#000000", 1)
	GUI:setAnchorPoint(Button_search, 0.50, 0.50)
	GUI:setTouchEnabled(Button_search, true)
	GUI:setTag(Button_search, -1)

	-- Create Panel_info
	local Panel_info = GUI:Layout_Create(Panel_main, "Panel_info", 600.00, 0.00, 336.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_info, 1)
	GUI:Layout_setBackGroundColor(Panel_info, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_info, 76)
	GUI:setTouchEnabled(Panel_info, false)
	GUI:setTag(Panel_info, -1)

	-- Create Text_audio
	local Text_audio = GUI:Text_Create(Panel_info, "Text_audio", 20.00, 610.00, 16, "#ffffff", [[音效ID：]])
	GUI:setTouchEnabled(Text_audio, false)
	GUI:setTag(Text_audio, -1)
	GUI:Text_enableOutline(Text_audio, "#000000", 1)

	-- Create img_inputBg_audio
	local img_inputBg_audio = GUI:Image_Create(Panel_info, "img_inputBg_audio", 120.00, 605.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg_audio, 120, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg_audio, false)
	GUI:setTouchEnabled(img_inputBg_audio, false)
	GUI:setTag(img_inputBg_audio, -1)

	-- Create Input_sfx1_audio
	local Input_sfx1_audio = GUI:TextInput_Create(Panel_info, "Input_sfx1_audio", 120.00, 605.00, 120.00, 24.00, 16)
	GUI:TextInput_setString(Input_sfx1_audio, "")
	GUI:TextInput_setFontColor(Input_sfx1_audio, "#ffffff")
	GUI:setTouchEnabled(Input_sfx1_audio, true)
	GUI:setTag(Input_sfx1_audio, -1)

	-- Create Text_sfx1
	local Text_sfx1 = GUI:Text_Create(Panel_info, "Text_sfx1", 20.00, 580.00, 16, "#ffffff", [[前特效ID：]])
	GUI:setTouchEnabled(Text_sfx1, false)
	GUI:setTag(Text_sfx1, -1)
	GUI:Text_enableOutline(Text_sfx1, "#000000", 1)

	-- Create img_inputBg1
	local img_inputBg1 = GUI:Image_Create(Panel_info, "img_inputBg1", 120.00, 575.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg1, 120, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg1, false)
	GUI:setTouchEnabled(img_inputBg1, false)
	GUI:setTag(img_inputBg1, -1)

	-- Create Input_sfx1
	local Input_sfx1 = GUI:TextInput_Create(Panel_info, "Input_sfx1", 120.00, 575.00, 120.00, 24.00, 16)
	GUI:TextInput_setString(Input_sfx1, "")
	GUI:TextInput_setFontColor(Input_sfx1, "#ffffff")
	GUI:setTouchEnabled(Input_sfx1, true)
	GUI:setTag(Input_sfx1, -1)

	-- Create Text_sfx2
	local Text_sfx2 = GUI:Text_Create(Panel_info, "Text_sfx2", 20.00, 550.00, 16, "#ffffff", [[后特效ID：]])
	GUI:setTouchEnabled(Text_sfx2, false)
	GUI:setTag(Text_sfx2, -1)
	GUI:Text_enableOutline(Text_sfx2, "#000000", 1)

	-- Create img_inputBg2
	local img_inputBg2 = GUI:Image_Create(Panel_info, "img_inputBg2", 120.00, 545.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg2, 120, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg2, false)
	GUI:setTouchEnabled(img_inputBg2, false)
	GUI:setTag(img_inputBg2, -1)

	-- Create Input_sfx2
	local Input_sfx2 = GUI:TextInput_Create(Panel_info, "Input_sfx2", 120.00, 545.00, 120.00, 24.00, 16)
	GUI:TextInput_setString(Input_sfx2, "")
	GUI:TextInput_setFontColor(Input_sfx2, "#ffffff")
	GUI:setTouchEnabled(Input_sfx2, true)
	GUI:setTag(Input_sfx2, -1)

	-- Create Text_speed
	local Text_speed = GUI:Text_Create(Panel_info, "Text_speed", 20.00, 515.00, 16, "#ffffff", [[速度：]])
	GUI:setTouchEnabled(Text_speed, false)
	GUI:setTag(Text_speed, -1)
	GUI:Text_enableOutline(Text_speed, "#000000", 1)

	-- Create img_inputBg3
	local img_inputBg3 = GUI:Image_Create(Panel_info, "img_inputBg3", 120.00, 515.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg3, 120, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg3, false)
	GUI:setTouchEnabled(img_inputBg3, false)
	GUI:setTag(img_inputBg3, -1)

	-- Create Input_speed
	local Input_speed = GUI:TextInput_Create(Panel_info, "Input_speed", 120.00, 515.00, 120.00, 24.00, 16)
	GUI:TextInput_setString(Input_speed, "")
	GUI:TextInput_setFontColor(Input_speed, "#ffffff")
	GUI:setTouchEnabled(Input_speed, true)
	GUI:setTag(Input_speed, -1)

	-- Create Text_x
	local Text_x = GUI:Text_Create(Panel_info, "Text_x", 20.00, 485.00, 16, "#ffffff", [[X坐标偏移：]])
	GUI:setTouchEnabled(Text_x, false)
	GUI:setTag(Text_x, -1)
	GUI:Text_enableOutline(Text_x, "#000000", 1)

	-- Create img_inputBg4
	local img_inputBg4 = GUI:Image_Create(Panel_info, "img_inputBg4", 120.00, 485.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg4, 120, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg4, false)
	GUI:setTouchEnabled(img_inputBg4, false)
	GUI:setTag(img_inputBg4, -1)

	-- Create Input_x
	local Input_x = GUI:TextInput_Create(Panel_info, "Input_x", 120.00, 485.00, 120.00, 24.00, 16)
	GUI:TextInput_setString(Input_x, "")
	GUI:TextInput_setFontColor(Input_x, "#ffffff")
	GUI:setTouchEnabled(Input_x, true)
	GUI:setTag(Input_x, -1)

	-- Create Text_y
	local Text_y = GUI:Text_Create(Panel_info, "Text_y", 20.00, 455.00, 16, "#ffffff", [[Y坐标偏移：]])
	GUI:setTouchEnabled(Text_y, false)
	GUI:setTag(Text_y, -1)
	GUI:Text_enableOutline(Text_y, "#000000", 1)

	-- Create img_inputBg5
	local img_inputBg5 = GUI:Image_Create(Panel_info, "img_inputBg5", 120.00, 455.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg5, 120, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg5, false)
	GUI:setTouchEnabled(img_inputBg5, false)
	GUI:setTag(img_inputBg5, -1)

	-- Create Input_y
	local Input_y = GUI:TextInput_Create(Panel_info, "Input_y", 120.00, 455.00, 120.00, 24.00, 16)
	GUI:TextInput_setString(Input_y, "")
	GUI:TextInput_setFontColor(Input_y, "#ffffff")
	GUI:setTouchEnabled(Input_y, true)
	GUI:setTag(Input_y, -1)

	-- Create Text_title
	local Text_title = GUI:Text_Create(Panel_info, "Text_title", 20.00, 425.00, 16, "#ffffff", [[触发buff文字：]])
	GUI:setTouchEnabled(Text_title, false)
	GUI:setTag(Text_title, -1)
	GUI:Text_enableOutline(Text_title, "#000000", 1)

	-- Create img_inputBg6
	local img_inputBg6 = GUI:Image_Create(Panel_info, "img_inputBg6", 20.00, 360.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg6, 250, 60)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg6, false)
	GUI:setTouchEnabled(img_inputBg6, false)
	GUI:setTag(img_inputBg6, -1)

	-- Create Input_title
	local Input_title = GUI:TextInput_Create(Panel_info, "Input_title", 20.00, 360.00, 250.00, 60.00, 16)
	GUI:TextInput_setString(Input_title, "")
	GUI:TextInput_setFontColor(Input_title, "#ffffff")
	GUI:setTouchEnabled(Input_title, true)
	GUI:setTag(Input_title, -1)

	-- Create Button_icon
	local Button_icon = GUI:Button_Create(Panel_info, "Button_icon", 50.00, 230.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_icon, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_icon, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_icon, 16, 16, 12, 12)
	GUI:setContentSize(Button_icon, 80, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_icon, false)
	GUI:Button_setTitleText(Button_icon, "选择文件")
	GUI:Button_setTitleColor(Button_icon, "#44ddff")
	GUI:Button_setTitleFontSize(Button_icon, 14)
	GUI:Button_titleEnableOutline(Button_icon, "#000000", 1)
	GUI:setAnchorPoint(Button_icon, 0.50, 0.50)
	GUI:setTouchEnabled(Button_icon, true)
	GUI:setTag(Button_icon, -1)

	-- Create Text_path
	local Text_path = GUI:Text_Create(Panel_info, "Text_path", 110.00, 180.00, 16, "#ffffff", [[图片路径：]])
	GUI:setAnchorPoint(Text_path, 0.00, 0.50)
	GUI:setTouchEnabled(Text_path, false)
	GUI:setTag(Text_path, -1)
	GUI:Text_enableOutline(Text_path, "#000000", 1)

	-- Create Image_icon
	local Image_icon = GUI:Image_Create(Panel_info, "Image_icon", 50.00, 180.00, "res/private/gui_edit/ImageFile.png")
	GUI:setAnchorPoint(Image_icon, 0.50, 0.50)
	GUI:setTouchEnabled(Image_icon, false)
	GUI:setTag(Image_icon, -1)

	-- Create Text_tips
	local Text_tips = GUI:Text_Create(Panel_info, "Text_tips", 20.00, 120.00, 16, "#ffffff", [[图标Tips内容显示：]])
	GUI:setTouchEnabled(Text_tips, false)
	GUI:setTag(Text_tips, -1)
	GUI:Text_enableOutline(Text_tips, "#000000", 1)

	-- Create img_inputBg7
	local img_inputBg7 = GUI:Image_Create(Panel_info, "img_inputBg7", 20.00, 30.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg7, 250, 80)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg7, false)
	GUI:setTouchEnabled(img_inputBg7, false)
	GUI:setTag(img_inputBg7, -1)

	-- Create Input_tips
	local Input_tips = GUI:TextInput_Create(Panel_info, "Input_tips", 20.00, 30.00, 250.00, 80.00, 16)
	GUI:TextInput_setString(Input_tips, "")
	GUI:TextInput_setFontColor(Input_tips, "#ffffff")
	GUI:setTouchEnabled(Input_tips, true)
	GUI:setTag(Input_tips, -1)

	-- Create Text_color
	local Text_color = GUI:Text_Create(Panel_info, "Text_color", 20.00, 340.00, 16, "#ffffff", [[模型颜色：]])
	GUI:setAnchorPoint(Text_color, 0.00, 0.50)
	GUI:setTouchEnabled(Text_color, false)
	GUI:setTag(Text_color, -1)
	GUI:Text_enableOutline(Text_color, "#000000", 1)

	-- Create Text
	local Text = GUI:Text_Create(Text_color, "Text", 220.00, 0.00, 14, "#a0a0a4", [[0-255数值]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_color, "img_inputBg", 120.00, 10.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg, 80, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_color
	local Input_color = GUI:TextInput_Create(Text_color, "Input_color", 120.00, 10.00, 80.00, 24.00, 16)
	GUI:TextInput_setString(Input_color, "")
	GUI:TextInput_setFontColor(Input_color, "#ffffff")
	GUI:setAnchorPoint(Input_color, 0.00, 0.50)
	GUI:setTouchEnabled(Input_color, true)
	GUI:setTag(Input_color, -1)

	-- Create panel_color
	local panel_color = GUI:Layout_Create(Text_color, "panel_color", 80.00, 10.00, 30.00, 30.00, false)
	GUI:Layout_setBackGroundColorType(panel_color, 1)
	GUI:Layout_setBackGroundColor(panel_color, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(panel_color, 255)
	GUI:setAnchorPoint(panel_color, 0.00, 0.50)
	GUI:setTouchEnabled(panel_color, false)
	GUI:setTag(panel_color, -1)

	-- Create Text_scale
	local Text_scale = GUI:Text_Create(Panel_info, "Text_scale", 20.00, 305.00, 16, "#ffffff", [[模型缩放：]])
	GUI:setAnchorPoint(Text_scale, 0.00, 0.50)
	GUI:setTouchEnabled(Text_scale, false)
	GUI:setTag(Text_scale, -1)
	GUI:Text_enableOutline(Text_scale, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_scale, "img_inputBg", 80.00, 10.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg, 80, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_scale
	local Input_scale = GUI:TextInput_Create(Text_scale, "Input_scale", 80.00, 10.00, 80.00, 24.00, 16)
	GUI:TextInput_setString(Input_scale, "")
	GUI:TextInput_setFontColor(Input_scale, "#ffffff")
	GUI:setAnchorPoint(Input_scale, 0.00, 0.50)
	GUI:setTouchEnabled(Input_scale, true)
	GUI:setTag(Input_scale, -1)

	-- Create Text_avatar
	local Text_avatar = GUI:Text_Create(Panel_info, "Text_avatar", 20.00, 275.00, 16, "#ffffff", [[模型变形：]])
	GUI:setAnchorPoint(Text_avatar, 0.00, 0.50)
	GUI:setTouchEnabled(Text_avatar, false)
	GUI:setTag(Text_avatar, -1)
	GUI:Text_enableOutline(Text_avatar, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_avatar, "img_inputBg", 80.00, 10.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg, 80, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_avatar
	local Input_avatar = GUI:TextInput_Create(Text_avatar, "Input_avatar", 80.00, 10.00, 80.00, 24.00, 16)
	GUI:TextInput_setString(Input_avatar, "")
	GUI:TextInput_setFontColor(Input_avatar, "#ffffff")
	GUI:setAnchorPoint(Input_avatar, 0.00, 0.50)
	GUI:setTouchEnabled(Input_avatar, true)
	GUI:setTag(Input_avatar, -1)

	-- Create Text_sort
	local Text_sort = GUI:Text_Create(Panel_info, "Text_sort", 109.00, 226.00, 16, "#ffffff", [[图标排列顺序：
(数字越小位置越前)]])
	GUI:setAnchorPoint(Text_sort, 0.00, 0.50)
	GUI:setTouchEnabled(Text_sort, false)
	GUI:setTag(Text_sort, -1)
	GUI:Text_enableOutline(Text_sort, "#000000", 1)

	-- Create img_inputBg
	local img_inputBg = GUI:Image_Create(Text_sort, "img_inputBg", 120.00, 30.00, "res/public/1900015004.png")
	GUI:setContentSize(img_inputBg, 80, 24)
	GUI:setIgnoreContentAdaptWithSize(img_inputBg, false)
	GUI:setAnchorPoint(img_inputBg, 0.00, 0.50)
	GUI:setTouchEnabled(img_inputBg, false)
	GUI:setTag(img_inputBg, -1)

	-- Create Input_sort
	local Input_sort = GUI:TextInput_Create(Text_sort, "Input_sort", 120.00, 30.00, 80.00, 24.00, 16)
	GUI:TextInput_setString(Input_sort, "")
	GUI:TextInput_setFontColor(Input_sort, "#ffffff")
	GUI:setAnchorPoint(Input_sort, 0.00, 0.50)
	GUI:setTouchEnabled(Input_sort, true)
	GUI:setTag(Input_sort, -1)

	-- Create CheckBox_lookOther
	local CheckBox_lookOther = GUI:CheckBox_Create(Panel_info, "CheckBox_lookOther", 208.00, 264.00, "res/public/1900000550.png", "res/public/1900000551.png")
	GUI:CheckBox_setSelected(CheckBox_lookOther, false)
	GUI:setTouchEnabled(CheckBox_lookOther, true)
	GUI:setTag(CheckBox_lookOther, -1)

	-- Create Text_lookOther
	local Text_lookOther = GUI:Text_Create(Panel_info, "Text_lookOther", 242.00, 268.00, 16, "#ffffff", [[他人可见]])
	GUI:setTouchEnabled(Text_lookOther, false)
	GUI:setTag(Text_lookOther, -1)
	GUI:Text_enableOutline(Text_lookOther, "#000000", 1)

	-- Create Button_save
	local Button_save = GUI:Button_Create(Panel_main, "Button_save", 905.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_save, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_save, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_save, 15, 16, 12, 12)
	GUI:setContentSize(Button_save, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_save, false)
	GUI:Button_setTitleText(Button_save, "保存")
	GUI:Button_setTitleColor(Button_save, "#10ff00")
	GUI:Button_setTitleFontSize(Button_save, 14)
	GUI:Button_titleEnableOutline(Button_save, "#000000", 1)
	GUI:setAnchorPoint(Button_save, 0.50, 0.50)
	GUI:setTouchEnabled(Button_save, true)
	GUI:setTag(Button_save, -1)

	-- Create Button_add
	local Button_add = GUI:Button_Create(Panel_main, "Button_add", 335.00, 100.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_add, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_add, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_add, 0, 0, 0, 0)
	GUI:setContentSize(Button_add, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_add, false)
	GUI:Button_setTitleText(Button_add, "添加")
	GUI:Button_setTitleColor(Button_add, "#10ff00")
	GUI:Button_setTitleFontSize(Button_add, 14)
	GUI:Button_titleEnableOutline(Button_add, "#000000", 1)
	GUI:setAnchorPoint(Button_add, 0.50, 0.50)
	GUI:setTouchEnabled(Button_add, true)
	GUI:setTag(Button_add, -1)
	GUI:setVisible(Button_add, false)

	-- Create Button_delete
	local Button_delete = GUI:Button_Create(Panel_main, "Button_delete", 335.00, 60.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_delete, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_delete, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_delete, 0, 0, 0, 0)
	GUI:setContentSize(Button_delete, 50, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_delete, false)
	GUI:Button_setTitleText(Button_delete, "删除")
	GUI:Button_setTitleColor(Button_delete, "#10ff00")
	GUI:Button_setTitleFontSize(Button_delete, 14)
	GUI:Button_titleEnableOutline(Button_delete, "#000000", 1)
	GUI:setAnchorPoint(Button_delete, 0.50, 0.50)
	GUI:setTouchEnabled(Button_delete, true)
	GUI:setTag(Button_delete, -1)
	GUI:setVisible(Button_delete, false)

	-- Create Button_edit
	local Button_edit = GUI:Button_Create(Panel_main, "Button_edit", 350.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_edit, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_edit, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_edit, 16, 16, 12, 12)
	GUI:setContentSize(Button_edit, 80, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_edit, false)
	GUI:Button_setTitleText(Button_edit, "编辑名字")
	GUI:Button_setTitleColor(Button_edit, "#10ff00")
	GUI:Button_setTitleFontSize(Button_edit, 14)
	GUI:Button_titleEnableOutline(Button_edit, "#000000", 1)
	GUI:setAnchorPoint(Button_edit, 0.50, 0.50)
	GUI:setTouchEnabled(Button_edit, true)
	GUI:setTag(Button_edit, -1)
	GUI:setVisible(Button_edit, false)

	-- Create Button_update
	local Button_update = GUI:Button_Create(Panel_main, "Button_update", 555.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_update, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_update, "res/private/gui_edit/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_update, 16, 16, 12, 12)
	GUI:setContentSize(Button_update, 80, 30)
	GUI:setIgnoreContentAdaptWithSize(Button_update, false)
	GUI:Button_setTitleText(Button_update, "更新服务")
	GUI:Button_setTitleColor(Button_update, "#10ff00")
	GUI:Button_setTitleFontSize(Button_update, 14)
	GUI:Button_titleEnableOutline(Button_update, "#000000", 1)
	GUI:setAnchorPoint(Button_update, 0.50, 0.50)
	GUI:setTouchEnabled(Button_update, true)
	GUI:setTag(Button_update, -1)

	-- Create Panel_tips
	local Panel_tips = GUI:Layout_Create(Panel_main, "Panel_tips", 300.00, 120.00, 200.00, 100.00, false)
	GUI:Layout_setBackGroundColorType(Panel_tips, 1)
	GUI:Layout_setBackGroundColor(Panel_tips, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_tips, 153)
	GUI:setTouchEnabled(Panel_tips, false)
	GUI:setTag(Panel_tips, -1)
	GUI:setVisible(Panel_tips, false)

	-- Create Input_name
	local Input_name = GUI:TextInput_Create(Panel_tips, "Input_name", 100.00, 60.00, 100.00, 25.00, 16)
	GUI:TextInput_setString(Input_name, "")
	GUI:TextInput_setPlaceHolder(Input_name, "请输入.......")
	GUI:TextInput_setFontColor(Input_name, "#ffffff")
	GUI:setAnchorPoint(Input_name, 0.50, 0.50)
	GUI:setTouchEnabled(Input_name, true)
	GUI:setTag(Input_name, -1)

	-- Create Btn_yes
	local Btn_yes = GUI:Button_Create(Panel_tips, "Btn_yes", 50.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Btn_yes, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Btn_yes, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(Btn_yes, 45, 25)
	GUI:setIgnoreContentAdaptWithSize(Btn_yes, false)
	GUI:Button_setTitleText(Btn_yes, "确定")
	GUI:Button_setTitleColor(Btn_yes, "#000000")
	GUI:Button_setTitleFontSize(Btn_yes, 14)
	GUI:Button_titleDisableOutLine(Btn_yes)
	GUI:setAnchorPoint(Btn_yes, 0.50, 0.50)
	GUI:setTouchEnabled(Btn_yes, true)
	GUI:setTag(Btn_yes, -1)

	-- Create Btn_no
	local Btn_no = GUI:Button_Create(Panel_tips, "Btn_no", 150.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Btn_no, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Btn_no, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(Btn_no, 45, 25)
	GUI:setIgnoreContentAdaptWithSize(Btn_no, false)
	GUI:Button_setTitleText(Btn_no, "取消")
	GUI:Button_setTitleColor(Btn_no, "#000000")
	GUI:Button_setTitleFontSize(Btn_no, 14)
	GUI:Button_titleDisableOutLine(Btn_no)
	GUI:setAnchorPoint(Btn_no, 0.50, 0.50)
	GUI:setTouchEnabled(Btn_no, true)
	GUI:setTag(Btn_no, -1)
end
return ui