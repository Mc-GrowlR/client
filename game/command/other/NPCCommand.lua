local NPCCommand = class('NPCCommand', framework.SimpleCommand)
local STATE_TAG             = 99

function NPCCommand:ctor()
end

function NPCCommand:execute(notification)
  local data    = notification:getBody()
  
  

end

-------------------------------------------下面代码勿删勿删 ---------------------------------------------------
-------------------------------------------下面代码勿删勿删 ---------------------------------------------------
-------------------------------------------下面代码勿删勿删 ---------------------------------------------------


-- require "UlSystems/Common/IDefine"
-- require 'Common/StackList'

UIManager = {}
local this = UIManager
local ctrlList = {}
local panelStack = nil
--[[
对table运用mm L＜度要求
]]

function this.Init()
    logWarn("ctrl mgr init Ctrl len is :")

    panelStack = StackList:New()
    for panelName, path in pairs(UlPanels) do
        require (path.. panelName)
        --log('req panel name : ' .. panelName)
        local panel = panelName
        --替换字符串
        local ctrlName = string.gsub(panelName, 'Panel', 'Ctrl')
        local ctrl = require(path.. ctrlName)
        if type(ctrl) == 'boolean' then
            error (" require Ctrl error, 找不至lj lua 文件 path: *.. path.. ctrlName")
        end

        ctrlList[panelName] = ctrl
        --attempt to index a boolean value
        --出碰上面那个错，说明require路径没写对
        ctrlList[panelName].panelName = panel--这里赋值 panel 给 UlCtrl
        ctrlList[panelName].Init()
    end
end

local curPanelCtrl = nil
function this.ShowPanel(panelName, data)
    --local topPaneLName = this. panelStack:GetTop()
    local beforePanelCtrl = curPanelCtrl
    local openPanelCtrl = ctrlList[panelName]
    if openPanelCtrl.uiShowType == nil then
        openPanelCtrl.uiShowType = UiShowType.ShowOnly
    end
    local showType = openPanelCtrl.uiShowType
    if showType == UiShowType.Switch and beforePanelCtrl ~= nil then
        beforePanelCtrl:HidePanel()
    end
    if showType == UiShowType.Top then
        -- openPEinelClrl. genneObject:SetAsLastSibling()
    end
    if showType ~= UiShowType.Stack then
        --如果没有根，push BasePanel,作为根Panel
        if panelStack:Comit() == 0 then 
            panelStack:Push(beforePanelCtrl.panelName)
        end
        this.PushPanelStack(openPanelCtrl.panelName)
    end
    
    if showType == UIShowType.HideOthers then
    end
    -- panelStack:ToString()
    openPanelCtrl:ShowPanel(data)
    curPanelCtrl = openPanelCtrl
    --this.panelStack:Push(panelNamc)
    --this.panelStack:ToString()
end

function this.PushPanelStack(panelName)
    panelStack:Push(panelName)
end

function this.IlideTopPanel()
    local topPanelName = this.panelStack:GetTop()
    this.HidePanel(topPanelName)
end

function this.GetPanelCtrl(panelName)
    return ctrlList[panelName]
end

function this.HidePanel(panelName, data)
    local panelCtrl = ctrlList[panelName]
    if panelCtrl.uiShowType == UIShowType.Stack then
        local popPaneIName = panelStack:Pop() 
        if panelName ~= popPanelName then
            logError('Pop panel name error'.. popPanelName) 
            panelStack:Push(popPanelName)
        else
            --正常pop
            local parentCtrlName = panelStack:GctTop() 
            local parentCtrl = ctrlList[parentCtrlName]
            -- pop时反向传值给父Panel
            if parentCtrl.OnPopPanel ~= nil and type(parentCtrl. OnPopPanel) == 'function' then 
                parentCtrl.OnPopPanel(panelName, data)
            end
            ctrlList[panelName]:HidePanel()
        end
    else
        ctrlList[panelName]:HidePanel()
    end
    --只有一个了，留着无意义了
    if panelStack:Count() <= 1 then
        panelStack:Clear()
    end
    --panelStack:ToString()
end

function this.DestroyPanel(panelName)
    ctrlList[panelName]:DestroyPanel()
end 

-- return {
-- versioninfo = 
-- date = * 2017-1-16 16:54:22',
-- checkvalue = ' d882d8b2d51a75dacbl7cfc6cda432455, version = 1484556862,
-- creater = ' JUN'
-- },


return NPCCommand
