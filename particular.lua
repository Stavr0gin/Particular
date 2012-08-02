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

Particular = class()

function Particular:init(x,y)
    self.x = x
    self.y = y
    self.sizeX = 0
    self.sizeY = 0
    self.partPerSec = 2
    self.life = 30
    self.lifeVariation = 0
    self.rotSpd = 0.0
    self.rotSpdVariation = 0
    self.initPartSize = 35
    self.partSizeVariation = 0
    self.finalPartSize = -1
    self.velocity = 10
    self.velocityVariation = 0
    self.initOpacity = 255
    self.opacityVariation = 0
    self.finalOpacity = -1
    self.windX = 0
    self.airResistance = 0.1
    self.gravity = 0
    self.useGravityVector = 0
    self.sizeWiggle = 0
    self.turbulencePosAffect = 0

    self.rects = {}
    self.deadRects = {}
    self.parts = {}
    self.particularMesh = mesh()
    self.evo = 0
    self.tSinceLast = 0.0
    self.particleLimit = 50
end

function Particular:draw()
    self.tSinceLast = self.tSinceLast + DeltaTime
    local tCreation = 1 / self.partPerSec
    local partCreated = 0
    if self.partPerSec == 0 then
        self.tSinceLast = 0
    end
    -- Creating new particles
    while (self.tSinceLast > tCreation) do
        partCreated = partCreated + 1
        if (partCreated<=self.particleLimit)then
            self.tSinceLast = self.tSinceLast-tCreation
        else
            self.tSinceLast = 0
        end
        self:createParticle()
    end
    local resistance = 1/(self.airResistance + 1)
    -- Calculating gravity
    local g
    if self.useGravityVector > 0 then
        if self.gravity == 0 then
            g = vec2(0,0)
        else if self.gravity > 0 then
            g = vec2(Gravity.x,Gravity.y)
        else
            g = vec2(-Gravity.x,-Gravity.y)
        end
        end
    else
        g = vec2(0,-self.gravity)
    end
    
    for k,i in ipairs(self.rects) do
        local p = self.parts[i]
        -- Calculating turbulence
        local nx = 0
        local ny = 0
        if self.turbulencePosAffect>0 then
            local n = noise(p.x,p.y,self.evo)
            if n > 0 then
                n = n - math.floor(n)
            else
                n = n - math.ceil(n)
            end
            
            nx = n * math.cos(self.evo)
            ny = n * math.sin(self.evo)
            self.evo = self.evo + 1
            if self.evo > 9999 then
                self.evo = 0
            end
        end
        
        if (p.lifeLeft > 0) then
            -- Calculating position and velocity
            p.x = p.x + p.v.x +
                self.windX * 0.1 +
                self.turbulencePosAffect*nx
            p.y = p.y + p.v.y +
                self.turbulencePosAffect*ny
            p.v = p.v + g
            p.v = p.v * resistance
            
            local lifePercentage = (p.life-p.lifeLeft)/p.life
            -- Calculating size
            local size
            if self.finalPartSize >= 0 then
                local sizeInc = self.finalPartSize - p.initSize
                size = (lifePercentage*sizeInc)+p.initSize
            else
                size = p.initSize
            end
            if ((self.sizeWiggle>0)and(size>1)) then
                size = math.random(size)
            end
            if (size<0) then
                size = 0
            end
            
            -- Calculating opacity
            local opacity
            if self.finalOpacity >= 0 then
                local opacityInc = self.finalOpacity - p.initOpacity
                opacity = (lifePercentage*opacityInc)+p.initOpacity
            else
                opacity = p.initOpacity
            end
            
            -- Calculating rotation
            p.angle = p.angle + p.rotSpd
            
            p.lifeLeft = p.lifeLeft - 1
            self.particularMesh:setRect(i,p.x,p.y,size,size,p.angle)
            self.particularMesh:setRectColor(i,255,255,255,opacity)
        else
            local deadPart = self.parts[i]
            if not deadPart.isDead then
                table.insert(self.deadRects,i)
                self.particularMesh:setRect(i,0,0,0,0)
                deadPart.isDead = true
            end
        end
    end
    self.particularMesh:draw()
end

function Particular:createParticle()
    local psize = genNumber(self.initPartSize,self.partSizeVariation)
        
    local v = vec2(math.random(-100,100),math.random(-100,100))
    v = v:normalize()
    v = v * genNumber(self.velocity,self.velocityVariation)
        
    local partX = self.x + math.random(-self.sizeX,self.sizeX)
    local partY = self.y + math.random(-self.sizeY,self.sizeY)
    local particle = Particle(partX,
                partY,
                psize,
                genNumber(self.life,self.lifeVariation),
                v,
                0,
                genNumber(self.initOpacity,self.opacityVariation),
                genNumber(self.rotSpd,self.rotSpdVariation))
    local index
    if (self.deadRects[1]==nil) then
        index = self.particularMesh:addRect(self.x,
                                        self.y,
                                        psize,
                                        psize)
        table.insert(self.rects, index)
        table.insert(self.parts, particle)
    else
        index = self.deadRects[1]
        table.remove(self.deadRects,1)
        self.particularMesh:setRect(index,
                                    self.x,
                                    self.y,
                                    psize,
                                    psize)
        self.parts[index] = particle
    end
    self.particularMesh:setRectColor(index,255,255,255,
                                    particle.initOpacity)
end

function genNumber(number,variation)
    if variation == 0.0 then
        return number
    end
    if number == 0 then
        return number
    end
    number = number * 1000
    mult = true
    ret = variation*0.01*math.abs(number)
    ret = number + math.random(-ret,ret)
    ret = ret / 1000
    return ret
end


--
-- Particle class
--

Particle = class()

Particle.DEFAULT_OPACITY = 125
Particle.DEFAULT_ANGLE = 0
Particle.DEFAULT_MASS = 1

function Particle:init(posx,posy,size,life,
    velocity,angle,opacity,rotSpd)
    -- position
    self.x = posx
    self.y = posy
    
    -- size
    self.initSize = size
    
    -- velocity
    self.v = velocity
    
    -- life
    self.life = life
    self.lifeLeft= life
    
    -- angle
    if angle == nil then
        self.angle = self.DEFAULT_ANGLE
    else
        self.angle = angle
    end
    
    -- rotation speed
    if rotSpd==nil then
        self.rotSpd = 0.0
    else
        self.rotSpd = rotSpd
    end
    
    -- opacity
    self.initOpacity = opacity
    
    self.isDead = false
end