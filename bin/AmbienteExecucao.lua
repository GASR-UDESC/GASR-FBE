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

COEF_FILE   = io.open('COEF_FILE', 'w')
LOG_FILE    = io.open('LOG_FILE',  'w')
GEOM_FILE   = io.open('GEOM_FILE', 'w')
CONFIG_FILE = io.open('CONFIG_FILE', 'r')

GEOM_FILE:write( "equations = {\n" )

System = {}
require 'System'
require 'FBViewer'
print('\n\n\n\n-------------------FBE - Function Block Environment-----------------------')
print('---UDESC - Universidade do Estado de Santa Catarina')
print('---GASR  - Grupo de Automacao de Sistemas e Robotica\n---Version 1.0 ')
print('---gtk version = ' , gtk.version() )

F = FBViewer.new(CONFIG_FILE)
F:run()
GEOM_FILE:write( "}\n" )
GEOM_FILE:close()



