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

Yellow_Light_SIFB = {
    event = 'output',
}

function Yellow_Light_SIFB:_get_active_color()
	if type(self.Color) ~= 'table' then
		self.Color = {0.5, 0.5, 0.5}
    end
	local c = {self.Color[1], self.Color[2], self.Color[3]}
	return c, c
end

function Yellow_Light_SIFB._SpecialDraw(widget, cr, block)
	cr:set_source_rgb(0, 0, 0)
	local xo = block.ORIGEM[1] + block._BodyWidth/2
	local yo = block.ORIGEM[2] + block._BodyWidth/4 
	cr:move_to(N*xo - N*math.sqrt(2)/2*block._BodyWidth/4, N*yo + N*math.sqrt(2)/2*block._BodyWidth/4)
	cr:set_antialias(0)
	cr:arc(N*xo, N*yo, N*block._BodyWidth/4, 3/4*math.pi, 1/4*math.pi)
	local Color = block._FunctionBlock.Color
	cr:set_source_rgb(Color[1], Color[2], Color[3])
	cr:fill()
	cr:stroke()
	cr:set_source_rgb(0, 0, 0)
	cr:move_to(N*xo - N*math.sqrt(2)/2*block._BodyWidth/4, N*yo + N*math.sqrt(2)/2*block._BodyWidth/4)
	cr:arc(N*xo, N*yo, N*block._BodyWidth/4, 3/4*math.pi, 1/4*math.pi)
	cr:line_to(N*xo - N*math.sqrt(2)/2*block._BodyWidth/4, N*yo + N*math.sqrt(2)/2*block._BodyWidth/4)
	cr:stroke()
	
end


function Yellow_Light_SIFB:exe( --[[include arguments]] )
    self.Color1 = {0.5, 0.5, 0.5}
	self.Color2 = {0.7, 0.7, 0}
	if type(self.Color) ~= 'table' then
		self.Color = {}
    end
    if self.Color[1] == 0.5 then
		self.Color = self.Color2
    else	
		self.Color = self.Color1
    end	
	LOG_FILE:write('Yellow_Light_SIFB--- '..self.label..' initialized\n')
	LOG_FILE:write('Yellow_Light_SIFB--- '..self.label..' execution completed\n')
    --if your SIFB is a STARTER TYPE SIFB then
    --self._Resource:exe(self.event, self.label)
    --else
	for i, v in ipairs(ApStructs) do
		if v._FunctionBlock and v._FunctionBlock.label == self.label then
			if not v.X then
				v.X = v.ORIGEM[1]
				v.Y = v.ORIGEM[2]
			end
			v.CORPO.CLICKED = true
			v:MOVE(F.Drawing_Area, false, nil, nil, v.X, v.Y)
			v.CORPO.CLICKED = false
			break
		end
	end
	return {self.event}, self.label

end

Yellow_Light_SIFB.__index = Yellow_Light_SIFB

SIFB_Class.Yellow_Light_SIFB = Yellow_Light_SIFB
