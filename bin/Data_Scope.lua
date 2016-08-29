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
Data_Scope = {
    event = 'output',
    _Functionality = 'Data_Scope'
}

function Data_Scope:exe( --[[include arguments]] )
	LOG_FILE:write('Data_Scope--- '..self.label..' initialized\n')
    LOG_FILE:write('Data_Scope--- '..self.label..' execution completed\n')
	local dialog = gtk.Dialog.new('Set data', nil, gtk.DIALOG_MODAL)
    dialog:connect('delete-event', function() dialog:hide() end, dialog)
	local content_area = dialog:get_action_area()
	local apply  = gtk.Button.new_with_label('OK')
	local vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	local dlabel = gtk.Label.new('Data Scope: '..self.label)
	local entrys = {}
	local labels = {}
	local hboxes = {}
	vbox:pack_start(dlabel, false, false, 0)
        for i, v in ipairs (self.invarlist) do
		entrys[#entrys+1] = gtk.Entry.new()
		labels[#labels+1] = gtk.Label.new('x'..#entrys)
		hboxes[#hboxes+1] = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
		hboxes[#hboxes]:add(labels[#labels], entrys[#entrys])
		vbox:add(hboxes[#hboxes])
		local str
		if type(self[v]) == 'table' then
			str = '{'
			for j, k in ipairs(self[v]) do
				if j == #self[v] then	str = str..'k '
				else	str = str..'k '..','	end
			end
			str = str..'}'
		else	str = tostring(self[v])       end
	        entrys[#entrys]:set('text', str)
	end
	content_area:add(vbox)
	dialog:add_action_widget(apply, gtk.RESPONSE_OK)
	content_area:show_all()
	dialog:run() dialog:hide()
end
Data_Scope.__index = Data_Scope
SIFB_Class.Data_Scope = Data_Scope

