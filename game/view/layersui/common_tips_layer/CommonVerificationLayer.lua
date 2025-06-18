local COMMONTIPS_LAYER_PATH = getResFullPath( "ui/ui/layers_ui/tips/" )
local BaseLayer = requireLayerUI( "BaseLayer" )
local CommonVerificationLayer = class( "CommonVerificationLayer", BaseLayer )

function  CommonVerificationLayer:ctor()
    CommonVerificationLayer.super.ctor( self )
end

function CommonVerificationLayer.create(noticeData)
    local layer = CommonVerificationLayer.new()

    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function CommonVerificationLayer:Init(data)
    self._quickUI = ui_delegate(self)
    return true
end

function CommonVerificationLayer:InitEditMode()
    local items = {
        "Image_panel",
        "Text_desc",
        "Image_1",
        "Image_bg",
        "Image_icon",
    }

    for _,widget in ipairs(items) do
        if self._quickUI[widget] then
            self._quickUI[widget].editMode = 1
        end
    end
end

function CommonVerificationLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_COMMON_VERIFICATION)
    CommonVerification.main()
    self:InitUI(data)
    self:InitEditMode()
end

function CommonVerificationLayer:InitUI(data)

    self._oriPos = cc.p(self._quickUI.Image_icon:getPosition())
    self._quickUI.Image_icon:setTouchEnabled(true)
    local size = self._quickUI.Image_icon:getContentSize()
    self._quickUI.Image_icon:addTouchEventListener(function(sender,type)  
        if type == ccui.TouchEventType.moved then
            local worldpos = sender:getTouchMovePosition()
            
            local pos = self._quickUI.Image_panel:convertToNodeSpace(worldpos)     
            sender:setPosition(pos.x - size.width / 2, pos.y + size.height / 2)
        elseif type == ccui.TouchEventType.ended then 
            local endPos = sender:getTouchEndPosition()
            local pos = self._quickUI.Image_bg:convertToNodeSpaceAR(endPos)
            pos = cc.p(pos.x - size.width / 2, pos.y + size.height / 2)
            local VerificationProxy = global.Facade:retrieveProxy(global.ProxyTable.VerificationProxy)
            VerificationProxy:sendPos(pos.x / 2, - pos.y / 2)--ui放大了两倍
        end
    end)
    self:updateUI(data)
end

function CommonVerificationLayer:updateUI(data)
    self._quickUI.Image_icon:setPosition(self._oriPos)
    local fileUtil = cc.FileUtils:getInstance()
    local path = fileUtil:getWritablePath()
    local textureCache  = global.Director:getTextureCache()
    local bgdata = data.bgImg
    local imgdata = data.Img
    local savePng = function(data, path) 
        local okstr = base64dec(data)
        if fileUtil:isFileExist(path) then
            fileUtil:removeFile(path)
        end 
        if textureCache:getTextureForKey(path) then
            textureCache:removeTextureForKey(path)
        end
        fileUtil:writeStringToFile(okstr, path)
    end 
    if bgdata then 
        local bgPath = path .. "VerificationBg.png"
        savePng(bgdata, bgPath)
        self._quickUI.Image_bg:loadTexture(bgPath)
    end
    if imgdata then 
        local imgPath = path.."VerificationImg.png"
        savePng(imgdata, imgPath)
        self._quickUI.Image_icon:loadTexture(imgPath)
    end
    self._time = data.time or 0
    self._quickUI.Text_time:setString(self._time .. "S")
    self._quickUI.Text_time:stopActionByTag(666)
    local action = schedule(self._quickUI.Text_time,function()
        self._time = self._time - 1
     
        if self._time < 0 then
            self._time = 0 
        end
        self._quickUI.Text_time:setString(self._time .. "S")
    end, 1)
    action:setTag(666)
end

function CommonVerificationLayer:GetSUIParent()
    return self._quickUI.Image_panel
end

return CommonVerificationLayer