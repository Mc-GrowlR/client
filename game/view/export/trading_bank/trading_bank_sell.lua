local ui = {}
function ui.init(parent)
	-- Create Node
	local Node = GUI:Node_Create(parent, "Node", 0.00, 0.00)
	GUI:setAnchorPoint(Node, 0.50, 0.50)
	GUI:setTag(Node, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Node, "Panel_1", 0.00, 0.00, 732.00, 445.00, false)
	GUI:setTouchEnabled(Panel_1, true)
	GUI:setTag(Panel_1, 12)

	-- Create Panel_role
	local Panel_role = GUI:Layout_Create(Panel_1, "Panel_role", 0.00, 22.00, 732.00, 382.00, false)
	GUI:setTouchEnabled(Panel_role, false)
	GUI:setTag(Panel_role, 180)
	GUI:setVisible(Panel_role, false)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_role, "Text_1", 66.00, 316.00, 20, "#f8e6c6", [[寄 售 角 色:]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 182)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Text_roleName
	local Text_roleName = GUI:Text_Create(Panel_role, "Text_roleName", 176.00, 316.00, 20, "#ffffff", [[当前角色 ]])
	GUI:setAnchorPoint(Text_roleName, 0.00, 0.50)
	GUI:setTouchEnabled(Text_roleName, false)
	GUI:setTag(Text_roleName, 183)
	GUI:Text_enableOutline(Text_roleName, "#000000", 1)

	-- Create Text_3
	local Text_3 = GUI:Text_Create(Panel_role, "Text_3", 66.00, 224.00, 20, "#f8e6c6", [[出 售 总 价:]])
	GUI:setAnchorPoint(Text_3, 0.00, 0.50)
	GUI:setTouchEnabled(Text_3, false)
	GUI:setTag(Text_3, 184)
	GUI:Text_enableOutline(Text_3, "#000000", 1)

	-- Create Text_sxf1
	local Text_sxf1 = GUI:Text_Create(Panel_role, "Text_sxf1", 175.00, 195.00, 16, "#ff0000", [[手续费10%]])
	GUI:setAnchorPoint(Text_sxf1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_sxf1, false)
	GUI:setTag(Text_sxf1, 188)
	GUI:Text_enableOutline(Text_sxf1, "#000000", 1)

	-- Create Text_5
	local Text_5 = GUI:Text_Create(Panel_role, "Text_5", 59.00, 220.00, 22, "#ff0000", [[*]])
	GUI:setAnchorPoint(Text_5, 0.50, 0.50)
	GUI:setTouchEnabled(Text_5, false)
	GUI:setTag(Text_5, 189)
	GUI:Text_enableOutline(Text_5, "#000000", 1)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Panel_role, "Image_1", 284.00, 225.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_1, 8, 8, 10, 10)
	GUI:setContentSize(Image_1, 220, 34)
	GUI:setIgnoreContentAdaptWithSize(Image_1, false)
	GUI:setAnchorPoint(Image_1, 0.50, 0.50)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 186)

	-- Create Text_min_price_role
	local Text_min_price_role = GUI:Text_Create(Image_1, "Text_min_price_role", 227.00, 16.00, 16, "#ffffff", [[最低售价]])
	GUI:setAnchorPoint(Text_min_price_role, 0.00, 0.50)
	GUI:setTouchEnabled(Text_min_price_role, false)
	GUI:setTag(Text_min_price_role, 124)
	GUI:Text_enableOutline(Text_min_price_role, "#000000", 1)

	-- Create TextField_role_price
	local TextField_role_price = GUI:TextInput_Create(Image_1, "TextField_role_price", 110.00, 17.00, 220.00, 34.00, 20)
	GUI:TextInput_setString(TextField_role_price, "")
	GUI:TextInput_setFontColor(TextField_role_price, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_role_price, 13)
	GUI:setAnchorPoint(TextField_role_price, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_role_price, true)
	GUI:setTag(TextField_role_price, 185)

	-- Create Text_most3_0
	local Text_most3_0 = GUI:Text_Create(Panel_role, "Text_most3_0", 177.00, 290.00, 16, "#ff0000", [[寄售后的角色将无法登录]])
	GUI:setAnchorPoint(Text_most3_0, 0.00, 0.50)
	GUI:setTouchEnabled(Text_most3_0, false)
	GUI:setTag(Text_most3_0, 106)
	GUI:Text_enableOutline(Text_most3_0, "#000000", 1)

	-- Create Text_bargain_role
	local Text_bargain_role = GUI:Text_Create(Panel_role, "Text_bargain_role", 66.00, 137.00, 19, "#f8e6c6", [[买家是否可以还价:]])
	GUI:setTouchEnabled(Text_bargain_role, false)
	GUI:setTag(Text_bargain_role, -1)
	GUI:Text_enableOutline(Text_bargain_role, "#000000", 1)

	-- Create Panel_bargain_role
	local Panel_bargain_role = GUI:Layout_Create(Panel_role, "Panel_bargain_role", 233.00, 135.00, 150.00, 30.00, false)
	GUI:setTouchEnabled(Panel_bargain_role, true)
	GUI:setTag(Panel_bargain_role, -1)

	-- Create Text
	local Text = GUI:Text_Create(Panel_bargain_role, "Text", 114.00, 3.00, 20, "#f8e6c6", [[否]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_bargain_role, "Text_1", 42.00, 3.00, 20, "#f8e6c6", [[是]])
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create CheckBox_true
	local CheckBox_true = GUI:CheckBox_Create(Panel_bargain_role, "CheckBox_true", 24.00, 14.00, "res/private/trading_bank/word_jiaoyh_022.png", "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:CheckBox_setSelected(CheckBox_true, false)
	GUI:setAnchorPoint(CheckBox_true, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox_true, true)
	GUI:setTag(CheckBox_true, 175)

	-- Create CheckBox_false
	local CheckBox_false = GUI:CheckBox_Create(Panel_bargain_role, "CheckBox_false", 94.00, 14.00, "res/private/trading_bank/word_jiaoyh_022.png", "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:CheckBox_setSelected(CheckBox_false, false)
	GUI:setAnchorPoint(CheckBox_false, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox_false, true)
	GUI:setTag(CheckBox_false, 175)

	-- Create Text_6
	local Text_6 = GUI:Text_Create(Panel_role, "Text_6", 66.00, 96.00, 19, "#f8e6c6", [[指定购买人:]])
	GUI:setAnchorPoint(Text_6, 0.00, 0.50)
	GUI:setTouchEnabled(Text_6, false)
	GUI:setTag(Text_6, 125)
	GUI:Text_enableOutline(Text_6, "#000000", 1)

	-- Create Text_8
	local Text_8 = GUI:Text_Create(Panel_role, "Text_8", 174.00, 76.00, 16, "#ffffff", [[如需指定售卖，需输入对方的游戏账号，输入前请多次确认，一旦售出
概不负责。]])
	GUI:setAnchorPoint(Text_8, 0.00, 1.00)
	GUI:setTouchEnabled(Text_8, false)
	GUI:setTag(Text_8, 127)
	GUI:Text_enableOutline(Text_8, "#000000", 1)

	-- Create Image_target_role
	local Image_target_role = GUI:Image_Create(Panel_role, "Image_target_role", 284.00, 95.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_target_role, 8, 8, 10, 10)
	GUI:setContentSize(Image_target_role, 220, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_target_role, false)
	GUI:setAnchorPoint(Image_target_role, 0.50, 0.50)
	GUI:setTouchEnabled(Image_target_role, false)
	GUI:setTag(Image_target_role, 134)

	-- Create TextField_target_role
	local TextField_target_role = GUI:TextInput_Create(Image_target_role, "TextField_target_role", 110.00, 16.00, 220.00, 32.00, 20)
	GUI:TextInput_setString(TextField_target_role, "")
	GUI:TextInput_setFontColor(TextField_target_role, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_target_role, 32)
	GUI:setAnchorPoint(TextField_target_role, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_target_role, true)
	GUI:setTag(TextField_target_role, -1)

	-- Create target_role_mask
	local target_role_mask = GUI:Layout_Create(Image_target_role, "target_role_mask", -1.00, 0.00, 220.00, 32.00, false)
	GUI:setTouchEnabled(target_role_mask, true)
	GUI:setTag(target_role_mask, 92)

	-- Create Panel_money
	local Panel_money = GUI:Layout_Create(Panel_1, "Panel_money", 0.00, 0.00, 732.00, 382.00, false)
	GUI:setTouchEnabled(Panel_money, false)
	GUI:setTag(Panel_money, 119)
	GUI:setVisible(Panel_money, false)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_money, "Text_1", 66.00, 362.00, 20, "#f8e6c6", [[货 币 种 类:]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 120)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Panel_money, "Text_2", 66.00, 303.00, 20, "#f8e6c6", [[出 售 数 量:]])
	GUI:setAnchorPoint(Text_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, 142)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create Text_3
	local Text_3 = GUI:Text_Create(Panel_money, "Text_3", 66.00, 228.00, 20, "#f8e6c6", [[出 售 总 价:]])
	GUI:setAnchorPoint(Text_3, 0.00, 0.50)
	GUI:setTouchEnabled(Text_3, false)
	GUI:setTag(Text_3, 122)
	GUI:Text_enableOutline(Text_3, "#000000", 1)

	-- Create Text_sxf2
	local Text_sxf2 = GUI:Text_Create(Panel_money, "Text_sxf2", 174.00, 199.00, 16, "#ff0000", [[手续费10%]])
	GUI:setAnchorPoint(Text_sxf2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_sxf2, false)
	GUI:setTag(Text_sxf2, 123)
	GUI:Text_enableOutline(Text_sxf2, "#000000", 1)

	-- Create Text_5
	local Text_5 = GUI:Text_Create(Panel_money, "Text_5", 59.00, 224.00, 22, "#ff0000", [[*]])
	GUI:setAnchorPoint(Text_5, 0.50, 0.50)
	GUI:setTouchEnabled(Text_5, false)
	GUI:setTag(Text_5, 124)
	GUI:Text_enableOutline(Text_5, "#000000", 1)

	-- Create Text_13
	local Text_13 = GUI:Text_Create(Panel_money, "Text_13", 59.00, 298.00, 22, "#ff0000", [[*]])
	GUI:setAnchorPoint(Text_13, 0.50, 0.50)
	GUI:setTouchEnabled(Text_13, false)
	GUI:setTag(Text_13, 145)
	GUI:Text_enableOutline(Text_13, "#000000", 1)

	-- Create Image_0
	local Image_0 = GUI:Image_Create(Panel_money, "Image_0", 284.00, 304.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_0, 8, 8, 10, 10)
	GUI:setContentSize(Image_0, 220, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_0, false)
	GUI:setAnchorPoint(Image_0, 0.50, 0.50)
	GUI:setTouchEnabled(Image_0, false)
	GUI:setTag(Image_0, 143)

	-- Create TextField_money_count
	local TextField_money_count = GUI:TextInput_Create(Image_0, "TextField_money_count", 110.00, 16.00, 220.00, 32.00, 20)
	GUI:TextInput_setString(TextField_money_count, "")
	GUI:TextInput_setFontColor(TextField_money_count, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_money_count, 13)
	GUI:setAnchorPoint(TextField_money_count, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_money_count, true)
	GUI:setTag(TextField_money_count, 144)

	-- Create money_count_mask
	local money_count_mask = GUI:Layout_Create(Image_0, "money_count_mask", 0.00, 0.00, 220.00, 32.00, false)
	GUI:setTouchEnabled(money_count_mask, true)
	GUI:setTag(money_count_mask, 90)

	-- Create Text_min_count_money
	local Text_min_count_money = GUI:Text_Create(Image_0, "Text_min_count_money", 1.00, -12.00, 16, "#ffffff", [[最低出售数量]])
	GUI:setAnchorPoint(Text_min_count_money, 0.00, 0.50)
	GUI:setTouchEnabled(Text_min_count_money, false)
	GUI:setTag(Text_min_count_money, 54)
	GUI:Text_enableOutline(Text_min_count_money, "#000000", 1)

	-- Create Text_min_price_money
	local Text_min_price_money = GUI:Text_Create(Image_0, "Text_min_price_money", 227.00, 16.00, 16, "#ffffff", [[最低售价:]])
	GUI:setAnchorPoint(Text_min_price_money, 0.00, 0.50)
	GUI:setTouchEnabled(Text_min_price_money, false)
	GUI:setTag(Text_min_price_money, 271)
	GUI:Text_enableOutline(Text_min_price_money, "#000000", 1)

	-- Create ScrollView_money
	local ScrollView_money = GUI:ScrollView_Create(Panel_money, "ScrollView_money", 170.00, 383.00, 500.00, 60.00, 1)
	GUI:ScrollView_setBounceEnabled(ScrollView_money, true)
	GUI:ScrollView_setInnerContainerSize(ScrollView_money, 500.00, 94.00)
	GUI:setAnchorPoint(ScrollView_money, 0.00, 1.00)
	GUI:setTouchEnabled(ScrollView_money, true)
	GUI:setTag(ScrollView_money, 327)

	-- Create Money_CheckBox
	local Money_CheckBox = GUI:Layout_Create(Panel_money, "Money_CheckBox", 172.00, 385.00, 218.00, 40.00, false)
	GUI:setAnchorPoint(Money_CheckBox, 0.00, 1.00)
	GUI:setTouchEnabled(Money_CheckBox, true)
	GUI:setTag(Money_CheckBox, 322)

	-- Create CheckBox
	local CheckBox = GUI:CheckBox_Create(Money_CheckBox, "CheckBox", 16.00, 20.00, "res/private/trading_bank/1900000654.png", "res/private/trading_bank/1900000655.png")
	GUI:CheckBox_setSelected(CheckBox, true)
	GUI:setAnchorPoint(CheckBox, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox, false)
	GUI:setTag(CheckBox, 146)

	-- Create Text_money
	local Text_money = GUI:Text_Create(Money_CheckBox, "Text_money", 32.00, 20.00, 20, "#ffffff", [[金币(余:200000000)]])
	GUI:setAnchorPoint(Text_money, 0.00, 0.50)
	GUI:setTouchEnabled(Text_money, false)
	GUI:setTag(Text_money, 148)
	GUI:Text_enableOutline(Text_money, "#000000", 1)

	-- Create Image_1
	local Image_1 = GUI:Image_Create(Panel_money, "Image_1", 283.00, 229.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_1, 8, 8, 10, 10)
	GUI:setContentSize(Image_1, 220, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_1, false)
	GUI:setAnchorPoint(Image_1, 0.50, 0.50)
	GUI:setTouchEnabled(Image_1, false)
	GUI:setTag(Image_1, 132)

	-- Create Text_most2
	local Text_most2 = GUI:Text_Create(Image_1, "Text_most2", 226.00, 16.00, 16, "#ffffff", [[最低售价]])
	GUI:setAnchorPoint(Text_most2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_most2, false)
	GUI:setTag(Text_most2, 125)
	GUI:Text_enableOutline(Text_most2, "#000000", 1)

	-- Create TextField_money_price
	local TextField_money_price = GUI:TextInput_Create(Image_1, "TextField_money_price", 110.00, 16.00, 220.00, 32.00, 20)
	GUI:TextInput_setString(TextField_money_price, "")
	GUI:TextInput_setFontColor(TextField_money_price, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_money_price, 13)
	GUI:setAnchorPoint(TextField_money_price, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_money_price, true)
	GUI:setTag(TextField_money_price, 133)

	-- Create money_price_mask
	local money_price_mask = GUI:Layout_Create(Image_1, "money_price_mask", -2.00, -2.00, 220.00, 32.00, false)
	GUI:setTouchEnabled(money_price_mask, true)
	GUI:setTag(money_price_mask, 91)

	-- Create Text_6
	local Text_6 = GUI:Text_Create(Panel_money, "Text_6", 66.00, 117.00, 19, "#f8e6c6", [[指定购买人:]])
	GUI:setAnchorPoint(Text_6, 0.00, 0.50)
	GUI:setTouchEnabled(Text_6, false)
	GUI:setTag(Text_6, 125)
	GUI:Text_enableOutline(Text_6, "#000000", 1)

	-- Create Text_8
	local Text_8 = GUI:Text_Create(Panel_money, "Text_8", 174.00, 98.00, 16, "#ffffff", [[如需指定售卖，需输入对方的角色名称]])
	GUI:setAnchorPoint(Text_8, 0.00, 1.00)
	GUI:setTouchEnabled(Text_8, false)
	GUI:setTag(Text_8, 127)
	GUI:Text_enableOutline(Text_8, "#000000", 1)

	-- Create Image_target_money
	local Image_target_money = GUI:Image_Create(Panel_money, "Image_target_money", 284.00, 117.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_target_money, 8, 8, 10, 10)
	GUI:setContentSize(Image_target_money, 220, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_target_money, false)
	GUI:setAnchorPoint(Image_target_money, 0.50, 0.50)
	GUI:setTouchEnabled(Image_target_money, false)
	GUI:setTag(Image_target_money, 134)

	-- Create TextField_target_money
	local TextField_target_money = GUI:TextInput_Create(Image_target_money, "TextField_target_money", 110.00, 16.00, 220.00, 32.00, 20)
	GUI:TextInput_setString(TextField_target_money, "")
	GUI:TextInput_setFontColor(TextField_target_money, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_target_money, 32)
	GUI:setAnchorPoint(TextField_target_money, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_target_money, true)
	GUI:setTag(TextField_target_money, -1)

	-- Create target_money_mask
	local target_money_mask = GUI:Layout_Create(Image_target_money, "target_money_mask", -1.00, 0.00, 220.00, 32.00, false)
	GUI:setTouchEnabled(target_money_mask, true)
	GUI:setTag(target_money_mask, 92)

	-- Create Text_bargain_money
	local Text_bargain_money = GUI:Text_Create(Panel_money, "Text_bargain_money", 66.00, 159.00, 19, "#f8e6c6", [[买家是否可以还价:]])
	GUI:setTouchEnabled(Text_bargain_money, false)
	GUI:setTag(Text_bargain_money, -1)
	GUI:Text_enableOutline(Text_bargain_money, "#000000", 1)

	-- Create Panel_bargain_money
	local Panel_bargain_money = GUI:Layout_Create(Panel_money, "Panel_bargain_money", 233.00, 156.00, 150.00, 30.00, false)
	GUI:setTouchEnabled(Panel_bargain_money, true)
	GUI:setTag(Panel_bargain_money, -1)

	-- Create Text
	local Text = GUI:Text_Create(Panel_bargain_money, "Text", 114.00, 3.00, 20, "#f8e6c6", [[否]])
	GUI:setTouchEnabled(Text, false)
	GUI:setTag(Text, -1)
	GUI:Text_enableOutline(Text, "#000000", 1)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Panel_bargain_money, "Text_1", 42.00, 3.00, 20, "#f8e6c6", [[是]])
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, -1)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create CheckBox_true
	local CheckBox_true = GUI:CheckBox_Create(Panel_bargain_money, "CheckBox_true", 24.00, 14.00, "res/private/trading_bank/word_jiaoyh_022.png", "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:CheckBox_setSelected(CheckBox_true, false)
	GUI:setAnchorPoint(CheckBox_true, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox_true, true)
	GUI:setTag(CheckBox_true, 175)

	-- Create CheckBox_false
	local CheckBox_false = GUI:CheckBox_Create(Panel_bargain_money, "CheckBox_false", 94.00, 14.00, "res/private/trading_bank/word_jiaoyh_022.png", "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:CheckBox_setSelected(CheckBox_false, false)
	GUI:setAnchorPoint(CheckBox_false, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox_false, true)
	GUI:setTag(CheckBox_false, 175)

	-- Create Panel_equip
	local Panel_equip = GUI:Layout_Create(Panel_1, "Panel_equip", 0.00, 0.00, 732.00, 386.00, false)
	GUI:setTouchEnabled(Panel_equip, false)
	GUI:setTag(Panel_equip, 119)

	-- Create Image_fgx
	local Image_fgx = GUI:Image_Create(Panel_equip, "Image_fgx", 469.00, 0.00, "res/private/trading_bank/img_sell_equip_fgx.png")
	GUI:setTouchEnabled(Image_fgx, false)
	GUI:setTag(Image_fgx, -1)

	-- Create Image_title1
	local Image_title1 = GUI:Image_Create(Panel_equip, "Image_title1", 14.00, 344.00, "res/private/trading_bank/img_title_bg.png")
	GUI:setTouchEnabled(Image_title1, false)
	GUI:setTag(Image_title1, -1)

	-- Create Image_title2
	local Image_title2 = GUI:Image_Create(Panel_equip, "Image_title2", 476.00, 344.00, "res/private/trading_bank/img_title_bg.png")
	GUI:Image_setScale9Slice(Image_title2, 148, 148, 14, 14)
	GUI:setContentSize(Image_title2, 250, 42)
	GUI:setIgnoreContentAdaptWithSize(Image_title2, false)
	GUI:setTouchEnabled(Image_title2, false)
	GUI:setTag(Image_title2, -1)

	-- Create ScrollView_goodList
	local ScrollView_goodList = GUI:ScrollView_Create(Panel_equip, "ScrollView_goodList", 10.00, 0.00, 456.00, 346.00, 1)
	GUI:ScrollView_setInnerContainerSize(ScrollView_goodList, 500.00, 400.00)
	GUI:setTouchEnabled(ScrollView_goodList, true)
	GUI:setTag(ScrollView_goodList, -1)

	-- Create ScrollView_bagList
	local ScrollView_bagList = GUI:ScrollView_Create(Panel_equip, "ScrollView_bagList", 477.00, 50.00, 244.00, 296.00, 1)
	GUI:ScrollView_setInnerContainerSize(ScrollView_bagList, 470.00, 370.00)
	GUI:setTouchEnabled(ScrollView_bagList, true)
	GUI:setTag(ScrollView_bagList, -1)

	-- Create good_item
	local good_item = GUI:Image_Create(Panel_equip, "good_item", 0.00, 206.00, "res/private/trading_bank/img_sell_equipItemBg.png")
	GUI:setTouchEnabled(good_item, false)
	GUI:setTag(good_item, -1)

	-- Create Text_name
	local Text_name = GUI:Text_Create(good_item, "Text_name", 114.00, 96.00, 16, "#ff7700", [[文本]])
	GUI:setAnchorPoint(Text_name, 0.50, 0.00)
	GUI:setTouchEnabled(Text_name, false)
	GUI:setTag(Text_name, -1)
	GUI:Text_enableOutline(Text_name, "#000000", 2)

	-- Create Image_goodBg
	local Image_goodBg = GUI:Image_Create(good_item, "Image_goodBg", 15.00, 19.00, "res/private/trading_bank/img_sell_equipBg.png")
	GUI:setTouchEnabled(Image_goodBg, false)
	GUI:setTag(Image_goodBg, -1)

	-- Create Image_add
	local Image_add = GUI:Image_Create(Image_goodBg, "Image_add", 16.00, 15.00, "res/private/trading_bank/btn_jiahao_01.png")
	GUI:setTouchEnabled(Image_add, false)
	GUI:setTag(Image_add, -1)

	-- Create Text_price_desc
	local Text_price_desc = GUI:Text_Create(good_item, "Text_price_desc", 89.00, 63.00, 15, "#f8e6c6", [[售价:]])
	GUI:setAnchorPoint(Text_price_desc, 0.00, 0.50)
	GUI:setTouchEnabled(Text_price_desc, false)
	GUI:setTag(Text_price_desc, 177)
	GUI:Text_enableOutline(Text_price_desc, "#000000", 1)

	-- Create Text_state
	local Text_state = GUI:Text_Create(good_item, "Text_state", 89.00, 34.00, 15, "#f8e6c6", [[上架中]])
	GUI:setAnchorPoint(Text_state, 0.00, 0.50)
	GUI:setTouchEnabled(Text_state, false)
	GUI:setTag(Text_state, 177)
	GUI:Text_enableOutline(Text_state, "#000000", 1)

	-- Create Text_price
	local Text_price = GUI:Text_Create(good_item, "Text_price", 132.00, 63.00, 15, "#10ff00", [[10元]])
	GUI:setAnchorPoint(Text_price, 0.00, 0.50)
	GUI:setTouchEnabled(Text_price, false)
	GUI:setTag(Text_price, 177)
	GUI:Text_enableOutline(Text_price, "#000000", 1)

	-- Create Text_empty
	local Text_empty = GUI:Text_Create(good_item, "Text_empty", 103.00, 31.00, 16, "#ffffff", [[点击右侧道具
上架]])
	GUI:setTouchEnabled(Text_empty, false)
	GUI:setTag(Text_empty, -1)
	GUI:Text_enableOutline(Text_empty, "#000000", 1)

	-- Create bag_item
	local bag_item = GUI:Image_Create(Panel_equip, "bag_item", 484.00, 272.00, "res/private/trading_bank/img_sell_equipBg.png")
	GUI:setTouchEnabled(bag_item, false)
	GUI:setTag(bag_item, -1)

	-- Create Text_time_desc
	local Text_time_desc = GUI:Text_Create(Panel_equip, "Text_time_desc", 602.00, 25.00, 13, "#f8e6c6", [[30天以内在交易行中购买的装备不可寄售]])
	GUI:setAnchorPoint(Text_time_desc, 0.50, 0.50)
	GUI:setTouchEnabled(Text_time_desc, false)
	GUI:setTag(Text_time_desc, 177)
	GUI:Text_enableOutline(Text_time_desc, "#000000", 1)

	-- Create Panel_common
	local Panel_common = GUI:Layout_Create(Panel_1, "Panel_common", 0.00, 445.00, 732.00, 445.00, false)
	GUI:setAnchorPoint(Panel_common, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_common, false)
	GUI:setTag(Panel_common, 174)

	-- Create ImageBg
	local ImageBg = GUI:Image_Create(Panel_common, "ImageBg", 0.00, 386.00, "res/private/trading_bank/img_sell_select_bg.png")
	GUI:setTouchEnabled(ImageBg, false)
	GUI:setTag(ImageBg, -1)

	-- Create Text_1_0
	local Text_1_0 = GUI:Text_Create(Panel_common, "Text_1_0", 66.00, 417.00, 20, "#f8e6c6", [[售 卖 类 型:]])
	GUI:setAnchorPoint(Text_1_0, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1_0, false)
	GUI:setTag(Text_1_0, 173)
	GUI:Text_enableOutline(Text_1_0, "#000000", 1)

	-- Create CheckBox_role
	local CheckBox_role = GUI:CheckBox_Create(Panel_common, "CheckBox_role", 189.00, 418.00, "res/private/trading_bank/word_jiaoyh_022.png", "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:CheckBox_setSelected(CheckBox_role, false)
	GUI:setAnchorPoint(CheckBox_role, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox_role, true)
	GUI:setTag(CheckBox_role, 175)

	-- Create Text_role_checkDesc
	local Text_role_checkDesc = GUI:Text_Create(CheckBox_role, "Text_role_checkDesc", 56.00, 11.00, 20, "#f8e6c6", [[角色]])
	GUI:setAnchorPoint(Text_role_checkDesc, 0.50, 0.50)
	GUI:setTouchEnabled(Text_role_checkDesc, false)
	GUI:setTag(Text_role_checkDesc, 177)
	GUI:Text_enableOutline(Text_role_checkDesc, "#000000", 1)

	-- Create CheckBox_money
	local CheckBox_money = GUI:CheckBox_Create(Panel_common, "CheckBox_money", 286.00, 418.00, "res/private/trading_bank/word_jiaoyh_022.png", "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:CheckBox_setSelected(CheckBox_money, true)
	GUI:setAnchorPoint(CheckBox_money, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox_money, true)
	GUI:setTag(CheckBox_money, 187)

	-- Create Text_money_checkDesc
	local Text_money_checkDesc = GUI:Text_Create(CheckBox_money, "Text_money_checkDesc", 56.00, 11.00, 20, "#f8e6c6", [[货币]])
	GUI:setAnchorPoint(Text_money_checkDesc, 0.50, 0.50)
	GUI:setTouchEnabled(Text_money_checkDesc, false)
	GUI:setTag(Text_money_checkDesc, 179)
	GUI:Text_enableOutline(Text_money_checkDesc, "#000000", 1)

	-- Create CheckBox_equip
	local CheckBox_equip = GUI:CheckBox_Create(Panel_common, "CheckBox_equip", 382.00, 418.00, "res/private/trading_bank/word_jiaoyh_022.png", "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:CheckBox_setSelected(CheckBox_equip, true)
	GUI:setAnchorPoint(CheckBox_equip, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox_equip, true)
	GUI:setTag(CheckBox_equip, 187)

	-- Create Text_equip_checkDesc
	local Text_equip_checkDesc = GUI:Text_Create(CheckBox_equip, "Text_equip_checkDesc", 56.00, 11.00, 20, "#f8e6c6", [[装备]])
	GUI:setAnchorPoint(Text_equip_checkDesc, 0.50, 0.50)
	GUI:setTouchEnabled(Text_equip_checkDesc, false)
	GUI:setTag(Text_equip_checkDesc, 179)
	GUI:Text_enableOutline(Text_equip_checkDesc, "#000000", 1)

	-- Create Button_help
	local Button_help = GUI:Button_Create(Panel_common, "Button_help", 694.00, 418.00, "res/private/trading_bank/1900001024.png")
	GUI:Button_setScale9Slice(Button_help, 15, 15, 12, 10)
	GUI:setContentSize(Button_help, 34, 34)
	GUI:setIgnoreContentAdaptWithSize(Button_help, false)
	GUI:Button_setTitleText(Button_help, "")
	GUI:Button_setTitleColor(Button_help, "#414146")
	GUI:Button_setTitleFontSize(Button_help, 14)
	GUI:Button_titleDisableOutLine(Button_help)
	GUI:setAnchorPoint(Button_help, 0.50, 0.50)
	GUI:setTouchEnabled(Button_help, true)
	GUI:setTag(Button_help, 181)

	-- Create Button_next
	local Button_next = GUI:Button_Create(Panel_common, "Button_next", 366.00, 36.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_next, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_next, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_next, 15, 15, 11, 11)
	GUI:setContentSize(Button_next, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_next, false)
	GUI:Button_setTitleText(Button_next, "下一步")
	GUI:Button_setTitleColor(Button_next, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_next, 19)
	GUI:Button_titleEnableOutline(Button_next, "#000000", 1)
	GUI:setAnchorPoint(Button_next, 0.50, 0.50)
	GUI:setTouchEnabled(Button_next, true)
	GUI:setTag(Button_next, 141)

	-- Create Text_tips
	local Text_tips = GUI:Text_Create(Panel_common, "Text_tips", 366.00, 222.00, 20, "#2abb2a", [[使用交易行需先验证身份信息,避免出现盗号现象]])
	GUI:setAnchorPoint(Text_tips, 0.50, 0.50)
	GUI:setTouchEnabled(Text_tips, false)
	GUI:setTag(Text_tips, 45)
	GUI:setVisible(Text_tips, false)
	GUI:Text_enableOutline(Text_tips, "#000000", 1)

	-- Create Button_tips
	local Button_tips = GUI:Button_Create(Panel_common, "Button_tips", 366.00, 178.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_tips, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_tips, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_tips, 15, 15, 11, 11)
	GUI:setContentSize(Button_tips, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_tips, false)
	GUI:Button_setTitleText(Button_tips, "验证身份")
	GUI:Button_setTitleColor(Button_tips, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_tips, 19)
	GUI:Button_titleEnableOutline(Button_tips, "#000000", 1)
	GUI:setAnchorPoint(Button_tips, 0.50, 0.50)
	GUI:setTouchEnabled(Button_tips, true)
	GUI:setTag(Button_tips, 272)
	GUI:setVisible(Button_tips, false)
end
return ui