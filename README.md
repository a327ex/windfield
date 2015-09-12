**hxdx** is a physics module for LÖVE. It wraps LÖVE's physics API so that using box2d becomes as simple as possible.

## Usage

Require the module:

```lua
hx = require 'hxdx'
```

### Create a world

```lua
function love.load()
  world = hx.newWorld({gravity_y = 10})
end

function love.update(dt)
  world:update(dt)
end
```

### Create colliders

```lua
function love.load()
  ...
  box = world:newRectangleCollider(400, 300, 50, 50)
  ground = world:newRectangleCollider(400, 400, 200, 30, {body_type = 'static'})
end

function love.draw()
  -- Colliders can be drawn for debugging purposes
  box:draw()
  ground:draw()
end
```

<p align="center">
<img src="http://i.imgur.com/vYYcfbH.gif"/>
</p>

### Add collision classes

```lua
function love.load()
  ...
  -- By default colliders belong to the collision class 'Default'
  -- So in this case the box will physically ignore the ground and go through it
  world:addCollisionClass('Ghost', ignores = {'Default'})
  world:collisionClassesSet()

  box = world:newRectangleCollider(400, 300, 50, 50, {collision_class = 'Ghost'})
  ground = world:newRectangleCollider(400, 400, 200, 30, {body_type = 'static'})
end
```

<p align="center">
<img src="http://i.imgur.com/0toUgjS.gif"/>
</p>

### Capture collision events

```lua
function love.update(dt)
  ...
  if box:enter('Default') then
    box.body:applyLinearImpulse(0, -5000)
  end
end
```

<p align="center">
<img src="http://i.imgur.com/eaKVMfP.gif"/>
</p>

## Examples

[EXAMPLES](https://github.com/adonaac/hxdx/tree/master/examples)

## Documentation

[DOCUMENTATION](https://github.com/adonaac/hxdx/blob/master/docs/README.md)

## LICENSE

You can do whatever you want with this. See the [LICENSE](https://github.com/adonaac/hxdx/blob/master/LICENSE).
