hx = require('hxdx')

function love.load()
    world = hx.newWorld()
    for i = 1, 1000 do
        world:newRectangleCollider(love.math.random(0, 770), love.math.random(0, 570), 30, 30, {body_type = 'static'})
    end
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    -- Queries are drawn for some number of frames (set with world.draw_query_for_n_frames) after they were last called
    world:draw()
end

function love.keypressed(key)
    if key == '1' then
        local colliders = world:queryRectangleArea(0, 0, 200, 200)
        for _, collider in ipairs(colliders) do collider:destroy() end
    elseif key == '2' then
        local colliders = world:queryCircleArea(400, 150, 100)
        for _, collider in ipairs(colliders) do collider:destroy() end
    elseif key == '3' then
        local colliders = world:queryPolygonArea({600, 200, 780, 480, 400, 350})
        for _, collider in ipairs(colliders) do collider:destroy() end
    elseif key == '4' then
        local colliders = world:queryLine(50, 550, 400, 200)
        for _, collider in ipairs(colliders) do collider:destroy() end
    end
end
