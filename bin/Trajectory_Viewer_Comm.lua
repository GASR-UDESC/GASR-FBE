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

Trajectory_Viewer_Comm = {}
Trajectory_Viewer_Comm.__index = Trajectory_Viewer_Comm
function Trajectory_Viewer_Comm:exe(event)
    self.CONFIRMATION ='RSP'
    LOG_FILE:write('FileWriter: '..self.label..' initialized with event: '..event..'\n')
    GEOM_FILE:write( "}\n" )
    GEOM_FILE:close()
    local f = loadfile( 'TrajectoryViewer.lua' )
    f()
    LOG_FILE:write('FileWriter: '..self.label..' execution complete\n')
    LOG_FILE:write('FileWriter: '..self.label..' returned event '..self.CONFIRMATION..'\n')
    return {self.CONFIRMATION}, self.label
end

SIFB_Class.Trajectory_Viewer_Comm = Trajectory_Viewer_Comm
