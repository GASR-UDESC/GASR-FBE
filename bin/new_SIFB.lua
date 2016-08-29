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

new_SIFB = {
    event = 'event',
    _Functionality = 'new_SIFB'
}


function new_SIFB:exe( --[[include arguments]] )
    LOG_FILE:write('new_SIFB--- '..self.label..' initialized\n')
	LOG_FILE:write('new_SIFB--- '..self.label..' execution completed\n')
    --if your SIFB is a STARTER TYPE SIFB then
    --self._Resource:exe(self.event, self.label)
    --else
    --return {self.event}, self.label

end

new_SIFB.__index = new_SIFB

SIFB_Class.new_SIFB = new_SIFB
