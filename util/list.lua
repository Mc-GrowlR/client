--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local list = class("list")

function list:ctor()
    self._headNode = { nextNode = nil }
    self._currentNode = self._headNode
    self._size = 0
end

function list:Begin()
    if self._headNode then
        return self._headNode.nextNode
    end

    return nil
end

function list:Back()
    if self._size <= 0 then
        return 
    end

    return self._currentNode
end

function list:Size()
    return self._size
end

function list:PushBack(value)
    local node = 
    {
        value = value,
        nextNode = nil
    }

    self._currentNode.nextNode = node
    self._currentNode = node

    self._size = self._size + 1
end

function list:Remove(node)
    if self._size <= 0 then
        return
    end

    local preIter = self._headNode
    local iter = self:Begin()

    while iter do

        if iter == node then
            
            if self._currentNode == iter then
                self._currentNode = preIter
            end

            preIter.nextNode = iter.nextNode
            self._size = self._size - 1
            break
        end

        preIter = iter
        iter = iter.nextNode
    end
end

function list:Clear()
    self._headNode = { nextNode = nil }
    self._currentNode = self._headNode
    self._size = 0
end

return list

--endregion
