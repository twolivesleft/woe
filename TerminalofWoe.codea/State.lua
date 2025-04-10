State = class()

function State:init(id, data)
    self.id = id
    self.data = data or {}
end

function State:__eq(other)
    return self.id == other.id
end

function State:__call(data)
    return State(self.id, data)
end

function State:__tostring()   
    local d = ""
    for k,v in pairs(self.data) do
        
        d = d .. "," .. k
    end
    
    return self.id .. "(" .. d .. ")"
end

function State:__index(key)
    if key == "id" then
        return rawget(self, "id")
    end
    
    if key == "data" then
        return rawget(self, "data")
    end
    
    local data = rawget(self, "data")
    return data[key]
end

function State:__newindex(key, value)
    if key == "id" then
        rawset(self, "id", value)
        return
    end
    
    if key == "data" then
        rawset(self, "data", value)
        return
    end

    local data = rawget(self, "data")
    data[key] = value
end