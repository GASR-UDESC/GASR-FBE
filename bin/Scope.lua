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


--depends on GNUPLOT
Scope = {
    event = 'Cnf',
    _Functionality = 'Scope'
}

function Scope:exe( event )
	LOG_FILE:write('Scope--- '..self.label..' initialized\n')
    LOG_FILE:write('Scope--- '..self.label..' execution completed\n')
	if event then
		if type(self.Data) ~= 'table' then
			self.Data = {}
		end
		self.Data[#self.Data+1] = self.DataIn
		self.DataOut            = self.DataIn
		print(self.dt*(#self.Data-1), self.DataIn)
		return {'Cnf'}, self.label
	else
		local file   = io.open('plot_file', 'w')
		for i, v in ipairs(self.Data) do
			file:write(self.dt*(i-1)..' '..v..'\n')
		end
		file:close()
		local gnu    = io.open('scope.gnu', 'w')
		gnu:write("plot 'plot_file' using 1:2 with lines")
		gnu:close()
		os.execute('gnuplot.exe scope.gnu -persist')
	end
	
end
Scope.__index 	 = Scope
SIFB_Class.Scope = Scope

