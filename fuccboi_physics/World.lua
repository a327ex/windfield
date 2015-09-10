local Collision = require (fuccboi_path .. '/world/Collision')
local Render = require (fuccboi_path .. '/world/Render')
local Area = require (fuccboi_path .. '/world/Area')
local Class = require (fuccboi_path .. '/libraries/classic/classic')

local World = Class:extend()
World:implement(Collision)
World:implement(Render)

function World:new(fg)
    self.fg = fg
    self.id = self.fg.getUID()

    love.physics.setMeter(32)
    self.box2d_world = love.physics.newWorld(0, 0) 
    self.box2d_world:setCallbacks(self.collisionOnEnter, self.collisionOnExit, self.collisionPre, self.collisionPost)

    self:collisionNew()
    self:renderNew()

    self:collisionClear()
    self:collisionSet()

    self.paused = false
    self.areas = {}
    self:createArea('Default', 0, 0)
    self.areas['Default']:activate()

    self.ui_entities = {}
end

function World:createArea(area_name, x, y, settings)
    if not self.areas[area_name] then
        self.areas[area_name] = Area(self, area_name, x, y, settings)
    end
end

function World:collisionSet()
    local collision_table = self.fg.Collision:getCollisionCallbacksTable()
    for class_name, collision_list in pairs(collision_table) do
        for _, collision_info in ipairs(collision_list) do
            if collision_info.type == 'enter' then 
                self:addCollisionEnter(class_name, collision_info.other, 'handleCollisions', collision_info.physical) 
            end
            if collision_info.type == 'exit' then 
                self:addCollisionExit(class_name, collision_info.other, 'handleCollisions', collision_info.physical) 
            end
            if collision_info.type == 'pre' then 
                self:addCollisionPre(class_name, collision_info.other, 'handleCollisions', collision_info.physical) 
            end
            if collision_info.type == 'post' then 
                self:addCollisionPre(class_name, collision_info.other, 'handleCollisions', collision_info.physical) 
            end
        end
    end
end

function World:pause()
    self.paused = true
end

function World:unpause()
    self.paused = false
end

function World:update(dt)
    for _, entity in ipairs(self.ui_entities) do entity:update(dt) end
    for i = #self.ui_entities, 1, -1 do 
        if self.ui_entities[i].dead then 
            self:removeFromRender(self.ui_entities[i].id)
            table.remove(self.ui_entities, i)
        end
    end

    if self.paused then return end
    self:renderUpdate(dt)
    self.box2d_world:update(dt)
    self:collisionClear()
    self:collisionSet()
    for area_name, area in pairs(self.areas) do if area.active then area:update(dt) end end
end

function World:draw()
    self:renderDraw()
    self.camera:debugDraw()
end

function World:resize(w, h)
    self:renderResize(w, h)
end

function World:clear()
    for _, area in pairs(self.areas) do area:clear() end
    self.ui_entities = {}
    self.areas = {}
    self:createArea('Default', 0, 0)
    self.areas['Default']:activate()
    self:renderClear()
end

function World:createUIEntity(type, x, y, settings)
    local entity = _G[type](x, y, settings)
    table.insert(self.ui_entities, entity) 
    self:addToLayer(entity.layer, entity)
    return entity
end

function World:clearUI()
    for _, e in ipairs(self.ui_entities) do self:removeFromRender(e.id) end
    self.ui_entities = {}
end

-- mg.world -> mg.world.areas['Default'] redirects
function World:createEntity(...) self.areas['Default']:createEntity(...) end
function World:createEntityImmediate(...) return self.areas['Default']:createEntityImmediate(...) end
function World:hitFrameStopAdd(...) self.areas['Default']:hitFrameStopAdd(...) end
function World:getEntitiesBy(...) return self.areas['Default']:getEntitiesBy(...) end
function World:queryClosestAreaCircle(...) return self.areas['Default']:queryClosestAreaCircle(...) end
function World:queryAreaCircle(...) return self.areas['Default']:queryAreaCircle(...) end
function World:queryAreaRectangle(...) return self.areas['Default']:queryAreaRectangle(...) end
function World:queryAreaLine(...) return self.areas['Default']:queryAreaLine(...) end
function World:queryAreaPolygon(...) return self.areas['Default']:queryAreaPolygon(...) end
function World:applyAreaCircle(...) self.areas['Default']:applyAreaCircle(...) end
function World:applyAreaRectangle(...) self.areas['Default']:applyAreaRectangle(...) end
function World:applyAreaLine(...) self.areas['Default']:applyAreaLine(...) end
function World:applyAreaPolygon(...) self.areas['Default']:applyAreaPolygon(...) end
function World:createTiledMapEntities(...) self.areas['Default']:createTiledMapEntities(...) end
function World:generateCollisionSolids(...) self.areas['Default']:generateCollisionSolids(...) end
function World:spawnParticles(...) self.areas['Default']:spawnParticles(...) end
function World:activate(...) self.areas['Default']:activate(...) end
function World:deactivate(...) self.areas['Default']:deactivate(...) end

return World
