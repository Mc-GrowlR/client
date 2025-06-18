ConfigUpdateInfo = {}

function ConfigUpdateInfo.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "config_update_info_ui/config_update_info")
    ConfigUpdateInfo._ui = GUI:ui_delegate(parent)

    GUI:addOnClickEvent(ConfigUpdateInfo._ui["Button_update"], function()
        if GET_GAME_STATE() == global.MMO.GAME_STATE_WORLD then
            SL:UpdateConfig()
            SL:ShowSystemTips("更新成功.......")
        else 
            SL:ShowSystemTips("请进入游戏世界后操作.......")
        end 
    end) 
end

function ConfigUpdateInfo.close()
    print("ConfigUpdateInfo.close")
end

return ConfigUpdateInfo