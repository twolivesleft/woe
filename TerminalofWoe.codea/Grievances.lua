Grievances = class()

function Grievances:init()
    self.scale = 1.0
    self.submitted = false
    self:layout()
end

function Grievances:layout()
    self.closeButton = Button("╳", 40 * proj.mode.titleFontScale, proj.screenSize.y - 56 * proj.mode.titleFontScale, 25 * proj.mode.titleFontScale)
    self.closeButton.inverted = true
    self.closeButton.touchPadding = 20

    self.submitButton = Button("↳ Submit", 0, 0, 25 * proj.mode.titleFontScale)
    local w,h = self.submitButton:size()
    self.submitButton.mode = CORNER
    self.submitButton.x = proj.screenSize.x - w - 40 * proj.mode.titleFontScale
    self.submitButton.y = 40 * proj.mode.titleFontScale
    self.submitButton.touchPadding = 10
    
    local offset = 20 * proj.mode.titleFontScale
    local yPos = 120 * proj.mode.titleFontScale
    local xPos = 70 * proj.mode.titleFontScale
    self.option1 = Button("Uniform temporal satisfaction", xPos, proj.screenSize.y - yPos, 20 * proj.mode.titleFontScale)
    self.option1.touchPadding = 10
    self.option1.wrapWidth = proj.screenSize.x - 120 * proj.mode.titleFontScale

    self.option2 = Button("Excessive lexical density", xPos, proj.screenSize.y - yPos, 20 * proj.mode.titleFontScale)
    self.option2.wrapWidth = proj.screenSize.x - 120 * proj.mode.titleFontScale
    self.option2.touchPadding = 10
    local _,h = self.option2:size()
    yPos = yPos + h + offset
    self.option2.y = proj.screenSize.y - yPos

    self.option3 = Button("Request Innie resignation", xPos, proj.screenSize.y - yPos, 20 * proj.mode.titleFontScale)
    self.option3.wrapWidth = proj.screenSize.x - 120 * proj.mode.titleFontScale
    self.option3.touchPadding = 10
    local _,h = self.option3:size()
    yPos = yPos + h + offset
    self.option3.y = proj.screenSize.y - yPos    

    self.option4 = Button("Devour feculence", xPos, proj.screenSize.y - yPos, 20 * proj.mode.titleFontScale)
    self.option4.wrapWidth = proj.screenSize.x - 120 * proj.mode.titleFontScale
    self.option4.touchPadding = 10
    local _,h = self.option4:size()
    yPos = yPos + h + offset
    self.option4.y = proj.screenSize.y - yPos    

    self.option5 = Button("Initiate freeform lamentation", xPos, proj.screenSize.y - yPos, 20 * proj.mode.titleFontScale)
    self.option5.wrapWidth = proj.screenSize.x - 120 * proj.mode.titleFontScale
    self.option5.touchPadding = 10
    local _,h = self.option5:size()
    yPos = yPos + h + offset
    self.option5.y = proj.screenSize.y - yPos

    self.option1.selected = true

    self.options = {
        self.option1,
        self.option2,
        self.option3,
        self.option4,        
        self.option5,        
    }

    self.title = proj.mode.grievanceTitle
end

function Grievances:draw()
    pushStyle()
    pushMatrix()

    if self.submitted then
        fill(118, 222, 236)
        textWrapWidth(proj.screenSize.x - 60)
        font("FixedsysExcelsiorIIIb")
        fontSize(40 * proj.mode.titleFontScale)
        text("☕ GRIEVANCE SUBMITTED", proj.screenSize.x / 2, proj.screenSize.y / 2)

        return
    end

    noFill()
    stroke(118, 222, 236)
    strokeWidth(2 * (1/math.max(self.scale, 0.1)))

    translate((proj.screenSize.x / 2) * (1 - self.scale), (proj.screenSize.y / 2) * (1 - self.scale))
    scale(self.scale, self.scale)

    font("AmericanTypewriter")
    textMode(CENTER)

    rect(26 * proj.mode.titleFontScale, 26 * proj.mode.titleFontScale, proj.screenSize.x - 52 * proj.mode.titleFontScale, proj.screenSize.y - 52 * proj.mode.titleFontScale)
    rect(30 * proj.mode.titleFontScale, 30 * proj.mode.titleFontScale, proj.screenSize.x - 60 * proj.mode.titleFontScale, proj.screenSize.y - 60 * proj.mode.titleFontScale)

    fill(118, 222, 236)
    rect(30 * proj.mode.titleFontScale, proj.screenSize.y - 60 * proj.mode.titleFontScale, proj.screenSize.x - 60 * proj.mode.titleFontScale, 30 * proj.mode.titleFontScale)

    fill(0)
    fontSize(20 * proj.mode.titleFontScale)
    text(self.title, proj.screenSize.x / 2, proj.screenSize.y - 45 * proj.mode.titleFontScale)

    self.closeButton:draw()

    self.submitButton:draw()
    self.submitButton:update()

    for i, option in ipairs(self.options) do
        option:draw()
    end

    popMatrix()
    popStyle()
end

function Grievances:touched(touch)
    local screenPos = vec2(touch.x, touch.y)
    local worldPos = screenToWorld(screenPos)
    
    if touch.state ~= ENDED or touch.tapCount ~= 1 then
        return
    end

    if self.closeButton:hitTest(worldPos) then 
        proj.scene = MenuSelect()
        sound(SOUND_HIT, 12483)
    end

    if self.submitButton:hitTest(worldPos) then 
        sound(SOUND_RANDOM, 49756)
        tween(2.0, self, {scale = 0}, tween.easing.linear, function()
            self.submitted = true
            tween.delay(2.0, function()
                if self.option5.selected then
                    openURL("https://itunes.apple.com/app/id6744296466?action=write-review")
                else
                    local scene = objc.app.keyWindow.windowScene
                    local store = objc.SKStoreReviewController
                    store:requestReviewInScene_(scene)                    
                end

                proj.scene = MenuSelect()
            end)
        end)
    end

    for i, option in ipairs(self.options) do
        if option:hitTest(worldPos) then
            for j, opt in ipairs(self.options) do
                opt.selected = false
            end
            option.selected = true
            sound(DATA, "ZgBALABAPUBAIX1AtHmfPTXPJTxq7OE+DABAfyhAQEFBQUA7")
        end
    end
end