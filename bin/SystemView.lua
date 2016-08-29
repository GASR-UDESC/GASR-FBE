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
require('BlockView')
require('CompView')
require('ResourceView')
require('DeviceView')

local TIPO_DX            = 10  --distancia da origem que vai ficar o tipo 
local TIPO_DY            = 15
SystemView               = {}
SystemView.BODY          = {}
SystemView.LABEL         = {}
SystemView.SYSTEM_TYPE   = {}
local function clone( t, deep )
    local r = {}
    for k, v in pairs( t ) do
        if deep and type( v ) == 'table'
            then r[ k ] = clone( v, deep )
            else r[ k ] = v
            end
    end
    return r
end

SystemView.BODY.__index = SystemView.BODY 
function SystemView.BODY.new(S)
    local self   		= {}
    self.TOP     		= {S.ORIGEM[1], S.ORIGEM[2]}
    self.DOWN    		= {S.ORIGEM[1] + #S.SystemType*T_SPC, S.ORIGEM[2] +#S.SystemType*T_SPC}
    self.WIDTH   		= self.DOWN[1]-self.TOP[1]
    self.HEIGHT  		= self.DOWN[2]-self.TOP[2]
    if self.WIDTH  < 100 then  self.WIDTH = 100 end
    if self.HEIGHT < 100 then self.HEIGHT = 100 end
    self.CLICKED = false
    setmetatable (self, SystemView.BODY)
    return self
end

function SystemView.BODY:draw(widget, cr)
    if self.CLICKED 
        then
        cr:set_source_rgb (0.8, 0.6, 0.6)
        else
        cr:set_source_rgb (0.8, 0.8, 0.9)
    end
    cr:rectangle(self.TOP[1]*N, self.TOP[2]*N, self.WIDTH*N, self.HEIGHT*N)
    cr:fill()
    cr:set_source_rgb(0, 0, 0)
    cr:move_to(self.TOP[1]*N, self.TOP[2]*N)
    cr:rel_line_to(0, self.HEIGHT*N)
    cr:rel_line_to(self.WIDTH*N, 0)
    cr:rel_line_to(0, -self.HEIGHT*N)
    cr:rel_line_to(-self.WIDTH*N, 0)
    cr:stroke()
end

SystemView.SYSTEM_TYPE.__index = SystemView.SYSTEM_TYPE
SystemView.SYSTEM_TYPE.new = function (S)
    local self = {}
    self.ORIGEM = S.ORIGEM
    self.NAME   = S.SystemType
    self.POS    = {self.ORIGEM[1] + TIPO_DX , (S.CORPO.TOP[2] +TIPO_DY) }
    setmetatable(self, SystemView.SYSTEM_TYPE)
    return self
end

function SystemView.SYSTEM_TYPE:draw (widget, cr)
    cr:set_source_rgb(0, 0, 0)
    cr:set_font_size(10*N)
    cr:move_to (self.POS[1]*N, self.POS[2]*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.NAME)
    cr:move_to (self.POS[1]*N, self.POS[2]*N+15*N)
    cr:show_text ('(System)')
end

SystemView.LABEL.__index = SystemView.LABEL
SystemView.LABEL.new = function ( S )
    local self  = {}
    self.ORIGEM = S.ORIGEM
    self.NAME   = S.label
    self.POS    = {self.ORIGEM[1] + 0.5*S.CORPO.WIDTH - 3.14*#self.NAME, self.ORIGEM[2] - 5}
    setmetatable(self, SystemView.LABEL)
    return self
end

function SystemView.LABEL:draw (widget, cr)
    cr:set_source_rgb(0, 0, 0)
    cr:set_font_size(10*N)
    cr:move_to (self.POS[1]*N, self.POS[2]*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.NAME)
end

function SystemView:get_clicked(widget, x, y)
    self.X, self.Y = x, y
    if x >= self.ORIGEM[1]*N and x <= self.ORIGEM[1]*N + self.CORPO.WIDTH*N and y >= self.ORIGEM[2]*N and y <=self.ORIGEM[2]*N + self.CORPO.HEIGHT*N then
        if self.CORPO.CLICKED then
            self:double_click(widget)
        end
        self.CORPO.CLICKED = true
        widget:queue_draw()
        return true
    else
        self.CORPO.CLICKED = false
        widget:queue_draw()
        return false
    end
end

function SystemView:double_click(widget)
    ApStructs = nil ApStructs = {}
    self.CORPO.CLICKED = false
    self.DrawType = 'open'
    widget:queue_draw()
    return true
end

function SystemView:MOVE(widget,LOAD, block_moved, static, x, y)
    if LOAD or static then
        x = self.X
        y = self.Y
    end
    if self.CORPO.CLICKED or LOAD then
        self.ORIGEM[1], self.ORIGEM[2] = self.ORIGEM[1] + x/N - self.X/N, self.ORIGEM[2] +  y/N - self.Y/N
        if self.ORIGEM[1] < 0 then self.ORIGEM[1] = 0 end
        if self.ORIGEM[2] < 0 then self.ORIGEM[2] = 0 end
        local dx, dy = x - self.X, y - self.Y
        self.X, self.Y = x, y
        self.CORPO = SystemView.BODY.new(self)
        self.TIPO  = SystemView.SYSTEM_TYPE.new( self)
        self.INSTANCIA = SystemView.LABEL.new( self)
        self.CORPO.CLICKED = not LOAD
        --~ if self.UPPER then
            --~ self.UPPER:MOVE(widget, LOAD, self) 
        --~ end
        widget:queue_draw()
        return true
    end
    widget:queue_draw()
    return false
end

SystemView.__index = SystemView
function SystemView.new(S, origem)
    local self                    = clone(S, false)
    self._FunctionBlock 		  = S
    self.XTREME                   = {}
    self.NAME                     = S.label
    self._Type                    = 'SystemView'
    self.DrawType                 = 'closed'
    if origem then origem         = {tonumber(origem[1]), tonumber(origem[2])} end
    self.ORIGEM                   = origem or {200, 150}
    self.SLOT                     = {}
    
    
    --------------------------------------------------
    --cria o corpo
    self.CORPO = SystemView.BODY.new(self)
    self.CORPO.CLICKED = false
    
    --------------------------------------------------
    
    
    --cria o texto com nome de instância e tipo de System
    self.TIPO            = SystemView.SYSTEM_TYPE.new(self)
    self.INSTANCIA       = SystemView.LABEL.new(self)
    self.INSTANCIA.UPPER = self
    -----------------------------------------------------
    
    --Cria os blocos internos
    self.BLOCKS = {}
    for i, v in ipairs (S.DeviceList) do
        self.BLOCKS[#self.BLOCKS+1] = DeviceView.new(v[1], {v[2], v[3]})
        self[v[1].label]                  = self.BLOCKS[#self.BLOCKS]
        self[v[1].label].UPPER            = self
    end
    ------------------------------------------------------
    
    
    setmetatable(self, SystemView)
    return self
end

function SystemView:draw(widget, cr)
    --desenha o device aberto (rede de FB's internos)
    if self.DrawType == 'open' then
        F.Struct = self                         --estrutura global = self   
        ApStructs = nil ApStructs = {}          --zera estruturas aparentes
        for i, v in ipairs (self.BLOCKS) do     
            v:draw(widget, cr)                  --desenha cada bloco, adicionando às estruturas aparentes
        end
    -------------------------------------------------
    --ou desenha o bloco fechado 
    else
        local already_is = false
        for i, v in ipairs(ApStructs) do
            if self.INSTANCIA.NAME == v.INSTANCIA.NAME then
                already_is = true
            end                                 --evita de ser desenhado duas vezes
        end
        if not already_is then
            ApStructs[#ApStructs+1] = self
        end
        cr:set_antialias (1)                     --desliga o antialising
        self.CORPO:draw (widget, cr)             --desenha o corpo
        self.TIPO:draw(widget, cr)               --'escreve' o nome do tipo do bloco
        self.INSTANCIA:draw(widget, cr)          --'escreve' o nome de instancia do bloco
    end
end


