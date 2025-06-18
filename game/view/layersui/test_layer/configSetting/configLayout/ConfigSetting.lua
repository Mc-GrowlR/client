ConfigSetting = {}

-- 文件名和类名一致
ConfigSetting._pagesCfg = {
    { name = "更新内容",                          fileName = "ConfigUpdateInfo"  },
    { name = "参数配置\n cfg_game_data.lua",      fileName = "GameDataSetting"   },
    { name = "拍卖行配置\n cfg_auction_type.lua", fileName = "AuctionSet"        },
    { name = "飘血配置\n cfg_damage_number.lua",  fileName = "DamageNumSetting"  },
    { name = "地图描述配置\n cfg_mapdesc.lua",    fileName = "MapSetting"        },
    { name = "内挂配置\n cfg_setup.lua",          fileName = "NeiGuaSetting"     },
    { name = "BUFF配置\n cfg_buff.lua",           fileName = "BuffSetting"       },
    { name = "声音配置\n cfg_sound.lua",          fileName = "SoundSetting"      },
    { name = "属性配置\n cfg_att_score.lua",      fileName = "AttSetting"        },
    { name = "经络配置\n cfg_PulsDesc.lua",       fileName = "PulsDescSetting"   },
    { name = "拾取设置\n cfg_pick_set.lua",       fileName = "PickSetting"       },
    { name = "界面设置\n cfg_menulayer.lua",      fileName = "MenuSetting"       },
    --{ name = "套装备注\n cfg_suit.lua",           fileName = "SuitSetting"       },
    { name = "自定义属性\n cfg_custpro_caption.lua", fileName = "CaptionSetting"       },
    { name = "预览技能配置\n cfg_skill_present.lua", open = global.NoticeTable.PreviewSkillOpen},
    { name = "技能配置\n cfg_magicinfo.lua", open = global.NoticeTable.MagicInfoOpen},
}

function ConfigSetting.main(index)
    local parent = GUI:Attach_Parent()
    loadConfigSettingExport(parent, "main_frame")

    ConfigSetting._ui = GUI:ui_delegate(parent)
    ConfigSetting._nodeUI = ConfigSetting._ui["nodeUI"]

    ConfigSetting._pages = {}
    ConfigSetting._index = 0
    ConfigSetting._openPage = nil

    ConfigSetting.initAdapet()

    -- 关闭按钮
    GUI:addOnClickEvent(ConfigSetting._ui["Button_close"], function()
        GUI:Win_Close(parent)
    end)

    ConfigSetting.initPages()

    -- 默认跳到第一个
    ConfigSetting.pageTo(1)
end

function ConfigSetting.initAdapet()
    local ww = SL:GetMetaValue("SCREEN_WIDTH")
    local hh = SL:GetMetaValue("SCREEN_HEIGHT")

    GUI:setContentSize(ConfigSetting._ui["ListView_page"], 200, hh)
    GUI:setContentSize(ConfigSetting._ui["Panel_background"], ww, hh)
    GUI:setPosition(ConfigSetting._ui["Button_close"], ww - 8, hh)
end

function ConfigSetting.initPages()
    local ListView_page = ConfigSetting._ui["ListView_page"]
    for k, v in ipairs(ConfigSetting._pagesCfg) do
        local pageCell = ConfigSetting.createPageCell()
        GUI:Win_SetParam(pageCell, k)
        GUI:addOnClickEvent(pageCell, function()
            ConfigSetting.pageTo(k)
        end)
        local PageText = GUI:getChildByName(pageCell, "PageText")
        GUI:Text_setTextHorizontalAlignment(PageText, 1)
        GUI:Text_setString(PageText, v.name)
        ConfigSetting._pages["pageCell" .. k] = pageCell
        GUI:ListView_pushBackCustomItem(ListView_page, pageCell)
    end
end

function ConfigSetting.createPageCell()
    local parent = GUI:Node_Create(ConfigSetting._ui["nativeUI"], "node", 0, 0)
    loadConfigSettingExport(parent, "page_cell")
    local page_cell = GUI:getChildByName(parent, "page_cell")
    GUI:removeFromParent(page_cell)
    GUI:removeFromParent(parent)
    return page_cell
end

function ConfigSetting.pageTo(index)
    local pageCfg = ConfigSetting._pagesCfg[index]
    if pageCfg and pageCfg.open then
        global.Facade:sendNotification(pageCfg.open)
        return
    end

    if ConfigSetting._index == index then
        return
    end

    ConfigSetting.onClose()

    ConfigSetting._index = index

    ConfigSetting.setPageStatus()

    ConfigSetting.onOpen()
end

function ConfigSetting.onOpen()
    local pageCfg = ConfigSetting._pagesCfg[ConfigSetting._index]
    if pageCfg and pageCfg.fileName and pageCfg.fileName ~= "" then
        local filePath = "game/view/layersui/test_layer/configSetting/configLayout/" .. pageCfg.fileName
        ConfigSetting._openPage = SL:RequireFile(filePath)
        ConfigSetting._openPage.main(ConfigSetting._nodeUI)
    end
end

function ConfigSetting.onClose()
    if ConfigSetting._openPage then
        if ConfigSetting._openPage.close then
            ConfigSetting._openPage.close()
        end
        ConfigSetting._openPage = nil
    end
    GUI:removeAllChildren(ConfigSetting._nodeUI)
end

function ConfigSetting.setPageStatus()
    for _, uiPage in pairs(ConfigSetting._pages) do
        local index = GUI:Win_GetParam(uiPage)
        local isSel = index == ConfigSetting._index and true or false
        GUI:Layout_setBackGroundColor(uiPage, isSel and "#ffbf6b" or "#000000")
    end
end