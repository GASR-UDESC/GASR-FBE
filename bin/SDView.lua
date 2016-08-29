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
--SD = ServiceDiagram
SDView                 = {}
SDView.ServiceSequence = {}

SDView.ServiceSequence.__index = SDView.ServiceSequence
function SDView.ServiceSequence.new(FB, Sequence, Slot)
    --~ print('Hello .NEW')
    local self          = {}
    self.SLOT           = Slot -1
    self.LeftInterface  = FB.Service.LeftInterface
    self.RightInterface = FB.Service.RightInterface
    self.Primitives     = {}
    self.NAME           = Sequence.Name
    for j, k in ipairs(Sequence.Transactions) do
		self.Primitives[#self.Primitives+1] = {}
		self.Primitives[#self.Primitives+1] = {}
        if k.InputPrimitive then
			self.Primitives[#self.Primitives-1].Interface   = k.InputPrimitive.Interface or ''
			self.Primitives[#self.Primitives-1].Event       = k.InputPrimitive.Event or ''
			self.Primitives[#self.Primitives].Interface     = k.OutputPrimitive.Interface or ''
			self.Primitives[#self.Primitives].Event         = k.OutputPrimitive.Event or ''
		else
			self.Primitives[#self.Primitives-1].Interface   = ''
			self.Primitives[#self.Primitives-1].Event       = ''
			self.Primitives[#self.Primitives].Interface     = ''
			self.Primitives[#self.Primitives].Event         = ''
		end
    end
    setmetatable(self, SDView.ServiceSequence)
    return self
end

function SDView.ServiceSequence:draw(widget, cr)
    --desenha as barras laterais
    local tam = #self.Primitives
    cr:set_line_width(2*N)
    cr:set_source_rgb(0, 0, 0)
    cr:move_to(350*N + 900*N*self.SLOT, 50*N) 
    cr:rel_line_to(0, 60*tam*N)
    cr:move_to(350*N + 900*N*self.SLOT + 180*N, 50*N) 
    cr:rel_line_to(0, 60*tam*N)
    cr:stroke()
   
    --escreve o nome da sequencia
    cr:set_font_size(16*N)
    cr:select_font_face('arial', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    local t_ext = cairo.TextExtents.create()
    cr:text_extents(self.NAME, t_ext)
    local x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to(350*N + 900*self.SLOT*N - txt_width/2 + 90*N , 18*N)
    cr:show_text(self.NAME)
   
    --escreve o nome da interface esquerda
    t_ext = cairo.TextExtents.create()
    cr:text_extents(self.LeftInterface, t_ext)
    x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
    cr:move_to(350*N + 900*self.SLOT*N - txt_width -90*N , 48*N)
    cr:show_text(self.LeftInterface)
  
    --escreve o nome da interface direita
    cr:move_to(350*N + 900*N*self.SLOT  +90*N + 180*N , 48*N)
    cr:show_text(self.RightInterface)
   
    --desenha os primitivos
    cr:set_font_size(12*N)
    for i, v in ipairs (self.Primitives) do
        if v.Interface == self.LeftInterface then
            cr:rectangle(350*N + 900*N*self.SLOT, 80*N + 60*(i-1)*N, 8*N, 8*N)
            v._ORIGEM = {
                350*N + 900*self.SLOT*N,
                80*N + 60*(i-1)*N,
                0
            }
            -- escreve o nome do evento
            t_ext = cairo.TextExtents.create()
            cr:text_extents(v.Event, t_ext)
            x_bearing, y_bearing, txt_width, txt_height, x_advance, y_advance = t_ext:get()
            cr:move_to(350*N + 900*self.SLOT*N - txt_width -60*N , 80*N + 60*(i-1)*N)
            cr:show_text(v.Event)
            -- desenha a flecha
            if i%2 ~= 0 then
                cr:move_to(350*N + 900*self.SLOT*N - 55*N, 80*N + 60*(i-1)*N+4*N)
                cr:line_to(350*N + 900*self.SLOT*N-5*N, 80*N + 60*(i-1)*N+4*N)
                cr:rel_line_to(-8*N, 6*N)
                cr:rel_move_to(8*N, -6*N)
                cr:rel_line_to(-8*N, -6*N)
            else
                cr:move_to(350*N + 900*self.SLOT*N-5*N, 80*N + 60*(i-1)*N+4*N)
                cr:line_to(350*N + 900*self.SLOT*N - 55*N, 80*N + 60*(i-1)*N+4*N)
                cr:rel_line_to(8*N, 6*N)
                cr:rel_move_to(-8*N, -6*N)
                cr:rel_line_to(8*N, -6*N)
            end
            cr:stroke()
        else
            cr:rectangle(350*N + 900*N*self.SLOT + 172*N, 80*N + 60*N*(i-1), 8*N, 8*N)
            v._ORIGEM = {
                350*N + 900*self.SLOT*N +172*N,
                80*N + 60*N*(i-1),
                1
            }
            --escreve o nome do evento
            cr:move_to(350*N + 900*self.SLOT*N +60*N + 180*N , 80*N + 60*(i-1)*N)
            cr:show_text(v.Event)
            --desenha a flecha
            if i%2 ~= 0 then
                cr:move_to(350*N + 900*self.SLOT*N + 55*N + 180*N, 80*N + 60*(i-1)*N+4*N)
                cr:line_to(350*N + 900*self.SLOT*N +5*N + 180*N , 80*N + 60*(i-1)*N+4*N)
                cr:rel_line_to(8*N, 6*N)
                cr:rel_move_to(-8*N, -6*N)
                cr:rel_line_to(8*N, -6*N)
            else
                cr:move_to(350*N + 900*self.SLOT*N +5*N + 180*N , 80*N + 60*(i-1)*N+4*N)
                cr:line_to(350*N + 900*self.SLOT*N + 55*N + 180*N, 80*N + 60*(i-1)*N+4*N)
                cr:rel_line_to(-8*N, 6*N)
                cr:rel_move_to(8*N, -6*N)
                cr:rel_line_to(-8*N, -6*N)
            end
            cr:stroke()
        end
        cr:stroke()
    end
    -- desenha as conexões
    cr:set_antialias(0)
    for i, v in ipairs (self.Primitives) do
        if i%2 ~= 0 then
            --1º caso -- Input - Left          Output-Right
			if self.Primitives[i]._ORIGEM[3] == 0 and self.Primitives[i+1]._ORIGEM[3] == 1 then
                cr:move_to(self.Primitives[i]._ORIGEM[1] + 8, self.Primitives[i]._ORIGEM[2] + 4)
                cr:line_to(self.Primitives[i+1]._ORIGEM[1] , self.Primitives[i+1]._ORIGEM[2] + 4)
            --2º caso -- Input - Right          Output-Left
            elseif self.Primitives[i]._ORIGEM[3] == 1 and self.Primitives[i+1]._ORIGEM[3] == 0 then
                cr:move_to(self.Primitives[i]._ORIGEM[1] , self.Primitives[i]._ORIGEM[2] + 4)
                cr:line_to(self.Primitives[i+1]._ORIGEM[1]+8 , self.Primitives[i+1]._ORIGEM[2] + 4)
            --3º caso -- Input - Right          Output-Right ou Left-Left
            elseif (self.Primitives[i]._ORIGEM[3] == 1 and self.Primitives[i+1]._ORIGEM[3] == 1) or
                   (self.Primitives[i]._ORIGEM[3] == 0 and self.Primitives[i+1]._ORIGEM[3] == 0) then
                cr:move_to(self.Primitives[i]._ORIGEM[1]+4 , self.Primitives[i]._ORIGEM[2] + 8)
                cr:line_to(self.Primitives[i+1]._ORIGEM[1]+4 , self.Primitives[i+1]._ORIGEM[2] )
            end
        end
    end
    cr:stroke()
    cr:set_antialias(1)
end

SDView.__index = SDView
function SDView.new(FB)
    --~ print('Hello SDVIEW')
    local self = {}
    self.ServiceSequences = {}
    for i, v in ipairs(FB.ServiceSequences) do
  		self.ServiceSequences[#self.ServiceSequences+1] = SDView.ServiceSequence.new(FB, v, i)
    end
    setmetatable(self, SDView)
    return self
end

function SDView:draw(widget, cr)
    for i, v in ipairs (self.ServiceSequences) do
        v:draw(widget , cr)
    end
    
end


    
