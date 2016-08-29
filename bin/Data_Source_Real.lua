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
require 'lgob.gtk'
require 'lgob.gdk'

Data_Source_Real = {
    event = 'output',
    _Functionality = 'Data_Source_Real'
}


function Data_Source_Real:exe( --[[include arguments]] )
    LOG_FILE:write('Data_Source_Real--- '..self.label..' initialized\n')
    LOG_FILE:write('Data_Source_Real--- '..self.label..' execution completed\n')
    
	local dialog = gtk.Dialog.new('Set data', nil, gtk.DIALOG_MODAL)
    dialog:connect('delete-event', function() dialog:hide() end, dialog)
	local content_area = dialog:get_action_area()
	local apply  = gtk.Button.new_with_label('OK')
	local vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	local dlabel = gtk.Label.new('Set Data')
	local entrys = {}
	local labels = {}
	local hboxes = {}
	vbox:pack_start(dlabel, false, false, 0)
    for i, v in ipairs (self.outvarlist) do
		entrys[#entrys+1] = gtk.Entry.new()
		entrys[#entrys]:set('text', '0')
		labels[#labels+1] = gtk.Label.new('x'..#entrys)
		hboxes[#hboxes+1] = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
		hboxes[#hboxes]:add(labels[#labels], entrys[#entrys])
		vbox:add(hboxes[#hboxes])
		
	end
	content_area:add(vbox)
	local function f_apply()
		for i, v in ipairs (self.outvarlist) do
			self[v] = tonumber(entrys[i]:get('text'))
		end
	end
	apply:connect('clicked', f_apply)
	dialog:add_action_widget(apply, gtk.RESPONSE_OK)
	content_area:show_all()
	dialog:run()
	dialog:hide()
	self._Resource:exe(self.event, self.label)
  
end

Data_Source_Real.__index = Data_Source_Real

SIFB_Class.Data_Source_Real = Data_Source_Real


