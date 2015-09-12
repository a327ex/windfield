hx = require('hxdx')

-- There are two ways of doing this: 
-- 1. Change collision classes every frame based on the player's potision
-- 2. Disable the contact on the preSolve callback if the player is below the platform

function love.load()
    world = hx.newWorld({gravity_y = 500})

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('PlayerIgnoresPlatform', {ignores = {'Platform'}})

    ground = world:newRectangleCollider(100, 500, 600, 50, {body_type = 'static'})
    platform = world:newRectangleCollider(350, 400, 100, 20, {body_type = 'static', collision_class = 'Platform'})
    player = world:newRectangleCollider(390, 450, 20, 40, {collision_class = 'Player'})

    --[[
    -- This is method 2, uncomment this and comment method 1 to see that either works
    player:setPreSolve(function(collider_1, collider_2, contact)
        if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
            local px, py = collider_1.body:getPosition()
            local pw, ph = 20, 40
            local tx, ty = collider_2.body:getPosition()
            local tw, th = 100, 20
            if py + ph/2 > ty - th/2 then contact:setEnabled(false) end
        end
    end)
    ]]--
end

function love.update(dt)
    world:update(dt)

    -- This is method 1
    local px, py = player.body:getPosition()
    local pw, ph = 20, 40
    local tx, ty = platform.body:getPosition()
    local tw, th = 100, 20

    -- Player below platform
    if py - ph/2 > ty + th/2 then player:changeCollisionClass('PlayerIgnoresPlatform') end
    -- Player above platform
    if py + ph/2 < ty - th/2 then player:changeCollisionClass('Player') end
end

function love.draw()
    world:draw()
end

function love.keypressed(key)
    if key == 'space' then
        player.body:applyLinearImpulse(0, -600)
    end
end
