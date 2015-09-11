local path = ... .. '.' local hx = {} hx.Math = require(path .. 'mlib.mlib') 

--- @class World 
-- @description A World contains the [box2d world](https://www.love2d.org/wiki/World) as well as state for handling collision classes, methods for changing box2d world settings as well as methods for the creation of Colliders and Effectors.  
local World = {} 
World.__index = World 

--- Creates a new World 
-- @luastart 
-- @code physics_world = hx.newWorld({gravity_y = 20})
-- @luaend 
-- @arg {table=} settings - Table with optional settings for the world:
-- @setting {number=0} gravity_x - The world's x gravity component 
-- @setting {number=0} gravity_y - The world's y gravity component
-- @setting {boolean=true} allow_sleeping - If the world's bodies are allowed to sleep
-- @returns {World}
function hx.newWorld(settings)
    local world = hx.World.new(hx, settings)

    world.box2d_world:setCallbacks(world.collisionOnEnter, world.collisionOnExit, world.collisionPre, world.collisionPost)
    world:collisionClear()
    world:addCollisionClass('Default')
    world:collisionClassesSet()

    return world
end

function World.new(hx, settings)
    local self = {}
    local settings = settings or {}
    self.hx = hx

    self.collision_classes = {}
    self.masks = {}
    self.is_sensor_memo = {}

    love.physics.setMeter(32)
    self.box2d_world = love.physics.newWorld(settings.gravity_x or 0, settings.gravity_y or 0, settings.allow_sleeping) 

    return setmetatable(self, World)
end

--- Updates the World
-- @luastart
-- @code physics_world:update(dt)
-- @luaend
-- @arg {number} dt - Time step delta
function World:update(dt)
    self.box2d_world:update(dt)
end

--- Draws the World (for debugging purposes)
-- @luastart
-- @code physics_world:draw()
-- @luaend
function World:draw()

end

--- Adds a new collision class to the world. Collision classes are attached to colliders and define collider behavior in terms of which ones will be physically ignored and which ones will generate collision events between each other. All collision classes must be added **before** any collider is created. After all collision classes are added `collisionClassesSet` must be called once.
-- @luastart
-- @code physics_world:addCollisionClass('Player', {
-- @code                                 ignores = {'NPC', 'Enemy'}, 
-- @code                                 enter = {'LevelTransitionArea'}, 
-- @code                                 exit = {'Projectile'}})
-- @luaend
-- @arg {string} collision_class_name - The unique name of the collision class
-- @arg {table} collision_class - The collision class. This table can contain:
-- @setting {table[string]=} ignores - The collision class names that will be physically ignored
-- @setting {table[string]=} enter - The collision class names that will generate collision events when they enter contact 
-- @setting {table[string]=} exit - The collision class names that will generate collision events when they exit contact 
-- @setting {table[string]=} pre - The collision class names that will generate collision events right before collision response is applied 
-- @setting {table[string]=} post - The collision class names that will generate collision events right after collision response is applied
function World:addCollisionClass(collision_class_name, collision_class)
    if self.collision_classes[collision_class_name] then error('Collision class ' .. collision_class_name .. ' already exists.') end
    self.collision_classes[collision_class_name] = collision_class or {}
end

--- Sets all collision classes. This function must be called once after all collision classes have been added and before any collider is created.
function World:collisionClassesSet()
    self:generateCategoriesMasks()

    local collision_table = self:getCollisionCallbacksTable()
    for collision_class_name, collision_list in pairs(collision_table) do
        for _, collision_info in ipairs(collision_list) do
            if collision_info.type == 'enter' then self:addCollisionEnter(collision_class_name, collision_info.other) end
            if collision_info.type == 'exit' then self:addCollisionExit(collision_class_name, collision_info.other) end
            if collision_info.type == 'pre' then self:addCollisionPre(collision_class_name, collision_info.other) end
            if collision_info.type == 'post' then self:addCollisionPre(collision_class_name, collision_info.other) end
        end
    end
end

function World.collisionOnEnter(a, b, contact)

end

function World.collisionOnExit()
    
end

function World.collisionPre()
    
end

function World.collisionPost()
    
end

function World:collisionClear()
    self.collisions = {}
    self.collisions.on_enter = {}
    self.collisions.on_enter.sensor = {}
    self.collisions.on_enter.non_sensor = {}
    self.collisions.on_exit = {}
    self.collisions.on_exit.sensor = {}
    self.collisions.on_exit.non_sensor = {}
    self.collisions.pre = {}
    self.collisions.pre.sensor = {}
    self.collisions.pre.non_sensor = {}
    self.collisions.post = {}
    self.collisions.post.sensor = {}
    self.collisions.post.non_sensor = {}
end

function Collision:addCollisionEnter(type1, type2)
    if not self:isCollisionBetweenSensors(type1, type2) then
        table.insert(self.collisions.on_enter.non_sensor, {type1 = type1, type2 = type2})
    else table.insert(self.collisions.on_enter.sensor, {type1 = type1, type2 = type2}) end
end

function Collision:addCollisionExit(type1, type2)
    if not self:isCollisionBetweenSensors(type1, type2) then
        table.insert(self.collisions.on_exit.non_sensor, {type1 = type1, type2 = type2})
    else table.insert(self.collisions.on_exit.sensor, {type1 = type1, type2 = type2}) end
end

function Collision:addCollisionPre(type1, type2)
    if not self:isCollisionBetweenSensors(type1, type2) then
        table.insert(self.collisions.pre.non_sensor, {type1 = type1, type2 = type2})
    else table.insert(self.collisions.pre.sensor, {type1 = type1, type2 = type2}) end
end

function Collision:addCollisionPost(type1, type2)
    if not self:isCollisionBetweenSensors(type1, type2) then
        table.insert(self.collisions.post.non_sensor, {type1 = type1, type2 = type2})
    else table.insert(self.collisions.post.sensor, {type1 = type1, type2 = type2}) end
end

function World:doesType1IgnoreType2(type1, type2)
    local collision_ignores = {}
    for collision_class_name, collision_class in pairs(self.collision_classes) do
        collision_ignores[collision_class_name] = collision_class.ignores or {}
    end
    local all = {}
    for collision_class_name, _ in pairs(collision_ignores) do
        table.insert(all, collision_class_name)
    end
    local ignored_types = {}
    for _, collision_class_type in ipairs(collision_ignores[type1]) do
        if collision_class_type == 'All' then
            for _, collision_class_name in ipairs(all) do
                table.insert(ignored_types, collision_class_name)
            end
        else table.insert(ignored_types, collision_class_type) end
    end
    for key, _ in pairs(collision_ignores[type1]) do
        if key == 'except' then
            for _, except_type in ipairs(collision_ignores[type1].except) do
                for i = #ignored_types, 1, -1 do
                    if ignored_types[i] == except_type then table.remove(ignored_types, i) end
                end
            end
        end
    end
    for _, ignored_type in ipairs(ignored_types) do
        if ignored_type == type2 then return true end
    end
end

function World:isCollisionBetweenSensors(type1, type2)
    if not self.is_sensor_memo[type1] then self.is_sensor_memo[type1] = {} end
    if not self.is_sensor_memo[type1][type2] then self.is_sensor_memo[type1][type2] = (self:doesType1IgnoreType2(type1, type2) or self:doesType1IgnoreType2(type2, type1)) end
    if self.is_sensor_memo[type1][type2] then return true
    else return false end
end

function World:generateCategoriesMasks()
    local collision_ignores = {}
    for collision_class_name, collision_class in pairs(self.collision_classes) do
        collision_ignores[collision_class_name] = collision_class.ignores or {}
    end
    local incoming = {}
    local expanded = {}
    local all = {}
    for object_type, _ in pairs(collision_ignores) do
        incoming[object_type] = {}
        expanded[object_type] = {}
        table.insert(all, object_type)
    end
    for object_type, ignore_list in pairs(collision_ignores) do
        for key, ignored_type in pairs(ignore_list) do
            if ignored_type == 'All' then
                for _, all_object_type in ipairs(all) do
                    table.insert(incoming[all_object_type], object_type)
                    table.insert(expanded[object_type], all_object_type)
                end
            elseif type(ignored_type) == 'string' then
                if ignored_type ~= 'All' then
                    table.insert(incoming[ignored_type], object_type)
                    table.insert(expanded[object_type], ignored_type)
                end
            end
            if key == 'except' then
                for _, except_ignored_type in ipairs(ignored_type) do
                    for i, v in ipairs(incoming[except_ignored_type]) do
                        if v == object_type then
                            table.remove(incoming[except_ignored_type], i)
                            break
                        end
                    end
                end
                for _, except_ignored_type in ipairs(ignored_type) do
                    for i, v in ipairs(expanded[object_type]) do
                        if v == except_ignored_type then
                            table.remove(expanded[object_type], i)
                            break
                        end
                    end
                end
            end
        end
    end
    local edge_groups = {}
    for k, v in pairs(incoming) do
        table.sort(v, function(a, b) return string.lower(a) < string.lower(b) end)
    end
    local i = 0
    for k, v in pairs(incoming) do
        local str = ""
        for _, c in ipairs(v) do
            str = str .. c
        end
        if not edge_groups[str] then i = i + 1; edge_groups[str] = {n = i} end
        table.insert(edge_groups[str], k)
    end
    local categories = {}
    for k, _ in pairs(collision_ignores) do
        categories[k] = {}
    end
    for k, v in pairs(edge_groups) do
        for i, c in ipairs(v) do
            categories[c] = v.n
        end
    end
    for k, v in pairs(expanded) do
        local category = {categories[k]}
        local current_masks = {}
        for _, c in ipairs(v) do
            table.insert(current_masks, categories[c])
        end
        self.masks[k] = {categories = category, masks = current_masks}
    end
end

function World:getCollisionCallbacksTable()
    local collision_table = {}
    for collision_class_name, collision_class in pairs(self.collision_classes) do
        collision_table[collision_class_name] = {}
        for _, v in ipairs(collision_class.enter or {}) do table.insert(collision_table[collision_class_name], {type = 'enter', other = v}) end
        for _, v in ipairs(collision_class.exit or {}) do table.insert(collision_table[collision_class_name], {type = 'exit', other = v}) end
        for _, v in ipairs(collision_class.pre or {}) do table.insert(collision_table[collision_class_name], {type = 'pre', other = v}) end
        for _, v in ipairs(collision_class.post or {}) do table.insert(collision_table[collision_class_name], {type = 'post', other = v}) end
    end
    return collision_table
end

--- Creates a new CircleCollider
-- @luastart
-- @code collider = physics_world:newCircleCollider(100, 100, 30)
-- @luaend
-- @arg {number} x - The initial x position of the circle (center)
-- @arg {number} y - The initial y position of the circle (center)
-- @arg {number} r - The radius of the circle
-- @arg {table=} settings - A table with additional and optional settings. This table can contain:
-- @setting {BodyType='dynamic'} body_type - The body type, can be 'static', 'dynamic' or 'kinematic'
-- @setting {string=} collision_class - The collision class of the circle, must be a valid collision class previously added with `addCollisionClass`
-- @returns {Collider}
function World:newCircleCollider(x, y, r, settings)
    return self.hx.Collider.new(self, 'Circle', x, y, r, settings)
end

--- Creates a new RectangleCollider
-- @luastart
-- @code collider = physics_world:newRectangleCollider(100, 100, 50, 50, {body_type = 'static', collision_class = 'Solid'})
-- @luaend
-- @arg {number} x - The initial x position of the rectangle (center)
-- @arg {number} y - The initial y position of the rectangle (center)
-- @arg {number} w - The width of the rectangle (x - w/2 = rectangle's left side)
-- @arg {number} h - The height of the rectangle (y - h/2 = rectangle's top side)
-- @arg {table=} settings - A table with additional and optional settings. This table can contain:
-- @setting {BodyType='dynamic'} body_type - The body type, can be 'static', 'dynamic' or 'kinematic'
-- @setting {string=} collision_class - The collision class of the rectangle, must be a valid collision class previously added with `addCollisionClass`
-- @returns {Collider}
function World:newRectangleCollider(x, y, w, h, settings)
    return self.hx.Collider.new(self, 'Rectangle', x, y, w, h, settings)
end

--- Creates a new BSGRectangleCollider (a rectangle with its corners cut (an octagon))
-- @luastart
-- @code collider = physics_world:newBSGRectangleCollider(100, 100, 50, 50, 5)
-- @luaend
-- @arg {number} x - The initial x position of the rectangle (center)
-- @arg {number} y - The initial y position of the rectangle (center)
-- @arg {number} w - The width of the rectangle (x - w/2 = rectangle's left side)
-- @arg {number} h - The height of the rectangle (y - h/2 = rectangle's top side)
-- @arg {number} corner_cut_size - The corner cut size
-- @arg {table=} settings - A table with additional and optional settings. This table can contain:
-- @setting {BodyType='dynamic'} body_type - The body type, can be 'static', 'dynamic' or 'kinematic'
-- @setting {string=} collision_class - The collision class of the rectangle, must be a valid collision class previously added with `addCollisionClass`
-- @returns {Collider}
function World:newBSGRectangleCollider(x, y, w, h, corner_cut_size, settings)
    return self.hx.Collider.new(self, 'BSGRectangle', x, y, w, h, corner_cut_size, settings)
end

--- Creates a new PolygonCollider
-- @luastart
-- @code collider = physics_world:newPolygonCollider({10, 10, 10, 20, 20, 20, 20, 10})
-- @luaend
-- @arg {table[number]} vertices - The polygon vertices as a table of numbers
-- @arg {table=} settings - A table with additional and optional settings. This table can contain:
-- @setting {BodyType='dynamic'} body_type - The body type, can be 'static', 'dynamic' or 'kinematic'
-- @setting {string=} collision_class - The collision class of the polygon, must be a valid collision class previously added with `addCollisionClass`
-- @returns {Collider}
function World:newPolygonCollider(vertices, settings)
    return self.hx.Collider.new(self, 'Polygon', vertices, settings)
end

--- Creates a new LineCollider
-- @luastart
-- @code collider = physics_world:newLineCollider(100, 100, 200, 200, {body_type = 'static'})
-- @luaend
-- @arg {number} x1 - The initial x position of the line
-- @arg {number} y1 - The initial y position of the line
-- @arg {number} x2 - The final x position of the line
-- @arg {number} y2 - The final y position of the line
-- @arg {table=} settings - A table with additional and optional settings. This table can contain:
-- @setting {BodyType='dynamic'} body_type - The body type, can be 'static', 'dynamic' or 'kinematic'
-- @setting {string=} collision_class - The collision class of the line, must be a valid collision class previously added with `addCollisionClass`
-- @returns {Collider}
function World:newLineCollider(x1, y1, x2, y2, settings)
    return self.hx.Collider.new(self, 'Line', x1, y1, x2, y2, settings)
end

--- Creates a new ChainCollider
-- @luastart
-- @code collider = physics_world:newChainCollider({10, 10, 10, 20, 20, 20}, true, {body_type = 'static', collision_class = 'Ground'})
-- @luaend
-- @arg {table[number]} vertices - The chain vertices as a table of numbers
-- @arg {boolean} loop - If the chain should loop back from the last to the first point
-- @arg {table=} settings - A table with additional and optional settings. This table can contain:
-- @setting {BodyType='dynamic'} body_type - The body type, can be 'static', 'dynamic' or 'kinematic'
-- @setting {string=} collision_class - The collision class of the chain, must be a valid collision class previously added with `addCollisionClass`
-- @returns {Collider}
function World:newChainCollider(vertices, loop, settings)
    return self.hx.Collider.new(self, 'Chain', vertices, loop, settings)
end

-- Internal AABB box2d query used before going for more specific and precise computations.
function World:queryBoundingBox(x1, y1, x2, y2, callback)

end

--- Queries a circular area around a point for colliders
-- @luastart
-- @code colliders_1 = physics_world:queryCircleArea(100, 100, 50, {'Enemy', 'NPC'})
-- @code colliders_2 = physics_world:queryCircleArea(100, 100, 50, {'All', except = {'Player'}})
-- @luaend
-- @arg {number} x - The initial x position of the circle (center)
-- @arg {number} y - The initial y position of the circle (center)
-- @arg {number} r - The radius of the circle
-- @arg {table[string]='All'} collision_class_names - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision class names. Another special value (a table of collision class names) `except` can be used to exclude some collision class names when `'All'` is used.
function World:queryCircleArea(x, y, radius, collision_class_names)
    
end

--- Queries a rectangular area around a point for colliders
-- @luastart
-- @code -- In both examples x, y are the center of the rectangle, meaning the top-left points on both is 75, 75
-- @code colliders_1 = physics_world:queryRectangleArea(100, 100, 50, 50 {'Enemy', 'NPC'})
-- @code colliders_2 = physics_world:queryRectangleArea(100, 100, 50, 50, {'All', except = {'Player'}})
-- @luaend
-- @arg {number} x - The initial x position of the rectangle (center)
-- @arg {number} y - The initial y position of the rectangle (center)
-- @arg {number} w - The width of the rectangle (x - w/2 = rectangle's left side)
-- @arg {number} h - The height of the rectangle (y - h/2 = rectangle's top side)
-- @arg {table[string]='All'} collision_class_names - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision class names. Another special value (a table of collision class names) `except` can be used to exclude some collision class names when `'All'` is used.
function World:queryRectangleArea(x, y, w, h, collision_class_names)
    
end

--- Queries an arbitrary area for colliders
-- @luastart
-- @code colliders = physics_world:queryPolygonArea({10, 10, 20, 10, 20, 20, 10, 20}, {'Enemy'})
-- @code colliders = physics_world:queryPolygonArea({10, 10, 20, 10, 20, 20, 10, 20}, {'All', except = {'Player'}})
-- @luaend
-- @arg {table[number]} vertices - The polygon vertices as a table of numbers
-- @arg {table[string]='All'} collision_class_names - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision class names. Another special value (a table of collision class names) `except` can be used to exclude some collision class names when `'All'` is used.
function World:queryPolygonArea(vertices, collision_class_names)
    
end

--- Queries for colliders that intersect with a line
-- @luastart
-- @code colliders = physics_world:queryLine(100, 100, 200, 200, {'Enemy', 'NPC', 'Projectile'})
-- @code colliders = physics_world:queryLine(100, 100, 200, 200, {'All', except = {'Player'}})
-- @luaend
-- @arg {number} x1 - The initial x position of the line
-- @arg {number} y1 - The initial y position of the line
-- @arg {number} x2 - The final x position of the line
-- @arg {number} y2 - The final y position of the line
-- @arg {table[string]='All'} collision_class_names - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision class names. Another special value (a table of collision class names) `except` can be used to exclude some collision class names when `'All'` is used.
function World:queryLine(x1, y1, x2, y2, collision_class_names)
    
end

--- Adds a joint to the world. A joint can be accessed via physics_world.joints[joint_name]
-- @arg {string} joint_name - The unique name of the joint
-- @arg {string} joint_type - The joint type, can be `'DistanceJoint'`, `'FrictionJoint'`, `'GearJoint'`, `'MouseJoint'`, `'PrismaticJoint'`, `'PulleyJoint'`, `'RevoluteJoint'`, `'RopeJoint'`, `'WeldJoint'` or `'WheelJoint'`
-- @arg {*} ... - The joint creation arguments that are different for each joint type. Check [here](https://www.love2d.org/wiki/Joint) for more details
-- @returns {Joint}
function World:addJoint(joint_name, joint_type, ...)
    if self.joints[joint_name] then error("Joint " .. joint_name .. " already exists.") end
    local args = {...}
    local joint = love.physics['new' .. joint_type](unpack(args))
    self.joints[joint_name] = joint
    return joint
end

--- Removes a joint from the world 
-- @arg {string} joint_name - The unique name of the joint to be removed. Must be a name previously added with `addJoint`
function World:removeJoint(joint_name)
    
end

--- @class Collider 
-- @description A collider is a box2d physics object (body + shape + fixture) that has a collision class and that can generate collision events.
local Collider = {}
Collider.__index = Collider

function Collider.new(world, collider_type, ...)
    local self = {}
    self.world = world
    self.type = collider_type
    self.shapes = {}
    self.fixtures = {}
    self.sensors = {}

    local args = {...}
    local shape, fixture
    if self.type == 'Circle' then
        self.collision_class = (args[4] and args[4].collision_class) or 'Default'
        self.body = love.physics.newBody(self.world.box2d_world, args[1], args[2], (args[4] and args[4].body_type) or 'dynamic')
        self.body:setFixedRotation(true)
        shape = love.physics.newCircleShape(args[3])

    elseif self.type == 'Rectangle' then
        self.collision_class = (args[5] and args[5].collision_class) or 'Default'
        self.body = love.physics.newBody(self.world.box2d_world, args[1], args[2], (args[5] and args[5].body_type) or 'dynamic')
        self.body:setFixedRotation(true)
        shape = love.physics.newRectangleShape(args[3], args[4])

    elseif self.type == 'BSGRectangle' then
        self.collision_class = (args[6] and args[6].collision_class) or 'Default'
        self.body = love.physics.newBody(self.world.box2d_world, args[1], args[2], (args[6] and args[6].body_type) or 'dynamic')
        self.body:setFixedRotation(true)
        local w, h, s = args[3], args[4], args[5]
        shape = love.physics.newPolygonShape({
            -w/2, -h/2 + s, -w/2 + s, -h/2,
             w/2 - s, -h/2, w/2, -h/2 + s,
             w/2, h/2 - s, w/2 - s, h/2,
            -w/2 + s, h/2, -w/2, h/2 - s
        })

    elseif self.type == 'Polygon' then
        self.collision_class = (args[2] and args[2].collision_class) or 'Default'
        local cx, cy = self.hx.Math.polygon.getCentroid(args[1])
        self.body = love.physics.newBody(self.world.box2d_world, 0, 0, (args[2] and args[2].body_type) or 'dynamic')
        self.body:setFixedRotation(true)
        --[[
        for i = 1, #args[1], 2 do
            args[1][i] = args[1][i] - cx
            args[1][i+1] = args[1][i+1] - cy
        end
        ]]--
        shape = love.physics.newPolygonShape(unpack(args[1]))

    elseif self.type == 'Line' then
        self.collision_class = (args[5] and args[5].collision_class) or 'Default'
        local mx, my = self.hx.Math.line.getMidpoint(args[1], args[2], args[3], args[4])
        self.body = love.physics.newBody(self.world.box2d_world, 0, 0, (args[5] and args[5].body_type) or 'dynamic')
        self.body:setFixedRotation(true)
        shape = love.physics.newEdgeShape(args[1], args[2], args[3], args[4])

    elseif self.type == 'Chain' then
        self.collision_class = (args[3] and args[3].collision_class) or 'Default'
        self.body = love.physics.newBody(self.world.box2d_world, 0, 0, (args[3] and args[3].body_type) or 'dynamic')
        self.body:setFixedRotation(true)
        shape = love.physics.newChainShape(args[2], args[1])
    end

    -- Define collision classes and attach them to fixture and sensor
    fixture = love.physics.newFixture(self.body, shape)
    if self.world.masks[self.collision_class] then
        fixture:setCategory(unpack(self.world.masks[self.collision_class].categories))
        fixture:setMask(unpack(self.world.masks[self.collision_class].masks))
    end
    local sensor = love.physics.newFixture(self.body, shape)
    sensor:setSensor(true)

    self.shapes['main'] = shape
    self.fixtures['main'] = fixture
    self.sensors['main'] = sensor

    return setmetatable(self, Collider)
end

function Collider:update(dt)
    
end

function Collider:draw()
    for name, _ in pairs(self.shapes) do
        if self.shapes[name]:type() == 'PolygonShape' then
            love.graphics.setColor(r or 64, g or 128, b or 244)
            love.graphics.polygon('line', self.body:getWorldPoints(self.shapes[name]:getPoints()))
            love.graphics.setColor(255, 255, 255)

        elseif self.shapes[name]:type() == 'EdgeShape' or self.shapes[name]:type() == 'ChainShape' then
            love.graphics.setColor(r or 64, g or 128, b or 244)
            local points = {self.body:getWorldPoints(self.shapes[name]:getPoints())}
            for i = 1, #points, 2 do
                if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
            end
            love.graphics.setColor(255, 255, 255)

        elseif self.shapes[name]:type() == 'CircleShape' then
            love.graphics.setColor(r or 64, g or 128, b or 244)
            local x, y, r = self.body:getPosition(), self.shapes[name]:getRadius()
            love.graphics.circle('line', x, y, r, 360)
            love.graphics.setColor(255, 255, 255)
        end
    end
end

--- Changes this collider's collision class. The new collision class must be a valid one previously added with `addCollisionClass`
-- @luastart
-- @code physics_world:addCollisionClass('Player', {enter = {'LevelTransitionArea'}})
-- @code physics_world:addCollisionClass('PlayerNOCLIP', {ignores = {'Solid'}, enter = {'LevelTransitionArea'}})
-- @code physics_world:collisionClassesSet()
-- @code collider = physics_world:newRectangleCollider(100, 100, 12, 24, {collision_class = 'Player'})
-- @code collider:changeCollisionClass('PlayerNOCLIP')
-- @luaend
-- @arg {string} collision_class_name - The unique name of the new collision class
function Collider:changeCollisionClass(collision_class_name)

end

--- Checks for collision enter events from this collider with another
-- @luastart
-- @code if collider:enter('Enemy') then
-- @code   local _, enemy_collider = collider:enter('Enemy')
-- @code end
-- @luaend
-- @arg {string} other_collision_class_name - The unique name of the target collision class
-- @returns {boolean} If the enter collision event between both collision classes happened on this frame or not
-- @returns {Collider} The target Collider
-- @returns {Contact} The [Contact](https://www.love2d.org/wiki/Contact) object
function Collider:enter(other_collision_class_name)
    
end

--- Checks for collision exit events from this collider with another
-- @luastart
-- @code if collider:exit('Enemy') then
-- @code   local _, enemy_collider = collider:exit('Enemy')
-- @code end
-- @luaend
-- @arg {string} other_collision_class_name - The unique name of the target collision class
-- @returns {boolean} If the enter collision event between both collision classes happened on this frame or not
-- @returns {Collider} The target Collider
-- @returns {Contact} The [Contact](https://www.love2d.org/wiki/Contact) object
function Collider:exit(other_collision_class_name)

end

--- Checks for collision events that happen right before collision response is applied
-- @luastart
-- @code if collider:pre('Enemy') then
-- @code   local _, enemy_collider = collider:pre('Enemy')
-- @code end
-- @luaend
-- @arg {string} other_collision_class_name - The unique name of the target collision class
-- @returns {boolean} If the enter collision event between both collision classes happened on this frame or not
-- @returns {Collider} The target Collider
-- @returns {Contact} The [Contact](https://www.love2d.org/wiki/Contact) object
function Collider:pre(other_collision_class_name)
    
end

--- Checks for collision events that happen right after collision response is applied
-- @luastart
-- @code if collider:post('Enemy') then
-- @code   local _, enemy_collider, _, ni1, ti1, ni2, ti2 = collider:post('Enemy')
-- @code end
-- @luaend
-- @arg {string} other_collision_class_name - The unique name of the target collision class
-- @returns {boolean} If the enter collision event between both collision classes happened on this frame or not
-- @returns {Collider} The target Collider
-- @returns {Contact} The [Contact](https://www.love2d.org/wiki/Contact) object
-- @returns {number} The amount of impulse applied along the normal of the first point of collision
-- @returns {number} The amount of impulse applied along the tangent of the first point of collision
-- @returns {number} The amount of impulse applied along the normal of the second point of collision
-- @returns {number} The amount of impulse applied along the tangent of the second point of collision
function Collider:post(other_collision_class_name)
    
end

--- Adds a shape to the collider. A shape can be accessed via collider.shapes[shape_name]. A fixture of the same name is also added to attach the shape to the collider body. A fixture can be accessed via collider.fixtures[fixture_name]
-- @arg {string} shape_name - The unique name of the shape
-- @arg {string} shape_type - The shape type, can be `'ChainShape'`, `'CircleShape'`, `'EdgeShape'`, `'PolygonShape'` or `'RectangleShape'`
-- @arg {*} ... - The shape creation arguments that are different for each shape type. Check [here](https://www.love2d.org/wiki/Shape) for more details
function Collider:addShape(shape_name, shape_type, ...)
    if self.shapes[shape_name] or self.fixtures[shape_name] then error("Shape/fixture " .. shape_name .. " already exists.") end
    local args = {...}
    local shape = love.physics['new' .. shape_type](unpack(args))
    local fixture = love.physics.newFixture(self.body, shape)
    local sensor = love.physics.newFixture(self.body, shape)
    sensor:setSensor(true)

    self.shapes[shape_name] = shape
    self.fixtures[shape_name] = fixture
    self.sensors[shape_name] = sensor
end

--- Removes a shape from the collider (also removes the accompanying fixture)
-- @arg {string} shape_name - The unique name of the shape to be removed. Must be a name previously added with `addShape`
function Collider:removeShape(shape_name)
    if not self.shapes[shape_name] then return end
    self.shapes[shape_name] = nil
    self.fixtures[shape_name]:destroy()
    self.fixtures[shape_name] = nil
    self.sensors[shape_name]:destroy()
    self.sensors[shape_name] = nil
end

hx.World = World
hx.Collider = Collider

return hx
