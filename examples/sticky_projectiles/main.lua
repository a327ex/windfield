hx = require('hxdx')

function love.load()
    world = hx.newWorld({gravity_y = 500})
    world:addCollisionClass('Wall')

    wall = world:newRectangleCollider(500, 100, 30, 400, {body_type = 'static', collision_class = 'Wall'})
    projectiles = {}
end

function love.update(dt)
    world:update(dt)

    for _, projectile in ipairs(projectiles) do
        if projectile:enter('Wall') then
            local _, wall = projectile:enter('Wall')
            local x, y = projectile.body:getPosition()
            world:addJoint('RevoluteJoint', projectile.body, wall.body, x, y, true)
        end
    end
end

function love.draw()
    world:draw()
end

function love.keypressed(key)
    if key == 'space' then
        local projectile = world:newCircleCollider(50, 400, 5)
        projectile.body:applyLinearImpulse(love.math.random(40, 60), love.math.random(-80, -40))
        table.insert(projectiles, projectile)
    end
end
