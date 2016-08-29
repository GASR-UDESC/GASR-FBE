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

ResourceView               = {}
ResourceView.BODY          = {}
ResourceView.LABEL         = {}
ResourceView.CONNECTION    = {}
ResourceView.RESOURCE_TYPE = {}
ResourceView.PARAMETER     = {}

PARAMETER_SIZE             = 10
local c_trian 			   = 5
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

ResourceView.PARAMETER.__index = ResourceView.PARAMETER
function ResourceView.PARAMETER.new(block, name, value, tipo)
    local self     = {}
    self.NAME      = name
    self.INSTANCIA = {
        NAME = block.INSTANCIA.NAME..'.'..name
    }
    
    --~ print(block.INSTANCIA.NAME, name, block.XTREME[name])
    self.ORIGEM    = block.XTREME[name]
    self.TYPE      = tipo
    self.VALUE     = value
    self.BLOCK     = block
    self.X         = -1
    self.CORPO     = {
        CLICKED = false
    }
    setmetatable(self, ResourceView.PARAMETER)
    return self
end

function ResourceView.PARAMETER:draw(widget, cr)
    --~ local already_is = false
    --~ for i, v in ipairs(ApStructs) do
        --~ if self.INSTANCIA.NAME == v.INSTANCIA.NAME then
            --~ already_is = true
        --~ end                                 --evita de ser desenhado duas vezes
    --~ end
    --~ if not already_is then
        --~ ApStructs[#ApStructs+1] = self
    --~ end
--~ 
    --~ if self.CORPO.CLICKED then
        --~ cr:set_source_rgb (0.4, 0.2, 0.2)
    --~ else
        cr:set_source_rgb(0, 0, 0)
    --end
    cr:set_font_size (PARAMETER_SIZE*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    t_ext = cairo.TextExtents.create()
    cr:text_extents(self.VALUE, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    self.SIZE      = txt_width
    cr:rectangle (self.ORIGEM[1]*N - txt_width -2*N, self.ORIGEM[2]*N, txt_width, -txt_height)
    cr:set_source_rgb(0.8,0.8,1)
    cr:fill()
    cr:set_source_rgb(0,0,0)
    cr:move_to(self.ORIGEM[1]*N - txt_width -2*N, self.ORIGEM[2]*N)
    cr:show_text(self.VALUE)
end


ResourceView.BODY.__index = ResourceView.BODY 
function ResourceView.BODY.new( R )
    local self   = {}
    self.TOP     = { R.ORIGEM[1] , R.ORIGEM[2] }
    self.DOWN    = { R.ORIGEM[1] + R._BodyWidth, R.ORIGEM[2] + R._BodyWidth }
    self.WIDTH   = self.DOWN[1] - self.TOP[1]
    self.HEIGHT  = self.DOWN[2] - self.TOP[2]
    self.CLICKED = false
    setmetatable ( self , ResourceView.BODY )
    return self
end

function ResourceView.BODY:draw( widget, cr )
    if self.CLICKED 
        then
        cr:set_source_rgb ( 0.8 , 0.6 , 0.6 )
        else
        cr:set_source_rgb ( 0.8 , 0.8 , 0.9 )
    end
    cr:rectangle(self.TOP[ 1 ]*N, self.TOP[ 2 ]*N, self.WIDTH*N, self.HEIGHT*N)
    cr:fill()
    cr:set_source_rgb( 0 , 0 , 0 )
    cr:move_to(self.TOP[ 1 ]*N, self.TOP[ 2 ]*N)
    cr:rel_line_to( 0 , self.HEIGHT*N )
    cr:rel_line_to( self.WIDTH*N , 0)
    cr:rel_line_to(0 , -self.HEIGHT*N )
    cr:rel_line_to( -self.WIDTH*N , 0 )
    cr:stroke()
end

ResourceView.RESOURCE_TYPE.__index = ResourceView.RESOURCE_TYPE
ResourceView.RESOURCE_TYPE.new = function (R)
    local self      = {}
    self.ORIGEM     = R.ORIGEM
    self.NAME       = R.ResourceType
    self._BodyWidth = R._BodyWidth
    self.POS        = {self.ORIGEM[1]  , (R.CORPO.TOP[2] + R.CORPO.DOWN[2])/2}
    setmetatable(self, ResourceView.RESOURCE_TYPE)
    return self
end

function ResourceView.RESOURCE_TYPE:draw (widget, cr)
    cr:set_source_rgb(0, 0, 0)
    cr:set_font_size(10*N)
    
    local t_ext = cairo.TextExtents.create()
    --escreve o tipo do Resource
	cr:text_extents(self.NAME, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.NAME)
	--escreve a classe= Resource
	cr:text_extents('Resource', t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N + 10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text ('Resource')
end

ResourceView.LABEL.__index = ResourceView.LABEL
ResourceView.LABEL.new = function ( R )
    local self      = {}
    self.ORIGEM     = R.ORIGEM
    self.NAME       = R.label
    self._BodyWidth = R._BodyWidth
    self.POS        = {self.ORIGEM[1] , self.ORIGEM[2] - 5}
    setmetatable(self, ResourceView.LABEL)
    return self
end

function ResourceView.LABEL:draw (widget, cr)
    cr:set_source_rgb(0, 0, 0)
    cr:set_font_size(10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    local t_ext = cairo.TextExtents.create()
    cr:text_extents(self.NAME, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.NAME)
end

ResourceView.CONNECTION.__index = ResourceView.CONNECTION
ResourceView.CONNECTION.new = function (origem, destino, tipo, slot, ev, block, n, BV, seve_dvar, sb_db)
    local self     = {}
    self.n         = n
    self.BLOCK     = block
    self.SLOT      = slot
    self.EV        = ev         --e/v evento ou variável
    self.TIPO      = tipo
    self.CLICK_P   = {}          --ponto de click
    self.LIST      = {}
    self.UPPER     = BV
    self.SEVE_DVAR = seve_dvar   -- source event ou destination var
    self.SB_DB     = sb_db       -- source block ou destinationblock
    if origem == 'self' then
        self.ORIGEM = 'self'
    else
        self.ORIGEM    = {origem[1], origem[2]}
    end
    if destino == 'self' then
        self.DESTINO = 'self'
    else
        self.DESTINO   = {destino[1], destino[2]}
    end
	self.TIPO      = tipo
    if origem == 'self' or destino == 'self' then
        self.DIST_X, self.DIST_Y = origem, destino
    else
        self.DIST_X    = destino[1] - origem[1]
        self.DIST_Y    = destino[2] - origem[2]
    end
    if self.BLOCK then
        self.INVARS    = #self.BLOCK.invarlist
        self.OUTVARS   = #self.BLOCK.outvarlist
        self.INEVENTS  = #self.BLOCK.ineventlist
        self.OUTEVENTS = #self.BLOCK.outeventlist
        self.OUTEL     = self.OUTEVENTS + self.OUTVARS
    end
    self.INSTANCIA = {NAME    = 'CONNECTION'..n}
    self.CORPO     = {CLICKED = false}
    self.EL_CKD    = 0 --elemento clicado
    
    --0º caso -> destino ou origem no bloco composto
    if self.DIST_X == 'self' or self.DIST_Y == 'self' then
		if self.DIST_X == 'self' then
			self.LIST[1] = -10*N;
		else
			self.LIST[1] =  10*N;
		end
    --1º caso -> destino a direita e acima
    elseif self.DIST_X >= 0 and self.DIST_Y <=0 then
        self.LIST[1] = self.DIST_X*(0.8*(self.SLOT)/self.OUTEL)
        self.LIST[2] = self.DIST_Y
        self.LIST[3] = self.DIST_X*(1- 0.8*(self.SLOT)/self.OUTEL)
    --2º caso -> destino a direita e abaixo
    elseif self.DIST_X >=0 and self.DIST_Y >=0 then
        self.LIST[1] = self.DIST_X*(1 - 0.8*(self.SLOT)/self.OUTEL)
        self.LIST[2] = self.DIST_Y
        self.LIST[3] = self.DIST_X*(0.8*(self.SLOT)/self.OUTEL)
    --3º caso -> destino a esquerda e acima
    elseif self.DIST_X <=0 and self.DIST_Y <=0 then
        self.LIST[1] = self.SLOT*C_ESC_H_SPC
        if self.TIPO == 'event' then
            self.LIST[2] = -E_SPC*self.SLOT - C_ESC_V_SPC*self.SLOT --valor meio chutado, tentar melhorar
        else                                                                       
            self.LIST[2] = -E_SPC*self.SLOT - SV_SPC - C_ESC_V_SPC*self.SLOT
        end
        self.LIST[3] = - self.LIST[1] + self.DIST_X - C_ENT_H_SPC/(self.SLOT+2)
        self.LIST[4] = self.DIST_Y - self.LIST[2]
        self.LIST[5] = self.DIST_X - self.LIST[3] - self.LIST[1]
    --4º caso -> destino a esquerda e abaixo
    elseif self.DIST_X <=0 and self.DIST_Y >=0 then
        if self.TIPO == 'var' then
            self.LIST[1] = C_ESC_H_SPC * (self.OUTEL - self.SLOT +1)
            self.LIST[2] = E_SPC*( self.OUTEL + 1 - self.SLOT) + C_ESC_V_SPC*( self.OUTEL + 1 - self.SLOT)
        else                                                                       
            self.LIST[1] = C_ESC_H_SPC * (self.OUTEL - self.SLOT +1)
            self.LIST[2] = E_SPC*( self.OUTEL + 1 - self.SLOT) + C_ESC_V_SPC*( self.OUTEL + 1 - self.SLOT) + SV_SPC
        end
        self.LIST[3] = - self.LIST[1] + self.DIST_X - C_ESC_H_SPC*self.SLOT
        self.LIST[4] = self.DIST_Y - self.LIST[2]
        self.LIST[5] = self.DIST_X - self.LIST[3] - self.LIST[1]
    end
    setmetatable(self, ResourceView.CONNECTION)
    return self
end

function ResourceView.CONNECTION:draw(widget, cr)
    
    if Edit_Lines then
        local already_is = false
        for i, v in ipairs(ApStructs) do
            if self.INSTANCIA.NAME == v.INSTANCIA.NAME then
                already_is = true
            end                                 --evita de ser desenhado duas vezes
        end
        if not already_is then
            ApStructs[#ApStructs+1] = self
        end
    end
    if self.CORPO.CLICKED then
        cr:set_source_rgb (0.4, 0.0, 0)
    elseif self.TIPO == 'event' then
        cr:set_source_rgb (0, 0.4, 0)
    elseif self.TIPO == 'var' then
        cr:set_source_rgb (0, 0, 0.4)
    end
    if self.ORIGEM == 'self' then
        if self.CORPO.CLICKED then
			cr:set_source_rgb (0.4, 0.0, 0)
		else
			cr:set_source_rgb (0, 0, 0)
		end
        cr:move_to(self.DESTINO[1]*N, self.DESTINO[2]*N)
        cr:rel_line_to(-2*c_trian*N, 0)
        cr:rel_line_to(c_trian*N, c_trian*N)
        cr:move_to(self.DESTINO[1]*N, self.DESTINO[2]*N)
        cr:rel_move_to(-2*c_trian*N, 0)
        cr:rel_line_to(c_trian*N, -c_trian*N)
    elseif self.DESTINO == 'self' then
        if self.CORPO.CLICKED then
			cr:set_source_rgb (0.4, 0.0, 0)
		else
			cr:set_source_rgb (0, 0, 0)
		end
        cr:move_to(self.ORIGEM[1]*N, self.ORIGEM[2]*N)
        cr:rel_line_to(2*c_trian*N, 0)
        cr:rel_line_to(-c_trian*N, c_trian*N)
        cr:move_to(self.ORIGEM[1]*N, self.ORIGEM[2]*N)
        cr:rel_move_to(2*c_trian*N, 0)
        cr:rel_line_to(-c_trian*N, -c_trian*N)
    else
		cr:set_line_width(1.5*N)
		cr:move_to(self.ORIGEM[1]*N , self.ORIGEM[2]*N)
		if self.LIST then
			for i, v in ipairs (self.LIST) do
				if math.mod(i, 2) ~=0 then
					cr:rel_line_to(v*N, 0)
				else
					cr:rel_line_to(0, v*N)
				end
			end
		end
    end
    --cr:line_to(self.DESTINO[1], self.DESTINO[2])
    cr:stroke()
end

function ResourceView.CONNECTION:get_clicked(widget,  x, y)
     self.CLICK_P = {x, y}
    local x0, y0 = self.ORIGEM[1], self.ORIGEM[2]
    if self.ORIGEM == 'self' then
		x0, y0 = self.DESTINO[1], self.DESTINO[2];
	end
    for i, v in ipairs(self.LIST) do
        if v >=0 then
            if math.mod(i,2) ~= 0 then
                if y >= (y0 -TL)*N and y <= (y0 + TL)*N and x >= x0*N and x <= (x0 + v)*N then
                    self.CORPO.CLICKED = true
                    self.EL_CKD         = i
                    clicked_struct	    = self
                    return true
                end
            x0 = (x0 + v)
            else
                if y >= y0*N  and y <= (y0 + v)*N and x >= (x0 -TL)*N and x <= (x0 + TL)*N then
                    self.CORPO.CLICKED = true
                    self.EL_CKD         = i
                    clicked_struct	    = self
                    return true
                end
            y0 = (y0 + v)
            end
        else
           if math.mod(i,2) ~= 0 then
                if y >= (y0 -TL)*N and y <= (y0 + TL)*N and x <= x0*N and x >= (x0 + v)*N then
                    self.CORPO.CLICKED = true
                    self.EL_CKD         = i
                    clicked_struct	    = self
                    return true
                end
            x0 = (x0 + v)
            else
                if y <= y0*N  and y >= (y0 + v)*N and x >= (x0 - TL)*N and x <= (x0 + TL)*N then
                    self.CORPO.CLICKED = true
                    self.EL_CKD         = i
                    clicked_struct	    = self
                    return true
                end
            y0 = (y0 + v)
            end 
        end
    end
    self.EL_CKD        = 0
    self.CORPO.CLICKED = false
    return false
end

function ResourceView.CONNECTION:MOVE(widget, a, b, c, x, y)
    if self.CORPO.CLICKED then
        if self.EL_CKD == 0 or self.EL_CKD == 1 or self.EL_CKD == #self.LIST then
            return false
        end
        if math.mod(self.EL_CKD, 2) ~= 0 then
            local dy = y - self.CLICK_P[2]
            self.LIST[self.EL_CKD - 1] = self.LIST[self.EL_CKD - 1] + dy
            self.LIST[self.EL_CKD + 1] = self.LIST[self.EL_CKD + 1] - dy
        else
            local dx = x - self.CLICK_P[1]
            self.LIST[self.EL_CKD - 1] = self.LIST[self.EL_CKD - 1] + dx
            self.LIST[self.EL_CKD + 1] = self.LIST[self.EL_CKD + 1] - dx
        end
        self.CLICK_P       = {x, y}
        self.CORPO.CLICKED = true
        return true
    end
    return false
end

function ResourceView.CONNECTION:delete()
	if self.TIPO == 'event' then
		F.Struct._FunctionBlock.EventConnections[self.SB_DB][self.SEVE_DVAR] = nil
	elseif self.TIPO == 'var' then
		F.Struct._FunctionBlock.DataConnections[self.SB_DB][self.SEVE_DVAR] = nil
	end
	refresh_resource()
	
end

function ResourceView:get_clicked(widget, x, y)
    self.X, self.Y = x, y
    if x >= self.ORIGEM[1]*N and x <= self.ORIGEM[1]*N + self.CORPO.WIDTH*N and y >= self.ORIGEM[2]*N and y <=self.ORIGEM[2]*N + self.CORPO.HEIGHT *N then
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

function ResourceView:double_click(widget)
    ApStructs = nil ApStructs = {}
    self.CORPO.CLICKED = false
    self.DrawType = 'open'
    --print(self.ORIGEM[1], self.ORIGEM[2])
    F.CurrentStructEntry:set('text', self._FunctionBlock.FBType)
	F.Struct = self
	widget:queue_draw()
    return true
end

function ResourceView:MOVE(widget, LOAD, block_moved, static, x, y)
    if LOAD or static then
        x = self.X
        y = self.Y
    end
    if self.CORPO.CLICKED or LOAD then
        self.ORIGEM[1], self.ORIGEM[2] = self.ORIGEM[1] + x/N - self.X/N, self.ORIGEM[2]+ y/N - self.Y/N
        if self.ORIGEM[1] < 0 then self.ORIGEM[1] = 0 end
        if self.ORIGEM[2] < 0 then self.ORIGEM[2] = 0 end
        local dx, dy = x - self.X, y - self.Y
        self.X, self.Y = x, y
        self.CORPO = ResourceView.BODY.new(self)
        

        if block_moved then
            for i, v in ipairs (self.CONNECTION_LIST) do
                local origem, destino
                if v.B_OR.INSTANCIA.NAME   == block_moved.INSTANCIA.NAME or  v.B_DEST.INSTANCIA.NAME == block_moved.INSTANCIA.NAME then
                    if v.TIPO == 'event' then
                        if v.B_DEST.INSTANCIA.NAME == 'self' then
                            destino = 'self'
                        else
                            destino = {v.B_DEST.IN_EVENT_TARGET[v.EV_DEST][1] - 10*v.B_DEST.IN_WITHS, v.B_DEST.IN_EVENT_TARGET[v.EV_DEST][2]-2}
                        end
                        if v.B_OR.INSTANCIA.NAME == 'self' then
                            origem = 'self'
                        else
                            origem  = {v.B_OR.OUT_EVENT_TARGET[v.EV_OR][1] + 10*v.B_OR.OUT_WITHS , v.B_OR.OUT_EVENT_TARGET[v.EV_OR][2]-2 }
                        end
                        local aux   = {}
                        aux.B_OR    = v.B_OR   
                        aux.B_DEST  = v.B_DEST 
                        aux.EV_OR   = v.EV_OR
                        aux.EV_DEST = v.EV_DEST
                            
                        if v.B_OR.INSTANCIA.NAME == 'self' then
                            v           = ResourceView.CONNECTION.new (origem, destino, v.TIPO, v.SLOT, v.EV, nil, v.n, self, v.SEVE_DVAR, v.SB_DB)
                        else              
                            v           = ResourceView.CONNECTION.new (origem, destino, v.TIPO, v.SLOT, v.EV, v.B_OR, v.n, self, v.SEVE_DVAR, v.SB_DB)
                        end
                        v.B_OR      = aux.B_OR
                        v.B_DEST    = aux.B_DEST
                        v.EV_OR     = aux.EV_OR
                        v.EV_DEST   = aux.EV_DEST
                    else
                        if v.B_DEST.INSTANCIA.NAME == 'self' then
                            destino = 'self'
                        else
                            destino = {v.B_DEST.IN_VAR_TARGET[v.EV_DEST][1] - 10*v.B_DEST.IN_WITHS, v.B_DEST.IN_VAR_TARGET[v.EV_DEST][2]-2}
                        end
                        if v.B_OR.INSTANCIA.NAME == 'self' then
                            origem = 'self'
                        else
                            origem  = {v.B_OR.OUT_VAR_TARGET[v.EV_OR][1] + 10*v.B_OR.OUT_WITHS, v.B_OR.OUT_VAR_TARGET[v.EV_OR][2]-2 }
                        end
                        local aux   = {}
                        aux.B_OR    = v.B_OR   
                        aux.B_DEST  = v.B_DEST 
                        aux.EV_OR   = v.EV_OR 
                        aux.EV_DEST = v.EV_DEST
                        if v.B_OR.INSTANCIA.NAME == 'self' then
                            v = ResourceView.CONNECTION.new (origem, destino, v.TIPO, v.SLOT, v.EV, nil, v.n, self, v.SEVE_DVAR, v.SB_DB)
                        else
                            v = ResourceView.CONNECTION.new (origem, destino, v.TIPO, v.SLOT, v.EV, v.B_OR, v.n, self, v.SEVE_DVAR, v.SB_DB)
                        end
                        v.B_OR    = aux.B_OR
                        v.B_DEST  = aux.B_DEST
                        v.EV_OR   = aux.EV_OR
                        v.EV_DEST = aux.EV_DEST
                    end
                end
                self.CONNECTION_LIST[i] = v
            end
        end
        if block_moved then
            for i, v in ipairs (self.PARAMETER_LIST) do
                if self.PARAMETER_LIST[i].BLOCK.INSTANCIA.NAME == block_moved.INSTANCIA.NAME then
                    self.PARAMETER_LIST[i] = ResourceView.PARAMETER.new(self.PARAMETER_LIST[i].BLOCK, self.PARAMETER_LIST[i].NAME, self.PARAMETER_LIST[i].VALUE, self.PARAMETER_LIST[i].TYPE)
                end
            end
        end
        self.TIPO  = ResourceView.RESOURCE_TYPE.new( self)
        self.INSTANCIA = ResourceView.LABEL.new( self)
        self.CORPO.CLICKED = not LOAD
        --~ if self.UPPER then
            --~ self.UPPER:MOVE(widget, LOAD, self,  true, x, y) 
        --~ end
        widget:queue_draw()
        return true
    end
    widget:queue_draw()
    return false
end

ResourceView.__index = ResourceView
function ResourceView.new(R, origem)
    local self                    = clone(R, false)
    self._FunctionBlock           = R
    self.XTREME                   = {}
    self._Type                    = 'ResourceView'
    self.NAME                     = R.label
    self.Event_Connections        = clone (R.EventConnections, true)
    self.Data_Connections         = clone (R.EventConnections, true)
    self.Parameters               = R.Parameters
    self.DrawType                 = 'closed'
    if origem then origem         = {tonumber(origem[1]), tonumber(origem[2])} end
    self.ORIGEM                   = origem or {200, 150}
    self.SLOT                     = {}
    
    
    --------------------------------------------------
    --cria o corpo
    --self._BodyWidth    = #self.ResourceType*T_SPC
    --~ if self._BodyWidth < 100 then
        self._BodyWidth = 195
    --~ end
    self.CORPO         = ResourceView.BODY.new(self)
    self.CORPO.CLICKED = false
    
    --------------------------------------------------
    
    
    --cria o texto com nome de instância e tipo do Recurso
    self.TIPO      = ResourceView.RESOURCE_TYPE.new(self)
    self.INSTANCIA = ResourceView.LABEL.new(self)
    -----------------------------------------------------
    
    --Cria os blocos internos
    self.BLOCKS = {}
    for i, v in ipairs (R.FBNetwork) do
        if R[v[1]].Class == 'Basic' then
            self.BLOCKS[#self.BLOCKS+1] = BlockView.new(R[v[1]], {R[v[1]].dx, R[v[1]].dy})
            self.BLOCKS[v[1]]           = self.BLOCKS[#self.BLOCKS]
            self[v[1]]                  = self.BLOCKS[#self.BLOCKS]
            self[v[1]].UPPER            = self
        elseif R[v[1]].Class == 'Composite' or  R[v[1]].Class =='Comp' then
            self.BLOCKS[#self.BLOCKS+1] = CompView.new(R[v[1]], {R[v[1]].dx, R[v[1]].dy})
            self.BLOCKS[v[1]]           = self.BLOCKS[#self.BLOCKS]
            self[v[1]]                  = self.BLOCKS[#self.BLOCKS]
            self[v[1]].UPPER            = self
        else
            self.BLOCKS[#self.BLOCKS+1] = BlockView.new(R[v[1]], {R[v[1]].dx, R[v[1]].dy})
            self.BLOCKS[v[1]]           = self.BLOCKS[#self.BLOCKS]
            self[v[1]]                  = self.BLOCKS[#self.BLOCKS]
            self[v[1]].UPPER            = self
        end
    end
    ------------------------------------------------------
    
    --Cria Conexões de evento e variável
    self.CONNECTION_LIST = {}
    for i, v in pairs (self.EventConnections) do
        for j, k in pairs (v) do
            local slot = '-1'
            --print(self[i]._FunctionBlock.FBType)
			if self[i] and self[i].outeventlist[j].SLOT then
                slot    = self[i].outeventlist[j].SLOT
            end
            local ev      = j
            --print(k[1], k[2])
            local destino = {self[k[1]].IN_EVENT_TARGET[k[2]][1] - 10*self[k[1]].IN_WITHS, self[k[1]].IN_EVENT_TARGET[k[2]][2]-2}
            local origem  = {self[i].OUT_EVENT_TARGET[j][1] + 10*self[i].OUT_WITHS, self[i].OUT_EVENT_TARGET[j][2]-2}
            local tam = #self.CONNECTION_LIST 
            self.CONNECTION_LIST[tam + 1]         = ResourceView.CONNECTION.new(origem, destino, 'event', slot, ev, self[i], tam+1, self, j, i)
            
            self.CONNECTION_LIST[tam + 1].B_OR    = self[i]
            
            self.CONNECTION_LIST[tam + 1].B_DEST  = self[k[1]]     
            
            self.CONNECTION_LIST[tam + 1].EV_DEST = k[2]
            self.CONNECTION_LIST[tam + 1].EV_OR   = j
        end 
    end
    for i, v in pairs (self.DataConnections) do
        for j, k in pairs (v) do
            --k[1] == origem e i == destino
            local slot = '-1'
            --~ print(k[1], k[2])
            if self[k[1]] and self[k[1]].outvarlist[k[2]].SLOT2 then
                slot     = self[k[1]].outvarlist[k[2]].SLOT2
            end
            local origem, destino
            local ev       = k[2]
            if k[1] == 'self' then
                origem = 'self'
            else
                --~ print(self._ResourceType, self.label,k[1], k[2])
                origem   = {self[k[1]].OUT_VAR_TARGET[k[2]][1] + 10*self[k[1]].OUT_WITHS, self[k[1]].OUT_VAR_TARGET[k[2]][2]-2}
            end
            if i == 'self' then
                destino = 'self'
            else
                destino  = {self[i].IN_VAR_TARGET[j][1] - 10*self[i].IN_WITHS, self[i].IN_VAR_TARGET[j][2]-2}
            end
            local tam = #self.CONNECTION_LIST 
            self.CONNECTION_LIST[tam +1]         = ResourceView.CONNECTION.new(origem, destino, 'var', slot, ev, self[k[1]], tam+1, self, j, i)
            self.CONNECTION_LIST[tam + 1].B_OR    = self[k[1]] or 'self'
            self.CONNECTION_LIST[tam + 1].B_DEST  = self[i]    or 'self'
            if self.CONNECTION_LIST[tam + 1].B_OR == 'self' then
                self.CONNECTION_LIST[tam + 1].B_OR = {INSTANCIA = {NAME = 'self'}}
            end
            if self.CONNECTION_LIST[tam + 1].B_DEST == 'self' then
                self.CONNECTION_LIST[tam + 1].B_DEST = {INSTANCIA = {NAME = 'self'}}
            end
            self.CONNECTION_LIST[tam + 1].EV_DEST = j
            self.CONNECTION_LIST[tam + 1].EV_OR   = k[2]
        end 
    end

    -------------------------------------------------------------
    --insere os parâmetros descritos no XML
    self.PARAMETER_LIST = {}
    for i, v in ipairs (R.Parameters) do
        local tipo = R[v[1]]--.flag[v[2]]
        self.PARAMETER_LIST[#self.PARAMETER_LIST +1] = ResourceView.PARAMETER.new(self.BLOCKS[v[1]],v[2], v[3], tipo)
    end
    
    setmetatable(self, ResourceView)
    return self
end

function ResourceView:draw(widget, cr)
    --desenha o bloco aberto (rede de FB's internos)
    if self.DrawType == 'open' then
        F.Struct                  = self        --estrutura global = self   
        ApStructs = nil ApStructs = {}          --zera estruturas aparentes
        cr:set_antialias (0)                    --liga o antialiasing p/ desenhar conexões
        for i, v in ipairs(self.CONNECTION_LIST) do 
            v:draw(widget, cr)                  --desenha conexões, adicionando às estruturas aparentes 
        end
        
        for i, v in ipairs(self.PARAMETER_LIST) do --desenha os parametros
            v:draw(widget, cr)
        end
        
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
