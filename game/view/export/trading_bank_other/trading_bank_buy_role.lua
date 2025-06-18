local ui = {}
function ui.init(parent)
	-- Create Node
	local Node = GUI:Node_Create(parent, "Node", 0.00, 0.00)
	GUI:setAnchorPoint(Node, 0.50, 0.50)
	GUI:setTag(Node, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Node, "Panel_1", 0.00, 0.00, 612.00, 368.00, false)
	GUI:Layout_setBackGroundColorType(Panel_1, 1)
	GUI:Layout_setBackGroundColor(Panel_1, "#181000")
	GUI:Layout_setBackGroundColorOpacity(Panel_1, 255)
	GUI:setTouchEnabled(Panel_1, true)
	GUI:setTag(Panel_1, 89)

	-- Create Panel_2
	local Panel_2 = GUI:Layout_Create(Panel_1, "Panel_2", 0.00, 339.00, 612.00, 28.00, false)
	GUI:setTouchEnabled(Panel_2, false)
	GUI:setTag(Panel_2, 90)

	-- Create Image_1_0
	local Image_1_0 = GUI:Image_Create(Panel_2, "Image_1_0", 0.00, 0.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:Image_setScale9Slice(Image_1_0, 75, 75, 0, 0)
	GUI:setContentSize(Image_1_0, 610, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_1_0, false)
	GUI:setAnchorPoint(Image_1_0, 0.00, 0.50)
	GUI:setTouchEnabled(Image_1_0, false)
	GUI:setTag(Image_1_0, 91)

	-- Create Image_7
	local Image_7 = GUI:Image_Create(Panel_2, "Image_7", 491.00, 14.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setContentSize(Image_7, 28, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_7, false)
	GUI:setAnchorPoint(Image_7, 0.50, 0.50)
	GUI:setRotation(Image_7, 90.00)
	GUI:setRotationSkewX(Image_7, 90.00)
	GUI:setRotationSkewY(Image_7, 90.00)
	GUI:setTouchEnabled(Image_7, false)
	GUI:setTag(Image_7, 92)

	-- Create Image_8
	local Image_8 = GUI:Image_Create(Panel_2, "Image_8", 400.00, 14.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setContentSize(Image_8, 28, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_8, false)
	GUI:setAnchorPoint(Image_8, 0.50, 0.50)
	GUI:setRotation(Image_8, 90.00)
	GUI:setRotationSkewX(Image_8, 90.00)
	GUI:setRotationSkewY(Image_8, 90.00)
	GUI:setTouchEnabled(Image_8, false)
	GUI:setTag(Image_8, 92)

	-- Create Image_9
	local Image_9 = GUI:Image_Create(Panel_2, "Image_9", 339.00, 14.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setContentSize(Image_9, 28, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_9, false)
	GUI:setAnchorPoint(Image_9, 0.50, 0.50)
	GUI:setRotation(Image_9, 90.00)
	GUI:setRotationSkewX(Image_9, 90.00)
	GUI:setRotationSkewY(Image_9, 90.00)
	GUI:setTouchEnabled(Image_9, false)
	GUI:setTag(Image_9, 92)

	-- Create Image_10
	local Image_10 = GUI:Image_Create(Panel_2, "Image_10", 276.00, 14.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setContentSize(Image_10, 28, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_10, false)
	GUI:setAnchorPoint(Image_10, 0.50, 0.50)
	GUI:setRotation(Image_10, 90.00)
	GUI:setRotationSkewX(Image_10, 90.00)
	GUI:setRotationSkewY(Image_10, 90.00)
	GUI:setTouchEnabled(Image_10, false)
	GUI:setTag(Image_10, 92)

	-- Create Image_11
	local Image_11 = GUI:Image_Create(Panel_2, "Image_11", 189.00, 14.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:setContentSize(Image_11, 28, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_11, false)
	GUI:setAnchorPoint(Image_11, 0.50, 0.50)
	GUI:setRotation(Image_11, 90.00)
	GUI:setRotationSkewX(Image_11, 90.00)
	GUI:setRotationSkewY(Image_11, 90.00)
	GUI:setTouchEnabled(Image_11, false)
	GUI:setTag(Image_11, 92)

	-- Create Text_roleName
	local Text_roleName = GUI:Text_Create(Panel_2, "Text_roleName", 98.00, 13.00, 14, "#ffffff", [[角色名称]])
	GUI:setAnchorPoint(Text_roleName, 0.50, 0.50)
	GUI:setTouchEnabled(Text_roleName, false)
	GUI:setTag(Text_roleName, 93)
	GUI:Text_enableOutline(Text_roleName, "#000000", 1)

	-- Create Panel_serverName
	local Panel_serverName = GUI:Layout_Create(Panel_2, "Panel_serverName", 190.00, 28.00, 84.00, 28.00, false)
	GUI:setAnchorPoint(Panel_serverName, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_serverName, true)
	GUI:setTag(Panel_serverName, 94)

	-- Create Layout_select_serverName1
	local Layout_select_serverName1 = GUI:Layout_Create(Panel_serverName, "Layout_select_serverName1", 0.00, 0.00, 65.00, 28.00, true)
	GUI:setTouchEnabled(Layout_select_serverName1, false)
	GUI:setTag(Layout_select_serverName1, -1)

	-- Create Text_serverName1
	local Text_serverName1 = GUI:Text_Create(Layout_select_serverName1, "Text_serverName1", 5.00, 13.00, 14, "#ffffff", [[区服名字]])
	GUI:setAnchorPoint(Text_serverName1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_serverName1, false)
	GUI:setTag(Text_serverName1, 95)
	GUI:Text_enableOutline(Text_serverName1, "#000000", 1)

	-- Create Image_8
	local Image_8 = GUI:Image_Create(Panel_serverName, "Image_8", 73.00, 12.00, "res/private/trading_bank/word_jiaoyh_017.png")
	GUI:setAnchorPoint(Image_8, 0.50, 0.50)
	GUI:setTouchEnabled(Image_8, false)
	GUI:setTag(Image_8, 96)

	-- Create Panel_job1
	local Panel_job1 = GUI:Layout_Create(Panel_2, "Panel_job1", 278.00, 28.00, 60.00, 28.00, false)
	GUI:setAnchorPoint(Panel_job1, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_job1, true)
	GUI:setTag(Panel_job1, 94)

	-- Create Text_job1
	local Text_job1 = GUI:Text_Create(Panel_job1, "Text_job1", 24.00, 13.00, 14, "#ffffff", [[职业]])
	GUI:setAnchorPoint(Text_job1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_job1, false)
	GUI:setTag(Text_job1, 95)
	GUI:Text_enableOutline(Text_job1, "#000000", 1)

	-- Create Image_8
	local Image_8 = GUI:Image_Create(Panel_job1, "Image_8", 51.00, 12.00, "res/private/trading_bank/word_jiaoyh_017.png")
	GUI:setAnchorPoint(Image_8, 0.50, 0.50)
	GUI:setTouchEnabled(Image_8, false)
	GUI:setTag(Image_8, 96)

	-- Create Panel_level1
	local Panel_level1 = GUI:Layout_Create(Panel_2, "Panel_level1", 340.00, 28.00, 58.00, 28.00, false)
	GUI:setAnchorPoint(Panel_level1, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_level1, true)
	GUI:setTag(Panel_level1, 107)

	-- Create Text_3_0
	local Text_3_0 = GUI:Text_Create(Panel_level1, "Text_3_0", 23.00, 12.00, 14, "#ffffff", [[等级]])
	GUI:setAnchorPoint(Text_3_0, 0.50, 0.50)
	GUI:setTouchEnabled(Text_3_0, false)
	GUI:setTag(Text_3_0, 108)
	GUI:Text_enableOutline(Text_3_0, "#000000", 1)

	-- Create Image_8
	local Image_8 = GUI:Image_Create(Panel_level1, "Image_8", 47.00, 12.00, "res/private/trading_bank/word_jiaoyh_016.png")
	GUI:setAnchorPoint(Image_8, 0.50, 0.50)
	GUI:setTouchEnabled(Image_8, false)
	GUI:setTag(Image_8, 109)

	-- Create Panel_price1
	local Panel_price1 = GUI:Layout_Create(Panel_2, "Panel_price1", 400.00, 28.00, 90.00, 28.00, false)
	GUI:setAnchorPoint(Panel_price1, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_price1, true)
	GUI:setTag(Panel_price1, 110)

	-- Create Text_3_0
	local Text_3_0 = GUI:Text_Create(Panel_price1, "Text_3_0", 39.00, 12.00, 14, "#ffffff", [[价格]])
	GUI:setAnchorPoint(Text_3_0, 0.50, 0.50)
	GUI:setTouchEnabled(Text_3_0, false)
	GUI:setTag(Text_3_0, 111)
	GUI:Text_enableOutline(Text_3_0, "#000000", 1)

	-- Create Image_8
	local Image_8 = GUI:Image_Create(Panel_price1, "Image_8", 69.00, 12.00, "res/private/trading_bank/word_jiaoyh_016.png")
	GUI:setAnchorPoint(Image_8, 0.50, 0.50)
	GUI:setTouchEnabled(Image_8, false)
	GUI:setTag(Image_8, 112)

	-- Create Text_3_0
	local Text_3_0 = GUI:Text_Create(Panel_2, "Text_3_0", 553.00, 13.00, 14, "#ffffff", [[操作]])
	GUI:setAnchorPoint(Text_3_0, 0.50, 0.50)
	GUI:setTouchEnabled(Text_3_0, false)
	GUI:setTag(Text_3_0, 113)
	GUI:Text_enableOutline(Text_3_0, "#000000", 1)

	-- Create Panel_item
	local Panel_item = GUI:Layout_Create(Panel_1, "Panel_item", 305.00, 193.00, 612.00, 85.00, false)
	GUI:setAnchorPoint(Panel_item, 0.50, 1.00)
	GUI:setTouchEnabled(Panel_item, true)
	GUI:setTag(Panel_item, 116)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_item, "Image_bg", 0.00, 1.00, "res/private/trading_bank/word_jiaoyh_019.png")
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, 117)

	-- Create Image_item
	local Image_item = GUI:Image_Create(Panel_item, "Image_item", 37.00, 42.00, "res/private/trading_bank/1900000651.png")
	GUI:setAnchorPoint(Image_item, 0.50, 0.50)
	GUI:setTouchEnabled(Image_item, false)
	GUI:setTag(Image_item, 118)

	-- Create Image_head
	local Image_head = GUI:Image_Create(Image_item, "Image_head", 30.00, 30.00, "res/private/trading_bank/img_011.png")
	GUI:setAnchorPoint(Image_head, 0.50, 0.50)
	GUI:setTouchEnabled(Image_head, false)
	GUI:setTag(Image_head, 201)

	-- Create Layout_show_serverName
	local Layout_show_serverName = GUI:Layout_Create(Panel_item, "Layout_show_serverName", 192.00, 1.00, 80.00, 80.00, true)
	GUI:setTouchEnabled(Layout_show_serverName, false)
	GUI:setTag(Layout_show_serverName, -1)

	-- Create Text_serverName
	local Text_serverName = GUI:Text_Create(Layout_show_serverName, "Text_serverName", 7.00, 42.00, 16, "#ffffff", [[区服名字]])
	GUI:setAnchorPoint(Text_serverName, 0.00, 0.50)
	GUI:setTouchEnabled(Text_serverName, false)
	GUI:setTag(Text_serverName, 119)
	GUI:Text_enableOutline(Text_serverName, "#000000", 1)

	-- Create Layout_show_Name
	local Layout_show_Name = GUI:Layout_Create(Panel_item, "Layout_show_Name", 71.00, 4.00, 120.00, 80.00, true)
	GUI:setTouchEnabled(Layout_show_Name, false)
	GUI:setTag(Layout_show_Name, -1)

	-- Create Text_name
	local Text_name = GUI:Text_Create(Layout_show_Name, "Text_name", 4.00, 38.00, 16, "#ffffff", [[名字七个字啊啊]])
	GUI:setAnchorPoint(Text_name, 0.00, 0.50)
	GUI:setTouchEnabled(Text_name, false)
	GUI:setTag(Text_name, 119)
	GUI:Text_enableOutline(Text_name, "#000000", 1)

	-- Create Text_job
	local Text_job = GUI:Text_Create(Panel_item, "Text_job", 307.00, 44.00, 16, "#ffffff", [[法师]])
	GUI:setAnchorPoint(Text_job, 0.50, 0.50)
	GUI:setTouchEnabled(Text_job, false)
	GUI:setTag(Text_job, 120)
	GUI:Text_enableOutline(Text_job, "#000000", 1)

	-- Create Text_level
	local Text_level = GUI:Text_Create(Panel_item, "Text_level", 369.00, 42.00, 16, "#ffffff", [[99]])
	GUI:setAnchorPoint(Text_level, 0.50, 0.50)
	GUI:setTouchEnabled(Text_level, false)
	GUI:setTag(Text_level, 121)
	GUI:Text_enableOutline(Text_level, "#000000", 1)

	-- Create Text_pirce
	local Text_pirce = GUI:Text_Create(Panel_item, "Text_pirce", 445.00, 41.00, 16, "#ffffff", [[9999]])
	GUI:setAnchorPoint(Text_pirce, 0.50, 0.50)
	GUI:setTouchEnabled(Text_pirce, false)
	GUI:setTag(Text_pirce, 122)
	GUI:Text_enableOutline(Text_pirce, "#000000", 1)

	-- Create Button_buy
	local Button_buy = GUI:Button_Create(Panel_item, "Button_buy", 552.00, 41.00, "res/private/trading_bank/btn_jiaoyh_01.png")
	GUI:Button_loadTexturePressed(Button_buy, "res/private/trading_bank/btn_jiaoyh_02.png")
	GUI:Button_loadTextureDisabled(Button_buy, "res/private/trading_bank/btn_jiaoyh_02.png")
	GUI:Button_setScale9Slice(Button_buy, 15, 15, 12, 10)
	GUI:setContentSize(Button_buy, 91, 33)
	GUI:setIgnoreContentAdaptWithSize(Button_buy, false)
	GUI:Button_setTitleText(Button_buy, "购买")
	GUI:Button_setTitleColor(Button_buy, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_buy, 16)
	GUI:Button_titleEnableOutline(Button_buy, "#000000", 1)
	GUI:setAnchorPoint(Button_buy, 0.50, 0.50)
	GUI:setTouchEnabled(Button_buy, true)
	GUI:setTag(Button_buy, 123)

	-- Create ListView_2
	local ListView_2 = GUI:ListView_Create(Panel_1, "ListView_2", 307.00, 337.00, 612.00, 320.00, 1)
	GUI:ListView_setGravity(ListView_2, 5)
	GUI:setAnchorPoint(ListView_2, 0.50, 1.00)
	GUI:setTouchEnabled(ListView_2, true)
	GUI:setTag(ListView_2, 115)
end
return ui