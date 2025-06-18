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
	local Image_bg = GUI:Image_Create(Panel_2, "Image_bg", 568.00, 319.00, "res/private/trading_bank_other/img_suggestBg.png")
	GUI:setAnchorPoint(Image_bg, 0.50, 0.50)
	GUI:setTouchEnabled(Image_bg, true)
	GUI:setTag(Image_bg, 312)

	-- Create Button_submit
	local Button_submit = GUI:Button_Create(Image_bg, "Button_submit", 377.00, 37.00, "res/public/btn_push_short.png")
	GUI:Button_setTitleText(Button_submit, "提交")
	GUI:Button_setTitleColor(Button_submit, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_submit, 16)
	GUI:Button_titleEnableOutline(Button_submit, "#000000", 1)
	GUI:setAnchorPoint(Button_submit, 0.50, 0.50)
	GUI:setTouchEnabled(Button_submit, true)
	GUI:setTag(Button_submit, 330)

	-- Create Button_close
	local Button_close = GUI:Button_Create(Image_bg, "Button_close", 285.00, 37.00, "res/public/btn_push_short.png")
	GUI:Button_setTitleText(Button_close, "关闭")
	GUI:Button_setTitleColor(Button_close, "#f8e6c6")
	GUI:Button_setTitleFontSize(Button_close, 16)
	GUI:Button_titleEnableOutline(Button_close, "#000000", 1)
	GUI:setAnchorPoint(Button_close, 0.50, 0.50)
	GUI:setTouchEnabled(Button_close, true)
	GUI:setTag(Button_close, 330)

	-- Create Text_question_type
	local Text_question_type = GUI:Text_Create(Image_bg, "Text_question_type", 29.00, 256.00, 18, "#f8e6c6", [[问题类型：]])
	GUI:setTouchEnabled(Text_question_type, false)
	GUI:setTag(Text_question_type, -1)
	GUI:Text_enableOutline(Text_question_type, "#000000", 1)

	-- Create Image_selectBg
	local Image_selectBg = GUI:Image_Create(Image_bg, "Image_selectBg", 118.00, 254.00, "res/private/trading_bank_other/img_listBg.png")
	GUI:Image_setScale9Slice(Image_selectBg, 10, 10, 10, 10)
	GUI:setContentSize(Image_selectBg, 250, 28)
	GUI:setIgnoreContentAdaptWithSize(Image_selectBg, false)
	GUI:setTouchEnabled(Image_selectBg, true)
	GUI:setTag(Image_selectBg, -1)

	-- Create Image_arrow
	local Image_arrow = GUI:Image_Create(Image_selectBg, "Image_arrow", 225.00, 7.00, "res/private/trading_bank_other/img_arrow.png")
	GUI:setTouchEnabled(Image_arrow, false)
	GUI:setTag(Image_arrow, -1)

	-- Create ScrollView
	local ScrollView = GUI:ScrollView_Create(Image_selectBg, "ScrollView", 3.00, 25.00, 215.00, 24.00, 1)
	GUI:ScrollView_setBounceEnabled(ScrollView, true)
	GUI:ScrollView_setInnerContainerSize(ScrollView, 215.00, 26.00)
	GUI:setAnchorPoint(ScrollView, 0.00, 1.00)
	GUI:setTouchEnabled(ScrollView, true)
	GUI:setTag(ScrollView, -1)

	-- Create Text_select
	local Text_select = GUI:Text_Create(ScrollView, "Text_select", 0.00, 26.00, 16, "#ffffff", [[请选择]])
	GUI:setAnchorPoint(Text_select, 0.00, 1.00)
	GUI:setTouchEnabled(Text_select, false)
	GUI:setTag(Text_select, -1)
	GUI:Text_enableOutline(Text_select, "#000000", 1)

	-- Create Text_question_desc
	local Text_question_desc = GUI:Text_Create(Image_bg, "Text_question_desc", 29.00, 192.00, 18, "#f8e6c6", [[问题描述：]])
	GUI:setTouchEnabled(Text_question_desc, false)
	GUI:setTag(Text_question_desc, -1)
	GUI:Text_enableOutline(Text_question_desc, "#000000", 1)

	-- Create Image_desctBg
	local Image_desctBg = GUI:Image_Create(Image_bg, "Image_desctBg", 120.00, 216.00, "res/private/trading_bank_other/img_listBg.png")
	GUI:Image_setScale9Slice(Image_desctBg, 58, 57, 9, 10)
	GUI:setContentSize(Image_desctBg, 300, 150)
	GUI:setIgnoreContentAdaptWithSize(Image_desctBg, false)
	GUI:setAnchorPoint(Image_desctBg, 0.00, 1.00)
	GUI:setTouchEnabled(Image_desctBg, false)
	GUI:setTag(Image_desctBg, -1)

	-- Create Input_desc
	local Input_desc = GUI:TextInput_Create(Image_desctBg, "Input_desc", 5.00, 144.00, 290.00, 140.00, 16)
	GUI:TextInput_setString(Input_desc, "")
	GUI:TextInput_setPlaceHolder(Input_desc, "最多50字")
	GUI:TextInput_setFontColor(Input_desc, "#ffffff")
	GUI:TextInput_setMaxLength(Input_desc, 50)
	GUI:setAnchorPoint(Input_desc, 0.00, 1.00)
	GUI:setTouchEnabled(Input_desc, true)
	GUI:setTag(Input_desc, -1)

	-- Create ImageView
	local ImageView = GUI:Image_Create(Image_bg, "ImageView", 66.00, 308.00, "res/private/trading_bank_other/img_fgx.png")
	GUI:setTouchEnabled(ImageView, false)
	GUI:setTag(ImageView, -1)

	-- Create ImageView2
	local ImageView2 = GUI:Image_Create(Image_bg, "ImageView2", 110.00, 318.00, "res/private/trading_bank_other/img_suggest_title.png")
	GUI:setTouchEnabled(ImageView2, false)
	GUI:setTag(ImageView2, -1)
end
return ui