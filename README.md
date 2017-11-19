**windfield** is a physics module for LÖVE. It wraps LÖVE's physics API so that using box2d becomes as simple as possible.

# Contents

* [Quick Start](#quick-start)
   * [Create a world](#create-a-world)
   * [Create colliders](#create-colliders)
   * [Create joints](#create-joints)
   * [Create collision classes](#create-collision-classes)
   * [Capture collision events](#capture-collision-events)
   * [Query the world](#query-the-world)
* [Examples & Tips](#examples-tips)
   * [Checking collisions between game objects](#checking-collisions-between-game-objects)
   * [One-way Platforms](#one-way-platforms)
* [Documentation](#documentation)
   * [World](#world)
      * [newWorld](#newworldxg-yg-sleep)
      * [update](#updatedt)
      * [draw](#drawalpha)
      * [destroy](#destroy)
      * [addCollisionClass](#addcollisionclasscollision_class_name-collision_class)
      * [newCircleCollider](#newcirclecolliderx-y-r)
      * [newRectangleCollider](#newrectanglecolliderx-y-w-h)
      * [newBSGRectangleCollider](#newbsgrectanglecolliderx-y-w-h-corner_cut_size)
      * [newPolygonCollider](#newpolygoncollidervertices)
      * [newLineCollider](#newlinecolliderx1-y1-x2-y2)
      * [newChainCollider](#newchaincollidervertices-loop)
      * [queryCircleArea](#querycircleareax-y-r-collision_class_name)
      * [queryRectangleArea](#queryrectangleareax-y-w-h-collision_class_names)
      * [queryPolygonArea](#querypolygonareavertices-collision_class_names)
      * [queryLine](#querylinex1-y1-x2-y2-collision_class_names)
      * [addJoint](#addjointjoint_type)
      * [removeJoint](#removejointjoint)
      * [setExplicitCollisionEvents](#setexplicitcollisioneventsvalue)
      * [setQueryDebugDrawing](#setquerydebugdrawingvalue)
   * [Collider](#collider)
      * [destroy](#destroy-1)
      * [setCollisionClass](#setcollisionclasscollision_class_name)
      * [enter](#enterother_collision_class_name)
      * [getEnterCollisionData](#getentercollisiondataother_collision_class_name)
      * [exit](#exitother_collision_class_name)
      * [getExitCollisionData](#getexitcollisiondataother_collision_class_name)
      * [stay](#stayother_collision_class_name)
      * [getStayCollisionData](#getstaycollisiondataother_collision_class_name)
      * [setPreSolve](#setpresolvecallback)
      * [setPostSolve](#setpostsolvecallback)
      * [addShape](#addshapeshape_name-shape_type)
      * [removeShape](#removeshapeshape_name)
      * [setObject](#setobjectobject)
      * [getObject](#getobject)
      
<br>

# Quick Start

Place the `windfield` folder inside your project and require it:

```lua
wf = require 'windfield'
```

<br>

## Create a world

A physics world can be created just like in box2d. The world returned by `wf.newWorld` contains all the functions of a [LÖVE physics World](https://love2d.org/wiki/World) as well as additional ones defined by this library.

```lua
function love.load()
    world = wf.newWorld(0, 0, true)
    world:setGravity(0, 512)
end

function love.update(dt)
    world:update(dt)
end
```

<br>

## Create colliders

A collider is a composition of a single body, fixture and shape. For most use cases whenever box2d is needed a body will only have one fixture/shape attached to it, so it makes sense to work primarily on that level of abstraction. Colliders contain all the functions of a LÖVE physics [Body](https://love2d.org/wiki/Body), [Fixture](https://love2d.org/wiki/Fixture) and [Shape](https://love2d.org/wiki/Shape) as well as additional ones defined by this library:

```lua
function love.load()
    ...

    box = world:newRectangleCollider(400 - 50/2, 0, 50, 50)
    box:setRestitution(0.8)
    box:applyAngularImpulse(5000)

    ground = world:newRectangleCollider(0, 550, 800, 50)
    wall_left = world:newRectangleCollider(0, 0, 50, 600)
    wall_right = world:newRectangleCollider(750, 0, 50, 600)
    ground:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
    wall_left:setType('static')
    wall_right:setType('static')
end

...

function love.draw()
    world:draw() -- The world can be drawn for debugging purposes
end
```

And that looks like this:

<p align="center">
  <img src="http://i.imgur.com/ytfhmjc.gif"/>
</p>

<br>

## Create joints

Joints are mostly unchanged from how they work normally in box2d:

```lua
function love.load()
    ...

    box_1 = world:newRectangleCollider(400 - 50/2, 0, 50, 50)
    box_1:setRestitution(0.8)
    box_2 = world:newRectangleCollider(400 - 50/2, 50, 50, 50)
    box_2:setRestitution(0.8)
    box_2:applyAngularImpulse(5000)
    joint = world:addJoint('RevoluteJoint', box_1, box_2, 400, 50, true)

    ...
end
```

And that looks like this:

<p align="center">
  <img src="http://i.imgur.com/tSqkxJR.gif"/>
</p>

<br>

## Create collision classes

Collision classes are used to make colliders ignore other colliders of certain classes and to capture collision events between colliders. The same concept goes by the name of 'collision layer' or 'collision tag' in other engines. In the example below we add a Solid and Ghost collision class. The Ghost collision class is set to ignore the Solid collision class.

```lua
function love.load()
    ...

    world:addCollisionClass('Solid')
    world:addCollisionClass('Ghost', {ignores = {'Solid'}})

    box_1 = world:newRectangleCollider(400 - 100, 0, 50, 50)
    box_1:setRestitution(0.8)
    box_2 = world:newRectangleCollider(400 + 50, 0, 50, 50)
    box_2:setCollisionClass('Ghost')

    ground = world:newRectangleCollider(0, 550, 800, 50)
    ground:setType('static')
    ground:setCollisionClass('Solid')

    ...
end
```

And that looks like this:

<p align="center">
  <img src="http://i.imgur.com/j7IhVSe.gif"/>
</p>

The box that was set be of the Ghost collision class ignored the ground and went right through it, since the ground is set to be of the Solid collision class.

<br>

## Capture collision events

Collision events can be captured inside the update function by calling the `enter`, `exit` or `stay` functions of a collider. In the example below, whenever the box collider enters contact with another collider of the Solid collision class it will get pushed to the right:

```lua
function love.update(dt)
    ...
    if box:enter('Solid') then
        box:applyLinearImpulse(1000, 0)
        box:applyAngularImpulse(5000)
    end
end
```

And that looks like this:

<p align="center">
  <img src="http://i.imgur.com/uF1bqKM.gif"/>
</p>

<br>

## Query the world

The world can be queried with a few area functions and then all colliders inside that area will be returned. In the example below, the world is queried at position 400, 300 with a circle of radius 100, and then all colliders in that area are pushed to the right and down.

```lua
function love.load()
    world = wf.newWorld(0, 0, true)
    world:setQueryDebugDrawing(true) -- Draws the area of a query for 10 frames

    colliders = {}
    for i = 1, 200 do
        table.insert(colliders, world:newRectangleCollider(love.math.random(0, 800), love.math.random(0, 600), 25, 25))
    end
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    world:draw()
end

function love.keypressed(key)
    if key == 'p' then
        local colliders = world:queryCircleArea(400, 300, 100)
        for _, collider in ipairs(colliders) do
            collider:applyLinearImpulse(1000, 1000)
        end
    end
end
```

And that looks like this:

<p align="center">
  <img src="http://i.imgur.com/YVxAiuu.gif"/>
</p>

<br>

# Examples & Tips

## Checking collisions between game objects

The most common use case for a physics engine is doing things when things collide. For instance, when the Player collides with an enemy you might want to deal damage to the player. Here's the way to achieve that with this library:


```lua
-- in Player.lua
function Player:new()
  self.collider = world:newRectangleCollider(...)
  self.collider:setCollisionClass('Player')
  self.collider:setObject(self)
end

-- in Enemy.lua
function Enemy:new()
  self.collider = world:newRectangleCollider(...)
  self.collider:setCollisionClass('Enemy')
  self.collider:setObject(self)
end
```

First we define in the constructor of both classes the collider that should be attached to them. We set their collision classes (Player and Enemy) and then link the object to the colliders with `setObject`. With this, we can capture collision events between both and then do whatever we wish when a collision happens:

```lua
-- in Player.lua
function Player:update(dt)
  if self.collider:enter('Enemy') then
    local collision_data = self.collider:getEnterCollisionData('Enemy')
    local enemy = collision_data.collider:getObject()
    -- Kills the enemy on hit but also take damage
    enemy:die()
    self:takeDamage(10)
  end
end
```

<br>

## One-way Platforms

A common problem people have with using 2D physics engines seems to be getting one-way platforms to work. Here's one way to achieve this with this library:

```lua
function love.load()
  world = wf.newWorld(0, 512, true)
  world:addCollisionClass('Platform')
  world:addCollisionClass('Player')
  
  ground = world:newRectangleCollider(100, 500, 600, 50)
  ground:setType('static')
  platform = world:newRectangleCollider(350, 400, 100, 20)
  platform:setType('static')
  platform:setCollisionClass('Platform')
  player = world:newRectangleCollider(390, 450, 20, 40)
  player:setCollisionClass('Player')
  
  player:setPreSolve(function(collider_1, collider_2, contact)        
    if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
      local px, py = collider_1:getPosition()            
      local pw, ph = 20, 40            
      local tx, ty = collider_2:getPosition() 
      local tw, th = 100, 20
      if py + ph/2 > ty - th/2 then contact:setEnabled(false) end
    end   
  end)
end

function love.keypressed(key)
  if key == 'space' then
    player:applyLinearImpulse(0, -1000)
  end
end
```

And that looks like this:

<p align="center">
  <img src="http://i.imgur.com/ouwxVRH.gif"/>
</p>

The way this works is that by disabling the contact before collision response is applied (so in the preSolve callback) we can make a collider ignore another. And then all we do is check to see if the player is below platform, and if he is then we disable the contact.

<br>

# Documentation

## World

On top of containing all functions exposed in this documentation it also contains all functions of a [box2d World](https://love2d.org/wiki/World).

---

#### `.newWorld(xg, yg, sleep)`

Creates a new World.

```lua
world = wf.newWorld(0, 0, true)
```

Arguments:

* `xg` `(number)` - The world's x gravity component
* `yg` `(number)` - The world's y gravity component
* `sleep=true` `(boolean)` - If the world's bodies are allowed to sleep or not

Returns:

* `World` `(table)` - the World object, containing all attributes and methods defined below as well as all of a [box2d World](https://love2d.org/wiki/World)


---

#### `:update(dt)`

Updates the world.

```lua
world:update(dt)
```

Arguments:

* `dt` `(number)` - The time step delta

---

#### `:draw(alpha)`

Draws the world, drawing all colliders, joints and world queries (for debugging purposes).

```lua
world:draw() -- default drawing
world:draw(128) -- semi transparent drawing
```

Arguments:

* `alpha=255` `(number)` - The optional alpha value to use when drawing, defaults to 255

---

#### `:destroy()`

Destroys the world and removes all bodies, fixtures, shapes and joints from it. This must be called whenever the World is to discarded otherwise it will result in it not getting collected (and so memory will leak).

```lua
world:destroy()
```

---

#### `:addCollisionClass(collision_class_name, collision_class)`

Adds a new collision class to the World. Collision classes are attached to Colliders and defined their behaviors in terms of which ones will physically ignore each other and which ones will generate collision events between each other. All collision classes must be added before any Collider is created. If `world:setExplicitCollisionEvents` is set to false (the default setting) then `enter`, `exit`, `pre` and `post` settings don't need to be specified, otherwise they do.
```lua
world:addCollisionClass('Player', {ignores = {'NPC', 'Enemy'}})
```

Arguments:

* `collision_class_name` `(string)` - The unique name of the collision class
* `collision_class` `(table)` - The collision class. This table can contain:

Settings:

* `[ignores]` `(table[string])` - The collision classes that will be physically ignored
* `[enter]` `(table[string])` - The collision classes that will generate collision events with the collider of this collision class when they enter contact with each other
* `[exit]` `(table[string])` - The collision classes that will generate collision events with the collider of this collision class when they exit contact with each other
* `[pre]` `(table[string])` - The collision classes that will generate collision events with the collider of this collision class right before collision response is applied
* `[post]` `(table[string])` - The collision classes that will generate collision events with the collider of this collision class right after collision response is applied

---

#### `:newCircleCollider(x, y, r)`

Creates a new CircleCollider.

```lua
circle = world:newCircleCollider(100, 100, 30)
```

Arguments:

* `x` `(number)` - The x position of the circle's center
* `y` `(number)` - The y position of the circle's center
* `r` `(number)` - The radius of the circle

Returns:

* `Collider` `(table)` - The newly created CircleCollider

---

#### `:newRectangleCollider(x, y, w, h)`

Creates a new RectangleCollider.

```lua
rectangle = world:newRectangleCollider(100, 100, 50, 50)
```

Arguments:

* `x` `(number)` - The x position of the rectangle's top-left corner
* `y` `(number)` - The y position of the rectangle's top-left corner
* `w` `(number)` - The width of the rectangle
* `h` `(number)` - The height of the rectangle

Returns:

* `Collider` `(table)` - The newly created RectangleCollider

---

#### `:newBSGRectangleCollider(x, y, w, h, corner_cut_size)`

Creates a new BSGRectangleCollider, which is a rectangle with its corners cut (an octagon).

```lua
bsg_rectangle = world:newBSGRectangleCollider(100, 100, 50, 50, 5)
```

Arguments:

* `x` `(number)` - The x position of the rectangle's top-left corner
* `y` `(number)` - The y position of the rectangle's top-left corner
* `w` `(number)` - The width of the rectangle
* `h` `(number)` - The height of the rectangle
* `corner_cut_size` `(number)` - The corner cut size

Returns:

* `Collider` `(table)` - The newly created BSGRectangleCollider

---

#### `:newPolygonCollider(vertices)`

Creates a new PolygonCollider.

```lua
polygon = world:newPolygonCollider({10, 10, 10, 20, 20, 20, 20, 10})
```

Arguments:

* `vertices` `(table[number])` - The polygon vertices as a table of numbers

Returns:

* `Collider` `(table)` - The newly created PolygonCollider

---

#### `:newLineCollider(x1, y1, x2, y2)`

Creates a new LineCollider.

```lua
line = world:newLineCollider(100, 100, 200, 200)
```

Arguments:

* `x1` `(number)` - The x position of the first point of the line
* `y1` `(number)` - The y position of the first point of the line
* `x2` `(number)` - The x position of the second point of the line
* `y2` `(number)` - The y position of the second point of the line

Returns:

* `Collider` `(table)` - The newly created LineCollider

---

#### `:newChainCollider(vertices, loop)`

Creates a new ChainCollider.

```lua
chain = world:newChainCollider({10, 10, 10, 20, 20, 20}, true)
```

Arguments:

* `vertices` `(table[number])` - The chain vertices as a table of numbers
* `loop` `(boolean)` - If the chain should loop back from the last to the first point

Returns:

* `Collider` `(table)` - The newly created ChainCollider

---

#### `:queryCircleArea(x, y, r, collision_class_names)`

Queries a circular area around a point for colliders.

```lua
colliders_1 = world:queryCircleArea(100, 100, 50, {'Enemy', 'NPC'})
colliders_2 = world:queryCircleArea(100, 100, 50, {'All', except = {'Player'}})
```

Arguments:

* `x` `(number)` - The x position of the circle's center
* `y` `(number)` - The y position of the circle's center
* `r` `(number)` - The radius of the circle
* `[collision_class_names='All']` `(table[string])` - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision classes. Another special value `except` can be used to exclude some collision classes when `'All'` is used.

Returns:

* `table[Collider]` - The table of colliders with the specified collision classes inside the area

---

#### `:queryRectangleArea(x, y, w, h, collision_class_names)`

Queries a rectangular area for colliders.

```lua
colliders_1 = world:queryRectangleArea(100, 100, 50, 50, {'Enemy', 'NPC'})
colliders_2 = world:queryRectangleArea(100, 100, 50, 50, {'All', except = {'Player'}})
```

Arguments:

* `x` `(number)` - The x position of the rectangle's top-left corner
* `y` `(number)` - The y position of the rectangle's top-left corner
* `w` `(number)` - The width of the rectangle
* `h` `(number)` - The height of the rectangle
* `[collision_class_names='All']` `(table[string])` - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision classes. Another special value `except` can be used to exclude some collision classes when `'All'` is used.

Returns:

* `table[Collider]` - The table of colliders with the specified collision classes inside the area

---

#### `:queryPolygonArea(vertices, collision_class_names)`

Queries a polygon area for colliders.

```lua
colliders_1 = world:queryPolygonArea({10, 10, 20, 10, 20, 20, 10, 20}, {'Enemy'})
colliders_2 = world:queryPolygonArea({10, 10, 20, 10, 20, 20, 10, 20}, {'All', except = {'Player'}})
```

Arguments:

* `vertices` `(table[number])` - The polygon vertices as a table of numbers
* `[collision_class_names='All']` `(table[string])` - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision classes. Another special value `except` can be used to exclude some collision classes when `'All'` is used.

Returns:

* `table[Collider]` - The table of colliders with the specified collision classes inside the area

---

#### `:queryLine(x1, y1, x2, y2, collision_class_names)`

Queries for colliders that intersect with a line.

```lua
colliders_1 = world:queryLine(100, 100, 200, 200, {'Enemy', 'NPC', 'Projectile'})
colliders_2 = world:queryLine(100, 100, 200, 200, {'All', except = {'Player'}})
```

Arguments:

* `x1` `(number)` - The x position of the first point of the line
* `y1` `(number)` - The y position of the first point of the line
* `x2` `(number)` - The x position of the second point of the line
* `y2` `(number)` - The y position of the second point of the line
* `[collision_class_names='All']` `(table[string])` - A table of strings with collision class names to be queried. The special value `'All'` (default) can be used to query for all existing collision classes. Another special value `except` can be used to exclude some collision classes when `'All'` is used.

Returns:

* `table[Collider]` - The table of colliders with the specified collision classes inside the area

---

#### `:addJoint(joint_type, ...)`

Adds a joint to the world.

```lua
joint = world:addJoint('RevoluteJoint', collider_1, collider_2, 50, 50, true)
```

Arguments:

* `joint_type` `(string)` - The joint type, it can be `'DistanceJoint'`, `'FrictionJoint'`, `'GearJoint'`, `'MouseJoint'`, `'PrismaticJoint'`, `'PulleyJoint'`, `'RevoluteJoint'`, `'RopeJoint'`, `'WeldJoint'` or `'WheelJoint'`
* `...` `(*)` - The joint creation arguments that are different for each joint type, check [here](https://love2d.org/wiki/Joint) for more details

Returns:

* `joint` `(Joint)` - The newly created Joint

---

#### `:removeJoint(joint)`

Removes a joint from the world.

```lua
joint = world:addJoint('RevoluteJoint', collider_1, collider_2, 50, 50, true)
world:removeJoint(joint)
```

Arguments:

* `joint` `(Joint)` - The joint to be removed

---

#### `:setExplicitCollisionEvents(value)`

Sets collision events to be explicit or not. If explicit, then collision events will only be generated between collision classes when they are specified in `addCollisionClasses`. By default this is set to false, meaning that collision events are generated between all collision classes. The main reason why you might want to set this to true is for performance, since not generating collision events between every collision class will require less computation. This function must be called before any collision class is added to the world.

```lua
world:setExplicitCollisionEvents(true)
```

Arguments:

* `value` `(boolean)` - If collision events are explicit or not

---

#### `:setQueryDebugDrawing(value)`

Sets query debug drawing to be active or not. If active, then collider queries will be drawn to the screen for 10 frames. This is used for debugging purposes and incurs a performance penalty. Don't forget to turn it off!

```lua
world:setQueryDebugDrawing(true)
```

Arguments:

* `value` `(boolean)` - If query debug drawing is active or not

---

## Collider

On top of containing all functions exposed in this documentation it also contains all functions of a [Body](https://love2d.org/wiki/Body), [Fixture](https://love2d.org/wiki/Fixture) and [Shape](https://love2d.org/wiki/Shape).

---

#### `:destroy()`

Destroys the collider and removes it from the world. This must be called whenever the Collider is to discarded otherwise it will result in it not getting collected (and so memory will leak).

```lua
collider:destroy()
```

---

#### `:setCollisionClass(collision_class_name)`

Sets this collider's collision class. The collision class must be a valid one previously added with `world:addCollisionClass`.

```lua
world:addCollisionClass('Player')
collider = world:newRectangleCollider(100, 100, 50, 50)
collider:setCollisionClass('Player')
```

Arguments:

* `collision_class_name` `(string)` - The name of the collision class

---

#### `:enter(other_collision_class_name)`

Checks for collision enter events from this collider with another. Enter events are generated on the frame when one collider enters contact with another.

```lua
-- in some update function
if collider:enter('Enemy') then
    print('Collision entered!')
end
```

Arguments:

* `other_collision_class_name` `(string)` - The name of the target collision class

Returns:

* `boolean` - If the enter collision event between both colliders happened on this frame or not

---

#### `:getEnterCollisionData(other_collision_class_name)`

Gets the collision data generated from the last collision enter event

```lua
-- in some update function
if collider:enter('Enemy') then
    local collision_data = collider:getEnterCollisionData('Enemy')
    print(collision_data.collider, collision_data.contact)
end
```

Arguments:

* `other_collision_class_name` `(string)` - The name of the target collision class

Returns:

* `collision_data` `(table[Collider, Contact])` - A table containing the Collider and the [Contact](https://love2d.org/wiki/Contact) generated from the last enter collision event

---

#### `:exit(other_collision_class_name)`

Checks for collision exit events from this collider with another. Exit events are generated on the frame when one collider exits contact with another.

```lua
-- in some update function
if collider:exit('Enemy') then
    print('Collision exited!')
end
```

Arguments:

* `other_collision_class_name` `(string)` - The name of the target collision class

Returns:

* `boolean` - If the exit collision event between both colliders happened on this frame or not

---

#### `:getExitCollisionData(other_collision_class_name)`

Gets the collision data generated from the last collision exit event

```lua
-- in some update function
if collider:exit('Enemy') then
    local collision_data = collider:getEnterCollisionData('Enemy')
    print(collision_data.collider, collision_data.contact)
end
```

Arguments:

* `other_collision_class_name` `(string)` - The name of the target collision class

Returns:

* `collision_data` `(table[Collider, Contact])` - A table containing the Collider and the [Contact](https://love2d.org/wiki/Contact) generated from the last exit collision event

---

#### `:stay(other_collision_class_name)`

Checks for collision stay events from this collider with another. Stay events are generated on every frame when one collider is in contact with another.

```lua
-- in some update function
if collider:stay('Enemy') then
    print('Collision staying!')
end
```

Arguments:

* `other_collision_class_name` `(string)` - The name of the target collision class

Returns:

* `boolean` - If the stay collision event between both colliders is happening on this frame or not

---

#### `:getStayCollisionData(other_collision_class_name)`

Gets the collision data generated from the last collision stay event

```lua
-- in some update function
if collider:stay('Enemy') then
    local collision_data_list = collider:getStayCollisionData('Enemy')
    for _, collision_data in ipairs(collision_data_list) do
        print(collision_data.collider, collision_data.contact)
    end
end
```

Arguments:

* `other_collision_class_name` `(string)` - The name of the target collision class

Returns:

* `collision_data_list` `(table[table[Collider, Contact]])` - A table containing multiple Colliders and [Contacts](https://love2d.org/wiki/Contact) generated from the last stay collision event. Usually this list will be of size 1, but sometimes this collider will be staying in contact with multiple other colliders on the same frame, and so those multiple stay events (with multiple colliders) are returned.

---

#### `:setPreSolve(callback)`

Sets the preSolve callback. Unlike with `:enter` or `:exit` that can be delayed and checked after the physics simulation is done for this frame, both preSolve and postSolve must be callbacks that are resolved immediately, since they may change how the rest of the simulation plays out on this frame.

```lua
collider:setPreSolve(function(collider_1, collider_2, contact)
    contact:setEnabled(false)
end
```

Arguments:

* `callback` `(function)` - The preSolve callback. Receives `collider_1`, `collider_2` and `contact` as arguments

---

#### `:setPostSolve(callback)`

Sets the postSolve callback. Unlike with `:enter` or `:exit` that can be delayed and checked after the physics simulation is done for this frame, both preSolve and postSolve must be callbacks that are resolved immediately, since they may change how the rest of the simulation plays out on this frame.

```lua
collider:setPostSolve(function(collider_1, collider_2, contact, ni1, ti1, ni2, ti2)
    contact:setEnabled(false)
end
```

Arguments:

* `callback` `(function)` - The postSolve callback. Receives `collider_1`, `collider_2`, `contact`, `normal_impulse1`, `tangent_impulse1`, `normal_impulse2` and `tangent_impulse2` as arguments

---

#### `:addShape(shape_name, shape_type, ...)`

Adds a shape to the collider. A shape can be accessed via collider.shapes[shape_name]. A fixture of the same name is also added to attach the shape to the collider body. A fixture can be accessed via collider.fixtures[fixture_name].

Arguments:

* `shape_name` `(string)` - The unique name of the shape
* `shape_type` `(string)` - The shape type, can be `'ChainShape'`, `'CircleShape'`, `'EdgeShape'`, `'PolygonShape'` or `'RectangleShape'`
* `...` `(*)` - The shape creation arguments that are different for each shape. Check [here](https://love2d.org/wiki/Shape) for more details

---

#### `:removeShape(shape_name)`

Removes a shape from the collider (also removes the accompanying fixture).

Arguments:

* `shape_name` `(string)` - The unique name of the shape to be removed. Must be a name previously added with `:addShape`

---

#### `:setObject(object)`

Sets the collider's object. This is useful to set to the object the collider belongs to, so that when a query call is made and colliders are returned you can immediately get the pertinent object.

```lua
-- in the constructor of some object
self.collider = world:newRectangleCollider(...)
self.collider:setObject(self)
```

Arguments:

* `object` `(*)` - The object that this collider belongs to

---

#### `:getObject()`

Gets the object a collider belongs to.

```lua
-- in an update function
if self.collider:enter('Enemy') then
    local collision_data = self.collider:getEnterCollisionData('SomeTag')
    -- gets the reference to the enemy object, the enemy object must have used :setObject(self) to attach itself to the collider otherwise this wouldn't work
    local enemy = collision_data.collider:getObject()
end
```

Returns:

* `object` `(*)` - The object that is attached to this collider

---

# LICENSE

You can do whatever you want with this. See the license at the top of the main file.
