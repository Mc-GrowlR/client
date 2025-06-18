local ui = {}
function ui.init(parent)
	-- Create Scene
	local Scene = GUI:Node_Create(parent, "Scene", 0.00, 0.00)
	GUI:setAnchorPoint(Scene, 0.50, 0.50)
	GUI:setTag(Scene, -1)

	-- Create Panel_2
	local Panel_2 = GUI:Layout_Create(Scene, "Panel_2", 568.00, 320.00, 1136.00, 640.00, false)
	GUI:setAnchorPoint(Panel_2, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_2, true)
	GUI:setTag(Panel_2, 311)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_2, "Image_bg", 568.00, 320.00, "res/private/trading_bank/bg_jiaoyh_012.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, true)
	GUI:setTag(Image_bg, 312)

	-- Create Button_cancel
	local Button_cancel = GUI:Button_Create(Image_bg, "Button_cancel", 110.00, 57.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_cancel, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_cancel, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_cancel, 15, 15, 11, 11)
	GUI:setContentSize(Button_cancel, 100, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_cancel, false)
	GUI:Button_setTitleText(Button_cancel, "取消上架")
	GUI:Button_setTitleColor(Button_cancel, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_cancel, 18)
	GUI:Button_titleEnableOutline(Button_cancel, "#000000", 1)
	GUI:setAnchorPoint(Button_cancel, 0.50, 0.50)
	GUI:setTouchEnabled(Button_cancel, true)
	GUI:setTag(Button_cancel, 313)

	-- Create Button_next
	local Button_next = GUI:Button_Create(Image_bg, "Button_next", 264.00, 57.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_next, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_next, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_next, 15, 15, 11, 11)
	GUI:setContentSize(Button_next, 100, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_next, false)
	GUI:Button_setTitleText(Button_next, "寄售上架")
	GUI:Button_setTitleColor(Button_next, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_next, 18)
	GUI:Button_titleEnableOutline(Button_next, "#000000", 1)
	GUI:setAnchorPoint(Button_next, 0.50, 0.50)
	GUI:setTouchEnabled(Button_next, true)
	GUI:setTag(Button_next, 314)

	-- Create Button_close
	local Button_close = GUI:Button_Create(Image_bg, "Button_close", 383.00, 471.00, "res/private/trading_bank/1900000510.png")
	GUI:Button_loadTexturePressed(Button_close, "res/private/trading_bank/1900000511.png")
	GUI:Button_loadTextureDisabled(Button_close, "res/private/trading_bank/1900000511.png")
	GUI:Button_setTitleText(Button_close, "")
	GUI:Button_setTitleColor(Button_close, "#ffffff")
	GUI:Button_setTitleFontSize(Button_close, 14)
	GUI:Button_titleEnableOutline(Button_close, "#000000", 1)
	GUI:setTouchEnabled(Button_close, true)
	GUI:setTag(Button_close, -1)

	-- Create Image_titleBg
	local Image_titleBg = GUI:Image_Create(Image_bg, "Image_titleBg", 39.00, 450.00, "res/private/trading_bank/word_sxbt_05.png")
	GUI:setTouchEnabled(Image_titleBg, false)
	GUI:setTag(Image_titleBg, -1)

	-- Create Image_title
	local Image_title = GUI:Image_Create(Image_bg, "Image_title", 189.00, 444.00, "res/private/trading_bank/img_sell_equip_title.png")
	GUI:setAnchorPoint(Image_title, 0.50, 0.00)
	GUI:setTouchEnabled(Image_title, false)
	GUI:setTag(Image_title, -1)

	-- Create Image_equipBg
	local Image_equipBg = GUI:Image_Create(Image_bg, "Image_equipBg", 158.00, 365.00, "res/private/trading_bank/img_sell_equipBg.png")
	GUI:setTouchEnabled(Image_equipBg, false)
	GUI:setTag(Image_equipBg, -1)

	-- Create Text_equip_name
	local Text_equip_name = GUI:Text_Create(Image_equipBg, "Text_equip_name", 30.00, -22.00, 16, "#ffffff", [[大吐龙]])
	GUI:setAnchorPoint(Text_equip_name, 0.50, 0.00)
	GUI:setTouchEnabled(Text_equip_name, false)
	GUI:setTag(Text_equip_name, -1)
	GUI:Text_enableOutline(Text_equip_name, "#000000", 1)

	-- Create Text_desc1
	local Text_desc1 = GUI:Text_Create(Image_bg, "Text_desc1", 126.00, 298.00, 16, "#f8e6c6", [[售价:]])
	GUI:setAnchorPoint(Text_desc1, 1.00, 0.50)
	GUI:setTouchEnabled(Text_desc1, false)
	GUI:setTag(Text_desc1, 369)
	GUI:Text_enableOutline(Text_desc1, "#000000", 1)

	-- Create Image_price
	local Image_price = GUI:Image_Create(Image_bg, "Image_price", 134.00, 282.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_price, 8, 8, 10, 10)
	GUI:setContentSize(Image_price, 90, 30)
	GUI:setIgnoreContentAdaptWithSize(Image_price, false)
	GUI:setTouchEnabled(Image_price, false)
	GUI:setTag(Image_price, 143)

	-- Create TextField_price
	local TextField_price = GUI:TextInput_Create(Image_price, "TextField_price", 44.00, 17.00, 86.00, 26.00, 20)
	GUI:TextInput_setString(TextField_price, "")
	GUI:TextInput_setFontColor(TextField_price, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_price, 13)
	GUI:setAnchorPoint(TextField_price, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_price, true)
	GUI:setTag(TextField_price, -1)

	-- Create Text_min_price
	local Text_min_price = GUI:Text_Create(Image_price, "Text_min_price", 124.00, 13.00, 14, "#ffffff", [[最低1元]])
	GUI:setAnchorPoint(Text_min_price, 0.00, 0.50)
	GUI:setTouchEnabled(Text_min_price, false)
	GUI:setTag(Text_min_price, 54)
	GUI:Text_enableOutline(Text_min_price, "#000000", 1)

	-- Create Text_y
	local Text_y = GUI:Text_Create(Image_price, "Text_y", 92.00, 14.00, 16, "#ffffff", [[元]])
	GUI:setAnchorPoint(Text_y, 0.00, 0.50)
	GUI:setTouchEnabled(Text_y, false)
	GUI:setTag(Text_y, 271)
	GUI:Text_enableOutline(Text_y, "#000000", 1)

	-- Create Text_sxf
	local Text_sxf = GUI:Text_Create(Image_price, "Text_sxf", 2.00, -13.00, 14, "#00ff00", [[手续费:10%]])
	GUI:setAnchorPoint(Text_sxf, 0.00, 0.50)
	GUI:setTouchEnabled(Text_sxf, false)
	GUI:setTag(Text_sxf, 271)
	GUI:Text_enableOutline(Text_sxf, "#000000", 1)

	-- Create Text_svip_desc
	local Text_svip_desc = GUI:Text_Create(Image_price, "Text_svip_desc", -110.00, -32.00, 14, "#00ff00", [[(盒子SVIP%s交易行手续费可减免，减免详情盒子查看)]])
	GUI:setAnchorPoint(Text_svip_desc, 0.00, 0.50)
	GUI:setTouchEnabled(Text_svip_desc, false)
	GUI:setTag(Text_svip_desc, 271)
	GUI:Text_enableOutline(Text_svip_desc, "#000000", 1)

	-- Create Text_desc2
	local Text_desc2 = GUI:Text_Create(Image_bg, "Text_desc2", 126.00, 219.00, 16, "#f8e6c6", [[是否可还价:]])
	GUI:setAnchorPoint(Text_desc2, 1.00, 0.50)
	GUI:setTouchEnabled(Text_desc2, false)
	GUI:setTag(Text_desc2, 369)
	GUI:Text_enableOutline(Text_desc2, "#000000", 1)

	-- Create Panel_bargain_equip
	local Panel_bargain_equip = GUI:Layout_Create(Image_bg, "Panel_bargain_equip", 130.00, 204.00, 150.00, 30.00, false)
	GUI:setTouchEnabled(Panel_bargain_equip, true)
	GUI:setTag(Panel_bargain_equip, -1)

	-- Create Text_no
	local Text_no = GUI:Text_Create(Panel_bargain_equip, "Text_no", 112.00, 3.00, 16, "#f8e6c6", [[否]])
	GUI:setTouchEnabled(Text_no, false)
	GUI:setTag(Text_no, -1)
	GUI:Text_enableOutline(Text_no, "#000000", 1)

	-- Create Text_yes
	local Text_yes = GUI:Text_Create(Panel_bargain_equip, "Text_yes", 41.00, 3.00, 16, "#f8e6c6", [[是]])
	GUI:setTouchEnabled(Text_yes, false)
	GUI:setTag(Text_yes, -1)
	GUI:Text_enableOutline(Text_yes, "#000000", 1)

	-- Create CheckBox_true
	local CheckBox_true = GUI:CheckBox_Create(Panel_bargain_equip, "CheckBox_true", 24.00, 14.00, "res/private/trading_bank/word_jiaoyh_022.png", "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:CheckBox_setSelected(CheckBox_true, false)
	GUI:setAnchorPoint(CheckBox_true, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox_true, true)
	GUI:setTag(CheckBox_true, 175)

	-- Create CheckBox_false
	local CheckBox_false = GUI:CheckBox_Create(Panel_bargain_equip, "CheckBox_false", 94.00, 14.00, "res/private/trading_bank/word_jiaoyh_022.png", "res/private/trading_bank/word_jiaoyh_021.png")
	GUI:CheckBox_setSelected(CheckBox_false, false)
	GUI:setAnchorPoint(CheckBox_false, 0.50, 0.50)
	GUI:setTouchEnabled(CheckBox_false, true)
	GUI:setTag(CheckBox_false, 175)

	-- Create Text_desc3
	local Text_desc3 = GUI:Text_Create(Image_bg, "Text_desc3", 126.00, 152.00, 16, "#f8e6c6", [[指定购买人:]])
	GUI:setAnchorPoint(Text_desc3, 1.00, 0.50)
	GUI:setTouchEnabled(Text_desc3, false)
	GUI:setTag(Text_desc3, 369)
	GUI:Text_enableOutline(Text_desc3, "#000000", 1)

	-- Create Image_target
	local Image_target = GUI:Image_Create(Image_bg, "Image_target", 134.00, 151.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_target, 8, 8, 10, 10)
	GUI:setContentSize(Image_target, 190, 30)
	GUI:setIgnoreContentAdaptWithSize(Image_target, false)
	GUI:setAnchorPoint(Image_target, 0.00, 0.50)
	GUI:setTouchEnabled(Image_target, false)
	GUI:setTag(Image_target, 134)

	-- Create TextField_target_equip
	local TextField_target_equip = GUI:TextInput_Create(Image_target, "TextField_target_equip", 95.00, 14.00, 180.00, 28.00, 20)
	GUI:TextInput_setString(TextField_target_equip, "")
	GUI:TextInput_setFontColor(TextField_target_equip, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_target_equip, 32)
	GUI:setAnchorPoint(TextField_target_equip, 0.50, 0.50)
	GUI:setTouchEnabled(TextField_target_equip, true)
	GUI:setTag(TextField_target_equip, -1)

	-- Create Text_min_price
	local Text_min_price = GUI:Text_Create(Image_target, "Text_min_price", 2.00, -3.00, 14, "#ffffff", [[如需指定售卖，需输入对方
的角色名称]])
	GUI:setAnchorPoint(Text_min_price, 0.00, 1.00)
	GUI:setTouchEnabled(Text_min_price, false)
	GUI:setTag(Text_min_price, 54)
	GUI:Text_enableOutline(Text_min_price, "#000000", 1)
end
return ui