local ItemUpdateCommand = class("ItemUpdateCommand", framework.SimpleCommand)

function ItemUpdateCommand:ctor()
end

function ItemUpdateCommand:execute(notification)
    local updateData = notification:getBody()
    local from        = updateData.from
    local item        = updateData.item

    local stdModes = { 0, 1, 2, 3, 4, 31, 40, 42, 44, 45, 46, 47, 49, 200 }
    local function isStdMode(sm)
        for _, v in pairs(stdModes) do
            if v == sm then
                return true
            end
        end
        return false
    end

    -- 持久提醒
    if CHECK_SETTING(50) == 1 and item.OverLap <= 1 and (item.StdMode ~= 2 or (item.Shape ~= 1 and item.Shape ~= 2)) and not isStdMode(item.StdMode) then
        if item.StdMode == 96 and item.Shape > 0 then --祝福罐  根据最大持久度判断

            local isShowSystemChat  = false
            local duraValue         = tonumber(SL:GetMetaValue("GAME_DATA","chijiuts")) 
            if not duraValue and item.DuraMax and item.DuraMax < 2000 then
                isShowSystemChat = true
            elseif duraValue and item.Dura and item.DuraMax and (item.Dura / item.DuraMax) * 100 <= duraValue then
                isShowSystemChat = true
            end

            if isShowSystemChat then
                if SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_DISPOSE_ITEM_FRM_CHIJIU) then
                    ShowSystemChat(string.format(GET_STRING(30001076), item.Name), 251, 249)
                else
                    ShowSystemChat(string.format(GET_STRING(30001070), item.Name), 251, 249)
                end
            end
        else

            local isShowSystemChat  = false
            local duraValue         = tonumber(SL:GetMetaValue("GAME_DATA","chijiuts"))      
            if not duraValue and item.Dura and item.Dura < 1000 then
                isShowSystemChat = true
            elseif duraValue and item.Dura and item.DuraMax and (item.Dura / item.DuraMax) * 100 <= duraValue then
                isShowSystemChat = true
            end

            if isShowSystemChat then
                if SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_DISPOSE_ITEM_FRM_CHIJIU) then
                    ShowSystemChat(string.format(GET_STRING(30001076), item.Name), 251, 249)
                else
                    ShowSystemChat(string.format(GET_STRING(30001070), item.Name), 251, 249)
                end
            end
        end
    end
end

return ItemUpdateCommand