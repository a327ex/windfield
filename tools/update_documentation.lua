local docroc = require 'docroc'

io.output('README.md')

io.write('hxdx\n===\n\n')

local comments = docroc.process('../hxdx/init.lua')

-- Generate table of contents
for _, comment in ipairs(comments) do
  local tags = comment.tags

  if tags.class then
    local class = tags.class[1].name
    io.write('- [' .. class .. '](#' .. class:lower() .. ')\n')
  else
    local context = comment.context:match('function.-([:%.].+)')
    if tags.arg then
      context = context:gsub('%b()', function(signature)
        local args = {}

        for _, arg in ipairs(tags.arg) do
          table.insert(args, arg.name)
        end

        return '(' .. table.concat(args, ', ') .. ')'
      end)
    end

    local name = comment.context:match('function.-[:%.]([^%(]+)')

    io.write('  - [' .. name .. '](#' .. context:gsub('[^%w%s]+', ''):gsub(' ', '-'):lower() .. ')\n')
  end
end

io.write('\n')

-- Generate content
for _, comment in ipairs(comments) do
  local tags = comment.tags

  if tags.class then
    io.write('# ' .. tags.class[1].name .. '\n\n')
    if tags.description then
      io.write(tags.description[1].text .. '\n\n')
    end
  else
    local context = comment.context:match('function.-([:%.].+)')
    if tags.arg then
      context = context:gsub('%b()', function(signature)
        local args = {}

        for _, arg in ipairs(tags.arg) do
          table.insert(args, arg.name)
        end

        return '(' .. table.concat(args, ', ') .. ')'
      end)

    end

    io.write(('---\n\n#### `%s`\n\n'):format(context))

    if tags.description then
      io.write(('%s\n\n'):format(tags.description[1].text))
    end

    if tags.luastart then
      io.write('```lua\n')
    end

    if tags.code then
      for _, code in ipairs(tags.code) do
        io.write(code.raw .. '\n')
      end
    end

    if tags.luaend then
      io.write('```\n')
    end

    if tags.arg then
      io.write('Arguments:\n\n')

      for _, arg in ipairs(tags.arg) do
        local name = arg.name
        if arg.optional then
          if arg.default then
            name = '[' .. name .. '=' .. arg.default .. ']'
          else
            name = '[' .. name .. ']'
          end
        end
        name = '`' .. name .. '`'
        local description = arg.description and (' - ' .. arg.description) or ''
        local type = ' `(' .. arg.type .. ')`'
        local line = '- ' .. name .. type .. description
        io.write(line .. '\n')
      end

      io.write('\n')
    end

    if tags.setting then
      io.write('Settings:\n\n')

      for _, arg in ipairs(tags.setting) do
        local name = arg.name
        if arg.optional then
          if arg.default then
            name = '[' .. name .. '=' .. arg.default .. ']'
          else
            name = '[' .. name .. ']'
          end
        end
        name = '`' .. name .. '`'
        local description = arg.description and (' - ' .. arg.description) or ''
        local type = ' `(' .. arg.type .. ')`'
        local line = '- ' .. name .. type .. description
        io.write(line .. '\n')
      end

      io.write('\n')
    end

    if tags.returns then
      io.write('Returns:\n\n')

      for _, result in ipairs(tags.returns) do
        io.write('- `' .. result.type .. '`\n')
      end

      io.write('\n')
    end

  end
end
