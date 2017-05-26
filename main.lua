wf = require 'windfield'

function createSimulation()
    world = wf.newWorld(0, 0, true)
    world:setQueryDebugDrawing(true)

    colliders = {}
    for i = 1, 200 do table.insert(colliders, world:newRectangleCollider(love.math.random(0, 800), love.math.random(0, 600), 25, 25)) end
end

function destroySimulation()
    world:destroy()
    colliders = nil
    world = nil
end

function love.load()

end

function love.update(dt)
    if world then world:update(dt) end
end

function love.draw()
    if world then world:draw() end
end

function love.keypressed(key)
    if key == 'p' then
        local colliders = world:queryCircleArea(400, 300, 100)
        for _, collider in ipairs(colliders) do
            collider:applyLinearImpulse(1000, 1000)
        end
    end

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

