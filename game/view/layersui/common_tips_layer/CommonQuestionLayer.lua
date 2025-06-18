local COMMONTIPS_LAYER_PATH = getResFullPath( "ui/ui/layers_ui/tips/" )
local BaseLayer = requireLayerUI( "BaseLayer" )
local CommonQuestionLayer = class( "CommonQuestionLayer", BaseLayer )

local RichTextHelp = require( "util/RichTextHelp" )

function  CommonQuestionLayer:ctor()
    CommonQuestionLayer.super.ctor( self )
end

function CommonQuestionLayer.create(noticeData)
    local layer = CommonQuestionLayer.new()

    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function CommonQuestionLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function CommonQuestionLayer:InitEditMode()
    local items = 
    {
        "Image_bg",
        "Text_question",
        "Text_time",
        "ListView",
        "Text_answer",
        "CheckBox_1"
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

function CommonQuestionLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_COMMON_QUESTION)
    CommonQuestion.main() 
    self:InitUI(data)
    self:InitEditMode()
end

function CommonQuestionLayer:InitUI(data)
    self._ui.Text_question:setString(data.question or "")
    self._ui.Panel_item:setVisible(false)
    if data.isEdit then
        self._ui.Panel_item:setVisible(true)
    end
    self._time = data.time or 0
    self._ui.Text_time:setString(self._time.."S")
    self._ui.Text_time:stopActionByTag(666)
    local action = schedule(self._ui.Text_time,function()
        self._time = self._time - 1
        local needClose = false
        if self._time < 0 then
            self._time = 0 
            needClose = true
        end
        self._ui.Text_time:setString(self._time.."S")
        if needClose then
            global.Facade:sendNotification(global.NoticeTable.QuestionLayer_Close)
        end
    end,1)
    action:setTag(666)
    
    self._items = {}
    self._ui.ListView:removeAllChildren()
    local func = function(index)--回答
        for i,v in ipairs(self._items) do
            local CheckBox_1 = v:getChildByName("CheckBox_1")
            CheckBox_1:setSelected(i == index)
        end
        local QuestionProxy = global.Facade:retrieveProxy(global.ProxyTable.QuestionProxy)
        QuestionProxy:sendAnswer(data.idx[index])
        global.Facade:sendNotification(global.NoticeTable.QuestionLayer_Close)
    end
    if data.answer then
        for i,v in ipairs(data.answer) do
            local answerItem = self._ui.Panel_item:cloneEx()
            local Text_answer = answerItem:getChildByName("Text_answer")
            Text_answer:setString(v)
            local CheckBox_1 = answerItem:getChildByName("CheckBox_1")
            CheckBox_1:setSelected(false)
            CheckBox_1:addEventListener( function()
                if CheckBox_1:isSelected() then 
                    func(i)
                end
            end)
            answerItem:setVisible(true)
            self._ui.ListView:pushBackCustomItem(answerItem)
            table.insert(self._items,answerItem)
        end
    end
end

function CommonQuestionLayer:GetSUIParent()
    return self._ui.Image_bg
end

return CommonQuestionLayer