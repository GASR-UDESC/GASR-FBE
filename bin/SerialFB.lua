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

rs232 = require("luars232")
SerialFB = {
    event = 'Cnf',
}

function SerialFB:exe( event )
	local function wait(n)
		os.execute( string.format('sleep %.6f', n ))
	end
	if event == 'close' then
		if self.p:close() == rs232.RS232_ERR_NOERROR then
			print('serial port close SUCESS')
		else
			print('serial port close FAIL')
		end
		return
	end
	
	if(not self.OPEN) then --abre a comunicação serial
		self.e, self.p = rs232.open(self.port_name)
		if self.e ~= rs232.RS232_ERR_NOERROR then
		-- handle error
		io.write(string.format("can't open serial port '%s', error: '%s'\n",
			self.port_name, rs232.error_tostring(self.e)))
			return
		end
		-- set port settings
		assert(self.p:set_baud_rate(rs232.RS232_BAUD_9600) == rs232.RS232_ERR_NOERROR)
		assert(self.p:set_data_bits(rs232.RS232_DATA_8) == rs232.RS232_ERR_NOERROR)
		assert(self.p:set_parity(rs232.RS232_PARITY_NONE) == rs232.RS232_ERR_NOERROR)
		assert(self.p:set_stop_bits(rs232.RS232_STOP_1) == rs232.RS232_ERR_NOERROR)
		assert(self.p:set_flow_control(rs232.RS232_FLOW_OFF)  == rs232.RS232_ERR_NOERROR)
		
		io.write(string.format("OK, port open with values '%s'\n", tostring(self.p)))
		wait(2)
		self.OPEN = true
	end
		
	
	wait(self.T/2)
	err, len_written = self.p:write(string.format("%.2f", self.input) ..'\n')
	wait(self.T/2)
	assert(self.e == rs232.RS232_ERR_NOERROR)
	local resp = {}
	for i = 1, math.huge do
		a, resp[i], c = self.p:read(1)
		if(resp[i] == '\n' or not resp[i] or resp[i] ==' ') then break end
	end
	self.output = 0
	for i =1, #resp do
		if(not tonumber(resp[i])) then
			resp[i] = nil
		end
	end
	
	
	for i =1, #resp do
		self.output = self.output + tonumber(resp[i])*10^(#resp-i)
	end
	
	return {self.event}, self.label

end

SerialFB.__index = SerialFB

SIFB_Class.SerialFB = SerialFB
