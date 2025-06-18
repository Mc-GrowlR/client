
SLDefine = {}

------------------------------------------------------------------------------------------------------------------------

LUA_EVENT_ROLE_PROPERTY_INITED      = "LUA_EVENT_ROLE_PROPERTY_INITED"          -- 玩家角色属性初始化完毕
LUA_EVENT_ROLE_PROPERTY_CHANGE      = "LUA_EVENT_ROLE_PROPERTY_CHANGE"          -- 玩家属性变化时

LUA_EVENT_LEVELCHANGE               = "LUA_EVENT_LEVELCHANGE"                   -- 等级改变
LUA_EVENT_REINLEVELCHANGE           = "LUA_EVENT_REINLEVELCHANGE"               -- 转生等级改变
LUA_EVENT_HPMPCHANGE                = "LUA_EVENT_HPMPCHANGE"                    -- HP/MP改变
LUA_EVENT_EXPCHANGE                 = "LUA_EVENT_EXPCHANGE"                     -- EXP改变
LUA_EVENT_BATTERYCHANGE             = "LUA_EVENT_BATTERYCHANGE"                 -- 电池电量改变
LUA_EVENT_NETCHANGE                 = "LUA_EVENT_NETCHANGE"                     -- 网络状态改变
LUA_EVENT_WEIGHTCHANGE              = "LUA_EVENT_WEIGHTCHANGE"                  -- 负重改变

LUA_EVENT_PKMODECHANGE              = "LUA_EVENT_PKMODECHANGE"                  -- pk模式改变

LUA_EVENT_AFKBEGIN                  = "LUA_EVENT_AFKBEGIN"                      -- 自动挂机开始
LUA_EVENT_AFKEND                    = "LUA_EVENT_AFKEND"                        -- 自动挂机结束
LUA_EVENT_AUTOMOVEBEGIN             = "LUA_EVENT_AUTOMOVEBEGIN"                 -- 自动寻路开始
LUA_EVENT_AUTOMOVEEND               = "LUA_EVENT_AUTOMOVEEND"                   -- 自动寻路结束
LUA_EVENT_AUTOPICKBEGIN             = "LUA_EVENT_AUTOPICKBEGIN"                 -- 自动捡物开始
LUA_EVENT_AUTOPICKEND               = "LUA_EVENT_AUTOPICKEND"                   -- 自动捡物结束

LUA_EVENT_MAINBUFFUPDATE            = "LUA_EVENT_MAINBUFFUPDATE"                -- 主玩家buff刷新
LUA_EVENT_BUFFUPDATE                = "LUA_EVENT_BUFFUPDATE"                    -- 通用buff刷新

LUA_EVENT_TALKTONPC                 = "LUA_EVENT_TALKTONPC"                     -- 与NPC对话

LUA_EVENT_CHANGESCENE               = "LUA_EVENT_CHANGESCENE"                   -- 切换地图(包含同地图)
LUA_EVENT_MAPINFOCHANGE             = "LUA_EVENT_MAPINFOCHANGE"                 -- 切换地图(不同地图)
LUA_EVENT_MAPINFOINIT               = "LUA_EVENT_MAPINFOINIT"                   -- 初始化地图
LUA_EVENT_MAP_STATE_CHANGE          = "LUA_EVENT_MAP_STATE_CHANGE"              -- 地图状态改变
LUA_EVENT_MAP_SIEGEAREA_CHANGE      = "LUA_EVENT_MAP_SIEGEAREA_CHANGE"          -- 是否进入攻城区域状态改变

LUA_EVENT_OPENWIN                   = "LUA_EVENT_OPENWIN"                       -- 打开界面(已添加)
LUA_EVENT_CLOSEWIN                  = "LUA_EVENT_CLOSEWIN"                      -- 关闭界面

LUA_EVENT_WINDOW_CHANGE             = "LUA_EVENT_WINDOW_CHANGE"                 -- 窗体尺寸改变时
LUA_EVENT_DEVICE_ROTATION_CHANGED   = "LUA_EVENT_DEVICE_ROTATION_CHANGED"       -- 设备方向改变

LUA_EVENT_MONEYCHANGE               = "LUA_EVENT_MONEYCHANGE"                   -- 货币变化时

LUA_EVENT_GUILD_MAIN_INFO           = "LUA_EVENT_GUILD_MAIN_INFO"               -- 行会信息
LUA_EVENT_GUILD_CREATE              = "LUA_EVENT_GUILD_CREATE"                  -- 行会创建
LUA_EVENT_GUILD_WORLDLIST           = "LUA_EVENT_GUILD_WORLDLIST"               -- 世界行会列表
LUA_EVENT_GUILD_APPLYLIST           = "LUA_EVENT_GUILD_APPLYLIST"               -- 入会申请列表
LUA_EVENT_GUILDE_ALLY_APPLY_UPDATE  = "LUA_EVENT_GUILDE_ALLY_APPLY_UPDATE"      -- 结盟列表

LUA_EVENT_TRADE_MONEY_CHANGE        = "LUA_EVENT_TRADE_MONEY_CHANGE"            -- 对方交易货币改变
LUA_EVENT_TRADE_MY_MONEY_CHANGE     = "LUA_EVENT_TRADE_MY_MONEY_CHANGE"         -- 自己交易货币改变
LUA_EVENT_TRADE_STATUS_CHANGE       = "LUA_EVENT_TRADE_STATUS_CHANGE"           -- 对方交易状态改变
LUA_EVENT_TRADE_MY_STATUS_CHANGE    = "LUA_EVENT_TRADE_MY_STATUS_CHANGE"        -- 自己交易状态改变

LUA_EVENT_ADDFIREND                 = "LUA_EVENT_ADDFIREND"                     -- 添加好友
LUA_EVENT_REMFIREND                 = "LUA_EVENT_REMFIREND"                     -- 删除好友

LUA_EVENT_JOINTEAM                  = "LUA_EVENT_JOINTEAM"                      -- 加入队伍
LUA_EVENT_LEAVETEAM                 = "LUA_EVENT_LEAVETEAM"                     -- 离开队伍

LUA_EVENT_REF_ITEM_LIST             = "LUA_EVENT_REF_ITEM_LIST"                 -- 刷新道具列表         背包
LUA_EVENT_PLAYER_EQUIP_CHANGE       = "LUA_EVENT_PLAYER_EQUIP_CHANGE"           -- 角色装备数据操作
LUA_EVENT_BAG_ITEM_CHANGE           = "LUA_EVENT_BAG_ITEM_CHANGE"               -- 背包数据发生变化时

LUA_EVENT_REF_HERO_ITEM_LIST        = "LUA_EVENT_REF_HERO_ITEM_LIST"            -- 刷新道具列表         英雄背包
LUA_EVENT_HERO_EQUIP_CHANGE         = "LUA_EVENT_HERO_EQUIP_CHANGE"             -- 英雄装备变化
LUA_EVENT_HERO_BAG_ITEM_CAHNGE      = "LUA_EVENT_HERO_BAG_ITEM_CAHNGE"

LUA_EVENT_DISCONNECT                = "LUA_EVENT_DISCONNECT"                    -- 断线
LUA_EVENT_RECONNECT                 = "LUA_EVENT_RECONNECT"                     -- 重连

LUA_EVENT_TAKE_ON_EQUIP             = "LUA_EVENT_TAKE_ON_EQUIP"                 -- 玩家穿戴装备
LUA_EVENT_TAKE_OFF_EQUIP            = "LUA_EVENT_TAKE_OFF_EQUIP"                -- 玩家脱掉装备

LUA_EVENT_HERO_TAKE_ON_EQUIP        = "LUA_EVENT_HERO_TAKE_ON_EQUIP"            -- 英雄穿戴装备
LUA_EVENT_HERO_TAKE_OFF_EQUIP       = "LUA_EVENT_HERO_TAKE_OFF_EQUIP"           -- 英雄脱掉装备

LUA_EVENT_SETTING_CAHNGE            = "LUA_EVENT_SETTING_CAHNGE"                -- 设置项发生变化

LUA_EVENT_BESTRINGBOX_STATE         = "LUA_EVENT_BESTRINGBOX_STATE"             -- 首饰盒状态变化
LUA_EVENT_HERO_BESTRINGBOX_STATE    = "LUA_EVENT_HERO_BESTRINGBOX_STATE"        -- 英雄首饰盒状态变化

LUA_EVENT_ACTOR_IN_OF_VIEW          = "LUA_EVENT_ACTOR_IN_OF_VIEW"              -- 进视野
LUA_EVENT_ACTOR_OUT_OF_VIEW         = "LUA_EVENT_ACTOR_OUT_OF_VIEW"             -- 出视野

LUA_EVENT_DROPITEM_IN_OF_VIEW       = "LUA_EVENT_DROPITEM_IN_OF_VIEW"           -- 掉落物进视野
LUA_EVENT_DROPITEM_OUT_OF_VIEW      = "LUA_EVENT_DROPITEM_OUT_OF_VIEW"          -- 掉落物出视野

LUA_EVENT_TARGET_HP_CHANGE          = "LUA_EVENT_TARGET_HP_CHANGE"              -- 目标血量变化
LUA_EVENT_TARGET_CAHNGE             = "LUA_EVENT_TARGET_CAHNGE"                 -- 目标发生变化 
LUA_EVENT_ACTOR_OWNER_CHANGE        = "LUA_EVENT_ACTOR_OWNER_CHANGE"            -- 归属变化

LUA_EVENT_HERO_ANGER_CAHNGE         = "LUA_EVENT_HERO_ANGER_CAHNGE"             -- 英雄怒气改变 

LUA_EVENT_PLAYER_BEHAVIOR_STATE_CAHNGE = "LUA_EVENT_PLAYER_BEHAVIOR_STATE_CAHNGE"  -- 玩家行为状态改变（站立、走、跑等） 
LUA_EVENT_PLAYER_ACTION_BEGIN       = "LUA_EVENT_PLAYER_ACTION_BEGIN"           -- 主玩家行为状态改变（站立、走、跑等） 
LUA_EVENT_PLAYER_ACTION_COMPLETE    = "LUA_EVENT_PLAYER_ACTION_COMPLETE"        -- 主玩家行为状态改变（站立、走、跑等） 
LUA_EVENT_NET_PLAYER_ACTION_BEGIN   = "LUA_EVENT_NET_PLAYER_ACTION_BEGIN"       -- 网络玩家行为状态改变（站立、走、跑等） 
LUA_EVENT_NET_PLAYER_ACTION_COMPLETE= "LUA_EVENT_NET_PLAYER_ACTION_COMPLETE"    -- 网络玩家行为状态改变（站立、走、跑等） 
LUA_EVENT_MONSTER_ACTION_BEGIN      = "LUA_EVENT_MONSTER_ACTION_BEGIN"          -- 怪物行为状态改变（站立、走、跑等） 
LUA_EVENT_MONSTER_ACTION_COMPLETE   = "LUA_EVENT_MONSTER_ACTION_COMPLETE"       -- 怪物行为状态改变（站立、走、跑等） 
LUA_EVENT_ACTOR_GMDATA_UPDATE       = "LUA_EVENT_ACTOR_GMDATA_UPDATE"           -- 玩家/怪物 GM数据改变

LUA_EVENT_SKILL_INIT                = "LUA_EVENT_SKILL_INIT"                    -- 初始化技能
LUA_EVENT_SKILL_ADD                 = "LUA_EVENT_SKILL_ADD"                     -- 获得技能
LUA_EVENT_SKILL_DEL                 = "LUA_EVENT_SKILL_DEL"                     -- 删除技能
LUA_EVENT_SKILL_UPDATE              = "LUA_EVENT_SKILL_UPDATE"                  -- 更新技能
LUA_EVENT_SKILL_ONOFF               = "LUA_EVENT_SKILL_ONOFF"                   -- 开关型技能开关触发

LUA_EVENT_HERO_SKILL_ADD            = "LUA_EVENT_HERO_SKILL_ADD"                -- 英雄新增普通技能
LUA_EVENT_HERO_SKILL_DEL            = "LUA_EVENT_HERO_SKILL_DEL"                -- 英雄删除普通技能

LUA_EVENT_SKILL_ADD_TO_UI_WIN32 	= "LUA_EVENT_SKILL_ADD_TO_UI_WIN32" 		-- 添加技能到界面
LUA_EVENT_SKILL_REMOVE_TO_UI_WIN32  = "LUA_EVENT_SKILL_REMOVE_TO_UI_WIN32"		-- 从界面删除技能
LUA_EVENT_SKILL_POSITION_UPDATE_WIN32= "LUA_EVENT_SKILL_POSITION_UPDATE_WIN32"  -- 界面技能按钮位置刷新
LUA_EVENT_SKILL_CD_TIME_CHANGE 		= "LUA_EVENT_SKILL_CD_TIME_CHANGE" 			-- 技能cd倒计时

LUA_EVENT_SUMMON_MODE_CHANGE        = "LUA_EVENT_SUMMON_MODE_CHANGE"            -- 召唤物 状态改变
LUA_EVENT_SUMMON_ALIVE_CHANGE       = "LUA_EVENT_SUMMON_ALIVE_CHANGE"           -- 召唤物 存活状态改变

LUA_EVENT_BUBBLETIPS_STATUS_CHANGE  = "LUA_EVENT_BUBBLETIPS_STATUS_CHANGE"      -- 气泡状态改变
LUA_EVENT_PLAY_MAGICBALL_EFFECT     = "LUA_EVENT_PLAY_MAGICBALL_EFFECT"         -- 脚本魔血球动画
LUA_EVENT_AUTOFIGHT_TIPS_SHOW       = "LUA_EVENT_AUTOFIGHT_TIPS_SHOW"           -- 自动战斗提示显示与否
LUA_EVENT_AUTOMOVE_TIPS_SHOW        = "LUA_EVENT_AUTOMOVE_TIPS_SHOW"            -- 自动寻路提示显示与否
LUA_EVENT_AUTOPICK_TIPS_SHOW        = "LUA_EVENT_AUTOPICK_TIPS_SHOW"            -- 自动捡物提示显示与否
LUA_EVENT_HERO_LOGIN_OROUT          = "LUA_EVENT_HERO_LOGIN_OROUT"              -- 英雄登录/登出
LUA_EVENT_REIN_ATTR_CHANGE          = "LUA_EVENT_REIN_ATTR_CHANGE"              -- 转生点数据变化

LUA_EVENT_ASSIST_HIDESTATUS_CHANGE  = "LUA_EVENT_ASSIST_HIDESTATUS_CHANGE"      -- 主界面-任务栏显示和收缩状态改变
LUA_EVENT_ASSIST_MISSION_TOP        = "LUA_EVENT_ASSIST_MISSION_TOP"            -- 主界面-辅助-任务置顶
LUA_EVENT_ASSIST_MISSION_ADD        = "LUA_EVENT_ASSIST_MISSION_ADD"            -- 主界面-辅助-任务增加
LUA_EVENT_ASSIST_MISSION_CHANGE     = "LUA_EVENT_ASSIST_MISSION_CHANGE"         -- 主界面-辅助-任务改变
LUA_EVENT_ASSIST_MISSION_REMOVE     = "LUA_EVENT_ASSIST_MISSION_REMOVE"         -- 主界面-辅助-任务移除
LUA_EVENT_ASSIST_MISSION_SHOW       = "LUA_EVENT_ASSIST_MISSION_SHOW"           -- 主界面-辅助-任务显示和隐藏
LUA_EVENT_TEAM_MEMBER_UPDATE        = "LUA_EVENT_TEAM_MEMBER_UPDATE"            -- 主界面-辅助-队伍刷新
LUA_EVENT_TEAM_NEAR_UPDATE          = "LUA_EVENT_TEAM_NEAR_UPDATE"              -- 附近队伍刷新
LUA_EVENT_TEAM_APPLY_UPDATE         = "LUA_EVENT_TEAM_APPLY_UPDATE"             -- 申请入队列表刷新

LUA_EVENT_RANK_PLAYER_UPDATE        = "LUA_EVENT_RANK_PLAYER_UPDATE"            -- 排行榜个人数据刷新
LUA_EVENT_RANK_DATA_UPDATE          = "LUA_EVENT_RANK_DATA_UPDATE"              -- 排行榜分类数据刷新

LUA_EVENT_BIND_MAINPLAYER           = "LUA_EVENT_BIND_MAINPLAYER"               -- 绑定主玩家
LUA_EVENT_PLAYER_MAPPOS_CHANGE      = "LUA_EVENT_PLAYER_MAPPOS_CHANGE"          -- 主玩家位置改变

LUA_EVENT_FRIEND_LIST_UPDATE        = "LUA_EVENT_FRIEND_LIST_UPDATE"            -- 好友列表刷新
LUA_EVENT_FRIEND_APPLY              = "LUA_EVENT_FRIEND_APPLY"                  -- 好友申请

LUA_EVENT_MAIL_UPDATE               = "LUA_EVENT_MAIL_UPDATE"                   -- 邮件列表刷新

LUA_EVENT_ITEMTIPS_MOUSE_SCROLL     = "LUA_EVENT_ITEMTIPS_MOUSE_SCROLL"         -- ITEMTIPS鼠标滚轮滚动

LUA_EVENT_PCMINIMAP_STATUS_CHANGE   = "LUA_EVENT_PCMINIMAP_STATUS_CHANGE"       -- PC 主界面小地图展示状态改变

LUA_EVENT_MAIN_PLAYER_REVIVE        = "LUA_EVENT_MAIN_PLAYER_REVIVE"            -- 主玩家复活            
LUA_EVENT_NET_PLAYER_REVIVE         = "LUA_EVENT_NET_PLAYER_REVIVE"             -- 网络玩家复活
LUA_EVENT_MONSTER_REVIVE            = "LUA_EVENT_MONSTER_REVIVE"                -- 怪物复活

LUA_EVENT_MAIN_PLAYER_DIE           = "LUA_EVENT_MAIN_PLAYER_DIE"               -- 主玩家死亡
LUA_EVENT_NET_PLAYER_DIE            = "LUA_EVENT_NET_PLAYER_DIE"                -- 网络玩家死亡
LUA_EVENT_MONSTER_DIE               = "LUA_EVENT_MONSTER_DIE"                   -- 怪物死亡

LUA_EVENT_NPCLAYER_OPENSTATUS       = "LUA_EVENT_NPCLAYER_OPENSTATUS"           -- NPC界面打开或关闭
LUA_EVENT_NPC_TALK                  = "LUA_EVENT_NPC_TALK"                      -- NPC 说话 (打开NPC界面)

LUA_EVENT_BESTRONG_POS_REFRESH      = "LUA_EVENT_BESTRONG_POS_REFRESH"          -- 变强按钮位置刷新

LUA_EVENT_ITEM_CUSTOM_ATTR          = "LUA_EVENT_ITEM_CUSTOM_ATTR"              -- 物品自定义属性

-- 人物内功
LUA_EVENT_PLAYER_INTERNAL_FORCE_CHANGE  = "LUA_EVENT_PLAYER_INTERNAL_FORCE_CHANGE"  -- 内力值改变
LUA_EVENT_PLAYER_INTERNAL_EXP_CHANGE    = "LUA_EVENT_PLAYER_INTERNAL_EXP_CHANGE"    -- 内功经验值改变
LUA_EVENT_PLAYER_INTERNAL_LEVEL_CHANGE  = "LUA_EVENT_PLAYER_INTERNAL_LEVEL_CHANGE"  -- 内功等级改变
LUA_EVENT_INTERNAL_SKILL_ADD            = "LUA_EVENT_INTERNAL_SKILL_ADD"            -- 内功技能增加
LUA_EVENT_INTERNAL_SKILL_DEL            = "LUA_EVENT_INTERNAL_SKILL_DEL"            -- 内功技能删除
LUA_EVENT_INTERNAL_SKILL_UPDATE         = "LUA_EVENT_INTERNAL_SKILL_UPDATE"         -- 内功技能刷新
LUA_EVENT_PLAYER_LEARNED_INTERNAL       = "LUA_EVENT_PLAYER_LEARNED_INTERNAL"       -- 人物学习内功

LUA_EVENT_MERIDIAN_DATA_REFRESH         = "LUA_EVENT_MERIDIAN_DATA_REFRESH"         -- 内功经络数据刷新
LUA_EVENT_PLAYER_INTERNAL_DZVALUE_CHANGE= "LUA_EVENT_PLAYER_INTERNAL_DZVALUE_CHANGE"-- 内功斗转值改变/恢复

LUA_EVENT_PLAYER_COMBO_SKILL_ADD        = "LUA_EVENT_PLAYER_COMBO_SKILL_ADD"        -- 人物连击技能增加
LUA_EVENT_PLAYER_COMBO_SKILL_DEL        = "LUA_EVENT_PLAYER_COMBO_SKILL_DEL"        -- 人物连击技能删除
LUA_EVENT_PLAYER_COMBO_SKILL_UPDATE     = "LUA_EVENT_PLAYER_COMBO_SKILL_UPDATE"     -- 人物连击技能刷新
LUA_EVENT_PLAYER_SET_COMBO_REFRESH      = "LUA_EVENT_PLAYER_SET_COMBO_REFRESH"      -- 人物设置连击技能刷新
LUA_EVENT_PLAYER_COMBO_SKILLCD_STATE    = "LUA_EVENT_PLAYER_COMBO_SKILLCD_STATE"    -- 人物连击技能CD状态
LUA_EVENT_PLAYER_OPEN_COMBO_NUM         = "LUA_EVENT_PLAYER_OPEN_COMBO_NUM"         -- 人物开启连击个数

-- 英雄内功
LUA_EVENT_HERO_INTERNAL_FORCE_CHANGE    = "LUA_EVENT_HERO_INTERNAL_FORCE_CHANGE"    -- 内力值改变
LUA_EVENT_HERO_INTERNAL_EXP_CHANGE      = "LUA_EVENT_HERO_INTERNAL_EXP_CHANGE"      -- 内功经验值改变
LUA_EVENT_HERO_INTERNAL_LEVEL_CHANGE    = "LUA_EVENT_HERO_INTERNAL_LEVEL_CHANGE"    -- 内功等级改变
LUA_EVENT_HERO_INTERNAL_SKILL_ADD       = "LUA_EVENT_HERO_INTERNAL_SKILL_ADD"       -- 英雄内功技能增加
LUA_EVENT_HERO_INTERNAL_SKILL_DEL       = "LUA_EVENT_HERO_INTERNAL_SKILL_DEL"       -- 英雄内功技能删除
LUA_EVENT_HERO_INTERNAL_SKILL_UPDATE    = "LUA_EVENT_HERO_INTERNAL_SKILL_UPDATE"    -- 英雄内功技能刷新
LUA_EVENT_HERO_LEARNED_INTERNAL         = "LUA_EVENT_HERO_LEARNED_INTERNAL"         -- 英雄学习内功

LUA_EVENT_HERO_MERIDIAN_DATA_REFRESH    = "LUA_EVENT_HERO_MERIDIAN_DATA_REFRESH"    -- 英雄内功经络数据刷新
LUA_EVENT_HERO_INTERNAL_DZVALUE_CHANGE  = "LUA_EVENT_HERO_INTERNAL_DZVALUE_CHANGE"  -- 内功斗转值改变/恢复

LUA_EVENT_HERO_COMBO_SKILL_ADD          = "LUA_EVENT_HERO_COMBO_SKILL_ADD"          -- 英雄连击技能增加
LUA_EVENT_HERO_COMBO_SKILL_DEL          = "LUA_EVENT_HERO_COMBO_SKILL_DEL"          -- 英雄连击技能删除
LUA_EVENT_HERO_COMBO_SKILL_UPDATE       = "LUA_EVENT_HERO_COMBO_SKILL_UPDATE"       -- 英雄连击技能刷新
LUA_EVENT_HERO_SET_COMBO_REFRESH        = "LUA_EVENT_HERO_SET_COMBO_REFRESH"        -- 英雄设置连击技能刷新
LUA_EVENT_HERO_OPEN_COMBO_NUM           = "LUA_EVENT_HERO_OPEN_COMBO_NUM"           -- 英雄开启连击个数

LUA_EVENT_HERO_PROPERTY_CHANGE          = "LUA_EVENT_HERO_PROPERTY_CHANGE"          -- 英雄属性变化

-- 小地图
LUA_EVENT_MINIMAP_FIND_PATH             = "LUA_EVENT_MINIMAP_FIND_PATH"             -- 寻路路径
LUA_EVENT_MINIMAP_MONSTER               = "LUA_EVENT_MINIMAP_MONSTER"               -- 怪物坐标
LUA_EVENT_MINIMAP_PLAYER                = "LUA_EVENT_MINIMAP_PLAYER"                -- 人物坐标
LUA_EVENT_MINIMAP_TEAM                  = "LUA_EVENT_MINIMAP_TEAM"                  -- 队伍坐标
LUA_EVENT_MINIMAP_RELEASE               = "LUA_EVENT_MINIMAP_RELEASE"               -- 释放内存

-- 消息
LUA_EVENT_NOTICE_SERVER                 = "LUA_EVENT_NOTICE_SERVER"                 -- 消息 服务 (Type4)
LUA_EVENT_NOTICE_SERVER_EVENT           = "LUA_EVENT_NOTICE_SERVER_EVENT"           -- 消息 服务 枚举值 (Type11)
LUA_EVENT_NOTICE_SYSYTEM                = "LUA_EVENT_NOTICE_SYSYTEM"                -- 消息 系统 跑马灯 (Type5)
LUA_EVENT_NOTICE_SYSYTEM_SCALE          = "LUA_EVENT_NOTICE_SYSYTEM_SCALE"          -- 消息 系统 顶端弹窗 (Type13)
LUA_EVENT_NOTICE_SYSYTEM_XY             = "LUA_EVENT_NOTICE_SYSYTEM_XY"             -- 消息 系统 设置XY 跑马灯 (Type10)
LUA_EVENT_NOTICE_SYSYTEM_TIPS           = "LUA_EVENT_NOTICE_SYSYTEM_TIPS"           -- 消息 系统 提示弹窗 警告
LUA_EVENT_NOTICE_TIMER                  = "LUA_EVENT_NOTICE_TIMER"                  -- 消息 提示 警告 (Type6)
LUA_EVENT_NOTICE_DELETE_TIMER           = "LUA_EVENT_NOTICE_DELETE_TIMER"           -- 消息 提示 警告 
LUA_EVENT_NOTICE_TIMER_XY               = "LUA_EVENT_NOTICE_TIMER_XY"               -- 消息 提示 警告 设置XY (Type14)
LUA_EVENT_NOTICE_DELETE_TIMER_XY        = "LUA_EVENT_NOTICE_DELETE_TIMER_XY"        -- 消息 提示 警告 设置XY (Type14)
LUA_EVENT_NOTICE_ITEM_TIPS              = "LUA_EVENT_NOTICE_ITEM_TIPS"              -- 飘字 物品拾取获得消耗
LUA_EVENT_NOTICE_ATTRIBUTE              = "LUA_EVENT_NOTICE_ATTRIBUTE"              -- 飘字 属性变化
LUA_EVENT_NOTICE_EXP                    = "LUA_EVENT_NOTICE_EXP"                    -- 飘字 经验值变化
LUA_EVENT_NOTICE_DROP                   = "LUA_EVENT_NOTICE_DROP"                   -- 飘字 掉落物品提示 (Type15)

-- 合成
LUA_EVENT_COMPOUND_RED_POINT            = "LUA_EVENT_COMPOUND_RED_POINT"            -- 合成红点

-- richText
LUA_EVENT_RICHTEXT_OPEN_URL             = "LUA_EVENT_RICHTEXT_OPEN_URL"             -- 富文本超链(href)点击触发

LUA_EVENT_KF_STATUS_CHANGE              = "LUA_EVENT_KF_STATUS_CHANGE"              -- 跨服状态改变
LUA_EVENT_QUICKUSE_DATA_OPER            = "LUA_EVENT_QUICKUSE_DATA_OPER"            -- 快捷栏道具数据变动触发

-- 游戏世界
LUA_EVENT_ENTER_WORLD                   = "LUA_EVENT_ENTER_WORLD"                   -- 进入游戏世界，主界面已经刷出来了
LUA_EVENT_LEAVE_WORLD                   = "LUA_EVENT_LEAVE_WORLD"                   -- 离开游戏世界 - 小退触发

-- 玩家状态刷新
LUA_EVENT_PLAYER_IN_SAFEZONE_CHANGE     = "LUA_EVENT_PLAYER_IN_SAFEZONE_CHANGE"     -- 主玩家安全区状态改变
LUA_EVENT_NET_PLAYER_IN_SAFEZONE_CHANGE = "LUA_EVENT_NET_PLAYER_IN_SAFEZONE_CHANGE" -- 网络玩家安全区状态改变

LUA_EVENT_PLAYER_STALL_STATUS_CHANGE    = "LUA_EVENT_PLAYER_STALL_STATUS_CHANGE"    -- 主玩家摆摊状态改变
LUA_EVENT_NET_PLAYER_STALL_STATUS_CHANGE= "LUA_EVENT_NET_PLAYER_STALL_STATUS_CHANGE"-- 网络玩家摆摊状态改变

LUA_EVENT_PLAYER_HUSHEN_STATUS_CHANGE       = "LUA_EVENT_PLAYER_HUSHEN_STATUS_CHANGE"       -- 主玩家护身状态改变
LUA_EVENT_NET_PLAYER_HUSHEN_STATUS_CHANGE   = "LUA_EVENT_NET_PLAYER_HUSHEN_STATUS_CHANGE"   -- 网络玩家护身状态改变

LUA_EVENT_PLAYER_TEAM_STATUS_CHANGE     = "LUA_EVENT_PLAYER_TEAM_STATUS_CHANGE"     -- 主玩家组队状态改变
LUA_EVENT_NET_PLAYER_TEAM_STATUS_CHANGE = "LUA_EVENT_NET_PLAYER_TEAM_STATUS_CHANGE" -- 网络玩家组队状态改变

-- 求购
LUA_EVENT_PURCHASE_ITEM_LIST_PULL       = "LUA_EVENT_PURCHASE_ITEM_LIST_PULL"       -- 求购列表返回
LUA_EVENT_PURCHASE_ITEM_LIST_COMPLETE   = "LUA_EVENT_PURCHASE_ITEM_LIST_COMPLETE"   -- 求购列表加载完成
LUA_EVENT_PURCHASE_SEARCH_ITEM_UPDATE   = "LUA_EVENT_PURCHASE_SEARCH_ITEM_UPDATE"   -- 求购搜索刷新
LUA_EVENT_PURCHASE_MYITEM_UPDATE        = "LUA_EVENT_PURCHASE_MYITEM_UPDATE"        -- 求购数据刷新(我的)
LUA_EVENT_PURCHASE_WORLDITEM_UPDATE     = "LUA_EVENT_PURCHASE_WORLDITEM_UPDATE"     -- 求购数据刷新(世界)

-- 红点增删 (cfg_redpoint 配置id)
LUA_EVENT_RED_POINT_ADD                 = "LUA_EVENT_RED_POINT_ADD"                 -- 增
LUA_EVENT_RED_POINT_DEL                 = "LUA_EVENT_RED_POINT_DEL"                 -- 删

LUA_EVENT_FLYIN_BTN_ITEM_COMPLETE       = "LUA_EVENT_FLYIN_BTN_ITEM_COMPLETE"       -- item飞入指定按钮完成

LUA_EVENT_STORAGE_DATA_CHANGE           = "LUA_EVENT_STORAGE_DATA_CHANGE"           -- 仓库数据变动
LUA_EVENT_HERO_LOCK_CHANGE              = "LUA_EVENT_HERO_LOCK_CHANGE"              -- 英雄锁定刷新
LUA_EVENT_PLAYER_TITLE_CHANGE           = "LUA_EVENT_PLAYER_TITLE_CHANGE"           -- 人物称号数据变化
LUA_EVENT_PLAYER_EMBATTLE_CHANGE        = "LUA_EVENT_PLAYER_EMBATTLE_CHANGE"        -- 人物法阵刷新
LUA_EVENT_PLAYER_SEX_CHANGE             = "LUA_EVENT_PLAYER_SEX_CHANGE"             -- 人物性别刷新
LUA_EVENT_HERO_EMBATTLE_CHANGE          = "LUA_EVENT_HERO_EMBATTLE_CHANGE"          -- 英雄法阵刷新
LUA_EVENT_HERO_SEX_CHANGE               = "LUA_EVENT_HERO_SEX_CHANGE"               -- 英雄性别刷新

-- 骑马
LUA_EVENT_HORSE_UP                      = "LUA_EVENT_HORSE_UP"                      -- 上马
LUA_EVENT_HORSE_DOWN                    = "LUA_EVENT_HORSE_DOWN"                    -- 下马

-- 客服会话
LUA_EVENT_MANUAL_SERVICE_MESSAGE_NEW    = "LUA_EVENT_MANUAL_SERVICE_MESSAGE_NEW"    -- 客服会话新消息
LUA_EVENT_MANUAL_SERVICE_MESSAGE_UN_READ= "LUA_EVENT_MANUAL_SERVICE_MESSAGE_UN_READ"-- 客服会话未读
LUA_EVENT_MANUAL_SERVICE_MESSAGE_CLOSE  = "LUA_EVENT_MANUAL_SERVICE_MESSAGE_CLOSE"  -- 客服会话结束

-------------------zfs begin------------------------------------------------------------------------------------
LUA_EVENT_DARK_STATE_CHANGE              = "LUA_EVENT_DARK_STATE_CHANGE"             -- 黑夜状态改变
LUA_EVENT_MONSTER_IGNORELIST_ADD         = "LUA_EVENT_MONSTER_IGNORELIST_ADD"        -- 设置 怪物忽略列表增加
LUA_EVENT_BOSSTIPSLIST_ADD               = "LUA_EVENT_BOSSTIPSLIST_ADD"              -- 设置 boss提示 增加
LUA_EVENT_MONSTER_NAME_RM                = "LUA_EVENT_MONSTER_NAME_RM"               -- 设置 怪物类型删除
LUA_EVENT_SKILL_RANKDATA_ADD             = "LUA_EVENT_SKILL_RANKDATA_ADD"            -- 设置 技能数据添加
LUA_EVENT_SKILLBUTTON_DISTANCE_CHANGE    = "LUA_EVENT_SKILLBUTTON_DISTANCE_CHANGE"   -- 技能边距调整 

LUA_EVENT_PLAYER_FRAME_PAGE_ADD          = "LUA_EVENT_PLAYER_FRAME_PAGE_ADD"         -- 角色框增加子页
LUA_EVENT_PLAYER_FRAME_NAME_RRFRESH      = "LUA_EVENT_PLAYER_FRAME_NAME_RRFRESH"     -- 角色框刷新名字

LUA_EVENT_PLAYER_LOOK_FRAME_PAGE_ADD     = "LUA_EVENT_PLAYER_LOOK_FRAME_PAGE_ADD"    -- 查看他人角色框增加子页
LUA_EVENT_PLAYER_GUILD_INFO_CHANGE       = "LUA_EVENT_PLAYER_GUILD_INFO_CHANGE"      -- 玩家行会信息改变

LUA_EVENT_HERO_FRAME_PAGE_ADD            = "LUA_EVENT_HERO_FRAME_PAGE_ADD"           -- 英雄框增加子页
LUA_EVENT_HERO_FRAME_NAME_RRFRESH        = "LUA_EVENT_HERO_FRAME_NAME_RRFRESH"       -- 英雄框刷新名字

LUA_EVENT_HERO_LOOK_FRAME_PAGE_ADD       = "LUA_EVENT_HERO_LOOK_FRAME_PAGE_ADD"      -- 查看他人英雄框增加子页

LUA_EVENT_TRAD_PLAYER_LOOK_FRAME_PAGE_ADD = "LUA_EVENT_TRADE_PLAYER_LOOK_FRAME_PAGE_ADD"    -- 交易行查看他人增加子页
LUA_EVENT_TRAD_HERO_LOOK_FRAME_PAGE_ADD   = "LUA_EVENT_TRAD_HERO_LOOK_FRAME_PAGE_ADD"       -- 交易行查看他人英雄框增加子页
LUA_EVENT_SERVER_VALUE_CHANGE             = "LUA_EVENT_SERVER_VALUE_CHANGE"                 -- 服务器下发的变量改变
-------------------zfs end------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------
-- 触发
LUA_TRIGGER_CHAT_CLICK_PLAYER_NAME      = "LUA_TRIGGER_CHAT_CLICK_PLAYER_NAME"      -- 触发，聊天点击玩家名字

LUA_TRIGGER_NOTICE_SHOW_ATTRIBUTES      = "LUA_TRIGGER_NOTICE_SHOW_ATTRIBUTES"      -- 提示通知--属性通知

LUA_TRIGGER_NOTICE_SHOW_GET_ITEM        = "LUA_TRIGGER_NOTICE_SHOW_GET_ITEM"        -- 提示通知--获得物品
LUA_TRIGGER_NOTICE_SHOW_COST_ITEM       = "LUA_TRIGGER_NOTICE_SHOW_COST_ITEM"       -- 提示通知--消耗物品

LUA_TRIGGER_NOTICE_SHOW_EXP_CHANGE      = "LUA_TRIGGER_NOTICE_SHOW_EXP_CHANGE"      -- 提示通知--经验通知

------------------------------------------------------------------------------------------------------------------------
LUA_EVENT_OPEN_SETTING_HELP_UP_LOAD_TIPS     = "LUA_EVENT_OPEN_SETTING_HELP_UP_LOAD_TIPS"      -- 打开设置帮助页面上传文字提醒
LUA_EVENT_CLOSE_SETTING_HELP_UP_LOAD_TIPS    = "LUA_EVENT_CLOSE_SETTING_HELP_UP_LOAD_TIPS"     -- 关闭设置帮助页面上传文字提醒

------------------------------------------------------------------------------------------------------------------------
-- 服务器开关
------------------------------------------------------------------------------------------------------------------------
SW_KEY_AUCTION                          = global.MMO.SERVER_OPTION_AUCTION             -- 服务器开关 拍卖
SW_KEY_ALL_FIGHTPAGES                   = global.MMO.SO_SHOW_ALL_FIGHTPAGES            -- 服务器开关 显示所有战斗页
SW_KEY_MISSTION                         = global.MMO.SERVER_OPTION_MISSTION            -- 服务器开关 任务
SW_KEY_SNDAITEMBOX                      = global.MMO.SERVER_OPTION_SNDAITEMBOX         -- 服务器开关 是否显示首饰盒
SW_KEY_TRADE_DEAL                       = global.MMO.SERVER_OPTION_TRADE_DEAL          -- 服务器开关 面对面交易 true/需要面对面
SW_KEY_AUTO_DRESS                       = global.MMO.SERVER_OPTION_AUTO_DRESS          -- 服务器开关 自动穿戴
SW_KEY_OPEN_F_EQUIP                     = global.MMO.SERVER_OPTION_OPEN_F_EQUIP        -- 服务器开关 时装是否开启首饰
SW_KEY_BIND_GOLD                        = global.MMO.SERVER_OPTION_BIND_GOLD           -- 服务器开关 开启元宝替换绑元
SW_KEY_NPC_BUTTON                       = global.MMO.SERVER_OPTION_NPC_BUTTON          -- 服务器开关 显示npc按钮
SW_KEY_NPC_NAME                         = global.MMO.SERVER_OPTION_NPC_NAME            -- 服务器开关 显示npc名字 1:不显示
SW_KEY_DROP_TIPS                        = global.MMO.SERVER_DROP_TIPS                  -- 服务器开关 显示绑定丢弃提示 0:显示
SW_KEY_EXP_IN_CHAT                      = global.MMO.SERVER_EXP_IN_CHAT                -- 服务器开关 经验信息是否显示在聊天框 0：显示在聊天框
SW_KEY_SHOW_STALL_NAME                  = global.MMO.SERVER_SHOW_STALL_NAME            -- 服务器开关 是否显示默认摊位名字  0：显示
SW_KEY_PLAYER_BLUE_BLOOD                = global.MMO.PLAYER_BLUE_BLOOD                 -- 服务器开关  是否显示蓝条HUD_SPRITE_MP   0: 显示
SW_KEY_ITEMTIPS_TOUBAO_SHOW             = global.MMO.ITEMTIPS_TOUBAO_SHOW              -- 服务器开关  是否显示itemtips的投保描述   1    = 开启 0       = 关闭
SW_KEY_BAN_DOUBLE_FIREHIT               = global.MMO.SERVER_OPTION_BAN_DOUBLE_FIREHIT  -- 服务器开关  是否禁止双烈火    1：禁止
SW_KEY_ALL_TEAM_EXP                     = global.MMO.SERVER_OPTION_ALL_TEAM_EXP        -- 服务器开关 是否开启全队经验 true/false
SW_KEY_EQUIP_EXTRA_POS     	            = global.MMO.EQUIP_EXTRA_POS	 	           -- 服务器开关，是否有额外的装备位置  1= 开启 0 = 关闭
SW_KEY_NO_SELL_MONEY                    = global.MMO.SERVER_NO_SELL_MONEY              -- 服务器开关，是否禁止交易货币  true = 禁止
------------------------------------------------------------------------------------------------------------------------


SLDefine.LUAFile = 
{
    LUA_FILE_MAIN_LEFTTOP       = "GUILayout/MainLeftTop",          -- 主界面 左上
    LUA_FILE_MAIN_RIGHTTOP      = "GUILayout/MainRightTop",         -- 主界面 右上
    LUA_FILE_MAIN_LEFTBOTTOM    = "GUILayout/MainLeftBottom",       -- 主界面 左下
    LUA_FILE_MAIN_RIGHTBOTTOM   = "GUILayout/MainRightBottom",      -- 主界面 右下
    LUA_FILE_MAIN_MINIMAP       = "GUILayout/MainMiniMap",          -- 主界面 小地图
    LUA_FILE_MAIN_ASSIST        = "GUILayout/MainAssist",           -- 主界面 导航栏
    LUA_FILE_MAIN_PROPERTY      = "GUILayout/MainProperty",         -- 主界面 属性栏
    LUA_FILE_MAIN_SKILL         = "GUILayout/MainSkill",            -- 主界面 技能/按钮
    LUA_FILE_MAIN_TARGET        = "GUILayout/MainTarget",           -- 主界面 目标栏
    LUA_FILE_MAIN_TOP           = "GUILayout/MainTop",              -- 主界面 最上方
    LUA_FILE_MAIN_DIG           = "GUILayout/MainDig",              -- 主界面 尸体挖掘
    LUA_FILE_MAIN_SUMMONS       = "GUILayout/MainSummons",          -- 主界面 召唤物
    LUA_FILE_MAIN_COLLECT       = "GUILayout/MainCollect",          -- 主界面 采集怪

    LUA_FILE_MAIN_PROPERTY_WIN32= "GUILayout/MainProperty_win32",   -- PC 主界面 属性栏
    LUA_FILE_MAIN_ASSIST_WIN32  = "GUILayout/MainAssist_win32",     -- PC 导航栏
    LUA_FILE_MAIN_MINIMAP_WIN32 = "GUILayout/MainMiniMap_win32",    -- PC 主界面小地图

    LUA_FILE_MAIN_NEAR          = "GUILayout/MainNear",             -- 附近列表展示

    LUA_FILE_LOGINROLE          = "GUILayout/LoginRolePanel",

    LUA_FILE_MAIN_BUFFLIST      = "GUILayout/MainBuffList",         -- 主界面BUFF列表（配置显示

    LUA_FILE_MAIN_SKILL_WIN32   = "GUILayout/MainSkill_win32", 		-- PC主界面技能按钮

    -------------------zfs begin------------------------------------------------------------------------------------
    LUA_FILE_SETTINGFRAME                       = "GUILayout/SettingFrame",             -- 设置 外框
    LUA_FILE_SETTING_BASIC                      = "GUILayout/SettingBasic",             -- 设置 基础
    LUA_FILE_SETTING_WINRANGE                   = "GUILayout/SettingWinRange",          -- 设置 视距
    LUA_FILE_SETTING_LAUNCH                     = "GUILayout/SettingLaunch",            -- 设置 战斗
    LUA_FILE_SETTING_PROTECT                    = "GUILayout/SettingProtect",           -- 设置 保护
    LUA_FILE_SETTING_PROTECTSET                 = "GUILayout/SettingProtectSetting",    -- 设置 保护相关设置
    LUA_FILE_SETTING_AUTO                       = "GUILayout/SettingAuto",              -- 设置 自动
    LUA_FILE_SETTING_SKILL_RANK                 = "GUILayout/SettingSkillRank",         -- 设置 技能优先级
    LUA_FILE_SETTING_SKILL_PANEl                = "GUILayout/SettingSkillPanel",        -- 设置 技能
    LUA_FILE_SETTING_PICK_SETTING               = "GUILayout/SettingPickSetting",       -- 设置 拾取
    LUA_FILE_SETTING_PICK_SETTING_WIN32         = "GUILayout/SettingPickSetting_win32", -- 设置 拾取

    LUA_FILE_SETTING_ADDMONSTERNAME             = "GUILayout/SettingAddMonsterName",    -- 设置 增加怪物name
    LUA_FILE_SETTING_ADDMONSTERTYPE             = "GUILayout/SettingAddMonsterType",    -- 设置 增加怪物type
    LUA_FILE_SETTING_BOSSTIPS                   = "GUILayout/SettingBossTips",          -- 设置 增加boss提醒
    LUA_FILE_SETTING_HELP                       = "GUILayout/SettingHelp",              -- 设置 帮助
    LUA_FILE_SETTINGFRAME_WIN32                 = "GUILayout/SettingFrame_win32",       -- 设置 外框
    LUA_FILE_SETTING_BASIC_WIN32                = "GUILayout/SettingBasic_win32",       -- 设置 基础
    LUA_FILE_SETTING_LAUNCH_WIN32               = "GUILayout/SettingLaunch_win32",      -- 设置 战斗
    LUA_FILE_SETTING_PROTECT_WIN32              = "GUILayout/SettingProtect_win32",     -- 设置 保护
    LUA_FILE_SETTING_AUTO_WIN32                 = "GUILayout/SettingAuto_win32",        -- 设置 自动
    LUA_FILE_SETTING_HELP_WIN32                 = "GUILayout/SettingHelp_win32",        -- 设置 帮助

    LUA_FILE_PLAYER_FRAME                       = "GUILayout/PlayerFrame",                      -- 人物面板外框
    LUA_FILE_PLAYER_EQUIP                       = "GUILayout/PlayerEquip",                      -- 装备
    LUA_FILE_PLAYER_BASE_ATT                    = "GUILayout/PlayerBaseAtt",                    -- 基础属性
    LUA_FILE_PLAYER_EXTRA_ATT                   = "GUILayout/PlayerExtraAtt",                   -- 额外属性
    LUA_FILE_PLAYER_SKILL                       = "GUILayout/PlayerSkill",                      -- 技能
    LUA_FILE_PLAYER_SUPER_EQUIP                 = "GUILayout/PlayerSuperEquip",                 -- 神装
    LUA_FILE_PLAYER_TITLE                       = "GUILayout/PlayerTitle",                      -- 称号
    LUA_FILE_PLAYER_BESTRING                    = "GUILayout/PlayerBestRing",                   -- 生肖
    LUA_FILE_PLAYER_BUFF                        = "GUILayout/PlayerBuff",                       -- BUFF
    LUA_FILE_PLAYER_SKILL_SETTING               = "GUILayout/PlayerSkillSetting",               -- 技能设置
    LUA_FILE_PLAYER_FRAME_WIN32                 = "GUILayout/PlayerFrame_win32",                -- win32 人物面板外框
    LUA_FILE_PLAYER_EQUIP_WIN32                 = "GUILayout/PlayerEquip_win32",                -- win32 装备
    LUA_FILE_PLAYER_BASE_ATT_WIN32              = "GUILayout/PlayerBaseAtt_win32",              -- win32 基础属性
    LUA_FILE_PLAYER_EXTRA_ATT_WIN32             = "GUILayout/PlayerExtraAtt_win32",             -- win32 额外属性
    LUA_FILE_PLAYER_SKILL_WIN32                 = "GUILayout/PlayerSkill_win32",                -- win32 技能
    LUA_FILE_PLAYER_SUPER_EQUIP_WIN32           = "GUILayout/PlayerSuperEquip_win32",           -- win32 神装
    LUA_FILE_PLAYER_TITLE_WIN32                 = "GUILayout/PlayerTitle_win32",                -- win32 称号
    LUA_FILE_PLAYER_BESTRING_WIN32              = "GUILayout/PlayerBestRing_win32",             -- win32 生肖
    LUA_FILE_PLAYER_SKILL_SETTING_WIN32         = "GUILayout/PlayerSkillSetting_win32",         -- win32 技能设置

    LUA_FILE_PLAYER_INTERNAL_STATE              = "GUILayout/PlayerInternalState",              -- 内功状态
    LUA_FILE_PLAYER_INTERNAL_SKILL              = "GUILayout/PlayerInternalSkill",              -- 内功技能
    LUA_FILE_PLAYER_INTERNAL_MERIDIAN           = "GUILayout/PlayerInternalMeridian",           -- 内功经络
    LUA_FILE_PLAYER_INTERNAL_COMBO              = "GUILayout/PlayerInternalCombo",              -- 内功连击

    LUA_FILE_PLAYER_LOOK_FRAME                  = "GUILayout/PlayerFrame_Look",                 -- 查看他人人物面板外框
    LUA_FILE_PLAYER_LOOK_EQUIP                  = "GUILayout/PlayerEquip_Look",                 -- 查看他人装备
    LUA_FILE_PLAYER_LOOK_SUPER_EQUIP            = "GUILayout/PlayerSuperEquip_Look",            -- 查看他人神装
    LUA_FILE_PLAYER_LOOK_TITLE                  = "GUILayout/PlayerTitle_Look",                 -- 查看他人称号 
    LUA_FILE_PLAYER_LOOK_BESTRING               = "GUILayout/PlayerBestRing_Look",              -- 查看他人生肖
    LUA_FILE_PLAYER_LOOK_FRAME_WIN32            = "GUILayout/PlayerFrame_Look_win32",           -- win32 查看他人人物面板外框
    LUA_FILE_PLAYER_LOOK_EQUIP_WIN32            = "GUILayout/PlayerEquip_Look_win32",           -- win32 查看他人装备
    LUA_FILE_PLAYER_LOOK_SUPER_EQUIP_WIN32      = "GUILayout/PlayerSuperEquip_Look_win32",      -- win32 查看他人神装
    LUA_FILE_PLAYER_LOOK_TITLE_WIN32            = "GUILayout/PlayerTitle_Look_win32",           -- win32 查看他人称号
    LUA_FILE_PLAYER_LOOK_BESTRING_WIN32         = "GUILayout/PlayerBestRing_Look_win32",        -- win32 查看他人生肖
    LUA_FILE_PLAYER_LOOK_BUFF                   = "GUILayout/PlayerBuff_Look",

    LUA_FILE_HERO_FRAME                         = "GUILayout/HeroFrame",                        -- 英雄主界面
    LUA_FILE_HERO_EQUIP                         = "GUILayout/HeroEquip",                        -- 装备
    LUA_FILE_HERO_BASE_ATT                      = "GUILayout/HeroBaseAtt",                      -- 基础属性
    LUA_FILE_HERO_EXTRA_ATT                     = "GUILayout/HeroExtraAtt",                     -- 额外属性
    LUA_FILE_HERO_SKILL                         = "GUILayout/HeroSkill",                        -- 技能
    LUA_FILE_HERO_SUPER_EQUIP                   = "GUILayout/HeroSuperEquip",                   -- 神装
    LUA_FILE_HERO_TITLE                         = "GUILayout/HeroTitle",                        -- 称号
    LUA_FILE_HERO_BESTRING                      = "GUILayout/HeroBestRing",                     -- 生肖
    LUA_FILE_HERO_BUFF                          = "GUILayout/HeroBuff",                         -- BUFF
    LUA_FILE_HERO_FRAME_WIN32                   = "GUILayout/HeroFrame_win32",                  -- win32 英雄主界面
    LUA_FILE_HERO_EQUIP_WIN32                   = "GUILayout/HeroEquip_win32",                  -- win32 装备
    LUA_FILE_HERO_BASE_ATT_WIN32                = "GUILayout/HeroBaseAtt_win32",                -- win32 基础属性
    LUA_FILE_HERO_EXTRA_ATT_WIN32               = "GUILayout/HeroExtraAtt_win32",               -- win32 额外属性
    LUA_FILE_HERO_SKILL_WIN32                   = "GUILayout/HeroSkill_win32",                  -- win32 技能
    LUA_FILE_HERO_SUPER_EQUIP_WIN32             = "GUILayout/HeroSuperEquip_win32",             -- win32 神装
    LUA_FILE_HERO_TITLE_WIN32                   = "GUILayout/HeroTitle_win32",                  -- win32 称号
    LUA_FILE_HERO_BESTRING_WIN32                = "GUILayout/HeroBestRing_win32",               -- win32 生肖

    LUA_FILE_HERO_LOOK_FRAME                    = "GUILayout/HeroFrame_Look",                   -- 查看英雄人物面板外框
    LUA_FILE_HERO_LOOK_EQUIP                    = "GUILayout/HeroEquip_Look",                   -- 查看英雄装备
    LUA_FILE_HERO_LOOK_SUPER_EQUIP              = "GUILayout/HeroSuperEquip_Look",              -- 查看英雄神装
    LUA_FILE_HERO_LOOK_TITLE                    = "GUILayout/HeroTitle_Look",                   -- 查看英雄称号 
    LUA_FILE_HERO_LOOK_BESTRING                 = "GUILayout/HeroBestRing_Look",                -- 查看英雄生肖
    LUA_FILE_HERO_LOOK_FRAME_WIN32              = "GUILayout/HeroFrame_Look_win32",             -- win32 查看英雄人物面板外框
    LUA_FILE_HERO_LOOK_EQUIP_WIN32              = "GUILayout/HeroEquip_Look_win32",             -- win32 查看英雄装备
    LUA_FILE_HERO_LOOK_SUPER_EQUIP_WIN32        = "GUILayout/HeroSuperEquip_Look_win32",        -- win32 查看英雄神装
    LUA_FILE_HERO_LOOK_TITLE_WIN32              = "GUILayout/HeroTitle_Look_win32",             -- win32 查看英雄称号
    LUA_FILE_HERO_LOOK_BESTRING_WIN32           = "GUILayout/HeroBestRing_Look_win32",          -- win32 查看英雄生肖
    LUA_FILE_HERO_LOOK_BUFF                     = "GUILayout/HeroBuff_Look",                    

    LUA_FILE_HERO_INTERNAL_STATE                = "GUILayout/HeroInternalState",                -- 内功状态
    LUA_FILE_HERO_INTERNAL_SKILL                = "GUILayout/HeroInternalSkill",                -- 内功技能
    LUA_FILE_HERO_INTERNAL_MERIDIAN             = "GUILayout/HeroInternalMeridian",             -- 内功经络
    LUA_FILE_HERO_INTERNAL_COMBO                = "GUILayout/HeroInternalCombo",                -- 内功连击

    LUA_FILE_MERGE_PLAYER_MAIN                  = "GUILayout/MergePlayerFrame",                 -- 个人-人物和英雄
    LUA_FILE_LOOK_MERGE_PLAYER_MAIN             = "GUILayout/LookMergePlayerMain",              -- 其他玩家-人物和英雄

    LUA_FILE_HERO_STATE                         = "GUILayout/HeroState",                        -- 英雄状态
    LUA_FILE_HERO_STATE_SELECT                  = "GUILayout/HeroStateSelect",                  -- 英雄状态设置
    LUA_FILE_HERO_STATE_THREE_SELECT            = "GUILayout/HeroStateThreeSelect", 
    LUA_FILE_TITLE_TIPS                         = "GUILayout/TitleTips",                        -- 称号提示
    LUA_FILE_LOOK_TITLE_TIPS                    = "GUILayout/TitleTips_Look",                   -- 查看他人称号提示

    LUA_FILE_TRADE_PLAYER_FRAME                 = "GUILayout/PlayerHeroFrame_Look_TradingBank", -- 交易行人物主界面
    LUA_FILE_TRADE_PLAYER_EQUIP                 = "GUILayout/PlayerEquip_Look_TradingBank",     -- 装备
    LUA_FILE_TRADE_PLAYER_BASE_ATT              = "GUILayout/PlayerBaseAtt_Look_TradingBank",   -- 基础属性
    LUA_FILE_TRADE_PLAYER_EXTRA_ATT             = "GUILayout/PlayerExtraAtt_Look_TradingBank",  -- 额外属性
    LUA_FILE_TRADE_PLAYER_SKILL                 = "GUILayout/PlayerSkill_Look_TradingBank",     -- 技能
    LUA_FILE_TRADE_PLAYER_SUPER_EQUIP           = "GUILayout/PlayerSuperEquip_Look_TradingBank",-- 神装
    LUA_FILE_TRADE_PLAYER_TITLE                 = "GUILayout/PlayerTitle_Look_TradingBank",     -- 称号
    LUA_FILE_TRADE_PLAYER_BESTRING              = "GUILayout/PlayerBestRing_Look_TradingBank",  -- 生肖
    
                                                                                                -- 交易行英雄 
    LUA_FILE_TRADE_HERO_EQUIP                   = "GUILayout/HeroEquip_Look_TradingBank",       -- 装备
    LUA_FILE_TRADE_HERO_BASE_ATT                = "GUILayout/HeroBaseAtt_Look_TradingBank",     -- 基础属性
    LUA_FILE_TRADE_HERO_EXTRA_ATT               = "GUILayout/HeroExtraAtt_Look_TradingBank",    -- 额外属性
    LUA_FILE_TRADE_HERO_SKILL                   = "GUILayout/HeroSkill_Look_TradingBank",       -- 技能
    LUA_FILE_TRADE_HERO_SUPER_EQUIP             = "GUILayout/HeroSuperEquip_Look_TradingBank",  -- 神装
    LUA_FILE_TRADE_HERO_TITLE                   = "GUILayout/HeroTitle_Look_TradingBank",       -- 称号
    LUA_FILE_TRADE_HERO_BESTRING                = "GUILayout/HeroBestRing_Look_TradingBank",    -- 生肖

    -------------------zfs end------------------------------------------------------------------------------------



    LUA_FILE_NPC_TALK           = "GUILayout/NPCTalk",              -- NPC
    LUA_FILE_GAME_WORLD_CONFIRM = "GUILayout/GameWorldConfirm",     -- 游戏世界确认公告

    LUA_FILE_GUILD_FRAME        = "GUILayout/GuildFrame",           -- 行会 外框
    LUA_FILE_GUILD_MAIN         = "GUILayout/GuildMain",            -- 行会主界面
    LUA_FILE_GUILD_LIST         = "GUILayout/GuildList",            -- 行会列表
    LUA_FILE_GUILD_CREATE       = "GUILayout/GuildCreate",          -- 行会创建
    LUA_FILE_GUILD_MEMBER       = "GUILayout/GuildMember",          -- 行会成员
    LUA_FILE_GUILD_EDITTITLE    = "GUILayout/GuildEditTitle",       -- 行会编辑
    LUA_FILE_GUILD_APPLY_LIST   = "GUILayout/GuildApplyList",       -- 行会申请列表
    LUA_FILE_GUILD_ALLY_APPLY   = "GUILayout/GuildAllyApply",       -- 行会结盟申请列表
    LUA_FILE_GUILD_WAR_SPONSOR  = "GUILayout/GuildWarSponsor",      -- 宣战、结盟结盟

    LUA_FILE_FUNC_DOCK          = "GUILayout/FuncDock",             -- 功能菜单
    
    LUA_FILE_SOCIAL_FRAME       = "GUILayout/SocialFrame",          -- 社交 外框
    LUA_FILE_MAIL               = "GUILayout/Mail",                 -- 邮件
    LUA_FILE_NEAR_PLAYER        = "GUILayout/NearPlayer",           -- 附近
    LUA_FILE_TEAM               = "GUILayout/Team",                 -- 组队
    LUA_FILE_FRIEND             = "GUILayout/Friend",               -- 好友

    LUA_FILE_TEAM_APPLY         = "GUILayout/TeamApply",            -- 组队申请
    LUA_FILE_TEAM_INVITE        = "GUILayout/TeamInvite",           -- 组队邀请
    LUA_FILE_FRIEND_APPLY       = "GUILayout/FriendApply",          -- 好友申请
    LUA_FILE_FRIEND_ADD         = "GUILayout/FriendAdd",            -- 添加好友
    LUA_FILE_FRIEND_ADD_BLACKLIST = "GUILayout/FriendAddBlacklist", -- 添加黑名单
    LUA_FILE_TEAM_BEINVITED_POP   = "GUILayout/TeamBeInvitedPop",   -- 被邀请组队弹窗

    LUA_FILE_BAG_LAYER                       = "GUILayout/Bag",                         -- 个人背包
    LUA_FILE_BAG_ITEM_LAYER                  = "GUILayout/BagItem",                     -- 背包道具
    LUA_FILE_BAG_ITEM_TEXT_LAYER             = "GUILayout/BagItemText",                 -- 背包文字
    LUA_FILE_BAG_ITEM_EFFECT_LAYER           = "GUILayout/BagItemEffect",               -- 背包特效
    LUA_FILE_HERO_BAG_LAYER                  = "GUILayout/HeroBag",                     -- 英雄背包
    LUA_FILE_MERGE_BAG_LAYER                 = "GUILayout/MergeBag",                    -- 个人、英雄背包合并
    LUA_FILE_NPC_STORAGE                     = "GUILayout/Storage",                     -- 仓库

    LUA_FILE_NPC_STORE                       = "GUILayout/NPCStore",                    -- npc商店
    LUA_FILE_MAKE_DRUG                       = "GUILayout/NPCMakeDrug",                 -- 炼药
    LUA_FILE_SELL_REPAIRE                    = "GUILayout/NPCSellRepaire",              -- 出售或修理

    LUA_FILE_AUCTION_MAIN                    = "GUILayout/AuctionMain",                 -- 拍卖行主界面
    LUA_FILE_AUCTION_WORLD                   = "GUILayout/AuctionWorld",                -- 世界拍卖、行会拍卖
    LUA_FILE_AUCTION_BIDDING                 = "GUILayout/AuctionBidding",              -- 我的竞拍
    LUA_FILE_AUCTION_PUT_LIST                = "GUILayout/AuctionPutList",              -- 我的上架
    LUA_FILE_AUCTION_PUTIN                   = "GUILayout/AuctionPutin",                -- 上架道具
    LUA_FILE_AUCTION_TIMEOUT                 = "GUILayout/AuctionTimeout",              -- 超时
    LUA_FILE_AUCTION_PUTOUT                  = "GUILayout/AuctionPutout",               -- 下架道具
    LUA_FILE_AUCTION_BID                     = "GUILayout/AuctionBid",                  -- 竞拍
    LUA_FILE_AUCTION_BUY                     = "GUILayout/AuctionBuy",                  -- 购买

    LUA_FILE_STALL                           = "GUILayout/Stall",                       -- 摆摊
    LUA_FILE_STALL_SET                       = "GUILayout/StallSet",                   
    LUA_FILE_STALL_PUT                       = "GUILayout/StallPut",        
    
    LUA_FILE_TRADE                           = "GUILayout/Trade",                       -- 交易

    LUA_FILE_RANK                            = "GUILayout/Rank",                        -- 排行榜
    LUA_FILE_RANK_WIN32                      = "GUILayout/Rank_win32",                  

    LUA_FILE_STORE_FRAME                     = "GUILayout/StoreFrame",                  -- 商城外框
    LUA_FILE_STORE_PAGE                      = "GUILayout/StorePage",                   -- 商城内容
    LUA_FILE_STORE_RECHARGE                  = "GUILayout/StoreRecharge",               -- 商城充值
    LUA_FILE_STORE_DETAIL                    = "GUILayout/StoreDetail",                 -- 商城快捷购买
    LUA_FILE_RECHARGE_QRCODE                 = "GUILayout/RechargeQRCode",              -- 充值二维码

    LUA_FILE_AUTO_USE_POP                    = "GUILayout/AutoUsePop",                  -- 自动使用

    LUA_FILE_COMMON_BUBBLE_INFO              = "GUILayout/CommonBubbleInfo",            -- 被多人邀请组队、交易
    LUA_FILE_COMMON_TIPS_POP                 = "GUILayout/CommonTipsPop",               -- 通用弹窗
    LUA_FILE_COMMON_DESC_TIPS                = "GUILayout/CommonDescTips",              -- 通用描述Tips

    LUA_FILE_ITEM_SPLIT_POP                  = "GUILayout/ItemSplitPop",                -- 道具拆分弹窗

    LUA_FILE_TREASURE_BOX                    = "GUILayout/TreasureBox",                 -- 宝箱道具
    LUA_FILE_GOLD_BOX                        = "GUILayout/GoldBox",                     -- 宝箱

    LUA_FILE_ITEM_TIPS                       = "GUILayout/ItemTips",                    -- 道具tips

    LUA_FILE_CHAT                            = "GUILayout/Chat",                        -- 聊天
    LUA_FILE_CAHTEXTEND                      = "GUILayout/ChatExtend",                  -- 聊天拓展框
    LUA_FILE_PRIVATE_CHAT_WIN32              = "GUILayout/PrivateChat_win32",           -- 私聊记录页
    
    LUA_FILE_NOTICE                          = "GUILayout/Notice",                      -- 系统类通知

    LUA_FILE_MAIN_MONSTER                    = "GUILayout/MainMonster",                 -- 大血条
    LUA_FILE_MAIN_MONSTER_BELONG             = "GUILayout/MonsterBelongNetPlayer",      -- 快捷选中归属
    LUA_FILE_COMPOUND_ITEM                   = "GUILayout/CompoundItem",                -- 合成

    LUA_FILE_ITEM                            = "GUILayout/Item",                        -- 物品框

    LUA_FILE_REIN_ATTR                       = "GUILayout/ReinAttr",                    -- 转生加点

    LUA_FILE_SET_WINSIZE_POP                 = "GUILayout/SetWinSizePop",               -- 设置分辨率 

    LUA_FILE_COMMON_QUESTION                 = "GUILayout/CommonQuestion",              -- 答题
    LUA_FILE_COMMON_VERIFICATION             = "GUILayout/CommonVerification",          -- 验证
    LUA_FILE_COMMON_SELECT_LIST              = "GUILayout/CommonSelectList",            -- 选择下拉栏
    
    LUA_FILE_MINIMAP                         = "GUILayout/MiniMap",                     -- 小地图

    LUA_FILE_UIMODEL                         = "GUILayout/UIModel",                     -- 内观模型
    LUA_FILE_BESTRONG_UP                     = "GUILayout/BeStrongUp",                  -- 变强按钮

    LUA_FILE_LOGIN_SERVER                    = "GUILayout/LoginServer",                 -- 登录账号 开门动画
    LUA_FILE_LOGIN_ACCOUNT                   = "GUILayout/LoginAccount",                -- 登录账号 

    LUA_FILE_PROGRESS_BAR                    = "GUILayout/ProgressBar",                 -- 进度条 采集 
    LUA_FILE_PLAY_DICE                       = "GUILayout/PlayDice",                    -- 摇骰子

    LUA_FILE_UI_ROTATEVIEW                   = "GUILayout/UIRotateView",                -- 控件 旋转容器

    LUA_FILE_PURCHASE_MAIN                   = "GUILayout/PurchaseMain",                -- 求购- 主界面
    LUA_FILE_PURCHASE_WORLD                  = "GUILayout/PurchaseWorld",               -- 世界求购
    LUA_FILE_PURCHASE_MY                     = "GUILayout/PurchaseMy",                  -- 我的求购
    LUA_FILE_PURCHASE_SELL                   = "GUILayout/PurchaseSell",                -- 求购 - 出售界面
    LUA_FILE_PURCHASE_PUTIN                  = "GUILayout/PurchasePutIn",               -- 求购 - 上架

}

SLDefine.LAYERID = 
{
    MiniMapGUI                  = "MiniMapGUI",                     -- 小地图           
    LoginRoleGUI                = "LoginRoleGUI",                   -- 登录 选角
    LoginServerGUI              = "LoginServerGUI",                 -- 登录账号 开门动画
    LoginAccountGUI             = "LoginAccountGUI",                -- 登录账号

    SettingFrameGUI             = "SettingFrameGUI",                -- 设置 外框

    NPCTalkGUI                  = "NPCTalkGUI",                     -- NPC 对话
    GameWorldConfirmGUI         = "GameWorldConfirmGUI",            -- 游戏世界确认公告

    GuildFrameGUI               = "GuildFrameGUI",                  -- 行会外框
    GuildCreateGUI              = "GuildCreateGUI",                 -- 行会创建
    GuildEditTitleGUI           = "GuildEditTitleGUI",              -- 行会编辑
    GuildApplyListGUI           = "GuildApplyListGUI",              -- 行会申请列表
    GuildAllyApplyGUI           = "GuildAllyApplyGUI",              -- 行会结盟申请列表
    GuildWarSponsorGUI          = "GuildWarSponsorGUI",             -- 宣战、结盟结盟

    TradePlayerMainGUI          = "TradePlayerMainGUI",             -- 人物主界面
    TradePlayerBestRingGUI      = "TradePlayerBestRingGUI",         -- 生肖
    TradePlayerHeroBestRingGUI  = "TradePlayerHeroBestRingGUI",     -- 生肖

    PlayerMainGUI               = "PlayerMainGUI",                  -- 人物主界面
    PlayerBestRingGUI           = "PlayerBestRingGUI",              -- 生肖
    PlayerSkillSetting          = "PlayerSkillSetting",             -- 人物技能设置

    PlayerHeroMainGUI           = "PlayerHeroMainGUI",              -- 英雄主界面
    PlayerHeroBestRingGUI       = "PlayerHeroBestRingGUI",          -- 生肖
    HeroStateSelectGUI          = "HeroStateSelectGUI",             -- 英雄状态设置

    LookPlayerMainGUI           = "LookPlayerMainGUI",              -- 查看他人主界面
    LookPlayerBestRingGUI       = "LookPlayerBestRingGUI",          -- 查看他人生肖

    LookHeroMainGUI             = "LookHeroMainGUI",                 -- 查看他人英雄主界面
    LookHeroBestRingGUI         = "LookHeroBestRingGUI",             -- 查看他人英雄生肖

    MergePlayerMainGUI          = "MergePlayerMainGUI",             -- 个人-人物和英雄
    LookMergePlayerMainGUI      = "LookMergePlayerMainGUI",         -- 其他玩家-人物和英雄

    TradingBankFrame            = "TradingBankFrame",               -- 交易行主界面
    TradingBankBestRingGUI      = "TradingBankBestRingGUI",         -- 交易行查看他人生肖
    TradingBankHeroBestRingGUI  = "TradingBankHeroBestRingGUI",     -- 交易行查看他人英雄生肖

    SocialGUI                   = "SocialGUI",                      -- 社交 外框

    BagLayerGUI                 = "BagLayerGUI",                    -- 个人背包
    HeroBagLayerGUI             = "HeroBagLayerGUI",                -- 英雄背包
    MergeBagLayerGUI            = "MergeBagLayerGUI",               -- 个人、英雄背包合并
    NPCStorageGUI               = "NPCStorageGUI",                  -- 仓库
    
    NPCStoreGUI                 = "NPCStoreGUI",                    -- npc商店
    NPCMakeDrugGUI              = "NPCMakeDrugGUI",                 -- 炼药
    NPCSellOrRepaire            = "NPCSellOrRepaireGUI",            -- 出售或修理

    AuctionMainGUI              = "AuctionMainGUI",                 -- 拍卖行主界面
    AuctionPutinGUI             = "AuctionPutinGUI",                -- 上架道具
    AuctionTimeoutGUI           = "AuctionTimeoutGUI",              -- 超时
    AuctionPutoutGUI            = "AuctionPutoutGUI",               -- 下架道具
    AuctionBidGUI               = "AuctionBidGUI",                  -- 竞拍
    AuctionBuyGUI               = "AuctionBuyGUI",                  -- 购买

    StallLayerGUI                = "StallLayerGUI",                 -- 摆摊
    StallSetGUI                  = "StallSetGUI", 
    StallPutGUI                  = "StallPutGUI",

    TradeGUI                    = "TradeGUI",                       -- 交易

    RankGUI                     = "RankGUI",                        -- 排行榜

    StoreFrameGUI               = "StoreFrameGUI",                  -- 商城外框
    StoreBuyGUI                 = "StoreBuyGUI",                    -- 商城购买
    StoreDetailGUI              = "StoreDetailGUI",                 -- 快捷购买

    TeamApplyGUI                = "TeamApplyGUI",                   -- 组队申请
    TeamInviteGUI               = "TeamInviteGUI",                  -- 组队邀请
    TeamBeInvitedPopGUI         = "TeamBeInvitedPopGUI",            -- 被邀请组队弹窗
    
    FriendApplyGUI              = "FriendApplyGUI",                 -- 好友申请
    FriendAdd                   = "FriendAddGUI",                   -- 添加好友
    FriendAddBlacklist          = "FriendAddBlacklist",             -- 添加黑名单

    MainNearGUI                 = "MainNearGUI",                    -- 附近列表展示

    CompoundItemGUI             = "CompoundItemGUI",                -- 合成

    PrivateChatWin32GUI         = "PrivateChatWin32GUI",            -- 私聊记录

    ReinAttrGUI                 = "ReinAttrGUI",                    -- 转生加属性点

    RechargeQRCodeGUI           = "RechargeQRCodeGUI",              -- 充值二维码

    SetWinSizeGUI               = "SetWinSizeGUI",                  -- 设置分辨率
    
    ConfigSettingGUI            = "ConfigSettingGUI",               -- 配置表设置

    CommonTipsGUI               = "CommonTipsGUI",                  -- 通用弹窗GUI
    ItemTipsGUI                 = "ItemTipsGUI",                    -- 道具Tips

    PurchaseMainGUI             = "PurchaseMainGUI",                -- 求购
    PurchaseSellGUI             = "PurchaseSellGUI",                -- 求购-出售
    PurchasePutInGUI            = "PurchasePutInGUI",               -- 求购-上架


}

SLDefine.SETTINGID = {
    SETTING_IDX_PLAYER_NAME          = global.MMO.SETTING_IDX_PLAYER_NAME           ,    -- 人物显名设置
	SETTING_IDX_HP_NUM               = global.MMO.SETTING_IDX_HP_NUM                ,    -- 数字显血设置
	SETTING_IDX_DAMAGE_NUM           = global.MMO.SETTING_IDX_DAMAGE_NUM            ,    -- 飘血显示设置
	SETTING_IDX_HP_HUD               = global.MMO.SETTING_IDX_HP_HUD                ,    -- 显示血条设置
	SETTING_IDX_MONSTER_NAME         = global.MMO.SETTING_IDX_MONSTER_NAME          ,    -- 怪物显名设置
	SETTING_IDX_ONE_DOUBLE_ROCKER    = global.MMO.SETTING_IDX_ONE_DOUBLE_ROCKER     ,    -- 单双摇杆
	SETTING_IDX_HP_LOW_USE_HCS       = global.MMO.SETTING_IDX_HP_LOW_USE_HCS        ,    -- 生命值低于多少使用回城石
	SETTING_IDX_HP_LOW_USE_SJS       = global.MMO.SETTING_IDX_HP_LOW_USE_SJS        ,    -- 生命值低于多少使用随机石
	SETTING_IDX_HP_LOW_USE_HY        = global.MMO.SETTING_IDX_HP_LOW_USE_HY         ,    -- 生命值低于多少使用HY
	SETTING_IDX_HP_LOW_USE_SHY       = global.MMO.SETTING_IDX_HP_LOW_USE_SHY        ,   -- 生命值低于多少使用SHY
	SETTING_IDX_MP_LOW_USE_LY        = global.MMO.SETTING_IDX_MP_LOW_USE_LY         ,   -- 魔法值低于多少使用LY
	SETTING_IDX_MP_LOW_USE_SHY       = global.MMO.SETTING_IDX_MP_LOW_USE_SHY        ,   -- 魔法值低于多少使用SHY
	SETTING_IDX_AUTO_MOVE            = global.MMO.SETTING_IDX_AUTO_MOVE             ,   -- 自动走位
	SETTING_IDX_ALWAYS_ATTACK        = global.MMO.SETTING_IDX_ALWAYS_ATTACK         ,   -- 持续攻击  
	SETTING_IDX_DAODAOCISHA          = global.MMO.SETTING_IDX_DAODAOCISHA           ,   -- 刀刀刺杀  
	SETTING_IDX_AUTO_LIEHUO          = global.MMO.SETTING_IDX_AUTO_LIEHUO           ,   -- 自动烈火
	SETTING_IDX_GEWEICISHA           = global.MMO.SETTING_IDX_GEWEICISHA            ,   -- 隔位刺杀
	SETTING_IDX_SMART_BANYUE         = global.MMO.SETTING_IDX_SMART_BANYUE          ,   -- 智能半月
	SETTING_IDX_AUTO_MOFADUN         = global.MMO.SETTING_IDX_AUTO_MOFADUN          ,   -- 自动魔法盾
	SETTING_IDX_AUTO_FIRE_WALL       = global.MMO.SETTING_IDX_AUTO_FIRE_WALL        ,   -- 自动火墙
	SETTING_IDX_AUTO_GROUPSKILL      = global.MMO.SETTING_IDX_AUTO_GROUPSKILL       ,   -- 群怪技能
	SETTING_IDX_AUTO_DU              = global.MMO.SETTING_IDX_AUTO_DU               ,   -- 自动施毒
	SETTING_IDX_AUTO_YOULINGDUN      = global.MMO.SETTING_IDX_AUTO_YOULINGDUN       ,   -- 自动幽灵盾
	SETTING_IDX_AUTO_SSZJS           = global.MMO.SETTING_IDX_AUTO_SSZJS            ,   -- 自动神圣战甲术
	SETTING_IDX_HP_LOW_USE_SKILL     = global.MMO.SETTING_IDX_HP_LOW_USE_SKILL      ,   -- 生命值低于多少使用 技能
	SETTING_IDX_AUTO_SUMMON          = global.MMO.SETTING_IDX_AUTO_SUMMON           ,   -- 自动召唤
	SETTING_IDX_BGMUSIC              = global.MMO.SETTING_IDX_BGMUSIC               ,   -- BG音乐
	SETTING_IDX_UNSAFE_TIPS          = global.MMO.SETTING_IDX_UNSAFE_TIPS           ,   -- 残血提示
	SETTING_IDX_CAMERA_ZOOM          = global.MMO.SETTING_IDX_CAMERA_ZOOM           ,   -- 摄像机zoom设置
	SETTING_IDX_SKILL_NEXT_ATTACK    = global.MMO.SETTING_IDX_SKILL_NEXT_ATTACK     ,   -- 技能接平砍
    SETTING_IDX_NOT_NEED_SHIFT       = global.MMO.SETTING_IDX_NOT_NEED_SHIFT        ,   -- 免shift
	SETTING_IDX_WINDOW_SMOOTH_VIEW   = global.MMO.SETTING_IDX_WINDOW_SMOOTH_VIEW    ,   -- PC端平滑模式
	SETTING_IDX_ONLY_NAME            = global.MMO.SETTING_IDX_ONLY_NAME             ,   -- 只显人名
	SETTING_IDX_PLAYER_JOB_LEVEL     = global.MMO.SETTING_IDX_PLAYER_JOB_LEVEL      ,   -- 主场景显示玩家职业等级模式设置
	SETTING_IDX_EXP_IGNORE           = global.MMO.SETTING_IDX_EXP_IGNORE            ,   -- 经验过滤
	SETTING_IDX_EQUIP_COMPARE        = global.MMO.SETTING_IDX_EQUIP_COMPARE         ,   -- 装备对比
	SETTING_IDX_MAGIC_LOCK           = global.MMO.SETTING_IDX_MAGIC_LOCK            ,   -- 魔法锁定
	SETTING_IDX_AUTO_LAUNCH          = global.MMO.SETTING_IDX_AUTO_LAUNCH           ,   -- 自动练功
	SETTING_IDX_HIDE_MONSTER_BODY    = global.MMO.SETTING_IDX_HIDE_MONSTER_BODY     ,   -- 尸体清理
	SETTING_IDX_DU_FU_AUTOCHANGE     = global.MMO.SETTING_IDX_DU_FU_AUTOCHANGE      ,   -- 毒符互换
	SETTING_IDX_BB_ATTACK_WITH       = global.MMO.SETTING_IDX_BB_ATTACK_WITH        ,   -- 宝宝跟随攻击
    SETTING_IDX_NEAR_LIEHUO          = global.MMO.SETTING_IDX_NEAR_LIEHUO           ,   -- 近身烈火
	SETTING_IDX_BOSS_TIPS            = global.MMO.SETTING_IDX_BOSS_TIPS             ,   -- boss提示
	SETTING_IDX_AUTO_SIMPSKILL       = global.MMO.SETTING_IDX_AUTO_SIMPSKILL        ,   -- 单体技能
	SETTING_IDX_DURABILITY_TIPS      = global.MMO.SETTING_IDX_DURABILITY_TIPS       ,   -- 耐久提示
	SETTING_IDX_AUTO_REPAIR          = global.MMO.SETTING_IDX_AUTO_REPAIR           ,   -- 自动修理
	SETTING_IDX_EFFECTMUSIC          = global.MMO.SETTING_IDX_EFFECTMUSIC           ,   -- 游戏音乐
	SETTING_IDX_AUTO_KAITIAN         = global.MMO.SETTING_IDX_AUTO_KAITIAN          ,   -- 自动开天
	SETTING_IDX_AUTO_ZHURI           = global.MMO.SETTING_IDX_AUTO_ZHURI            ,   -- 自动逐日
	SETTING_IDX_AUTO_CLOAKING        = global.MMO.SETTING_IDX_AUTO_CLOAKING         ,   -- 自动隐身
	SETTING_IDX_MOVE_GEWEI_CISHA     = global.MMO.SETTING_IDX_MOVE_GEWEI_CISHA      ,   -- 移动隔位刺杀
	SETTING_IDX_PLAYER_SIMPLE_DRESS  = global.MMO.SETTING_IDX_PLAYER_SIMPLE_DRESS   ,   -- 人物简装
	SETTING_IDX_MONSTER_SIMPLE_DRESS = global.MMO.SETTING_IDX_MONSTER_SIMPLE_DRESS  ,   -- 怪物简装
    SETTING_IDX_BOSS_NO_SIMPLE_DRESS = global.MMO.SETTING_IDX_BOSS_NO_SIMPLE_DRESS  ,      -- Boss不简装
	SETTING_IDX_AUTO_WJZQ            = global.MMO.SETTING_IDX_AUTO_WJZQ             ,   -- 自动无极真气
	SETTING_IDX_ROCKER_CANCEL_ATTACK = global.MMO.SETTING_IDX_ROCKER_CANCEL_ATTACK  ,   -- 摇杆取消攻击
	SETTING_IDX_TITLE_VISIBLE        = global.MMO.SETTING_IDX_TITLE_VISIBLE         ,   -- 显示称号设置
	SETTING_IDX_AUTO_PUT_IN_EQUIP    = global.MMO.SETTING_IDX_AUTO_PUT_IN_EQUIP     ,   -- 装备自动穿戴读表
	SETTING_IDX_LEVEL_SHOW_NAME_HUD  = global.MMO.SETTING_IDX_LEVEL_SHOW_NAME_HUD   ,   -- 不选中状态,满足等级显示玩家名字HUD
	SETTING_IDX_AUTO_FIGHT_BACK      = global.MMO.SETTING_IDX_AUTO_FIGHT_BACK       ,   -- 自动反击
	SETTING_IDX_HP_UNIT              = global.MMO.SETTING_IDX_HP_UNIT               ,   -- hp血量单位转换
	SETTING_IDX_LAYER_OPACITY        = global.MMO.SETTING_IDX_LAYER_OPACITY         ,   -- Layer Opacity
	SETTING_IDX_ROCKER_SHOW_DISTANCE = global.MMO.SETTING_IDX_ROCKER_SHOW_DISTANCE  ,   -- 轮盘侧边距离
	SETTING_IDX_SKILL_SHOW_DISTANCE  = global.MMO.SETTING_IDX_SKILL_SHOW_DISTANCE   ,   -- 技能侧边距离
	SETTING_IDX_MP_LOW_USE_HCS       = global.MMO.SETTING_IDX_MP_LOW_USE_HCS        ,   -- 魔法值低于多少使用回城石
	SETTING_IDX_MP_LOW_USE_SJS       = global.MMO.SETTING_IDX_MP_LOW_USE_SJS        ,   -- 魔法值低于多少使用随机石
	SETTING_IDX_AUTO_SHIELD_OF_FORCE = global.MMO.SETTING_IDX_AUTO_SHIELD_OF_FORCE  ,   -- 武力盾
	SETTING_IDX_AUTO_SHIELD_OF_TAOIST= global.MMO.SETTING_IDX_AUTO_SHIELD_OF_TAOIST ,  -- 道力盾
    SETTING_IDX_AUTO_ICE_PALM        = global.MMO.SETTING_IDX_AUTO_ICE_PALM 	    ,  -- 自动寒冰掌
	SETTING_IDX_AUTO_BLOODTHIRSTY_S  = global.MMO.SETTING_IDX_AUTO_BLOODTHIRSTY_S   ,  -- 自动嗜血术
	SETTING_IDX_AUTO_BREACH_NERVE_FU = global.MMO.SETTING_IDX_AUTO_BREACH_NERVE_FU  ,  -- 自动裂神符
	SETTING_IDX_AUTO_DEATH_EYE       = global.MMO.SETTING_IDX_AUTO_DEATH_EYE  	    ,  -- 自动死亡之眼
	SETTING_IDX_AUTO_ICE_SICKLE_S    = global.MMO.SETTING_IDX_AUTO_ICE_SICKLE_S     ,  -- 自动冰镰术
	SETTING_IDX_AUTO_FLAME_ICE       = global.MMO.SETTING_IDX_AUTO_FLAME_ICE        ,  -- 自动火焰冰
	SETTING_IDX_AUTO_ICE_GROUP_RAIN  = global.MMO.SETTING_IDX_AUTO_ICE_GROUP_RAIN   ,  -- 自动冰霜群雨
	SETTING_IDX_AUTO_DOUBLE_DRAGON_Z = global.MMO.SETTING_IDX_AUTO_DOUBLE_DRAGON_Z  ,  -- 自动双龙斩
	SETTING_IDX_AUTO_DRAGON_SHADOW_JF = global.MMO.SETTING_IDX_AUTO_DRAGON_SHADOW_JF ,  -- 自动龙影剑法
	SETTING_IDX_AUTO_THUNDERBOLT_JF  = global.MMO.SETTING_IDX_AUTO_THUNDERBOLT_JF   ,  -- 自动雷霆剑法
	SETTING_IDX_AUTO_FREELY_JS       = global.MMO.SETTING_IDX_AUTO_FREELY_JS        ,  -- 自动纵横剑术
    SETTING_IDX_PICK_SETTING         = global.MMO.SETTING_IDX_PICK_SETTING          ,  -- 拾取设置
    SETTING_IDX_AUTO_COMBO           = global.MMO.SETTING_IDX_AUTO_COMBO            ,  -- 自动连击
    SETTING_IDX_IGNORE_STALL         = global.MMO.SETTING_IDX_IGNORE_STALL          ,  -- 屏蔽摆摊
	SETTING_IDX_FRAME_RATE_TYPE_HIGH = global.MMO.SETTING_IDX_FRAME_RATE_TYPE_HIGH  , -- 高帧率模式设置
	SETTING_IDX_MONSTER_PET_VISIBLE  = global.MMO.SETTING_IDX_MONSTER_PET_VISIBLE   , -- 屏蔽物显示设置
	SETTING_IDX_EFFECT_SHOW          = global.MMO.SETTING_IDX_EFFECT_SHOW           , -- 屏蔽特效设置
	SETTING_IDX_PLAYER_SHOW_FRIEND   = global.MMO.SETTING_IDX_PLAYER_SHOW_FRIEND    , -- 屏蔽己方玩家设置
	SETTING_IDX_PLAYER_SHOW          = global.MMO.SETTING_IDX_PLAYER_SHOW           , -- 屏蔽玩家设置
	SETTING_IDX_MONSTER_VISIBLE      = global.MMO.SETTING_IDX_MONSTER_VISIBLE       , -- 屏蔽怪物设置
	SETTING_IDX_HERO_HIDE            = global.MMO.SETTING_IDX_HERO_HIDE             , -- 屏蔽英雄
	SETTING_IDX_HERO_JOINT_SHAKE     = global.MMO.SETTING_IDX_HERO_JOINT_SHAKE      , -- 合击震屏
	SETTING_IDX_HERO_AUTO_JOINT      = global.MMO.SETTING_IDX_HERO_AUTO_JOINT       , -- 自动合击
	SETTING_IDX_HERO_FOLLOW_ATTACK   = global.MMO.SETTING_IDX_HERO_FOLLOW_ATTACK    , -- 跟随主角攻击
	SETTING_IDX_HERO_ATTACK_DODGE    = global.MMO.SETTING_IDX_HERO_ATTACK_DODGE     , -- 英雄打怪躲避
	SETTING_IDX_HERO_AUTO_LOGIN      = global.MMO.SETTING_IDX_HERO_AUTO_LOGIN       , -- 自动召唤英雄
	SETTING_IDX_HERO_AUTO_LOGINOUT   = global.MMO.SETTING_IDX_HERO_AUTO_LOGINOUT    , -- 英雄残血自动收回
    SETTING_IDX_REVIVE_PROTECT       = global.MMO.SETTING_IDX_REVIVE_PROTECT        , -- 复活戒指回城保护
	SETTING_IDX_REVIVE_PROTECT_HERO  = global.MMO.SETTING_IDX_REVIVE_PROTECT_HERO   , -- 复活戒指回城保护 英雄
	SETTING_IDX_SKILL_EFFECT_SHOW    = global.MMO.SETTING_IDX_SKILL_EFFECT_SHOW     , -- 屏蔽技能特效
	SETTING_IDX_AUTO_SHI_ZI_HOU 	 = global.MMO.SETTING_IDX_AUTO_SHI_ZI_HOU		, -- 自动狮子吼
	----人物保护
	SETTING_IDX_HP_PROTECT1          = global.MMO.SETTING_IDX_HP_PROTECT1           , -- hp保护1
	SETTING_IDX_HP_PROTECT2          = global.MMO.SETTING_IDX_HP_PROTECT2           , -- hp保护2
	SETTING_IDX_HP_PROTECT3          = global.MMO.SETTING_IDX_HP_PROTECT3           , -- hp保护3
	SETTING_IDX_HP_PROTECT4          = global.MMO.SETTING_IDX_HP_PROTECT4           , -- hp保护4
	SETTING_IDX_MP_PROTECT1          = global.MMO.SETTING_IDX_MP_PROTECT1           , -- mp保护1
	SETTING_IDX_MP_PROTECT2          = global.MMO.SETTING_IDX_MP_PROTECT2           , -- mp保护2
	SETTING_IDX_MP_PROTECT3          = global.MMO.SETTING_IDX_MP_PROTECT3           , -- mp保护3
	SETTING_IDX_MP_PROTECT4          = global.MMO.SETTING_IDX_MP_PROTECT4           , -- mp保护4
	----hero保护
	SETTING_IDX_HERO_HP_PROTECT1     = global.MMO.SETTING_IDX_HERO_HP_PROTECT1      , -- hp保护1
	SETTING_IDX_HERO_HP_PROTECT2     = global.MMO.SETTING_IDX_HERO_HP_PROTECT2      , -- hp保护2
	SETTING_IDX_HERO_HP_PROTECT3     = global.MMO.SETTING_IDX_HERO_HP_PROTECT3      , -- hp保护3
	SETTING_IDX_HERO_HP_PROTECT4     = global.MMO.SETTING_IDX_HERO_HP_PROTECT4      , -- hp保护4
	SETTING_IDX_HERO_MP_PROTECT1     = global.MMO.SETTING_IDX_HERO_MP_PROTECT1      , -- mp保护1
	SETTING_IDX_HERO_MP_PROTECT2     = global.MMO.SETTING_IDX_HERO_MP_PROTECT2      , -- mp保护2
	SETTING_IDX_HERO_MP_PROTECT3     = global.MMO.SETTING_IDX_HERO_MP_PROTECT3      , -- mp保护3
	SETTING_IDX_HERO_MP_PROTECT4     = global.MMO.SETTING_IDX_HERO_MP_PROTECT4      , -- mp保护4

	SETTING_IDX_PK_PROTECT           = global.MMO.SETTING_IDX_PK_PROTECT            , -- 红名保护
	SETTING_IDX_BEDAMAGED_PLAYER     = global.MMO.SETTING_IDX_BEDAMAGED_PLAYER      , -- 被玩家攻击时
	SETTING_IDX_N_RANGE_NO_PICK      = global.MMO.SETTING_IDX_N_RANGE_NO_PICK       , -- N范围内有多少怪 不走去拾取
	SETTING_IDX_FIRST_ATTACK_MASTER  = global.MMO.SETTING_IDX_FIRST_ATTACK_MASTER   , -- 受到BB攻击时先打主人
	SETTING_IDX_NO_ATTACK_HAVE_BELONG= global.MMO.SETTING_IDX_NO_ATTACK_HAVE_BELONG , -- 不抢别人归属怪物
	SETTING_IDX_NO_MONSTAER_USE      = global.MMO.SETTING_IDX_NO_MONSTAER_USE       , -- 多少秒没怪物使用
	SETTING_IDX_BESIEGE_FLEE         = global.MMO.SETTING_IDX_BESIEGE_FLEE          , -- 周围有多少敌人时使用
	SETTING_IDX_RED_BESIEGE_FLEE     = global.MMO.SETTING_IDX_RED_BESIEGE_FLEE      , -- 周围有多少红名时使用
	SETTING_IDX_ENEMY_ATTACK         = global.MMO.SETTING_IDX_ENEMY_ATTACK          , -- 周围有敌人时主动攻击
	SETTING_IDX_IGNORE_MONSTER       = global.MMO.SETTING_IDX_IGNORE_MONSTER        , -- 自动挂机忽略的怪物
} 

-- F6可视化配置表
SLDefine.ConfigSettingFile = {
    [1]   = "cfg_att_score.lua",
    [2]   = "cfg_auction_type.lua",
    [3]   = "cfg_buff.lua",
    [4]   = "cfg_damage_number.lua",
    [5]   = "cfg_game_data.lua",
    [6]   = "cfg_magicinfo.lua",
    [7]   = "cfg_mapdesc.lua",
    [8]   = "cfg_setup.lua",
    [9]   = "cfg_skill_present.lua",
    [10]  = "cfg_sound.lua",
    [11]  = "cfg_PulsDesc.lua",
}

-- F6服务下发配置表
SLDefine.ConfigServerFile = {
    [1]   = "cfg_buff",
}

SLDefine.PATH_RES_PRIVATE = global.MMO.PATH_RES_PRIVATE --private 目录

SLDefine.TouchEventType =
{
    began = 0,
    moved = 1,
    ended = 2,
    canceled = 3,
}
--玩家面板页
SLDefine.PlayerPage = {
    MAIN_PLAYER_LAYER_EQUIP         = 1,
	MAIN_PLAYER_LAYER_BASE_ATTRI    = 2,
	MAIN_PLAYER_LAYER_EXTRA_ATTRO   = 3,
	MAIN_PLAYER_LAYER_SKILL         = 4,
	MAIN_PLAYER_LAYER_TITLE         = 6,
	MAIN_PLAYER_LAYER_SUPER_EQUIP   = 11,
    MAIN_PLAYER_LAYER_BUFF          = 20,
    MAIN_PLAYER_LAYER_BAG           = 100,--交易行查看背包
    MAIN_PLAYER_LAYER_STORAGE       = 101,--交易行查看仓库
}

-- 内功页签
SLDefine.InternalPage = {
    State           = 1,
    Skill           = 2,
    Meridian        = 3,
    Combo           = 4,
}

-- 社交面板
SLDefine.SocialPage = {
    NearPlayer  = global.LayerTable.NearPlayer,
    Team        = global.LayerTable.Team,
    Friend      = global.LayerTable.Friend,
    Mail        = global.LayerTable.Mail,
}

-- 商城面板 
SLDefine.StorePage = {
    StoreHot        = global.LayerTable.StoreHotLayer,
    StoreBeauty     = global.LayerTable.StoreBeautyLayer,
    StoreEngine     = global.LayerTable.StoreEngineLayer,
    StoreFestival   = global.LayerTable.StoreFestivalLayer,
    StoreRecharge   = global.LayerTable.StoreRechargeLayer, 
}

-- 行会面板
SLDefine.GuildPage = {
    GuildMain       = global.LayerTable.GuildMain,
    GuildMember     = global.LayerTable.GuildMember,
    GuildList       = global.LayerTable.GuildList,
}

-- 设置面板
SLDefine.SettingPage = {
    SettingBasic          = global.LayerTable.SettingBasic,           
    SettingWindowRange    = global.LayerTable.SettingWindowRange,     
    SettingFight          = global.LayerTable.SettingFight,           
    SettingProtect        = global.LayerTable.SettingProtect,
    SettingAuto           = global.LayerTable.SettingAuto,
    SettingHelp           = global.LayerTable.SettingHelp,
}

--交易行面板
SLDefine.TradingBankPage = {
    Buy     = global.LayerTable.TradingBankBuyLayer,
    Sell    = global.LayerTable.TradingBankSellLayer,
    Goods   = global.LayerTable.TradingBankGoodsLayer,
    Mine    = global.LayerTable.TradingBankMeLayer,
}

SLDefine.CLICK_DOUBLE_TIME = 0.3