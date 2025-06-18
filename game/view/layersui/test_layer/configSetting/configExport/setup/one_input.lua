local ui = {}
function ui.init(parent)
	-- Create panel_bg
	local panel_bg = GUI:Layout_Create(parent, "panel_bg", 0.00, 0.00, 520.00, 170.00, false)
	GUI:setTouchEnabled(panel_bg, true)
	GUI:setTag(panel_bg, -1)

	-- Create bg_input
	local bg_input = GUI:Image_Create(panel_bg, "bg_input", 82.00, 138.00, "res/public/1900015004.png")
	GUI:Image_setScale9Slice(bg_input, 0, 0, 0, 0)
	GUI:setContentSize(bg_input, 80, 26)
	GUI:setIgnoreContentAdaptWithSize(bg_input, false)
	GUI:setTouchEnabled(bg_input, false)
	GUI:setTag(bg_input, -1)

	-- Create prefix
	local prefix = GUI:Text_Create(bg_input, "prefix", -7.00, 13.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(prefix, 1.00, 0.50)
	GUI:setTouchEnabled(prefix, false)
	GUI:setTag(prefix, -1)
	GUI:Text_enableOutline(prefix, "#000000", 1)

	-- Create input
	local input = GUI:TextInput_Create(bg_input, "input", 0.00, 1.00, 76.00, 25.00, 16)
	GUI:TextInput_setString(input, "")
	GUI:TextInput_setFontColor(input, "#ffffff")
	GUI:setTouchEnabled(input, true)
	GUI:setTag(input, -1)

	-- Create suffix
	local suffix = GUI:Text_Create(bg_input, "suffix", 89.00, 13.00, 14, "#ffffff", [[]])
	GUI:setAnchorPoint(suffix, 0.00, 0.50)
	GUI:setTouchEnabled(suffix, false)
	GUI:setTag(suffix, -1)
	GUI:Text_enableOutline(suffix, "#000000", 1)
end
return ui