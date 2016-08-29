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

MODBUS_READ_4 = {}

MODBUS_READ_4.__index = MODBUS_READ_4


function MODBUS_READ_4:exe(event)
    
    LOG_FILE:write('MODBUS_READ_4--- '..self.label..' started with event: '..event..'\n')
    local label
    self.output = {}
    
    local p = io.popen('java -jar modbus.jar.jar ' ..self.PORT..' '..self.INIT_REG..' '..self.NUM_REG, 'r')

    for i = 1, tonumber(self.NUM_REG)  do
        d = p:read()
        if d == nil then
            break
        end
        self['RD_'..tostring(i)] = tonumber(d)
    end
    
    return {"CNF"} , self.label
    
end

SIFB_Class.MODBUS_READ = MODBUS_READ
