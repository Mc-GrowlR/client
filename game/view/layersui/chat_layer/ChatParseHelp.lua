local ChatParseHelp = class("ChatParseHelp")

-- -- 服务器返回消息结构
-- {
--     SendId = xx     -- 发送者ID
--     SendName = xx   -- 发送者名字
--     viplabel = xx   -- vip等级名字
--     vipcolor = xx   -- vip等级颜色
--     FColor = xx     -- 字体颜色id
--     BColor = xx     -- 背景颜色id
--     Msg = xx        -- 消息内容
--     mt = xx         -- 消息类型
--     ChannelId = xx  -- 频道
--     Prefix = xx     -- 前缀
-- }
-- -- 客户端发送
-- {
--     mt          = xx    消息类型
--     Msg         = xx    消息内容
--     ChannelId   = xx    频道
--     Target      = xx    私聊目标名
--     TargetID    = xx    私聊目标id
-- }

function ChatParseHelp:parseMiniItem(data)
    return GUIFunction:GenerateChatMiniItem(data)
end

function ChatParseHelp:parseItem(data)
    return GUIFunction:GenerateChatItem(data)
end

function ChatParseHelp:parsePCPrivateItem(data)
    return GUIFunction:GenerateChatPCPrivateItem(data)
end

return ChatParseHelp
