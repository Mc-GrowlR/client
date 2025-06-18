local ui = {}
function ui.init(parent)
	-- Create Node
	local Node = GUI:Node_Create(parent, "Node", 0.00, 0.00)
	GUI:setAnchorPoint(Node, 0.50, 0.50)
	GUI:setTag(Node, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Node, "Panel_1", 0.00, 0.00, 1136.00, 640.00, false)
	GUI:setTouchEnabled(Panel_1, true)
	GUI:setTag(Panel_1, 41)

	-- Create Panel_touch
	local Panel_touch = GUI:Layout_Create(Panel_1, "Panel_touch", 0.00, 0.00, 1136.00, 640.00, false)
	GUI:setTouchEnabled(Panel_touch, false)
	GUI:setTag(Panel_touch, 53)

	-- Create Node_mes
	local Node_mes = GUI:Node_Create(Panel_1, "Node_mes", 880.00, 640.00)
	GUI:setAnchorPoint(Node_mes, 0.50, 0.50)
	GUI:setTag(Node_mes, 9)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Node_mes, "Image_bg", 0.08, -46.00, "res/private/title_layer_ui/title_1.png")
	GUI:Image_setScale9Slice(Image_bg, 58, 58, 15, 15)
	GUI:setContentSize(Image_bg, 248, 88)
	GUI:setIgnoreContentAdaptWithSize(Image_bg, false)
	GUI:setAnchorPoint(Image_bg, 0.00, 0.50)
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, 34)

	-- Create Panel_2
	local Panel_2 = GUI:Layout_Create(Image_bg, "Panel_2", 2.00, 2.00, 244.28, 22.00, false)
	GUI:Layout_setBackGroundColorType(Panel_2, 1)
	GUI:Layout_setBackGroundColor(Panel_2, "#000000")
	GUI:Layout_setBackGroundColorOpacity(Panel_2, 255)
	GUI:setTouchEnabled(Panel_2, false)
	GUI:setTag(Panel_2, 17)

	-- Create Text_1
	local Text_1 = GUI:Text_Create(Image_bg, "Text_1", 3.00, 14.00, 20, "#ffffff", [[X:]])
	GUI:setAnchorPoint(Text_1, 0.00, 0.50)
	GUI:setTouchEnabled(Text_1, false)
	GUI:setTag(Text_1, 10)
	GUI:Text_enableOutline(Text_1, "#000000", 1)

	-- Create Text_X
	local Text_X = GUI:Text_Create(Image_bg, "Text_X", 22.00, 14.00, 20, "#ffffff", [[1136]])
	GUI:setAnchorPoint(Text_X, 0.00, 0.50)
	GUI:setTouchEnabled(Text_X, false)
	GUI:setTag(Text_X, 14)
	GUI:Text_enableOutline(Text_X, "#000000", 1)

	-- Create Text_2
	local Text_2 = GUI:Text_Create(Image_bg, "Text_2", 86.33, 14.00, 20, "#ffffff", [[Y:]])
	GUI:setAnchorPoint(Text_2, 0.00, 0.50)
	GUI:setTouchEnabled(Text_2, false)
	GUI:setTag(Text_2, 15)
	GUI:Text_enableOutline(Text_2, "#000000", 1)

	-- Create Text_Y
	local Text_Y = GUI:Text_Create(Image_bg, "Text_Y", 107.33, 14.00, 20, "#ffffff", [[640]])
	GUI:setAnchorPoint(Text_Y, 0.00, 0.50)
	GUI:setTouchEnabled(Text_Y, false)
	GUI:setTag(Text_Y, 16)
	GUI:Text_enableOutline(Text_Y, "#000000", 1)

	-- Create Text_type
	local Text_type = GUI:Text_Create(Image_bg, "Text_type", 168.33, 14.00, 20, "#ffffff", [[103左下]])
	GUI:setAnchorPoint(Text_type, 0.00, 0.50)
	GUI:setTouchEnabled(Text_type, false)
	GUI:setTag(Text_type, 54)
	GUI:Text_enableOutline(Text_type, "#000000", 1)

	-- Create Button_1
	local Button_1 = GUI:Button_Create(Node_mes, "Button_1", 33.00, -14.00, "Default/Button_Normal.png")
	GUI:Button_loadTextureDisabled(Button_1, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_1, 15, 15, 11, 11)
	GUI:setContentSize(Button_1, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_1, false)
	GUI:Button_setTitleText(Button_1, "")
	GUI:Button_setTitleColor(Button_1, "#000000")
	GUI:Button_setTitleFontSize(Button_1, 16)
	GUI:Button_titleDisableOutLine(Button_1)
	GUI:setAnchorPoint(Button_1, 0.50, 0.50)
	GUI:setTouchEnabled(Button_1, true)
	GUI:setTag(Button_1, 34)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_1, "Text_zi", 30.00, 9.00, 16, "#000000", [[101左上]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 43)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_6
	local Button_6 = GUI:Button_Create(Node_mes, "Button_6", 93.95, -14.00, "Default/Button_Normal.png")
	GUI:Button_loadTextureDisabled(Button_6, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_6, 15, 15, 11, 11)
	GUI:setContentSize(Button_6, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_6, false)
	GUI:Button_setTitleText(Button_6, "")
	GUI:Button_setTitleColor(Button_6, "#000000")
	GUI:Button_setTitleFontSize(Button_6, 16)
	GUI:Button_titleDisableOutLine(Button_6)
	GUI:setAnchorPoint(Button_6, 0.50, 0.50)
	GUI:setTouchEnabled(Button_6, true)
	GUI:setTag(Button_6, 35)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_6, "Text_zi", 30.00, 9.00, 16, "#000000", [[106中上]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 44)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_2
	local Button_2 = GUI:Button_Create(Node_mes, "Button_2", 154.89, -14.00, "Default/Button_Normal.png")
	GUI:Button_loadTextureDisabled(Button_2, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_2, 15, 15, 11, 11)
	GUI:setContentSize(Button_2, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_2, false)
	GUI:Button_setTitleText(Button_2, "")
	GUI:Button_setTitleColor(Button_2, "#000000")
	GUI:Button_setTitleFontSize(Button_2, 16)
	GUI:Button_titleDisableOutLine(Button_2)
	GUI:setAnchorPoint(Button_2, 0.50, 0.50)
	GUI:setTouchEnabled(Button_2, true)
	GUI:setTag(Button_2, 36)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_2, "Text_zi", 30.00, 9.00, 16, "#000000", [[102右上]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 45)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_5
	local Button_5 = GUI:Button_Create(Node_mes, "Button_5", 33.00, -34.50, "Default/Button_Normal.png")
	GUI:Button_loadTextureDisabled(Button_5, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_5, 15, 15, 11, 11)
	GUI:setContentSize(Button_5, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_5, false)
	GUI:Button_setTitleText(Button_5, "")
	GUI:Button_setTitleColor(Button_5, "#000000")
	GUI:Button_setTitleFontSize(Button_5, 16)
	GUI:Button_titleDisableOutLine(Button_5)
	GUI:setAnchorPoint(Button_5, 0.50, 0.50)
	GUI:setTouchEnabled(Button_5, true)
	GUI:setTag(Button_5, 37)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_5, "Text_zi", 30.00, 9.00, 16, "#000000", [[105左中]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 46)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_7
	local Button_7 = GUI:Button_Create(Node_mes, "Button_7", 154.89, -34.50, "Default/Button_Normal.png")
	GUI:Button_loadTextureDisabled(Button_7, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_7, 15, 15, 11, 11)
	GUI:setContentSize(Button_7, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_7, false)
	GUI:Button_setTitleText(Button_7, "")
	GUI:Button_setTitleColor(Button_7, "#000000")
	GUI:Button_setTitleFontSize(Button_7, 16)
	GUI:Button_titleDisableOutLine(Button_7)
	GUI:setAnchorPoint(Button_7, 0.50, 0.50)
	GUI:setTouchEnabled(Button_7, true)
	GUI:setTag(Button_7, 38)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_7, "Text_zi", 30.00, 9.00, 16, "#000000", [[107右中]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 47)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_3
	local Button_3 = GUI:Button_Create(Node_mes, "Button_3", 33.00, -55.00, "Default/Button_Normal.png")
	GUI:Button_loadTextureDisabled(Button_3, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_3, 15, 15, 11, 11)
	GUI:setContentSize(Button_3, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_3, false)
	GUI:Button_setTitleText(Button_3, "")
	GUI:Button_setTitleColor(Button_3, "#000000")
	GUI:Button_setTitleFontSize(Button_3, 16)
	GUI:Button_titleDisableOutLine(Button_3)
	GUI:setAnchorPoint(Button_3, 0.50, 0.50)
	GUI:setTouchEnabled(Button_3, true)
	GUI:setTag(Button_3, 39)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_3, "Text_zi", 30.00, 9.00, 16, "#000000", [[103左下]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 48)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_8
	local Button_8 = GUI:Button_Create(Node_mes, "Button_8", 93.95, -55.00, "Default/Button_Normal.png")
	GUI:Button_loadTextureDisabled(Button_8, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_8, 15, 15, 11, 11)
	GUI:setContentSize(Button_8, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_8, false)
	GUI:Button_setTitleText(Button_8, "")
	GUI:Button_setTitleColor(Button_8, "#000000")
	GUI:Button_setTitleFontSize(Button_8, 16)
	GUI:Button_titleDisableOutLine(Button_8)
	GUI:setAnchorPoint(Button_8, 0.50, 0.50)
	GUI:setTouchEnabled(Button_8, true)
	GUI:setTag(Button_8, 40)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_8, "Text_zi", 30.00, 9.00, 16, "#000000", [[108中下]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 49)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_4
	local Button_4 = GUI:Button_Create(Node_mes, "Button_4", 154.89, -55.00, "Default/Button_Normal.png")
	GUI:Button_loadTextureDisabled(Button_4, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_4, 15, 15, 11, 11)
	GUI:setContentSize(Button_4, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_4, false)
	GUI:Button_setTitleText(Button_4, "")
	GUI:Button_setTitleColor(Button_4, "#000000")
	GUI:Button_setTitleFontSize(Button_4, 16)
	GUI:Button_titleDisableOutLine(Button_4)
	GUI:setAnchorPoint(Button_4, 0.50, 0.50)
	GUI:setTouchEnabled(Button_4, true)
	GUI:setTag(Button_4, 41)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_4, "Text_zi", 30.00, 9.00, 16, "#000000", [[104右下]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 50)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_9
	local Button_9 = GUI:Button_Create(Node_mes, "Button_9", 93.45, -34.50, "Default/Button_Normal.png")
	GUI:Button_loadTextureDisabled(Button_9, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_9, 15, 15, 11, 11)
	GUI:setContentSize(Button_9, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_9, false)
	GUI:Button_setTitleText(Button_9, "")
	GUI:Button_setTitleColor(Button_9, "#000000")
	GUI:Button_setTitleFontSize(Button_9, 16)
	GUI:Button_titleDisableOutLine(Button_9)
	GUI:setAnchorPoint(Button_9, 0.50, 0.50)
	GUI:setTouchEnabled(Button_9, true)
	GUI:setTag(Button_9, 32)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_9, "Text_zi", 30.00, 9.00, 16, "#000000", [[109技能]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 33)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_close
	local Button_close = GUI:Button_Create(Node_mes, "Button_close", 215.84, -14.00, "Default/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_close, "Default/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_close, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_close, 15, 15, 11, 11)
	GUI:setContentSize(Button_close, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_close, false)
	GUI:Button_setTitleText(Button_close, "")
	GUI:Button_setTitleColor(Button_close, "#000000")
	GUI:Button_setTitleFontSize(Button_close, 16)
	GUI:Button_titleDisableOutLine(Button_close)
	GUI:setAnchorPoint(Button_close, 0.50, 0.50)
	GUI:setTouchEnabled(Button_close, true)
	GUI:setTag(Button_close, 19)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_close, "Text_zi", 30.00, 9.00, 16, "#000000", [[退出]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 51)
	GUI:Text_disableOutLine(Text_zi)

	-- Create Button_switch
	local Button_switch = GUI:Button_Create(Node_mes, "Button_switch", 215.84, -34.50, "Default/Button_Normal.png")
	GUI:Button_loadTexturePressed(Button_switch, "Default/Button_Press.png")
	GUI:Button_loadTextureDisabled(Button_switch, "Default/Button_Disable.png")
	GUI:Button_setScale9Slice(Button_switch, 15, 15, 11, 11)
	GUI:setContentSize(Button_switch, 60, 18)
	GUI:setIgnoreContentAdaptWithSize(Button_switch, false)
	GUI:Button_setTitleText(Button_switch, "")
	GUI:Button_setTitleColor(Button_switch, "#000000")
	GUI:Button_setTitleFontSize(Button_switch, 16)
	GUI:Button_titleDisableOutLine(Button_switch)
	GUI:setAnchorPoint(Button_switch, 0.50, 0.50)
	GUI:setTouchEnabled(Button_switch, true)
	GUI:setTag(Button_switch, 42)

	-- Create Text_zi
	local Text_zi = GUI:Text_Create(Button_switch, "Text_zi", 30.00, 9.00, 16, "#000000", [[切换]])
	GUI:setAnchorPoint(Text_zi, 0.50, 0.50)
	GUI:setTouchEnabled(Text_zi, false)
	GUI:setTag(Text_zi, 52)
	GUI:Text_disableOutLine(Text_zi)
end
return ui