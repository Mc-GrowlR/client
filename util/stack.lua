local stack = class('stack' )

function stack:ctor()
    self._data = {}
end

function stack:pop()
    local ret = nil
    local size = #self._data
    if size > 0 then
        ret = self._data[size]
        self._data[size] = nil
    end

	return ret	
end

function stack:push( d )
	self._data[#self._data + 1] = d
end

function stack:top()
    local size = #self._data
    if size > 0 then
        return self._data[size]
    end

	return nil
end

function stack:bottom()
    local size = #self._data
    if size > 0 then
        return self._data[1]
    end

    return nil
end

function stack:at( index )
	return self._data[index]
end

function stack:size()
	return #self._data
end

function stack:empty()
	return self:size() == 0
end

function stack:clear()
    local size = #self._data
	if size > 0 then
		for i = 1, size do
			self._data[i] = nil
		end
	end
end

return stack
