function createSurge()
    return {
        pos = vec2(math.random(1, math.floor(proj.screenSize.x)), math.random(1, math.floor(proj.screenSize.y))),
        radius = vec2(math.random(20, 60)),
        radiusScale = 1.0,
        dir = vec2(1, 0):rotate(math.random() * math.pi * 2),
        timeScale = math.random() * 0.5 + 0.8
    }
end

function MacroData:closestSurgeDistance(loc)
    for i,s in pairs(self.surges) do
        local dist = s.pos:dist(loc)
        if dist < s.radius then
            return dist,s,i
        end
    end
end

function MacroData:updateSurge(surge)
    local newPos = surge.pos + surge.dir * 0.1
    
    while newPos.x < 0 or newPos.x > proj.screenSize.x or newPos.y < 0 or newPos.y > proj.screenSize.y do
        surge.dir = vec2(1, 0):rotate(math.random() * math.pi * 2.0)
        newPos = surge.pos + surge.dir * 0.2
    end
    
    surge.pos = newPos
    surge.radius = (math.sin(self.time * surge.timeScale) + 2.0) * proj.mode.surgeScale * surge.radiusScale
end
