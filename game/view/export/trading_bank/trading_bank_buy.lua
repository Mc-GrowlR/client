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

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Panel_1, "Image_1", 1.00, 0.00, "res/private/trading_bank/word_jiaoyh_018.jpg")
	GUI:Image_setScale9Slice(Image_1, 75, 75, 0, 0)
	GUI:setContentSize(Image_1, 729, 445)
	GUI:setIgnoreContentAdaptWithSize(Image_1, false)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 6)

	-- Create ListView_type
	local ListView_type = GUI:ListView_Create(Panel_1, "ListView_type", 60.00, 441.00, 120.00, 441.00, 1)
	GUI:ListView_setGravity(ListView_type, 2)
	GUI:ListView_setItemsMargin(ListView_type, 4)
	GUI:setAnchorPoint(ListView_type, 0.50, 1.00)
	GUI:setTouchEnabled(ListView_type, true)
	GUI:setTag(ListView_type, 3)

	-- Create Button_Type1
	local Button_Type1 = GUI:Button_Create(Panel_1, "Button_Type1", 0.00, 0.00, "res/private/trading_bank/1900000663.png")
	GUI:Button_loadTexturePressed(Button_Type1, "res/private/trading_bank/1900000662.png")
	GUI:Button_loadTextureDisabled(Button_Type1, "res/private/trading_bank/1900000662.png")
	GUI:Button_setTitleText(Button_Type1, "角色")
	GUI:Button_setTitleColor(Button_Type1, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_Type1, 16)
	GUI:Button_titleEnableOutline(Button_Type1, "#000000", 1)
	GUI:setAnchorPoint(Button_Type1, 0.50, 0.50)
	GUI:setTouchEnabled(Button_Type1, true)
	GUI:setTag(Button_Type1, 4)

	-- Create Button_Type2
	local Button_Type2 = GUI:Button_Create(Panel_1, "Button_Type2", 0.00, 39.00, "res/private/trading_bank/btn_type2_2.png")
	GUI:Button_loadTexturePressed(Button_Type2, "res/private/trading_bank/btn_type2.png")
	GUI:Button_loadTextureDisabled(Button_Type2, "res/private/trading_bank/btn_type2.png")
	GUI:Button_setTitleText(Button_Type2, "全部")
	GUI:Button_setTitleColor(Button_Type2, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_Type2, 15)
	GUI:Button_titleEnableOutline(Button_Type2, "#000000", 1)
	GUI:setAnchorPoint(Button_Type2, 0.50, 0.50)
	GUI:setTouchEnabled(Button_Type2, true)
	GUI:setTag(Button_Type2, 4)

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

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Image_bottom, "Image_1", 250.00, 26.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_1, 8, 8, 10, 10)
	GUI:setContentSize(Image_1, 288, 28)
	GUI:setIgnoreContentAdaptWithSize(Image_1, false)
	GUI:setAnchorPoint(Image_1, 0.50, 0.50)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 199)

	-- Create TextField_search
	local TextField_search = GUI:TextInput_Create(Image_1, "TextField_search", 144.00, 14.00, 288.00, 28.00, 18)
	GUI:TextInput_setString(TextField_search, "")
	GUI:TextInput_setPlaceHolder(TextField_search, "角色名称")
	GUI:TextInput_setFontColor(TextField_search, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_search, 13)
	GUI:setAnchorPoint(TextField_search, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_search, true)
	GUI:setTag(TextField_search, 201)

	-- Create Button_search
	local Button_search = GUI:Button_Create(Image_bottom, "Button_search", 476.00, 26.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_search, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_search, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_search, 15, 15, 11, 11)
	GUI:setContentSize(Button_search, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_search, false)
	GUI:Button_setTitleText(Button_search, "搜索")
	GUI:Button_setTitleColor(Button_search, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_search, 24)
	GUI:Button_titleEnableOutline(Button_search, "#000000", 1)
	GUI:setAnchorPoint(Button_search, 0.50, 0.50)
	GUI:setScaleX(Button_search, 0.90)
	GUI:setScaleY(Button_search, 0.90)
	GUI:setTouchEnabled(Button_search, true)
	GUI:setTag(Button_search, 219)

	-- Create Text_tip
	local Text_tip = GUI:Text_Create(Panel_1, "Text_tip", 420.00, 68.00, 20, "#f8e6c6", [[购买后角色会直接出现在角色栏]])
	GUI:setAnchorPoint(Text_tip, 0.50, 0.50)
	GUI:setTouchEnabled(Text_tip, false)
	GUI:setTag(Text_tip, 84)
	GUI:Text_enableOutline(Text_tip, "#000000", 1)
end
return ui