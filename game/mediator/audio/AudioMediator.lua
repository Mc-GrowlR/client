local AudioMediator = class('AudioMediator', framework.Mediator)
AudioMediator.NAME  = "AudioMediator"

function AudioMediator:ctor()
    AudioMediator.super.ctor( self, self.NAME )

    self._audioEngine   = ccexp.AudioEngine

    self._musicEnable   = true
    self._effectEnable  = true

    local AudioProxy 	= global.Facade:retrieveProxy(global.ProxyTable.Audio)
    self._musicVolume   = AudioProxy:getMusicVolume()
    self._effectVolume  = AudioProxy:getEffectVolume()

    self._musicEntity   = nil
    self._effectEntitys = {}
    self._audioCount 	= {}

    self._BGMPath       = nil
    self._BGMStop		= nil

    self._playCount     = 0

    self:Init()
end

function AudioMediator:Init()
    local NT = global.NoticeTable
    self._noticeMaps = {
        [NT.Audio_Play]          = function (...) self:PlayAudio(...) end,
        [NT.Audio_Play_BGM]      = function (...) self:PlayBGM(...) end,
        [NT.Audio_Stop_BGM]      = function (...) self:StopBGM() end,
        [NT.Audio_Play_EffectId] = function (...) self:PlayEffectById(...) end,
        [NT.Audio_Stop_EffectId] = function (...) self:StopEffectByID(...) end,
        [NT.Audio_Pause_All]     = function (...) self:PauseAll() end,
        [NT.Audio_Resume_All]    = function (...) self:ResumeAll() end,
        [NT.Audio_Stop_All]      = function (...) self:StopAll() end,
        [NT.GameSettingInited]   = function (...) self:onGameSettingInited() end,
        [NT.GameSettingChange]   = function (...) self:onGameSettingChange(...) end,
        [NT.MapInfoChange]       = function (...) self:onMapInfoChange() end
    }
end

function AudioMediator:listNotificationInterests()
    local NT = global.NoticeTable
    return  {
        NT.Audio_Play,
        NT.Audio_Play_BGM,
        NT.Audio_Stop_BGM,
        NT.Audio_Play_EffectId,
        NT.Audio_Stop_EffectId,
        NT.Audio_Pause_All,
        NT.Audio_Resume_All,
        NT.Audio_Stop_All,
        NT.GameSettingInited,
        NT.GameSettingChange,
        NT.MapInfoChange
    }
end


function AudioMediator:handleNotification(notification)
    local noticeID = notification:getName()
    if self._noticeMaps[noticeID] then
        self._noticeMaps[noticeID](notification:getBody())
    end
end

function AudioMediator:onMapInfoChange()
    --地图场景BGM
    self:PlayBGM({type = global.MMO.SND_TYPE_BGM_MAP})
end

function AudioMediator:onGameSettingInited()
    self:changeBGMVolume()
    self:changeEffectVolume()
end

function AudioMediator:onGameSettingChange(data)
    if data.id == 27 then
        -- 背景音乐
        self:changeBGMVolume()
        local value = CHECK_SETTING(27) or 0
        local tips  = value == 0 and GET_STRING(30053001) or string.format(GET_STRING(30053002), value or 0)
        ShowSystemChat(tips, 255, 0)

    elseif data.id == 52 then
        -- 游戏音效
        self:changeEffectVolume()
        local value = CHECK_SETTING(52) or 0
        local tips  = value == 0 and GET_STRING(30053003) or string.format(GET_STRING(30053004), value or 0)
        ShowSystemChat(tips, 255, 0)
    end
end

function AudioMediator:changeBGMVolume()
    local volume        = CHECK_SETTING(27) or 0
    local enable        = volume > 0
    self._musicEnable   = enable
    self._musicVolume   = volume / 100
    self:SetBGMVolume(self._musicVolume)
end

function AudioMediator:changeEffectVolume()
    local volume        = CHECK_SETTING(52) or 0
    local enable        = volume > 0
    self._effectEnable  = enable
    self._effectVolume  = volume / 100
    self:SetEffectEnabled(enable)
end

function AudioMediator:PauseAll()
    self._audioEngine:pauseAll()
    self:clearAudioCount()
end

function AudioMediator:ResumeAll()
    self._audioEngine:resumeAll()
end

function AudioMediator:StopAll()
    self._BGMStop = true
    self._BGMPath = nil
    self._audioEngine:stopAll()
    self:clearAudioCount()
end

function AudioMediator:PlayAudio( data )
    local AudioProxy = global.Facade:retrieveProxy(global.ProxyTable.Audio)
    local id, delayTime, id2, delayTime2 = AudioProxy:getAudioId(data)
    if not id then return end

    local config = AudioProxy:GetConfig( id )
    if not config or not config.file or config.file == "" then
        return
    end

    local isLoop = data.isLoop and data.isLoop or false

    if delayTime and delayTime > 0 then
        PerformWithDelayGlobal( function()
            self:PlayEffect(config.file, isLoop, data.type)
        end, delayTime )
    else
        self:PlayEffect(config.file, isLoop, data.type)
    end

    if id2 then
        local config = AudioProxy:GetConfig( id2 )
        if config and config.file then
            if delayTime2 and delayTime2 > 0 then
                PerformWithDelayGlobal( function()
                    self:PlayEffect(config.file, isLoop, data.type)
                end, delayTime2 )
            else
                self:PlayEffect(config.file, isLoop, data.type)
            end
        end
    end
end

function AudioMediator:PlayBGM( data, isLoop )
    local AudioProxy = global.Facade:retrieveProxy(global.ProxyTable.Audio)
    local path = data.path or AudioProxy:getBGMPath(data)

    if not path or path == "" then
        self:StopBGM()
        return
    end
    if not data.path and path ~= nil and path == self._BGMPath then
        return
    end

    if not self._musicEnable or not path or path == "" then
        return
    end

    -- stop last bgm
    self:StopBGM()
    self._BGMStop		= false
    self._BGMPath       = path
    self._musicEntity 	= self:play( path, true, self._musicVolume )
end

function AudioMediator:PlayBGMByPath(path)
    if not path then
        return nil
    end

    self:StopBGM()
    self._BGMStop		= false
    self._BGMPath       = path
    self._musicEntity 	= self:play( path, true, self._musicVolume )
end

function AudioMediator:StopBGM()
    if self._musicEntity then
        self._audioEngine:stop( self._musicEntity.id )
        self._musicEntity 	= nil
        self._BGMStop		= true
        self._BGMPath       = nil
        self._playCount     = self._playCount - 1
    end
end

function AudioMediator:effectFinishCallback( audioID, path )
    -- clear trace
    self:onAudioStop(audioID)

    local entity = self._effectEntitys[audioID]
    if entity and entity.times and entity.times > 1 then
        self:PlayEffect(entity.path, false, entity.type, entity.times-1)
    end

    self._effectEntitys[audioID] = nil
end

function AudioMediator:StopEffectByPath( path )
    local effect = nil
    for _, entity in pairs( self._effectEntitys ) do
        if path == entity.path then
            effect = entity
            break
        end
    end

    if effect then
        self:stop( effect.id )

        self._effectEntitys[effect.id] = nil
    end

    return nil
end

function AudioMediator:StopEffectByType( type )
    local effect = nil
    for _, entity in pairs( self._effectEntitys ) do
        if type == entity.type then
            effect = entity
            break
        end
    end

    if effect then
        self:stop( effect.id )
        self._effectEntitys[effect.id] = nil
    end

    return nil
end

function AudioMediator:StopEffectByID(id)
    local AudioProxy = global.Facade:retrieveProxy(global.ProxyTable.Audio)
    local config = AudioProxy:GetConfig( id )
    if not config or not config.file then return end
    local path = config.file
    self:StopEffectByPath(path)
end

function AudioMediator:PlayEffectById(data)
    local id, isLoop, type, times = data.id, data.loop, data.type, data.times
    local path = nil
    local AudioProxy = global.Facade:retrieveProxy(global.ProxyTable.Audio)
    local config = AudioProxy:GetConfig( id )
    if not config or not config.file then return end

    path = config.file
    type = type or global.MMO.SUD_TYPE_SERVER
    isLoop = isLoop or false
    self:StopEffectByType(global.MMO.SUD_TYPE_SERVER)
    self:PlayEffect(path, isLoop, type, times)
end

function AudioMediator:PlayEffect( path, isLoop, type, times )
    if not self._effectEnable then
        return
    end

    if not self:checkAllCount() then
        return
    end

    if not self:checkAudioCount(type) then
        return
    end

    if times and times > 0 then
        isLoop = false
    end

    local entity = self:play( path, isLoop, self._effectVolume )
    if entity then
        entity.path = path
        entity.type = type
        entity.times = times
        self._effectEntitys[entity.id] = entity
        self._audioEngine:setFinishCallback( entity.id, handler( self, self.effectFinishCallback ) )
        self:onAudioPlay(type)
    end
end

function AudioMediator:SetEffectEnabled( enable )
    self._effectEnable = enable

    if not enable then
        self:stopAllEffects()
    end
end

function AudioMediator:stopAllEffects()
    for audioID, _ in pairs( self._effectEntitys ) do
        self:stop( audioID )
    end

    self._effectEntitys = {}
    self:clearAudioCount()
end


function AudioMediator:play( path, isLoop, volume )
    if not path or path == "" or not volume then
        return nil
    end

    if not global.FileUtilCtl:isFileExist(path) then
        global.ResDownloader:download(path, function(isOK)
            if isOK then
                self:downloadComplete(path)
            end
        end)
        return nil
    end

    local entity  	= { path = path }
    local audioID 	= self._audioEngine:play2d( path, isLoop, volume )
    if audioID == cc.AUDIO_INVAILD_ID then
        -- self:onLoadFileError(path)
        return nil
    end
    entity.id = audioID

    return entity
end

function AudioMediator:stop( audioID )
    if audioID then
        self:onAudioStop(audioID)
        self._audioEngine:stop( audioID )
    end
end

function AudioMediator:pause( audioID )
    if audioID then
        self:onAudioStop(audioID)
        self._audioEngine:pause( audioID )
    end
end

function AudioMediator:resume( audioID )
    if audioID then
        self._audioEngine:resume( audioID )
    end
end

function AudioMediator:setVolume( audioID, volume )
    if audioID then
        self._audioEngine:setVolume( audioID, volume )
    end
end

function AudioMediator:SetBGMVolume( value )
    self._musicVolume = value

    if self._musicEntity then
        self:setVolume( self._musicEntity.id, self._musicVolume )
    end
end

function AudioMediator:checkAudioCount(type)
    if self._audioCount[type] and self._audioCount[type] >= 10 then
        return false
    end
    return true
end

function AudioMediator:checkAllCount()
    return self._playCount <= 10
end

function AudioMediator:onAudioPlay(type)
    self._playCount = self._playCount + 1

    self._audioCount[type] = self._audioCount[type] and self._audioCount[type] + 1 or 1

    self._playCount = self._playCount + 1
end

function AudioMediator:onAudioStop(id)
    self._playCount = self._playCount - 1

    if not self._effectEntitys[id] then
        return
    end

    local type = self._effectEntitys[id].type
    if type and self._audioCount and self._audioCount[type] then
        self._audioCount[type] = self._audioCount[type] - 1
        if self._audioCount[type] < 1 then
            self._audioCount[type] = nil
        end
    end

    self._playCount = self._playCount - 1
end

function AudioMediator:clearAudioCount()
    self._audioCount = {}
    self._playCount = 0
end

function AudioMediator:downloadComplete(path)
    if self._BGMPath == path and not self._BGMStop then
        self:PlayBGMByPath(path)
    end
end

function AudioMediator:onLoadFileError(filePath)
    if not global.FileUtilCtl:isFileExist(filePath) then
        return
    end
    local fullPath = global.FileUtilCtl:fullPathForFilename(filePath)
    if not (fullPath ~= "" and string.find(fullPath, global.FileUtilCtl:getWritablePath())) then
        return
    end

    global.FileUtilCtl:removeFile(fullPath)
    global.FileUtilCtl:purgeCachedEntries()
end

return AudioMediator
