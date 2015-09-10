local path = ... .. '.'
local hx = {}
hx.Math = require(path .. 'mlib.mlib')

--- @class World
-- @description A World contains the [box2d world](https://www.love2d.org/wiki/World) as well as state for handling collision classes, methods for changing box2d world settings as well as methods for the creation of Colliders and Effectors.
local World = {}
World.__index = World

--- Creates a new World
-- @luastart 
-- @code physics_world = hx.newWorld()
-- @luaend
-- @arg {table=} settings - Table with optional settings for the world
-- @returns {World}
function hx.newWorld(settings)
    return hx.World.new(hx, settings)
end

function World.new(hx, settings)
    local self = {}
    self.hx = hx
    return setmetatable(self, World)
end

--- Updates the World
-- @luastart
-- @code physics_world:update(dt)
-- @luaend
-- @arg {number} dt - Time step delta
function World:update(dt)

end

--- Draws the World (for debugging purposes)
-- @luastart
-- @code physics_world:draw()
-- @luaend
function World:draw()

end

--- Creates a new collision class. Collision classes are attached to colliders and define collider behavior in tertms of which ones will be physically ignored and which ones will generate collision events between each other. All collision classes must be added **before** any collider is created. After all collision classes are added `collisionClassesSet` must be called once.
-- @luastart
-- @code physics_world:addCollisionClass('Player', {
-- @code                                 ignores = {'NPC', 'Enemy'}, 
-- @code                                 enter = {'LevelTransitionArea'}, 
-- @code                                 exit = {'Projectile'}})
-- @luaend
-- @arg {string} collision_class_name - The unique name of the collision class
-- @arg {table} collision_class - The collision class. This table can contain:
-- @setting {table[string]=} ignores - A table of strings containing other collision class names that this collision class will physically ignore (they will go through each other). In the example above, colliders of collision class `'Player'` will ignore colliders of collision class `'NPC'` and `'Enemy'`.
-- @setting {table[string]=} enter - A table of strings containing other collision class names that will generate collision events when they enter contact with this collision class. In the example above, colliders of collision class `'Player'` will generate collision events on the frame they enter contact with colliders of collision class `'LevelTransitionArea'`. 
-- @setting {table[string]=} exit - A table of strings containing other collision class names that will generate collision events when they leave contact with this collision class. In the example above, colliders of collision class `'Player'` will generate collision events on the frame they exit contact with colliders of collision class `'Projectile'`.
-- @setting {table[string]=} pre - A table of strings containing other collision class names that will generate collision events right before they enter contact with this collision class. 
-- @setting {table[string]=} post - A table of strings containing other collision class names that will generate collision events right after they exit contact with this collision class.
function World:addCollisionClass(collision_class_name, collision_class)
    
end

--- Sets all collision classes. This function must be called once after all collision classes have been added and before any collider is created.
function World:collisionClassesSet()
    
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
-- @setting {string=} collision_class - The collision class of the circle, must be a valid collision class previously added with `addColliisonClass`
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
-- @setting {string=} collision_class - The collision class of the rectangle, must be a valid collision class previously added with `addColliisonClass`
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
-- @setting {string=} collision_class - The collision class of the rectangle, must be a valid collision class previously added with `addColliisonClass`
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
-- @setting {string=} collision_class - The collision class of the polygon, must be a valid collision class previously added with `addColliisonClass`
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
-- @setting {string=} collision_class - The collision class of the line, must be a valid collision class previously added with `addColliisonClass`
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
-- @setting {string=} collision_class - The collision class of the chain, must be a valid collision class previously added with `addColliisonClass`
-- @returns {Collider}
function World:newChainCollider(vertices, loop, settings)
    return self.hx.Collider.new(self, 'Chain', vertices, loop, settings)
end

--- @class Collider 
-- @description A collider is a box2d physics object (body + shape + fixture) that has a collision class and that can generate collision events.
local Collider = {}
Collider.__index = Collider

function Collider.new(physics_world, collider_type, ...)
    local self = {}
    self.physics_world = physics_world
    self.type = collider_type

    local args = {...}
    if self.type == 'Circle' then

    elseif self.type == 'Rectangle' then

    elseif self.type == 'BSGRectangle' then

    elseif self.type == 'Polygon' then

    elseif self.type == 'Line' then

    elseif self.type == 'Chain' then

    end

    return setmetatable(self, Collider)
end

hx.World = World
hx.Collider = Collider

return hx
