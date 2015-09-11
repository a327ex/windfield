package.path = package.path .. ";C:\\Users\\Felipe\\dev\\hxdx\\?\\init.lua;C:\\Users\\Felipe\\dev\\hxdx\\?.lua"
hx = require('hxdx')

function love.load()
    world = hx.newWorld({gravity_y = 100})

    world:addCollisionClass('Ghost', {ignores = {'Default'}})
    world:collisionClassesSet()

    box = world:newRectangleCollider(50, 50, 50, 50, {collision_class = 'Ghost'})
    ground = world:newRectangleCollider(50, 150, 200, 60, {body_type = 'static'})
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    world:draw()
    box:draw()
    ground:draw()
end
