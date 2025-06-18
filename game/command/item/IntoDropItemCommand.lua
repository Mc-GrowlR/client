local IntoDropItemCommand = class('IntoDropItemCommand', framework.SimpleCommand)

function IntoDropItemCommand:ctor()
end

function IntoDropItemCommand:execute(notification)
    local itemData = notification:getBody()
    if itemData then
        local function drop(dropNum)
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
            local Name = itemData.Name
            local MakeIndex = itemData.MakeIndex
            
            LuaSendMsg(global.MsgType.MSG_CS_MAP_ITEM_DISCARD, MakeIndex, dropNum or 0, 0, 0, Name, string.len(Name))
        end

        local dropItemNum = 0

        local function RefreshBagItem()
            -- 背包中的重新刷出来
            local data = {
                dropping = {
                    MakeIndex = itemData.MakeIndex,
                    state = 1
                }
            }
            global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
        end

        local function RefreshBagItemQuickUse()
            local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
            local itemPos = QuickUseProxy:GetQucikUsePosByMakeIndex(itemData.MakeIndex)
            local data = {
                pos = itemPos,
                state = 1                
            }
            global.Facade:sendNotification(global.NoticeTable.QuickUseItemRefresh, data)
        end

        local function CancelAndReset()
            local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
            local itemFrom = ItemManagerProxy:GetItemBelong(itemData.MakeIndex)
            if itemFrom == global.MMO.ITEM_FROM_BELONG_BAG then
                RefreshBagItem()
            elseif itemFrom == global.MMO.ITEM_FROM_BELONG_QUICKUSE then
                RefreshBagItemQuickUse()
            end

            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        end

        local function DropItems()
            local dropTips = CHECK_SERVER_OPTION(global.MMO.SERVER_DROP_TIPS)
            local isBind = CheckItemisBind(itemData)
            if isBind and dropTips == 0 then
                local function checkBind(atype, aData)
                    if atype == 1 then
                        drop(dropItemNum)
                    else
                        CancelAndReset()
                    end
                end

                local data = {}
                data.str = string.format(GET_STRING(90020013), itemData.Name)
                data.callback = checkBind
                data.btnType = 2
                global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
            else
                drop(dropItemNum)
            end
        end
        -- 随机石 回城石
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        local isStone        = ItemManagerProxy:IsCityStone(itemData) or ItemManagerProxy:IsRandStone(itemData)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        if not isStone and ItemConfigProxy:CheckItemOverLap(itemData) then
            -- 叠加道具使用
            local Name    = itemData.Name
            local MakeIndex = itemData.MakeIndex
            local function callback(btnType, data)
                local num = 0
                if data.editStr and tonumber(data.editStr) then
                    num = tonumber(data.editStr)
                end
                if num > itemData.OverLap then
                    dropItemNum = itemData.OverLap
                    DropItems()
                    -- global.Facade:sendNotification( global.NoticeTable.SystemTips, GET_STRING( 90020007 ) )
                    -- CancelAndReset()
                    -- return
                elseif num <= 0 then
                    CancelAndReset()
                    return
                else
                    dropItemNum = num
                    DropItems()
                end
            end
            local data = {}
            data.str = GET_STRING(90020009)
            data.callback = callback
            data.btnType = SL:GetMetaValue("GAME_DATA","DropCancelShow") and 2 or 1
            data.showEdit = true
            data.editParams = {
                inputMode = 2
            }
            global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        else
            DropItems()
        end
    end
end

return IntoDropItemCommand