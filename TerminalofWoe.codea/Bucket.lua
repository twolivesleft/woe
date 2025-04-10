Bucket = class()

function Bucket:init(bucket, pos, size)
    self.IDLE = State "IDLE"
    self.CONSUMING = State "CONSUMING"

    self.state = self.IDLE
    self.bucket = bucket
    self.name = bucket.name
    self.pos = pos or vec2()
    self.size = size or vec2(100, 25)
end

function Bucket:draw()
    pushStyle()
    pushMatrix()
    stroke(118, 212 + 10, 226 + 10)
    noFill()

    strokeWidth(2)
    
    rectMode(CENTER)
    rect(self.pos.x, self.pos.y, self.size.x, self.size.y)

    if self.state == self.CONSUMING then
        local rotation = self.state.rotation or 0
        
        pushMatrix()
        rectMode(CORNER)        
        translate(self.pos.x - (self.size.x/2), self.pos.y + self.size.y/2.0)
        rotate(rotation)
        rect(0, 0, self.size.x/2, self.size.y * 0.4)
        popMatrix()

        pushMatrix()
        rectMode(CORNER)                
        translate(self.pos.x + (self.size.x/2), self.pos.y + self.size.y/2.0)
        rotate(-rotation)
        rect(-(self.size.x/2), 0, self.size.x/2, self.size.y * 0.4)
        popMatrix()
    end

    fill(158, 241, 255)

    local progress = math.min(self.bucket.content / self.bucket.capacity, 1.0)
    rectMode(CORNER)
    rect(self.pos.x - self.size.x/2, self.pos.y - self.size.y/2, self.size.x * progress, self.size.y)
    
    fontSize(11)
    textAlign(CENTER)
    text(self.name, self.pos.x + 0.5, self.pos.y - 0.5)
    text(self.name, self.pos.x - 0.5, self.pos.y + 0.5)    
    text(self.name, self.pos.x - 0.5, self.pos.y - 0.5)
    text(self.name, self.pos.x + 0.5, self.pos.y + 0.5)

    fill(0)
    text(self.name, self.pos.x, self.pos.y)

    popMatrix()
    popStyle()
end

function Bucket:open(duration, completion)
    if self.state == self.CONSUMING then
        return
    end

    local t = { rotation = 0 }

    self.state = self.CONSUMING(t)

    tween(duration, t, { rotation = 110 }, tween.easing.linear, completion)
end

function Bucket:close(duration, completion)
    if self.state ~= self.CONSUMING then
        return
    end

    tween(duration, self.state.data, { rotation = 0 }, tween.easing.linear, function ()
        self.state = self.IDLE
        if completion then
            completion()
        end
    end)
end