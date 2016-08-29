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

require('lgob.gtk')
require('lgob.gdk')
require('lgob.cairo')

Starter = {
    event = 'start',
    _Functionality = 'Starter'
}


function Starter:exe( override )
    LOG_FILE:write('Starter--- '..self.label..' initialized\n')
    if( override == 1 ) then
        LOG_FILE   = io.open('LOG_FILE', 'w')
        COEF_FILE  = io.open('COEF_FILE', 'w')
        GEOM_FILE  = io.open('GEOM_FILE', 'w')
        GEOM_FILE:write( "equations = {\n" )
        LOG_FILE:write('Starter--- '..self.label..' execution completed\n')
        LOG_FILE:write('Starter--- '..self.label .. ' returned event: '..self.event ..'\n')
        self._Resource:exe(self.event, self.label)

        LOG_FILE:write('\n\nEXECUTION COMPLETED \n\n\n')
        LOG_FILE:flush()
        COEF_FILE:flush()
        GEOM_FILE:flush()
        print('**execution completed**')
    else
        if self.is_open then return end
        self.is_open = true
        local answer = 'n'
        local win    = gtk.Window.new()
        win:set_position(gtk.WIN_POS_CENTER)
        win:set('default-height', 50, 'default-width', 50)
        win:connect('delete-event', function ()
                                        win:hide()
                                    end
        )
        local box    = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
        local button = gtk.Button.new_with_label('START')
        local flag = -1
        function exe_start()
            flag = -flag
            if flag == 1 then
                LOG_FILE   = io.open('LOG_FILE', 'w')
                COEF_FILE  = io.open('COEF_FILE', 'w')
                GEOM_FILE  = io.open('GEOM_FILE', 'w')
                GEOM_FILE:write( "equations = {\n" )
                LOG_FILE:write('Starter--- '..self.label..' execution completed\n')
                LOG_FILE:write('Starter--- '..self.label .. ' returned event: '..self.event ..'\n')
                self._Resource:exe(self.event, self.label)

                LOG_FILE:write('\n\nEXECUTION COMPLETED \n\n\n')
                LOG_FILE:flush()
                COEF_FILE:flush()
                --GEOM_FILE:flush()
                print('**execution completed**')
            end
            button:set('label', 'Execution Ok\n Click to Exit')
            if flag == -1 then
                win:destroy()
                self.is_open = false
            end

        end

        button:connect('clicked', exe_start)
        box:add(button)
        win:add(box)
        win:show_all()
        win:connect('delete-event', function() self.is_open = false win:hide() end)
    end
end

Starter.__index = Starter

SIFB_Class.Starter = Starter
