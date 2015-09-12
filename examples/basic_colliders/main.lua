package.path = package.path .. ";C:\\Users\\Felipe\\dev\\hxdx\\?\\init.lua;C:\\Users\\Felipe\\dev\\hxdx\\?.lua"
hx = require('hxdx')

function love.load()
    world = hx.newWorld({gravity_y = 100})

    world:addCollisionClass('Ghost', {ignores = {'Default'}})
    world:collisionClassesSet()

    box = world:newRectangleCollider(400, 300, 50, 50, {collision_class = 'Ghost'}) 
    ground = world:newRectangleCollider(400, 400, 200, 30, {body_type = 'static'})
end

function love.update(dt)
    world:update(dt)

    if box:enter('Default') then
        box.body:applyLinearImpulse(0, -5000)
    end
end

function love.draw()
    world:draw()
    box:draw()
    ground:draw()
end
