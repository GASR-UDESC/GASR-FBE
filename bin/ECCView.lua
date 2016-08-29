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
require('System')

local R_HEIGHT   = 40 --Rectange height
local R_WIDTH    = 92 --Rectangle width
local SLOPE      = 1  --Inclinação para as conexoes
local ARROW_SIZE = 9  --tamanho das linhas das flechas
local PHI        = math.pi/7 --abertura entre as flechas/2 , em radianos
ECCView            = {}
ECCView.ECState    = {}
ECCView.Connection = {}

local function arrow_rotate (v1, v2, theta)
    v1 = {v1[1]*math.cos(theta) - v1[2]*math.sin(theta), v1[1]*math.sin(theta) + v1[2]*math.cos(theta)}
    v2 = {v2[1]*math.cos(theta) - v2[2]*math.sin(theta), v2[1]*math.sin(theta) + v2[2]*math.cos(theta)}
    return v1, v2
end

ECCView.ECState.__index = ECCView.ECState
function ECCView.ECState.new(name, x, y)
    local self             = {}
    self.ORIGEM            = {}
    self.CORPO             = {}
    self.CORPO.CLICKED     = false
    self.NAME              = name
    self.Connections       = {}
    self.Top_Connections   = 0
    self.Down_Connections  = 0
    self.Left_Connections  = 0
    self.Right_Connections = 0
    self.Right_Slot        = 1  --inicializa no 1º slot, p/ as conexões
    self.Left_Slot         = 1
    self.Top_Slot          = 1
    self.Down_Slot         = 1
    self.ORIGEM[1]         = tonumber(x) or 50
    self.ORIGEM[2]         = tonumber(y) or 50
    setmetatable(self, ECCView.ECState)
    return self
end

function ECCView.ECState:draw(widget, cr)
    ApStructs[#ApStructs+1] = self
    cr:set_source_rgb(0, 0, 0)
    --Text Extents
    cr:set_font_size(10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    local t_ext = cairo.TextExtents.create()
    cr:text_extents(self.NAME, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:rectangle (self.ORIGEM[1]*N, self.ORIGEM[2]*N, R_WIDTH*N, R_HEIGHT*N)
    if self.CORPO.CLICKED then
        cr:set_source_rgb (0.8, 0.6, 0.6)
    else
        cr:set_source_rgb(0.8, 0.8, 0.9)
    end
    cr:fill()
    cr:stroke()
    cr:move_to (self.ORIGEM[1]*N, self.ORIGEM[2]*N)
    cr:rel_line_to(R_WIDTH*N, 0)
    cr:rel_line_to(0, R_HEIGHT*N)
    cr:rel_line_to(-R_WIDTH*N, 0)
    cr:rel_line_to(0, -R_HEIGHT*N)
    
    cr:move_to(self.ORIGEM[1]*N + R_WIDTH*N/2 - txt_width/2, self.ORIGEM[2]*N + R_HEIGHT*N/2 + txt_height/2)
    cr:set_source_rgb(0, 0, 0)
    cr:show_text (self.NAME)
    cr:stroke()
end

ECCView.Connection.__index = ECCView.Connection
function ECCView.Connection.new( ors , des ) --origin state and destiny state
    local self  = {}
    if ors.Top_Slot > ors.Top_Connections then
        ors.Top_Slot = 1
    end
    if des.Top_Slot > des.Top_Connections then
        des.Top_Slot = 1
    end
    if ors.Down_Slot > ors.Down_Connections then
        ors.Down_Slot = 1
    end
    if des.Down_Slot > des.Down_Connections then
        des.Down_Slot = 1
    end
    if ors.Right_Slot > ors.Right_Connections then
        ors.Right_Slot = 1
    end
    if des.Right_Slot > des.Right_Connections then
        des.Right_Slot = 1
    end
    if ors.Left_Slot > ors.Left_Connections then
        ors.Left_Slot = 1
    end
    if des.Left_Slot > des.Left_Connections then
        des.Left_Slot = 1
    end
    self.ors    = ors
    self.des    = des
    local dx    = des.ORIGEM[1] - ors.ORIGEM[1]    
    local dy    = des.ORIGEM[2] - ors.ORIGEM[2]
    self.theta  = math.atan2 (dy, dx)
    self.v1 = {-math.cos(PHI)*ARROW_SIZE, math.sin(PHI)*ARROW_SIZE}
    self.v2 = {-math.cos(PHI)*ARROW_SIZE, -math.sin(PHI)*ARROW_SIZE}
    self.v1, self.v2 = arrow_rotate(self.v1, self.v2, self.theta)
    if dy == 0 then dy = 0.001 end
    if dx == 0 then dx = 0.000001 end
    self.CORPO         = {}
    self.CORPO.CLICKED = false
    if dx <= 0 and dy <= 0 then    
        if (dy/dx) > SLOPE then
            self.Orientation = 'TD'  --lado da origem, lado do destino
        else
            self.Orientation = 'LR'
        end
    elseif dx <= 0  and dy >= 0 then
        if -(dy/dx) > SLOPE then
            self.Orientation = 'DT'  --lado da origem, lado do destino
        else
            self.Orientation = 'LR'
        end
    elseif dx >= 0 and dy <= 0 then
        if -(dy/dx) > SLOPE then
            self.Orientation = 'TD'  --lado da origem, lado do destino
        else
            self.Orientation = 'RL'
        end
    elseif dx >= 0 and dy >= 0 then
        if (dy/dx) > SLOPE then
            self.Orientation = 'DT'  --lado da origem, lado do destino
        else
            self.Orientation = 'RL'
        end
    end
    self.ORIGEM  = {}
    self.DESTINO = {}
    --1º caso TD
    if self.Orientation == 'TD' then
        self.ORIGEM[1]   = ors.ORIGEM[1]  + (R_WIDTH/(ors.Top_Connections+1)) *ors.Top_Slot
        self.ORIGEM[2]   = ors.ORIGEM[2]
        self.DESTINO[1]  = des.ORIGEM[1]  + (R_WIDTH/(des.Down_Connections+1)) *des.Down_Slot
        self.DESTINO[2]  = des.ORIGEM[2]  + R_HEIGHT
        des.Down_Slot    = des.Down_Slot  + 1
        ors.Top_Slot     = ors.Top_Slot   + 1
    elseif self.Orientation == 'DT' then
        self.ORIGEM[1]   = ors.ORIGEM[1]  + (R_WIDTH/(ors.Down_Connections+1)) *ors.Down_Slot
        self.ORIGEM[2]   = ors.ORIGEM[2]  + R_HEIGHT
        self.DESTINO[1]  = des.ORIGEM[1]  + (R_WIDTH/(des.Top_Connections+1)) *des.Top_Slot
        self.DESTINO[2]  = des.ORIGEM[2]
        ors.Down_Slot    = ors.Down_Slot  + 1
        des.Top_Slot     = ors.Top_Slot   + 1
    elseif self.Orientation == 'RL' then
        self.ORIGEM[1]   = ors.ORIGEM[1]  + R_WIDTH
        self.ORIGEM[2]   = ors.ORIGEM[2]  + (R_HEIGHT/(ors.Right_Connections+1)) *ors.Right_Slot 
        self.DESTINO[1]  = des.ORIGEM[1] 
        self.DESTINO[2]  = des.ORIGEM[2]  + (R_HEIGHT/(des.Left_Connections+1)) *des.Left_Slot
        ors.Right_Slot   = ors.Right_Slot + 1
        des.Left_Slot    = des.Left_Slot  + 1    
    elseif self.Orientation == 'LR' then
        self.ORIGEM[1]   = ors.ORIGEM[1]   
        self.ORIGEM[2]   = ors.ORIGEM[2]  + (R_HEIGHT/(ors.Left_Connections+1)) *ors.Left_Slot 
        self.DESTINO[1]  = des.ORIGEM[1]  + R_WIDTH
        self.DESTINO[2]  = des.ORIGEM[2]  + (R_HEIGHT/(des.Right_Connections+1)) *des.Right_Slot
        des.Right_Slot   = des.Right_Slot + 1
        ors.Left_Slot    = ors.Left_Slot  + 1    
    end
    setmetatable (self, ECCView.Connection)
    return self
end

function ECCView.Connection:draw( widget, cr )
    cr:set_antialias (0)
    
    cr:move_to (self.ORIGEM[1]*N, self.ORIGEM[2]*N)
    cr:line_to (self.DESTINO[1]*N, self.DESTINO[2]*N)
    cr:set_line_width (1.5*N)
    cr:move_to (self.DESTINO[1]*N+ self.v1[1]*N, self.DESTINO[2]*N +self.v1[2]*N)
    cr:line_to (self.DESTINO[1]*N, self.DESTINO[2]*N)
    cr:move_to (self.DESTINO[1]*N+self.v2[1]*N, self.DESTINO[2]*N + self.v2[2]*N)
    cr:line_to (self.DESTINO[1]*N, self.DESTINO[2]*N)
    cr:stroke()
    cr:set_antialias (1)
end

function ECCView.Connection:get_clicked()
    return false
end

function ECCView.Connection:MOVE()
    return false
end

function ECCView.Count ( ors, des )
    --print(ors.NAME, des.NAME)
    local dx = des.ORIGEM[1] - ors.ORIGEM[1]    
    local dy = des.ORIGEM[2] - ors.ORIGEM[2]

    if dy == 0 then dy = 0.00001 end
    if dx == 0 then dx = 0.00001 end
    if dx <= 0 and dy <= 0 then    
        if (dy/dx) > SLOPE then
            des.Down_Connections  = des.Down_Connections  + 1
            ors.Top_Connections   = ors.Top_Connections   + 1
        else
            des.Right_Connections = des.Right_Connections + 1
            ors.Left_Connections  = ors.Left_Connections  + 1
        end
    elseif dx <= 0  and dy >= 0 then
        if -(dy/dx) > SLOPE then
            des.Top_Connections   = des.Top_Connections   + 1
            ors.Down_Connections  = ors.Down_Connections  + 1
        else
            des.Right_Connections = des.Right_Connections + 1
            ors.Left_Connections  = ors.Left_Connections  + 1
        end
    elseif dx >= 0 and dy <= 0 then
        if -(dy/dx) > SLOPE then
            des.Down_Connections  = des.Down_Connections  + 1
            ors.Top_Connections   = ors.Top_Connections   + 1
        else
            des.Left_Connections  = des.Left_Connections  + 1
            ors.Right_Connections = ors.Right_Connections + 1
        end
    elseif dx >= 0 and dy >= 0 then
        if (dy/dx) > SLOPE then
            des.Top_Connections   = des.Top_Connections   + 1
            ors.Down_Connections  = ors.Down_Connections  + 1
        else
            des.Left_Connections  = des.Left_Connections  + 1
            ors.Right_Connections = ors.Right_Connections + 1
        end
    end
end

function ECCView.ECState:get_clicked(widget, x, y)
    self.X, self.Y = x, y
    if x >= self.ORIGEM[1]*N and x <= self.ORIGEM[1]*N + R_WIDTH*N and y >= self.ORIGEM[2]*N and y <= self.ORIGEM[2]*N + R_HEIGHT*N then
        self.CORPO.CLICKED = true
        widget:queue_draw()
        return true
    else 
        self.CORPO.CLICKED = false
        return false
    end
end 
function ECCView.ECState:MOVE(widget, LOAD, b, c, x, y)
    if LOAD then
		x, y = self.X, self.Y 
    end
    if self.CORPO.CLICKED or LOAD then
        self.ORIGEM[1] = self.ORIGEM[1] + x/N - self.X/N
        self.ORIGEM[2] = self.ORIGEM[2] + y/N - self.Y/N
        if self.ORIGEM[1] < 0 then self.ORIGEM[1] = 0 end
        if self.ORIGEM[2] < 0 then self.ORIGEM[2] = 0 end
        self.X, self.Y = x, y
        if self.UPPER then 
            self.UPPER:MOVE()
			self.UPPER.UPPER._FunctionBlock.STdx[self.NAME] = self.ORIGEM[1]
			self.UPPER.UPPER._FunctionBlock.STdy[self.NAME] = self.ORIGEM[2]
        end
        widget:queue_draw()
        return true
    end
	
    return false
end 



ECCView.__index = ECCView
function ECCView.new(FB, UPPER)
    local self = {}
    self.UPPER      = UPPER
	self.STATE_LIST = {}
    self.stlist     = FB.stlist
    self.LABEL = FB.label
    for i, v in pairs(FB.stlist) do
        self.STATE_LIST[#self.STATE_LIST + 1]   = ECCView.ECState.new(i, FB.STdx[i], FB.STdy[i])
        self.STATE_LIST[i]                      = self.STATE_LIST[#self.STATE_LIST]
        self[i]                                 = self.STATE_LIST[#self.STATE_LIST]
    end
    for i, v in ipairs(self.UPPER._FunctionBlock.transitions) do
		ECCView.Count(self.STATE_LIST[v.Source], self.STATE_LIST[v.Destination])
    end 
    
	for i , v in ipairs(self.STATE_LIST) do
        v.UPPER = self
    end
    
	self.CONNECTION_LIST = {}
    for j, v in ipairs(FB.transitions) do
        local dest = v.Destination
		local i    = v.Source
        self.CONNECTION_LIST[ #self.CONNECTION_LIST + 1 ] = ECCView.Connection.new (self.STATE_LIST[i], self.STATE_LIST[dest])
        self.STATE_LIST[i].Connections [#self.STATE_LIST[i].Connections+1]       = self.CONNECTION_LIST[ #self.CONNECTION_LIST ]
        self.STATE_LIST[dest].Connections [#self.STATE_LIST[dest].Connections+1] = self.CONNECTION_LIST[ #self.CONNECTION_LIST ]
    end
    setmetatable(self, ECCView)
    return self
end

function ECCView:draw(widget, cr)
    for i, v in ipairs(self.CONNECTION_LIST) do
        v:draw(widget, cr)
    end
    for i, v in ipairs(self.STATE_LIST) do
        v:draw(widget, cr)
    end
    local st_pos   = 0
    local cond_pos = 0
    cr:move_to (50*N, 34*N)
    cr:set_font_size (14*N)
    cr:show_text('*State List*')
    cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    for i, v in pairs(self.stlist) do
        cr:move_to (50*N, 50*N + 16*st_pos*N)
        st_pos = st_pos + 1
        cr:set_font_size (14*N)
        cr:show_text(i)
        if v.action then
            for g, h in ipairs (v.action) do
                cr:move_to (55*N, 50*N + 16*st_pos*N)
                cr:show_text('alg: '..(h.alg or 'N/A')..' ; output: '..(h.out or 'N/A'))
                st_pos = st_pos + 1
            end
        end
    end 
    
    cr:move_to (50*N, 100*N + 16*(-1+st_pos)*N )
    cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:set_font_size(14*N)
    cr:show_text('*Transitions*:')
    cr:select_font_face('sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
	for i, v in ipairs(self.UPPER._FunctionBlock.transitions) do
        cr:move_to (50*N, 100*N + 16*(cond_pos+st_pos)*N)
        cond_pos = cond_pos + 1
        cr:set_font_size (14*N)
        cr:show_text(v.Source..' -> '..v.Destination..' Condition: '..v.Condition)
    end    
         
    
end

function ECCView:MOVE(widget, cr)
    for i, v in ipairs(self.UPPER._FunctionBlock.transitions) do  
        self.STATE_LIST[v.Source].Top_Connections        = 0
        self.STATE_LIST[v.Source].Down_Connections       = 0
        self.STATE_LIST[v.Source].Left_Connections       = 0
        self.STATE_LIST[v.Source].Right_Connections      = 0
        self.STATE_LIST[v.Destination].Top_Connections   = 0
        self.STATE_LIST[v.Destination].Down_Connections  = 0
        self.STATE_LIST[v.Destination].Left_Connections  = 0
        self.STATE_LIST[v.Destination].Right_Connections = 0
    end
    for i, v in ipairs(self.UPPER._FunctionBlock.transitions) do
        ECCView.Count(self.STATE_LIST[v.Source], self.STATE_LIST[v.Destination])
    end 
     self.CONNECTION_LIST = {}
    for j, v in pairs(self.UPPER._FunctionBlock.transitions) do
        local dest = v.Destination
		local i    = v.Source
        self.CONNECTION_LIST[ #self.CONNECTION_LIST + 1 ] = ECCView.Connection.new (self.STATE_LIST[i], self.STATE_LIST[dest])
        self.STATE_LIST[i].Connections [#self.STATE_LIST[i].Connections+1] = self.CONNECTION_LIST[ #self.CONNECTION_LIST ]
        self.STATE_LIST[dest].Connections [#self.STATE_LIST[dest].Connections+1] = self.CONNECTION_LIST[ #self.CONNECTION_LIST ]
    end
    
end
