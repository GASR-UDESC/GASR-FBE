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

File_Writer = {}
File_Writer.__index = File_Writer
function File_Writer:exe(event)
    self.CONFIRMATION ='RSP'
    LOG_FILE:write('FileWriter: '..self.label..' initialized with event: '..event..'\n')
    if( tonumber(self[self.INPUTS[ 1 ]]) > 0 ) then 
        GEOM_FILE:write( "{" )
    end
    for i, v in ipairs (self.INPUTS) do
        if type (self[v]) == 'table' then
            for j, k in ipairs (self[v]) do
                COEF_FILE:write(k..' ')
                if( tonumber(self[self.INPUTS[ 1 ]]) > 0 ) then 
                    GEOM_FILE:write( k.."," )
                end
            end
        else
            COEF_FILE:write(self[v]..' ')
            if( tonumber(self[self.INPUTS[ 1 ]]) > 0 ) then 
                GEOM_FILE:write( self[v].."," )
            end
        end
    end
    if( tonumber(self[self.INPUTS[ 1 ]]) > 0 ) then 
        GEOM_FILE:write( "},\n" )
    end
    COEF_FILE:write('\n')
    LOG_FILE:write('FileWriter: '..self.label..' execution complete\n')
    LOG_FILE:write('FileWriter: '..self.label..' returned event '..self.CONFIRMATION..'\n')
    return {self.CONFIRMATION}, self.label
end

SIFB_Class.File_Writer = File_Writer
