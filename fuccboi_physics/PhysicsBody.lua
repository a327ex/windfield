local Class = require (fuccboi_path .. '/libraries/classic/classic')
local PhysicsBody = Class:extend()  

function PhysicsBody:physicsBodyNew(area, x, y, settings)
    self.bodies = {}
    self.shapes = {}
    self.fixtures = {}
    self.sensors = {}
    self.joints = {}

    self:addBody(area, x, y, settings)
end

function PhysicsBody:addBody(area, x, y, settings)
    -- Set name to main if there isn't one and/or remove previous physics names if they already exist
    local settings = settings or {}
    settings.physics_name = settings.physics_name or 'main'
    local name = settings.physics_name
    if self.bodies[name] then self:removeBody(name) end

    -- Define body
    local body = love.physics.newBody(area.world.box2d_world, x, y, settings.body_type or 'dynamic')
    body:setFixedRotation(true)

    -- Define shape
    settings.shape = settings.shape or 'rectangle'
    local shape = nil
    local shape_name = string.lower(settings.shape)
    self.shape_name = shape_name
    local body_w, body_h, body_r = 0, 0, 0

    if shape_name == 'bsgrectangle' then
        local w, h, s = settings.w or 32, settings.h or 32, settings.s or 4
        body_w, body_h = w, h
        shape = love.physics.newPolygonShape(
            -w/2, -h/2 + s, -w/2 + s, -h/2,
             w/2 - s, -h/2, w/2, -h/2 + s,
             w/2, h/2 - s, w/2 - s, h/2,
            -w/2 + s, h/2, -w/2, h/2 - s
        )

    elseif shape_name == 'rectangle' then
        body_w, body_h = settings.w or 32, settings.h or 32
        shape = love.physics.newRectangleShape(settings.w or 32, settings.h or 32)

    elseif shape_name == 'polygon' then
        shape = love.physics.newPolygonShape(unpack(settings.vertices))

    elseif shape_name == 'chain' then
        shape = love.physics.newChainShape(settings.loop or false, unpack(settings.vertices))
        self.chain_vertices = settings.vertices

    elseif shape_name == 'circle' then
        body_r = settings.r or 16
        body_w, body_h = settings.r or 32, settings.r or 32
        shape = love.physics.newCircleShape(settings.r or 16)
    end

    -- Define collision classes and attach them to fixture and sensor
    local mask_name = settings.collision_class or self.class_name
    local fixture = love.physics.newFixture(body, shape)
    fixture:setCategory(unpack(self.area.fg.Collision.masks[mask_name].categories))
    fixture:setMask(unpack(self.area.fg.Collision.masks[mask_name].masks))
    fixture:setUserData({object = self, tag = mask_name})
    local sensor = love.physics.newFixture(body, shape)
    sensor:setSensor(true)
    sensor:setUserData({object = self, tag = mask_name})

    self.bodies[name] = body
    self.shapes[name] = shape
    self.fixtures[name] = fixture
    self.sensors[name] = sensor

    -- self.body, shape, fixture, sensor = the main body, shape, fixture, sensor
    if name == 'main' then
        self.w, self.h, self.r = body_w, body_h, body_r
        self.body = self.bodies['main']
        self.shape = self.shapes['main']
        self.fixture = self.fixtures['main']
        self.sensor = self.sensors['main']
    end
end

function PhysicsBody:removeBody(name)
    if not self.bodies[name] then return end
    self.fixtures[name]:setUserData(nil)
    self.sensors[name]:setUserData(nil)
    self.bodies[name]:destroy()
    self.fixtures[name] = nil
    self.sensors[name] = nil
    self.shapes[name] = nil
    self.bodies[name] = nil
end

function PhysicsBody:removeJoint(name)
    if not self.joints[name] then return end
    self.joints[name]:destroy()
    self.joints[name] = nil
end

function PhysicsBody:removeShape(name)
    if not self.shapes[name] then return end
    self.shapes[name] = nil
end

function PhysicsBody:addJoint(name, type, ...)
    if self.joints[name] then self:removeJoint(name) end
    local args = {...}
    local joint_name = string.lower(type)
    local joint = nil
    local joint_name_to_function_name = {
        distance = 'newDistanceJoint', friction = 'newFrictionJoint', gear = 'newGearJoint',
        mouse = 'newMouseJoint', prismatic = 'newPrismaticJoint', pulley = 'newPulleyJoint',
        revolute = 'newRevoluteJoint', rope = 'newRopeJoint', weld = 'newWeldJoint', wheel = 'newWheelJoint',
    }
    joint = love.physics[joint_name_to_function_name[joint_name]](unpack(args))
    self.joints[name] = joint
end

function PhysicsBody:changeCollisionClass(name, collision_class)
    if not self.fixtures[name] then return end -- fail silently or not? Same question for add/remove calls
    self.fixtures[name]:setCategory(unpack(self.area.fg.Collision.masks[collision_class].categories))
    self.fixtures[name]:setMask(unpack(self.area.fg.Collision.masks[collision_class].masks))
    self.fixtures[name]:setUserData({object = self, tag = collision_class})
    self.sensors[name]:setSensor(true)
    self.sensors[name]:setUserData({object = self, tag = collision_class})
end

function PhysicsBody:getGroupIndex(name)
    if not self.fixtures[name] then return end
    return self.fixtures[name]:getGroupIndex()
end

function PhysicsBody:setGroupIndex(name, group_index)
    if not self.fixtures[name] then return end
    self.fixtures[name]:setGroupIndex(group_index)
end

function PhysicsBody:physicsBodyUpdate(dt)
    self.x, self.y = self.body:getPosition()
end

function PhysicsBody:physicsBodyDraw(r, g, b)
    self.x, self.y = self.body:getPosition()
    if not self.area.fg.debugDraw.physics_enabled then return end

    for name, body in pairs(self.bodies) do
        if self.shapes[name]:type() == 'PolygonShape' then
            love.graphics.setColor(r or 64, g or 128, b or 244)
            love.graphics.polygon('line', self.bodies[name]:getWorldPoints(self.shapes[name]:getPoints()))
            love.graphics.setColor(255, 255, 255)

        elseif self.shapes[name]:type() == 'EdgeShape' or self.shapes[name]:type() == 'ChainShape' then
            love.graphics.setColor(r or 64, g or 128, b or 244)
            local points = {self.bodies[name]:getWorldPoints(self.shapes[name]:getPoints())}
            for i = 1, #points, 2 do
                if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
            end
            love.graphics.setColor(255, 255, 255)

        elseif self.shapes[name]:type() == 'CircleShape' then
            love.graphics.setColor(r or 64, g or 128, b or 244)
            local x, y = self.bodies[name]:getPosition()
            love.graphics.circle('line', x, y, self.r, 360)
            love.graphics.setColor(255, 255, 255)
        end
    end

    for name, joint in pairs(self.joints) do
        local x1, y1, x2, y2 = self.joints[name]:getAnchors()
        love.graphics.setPointSize(8)
        love.graphics.setColor(244, 128, 64)
        love.graphics.point(x1, y1)
        love.graphics.setColor(128, 244, 64)
        love.graphics.point(x2, y2)
        love.graphics.setColor(255, 255, 255)
        love.graphics.setPointSize(1)
    end
end

function PhysicsBody:handleCollisions(type, object, contact, ni1, ti1, ni2, ti2)
    if type == 'pre' then
        if self.preSolve then
            self:preSolve(object, contact)
        end
        
    elseif type == 'post' then
        if self.postSolve then
            self:postSolve(object, contact, ni1, ti1, ni2, ti2)
        end

    elseif type == 'enter' then
        if self.onCollisionEnter then
            self:onCollisionEnter(object, contact)
        end

    elseif type == 'exit' then
        if self.onCollisionExit then
            self:onCollisionExit(object, contact)
        end
    end
end

return PhysicsBody
