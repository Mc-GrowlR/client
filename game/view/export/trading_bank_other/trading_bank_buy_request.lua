local ui = {}
function ui.init(parent)
	-- Create Node
	local Node = GUI:Node_Create(parent, "Node", 0.00, 0.00)
	GUI:setAnchorPoint(Node, 0.50, 0.50)
	GUI:setTag(Node, -1)

	-- Create Panel_1
	local Panel_1 = GUI:Layout_Create(Node, "Panel_1", 0.00, 0.00, 612.00, 368.00, false)
	GUI:setTouchEnabled(Panel_1, true)
	GUI:setTag(Panel_1, 89)

	-- Create Panel_2
	local Panel_2 = GUI:Layout_Create(Panel_1, "Panel_2", 0.00, 339.00, 612.00, 33.00, false)
	GUI:setTouchEnabled(Panel_2, false)
	GUI:setTag(Panel_2, 159)

	-- Create Image_1_0
	local Image_1_0 = GUI:Image_Create(Panel_2, "Image_1_0", -0.00, -1.00, "res/private/trading_bank/bg_yyxsz_01.png")
	GUI:Image_setScale9Slice(Image_1_0, 75, 75, 0, 0)
	GUI:setContentSize(Image_1_0, 610, 2)
	GUI:setIgnoreContentAdaptWithSize(Image_1_0, false)
	GUI:setAnchorPoint(Image_1_0, 0.00, 0.50)
	GUI:setTouchEnabled(Image_1_0, false)
	GUI:setTag(Image_1_0, 160)

	-- Create Image_32
	local Image_32 = GUI:Image_Create(Panel_2, "Image_32", 158.00, 15.00, "res/private/trading_bank/bg_yyxsz_02.png")
	GUI:Image_setScale9Slice(Image_32, 0, 0, 199, 199)
	GUI:setContentSize(Image_32, 2, 30)
	GUI:setIgnoreContentAdaptWithSize(Image_32, false)
	GUI:setAnchorPoint(Image_32, 0.50, 0.50)
	GUI:setTouchEnabled(Image_32, false)
	GUI:setTag(Image_32, 161)

	-- Create Image_32_0_0
	local Image_32_0_0 = GUI:Image_Create(Panel_2, "Image_32_0_0", 332.00, 15.00, "res/private/trading_bank/bg_yyxsz_02.png")
	GUI:Image_setScale9Slice(Image_32_0_0, 0, 0, 199, 199)
	GUI:setContentSize(Image_32_0_0, 2, 30)
	GUI:setIgnoreContentAdaptWithSize(Image_32_0_0, false)
	GUI:setAnchorPoint(Image_32_0_0, 0.50, 0.50)
	GUI:setTouchEnabled(Image_32_0_0, false)
	GUI:setTag(Image_32_0_0, 163)

	-- Create Image_32_0_0_0
	local Image_32_0_0_0 = GUI:Image_Create(Panel_2, "Image_32_0_0_0", 497.00, 15.00, "res/private/trading_bank/bg_yyxsz_02.png")
	GUI:Image_setScale9Slice(Image_32_0_0_0, 0, 0, 199, 199)
	GUI:setContentSize(Image_32_0_0_0, 2, 30)
	GUI:setIgnoreContentAdaptWithSize(Image_32_0_0_0, false)
	GUI:setAnchorPoint(Image_32_0_0_0, 0.50, 0.50)
	GUI:setTouchEnabled(Image_32_0_0_0, false)
	GUI:setTag(Image_32_0_0_0, 164)

	-- Create Panel_job
	local Panel_job = GUI:Layout_Create(Panel_2, "Panel_job", 0.00, 30.00, 158.00, 30.00, false)
	GUI:setAnchorPoint(Panel_job, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_job, true)
	GUI:setTag(Panel_job, 165)

	-- Create Text_jobLabel
	local Text_jobLabel = GUI:Text_Create(Panel_job, "Text_jobLabel", 83.00, 14.00, 18, "#ffffff", [[求购职业]])
	GUI:setAnchorPoint(Text_jobLabel, 0.50, 0.50)
	GUI:setTouchEnabled(Text_jobLabel, false)
	GUI:setTag(Text_jobLabel, 166)
	GUI:Text_enableOutline(Text_jobLabel, "#000000", 1)

	-- Create Image_8
	local Image_8 = GUI:Image_Create(Panel_job, "Image_8", 126.00, 13.00, "res/private/trading_bank/word_jiaoyh_017.png")
	GUI:setAnchorPoint(Image_8, 0.50, 0.50)
	GUI:setTouchEnabled(Image_8, false)
	GUI:setTag(Image_8, 167)

	-- Create Panel_level
	local Panel_level = GUI:Layout_Create(Panel_2, "Panel_level", 159.00, 30.00, 172.00, 30.00, false)
	GUI:setAnchorPoint(Panel_level, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_level, true)
	GUI:setTag(Panel_level, 177)

	-- Create Text_levelLabel
	local Text_levelLabel = GUI:Text_Create(Panel_level, "Text_levelLabel", 86.00, 14.00, 18, "#ffffff", [[求购等级]])
	GUI:setAnchorPoint(Text_levelLabel, 0.50, 0.50)
	GUI:setTouchEnabled(Text_levelLabel, false)
	GUI:setTag(Text_levelLabel, 178)
	GUI:Text_enableOutline(Text_levelLabel, "#000000", 1)

	-- Create Panel_price
	local Panel_price = GUI:Layout_Create(Panel_2, "Panel_price", 334.00, 30.00, 160.00, 30.00, false)
	GUI:setAnchorPoint(Panel_price, 0.00, 1.00)
	GUI:setTouchEnabled(Panel_price, true)
	GUI:setTag(Panel_price, 180)

	-- Create Text_priceLabel
	local Text_priceLabel = GUI:Text_Create(Panel_price, "Text_priceLabel", 79.00, 13.00, 18, "#ffffff", [[求购价格]])
	GUI:setAnchorPoint(Text_priceLabel, 0.50, 0.50)
	GUI:setTouchEnabled(Text_priceLabel, false)
	GUI:setTag(Text_priceLabel, 181)
	GUI:Text_enableOutline(Text_priceLabel, "#000000", 1)

	-- Create Image_8
	local Image_8 = GUI:Image_Create(Panel_price, "Image_8", 123.00, 12.00, "res/private/trading_bank/word_jiaoyh_016.png")
	GUI:setAnchorPoint(Image_8, 0.50, 0.50)
	GUI:setTouchEnabled(Image_8, false)
	GUI:setTag(Image_8, 182)

	-- Create Text_3_1
	local Text_3_1 = GUI:Text_Create(Panel_2, "Text_3_1", 554.00, 14.00, 18, "#ffffff", [[操作]])
	GUI:setAnchorPoint(Text_3_1, 0.50, 0.50)
	GUI:setTouchEnabled(Text_3_1, false)
	GUI:setTag(Text_3_1, 183)
	GUI:Text_enableOutline(Text_3_1, "#000000", 1)

	-- Create ListView_2
	local ListView_2 = GUI:ListView_Create(Panel_1, "ListView_2", 306.00, 337.00, 612.00, 337.93, 1)
	GUI:ListView_setGravity(ListView_2, 5)
	GUI:setAnchorPoint(ListView_2, 0.50, 1.00)
	GUI:setTouchEnabled(ListView_2, true)
	GUI:setTag(ListView_2, 115)

	-- Create Panel_item
	local Panel_item = GUI:Layout_Create(Panel_1, "Panel_item", 308.00, 313.00, 612.00, 85.00, false)
	GUI:setAnchorPoint(Panel_item, 0.50, 1.00)
	GUI:setTouchEnabled(Panel_item, true)
	GUI:setTag(Panel_item, 116)

	-- Create Image_bg
	local Image_bg = GUI:Image_Create(Panel_item, "Image_bg", 0.00, 1.00, "res/private/trading_bank/word_jiaoyh_019.png")
	GUI:setTouchEnabled(Image_bg, false)
	GUI:setTag(Image_bg, 117)

	-- Create Image_item
	local Image_item = GUI:Image_Create(Panel_item, "Image_item", 41.00, 42.00, "res/private/trading_bank/1900000651.png")
	GUI:setAnchorPoint(Image_item, 0.50, 0.50)
	GUI:setTouchEnabled(Image_item, false)
	GUI:setTag(Image_item, 118)
	GUI:setVisible(Image_item, false)

	-- Create Image_head
	local Image_head = GUI:Image_Create(Image_item, "Image_head", 30.00, 30.00, "res/private/trading_bank/img_cost.png")
	GUI:setContentSize(Image_head, 60, 60)
	GUI:setIgnoreContentAdaptWithSize(Image_head, false)
	GUI:setAnchorPoint(Image_head, 0.50, 0.50)
	GUI:setTouchEnabled(Image_head, false)
	GUI:setTag(Image_head, 137)

	-- Create Text_job
	local Text_job = GUI:Text_Create(Panel_item, "Text_job", 74.00, 44.00, 18, "#ffffff", [[战士]])
	GUI:setAnchorPoint(Text_job, 0.50, 0.50)
	GUI:setTouchEnabled(Text_job, false)
	GUI:setTag(Text_job, 119)
	GUI:Text_enableOutline(Text_job, "#000000", 1)

	-- Create Text_level
	local Text_level = GUI:Text_Create(Panel_item, "Text_level", 242.00, 44.00, 16, "#ffffff", [[80-100]])
	GUI:setAnchorPoint(Text_level, 0.50, 0.50)
	GUI:setTouchEnabled(Text_level, false)
	GUI:setTag(Text_level, 120)
	GUI:Text_enableOutline(Text_level, "#000000", 1)

	-- Create Text_price
	local Text_price = GUI:Text_Create(Panel_item, "Text_price", 411.00, 41.00, 16, "#ffffff", [[200-1000]])
	GUI:setAnchorPoint(Text_price, 0.50, 0.50)
	GUI:setTouchEnabled(Text_price, false)
	GUI:setTag(Text_price, 122)
	GUI:Text_enableOutline(Text_price, "#000000", 1)

	-- Create Text_sell
	local Text_sell = GUI:Text_Create(Panel_item, "Text_sell", 548.00, 41.00, 16, "#00fb00", [[去寄售]])
	GUI:setAnchorPoint(Text_sell, 0.50, 0.50)
	GUI:setTouchEnabled(Text_sell, true)
	GUI:setTag(Text_sell, 122)
	GUI:Text_enableOutline(Text_sell, "#000000", 1)
end
return ui