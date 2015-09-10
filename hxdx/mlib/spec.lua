-- run using 'lua tsc -f spec.lua'
require 'telescope'
local _ = require 'mlib'

context( 'mlib', function()
	before( function() end )
	after( function() end )

	local function check_fuzzy( a, b )
		return ( a - .00001 <= b and b <= a + .00001 )
	end

	local function DeepCompare( Table1, Table2 )
		if type( Table1 ) ~= type( Table2 ) then return false end

		for Key, Value in pairs( Table1 ) do
			if ( type( Value ) == 'table' and type( Table2[Key] ) == 'table' ) then
				if ( not DeepCompare( Value, Table2[Key] ) ) then return false end
			else
				if type( Value ) ~= type( Table2[Key] ) then return false end
				if type( Value ) == 'number' then
					return check_fuzzy( Value, Table2[Key] )
				elseif ( Value ~= Table2[Key] ) then return false end
			end
		end
		for Key, Value in pairs( Table2 ) do
			if ( type( Value ) == 'table' and type( Table1[Key] ) == 'table' ) then
				if ( not DeepCompare( Value, Table1[Key] ) ) then return false end
			else
				if type( Value ) ~= type( Table1[Key] ) then return false end
				if type( Value ) == 'number' then
					return check_fuzzy( Value, Table1[Key] )
				elseif ( Value ~= Table1[Key] ) then return false end
			end
		end
		return true
	end

	make_assertion( 'fuzzy_equal', 'fuzzy values to be equal to each other',
		function( a, b )
			return check_fuzzy( a, b )
		end
	)

	make_assertion( 'multiple_fuzzy_equal', 'all fuzzy values to equal respective fuzzy value',
		function( a, b )
			for i = 1, #a do
				if type( a[i] ) ~= 'number' then
					if a[i] ~= b[i] then return false end
				else
					if not check_fuzzy( a[i], b[i] ) then
						return false
					end
				end
			end
			return true
		end
	)

	make_assertion( 'tables_fuzzy_equal', 'all table values are equal',
		function( Table1, Table2 )
			return DeepCompare( Table1, Table2 )
		end
	)

    context( 'point', function()
        context( 'rotate', function()
            test( 'Gives the rotated point.', function()
                assert_multiple_fuzzy_equal( { _.point.rotate( 1, 2, math.pi ) }, { -1, -2 } )
                assert_multiple_fuzzy_equal( { _.point.rotate( 5, 10, 2 * math.pi ) }, { 5, 10 } )
                assert_multiple_fuzzy_equal( { _.point.rotate( 2, 2, -math.pi / 6 ) }, { 02.7320508075600003, .7320508075600001 } )
            end )

            test( 'Rotate about other point.', function()
                assert_multiple_fuzzy_equal( { _.point.rotate( 2, 3, math.pi / 2, 2, -2 ) }, { -3, -2 } )
                assert_multiple_fuzzy_equal( { _.point.rotate( -6, 1, math.pi, -1, 2 ) }, { 4, 3 } )
            end )
        end )

        context( 'scale', function()
            test( 'Gives the scaled point.', function()
                assert_multiple_fuzzy_equal( { _.point.scale( -2, -2, 2 ) }, { -4, -4 } )
                assert_multiple_fuzzy_equal( { _.point.scale( 6, -3, 1/3 ) }, { 2, -1 } )
            end )

            test( 'Scale about other point.', function()
                assert_multiple_fuzzy_equal( { _.point.scale( 2, 4, .5, -2, -2 ) }, { 0, 1 } )
                assert_multiple_fuzzy_equal( { _.point.scale( 5, -1, 5/3, -4, -4 ) }, { 11, 1 } )
                assert_multiple_fuzzy_equal( { _.point.scale( 6, 4, 4/5, 5, -1 ) }, { 5.8, 3 } )
            end )
        end )
    end )

	context( 'line', function()
		context( 'getLength', function()
			test( 'Gives the length of a line.', function()
				assert_fuzzy_equal( _.line.getLength( 1, 1, 1, 2 ), 1 )
				assert_fuzzy_equal( _.line.getLength( 0, 0, 1, 0 ), 1 )
				assert_fuzzy_equal( _.line.getLength( 4, 4, 7, 8 ), 5 )
				assert_fuzzy_equal( _.line.getLength( 9.3, 7.6, -12, .001 ), 22.61492 )
				assert_fuzzy_equal( _.line.getLength( 4.2, 4.134, 7.2342, -78 ), 82.190025 )
			end )
		end )

		context( 'getDistance', function()
			test( 'Alias for getLength.', function()
				assert_fuzzy_equal( _.line.getDistance( 1, 1, 1, 2 ), _.line.getLength( 1, 1, 1, 2 ) )
				assert_fuzzy_equal( _.line.getDistance( 0, 0, 1, 0 ), _.line.getLength( 0, 0, 1, 0 ) )
				assert_fuzzy_equal( _.line.getDistance( 4, 4, 7, 8 ), _.line.getLength( 4, 4, 7, 8 ) )
				assert_fuzzy_equal( _.line.getDistance( 9.3, 7.6, -12, .001 ), _.line.getLength( 9.3, 7.6, -12, .001 ) )
				assert_fuzzy_equal( _.line.getDistance( 4.2, 4.134, 7.2342, -78 ), _.line.getLength( 4.2, 4.134, 7.2342, -78 ) )
			end )
		end )

		context( 'getMidpoint', function()
			test( 'Gives the midpoint of a line.', function()
				assert_multiple_fuzzy_equal( { _.line.getMidpoint( 0, 0, 2, 2 ) }, { 1, 1 } )
				assert_multiple_fuzzy_equal( { _.line.getMidpoint( 4, 4, 7, 8 ) }, { 5.5, 6 } )
				assert_multiple_fuzzy_equal( { _.line.getMidpoint( -1, 2, 3, -6 ) }, { 1, -2 } )
				assert_multiple_fuzzy_equal( { _.line.getMidpoint( 6.4, 3, -10.7, 4 ) }, { -2.15, 3.5 } )
				assert_multiple_fuzzy_equal( { _.line.getMidpoint( 3.14159, 3.14159, 2.71828, 2.71828 ) }, { 2.92993, 2.92993 } )
			end )
		end )

		context( 'getSlope', function()
			test( 'Gives the slope of a line given two points.', function()
				assert_fuzzy_equal( _.line.getSlope( 1, 1, 2, 2 ), 1 )
				assert_fuzzy_equal( _.line.getSlope( 1, 1, 0, 1 ), 0 )
				assert_fuzzy_equal( _.line.getSlope( 1, 0, 0, 1 ), -1 )
			end )

			test( 'Returns false if the slope is vertical.', function()
				assert_false( _.line.getSlope( 1, 0, 1, 5 ) )
				assert_false( _.line.getSlope( -4, 9, -4, 13423 ) )
			end )
		end )

		context( 'getPerpendicularSlope', function()
			test( 'Gives the perpendicular slope given two points.', function()
				assert_fuzzy_equal( _.line.getPerpendicularSlope( 1, 1, 2, 2 ), -1 )
			end )

			test( 'Gives the perpendicular slope given the slope.', function()
				assert_fuzzy_equal( _.line.getPerpendicularSlope( 2 ), -.5 )
			end )

			test( 'Gives the perpendicular slope if the initial line is vertical.', function()
				assert_fuzzy_equal( _.line.getPerpendicularSlope( 1, 0, 1, 5 ), 0 )
				assert_fuzzy_equal( _.line.getPerpendicularSlope( false ), 0 )
			end )

			test( 'Returns false if the initial slope is horizontal.', function()
				assert_false( _.line.getPerpendicularSlope( 0, 0, 5, 0 ) )
			end )
		end )

		context( 'getYIntercept', function()
			test( 'Gives the y-intercept, false given two non-vertical points.', function()
				assert_multiple_fuzzy_equal( { _.line.getYIntercept( 0, 0, 1, 1 ) }, { 0, false } )
				assert_multiple_fuzzy_equal( { _.line.getYIntercept( 2, 3, 4, 9 ) }, { -3, false } )
			end )

			test( 'Gives the y-intercept given one point and the slope.', function()
				assert_multiple_fuzzy_equal( { _.line.getYIntercept( 0, 0, 1 ) }, { 0, false } )
			end )

			test( 'Returns the x, true if the slope is false.', function()
				assert_multiple_fuzzy_equal( { _.line.getYIntercept( 1, 0, 1, 5 ) }, { 1, true } )
				assert_multiple_fuzzy_equal( { _.line.getYIntercept( 0, 0, false ) }, { 0, true } )
			end )
		end )

		context( 'getIntersection', function()
			test( 'Given the slope, y-intercept, and two points of other line.', function()
				assert_multiple_fuzzy_equal( { _.line.getIntersection( 1, 0, 1, 0, 0, 1 ) }, { .5, .5 } )
			end )

			test( 'Given the slope, y-intercept, the other slope and y-intercept.', function()
				assert_multiple_fuzzy_equal( { _.line.getIntersection( 1, 0, -1, 1 ) }, { .5, .5 } )
			end )

			test( 'Given two points on one line and two on the other.', function()
				assert_multiple_fuzzy_equal( { _.line.getIntersection( 1, 1, 0, 0, 1, 0, 0, 1 ) }, { .5, .5 } )
			end )

			test( 'Works for vertical lines.', function()
				assert_multiple_fuzzy_equal( { _.line.getIntersection( 1, 0, 1, 5, 2, 2, 0, 2 ) }, { 1, 2 } )
			end )

			test( 'Returns false if the lines are parallel and don\'t intersect.', function()
				assert_false( _.line.getIntersection( 2, 4, 2, 7 ) )
			end )

			test( 'Works with collinear lines.', function()
				assert_true( _.line.getIntersection( 0, 0, 2, 2, 1, 1, 3, 3 ) )
			end )
		end )

		context( 'getClosestPoint', function()
			test( 'Given the point and two points on the line.', function()
				assert_multiple_fuzzy_equal( { _.line.getClosestPoint( 4, 2, 1, 1, 3, 5 ) }, { 2, 3 } )
				assert_multiple_fuzzy_equal( { _.line.getClosestPoint( 3, 5, 3, 0, 2, 2 ) }, { 1, 4 } )
				assert_multiple_fuzzy_equal( { _.line.getClosestPoint( -1, 3, -2, 0, 2, 2 ) }, { 0, 1 } )
			end )

			test( 'Given the the point and the slope and y-intercept.', function()
				assert_multiple_fuzzy_equal( { _.line.getClosestPoint( 4, 2, 2, -1 ) }, { 2, 3 } )
				assert_multiple_fuzzy_equal( { _.line.getClosestPoint( -1, 3, .5, 1 ) }, { 0, 1 } )
			end )
		end )

		context( 'getSegmentIntersection', function()
			test( 'Given the end points of the segment and 2 points on the line.', function()
				assert_multiple_fuzzy_equal( { _.line.getSegmentIntersection( 3, 6, 5, 8, 3, 8, 5, 6 ) }, { 4, 7 } )
				assert_multiple_fuzzy_equal( { _.line.getSegmentIntersection( 0, 0, 4, 4, 0, 4, 4, 0 ) }, { 2, 2 } )
			end )

			test( 'Given end points of the segment and the slope and intercept.', function()
				assert_multiple_fuzzy_equal( { _.line.getSegmentIntersection( 3, 6, 5, 8, -1, 11 ) }, { 4, 7 } )
			end )

			test( 'Returns false if they don\'t intersect.', function()
				assert_false( _.line.getSegmentIntersection( 0, 0, 1, 1, 0, 4, 4, 0 ) )
				assert_false( _.line.getSegmentIntersection( 0, 0, 1, 1, -1, 4 ) )
			end )

			test( 'Works with collinear lines.', function()
				assert_multiple_fuzzy_equal( { _.line.getSegmentIntersection( 0, 0, 2, 2, -1, -1, 3, 3 ) }, { 0, 0, 2, 2 } )
			end )
		end )

		context( 'checkPoint', function()
			test( 'Returns true if the point is on the line.', function()
				assert_true( _.line.checkPoint( 1, 1, 0, 0, 2, 2 ) )
				assert_true( _.line.checkPoint( 3, 10, 0, 1, 1, 4 ) )
			end )

			test( 'Returns false if the point is on the line.', function()
				assert_false( _.line.checkPoint( 4, 5, 1, 0, 6, 3 ) )
			end )

			test( 'Works with vertical lines.', function()
				assert_true( _.line.checkPoint( 1, 1, 1, 0, 1, 2 ) )
				assert_false( _.line.checkPoint( 2, 4, 1, 0, 1, 2 ) )
			end )
		end )

		context( 'getCircleIntersection', function()
			test( 'Returns \'Secant\' when intersects twice.', function()
				assert_multiple_fuzzy_equal( { _.line.getCircleIntersection( 4, 9, 1, 0, 9, 6, 9 ) }, { 'secant', 3, 9, 5, 9 } )
				assert_multiple_fuzzy_equal( { _.line.getCircleIntersection( 2, 2, 1, 2, 3, 3, 2 ) }, { 'secant', 2, 3, 3, 2 } )
			end )

			test( 'Returns \'Tangent\' when intersects once.', function()
				assert_multiple_fuzzy_equal( { _.line.getCircleIntersection( 4, 9, 1, 0, 8, 6, 8 ) }, { 'tangent', 4, 8 } )
				assert_multiple_fuzzy_equal( { _.line.getCircleIntersection( 2, 2, 1, 2, 3, 0, 3 ) }, { 'tangent', 2, 3 } )
			end )

			test( 'Returns \'false\' when neither.', function()
				assert_false( _.line.getCircleIntersection( 4, 9, 1, 0, 7, 6, 8 ) )
			end )
		end )

		context( 'getPolygonIntersection', function()
			test( 'Returns true if the line intersects the polygon.', function()
				local tab = _.line.getPolygonIntersection( 0, 4, 4, 4, 0, 0, 0, 4, 4, 4, 4, 0 )
				assert_tables_fuzzy_equal( tab, { { 0, 4 }, { 4, 4 } } )
				local tab2 = _.line.getPolygonIntersection( 0, 4, 4, 0, 0, 0, 0, 4, 4, 4, 4, 0 )
				assert_tables_fuzzy_equal( tab2, { { 0, 4 }, { 4, 0 } } )
			end )

			test( 'Returns false if the line does not intersect.', function()
				assert_false( _.line.getPolygonIntersection( 0, 5, 5, 5, 0, 0, 0, 4, 4, 4, 4, 0 ) )
			end )

			test( 'Works with vertical lines.', function()
				local tab = _.line.getPolygonIntersection( 0, 0, 0, 4, 0, 0, 0, 4, 4, 4, 4, 0 )
				assert_tables_fuzzy_equal( tab, { { 0, 4 }, { 0, 0 } } )
				assert_false( _.line.getPolygonIntersection( -1, 0, -1, 5, 0, 0, 0, 4, 4, 4, 4, 0 ) )
			end )
		end )

		context( 'getLineIntersection', function()
			test( 'Given the slope, y-intercept, and two points of other line.', function()
				assert_multiple_fuzzy_equal( { _.line.getLineIntersection( 1, 0, 1, 0, 0, 1 ) }, { .5, .5 } )
			end )

			test( 'Given the slope, y-intercept, the other slope and y-intercept.', function()
				assert_multiple_fuzzy_equal( { _.line.getLineIntersection( 1, 0, -1, 1 ) }, { .5, .5 } )
                assert_multiple_fuzzy_equal( { _.line.getLineIntersection( 2, -11, -1, 19 ) }, { 10, 9 } )
			end )

			test( 'Given two points on one line and two on the other.', function()
				assert_multiple_fuzzy_equal( { _.line.getLineIntersection( 1, 1, 0, 0, 1, 0, 0, 1 ) }, { .5, .5 } )
			end )

			test( 'Works for vertical lines.', function()
				assert_multiple_fuzzy_equal( { _.line.getLineIntersection( 1, 0, 1, 5, 2, 2, 0, 2 ) }, { 1, 2 } )
			end )

			test( 'Returns false if the lines are parallel and don\'t intersect.', function()
				assert_false( _.line.getLineIntersection( 2, 4, 2, 7 ) )
			end )

			test( 'Works with collinear lines.', function()
				assert_true( _.line.getLineIntersection( 0, 0, 2, 2, 1, 1, 3, 3 ) )
			end )
		end )

		context( 'segment', function()
			context( 'checkPoint', function()
				test( 'Returns true if the point is on the segment.', function()
					assert_true( _.segment.checkPoint( 1, 1, 2, 2, 0, 0 ) )
					assert_true( _.segment.checkPoint( 3, 8, 1, 4, 5, 12 ) )
					assert_true( _.segment.checkPoint( -.5, 2, -1, 4, 0, 0 ) )
				end )

				test( 'Returns false if the point is not on the segment.', function()
					assert_false( _.segment.checkPoint( 3, 1, 2, 2, 0, 0 ) )
					assert_false( _.segment.checkPoint( 3, 9, 1, 4, 5, 12 ) )
				end )
			end )

            context( 'getPerpendicularBisector', function()
                test( 'Returns the midpoint and perpendicular slope given two points.', function()
                    assert_multiple_fuzzy_equal( { _.segment.getPerpendicularBisector( 1, 1, 3, 3 ) }, { 2, 2, -1 } )
                    assert_multiple_fuzzy_equal( { _.segment.getPerpendicularBisector( 1, 0, 1, 8 ) }, { 1, 4, 0 } )
                    assert_multiple_fuzzy_equal( { _.segment.getPerpendicularBisector( 4, 4, 6, 8 ) }, { 5, 6, -.5 } )
            end )

			test( 'Returns false and midpoint if original slope is horizontal.', function()
				assert_multiple_fuzzy_equal( { _.segment.getPerpendicularBisector( 0, 0, 6, 0 ) }, { 3, 0, false } )
				assert_multiple_fuzzy_equal( { _.segment.getPerpendicularBisector( 5, 7, 10, 7 ) }, { 7.5, 7, false } )
			end )
		end )

			context( 'getIntersection', function()
				test( 'Returns the point of intersection if they do.', function()
					assert_multiple_fuzzy_equal( { _.segment.getIntersection( 1, 1, 5, 3, 2, 3, 4, 1 ) }, { 3, 2, nil, nil } )
					assert_multiple_fuzzy_equal( { _.segment.getIntersection( 0, 0, 3, 3, 0, 1, 3, 1 ) }, { 1, 1, nil, nil } )
				end )

				test( 'Returns false if they don\'t.', function()
					assert_multiple_fuzzy_equal( { _.segment.getIntersection( 3, 7, 6, 8, 1, 6, 5, 4 ) }, { false, nil, nil, nil } )
				end )

				test( 'Return x1, y1, x2, y2 if lines have same slope and intercept.', function()
					assert_multiple_fuzzy_equal( { _.segment.getIntersection( 0, 0, 2, 2, 1, 1, 3, 3 ) }, { 2, 2, 1, 1 } )
					assert_multiple_fuzzy_equal( { _.segment.getIntersection( 0, 1, 4, 1, 2, 1, 3, 1 ) }, { 2, 1, 3, 1 } )
				end )
			end )

			context( 'getCircleIntersection', function()
				test( 'Returns \'Secant\' if the line connects two points.', function()
					assert_multiple_fuzzy_equal( { _.segment.getCircleIntersection( 4, 9, 1, 0, 9, 6, 9 ) }, { 'secant', 3, 9, 5, 9 } )
				end )

				test( 'Returns \'Tangent\' if the line attaches only one point.', function()
					assert_multiple_fuzzy_equal( { _.segment.getCircleIntersection( 1, 1, 1, 0, 0, 0, 2 ) }, { 'tangent', 0, 1 } )
				end )

				test( 'Returns \'Chord\' if both points are on the circle.', function()
					assert_multiple_fuzzy_equal( { _.segment.getCircleIntersection( 0, 0, 1, -1, 0, 1, 0 ) }, { 'chord', -1, 0, 1, 0 } )
				end )

				test( 'Returns \'Enclosed\' if the line is within the circle entirely.', function()
					assert_multiple_fuzzy_equal( { _.segment.getCircleIntersection( 0, 0, 2, -1, 0, 1, 0 ) }, { 'enclosed', -1, 0, 1, 0 } )
				end )

				test( 'Returns \'false\' if the line doesn\'t touch anywhere.', function()
					assert_false( _.segment.getCircleIntersection( 0, 0, 1, 2, 2, 2, 3 ) )
				end )
			end )

			context( 'getPolygonIntersection', function()
				test( 'Returns the points of intersection.', function()
					assert_tables_fuzzy_equal( _.segment.getPolygonIntersection( 4, 2, 6, 4, 3, 4, 4, 6, 8, 4, 7, 2 ), { { 5, 3 } } )
					assert_tables_fuzzy_equal( _.segment.getPolygonIntersection( 4, 2, 8, 6, 3, 4, 4, 6, 8, 4, 7, 2 ), { { 6.66666, 4.66666 }, { 5, 3 } } )
					assert_false( _.segment.getPolygonIntersection( 0, 0, 0, 1, 3, 4, 4, 6, 8, 4, 7, 2 ) )
				end )

				test( 'Works with collinear lines.', function()
					assert_tables_fuzzy_equal( _.segment.getPolygonIntersection( 2, 7, 10, 3, 3, 4, 4, 6, 8, 4, 7, 2 ), { { 4, 6 }, { 8, 4 } } )
					assert_false( _.segment.getPolygonIntersection( 2, 7, 0, 8, 3, 4, 4, 6, 8, 4, 7, 2 ) )
				end )

				test( 'Works with vertical lines (on poly. and/or segment).', function()
					assert_tables_fuzzy_equal( _.segment.getPolygonIntersection( 6, 2, 6, 6, 3, 4, 4, 6, 8, 4, 7, 2 ), { { 6, 2.5 }, { 6, 5 } } )
					assert_tables_fuzzy_equal( _.segment.getPolygonIntersection( 6, 4, 10, 4, 3, 4, 4, 6, 8, 5, 8, 3 ), { { 8, 4 } } )
					assert_tables_fuzzy_equal( _.segment.getPolygonIntersection( 8, 1, 8, 4, 3, 4, 4, 6, 8, 5, 8, 3 ), { { 8, 3, 8, 4 } } )
					assert_false( _.segment.getPolygonIntersection( 1, 0, 1, 5, 3, 4, 4, 6, 8, 5, 8, 3 ) )
				end )
			end )

			context( 'getLineIntersection', function()
				test( 'Given the end points of the segment and 2 points on the line.', function()
					assert_multiple_fuzzy_equal( { _.segment.getLineIntersection( 3, 6, 5, 8, 3, 8, 5, 6 ) }, { 4, 7 } )
					assert_multiple_fuzzy_equal( { _.segment.getLineIntersection( 0, 0, 4, 4, 0, 4, 4, 0 ) }, { 2, 2 } )
				end )

				test( 'Given end points of the segment and the slope and intercept.', function()
					assert_multiple_fuzzy_equal( { _.segment.getLineIntersection( 3, 6, 5, 8, -1, 11 ) }, { 4, 7 } )
				end )

				test( 'Returns false if they don\'t intersect.', function()
					assert_false( _.segment.getLineIntersection( 0, 0, 1, 1, 0, 4, 4, 0 ) )
					assert_false( _.segment.getLineIntersection( 0, 0, 1, 1, -1, 4 ) )
				end )

				test( 'Works with collinear lines.', function()
					assert_multiple_fuzzy_equal( { _.segment.getLineIntersection( 0, 0, 2, 2, -1, -1, 3, 3 ) }, { 0, 0, 2, 2 } )
				end )
			end )

			context( 'getSegmentIntersection', function()
				test( 'Returns the point of intersection if they do.', function()
					assert_multiple_fuzzy_equal( { _.segment.getSegmentIntersection( 1, 1, 5, 3, 2, 3, 4, 1 ) }, { 3, 2, nil, nil } )
					assert_multiple_fuzzy_equal( { _.segment.getSegmentIntersection( 0, 0, 3, 3, 0, 1, 3, 1 ) }, { 1, 1, nil, nil } )
				end )

				test( 'Returns false if they don\'t.', function()
					assert_multiple_fuzzy_equal( { _.segment.getSegmentIntersection( 3, 7, 6, 8, 1, 6, 5, 4 ) }, { false, nil, nil, nil } )
				end )

				test( 'Return x1, y1, x2, y2 if lines have same slope and intercept.', function()
					assert_multiple_fuzzy_equal( { _.segment.getSegmentIntersection( 0, 0, 2, 2, 1, 1, 3, 3 ) }, { 2, 2, 1, 1 } )
					assert_multiple_fuzzy_equal( { _.segment.getSegmentIntersection( 0, 1, 4, 1, 2, 1, 3, 1 ) }, { 2, 1, 3, 1 } )
				end )
			end )

			context( 'isSegmentCompletelyInsidePolygon', function()
				test( 'Returns if a segment is completely inside of a polygon.', function()
					assert_true( _.segment.isSegmentCompletelyInsidePolygon( 0, .5, .5, 0, -.5, -.5, -1, -.5, -1, .5, -.5, .5, -.5, 1, .5, 1, .5, .5, 1, .5, 1, -.5, .5, -.5, .5, -1 ) )
					assert_false( _.segment.isSegmentCompletelyInsidePolygon( 1.5, 1, 1, 1, -.5, -.5, -1, -.5, -1, .5, -.5, .5, -.5, 1, .5, 1, .5, .5, 1, .5, 1, -.5, .5, -.5, .5, -1 ) )
					assert_false( _.segment.isSegmentCompletelyInsidePolygon( 1, .5, .5, 1, -.5, -.5, -1, -.5, -1, .5, -.5, .5, -.5, 1, .5, 1, .5, .5, 1, .5, 1, -.5, .5, -.5, .5, -1 ) )
				end )
			end )

			context( 'isSegmentCompletelyInsideCircle', function()
				test( 'Returns if a segment is completely within a circle.', function()
					assert_true( _.segment.isSegmentCompletelyInsideCircle( 3, 3, 2, 2, 2, 3, 4 ) )
					assert_false( _.segment.isSegmentCompletelyInsideCircle( 3, 3, 2, 1, 1, 3, 4 ) )
					assert_false( _.segment.isSegmentCompletelyInsideCircle( 3, 3, 2, 1, 1, -1, -1 ) )
				end )
			end )
		end )
	end )

	context( 'polygon', function()
		context( 'getTriangleHeight', function()
			test( 'Given points of triangle and length of base.', function()
				assert_multiple_fuzzy_equal( { _.polygon.getTriangleHeight( 3, 0, 0, 0, 4, 3, 0 ) }, { 4, 6 } )
				assert_multiple_fuzzy_equal( { _.polygon.getTriangleHeight( 6, -2, 1, 2, 4, 4, 1 ) }, { 3, 9 } )
				assert_multiple_fuzzy_equal( { _.polygon.getTriangleHeight( 3, 1, 1, 3, 4, 0, 4 ) }, { 3, 4.5 } )
			end )

			test( 'Given the length of the base and the area.', function()
				assert_fuzzy_equal( _.polygon.getTriangleHeight( 3, 6 ), 4 )
				assert_fuzzy_equal( _.polygon.getTriangleHeight( 6, 9 ), 3 )
			end )
		end )

		context( 'getSignedArea', function()
			test( 'Gives the sigend area of the shape. Positive if clockwise.', function()
				assert_fuzzy_equal( _.polygon.getSignedArea( 0, 0, 3, 0, 3, 4, 0, 4 ), 12 )
				assert_fuzzy_equal( _.polygon.getSignedArea( 0, 0, 3, 0, 0, 4 ), 6 )
				assert_fuzzy_equal( _.polygon.getSignedArea( 4, 4, 0, 4, 0, 0, 4, 0 ), 16 )
			end )

			test( 'Negative if counter clock-wise.', function()
				assert_fuzzy_equal( _.polygon.getSignedArea( 0, 0, 0, 4, 3, 4, 3, 0 ), -12 )
				assert_fuzzy_equal( _.polygon.getSignedArea( 0, 0, 0, 4, 3, 0 ), -6 )
			end )
		end )

		context( 'getArea', function()
			test( 'Gives the sigend area of the shape. Positive if clockwise.', function()
				assert_fuzzy_equal( _.polygon.getArea( 0, 0, 3, 0, 3, 4, 0, 4 ), 12 )
				assert_fuzzy_equal( _.polygon.getArea( 0, 0, 3, 0, 0, 4 ), 6 )
				assert_fuzzy_equal( _.polygon.getArea( 4, 4, 0, 4, 0, 0, 4, 0 ), 16 )
			end )

			test( 'Gives the area of the shape. Negative if counter clock-wise.', function()
				assert_fuzzy_equal( _.polygon.getArea( 0, 0, 0, 4, 3, 4, 3, 0 ), 12 )
				assert_fuzzy_equal( _.polygon.getArea( 0, 0, 0, 4, 3, 0 ), 6 )
			end )
		end )

		context( 'getCentroid', function()
			test( 'Gives the x and y of the centroid.', function()
				assert_multiple_fuzzy_equal( { _.polygon.getCentroid( 0, 0, 0, 4, 4, 4, 4, 0 ) }, { 2, 2 } )
				assert_multiple_fuzzy_equal( { _.polygon.getCentroid( 0, 0, 0, 6, 3, 0 ) }, { 1, 2 } )
				assert_multiple_fuzzy_equal( { _.polygon.getCentroid( 2, -1, 2, 1, 1, 2, -1, 2, -2, 1, -2, -1, -1, -2, 1, -2 ) }, { 0, 0 } )
				assert_multiple_fuzzy_equal( { _.polygon.getCentroid( 2, 0, 3, 0, 4, 1, 3, 2, 2, 2, 1, 1 ) }, { 2.5, 1 } )
				assert_multiple_fuzzy_equal( { _.polygon.getCentroid( 3, 5, 2, 2, 4, 2 ) }, { 3, 3 } )
			end )
		end )

		context( 'checkPoint', function()
			test( 'Returns true if the point is in the polygon.', function()
				assert_true( _.polygon.checkPoint( 2, 2, 0, 0, 0, 4, 4, 4, 4, 0 ) )
				assert_true( _.polygon.checkPoint( 1, 1, 0, 0, 2, 0, 2, 2, 0, 2 ) )
				assert_true( _.polygon.checkPoint( 3, 2, 2, 2, 3, 1, 4, 3, 5, 2, 4, 4 ) )
			end )

			test( 'Returns false if the point is not.', function()
				assert_false( _.polygon.checkPoint( 7, 8, 0, 0, 0, 4, 4, 4, 4, 0 ) )
				assert_false( _.polygon.checkPoint( -1, 1, 0, 0, 2, 0, 2, 2, 0, 2 ) )
			end )

			test( 'Works with vertices.', function()
				assert_true( _.polygon.checkPoint( 5, 2, 3, 2, 2, 3, 4, 3, 6, 2, 7, 2, 6, 0, 4, 1, 4, 2 ) )
				assert_false( _.polygon.checkPoint( 2, 2, 3, 2, 2, 3, 4, 3, 6, 2, 7, 2, 6, 0, 4, 1, 4, 2 ) )
			end )
		end )

		context( 'getLineIntersection', function()
			test( 'Returns true if the line intersects the polygon.', function()
				local tab = _.polygon.getLineIntersection( 0, 4, 4, 4, 0, 0, 0, 4, 4, 4, 4, 0 )
				assert_tables_fuzzy_equal( tab, { { 0, 4 }, { 4, 4 } } )
				local tab2 = _.polygon.getLineIntersection( 0, 4, 4, 0, 0, 0, 0, 4, 4, 4, 4, 0 )
				assert_tables_fuzzy_equal( tab2, { { 0, 4 }, { 4, 0 } } )
			end )

			test( 'Returns false if the line does not intersect.', function()
				assert_false( _.polygon.getLineIntersection( 0, 5, 5, 5, 0, 0, 0, 4, 4, 4, 4, 0 ) )
			end )

			test( 'Works with vertical lines.', function()
				local tab = _.polygon.getLineIntersection( 0, 0, 0, 4, 0, 0, 0, 4, 4, 4, 4, 0 )
				assert_tables_fuzzy_equal( tab, { { 0, 4 }, { 0, 0 } } )
				assert_false( _.polygon.getLineIntersection( -1, 0, -1, 5, 0, 0, 0, 4, 4, 4, 4, 0 ) )
			end )
		end )

		context( 'getSegmentIntersection', function()
			test( 'Returns the points of intersection.', function()
				assert_tables_fuzzy_equal( _.polygon.getSegmentIntersection( 4, 2, 6, 4, 3, 4, 4, 6, 8, 4, 7, 2 ), { { 5, 3 } } )
				assert_tables_fuzzy_equal( _.polygon.getSegmentIntersection( 4, 2, 8, 6, 3, 4, 4, 6, 8, 4, 7, 2 ), { { 6.66666, 4.66666 }, { 5, 3 } } )
				assert_false( _.polygon.getSegmentIntersection( 0, 0, 0, 1, 3, 4, 4, 6, 8, 4, 7, 2 ) )
			end )

			test( 'Works with collinear lines.', function()
				assert_tables_fuzzy_equal( _.polygon.getSegmentIntersection( 2, 7, 10, 3, 3, 4, 4, 6, 8, 4, 7, 2 ), { { 4, 6 }, { 8, 4 } } )
				assert_false( _.polygon.getSegmentIntersection( 2, 7, 0, 8, 3, 4, 4, 6, 8, 4, 7, 2 ) )
			end )

			test( 'Works with vertical lines (on poly. and/or segment).', function()
				assert_tables_fuzzy_equal( _.polygon.getSegmentIntersection( 6, 2, 6, 6, 3, 4, 4, 6, 8, 4, 7, 2 ), { { 6, 2.5 }, { 6, 5 } } )
				assert_tables_fuzzy_equal( _.polygon.getSegmentIntersection( 6, 4, 10, 4, 3, 4, 4, 6, 8, 5, 8, 3 ), { { 8, 4 } } )
				assert_tables_fuzzy_equal( _.polygon.getSegmentIntersection( 8, 1, 8, 4, 3, 4, 4, 6, 8, 5, 8, 3 ), { { 8, 3, 8, 4 } } )
				assert_false( _.polygon.getSegmentIntersection( 1, 0, 1, 5, 3, 4, 4, 6, 8, 5, 8, 3 ) )
			end )
		end )

		context( 'isSegmentInside', function()
			test( 'Returns true if the segment is fully inside the polygon.', function()
				assert_true( _.polygon.isSegmentInside( 4, 4, 4, 5, 4, 3, 2, 5, 3, 6, 5, 6, 6, 5 ) )
				assert_false( _.polygon.isSegmentInside( 6, 3, 7, 6, 4, 3, 2, 5, 3, 6, 5, 6, 6, 5 ) )
			end )

			test( 'True if at least part of the segment is on/inside.', function()
				assert_true( _.polygon.isSegmentInside( 6, 3, 4, 5, 4, 3, 2, 5, 3, 6, 5, 6, 6, 5 ) )
			end )
		end )

		context( 'getPolygonIntersection', function()
			test( 'Returns true if the polygons intersect.', function()
				local tab = _.polygon.getPolygonIntersection( { 2, 6, 3, 8, 4, 6 }, { 3, 7, 2, 9, 4, 9 } )
				assert_tables_fuzzy_equal( tab, { { 2.75, 7.5 }, { 3.25, 7.5 } } )
				tab = _.polygon.getPolygonIntersection( { 3, 5, 4, 4, 3, 3, 2, 3, 1, 4, 1, 2, 3, 2, 5, 4, 3, 6, 1, 6 }, { 0, 6, 4, 5, 2, 4 } )
				assert_tables_fuzzy_equal( tab, { { 3.33333, 4.66666 }, { 4, 5 }, { 2, 5.5 } } )
			end )

			test( 'Returns false if the polygons don\'t intersect.', function()
				assert_false( _.polygon.getPolygonIntersection( { 2, 6, 3, 8, 4, 6 }, { 4, 7, 3, 9, 5, 9 } ) )
				assert_false( _.polygon.getPolygonIntersection( { 3, 5, 4, 4, 3, 3, 2, 3, 1, 4, 1, 2, 3, 2, 5, 4, 3, 6, 1, 6 }, { 0, 6, 3, 4, 2, 4 } ) )
			end )

			test( 'Works with vertical lines.', function()
				local tab = _.polygon.getPolygonIntersection( { 2, 3, 2, 6, 4, 6, 4, 4, 5, 5, 5, 3 }, { 3, 2, 3, 5, 6, 4, 6, 3, 4, 3, 4, 2 } )
				assert_tables_fuzzy_equal( tab, { { 4, 4.66666 }, { 4.5, 4.5 }, { 5, 4.33333 }, { 5, 3 }, { 3, 3 }, { 4, 3 } } )
			end )
		end )

		context( 'getCircleIntersection', function()
			test( 'Returns true if the circle intersects', function()
				local tab = _.polygon.getCircleIntersection( 3, 5, 2, 3, 1, 3, 6, 7, 4 )
				assert_tables_fuzzy_equal( tab, { { 'tangent', 3, 3 }, { 'tangent', 5, 5 } } )
				tab = _.polygon.getCircleIntersection( 5, 5, 1, 4, 4, 6, 4, 6, 6, 4, 6 )
				assert_tables_fuzzy_equal( tab, { { 'tangent', 5, 4 }, { 'tangent', 6, 5 }, { 'tangent', 5, 6 }, { 'tangent', 4, 5 } } )
				tab = _.polygon.getCircleIntersection( 3, 4, 2, 3, 3, 2, 4, 3, 5, 4, 4 )
				assert_tables_fuzzy_equal( tab, { { 'enclosed', 3, 3, 2, 4 }, { 'enclosed', 2, 4, 3, 5 }, { 'enclosed', 3, 5, 4, 4 }, { 'enclosed', 4, 4, 3, 3 } } )
			end )

			test( 'Returns false if the circle doesn\'t intersect.', function()
				assert_false( _.polygon.getCircleIntersection( 9, 9, 2, 3, 1, 3, 6, 7, 4 ) )
				assert_false( _.polygon.getCircleIntersection( 10, 5, 1, 4, 4, 6, 4, 6, 6, 4, 6 ) )
			end )
		end )

		context( 'isCircleInside', function()
			test( 'Returns true if the circle is fully inside the polygon.', function()
				assert_true( _.polygon.isCircleInside( 5, 5, 1, 4, 3, 3, 4, 3, 6, 4, 7, 6, 7, 7, 6, 7, 4, 6, 3 ) )
				assert_false( _.polygon.isCircleInside( 8, 5, 2, 4, 3, 3, 4, 3, 6, 4, 7, 6, 7, 7, 6, 7, 4, 6, 3 ) )
			end )
		end )

		context( 'isPolygonInside', function()
			test( 'Returns true if polygon2 is inside', function()
				assert_true( _.polygon.isPolygonInside( { 0, 0, 0, 4, 4, 4, 4, 0 }, { 2, 2, 2, 3, 3, 3, 3, 2 } ) )
			end )

			test( 'Returns false if polygon2 is outside', function()
				assert_false( _.polygon.isPolygonInside( { 0, 0, 0, 4, 4, 4, 4, 0 }, { 5, 5, 5, 7, 7, 7, 7, 5 } ) )
			end )
		end )

		context( 'isCircleCompletelyInside', function()
			test( 'Returns if a circle is completely inside of a polygon.', function()
				assert_true( _.polygon.isCircleCompletelyInside( 0, 0, .2, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
				assert_false( _.polygon.isCircleCompletelyInside( .2, .2, .2, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
				assert_false( _.polygon.isCircleCompletelyInside( 0, 0, .4, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
				assert_false( _.polygon.isCircleCompletelyInside( 0, 0, .5, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
				assert_false( _.polygon.isCircleCompletelyInside( 0, 0, 1, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
			end )
		end )

		context( 'isPolygonCompletelyInside', function()
			test( 'Returns if a polygon is completely inside of a polygon.', function()
				assert_true( _.polygon.isPolygonCompletelyInside( { -.5, 0, 0, .5, .5, 0, 0, -.5 }, { -.5, -.5, -1, -.5, -1, .5, -.5, .5, -.5, 1, .5, 1, .5, .5, 1, .5, 1, -.5, .5, -.5, .5, -1 } ) )
				assert_false( _.polygon.isPolygonCompletelyInside( { -.5, 0, 0, 1, .5, 0, 0, -.5 }, { -.5, -.5, -1, -.5, -1, .5, -.5, .5, -.5, 1, .5, 1, .5, .5, 1, .5, 1, -.5, .5, -.5, .5, -1 } ) )
				assert_false( _.polygon.isPolygonCompletelyInside( { 0, .5, .5, 1, 1, .5, .5, 0 }, { -.5, -.5, -1, -.5, -1, .5, -.5, .5, -.5, 1, .5, 1, .5, .5, 1, .5, 1, -.5, .5, -.5, .5, -1 } ) )
			end )
		end )

		context( 'isSegmentCompletelyInside', function()
			test( 'Returns if a segment is completely inside of a polygon.', function()
				assert_true( _.polygon.isSegmentCompletelyInside( 0, .5, .5, 0, -.5, -.5, -1, -.5, -1, .5, -.5, .5, -.5, 1, .5, 1, .5, .5, 1, .5, 1, -.5, .5, -.5, .5, -1 ) )
				assert_false( _.polygon.isSegmentCompletelyInside( 1.5, 1, 1, 1, -.5, -.5, -1, -.5, -1, .5, -.5, .5, -.5, 1, .5, 1, .5, .5, 1, .5, 1, -.5, .5, -.5, .5, -1 ) )
				assert_false( _.polygon.isSegmentCompletelyInside( 1, .5, .5, 1, -.5, -.5, -1, -.5, -1, .5, -.5, .5, -.5, 1, .5, 1, .5, .5, 1, .5, 1, -.5, .5, -.5, .5, -1 ) )
			end )
		end )

		context( 'isCircleCompletelyOver', function()
			test( 'Returns if a polygon is completely within a circle.', function()
				assert_true( _.polygon.isCircleCompletelyOver( 4, 2, 2.69, 4, 1, 2, 3, 3, 3, 6, 1, 4, 0 ) )
				assert_false( _.polygon.isCircleCompletelyOver( 4, 2, 1, 4, 1, 2, 3, 3, 3, 6, 1, 4, 0 ) )
				assert_false( _.polygon.isCircleCompletelyOver( 9, 2, 2.69, 4, 1, 2, 3, 3, 3, 6, 1, 4, 0 ) )
			end )
		end )
	end )

	context( 'circle', function()
		context( 'getArea', function()
			test( 'Gives the area of the circle.', function()
				assert_fuzzy_equal( _.circle.getArea( 1 ), 3.14159 )
				assert_fuzzy_equal( _.circle.getArea( 2 ), 12.56637 )
				assert_fuzzy_equal( _.circle.getArea( 5 ), 78.53981 )
				assert_fuzzy_equal( _.circle.getArea( 10 ), 314.15926 )
				assert_fuzzy_equal( _.circle.getArea( 20 ), 1256.63706 )
			end )
		end )

		context( 'checkPoint', function()
			test( 'Returns true if the point is within the circle.', function()
				assert_true( _.circle.checkPoint( 1, 1, 0, 0, 2 ) )
				assert_true( _.circle.checkPoint( 2, 2, 5, 5, 5 ) )
				assert_true( _.circle.checkPoint( -2, 8, -3, 9, 2 ) )
			end )

			test( 'Returns false if the point is not within the cirlce.', function()
				assert_false( _.circle.checkPoint( 5, 1, 0, 0, 2 ) )
				assert_false( _.circle.checkPoint( -2, 7, -3, 9, 2 ) )
			end )
		end )

		context( 'getCircumference', function()
			test( 'Gives the circumference of the circle.', function()
				assert_fuzzy_equal( _.circle.getCircumference( 1 ), 6.28318 )
				assert_fuzzy_equal( _.circle.getCircumference( 2 ), 12.56637 )
				assert_fuzzy_equal( _.circle.getCircumference( 5 ), 31.41592 )
				assert_fuzzy_equal( _.circle.getCircumference( 10 ), 62.83185 )
				assert_fuzzy_equal( _.circle.getCircumference( 20 ), 125.66370 )
			end )
		end )

		context( 'getLineIntersection', function()
			test( 'Returns \'Secant\' when intersects twice.', function()
				assert_multiple_fuzzy_equal( { _.circle.getLineIntersection( 4, 9, 1, 0, 9, 6, 9 ) }, { 'secant', 3, 9, 5, 9 } )
				assert_multiple_fuzzy_equal( { _.circle.getLineIntersection( 2, 2, 1, 2, 3, 3, 2 ) }, { 'secant', 2, 3, 3, 2 } )
			end )

			test( 'Returns \'Tangent\' when intersects once.', function()
				assert_multiple_fuzzy_equal( { _.circle.getLineIntersection( 4, 9, 1, 0, 8, 6, 8 ) }, { 'tangent', 4, 8 } )
				assert_multiple_fuzzy_equal( { _.circle.getLineIntersection( 2, 2, 1, 2, 3, 0, 3 ) }, { 'tangent', 2, 3 } )
			end )

			test( 'Returns \'false\' when neither.', function()
				assert_false( _.circle.getLineIntersection( 4, 9, 1, 0, 7, 6, 8 ) )
			end )
		end )

		context( 'getSegmentIntersection', function()
			test( 'Returns \'Secant\' if the line connects two points.', function()
				assert_multiple_fuzzy_equal( { _.circle.getSegmentIntersection( 4, 9, 1, 0, 9, 6, 9 ) }, { 'secant', 3, 9, 5, 9 } )
			end )

			test( 'Returns \'Tangent\' if the line attaches only one point.', function()
				assert_multiple_fuzzy_equal( { _.circle.getSegmentIntersection( 1, 1, 1, 0, 0, 0, 2 ) }, { 'tangent', 0, 1 } )
			end )

			test( 'Returns \'Chord\' if both points are on the circle.', function()
				assert_multiple_fuzzy_equal( { _.circle.getSegmentIntersection( 0, 0, 1, -1, 0, 1, 0 ) }, { 'chord', -1, 0, 1, 0 } )
			end )

			test( 'Returns \'Enclosed\' if the line is within the circle entirely.', function()
				assert_multiple_fuzzy_equal( { _.circle.getSegmentIntersection( 0, 0, 2, -1, 0, 1, 0 ) }, { 'enclosed', -1, 0, 1, 0 } )
			end )

			test( 'Returns \'false\' if the line doesn\'t touch anywhere.', function()
				assert_false( _.circle.getSegmentIntersection( 0, 0, 1, 2, 2, 2, 3 ) )
			end )
		end )

		context( 'getCircleIntersection', function()
			test( 'Returns \'Equal\' if the circles are the same.', function()
				assert_equal( _.circle.getCircleIntersection( 0, 0, 4, 0, 0, 4 ), 'equal' )
			end )

			test( 'Returns \'collinear\' if circles have same x and y but not radii.', function()
				assert_equal( _.circle.getCircleIntersection( 0, 0, 4, 0, 0, 8 ), 'collinear' )
				assert_equal( _.circle.getCircleIntersection( 0, 0, 8, 0, 0, 4 ), 'collinear' )
			end )

			test( 'Returns \'inside\' if the circles are inside but not touching one another.', function()
				assert_equal( _.circle.getCircleIntersection( 1, 1, 2, 2, 1, 4 ), 'inside' )
			end )

			test( 'Returns false if the point is not within the cirlce.', function()
				assert_false( _.circle.getCircleIntersection( 4, 4, 1, 6, 6, 1 ) )
			end )
		end )

		context( 'isPointOnCircle', function()
			test( 'Returns true if the point is on the circle.', function()
				assert_true( _.circle.isPointOnCircle( 1, 4, 3, 4, 2 ) )
				assert_true( _.circle.isPointOnCircle( 2, 1, 2, 2, 1 ) )
				assert_true( _.circle.isPointOnCircle( 0, 4, 2, 4, 2 ) )
			end )

			test( 'Returns false if the point is not on the circle.', function()
				assert_false( _.circle.isPointOnCircle( 2, 4, 3, 4, 2 ) )
				assert_false( _.circle.isPointOnCircle( 2, 2, 2, 2, 1 ) )
			end )
		end )

		context( 'isCircleCompletelyInside', function()
			test( 'Returns if a circle is completely inside of another circle.', function()
				assert_true( _.circle.isCircleCompletelyInside( 1, 1, 2, 2, 1, 4 ) )
				assert_true( _.circle.isCircleCompletelyInside( 1, 1, 3, 2, 1, 4 ) )
				assert_false( _.circle.isCircleCompletelyInside( 8, 2, .1, 2, 1, 4 ) )
			end )
		end )

		context( 'isPolygonCompletelyInside', function()
			test( 'Returns if a polygon is completely within a circle.', function()
				assert_true( _.circle.isPolygonCompletelyInside( 4, 2, 2.69, 4, 1, 2, 3, 3, 3, 6, 1, 4, 0 ) )
				assert_false( _.circle.isPolygonCompletelyInside( 4, 2, 1, 4, 1, 2, 3, 3, 3, 6, 1, 4, 0 ) )
				assert_false( _.circle.isPolygonCompletelyInside( 9, 2, 2.69, 4, 1, 2, 3, 3, 3, 6, 1, 4, 0 ) )
			end )
		end )

		context( 'isSegmentCompletelyInside', function()
			test( 'Returns if a segment is completely within a circle.', function()
				assert_true( _.circle.isSegmentCompletelyInside( 3, 3, 2, 2, 2, 3, 4 ) )
				assert_false( _.circle.isSegmentCompletelyInside( 3, 3, 2, 1, 1, 3, 4 ) )
				assert_false( _.circle.isSegmentCompletelyInside( 3, 3, 2, 1, 1, -1, -1 ) )
			end )
		end )

		context( 'getPolygonIntersection', function()
			test( 'Returns true if the circle intersects', function()
				local tab = _.circle.getPolygonIntersection( 3, 5, 2, 3, 1, 3, 6, 7, 4 )
				assert_tables_fuzzy_equal( tab, { { 'tangent', 3, 3 }, { 'tangent', 5, 5 } } )
				tab = _.circle.getPolygonIntersection( 5, 5, 1, 4, 4, 6, 4, 6, 6, 4, 6 )
				assert_tables_fuzzy_equal( tab, { { 'tangent', 5, 4 }, { 'tangent', 6, 5 }, { 'tangent', 5, 6 }, { 'tangent', 4, 5 } } )
				tab = _.circle.getPolygonIntersection( 3, 4, 2, 3, 3, 2, 4, 3, 5, 4, 4 )
				assert_tables_fuzzy_equal( tab, { { 'enclosed', 3, 3, 2, 4 }, { 'enclosed', 2, 4, 3, 5 }, { 'enclosed', 3, 5, 4, 4 }, { 'enclosed', 4, 4, 3, 3 } } )
			end )

			test( 'Returns false if the circle doesn\'t intersect.', function()
				assert_false( _.circle.getPolygonIntersection( 9, 9, 2, 3, 1, 3, 6, 7, 4 ) )
				assert_false( _.circle.getPolygonIntersection( 10, 5, 1, 4, 4, 6, 4, 6, 6, 4, 6 ) )
			end )
		end )

		context( 'isCircleInsidePolygon', function()
			test( 'Returns true if the circle is fully inside the polygon.', function()
				assert_true( _.circle.isCircleInsidePolygon( 5, 5, 1, 4, 3, 3, 4, 3, 6, 4, 7, 6, 7, 7, 6, 7, 4, 6, 3 ) )
				assert_false( _.circle.isCircleInsidePolygon( 8, 5, 2, 4, 3, 3, 4, 3, 6, 4, 7, 6, 7, 7, 6, 7, 4, 6, 3 ) )
			end )
		end )

		context( 'isCircleCompletelyInsidePolygon', function()
			test( 'Returns if a circle is completely inside of a polygon.', function()
				assert_true( _.circle.isCircleCompletelyInsidePolygon( 0, 0, .2, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
				assert_false( _.circle.isCircleCompletelyInsidePolygon( .2, .2, .2, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
				assert_false( _.circle.isCircleCompletelyInsidePolygon( 0, 0, .4, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
				assert_false( _.circle.isCircleCompletelyInsidePolygon( 0, 0, .5, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
				assert_false( _.circle.isCircleCompletelyInsidePolygon( 0, 0, 1, -.5, 0, 0, .5, .5, 0, 0, -.5 ) )
			end )
		end )
	end )

	context( 'statistics', function()
		context( 'getCentralTendency', function()
			test( 'Gives the central tendency.', function()
				assert_tables_fuzzy_equal( { _.statistics.getCentralTendency( 1, 2, 3, 4, 5, 1 ) }, { { 1 }, 2, 3.5, 3.2 } )
			end )
		end )

		context( 'getDispersion', function()
			test( 'Givse the dispersion.', function()
				assert_multiple_fuzzy_equal( { _.statistics.getDispersion( 600, 470, 170, 430, 300 ) }, { 0, 430, 147.32277 } )
			end )
		end )

		context( 'getMean', function()
			test( 'Gives the arithmetic mean of numbers.', function()
				assert_equal( _.statistics.getMean( 1, 2, 3, 4, 5 ), 3 )
				assert_equal( _.statistics.getMean( 10, 10, 10, 10 ), 10 )
			end )
		end )

		context( 'getMedian', function()
			test( 'Gives the median of numbers.', function()
				assert_equal( _.statistics.getMedian( 1, 2, 3, 4, 5 ), 3 )
			end )

			test( 'Gives average of two numbers if the amount of numbers is even.', function()
				assert_equal( _.statistics.getMedian( 1, 2, 3, 4, 5, 6 ), 3.5 )
			end )

			test( 'Works when the numbers aren\'t ordered, too.', function()
				assert_equal( _.statistics.getMedian( 5, 3, 4, 2, 1 ), 3 )
				assert_equal( _.statistics.getMedian( 3, 4, 1, 2, 5, 6 ), 3.5 )
			end )
		end )

		context( 'getMode', function()
			test( 'Returns the mode.', function()
				assert_tables_fuzzy_equal( { _.statistics.getMode( math.pi, math.huge, math.pi ) }, { { math.pi }, 2 } )
			end	)

			test( 'Works if it\'s bimodial, too', function()
				assert_tables_fuzzy_equal( { _.statistics.getMode( 2, 2, 1, 1, 3 ) }, { { 1, 2 }, 2 } )
			end	)
		end	)

		context( 'getRange', function()
			test( 'Returns the range.', function()
				assert_equal( _.statistics.getRange( 1, 2, 3, 4 ), 3 )
				assert_equal( _.statistics.getRange( 100, 5, 3, 6, 7 ), 97 )
			end )
		end )

		context( 'getStandardDeviation', function()
			test( 'Returns the standard deviation.', function()
				assert_fuzzy_equal( _.statistics.getStandardDeviation( 600, 470, 170, 430, 300 ), 147.32277 )
			end )
		end )

		context( 'getVariance', function()
			test( 'Returns the variance.', function()
				assert_equal( _.statistics.getVariance( 600, 470, 170, 430, 300 ), 21704 )
			end )
		end )

		context( 'getVariationRatio', function()
			test( 'Returns the variation ratio.', function()
				assert_fuzzy_equal( _.statistics.getVariationRatio( 4, 2, 5, 3, 0, 4 ), .66667 )
			end )
		end )
	end )

	context( 'math', function()
		context( 'getRoot', function()
			test( 'Gives the nth root to x, given n and x.', function()
				assert_multiple_fuzzy_equal( { _.math.getRoot( 4, 2 ) }, { 2 } )
				assert_multiple_fuzzy_equal( { _.math.getRoot( 16, 2 ) }, { 4 } )
				assert_multiple_fuzzy_equal( { _.math.getRoot( 4, -2 ) }, { .5 } )
			end )
		end )

		context( 'isPrime', function()
			test( 'Returns true if a number is prime.', function()
				assert_true( _.math.isPrime( 3 ) )
				assert_true( _.math.isPrime( 2 ) )
				assert_true( _.math.isPrime( 47 ) )
			end )

			test( 'Returns false if a number is not prime.', function()
				assert_false( _.math.isPrime( 1 ) )
				assert_false( _.math.isPrime( 100 ) )
			end )
		end )

		context( 'round', function()
			test( 'Rounds down if the number is less than .5.', function()
				assert_equal( _.math.round( 3.4 ), 3 )
			end )

			test( 'Rounds up if the number is more than .5.', function()
				assert_equal( _.math.round( 6.7 ), 7 )
			end )

			test( 'Specify the number of decimal places to use.', function()
				assert_equal( _.math.round( 197.88, 2 ), 197.88 )
				assert_equal( _.math.round( 197.88, 1 ), 197.9 )
				assert_equal( _.math.round( 197, -2 ), 200 )
			end )
		end )

		context( 'getSummation', function()
			test( 'Adds up numbers and such.', function()
				assert_equal( _.math.getSummation( 1, 10, function( i ) return ( i * 2 ) end ), 110 )
			end )

			test( 'Can access previous values with second function argument.', function()
				assert_equal( _.math.getSummation( 1, 5, function( i, t ) if t[i-1] then return i + t[i-1] else return 1 end end ), 35 )
			end )
		end )

		context( 'getPercentOfChange', function()
			test( 'Gives the percentage of change.', function()
				assert_equal( _.math.getPercentOfChange( 2, 4 ), 1 )
				assert_equal( _.math.getPercentOfChange( 4, 2 ), -.5 )
				assert_equal( _.math.getPercentOfChange( 4, 0 ), -1 )
				assert_equal( _.math.getPercentOfChange( 0, 0 ), 0 )
			end )

			test( 'Inf if original is 0.', function()
				assert_equal( _.math.getPercentOfChange( 0, 3 ), 1/0 )
			end )
		end )

		context( 'getPercentage', function()
			test( 'Gives the percent.', function()
				assert_equal( _.math.getPercentage( 1, 2 ), 2 )
				assert_equal( _.math.getPercentage( 2, 1 ), 2 )
				assert_equal( _.math.getPercentage( .5, 50 ), 25 )
				assert_equal( _.math.getPercentage( 50, 2 ), 100 )
				assert_equal( _.math.getPercentage( -.5, 4 ), -2 )
			end )
		end )

		context( 'getQuadraticRoots', function()
			test( 'Gives roots given a, b, and c.', function()
				assert_multiple_fuzzy_equal( { _.math.getQuadraticRoots( 1, -3, -4 ) }, { -1, 4 } )
				assert_multiple_fuzzy_equal( { _.math.getQuadraticRoots( 1, 0, -4 ) }, { -2, 2 } )
				assert_multiple_fuzzy_equal( { _.math.getQuadraticRoots( 6, 11, -35 ) }, { -3.5, 5/3 } )
			end )

			test( 'Returns false it has no roots.', function()
				assert_false( _.math.getQuadraticRoots( 1, 2, 4 ) )
				assert_false( _.math.getQuadraticRoots( .6, .3, .9 ) )
			end )
		end )

		context( 'getAngle', function()
			test( 'Gives the angle between three points.', function()
				assert_fuzzy_equal( _.math.getAngle( 1, 3, 1, 1, 3, 1 ), 1.57079633 )
				assert_fuzzy_equal( _.math.getAngle( 4, 4, 1, 1, 4, 1 ), 0.785398163 )
			end )
		end )
	end )
end )
