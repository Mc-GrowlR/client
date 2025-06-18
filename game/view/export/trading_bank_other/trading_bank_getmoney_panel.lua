local ui = {}
function ui.init(parent)
	-- Create Panel_cancel
	local Panel_cancel = GUI:Layout_Create(parent, "Panel_cancel", 0.00, 0.00, 1136.00, 640.00, false)
	GUI:setTouchEnabled(Panel_cancel, true)
	GUI:setTag(Panel_cancel, -1)

	-- Create Panel_2
	local Panel_2 = GUI:Layout_Create(parent, "Panel_2", 573.00, 311.00, 382.00, 509.00, false)
	GUI:setAnchorPoint(Panel_2, 0.50, 0.50)
	GUI:setTouchEnabled(Panel_2, true)
	GUI:setTag(Panel_2, 344)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_2, "Image_bg", 191.00, 254.00, "res/private/trading_bank/bg_jiaoyh_012.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, 345)

	-- Create Panel_apply
	local Panel_apply = GUI:Layout_Create(Panel_2, "Panel_apply", 17.00, 12.00, 350.00, 480.00, false)
	GUI:setTouchEnabled(Panel_apply, false)
	GUI:setTag(Panel_apply, -1)
	GUI:setVisible(Panel_apply, false)

	-- Create Text_30
	local Text_30 = GUI:Text_Create(Panel_apply, "Text_30", 22.00, 333.00, 16, "#ffffff", [[提现后，将进入1-2个工作日的人工审核（
周六周日非工作日顺延），可前往]])
	GUI:setAnchorPoint(Text_30, 0.00, 0.50)
	GUI:setTouchEnabled(Text_30, false)
	GUI:setTag(Text_30, 349)
	GUI:Text_enableOutline(Text_30, "#000000", 1)

	-- Create Image_money
	local Image_money = GUI:Image_Create(Panel_apply, "Image_money", 48.00, 370.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_money, 8, 8, 10, 10)
	GUI:setContentSize(Image_money, 245, 50)
	GUI:setIgnoreContentAdaptWithSize(Image_money, false)
	GUI:setTouchEnabled(Image_money, false)
	GUI:setTag(Image_money, 134)

	-- Create TextField_money
	local TextField_money = GUI:TextInput_Create(Image_money, "TextField_money", 0.00, 0.00, 245.00, 50.00, 40)
	GUI:TextInput_setString(TextField_money, "￥12000")
	GUI:TextInput_setFontColor(TextField_money, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_money, 15)
	GUI:setTouchEnabled(TextField_money, true)
	GUI:setTag(TextField_money, 135)

	-- Create Text_record
	local Text_record = GUI:Text_Create(Panel_apply, "Text_record", 268.00, 313.00, 16, "#00ff00", [[提现记录]])
	GUI:setTouchEnabled(Text_record, false)
	GUI:setTag(Text_record, -1)
	GUI:Text_enableOutline(Text_record, "#000000", 1)

	-- Create Text_30_1
	local Text_30_1 = GUI:Text_Create(Panel_apply, "Text_30_1", 22.00, 303.00, 16, "#ffffff", [[查看提现进度]])
	GUI:setAnchorPoint(Text_30_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_30_1, false)
	GUI:setTag(Text_30_1, 349)
	GUI:Text_enableOutline(Text_30_1, "#000000", 1)

	-- Create Text_jyb
	local Text_jyb = GUI:Text_Create(Panel_apply, "Text_jyb", 22.00, 212.00, 16, "#ffffff", [[交易币：]])
	GUI:setAnchorPoint(Text_jyb, 0.00, 0.50)
	GUI:setTouchEnabled(Text_jyb, false)
	GUI:setTag(Text_jyb, 349)
	GUI:Text_enableOutline(Text_jyb, "#000000", 1)

	-- Create Text_sxf
	local Text_sxf = GUI:Text_Create(Panel_apply, "Text_sxf", 22.00, 170.00, 16, "#ffffff", [[手续费5%：]])
	GUI:setAnchorPoint(Text_sxf, 0.00, 0.50)
	GUI:setTouchEnabled(Text_sxf, false)
	GUI:setTag(Text_sxf, 349)
	GUI:Text_enableOutline(Text_sxf, "#000000", 1)

	-- Create Text_dz
	local Text_dz = GUI:Text_Create(Panel_apply, "Text_dz", 22.00, 125.00, 16, "#ffffff", [[实际到账：]])
	GUI:setAnchorPoint(Text_dz, 0.00, 0.50)
	GUI:setTouchEnabled(Text_dz, false)
	GUI:setTag(Text_dz, 349)
	GUI:Text_enableOutline(Text_dz, "#000000", 1)

	-- Create Text_jyb_count
	local Text_jyb_count = GUI:Text_Create(Panel_apply, "Text_jyb_count", 324.00, 212.00, 16, "#ffffff", [[-12000]])
	GUI:setAnchorPoint(Text_jyb_count, 1.00, 0.50)
	GUI:setTouchEnabled(Text_jyb_count, false)
	GUI:setTag(Text_jyb_count, 349)
	GUI:Text_enableOutline(Text_jyb_count, "#000000", 1)

	-- Create Text_sxf_count
	local Text_sxf_count = GUI:Text_Create(Panel_apply, "Text_sxf_count", 324.00, 170.00, 16, "#ffffff", [[-12000]])
	GUI:setAnchorPoint(Text_sxf_count, 1.00, 0.50)
	GUI:setTouchEnabled(Text_sxf_count, false)
	GUI:setTag(Text_sxf_count, 349)
	GUI:Text_enableOutline(Text_sxf_count, "#000000", 1)

	-- Create Text_dz_count
	local Text_dz_count = GUI:Text_Create(Panel_apply, "Text_dz_count", 324.00, 125.00, 16, "#ffffff", [[-12000]])
	GUI:setAnchorPoint(Text_dz_count, 1.00, 0.50)
	GUI:setTouchEnabled(Text_dz_count, false)
	GUI:setTag(Text_dz_count, 349)
	GUI:Text_enableOutline(Text_dz_count, "#000000", 1)

	-- Create Panel_record
	local Panel_record = GUI:Layout_Create(Panel_2, "Panel_record", 17.00, 12.00, 350.00, 480.00, false)
	GUI:setTouchEnabled(Panel_record, false)
	GUI:setTag(Panel_record, -1)

	-- Create Text_money
	local Text_money = GUI:Text_Create(Panel_record, "Text_money", 173.00, 381.00, 35, "#00ff00", [[1000]])
	GUI:setAnchorPoint(Text_money, 0.50, 0.50)
	GUI:setTouchEnabled(Text_money, false)
	GUI:setTag(Text_money, 349)
	GUI:Text_enableOutline(Text_money, "#000000", 1)

	-- Create Text_state
	local Text_state = GUI:Text_Create(Panel_record, "Text_state", 172.00, 324.00, 18, "#00ff00", [[提现成功]])
	GUI:setAnchorPoint(Text_state, 0.50, 0.00)
	GUI:setTouchEnabled(Text_state, false)
	GUI:setTag(Text_state, -1)
	GUI:Text_enableOutline(Text_state, "#000000", 1)

	-- Create Text_sxf
	local Text_sxf = GUI:Text_Create(Panel_record, "Text_sxf", 22.00, 213.00, 16, "#ffffff", [[手续费：]])
	GUI:setAnchorPoint(Text_sxf, 0.00, 0.50)
	GUI:setTouchEnabled(Text_sxf, false)
	GUI:setTag(Text_sxf, 349)
	GUI:Text_enableOutline(Text_sxf, "#000000", 1)

	-- Create Text_dz
	local Text_dz = GUI:Text_Create(Panel_record, "Text_dz", 22.00, 180.00, 16, "#ffffff", [[实际到账：]])
	GUI:setAnchorPoint(Text_dz, 0.00, 0.50)
	GUI:setTouchEnabled(Text_dz, false)
	GUI:setTag(Text_dz, 349)
	GUI:Text_enableOutline(Text_dz, "#000000", 1)

	-- Create Text_jydh
	local Text_jydh = GUI:Text_Create(Panel_record, "Text_jydh", 22.00, 158.00, 16, "#ffffff", [[交易单号：]])
	GUI:setAnchorPoint(Text_jydh, 0.00, 1.00)
	GUI:setTouchEnabled(Text_jydh, false)
	GUI:setTag(Text_jydh, 349)
	GUI:Text_enableOutline(Text_jydh, "#000000", 1)

	-- Create Text_time
	local Text_time = GUI:Text_Create(Panel_record, "Text_time", 22.00, 112.00, 16, "#ffffff", [[时间：]])
	GUI:setAnchorPoint(Text_time, 0.00, 0.50)
	GUI:setTouchEnabled(Text_time, false)
	GUI:setTag(Text_time, 349)
	GUI:Text_enableOutline(Text_time, "#000000", 1)

	-- Create Text_desc
	local Text_desc = GUI:Text_Create(Panel_record, "Text_desc", 22.00, 79.00, 16, "#ffffff", [[备注：]])
	GUI:setAnchorPoint(Text_desc, 0.00, 0.50)
	GUI:setTouchEnabled(Text_desc, false)
	GUI:setTag(Text_desc, 349)
	GUI:Text_enableOutline(Text_desc, "#000000", 1)

	-- Create Text_time_2
	local Text_time_2 = GUI:Text_Create(Panel_record, "Text_time_2", 22.00, 45.00, 16, "#ffffff", [[到账时间：]])
	GUI:setAnchorPoint(Text_time_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_time_2, false)
	GUI:setTag(Text_time_2, 349)
	GUI:Text_enableOutline(Text_time_2, "#000000", 1)

	-- Create Text_jydh_count
	local Text_jydh_count = GUI:Text_Create(Panel_record, "Text_jydh_count", 96.00, 158.00, 16, "#ffffff", [[exasdasdasdasdasdasdasdasdass]])
	GUI:setAnchorPoint(Text_jydh_count, 0.00, 1.00)
	GUI:setTouchEnabled(Text_jydh_count, false)
	GUI:setTag(Text_jydh_count, 349)
	GUI:Text_enableOutline(Text_jydh_count, "#000000", 1)

	-- Create desc_list
	local desc_list = GUI:ListView_Create(Panel_record, "desc_list", 61.00, 89.00, 285.00, 30.00, 1)
	GUI:ListView_setGravity(desc_list, 5)
	GUI:setAnchorPoint(desc_list, 0.00, 1.00)
	GUI:setTouchEnabled(desc_list, true)
	GUI:setTag(desc_list, -1)

	-- Create Text_desc_1
	local Text_desc_1 = GUI:Text_Create(desc_list, "Text_desc_1", 0.00, 30.00, 16, "#ffffff", [[]])
	GUI:setAnchorPoint(Text_desc_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_desc_1, false)
	GUI:setTag(Text_desc_1, 349)
	GUI:Text_enableOutline(Text_desc_1, "#000000", 1)

	-- Create ButtonClose
	local ButtonClose = GUI:Button_Create(Panel_2, "ButtonClose", 395.00, 485.00, "res/private/trading_bank/1900000510.png")
	GUI:Button_loadTexturePressed(ButtonClose, "res/private/trading_bank/1900000511.png")
	GUI:Button_loadTextureDisabled(ButtonClose, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(ButtonClose, 8, 6, 12, 10)
	GUI:setContentSize(ButtonClose, 26, 42)
	GUI:setIgnoreContentAdaptWithSize(ButtonClose, false)
	GUI:Button_setTitleText(ButtonClose, "")
	GUI:Button_setTitleColor(ButtonClose, "#414146")
	GUI:Button_setTitleFontSize(ButtonClose, 14)
	GUI:Button_titleDisableOutLine(ButtonClose)
	GUI:setAnchorPoint(ButtonClose, 0.50, 0.50)
	GUI:setTouchEnabled(ButtonClose, true)
	GUI:setTag(ButtonClose, 357)

	-- Create Image_2
	local Image_2 = GUI:Image_Create(Panel_2, "Image_2", 191.00, 461.00, "res/private/trading_bank/word_sxbt_05.png")
	GUI:setAnchorPoint(Image_2, 0.50, 0.50)
	GUI:setTouchEnabled(Image_2, false)
	GUI:setTag(Image_2, 347)

	-- Create Image_3
	local Image_3 = GUI:Image_Create(Panel_2, "Image_3", 191.00, 461.00, "res/private/trading_bank_other/img_title.png")
	GUI:setAnchorPoint(Image_3, 0.50, 0.50)
	GUI:setTouchEnabled(Image_3, false)
	GUI:setTag(Image_3, 348)

	-- Create img_fgx
	local img_fgx = GUI:Image_Create(Panel_2, "img_fgx", 20.00, 256.00, "res/private/trading_bank_other/img_fgx.png")
	GUI:setTouchEnabled(img_fgx, false)
	GUI:setTag(img_fgx, -1)

	-- Create Button_1
	local Button_1 = GUI:Button_Create(Panel_2, "Button_1", 193.00, 49.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_1, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_1, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_1, 15, 15, 11, 11)
	GUI:setContentSize(Button_1, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_1, false)
	GUI:Button_setTitleText(Button_1, "申请提现")
	GUI:Button_setTitleColor(Button_1, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_1, 18)
	GUI:Button_titleEnableOutline(Button_1, "#000000", 1)
	GUI:setAnchorPoint(Button_1, 0.50, 0.50)
	GUI:setTouchEnabled(Button_1, true)
	GUI:setTag(Button_1, 355)
end
return ui