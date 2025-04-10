Button = class()

function Button:init(text, x, y, fontSize)
    self.x = x
    self.y = y
    self.text = text
    self.inverted = false
    self.selected = false
    self.flashRate = 0.8
    self.time = 0
    self.fontSize = fontSize or 30
    self.mode = CORNER
    self.touchPadding = 0
    self.wrapWidth = 0
end

function Button:hitTest(pos)
    pushStyle()
    font("FixedsysExcelsiorIIIb")
    fontSize(self.fontSize)
    local w,h = textSize(self.text)
    popStyle()

    local x, y = self.x, self.y    

    if self.mode == CORNER then
        x = x - self.touchPadding
        y = y - self.touchPadding
        w = w + self.touchPadding * 2
        h = h + self.touchPadding * 2        
    elseif self.mode == CENTER then 
        x = x - w / 2 - self.touchPadding
        y = y - h / 2 - self.touchPadding
        w = w + self.touchPadding * 2
        h = h + self.touchPadding * 2
    end
    
    return pos.x > x and pos.x < x + w and pos.y > y and pos.y < y + h
end

function Button:update()
    self.time = self.time + DeltaTime
    if self.time > self.flashRate then
        self.inverted = not self.inverted
        self.time = 0
    end
end

function Button:size()
    pushStyle()
    font("FixedsysExcelsiorIIIb")
    fontSize(self.fontSize)
    textWrapWidth(self.wrapWidth)
    local w,h = textSize(self.text)
    popStyle()
    return w, h
end

function Button:draw()
    pushStyle()
    pushMatrix()

    font("FixedsysExcelsiorIIIb")
    fontSize(self.fontSize)
    fill(118, 222, 236)
    stroke(118, 222, 236)

    translate(self.x, self.y)

    rectMode(self.mode)
    textMode(self.mode)
    local w,h = textSize(self.text)
    if self.inverted then 
        rect(0, 0, w, h)    
        fill(0)
    end
    textWrapWidth(self.wrapWidth)
    text(self.text)

    if self.selected then 
        textMode(CENTER)
        local _,h = textSize(self.text)
        local _,sh = textSize("☛")
        text("☛", -(self.fontSize*1.2)/2, h - sh/2)
    end

    popMatrix()    
    popStyle()
end