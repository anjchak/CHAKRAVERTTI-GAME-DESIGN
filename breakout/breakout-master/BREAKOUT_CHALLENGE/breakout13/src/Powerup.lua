Powerup = Class{}


function Powerup:init(skin, x, y)
    self.width = 16
    self.height = 16

    self.x = x
    self.y = y

    self.dy = 20
    self.dx = 0

    self.skin = skin
end

function Powerup:update(dt)
    if self.y < VIRTUAL_HEIGHT then
        self.y = self.y + self.dy * dt
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

    return true
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin], self.x, self.y)
end