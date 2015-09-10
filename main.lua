hx = require 'hxdx'

function love.load()
    world = hx.newWorld()
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    world:draw()
end
