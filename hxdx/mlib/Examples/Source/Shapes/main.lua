local mlib = require 'mlib' 
local width, height = love.graphics.getDimensions() 
local font = love.graphics.getFont() 

local function generateRandomPolygon( numberOfPoints, minimumX, minimumY, maxWidth, maxHeight ) 
	-- Based off of the "TwoPeasants" algorithm. 
	local x = {} 
	local y = {}
	local maximumX = minimumX + maxWidth
	local maximumY = minimumY + maxHeight
	
	local function isInTable( tab, value )
		for _, val in ipairs( tab ) do
			if val == Value then return true end
		end
		return false
	end
	
	for i = 1, numberOfPoints do 
		local X = love.math.random( minimumX, maximumX )
		local Y = love.math.random( minimumY, maximumY )
		-- Make sure the point is not already done (highly unlikely).
		while isInTable( x, X ) do X = love.math.random( minimumX, maximumX ) end
		while isInTable( y, Y ) do Y = love.math.random( minimumX, maximumX ) end
		x[i] = X
		y[i] = Y
	end
	
	-- Arrange the points in order to be drawn. 
	local function orderPoints( x, y )
		local function sortWithReference( tab, func )
			if #tab == 0 then return nil, nil end
			local i, v = 1, tab[1]
			for ii = 2, #tab do
				if func( v, tab[ii] ) then
					i, v = ii, tab[ii]
				end
			end
			return v, i
		end
		
		-- Step 1: Divide it into two halves:
		local smallestX, smallestReference = sortWithReference( x, function ( v1, v2 ) return v1 > v2 end ) 
		local smallestXY = y[smallestReference]		
		table.remove( x, smallestReference )
		table.remove( y, smallestReference )
		local largestX, largestReference = sortWithReference( x, function ( v1, v2 ) return v1 < v2 end ) 
		local largestXY = y[largestReference]
		table.remove( x, largestReference )
		table.remove( y, largestReference )
		local m = mlib.line.getSlope( smallestX, largestX, smallestXY, largestXY )
		local b = mlib.line.getYIntercept( smallestX, smallestXY, m )
		
		local upperX = {}
		local upperY = {}
		local lowerX = {}
		local lowerY = {}

		while #x > 0 do
			local length = #x
			local X, Y = x[length], y[length]
			
			local vector1 = { x = smallestX - largestX, y = smallestXY - largestXY }
			local vector2 = { x = largestX - X, y = largestXY - Y }
			local crossProduct = vector1.x * vector2.y - vector1.y * vector2.x
			
			if crossProduct >= 0 then upperX[#upperX + 1], upperY[#upperY + 1] = X, Y 
			else lowerX[#lowerX + 1], lowerY[#lowerY + 1] = X, Y end
			table.remove( x, length )
			table.remove( y, length )
		end
		
		-- Step 2 (Upper Half): Start on the most-left point, connect to closest point NOT crossing imaginary boundary. 
		local newOrder = { smallestX, smallestXY }
		
		while #upperX > 0 do
			local x, Reference = sortWithReference( upperX, function( v1, v2 ) return v1 > v2 end )
			newOrder[#newOrder + 1] = x
			newOrder[#newOrder + 1] = upperY[Reference]
			-- print( 'Upper: ', x, upperY[Reference] )
			table.remove( upperX, Reference )
			table.remove( upperY, Reference )
		end
		
		-- Step 3 (Lower Half): Start on the most-right point, connect to closest point NOT crossing imaginary boundary. 		
		newOrder[#newOrder + 1] = largestX
		newOrder[#newOrder + 1] = largestXY
		while #lowerX > 0 do
			local x, Reference = sortWithReference( lowerX, function( v1, v2 ) return v1 < v2 end )
			newOrder[#newOrder + 1] = x
			newOrder[#newOrder + 1] = lowerY[Reference]
			-- print( 'Lower: ', x, lowerY[Reference] )
			table.remove( lowerX, Reference )
			table.remove( lowerY, Reference )
		end
		
		return newOrder
	end
	
	return orderPoints( x, y )
end

local function lgprint( x, y, ... )
	local width = 0
	text = { ... }
	
	table.foreach( text, 
		function( _, str ) 
			str = tostring( str )
			love.graphics.print( str, width + x, y )
			width = width + font:getWidth( str ) + 2
			repeat 
				width = 20 * math.ceil( width / 20 )
			until width % 20 == 0
		end 
	)
	
	y = y + 12
	if y >= height then
		y = 0
		x = x + 150
	end
	return x, y
end

local function printInformation( shape, x, y )
	x, y = lgprint( x, y, shape.type )
	x, y = lgprint( x, y, '- - - - - - -' )
	x, y = lgprint( x, y, 'selected:', shape.selected )
	x, y = lgprint( x, y, 'mode:', shape.mode )
	x, y = lgprint( x, y, 'clicked:', shape.clicked )
	x, y = lgprint( x, y, 'collided:', shape.collided )
	
	x = x + 5
	if shape.type == 'polygon' then
		for i = 1, #shape.points, 2 do
			x, y = lgprint( x, y, shape.points[i] .. ', ' .. shape.points[i + 1] )
		end
	elseif shape.type == 'circle' then
		x, y = lgprint( x, y, 'x:', shape.x )
		x, y = lgprint( x, y, 'y:', shape.y )
		x, y = lgprint( x, y, 'radius:', shape.radius )
	elseif shape.type == 'line' then
		x, y = lgprint( x, y, 'x1:', shape.x1 )
		x, y = lgprint( x, y, 'y1:', shape.y1 )
		x, y = lgprint( x, y, 'x2:', shape.x2 )
		x, y = lgprint( x, y, 'y2:', shape.y2 )
	end
	return x, y + 24
end

local function checkFuzzy( number1, number2 )
	return ( number1 - .00001 <= number2 and number2 <= number1 + .00001 )
end

local function removeDuplicatePairs( tab ) 
	for index1 = #tab, 1, -1 do
		local first = tab[index1]
		for index2 = #tab, 1, -1 do
			local second = tab[index2]
			if index1 ~= index2 then
				if type( first[1] ) == 'number' and type( second[1] ) == 'number' and type( first[2] ) == 'number' and type( second[2] ) == 'number' then
					if checkFuzzy( first[1], second[1] ) and checkFuzzy( first[2], second[2] ) then
						table.remove( tab, index1 )
					end
				elseif first[1] == second[1] and first[2] == second[2] then
					table.remove( tab, index1 )
				end
			end
		end
	end
	return tab
end

local shapes
local circles
local DEBUG

function love.load()
	DEBUG = false
	shapes = {
		{ type = 'polygon', selected = false, mode = 'line', clicked = false, collided = false, offsets = {}, 
			points = generateRandomPolygon( 
				love.math.random( 3, 15 ), 
				love.math.random( 0, width / 4 ), love.math.random( 0, height / 4 ), 
				love.math.random( 100, width / 4 ), love.math.random( 100, height / 4 )
			) 
		}, 
		{ type = 'polygon', selected = false, mode = 'line', clicked = false, collided = false, offsets = {}, 
			points = generateRandomPolygon( 
				love.math.random( 3, 15 ), 
				love.math.random( width / 4, width / 2 ), love.math.random( height / 4, height / 2 ), 
				love.math.random( 100, width / 4 ), love.math.random( 100, height / 4 )
			) 
		}, 
		{ type = 'polygon', selected = false, mode = 'line', clicked = false, collided = false, offsets = {}, 
			points = generateRandomPolygon( 
				love.math.random( 3, 15 ), 
				love.math.random( width / 2, 3 * width / 4 ), love.math.random( height / 2, 3 * height / 4 ), 
				love.math.random( 100, width / 4 ), love.math.random( 100, height / 4 )
			) 
		}, 
		{ type = 'polygon', selected = false, mode = 'line', clicked = false, collided = false, offsets = {}, 
			points = generateRandomPolygon( 
				love.math.random( 3, 15 ), 
				love.math.random( width / 4, width ), love.math.random( height / 4, height ), 
				love.math.random( 100, width / 4 ), love.math.random( 100, height / 4 )
			) 
		},  
		{ type = 'circle', selected = false, mode = 'line', clicked = false, collided = false, offsets = { 0, 0 }, 
			x = love.math.random( 0, width / 4 ), 
			y = love.math.random( 0, height / 4 ), 
			radius = love.math.random( 10, 20 ), 
		}, 
		{ type = 'circle', selected = false, mode = 'line', clicked = false, collided = false, offsets = { 0, 0 }, 
			x = love.math.random( width / 4, width / 2 ), 
			y = love.math.random( height / 4, height / 2 ), 
			radius = love.math.random( 10, 20 ), 
		},
		{ type = 'circle', selected = false, mode = 'line', clicked = false, collided = false, offsets = { 0, 0 }, 
			x = love.math.random( width / 2, 3 * width / 4 ), 
			y = love.math.random( height / 2, 3 * height / 4 ), 
			radius = love.math.random( 10, 20 ), 
		},
		{ type = 'circle', selected = false, mode = 'line', clicked = false, collided = false, offsets = { 0, 0 }, 
			x = love.math.random( 3 * width / 4, width ), 
			y = love.math.random( 3 * height / 4, height ), 
			radius = love.math.random( 10, 20 ), 
		},
		{ type = 'line', selected = false, clicked = false, collided = false, offsets = { 0, 0 }, 
			x1 = love.math.random( width / 8, width / 4 ), 
			y1 = love.math.random( height / 8, height / 4 ), 
			x2 = love.math.random( width / 8, width / 4 ), 
			y2 = love.math.random( height / 8, height / 4 ), 
		}, 
		{ type = 'line', selected = false, clicked = false, collided = false, offsets = { 0, 0 }, 
			x1 = love.math.random( 3 * width / 4, 7 * width / 8 ), 
			y1 = love.math.random( 3 * height / 4, 7 * height / 8 ),  
			x2 = love.math.random( 3 * width / 4, 7 * width / 8 ), 
			y2 = love.math.random( 3 * height / 4, 7 * height / 8 ), 
		}
	}
	for _, shape in ipairs( shapes ) do
		if shape.type == 'polygon' then
			if #shape.points < 6 then error( #shape.points ) end
			shape.triangles = love.math.triangulate( shape.points )
			for i = 1, #shape.points do
				shape.offsets[i] = 0
			end
		end
	end
	
	love.graphics.setLineWidth( 2 )
end

function love.update( dt )
	local mx, my = love.mouse.getPosition()
	circles = {}
	
	for i, shape in ipairs( shapes ) do
		if shape.selected then shape.mode = 'fill' 
		else shape.mode = 'line' end
		
		if shape.type == 'circle' then
			if shape.clicked then
				shape.x = mx + shape.offsets[1]
				shape.y = my + shape.offsets[2]
			end
			if mlib.circle.checkPoint( mx, my, shape.x, shape.y, shape.radius ) then
				shape.selected = true
			else
				shape.selected = false
			end
		elseif shape.type == 'polygon' then
			if shape.clicked then
				for i = 1, #shape.offsets, 2 do
					shape.points[i] = mx + shape.offsets[i]
					shape.points[i + 1] = my + shape.offsets[i + 1]
				end
				shape.triangles = love.math.triangulate( shape.points )
			end
			if mlib.polygon.checkPoint( mx, my, shape.points ) then shape.selected = true
			else shape.selected = false end
		elseif shape.type == 'line' then
			if shape.clicked then 
				shape.x1 = mx + shape.offsets[1]
				shape.y1 = my + shape.offsets[2]
				shape.x2 = mx + shape.offsets[3]
				shape.y2 = my + shape.offsets[4]
			end
		end
		
		local intersection = false
		for ii, shape2 in ipairs( shapes ) do
			if i ~= ii then
				if shape.type == 'polygon' then
					if shape2.type == 'polygon' then
						local intersections = mlib.polygon.getPolygonIntersection( shape.points, shape2.points )
						if intersections then
							intersection = true
							shape.collided = true
							shape2.collided = true
							for i = 1, #intersections do
								circles[#circles + 1] = intersections[i]
							end
						end
					elseif shape2.type == 'circle' then
						local intersections = mlib.polygon.getCircleIntersection( shape2.x, shape2.y, shape2.radius, shape.points )
						if intersections then
							intersection = true
							shape.collided = true
							shape2.collided = true
							for i = 1, #intersections do
								table.remove( intersections[i], 1 )
								circles[#circles + 1] = intersections[i]
							end
						end
					elseif shape2.type == 'line' then
						local intersections = mlib.polygon.getSegmentIntersection( shape2.x1, shape2.y1, shape2.x2, shape2.y2, shape.points )
						if intersections then
							intersection = true
							shape.collided = true
							shape2.collided = true
							for i = 1, #intersections do
								circles[#circles + 1] = intersections[i]
							end
						end
					end
				elseif shape.type == 'circle' then
					if shape2.type == 'polygon' then
						local intersections = mlib.polygon.getCircleIntersection( shape.x, shape.y, shape.radius, shape2.points )
						if intersections then
							intersection = true
							shape.collided = true
							shape2.collided = true
							for i = 1, #intersections do
								for ii = 2, #intersections[i], 2 do
									circles[#circles + 1] = { intersections[i][ii], intersections[i][ii + 1] }
								end
							end
						end
					elseif shape2.type == 'circle' then
						local _, x1, y1, x2, y2 = mlib.circle.getCircleIntersection( shape.x, shape.y, shape.radius, shape2.x, shape2.y, shape2.radius )
						if x1 then
							intersection = true
							shape.collided = true
							shape2.collided = true
							if x2 then
								circles[#circles + 1] = { x2, y2 }
							end
							circles[#circles + 1] = { x1, y1 }
						end
					elseif shape2.type == 'line' then
						local _, x1, y1, x2, y2 = mlib.circle.getSegmentIntersection( shape.x, shape.y, shape.radius, shape2.x1, shape2.y1, shape2.x2, shape2.y2 )
						if x1 then
							intersection = true
							shape.collided = true
							shape2.collided = true
							if x2 then
								circles[#circles + 1] = { x2, y2 }
							end
							circles[#circles + 1] = { x1, y1 }
						end
					end
				elseif shape.type == 'line' then
					if shape2.type == 'polygon' then
						local intersections = mlib.polygon.getSegmentIntersection( shape.x1, shape.y1, shape.x2, shape.y2, shape2.points )
						if intersections then
							intersection = true
							shape2.collided = true
							shape.collided = true
							for i = 1, #intersections do
								circles[#circles + 1] = intersections[i]
							end
						end
					elseif shape2.type == 'circle' then
						local _, x1, y1, x2, y2 = mlib.circle.getSegmentIntersection( shape2.x, shape2.y, shape2.radius, shape.x1, shape.y1, shape.x2, shape.y2 )
						if x1 then
							intersection = true
							shape2.collided = true
							shape.collided = true
							if x2 then
								circles[#circles + 1] = { x2, y2 }
							end
							circles[#circles + 1] = { x1, y1 }
						end
					elseif shape2.type == 'line' then
						local x1, y1, x2, y2 = mlib.segment.getIntersection( shape.x1, shape.y1, shape.x2, shape.y2, shape2.x1, shape2.y1, shape2.x2, shape2.y2 )
						if x1 then
							intersection = true
							shape2.collided = true
							shape.collided = true
							if x2 then
								circles[#circles + 1] = { x2, y2 }
							end
							circles[#circles + 1] = { x1, y1 }
						end
					end
				end
			end
		end
		if not intersection then shape.collided = false end
	end
end

function love.draw()
	local x, y = 0, 0
	
	for _, shape in ipairs( shapes ) do
		if shape.collided then love.graphics.setColor( 255, 0, 0, 255 ) 
		else love.graphics.setColor( 255, 255, 255, 255 ) end
		
		if shape.type == 'circle' then
			love.graphics.circle( shape.mode, shape.x, shape.y, shape.radius )
		elseif shape.type == 'polygon' then
			if shape.mode == 'line' then
				love.graphics.polygon( 'line', shape.points )
			elseif shape.mode == 'fill' then
				for i = 1, #shape.triangles do
					love.graphics.polygon( 'fill', shape.triangles[i] )
				end
			end
		elseif shape.type == 'line' then
			love.graphics.line( shape.x1, shape.y1, shape.x2, shape.y2 )
		end
		
		love.graphics.setColor( 255, 255, 255, 255 )
		if DEBUG then x, y = printInformation( shape, x, y ) end
	end
	
	circles = removeDuplicatePairs( circles )
	if DEBUG then
		x, y = lgprint( x, y, 'INTERSECTIONS:' )
		x, y = lgprint( x, y, '- - - - - - -' )
		for _, circle in ipairs( circles ) do
			x, y = lgprint( x, y, circle[1] .. ', ' .. circle[2] )
		end
	end
	
	love.graphics.setColor( 255, 255, 0, 255 )
	for _, circle in ipairs( circles ) do
		love.graphics.circle( 'fill', circle[1], circle[2], 3 )
	end
	
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.print( love.timer.getFPS(), 780 )
end

function love.mousepressed( x, y, button )
	for _, shape in ipairs( shapes ) do
		if shape.type == 'circle' then
			if shape.selected then 
				shape.clicked = true
				shape.offsets[1] = shape.x - x
				shape.offsets[2] = shape.y - y
			end
		elseif shape.type == 'polygon' then
			if shape.selected then
				shape.clicked = true
				
				local offsets = {}
				for i = 1, #shape.points, 2 do
					table.insert( offsets, shape.points[i] - x )
					table.insert( offsets, shape.points[i + 1] - y )
				end
				shape.offsets = offsets
			end
		elseif shape.type == 'line' then
			if mlib.segment.checkPoint( x, y, shape.x1, shape.y1, shape.x2, shape.y2 ) then
				shape.clicked = true
				shape.offsets = {
					shape.x1 - x, 
					shape.y1 - y, 
					shape.x2 - x, 
					shape.y2 - y, 
				}
			end
		end
	end
end

function love.mousereleased( x, y, button )
	for a = 1, #shapes do
		shapes[a].clicked = false
	end
end

function love.keypressed( key )
	if key == 'escape' then love.event.quit() 
	elseif key == '`' then -- Enable debugging mode.
		DEBUG = not DEBUG
	elseif key ~= 'printscreen' and key ~= 'lctrl' -- Take pictures for debugging. 
	and key ~= 'lalt' and key ~= 'tab' then -- Switch between views without changing view.
		love.load()
	end
end
