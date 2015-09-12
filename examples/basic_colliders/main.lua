hx = require('hxdx')

function love.load()
    world = hx.newWorld({gravity_y = 200})

    world:addCollisionClass('Ghost', {ignores = {'Default'}})
    world:collisionClassesSet()

    box = world:newRectangleCollider(375, 300, 50, 50, {collision_class = 'Ghost'}) 
    ground = world:newRectangleCollider(300, 400, 200, 30, {body_type = 'static'})
end

function love.update(dt)
    world:update(dt)

    if box:enter('Default') then
        box.body:applyLinearImpulse(0, -5000)
    end
end

function love.draw()
    world:draw()
end
