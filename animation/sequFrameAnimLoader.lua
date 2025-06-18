local sequFrameAnimLoader = class("sequFrameAnimLoader")

sequFrameAnimLoader.DEFAULT_DIR = global.MMO.ORIENT_B

function sequFrameAnimLoader:ctor()
    self:init()
end

function sequFrameAnimLoader:init()
    self._animDataInLoading = {}
end

function sequFrameAnimLoader:Cleanup()
    self._animDataInLoading = {}
end

function sequFrameAnimLoader:getConfig( animID ) 
    local ModelConfigProxy = global.Facade:retrieveProxy( global.ProxyTable.ModelConfigProxy )
    return ModelConfigProxy:GetConfig( animID )
end

function sequFrameAnimLoader:UNITE_ID( ID, PARAM )
    return ID * 0xFF + PARAM
end

function sequFrameAnimLoader:convertTexFileName( rawAnimID, sex, act )  
end

function sequFrameAnimLoader:convertPlistFileName( rawAnimID, sex, act )  
end

function sequFrameAnimLoader:convertTexFileNameByIdx( rawAnimID, sex, act, idx )  
end

function sequFrameAnimLoader:convertPlistFileNameByIdx( rawAnimID, sex, act, idx )  
end

function sequFrameAnimLoader:convertFrameName( rawAnimID, sex, act, dir, frameID )  
end

function sequFrameAnimLoader:OnLoadingBegin()
    global.FrameAnimManager:AddLoadingCount()
end

function sequFrameAnimLoader:OnLoadingFinish()
    global.FrameAnimManager:DecLoadingCount()
end

function sequFrameAnimLoader:notifyCaller( animDataDesc, act, loadcode )
    if nil == self._animDataInLoading[self:UNITE_ID( animDataDesc.animID, act )] then
        return nil
    end

    if animDataDesc.loadCallback then
        animDataDesc.loadCallback( act, loadcode )
    end

    -- clear loading state
    self._animDataInLoading[self:UNITE_ID( animDataDesc.animID, act ) ] = nil
end

function sequFrameAnimLoader:loadSequAnim( animDataDesc, act )
    local animID = animDataDesc.animID
    local loadingID = self:UNITE_ID( animID, act )
    local loadDesc = self._animDataInLoading[loadingID]
    if nil == loadDesc then
        self._animDataInLoading[loadingID] = animDataDesc

        -- on load begin notice
        self:OnLoadingBegin()

        -- check unload unused
        global.FrameAnimManager:unloadUnusedInOOM()

        -- start loading
        self:animResTextureLoad( animDataDesc, act )
    end
end

function sequFrameAnimLoader:releaseCocosAnim( animDataDesc, act, actionDir  )
    local animIndex    = 0
    local animFrameVec = nil
    for dir = 0, actionDir do
        animIndex = GetFrameAnimIndex( act, dir )
        animFrameVec = animDataDesc.animFrameVecs[animIndex]
        if animFrameVec then
            for _, animFrame in ipairs( animFrameVec ) do
                if (not tolua.isnull(animFrame)) then
                    animFrame:release()
                end
            end
        end
        animDataDesc.animFrameVecs[animIndex] = nil
    end
end

function sequFrameAnimLoader:unloadSequAnim( animDataDesc )
    local animCount = global.MMO.ANIM_COUNT
    local actionDir = 7
    for act = 0, animCount - 1 do
        if true == animDataDesc.frameLoaded[act] then
            -- step1 cocos anim
            self:releaseCocosAnim( animDataDesc, act, actionDir )

            -- remove anim texture
            self:removeTextureCache(animDataDesc, act)

            animDataDesc.frameLoaded[act] = nil
        end
    end
end

function sequFrameAnimLoader:animResTextureLoad( animDataDesc, act )
    local modelProxy = global.Facade:retrieveProxy( global.ProxyTable.ModelConfigProxy )
    local animID = animDataDesc.animID
    local config = modelProxy:GetConfig( animID )
    if nil == config then
        self:animResConfigFailed(animDataDesc, act)
        return
    end

    -- calc temporary ID
    local temporaryID = global.FrameAnimManager:GetAnimTemporaryID(animDataDesc.animType, animDataDesc.sex)
    
    -- out of memory
    if global.FrameAnimManager:isMemWarning(animDataDesc.animType) and animDataDesc.animID ~= temporaryID then
        self:animResMemoryWarning(animDataDesc, act)
        return
    end

    -- check loading
    if animDataDesc.animID == temporaryID then
        local texFile       = self:convertTexFileName( animDataDesc.rawAnimID, animDataDesc.sex, act )
        local plistFile     = self:convertPlistFileName( animDataDesc.rawAnimID, animDataDesc.sex, act )
        if not global.SpriteFrameCache:isSpriteFramesWithFileLoaded(plistFile) then
            local function addImageCallback( tex, plistOK )
                -- for memory record
                global.FrameAnimManager:textureMemAdd(tex, texFile)

                self:animResTextureLoadCB( animDataDesc, act, tex, plistOK, config )
            end
            global.SpriteFrameCache:addSpriteFramesWithFileAsync( plistFile, texFile, addImageCallback )
        else
            self:animResTextureLoadCB( animDataDesc, act, true, true, config )
        end
    else
        local atlasCount = modelProxy:GetSplitAtlas( animID, act )
        if atlasCount and atlasCount > 1 then
            for idx = 0, atlasCount-1 do
                local texFile = self:convertTexFileNameByIdx( animDataDesc.rawAnimID, animDataDesc.sex, act, idx )
                local plistFile = self:convertPlistFileNameByIdx( animDataDesc.rawAnimID, animDataDesc.sex, act, idx )
                if not global.FileUtilCtl:isFileExist(plistFile) then
                    self:downloadRes(plistFile, function(isOK)
                        if isOK then
                            self:animResTextureLoad(animDataDesc, act)
                        else
                            self:animResDownloadFailed(animDataDesc, act)
                        end
                    end)
                    break
                    
                elseif not global.FileUtilCtl:isFileExist(texFile) then
                    self:downloadRes(texFile, function(isOK)
                        if isOK then
                            self:animResTextureLoad(animDataDesc, act)
                        else
                            self:animResDownloadFailed(animDataDesc, act)
                        end
                    end)
                    break

                elseif not global.SpriteFrameCache:isSpriteFramesWithFileLoaded(plistFile) then
                    local function addImageCallback( tex, plistOK )
                        -- for memory record
                        global.FrameAnimManager:textureMemAdd(tex, texFile)
                        
                        if not plistOK or nil == tex then
                            self:animResTextureLoadCB(animDataDesc, act, nil, false, config)
                        else
                            self:animResTextureLoad(animDataDesc, act)
                        end
                    end
                    global.SpriteFrameCache:addSpriteFramesWithFileAsync( plistFile, texFile, addImageCallback )
                    break

                elseif idx == atlasCount -1 then
                    self:animResTextureLoadCB( animDataDesc, act, true, true, config )
                end
            end
        else
            local texFile = self:convertTexFileName( animDataDesc.rawAnimID, animDataDesc.sex, act )
            local plistFile = self:convertPlistFileName( animDataDesc.rawAnimID, animDataDesc.sex, act )
            if not global.FileUtilCtl:isFileExist(plistFile) then
                self:downloadRes(plistFile, function(isOK)
                    if isOK then
                        self:animResTextureLoad(animDataDesc, act)
                    else
                        self:animResDownloadFailed(animDataDesc, act)
                    end
                end)
                
            elseif not global.FileUtilCtl:isFileExist(texFile) then
                self:downloadRes(texFile, function(isOK)
                    if isOK then
                        self:animResTextureLoad(animDataDesc, act)
                    else
                        self:animResDownloadFailed(animDataDesc, act)
                    end
                end)

            elseif not global.SpriteFrameCache:isSpriteFramesWithFileLoaded(plistFile) then
                local function addImageCallback( tex, plistOK )
                    -- for memory record
                    global.FrameAnimManager:textureMemAdd(tex, texFile)

                    self:animResTextureLoadCB( animDataDesc, act, tex, plistOK, config )
                end
                global.SpriteFrameCache:addSpriteFramesWithFileAsync( plistFile, texFile, addImageCallback )
            else
                self:animResTextureLoadCB( animDataDesc, act, true, true, config )
            end
        end
    end
end

function sequFrameAnimLoader:animResTextureLoadCB( animDataDesc, act, tex, plistOK, config )
    if not plistOK or nil == tex then
        -- remove anim texture
        self:removeTextureCache(animDataDesc, act)
        
        -- except temporary
        local temporaryID = global.FrameAnimManager:GetAnimTemporaryID(animDataDesc.animType, animDataDesc.sex)
        if animDataDesc.animID ~= temporaryID then
            local modelProxy = global.Facade:retrieveProxy( global.ProxyTable.ModelConfigProxy )
            local splitCount = modelProxy:GetSplitAtlas( animDataDesc.animID, act )

            if splitCount then
                for i = 0, splitCount-1 do
                    -- del plist
                    local plistFile = self:convertPlistFileNameByIdx( animDataDesc.rawAnimID, animDataDesc.sex, act , i )
                    self:onLoadFileError(plistFile)
                    
                    -- del png
                    local texFile = self:convertTexFileNameByIdx( animDataDesc.rawAnimID, animDataDesc.sex, act ,i )
                    self:onLoadFileError(texFile)
                end
            else
                -- del plist
                local plistFile = self:convertPlistFileName( animDataDesc.rawAnimID, animDataDesc.sex, act )
                self:onLoadFileError(plistFile)
                
                -- del png
                local texFile = self:convertTexFileName( animDataDesc.rawAnimID, animDataDesc.sex, act )
                self:onLoadFileError(texFile)
            end
        end
    else
        -- creat sprite frame
        self:createAnimation( animDataDesc, act, config )
    end

    -- notify
    if not plistOK then
        self:notifyCaller( animDataDesc, act, global.MMO.ANIM_LOAD_FRAME )
    elseif nil == tex then
        self:notifyCaller( animDataDesc, act, global.MMO.ANIM_LOAD_TEX )
    else
        self:notifyCaller( animDataDesc, act, global.MMO.ANIM_LOAD_SUCCESS )
    end

    -- on load finish notice
    self:OnLoadingFinish()
end

function sequFrameAnimLoader:animResConfigFailed(animDataDesc, act)
    self:notifyCaller( animDataDesc, act, global.MMO.ANIM_LOAD_CONFIG )

    -- on load finish notice
    self:OnLoadingFinish()
end

function sequFrameAnimLoader:animResMemoryWarning(animDataDesc, act)
    self:notifyCaller( animDataDesc, act, global.MMO.ANIM_LOAD_OOM )

    -- remove anim texture
    self:removeTextureCache(animDataDesc, act)

    -- on load finish notice
    self:OnLoadingFinish()
end

function sequFrameAnimLoader:animResDownloadFailed( animDataDesc, act )
    self:notifyCaller( animDataDesc, act, global.MMO.ANIM_LOAD_TIMEOUT )

    -- on load finish notice
    self:OnLoadingFinish()
end

function sequFrameAnimLoader:createAnimation( animDataDesc, act, config )
    local animID   = animDataDesc.animID
    local sex      = animDataDesc.sex

    local dir          = 0
    local frameName    = ""
    local spriteFrame  = nil
    local animFrame    = nil
    local actionDir    = 7
    
    -- 施法动作重复第五帧
    local additionACT = (act == global.MMO.ANIM_SKILL)

    for i = 0, actionDir do
        dir = i
        local animIndex = GetFrameAnimIndex( act, i )

        local animFrameVec = {}
        local animFrameCnt = 0

        for xy = 0, 100 do
            frameName = self:convertFrameName( animDataDesc.rawAnimID, sex, act, dir, xy )
            spriteFrame = global.SpriteFrameCache:getSpriteFrame( frameName, true )
            if spriteFrame then
                animFrame = cc.AnimationFrame:create( spriteFrame, 1, {} )
                animFrame:retain()
                animFrameCnt = animFrameCnt + 1
                animFrameVec[animFrameCnt] = animFrame

                if additionACT and xy == 4 then
                    animFrame = cc.AnimationFrame:create( spriteFrame, 1, {} )
                    animFrame:retain()
                    animFrameCnt = animFrameCnt + 1
                    animFrameVec[animFrameCnt] = animFrame
                    
                    animFrame = cc.AnimationFrame:create( spriteFrame, 1, {} )
                    animFrame:retain()
                    animFrameCnt = animFrameCnt + 1
                    animFrameVec[animFrameCnt] = animFrame
                end
            else
                -- 其他帧可能没有，只取0方向作为间隔
                if not config.frame[act] then
                    config.frame[act] = xy
                end
                break
            end
        end

        local inerval = config.interval[act] or global.MMO.ANIM_DEFAULT_INTERVAL
        animDataDesc.animFrameVecs[animIndex] = animFrameCnt > 0 and animFrameVec or nil
        animDataDesc.animDelays[animIndex] = additionACT and (inerval * 0.75) or inerval
    end
    animDataDesc.frameLoaded[act]  = true
end

function sequFrameAnimLoader:removeTextureCache(animDataDesc, act)
    local modelProxy = global.Facade:retrieveProxy( global.ProxyTable.ModelConfigProxy )
    local atlasCount = modelProxy:GetSplitAtlas( animDataDesc.animID, act )
    if atlasCount and atlasCount > 1 then
        for idx = 0, atlasCount-1 do
            local texFile = self:convertTexFileNameByIdx( animDataDesc.rawAnimID, animDataDesc.sex, act, idx )
            local plistFile = self:convertPlistFileNameByIdx( animDataDesc.rawAnimID, animDataDesc.sex, act, idx )
            if global.SpriteFrameCache:isSpriteFramesWithFileLoaded( plistFile ) then
                global.SpriteFrameCache:removeSpriteFramesFromFile( plistFile )
                global.TextureCache:removeTextureForKey( texFile )
    
                -- for memory record
                global.FrameAnimManager:textureMemDel(texFile)
            end
        end
    else
        local texFile = self:convertTexFileName( animDataDesc.rawAnimID, animDataDesc.sex, act )
        local plistFile = self:convertPlistFileName( animDataDesc.rawAnimID, animDataDesc.sex, act )
        if global.SpriteFrameCache:isSpriteFramesWithFileLoaded( plistFile ) then
            global.SpriteFrameCache:removeSpriteFramesFromFile( plistFile )
            global.TextureCache:removeTextureForKey( texFile )
    
            -- for memory record
            global.FrameAnimManager:textureMemDel(texFile)
        end
    end
end

--------------------- download ---------------------
function sequFrameAnimLoader:downloadRes(path, callback)
    global.ResDownloader:download(path, callback)
end

function sequFrameAnimLoader:onLoadFileError(filePath)
    release_print("onLoadFileError", filePath)
    if not global.FileUtilCtl:isFileExist(filePath) then
        return
    end
    local fullPath = global.FileUtilCtl:fullPathForFilename(filePath)
    if not (fullPath ~= "" and string.find(fullPath, global.FileUtilCtl:getWritablePath())) then
        return
    end
    global.FileUtilCtl:removeFile( fullPath )
    global.FileUtilCtl:purgeCachedEntries()
end
----------------------------------------------------

return sequFrameAnimLoader
