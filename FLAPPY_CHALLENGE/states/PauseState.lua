--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PauseState = Class{__includes = BaseState}

function PauseState:init()
    -- empty table where all the things being passed in from playstate can be stored
    self.gameState = {}
end

function PauseState:enter(playState)
    PAUSED = true
    self.gameState = playState
    -- pause music
    love.audio.pause(sounds['music'])
    -- play paused sound
    love.audio.play(sounds['pause'])
end

function PauseState:update(dt)
    -- switching back to playstate if they press p again
    if love.keyboard.wasPressed('p') then
        PAUSED = false
        -- play music
        love.audio.play(sounds['music'])
        -- change into playstate, return the self.gamestate file
        gStateMachine:change('play', self.gameState)
    end
end

function PauseState:render()
    -- rendering pipes
    for k, pair in pairs(self.gameState.pipePairs) do
        pair:render()
    end

    -- rendering the button
    love.graphics.draw(button, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 0, 0.1, 0.1)

    --rendering images  FROM MEDAL CHALLENGE
    if self.gameState.score >= 2 and self.gameState.score < 5 then
        love.graphics.draw(shrug, VIRTUAL_WIDTH - 30, 8, 0.05, 0.05)
    end
    if self.gameState.score >= 5 and self.gameState.score < 7 then
        love.graphics.draw(thumbs_up, VIRTUAL_WIDTH - 30, 8, 0.04, 0.04)
    end
    if self.gameState.score >= 7 then
        love.graphics.draw(celebrate, VIRTUAL_WIDTH - 30, 8, 0.05, 0.05)
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.gameState.score), 8, 8)

    --rendering bird
    self.gameState.bird:render()
end

