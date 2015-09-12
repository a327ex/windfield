package.path = package.path .. ";C:\\Users\\Felipe\\dev\\hxdx\\?\\init.lua;C:\\Users\\Felipe\\dev\\hxdx\\?.lua"
hx = require('hxdx')

function love.load()
    world = hx.newWorld({gravity_y = 500})

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('PlayerIgnoresPlatform', {ignores = {'Platform'}})

    ground = world:newRectangleCollider(100, 500, 600, 50, {body_type = 'static'})
    platform = world:newRectangleCollider(350, 400, 100, 20, {body_type = 'static', collision_class = 'Platform'})
    player = world:newRectangleCollider(390, 450, 20, 40, {collision_class = 'Player'})
end

function love.update(dt)
    world:update(dt)

    --[[
    -- ATTEMPT 1
    -- This is the natural thing to try. Doesn't work because by the time the collision happened
    -- changing the collision class won't nullify collision response.

    -- Check to see if player is below the platform right as a collision happens
    -- If it is then change its collision class to PlayerIgnoresPlatform so it can go through
    if player:pre('Platform') then
        local px, py = player.body:getPosition()
        local _, platform = player:pre('Platform')
        local tx, ty = platform.body:getPosition()
        if py > ty then player:changeCollisionClass('PlayerIgnoresPlatform') end
    end

    -- Change player's collision class back if the player is above the platform
    if player:exit('Platform') then 
        local px, py = player.body:getPosition()
        local _, platform = player:exit('Platform')
        local tx, ty = platform.body:getPosition()
        if py < ty then player:changeCollisionClass('Player') end
    end
    ]]--

    -- ATTEMPT 2
    -- This changes collision classes based on the player's and platform's position on every frame
    -- and not only when collision events happen. This will work.
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
