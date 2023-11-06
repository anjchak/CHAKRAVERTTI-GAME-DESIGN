Powerup = Class{}


function Powerup:init(skin)
    self.x = VIRTUAL_WIDTH / 2 + math.random(-3,3)
    self.y = VIRTUAL_HEIGHT / 2 + math.random(-3,3)

    self.width = 16
    self.height = 16

    self.dy = 0
    self.dx = 20

    self.skin = skin
end

function Powerup:update(dt)
    if self.y < VIRTUAL_HEIGHT then
        self.dy = self.dy + dt
        self.y = self.y + self.dy
    end
end

function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin], self.x, self.y)
end