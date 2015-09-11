fuccboi_path = string.sub(..., 1, -9)

fg = {}

fg.Timer = require (fuccboi_path .. '/libraries/fuccboi/Timer')
fg.timer = fg.Timer()
fg.Camera = require (fuccboi_path .. '/libraries/hump/camera')
fg.Vector = require (fuccboi_path .. '/libraries/hump/vector')
fg.Gamestate = require (fuccboi_path .. '/libraries/hump/gamestate')
fg.Animation = require (fuccboi_path .. '/libraries/anal/AnAL')
fg.Tilemap = require (fuccboi_path .. '/libraries/fuccboi/Tilemap')
fg.Text = require (fuccboi_path .. '/libraries/fuccboi/Text')
fg.Group = require (fuccboi_path .. '/world/Group')
fg.Object = require (fuccboi_path .. '/libraries/classic/classic')
fg.Sound = require (fuccboi_path .. '/libraries/TEsound/TEsound')
fg.Serial = require (fuccboi_path .. '/libraries/fuccboi/Serial')()
fg.obv = require (fuccboi_path .. '/libraries/obvar/obvar')
fg.log = require(fuccboi_path .. '/libraries/log/log')
fg.probe = require(fuccboi_path .. '/libraries/probe/PROBE')
fg.bump = require(fuccboi_path .. '/libraries/bump/bump')

-- holds all classes created with the fg.Class call
fg.classes = {}
fg.Class = function(class_name, ...)
    local args = {...}
    fg.classes[class_name] = (fg[args[1]] or fg.classes[args[1]]):extend(class_name)
    return fg.classes[class_name]
end

fg.moses = require (fuccboi_path .. '/libraries/moses/moses')
fg.fn = fg.moses
fg.mo = fg.moses
fg.mlib = require (fuccboi_path .. '/libraries/mlib/mlib')
fg.ui = require (fuccboi_path .. '/libraries/thranduil')
fg.Assets = {}
fg.Loader = require (fuccboi_path .. '/libraries/love-loader/love-loader')
fg.lovebird = require (fuccboi_path .. '/libraries/lovebird/lovebird')
fg.lurker = require (fuccboi_path .. '/libraries/lurker/lurker')
require(string.gsub(fuccboi_path, '/', '.') .. '.libraries.loveframes')
fg.loveframes = loveframes

fg.Input = require (fuccboi_path .. '/libraries/fuccboi/Input')
fg.input = fg.Input()

fg.textinput = function(text)
    fg.loveframes.textinput(text)
end

fg.keypressed = function(key) 
    fg.input:keypressed(key) 
    player_input:keypressed(key) 
    fg.loveframes.keypressed(key)
end

fg.keyreleased = function(key) 
    fg.input:keyreleased(key) 
    player_input:keyreleased(key) 
    fg.loveframes.keyreleased(key)
end

fg.mousepressed = function(x, y, button) 
    fg.input:mousepressed(x, y, button) 
    player_input:mousepressed(x, y, button) 
    fg.loveframes.mousepressed(x, y, button)
end

fg.mousereleased = function(x, y, button) 
    fg.input:mousereleased(x, y, button) 
    player_input:mousereleased(x, y, button) 
    fg.loveframes.mousereleased(x, y, button)
end

fg.gamepadpressed = function(joystick, button) 
    fg.input:gamepadpressed(joystick, button) 
    player_input:gamepadpressed(joystick, button) 
end

fg.gamepadreleased = function(joystick, button) 
    fg.input:gamepadreleased(joystick, button) 
    player_input:gamepadreleased(joystick, button) 
end

fg.gamepadaxis = function(joystick, axis, newvalue) 
    fg.input:gamepadaxis(joystick, axis, newvalue) 
    player_input:gamepadaxis(joystick, axis, newvalue) 
end

-- collision, holds global collision data (mostly who should ignore who and callback settings)
fg.Collision = require (fuccboi_path .. '/libraries/fuccboi/Collision')(fg)

-- utils
fg.utils = require (fuccboi_path .. '/libraries/fuccboi/utils')

-- debugDraw drawing
fg.debugDraw = require (fuccboi_path .. '/libraries/fuccboi/debugDraw')

fg.getUID = function(id)
    if id then 
        if not fg.uids[id] then
            fg.uids[id] = true
            return id
        else
            error("id conflict: #" .. id)
        end
    else
        local i = 1
        while true do
            if not fg.uids[i] then
                fg.uids[i] = true
                return i
            end
            i = i + 1
        end
    end
end

fg.uids = {}
fg.uid = 0
fg.path = nil
fg.lovebird_enabled = false
fg.lurker_enabled = false
fg.min_width = 480
fg.min_height = 360
fg.screen_width = fg.min_width
fg.screen_height = fg.min_height
fg.screen_scale = 1
fg.log.usecolor = false

fg.init = function()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    fg.screen_width = fg.min_width
    fg.screen_heigth = fg.min_height
    fg.ui.registerEvents()
    -- love.window.setMode(fg.screen_width, fg.screen_height, {resizable = true, display = 2})
    fg.world = fg.World(fg)
    fg.Collision:generateCategoriesMasks()
end

fg.setScreenSize = function(w, h)
    love.window.setMode(w, h, {resizable = true})
    fg.resize(w, h)
end

fg.resize = function(w, h)
    fg.screen_scale = math.max(w/fg.min_width, h/fg.min_height)
    fg.screen_width = w
    fg.screen_height = h
    fg.world:resize(w, h)
end

fg.setScale = function(s)
    fg.screen_scale = s
    fg.world:resize(fg.min_width*fg.screen_scale, fg.min_height*fg.screen_scale) 
end

fg.zoomOut = function(dz)
    fg.screen_scale = math.min(fg.screen_scale + dz, 4)
    fg.world:resize(love.graphics.getWidth()*fg.screen_scale, love.graphics.getHeight()*fg.screen_scale) 
end

fg.zoomIn = function(dz)
    fg.screen_scale = math.max(fg.screen_scale - dz, math.max((love.graphics.getWidth()/fg.min_width)/2, (love.graphics.getHeight()/fg.min_height)/2))
    fg.world:resize(love.graphics.getWidth()*fg.screen_scale, love.graphics.getHeight()*fg.screen_scale) 
end

-- world
fg.World = require (fuccboi_path .. '/world/World')

-- entity
fg.Background = require (fuccboi_path .. '/entities/Background') 
fg.Entity = require (fuccboi_path .. '/entities/Entity')
fg.DebugShape = require (fuccboi_path .. '/entities/DebugShape')
fg.classes['DebugShape'] = fg.DebugShape
fg.Solid = require (fuccboi_path .. '/entities/Solid')
fg.classes['Solid'] = fg.Solid
fg.Spritebatch = require (fuccboi_path .. '/entities/Spritebatch')
fg.Spritebatches = {}
fg.Shaders = {}

-- mixin
fg.PhysicsBody = require (fuccboi_path .. '/mixins/PhysicsBody')

fg.getPS = function(name)
    local image = love.graphics.newImage(fuccboi_path .. '/resources/particles/sperm/square.png')
    local ps_data = require (fuccboi_path .. '/resources/particles/sperm/' .. name)
    local particle_settings = {}
    particle_settings["colors"] = {}
    particle_settings["sizes"] = {}
    for k, v in pairs(ps_data) do
        if k == "colors" then
            local j = 1
            for i = 1, #v , 4 do
                local color = {v[i], v[i+1], v[i+2], v[i+3]}
                particle_settings["colors"][j] = color
                j = j + 1
            end
        elseif k == "sizes" then
            for i = 1, #v do particle_settings["sizes"][i] = v[i] end
        else particle_settings[k] = v end
    end
    local ps = love.graphics.newParticleSystem(image, particle_settings["buffer_size"])
    ps:setAreaSpread(string.lower(particle_settings["area_spread_distribution"]), particle_settings["area_spread_dx"] or 0, 
                     particle_settings["area_spread_dy"] or 0)
    ps:setBufferSize(particle_settings["buffer_size"] or 1)
    local colors = {}
    for i = 1, 8 do
        if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or 
           particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
            table.insert(colors, particle_settings["colors"][i][1] or 0)
            table.insert(colors, particle_settings["colors"][i][2] or 0)
            table.insert(colors, particle_settings["colors"][i][3] or 0)
            table.insert(colors, particle_settings["colors"][i][4] or 0)
        end
    end
    ps:setColors(unpack(colors))
    ps:setDirection(math.rad(particle_settings["direction"] or 0))
    ps:setEmissionRate(particle_settings["emission_rate"] or 0)
    ps:setEmitterLifetime(particle_settings["emitter_lifetime"] or 0)
    ps:setInsertMode(string.lower(particle_settings["insert_mode"]))
    ps:setLinearAcceleration(particle_settings["linear_acceleration_xmin"] or 0, particle_settings["linear_acceleration_ymin"] or 0,
                             particle_settings["linear_acceleration_xmax"] or 0, particle_settings["linear_acceleration_ymax"] or 0)
    if particle_settings["offsetx"] ~= 0 or particle_settings["offsety"] ~= 0 then
        ps:setOffset(particle_settings["offsetx"], particle_settings["offsety"])
    end
    ps:setParticleLifetime(particle_settings["plifetime_min"] or 0, particle_settings["plifetime_max"] or 0)
    ps:setRadialAcceleration(particle_settings["radialacc_min"] or 0, particle_settings["radialacc_max"] or 0)
    ps:setRotation(math.rad(particle_settings["rotation_min"] or 0), math.rad(particle_settings["rotation_max"] or 0))
    ps:setSizeVariation(particle_settings["size_variation"] or 0)
    local sizes = {}
    local sizes_i = 1
    for i = 1, 8 do
        if particle_settings["sizes"][i] == 0 then
            if i < 8 and particle_settings["sizes"][i+1] == 0 then
                sizes_i = i
                break
            end
        end
    end
    if sizes_i > 1 then
        for i = 1, sizes_i do table.insert(sizes, particle_settings["sizes"][i] or 0) end
        ps:setSizes(unpack(sizes))
    end
    ps:setSpeed(particle_settings["speed_min"] or 0, particle_settings["speed_max"] or 0)
    ps:setSpin(math.rad(particle_settings["spin_min"] or 0), math.rad(particle_settings["spin_max"] or 0))
    ps:setSpinVariation(particle_settings["spin_variation"] or 0)
    ps:setSpread(math.rad(particle_settings["spread"] or 0))
    ps:setTangentialAcceleration(particle_settings["tangential_acceleration_min"] or 0, 
                                 particle_settings["tangential_acceleration_max"] or 0)
    return ps
end

fg.update = function(dt)
    fg.Sound.cleanup()
    if fg.lurker_enabled then fg.lurker.update() end
    if fg.lovebird_enabled then fg.lovebird.update() end
    fg.loveframes.update(dt)
    fg.Collision:generateCategoriesMasks()
    for k, s in pairs(fg.Spritebatches) do s:update(dt) end
    fg.timer:update(dt)
    fg.world:update(dt)
    fg.debugDraw.update(dt)
    fg.obv:update()
end

fg.draw = function()
    fg.world:draw()
    fg.loveframes.draw()
    fg.debugDraw.draw()
end

fg.run = function()
    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then love.audio.stop() end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt); fg.input:update(dt); player_input:update(dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.window and love.graphics then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

return fg
