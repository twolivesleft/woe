Mammalians = class()

function Mammalians:init()
    self:layout()
end

function Mammalians:play()
    print("PLAY")
    tween(2.0, self, {lineEnd = 1}, tween.easing.linear, function()
        tween(4.0, self, { mammalPos = vec2(proj.screenSize.x/2, self.mammalPos.y)}, tween.easing.linear, function()
            self.mammal.paused = true
            sound(SOUND_RANDOM, 4991)
            tween.delay(2.0, function()
                self.mammal.paused = false
                tween(4.0, self, { mammalPos = vec2(-50, self.mammalPos.y)}, tween.easing.linear, function()
                    tween(2.0, self, {lineStart = 1}, tween.easing.linear, function()
                        tween.delay(1.0, function () 
                            m.nurtureMammalian()
                        end)
                        proj.scene = MenuSelect()                  
                    end)
                end)
            end)
        end)
    end)
end

function Mammalians:layout()
    self.mammal = Mammal()
    self.lineStart = 0
    self.lineEnd = 0
    self.mammalPos = vec2(proj.screenSize.x + 50, proj.screenSize.y/4 + 50 * proj.mode.titleFontScale)

    tween.resetAll()
    self:play()
end

function Mammalians:draw()
    pushStyle()

    font("FixedsysExcelsiorIIIb")

    fill(118, 222, 236)
    stroke(118, 222, 236)
    strokeWidth(2)
    
    pushMatrix()
    translate(self.mammalPos.x, self.mammalPos.y)
    scale(-1, 1)
    self.mammal:update()
    self.mammal:draw()
    popMatrix()

    if self.mammalPos.x == proj.screenSize.x/2 then
        textMode(CENTER)
        fontSize(50 * proj.mode.titleFontScale)
        textWrapWidth(proj.screenSize.x)
        textAlign(CENTER)
        text("YOU SAAAAVED ME", proj.screenSize.x/2, proj.screenSize.y/2 + 50)
    end

    line(proj.screenSize.x * self.lineStart, proj.screenSize.y/4, proj.screenSize.x * self.lineEnd, proj.screenSize.y/4)

    popStyle()
end

function Mammalians:touched(touch)
end


Mammal = class()

function Mammal:init()
    self.mesh = mesh()
    self.index = self.mesh:addRect(0, 0, 100 * proj.mode.titleFontScale, 100 * proj.mode.titleFontScale)
    self.mesh.texture = asset.Emile
    self.fps = 8
    self.time = 0
    self.paused = false

    self:setFrame(0)
end

function Mammal:draw()
    pushStyle()
    noSmooth()
    self.mesh:draw()
    popStyle()
end

function Mammal:update()
    if self.paused then
        return
    end

    self.time = self.time + DeltaTime
    if self.time > 1/self.fps then
        self.time = 0
        self:setFrame(self.frame + 1)
    end
end

function Mammal:setFrame(frame)
    self.frame = frame
    if self.frame > 7 then
        self.frame = 0
    end
    self.mesh:setRectTex(self.index, 1/8 * self.frame, 0, 1/8, 1)
end