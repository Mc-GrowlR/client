local DebugProxy = requireProxy("DebugProxy")
local SensitiveWordProxy = class("SensitiveWordProxy", DebugProxy)
SensitiveWordProxy.NAME = global.ProxyTable.SensitiveWordProxy

local utf8 = require("util/utf8")

local tostring = tostring
local tinsert = table.insert
local sfind = string.find
local sgsub = string.gsub
local sbyte = string.byte
local slen = string.len
local ssub = string.sub

------------------------------------------------------------
-- 简单正则匹配，匹配出所有网址
local function findSensitivePattren(str)
    local items = {}
    
    while true do
        local pattern = { sfind(str, "(%w+%.%a+)") }
        if not pattern[3] then
            break
        end
        tinsert(items, {b = pattern[1], c = pattern[2] - pattern[1]+1, w = pattern[3]})

        local p = ssub(str, 1, pattern[1]-1)
        local s = ssub(str, pattern[2]+1, slen(str))
        str = p .. s
    end
    return #items > 0, items
end

-- 字符串匹配，非正常匹配字符
local function fixMalformedPattern(v)
    v = sgsub(v, "%%", "%%%%")
    v = sgsub(v, "%.", "%%.")
    v = sgsub(v, "%(", "%%(")
    v = sgsub(v, "%)", "%%)")
    v = sgsub(v, "%+", "%%+")
    v = sgsub(v, "%-", "%%-")
    v = sgsub(v, "%*", "%%*")
    v = sgsub(v, "%?", "%%?")
    v = sgsub(v, "%[", "%%[")
    v = sgsub(v, "%]", "%%]")
    v = sgsub(v, "%^", "%%^")
    v = sgsub(v, "%$", "%%$")
    return v
end

-- 结束标记，使用数字作为Key，解决字符作为Key产生的无法匹配问题
local endFlag = 0

-- 是否是特殊字符，在处理敏感字时跳过夹在中间的特殊字符
local charaterHash = {}
local charaterList = {
    "`","~", "!","！", "@","@", "$","￥", "%", "^","…", "&", "*", "(", ")", "_","-", "+","=", "\\", "/", "?","？", "[","]", " ", "　", "\t", "\n", "\r", "<", ">", "'", "\"", "—", 
    "#", ",", "，", ".", "。", ":",";", "：", "；", "�",
}
for i, v in ipairs(charaterList) do
    charaterHash[v] = 1
end
local function isCharaters(s)
    if charaterHash[s] == 1 then
        return true
    end

    return false
end

------------------------------------------------------------
-- 字典树
-- 字母转小写
-- 排除特殊字符，中间插入特殊字符先清特殊字符再匹配
------------------------------------------------------------


------------------------------------------------------------
-- 字典树
local TrieNode = class("TrieNode")
function TrieNode:ctor()
    self.subNodes = {}
end

function TrieNode:addSubNode(k, subNode)
    self.subNodes[k] = subNode
end

function TrieNode:getSubNode(k)
    return self.subNodes[k]
end

---
local Trie = class("Trie")
function Trie:ctor()
    self.root = TrieNode.new()
end

function Trie:add(word)
    -- 转换为小写
    word = string.lower(word)

    local utf8len = utf8:length(word)
    local currNode = self.root
    for i = 1, utf8len do
        local s = utf8:sub(word, i, 1)

        -- 特殊字符
        if isCharaters(s) then
        else
            local subNode = currNode:getSubNode(s)
            if subNode == nil then
                subNode = TrieNode.new()
                currNode:addSubNode(s, subNode)
            end
    
            currNode = subNode
        end
    end
    
    currNode:addSubNode(endFlag, TrieNode.new())
end

function Trie:search(word, isEasy)
    -- 转换为小写
    word = string.lower(word)
    
    local items = {}
    local utf8len = utf8:length(word)
    local index = 1
    while true do
        local numChars = self:search_sub(word, index, utf8len)
        if numChars > 0 then
            tinsert(items, {b = index, c = numChars, w = utf8:sub(word, index, numChars)})
        end

        -- 尽量少匹配
        if isEasy and #items == 1 then
            break
        end

        if index > utf8len then
            break
        end

        if numChars > 0 then
            index = index + numChars
        else
            index = index + 1
        end
    end

    return #items > 0, items
end

function Trie:search_sub(word, startIndex, utf8len)
    local numChars = 0
    local complete = false
    local currNode = self.root
    for i = startIndex, utf8len do
        local s = utf8:sub(word, i, 1)

        numChars = numChars + 1
        
        -- 是特殊字符
        if not (isCharaters(s)) then
            -- 不存在子节点
            local subNode = currNode:getSubNode(s)
            if subNode == nil then
                break
            end
    
            -- 完整结束了
            if (subNode:getSubNode(endFlag)) then
                complete = true
                break
            end
    
            currNode = subNode
        end
    end

    if not complete then
        numChars = 0
    end

    return numChars
end
------------------------------------------------------------

function SensitiveWordProxy:ctor()
    SensitiveWordProxy.super.ctor(self)

    self._words_trie = Trie.new()

    self._talk_charaters = {}
    self._name_charaters = {}
end

function SensitiveWordProxy:lazyInit()
    if self._isInited then
        return nil
    end
    self._isInited = true


    -- 基础配置表
    local config = requireGameConfig("cfg_sensitive_normal.lua")
    for k, v in pairs(config) do
        self._words_trie:add(v)
    end

    -- 自定义敏感字
    local filePath = "data_config/sensitive_words.txt"
    local text = ""
    if global.FileUtilCtl:isFileExist(filePath) then
        local function callback(dataTable)
            if dataTable[1] and dataTable[1] ~= "" then
                text = string.trim(dataTable[1])
                if text ~= "" then
                    self._words_trie:add(text)
                end
            end
        end
        LoadTxt(filePath, nil, callback)
    end

    -- 聊天 额外屏蔽
    self._talk_charaters = { "\\", "￥", "%", "\t", "\n", "\r", "'", "\"", "卍" }
    
    -- 取名 额外屏蔽
    self._name_charaters = { 
        "\\", "/", "￥", "%", "(", ")", "+", "-", "*", "?", "[", "]", "^", "$", " ", "　", "\t", "\n", "\r", "<", ">", "!", 
        "@", "&", "=", "'", "\"", "_", "#", "；", "：", "【", "】", "“", "”", "。", "，", "《", "》", "？", "、", "！","卍","卐"
    }
end

----------------------------------------------------------------------
-- 是否包含敏感字，敏感级别=取名
function SensitiveWordProxy:IsHaveSensitiveName(str)
    self:lazyInit()

    local found = false
    local items = {}

    -- 特殊字符匹配
    if not found then
        for i, v in ipairs(self._name_charaters) do
            local s = fixMalformedPattern(v)
            if sfind(str, s, 1, true) ~= nil then
                found = true
                break
            end
        end
    end

    -- 字典树匹配
    if not found then
        found, items = self._words_trie:search(str, true)
    end

    -- 正则匹配
    if not found then
        found, items = findSensitivePattren(str)
    end

    return found
end

function SensitiveWordProxy:IsHaveSensitiveAddFilter(str, callback)
    local found = self:IsHaveSensitiveName(str)
    if found then
        if callback then
            callback(false)
        end
        return
    end

    -- 使用第三方敏感字检测
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    AuthProxy:RequestWordFilteringQQ(1, str, callback)
end

function SensitiveWordProxy:IsHaveSensitiveEx(strList, callback)
    if not strList or #strList <= 0 then
        callback(false)
        return
    end

    local idx = 1
    local function checkHaveSensitive(str)
        self:IsHaveSensitiveAddFilter(str, function(state) 
            -- 检测，不通过
            if not state then
                callback(false)
                return
            end

            -- 检测，全部通过
            if idx == #strList then
                callback(true)
                return
            end

            idx = idx + 1
            checkHaveSensitive(strList[idx])
        end)
    end
    checkHaveSensitive(strList[idx])
end
----------------------------------------------------------------------

----------------------------------------------------------------------
-- 是否包含敏感字，敏感级别=聊天
function SensitiveWordProxy:fixSensitiveTalkAddFilter(str, callback, type, ex_param)
    self:lazyInit()

    local replace = "*"

    local found = false
    local items = {}

    -- 特殊字符被替换掉
    for i, v in ipairs(self._talk_charaters) do
        local s = fixMalformedPattern(v)
        str = sgsub(str, s, replace)
    end

    -- 配置表敏感字
    found, items = self._words_trie:search(str)
    for i, v in ipairs(items) do
        local s = fixMalformedPattern(v.w)
        str = sgsub(str, s, replace)
    end

    -- 正则匹配的敏感字，域名等
    found, items = findSensitivePattren(str)
    for _, v in ipairs(items) do
        local s = fixMalformedPattern(v.w)
        str = sgsub(str, s, replace)
    end

    -- 使用第三方敏感字检测
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    if type and type == 1 then
        AuthProxy:RequestWordFilteringQQ(3, str, callback)
    else
        AuthProxy:RequestWordFilteringQQ(2, str, callback, ex_param)
    end
end

-- 是否包含敏感字，敏感级别=聊天
function SensitiveWordProxy:IsHaveSensitiveChat(str)
    self:lazyInit()

    local found = false
    local items = {}

    -- 特殊字符匹配
    if not found then
        for i, v in ipairs(self._talk_charaters) do
            local s = fixMalformedPattern(v)
            if sfind(str, s, 1, true) ~= nil then
                found = true
                break
            end
        end
    end

    -- 字典树匹配
    if not found then
        found, items = self._words_trie:search(str, true)
    end

    -- 正则匹配
    if not found then
        found, items = findSensitivePattren(str)
    end

    return found
end

function SensitiveWordProxy:IsHaveSensitiveTalkAddFilter(str, callback)
    local found = self:IsHaveSensitiveChat(str)
    if found then
        if callback then
            callback(false)
        end
        return
    end

    -- 使用第三方敏感字检测
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    AuthProxy:RequestWordFilteringQQ(2, str, callback)
end

return SensitiveWordProxy