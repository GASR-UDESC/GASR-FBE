--[[
	Copyright 2014 Gabriel Hermann Negri, Guilherme Jarentchuk, Eduardo Harbs, Roberto S. U. Rosso Jr.

	This file is part of GASR-FBE.
	
    GASR-FBE is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

--Trajectory viewer
_f = loadfile( "GEOM_FILE" )
_f()
--ID count
id = 1;

function write_line( file, coef )
    file:write( "Point("..id..") = {"..coef[5]..", "..coef[6]..", "..coef[7]..", 0.009 };\n" )
    id = id + 1
    file:write( "Point("..id..") = {"..coef[10]..", "..coef[11]..", "..coef[12]..", 0.009 };\n" )
    id = id + 1
    file:write( "Line("..id..") = {"..(id - 2)..", "..(id - 1).." };\n" )
    id = id + 1
    if( anim ) then
        file:write( 'Print Sprintf("anim_'..(id - 1)..'.png");\n' )
    end
end

function write_arc( file, coef )
    local angle = coef[11]
    local div
    local center = { coef[2], coef[3], coef[4] }
    local start_p, end_p = {}, {}
    local U = { coef[5], coef[6], coef[7] }
    local V = { coef[8], coef[9], coef[10] }
    local R = coef[12]
    if( math.abs(angle) < 3.14 ) then
        div = 1
    elseif( math.abs(angle) < 6.28 ) then
        div = 2
    else
        div = 3
    end
    angle = angle/div
    for i = 1, div do
        if( i == 1 ) then
            start_p[1] = ( center[1] + U[1]*R*math.cos( 0 ) + V[1]*R*math.sin( 0 ) )
            start_p[2] = ( center[2] + U[2]*R*math.cos( 0 ) + V[2]*R*math.sin( 0 ) )
            start_p[3] = ( center[3] + U[3]*R*math.cos( 0 ) + V[3]*R*math.sin( 0 ) )
        else
            start_p[1] = ( center[1] + U[1]*R*math.cos( angle*(i-1) ) + V[1]*R*math.sin( angle*(i-1) ) )
            start_p[2] = ( center[2] + U[2]*R*math.cos( angle*(i-1) ) + V[2]*R*math.sin( angle*(i-1) ) )
            start_p[3] = ( center[3] + U[3]*R*math.cos( angle*(i-1) ) + V[3]*R*math.sin( angle*(i-1) ) )
        end
        end_p[1] = ( center[1] + U[1]*R*math.cos( angle*i ) + V[1]*R*math.sin( angle*i ) )
        end_p[2] = ( center[2] + U[2]*R*math.cos( angle*i ) + V[2]*R*math.sin( angle*i ) )
        end_p[3] = ( center[3] + U[3]*R*math.cos( angle*i ) + V[3]*R*math.sin( angle*i ) )
        file:write( "Point("..id..") = {"..start_p[1]..", "..start_p[2]..", "..start_p[3]..", 0.009 };\n" )
        id = id + 1
        file:write( "Point("..id..") = {"..center[1]..", "..center[2]..", "..center[3]..", 0.009 };\n" )
        id = id + 1
        file:write( "Point("..id..") = {"..end_p[1]..", "..end_p[2]..", "..end_p[3]..", 0.009 };\n" )
        id = id + 1
        file:write( "Circle("..id..") = {"..(id - 3)..", "..(id - 2)..", "..(id - 1).." };\n" )
        id = id + 1
        if( anim ) then
            file:write( 'Print Sprintf("anim_'..(id - 1)..'.png");\n' )
        end
    end
end

--Execution
print( "Trajectory viewer for GMSH v1.0" )
g_file = io.open( "Gmsh/traj_sim.geo", "w" )
g_file:write( "General.Trackball = 0 ;\n" )
g_file:write( "General.ScaleX = 0.25 ;\n" )
g_file:write( "General.ScaleY = 0.25 ;\n" )
g_file:write( "General.Axes = 1 ;\n" )
g_file:write( "General.RotationX = -45 ;\n" )
g_file:write( "General.RotationY = 0;\n" )
g_file:write( "General.RotationZ = -35.264;\n" )
anim = false
for k, v in ipairs( equations ) do
    if( k > 1 ) then --Ignores machine going to workpiece zero
        if( v[1] == 1 ) then
            write_line( g_file, v )
        elseif( v[1] == 2 ) then
            write_arc( g_file, v )
        end
    end
end
g_file:close()
--os.execute( "cd Gmsh" )
--os.execute( "\"C:\\Users\\Guilherme\\Documents\\Udesc\\Pesquisa\\FRANK II - Software\\GASR FB Editor\gmsh.exe\"  traj_sim.geo" )
print( "Finished" )
os.execute( "Gmsh\\gmsh.exe \"Gmsh\\traj_sim.geo\"" )
print( "Press enter to continue" )
local l = io.read( "*l" )
print( l )

--Arc = {}
--function Arc:build( parent_table, is_parametric )
--    --parent_table is the table to store any child entity created here to the main talbe of entities
--    --is_parametric = bool -> if true, the geometry with be plotted as the "machine would do it"
--    --print( "size", #parent_table - 1 )
--    for i = (#parent_table - 1), 1, -1 do --Seeks for the last point entity
----        print( parent_table[i] )
--        if( parent_table[i] ~= nil ) then
--            if( parent_table[i].type == "Point" ) then
--                self.last_point_id = i
----                print( "oi",self.last_point_id )
--                break
--            end
--        end
--    end
--    self.points = {}
--    local id = #parent_table + 2
--    if( is_parametric == false ) then
--        if( self.coef ~= nil ) then
--            parent_table[ id ] = Point:new( { file = g_file, do_anim = false, id = id, [1] = self.coef[2], [2] = self.coef[3], [3] = self.coef[4] } )
--            self.points[ #self.points + 1 ] = parent_table[ id ]
--            parent_table[ id ]:write()
--            id = id + 1
--            parent_table[ id ] = Point:new( { file = g_file, do_anim = false, id = id, [1] = self.coef[15], [2] = self.coef[16], [3] = self.coef[17] } )
--            self.points[ #self.points + 1 ] = parent_table[ id ]
--            parent_table[ id ]:write()
--        end
--    end
--    return self
--end
--function Arc:write()
--    self.type = "Circle"
--    self.file:write( "Circle("..self.id..") = {"..self.last_point_id..", " )
--    i = 1
--    for k, v in ipairs( self.points ) do
--        if( i == 2 ) then
--            self.file:write( v.id.." };\n" )
--            break
--        else
--            self.file:write( v.id..", " )
--            i = i + 1
--        end
--    end
--    if( self.do_anim ) then
--        self.file:write( 'Print Sprintf("anim_'..self.id..'.png");\n' )
--    end
--end
--Arc = GMSH:new( Arc )
--
----Execution
--print( "Trajectory viewer for GMSH v1.0" )
--g_file = io.open( "Gmsh/traj_sim.geo", "w" )
--g_file:write( "General.Trackball = 0 ;\n" )
--g_file:write( "General.ScaleX = 0.25 ;\n" )
--g_file:write( "General.ScaleY = 0.25 ;\n" )
--g_file:write( "General.Axes = 1 ;\n" )
--g_file:write( "General.RotationX = -45 ;\n" )
--g_file:write( "General.RotationY = 0;\n" )
--g_file:write( "General.RotationZ = -35.264;\n" )
--eq_index = 1
--anim = true
--geom = {}
--geom[1] = Point:new( { file = g_file, do_anim = anim, id = 1, [1] = 0, [2] = 0, [3] = 0 } )
--geom[1]:write()
--for k, v in ipairs( equations ) do
--    if( v[1] == 1 ) then
--        local id = #geom + 1
--        geom[ #geom + 1 ] = Line:new( { file = g_file, coef = v, do_anim = anim, ["id"] = #geom + 1 } )
--        geom[ id ]:build( geom, false )
----        print( geom[ id ].last_point_id )
--        geom[ id ]:write()
--    elseif( v[1] == 2 ) then
--        local id = #geom + 1
--        geom[ #geom + 1 ] = Arc:new( { file = g_file, coef = v, do_anim = anim, ["id"] = #geom + 1 } )
--        geom[ id ]:build( geom, false )
----        print( geom[ id ].last_point_id )
--        geom[ id ]:write()
--    end
--end
--g_file:close()
----os.execute( "cd Gmsh" )
----os.execute( "\"C:\\Users\\Guilherme\\Documents\\Udesc\\Pesquisa\\FRANK II - Software\\GASR FB Editor\gmsh.exe\"  traj_sim.geo" )
--print( "Finished" )
