-- Terminal of Woe

-- Screen Modes
COMPACT = {
    rowSpacing = 24,
    buckets = 2,
    bucketHeight = 18,
    bucketSpacing = 5,
    padding = 10,
    numbersOffset = vec2(0, 40),
    intensityScaleFactor = 0.8,
    surgeScale = 20.0,

    -- Menu screen
    titleFontScale = 0.6,
    menuTopOffset = 150,
    mammalianOffset = 100,
    madeWithScale = 0.7,

    -- Grievances
    grievanceTitle = "Grievance Filing",
}

REGULAR = {
    rowSpacing = 32,
    buckets = 5,
    bucketHeight = 25,
    bucketSpacing = 10,
    padding = 20,
    numbersOffset = vec2(5, 50),
    intensityScaleFactor = 1.0,
    surgeScale = 40.0,

    -- Menu screen
    titleFontScale = 1.0,
    menuTopOffset = 50,
    mammalianOffset = 0,
    madeWithScale = 1.0,

    -- Grievances
    grievanceTitle = "Grievance Filing Procedure",
}

-- Use this function to perform your initial setup
function setup()
    -- A table to store our globals
    proj = {}

    if objc.viewer.traitCollection.horizontalSizeClass == objc.enum.UIUserInterfaceSizeClass.compact then 
        proj.mode = COMPACT
    else
        proj.mode = REGULAR        
    end

    viewer.mode = FULLSCREEN
    parameter.boolean("DebugDraw", false)
    
    -- Create a half-resolution screen image to render into
    proj.screenSize = vec2(WIDTH/2, HEIGHT/2)
    proj.screen = image(proj.screenSize.x, proj.screenSize.y)

    -- Configure a mesh to render the screen image
    -- Set up the CRT effect parameters
    proj.screenMesh = mesh()
    proj.meshID = proj.screenMesh:addRect(WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
    proj.screenMesh.shader = shader(asset.CRT)
    proj.screenMesh.texture = proj.screen

    proj.scene = MenuSelect()
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(0)    
    
    -- Render to our screen buffer
    setContext(proj.screen)
    background(30, 48, 63)    
    
    font("AmericanTypewriter")

    proj.scene:draw()
    
    setContext()
    
    -- Apply CRT shader effect
    proj.screenMesh.shader.time = ElapsedTime
    
    -- Draw the screen with the shader
    pushStyle()
    pushMatrix()
    proj.screenMesh:draw()
    popMatrix()
    popStyle()
end

function worldToScreen(pos)
    return vec2(pos.x * WIDTH/proj.screenSize.x, pos.y * HEIGHT/proj.screenSize.y)
end

function screenToWorld(pos)
    return vec2(pos.x * proj.screenSize.x/WIDTH, pos.y * proj.screenSize.y/HEIGHT)
end

function touched(touch) 
    proj.scene:touched(touch)
end

function sizeChanged(w,h)
    proj.screenSize = vec2(WIDTH/2, HEIGHT/2)
    proj.screen = image(proj.screenSize.x, proj.screenSize.y)
    proj.screenMesh.texture = proj.screen
    proj.screenMesh:setRect(proj.meshID, WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)

    proj.scene:layout()
end