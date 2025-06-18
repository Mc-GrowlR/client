GameDataSetting = {}

local pageData = { 
    [1] = { name = "功能类" }, 
    [2] = { name = "表现类" }, 
    [3] = { name = "英雄类" }, 
    [4] = { name = "PC端配置" }, 
    [5] = { name = "客户端配置" } 
}

local itemsData = {
    [1] = {
        ["BackpackGuide"] = { name = "穿戴/拆分按钮配置", desc = "配置后Tips右上方会有穿戴/拆分的按钮显示", ui = "BackpackGuide",},
        ["autousetimes"] = { name = "自动穿戴时间设置", desc = "按配置秒数进行自动穿戴", ui = "SingleInputSetting", prefix = "时间：", suffix = "秒",},
        ["Hangxuan"] = { name = "行会宣战结盟按钮显示开关", desc = "关闭=不显示，打开=显示，默认显示", ui = "SingleSwitchSetting",},
        ["PickupTime"] = { name = "单个捡物时间间隔", desc = "配置单位: 毫秒 默认1000 (1秒=1000毫秒)", ui = "SingleInputSetting", prefix = "时间：", suffix = "豪秒",},
        ["Team_assembled"] = { name = "配置召集队伍使用的道具", desc = "配置道具IDX", ui = "SingleInputSetting", prefix = "道具IDX：", suffix = "",},
        ["zhanguxianshi"] = { name = "时装部位显示条件配置",},
        ["gameOption_WalkOnly"] = { name = "走代替跑开关", desc = "开启后走路将变为跑步形态且为1步1格，游戏速度需要调整走路间隔", ui = "SingleSwitchSetting",},
        ["isHideAuctionGuild"] = { name = "拍卖行(行会拍卖栏)显示开关", desc = "关闭后拍卖行将不再显示行会拍卖页面\n关闭=显示，打开=不显示", ui = "SingleSwitchSetting",},
        ["disHeadLookHumanoid"] = { name = "查看人形怪装备开关", desc = "关闭后无法查看人形怪装备\n关闭=可以查看\n打开=禁止查看", ui = "SingleSwitchSetting",},
        ["CHATCDS"] = { name = "聊天信息发送内容时间间隔", desc = "其中喊话M2-参数设置-信息控制-喊话间隔上可以设置", ui = "CHATCDS",},
        ["MobileChannelNotShow"] = { name = "手机端隐藏相关频道配置", desc = "设置后将不在聊天频道中显示该选项", ui = "MobileChannelNotShow",},
        ["monster_hp_count"] = { name = "怪物大血条显示数量设置", desc = "血条数量显示，总血量÷设置血量=条数\ncfg_monster.xls表27列nBigTips字段大于0开启大血条", ui = "SingleInputSetting", prefix = "单条血量设置：", suffix = "",},
        ["off_horse_launch"] = { name = "骑马状态是否施法", desc = "\n开启 = 不能释放技能\n关闭 = 自动魔法盾", ui = "SingleSwitchSetting", prefix = "是否施法：", suffix = "",},
        ["horse_down"] = { name = "骑马状态下有攻击动作时自动下马", desc = "\n开启 = 下马\n关闭 = 不下马", ui = "SingleSwitchSetting", prefix = "是否下马：", suffix = "",},
        ["DropTypeShow"] = {isNew = true, name = "掉落分类配置", desc = "设置后将在聊天掉落频道显示", ui = "DropTypeShow",},
        ["ShowFakeDropType"] = {isNew = true, name = "假掉落配置开关", desc = "配置后将在聊天掉落频道显示，纯客户端显示", ui = "ShowFakeDropType"},
        ["pk_mode_lock"] = {isNew = true, name = "任何攻击模式可攻击开关", desc = "配置后任何模式下都可攻击任何人或者怪，非敌人不掉血", ui = "SingleSwitchSetting", prefix = "", suffix = "",},
        ["check_guild_color"] = {isNew = true, name = "行会联盟颜色", desc = "非FIGHT3和沙巴克地图区域也需检测行会联盟颜色", ui = "SingleSwitchSetting", prefix = "", suffix = "",},
    },
    [2] = {
        ["currency_shield"] = { name = "屏蔽货币消耗提示", desc = "添加并勾选要屏蔽的货币显示ID", ui = "CurrencyShield" },
        ["noDigMonsters"] = { name = "隐藏挖取怪物图标", desc = "配置需要隐藏该图标的怪物IDX", ui = "NoDigMonsters",},
        ["HumanPaperback"] = { name = "人物简装外观显示", desc = "配置需要的外观显示ID", ui = "HumanPaperback",},
        ["MonsterPaperback"] = { name = "怪物简装外观显示", desc = "配置需要的怪物模型显示ID", ui = "SingleInputSetting", prefix = "怪物模型ID：", suffix = "",},
        ["EXPcoordinate"] = { name = "经验显示坐标位置", desc = "获得经验时显示的文字信息位置", ui = "ExpCoordinate",},
        ["StallName"] = { name = "修改摆摊名称", desc = "示例：<$USERNAME>的摊位", ui = "SingleInputSetting", prefix = "修改摆摊名称(支持变量)", suffix = "", inputString = 1,},
        ["MiniMap"] = { name = "调整小地图大小", desc = "仅支持手机端", ui = "MiniMapSetting",},
        ["itemSacle"] = { name = "道具缩放配置", desc = "仅针对道具的item图标，特效无效\n放大20%，填写1.2\n缩小20%，填写0.8", ui = "ItemScale" },
        ["Monsterlevel"] = { name = "显示怪物等级", desc = "内挂勾选职业等级，是否显示怪物等级", ui = "SingleSwitchSetting",},
        ["staticSacle"] = { name = "剑甲内观缩放", desc = "移动端默认1.44，PC端1.0", ui = "StaticScale" },
        ["setTipsFontSizeVspace"] = { name = "配置TIPS字体大小及上下间隔", desc = "间隔单位为像素点，根据自身需要适当调整", ui = "SetTipsFontSizeVspace" },
        ["ItemLock"] = { name = "配置绑定物品图标显示", desc = "只能选择其中一种", ui = "ItemLock" },
        ["itemGroundSacle"] = { name = "掉落物缩放比例", desc = "放大20%，填写1.2\n缩小20，填写0.8", ui = "SingleInputSetting", prefix = "缩放比例：", suffix = "", inputString = 1, checkNum = 1,},
        ["missionControl"] = { name = "任务内容智能屏蔽", desc = "当任务面板中存在脚本增加的内容或自定义按钮时则会自动隐藏相关任务文字内容，关闭=不隐藏，打开=隐藏", ui = "SingleSwitchSetting",},
        ["attr_not_hint"] = { name = "不飘字属性配置", desc = "勾选后将不显示该伤害类型的头顶飘字\n读取客户端cfg_att_score.lua表", ui = "AttrNotHint" },
        ["NeedResetPosWithChat"] = { name = "隐藏聊天窗口UI", desc = "快捷栏下滑至屏幕底部，其它为直接隐藏，支持QF触发，相关触发请在说明书查看 \"隐藏聊天窗\"", ui = "NeedResetPosWithChat" },
        ["sceneFontSize"] = { name = "手机端场景字大小", desc = "", ui = "SingleInputSetting", prefix = "字号：", suffix = "", checkNum = 1,},
        ["sceneFontSize_pc"] = { name = "PC端场景字大小", desc = "", ui = "SingleInputSetting", prefix = "字号：", suffix = "", checkNum = 1,},
        ["NoShowItemDropEff"] = { name = "物品掉落弹起效果", desc = "关闭=有弹起，打开=禁止弹起", ui = "SingleSwitchSetting",},
        ["disBuffHideEffect"] = { name = "取消隐身半透明效果", desc = "如佩戴隐身戒指时，角色将不显示半透明效果", ui = "SingleSwitchSetting",},
        ["CancelDefaultMiniMap"] = { name = "右上角小地图显示", desc = "无小地图时是否显示一张黑色小地图，关闭=显示，打开=不显示", ui = "SingleSwitchSetting",},
        ["tipsButtonOut"] = { name = "TIPS按钮位置在外框显示", desc = "如穿戴、拆分、使用等按钮", ui = "SingleSwitchSetting",},
        ["ShowBuffList"] = {isNew = true, name = "BUFF图标显示位置", desc = "服务端data目录下cfg_buff.xls表第25列必须设置为\"1\"才有效\n收缩图标：滑动方向为横向, 收缩方向必须为往左或右收缩;   滑动方向为纵向, 收缩方向必须为往上或下.  ", ui = "ShowBuffList",},
        ["itemTypeName"] = { name = "自定义道具类型名称", desc = "例如将31类改为道具，41类改为材料", ui = "SetItemTypeName"},
        ["tips_star_custom"] = { name = "配置强化星星样式", desc = "自定义星星样式，支持特效显示，例：999颗星星则显示为9颗百位星星+9颗十位星星+9颗个位星星", ui = "TipsStarCustom",},
        ["WeaponLooksOrderUp"] = { name = "武器外观层级配置", desc = "武器外观显示在衣服外层", ui = "WeaponLooksOrderUp",},
        ["goods_item_star_styleid"] = { name = "装备强化自定义数字显示", desc = "强化道具图标显示强化次数文字的位置及颜色", ui = "GoodsItemStarStyleid"},
        ["ChatShowInterval"] = { name = "聊天和富文本行间距", desc = "调整聊天和富文本行间距", ui = "ChatShowInterval"},
        ["hideRankHeadCapShow"] = { name = "排行榜斗笠头盔显示", desc = "排行榜斗笠头盔(0=显示，1=不显示)", ui = "SingleSwitchSetting",},
        ["RankDesc"] = { name = "排行榜排序数值的后缀描述", desc = "排行榜排序数值的后缀描述", ui = "RankSetDesc",},
        ["Hide_Select_Collection"] = { name = "隐藏采集怪弹窗", desc = "开启：隐藏弹窗，关闭：显示弹窗", ui = "SingleSwitchSetting"},
        ["MobileMainMaxChatNum"] = { name = "手机端主界面聊天栏最大显示条数", desc = "主界面聊天栏最大7条", ui = "SingleInputSetting", prefix = "显示条数：", checkNum = 1},
        ["NGEXPcoordinate"] = { name = "内功经验显示坐标", desc = "PC端X坐标#PC端Y坐标|移动端X坐标#移动端Y坐标|字体颜色#字体描边颜色|最低内功经验显示", ui = "NGEXPcoordinate" },
        ["setTipsAttrTitle"] = { name = "Tips属性配置", desc = "Tips属性配置", ui = "TipsAttrSetting",},    
        ["dark"] = { name = "是否开启黑夜系统", desc = "\n打开：开启黑夜模式\n关闭：不开启黑夜模式", ui = "SingleSwitchSetting",},
        ["HideNGHUD"] = { name = "是否隐藏人物内力黄条", desc = "是否隐藏人物内力黄条(0=不隐藏,1=隐藏)\n限内功客户端下有效", ui = "SingleSwitchSetting",},
        ["RedPointValue"] = { name = "自定义变量刷新", desc = "1.服务推送变量，需要引擎M2-功能设置-其他设置-前端变量推送里填写，变量名参考M2。\n2.填写物品Idx，获取物品数量，如：获取元宝数量，变量名填2。无需M2设置。", ui = "RedPointValueSet" },
        ["Redtips"] = { name = "界面红点提示图片设置", desc = "界面红点提示图片设置(PC端|移动端)", ui = "RedTipsPath" },  
        ["auto_set_topHat_posY"] = { name = "顶戴显示位置", desc = "顶戴显示位置", ui = "SingleSwitchSetting" },     
        ["PCAssistNearShow"] = { name = "PC端导航栏开启附近按钮", desc = "关闭=不显示\n打开=显示", ui = "SingleSwitchSetting" },  
        ["RechargeNum"] = { name = "充值界面修改最大充值和最小充值金额", desc = "\n最大充值金额maxRecharge\n最小充值金额minRecharge", ui = "RechargeNum" },  
        ["TradingBankHideSUI"] = { isNew = true, name = "隐藏交易行自定义装备按钮", desc = "关闭=不显示\n打开=显示", ui = "SingleSwitchSetting" },  
        ["AutoMoveRange_Collection"] = { name = "采集距离", desc = "采集距离,用于采集怪使用，超出距离采集时会自动寻路到此范围内", ui = "SingleInputSetting", prefix = "采集距离：", checkNum = 1},        
		["FindDropItemRange"] = { isNew = true, name = "自动捡取范围识别配置", desc = "自动捡取范围识别配置,默认值:12", ui = "SingleInputSetting", prefix = "拾取范围:", checkNum = 1},
        ["check_skill_neighbors"] = { isNew = true, name = "内挂群体技能新方式", desc = "关闭=不开启\n打开=群怪才放群体技能", ui = "SingleSwitchSetting" },  
        ["FontAtlasAntialiasEnabled"] = { isNew = true, name = "PC端抗锯齿模式", desc = "关闭=不开启\n打开=开启（推荐开启）", ui = "SingleSwitchSetting" },  
		["DEFAULT_FONT_SIZE"] = { isNew = true, name = "配置字体大小设置", desc = "游戏里90%以上字体大小会根据这个改变", ui = "SingleInputSetting", prefix = "字体大小:", checkNum = 1},
        ["ShowSkillCDTime"] = { isNew = true, name = "开启技能按钮数字CD显示", desc = "关闭=不开启\n打开=开启", ui = "SingleSwitchSetting" },  
		["bangdingguize"] = { isNew = true, name = "物品绑定规则", desc = "模式1：1#2#3(包含#分割=物品有一个绑定规则时显示锁图标与已绑定标记)\n模式2：1&2&3(满足&分割物品有全部绑定规则时显示锁图标与已绑定标记)", ui = "SingleInputSetting", prefix = "配置:", inputString = 1},
		["prompt"] = { isNew = true, name = "背包满物品提示红点", desc = "(聚灵珠(大)提示红点(PC端#X坐标#Y坐标#缩放比例|移动端#X坐标#Y坐标#缩放比例)\n(res/public/btn_npcfh_04.png#5#1#0.6|res/public/btn_npcfh_04.png#10#-7#1)", ui = "RedBagPromptPath"},
        ["itemShowModel"] = { isNew = true, name = "开启Tips剑甲展示", desc = "关闭=不开启\n打开=开启", ui = "SingleSwitchSetting" },  
        ["DivideWeaponAndClothes"] = { isNew = true, name = "开启人物内观剑甲物品框", desc = "关闭=不开启\n打开=开启", ui = "SingleSwitchSetting" },
        ["TipsCombineExAddShow"]  = { isNew = true, name = "Tips批量附加属性显示规则", desc = "配置按不同方式显示\n说明：本功能仅针对SETADDNEWABIL命令进行显示区分", ui = "TipsCombineExAddShow" },     
        ["Fashionfx"]  = { isNew = true, name = "时装裸模展示", desc = "展示裸模(打开=不展示，关闭=展示)", ui = "SingleSwitchSetting" },     
        ["hight_main_player_hp"]  = { isNew = true, name = "主玩家血条高亮，显示绿色血条", desc = "高亮血条(打开=显示，关闭=不显示)", ui = "SingleSwitchSetting" },     
        ["showOrinalEffec"] = { isNew = true, name = "SETITEMEFFECT命令修改的内观特效", desc="打开=同时显示表配置和修改, 关闭=修改覆盖表配置", ui = "SingleSwitchSetting" },
        ["boxtexiao"] = { isNew = true, name = "开宝箱相关特效配置", desc = "开宝箱相关特效配置", ui = "Boxtexiao"},
        ["SUI_FONT_PATH"] = { isNew = true, name = "脚本NPC界面字体配置", desc = "脚本NPC界面字体文件路径统一配置, 例如填: fonts/font1.ttf", ui = "SingleInputSetting", prefix = "文件路径：", suffix = "", inputString = 1},
        ["MailFormatType"]  = { isNew = true, name = "邮件内容富文本类别配置", desc = "开启则使用富文本, 例：<font color='#ffff00' size='16'>TTT</font> \n 不开启默认格式(原始富文本)：\n<TTT/FCOLOR=251>", ui = "SingleSwitchSetting" },   
        ["MonsterDieHideAnim"]  = { isNew = true, name = "配置怪物死亡后隐藏身上特效", desc = "开启表示 怪物死亡尸体没消失前 不显示身上BUFF特效", ui = "SingleSwitchSetting" },   

    },
    [3] = {
        ["Heroqiehuan"] = { name = "英雄状态配置", desc = "最低配置3种状态", ui = "Heroqiehuan" },
        ["Heroqiehuanmoshi"] = { name = "英雄状态切换方式", desc = "二选一", ui = "Heroqiehuanmoshi" },
        ["Heronuqitiao"] = { name = "英雄怒气条样式", desc = "二选一", ui = "Heronuqitiao" },
        ["heroLoginBtnoffset"] = { name = "英雄显示面板智能偏移", desc = "英雄头像和按钮都在左边，刘海屏幕是否按钮一起偏移", ui = "SingleSwitchSetting" },
        ["HeroStateHideWithAssist"] = { name = "英雄显示界面跟随任务栏隐藏显示而变动", desc = "关闭=不变动，打开=变动", ui = "SingleSwitchSetting" },
        ["firstHeroAutoUse"] = { isNew = true, name = "优先英雄穿戴装备", desc = "关闭=优先玩家，打开=优先英雄\n注：需要在M2-英雄设置上开启人物英雄背包互通", ui = "SingleSwitchSetting" },
    },
    [4] = {
        ["OpenAuctionByP"] = { name = "拍卖行快捷键\"P\"键", desc = "关闭=开启，打开=禁止", ui = "SingleSwitchSetting" },
        ["bag_row_col_max"] = { name = "大背包格子设置", desc = "需替换原有PC端背包资源", ui = "SetBagRowColMax"},
        ["bag_storage_row_col_max"] = { name = "大仓库格子设置", desc = "需替换原有PC端仓库资源", ui = "SetStorageRowColMax"},
        ["PCShowSelectChannels"] = { name = "聊天频道切换按钮", desc = "配置好后玩家无需输入特殊命令操作", ui = "PCShowSelectChannels" },
        ["PCMainMiniMapSize"] = { name = "不使用二级小地图", desc = "不使用二级小地图后相关二级地图尺寸将无效", ui = "PCMainMiniMapSize" },
        ["Texture2DAntialiasEnabled"] = { name = "图片文字抗锯齿", desc = "开启抗锯齿图片将表现比较圆滑，但可能会有些糊", ui = "SingleSwitchSetting" },
        ["pc_tips_attr_alignment"] = { name = "TIPS文字与数值之间距离间隔", desc = "推荐设置30", ui = "SingleInputSetting", prefix = "像素点：", suffix = "", },
        ["monster_force_show_hp"] = { name = "鼠标移至怪物身上显示血量", desc = "鼠标移至怪物身上显示血量开关，带有极品怪物血量的不推荐开启", ui = "SingleSwitchSetting" },
        ["skill_move_main"] = { name = "技能拖拽至屏幕中", desc = "", ui = "SingleSwitchSetting" },
        ["PCPropertyNotAdapet"] = { name = "PC聊天是否不拉伸", desc = "开启后聊天不拉伸", ui = "SingleSwitchSetting" },
        ["FontAtlasAntialiasEnabled"] = { name = "PC文字抗锯齿", desc = "PC-开启字体抗锯齿将表现比较圆滑，但可能会有些糊", ui = "SingleSwitchSetting" },
        ["PCSwitchChannelShow"] = { isNew = true, name = "PC切换接收频道区域展示", desc = "PC切换接收频道区域展示", ui = "SingleSwitchSetting" },
        ["HudNotUseBmpFont"] = { isNew = true, name = "HUD不使用BMFont字体", desc = "打开 = 不使用，关闭 = 使用", ui = "SingleSwitchSetting" },
		["PCFontConfig"] = { isNew = true, name = "PC端字体类型和大小", desc = "2#12字体#大小(字体：1黑体 2宋体   大小：0默认 大于0为字体大小)", ui = "PCFontTypeSize" },
        ["PCMapCenterOffset"] = {isNew = true, name = "PC端地图中心点偏移坐标", desc = "偏移x|偏移y (官方默认偏移x: -22, y: -80)", ui = "PCMapCenterOffset"},
    },
    [5] = {
        ["OpenNGUI"] = { name = "内功客户端", desc = "内功客户端(关闭,开启)", ui = "SingleSwitchSetting" },
        ["syshero"] = { name = "英雄客户端", desc = "英雄客户端(关闭,开启)", ui = "SingleSwitchSetting" },
        ["playerInfoMode"] = { name = "英雄装备界面二合一", desc = "英雄装备界面(关=分开界面,开=二合一界面)", ui = "SingleSwitchSetting" },
        ["isShowAttributeTips"] = { name = "是否显示属性飘字", desc = "是否显示属性飘字(关=不显示,开=显示)", ui = "SingleSwitchSetting" },
        ["isHideAuctionGuild"] = { name = "是否隐藏行会拍卖行", desc = "是否隐藏行会拍卖行(关=不隐藏,开=隐藏)", ui = "SingleSwitchSetting" },
        ["isSingleJob"] = { name = "是否单职业", desc = "是否单职业(关=否,开=是)", ui = "SingleSwitchSetting" },
        ["isSingleSex"] = { name = "是否单性别", desc = "是否单性别(关=否,开=是)", ui = "SingleSwitchSetting" },
        ["isRandomJob"] = { name = "标识开启随机职业", desc = "标识开启随机职业(关=不随机,开=随机)\n单职业开启时,无效", ui = "SingleSwitchSetting" },
        ["isRandomSex"] = { name = "标识开启随机性别", desc = "标识开启随机性别(关=不随机,开=随机)\n单性别开启时,无效", ui = "SingleSwitchSetting" },
        ["buttonSmall"] = { name = "重进游戏等待时间", desc = "大于0有时间等待", ui = "SingleInputSetting", prefix = "时间：", suffix = "毫秒",},
        ["MultipleJobSet"] = {isNew = true, name = "多职业客户端", desc = "菜单选择每个职业相关配置编辑\n每个职业都是独立控制，开启后生效！\n字母标识：显示在血条上面的职业简称，比如/Z40,战士40级", ui = "MultipleJobSet"},
    }, 
}

local function getIdxByKey(key)
    local finalIndex = nil
    for index, items in ipairs(itemsData) do
        if items[key] then
            finalIndex = index
            break
        end
    end
    return finalIndex
end

local _allNameStr = ""   --模糊搜索的名字格式 <name&key><name&key>
local _blurT = {}
local _searchIndex = 1
local _markSearchStr = ""
for k, v in ipairs(itemsData) do
    local one = ""
    for kk, vv in pairs(v) do
        local keyLower = string.lower(kk)
        local nameStr = "<" .. vv.name .. "&" .. kk .. "&" .. keyLower .. ">"
        one = one .. nameStr
    end
    _allNameStr = _allNameStr .. one
end

local function GetBlurNames(str)
    local names = {}
    if string.len(str) > 0 then
        for w in string.gmatch(_allNameStr, "<([^<>]-" .. str .. "+" .. "[^<>]-)>") do
            local split = string.split(w, "&")
            local key = split[2]
            if key then
                table.insert(names, key)
            end
        end
    end

    dump(names, "names:::::"..str)

    return names
end

function GameDataSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data_setting")

    GameDataSetting._ui = GUI:ui_delegate(parent)
    GameDataSetting.Node_ui_cur = GameDataSetting._ui["Node_ui_cur"]
    GameDataSetting.Node_desc_name = GameDataSetting._ui["Node_desc_name"]
    GameDataSetting.Node_desc_content = GameDataSetting._ui["Node_desc_content"]
    GameDataSetting.ListView_items = GameDataSetting._ui["ListView_items"]
    GUI:ListView_addMouseScrollPercent(GameDataSetting.ListView_items)

    GameDataSetting._pages = {}
    GameDataSetting._index = 0
    GameDataSetting._itemIndex = 0
    GameDataSetting._searchStr = nil

    GameDataSetting.initPages()

    -- 默认跳到第一个
    GameDataSetting.pageTo(1)

    GameDataSetting.Input_search = GameDataSetting._ui["Input_search"]
    GUI:TextInput_addOnEvent(GameDataSetting.Input_search, function(sender, eventType)
        local function search(inputStr)
            if getIdxByKey(inputStr) then
                _blurT[1] = inputStr
                _searchIndex = 1
            else
                if _markSearchStr ~= inputStr then
                    _markSearchStr = inputStr
                    _blurT = GetBlurNames(inputStr)
                    _searchIndex = 1
                end
            end

            GameDataSetting.onBtnSearch(_blurT, _searchIndex)
        end
        if eventType == 1 then
            local inputStr = sender:getString()
            search(inputStr)
        elseif eventType == 2 then
            local str = sender:getString()
            if sender.closeKeyboard and string.find(str, "\n") then
                sender:closeKeyboard()
                sender:setString(string.trim(str))
                local inputStr = sender:getString()
                search(inputStr)
            end
        end
    end)

    local Button_search = GameDataSetting._ui["Button_search"]
    GUI:addOnClickEvent(Button_search, function()
        _searchIndex = _searchIndex + 1
        if _searchIndex > #_blurT then
            _searchIndex = 1
        end
        GameDataSetting.onBtnSearch(_blurT, _searchIndex)
    end) 
end

function GameDataSetting.initPages()    -- 配置类别
    local ListView_page = GameDataSetting._ui["ListView_page"]
    for k, v in ipairs(pageData) do
        local pageCell = GameDataSetting.createPageCell()
        GUI:Win_SetParam(pageCell, k)
        GUI:addOnClickEvent(pageCell, function()
            GameDataSetting._searchStr = nil
            GameDataSetting.pageTo(k)
        end)
        local PageText = GUI:getChildByName(pageCell, "PageText")
        GUI:Text_setTextHorizontalAlignment(PageText, 1)
        GUI:Text_setString(PageText, v.name)
        GameDataSetting._pages["pageCell" .. k] = pageCell
        GUI:ListView_pushBackCustomItem(ListView_page, pageCell)
    end
end

function GameDataSetting.createPageCell()
    local parent = GUI:Node_Create(GameDataSetting._ui["nativeUI"], "node", 0, 0)
    loadConfigSettingExport(parent, "game_data/page_cell")
    local page_cell = GUI:getChildByName(parent, "page_cell")
    GUI:removeFromParent(page_cell)
    GUI:removeFromParent(parent)
    return page_cell
end

function GameDataSetting.pageTo(index)
    if GameDataSetting._index == index and not GameDataSetting._searchStr then
        return
    end

    GameDataSetting._index = index

    for _, uiPage in pairs(GameDataSetting._pages) do
        local index = GUI:Win_GetParam(uiPage)
        local isSel = index == GameDataSetting._index and true or false
        GUI:Layout_setBackGroundColor(uiPage, isSel and "#ffbf6b" or "#000000")
    end

    GameDataSetting.updateItems()
end

function GameDataSetting.updateItems()  -- 配置字段Item
    local data = itemsData[GameDataSetting._index]
    if not data then
        return
    end

    local keys = table.keys(data)
    table.sort(keys, function(a, b)
        return string.upper(a) < string.upper(b)
    end)

    GUI:ListView_removeAllItems(GameDataSetting.ListView_items)

    local jumpIdx = 1
    for k, v in ipairs(keys) do
        local itemUI = GameDataSetting.createItemCell()
        GUI:Text_setString(itemUI["Text_index"], k)
        GUI:Text_setString(itemUI["Text_key"], v)
        GUI:Text_setString(itemUI["Text_name"], data[v].name or "")
        GUI:Win_SetParam(itemUI["nativeUI"], { index = k, key = v, data = data[v] })
        GUI:setVisible(itemUI["Image_new"], data[v].isNew or false)
        GUI:addOnClickEvent(itemUI["nativeUI"], function()
            GameDataSetting._searchStr = nil
            GameDataSetting.onClickItem(k)
        end)
        GUI:ListView_pushBackCustomItem(GameDataSetting.ListView_items, itemUI["nativeUI"])
        if GameDataSetting._searchStr and GameDataSetting._searchStr == v then
            jumpIdx = k
        end
    end

    -- 默认跳到第一个
    GameDataSetting._itemIndex = 0
    GUI:ListView_jumpToItem(GameDataSetting.ListView_items, jumpIdx - 1)
    GameDataSetting.onClickItem(jumpIdx)
end

function GameDataSetting.createItemCell()
    local parent = GUI:Node_Create(ConfigSetting._ui["nativeUI"], "node", 0, 0)
    loadConfigSettingExport(parent, "game_data/item_cell")
    local item_cell = GUI:getChildByName(parent, "item_cell")
    GUI:removeFromParent(item_cell)
    GUI:removeFromParent(parent)
    return GUI:ui_delegate(item_cell)
end

function GameDataSetting.onClickItem(index)
    if GameDataSetting._itemIndex == index and not GameDataSetting._searchStr then
        return
    end

    GameDataSetting._itemIndex = index

    for _, item in ipairs(GUI:ListView_getItems(GameDataSetting.ListView_items)) do
        local param = GUI:Win_GetParam(item)
        if GameDataSetting._itemIndex == param.index then
            GUI:Layout_setBackGroundColor(GUI:getChildByName(item, "Layout_bg"), "#ffbf6b")
            GameDataSetting.updateResult(param)
        else
            GUI:Layout_setBackGroundColor(GUI:getChildByName(item, "Layout_bg"), "#000000")
        end
    end
end

function GameDataSetting.updateResult(param)    -- 当前配置内容
    GameDataSetting.updateDesc(param.data)
    GameDataSetting.updateCurConfig(param.key)
end

function GameDataSetting.updateDesc(descData)
    GUI:removeAllChildren(GameDataSetting.Node_desc_name)
    GUI:removeAllChildren(GameDataSetting.Node_desc_content)

    if descData then
        local richNameH = nil
        if descData.name and string.len(descData.name) > 0 then
            local richName = GUI:RichText_Create(GameDataSetting.Node_desc_name, "richName", 0, 0, "功能：" .. descData.name, 288)
            GUI:setAnchorPoint(richName, 0, 1)
            richNameH = GUI:getContentSize(richName).height
        end

        if descData.desc and string.len(descData.desc) > 0 then
            local descStr = string.gsub(descData.desc, "<", "&lt;")
            descStr = string.gsub(descStr, ">", "&gt;")
            local richContent = GUI:RichText_Create(GameDataSetting.Node_desc_content, "richContent", 0, 0, "配置：" .. descStr, 288)
            GUI:setAnchorPoint(richContent, 0, 1)
            local namePosY = GUI:getPositionY(GameDataSetting.Node_desc_name)
            GUI:setPositionY(GameDataSetting.Node_desc_content, richNameH and math.ceil(namePosY - richNameH - 10) or namePosY)
        end
    end
end

function GameDataSetting.updateCurConfig(key)   -- 当前配置UI
    GUI:removeAllChildren(GameDataSetting.Node_ui_cur)

    local pageCfg = itemsData[GameDataSetting._index]
    if pageCfg and pageCfg[key] then
        local uiName = pageCfg[key].ui
        if uiName and uiName ~= "" then
            local filePath = "game/view/layersui/test_layer/configSetting/configLayout/game_data/" .. uiName
            SL:RequireFile(filePath).main(GameDataSetting.Node_ui_cur, { key = key, config = pageCfg[key] })
        end
    end
end

function GameDataSetting.onBtnSearch(blurT, idx)
    local key = blurT[idx]
    if not key then
        SL:ShowSystemTips("未搜索到相关字段")
        return
    end

    local finalIndex = getIdxByKey(key)

    if not finalIndex then
        SL:ShowSystemTips("未搜索到相关字段")
        return
    end

    GameDataSetting._searchStr = key
    GameDataSetting.pageTo(finalIndex)
end

function GameDataSetting.close()
    print("GameDataSetting.close")
end

function SAVE_GAME_DATA(key, value)
    local game_data = SL:Require("game_config/cfg_game_data")
    local cfg = game_data[key]
    if not cfg then
        cfg = { k = key, value = value }
        game_data[key] = cfg
    else
        cfg.value = value
    end
    SL:SaveTableToConfig(game_data, "cfg_game_data", nil, nil, true)
    global.FileUtilCtl:purgeCachedEntries()
end

return GameDataSetting