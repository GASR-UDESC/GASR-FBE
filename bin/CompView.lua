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
require('BlockView')
require('System')

local c_trian 		= 5
TL            		= 4
C_ESC_H_SPC   		= 12.5  --connection escape horizontal spacement
C_ESC_V_SPC   		= 12.5  --connection escape vertical spacement
C_ENT_H_SPC         = 198
CompView            = {}
local IN_WITHS      = 0
local OUT_WITHS     = 0
CompView.BODY       = {}
CompView.EVENT      = {}
CompView.VAR        = {}
CompView.FBTYPE     = {}
CompView.LABEL      = {}
CompView.WITH       = {}
CompView.CONNECTION = {}

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

CompView.BODY.__index = CompView.BODY 
function CompView.BODY.new(BV)
    local self = {}
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

function CompView.BODY:draw(widget, cr)
    if self.CLICKED 
        then
        cr:set_source_rgb (0.8, 0.6, 0.6)
        else
        cr:set_source_rgb (0.8, 0.8, 0.9)
    end
    cr:set_line_width (2*N)
    cr:rectangle(self.LEFT_TOP[1]*N, self.LEFT_TOP[2]*N, (self.RIGHT_TOP[1]-self.LEFT_TOP[1])*N, (self.RIGHT_TOP[2] - self.LEFT_TOP[2])*N)
    cr:rectangle((self.LEFT_TOP[3]+SH_SPC)*N, self.LEFT_TOP[4]*N, (self.RIGHT_TOP[3]-self.LEFT_TOP[3]-2*SH_SPC)*N, SV_SPC*N)
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

CompView.EVENT.__index = CompView.EVENT 
function CompView.EVENT.new(name, tipo, slot, BV)  
    local self 	    = {}
    self.ORIGEM 	= BV.ORIGEM
    self.NAME   	= name
    self.INSTANCIA  = {NAME= BV.NAME..'.'..self.NAME}
    self.UPPER  	= BV
    self.TIPO   	= tipo
    self.SLOT   	= slot
    self.FBTYPE 	= BV.FBType
    self.IN_WITHS   = BV.IN_WITHS
    self.OUT_WITHS  = BV.OUT_WITHS
    self.CORPO      = {CLICKED = false}
    if self.IN_WITHS == 0 then self.IN_WITHS = 1 end
    if self.OUT_WITHS == 0 then self.OUT_WITHS = 1 end
    if tipo == 'InputEvent'  
        then
        BV.XTREME[name]  = {self.ORIGEM[1]+10*self.OUT_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2}
        self.POS    = {self.ORIGEM[1]+ 2, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
        self.TARGET = {self.ORIGEM[1], self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
        else
        BV.XTREME[name]  = {self.ORIGEM[1]-10*self.IN_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2}
        self.POS    = {self.ORIGEM[1] + #BV.FBType*T_SPC, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
        self.TARGET    = {self.ORIGEM[1]  + #BV.FBType*T_SPC, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC}
    end
    setmetatable ( self , CompView.EVENT )
    return self
end

function CompView.EVENT:draw(widget, cr)
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
    if self.TIPO == 'InputEvent' 
        then 
        cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2)*N)
        self.CONNECT_POS = {self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2)*N}
        cr:rel_line_to(-10*self.IN_WITHS*N, 0)
        else
        cr:move_to((self.ORIGEM[1]+ #self.FBTYPE*T_SPC)*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2)*N)
        self.CONNECT_POS = {(self.ORIGEM[1]+ #self.FBTYPE*T_SPC)*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2)*N}
        cr:rel_line_to(10*self.OUT_WITHS*N, 0)
    end
    cr:stroke()
    cr:set_source_rgb (0, 0, 0)
end

function CompView.EVENT:get_clicked(widget, x, y)
	if not F._IsEditMode or not self.UPPER.UPPER then return false end
	if self.TIPO == 'InputEvent' then
		local Xev, Yev = self.POS[1], self.POS[2]
		if x > Xev -13*N and x < Xev and
		   y > Yev -7*N and y < Yev + 7*N then
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

function CompView.EVENT:MOVE(widget, x, y)
	return false
end

CompView.VAR.__index = CompView.VAR
function CompView.VAR.new(name, tipo, slot,BV)  
    local self 		= {}
    self.ORIGEM 	= BV.ORIGEM
    self.NAME  		= name
    self.TIPO  	    = tipo
    self.SLOT  	    = slot
    self.FBTYPE 	= BV.FBType
    self.EMAX   	= BV.EMAX
    self.IN_WITHS   = BV.IN_WITHS
    self.OUT_WITHS  = BV.OUT_WITHS
    self.UPPER      = BV
    self.INSTANCIA  = {NAME= BV.NAME..'.'..self.NAME}
    self.CORPO      = {CLICKED = false}
    if self.IN_WITHS == 0 then self.IN_WITHS = 1 end
    if self.OUT_WITHS == 0 then self.OUT_WITHS = 1 end
    if tipo == 'InputVar' 
        then
        BV.XTREME[name] = {self.ORIGEM[1]-10*self.IN_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC}
        self.POS        = {self.ORIGEM[1] + 2, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
        self.TARGET     = {self.ORIGEM[1] , self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
        else
        BV.XTREME[name] = {self.ORIGEM[1]+10*self.OUT_WITHS, self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC}
        self.POS    = {self.ORIGEM[1]  + #BV.FBType*T_SPC, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
        self.TARGET = {self.ORIGEM[1] + #BV.FBType*T_SPC, self.ORIGEM[2] + (self.SLOT-0.5)*E_SPC + SV_SPC + BV.EMAX*E_SPC}
    end
    setmetatable ( self , CompView.VAR )
    return self
end

function CompView.VAR:draw(widget, cr)
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
        cr:move_to((self.POS[1] -txt_width/N-2)*N, self.POS[2]*N)
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
    
    
    cr:set_source_rgb (0, 0, 0.4)
    cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC)*N)
    if self.TIPO == 'InputVar' 
        then 
        cr:move_to(self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC)*N)
        self.CONNECT_POS = {self.ORIGEM[1]*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC)*N}
        cr:rel_line_to(-10*self.IN_WITHS*N, 0)
        else
        cr:move_to((self.ORIGEM[1]+ #self.FBTYPE*T_SPC)*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC)*N)
        self.CONNECT_POS = {(self.ORIGEM[1]+ #self.FBTYPE*T_SPC)*N, (self.ORIGEM[2]+ (self.SLOT-0.5)*E_SPC-2 + SV_SPC + self.EMAX*E_SPC)*N}
        cr:rel_line_to(10*self.OUT_WITHS, 0)
    end
    cr:stroke()
    cr:set_source_rgb (0, 0, 0)
end

function CompView.VAR:get_clicked(widget, x, y)
	if not F._IsEditMode or not self.UPPER.UPPER then return false end
	if self.TIPO == 'InputVar' then
		local Xev, Yev = self.POS[1], self.POS[2]
		if x > Xev -10*N and x < Xev and y > Yev -5*N and y < Yev +5*N then
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

function CompView.VAR:double_click(widget, x, y)
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

function CompView.VAR:MOVE(widget, x, y)
	return false
end

CompView.FBTYPE.__index = CompView.FBTYPE
CompView.FBTYPE.new = function ( BV)
    local self      = {}
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = BV.FBType
    self._BodyWidth = BV._BodyWidth
    self.POS        = {self.ORIGEM[1] , self.ORIGEM[2]+BV.EMAX*E_SPC + 10}
    setmetatable(self, CompView.FBTYPE)
    return self
end

function CompView.FBTYPE:draw (widget, cr)
    cr:set_source_rgb(0, 0, 0)
    cr:set_font_size(10*N)
    
    local t_ext = cairo.TextExtents.create()
    --escreve o nome do tipo do bloco
	cr:text_extents(self.NAME, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text (self.NAME)
	--escreve a classe do bloco
	cr:text_extents('Composite', t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to((self.POS[1] + self._BodyWidth/2 - txt_width/(2*N))*N, self.POS[2]*N + 10*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr:show_text ('Composite')
end

CompView.LABEL.__index = CompView.LABEL
CompView.LABEL.new = function ( BV)
    local self      = {}
    self.ORIGEM     = BV.ORIGEM
    self.NAME       = BV.label
    self._BodyWidth = BV._BodyWidth
    self.POS        = {self.ORIGEM[1], self.ORIGEM[2]-5}
    setmetatable(self, BlockView.LABEL)
    return self
end


function CompView.LABEL:draw (widget, cr)
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

CompView.WITH.__index = CompView.WITH
CompView.WITH.new = function (  BV, event, slot )
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
    setmetatable(self, CompView.WITH)
    return self
end

function CompView.WITH:draw(widget, cr)
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


CompView.CONNECTION.__index = CompView.CONNECTION
CompView.CONNECTION.new = function (origem, destino, tipo, slot, ev, block, n, BV, seve_dvar, sb_db)
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
            self.LIST[2] = -E_SPC*self.SLOT - C_ESC_V_SPC*self.SLOT 
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
    setmetatable(self, CompView.CONNECTION)
    return self
end

function CompView.CONNECTION:draw(widget, cr)
    
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

function CompView.CONNECTION:get_clicked(widget, x, y)
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

function CompView.CONNECTION:MOVE(widget, a, b, c, x, y)
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

function CompView.CONNECTION:delete()
	if self.TIPO == 'event' then
		F.Struct._FunctionBlock.EventConnections[self.SB_DB][self.SEVE_DVAR] = nil
	elseif self.TIPO == 'var' then
		F.Struct._FunctionBlock.DataConnections[self.SB_DB][self.SEVE_DVAR] = nil
	end
	refresh_comp()
	
end


function CompView:get_clicked(widget, x, y)
    self.X, self.Y = x, y
    if x >= self.ORIGEM[1]*N and x <= (self.ORIGEM[1] + self.CORPO.WIDTH)*N and y >= self.ORIGEM[2]*N and y <= (self.ORIGEM[2] + self.CORPO.HEIGHT)*N then
        if self.CORPO.CLICKED then
            self:double_click(widget)
        end
        self.CORPO.CLICKED = true
        clicked_struct     = self
        widget:queue_draw()
        return true
    else
        self.CORPO.CLICKED = false
        widget:queue_draw()
        return false
    end
end

function CompView:double_click(widget)
    --print(self.INSTANCIA.NAME, self.ORIGEM[1], self.ORIGEM[2])
    ApStructs = nil ApStructs = {}
    self.CORPO.CLICKED = false
    self.DrawType = 'open'
    F.CurrentStructEntry:set('text', self._FunctionBlock.FBType)
	F.Struct = self
	--self:MOVE(widget, nil, false )
    widget:queue_draw()
    return true
end

function CompView:MOVE(widget, LOAD, block_moved, static, x, y)
	if LOAD or static then
        x, y = self.X, self.Y
    end
    if self.CORPO.CLICKED or LOAD then
        self.ORIGEM[1], self.ORIGEM[2] = self.ORIGEM[1] + x/N - self.X/N, self.ORIGEM[2]+  y/N - self.Y/N
        if self.ORIGEM[1] < 0 then self.ORIGEM[1] = 0 end
        if self.ORIGEM[2] < 0 then self.ORIGEM[2] = 0 end
        local dx, dy = x - self.X, y - self.Y
        self.X, self.Y = x, y
        self.CORPO = CompView.BODY.new(self)
        for i, v in ipairs (self.ineventlist) do
            self.ineventlist[i] = CompView.EVENT.new(v.NAME, 'InputEvent', i, self)
            self.IN_EVENT_TARGET[v.NAME]  = self.ineventlist[i].TARGET
        end
        for i, v in ipairs (self.outeventlist) do
            self.outeventlist[i] = CompView.EVENT.new(v.NAME, 'OutputEvent', i, self)
            self.OUT_EVENT_TARGET[v.NAME] = self.outeventlist[i].TARGET
        end
        for i, v in ipairs (self.invarlist) do
            self.invarlist[i] = CompView.VAR.new(v.NAME, 'InputVar', i, self)
            self.IN_VAR_TARGET[v.NAME]  = self.invarlist[i] .TARGET
        end
        for i, v in ipairs (self.outvarlist) do
            self.outvarlist[i] = CompView.VAR.new(v.NAME, 'OutputVar', i, self)
            self.OUT_VAR_TARGET[v.NAME] = self.outvarlist[i] .TARGET
        end
        
        self.WITH_LIST = nil
        self.WITH_LIST = {}
        local in_slot, out_slot = 0, 0
        for i, v in ipairs (self.ineventlist) do
            if self.with[v.NAME] then
                in_slot = in_slot + 1
                self.WITH_LIST[#self.WITH_LIST+1] = CompView.WITH.new(self, v.NAME, in_slot )
            end
        end
        for i, v in ipairs (self.outeventlist) do
            if self.with[v.NAME] then
                out_slot = out_slot + 1
                self.WITH_LIST[#self.WITH_LIST+1] = CompView.WITH.new(self, v.NAME, out_slot )
            end
        end

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
                            v           = CompView.CONNECTION.new (origem, destino, v.TIPO, v.SLOT, v.EV, nil, v.n, self, v.SEVE_DVAR, v.SB_DB)
                        else
                            v           = CompView.CONNECTION.new (origem, destino, v.TIPO, v.SLOT, v.EV, v.B_OR, v.n, self, v.SEVE_DVAR, v.SB_DB)
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
                            v = CompView.CONNECTION.new (origem, destino, v.TIPO, v.SLOT, v.EV, nil, v.n, self, v.SEVE_DVAR, v.SB_DB)
                        else
                            v = CompView.CONNECTION.new (origem, destino, v.TIPO, v.SLOT, v.EV, v.B_OR, v.n, self, v.SEVE_DVAR, v.SB_DB)
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
        
        self.TIPO  = CompView.FBTYPE.new( self)
        self.INSTANCIA = CompView.LABEL.new( self)
        self.CORPO.CLICKED = not LOAD
        if self.UPPER then
            self.UPPER:MOVE(widget, LOAD, self , true, x, y) 
            self.UPPER._FunctionBlock[self.NAME].dx = self.ORIGEM[1]
            self.UPPER._FunctionBlock[self.NAME].dy = self.ORIGEM[2]
        end
        widget:queue_draw()
        return true
    end
    widget:queue_draw()
    return false
end

function CompView:delete()
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

CompView.__index = CompView
function CompView.new( FB, origem )
    local self                    = clone(FB, false)
    self._FunctionBlock           = FB
    self._Type                    = 'CompView'
    self.NAME                     = FB.label
    self.XTREME                   = {}
    self.with                     = clone(FB.with, true)
    self.flag                     = clone(FB.flag, true)
    self.Event_Connections        = clone (FB.EventConnections, true)
    self.Data_Connections         = clone (FB.DataConnections, true)
    self.DrawType                 = 'closed'
    if origem then origem         = {tonumber(origem[1]), tonumber(origem[2])} end
    self.ORIGEM                   = origem or {200, 150}
    self.SLOT                     = {}
    self.SLOT.IEV, self.SLOT.IVAR = 0, 0
    self.SLOT.OEV, self.SLOT.OVAR = 0, 0
    self.ineventlist              = {}
    self.outeventlist             = {}
    self.invarlist                = {}
    self.outvarlist               = {}
    self.IN_EVENT_TARGET          = {}
    self.OUT_EVENT_TARGET         = {}
    self.IN_VAR_TARGET            = {}
    self.OUT_VAR_TARGET           = {}
    self.WITH_LIST                = {}
    self.IN_WITHS, self.OUT_WITHS = 0, 0
    
    --conta os eventos e variáveis de entrada e saída
    self.EIN, self.EOUT, self.VIN, self.VOUT = #FB.ineventlist, #FB.outeventlist, #FB.invarlist, #FB.outvarlist
    if self.VIN > self.VOUT then self.VMAX = self.VIN else self.VMAX = self.VOUT end --retira vmax
        if self.VMAX == 0 then self.VMAX = 1 end
    if self.EIN > self.EOUT then self.EMAX = self.EIN else self.EMAX = self.EOUT end --retira emax
        if self.EMAX == 0 then self.EMAX = 1 end
    
    --------------------------------------------------
    --cria o corpo
    self._BodyWidth = #self.FBType*T_SPC
    self.CORPO = CompView.BODY.new(self)
    self.CORPO.CLICKED = false
    
    ---------------------------------------------------
    --Conta quantos withs de entrada e saída existem
    for i, v in pairs (FB.with) do
        if FB.flag[i] == 'InputEvent' 
            then
            self.IN_WITHS  = self.IN_WITHS +1
            else
            self.OUT_WITHS = self.OUT_WITHS +1
        end
    end
    --------------------------------------------------
    --cria os eventos e variáveis
    for i, v in ipairs (FB.ineventlist) do
        self.ineventlist[i]       = CompView.EVENT.new(v, 'InputEvent', i, self)
        self.ineventlist[v]       = self.ineventlist[i]
        self.IN_EVENT_TARGET[v]   = self.ineventlist[i] .TARGET
        self.ineventlist[v].SLOT2 = i
    end
    for i, v in ipairs (FB.outeventlist) do
        self.outeventlist[i]       = CompView.EVENT.new(v, 'OutputEvent', i, self)
        self.outeventlist[v]       = self.outeventlist[i]
        self.OUT_EVENT_TARGET[v]   = self.outeventlist[i] .TARGET
        self.outeventlist[v].SLOT2 = i
    end
    for i, v in ipairs (FB.invarlist) do
        self.invarlist[i]       = CompView.VAR.new(v, 'InputVar', i, self)
        self.invarlist[v]       = self.invarlist[i]
        self.IN_VAR_TARGET[v]   = self.invarlist[i] .TARGET
        self.invarlist[v].SLOT2 = i + self.EIN
    end
    for i, v in ipairs (FB.outvarlist) do
        self.outvarlist[i]       = CompView.VAR.new(v, 'OutputVar', i, self)
        self.outvarlist[v]       = self.outvarlist[i]  
        self.OUT_VAR_TARGET[v]   = self.outvarlist[i] .TARGET
        self.outvarlist[v].SLOT2 = i + self.EOUT
    end
    
    
    ----------------------------------------------------
    --Cria os Withs
    local in_slot, out_slot =  0, 0
    for i, v in ipairs (FB.ineventlist) do
        if FB.with[v] then
            in_slot = in_slot + 1
            self.WITH_LIST[#self.WITH_LIST+1] = CompView.WITH.new(self, v, in_slot )
        end
    end
    for i, v in ipairs (FB.outeventlist) do
        if FB.with[v] then
            out_slot = out_slot + 1
            self.WITH_LIST[#self.WITH_LIST+1] = CompView.WITH.new(self, v, out_slot )
        end
    end
    -----------------------------------------------------
    
    --cria o texto com nome de instância e tipo de bloco
    self.TIPO  = CompView.FBTYPE.new(self)
    self.INSTANCIA = CompView.LABEL.new(self)
    -----------------------------------------------------
    
    --Cria os blocos internos
    self.BLOCKS = {}
    for i, v in ipairs (FB.FBNetwork) do
		if FB[v[1]].Class == 'Basic' then
            self.BLOCKS[#self.BLOCKS+1] = BlockView.new(FB[v[1]], {FB[v[1]].dx, FB[v[1]].dy})
            self[v[1]]                  = self.BLOCKS[#self.BLOCKS]
            self[v[1]].UPPER            = self
        elseif FB[v[1]].Class == 'Comp'  or FB[v[1]].Class == 'Composite' then
            self.BLOCKS[#self.BLOCKS+1] = CompView.new(FB[v[1]], {FB[v[1]].dx, FB[v[1]].dy})
            self[v[1]]                  = self.BLOCKS[#self.BLOCKS]
            self[v[1]].UPPER            = self
        else
            self.BLOCKS[#self.BLOCKS+1] = BlockView.new(FB[v[1]], {FB[v[1]].dx, FB[v[1]].dy})
            self[v[1]]                  = self.BLOCKS[#self.BLOCKS]
            self[v[1]].UPPER            = self --para serviço de interface
        end
    end
    ------------------------------------------------------
    
    --Cria Conexões de evento e variável
    self.CONNECTION_LIST = {}
    for i, v in pairs (FB.EventConnections) do
		for j, k in pairs (v) do
            local slot = '-1'
            if self[i] and self[i].outeventlist[j].SLOT2 then
                slot    = self[i].outeventlist[j].SLOT2
            end
            local ev      = j
            local destino, origem
            if k[1] == 'self' then
                destino = 'self'
            else
				destino = {self[k[1]].IN_EVENT_TARGET[k[2]][1] - 10*self[k[1]].IN_WITHS, self[k[1]].IN_EVENT_TARGET[k[2]][2]-2}
            end
            if i == 'self' then
                origem = 'self'
            else
                origem  = {self[i].OUT_EVENT_TARGET[j][1] + 10*self[i].OUT_WITHS, self[i].OUT_EVENT_TARGET[j][2]-2}
            end
            local tam = #self.CONNECTION_LIST 
            self.CONNECTION_LIST[tam + 1]        = CompView.CONNECTION.new(origem, destino, 'event', slot, ev, self[i], tam+1, self, j, i)
            self.CONNECTION_LIST[tam + 1].B_OR   = self[i]    or 'self'
            self.CONNECTION_LIST[tam + 1].B_DEST = self[k[1]] or 'self'
            if self.CONNECTION_LIST[tam + 1].B_OR == 'self' then
                self.CONNECTION_LIST[tam + 1].B_OR = {INSTANCIA = {NAME = 'self'}}
            end
            if self.CONNECTION_LIST[tam + 1].B_DEST == 'self' then
                self.CONNECTION_LIST[tam + 1].B_DEST = {INSTANCIA = {NAME = 'self'}}
            end
            self.CONNECTION_LIST[tam + 1].EV_DEST = k[2]
            self.CONNECTION_LIST[tam + 1].EV_OR   = j
        end
    end
    for i, v in pairs (FB.DataConnections) do
        for j, k in pairs (v) do
            --k[1] == origem e i == destino
            local slot = '-1'
            if self[k[1]] and self[k[1]].outvarlist[k[2]].SLOT2 then
                slot   = self[k[1]].outvarlist[k[2]].SLOT2
            end
            local origem, destino
            local ev   = k[2]
            if k[1] == 'self' then
                origem = 'self'
            else
                origem   = {self[k[1]].OUT_VAR_TARGET[k[2]][1] + 10*self[k[1]].OUT_WITHS, self[k[1]].OUT_VAR_TARGET[k[2]][2]-2}
            end
            if i == 'self' then
                destino = 'self'
            else
                --print(i, j)
                destino  = {self[i].IN_VAR_TARGET[j][1] - 10*self[i].IN_WITHS, self[i].IN_VAR_TARGET[j][2]-2}
            end
            local tam = #self.CONNECTION_LIST 
            self.CONNECTION_LIST[tam +1]           = CompView.CONNECTION.new(origem, destino, 'var', slot, ev, self[k[1]], tam+1, self, j, i)
            self.CONNECTION_LIST[tam + 1].B_OR     = self[k[1]] or 'self'
            self.CONNECTION_LIST[tam + 1].B_DEST   = self[i]    or 'self'
            
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
    
    setmetatable(self, CompView)
    return self
end

function CompView:draw(widget, cr)
    --desenha o bloco aberto (rede de FB's internos)
    if self.DrawType == 'open' then
        F.Struct = self                         --estrutura global = self   
        ApStructs = nil ApStructs = {}          --zera estruturas aparentes
        cr:set_antialias (0)                    --liga o antialiasing p/ desenhar conexões
        for i, v in ipairs(self.CONNECTION_LIST)    do 
            v:draw(widget, cr)                  --desenha conexões, adicionando às estruturas aparentes 
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
        cr:set_antialias (1)                     --desliga o antialising
        self.CORPO:draw (widget, cr)             --desenha o corpo
        for i, v in ipairs(self.ineventlist)  do --desenha eventos de entrada
            v:draw(widget, cr)
        end
        for i, v in ipairs(self.outeventlist) do --desenha eventos de saída
            v:draw(widget, cr)
        end
        for i, v in ipairs(self.invarlist)    do --desenha variáveis de entrada
            v:draw(widget, cr)
        end
        for i, v in ipairs(self.outvarlist)   do --desenha variáveis de saída
            v:draw(widget, cr)
        end
        m = 0
        for i, v in ipairs(self.WITH_LIST)    do --desenha WITH
            v:draw(widget, cr)
        end
        self.TIPO:draw(widget, cr)               --'escreve' o nome do tipo do bloco
        self.INSTANCIA:draw(widget, cr)          --'escreve' o nome de instancia do bloco
    end
end
