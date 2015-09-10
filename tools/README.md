hxdx
===

- [World](#world)
  - [newWorld](#newworldsettings)
  - [update](#updatedt)
  - [draw](#draw)
  - [addCollisionClass](#addcollisionclasscollisionclassname-collisionclass)
  - [collisionClassesSet](#collisionclassesset)
  - [newCircleCollider](#newcirclecolliderx-y-r-settings)
  - [newRectangleCollider](#newrectanglecolliderx-y-w-h-settings)
  - [newBSGRectangleCollider](#newbsgrectanglecolliderx-y-w-h-cornercutsize-settings)
  - [newPolygonCollider](#newpolygoncollidervertices-settings)
  - [newLineCollider](#newlinecolliderx1-y1-x2-y2-settings)

# World

A World contains the [box2d world](https://www.love2d.org/wiki/World) as well as state for handling collision classes, methods for changing box2d world settings as well as methods for the creation of Colliders and Effectors.

---

#### `.newWorld(settings)`

Creates a new World

```lua
physics_world = hx.newWorld()
```
Arguments:

- `[settings]` `(table)` - Table with optional settings for the world

Returns:

- `World`

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

Draws the World (for debugging purposes)

```lua
physics_world:draw()
```
---

#### `:addCollisionClass(collision_class_name, collision_class)`

Creates a new collision class. Collision classes are attached to colliders and define collider behavior in tertms of which ones will be physically ignored and which ones will generate collision events between each other. All collision classes must be added **before** any collider is created. After all collision classes are added `collisionClassesSet` must be called once.

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

- `[ignores]` `(table[string])` - A table of strings containing other collision class names that this collision class will physically ignore (they will go through each other). In the example above, colliders of collision class `'Player'` will ignore colliders of collision class `'NPC'` and `'Enemy'`.
- `[enter]` `(table[string])` - A table of strings containing other collision class names that will generate collision events when they enter contact with this collision class. In the example above, colliders of collision class `'Player'` will generate collision events on the frame they enter contact with colliders of collision class `'LevelTransitionArea'`.
- `[exit]` `(table[string])` - A table of strings containing other collision class names that will generate collision events when they leave contact with this collision class. In the example above, colliders of collision class `'Player'` will generate collision events on the frame they exit contact with colliders of collision class `'Projectile'`.
- `[pre]` `(table[string])` - A table of strings containing other collision class names that will generate collision events right before they enter contact with this collision class.
- `[post]` `(table[string])` - A table of strings containing other collision class names that will generate collision events right after they exit contact with this collision class.

---

#### `:collisionClassesSet()`

Sets all collision classes. This function must be called once after all collision classes have been added and before any collider is created.

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
- `[collision_class]` `(string)` - The collision class of the circle, must be a valid collision class previously added with `addColliisonClass`

Returns:

- `Collider`

---

#### `:newRectangleCollider(x, y, w, h, settings)`

Creates a new RectangleCollider

```lua
collider = physics_world:newRectangleCollider(100, 100, 50, 50, {body_type = 'static', collision_class = 'Solid'})
```
Arguments:

- `x` `(number)` - The initial x position of the rectangle (center)
- `y` `(number)` - The initial y position of the rectangle (center)
- `w` `(number)` - The width of the rectangle (x - w/2 = rectangle's left side)
- `h` `(number)` - The height of the rectangle (y - h/2 = rectangle's top side)
- `[settings]` `(table)` - A table with additional and optional settings. This table can contain:

Settings:

- `[body_type='dynamic']` `(BodyType)` - The body type, can be 'static', 'dynamic' or 'kinematic'
- `[collision_class]` `(string)` - The collision class of the rectangle, must be a valid collision class previously added with `addColliisonClass`

Returns:

- `Collider`

---

#### `:newBSGRectangleCollider(x, y, w, h, corner_cut_size, settings)`

Creates a new BSGRectangleCollider (a rectangle with its corners cut (an octagon))

```lua
collider = physics_world:newBSGRectangleCollider(100, 100, 50, 50, 5)
```
Arguments:

- `x` `(number)` - The initial x position of the rectangle (center)
- `y` `(number)` - The initial y position of the rectangle (center)
- `w` `(number)` - The width of the rectangle (x - w/2 = rectangle's left side)
- `h` `(number)` - The height of the rectangle (y - h/2 = rectangle's top side)
- `corner_cut_size` `(number)` - The corner cut size
- `[settings]` `(table)` - A table with additional and optional settings. This table can contain:

Settings:

- `[body_type='dynamic']` `(BodyType)` - The body type, can be 'static', 'dynamic' or 'kinematic'
- `[collision_class]` `(string)` - The collision class of the rectangle, must be a valid collision class previously added with `addColliisonClass`

Returns:

- `Collider`

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
- `[collision_class]` `(string)` - The collision class of the polygon, must be a valid collision class previously added with `addColliisonClass`

Returns:

- `Collider`

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
- `[collision_class]` `(string)` - The collision class of the line, must be a valid collision class previously added with `addColliisonClass`

Returns:

- `Collider`

