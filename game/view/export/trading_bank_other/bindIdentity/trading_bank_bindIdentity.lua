local ui = {}
function ui.init(parent)
	-- Create Panel_cancel
	local Panel_cancel = GUI:Layout_Create(parent, "Panel_cancel", -3.00, 0.00, 1136.00, 640.00, false)
	GUI:Layout_setBackGroundColorType(Panel_cancel, 1)
	GUI:Layout_setBackGroundColor(Panel_cancel, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_cancel, 68)
	GUI:setTouchEnabled(Panel_cancel, false)
	GUI:setTag(Panel_cancel, -1)

	-- Create PMainUI
	local PMainUI = GUI:Layout_Create(Panel_cancel, "PMainUI", 568.00, 320.00, 790.00, 536.00, false)
	GUI:setAnchorPoint(PMainUI, 0.50, 0.50)
	GUI:setTouchEnabled(PMainUI, false)
	GUI:setTag(PMainUI, -1)

	-- Create Layout_Touch
	local Layout_Touch = GUI:Layout_Create(PMainUI, "Layout_Touch", 15.00, 23.00, 760.00, 510.00, false)
	GUI:setTouchEnabled(Layout_Touch, true)
	GUI:setTag(Layout_Touch, -1)

	-- Create FrameBG
	local FrameBG = GUI:Image_Create(PMainUI, "FrameBG", 0.00, 0.00, "res/private/trading_bank/1900000610.png")
	GUI:setTouchEnabled(FrameBG, false)
	GUI:setTag(FrameBG, -1)

	-- Create DressIMG
	local DressIMG = GUI:Image_Create(PMainUI, "DressIMG", -14.00, 474.00, "res/private/trading_bank/1900000610_1.png")
	GUI:setTouchEnabled(DressIMG, false)
	GUI:setTag(DressIMG, -1)

	-- Create TitleText
	local TitleText = GUI:Text_Create(PMainUI, "TitleText", 36.00, 498.00, 20, "#d8c8ae", [[交易行]])
	GUI:setTouchEnabled(TitleText, false)
	GUI:setTag(TitleText, -1)
	GUI:Text_enableOutline(TitleText, "#000000", 1)

	-- Create CloseButton
	local CloseButton = GUI:Button_Create(PMainUI, "CloseButton", 780.00, 493.00, "res/private/trading_bank/1900000510.png")
	GUI:Button_loadTexturePressed(CloseButton, "res/private/trading_bank/1900000511.png")
	GUI:Button_setTitleText(CloseButton, "")
	GUI:Button_setTitleColor(CloseButton, "#ffffff")
	GUI:Button_setTitleFontSize(CloseButton, 10)
	GUI:Button_titleEnableOutline(CloseButton, "#000000", 1)
	GUI:setTouchEnabled(CloseButton, true)
	GUI:setTag(CloseButton, -1)

	-- Create Panel_BindIdentity
	local Panel_BindIdentity = GUI:Layout_Create(PMainUI, "Panel_BindIdentity", 29.00, 37.00, 735.00, 450.00, false)
	GUI:setTouchEnabled(Panel_BindIdentity, false)
	GUI:setTag(Panel_BindIdentity, -1)

	-- Create Text_phone
	local Text_phone = GUI:Text_Create(Panel_BindIdentity, "Text_phone", 89.00, 244.00, 19, "#f8e6c6", [[姓          名:]])
	GUI:setTouchEnabled(Text_phone, false)
	GUI:setTag(Text_phone, 125)
	GUI:Text_enableOutline(Text_phone, "#000000", 1)

	-- Create Text_phone_tips
	local Text_phone_tips = GUI:Text_Create(Panel_BindIdentity, "Text_phone_tips", 82.00, 333.00, 18, "#ffffff", [[需认证身份信息，用于提现审核，请确认身份证信息与支付宝实名信息一致]])
	GUI:setTouchEnabled(Text_phone_tips, false)
	GUI:setTag(Text_phone_tips, -1)
	GUI:Text_enableOutline(Text_phone_tips, "#000000", 1)

	-- Create Text_verification_code
	local Text_verification_code = GUI:Text_Create(Panel_BindIdentity, "Text_verification_code", 82.00, 160.00, 19, "#f8e6c6", [[身 份 证 号:]])
	GUI:setTouchEnabled(Text_verification_code, false)
	GUI:setTag(Text_verification_code, 125)
	GUI:Text_enableOutline(Text_verification_code, "#000000", 1)

	-- Create Image_name
	local Image_name = GUI:Image_Create(Panel_BindIdentity, "Image_name", 201.00, 244.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_name, 8, 8, 10, 10)
	GUI:setContentSize(Image_name, 245, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_name, false)
	GUI:setTouchEnabled(Image_name, false)
	GUI:setTag(Image_name, 134)

	-- Create TextField_name
	local TextField_name = GUI:TextInput_Create(Image_name, "TextField_name", 4.00, 2.00, 236.00, 26.00, 20)
	GUI:TextInput_setString(TextField_name, "")
	GUI:TextInput_setFontColor(TextField_name, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_name, 11)
	GUI:setTouchEnabled(TextField_name, true)
	GUI:setTag(TextField_name, 135)

	-- Create Button_next
	local Button_next = GUI:Button_Create(Panel_BindIdentity, "Button_next", 377.00, 57.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_next, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_next, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_next, 15, 15, 11, 11)
	GUI:setContentSize(Button_next, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_next, false)
	GUI:Button_setTitleText(Button_next, "提交")
	GUI:Button_setTitleColor(Button_next, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_next, 19)
	GUI:Button_titleEnableOutline(Button_next, "#000000", 1)
	GUI:setAnchorPoint(Button_next, 0.50, 0.50)
	GUI:setTouchEnabled(Button_next, true)
	GUI:setTag(Button_next, 141)

	-- Create Image_code
	local Image_code = GUI:Image_Create(Panel_BindIdentity, "Image_code", 201.00, 156.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_code, 8, 8, 10, 10)
	GUI:setContentSize(Image_code, 245, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_code, false)
	GUI:setTouchEnabled(Image_code, false)
	GUI:setTag(Image_code, 134)

	-- Create TextField_code
	local TextField_code = GUI:TextInput_Create(Image_code, "TextField_code", 4.00, 2.00, 236.00, 26.00, 20)
	GUI:TextInput_setString(TextField_code, "")
	GUI:TextInput_setFontColor(TextField_code, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_code, 18)
	GUI:setTouchEnabled(TextField_code, true)
	GUI:setTag(TextField_code, -1)

	-- Create Panel_ok
	local Panel_ok = GUI:Layout_Create(PMainUI, "Panel_ok", 29.00, 36.00, 735.00, 450.00, false)
	GUI:setTouchEnabled(Panel_ok, false)
	GUI:setTag(Panel_ok, -1)
	GUI:setVisible(Panel_ok, false)

	-- Create Text_name1
	local Text_name1 = GUI:Text_Create(Panel_ok, "Text_name1", 213.00, 310.00, 19, "#f8e6c6", [[姓     名  ：]])
	GUI:setTouchEnabled(Text_name1, false)
	GUI:setTag(Text_name1, -1)
	GUI:Text_enableOutline(Text_name1, "#000000", 1)

	-- Create Button_next3
	local Button_next3 = GUI:Button_Create(Panel_ok, "Button_next3", 361.00, 66.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_next3, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_next3, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_next3, 0, 0, 0, 0)
	GUI:setContentSize(Button_next3, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_next3, false)
	GUI:Button_setTitleText(Button_next3, "返回交易行")
	GUI:Button_setTitleColor(Button_next3, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_next3, 19)
	GUI:Button_titleEnableOutline(Button_next3, "#000000", 1)
	GUI:setAnchorPoint(Button_next3, 0.50, 0.50)
	GUI:setTouchEnabled(Button_next3, true)
	GUI:setTag(Button_next3, 141)

	-- Create Text_name
	local Text_name = GUI:Text_Create(Panel_ok, "Text_name", 308.00, 310.00, 19, "#ffffff", [[海伦**]])
	GUI:setTouchEnabled(Text_name, false)
	GUI:setTag(Text_name, -1)
	GUI:Text_enableOutline(Text_name, "#000000", 1)

	-- Create Text_identity1
	local Text_identity1 = GUI:Text_Create(Panel_ok, "Text_identity1", 211.00, 240.00, 19, "#f8e6c6", [[身 份 证：]])
	GUI:setTouchEnabled(Text_identity1, false)
	GUI:setTag(Text_identity1, -1)
	GUI:Text_enableOutline(Text_identity1, "#000000", 1)

	-- Create Text_identity
	local Text_identity = GUI:Text_Create(Panel_ok, "Text_identity", 308.00, 240.00, 19, "#ffffff", [[33042123123123123123123]])
	GUI:setTouchEnabled(Text_identity, false)
	GUI:setTag(Text_identity, -1)
	GUI:Text_enableOutline(Text_identity, "#000000", 1)

	-- Create Text_tip3
	local Text_tip3 = GUI:Text_Create(Panel_ok, "Text_tip3", 212.00, 143.00, 18, "#00ff00", [[您已完成认证，无法修改实名信息
如有疑问，请联系客服]])
	GUI:setTouchEnabled(Text_tip3, false)
	GUI:setTag(Text_tip3, -1)
	GUI:Text_enableOutline(Text_tip3, "#000000", 1)
end
return ui