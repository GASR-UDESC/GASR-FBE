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

--~ RUN_UNTIL_LOOP_RESPONSE -> escreve 1 variavel (1057 - inicio de operação) e lê 1 variável ( 1058 - status da máquina 0 - livre; 1 - ocupado);  enquanto ocupado, ler 1058. Se 1058 == 0, setar evento de saída para enviar proxima equação
Run_until_loop_response = {}

Run_until_loop_response.__index = Run_until_loop_response


function Run_until_loop_response:exe(event)

    LOG_FILE:write('Run_until_loop_response--- '..self.label..' started with event: '..event..'\n')

    local p = io.popen('java -jar MODBUS_write_1.jar '.. self.PORT .. ' '..self.REG_WRITE..' 1', 'r')
    local d = p:read()

    if d then  --conseguiu escrever
        while true do
            local p = io.popen('java -jar MODBUS_read.jar '.. self.PORT .. ' '..self.REG_READ..' '..self.NUM_REG)
            d = p:read()
            if p then p:close() end
            print( d )
            if d =='0' then
                return {"CNF"} , self.label
            end
        end
    end



end

SIFB_Class['Run_until_loop_response'] = Run_until_loop_response
