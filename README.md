**windfield** is a physics module for LÖVE. It wraps LÖVE's physics API so that using box2d becomes as simple as possible.

# Usage

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

# Documentation

# LICENSE

You can do whatever you want with this. See the [LICENSE](https://github.com/SSYGEA/windfield/blob/master/LICENSE).
