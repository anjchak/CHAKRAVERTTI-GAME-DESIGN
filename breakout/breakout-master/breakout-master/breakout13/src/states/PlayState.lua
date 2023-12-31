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
<<<<<<< HEAD

=======
    self.balls = {params.ball}
    
>>>>>>> b584beb4fb70156d52adca6ea84fe4603fd3bf9a
    self.recoverPoints = 5000

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    self.balls = {params.ball}

    self.powerups = {}
<<<<<<< HEAD

=======
    currentPaddleSize = SMALLEST_PADDLE
>>>>>>> b584beb4fb70156d52adca6ea84fe4603fd3bf9a
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
<<<<<<< HEAD
    for k, ball in self.balls do 
=======

    -- POWERUP RANDOM SPAWN HERE
    self.timer = self.timer + dt
    if self.timer >= math.random(8, 10) then
        skin = math.random(10)
        powerup = Powerup(skin, math.random(VIRTUAL_WIDTH), 0)
        table.insert(self.powerups, powerup) 
        self.timer = 0
    end

    for k, ball in pairs(self.balls) do
>>>>>>> b584beb4fb70156d52adca6ea84fe4603fd3bf9a
        ball:update(dt)

        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -self.ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
        
            -- else if we hit the paddle on its right side while moving right...
            elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
<<<<<<< HEAD
    
=======

>>>>>>> b584beb4fb70156d52adca6ea84fe4603fd3bf9a
                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)
    
                -- trigger the brick's hit function, which removes it from play
                brick:hit()
    
                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)
    
                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)
<<<<<<< HEAD
    
                    -- play recover sound effect
                    gSounds['recover']:play()
                end
    
=======
                    
                    -- play recover sound effect
                    gSounds['recover']:play()
                end

>>>>>>> b584beb4fb70156d52adca6ea84fe4603fd3bf9a
                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()
    
                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.ball,
                        recoverPoints = self.recoverPoints
                    })
                end
            end

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
<<<<<<< HEAD
        
        -- if ball goes below bounds, revert to serve state and decrease health
        if ball.y == VIRTUAL_HEIGHT then
            gSounds['hurt']:play()
            table.remove(self.balls, k )
            
            if #balls == 0 then
=======


        --  POWERUP COLLISION/UPDATE HERE
        for k, powerup in pairs(self.powerups) do
            powerup:update(dt)
            if powerup:collides(self.paddle) then
                table.remove(self.powerups, k)
                ballNew = Ball(math.random(7), 
                self.paddle.x + (self.paddle.width / 2) - 4, self.paddle.y - 8, 
                math.random(-200, 200), math.random(-50, -60))

                table.insert(self.balls, ballNew)

                ballNew = Ball(math.random(7), 
                self.paddle.x + (self.paddle.width / 2) - 4, self.paddle.y - 8, 
                math.random(-200, 200), math.random(-50, -60))

                table.insert(self.balls, ballNew)
            end
            if powerup.y > VIRTUAL_HEIGHT then
                table.remove(self.powerups, k)
            end
        end


        -- if ball goes below bounds, revert to serve state and decrease health
        if ball.y > VIRTUAL_HEIGHT then
            if #self.balls <= 1 then
>>>>>>> b584beb4fb70156d52adca6ea84fe4603fd3bf9a
                self.health = self.health - 1
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
                        recoverPoints = self.recoverPoints
                    })
                end
            end

        end

    end

    for k, powerup in pairs(self.powerups) do 
        powerup.update(dt)
        if powerup:collides(self.paddle) then
            table.remove(self.powerups, k)
            table.insert(self.balls, k)
        end
        if powerup.y > VIRTUAL_HEIGHT then
            table.remove(self.powerups, k)
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
<<<<<<< HEAD
=======
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

>>>>>>> b584beb4fb70156d52adca6ea84fe4603fd3bf9a
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    for k, powerup in pairs(self.powerups) do 
        powerup:render()
    end

    self.paddle:render()

    renderScore(self.score)
    renderHealth(self.health)

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
