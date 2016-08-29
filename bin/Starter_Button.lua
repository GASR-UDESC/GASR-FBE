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

Starter_Button = {
    event = 'start',
    _Functionality = 'Starter_Button'
}

function Starter_Button:_get_active_color()
	if type(self.Color) ~= 'table' then
		self.Color = {0.9, 0, 0}
    end
	local c = {self.Color[1], self.Color[2], self.Color[3]}
	return c, c
end

function Starter_Button._SpecialDraw(widget, cr, block)
	cr:set_source_rgb(0, 0, 0)
	local xo = block.ORIGEM[1] + block._BodyWidth/2
	local yo = block.ORIGEM[2] + block._BodyWidth/4 
	cr:move_to(N*xo - N*1*block._BodyWidth/4, N*yo + N*0*block._BodyWidth/4)
	cr:set_antialias(0)
	cr:arc(N*xo, N*yo, N*block._BodyWidth/4, 0, 2*math.pi)
	local Color = block._FunctionBlock.Color
	cr:set_source_rgb(Color[1], Color[2], Color[3])
	cr:fill()
	cr:stroke()
	cr:set_source_rgb(0, 0, 0)
	cr:move_to(N*xo - N*1*block._BodyWidth/4, N*yo)
	cr:arc(N*xo, N*yo, N*block._BodyWidth/4, 0, 2*math.pi)
	cr:line_to(N*xo - N*1*block._BodyWidth/4, N*yo + N*0*block._BodyWidth/4)
	cr:stroke()
	
end

function Starter_Button:exe( override )
    self.Color1 = {0.9, 0, 0}
	self.Color2 = {0, 0.5, 0}
	if type(self.Color) ~= 'table' then
		self.Color = {}
    end
    
    LOG_FILE:write('Starter_Button--- '..self.label..' initialized\n')
    if( override == 1 ) then
        LOG_FILE   = io.open('LOG_FILE', 'w')
        COEF_FILE  = io.open('COEF_FILE', 'w')
        GEOM_FILE  = io.open('GEOM_FILE', 'w')
        GEOM_FILE:write( "equations = {\n" )
        LOG_FILE:write('Starter_Button--- '..self.label..' execution completed\n')
        LOG_FILE:write('Starter_Button--- '..self.label .. ' returned event: '..self.event ..'\n')
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
            self.Color = self.Color2
            flag = -flag
            if flag == 1 then
                LOG_FILE   = io.open('LOG_FILE', 'w')
                COEF_FILE  = io.open('COEF_FILE', 'w')
                GEOM_FILE  = io.open('GEOM_FILE', 'w')
                GEOM_FILE:write( "equations = {\n" )
                LOG_FILE:write('Starter_Button--- '..self.label..' execution completed\n')
                LOG_FILE:write('Starter_Button--- '..self.label .. ' returned event: '..self.event ..'\n')
                for i, v in ipairs(ApStructs) do
					if v._FunctionBlock and v._FunctionBlock.label == self.label then
						v.CORPO.CLICKED = true
						if not v.X then
							v.X = v.ORIGEM[1]
							v.Y = v.ORIGEM[2]
						end
						v:MOVE(F.Drawing_Area, false, nil, nil, v.X, v.Y)
						v.CORPO.CLICKED = false
						break
					end
				end          
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
                self.Color = self.Color1
                for i, v in ipairs(ApStructs) do
					if v._FunctionBlock and v._FunctionBlock.label == self.label then
						v.CORPO.CLICKED = true
						if not v.X then
							v.X = v.ORIGEM[1]
							v.Y = v.ORIGEM[2]
						end
						v:MOVE(F.Drawing_Area, false, nil, nil, v.X, v.Y)
						v.CORPO.CLICKED = false
						break
					end
				end          
            end

        end

        button:connect('clicked', exe_start)
        box:add(button)
        win:add(box)
        win:show_all()
        win:connect('delete-event', function() self.is_open = false win:destroy() end)
    end
end

Starter_Button.__index = Starter_Button

SIFB_Class.Starter_Button = Starter_Button
