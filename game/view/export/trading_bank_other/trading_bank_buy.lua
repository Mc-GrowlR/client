local ui = {}
function ui.init(parent)
	-- Create Node
	local Node = GUI:Node_Create(parent, "Node", 0.00, 0.00)
	GUI:setAnchorPoint(Node, 0.50, 0.50)
	GUI:setTag(Node, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Node, "Panel_1", 0.00, 0.00, 731.00, 445.00, false)
	GUI:setTouchEnabled(Panel_1, true)
	GUI:setTag(Panel_1, 12)
	GUI:setVisible(Panel_1, false)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Panel_1, "Image_1", 1.00, 0.00, "res/private/trading_bank/word_jiaoyh_018.jpg")
	GUI:Image_setScale9Slice(Image_1, 75, 75, 0, 0)
	GUI:setContentSize(Image_1, 729, 445)
	GUI:setIgnoreContentAdaptWithSize(Image_1, false)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 6)

	-- Create ListView_1
	local ListView_1 = GUI:ListView_Create(Panel_1, "ListView_1", 60.00, 441.00, 120.00, 441.00, 1)
	GUI:ListView_setGravity(ListView_1, 5)
	GUI:ListView_setItemsMargin(ListView_1, 4)
	GUI:setAnchorPoint(ListView_1, 0.50, 1.00)
	GUI:setTouchEnabled(ListView_1, true)
	GUI:setTag(ListView_1, 3)

	-- Create Button_1
	local Button_1 = GUI:Button_Create(Panel_1, "Button_1", -394.00, -324.00, "res/private/trading_bank/1900000662.png")
	GUI:Button_loadTexturePressed(Button_1, "res/private/trading_bank/1900000663.png")
	GUI:Button_loadTextureDisabled(Button_1, "res/private/trading_bank/1900000663.png")
	GUI:Button_setScale9Slice(Button_1, 15, 15, 11, 11)
	GUI:setContentSize(Button_1, 115, 37)
	GUI:setIgnoreContentAdaptWithSize(Button_1, false)
	GUI:Button_setTitleText(Button_1, "角色")
	GUI:Button_setTitleColor(Button_1, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_1, 20)
	GUI:Button_titleEnableOutline(Button_1, "#000000", 1)
	GUI:setAnchorPoint(Button_1, 0.50, 0.50)
	GUI:setTouchEnabled(Button_1, true)
	GUI:setTag(Button_1, 4)

	-- Create Node_1
	local Node_1 = GUI:Node_Create(Panel_1, "Node_1", 121.00, 76.00)
	GUI:setAnchorPoint(Node_1, 0.50, 0.50)
	GUI:setTag(Node_1, 240)

	-- Create Image_bottom
	local Image_bottom = GUI:Image_Create(Panel_1, "Image_bottom", 123.00, 0.00, "res/private/trading_bank/img_66.jpg")
	GUI:setContentSize(Image_bottom, 607, 92)
	GUI:setIgnoreContentAdaptWithSize(Image_bottom, false)
	GUI:setTouchEnabled(Image_bottom, false)
	GUI:setTag(Image_bottom, 202)

	-- Create Image_17
	local Image_17 = GUI:Image_Create(Image_bottom, "Image_17", 0.00, 90.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setContentSize(Image_17, 606.5, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_17, false)
	GUI:setAnchorPoint(Image_17, 0.00, 0.50)
	GUI:setTouchEnabled(Image_17, false)
	GUI:setTag(Image_17, 203)

	-- Create Image_input
	local Image_input = GUI:Image_Create(Image_bottom, "Image_input", 14.00, 26.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_input, 8, 8, 10, 10)
	GUI:setContentSize(Image_input, 140, 28)
	GUI:setIgnoreContentAdaptWithSize(Image_input, false)
	GUI:setAnchorPoint(Image_input, 0.00, 0.50)
	GUI:setTouchEnabled(Image_input, false)
	GUI:setTag(Image_input, 199)

	-- Create TextField_1
	local TextField_1 = GUI:TextInput_Create(Image_input, "TextField_1", 70.00, 14.00, 140.00, 28.00, 14)
	GUI:TextInput_setString(TextField_1, "")
	GUI:TextInput_setPlaceHolder(TextField_1, "角色名称")
	GUI:TextInput_setFontColor(TextField_1, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_1, 7)
	GUI:setAnchorPoint(TextField_1, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_1, true)
	GUI:setTag(TextField_1, 201)

	-- Create Button_search
	local Button_search = GUI:Button_Create(Image_bottom, "Button_search", 199.00, 26.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_search, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_search, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_search, 15, 15, 11, 11)
	GUI:setContentSize(Button_search, 90, 35)
	GUI:setIgnoreContentAdaptWithSize(Button_search, false)
	GUI:Button_setTitleText(Button_search, "搜索")
	GUI:Button_setTitleColor(Button_search, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_search, 18)
	GUI:Button_titleEnableOutline(Button_search, "#000000", 1)
	GUI:setAnchorPoint(Button_search, 0.50, 0.50)
	GUI:setScaleX(Button_search, 0.90)
	GUI:setScaleY(Button_search, 0.90)
	GUI:setTouchEnabled(Button_search, true)
	GUI:setTag(Button_search, 219)

	-- Create Text_tip
	local Text_tip = GUI:Text_Create(Image_bottom, "Text_tip", 14.00, 62.00, 14, "#f8e6c6", [[购买后角色会直接发放至角色选择栏]])
	GUI:setAnchorPoint(Text_tip, 0.00, 0.50)
	GUI:setTouchEnabled(Text_tip, false)
	GUI:setTag(Text_tip, 84)
	GUI:Text_enableOutline(Text_tip, "#000000", 1)

	-- Create Text_tip2
	local Text_tip2 = GUI:Text_Create(Image_bottom, "Text_tip2", 14.00, 28.00, 14, "#f8e6c6", [[购买后的货币直接发放至背包]])
	GUI:setAnchorPoint(Text_tip2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_tip2, false)
	GUI:setTag(Text_tip2, 84)
	GUI:Text_enableOutline(Text_tip2, "#000000", 1)

	-- Create Text_label
	local Text_label = GUI:Text_Create(Image_bottom, "Text_label", 255.00, 63.00, 14, "#f8e6c6", [[交易记录]])
	GUI:setAnchorPoint(Text_label, 0.00, 0.50)
	GUI:setTouchEnabled(Text_label, false)
	GUI:setTag(Text_label, 84)
	GUI:Text_enableOutline(Text_label, "#000000", 1)

	-- Create Layout_bg
	local Layout_bg = GUI:Layout_Create(Image_bottom, "Layout_bg", 255.00, 15.00, 340.00, 25.00, true)
	GUI:Layout_setBackGroundColorType(Layout_bg, 1)
	GUI:Layout_setBackGroundColor(Layout_bg, "#efd6ad")
	GUI:Layout_setBackGroundColorOpacity(Layout_bg, 255)
	GUI:setTouchEnabled(Layout_bg, false)
	GUI:setTag(Layout_bg, -1)

	-- Create Button_request
	local Button_request = GUI:Button_Create(Image_bottom, "Button_request", 86.00, 42.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_request, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_request, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_request, 0, 0, 0, 0)
	GUI:setContentSize(Button_request, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_request, false)
	GUI:Button_setTitleText(Button_request, "发布求购")
	GUI:Button_setTitleColor(Button_request, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_request, 14)
	GUI:Button_titleEnableOutline(Button_request, "#000000", 1)
	GUI:setAnchorPoint(Button_request, 0.50, 0.50)
	GUI:setTouchEnabled(Button_request, true)
	GUI:setTag(Button_request, 219)

	-- Create Panel_requestBug
	local Panel_requestBug = GUI:Layout_Create(Node, "Panel_requestBug", 0.00, 0.00, 731.00, 445.00, false)
	GUI:setTouchEnabled(Panel_requestBug, false)
	GUI:setTag(Panel_requestBug, -1)

	-- Create Text_requestBugLabel
	local Text_requestBugLabel = GUI:Text_Create(Panel_requestBug, "Text_requestBugLabel", 17.00, 414.00, 18, "#f8e6c6", [[求购]])
	GUI:setAnchorPoint(Text_requestBugLabel, 0.00, 0.50)
	GUI:setTouchEnabled(Text_requestBugLabel, false)
	GUI:setTag(Text_requestBugLabel, 84)
	GUI:Text_enableOutline(Text_requestBugLabel, "#000000", 1)

	-- Create Text_jobLabel_b
	local Text_jobLabel_b = GUI:Text_Create(Panel_requestBug, "Text_jobLabel_b", 240.00, 328.00, 18, "#f8e6c6", [[职业：]])
	GUI:setAnchorPoint(Text_jobLabel_b, 1.00, 0.50)
	GUI:setTouchEnabled(Text_jobLabel_b, false)
	GUI:setTag(Text_jobLabel_b, 84)
	GUI:Text_enableOutline(Text_jobLabel_b, "#000000", 1)

	-- Create Text_levelLabel_b
	local Text_levelLabel_b = GUI:Text_Create(Panel_requestBug, "Text_levelLabel_b", 240.00, 267.00, 18, "#f8e6c6", [[等级：]])
	GUI:setAnchorPoint(Text_levelLabel_b, 1.00, 0.50)
	GUI:setTouchEnabled(Text_levelLabel_b, false)
	GUI:setTag(Text_levelLabel_b, 84)
	GUI:Text_enableOutline(Text_levelLabel_b, "#000000", 1)

	-- Create Text_priceLabel_b
	local Text_priceLabel_b = GUI:Text_Create(Panel_requestBug, "Text_priceLabel_b", 240.00, 204.00, 18, "#f8e6c6", [[求购金额(元)：]])
	GUI:setAnchorPoint(Text_priceLabel_b, 1.00, 0.50)
	GUI:setTouchEnabled(Text_priceLabel_b, false)
	GUI:setTag(Text_priceLabel_b, 84)
	GUI:Text_enableOutline(Text_priceLabel_b, "#000000", 1)

	-- Create Button_request_b
	local Button_request_b = GUI:Button_Create(Panel_requestBug, "Button_request_b", 342.00, 81.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_request_b, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_request_b, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_request_b, 0, 0, 0, 0)
	GUI:setContentSize(Button_request_b, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_request_b, false)
	GUI:Button_setTitleText(Button_request_b, "发布求购")
	GUI:Button_setTitleColor(Button_request_b, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_request_b, 14)
	GUI:Button_titleEnableOutline(Button_request_b, "#000000", 1)
	GUI:setAnchorPoint(Button_request_b, 0.50, 0.50)
	GUI:setTouchEnabled(Button_request_b, true)
	GUI:setTag(Button_request_b, 219)

	-- Create ImageView_job_b
	local ImageView_job_b = GUI:Image_Create(Panel_requestBug, "ImageView_job_b", 260.00, 328.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(ImageView_job_b, 8, 9, 8, 8)
	GUI:setContentSize(ImageView_job_b, 200, 30)
	GUI:setIgnoreContentAdaptWithSize(ImageView_job_b, false)
	GUI:setAnchorPoint(ImageView_job_b, 0.00, 0.50)
	GUI:setTouchEnabled(ImageView_job_b, false)
	GUI:setTag(ImageView_job_b, -1)

	-- Create Text_job_b
	local Text_job_b = GUI:Text_Create(ImageView_job_b, "Text_job_b", 100.00, 5.00, 16, "#ffffff", [[全部]])
	GUI:setAnchorPoint(Text_job_b, 0.50, 0.00)
	GUI:setTouchEnabled(Text_job_b, false)
	GUI:setTag(Text_job_b, -1)
	GUI:Text_enableOutline(Text_job_b, "#000000", 1)

	-- Create ImageView
	local ImageView = GUI:Image_Create(ImageView_job_b, "ImageView", 177.00, 10.00, "res/private/trading_bank/word_jiaoyh_017.png")
	GUI:setTouchEnabled(ImageView, false)
	GUI:setTag(ImageView, -1)

	-- Create ImageView_price_b
	local ImageView_price_b = GUI:Image_Create(Panel_requestBug, "ImageView_price_b", 260.00, 204.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(ImageView_price_b, 8, 8, 8, 8)
	GUI:setContentSize(ImageView_price_b, 200, 30)
	GUI:setIgnoreContentAdaptWithSize(ImageView_price_b, false)
	GUI:setAnchorPoint(ImageView_price_b, 0.00, 0.50)
	GUI:setTouchEnabled(ImageView_price_b, false)
	GUI:setTag(ImageView_price_b, -1)

	-- Create Text_price_b
	local Text_price_b = GUI:Text_Create(ImageView_price_b, "Text_price_b", 100.00, 5.00, 16, "#ffffff", [[0-200]])
	GUI:setAnchorPoint(Text_price_b, 0.50, 0.00)
	GUI:setTouchEnabled(Text_price_b, false)
	GUI:setTag(Text_price_b, -1)
	GUI:Text_enableOutline(Text_price_b, "#000000", 1)

	-- Create ImageView
	local ImageView = GUI:Image_Create(ImageView_price_b, "ImageView", 177.00, 10.00, "res/private/trading_bank/word_jiaoyh_017.png")
	GUI:setTouchEnabled(ImageView, false)
	GUI:setTag(ImageView, -1)

	-- Create Panel_Level
	local Panel_Level = GUI:Layout_Create(Panel_requestBug, "Panel_Level", 260.00, 267.00, 200.00, 40.00, false)
	GUI:setAnchorPoint(Panel_Level, 0.00, 0.50)
	GUI:setTouchEnabled(Panel_Level, false)
	GUI:setTag(Panel_Level, -1)

	-- Create ImageView1
	local ImageView1 = GUI:Image_Create(Panel_Level, "ImageView1", 1.00, 19.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(ImageView1, 8, 9, 8, 8)
	GUI:setContentSize(ImageView1, 70, 30)
	GUI:setIgnoreContentAdaptWithSize(ImageView1, false)
	GUI:setAnchorPoint(ImageView1, 0.00, 0.50)
	GUI:setTouchEnabled(ImageView1, false)
	GUI:setTag(ImageView1, -1)

	-- Create Input_level1
	local Input_level1 = GUI:TextInput_Create(ImageView1, "Input_level1", 0.00, 0.00, 68.00, 28.00, 16)
	GUI:TextInput_setString(Input_level1, "")
	GUI:TextInput_setPlaceHolder(Input_level1, "最低")
	GUI:TextInput_setFontColor(Input_level1, "#ffffff")
	GUI:TextInput_setMaxLength(Input_level1, 5)
	GUI:setTouchEnabled(Input_level1, true)
	GUI:setTag(Input_level1, -1)

	-- Create ImageView2
	local ImageView2 = GUI:Image_Create(Panel_Level, "ImageView2", 75.00, 19.00, "res/private/gui_edit/LoadingBar.png")
	GUI:Image_setScale9Slice(ImageView2, 67, 66, 5, 4)
	GUI:setContentSize(ImageView2, 50, 2)
	GUI:setIgnoreContentAdaptWithSize(ImageView2, false)
	GUI:setAnchorPoint(ImageView2, 0.00, 0.50)
	GUI:setTouchEnabled(ImageView2, false)
	GUI:setTag(ImageView2, -1)

	-- Create ImageView3
	local ImageView3 = GUI:Image_Create(Panel_Level, "ImageView3", 128.00, 19.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(ImageView3, 8, 8, 8, 8)
	GUI:setContentSize(ImageView3, 70, 30)
	GUI:setIgnoreContentAdaptWithSize(ImageView3, false)
	GUI:setAnchorPoint(ImageView3, 0.00, 0.50)
	GUI:setTouchEnabled(ImageView3, false)
	GUI:setTag(ImageView3, -1)

	-- Create Input_level2
	local Input_level2 = GUI:TextInput_Create(ImageView3, "Input_level2", 0.00, 0.00, 68.00, 28.00, 16)
	GUI:TextInput_setString(Input_level2, "")
	GUI:TextInput_setPlaceHolder(Input_level2, "最高")
	GUI:TextInput_setFontColor(Input_level2, "#ffffff")
	GUI:TextInput_setMaxLength(Input_level2, 5)
	GUI:setTouchEnabled(Input_level2, true)
	GUI:setTag(Input_level2, -1)
end
return ui