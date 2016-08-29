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

function EditBasicFB_Initialize(self)
	--callback functions-----------------------------------------------------------------------
	local function refresh()
		ApStructs   		 = nil
		ApStructs   		 = {}
		local dt 		     = self.Struct.DrawType 
		self.Struct 		 = BlockView.new(self.Struct._FunctionBlock, self.Struct.ORIGEM)
		self.Struct.DrawType = dt
		self.Drawing_Area:queue_draw()
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
			refresh()
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
			refresh()
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
			refresh()
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
	
	local function AddState()
		local window    = gtk.Window.new()
		window:set('title', "Add ECState ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local addECS    	 = gtk.Button.new_with_label('Add ECState')
	    local nEntry         = gtk.Entry.new()
		local nLabel         = gtk.Label.new('Name')
		local state
		
		local function add_action()
			local window2   = gtk.Window.new()
			window2:set('title', "Add Action ", 'window-position', gtk.WIN_POS_CENTER)
			window2:set('default-width', 0, 'default-height', 0)
			local Hbox11    = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL )
			local Vbox11    = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
			local Vbox22    = gtk.Box.new( gtk.ORIENTATION_VERTICAL )	
			local finish    = gtk.Button.new_with_label('Finish')
			local action    = gtk.Button.new_with_label('Add Action')
			local algCombo  = gtk.ComboBoxText.new()
			local outCombo  = gtk.ComboBoxText.new()
			local algLabel  = gtk.Label.new('Algorithm')
			local outLabel  = gtk.Label.new('Output')
			for i, v in ipairs( self.Struct._FunctionBlock._algs ) do
				algCombo:append_text(v)
			end
			for i, v in ipairs( self.Struct._FunctionBlock.outeventlist ) do
				outCombo:append_text(v)
			end
			
			local function new_action()
				local alg = algCombo:get_active_text()
				local out = outCombo:get_active_text()
				tam       = #self.Struct._FunctionBlock.stlist[state].action
				self.Struct._FunctionBlock.stlist[state].action[tam+1] 	   = {}
				self.Struct._FunctionBlock.stlist[state].action[tam+1].alg = alg
				self.Struct._FunctionBlock.stlist[state].action[tam+1].out = out
				refresh()
			end
			
			local function close()
				refresh()
				window2:hide()
			end
			
			action:connect('clicked', new_action)
			finish:connect('clicked', close)
			Vbox11:add(algLabel, algCombo, action)
			Vbox22:add(outLabel, outCombo, finish)
			Hbox11:add(Vbox11, Vbox22)
			window2:add(Hbox11)
			window2:show_all()
		end
		
		local function add_state()
			if nEntry:get('text') == '' or not nEntry:get('text') then return end
			local name = nEntry:get('text')
			state 											   = name
			self.Struct._FunctionBlock.stlist[name] 		   = {}
			self.Struct._FunctionBlock.stlist[name].transition = {}
			self.Struct._FunctionBlock.stlist[name].action     = {}
			self.Struct._FunctionBlock.STdx[name]              = 300
			self.Struct._FunctionBlock.STdy[name]              = 300
			window:hide()
			add_action()
		end
		
		
		addECS:connect('clicked', add_state)
		Vbox:add(nLabel, nEntry, addECS)
		window:add(Vbox)
		window:show_all()
	end
	
	local function RemoveState()
		local window    = gtk.Window.new()
		window:set('title', "Remove ECState ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local remECS    	 = gtk.Button.new_with_label('Remove ECState')
	    local nCombo         = gtk.ComboBoxText.new()
		local nLabel         = gtk.Label.new('Name')
		local tam
		local function fill()
			tam = 0
			for i, v in pairs(self.Struct._FunctionBlock.stlist) do
				if i ~= 'START' then
					nCombo:append_text(i)
					tam = tam + 1
				end
			end
		end
		
		local function rem_state()
			local name = nCombo:get_active_text()
			if name and name ~= '' then
				self.Struct._FunctionBlock.STdx[name]              = nil
				self.Struct._FunctionBlock.STdy[name]              = nil
				self.Struct._FunctionBlock.stlist[name].transition = nil
				self.Struct._FunctionBlock.stlist[name].action 	   = nil
				self.Struct._FunctionBlock.stlist[name] 		   = nil
				local list_remove 								   = {}
				for i , v in ipairs(self.Struct._FunctionBlock.transitions) do
					if v.Source == name or v.Destination == name then
						list_remove[#list_remove+1] = i;
					end
				end
				
				for i , v in ipairs(list_remove) do
					for j = v, #self.Struct._FunctionBlock.transitions - 1 do
						self.Struct._FunctionBlock.transitions[j] = self.Struct._FunctionBlock.transitions[j+1]
					end
					self.Struct._FunctionBlock.transitions[#self.Struct._FunctionBlock.transitions] = nil
					
					if i < #list_remove then
						list_remove[i+1] = list_remove[i+1] - 1
					end
				end
			end	
			for i = 1, tam do
				nCombo:remove(0)
			end
			
			refresh()
			fill()
			
		end
		
		remECS:connect('clicked', rem_state)
		fill()
		Vbox:add(nLabel, nCombo, remECS)
		window:add(Vbox)
		window:show_all()
		refresh()
	end
	
	local function EditState()
		local window    = gtk.Window.new()
		window:set('title', "Add ECState ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local addaction  	 = gtk.Button.new_with_label('Add Action')
		local removeaction   = gtk.Button.new_with_label('Remove Action')
	    local nCombo         = gtk.ComboBoxText.new()
		local nLabel         = gtk.Label.new('Name')
		
		local function add_action()
			local state = nCombo:get_active_text()
			if not state or state == '' then return end
			local window2   = gtk.Window.new()
			window2:set('title', "Add Action ", 'window-position', gtk.WIN_POS_CENTER)
			window2:set('default-width', 0, 'default-height', 0)
			local Hbox11    = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL )
			local Vbox11    = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
			local Vbox22    = gtk.Box.new( gtk.ORIENTATION_VERTICAL )	
			local finish    = gtk.Button.new_with_label('Finish')
			local action    = gtk.Button.new_with_label('Add Action')
			local algCombo  = gtk.ComboBoxText.new()
			local outCombo  = gtk.ComboBoxText.new()
			local algLabel  = gtk.Label.new('Algorithm')
			local outLabel  = gtk.Label.new('Output')
			for i, v in ipairs( self.Struct._FunctionBlock._algs ) do
				algCombo:append_text(v)
			end
			for i, v in ipairs( self.Struct._FunctionBlock.outeventlist ) do
				outCombo:append_text(v)
			end
			
			local function new_action()
				local alg = algCombo:get_active_text()
				local out = outCombo:get_active_text()
				tam       = #self.Struct._FunctionBlock.stlist[state].action
				self.Struct._FunctionBlock.stlist[state].action[tam+1] 	   = {}
				self.Struct._FunctionBlock.stlist[state].action[tam+1].alg = alg
				self.Struct._FunctionBlock.stlist[state].action[tam+1].out = out
				refresh()
			end
			
			local function close()
				refresh()
				window2:hide()
			end
			
			action:connect('clicked', new_action)
			finish:connect('clicked', close)
			Vbox11:add(algLabel, algCombo, action)
			Vbox22:add(outLabel, outCombo, finish)
			Hbox11:add(Vbox11, Vbox22)
			window2:add(Hbox11)
			window2:show_all()
		end
		
		local function remove_action()
			local name = nCombo:get_active_text()
			if name == '' or not name then return end
			local window2   = gtk.Window.new()
			window2:set('title', "Remove Action ", 'window-position', gtk.WIN_POS_CENTER)
			window2:set('default-width', 0, 'default-height', 0)
			local Vbox11    = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
			local finish    = gtk.Button.new_with_label('Finish')
			local remova    = gtk.Button.new_with_label('Remove Action')
			local actlabel  = gtk.Label.new('Action')
			local actcombo  = gtk.ComboBoxText.new()
			for i, v in ipairs(self.Struct._FunctionBlock.stlist[name].action) do
				actcombo:append_text('#'..i..': Alg='..(v.alg or '')..' Output: '..(v.out or ''))
			end
			
			local function f_remova()
				for i, v in ipairs(self.Struct._FunctionBlock.stlist[name].action) do
					if '#'..i..': Alg='..v.alg or ''..'   Output: '..v.out or '' == actcombo:get_active_text() then
						local pos = i
						for j = pos, #self.Struct._FunctionBlock.stlist[name].action -1 do
							self.Struct._FunctionBlock.stlist[name].action[j] = self.Struct._FunctionBlock.stlist[name].action[j+1]
						end
						self.Struct._FunctionBlock.stlist[name].action[#self.Struct._FunctionBlock.stlist[name].action] = nil
						break
					end
				end
				refresh()
			end
			
			local function f_finish()
				window2:hide()
			end
			
			remova:connect('clicked', f_remova)
			finish:connect('clicked', f_finish)
			Vbox11:add(actlabel, actcombo, remova, finish)
			window2:add(Vbox11)
			window2:show_all()
			
		end
		
		for i, v in pairs(self.Struct._FunctionBlock.stlist) do
			if i ~= 'START' then
				nCombo:append_text(i)
			end
		end
		
		addaction:connect('clicked', add_action)
		removeaction:connect('clicked', remove_action)
		Vbox:add(nLabel, nCombo, addaction, removeaction)
		window:add(Vbox)
		window:show_all()
	end
	
	local function AddTransition()
		local window    = gtk.Window.new()
		window:set('title', "Add Transition ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox1      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox2      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox3      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Hbox      	 = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL )
		local add	    	 = gtk.Button.new_with_label('Add Transition')
	    local ComboS         = gtk.ComboBoxText.new()
		local ComboD         = gtk.ComboBoxText.new()
		local EntryC         = gtk.Entry.new()
		local LabelS         = gtk.Label.new('Source')
		local LabelD         = gtk.Label.new('Destination')
		local LabelC         = gtk.Label.new('Condition')
		
		for i, v in pairs(self.Struct._FunctionBlock.stlist) do
			ComboS:append_text(i)
			ComboD:append_text(i)
		end
		
		function f_add()
			local source, dest = ComboS:get_active_text(), ComboD:get_active_text()
			local condition    = EntryC:get('text')
			if not source or not dest or not condition or source == '' or dest == '' or condition == '' then return end
			self.Struct._FunctionBlock.stlist[source].transition[#self.Struct._FunctionBlock.stlist[source].transition+1]           = {}
            self.Struct._FunctionBlock.stlist[source].transition[#self.Struct._FunctionBlock.stlist[source].transition].Condition   = condition
            self.Struct._FunctionBlock.stlist[source].transition[#self.Struct._FunctionBlock.stlist[source].transition].Destination = dest
            self.Struct._FunctionBlock.transitions[#self.Struct._FunctionBlock.transitions+1] = {
				Source 	    = source,
				Destination = dest,
				Condition   = condition
            }
			refresh()
		end
		
		add:connect('clicked', f_add)
		Vbox1:add(LabelS, ComboS)
		Vbox2:add(LabelD, ComboD)
		Vbox3:add(LabelC, EntryC)
		Hbox:add(Vbox1, Vbox2, Vbox3)
		Vbox:add(Hbox, add)
		window:add(Vbox)
		window:show_all()
	end
	
	local function RemoveTransition()
		local window    = gtk.Window.new()
		window:set('title', "Remove Transition ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      	 = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local combo          = gtk.ComboBoxText.new()
		local remov          = gtk.Button.new_with_label('Remove Transition')
		local label          = gtk.Label.new('Transition')
		
		local function fill()
			for i, v in ipairs(self.Struct._FunctionBlock.transitions) do
				combo:append_text(v.Source..' to '..v.Destination..' Cond. = '..v.Condition)
			end
		end
		
		local function f_remove()
			local tr = combo:get_active_text()
			if not tr or tr == '' then return end
			local pos
			for i, v in ipairs(self.Struct._FunctionBlock.transitions) do
				if v.Source..' to '..v.Destination..' Cond. = '..v.Condition == tr then
					combo:remove(0)
					pos = i
					break
				end
			end
			for i = pos, #self.Struct._FunctionBlock.transitions - 1 do
				combo:remove(0)
				self.Struct._FunctionBlock.transitions[i] = self.Struct._FunctionBlock.transitions[i+1]
			end
			self.Struct._FunctionBlock.transitions[#self.Struct._FunctionBlock.transitions] = nil
			refresh()
			fill()
		end
		
		remov:connect('clicked', f_remove)
		fill()
		Vbox:add(label, combo, remov)
		window:add(Vbox)
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
					refresh()
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
				refresh()
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
	
	local function AddAlgorithm()
		local window = gtk.Window.new()
		window:set('title', "Add Algorithm ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local nEntry    = gtk.Entry.new()
		local add       = gtk.Button.new_with_label('Add Algorithm')
		local nLabel    = gtk.Label.new('Alg. Name')
		local done      = gtk.Button.new_with_label('Quit')
		local function f_add()
			local name = nEntry:get('text')
			if  not name or name == '' then return end 
			self.Struct._FunctionBlock._algs[#self.Struct._FunctionBlock._algs+1] = name
			local window2 = gtk.Window.new()
			window2:set( 'title', "Add Algorithm ", 'window-position', gtk.WIN_POS_CENTER )
			window2:set('default-width', 200, 'default-height', 400 )
			local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
			local scroll = gtk.ScrolledWindow.new()
			scroll:set('hscrollbar-policy', gtk.POLICY_AUTOMATIC, 'vscrollbar-policy', gtk.POLICY_AUTOMATIC)
			local txt 	 = gtk.TextView.new()
			local buffer = txt:get('buffer') 
			
			local okay   = gtk.Button.new_with_label('Add Algorithm')
			
			local function f_okay()
				local s_iter = gtk.TextIter.new()
				local e_iter = gtk.TextIter.new()
				buffer:get_start_iter(s_iter)
				buffer:get_end_iter(e_iter)
				self.Struct._FunctionBlock.FW_Alg[name] = buffer:get_text(s_iter, e_iter)
				nEntry:set('text', '')
				window2:hide()
				refresh()
			end
			
			okay:connect('clicked', f_okay)
			scroll:add(txt)
			Vbox:pack_start(scroll, true, true, 0)
			Vbox:pack_start(okay, false, false, 0)
			window2:add(Vbox)
			window2:show_all()
			
		end
		
		local function f_finish()
			window:hide()
		end
		
		
		add:connect('clicked', f_add)
		done:connect('clicked', f_finish)
		Vbox:add(nLabel, nEntry, add, done)
		window:add(Vbox)
		window:show_all()
	end
	
	local function RemoveAlgorithm()	
		local window    = gtk.Window.new()
		window:set('title', "Remove Algorithm ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local nCombo    = gtk.ComboBoxText.new()
		local remova    = gtk.Button.new_with_label('Remove Algorithm')
		local nLabel    = gtk.Label.new('Alg. Name')
		local done      = gtk.Button.new_with_label('Quit')
		
		local function fill()
			for i, v in ipairs(self.Struct._algs) do
				nCombo:append_text(v)
			end
		end
		
		local function f_remova()
			local name = nCombo:get_active_text()
			if not name or name =='' then return end
			local tam = #self.Struct._FunctionBlock._algs
			for i, v in ipairs(self.Struct._FunctionBlock._algs) do
				local pos
				if name == v then
					pos = i				
					for j = pos, tam - 1 do
						self.Struct._FunctionBlock._algs[j] = self.Struct._FunctionBlock._algs[j+1]
					end
					self.Struct._FunctionBlock._algs[tam] = nil
					break
				end
			end
			self.Struct._FunctionBlock.FW_Alg[name] = nil
			for i = 1 , tam do
				nCombo:remove(0)
			end
			for i, v in pairs(self.Struct._FunctionBlock.stlist) do
				for j, k in ipairs(v.action) do
					if k.alg == name then
						k.alg = nil
					end
				end
			end
			
			refresh()
			fill()
		end
		
		local function f_done()
			window:hide()
		end
		
		remova:connect('clicked', f_remova)
		done:connect('clicked', f_done)
		Vbox:add(nLabel, nCombo, remova, done)
		window:add(Vbox)
		fill()
		window:show_all()
		
	end
	
	local function EditAlgorithm()
		local window = gtk.Window.new()
		window:set('title', "Edit Algorithm ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local nCombo    = gtk.ComboBoxText.new()
		local add       = gtk.Button.new_with_label('Edit Algorithm')
		local nLabel    = gtk.Label.new('Alg. Name')
		local done      = gtk.Button.new_with_label('Quit')
		local function f_add()
			local name = nCombo:get_active_text()
			if  not name or name == '' then return end 
			local window2 = gtk.Window.new()
			window2:set( 'title', "Edit Algorithm ", 'window-position', gtk.WIN_POS_CENTER )
			window2:set('default-width', 400, 'default-height', 400 )
			local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
			local scroll = gtk.ScrolledWindow.new()
			scroll:set('hscrollbar-policy', gtk.POLICY_AUTOMATIC, 'vscrollbar-policy', gtk.POLICY_AUTOMATIC)
			local txt 	 = gtk.TextView.new()
			local buffer = txt:get('buffer') 
			buffer:set( 'text',  self.Struct._FunctionBlock.FW_Alg[name])
			local okay   = gtk.Button.new_with_label('Update Algorithm')
			
			local function f_okay()
				local s_iter = gtk.TextIter.new()
				local e_iter = gtk.TextIter.new()
				buffer:get_start_iter(s_iter)
				buffer:get_end_iter(e_iter)
				self.Struct._FunctionBlock.FW_Alg[name] = buffer:get_text(s_iter, e_iter)
				window2:hide()
				refresh()
			end
			
			okay:connect('clicked', f_okay)
			scroll:add(txt)
			Vbox:pack_start(scroll, true, true, 0)
			Vbox:pack_start(okay, false, false, 0)
			window2:add(Vbox)
			window2:show_all()
			
		end
		for i, v in ipairs(self.Struct._FunctionBlock._algs) do
			nCombo:append_text(v)
		end
		local function f_finish()
			window:hide()
		end
		
		
		add:connect('clicked', f_add)
		done:connect('clicked', f_finish)
		Vbox:add(nLabel, nCombo, add, done)
		window:add(Vbox)
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
			refresh()
			window:hide()
		end
		
		apply:connect('clicked', f_apply)
		window:add(Vbox)
		window:show_all()
	end
	
	--loading Basic Function Block .xml Template
	ApStructs		       = nil ApStructs = {}
	click_flag 			   = false
	self.Drawing_Area:queue_draw()
	--Boxes to keep the buttons
	self.AddRemoveBox	   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	self.HeaderBox	       = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	--Labels----------------------------------------------------------------------------------
	self.AddLabel          = gtk.Label.new('Add I/O')                             --Labels
	self.RemoveLabel       = gtk.Label.new('Remove I/O')					      
	self.ECCLabel          = gtk.Label.new('ECC')								  
	self.TransitionsLabel  = gtk.Label.new('Transitions')								  
	self.AlgLabel          = gtk.Label.new('Algorithm')							  
	self.HeaderLabel       = gtk.Label.new('Header')							  
	self.WithVarLabel      = gtk.Label.new('WithVar')							  
	
	--Entrys-----------------------------------------------------------------------------------
	
	--Buttons----------------------------------------------------------------------------------
	self.AddEvent          = gtk.Button.new_with_label('Add <Event>'		)     --ADD I/O
	self.AddVar  	       = gtk.Button.new_with_label('Add <Var>'			)     --
	self.RemoveEvent  	   = gtk.Button.new_with_label('Remove <Event>'     )     --REMOVE I/O
	self.RemoveVar	       = gtk.Button.new_with_label('Remove <Var>'       )  	  --
	self.AddWithVar        = gtk.Button.new_with_label('Add <With Var>'	    )
	self.RemoveWithVar     = gtk.Button.new_with_label('Remove <With Var>'  )
	self.AddState          = gtk.Button.new_with_label('Add <ECState>'	    )     --ECC
	self.RemoveState       = gtk.Button.new_with_label('Remove <ECState>'   )	  --
	self.EditState         = gtk.Button.new_with_label('Edit <ECState>'     )	  --
	self.AddTransition     = gtk.Button.new_with_label('Add <Transition>'   )	  --
	self.RemoveTransition  = gtk.Button.new_with_label('Remove <Transition>')	  --
	self.AddAlgorithm      = gtk.Button.new_with_label('Add <Algorithm>'	)     --ALGORITHM
	self.RemoveAlgorithm   = gtk.Button.new_with_label('Remove <Algorithm>' )	  --
	self.EditAlgorithm     = gtk.Button.new_with_label('Edit <Algorithm>'   )	  --
	self.HeaderButton      = gtk.Button.new_with_label('Edit <Header>'	    )     --HEADER
	
	
	--Connecting Buttons to Functions--------------------------------------------------------
	self.HeaderButton:connect(       'clicked', Header			    ) 
	self.AddEvent:connect(      	 'clicked', AddIO,   'Event' 	)               --I/O
	self.AddVar:connect(        	 'clicked', AddIO,   'Variable' )		
	self.RemoveEvent:connect(   	 'clicked', RemoveIO,'Event' 	)
	self.RemoveVar:connect(     	 'clicked', RemoveIO,'Variable'	)
	self.AddWithVar:connect(		 'clicked', AddWithVar		    )   
	self.RemoveWithVar:connect(		 'clicked', RemoveWithVar   	)
	self.AddState:connect(           'clicked', AddState            )              --ECC
	self.RemoveState:connect(        'clicked', RemoveState         )             
	self.EditState:connect(          'clicked', EditState	        )             
	self.AddTransition:connect(      'clicked', AddTransition       )              
	self.RemoveTransition:connect(   'clicked', RemoveTransition    )              
	self.AddAlgorithm:connect(       'clicked', AddAlgorithm        )              --ALGORITHM
	self.RemoveAlgorithm:connect(    'clicked', RemoveAlgorithm     )
	self.EditAlgorithm:connect(      'clicked', EditAlgorithm       )
	--Packing--------------------------------------------------------------------------------
	self.HeaderBox:pack_start(    self.HeaderLabel,         false, false, 2)  		 --HEADER_LABEL
  	self.HeaderBox:pack_start(    self.HeaderButton ,       false, false, 0)  		 --button
	self.HeaderBox:pack_start(    self.AddLabel,            false, false, 2)  		 --ADD_LABEL
  	self.HeaderBox:pack_start(    self.AddEvent,       	    false, false, 0)  		 --button
	self.HeaderBox:pack_start( 	  self.AddVar,              false, false, 0)  		 --button
	self.HeaderBox:pack_start(    self.RemoveLabel,         false, false, 2)  		 --REMOVE_LABEL
	self.HeaderBox:pack_start(    self.RemoveEvent,         false, false, 0)  		 --button
	self.HeaderBox:pack_start(    self.RemoveVar,	        false, false, 0)  		 --button
	self.HeaderBox:pack_start(    self.WithVarLabel,        false, false, 0)  		 --WITH VAR LABEL
	self.HeaderBox:pack_start(    self.AddWithVar,          false, false, 0)  		 --button
	self.HeaderBox:pack_start(    self.RemoveWithVar,       false, false, 0)  		 --button
	self.HeaderBox:pack_start(    self.AlgLabel,  	  	    false, false, 2)  		 --ALGORITHM_LABEL
	self.HeaderBox:pack_start(    self.AddAlgorithm,    	false, false, 0)  		 --button
	self.HeaderBox:pack_start(    self.RemoveAlgorithm,     false, false, 0)  		 --button
	self.HeaderBox:pack_start(    self.EditAlgorithm,     	false, false, 0)  		 --button
	self.HeaderBox:pack_start(	  self.ECCLabel,  	        false, false, 2)  		 --ECC_LABEL
	self.HeaderBox:pack_start(	  self.AddState,  		    false, false, 0)  		 --button
	self.HeaderBox:pack_start(	  self.RemoveState, 	    false, false, 0)  		 --button
	self.HeaderBox:pack_start(	  self.EditState,    	    false, false, 0)  		 --button
	self.HeaderBox:pack_start(	  self.TransitionsLabel,    false, false, 0)  		 --TRANSITIONS
	self.HeaderBox:pack_start(	  self.AddTransition,       false, false, 0)  		 --button
	self.HeaderBox:pack_start(    self.RemoveTransition,    false, false, 0)  		 --button
	self.EditBox:pack_start(      self.HeaderBox,           false, false, 0)         --HeaderBox 
end

function EditBasicFB(self , new )
	if self._IsEditModeBasic then return end
	self._IsEditMode 	   = true
	self._IsEditModeBasic  = true
	self._IsEditModeComp   = false
	self._IsEditModeSIFB   = false
	self._IsEditModeRes    = false
	self._IsEditModeDev    = false
	self._IsEditModeDevice = false
	self.ScrollBox:pack_start(	     self.EditBox,          false, false, 0)  		 --EditBox
	if new then
		ApStructs   = nil
		ApStructs   = {}
		self.Struct = BlockView.new(FB.importXML ('', 'TEMPLATE_BASICFB.xml', "FunctionBlock"))
		self.CurrentStructEntry:set( 'text' , self.Struct._FunctionBlock.FBType )
		self._File  = 'TEMPLATE_BASICFB.xml'
	end
	--Reset Window-------------------------------------------------------------------------	
	--self.Main_Window:hide()
	self.Main_Window:show_all()
	
end
