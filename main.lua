-- Copyright 2012 Javier Moral
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.

t = 0.0
lastGen = 0.0
fps = 0
frameCount = 0
smokeButtonPos = vec2(60,30)
flameButtonPos = vec2(170,30)
dustButtonPos = vec2(60,90)
trailButtonPos = vec2(170,90)
anim = false
animAngle = 0

-- Use this function to perform your initial setup
function setup()
    backingMode(RETAINED)
    iparameter("Draw_Emitters",0,1,0)
    iparameter("Particles_Sec",0,200,100)
    iparameter("Emitter_SizeX",0,500,0)
    iparameter("Emitter_SizeY",0,500,0)
    iparameter("Life",0,100,30)
    iparameter("Life_Variation",0,100,0)
    iparameter("PartSize",0,100,35)
    iparameter("PartSize_Variation",0,100,0)
    iparameter("Part_End_Life_Size",-1,500,-1)
    parameter("Velocity",0,50,10)
    iparameter("Velocity_Variation",0,100,0)
    parameter("Rotation_Speed",-0.2,0.2,0)
    iparameter("Rotation_Speed_Variation",0,100,0)
    iparameter("Opacity",0,255,255)
    iparameter("Opacity_Variation",0,100,0)
    iparameter("Opacity_End",-1,255,-1)
    iparameter("WindX",-50,50,0)
    parameter("Air_Resistance",0,1,0.1)
    parameter("Gravity_Val",-5,5,0)
    iparameter("Use_Gravity_Vector",0,1,0)
    iparameter("Size_Wiggle",0,1,0)
    iparameter("Turbulence_Pos_Affect",0,20,0)
    
    emitter = Particular(WIDTH/2,HEIGHT/2)
    presetDefault()
end

-- This function gets called once every frame
function draw()
    loadParameters()
    noSmooth()
    fill(0, 0, 0, 255)
    rect(0,0,WIDTH,HEIGHT)
    if anim == true then
        animateEmitter()
    end
    emitter:draw()
    if (Draw_Emitters == 1) then
        fill(0, 230, 255, 255)
        strokeWidth(3)
        stroke(255, 255, 255, 255)
        ellipse(emitter.x,emitter.y,20)
        noStroke()
    end
    if frameCount == 31 then
        frameCount = 0
    else
        frameCount = frameCount + 1
    end
    t = t + DeltaTime
    if frameCount == 30 then
        fps = 1.0/DeltaTime
    end
    fontSize(15)
    font("ArialMT")
    fill(255)
    text(string.format("Fps: %2.2f",fps),WIDTH - 60, 30)
    text(string.format("Time: %2.2f",t), WIDTH - 60, 50)
    drawButtons()
end

function drawButtons()
    fill(94, 0, 255, 81)
    rect(5,5,220,130)
    fill(255)
    text("Presets:",40,125)
    font("Baskerville-Bold")
    fill(242, 41, 41, 255)
    fontSize(30)
    drawButton(smokeButtonPos.x,
            smokeButtonPos.y,
            "Smoke")
            
    drawButton(flameButtonPos.x,
            flameButtonPos.y,
            "Flame")
            
    drawButton(dustButtonPos.x,
            dustButtonPos.y,
            "Dust")
            
    drawButton(trailButtonPos.x,
            trailButtonPos.y,
            "Trail")
end

function animateEmitter()
    emitter.x = WIDTH/2 + math.cos(animAngle) * 150
    emitter.y = HEIGHT/2 + math.sin(animAngle) * 150
    animAngle = animAngle + 0.05
end

function loadParameters()
    emitter.partPerSec = Particles_Sec
    emitter.sizeX = Emitter_SizeX
    emitter.sizeY = Emitter_SizeY
    emitter.life = Life
    emitter.lifeVariation = Life_Variation
    emitter.initPartSize = PartSize
    emitter.partSizeVariation = PartSize_Variation
    emitter.finalPartSize = Part_End_Life_Size
    emitter.velocity = Velocity
    emitter.velocityVariation = Velocity_Variation
    emitter.rotSpd = Rotation_Speed
    emitter.rotSpdVariation = Rotation_Speed_Variation
    emitter.initOpacity = Opacity
    emitter.opacityVariation = Opacity_Variation
    emitter.finalOpacity = Opacity_End
    emitter.windX = WindX
    emitter.airResistance = Air_Resistance
    emitter.gravity = Gravity_Val
    emitter.useGravityVector = Use_Gravity_Vector
    emitter.sizeWiggle = Size_Wiggle
    emitter.turbulencePosAffect = Turbulence_Pos_Affect
end

function drawButton(x,y,caption)
    font("ArialRoundedMTBold")
    sprite("Cargo Bot:Dialogue Button",x,y)
    fill(84, 84, 84, 255)
    fontSize(30)
    text(caption,x+1,y+1)
    fill(255)
    fontSize(30)
    text(caption,x,y)
end

function touched(touch)
    if(touch.state == ENDED) then
        if isTouched(touch.x,
                    touch.y,
                    smokeButtonPos.x - 20,
                    smokeButtonPos.y - 20,
                    smokeButtonPos.x + 20,
                    smokeButtonPos.y + 20) then
            presetSmoke()
            sound(SOUND_HIT,1)
            return
        end
        if isTouched(touch.x,
                    touch.y,
                    flameButtonPos.x - 20,
                    flameButtonPos.y - 20,
                    flameButtonPos.x + 20,
                    flameButtonPos.y + 20) then
            presetFlame()
            sound(SOUND_HIT,1)
            return
        end
        if isTouched(touch.x,
                    touch.y,
                    dustButtonPos.x - 20,
                    dustButtonPos.y - 20,
                    dustButtonPos.x + 20,
                    dustButtonPos.y + 20) then
            presetDust()
            sound(SOUND_HIT,1)
            return
        end
        if isTouched(touch.x,
                    touch.y,
                    trailButtonPos.x - 20,
                    trailButtonPos.y - 20,
                    trailButtonPos.x + 20,
                    trailButtonPos.y + 20) then
            presetTrail()
            sound(SOUND_HIT,1)
            return
        end
    end
    if anim == false and isTouched(touch.x,
                    touch.y,
                    emitter.x - 40,
                    emitter.y - 40,
                    emitter.x + 40,
                    emitter.y + 40) then
        emitter.x = touch.x
        emitter.y = touch.y
        if emitter.y < 150 then
            emitter.y = 150
        end
        return
    end
end

function isTouched(tx,ty,x1,y1,x2,y2)
    if tx >= x1 and tx <= x2 then
        if ty >= y1 and ty <= y2 then
            return true
        end
    end
    return false
end

function presetDefault()
    anim = false
    emitter.particularMesh.texture = "Cargo Bot:Star"
    Particles_Sec = 100
    Life = 30
    Life_Variation = 0
    PartSize = 35
    PartSize_Variation = 0
    Part_End_Life_Size = -1
    Velocity = 10
    Velocity_Variation = 0
    Rotation_Speed = 0
    Rotation_Speed_Variation = 0
    Opacity = 255
    Opacity_Variation = 0
    Opacity_End = -1
    Air_Resistance = 0.1
    Gravity_Val = 0
    Use_Gravity_Vector = 0
    Size_Wiggle = 0
    Turbulence_Pos_Affect = 0
end

function presetSmoke()
    anim = false
    emitter.particularMesh.texture = "Cargo Bot:Smoke Particle"
    Emitter_SizeX = 0
    Emitter_SizeY = 0
    Particles_Sec = 10
    Life = 60
    Life_Variation = 20
    PartSize = 10
    PartSize_Variation = 100
    Part_End_Life_Size = 155
    Velocity = 5.7
    Velocity_Variation = 100
    Rotation_Speed = 0.08
    Rotation_Speed_Variation = 45
    Opacity = 125
    Opacity_Variation = 100
    Opacity_End = 20
    WindX = 0
    Air_Resistance = 0.2
    Gravity_Val = -1.15
    Use_Gravity_Vector = 0
    Size_Wiggle = 0
    Turbulence_Pos_Affect = 0
end

function presetFlame()
    anim = false
    emitter.particularMesh.texture = 
                    "Tyrian Remastered:Explosion Huge"
    Emitter_SizeX = 0
    Emitter_SizeY = 0
    Particles_Sec = 100
    Life = 30
    Life_Variation = 50
    PartSize = 55
    PartSize_Variation = 100
    Part_End_Life_Size = 0
    Velocity = 2
    Velocity_Variation = 100
    Rotation_Speed = 0.2
    Rotation_Speed_Variation = 0
    Opacity = 100
    Opacity_Variation = 100
    Opacity_End = 255
    WindX = 0
    Air_Resistance = 0.1
    Gravity_Val = -1
    Use_Gravity_Vector = 0
    Size_Wiggle = 0
    Turbulence_Pos_Affect = 5
end

function presetDust()
    anim = false
    emitter.particularMesh.texture = 
                    "Tyrian Remastered:Energy Orb 1"
    Emitter_SizeX = WIDTH - 100
    Emitter_SizeY = HEIGHT - 100
    Particles_Sec = 100
    Life = 150
    Life_Variation = 50
    PartSize = 5
    PartSize_Variation = 95
    Part_End_Life_Size = 0
    Velocity = 0
    Velocity_Variation = 0
    Rotation_Speed = 0.2
    Rotation_Speed_Variation = 50
    Opacity = 70
    Opacity_Variation = 80
    Opacity_End = 0
    WindX = -10
    Air_Resistance = 0.1
    Gravity_Val = 0.3
    Use_Gravity_Vector = 0
    Size_Wiggle = 0
    Turbulence_Pos_Affect = 5
end

function presetTrail()
    anim = true
    emitter.particularMesh.texture = 
                    "Cargo Bot:Star Filled"
    Emitter_SizeX = 5
    Emitter_SizeY = 5
    Particles_Sec = 100
    Life = 150
    Life_Variation = 50
    PartSize = 15
    PartSize_Variation = 90
    Part_End_Life_Size = 5
    Velocity = 1.9
    Velocity_Variation = 90
    Rotation_Speed = 0.2
    Rotation_Speed_Variation = 50
    Opacity = 180
    Opacity_Variation = 80
    Opacity_End = 5
    WindX = -5
    Air_Resistance = 0.1
    Gravity_Val = -0.05
    Use_Gravity_Vector = 0
    Size_Wiggle = 1
    Turbulence_Pos_Affect = 5
end