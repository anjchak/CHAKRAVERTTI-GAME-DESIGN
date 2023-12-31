--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.balls = {params.ball}
    self.maxHealth = params.maxHealth
    
    self.recoverPoints = 5000
    self.timer = 0

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    -- create a table of powerups
    self.powerups = {}
    --key powerup
    self.key = false

    --small and largest paddle sizes
    self.smallestPaddle = 1
    self.largestPaddle = 4
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    -- POWERUP RANDOM SPAWN HERE
    self.timer = self.timer + dt
    if self.timer >= math.random(5, 6) then
        skin = math.random(10)
        --skin = 10
        powerup = Powerup(skin, math.random(VIRTUAL_WIDTH - 16), 16)
        table.insert(self.powerups, powerup)
        self.timer = 0
    end

    for k, ball in pairs(self.balls) do
        ball:update(dt)

        if ball:collides(self.paddle) then 
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
        
             -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end 

            -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                if self.key and brick.locked then
                    self.score = self.score + 1000
                    brick:hit(self.key)
                    self.key = false
                elseif not brick.locked then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                    brick:hit(self.key)
                end
                -- trigger the brick's hit function, which removes it from play

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 2 less than max health
                    if self.health + 1 < self.maxHealth then
                        self.health = math.min(self.maxHealth - 2, self.health + 1)
                    end
                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                    if self.paddle.size < self.largestPaddle then
                        self.paddle.size = self.paddle.size + 1
                    end 

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = ball,
                        recoverPoints = self.recoverPoints,
                        maxHealth = self.maxHealth
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
            
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
            
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
            
                -- bottom edge if no X collisions or top collision, last possibility
                else
                
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end

        --  POWERUP COLLISION/UPDATE HERE
        for k, powerup in pairs(self.powerups) do
            powerup:update(dt)
            if powerup:collides(self.paddle) then
                if powerup.skin == 10 then
                    self.key = true
                end

                if powerup.skin == 3 then
                    --if current health is at 10 (MAX_TOTAL_HEALTH), then check to see if max health is greater than current health
                    -- if its greater add health, otherwise don't do anything
                    if self.maxHealth == MAX_TOTAL_HEALTH then
                        if self.maxHealth > self.health then
                            self.health = self.health + 1
                        end
                    -- if current health is equal to current max health, increase both
                    elseif self.maxHealth == self.health then
                        self.maxHealth = self.maxHealth + 1
                        self.health = self.health + 1
                    -- otherwise only increase current max health
                    else
                        self.maxHealth = self.maxHealth + 1
                    end
                end

                table.remove(self.powerups, k) 

                ballNew = Ball(math.random(7), 
                self.paddle.x + (self.paddle.width / 2) - 4, self.paddle.y - 8, 
                math.random(-200, 200), math.random(-50, -60))
                table.insert(self.balls, ballNew)

                table.insert(self.balls, ballNew)

                ballNew = Ball(math.random(7), 
                self.paddle.x + (self.paddle.width / 2) - 4, self.paddle.y - 8, 
                math.random(-200, 200), math.random(-50, -60))
                table.insert(self.balls, ballNew)
            elseif powerup.y > VIRTUAL_HEIGHT then
                table.remove(self.powerups, k)
            end
        end


        -- if ball goes below bounds, revert to serve state and decrease health
        if ball.y > VIRTUAL_HEIGHT then
            if #self.balls <= 1 then
                self.health = self.health - 1
                -- decrease paddle size
                if self.paddle.size > self.smallestPaddle then
                    self.paddle.size = self.paddle.size - 1
                end
                gSounds['hurt']:play()

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints,
                        maxHealth = self.maxHealth
                    })
                end
            else
                table.remove(self.balls, k)
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    for k, ball in pairs(self.balls) do
        ball:render()
    end

    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    self.paddle:render()

    renderScore(self.score)
    --pass in max health now
    renderHealth(self.health, self.maxHealth)

    if self.key then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][10], 
        60, 5, 40)
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end
    return true
end