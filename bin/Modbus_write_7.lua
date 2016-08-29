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

Modbus_write_7 = {}

Modbus_write_7.__index = Modbus_write_7


function Modbus_write_7:exe(event)

    LOG_FILE:write('Modbus_write_7--- '..self.label..' started with event: '..event..'\n')

    print( 'EXE = '..'java -jar MODBUS_write_7.jar '.. self.PORT .. ' '..self.INIT_REG..' '..self.ID..' '..self.SD_1..' '..self.SD_2..' '..self.SD_3..' '..self.SD_4..' '..self.SD_5..' '..self.PAGE)
    local p = io.popen('java -jar MODBUS_write_7.jar '.. self.PORT .. ' '..self.INIT_REG..' '..self.ID..' '..self.SD_1..' '..self.SD_2..' '..self.SD_3..' '..self.SD_4..' '..self.SD_5..' '..self.PAGE, 'r')
    local d = p:read()
    print('RETORNOU: ', d)
    if p then p:close() end

    return {"CNF"} , self.label

end

SIFB_Class.Modbus_write_7 = Modbus_write_7
