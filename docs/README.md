hxdx
===

- [World](#world)
  - [newWorld](#newworldsettings)
  - [update](#updatedt)
  - [draw](#draw)
  - [addCollisionClass](#addcollisionclasscollision_class_name-collision_class)
  - [newCircleCollider](#newcirclecolliderx-y-r-settings)
  - [newRectangleCollider](#newrectanglecolliderx-y-w-h-settings)
  - [newBSGRectangleCollider](#newbsgrectanglecolliderx-y-w-h-corner_cut_size-settings)
  - [newPolygonCollider](#newpolygoncollidervertices-settings)
  - [newLineCollider](#newlinecolliderx1-y1-x2-y2-settings)
  - [newChainCollider](#newchaincollidervertices-loop-settings)
  - [queryCircleArea](#querycircleareax-y-r-collision_class_names)
  - [queryRectangleArea](#queryrectangleareax-y-w-h-collision_class_names)
  - [queryPolygonArea](#querypolygonareavertices-collision_class_names)
  - [queryLine](#querylinex1-y1-x2-y2-collision_class_names)
  - [addJoint](#addjointjoint_type-)
  - [removeJoint](#removejointjoint)
- [Collider](#collider)
  - [changeCollisionClass](#changecollisionclasscollision_class_name)
  - [enter](#enterother_collision_class_name)
  - [exit](#exitother_collision_class_name)
  - [setPreSolve](#setpresolvecallback)
  - [setPostSolve](#setpostsolvecallback)
  - [addShape](#addshapeshape_name-shape_type-)
  - [removeShape](#removeshapeshape_name)
  - [destroy](#destroy)

# World

A World contains the [box2d world](https://www.love2d.org/wiki/World) as well as state for handling collision classes, methods for changing box2d world settings as well as methods for the creation of Colliders and Effectors.

---

#### `.newWorld(settings)`

Creates a new World

```lua
physics_world = hx.newWorld({gravity_y = 20})
```
Arguments:

- `[settings]` `(table)` - Table with optional settings for the world:

Settings:

- `[gravity_x=0]` `(number)` - The world's x gravity component
- `[gravity_y=0]` `(number)` - The world's y gravity component
- `[allow_sleeping=true]` `(boolean)` - If the world's bodies are allowed to sleep
- `[explicit_collision_events=false]` `(boolean)` - If the collision classes added to this world will automatically generate collision events for all other collision classes they collide with or if this has to be specified manually
- `[draw_query_for_n_frames=60]` `(number)` - Number of frames a query is drawn for when debugging

Returns:

- `World` - 

---

#### `:update(dt)`

Updates the World

```lua
physics_world:update(dt)
```
Arguments:

- `dt` `(number)` - Time step delta

---

#### `:draw()`

Draws the World, drawing all colliders, joints and world queries (for debugging purposes)

```lua
physics_world:draw()
```
---

#### `:addCollisionClass(collision_class_name, collision_class)`

Adds a new collision class to the world. Collision classes are attached to colliders and define collider behavior in terms of which ones will be physically ignored and which ones will generate collision events between each other. All collision classes must be added before any collider is created. If `world.explicit_collision_events` is set to false (the default setting) then `enter`, `exit`, `pre` and `post` settings don't need to be specified (those events will be generated automatically for all existing collision classes).

```lua
physics_world:addCollisionClass('Player', {
                                ignores = {'NPC', 'Enemy'},
                                enter = {'LevelTransitionArea'},
                                exit = {'Projectile'}})
```
Arguments:

- `collision_class_name` `(string)` - The unique name of the collision class
- `collision_class` `(table)` - The collision class. This table can contain:

Settings:

- `[ignores]` `(table[string])` - The collision classes that will be physically ignored
- `[enter]` `(table[string])` - The collision classes that will generate collision events when they enter contact
- `[exit]` `(table[string])` - The collision classes that will generate collision events when they exit contact
- `[pre]` `(table[string])` - The collision classes that will generate collision events right before collision response is applied
- `[post]` `(table[string])` - The collision classes that will generate collision events right after collision response is applied

---

#### `:newCircleCollider(x, y, r, settings)`

Creates a new CircleCollider

```lua
collider = physics_world:newCircleCollider(100, 100, 30)
```
Arguments:

- `x` `(number)` - The initial x position of the circle (center)
- `y` `(number)` - The initial y position of the circle (center)
- `r` `(number)` - The radius of the circle
- `[settings]` `(table)` - A table with additional and optional settings. This table can contain:

Settings:

- `[body_type='dynamic']` `(BodyType)` - The body type, can be 'static', 'dynamic' or 'kinematic'
- `[collision_class]` `(string)` - The collision class of the circle, must be a valid collision class previously added with `addCollisionClass`

Returns:

- `Collider` - 

---

#### `:newRectangleCollider(x, y, w, h, settings)`

Creates a new RectangleCollider

```lua
collider = physics_world:newRectangleCollider(100, 100, 50, 50, {body_type = 'static', collision_class = 'Solid'})
```
Arguments:

- `x` `(number)` - The initial x position of the rectangle (left-top)
- `y` `(number)` - The initial y position of the rectangle (left-top)
- `w` `(number)` - The width of the rectangle
- `h` `(number)` - The height of the rectangle
- `[settings]` `(table)` - A table with additional and optional settings. This table can contain:

Settings:

- `[body_type='dynamic']` `(BodyType)` - The body type, can be 'static', 'dynamic' or 'kinematic'
- `[collision_class]` `(string)` - The collision class of the rectangle, must be a valid collision class previously added with `addCollisionClass`

Returns:

- `Collider` - 

---

#### `:newBSGRectangleCollider(x, y, w, h, corner_cut_size, settings)`

Creates a new BSGRectangleCollider (a rectangle with its corners cut (an octagon))

```lua
collider = physics_world:newBSGRectangleCollider(100, 100, 50, 50, 5)
```
Arguments:

- `x` `(number)` - The initial x position of the rectangle (left-top)
- `y` `(number)` - The initial y position of the rectangle (left-top)
- `w` `(number)` - The width of the rectangle
- `h` `(number)` - The height of the rectangle
- `corner_cut_size` `(number)` - The corner cut size
- `[settings]` `(table)` - A table with additional and optional settings. This table can contain:

Settings:

- `[body_type='dynamic']` `(BodyType)` - The body type, can be 'static', 'dynamic' or 'kinematic'
- `[collision_class]` `(string)` - The collision class of the rectangle, must be a valid collision class previously added with `addCollisionClass`

Returns:

- `Collider` - 

---

#### `:newPolygonCollider(vertices, settings)`

Creates a new PolygonCollider

```lua
collider = physics_world:newPolygonCollider({10, 10, 10, 20, 20, 20, 20, 10})
```
Arguments:

- `vertices` `(table[number])` - The polygon vertices as a table of numbers
- `[settings]` `(table)` - A table with additional and optional settings. This table can contain:

Settings:

- `[body_type='dynamic']` `(BodyType)` - The body type, can be 'static', 'dynamic' or 'kinematic'
- `[collision_class]` `(string)` - The collision class of the polygon, must be a valid collision class previously added with `addCollisionClass`

Returns:

- `Collider` - 

---

#### `:newLineCollider(x1, y1, x2, y2, settings)`

Creates a new LineCollider

```lua
collider = physics_world:newLineCollider(100, 100, 200, 200, {body_type = 'static'})
```
Arguments:

- `x1` `(number)` - The initial x position of the line
- `y1` `(number)` - The initial y position of the line
- `x2` `(number)` - The final x position of the line
- `y2` `(number)` - The final y position of the line
- `[settings]` `(table)` - A table with additional and optional settings. This table can contain:

Settings:

- `[body_type='dynamic']` `(BodyType)` - The body type, can be 'static', 'dynamic' or 'kinematic'
- `[collision_class]` `(string)` - The collision class of the line, must be a valid collision class previously added with `addCollisionClass`

Returns:

- `Collider` - 

---

#### `:newChainCollider(vertices, loop, settings)`

Creates a new ChainCollider

```lua
collider = physics_world:newChainCollider({10, 10, 10, 20, 20, 20}, true, {body_type = 'static', collision_class = 'Ground'})
```
Arguments:

- `vertices` `(table[number])` - The chain vertices as a table of numbers
- `loop` `(boolean)` - If the chain should loop back from the last to the first point
- `[settings]` `(table)` - A table with additional and optional settings. This table can contain:

Settings:

- `[body_type='dynamic']` `(BodyType)` - The body type, can be 'static', 'dynamic' or 'kinematic'
- `[collision_class]` `(string)` - The collision class of the chain, must be a valid collision class previously added with `addCollisionClass`

Returns:

- `Collider` - 

---

#### `:queryCircleArea(x, y, r, collision_class_names)`

Queries a circular area around a point for colliders

```lua
colliders_1 = physics_world:queryCircleArea(100, 100, 50, {'Enemy', 'NPC'})
colliders_2 = physics_world:queryCircleArea(100, 100, 50, {'All', except = {'Player'}})
```
Arguments:

- `x` `(number)` - The initial x position of the circle (center)
- `y` `(number)` - The initial y position of the circle (center)
- `r` `(number)` - The radius of the circle
- `[collision_class_names='All']` `(table[string])` - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision class names. Another special value (a table of collision class names) `except` can be used to exclude some collision class names when `'All'` is used.

Returns:

- `table[Collider]` - 

---

#### `:queryRectangleArea(x, y, w, h, collision_class_names)`

Queries a rectangular area around a point for colliders

```lua
-- In both examples x, y are the center of the rectangle, meaning the top-left points on both is 75, 75
colliders_1 = physics_world:queryRectangleArea(100, 100, 50, 50 {'Enemy', 'NPC'})
colliders_2 = physics_world:queryRectangleArea(100, 100, 50, 50, {'All', except = {'Player'}})
```
Arguments:

- `x` `(number)` - The initial x position of the rectangle (left-top)
- `y` `(number)` - The initial y position of the rectangle (left-top)
- `w` `(number)` - The width of the rectangle
- `h` `(number)` - The height of the rectangle
- `[collision_class_names='All']` `(table[string])` - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision class names. Another special value (a table of collision class names) `except` can be used to exclude some collision class names when `'All'` is used.

Returns:

- `table[Collider]` - 

---

#### `:queryPolygonArea(vertices, collision_class_names)`

Queries an arbitrary area for colliders

```lua
colliders = physics_world:queryPolygonArea({10, 10, 20, 10, 20, 20, 10, 20}, {'Enemy'})
colliders = physics_world:queryPolygonArea({10, 10, 20, 10, 20, 20, 10, 20}, {'All', except = {'Player'}})
```
Arguments:

- `vertices` `(table[number])` - The polygon vertices as a table of numbers
- `[collision_class_names='All']` `(table[string])` - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision class names. Another special value (a table of collision class names) `except` can be used to exclude some collision class names when `'All'` is used.

Returns:

- `table[Collider]` - 

---

#### `:queryLine(x1, y1, x2, y2, collision_class_names)`

Queries for colliders that intersect with a line

```lua
colliders = physics_world:queryLine(100, 100, 200, 200, {'Enemy', 'NPC', 'Projectile'})
colliders = physics_world:queryLine(100, 100, 200, 200, {'All', except = {'Player'}})
```
Arguments:

- `x1` `(number)` - The initial x position of the line
- `y1` `(number)` - The initial y position of the line
- `x2` `(number)` - The final x position of the line
- `y2` `(number)` - The final y position of the line
- `[collision_class_names='All']` `(table[string])` - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision class names. Another special value (a table of collision class names) `except` can be used to exclude some collision class names when `'All'` is used.

Returns:

- `table[Collider]` - 

---

#### `:addJoint(joint_type, ...)`

Adds a joint to the world.

Arguments:

- `joint_type` `(string)` - The joint type, can be `'DistanceJoint'`, `'FrictionJoint'`, `'GearJoint'`, `'MouseJoint'`, `'PrismaticJoint'`, `'PulleyJoint'`, `'RevoluteJoint'`, `'RopeJoint'`, `'WeldJoint'` or `'WheelJoint'`
- `...` `(*)` - The joint creation arguments that are different for each joint type. Check [here](https://www.love2d.org/wiki/Joint) for more details

Returns:

- `Joint` - 

---

#### `:removeJoint(joint)`

Removes a joint from the world

Arguments:

- `joint` `(Joint)` - The joint to be removed

# Collider

A collider is a box2d physics object (body + shape + fixture) that has a collision class and that can generate collision events.

---

#### `:changeCollisionClass(collision_class_name)`

Changes this collider's collision class. The new collision class must be a valid one previously added with `addCollisionClass`

```lua
physics_world:addCollisionClass('Player', {enter = {'LevelTransitionArea'}})
physics_world:addCollisionClass('PlayerNOCLIP', {ignores = {'Solid'}, enter = {'LevelTransitionArea'}})
physics_world:collisionClassesSet()
collider = physics_world:newRectangleCollider(100, 100, 12, 24, {collision_class = 'Player'})
collider:changeCollisionClass('PlayerNOCLIP')
```
Arguments:

- `collision_class_name` `(string)` - The unique name of the new collision class

---

#### `:enter(other_collision_class_name)`

Checks for collision enter events from this collider with another

```lua
if collider:enter('Enemy') then
  local _, enemy_collider = collider:enter('Enemy')
end
```
Arguments:

- `other_collision_class_name` `(string)` - The unique name of the target collision class

Returns:

- `boolean` - If the enter collision event between both collision classes happened on this frame or not
- `Collider` - The target Collider
- `Contact` - The [Contact](https://www.love2d.org/wiki/Contact) object

---

#### `:exit(other_collision_class_name)`

Checks for collision exit events from this collider with another

```lua
if collider:exit('Enemy') then
  local _, enemy_collider = collider:exit('Enemy')
end
```
Arguments:

- `other_collision_class_name` `(string)` - The unique name of the target collision class

Returns:

- `boolean` - If the enter collision event between both collision classes happened on this frame or not
- `Collider` - The target Collider
- `Contact` - The [Contact](https://www.love2d.org/wiki/Contact) object

---

#### `:setPreSolve(callback)`

Sets the preSolve callback. Unlike with `:enter` or `:exit` that can be delayed and checked after the physics simulation is done for this frame,  both preSolve and postSolve must be callbacks that are resolved immediately, since they may change how the rest of the simulation plays out on this frame.

```lua
collider:setPreSolve(function(collider, contact)
  contact:setEnabled(false)
end
```
Arguments:

- `callback` `(function)` - The preSolve callback. Receives `collider_1`, `collider_2`, `contact` as arguments

---

#### `:setPostSolve(callback)`

Sets the postSolve callback. Unlike with `:enter` or `:exit` that can be delayed and checked after the physics simulation is done for this frame,  both preSolve and postSolve must be callbacks that are resolved immediately, since they may change how the rest of the simulation plays out on this frame.

```lua
if collider:post('Enemy') then
  local _, enemy_collider, _, ni1, ti1, ni2, ti2 = collider:post('Enemy')
end
```
Arguments:

- `callback` `(function)` - The postSolve callback. Receives `collider_1`, `collider_2`, `contact`, `normal_impulse1`, `tangent_impulse1`, `normal_impulse2`, `tangent_impulse2` as arguments

---

#### `:addShape(shape_name, shape_type, ...)`

Adds a shape to the collider. A shape can be accessed via collider.shapes[shape_name]. A fixture of the same name is also added to attach the shape to the collider body. A fixture can be accessed via collider.fixtures[fixture_name]

Arguments:

- `shape_name` `(string)` - The unique name of the shape
- `shape_type` `(string)` - The shape type, can be `'ChainShape'`, `'CircleShape'`, `'EdgeShape'`, `'PolygonShape'` or `'RectangleShape'`
- `...` `(*)` - The shape creation arguments that are different for each shape type. Check [here](https://www.love2d.org/wiki/Shape) for more details

---

#### `:removeShape(shape_name)`

Removes a shape from the collider (also removes the accompanying fixture)

Arguments:

- `shape_name` `(string)` - The unique name of the shape to be removed. Must be a name previously added with `addShape`

---

#### `:destroy()`

Destroys the collider and removes it from the world

