local actorFeatureID = class("actorFeatureID")

function actorFeatureID:ctor( ID )
    self._ID     = ID
    self._showID = 0
    self._dirty  = false
end
  
function actorFeatureID:cleanup()
    self._ID     = 0
    self._showID = 0
    self._dirty  = false
end

function actorFeatureID:isDirty()
    return self._dirty
end

function actorFeatureID:setDirty(value)
    self._dirty = value
end

function actorFeatureID:getID()
    return self._ID
end

function actorFeatureID:getShowID()
    return self._showID
end

function actorFeatureID:setID(ID)
    if self._ID == ID then
        return self._ID
    end

    self._dirty = self._dirty or ( self._ID ~= ID )
    self._ID    = ID

    return self._ID
end


function actorFeatureID:setShowID(ID)
    self._dirty  = self._dirty or ( self._showID ~= ID )
    self._showID = ID

    return self._showID
end


function actorFeatureID:getFeatureID()
    if self._showID > 0 then
        return self._showID
    end

    return self._ID
end

return actorFeatureID
