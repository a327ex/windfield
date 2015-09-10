local Collision = {}
Collision.__index = Collision

function Collision.new(fg)
    local self = {}

    self.masks = {}
    self.fg = fg

    return setmetatable(self, Collision)
end

function Collision:generateCategoriesMasks()
    local collision_ignores = {}
    for class_name, class in pairs(self.fg.classes) do
        collision_ignores[class_name] = class.ignores or {}
    end
    local incoming = {}
    local expanded = {}
    local all = {}
    for object_type, _ in pairs(collision_ignores) do
        incoming[object_type] = {}
        expanded[object_type] = {}
        table.insert(all, object_type)
    end
    for object_type, ignore_list in pairs(collision_ignores) do
        for key, ignored_type in pairs(ignore_list) do
            if ignored_type == 'All' then
                for _, all_object_type in ipairs(all) do
                    table.insert(incoming[all_object_type], object_type)
                    table.insert(expanded[object_type], all_object_type)
                end
            elseif type(ignored_type) == 'string' then
                if ignored_type ~= 'All' then
                    table.insert(incoming[ignored_type], object_type)
                    table.insert(expanded[object_type], ignored_type)
                end
            end
            if key == 'except' then
                for _, except_ignored_type in ipairs(ignored_type) do
                    for i, v in ipairs(incoming[except_ignored_type]) do
                        if v == object_type then
                            table.remove(incoming[except_ignored_type], i)
                            break
                        end
                    end
                end
                for _, except_ignored_type in ipairs(ignored_type) do
                    for i, v in ipairs(expanded[object_type]) do
                        if v == except_ignored_type then
                            table.remove(expanded[object_type], i)
                            break
                        end
                    end
                end
            end
        end
    end
    local edge_groups = {}
    for k, v in pairs(incoming) do
        table.sort(v, function(a, b) return string.lower(a) < string.lower(b) end)
    end
    local i = 0
    for k, v in pairs(incoming) do
        local str = ""
        for _, c in ipairs(v) do
            str = str .. c
        end
        if not edge_groups[str] then i = i + 1; edge_groups[str] = {n = i} end
        table.insert(edge_groups[str], k)
    end
    local categories = {}
    for k, _ in pairs(collision_ignores) do
        categories[k] = {}
    end
    for k, v in pairs(edge_groups) do
        for i, c in ipairs(v) do
            categories[c] = v.n
        end
    end
    for k, v in pairs(expanded) do
        local category = {categories[k]}
        local current_masks = {}
        for _, c in ipairs(v) do
            table.insert(current_masks, categories[c])
        end
        self.masks[k] = {categories = category, masks = current_masks}
    end
end

function Collision:addCollisionClass(class_name, ignores)
    fg.classes[class_name] = {ignores = ignores}
end

function Collision:getCollisionClassMasks(class_name)
    return fg.classes[class_name].ignores 
end

function Collision:getCollisionCallbacksTable()
    local collision_table = {}
    for class_name, class in pairs(self.fg.classes) do
        collision_table[class_name] = {}
        local class_collision_enter = class.enter or {}
        for _, v in ipairs(class_collision_enter) do
            table.insert(collision_table[class_name], {type = 'enter', other = v})
        end
        local class_collision_exit = class.exit or {}
        for _, v in ipairs(class_collision_exit) do
            table.insert(collision_table[class_name], {type = 'exit', other = v})
        end
        local class_pre_solve = class.pre or {}
        for _, v in ipairs(class_pre_solve) do
            table.insert(collision_table[class_name], {type = 'pre', other = v})
        end
        local class_post_solve = class.post or {}
        for _, v in ipairs(class_post_solve) do
            table.insert(collision_table[class_name], {type = 'post', other = v})
        end
    end
    return collision_table
end

return setmetatable({new = new}, {__call = function(_, ...) return Collision.new(...) end})
