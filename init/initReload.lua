local layerFiles = {
    -- debug map
    -- "game/view/scene/DebugMapLayout",
    -- "game/view/csd/framerate/framerate",
    -- "game/view/layersui/framerate/FrameRateLayout",
    -- "game/view/layersui/comb_skill_layer/CombSkillLayer",
    -- "game/view/layersui/advance_level_layer/AdvanceLevelLayer",
    -- "game/view/layersui/vip_layer/ColourVipPanel",

    -- "game/view/layersui/preview_anim/PreviewAnimLayout",
    -- "game/view/export/preview_anim/preview_anim",

    -- "game/view/layersui/comb_skill_layer/CombSkillLayer",
    -- "game/view/layersui/advance_level_layer/AdvanceLevelLayer",
    -- "game/view/layersui/heart_magic_layer/HeartMagicLayer"
    --"game/view/layersui/hero_layer/HeroSelectSkillLayer",
}

local mediatorFiles = {
    -- debug map
    -- "game/mediator/debug_map/DebugMapMediator",
    -- "game/mediator/couping/FrameRateMediator",
    -- "game/mediator/comb_skill_layer/CombSkillMediator",
    -- "game/mediator/advance_level_layer/AdvanceLevelMediator",

    -- "game/mediator/comb_skill_layer/CombSkillMediator",
    -- "game/mediator/advance_level_layer/AdvanceLevelMediator"
}

local voFiles = {}

-- warning, remote proxy maybe register msg handler twice.
local proxyFiles = {}

local utilFiles = {}

local cmdFiles = nil

local function reloadLayer(files)
    for _, v in pairs(files) do
        package.loaded[v] = nil
        require(v)
        print("Reload File:" .. v .. ".lua")
    end
end

local function reloadMediaotr(files)
    for _, v in pairs(files) do
        if package.loaded[v] then
            -- invoke unloaded
            package.loaded[v].OnUnloaded()

            package.loaded[v] = nil
        end

        local mediator = require(v)
        -- invoke loaded
        mediator.Onloaded()
        print("Reload File:" .. v .. ".lua")
    end
end

local function reloadProxy(files)
    for _, v in pairs(files) do
        if package.loaded[v] then
            -- invoke unloaded
            package.loaded[v].OnUnloaded()

            package.loaded[v] = nil
        end

        local proxy = require(v)
        -- invoke loaded
        proxy.Onloaded()
        print("Reload File:" .. v .. ".lua")
    end
end

local function reloadVO(files)
    for _, v in pairs(files) do
        package.loaded[v] = nil
        require(v)
        print("Reload File:" .. v .. ".lua")
    end
end

local function reloadUtil(files)
    for _, v in pairs(files) do
        package.loaded[v] = nil
        require(v)
        print("Reload File:" .. v .. ".lua")
    end
end

local function reloadCommand(files)
    for k, v in pairs(files) do
        if package.loaded[v] then
            global.Facade:removeCommand( k )
            package.loaded[v] = nil
        end

        local command = require(v)
        global.Facade:registerCommand( k, command )
        print("Reload File:" .. v .. ".lua")
    end
end

local function UnitTest()
end

local function reload_func()
    print("====================================================================")
    -- 1. layer
    if #layerFiles > 0 then
        print("************************* reload layer *****************************")
        reloadLayer(layerFiles)
    end

    -- 2. mediator
    if #mediatorFiles > 0 then
        print("************************* reload mediator **************************")
        reloadMediaotr(mediatorFiles)
    end

    -- 3. VO
    if #voFiles > 0 then
        print("************************* reload ValueObject ***********************")
        reloadVO(voFiles)
    end

    -- 4. proxy
    if #proxyFiles > 0 then
        print("************************* reload proxy *****************************")
        reloadProxy(proxyFiles)
    end

    -- 5. util
    if utilFiles and #utilFiles > 0 then
        print("************************* reload util *****************************")
        reloadUtil(utilFiles)
    end

    -- 6. command
    if cmdFiles then
        print("************************* reload command *****************************")
        reloadCommand(cmdFiles)
    end

    -- 7. unit test
    if UnitTest then
        print("************************* unit test *****************************")
        UnitTest()
    end
    print("====================================================================")
end

function reload_script_files()
    -- debug switch
    _DEBUG = true

    -- default reload
    reload_func()


    -- local reload
    local localReloadPath = "scripts/init/localReload.lua"
    local loadReloadName = "init/localReload"
    if cc.FileUtils:getInstance():isFileExist( localReloadPath ) then
        package.loaded[loadReloadName] = nil
        local localReload = require(loadReloadName)

        layerFiles    = localReload.layerFiles
        mediatorFiles = localReload.mediatorFiles
        voFiles       = localReload.voFiles
        proxyFiles    = localReload.proxyFiles
        utilFiles     = localReload.utilFiles
        cmdFiles      = localReload.cmdFiles
        UnitTest      = localReload.UnitTest
        reload_func()
    end

end
