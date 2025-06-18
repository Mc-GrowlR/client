
local config = {
    [0] = { -- npc对话框
        startEventTag = "GUIDE_NPC_TALK_LOAD_SUCCESS",
        closeEventTag = "GUIDE_END_NPC_TALK_LAYER_CLOSED"
    },
    [1] = { -- 背包道具
        startEventTag = "GUIDE_BAG_ITEM_LOAD_SUCCESS",
        closeEventTag = "GUIDE_BAG_LAYER_CLOSED"
    },
    [2] = {--人物装备位
        startEventTag = "GUIDE_PLAYER_EQUIP_LOAD_SUCCESS"
    },
    [7] = { -- 背包挂接组件
       startEventTag =  "GUIDE_BAG_COMPONENT_LOAD_SUCCESS"
    },
    [9] = { --商店加载完成
        startEventTag = "GUIDE_STORE_ITEM_LOAD_SUCCESS"
    },
    [10] = {
        startEventTag = "GUIDE_STORE_ITEM_LOAD_SUCCESS"
    }, 
    [11] = {
        startEventTag = "GUIDE_STORE_ITEM_LOAD_SUCCESS"
    },
    [12] = {
        startEventTag = "GUIDE_STORE_ITEM_LOAD_SUCCESS"
    },
    [101] = {--主界面挂接组件左上

        -- startEventTag = nil,
        -- closeEventTag = "BagLayerMediator"
    },
    [102] = {--主界面挂接组件右上
        
        -- startEventTag = nil,
        -- closeEventTag = "BagLayerMediator"
    },
    [103] = {--主界面挂接组件左下
        
        -- startEventTag = nil,
        -- closeEventTag = "BagLayerMediator"
    },
    [104] = {--主界面挂接组件右下
        
        -- startEventTag = nil,
        -- closeEventTag = "BagLayerMediator"
    },
    [105] = {--主界面挂接组件左中
        
        -- startEventTag = nil,
        -- closeEventTag = "BagLayerMediator"
    },
    [106] = {--主界面挂接组件上中
        
        -- startEventTag = nil,
        -- closeEventTag = "BagLayerMediator"
    },
    [107] = {--主界面挂接组件右中
        
        -- startEventTag = nil,
        -- closeEventTag = "BagLayerMediator"
    },
    [108] = {--主界面挂接组件下中
        
        -- startEventTag = nil,
        -- closeEventTag = "BagLayerMediator"
    },
    [109] = {--主界面技能模块按钮   
        startEventTag =  "GUIDE_BEGIN_SKILL_BUTTON",
        closeEventTag = "GUIDE_END_SKILL_BUTTON", 
    },    
    [110] = {--主界面导航栏任务  
        startEventTag =  "GUIDE_ASSIST_MISSION_BEGIN" ,     
        closeEventTag = "GUIDE_ASSIST_MISSION_END",
    },
}

return config