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
require('ECCView')
require('SDView')

E_SPC  = 25  --espaçamento entre os eventos
V_SPC  = 25  --espaçamento entre as variáveis
T_SPC  = 7  --largura do bloco dependendo do tipo do bloco
SH_SPC = 10  --largura do separador, horizontal
SV_SPC = 17  --largura do separador, vertical


local IN_WITHS          = 0
local OUT_WITHS         = 0
BlockView               = {}
BlockView.BODY          = {}
BlockView.EVENT         = {}
BlockView.VAR           = {}
BlockView.FBTYPE        = {}
BlockView.LABEL         = {}
BlockView.WITH          = {}
BlockView.XTREME        = {}
BlockView.FUNCTIONALITY = {}

local function clone( t, deep )
    local r = {}
    for k, v in pairs( t ) do
        if deep and type( v ) == 'table' 
            then r[ k ] = clone( v, true )
            else r[ k ] = v
        end
    end
    return r
end


function BlockView.FUNCTIONALITY.new (FB,funct)
    local funcao
	funcao = function()
		FB._Resource[FB.label]:exe()
	end
	return funcao
end

BlockView.BODY.__index = BlockView.BODY 
function BlockView.BODY.new(BV)
	local self = {}
	--MELHORAR----------------------------
	--------------------------------------
	if BV._FunctionBlock.other.Neural then
		self.Color1 = {0.5, 0.7, 0.6}
		self.Color2 = {0.8, 0.7, 0.6}
	end
	if BV._FunctionBlock._get_active_color then
		self.Color1, self.Color2 = BV._FunctionBlock:_get_active_color()
	end
	--------------------------------------
	----------------------------MELHORAR--
    self.TOP        = {BV.ORIGEM[1], BV.ORIGEM[2], BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2]}  --(x1, y1, x2, y2)
    self.LEFT_TOP   = {BV.ORIGEM[1], BV.ORIGEM[2], BV.ORIGEM[1], BV.ORIGEM[2] + BV.EMAX*E_SPC}
    self.LEFT_DOWN  = {BV.ORIGEM[1], BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC,BV.ORIGEM[1],BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC  }
    self.DOWN       = {BV.ORIGEM[1], BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC , BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC }
    self.RIGHT_DOWN = {BV.ORIGEM[1]+ BV._BodyWidth,BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC, BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2]+BV.EMAX*E_SPC+SV_SPC}
    self.RIGHT_TOP  = {BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2] + BV.EMAX*E_SPC,BV.ORIGEM[1]+ BV._BodyWidth, BV.ORIGEM[2]}
    self.WIDTH  = BV._BodyWidth
    self.HEIGHT = BV.EMAX*E_SPC+SV_SPC+BV.VMAX*V_SPC
    setmetatable (self, BlockView.BODY)
    return self
end

function BlockView.BODY:draw(widget, cr)
  
    if self.CLICKED then
		if self.Color2 then
			cr:set_source_rgb (self.Color2[1], self.Color2[2], self.Color2[3])
		else
			cr:set_source_rgb (0.8, 0.6, 0.6)
		end
    else
		if self.Color1 then
			cr:set_source_rgb (self.Color1[1], self.Color1[2], self.Color1[3])
		else
			cr:set_source_rgb (0.8, 0.8, 0.9)
		end
    end
    cr:set_line_width (2*N)
    cr:rectangle(self.LEFT_TOP[1]*N, self.LEFT_TOP[2]*N, (self.RIGHT_TOP[1]-self.LEFT_TOP[1])*N, (self.RIGHT_TOP[2] - self.LEFT_TOP[2])*N)
    cr:rectangle((self.LEFT_TOP[3]+SH_SPC)*N, self.LEFT_TOP[4]*N , (self.RIGHT_TOP[3]-self.LEFT_TOP[3]-2*SH_SPC)*N, SV_SPC*N)
    cr:rectangle(self.LEFT_DOWN[1]*N, self.LEFT_DOWN[2]*N, (self.RIGHT_TOP[1]-self.LEFT_TOP[1])*N, (self.RIGHT_DOWN[2] - self.LEFT_DOWN[2])*N)
    cr:fill()
    cr:move_to ( self.TOP[1]*N, self.TOP[2]*N )
    cr:line_to ( self.TOP[3]*N, self.TOP[4]*N )
    cr:move_to ( self.LEFT_TOP[1]*N, self.LEFT_TOP[2]*N )
    cr:line_to ( self.LEFT_TOP[3]*N, self.LEFT_TOP[4]*N )
    cr:rel_line_to ( SH_SPC*N, 0 )
    cr:rel_line_to ( 0, SV_SPC*N )
    cr:rel_line_to ( -SH_SPC*N, 0 )
    cr:move_to ( self.LEFT_DOWN[1]*N, self.LEFT_DOWN[2]*N )
    cr:line_to ( self.LEFT_DOWN[3]*N, self.LEFT_DOWN[4]*N )
    cr:move_to ( self.DOWN[1]*N, self.DOWN[2]*N )
    cr:line_to ( self.DOWN[3]*N, self.DOWN[4]*N )
    cr:move_to ( self.RIGHT_DOWN[1]*N, self.RIGHT_DOWN[2]*N )
    cr:line_to ( self.RIGHT_DOWN[3]*N, self.RIGHT_DOWN[4]*N )
    cr:rel_line_to ( -SH_SPC*N, 0 )
    cr:rel_line_to ( 0, -SV_SPC*N )
    cr:rel_line_to ( SH_SPC*N, 0 )
    cr:move_to ( self.RIGHT_TOP[1]*N, self.RIGHT_TOP[2]*N )
    cr:line_to ( self.RIGHT_TOP[3]*N, self.RIGHT_TOP[4]*N )
    cr:set_source_rgb (0, 0, 0)
    cr:stroke()
end

BlockView.EVENT.__index = BlockView.EVENT 
function BlockView.EVENT.new(name, tipo, slot, BV)  
    local self 		= {}
    self.UPPER      = BV
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = name
    self.INSTANCIA  = {NAME= BV.NAME..'.'..self.NAME}
    self.CORPO      = {CLICKED = false}
    self.TIPO       = tipo
    self.SLOT       = slot
    self._BodyWidth = BV._BodyWidth
    self.IN_WITHS   = BV.IN_WITHS
    self.OUT_WITHS  = BV.OUT_WITHS
    if self.IN_WITHS == 0 then self.IN_WITHS = 1 end
    if self.OUT_WITHS == 0 then self.OUT_WITHS = 1 end
    if tipo == 'InputEvent'  
        then
            BV.XTREME[name]  = {self.ORIGEM[1]+10*self.OUT_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2}
            self.POS    = {self.ORIGEM[1]+ 2, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
            self.TARGET = {self.ORIGEM[1], self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
        else
            BV.XTREME[name]  = {self.ORIGEM[1]-10*self.IN_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2}
            self.POS    = {self.ORIGEM[1] + BV._BodyWidth, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
            self.TARGET    = {self.ORIGEM[1]  + BV._BodyWidth, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
    end
    self.CONNECT_POS = {self.TARGET[1], self.TARGET[2] - 2}
    setmetatable ( self , BlockView.EVENT )
    return self
end

function BlockView.EVENT:draw(widget, cr)
    if self.CORPO.CLICKED then
		cr:set_source_rgb (0.5, 0.5, 0.5)
    else
		cr:set_source_rgb (0, 0, 0)
	end
    cr:set_line_width (1*N)
    cr:set_font_size(10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    
    if self.TIPO == 'OutputEvent' then
        local t_ext = cairo.TextExtents.create()
        cr:text_extents(self.NAME, t_ext)
        local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
        cr:move_to((self.POS[1] -txt_width/N -2)*N, self.POS[2]*N)
    else
        cr:move_to(self.POS[1]*N, self.POS[2]*N)
    end
    cr:show_text(self.NAME)
    cr:set_source_rgb (0, 0.4, 0)
    cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC)*N)
    if self.TIPO == 'InputEvent' then 
        cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2)*N)
        cr:rel_line_to(-10*self.IN_WITHS*N, 0)
    else
        cr:move_to((self.ORIGEM[1]+ self._BodyWidth)*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2)*N)
        cr:rel_line_to(10*self.OUT_WITHS*N, 0)
    end
    cr:stroke()
    cr:set_source_rgb (0, 0, 0)
end

function BlockView.EVENT:get_clicked(widget, x, y)
	if not F._IsEditMode or not self.UPPER.UPPER then return false end
	if self.TIPO == 'InputEvent' then
		local Xev, Yev = self.POS[1], self.POS[2]
		if x > Xev -13*N and x < Xev and
		   y > Yev -7*N and y < Yev +7*N then
		   self.CORPO.CLICKED = true
		   if not connection_click then
		       connection_click   = self
		   else
			   if connection_click.TIPO == 'OutputEvent' then
			       local dest = self.UPPER.NAME
				   local source   = connection_click.UPPER.NAME
				   local svar   = connection_click.NAME
				   local dvar   = self.NAME
				   if type(F.Struct._FunctionBlock.EventConnections[source]) ~= 'table' then
					   F.Struct._FunctionBlock.EventConnections[source] = {}
	  			   end
	  		       F.Struct._FunctionBlock.EventConnections[source][svar] = {dest, dvar}
	  			   if self.UPPER.UPPER._Type == 'ResourceView' then
	  			       refresh_resource()
	  			   elseif self.UPPER.UPPER._Type == 'CompView' then
	  				   refresh_comp()
				   end
				   connection_click   = nil
				   self.CORPO.CLICKED = false	
			   end
		   end
		   widget:queue_draw()
		   return true
		else
		   self.CORPO.CLICKED = false              
		   widget:queue_draw()                     
		   return false                            
		end
	else
		local Xev, Yev = self.POS[1], self.POS[2]
		if x < Xev +13*N and x > Xev and y > Yev -7*N and y < Yev +7*N then
		    self.CORPO.CLICKED = true
		    if not connection_click then
		        connection_click   = self
		    else
			    if connection_click.TIPO == 'InputEvent' then
				local source     = self.UPPER.NAME
				local dest       = connection_click.UPPER.NAME
				local dvar       = connection_click.NAME
				local svar       = self.NAME
				if type(F.Struct._FunctionBlock.EventConnections[source]) ~= 'table' then
					F.Struct._FunctionBlock.EventConnections[source] = {}
				end
			    F.Struct._FunctionBlock.EventConnections[source][svar] = {dest, dvar}
				if self.UPPER.UPPER._Type == 'ResourceView' then
				    refresh_resource()
				elseif self.UPPER.UPPER._Type == 'CompView' then
				    refresh_comp()
				end
				connection_click   = nil
				self.CORPO.CLICKED = false	
			    end
		    end
		    widget:queue_draw()
		    return true
		else
		    self.CORPO.CLICKED = false
		    widget:queue_draw()
		    return false
		end
	end
	return false
end
function BlockView.EVENT:MOVE(widget, x, y)
	return false
end


BlockView.VAR.__index = BlockView.VAR
function BlockView.VAR.new(name, tipo, slot,BV)  
    local self 		= {}
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = name
    self.TIPO       = tipo
    self.SLOT       = slot
    self.UPPER      = BV
    self.INSTANCIA  = {NAME= BV.NAME..'.'..self.NAME}
    self.CORPO      = {CLICKED = false}
    self._BodyWidth = BV._BodyWidth
    self.EMAX       = BV.EMAX
    self.IN_WITHS   = BV.IN_WITHS
    self.OUT_WITHS  = BV.OUT_WITHS
    if self.IN_WITHS == 0 then self.IN_WITHS = 1 end
    if self.OUT_WITHS == 0 then self.OUT_WITHS = 1 end
    if tipo == 'InputVar' 
        then
            BV.XTREME[name] = {self.ORIGEM[1]-10*self.IN_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC}
            self.POS        = {self.ORIGEM[1] + 2, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
            self.TARGET     = {self.ORIGEM[1] , self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
            self.CONNECT_POS = {self.TARGET[1]-10*self.IN_WITHS, self.TARGET[2] -2}
        else
            BV.XTREME[name] = {self.ORIGEM[1]+10*self.OUT_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC}
            self.POS    = {self.ORIGEM[1] + self._BodyWidth, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
            self.TARGET = {self.ORIGEM[1] + self._BodyWidth, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
            self.CONNECT_POS = {self.TARGET[1]+10*self.IN_WITHS, self.TARGET[2] -2}
    end
    setmetatable ( self , BlockView.VAR )
    return self
end

function BlockView.VAR:draw(widget, cr)
    if self.CORPO.CLICKED then
		cr:set_source_rgb (0.5, 0.5, 0.5)
    else
		cr:set_source_rgb (0, 0, 0)
	end
    cr:set_line_width (1*N)
    cr:set_font_size(10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    
    local t_ext, x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance
    
    if self.TIPO == 'OutputVar' then
        t_ext = cairo.TextExtents.create()
        cr:text_extents(self.NAME, t_ext)
        x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
        cr:move_to((self.POS[1] -txt_width/N -2)*N, self.POS[2]*N)
    else
        cr:move_to(self.POS[1]*N, self.POS[2]*N)
    end
    
    cr:show_text(self.NAME)
    cr:stroke()
    if self.TIPO == 'OutputVar' then
		cr:set_font_size(9*N)
		t_ext = cairo.TextExtents.create()
        cr:text_extents(value_to_string(self.UPPER._FunctionBlock[self.NAME]), t_ext)
        x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
        cr:move_to((self.POS[1] -txt_width/N-2)*N, self.POS[2]*N + N*V_SPC/2.2)
    else
		cr:set_font_size(9*N)
		cr:move_to(self.POS[1]*N, self.POS[2]*N + N*V_SPC/2.2)
	end
	
	cr:set_source_rgb (0.4, 0, 0.2)
	
	
	cr:show_text(value_to_string(self.UPPER._FunctionBlock[self.NAME]))
	
    
    cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC)*N)
    if self.TIPO == 'InputVar' 
        then 
            cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC)*N)
            cr:rel_line_to(-10*self.IN_WITHS*N, 0)
        else
            cr:move_to((self.ORIGEM[1]+ self._BodyWidth)*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC)*N)
            cr:rel_line_to(10*self.OUT_WITHS*N, 0)
    end
    cr:stroke()
    cr:set_source_rgb (0, 0, 0)
end

function BlockView.VAR:get_clicked(widget, x, y)
	if not F._IsEditMode or not self.UPPER.UPPER then return false end
	if self.TIPO == 'InputVar' then
		local Xev, Yev = self.POS[1], self.POS[2]
		if x > Xev -10*N and x < Xev and  y > Yev -5*N and y < Yev +5*N then
		    if self.CORPO.CLICKED then
				self:double_click()
				return true
			end
		    self.CORPO.CLICKED = true
		 
		    if not connection_click then
		        connection_click   = self
		    else
			    if connection_click.TIPO == 'OutputVar' then
			        local dest = self.UPPER.NAME
				    local source   = connection_click.UPPER.NAME
				    local svar   = connection_click.NAME
				    local dvar   = self.NAME
				    if type(F.Struct._FunctionBlock.DataConnections[dest]) ~= 'table' then
					    F.Struct._FunctionBlock.DataConnections[dest] = {}
				    end
			        F.Struct._FunctionBlock.DataConnections[dest][dvar] = {source, svar}
				    if self.UPPER.UPPER._Type == 'ResourceView' then
				        refresh_resource()
				    elseif self.UPPER.UPPER._Type == 'CompView' then
					    refresh_comp()
				    end
				    connection_click   = nil
				    self.CORPO.CLICKED = false	
			    end
		    end
		    widget:queue_draw()
		    return true
		else
		    self.CORPO.CLICKED = false
		    widget:queue_draw()
		    return false
		end
	else
		local Xev, Yev = self.POS[1], self.POS[2]
		if x < Xev +10*N and x > Xev and y > Yev -5*N and y < Yev +5*N then
		    self.CORPO.CLICKED = true
		    if not connection_click then
		        connection_click   = self
		    else
			    if connection_click.TIPO == 'InputVar' then
					local source     = self.UPPER.NAME
					local dest       = connection_click.UPPER.NAME
					local dvar       = connection_click.NAME
					local svar       = self.NAME
					if type(F.Struct._FunctionBlock.DataConnections[dest]) ~= 'table' then
						F.Struct._FunctionBlock.DataConnections[dest] = {}
					end
					F.Struct._FunctionBlock.DataConnections[dest][dvar] = {source, svar}
					if self.UPPER.UPPER._Type == 'ResourceView' then
						refresh_resource()
					end
					connection_click   = nil
				    self.CORPO.CLICKED = false	
			    end
		    end
		    widget:queue_draw()
		    return true
		else
		    self.CORPO.CLICKED = false
		    widget:queue_draw()
		    return false
		end
	end
	return false
end

function BlockView.VAR:double_click(widget, x, y)
	local resource_upper = false
	local p = self.UPPER
	while p do
		if p._Type == 'ResourceView' then
			resource_upper = true
			break
		end
		p = p.UPPER
	end
	if not resource_upper then
		return
	end
	local window = gtk.Window.new()
	window:set('title', self.NAME, 'window-position', gtk.WIN_POS_CENTER)
	window:set('default-width', 0, 'default-height', 0)
	local box    = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	local entry  = gtk.Entry.new()
	local label1 = gtk.Label.new('Parameter Value')
	local button = gtk.Button.new_with_label('Apply')
	
	local function f_apply()
		if entry:get('text') ~= "" then
			local name  = self.UPPER.INSTANCIA.NAME
			local var   = self.NAME
			local val   = entry:get('text')
			if type(p._FunctionBlock._Parameters[name]) ~= 'table' then
				p._FunctionBlock._Parameters[name] = {}
			end
			
			local to_remove
			for i, v in ipairs(p._FunctionBlock.Parameters) do
				if v[1] == name and v[2] == var then
					to_remove = i
					break
				end
			end
			if to_remove then
				p._FunctionBlock.Parameters = list_remove_pos(p._FunctionBlock.Parameters, to_remove)
			end
			to_remove = nil
			for i, v in ipairs(p._FunctionBlock._Parameters[name]) do
				if v.Name == var then
					to_remove = i
					break
				end
			end
			if to_remove then
				p._FunctionBlock._Parameters[name] = list_remove_pos(p._FunctionBlock._Parameters[name], to_remove)
			end
			p._FunctionBlock._Parameters[name][#p._FunctionBlock._Parameters[name]+1] = {
				Name  = var,
				Value = val
			}
			p._FunctionBlock.Parameters[#p._FunctionBlock.Parameters+1] = {name, var, val}
			refresh_resource()
			window:destroy()
		end
	end
	box:add(label1, entry, button)
	window:add(box)
	button:connect('clicked', f_apply)
	window:show_all()
end

function BlockView.VAR:MOVE(widget, x, y)
	return false
end

BlockView.FBTYPE.__index = BlockView.FBTYPE
BlockView.FBTYPE.new = function ( BV)
    local self      = {}
    
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = BV.FBType
    self._BodyWidth = BV._BodyWidth
    self.POS        = {self.ORIGEM[1] , self.ORIGEM[2]+BV.EMAX*E_SPC + 10}
    self.CLASS      = BV._FunctionBlock.Class
    setmetatable(self, BlockView.FBTYPE)
    return self
end

function BlockView.FBTYPE:draw (widget, cr)
    cr:set_source_rgb(0, 0, 0)
    cr:set_font_size(10*N)
    --escreve o tipo do bloco
    local t_ext = cairo.TextExtents.create()
    cr:text_extents(self.NAME, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.NAME)
	--escreve a classe do bloco
	cr:text_extents(self.CLASS, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N + 10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.CLASS)
end

BlockView.LABEL.__index = BlockView.LABEL
BlockView.LABEL.new = function ( BV )
    local self      = {}
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = BV.label
    self._BodyWidth = BV._BodyWidth
    self.POS        = {self.ORIGEM[1], self.ORIGEM[2]-5*N}
    setmetatable(self, BlockView.LABEL)
    return self
end

function BlockView.LABEL:draw (widget, cr)
    cr:set_source_rgb(0, 0, 0)
    cr:set_font_size(10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    --escreve o nome de instância do bloco
	local t_ext = cairo.TextExtents.create()
    cr:text_extents(self.NAME, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.NAME)
end

BlockView.WITH.__index = BlockView.WITH
BlockView.WITH.new = function (  BV, event, slot )
    local self = {}
    self.SLOT    = slot
    self.FLAG    = BV.flag[event]
    self.TARGET  = {}
    if BV.flag[event] == 'InputEvent' 
        then 
        self.POS   = BV.IN_EVENT_TARGET[event]
        for i, v in ipairs(BV.with[event]) do
            self.TARGET[i] = BV.IN_VAR_TARGET[v]
        end
    else
        self.POS     = BV.OUT_EVENT_TARGET[event]
        for i, v in ipairs(BV.with[event]) do
            self.TARGET[i] = BV.OUT_VAR_TARGET[v]
        end
    end
    setmetatable(self, BlockView.WITH)
    return self
end

function BlockView.WITH:draw(widget, cr)
    cr:set_source_rgb (0, 0, 0)
    cr:set_line_width(1*N)
    local far = 0
    for i, v in ipairs (self.TARGET) do
        if v[2] > far then far = v[2] end
        if self.FLAG == 'InputEvent' 
            then
            cr:rectangle((self.POS[1] - 7.5*self.SLOT - 2)*N, (v[2]-4)*N , 4*N, 4*N)
            else
            cr:rectangle((self.POS[1] + 7.5*self.SLOT - 2)*N, (v[2]-4)*N , 4*N, 4*N)
        end
    end
    if self.FLAG == 'InputEvent' 
        then
        cr:rectangle((self.POS[1] - 7.5*self.SLOT - 2)*N, (self.POS[2]-4)*N , 4*N, 4*N)
        cr:move_to ((self.POS[1]  - 7.5*self.SLOT)*N, self.POS[2]*N)
        cr:line_to ((self.POS[1]  - 7.5*self.SLOT)*N, far*N)
        else                       
        cr:rectangle((self.POS[1] + 7.5*self.SLOT - 2)*N, (self.POS[2]-4)*N , 4*N, 4*N)
        cr:move_to ((self.POS[1]  + 7.5*self.SLOT)*N, self.POS[2]*N)
        cr:line_to ((self.POS[1]  + 7.5*self.SLOT)*N, far*N)
    end 
    
    cr:stroke()
    cr:set_line_width (2*N)
end

function BlockView:get_clicked(widget, x, y)
    self.X, self.Y = x, y
    if x >= self.ORIGEM[1]*N and x <= (self.ORIGEM[1] + self.CORPO.WIDTH)*N and y >= self.ORIGEM[2]*N and y <= (self.ORIGEM[2] + self.CORPO.HEIGHT)*N then
        local ret = true
		if self.CORPO.CLICKED then
            ret = self:double_click(widget)
        end
		self.CORPO.CLICKED = true
        clicked_struct = self
        widget:queue_draw()
		return ret
    else
        self.CORPO.CLICKED = false
        widget:queue_draw()
        return false
    end
end

function BlockView:double_click(widget)
    --print(self.INSTANCIA.NAME, self.ORIGEM[1], self.ORIGEM[2])
    self.CORPO.CLICKED = true
    if type(self._Functionality) =='function' then
        if not F._IsEditMode then
			self._Functionality()
			return 'f'
		end
    end
	ApStructs = nil ApStructs = {}
    self.DrawType = 'open'
    F.Struct 	  = self
	F.CurrentStructEntry:set('text', self._FunctionBlock.FBType)
    widget:queue_draw()
    return true
end

function BlockView:MOVE(widget, LOAD, b, c, x, y)
	if LOAD then
        x, y = self.X, self.Y
    end
    if self.CORPO.CLICKED  or LOAD then
        self.ORIGEM[1], self.ORIGEM[2] = self.ORIGEM[1] + x/N - self.X/N, self.ORIGEM[2] +  y/N - self.Y/N
        if self.ORIGEM[1] < 0 then self.ORIGEM[1] = 0 end
        if self.ORIGEM[2] < 0 then self.ORIGEM[2] = 0 end
        self.X, self.Y = x, y
        self.CORPO = BlockView.BODY.new(self)
        for i, v in ipairs (self.ineventlist) do
            self.ineventlist[i] = BlockView.EVENT.new(v.NAME, 'InputEvent', i, self)
            self.IN_EVENT_TARGET[v.NAME]  = self.ineventlist[i].TARGET
            local change
            for j, k in ipairs(ApStructs) do
				if k.INSTANCIA.NAME == self.ineventlist[i].INSTANCIA.NAME then
					change = j
					break
				end
            end
            ApStructs[change] = self.ineventlist[i]
        end
        for i, v in ipairs (self.outeventlist) do
            self.outeventlist[i] = BlockView.EVENT.new(v.NAME, 'OutputEvent', i, self)
            self.OUT_EVENT_TARGET[v.NAME] = self.outeventlist[i].TARGET
        end
        for i, v in ipairs (self.invarlist) do
            self.invarlist[i] = BlockView.VAR.new(v.NAME, 'InputVar', i, self)
            self.IN_VAR_TARGET[v.NAME]  = self.invarlist[i] .TARGET
        end
        for i, v in ipairs (self.outvarlist) do
            self.outvarlist[i] = BlockView.VAR.new(v.NAME, 'OutputVar', i, self)
            self.OUT_VAR_TARGET[v.NAME] = self.outvarlist[i] .TARGET
        end
        
        self.WITH_LIST = nil
        self.WITH_LIST = {}
        local in_slot, out_slot = 0, 0
        for i, v in ipairs (self.ineventlist) do
            if self.with[v.NAME] then
                in_slot = in_slot + 1
                self.WITH_LIST[#self.WITH_LIST+1] = BlockView.WITH.new(self, v.NAME, in_slot )
            end
        end
        for i, v in ipairs (self.outeventlist) do
            if self.with[v.NAME] then
                out_slot = out_slot + 1
                self.WITH_LIST[#self.WITH_LIST+1] = BlockView.WITH.new(self, v.NAME, out_slot )
            end
        end
    
        self.TIPO  		   = BlockView.FBTYPE.new( self)
        self.INSTANCIA 	   = BlockView.LABEL.new( self)
        self.CORPO.CLICKED = not LOAD
        if self.UPPER then
            self.UPPER:MOVE(widget, LOAD, self, true) 
			self.UPPER._FunctionBlock[self.NAME].dx = self.ORIGEM[1]
            self.UPPER._FunctionBlock[self.NAME].dy = self.ORIGEM[2]
        end
        widget:queue_draw()
        return true
    end
    widget:queue_draw()
    return false
end

function BlockView:delete()
	if self.UPPER --[[and self.UPPER._Type == 'ResourceView']] then
		local name = self.INSTANCIA.NAME
		for i, v in ipairs(F.Struct._FunctionBlock.FBNetwork) do
			if name == v[1] then
				F.Struct._FunctionBlock.FBNetwork = list_remove_pos(F.Struct._FunctionBlock.FBNetwork, i)
				F.Struct._FunctionBlock[name] = nil
				break
			end
		end
		local remove_list = {}
		F.Struct._FunctionBlock.EventConnections[name] = nil
		for i, v in pairs(F.Struct._FunctionBlock.EventConnections) do
			for j, k in pairs(v) do
				if k[1] == name then
					remove_list[#remove_list+1] = {i, j}
				end
			end
		end
		for i, v in ipairs(remove_list) do
			F.Struct._FunctionBlock.EventConnections[v[1]][v[2]] = nil
		end
		remove_list = {}
		F.Struct._FunctionBlock.DataConnections[name] = nil
		for i, v in pairs(F.Struct._FunctionBlock.DataConnections) do
			for j, k in pairs(v) do
				if k[1] == name then
					remove_list[#remove_list+1] = {i, j}
				end
			end
		end
		for i, v in ipairs(remove_list) do
			F.Struct._FunctionBlock.DataConnections[v[1]][v[2]] = nil
		end
		local continue = true
		while(continue) do
			continue = false
			for i, v in ipairs (F.Struct._FunctionBlock.Parameters) do
				if v[1] == name then
					F.Struct._FunctionBlock.Parameters = list_remove_pos(F.Struct._FunctionBlock.Parameters,i)
					continue = true
					break
				end
			end
		end
		if self.UPPER._Type == 'ResourceView' then
			refresh_resource()
		elseif self.UPPER._Type == 'CompView' then
			refresh_comp()
		end
	end
end


BlockView.__index = BlockView
BlockView.new = function(FB, origem)
    --função que instancia e retira informações do function block
    local self = clone(FB, false)
    self.NAME             = FB.label
    self._FunctionBlock   = FB
    self._FunctionBlock.other.net_file = FB.other.net_file
    self._Type            = 'BlockView'
    self.XTREME           = {}
    self.with             = clone(FB.with, true)
    self.flag             = clone(FB.flag, true)
    if origem then origem = {tonumber(origem[1]), tonumber(origem[2])} end
    self.ORIGEM           = origem or {200, 150}
    self.SLOT             = {}
    self.SLOT.IEV, self.SLOT.IVAR, self.SLOT.OEV, self.SLOT.OVAR = 0, 0, 0, 0
    self.MAIOR_VAR        = 0
    self.MAIOR_EV         = 0
    self.CONNECTION_LIST  = {}
    self.ineventlist      = {}
    self.outeventlist     = {}
    self.invarlist        = {}
    self.outvarlist       = {}
    self.IN_EVENT_TARGET  = {}
    self.OUT_EVENT_TARGET = {}
    self.IN_VAR_TARGET    = {}
    self.OUT_VAR_TARGET   = {}
    self.WITH_LIST   = {}
    self.IN_WITHS, self.OUT_WITHS = 0, 0
    
    -- testa se há funcionalidade gráfica do bloco  (STARTER)
    if FB._Functionality then
        self._Functionality = BlockView.FUNCTIONALITY.new(FB,FB._Functionality)
    end
    
    local max_string_in, max_string_out = 0, 0
    
    for i , v in ipairs(FB.ineventlist) do
		if #v > max_string_in then
            max_string_in = #v
        end
	end
	for i , v in ipairs(FB.outeventlist) do
		if #v > max_string_in then
            max_string_in = #v
        end
	end
	for i , v in ipairs(FB.invarlist) do
		if #v > max_string_in then
            max_string_in = #v
        end
	end
	for i , v in ipairs(FB.outvarlist) do
		if #v > max_string_in then
            max_string_in = #v
        end
	end
	
	-- Conta quantos Withs, e detecta maiores strings (ev ou var) de entrada e saida
    for i, v in pairs (FB.with) do
        if FB.flag[i] == 'InputEvent' then
            self.IN_WITHS  = self.IN_WITHS +1
        else
		    self.OUT_WITHS = self.OUT_WITHS +1
        end
    end
    
    -- Conta eventos e variáveis de entrada e saída
    self.EIN, self.EOUT, self.VIN, self.VOUT = #FB.ineventlist, #FB.outeventlist, #FB.invarlist, #FB.outvarlist
    
    if self.VIN > self.VOUT then self.VMAX = self.VIN else self.VMAX = self.VOUT end --retira vmax
        if self.VMAX == 0 then self.VMAX = 1 end
    
    if self.EIN > self.EOUT then self.EMAX = self.EIN else self.EMAX = self.EOUT end --retira emax
        if self.EMAX == 0 then self.EMAX = 1 end

    
    --determina largura do corpo de acordo com o tamanho do tipo ou maiores variáveis ou eventos
    --(tamanho da string)
    local max_string   = max_string_in + 20 + max_string_out
	if max_string > #self.FBType then
        self._BodyWidth = max_string*T_SPC
    else
        self._BodyWidth    = #self.FBType*T_SPC
    end
    if self._BodyWidth > 385 then
		self._BodyWidth = 385
	end
    
    --cria o corpo
    self.CORPO         = BlockView.BODY.new(self)
    self.CORPO.CLICKED = false
   
    --cria os eventos e variáveis
    for i, v in ipairs (FB.ineventlist) do
        self.ineventlist[i]       = BlockView.EVENT.new(v, 'InputEvent', i, self)
        self.ineventlist[v]       = self.ineventlist[i]
        self.IN_EVENT_TARGET[v]   = self.ineventlist[i] .TARGET
        self.ineventlist[v].SLOT2 = i
    end
    for i, v in ipairs (FB.outeventlist) do
        self.outeventlist[i]       = BlockView.EVENT.new(v, 'OutputEvent', i, self)
        self.outeventlist[v]       = self.outeventlist[i]
        self.OUT_EVENT_TARGET[v]   = self.outeventlist[i].TARGET
        self.outeventlist[v].SLOT2 = i
    end
    for i, v in ipairs (FB.invarlist) do
        self.invarlist[i]       = BlockView.VAR.new(v, 'InputVar', i, self)
        self.invarlist[v]       = self.invarlist[i]
        self.IN_VAR_TARGET[v]   = self.invarlist[i] .TARGET
        self.invarlist[v].SLOT2 = i + self.EIN
    end
    for i, v in ipairs (FB.outvarlist) do
        self.outvarlist[i]       = BlockView.VAR.new(v, 'OutputVar', i, self)
        self.outvarlist[v]       = self.outvarlist[i]  
        self.OUT_VAR_TARGET[v]   = self.outvarlist[i] .TARGET
        self.outvarlist[v].SLOT2 = i + self.EOUT
    end
   
   
    --crias os WITH's
    local in_slot, out_slot = 0, 0
    for i, v in ipairs (FB.ineventlist) do
        if FB.with[v] then
            in_slot = in_slot + 1
            self.WITH_LIST[#self.WITH_LIST+1] = BlockView.WITH.new(self, v, in_slot )
        end
    end
    for i, v in ipairs (FB.outeventlist) do
        if FB.with[v] then
            out_slot = out_slot + 1
            self.WITH_LIST[#self.WITH_LIST+1] = BlockView.WITH.new(self, v, out_slot )
        end
    end

    --instancia ECC ou SD (ServiceDiagram)
    
    if FB.Class == 'ServiceInterface' then
        self.SD       = SDView.new(FB)
        self.SD.UPPER = self
    else
        self.ECC       = ECCView.new(FB, self)
    end
    
    self.TIPO  = BlockView.FBTYPE.new( self)
    self.INSTANCIA = BlockView.LABEL.new( self)
    setmetatable (self, BlockView)
    return self
end

function BlockView:draw (widget, cr)
    if self.DrawType == 'open' then
        ApStructs = nil ApStructs = {}
        --~ self.CORPO.CLICKED = false
        if self.ECC then
            self.ECC:draw(widget, cr)
        else
            self.SD:draw(widget, cr)
        end
    else
        local already_is = false
        for i, v in ipairs(ApStructs) do
            if self.INSTANCIA.NAME == v.INSTANCIA.NAME then
                already_is = true
            end
        end
        if not already_is then
            ApStructs[#ApStructs+1] = self
            for i, v in ipairs(self.ineventlist) do
				ApStructs[#ApStructs+1] = v
            end
            for i, v in ipairs(self.outeventlist) do
				ApStructs[#ApStructs+1] = v
            end
            for i, v in ipairs(self.invarlist) do
				ApStructs[#ApStructs+1] = v
            end
            for i, v in ipairs(self.outvarlist) do
				ApStructs[#ApStructs+1] = v
            end
        end
        cr:set_antialias (1)
        cr:set_source_rgb(0.9, 0.9, 0.9)
        if(self._FunctionBlock._SpecialDraw) then
			self._FunctionBlock._SpecialDraw(widget, cr, self)
		else
			self.CORPO:draw (widget, cr) --desenha o corpo
		end
        for i, v in ipairs(self.ineventlist) do --adiciona eventos de entrada
            v:draw(widget, cr)
        end
        for i, v in ipairs(self.outeventlist) do --adiciona eventos de saída
            v:draw(widget, cr)
        end
        for i, v in ipairs(self.invarlist) do --adiciona variáveis de entrada
            v:draw(widget, cr)
        end
        for i, v in ipairs(self.outvarlist) do --adiciona variáveis de saída
            v:draw(widget, cr)
        end
        m = 0
        for i, v in ipairs(self.WITH_LIST) do --adiciona WITH
            v:draw(widget, cr)
        end
        self.TIPO:draw(widget, cr)
        self.INSTANCIA:draw(widget, cr)
    end
end





