local ui = {}
function ui.init(parent)
	-- Create Layer
	local Layer = GUI:Node_Create(parent, "Layer", 0.00, 0.00)
	GUI:setAnchorPoint(Layer, 0.50, 0.50)
	GUI:setTag(Layer, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Layer, "Panel_1", 0.00, 0.00, 936.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_1, 1)
	GUI:Layout_setBackGroundColor(Panel_1, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_1, 102)
	GUI:setTouchEnabled(Panel_1, false)
	GUI:setTag(Panel_1, 4)

	-- Create Image_search_bg
	local Image_search_bg = GUI:Image_Create(Panel_1, "Image_search_bg", 290.00, 598.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(Image_search_bg, 74, 72, 16, 10)
	GUI:setContentSize(Image_search_bg, 320, 40)
	GUI:setIgnoreContentAdaptWithSize(Image_search_bg, false)
	GUI:setAnchorPoint(Image_search_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_search_bg, false)
	GUI:setTag(Image_search_bg, -1)

	-- Create Input_search
	local Input_search = GUI:TextInput_Create(Image_search_bg, "Input_search", 160.00, 20.00, 320.00, 40.00, 25)
	GUI:TextInput_setString(Input_search, "")
	GUI:TextInput_setPlaceHolder(Input_search, "请输入要配置的字段名")
	GUI:TextInput_setFontColor(Input_search, "#ffffff")
	GUI:setAnchorPoint(Input_search, 0.50, 0.50)
	GUI:setTouchEnabled(Input_search, true)
	GUI:setTag(Input_search, -1)

	-- Create Button_search
	local Button_search = GUI:Button_Create(Image_search_bg, "Button_search", 330.00, 20.00, "res/private/gui_edit/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_search, "res/private/gui_edit/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_search, "res/private/gui_edit/Button_Disable.png")
	GUI:setContentSize(Button_search, 60, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_search, false)
	GUI:Button_setTitleText(Button_search, "搜 索")
	GUI:Button_setTitleColor(Button_search, "#0000ff")
	GUI:Button_setTitleFontSize(Button_search, 16)
	GUI:Button_titleDisableOutLine(Button_search)
	GUI:setAnchorPoint(Button_search, 0.00, 0.50)
	GUI:setTouchEnabled(Button_search, true)
	GUI:setTag(Button_search, -1)

	-- Create Layout_page
	local Layout_page = GUI:Layout_Create(Panel_1, "Layout_page", 5.00, 23.00, 150.00, 550.00, false)
	GUI:Layout_setBackGroundColorType(Layout_page, 1)
	GUI:Layout_setBackGroundColor(Layout_page, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_page, 127)
	GUI:setTouchEnabled(Layout_page, false)
	GUI:setTag(Layout_page, -1)

	-- Create ListView_page
	local ListView_page = GUI:ListView_Create(Layout_page, "ListView_page", 0.00, 50.00, 150.00, 500.00, 1)
	GUI:ListView_setGravity(ListView_page, 2)
	GUI:ListView_setItemsMargin(ListView_page, 2)
	GUI:setTouchEnabled(ListView_page, true)
	GUI:setTag(ListView_page, -1)

	-- Create Layout_items
	local Layout_items = GUI:Layout_Create(Panel_1, "Layout_items", 160.00, 23.00, 460.00, 550.00, false)
	GUI:Layout_setBackGroundColorType(Layout_items, 1)
	GUI:Layout_setBackGroundColor(Layout_items, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_items, 127)
	GUI:setTouchEnabled(Layout_items, false)
	GUI:setTag(Layout_items, -1)

	-- Create ListView_items
	local ListView_items = GUI:ListView_Create(Layout_items, "ListView_items", 0.00, 0.00, 460.00, 550.00, 1)
	GUI:ListView_setGravity(ListView_items, 2)
	GUI:ListView_setItemsMargin(ListView_items, 2)
	GUI:setTouchEnabled(ListView_items, true)
	GUI:setTag(ListView_items, -1)

	-- Create Layout_result
	local Layout_result = GUI:Layout_Create(Panel_1, "Layout_result", 625.00, 23.00, 305.00, 620.00, false)
	GUI:Layout_setBackGroundColorType(Layout_result, 1)
	GUI:Layout_setBackGroundColor(Layout_result, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_result, 124)
	GUI:setTouchEnabled(Layout_result, false)
	GUI:setTag(Layout_result, -1)

	-- Create Layout_desc
	local Layout_desc = GUI:Layout_Create(Layout_result, "Layout_desc", 153.00, 0.00, 300.00, 180.00, false)
	GUI:Layout_setBackGroundColorType(Layout_desc, 1)
	GUI:Layout_setBackGroundColor(Layout_desc, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_desc, 102)
	GUI:setAnchorPoint(Layout_desc, 0.50, 0.00)
	GUI:setTouchEnabled(Layout_desc, false)
	GUI:setTag(Layout_desc, -1)

	-- Create Image_desc
	local Image_desc = GUI:Image_Create(Layout_desc, "Image_desc", 150.00, 163.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(Image_desc, 74, 72, 16, 10)
	GUI:setContentSize(Image_desc, 100, 30)
	GUI:setIgnoreContentAdaptWithSize(Image_desc, false)
	GUI:setAnchorPoint(Image_desc, 0.50, 0.50)
	GUI:setTouchEnabled(Image_desc, false)
	GUI:setTag(Image_desc, -1)

	-- Create Text
	local Text = GUI:Text_Create(Image_desc, "Text", 50.00, 15.00, 16, "#ffffff", [[说明]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Node_desc_name
	local Node_desc_name = GUI:Node_Create(Layout_desc, "Node_desc_name", 7.00, 140.00)
	GUI:setTag(Node_desc_name, -1)

	-- Create Node_desc_content
	local Node_desc_content = GUI:Node_Create(Layout_desc, "Node_desc_content", 7.00, 90.00)
	GUI:setTag(Node_desc_content, -1)

	-- Create Layout_cur
	local Layout_cur = GUI:Layout_Create(Layout_result, "Layout_cur", 153.00, 596.00, 300.00, 412.00, false)
	GUI:Layout_setBackGroundColorType(Layout_cur, 1)
	GUI:Layout_setBackGroundColor(Layout_cur, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Layout_cur, 102)
	GUI:setAnchorPoint(Layout_cur, 0.50, 1.00)
	GUI:setTouchEnabled(Layout_cur, false)
	GUI:setTag(Layout_cur, -1)

	-- Create Image_cur
	local Image_cur = GUI:Image_Create(Layout_cur, "Image_cur", 150.00, 410.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(Image_cur, 74, 72, 16, 10)
	GUI:setContentSize(Image_cur, 100, 30)
	GUI:setIgnoreContentAdaptWithSize(Image_cur, false)
	GUI:setAnchorPoint(Image_cur, 0.50, 1.00)
	GUI:setTouchEnabled(Image_cur, false)
	GUI:setTag(Image_cur, -1)

	-- Create Text
	local Text = GUI:Text_Create(Image_cur, "Text", 50.00, 15.00, 16, "#ffffff", [[当前配置]])
	GUI:setAnchorPoint(Text, 0.50, 0.50)
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Node_ui_cur
	local Node_ui_cur = GUI:Node_Create(Layout_cur, "Node_ui_cur", 0.00, 0.00)
	GUI:setTag(Node_ui_cur, -1)

	-- Create Layout_line
	local Layout_line = GUI:Layout_Create(Layout_result, "Layout_line", 153.00, 181.00, 305.00, 1.00, false)
	GUI:Layout_setBackGroundColorType(Layout_line, 1)
	GUI:Layout_setBackGroundColor(Layout_line, "#ffffff")
	GUI:Layout_setBackGroundColorOpacity(Layout_line, 255)
	GUI:setAnchorPoint(Layout_line, 0.50, 0.00)
	GUI:setTouchEnabled(Layout_line, false)
	GUI:setTag(Layout_line, -1)
end
return ui