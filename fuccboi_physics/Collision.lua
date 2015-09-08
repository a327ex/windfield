local function collEnsure(class_name1, a, class_name2, b)
    if a.tag == class_name2 and b.tag == class_name1 then return b, a
    else return a, b end
end

local function collIf(class_name1, class_name2, a, b)
    if (a.tag == class_name1 and b.tag == class_name2) or
       (a.tag == class_name2 and b.tag == class_name1) then
       return true
    else return false end
end

local Class = require (fuccboi_path .. '/libraries/classic/classic')
local Collision = Class:extend()

function Collision:collisionNew()
    self:collisionClear()
end

function Collision:collisionClear()
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

function Collision:isSensor(type1, type2)
    local collision_ignores = {}
    for class_name, class in pairs(self.fg.classes) do
        collision_ignores[class_name] = class.ignores or {}
    end
    local all = {}
    for class_name, _ in pairs(collision_ignores) do
        table.insert(all, class_name)
    end
    local ignored_types = {}
    for _, class_type in ipairs(collision_ignores[type1]) do
        if class_type == 'All' then
            for _, class_name in ipairs(all) do
                table.insert(ignored_types, class_name)
            end
        else table.insert(ignored_types, class_type) end
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
    if self.fg.fn.contains(ignored_types, type2) then return true else return false end
end

function Collision:collIsSensor(type1, type2)
    if self:isSensor(type1, type2) or self:isSensor(type2, type1) then return true
    else return false end
end

function Collision:addCollisionEnter(type1, type2, action, physical)
    if not self:collIsSensor(type1, type2) or physical then
        table.insert(self.collisions.on_enter.non_sensor, {type1 = type1, type2 = type2, action = action})
    else table.insert(self.collisions.on_enter.sensor, {type1 = type1, type2 = type2, action = action}) end
end

function Collision:addCollisionExit(type1, type2, action, physical)
    if not self:collIsSensor(type1, type2) or physical then
        table.insert(self.collisions.on_exit.non_sensor, {type1 = type1, type2 = type2, action = action})
    else table.insert(self.collisions.on_exit.sensor, {type1 = type1, type2 = type2, action = action}) end
end

function Collision:addCollisionPre(type1, type2, action, physical)
    if not self:collIsSensor(type1, type2) or physical then
        table.insert(self.collisions.pre.non_sensor, {type1 = type1, type2 = type2, action = action})
    else table.insert(self.collisions.pre.sensor, {type1 = type1, type2 = type2, action = action}) end
end

function Collision:addCollisionPost(type1, type2, action, physical)
    if not self:collIsSensor(type1, type2) or physical then
        table.insert(self.collisions.post.non_sensor, {type1 = type1, type2 = type2, action = action})
    else table.insert(self.collisions.post.sensor, {type1 = type1, type2 = type2, action = action}) end
end

function Collision.collisionPre(fixture_a, fixture_b, contact)
    local a, b = fixture_a:getUserData(), fixture_b:getUserData()
    local nx, ny = contact:getNormal()

    if fixture_a:isSensor() and fixture_b:isSensor() then
        if a and b then
            for _, collision in ipairs(a.object.area.world.collisions.pre.sensor) do
                if collIf(collision.type1, collision.type2, a, b) then
                    a, b = collEnsure(collision.type1, a, collision.type2, b)
                    a.object[collision.action](a.object, 'pre', b, contact)
                    if collision.type1 == collision.type2 then 
                        b.object[collision.action](b.object, 'pre', a, contact) 
                    end
                end
            end
        end

    elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
        if a and b then
            for _, collision in ipairs(a.object.area.world.collisions.pre.non_sensor) do
                if collIf(collision.type1, collision.type2, a, b) then
                    a, b = collEnsure(collision.type1, a, collision.type2, b)
                    a.object[collision.action](a.object, 'pre', b, contact)
                    if collision.type1 == collision.type2 then 
                        b.object[collision.action](b.object, 'pre', a, contact) 
                    end
                end
            end
        end
    end
end

function Collision.collisionPost(fixture_a, fixture_b, contact, ni1, ti1, ni2, ti2)
    local a, b = fixture_a:getUserData(), fixture_b:getUserData()
    local nx, ny = contact:getNormal()

    if fixture_a:isSensor() and fixture_b:isSensor() then
        if a and b then
            for _, collision in ipairs(a.object.area.world.collisions.post.sensor) do
                if collIf(collision.type1, collision.type2, a, b) then
                    a, b = collEnsure(collision.type1, a, collision.type2, b)
                    a.object[collision.action](a.object, 'post', b, contact, ni1, ti1, ni2, ti2)
                    if collision.type1 == collision.type2 then 
                        b.object[collision.action](b.object, 'post', a, contact, ni1, ti2, ni2, ti2) 
                    end
                end
            end
        end

    elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
        if a and b then
            for _, collision in ipairs(a.object.area.world.collisions.post.non_sensor) do
                if collIf(collision.type1, collision.type2, a, b) then
                    a, b = collEnsure(collision.type1, a, collision.type2, b)
                    a.object[collision.action](a.object, 'post', b, contact, ni1, ti1, ni2, ti2)
                    if collision.type1 == collision.type2 then 
                        b[collision.action](b.object, 'post', a, contact, ni1, ti2, ni2, ti2) 
                    end
                end
            end
        end
    end
end

function Collision.collisionOnEnter(fixture_a, fixture_b, contact)
    local a, b = fixture_a:getUserData(), fixture_b:getUserData()
    local nx, ny = contact:getNormal()

    if fixture_a:isSensor() and fixture_b:isSensor() then
        if a and b then
            for _, collision in ipairs(a.object.area.world.collisions.on_enter.sensor) do
                if collIf(collision.type1, collision.type2, a, b) then
                    a, b = collEnsure(collision.type1, a, collision.type2, b)
                    a.object[collision.action](a.object, 'enter', b, contact)
                    if collision.type1 == collision.type2 then 
                        b.object[collision.action](b.object, 'enter', a, contact) 
                    end
                end
            end
        end

    elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
        if a and b then
            for _, collision in ipairs(a.object.area.world.collisions.on_enter.non_sensor) do
                if collIf(collision.type1, collision.type2, a, b) then
                    a, b = collEnsure(collision.type1, a, collision.type2, b)
                    a.object[collision.action](a.object, 'enter', b, contact)
                    if collision.type1 == collision.type2 then 
                        b.object[collision.action](b.object, 'enter', a, contact) 
                    end
                end
            end
        end
    end
end

function Collision.collisionOnExit(fixture_a, fixture_b, contact)
    local a, b = fixture_a:getUserData(), fixture_b:getUserData()
    local nx, ny = contact:getNormal()

    if fixture_a:isSensor() and fixture_b:isSensor() then
        if a and b then
            for _, collision in ipairs(a.object.area.world.collisions.on_exit.sensor) do
                if collIf(collision.type1, collision.type2, a, b) then
                    a, b = collEnsure(collision.type1, a, collision.type2, b)
                    a.object[collision.action](a.object, 'exit', b, contact)
                    if collision.type1 == collision.type2 then 
                        b.object[collision.action](b.object, 'exit', a, contact) 
                    end
                end
            end
        end

    elseif not (fixture_a:isSensor() or fixture_b:isSensor()) then
        if a and b then
            for _, collision in ipairs(a.object.area.world.collisions.on_exit.non_sensor) do
                if collIf(collision.type1, collision.type2, a, b) then
                    a, b = collEnsure(collision.type1, a, collision.type2, b)
                    a.object[collision.action](a.object, 'exit', b, contact)
                    if collision.type1 == collision.type2 then 
                        b.object[collision.action](b.object, 'exit', a, contact) 
                    end
                end
            end
        end
    end
end

return Collision
