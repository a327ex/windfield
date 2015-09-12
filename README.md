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
  -- The world can be drawn for debugging purposes
  world:draw()
end
```

### Add collision classes

```lua
function love.load()
  ...
  -- By default colliders belong to the collision class 'Default'
  -- So in this case the box will physically ignore the ground and go through it
  world:addCollisionClass('Ghost', ignores = {'Default'})

  box = world:newRectangleCollider(400, 300, 50, 50, {collision_class = 'Ghost'})
  ground = world:newRectangleCollider(400, 400, 200, 30, {body_type = 'static'})
end
```

### Capture collision events

```lua
function love.update(dt)
  ...
  if box:enter('Default') then
    box.body:applyLinearImpulse(0, -5000)
  end
end
```

### Query the world

```lua
function love.load()
  world = hx.newWorld({gravity_y = 400})

  box_1 = world:newRectangleCollider(375, 100, 50, 50)
  box_1.body:setFixedRotation(false)
  box_2 = world:newRectangleCollider(375, 200, 50, 50)
  box_2.body:setFixedRotation(false)
  box_3 = world:newRectangleCollider(375, 300, 50, 50)
  box_3.body:setFixedRotation(false)
end

function love.update(dt)
  world:update(dt)
end

function love.draw()
  world:draw()
end

function love.keypressed(key)
  if key == 'space' then
    local colliders = world:queryCircleArea(400, 320, 50)
    for _, collider in ipairs(colliders) do
      collider.body:applyLinearImpulse(500, 0)
    end
  end
end

```

## Examples

[Examples](https://github.com/adonaac/hxdx/tree/master/examples)

## Documentation

[Documentation](https://github.com/adonaac/hxdx/blob/master/docs/README.md)

## LICENSE

You can do whatever you want with this. See the [LICENSE](https://github.com/adonaac/hxdx/blob/master/LICENSE).
