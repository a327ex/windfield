wf = require 'windfield'

function createSimulation()
    world = wf.newWorld(0, 0, true)
    world:setGravity(0, 400)
    world:addCollisionClass('Box')
    world:addCollisionClass('Solid')

    colliders = {}
    for i = 1, 50 do
        local collider = world:newRectangleCollider(love.math.random(0, 800), 0, 25, 25)
        collider:setCollisionClass('Box')
        collider:setRestitution(0.8)
        table.insert(colliders, collider)
    end

    ground = world:newRectangleCollider(0, 550, 800, 50)
    ground:setCollisionClass('Solid')
    ground:setType('static')
end

function destroySimulation()
    world:destroy()
    ground = nil
    colliders = nil
    joint = nil
    world = nil
end

function love.load()

end

function love.update(dt)
    if world then
        world:update(dt)

        for _, collider in ipairs(colliders) do
            if collider:enter('Solid') then
                local collision_data = collider:getEnterCollisionData('Solid')
                -- print('enter', collision_data.collider, collision_data.contact)
            end

            if collider:stay('Solid') then
                local collision_datum = collider:getStayCollisionData('Solid')
                for _, collision_data in ipairs(collision_datum) do
                    -- print('stay', collision_data.collider, collision_data.contact)
                end
            end

            if collider:exit('Solid') then
                local collision_data = collider:getEnterCollisionData('Solid')
                -- print('exit', collision_data.collider, collision_data.contact)
            end
        end
    end
end

function love.draw()
    if world then
        world:draw()
    end
end

function love.keypressed(key)
    if key == 'f1' then
        print("Before collection: " .. collectgarbage("count")/1024)
        collectgarbage()
        print("After collection: " .. collectgarbage("count")/1024)
        print("Object count: ")
        local counts = type_count()
        for k, v in pairs(counts) do print(k, v) end
        print("-------------------------------------")
    end

    if key == 'f2' then
        createSimulation()
    end

    if key == 'f3' then
        destroySimulation()
    end
end

-- Memory --
function count_all(f)
    local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
	end
	count_table(_G)
end

function type_count()
	local counts = {}
	local enumerate = function (o)
		local t = type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	count_all(enumerate)
	return counts
end

global_type_table = nil
function type_name(o)
	if global_type_table == nil then
		global_type_table = {}
		for k,v in pairs(_G) do
			global_type_table[v] = k
		end
		global_type_table[0] = "table"
	end
	return global_type_table[getmetatable(o) or 0] or "Unknown"
end

