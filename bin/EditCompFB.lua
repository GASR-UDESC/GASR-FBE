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

function EditCompFB_Initialize(self)
	--callback functions-----------------------------------------------------------------------
	local function list_remove_pos(l, pos)
		for j = pos, #l - 1 do
			l[j] = l[j+1]
		end
		l[#l] = nil
		return l
	end
	
	local split = function ( str )
		local _,_,str1,str2 = str:find('(.+)%.(.+)')
		return str1, str2
	end
	
	function refresh_comp()
		ApStructs   		 = nil
		ApStructs   		 = {}
		local dt 		     = F.Struct.DrawType 
		local UPPER          = F.Struct.UPPER
		local st             = F.Struct.INSTANCIA.NAME
		F.Struct 		     = CompView.new(F.Struct._FunctionBlock, F.Struct.ORIGEM)
		F.Drawing_Area:queue_draw()
		if UPPER then
			F.Struct.UPPER = UPPER
			if UPPER._Type == 'CompView' then
				F.Struct = UPPER
				refresh_comp()
			elseif UPPER._Type == 'ResourceView' then
				F.Struct = UPPER
				refresh_resource()
			end
			F.Struct = F.Struct[st]
		end
		if dt == 'open' then
			F.Struct.CORPO.CLICKED  = true
			F.Struct:get_clicked(F.Drawing_Area, F.Struct.ORIGEM[1]*N, F.Struct.ORIGEM[2]*N)
		end
	end
	
	local function AddIO(class)
		--widgets
		local window = gtk.Window.new()
		window:set('title', "Add "..class, 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local array  = gtk.Entry.new()
		local iox    = gtk.Entry.new()
		local typex  = gtk.Entry.new()
		local initv  = gtk.Entry.new()
		local name   = gtk.Entry.new()
		local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox1  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox2  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox3  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox4  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox5  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Hbox1  = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
		local alabel = gtk.Label.new('ArraySize*')
		local ilabel = gtk.Label.new('Input(i) or Output(o)')
		local tlabel = gtk.Label.new('Type (INT, BOOL..)')
		local nlabel = gtk.Label.new('Name')
		local vlabel = gtk.Label.new('Initial Value*')
		
		local function f_add()
			if (name:get('text') == '') or (name:get('text') == nil) then return end
			if iox:get('text') ~= 'o' and iox:get('text') ~= 'O' and iox:get('text') ~= 'I' and iox:get('text') ~= 'i' then return end
			if class == 'Event' then
				if iox:get('text') == 'i' or iox:get('text') == 'I' then
					self.Struct._FunctionBlock.ineventlist[#self.Struct._FunctionBlock.ineventlist+1]   = name:get('text')
					self.Struct._FunctionBlock.flag[name:get('text')] = 'InputEvent'
				else
					self.Struct._FunctionBlock.outeventlist[#self.Struct._FunctionBlock.outeventlist+1] = name:get('text')
					self.Struct._FunctionBlock.flag[name:get('text')] = 'OutputEvent'
				end
			else
				self.Struct._FunctionBlock.other.Type[name:get('text')]       	 			  	    = typex:get('text')
				self.Struct._FunctionBlock.other.ArraySize[name:get('text')]             	  	    = array:get('text') or 1 
				self.Struct._FunctionBlock.other.ArraySize2[name:get('text')]             	  	    = array:get('text') 
				if initv:get('text') ~= '' and initv:get('text') then
					self.Struct._FunctionBlock.other.InitialValue[name:get('text')]               	    = initv:get('text')
				end
				if iox:get('text') == 'i' or iox:get('text') == 'I' then
					self.Struct._FunctionBlock.invarlist[#self.Struct._FunctionBlock.invarlist+1]   = name:get('text')
					self.Struct._FunctionBlock.INPUTS[#self.Struct._FunctionBlock.INPUTS+1]    	    = name:get('text')
					self.Struct._FunctionBlock.flag[name:get('text')] = 'InputVar'
				else
					self.Struct._FunctionBlock.outvarlist[#self.Struct._FunctionBlock.outvarlist+1] = name:get('text')
					self.Struct._FunctionBlock.flag[name:get('text')] = 'OutputVar'
				end	
				array:set('text', '')
				initv:set('text', '')
				typex:set('text', '')
				
			end
			self.Struct._FunctionBlock.other[name:get('text')] = {}
			name:set('text', '')
			iox:set('text', '')
			refresh_comp()
		end
		
		local add    = gtk.Button.new_with_label('Add '..class)
		add:connect('clicked', f_add)
		
		Vbox1:add(nlabel, name)
		Vbox2:add(ilabel, iox)
		Hbox1:add(Vbox1, Vbox2)
		if class == 'Variable' then
			Vbox3:add(tlabel, typex)
			Vbox4:add(alabel, array)
			Vbox5:add(vlabel, initv)
			Hbox1:add(Vbox3, Vbox4, Vbox5)
		end
		Vbox:add(Hbox1, add)
		window:add(Vbox)
		window:show_all()
	end

	local function RemoveIO(class)
		local window = gtk.Window.new()
		window:set('title', "Remove "..class, 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox     = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Hbox     = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL )
		local Vbox1    = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox2    = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local input    = gtk.Label.new('Input')
		local output   = gtk.Label.new('Output')
		local incombo  = gtk.ComboBoxText.new()
		local outcombo = gtk.ComboBoxText.new()
		local removi   = gtk.Button.new_with_label('Remove Input')
		local removo   = gtk.Button.new_with_label('Remove Output')
		
		local function fill(i, o)
			if class == 'Event' then
				if i then
					for i, v in ipairs(self.Struct._FunctionBlock.ineventlist)  do
						incombo:append_text(v)
					end
				end
				if o then
					for i, v in ipairs(self.Struct._FunctionBlock.outeventlist) do
						outcombo:append_text(v)
					end
				end
			else
				if i then
					for i, v in ipairs(self.Struct._FunctionBlock.invarlist)  do
						incombo:append_text(v)
					end
				end
				if o then
					for i, v in ipairs(self.Struct._FunctionBlock.outvarlist) do
						outcombo:append_text(v)
					end
				end
			end
		end
		
		local function remove_input()
			local pos  = 0
			local name = incombo:get_active_text() 
			self.Struct._FunctionBlock.other[name] = {}
			if class == 'Event' then	
				for i, v in ipairs(self.Struct._FunctionBlock.ineventlist) do
					incombo:remove(0)
					if v == name then pos = i break end
				end
				for i = pos, #self.Struct._FunctionBlock.ineventlist - 1 do
					incombo:remove(0)
					self.Struct._FunctionBlock.ineventlist[i] = self.Struct._FunctionBlock.ineventlist[i+1]
				end
				self.Struct._FunctionBlock.ineventlist[#self.Struct._FunctionBlock.ineventlist] = nil
			else
				for i, v in ipairs(self.Struct._FunctionBlock.invarlist) do
					incombo:remove(0)
					if v == name then pos = i break end
				end
				for i = pos, #self.Struct._FunctionBlock.invarlist - 1 do
					incombo:remove(0)
					self.Struct._FunctionBlock.invarlist[i] = self.Struct._FunctionBlock.invarlist[i+1]
				end
				self.Struct._FunctionBlock.invarlist[#self.Struct._FunctionBlock.invarlist] = nil
			end
			refresh_comp()
			fill(true, false)
		end
		
		local function remove_output()
			local pos  = 0
			local name = outcombo:get_active_text() 
			self.Struct._FunctionBlock.other[name] = {}
			if class == 'Event' then	
				for i, v in ipairs(self.Struct._FunctionBlock.outeventlist) do
					outcombo:remove(0)
					if v == name then  pos = i break end
				end
				for i = pos, #self.Struct._FunctionBlock.outeventlist - 1 do
					outcombo:remove(0)
					self.Struct._FunctionBlock.outeventlist[i] = self.Struct._FunctionBlock.outeventlist[i+1]
				end
				self.Struct._FunctionBlock.outeventlist[#self.Struct._FunctionBlock.outeventlist] = nil
				for i, v in pairs(self.Struct._FunctionBlock.stlist) do
				for j, k in ipairs(v.action) do
					if k.out == name then
						k.out = nil
					end
				end
			end
			else
				for i, v in ipairs(self.Struct._FunctionBlock.outvarlist) do
					outcombo:remove(v)
					if v == name then pos = i break end
				end
				for i = pos, #self.Struct._FunctionBlock.outvarlist - 1 do
					outcombo:remove(0)
					self.Struct._FunctionBlock.outvarlist[i] = self.Struct._FunctionBlock.outvarlist[i+1]
				end
				self.Struct._FunctionBlock.outvarlist[#self.Struct._FunctionBlock.outvarlist] = nil
			end
			refresh_comp()
			fill(false, true)
		end
		
		removi:connect('clicked', remove_input )
		removo:connect('clicked', remove_output)
		Vbox1:add(input, incombo, removi)
		Vbox2:add(output, outcombo, removo)
		Hbox:pack_start(Vbox1, false, false, 30)
		Hbox:pack_start(Vbox2, false, false, 30)
		Vbox:add(Hbox)
		window:add(Vbox)
		fill(true, true)
		window:show_all()
	end
	
	
	local function AddWithVar()
		local window    = gtk.Window.new()
		window:set('title', "Add 'WithVar' ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 100, 'default-height', 0)
		local Vbox      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox1      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox2      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Hbox      	 = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL )
		local incombo        = gtk.ComboBoxText.new()
		local outcombo       = gtk.ComboBoxText.new()
		local input	         = gtk.Button.new_with_label('Event Input')
		local output         = gtk.Button.new_with_label('Event Output')
		local ilabel         = gtk.Label.new('Event Input')
		local olabel         = gtk.Label.new('Event Output')
		
		for i, v in ipairs(self.Struct._FunctionBlock.ineventlist)  do
			incombo:append_text(v)
		end				
		for i, v in ipairs(self.Struct._FunctionBlock.outeventlist) do
			outcombo:append_text(v)
		end				
		
		local function var(i_o)
			local event
			if i_o == 'i' then
				event = incombo:get_active_text()
			else
				event = outcombo:get_active_text()
			end
			if not event or event == '' then return end
			window:hide()
			local window2 = gtk.Window.new()
			window2:set('title', "Add 'WithVar' ", 'window-position', gtk.WIN_POS_CENTER)
			window2:set('default-width', 0, 'default-height', 0)
			local combo  = gtk.ComboBoxText.new()
			local Vbox   = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
			local add    = gtk.Button.new_with_label('Add WithVar')
			local finish = gtk.Button.new_with_label('Finish')
			local vlabel = gtk.Label.new('Var')
			
			if i_o == 'i' then
				for i, v in ipairs(self.Struct._FunctionBlock.invarlist) do
					combo:append_text(v)
				end
			else
				for i, v in ipairs(self.Struct._FunctionBlock.outvarlist) do
					combo:append_text(v)
				end
			end
			local function f_add()
				local var = combo:get_active_text()
				if var and var ~= '' then
					if type(self.Struct._FunctionBlock.with[event]) ~= "table" then
						self.Struct._FunctionBlock.with[event] ={}
					end
					for i, v in ipairs(self.Struct._FunctionBlock.with[event]) do
						if v == var then return end
					end
					local tam = #self.Struct._FunctionBlock.with[event]  +1
					self.Struct._FunctionBlock.with[event][tam] = var
					refresh_comp()
				end
			end
			
			local function f_finish()
				window2:hide()
			end
			
			Vbox:add(vlabel, combo, add, finish)
			add:connect('clicked', f_add)
			finish:connect('clicked', f_finish)
			window2:add(Vbox)
			window2:show_all()
		end				
		input:connect('clicked', var,  'i')
		output:connect('clicked', var,  'o')
		Vbox1:add(ilabel, incombo, input)
		Vbox2:add(olabel, outcombo, output)
		Hbox:add(Vbox1, Vbox2)
		window:add(Hbox)
		window:show_all()
	end
	
	local function RemoveWithVar()
		local window    = gtk.Window.new()
		window:set('title', "Remove 'WithVar' ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 100, 'default-height', 0)
		local Vbox      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox1      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox2      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Hbox      	 = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL )
		local incombo        = gtk.ComboBoxText.new()
		local outcombo       = gtk.ComboBoxText.new()
		local input	         = gtk.Button.new_with_label('Input Event')
		local output         = gtk.Button.new_with_label('Output Event')
		local ilabel         = gtk.Label.new('Event')
		local olabel         = gtk.Label.new('Event')
		
		for i, v in ipairs(self.Struct._FunctionBlock.ineventlist)  do
			incombo:append_text(v)
		end				
		for i, v in ipairs(self.Struct._FunctionBlock.outeventlist) do
			outcombo:append_text(v)
		end				
		
		local function var(i_o)
			local event
			if i_o == 'i' then
				event = incombo:get_active_text()
			else
				event = outcombo:get_active_text()
			end
			window:hide()
			if not event or event == '' then return end
			local window2 = gtk.Window.new()
			window2:set('title', "Add 'WithVar' ", 'window-position', gtk.WIN_POS_CENTER)
			window2:set('default-width', 0, 'default-height', 0)
			local combo  = gtk.ComboBoxText.new()
			local Vbox   = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
			local removw = gtk.Button.new_with_label('Remove')
			local finish = gtk.Button.new_with_label('Finish')
			local vlabel = gtk.Label.new('Var')
			
			for i, v in ipairs(self.Struct._FunctionBlock.with[event]) do
				combo:append_text(v)
			end
			
			local function f_remove()
				local var = combo:get_active_text()
				if var and var ~= '' then
					for i, v in ipairs(self.Struct._FunctionBlock.with[event]) do
						local j
						if v == var then
							for j = i, #self.Struct._FunctionBlock.with[event] -1 do
								self.Struct._FunctionBlock.with[event][j] = self.Struct._FunctionBlock.with[event][j+1]
							end
							self.Struct._FunctionBlock.with[event][#self.Struct._FunctionBlock.with[event]] = nil
							if #self.Struct._FunctionBlock.with[event] == 0 then
								self.Struct._FunctionBlock.with[event] = nil
							end
						end
					end
				end
				refresh_comp()
			end
			
			local function f_finish()
				window2:hide()
			end
			
			Vbox:add(vlabel, combo, removw, finish)
			removw:connect('clicked', f_remove)
			finish:connect('clicked', f_finish)
			window2:add(Vbox)
			window2:show_all()
		end				
		
		
		input:connect('clicked', var,  'i')
		output:connect('clicked', var,  'o')
		Vbox1:add(ilabel, incombo, input)
		Vbox2:add(olabel, outcombo, output)
		Hbox:add(Vbox1, Vbox2)
		window:add(Hbox)
		window:show_all()
	end
	
	
	local function Header()
		local window = gtk.Window.new()
		window:set('title', "Header Info ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Hbox1     = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL )
		local Vbox1     = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox2     = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox3     = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox4     = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local nlabel    = gtk.Label.new('FBType Name')
		local clabel    = gtk.Label.new('Comment')
		local alabel    = gtk.Label.new('Author')
		local dlabel    = gtk.Label.new('Date')
		local nEntry    = gtk.Entry.new()
		local cEntry    = gtk.Entry.new()
		local aEntry    = gtk.Entry.new()
		local dEntry    = gtk.Entry.new()
		local apply     = gtk.Button.new_with_label('Apply')
		nEntry:set('text', self.Struct._FunctionBlock.FBType)
		cEntry:set('text', self.Struct._FunctionBlock.other.Comment['FBType'] or '')
		aEntry:set('text', self.Struct._FunctionBlock._Author or '')
		dEntry:set('text', self.Struct._FunctionBlock._Date or '')
		Vbox1:add(nlabel, nEntry)
		Vbox2:add(clabel, cEntry)
		Vbox3:add(alabel, aEntry)
		Vbox4:add(dlabel, dEntry)
		Hbox1:add(Vbox1, Vbox2, Vbox3, Vbox4)
		Vbox:add(Hbox1, apply)
	
		local function f_apply()
			if nEntry:get('text') ~= '' and nEntry:get('text') then
				self.Struct._FunctionBlock.FBType = nEntry:get('text')
				self.Struct._FunctionBlock.other.Version[1] = {
					Author       = aEntry:get('text'),
					Date         = dEntry:get('text') 
				}
				self.Struct._FunctionBlock.other.Comment['FBType'] = cEntry:get('text')
			end
			refresh_comp()
			window:hide()
		end
		
		apply:connect('clicked', f_apply)
		window:add(Vbox)
		window:show_all()
	end
	
	local function AddVarConnection()
		local window = gtk.Window.new()
		window:set('title', "Add Var Connection", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local sourceCombo  = gtk.ComboBoxText.new()
		local destCombo    = gtk.ComboBoxText.new()
		local svarCombo    = gtk.ComboBoxText.new()
		local dvarCombo    = gtk.ComboBoxText.new()
		local Vbox         = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Hbox         = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
		local Vbox1        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox2        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox3        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox4        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local sourceButton = gtk.Button.new_with_label('Select Source')
		local destButton   = gtk.Button.new_with_label('Select Dest.')
		local add          = gtk.Button.new_with_label('Add Var Connection')
		local sourceLabel  = gtk.Label.new('Source')
		local destLabel    = gtk.Label.new('Destination')
		local svarLabel    = gtk.Label.new('SourceVar')
		local dvarLabel    = gtk.Label.new('DestVar')
		local i_tam        = 0
		local o_tam        = 0
		for i, v in ipairs(self.Struct._FunctionBlock.FBNetwork) do
			sourceCombo:append_text(v[1])
			destCombo:append_text(v[1])
		end
		sourceCombo:append_text('self')
		destCombo:append_text('self')
		
		local function choose_source()
			local name = sourceCombo:get_active_text()
			if not name or name == '' then return end
			for i = 1, o_tam do
				svarCombo:remove(0)
			end
			if name == 'self' then
				for i, v in ipairs(self.Struct._FunctionBlock.outvarlist) do
					svarCombo:append_text(v)
				end
				o_tam = #self.Struct._FunctionBlock.outvarlist
			else
				for i, v in ipairs(self.Struct._FunctionBlock[name].outvarlist) do
					svarCombo:append_text(v)
				end
				o_tam = #self.Struct._FunctionBlock[name].outvarlist
			end
		end
		
		local function choose_dest()
			local name = destCombo:get_active_text()
			if not name or name == '' then return end
			for i = 1, i_tam do
				dvarCombo:remove(0)
			end
			if name == 'self' then
				for i, v in ipairs(self.Struct._FunctionBlock.invarlist) do
					dvarCombo:append_text(v)
				end
				i_tam = #self.Struct._FunctionBlock.invarlist
			else
				for i, v in ipairs(self.Struct._FunctionBlock[name].invarlist) do
					dvarCombo:append_text(v)
				end
				i_tam = #self.Struct._FunctionBlock[name].invarlist
			end
		end
		
		local function f_add()
			local source = sourceCombo:get_active_text()
			local dest   = destCombo:get_active_text()
			local svar   = svarCombo:get_active_text()
			local dvar   = dvarCombo:get_active_text()
			if not source or source == '' then return end
			if not dest or dest     == '' then return end
			if not svar or svar     == '' then return end
			if not dvar or dvar     == '' then return end
			if type(self.Struct._FunctionBlock.DataConnections[dest]) ~= 'table' then
                self.Struct._FunctionBlock.DataConnections[dest] = {}
            end
            self.Struct._FunctionBlock.DataConnections[dest][dvar] = {source, svar}
			refresh_comp()
		end
		--connecting buttons to functions
		sourceButton:connect('clicked', choose_source)
		destButton:connect('clicked', choose_dest)
		add:connect('clicked', f_add)
		--packing
		Vbox1:add(sourceLabel, sourceCombo, sourceButton)
		Vbox2:add(svarLabel, svarCombo)
		Vbox3:add(destLabel, destCombo, destButton)
		Vbox4:add(dvarLabel, dvarCombo)
		Hbox:add(Vbox1, Vbox2, Vbox3, Vbox4)
		Vbox:add(Hbox, add)
		window:add(Vbox)
		window:show_all()
	
	end
	
	local function AddEventConnection()
	local window = gtk.Window.new()
		window:set('title', "Add Event Connection", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local sourceCombo  = gtk.ComboBoxText.new()
		local destCombo    = gtk.ComboBoxText.new()
		local svarCombo    = gtk.ComboBoxText.new()
		local dvarCombo    = gtk.ComboBoxText.new()
		local Vbox         = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Hbox         = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
		local Vbox1        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox2        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox3        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox4        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local sourceButton = gtk.Button.new_with_label('Select Source')
		local destButton   = gtk.Button.new_with_label('Select Dest.')
		local add          = gtk.Button.new_with_label('Add Event Connection')
		local sourceLabel  = gtk.Label.new('Source')
		local destLabel    = gtk.Label.new('Destination')
		local svarLabel    = gtk.Label.new('SourceEvent')
		local dvarLabel    = gtk.Label.new('DestEvent')
		local i_tam        = 0
		local o_tam        = 0
		for i, v in ipairs(self.Struct._FunctionBlock.FBNetwork) do
			sourceCombo:append_text(v[1])
			destCombo:append_text(v[1])
		end
		sourceCombo:append_text('self')
		destCombo:append_text('self')
		
		local function choose_source()
			local name = sourceCombo:get_active_text()
			if not name or name == '' then return end
			for i = 1, o_tam do
				svarCombo:remove(0)
			end
			if name == 'self' then
				for i, v in ipairs(self.Struct._FunctionBlock.outeventlist) do
					svarCombo:append_text(v)
				end
				o_tam = #self.Struct._FunctionBlock.outeventlist
			else
				for i, v in ipairs(self.Struct._FunctionBlock[name].outeventlist) do
					svarCombo:append_text(v)
				end
				o_tam = #self.Struct._FunctionBlock[name].outeventlist
			end
		end
		
		local function choose_dest()
			local name = destCombo:get_active_text()
			if not name or name == '' then return end
			for i = 1, i_tam do
				dvarCombo:remove(0)
			end
			if name == 'self' then
				for i, v in ipairs(self.Struct._FunctionBlock.ineventlist) do
					dvarCombo:append_text(v)
				end
				i_tam = #self.Struct._FunctionBlock.ineventlist
			else
				for i, v in ipairs(self.Struct._FunctionBlock[name].ineventlist) do
					dvarCombo:append_text(v)
				end
				i_tam = #self.Struct._FunctionBlock[name].ineventlist
			end
		end
		
		local function f_add()
			local source = sourceCombo:get_active_text()
			local dest   = destCombo:get_active_text()
			local svar   = svarCombo:get_active_text()
			local dvar   = dvarCombo:get_active_text()
			if not source or source == '' then return end
			if not dest or dest     == '' then return end
			if not svar or svar     == '' then return end
			if not dvar or dvar     == '' then return end
			if type(self.Struct._FunctionBlock.EventConnections[source]) ~= 'table' then
                self.Struct._FunctionBlock.EventConnections[source] = {}
            end
            self.Struct._FunctionBlock.EventConnections[source][svar] = {dest, dvar}
			refresh_comp()
		end
		--connecting buttons to functions
		sourceButton:connect('clicked', choose_source)
		destButton:connect('clicked', choose_dest)
		add:connect('clicked', f_add)
		--packing
		Vbox1:add(sourceLabel, sourceCombo, sourceButton)
		Vbox2:add(svarLabel, svarCombo)
		Vbox3:add(destLabel, destCombo, destButton)
		Vbox4:add(dvarLabel, dvarCombo)
		Hbox:add(Vbox1, Vbox2, Vbox3, Vbox4)
		Vbox:add(Hbox, add)
		window:add(Vbox)
		window:show_all()
	end
	
	local function RemoveConnection()
		local window = gtk.Window.new()
		window:set('title', "Remove Connection", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local varCombo  = gtk.ComboBoxText.new()
		local eveCombo  = gtk.ComboBoxText.new()
		local Vbox      = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox1     = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox2     = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local varLabel  = gtk.Label.new('DataConnections')
		local eveLabel  = gtk.Label.new('EventConnections')
		local varButton = gtk.Button.new_with_label('Remove DataConnection')
		local eveButton = gtk.Button.new_with_label('Remove EventConnection')
		local eveTam    = 0
		local varTam    = 0
		
		local function fill(var, ev)
			if var then
				for i = 1, varTam do
					varCombo:remove(0)
				end
				varTam = 0
				for i, v in pairs(self.Struct._FunctionBlock.DataConnections) do
					for j, k in pairs(v) do
						varCombo:append_text(k[1]..'.'..k[2]..' --> '..i..'.'..j)
						varTam = varTam + 1
					end
				end
			end
			if ev then
				for i = 1, eveTam do
					eveCombo:remove(0)
				end
				eveTam = 0
				for i, v in pairs(self.Struct._FunctionBlock.EventConnections) do
					for j, k in pairs(v) do
						eveCombo:append_text(i..'.'..j..' -> '..k[1]..'.'..k[2])
						eveTam = eveTam + 1
					end
				end
			end
		end
		
		local function f_eve()
			local str = eveCombo:get_active_text()
			if not str or str == '' then return end
			local source, seve, dest, desteve, a, b, c
			a, b, source, seve, c, dest, desteve = str:find('(.+)%.(.+)%s(.+)%s(.+)%.(.+)')
			self.Struct._FunctionBlock.EventConnections[source][seve] = nil
			fill(false, true)
			refresh_comp()
			
			
		end
		
		local function f_var()
			local str = varCombo:get_active_text()
			if not str or str == '' then return end
			local source, seve, dest, desteve, a, b, c
			a, b, source, seve, c, dest, desteve = str:find('(.+)%.(.+)%s(.+)%s(.+)%.(.+)')
			self.Struct._FunctionBlock.DataConnections[dest][desteve] = nil
			fill(true, false)
			refresh_comp()
			
		end
		
		fill(true, true)
		eveButton:connect('clicked', f_eve)
		varButton:connect('clicked', f_var)
		Vbox1:add(eveLabel, eveCombo, eveButton)
		Vbox2:add(varLabel, varCombo, varButton)
		Vbox:add(Vbox1, Vbox2)
		window:add(Vbox)
		window:show_all()
	end
	
	local function AddFB()
		local name
		local window = gtk.Window.new()
		window:set('title', "Add FB", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local nlabel = gtk.Label.new('FB Instance Name')
		local nEntry = gtk.Entry.new()
		local add    = gtk.Button.new_with_label('Add FB')
		
		local function f_add()
			local name = nEntry:get('text')
			if not name or name =='' then return end
			local open_dialog = gtk.FileChooserDialog.new('Load FB', self.Main_Window, gtk.FILE_CHOOSER_ACTION_OPEN, 'gtk-close', 
															gtk.RESPONSE_CLOSE, 'gtk-open', gtk.RESPONSE_OK)
			open_dialog:set_current_folder(self.Library)
			if (open_dialog:run() == gtk.RESPONSE_OK) then
				local file
				file 		= open_dialog:get_filenames()
				file        = file[1]
				file 		= select( 3, file:find( ".-([^%/]*)$"  ) )
				local fb        = FB.importXML(self.Library..'/', file, 'fb')
				if fb.Class == 'Basic' or fb.Class == 'Comp' or fb.Class == 'Composite' or fb.Class == 'ServiceInterface' then
					self.Struct._FunctionBlock[name]    		          		= FB.importXML (self.Library..'\\',file, name)
					self.Struct._FunctionBlock.flag[name]				 		= self.Struct._FunctionBlock[name].Class
					self.Struct._FunctionBlock[name].Upper 			  	     	= self.Struct._FunctionBlock
					self.Struct._FunctionBlock[name].dx 	  			  		= 200
					self.Struct._FunctionBlock[name].dy 	  			  		= 200
					self.Struct._FunctionBlock.FBNetwork[#self.Struct._FunctionBlock.FBNetwork+1] = {name,200, 200}
					window:hide()
				end
			end
			nEntry:set('text', '')
			open_dialog:hide()
			refresh_comp()
		end
		
		local function f_done()
			window:hide()
		end
		
		add:connect('clicked', f_add)
		Vbox:add(nlabel, nEntry, add)
		window:add(Vbox)
		window:show_all()
	end
	
	local function RemoveFB()
		local window = gtk.Window.new()
		window:set('title', "Remove FB", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local nLabel = gtk.Label.new('FB Instance Name')
		local nCombo = gtk.ComboBoxText.new()
		local removb = gtk.Button.new_with_label('Remove FB')
		
		local function fill()
			for i, v in ipairs(self.Struct._FunctionBlock.FBNetwork) do
				nCombo:append_text(v[1])
			end
		end
		
		local function f_remove() 
			local name = nCombo:get_active_text()
			if not name or name == '' then return end
			for i = 1, #self.Struct._FunctionBlock.FBNetwork do
				nCombo:remove(0)
			end
			for i, v in ipairs(self.Struct._FunctionBlock.FBNetwork) do
				if name == v[1] then
					self.Struct._FunctionBlock.FBNetwork = list_remove_pos(self.Struct._FunctionBlock.FBNetwork, i)
					self.Struct._FunctionBlock[name] = nil
					break
				end
			end
			local remove_list = {}
			self.Struct._FunctionBlock.EventConnections[name] = nil
			for i, v in pairs(self.Struct._FunctionBlock.EventConnections) do
				for j, k in pairs(v) do
					if k[1] == name then
						remove_list[#remove_list+1] = {i, j}
					end
				end
			end
			
			for i, v in ipairs(remove_list) do
				self.Struct._FunctionBlock.EventConnections[v[1]][v[2]] = nil
			end
			remove_list = {}
			self.Struct._FunctionBlock.DataConnections[name] = nil
			for i, v in pairs(self.Struct._FunctionBlock.DataConnections) do
				for j, k in pairs(v) do
					if k[1] == name then
						remove_list[#remove_list+1] = {i, j}
					end
				end
			end
			
			for i, v in ipairs(remove_list) do
				self.Struct._FunctionBlock.DataConnections[v[1]][v[2]] = nil
			end
			
			refresh_comp()
			fill()
			window:hide()
		end
		
		fill()
		removb:connect('clicked', f_remove)
		Vbox:add(nLabel, nCombo, removb)
		window:add(Vbox)
		window:show_all()
	end
	
	--loading Basic Function Block .xml Template
	ApStructs		       = nil ApStructs = {}
	click_flag 			   = false
	self.Drawing_Area:queue_draw()
	--Boxes to keep the buttons
	self.CAddRemoveBox	   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	self.CHeaderBox	       = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	--Labels----------------------------------------------------------------------------------
	self.CAddLabel          = gtk.Label.new('Add I/O')                             --Labels
	self.CRemoveLabel       = gtk.Label.new('Remove I/O')					      
	self.CHeaderLabel       = gtk.Label.new('Header')							  
	self.CWithVarLabel      = gtk.Label.new('WithVar')							  
	self.CConnectionLabel   = gtk.Label.new('Connections')							  
	self.CFBNetLabel        = gtk.Label.new('FBNetwork')							  
	
	--Entrys-----------------------------------------------------------------------------------
	
	--Buttons----------------------------------------------------------------------------------
	self.CAddEvent            = gtk.Button.new_with_label('Add <Event>'		     )      --ADD I/O
	self.CAddVar  	          = gtk.Button.new_with_label('Add <Var>'		 	 )      --
	self.CRemoveEvent  	      = gtk.Button.new_with_label('Remove <Event>'       )      --REMOVE I/O
	self.CRemoveVar	          = gtk.Button.new_with_label('Remove <Var>'         )      --
	self.CAddWithVar          = gtk.Button.new_with_label('Add <With Var>'	   	 ) 
	self.CRemoveWithVar       = gtk.Button.new_with_label('Remove <With Var>'    )
	self.CAddVarConnection    = gtk.Button.new_with_label('Add <VarConnection>'  )       
	self.CAddEventConnection  = gtk.Button.new_with_label('Add <EventConnection>')       
	self.CRemoveConnection    = gtk.Button.new_with_label('Remove <Connection>'  )      
	self.CAddFB               = gtk.Button.new_with_label('Add <FB>'             )
	self.CRemoveFB            = gtk.Button.new_with_label('Remove <FB>'          )
	self.CHeaderButton        = gtk.Button.new_with_label('Edit <Header>'	     )     --HEADER
	
	
	--Connecting Buttons to Functions--------------------------------------------------------
	self.CHeaderButton:connect(        'clicked', Header			  ) 
	self.CAddEvent:connect(      	   'clicked', AddIO,   'Event' 	  )               --I/O
	self.CAddVar:connect(        	   'clicked', AddIO,   'Variable' )		
	self.CRemoveEvent:connect(   	   'clicked', RemoveIO,'Event' 	  )
	self.CRemoveVar:connect(     	   'clicked', RemoveIO,'Variable' )
	self.CAddWithVar:connect(		   'clicked', AddWithVar		  )   
	self.CRemoveWithVar:connect(	   'clicked', RemoveWithVar   	  )
	self.CAddVarConnection:connect(	   'clicked', AddVarConnection    )
	self.CAddEventConnection:connect(  'clicked', AddEventConnection  )
	self.CRemoveConnection:connect(    'clicked', RemoveConnection    )
	self.CAddFB:connect(			   'clicked', AddFB			      )
	self.CRemoveFB:connect(			   'clicked', RemoveFB			  )
	--Packing--------------------------------------------------------------------------------
	self.CHeaderBox:pack_start(    self.CHeaderLabel,         false, false, 5)  		 --HEADER_LABEL
  	self.CHeaderBox:pack_start(    self.CHeaderButton ,       false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CAddLabel,            false, false, 5)  		 --ADD_LABEL
  	self.CHeaderBox:pack_start(    self.CAddEvent,       	  false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CAddVar,              false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CRemoveLabel,         false, false, 5)  		 --REMOVE_LABEL
	self.CHeaderBox:pack_start(    self.CRemoveEvent,         false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CRemoveVar,	          false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CWithVarLabel,        false, false, 0)  		 --WITH VAR LABEL
	self.CHeaderBox:pack_start(    self.CAddWithVar,          false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CRemoveWithVar,       false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CFBNetLabel,     	  false, false, 0)  		 --FBNETWORK LABEL
	self.CHeaderBox:pack_start(    self.CAddFB,   		      false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CRemoveFB,    	      false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CConnectionLabel,     false, false, 0)  		 --CONNECTION LABEL
	self.CHeaderBox:pack_start(    self.CAddVarConnection,    false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CAddEventConnection,  false, false, 0)  		 --button
	self.CHeaderBox:pack_start(    self.CRemoveConnection,    false, false, 0)  		 --button
	self.EditBoxComp:pack_start(      self.CHeaderBox,        false, false, 0)         	 --HeaderBox 
	
end

function EditCompFB(self , new )
	if self._IsEditModeComp then return end
	self._IsEditMode 	   = true
	self._IsEditModeComp   = true
	self._IsEditModeBasic  = false
	self._IsEditModeSIFB   = false
	self._IsEditModeRes    = false
	self._IsEditModeDev    = false
	self._IsEditModeDevice = false
	self.ScrollBox:pack_start(	     self.EditBoxComp,       false, false, 0)  		 --EditBoxComp
	if new then
		ApStructs   = nil
		ApStructs   = {}
		self.Struct = CompView.new(FB.importXML ('', 'TEMPLATE_COMPFB.xml', "FunctionBlock"))
		self.CurrentStructEntry:set( 'text' , self.Struct._FunctionBlock.FBType )
		self._File  = 'TEMPLATE_COMPFB.xml'
	end
	--Reset Window-------------------------------------------------------------------------	
	--self.Main_Window:hide()
	self.Main_Window:show_all()
	
end
