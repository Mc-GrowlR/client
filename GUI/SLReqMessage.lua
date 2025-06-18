SL = SL or {}

-- 常用函数
---------------------------------------------------------------------------
-- 拉起充值面板(payChannel: 支付方式(微信/支付宝); currencyID: 货币ID; price: 支付金额; productIndex: 商品索引/商品ID
function SL:RequestPay(channel, currencyID, price, productIndex)
    if not channel then
        SL:Print("[GUI ERROR] SL:RequestPay channel is empty")
        return nil
    end

    if not currencyID then
        SL:Print("[GUI ERROR] SL:RequestPay currencyID is empty")
        return nil
    end

    -- 商品是否存在
    local RechargeProxy = global.Facade:retrieveProxy(global.ProxyTable.RechargeProxy)
    local product = RechargeProxy:GetProductByID(currencyID)
    if not product then
        ShowSystemTips("未找到商品: " .. (currencyID or ""))
        return nil
    end

    -- 支付宝/花呗/微信
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local channels =     {
        AuthProxy.PAY_CHANNEL.ALIPAY,
        AuthProxy.PAY_CHANNEL.HUABEI,
        AuthProxy.PAY_CHANNEL.WEIXIN,
    }
    local payChannel = channels[channel]

    -- 二维码充值回调
    local function qrcodeCB(isOK, filename)
        if isOK then
            -- 二维码拉取成功
            local qrcode_data = {
                filename    = filename,
                channel    = payChannel,
            }
            global.Facade:sendNotification(global.NoticeTable.Layer_Recharge_QRCode_Open, qrcode_data)
        end
    end

    -- 支付
    local info =     {
        id        = product.currency_itemid,
        name        = product.currency_name,
        price        = price,
        productIndex = productIndex,
    }
    local paytype = global.isWindows and AuthProxy.PAY_TYPE.QRCODE or AuthProxy.PAY_TYPE.NATIVE
    local payData = { paytype = paytype, channel = payChannel, product = info, qrcodeCB = qrcodeCB }
    global.Facade:sendNotification(global.NoticeTable.PayProductRequest, payData)
end

-- 兑换激活码
function SL:RequestCDK(cdk)
    local CDKProxy = global.Facade:retrieveProxy(global.ProxyTable.CDKProxy)
    CDKProxy:SendHTTPRequestPost(cdk)
end

-- 请求购买商品
function SL:RequestStoreBuy(index, count)
    local PageStoreProxy = global.Facade:retrieveProxy(global.ProxyTable.PageStoreProxy)
    PageStoreProxy:RequestBuy(index, count)
end

-- 请求改变PK模式
function SL:RequestChangePKMode(pkmode)
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    PlayerProperty:RequestChangePKMode(pkmode)
end

-- 请求改变宠物战斗模式
function SL:RequestChangePetPKMode(pkmode)
    local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
    return SummonsProxy:RequestModeChange(pkmode)
end

-- 请求从仓库取出道具
function SL:RequestPutOutStorageData(data)
    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    return NPCStorageProxy:RequestPutOutStorageData(data.MakeIndex, data.Name)
end

-- 请求道具到仓库
function SL:RequestSaveItemToNpcStorage(data)
    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    NPCStorageProxy:RequestSaveToStorageAllPage(data.MakeIndex, data.Name)
end

-- 请求使用道具
function SL:RequestUseItem(itemData)
    local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
    return ItemUseProxy:UseItem(itemData)
end

-- 请求使用英雄道具
function SL:RequestUseHeroItem(itemData)
    local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
    ItemUseProxy:HeroUseItem(itemData)
end

-- 请求拆分道具
function SL:RequestSplitItem(data, num)
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    BagProxy:RequestCountItem(data.MakeIndex, num)
end

-- 拆分道具（英雄）
function SL:RequestSplitHeroItem(data, num)
    local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    HeroBagProxy:RequestCountItem(data.MakeIndex, num)
end

-- 召唤英雄或收起
function SL:RequestCallOrOutHero()
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    HeroPropertyProxy:RequestHeroInOrOut()
end

-- 请求玩家首饰盒状态
function SL:RequestOpenPlayerBestRings()
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    EquipProxy:RequestBestRingsOpenState()
end

-- 请求英雄首饰盒状态
function SL:RequestOpenHeroBestRings()
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    HeroEquipProxy:RequestBestRingsOpenState()
end

-- 请求宠物锁定
function SL:RequestLockPetID(targetID)
    local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
    SummonsProxy:ReqLockActorByID(targetID)
end

-- 请求取消宠物锁定
function SL:RequestUnLockPetID(targetID)
    local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
    SummonsProxy:ReqUnLockActorByID(targetID)
end

-- 释放技能
function SL:RequestLaunchSkill(skillID)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local destPos = inputProxy:getCursorMapPosition()
    if global.isWinPlayMode then
        global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, destPos = destPos})
    else
        global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, priority = global.MMO.LAUNCH_PRIORITY_USER})
    end
end

-- 请求施法合击
function SL:RequestMagicJointAttack()
    local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
    local jointSkill     = HeroSkillProxy:haveHeroSkill()
    if not jointSkill then
        return ShowSystemTips("当前没有英雄技能")
    end

    -- 在闪的时候才能放合击
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    if HeroPropertyProxy:getShan()  then
        -- 请求合击
        HeroPropertyProxy:ReqJointAttack()
    end
end

-- 查看目标玩家信息
function SL:RequestLookPlayer(targetId, notForbid)
    local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if not notForbid and mapProxy:IsForbidVisitPlayer() then
        ShowSystemChat(GET_STRING(30001071), 255, 249)
        return
    end

    local target = global.actorManager:GetActor(targetId)
    if target and target:IsHumanoid() then --人形怪
        local disHeadLookHumanoid = tonumber(SL:GetMetaValue("GAME_DATA", "disHeadLookHumanoid")) == 1
        if disHeadLookHumanoid then
            ShowSystemTips(GET_STRING(50000269))
            return
        end
    end

    local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
    LookPlayerProxy:RequestPlayerData(targetId)
end

-- 请求开关型技能开关
function SL:RequestOnOffSkill(skillID)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:RequestSkillOnoff(skillID)
end
-- 常用函数
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- 行会
-- 请求行会申请列表
function SL:RequestGuildAllyApplyList()
    local guildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    guildProxy:RequestGuildAllyApplyList()
end

-- 设置结盟操作
function SL:RequestAllyOperate(guildID, param)
    local guildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    guildProxy:RequestGuildAllOperationy(guildID, param)
end

-- 请求行会成员列表
function SL:RequestGuildMemberList()
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    GuildProxy:RequestMemberList()
end

-- 请求世界行会列表 分页id
function SL:RequestWorldGuildList(page)
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    GuildProxy:RequestWorldGuildList(page)
end

-- 邀请入会
function SL:RequestGuildInviteOther(uid)
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    GuildProxy:RequestGuildInviteOther(uid)
end

-- 踢出行会
function SL:RequestSubGuildMember(uid)
    local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
    GuildPlayerProxy:RequestRemoveMember(uid)
end

-- 任命行会职位
function SL:RequestAppointGuildRank(uid, rank)
    local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
    GuildPlayerProxy:RequestAppointRank(uid, rank)
end
-- 行会
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- 组队
-- 请求创建队伍
function SL:RequestCreateTeam()
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestCreateTeam()
end

-- 邀请玩家入队
function SL:RequestInviteJoinTeam(uid, name)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestInvite(uid, name)
end

-- 拒绝组队邀请
function SL:RequestRefuseTeamInvite(uid)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestApplyRefuse(uid)
end

-- 同意组队邀请
function SL:RequestAgreeTeamInvite(uid)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestInviteAgree(uid)
end

-- 同意申请入队
function SL:RequestApplyAgree(memberUID)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestApplyAgree(memberUID)
end

-- 请求入队申请列表
function SL:RequestApplyData()
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestApplyData()
end

-- 请求附近队伍
function SL:RequestNearTeam()
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestNearTeam()
end

-- 请求加入队伍 uid: 队长userID
function SL:RequestApplyJoinTeam(uid)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestApply(uid)
end

-- 召集队友
function SL:RequestCallTeamMember()
    local FuncDockProxy = global.Facade:retrieveProxy(global.ProxyTable.FuncDockProxy)
    FuncDockProxy:TeamCallFunc()
end

-- 离开队伍
function SL:RequestLeaveTeam()
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestLeaveTeam()
end

-- 保存允许组队状态
function SL:RequestSetTeamPermitStatus(status)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:SetPermitStatus(status)
    TeamProxy:RequestPermit()
end

-- 踢出队伍
function SL:RequestSubTeamMember(uid)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestSubMember(uid)
end

-- 移交队长
function SL:RequestTransferTeamLeader(uid)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestTransferLeader(uid)
end
-- 组队
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- 交易
-- 请求进行交易
function SL:RequestTrade(uid)
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    TradeProxy:SendTradeRequest(uid)
end

-- 请求加入交易物品
function SL:RequestPutInItem(makeindex, name)
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    TradeProxy:RequestPutInItem(makeindex, name)
end
-- 交易
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- 好友
-- 请求好友列表
function SL:RequestFriendList()
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    FriendProxy:RequestFriendList()
end

-- 添加好友
function SL:RequestAddFriend(uname)
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    FriendProxy:requestAddFriend("", uname)
end

-- 删除好友
function SL:RequestDelFriend(uid)
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    FriendProxy:requestDelFriend(uid)
end

-- 好友加到黑名单
function SL:RequestAddBlacklistByName(uname)
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    FriendProxy:requestAddBlackList("", uname)
end

-- 移出黑名单
function SL:RequestOutBlacklist(uid)
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    FriendProxy:requestOutBlackList(uid)
end

-- 同意好友申请
function SL:RequestAgreeFriendApply(uname)
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    FriendProxy:requestAgreeFriendApply(uname)
end

-- 删除好友申请数据
function SL:RequestDelFriendApplyData(uname)
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    return FriendProxy:deleteApplyData(uname)
end

-- 清空好友申请列表
function SL:RequestClearFriendApplyList()
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    return FriendProxy:clearApplyData()
end
-- 好友
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- 邮件
-- 请求获取邮件列表 一次十条
function SL:RequestMailList()
    local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
    MailProxy:RequestMailList()
end

-- 删除已读邮件
function SL:RequestDelReadMail()
    local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
    return MailProxy:deleteReadMail()
end

-- 读邮件
function SL:RequestReadMail(mailId)
    local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
    return MailProxy:readMail(mailId)
end

-- 删除邮件
function SL:RequestDelMail(mailId)
    local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
    return MailProxy:deleteMail(mailId)
end

-- 邮件全部提取
function SL:RequestGetAllMailItems()
    local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
    return MailProxy:getAllMailItems()
end

-- 邮件提取
function SL:RequestGetMailItems(mailId)
    local MailProxy = global.Facade:retrieveProxy(global.ProxyTable.MailProxy)
    return MailProxy:getMailItems(mailId)
end
-- 邮件
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- 拍卖行
-- 请求拍卖行上架列表 listType 1表示查询自己上架的物品，2表示查询参与过的
function SL:RequestAuctionPutList(listType)
    local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    AuctionProxy:RequestItems(listType)
end

-- 拍卖行请求上架
function SL:RequestAuctionPutin(makeindex, count, bidPrice, buyPrice, currencyID, rebate)
    local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    local submitData = {
        makeindex   = makeindex, 
        count       = count,
        price       = bidPrice,
        lastprice   = buyPrice,
        type        = currencyID,
        meguildrate = rebate
    }    
    AuctionProxy:RequestPutin(submitData)
end

-- 拍卖行请求重新上架
function SL:RequestAuctionRePutin(makeindex, count, bidPrice, buyPrice, currencyID, rebate)
    local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    local submitData = {
        makeindex   = makeindex, 
        count       = count,
        price       = bidPrice,
        lastprice   = buyPrice,
        type        = currencyID,
        meguildrate = rebate
    }    
    AuctionProxy:RequestReputin(submitData)
end

-- 拍卖行请求下架
function SL:RequestAuctionPutout(makeindex)
    local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    local submitData = {
        makeindex = makeindex,
    }    
    AuctionProxy:RequestPutout(submitData)
end

-- 拍卖行请求竞价
function SL:RequestAuctionBid(makeindex, price)
    local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    local submitData = {
        price     = price,
        makeindex = makeindex,
    }    
    AuctionProxy:RequestBid(submitData)
end

-- 拍卖行请求领取竞拍成功物品
function SL:RequestAcquireBidItem(makeindex)
    local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    local submitData = {
        makeindex = makeindex,
    }    
    AuctionProxy:RequestAcquireItem(submitData)
end

-- 拍卖行
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- 排行榜
-- 请求排行榜数据 (通过类别)
function SL:RequestRankData(type)
    local RankProxy = global.Facade:retrieveProxy(global.ProxyTable.RankProxy)
    RankProxy:RequestListData(type)
end

-- 请求玩家排行榜数据 1玩家 2英雄
function SL:RequestPlayerRankData(userID, type)
    type = type - 1
    local RankProxy = global.Facade:retrieveProxy(global.ProxyTable.RankProxy)
    RankProxy:RequestPlayerShowData(userID, type)
end

-- 通知服务端点击排行榜类型 1玩家 2英雄
function SL:ReqNotifyClickRankType(type)
    local RankProxy = global.Facade:retrieveProxy(global.ProxyTable.RankProxy)
    RankProxy:RequestNotifyClickRankType(type)
end

-- 通知服务端点击排行榜第几名
function SL:ReqNotifyClickRankValue(value)
    local RankProxy = global.Facade:retrieveProxy(global.ProxyTable.RankProxy)
    RankProxy:RequestNotifyClickRankValue(value)
end

-- 排行榜
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- 任务
-- 提交任务
function SL:RequestSubmitMission(missionID)
    if not missionID then
        SL:Print("[GUI ERROR] SL:RequestSubmitMission missionID is empty")
        return
    end
    local MissionProxy = global.Facade:retrieveProxy(global.ProxyTable.MissionProxy)
    MissionProxy:RequestSubmitMission(missionID)
end
-- 任务
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---玩家面板
--请求通知脚本查看uid的珍宝
function SL:RequestLookZhenBao(uid)
    local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
    LookPlayerProxy:RequestLookZhenBao(uid)--
end
--[[
    请求称号数据
]]
function SL:ResquestTitleList()
    local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
    PlayerTitleProxy:ResquestTitleList()
end
--[[
    请求取下称号
]]
function SL:ResquestDisboardTitle()
    local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
    PlayerTitleProxy:ResquestDisboardTitle()
end
--[[
    请求激活称号
]]
function SL:ResquestActivateTitle(titleId)
    local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
    PlayerTitleProxy:ResquestActivateTitle(titleId)
end
--[[
    2 --设置显示神魔
    1 --设置时装显示
]]
function SL:SendSuperEquipSetting(type)
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    PlayerProperty:SendSuperEquipSetting(type)
end

--英雄
--切换英雄状态
function SL:RequestChangeHeroMode(type)
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    HeroPropertyProxy:RequestChangeHeroMode(type)
end

--[[
    英雄请求称号数据
]]
function SL:ResquestTitleList_Hero()
    local HeroTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroTitleProxy)
    HeroTitleProxy:ResquestTitleList()
end
--[[
    英雄请求取下称号
]]
function SL:ResquestDisboardTitle_Hero()
    local HeroTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroTitleProxy)
    HeroTitleProxy:ResquestDisboardTitle()
end
--[[
    请求激活称号
]]
function SL:ResquestActivateTitle_Hero(titleId)
    local HeroTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroTitleProxy)
    HeroTitleProxy:ResquestActivateTitle(titleId)
end

--[[
    2 --设置显示神魔
    1 --设置时装显示
]]
function SL:SendSuperEquipSetting_Hero(type)
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    HeroPropertyProxy:SendSuperEquipSetting(type)
end

-- 英雄请求锁定目标
function SL:RequestLockTargetByHero(actorID, isPlayer)
    if not actorID then
        return
    end
    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return
    end
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    HeroPropertyProxy:RequestLockTarget(actor:GetID(), actor:GetMapX(), actor:GetMapY(), isPlayer)
end

-- 英雄取消锁定
function SL:RequestCancelLockByHero()
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    HeroPropertyProxy:CancelLock()
end
---
---------------------------------------------------------------------------
--------------------------------------合成 begin---------------------------
--请求合成
function SL:ResquestCompoundItem()
    local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
    local compoundIndex = ItemCompoundProxy:GetOnCompoundIndex() 
    if not compoundIndex then
        SL:Print("[GUI ERROR] SL:ResquestCompoundItem compoundIndex is empty")
        return
    end
    ItemCompoundProxy:RequestCompound()
end

-- 通知脚本打开不同合成 id:合成表id
function SL:RequestCompoundChangeJson(id)
    local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
    ItemCompoundProxy:requestCompoundChangeJson(id)
end
--------------------------------------合成   end---------------------------

---------------------------------------------------------------------------
--- 请求敏感词检测
function SL:RequestCheckSensitiveWord(str, type, callback)
    if not tonumber(type) then
        return
    end
    local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
    if type == 1 then   -- 昵称类
        SensitiveWordProxy:IsHaveSensitiveAddFilter(str, callback)
    elseif type == 2 then   -- 聊天
        local function handle_Func(state, str, risk_param)
            if risk_param and risk_param ~= 0 then
                callback(false, false)
            else
                callback(state, str, risk_param)
            end
        end
        SensitiveWordProxy:fixSensitiveTalkAddFilter(str, handle_Func)
    elseif type == 3 then   -- 行会公告
        SensitiveWordProxy:fixSensitiveTalkAddFilter(str, callback, 1)
    end
end

-- 批量检测敏感字
function SL:RequestCheckSensitiveWordEx(strList, type, callback)
    if not strList or #strList <= 0 then
        return callback(false)
    end

    local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
    local idx = 1

    local function checkHaveSensitive(str)
        if type == 1 then
            SensitiveWordProxy:IsHaveSensitiveAddFilter(str, function(state) 
                -- 检测，不通过
                if not state then
                    return callback(false)
                end
    
                -- 检测，全部通过
                if idx == #strList then
                    return callback(true)
                end
    
                idx = idx + 1
                checkHaveSensitive(strList[idx])
            end)
        elseif type == 2 then
            SensitiveWordProxy:IsHaveSensitiveTalkAddFilter(str, function(state) 
                -- 检测，不通过
                if not state then
                    return callback(false)
                end
    
                -- 检测，全部通过
                if idx == #strList then
                    return callback(true)
                end
    
                idx = idx + 1
                checkHaveSensitive(strList[idx])
            end)
        end
    end
    checkHaveSensitive(strList[idx])
end

----------------------------------------------------------------------------

---------------------------------------------------------------------------
--- 邀请上马
function SL:RequestInviteInHorse(uid)
    local mainActor = global.gamePlayerController:GetMainPlayer()
    local targetActor = global.actorManager:GetActor(uid)
    if not mainActor then
        return
    end

    if not mainActor:IsDoubleHorse() then
        ShowSystemTips(GET_STRING(310000801))
        return
    end

    if mainActor:GetHorseMasterID() and mainActor:GetHorseCopilotID() then
        ShowSystemTips(GET_STRING(310000802))
        return
    end

    if not targetActor then
        ShowSystemTips(GET_STRING(310000803))
        return
    end

    local mainPos = cc.p(mainActor:GetMapX(), mainActor:GetMapY())
    local targetPos = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
    if cc.pGetDistance(mainPos, targetPos) > 3 then
        ShowSystemTips(GET_STRING(310000804))
        return
    end
    local HorseProxy = global.Facade:retrieveProxy( global.ProxyTable.HorseProxy )
    HorseProxy:RequestHorseUpInvite(uid)
end
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- 交易行
-- 交易行外框按钮点击上报
function SL:RequestTradingBankBtnUpload(type)
    if not type then
        return
    end
    local Box996Proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    Box996Proxy:requestLogUp(Box996Proxy.OTHER_UP_EVEIT[100+type])
end
-- 交易行
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- 服务端特殊记录
-- 通知服务端隐藏主界面聊天框
function SL:NoticeChatVisible(state)
    LuaSendMsg(global.MsgType.MSG_CS_TELL_CHAT_VISIBLE, state and 1 or 0)
end

---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- 小地图
-- 请求组队成员数据
function SL:RequestMiniMapTeam()
    local MiniMapProxy = global.Facade:retrieveProxy(global.ProxyTable.MiniMapProxy)
    MiniMapProxy:RequestTeamMemberData()
end

-- 请求地图怪物数据
function SL:RequestMiniMapMonsters()
    local MiniMapProxy = global.Facade:retrieveProxy(global.ProxyTable.MiniMapProxy)
    MiniMapProxy:RequestMonsters()
end

-- 小地图
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- 内功
-- 请求内功技能数据
function SL:RequestInternalSkillData(isHero)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:RequestNGSkillData(isHero)
end

-- 请求经络穴位激活
function SL:RequestAucPointOpen(typeID, aucPointID, isHero)
    local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
    MeridianProxy:RequestAucPointOpen(typeID, aucPointID, isHero)
end

-- 修炼经络
function SL:RequestMeridianLevelUp(typeID, isHero)
    local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
    MeridianProxy:RequestMeridianLevelUp(typeID, isHero)
end

-- 请求设置连击技能
function SL:RequestSetComboSkill(key, skillID, isHero)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:RequestSetComboSkill(key, skillID, isHero)
end

-- 请求内功hud显示
function SL:RequestNGHudShow(show)
    if show == nil then
        show = true
    end
    local MeridianProxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
    MeridianProxy:SetNGHudShow(show)
    MeridianProxy:OnRefreshNGHudShow()
end
-- 内功
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- 宝箱
-- 请求获取宝箱奖励
function SL:RequestGetGoldBoxReward()
    local GoldBoxProxy = global.Facade:retrieveProxy(global.ProxyTable.GoldBoxProxy)
    GoldBoxProxy:RequsetGetBoxReward()
end

-- 请求再开启宝箱
function SL:RequestOpenGoldBox()
    local GoldBoxProxy = global.Facade:retrieveProxy(global.ProxyTable.GoldBoxProxy)
    GoldBoxProxy:RequsetOpenBoxAgain()
end

---------------------------------------------------------------------------
-- 转生点加属性
-- 请求确认加属性点 [新版]
function SL:RequestAddReinAttr_N(data, m_nBonusPoint)
    local ReinAttrProxy = global.Facade:retrieveProxy(global.ProxyTable.ReinAttrProxy)
    ReinAttrProxy:RequestAddReinAttr_N(data, m_nBonusPoint)
end

---------------------------------------------------------------------------
-- 求购
-- 请求求购列表
function SL:RequestPurchaseItemList(data)
    local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
    PurchaseProxy:RequestItemList(data)
end

-- 求购 出售
function SL:RequestPurchaseSell(data)
    local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
    PurchaseProxy:RequestSell(data)
end

-- 求购 上架
function SL:RequestPurchasePutIn(data)
    local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
    PurchaseProxy:RequestPutIn(data)
end

-- 求购 下架
function SL:RequestPurchasePutOut(data)
    local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
    PurchaseProxy:RequestPutOut(data)
end

-- 求购 取出
function SL:RequestPurchaseTakeOut(data)
    local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
    PurchaseProxy:RequestTakeOut(data)
end

---------------------------------------------------------------------------
-- npc点击
function SL:RequestNPCTalk(npcID)
    if not npcID then
        return false
    end
    local NPCProxy = global.Facade:retrieveProxy( global.ProxyTable.NPC )
    NPCProxy:CheckTalk( npcID )
end

---------------------------------------------------------------------------
-- 游戏内客服
function SL:RequestOpen996ManualService()
    local ManualService996Proxy = global.Facade:retrieveProxy(global.ProxyTable.ManualService996Proxy)
    ManualService996Proxy:RequestManualService()
end
