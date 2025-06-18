local AutoFindNPCCommand = class('AutoFindNPCCommand', framework.SimpleCommand)

function AutoFindNPCCommand:ctor()
end

function AutoFindNPCCommand:execute(notification)
    local facade      = global.Facade
    local autoProxy   = facade:retrieveProxy( global.ProxyTable.Auto )
    local targetIndex = autoProxy:GetTargetIndex()

    local targetNpc = nil

    local npcVec, ncount = global.npcManager:GetNpcInCurrViewField()
    for i = 1, ncount do
        local npc = npcVec[i]
        if npc then
            if type(targetIndex) == "number" then
                if npc:GetTypeIndex() == targetIndex then
                    targetNpc = npc
                    break
                end
            elseif type(targetIndex) == "table" then
                for j = 1, #targetIndex do
                    local index = targetIndex[j]
                    if index and index == npc:GetTypeIndex() then
                        targetNpc = npc
                        break
                    end
                end
            end
        end
    end

    if not targetNpc then
        return false
    end

    local NPCProxy = facade:retrieveProxy( global.ProxyTable.NPC )
    NPCProxy:CheckTalk( targetNpc:GetID(), true )

    -- input idle
    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    autoProxy:ClearAFKState()
    autoProxy:ClearAllState()
    autoProxy:ClearPickState()
end

return AutoFindNPCCommand
