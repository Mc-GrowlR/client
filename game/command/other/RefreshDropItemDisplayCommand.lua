local RefreshDropItemDisplayCommand = class('RefreshDropItemDisplayCommand', framework.SimpleCommand)
local optionsUtils                  = requireProxy( "optionsUtils" )

function RefreshDropItemDisplayCommand:ctor()
end

function RefreshDropItemDisplayCommand:execute()
    local itemVec, nItemVec = global.dropItemManager:FindDropItemInCurrViewFieldAll()
    for i = 1, nItemVec do
        local actor = itemVec[i]
        if actor then
            optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_NAMELabel_VISIBLE)
            optionsUtils:refreshHUDLabelNameVisible(actor)
        end
    end
end

return RefreshDropItemDisplayCommand
