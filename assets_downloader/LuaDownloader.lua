local LuaDownloader = class('LuaDownloader')

local DOWNLOAD_PRIORITY_LOWEST = 0

function LuaDownloader:ctor()
    self._tasks         = {}
    self._downloader    = nil

    self._downloadDir   = nil   -- 下载存储文件夹
    self._downloadUrl   = nil   -- 下载资源路径
    self._downloadVer   = nil   -- 资源版本号
end

function LuaDownloader:reset()
    self._downloader = nil

    -- reset tasks
    self._tasks = {}

    -- new downloader
    local function fileTaskSuccess(task)
        self:OnFileTaskSuccess(task)
    end
    local function taskError(task, errorCode, errorCodeInternal, errorStr)
        self:OnTaskError(task, errorCode, errorCodeInternal, errorStr)
    end
    self._downloader = cc.Downloader.new()
    self._downloader:setOnFileTaskSuccess(fileTaskSuccess)
    self._downloader:setOnTaskError(taskError)

    -- property
    local module        = global.L_ModuleManager:GetCurrentModule()
    local modulePath    = module:GetSubModPath()
    local moduleGameEnv = module:GetGameEnv()
    self._downloadDir   = cc.FileUtils:getInstance():getWritablePath() .. modulePath
    self._downloadUrl   = moduleGameEnv:GetSceneDownloadUrl()
    self._downloadVer   = moduleGameEnv:GetResVersion()
end

function LuaDownloader:Cleanup()
    if self._downloader then
        self._downloader:destructor()
        self._downloader = nil
    end
    self._tasks = {}
end

function LuaDownloader:OnFileTaskSuccess(task)
    if self._tasks[task.identifier] then
        self._tasks[task.identifier](true)
    end
end

function LuaDownloader:OnTaskError(task)
    if self._tasks[task.identifier] then
        self._tasks[task.identifier](false)
    end
end

-----------------------------------------------------------------------------
function LuaDownloader:checkWriteDirsAndFiles(fullFilePath)
    if global.FileUtilCtl:isFileExist(fullFilePath) then
        -- file exist
        return 1
    end

    local writablePath = global.FileUtilCtl:getWritablePath()
    fullFilePath = string.gsub(fullFilePath, writablePath, "")

    local lastDir = writablePath
    local slices = string.split(fullFilePath, "/")
    for i, v in ipairs(slices) do
        if i == #slices then
            -- break file
            break
        end
        lastDir = lastDir .. v
        if not global.FileUtilCtl:isDirectoryExist(lastDir) then
            global.FileUtilCtl:createDirectory(lastDir)
        end
        lastDir = lastDir .. "/"
    end
    return 0
end

function LuaDownloader:addDownloadDir(downloadUrl)
    return self._downloadUrl .. downloadUrl
end

function LuaDownloader:addDownloadVer(downloadUrl)
    return downloadUrl .. self._downloadVer
end

function LuaDownloader:AsyncDownloadEx(reltiveFilePath, downloadCB)
    local fullFilePath = self._downloadDir .. reltiveFilePath
    local checkR = self:checkWriteDirsAndFiles(fullFilePath)
    if checkR == 1 then
        downloadCB(true)
        return
    end

    local downloadUrl = reltiveFilePath
    downloadUrl = self:addDownloadDir(downloadUrl)
    downloadUrl = self:addDownloadVer(downloadUrl)
    self:asyncDownload(downloadUrl, fullFilePath, downloadCB)
end

function LuaDownloader:AsyncDownloadEasy(downloadUrl, fullFilePath, downloadCB)
    local checkR = self:checkWriteDirsAndFiles(fullFilePath)
    if checkR == 1 then
        downloadCB(true)
        return
    end

    downloadUrl = self:addDownloadVer(downloadUrl)
    self:asyncDownload(downloadUrl, fullFilePath, downloadCB)
end

function LuaDownloader:asyncDownload(downloadUrl, fullFilePath, downloadCB)
    self._tasks[fullFilePath] = downloadCB
    self._downloader:createDownloadFileTask(downloadUrl, fullFilePath, fullFilePath)
end

return LuaDownloader
