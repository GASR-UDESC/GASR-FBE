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

SIFB_Subl = {}

SIFB_Subl.__index = SIFB_Subl

SIFB_Subl.new = function ( label, resource )
    local t = {}
    setmetatable ( t, SIFB_Subl )
    t.label = label
    _, _,t.id    = label:find('.+%_+(.+)')   --Coloca o nome do resource
    t.resource   = resource
    return t
end
    

function SIFB_Subl:exe(event)
    LOG_FILE:write( 'SIFB_Subl--- '..self.label..' started with event: '..event..'\n' )
    self._Resource:exe( event, self.label )
end

SIFB_Class.SIFB_Subl = SIFB_Subl
