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

SIFB_Publ = {}

SIFB_Publ.__index = SIFB_Publ

SIFB_Publ.new = function ( label, resource )
    local t = {}
    setmetatable ( t, SIFB_Publ )
    t.label = label
    _, _,t.id    = label:find('.+%_+(.+)')   --Coloca o nome do resource	 destino
    t.resource   = resource
    return t
end


function SIFB_Publ:exe(event)

    LOG_FILE:write('SIFB_Publ--- '..self.label..' started with event: '..event..'\n')
    LOG_FILE:write('SIFB_Publ--- Service -> Data transfer from local publisher to local subscriber\n')
    local _, _, quantas_in_vars = self.FBType:find('.+%_+(%d+)')
    quantas_in_vars = tonumber(quantas_in_vars)
    for i = 1, quantas_in_vars do
		print(self.label, self.ID, self.ID[1], self.ID[2])
        self._Resource._Device[ self.ID[1] ][ self.ID[2] ][ 'RD_'..tostring(i) ] = self[ 'SD_'..tostring(i) ]



    end

    if self._Resource and self._Resource._Device and self._Resource._Device[ self.ID[1] ] and
    self._Resource._Device[ self.ID[1] ][ self.ID[2] ] and self._Resource._Device[ self.ID[1] ][ self.ID[2] ].exe then
        self._Resource._Device[ self.ID[1] ][ self.ID[2] ]:exe( 'IND' )
    else
        LOG_FILE:write('SIFB_Publ--- Couldn\'t find subscriber\n')
    end
    return nil, 'Execution_OK'

end

SIFB_Class.SIFB_Publ = SIFB_Publ
