local ui = {}
function ui.init(parent)
	-- Create Panel_cancel
	local Panel_cancel = GUI:Layout_Create(parent, "Panel_cancel", 0.00, 0.00, 1136.00, 640.00, false)
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
	local TitleText = GUI:Text_Create(PMainUI, "TitleText", 124.00, 488.00, 20, "#d8c8ae", [[交易行]])
	GUI:setTouchEnabled(TitleText, false)
	GUI:setTag(TitleText, -1)
	GUI:Text_enableOutline(TitleText, "#000000", 1)

	-- Create CloseButton
	local CloseButton = GUI:Button_Create(PMainUI, "CloseButton", 802.00, 477.00, "res/private/trading_bank/1900000510.png")
	GUI:Button_loadTexturePressed(CloseButton, "res/private/trading_bank/1900000511.png")
	GUI:Button_setTitleText(CloseButton, "")
	GUI:Button_setTitleColor(CloseButton, "#ffffff")
	GUI:Button_setTitleFontSize(CloseButton, 10)
	GUI:Button_titleEnableOutline(CloseButton, "#000000", 1)
	GUI:setTouchEnabled(CloseButton, true)
	GUI:setTag(CloseButton, -1)

	-- Create Panel_Photo
	local Panel_Photo = GUI:Layout_Create(PMainUI, "Panel_Photo", 50.00, 29.00, 735.00, 450.00, false)
	GUI:setTouchEnabled(Panel_Photo, false)
	GUI:setTag(Panel_Photo, -1)

	-- Create Text_phone
	local Text_phone = GUI:Text_Create(Panel_Photo, "Text_phone", 82.00, 244.00, 19, "#f8e6c6", [[绑定手机号:]])
	GUI:setTouchEnabled(Text_phone, false)
	GUI:setTag(Text_phone, 125)
	GUI:Text_enableOutline(Text_phone, "#000000", 1)

	-- Create Text_phone_tips
	local Text_phone_tips = GUI:Text_Create(Panel_Photo, "Text_phone_tips", 82.00, 333.00, 19, "#ffffff", [[为保障您的账号安全，请绑定手机号，防止账号被盗造成财务损失]])
	GUI:setTouchEnabled(Text_phone_tips, false)
	GUI:setTag(Text_phone_tips, -1)
	GUI:Text_enableOutline(Text_phone_tips, "#000000", 1)

	-- Create Text_verification_code
	local Text_verification_code = GUI:Text_Create(Panel_Photo, "Text_verification_code", 82.00, 160.00, 19, "#f8e6c6", [[验    证    码:]])
	GUI:setTouchEnabled(Text_verification_code, false)
	GUI:setTag(Text_verification_code, 125)
	GUI:Text_enableOutline(Text_verification_code, "#000000", 1)

	-- Create Image_2
	local Image_2 = GUI:Image_Create(Panel_Photo, "Image_2", 187.00, 244.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_2, 8, 8, 10, 10)
	GUI:setContentSize(Image_2, 245, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_2, false)
	GUI:setTouchEnabled(Image_2, false)
	GUI:setTag(Image_2, 134)

	-- Create TextField_phone
	local TextField_phone = GUI:TextInput_Create(Image_2, "TextField_phone", 4.00, 2.00, 236.00, 26.00, 20)
	GUI:TextInput_setString(TextField_phone, "")
	GUI:TextInput_setFontColor(TextField_phone, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_phone, 11)
	GUI:setTouchEnabled(TextField_phone, true)
	GUI:setTag(TextField_phone, 135)

	-- Create Image_2_1
	local Image_2_1 = GUI:Image_Create(Panel_Photo, "Image_2_1", 186.00, 159.00, "res/private/trading_bank/word_jiaoyh_022.png")
	GUI:Image_setScale9Slice(Image_2_1, 8, 8, 10, 10)
	GUI:setContentSize(Image_2_1, 120, 32)
	GUI:setIgnoreContentAdaptWithSize(Image_2_1, false)
	GUI:setTouchEnabled(Image_2_1, false)
	GUI:setTag(Image_2_1, 134)

	-- Create TextField_Verification_Code
	local TextField_Verification_Code = GUI:TextInput_Create(Image_2_1, "TextField_Verification_Code", 5.00, 2.00, 110.00, 25.00, 20)
	GUI:TextInput_setString(TextField_Verification_Code, "")
	GUI:TextInput_setFontColor(TextField_Verification_Code, "#ffffff")
	GUI:TextInput_setMaxLength(TextField_Verification_Code, 8)
	GUI:setTouchEnabled(TextField_Verification_Code, true)
	GUI:setTag(TextField_Verification_Code, -1)

	-- Create Button_Verification_Code
	local Button_Verification_Code = GUI:Button_Create(Panel_Photo, "Button_Verification_Code", 310.00, 158.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_Verification_Code, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_Verification_Code, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_Verification_Code, 15, 15, 11, 11)
	GUI:setContentSize(Button_Verification_Code, 120, 36)
	GUI:setIgnoreContentAdaptWithSize(Button_Verification_Code, false)
	GUI:Button_setTitleText(Button_Verification_Code, "获取验证码")
	GUI:Button_setTitleColor(Button_Verification_Code, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_Verification_Code, 17)
	GUI:Button_titleEnableOutline(Button_Verification_Code, "#000000", 1)
	GUI:setTouchEnabled(Button_Verification_Code, true)
	GUI:setTag(Button_Verification_Code, 141)

	-- Create Button_next1
	local Button_next1 = GUI:Button_Create(Panel_Photo, "Button_next1", 377.00, 57.00, "res/private/trading_bank/1900000680.png")
	GUI:Button_loadTexturePressed(Button_next1, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_loadTextureDisabled(Button_next1, "res/private/trading_bank/1900000680_1.png")
	GUI:Button_setScale9Slice(Button_next1, 15, 15, 11, 11)
	GUI:setContentSize(Button_next1, 106, 40)
	GUI:setIgnoreContentAdaptWithSize(Button_next1, false)
	GUI:Button_setTitleText(Button_next1, "下一步")
	GUI:Button_setTitleColor(Button_next1, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_next1, 19)
	GUI:Button_titleEnableOutline(Button_next1, "#000000", 1)
	GUI:setAnchorPoint(Button_next1, 0.50, 0.50)
	GUI:setTouchEnabled(Button_next1, true)
	GUI:setTag(Button_next1, 141)

	-- Create Panel_agreement
	local Panel_agreement = GUI:Layout_Create(Panel_Photo, "Panel_agreement", 76.00, 86.00, 600.00, 60.00, false)
	GUI:setTouchEnabled(Panel_agreement, true)
	GUI:setTag(Panel_agreement, -1)

	-- Create CheckBox
	local CheckBox = GUI:CheckBox_Create(Panel_agreement, "CheckBox", 8.00, 48.00, "res/private/trading_bank/1900000654.png", "res/private/trading_bank/1900000655.png")
	GUI:CheckBox_setSelected(CheckBox, false)
	GUI:setAnchorPoint(CheckBox, 0.00, 1.00)
	GUI:setTouchEnabled(CheckBox, false)
	GUI:setTag(CheckBox, -1)
end
return ui