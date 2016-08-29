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

function EditSIFB_Initialize(self)
	--callback functions-----------------------------------------------------------------------
	local function refresh()
		ApStructs   		 = nil
		ApStructs   		 = {}
		local dt 		     = self.Struct.DrawType 
		self.Struct 		 = BlockView.new(self.Struct._FunctionBlock, self.Struct.ORIGEM)
		self.Struct.DrawType = dt
		self.Drawing_Area:queue_draw()
	end
	local function list_remove_pos(l, pos)
		if pos > #l then 
			print('List_remove_pos = erro')
			return l
		end
		if #l == 1 then
			l[1] = nil
		else
			for j = pos, #l - 1 do
				l[j] = l[j+1]
			end
			l[#l] = nil
		end
		return l
	end
	
	local function EditBaseFile()
		local window = gtk.Window.new()
		window:set('title', "EditBaseFile", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local file    = self.Struct._FunctionBlock.other.BaseFile
		local filename = file
		local entry   = gtk.Entry.new()
		local label   = gtk.Label.new('File Name')
		entry:set('text', file)
		local ch_name = gtk.Button.new_with_label('Change Name')
		local apply   = gtk.Button.new_with_label('Apply')
		local vbox    = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local txt 	  = gtk.TextView.new()
		local buffer  = txt:get('buffer') 
		file          = io.open(file, 'r')
		local str     = ''
		for l in file:lines() do
			str = str..l..'\n'
		end
		
		file:close()
		buffer:set('text', str)
		
		local function f_apply()
			local s_iter = gtk.TextIter.new()
			local e_iter = gtk.TextIter.new()
			buffer:get_start_iter(s_iter)
			buffer:get_end_iter(e_iter)
			local name = entry:get('text')
			if not name or name == '' then return end
			local a, b, c = name:find('(%.lua)')
			if not c then
				name = name..'.lua'
			end
			local name = self.Struct._FunctionBlock.other.BaseFile
			local basefile = io.open(name, 'w')
			basefile:write(buffer:get_text(s_iter, e_iter))
			basefile:close()
			dofile(name)
		end
		
		local function f_ch_name()
			local name = entry:get('text')
			if not name or name == '' then return end
			local _, _, c = name:find('(%.lua)')
			if not c then
				name = name..'.lua'
			end
			self.Struct._FunctionBlock.other.BaseFile = name
			local _, _, str = name:find('(.+)%.lua')
			local x, y, old_name = filename:find('(.+)%.lua')
			local s_iter = gtk.TextIter.new()
			local e_iter = gtk.TextIter.new()
			buffer:get_start_iter(s_iter)
			buffer:get_end_iter(e_iter)
			local text = buffer:get_text(s_iter, e_iter)
			text = text:gsub(old_name, str)
			buffer:set('text', text)
			local requires = io.open('SI_requires.lua', 'r')
			local r_text  =''
			if old_name ~= str then
				r_text = r_text.."require '"..str.."'\n"
			end
			for l in requires:lines() do
				r_text = r_text..l..'\n'
			end
			filename = name
			requires:close()
			requires = io.open('SI_requires.lua', 'w')
			requires:write(r_text)
			requires:close()
			local name = self.Struct._FunctionBlock.other.BaseFile
			local basefile = io.open(name, 'w')
			buffer:get_start_iter(s_iter)
			buffer:get_end_iter(e_iter)
			basefile:write(buffer:get_text(s_iter, e_iter))
			basefile:close()
		end
		
		vbox:add(label, entry, ch_name)
		vbox:pack_start(txt, true, true, 5)
		vbox:add(apply)
		apply:connect('clicked', f_apply)
		ch_name:connect('clicked', f_ch_name)
		window:add(vbox)
		window:show_all()
			
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
		local Vbox5     = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local nlabel    = gtk.Label.new('FBType Name')
		local blabel    = gtk.Label.new('BaseFile')
		local clabel    = gtk.Label.new('Comment')
		local alabel    = gtk.Label.new('Author')
		local dlabel    = gtk.Label.new('Date')
		local nEntry    = gtk.Entry.new()
		local cEntry    = gtk.Entry.new()
		local aEntry    = gtk.Entry.new()
		local dEntry    = gtk.Entry.new()
		local bCombo    = gtk.ComboBoxText.new()
		local apply     = gtk.Button.new_with_label('Apply')
		nEntry:set('text', self.Struct._FunctionBlock.FBType)
		cEntry:set('text', self.Struct._FunctionBlock.other.Comment['FBType'] or '')
		aEntry:set('text', self.Struct._FunctionBlock._Author or '')
		dEntry:set('text', self.Struct._FunctionBlock._Date or '')
		Vbox1:add(nlabel, nEntry)
		Vbox2:add(clabel, cEntry)
		Vbox3:add(alabel, aEntry)
		Vbox4:add(dlabel, dEntry)
		Vbox5:add(blabel, bCombo)
		Hbox1:add(Vbox1, Vbox2, Vbox3, Vbox4, Vbox5)
		Vbox:add(Hbox1, apply)
		self.Struct._FunctionBlock.other.IsLua = true
		
		for i, v in pairs(SIFB_Class) do
			bCombo:append_text(i)
		end
		local function f_apply()
			local bf = bCombo:get_active_text()
			if not bf or bf == '' then return end
			if nEntry:get('text') ~= '' and nEntry:get('text') then
				self.Struct._FunctionBlock.FBType = nEntry:get('text')
				self.Struct._FunctionBlock.other.Version[1] = {
					Author       = aEntry:get('text'),
					Date         = dEntry:get('text') 
				}
				self.Struct._FunctionBlock.other.Comment['FBType'] = cEntry:get('text')
				local a, b, c = bf:find('(%.lua)')
				if not c then
					self.Struct._FunctionBlock.other.BaseFile = bf..'.lua'
				end
			end
			refresh()
			window:hide()
		end
		apply:connect('clicked', f_apply)
		window:add(Vbox)
		window:show_all()
	end
	
	local function Service()
		local window = gtk.Window.new()
		window:set('title', "Service ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Hbox      = gtk.Box.new( gtk.ORIENTATION_HORIZONTAL )
		local Vbox1     = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local Vbox2     = gtk.Box.new( gtk.ORIENTATION_VERTICAL )
		local rLabel    = gtk.Label.new('RightInterface')    
		local lLabel    = gtk.Label.new('LeftInterface')
		local rEntry    = gtk.Entry.new()
		local lEntry    = gtk.Entry.new()
		local apply     = gtk.Button.new_with_label('Apply')
		rEntry:set('text', self.Struct._FunctionBlock.Service.RightInterface)
		lEntry:set('text', self.Struct._FunctionBlock.Service.LeftInterface)
		
		local function f_apply()
			local right = rEntry:get('text')
			local left  = lEntry:get('text')
			if not right or not left or right == '' or left == '' then return end
			self.Struct._FunctionBlock.Service.RightInterface = right
			self.Struct._FunctionBlock.Service.LeftInterface  = left
			refresh()
			window:hide()
		end
		
		apply:connect('clicked', f_apply)
		Vbox1:add(lLabel, lEntry)
		Vbox2:add(rLabel, rEntry)
		Hbox:add(Vbox1, Vbox2)
		Vbox:add(Hbox, apply)
		window:add(Vbox)
		window:show_all()
	end
	
	local function AddServiceSequence()
		local window = gtk.Window.new()
		window:set('title', "Add Service Sequence ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local nLabel = gtk.Label.new('Name')
		local nEntry = gtk.Entry.new()
		local add    = gtk.Button.new_with_label('Add ServiceSequence')
		local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		
		local function f_add()
			local name = nEntry:get('text')
			if not name or name == '' then return end
		    local acSequence = #self.Struct._FunctionBlock.ServiceSequences + 1
			self.Struct._FunctionBlock.ServiceSequences[acSequence] = {
				Name = name,
				Transactions = {}
            }
			self.Struct._FunctionBlock._SequenceNumber[name] = acSequence
			refresh()
			window:hide()
		end
		add:connect('clicked', f_add)
		Vbox:add(nLabel, nEntry, add)
		window:add(Vbox)
		window:show_all()
		
	end
	
	local function RemoveServiceSequence()
		local window = gtk.Window.new()
		window:set('title', "Remove Service Sequence ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local nLabel = gtk.Label.new('Name')
		local nCombo = gtk.ComboBoxText.new()
		local rem    = gtk.Button.new_with_label('Remove ServiceSequence')
		local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		
		local function fill(remo)
			if remo then
				for i = 1, #self.Struct._FunctionBlock.ServiceSequences + 1 do
					nCombo:remove(0)
				end
			end
			for i , v in ipairs(self.Struct._FunctionBlock.ServiceSequences) do
				nCombo:append_text(v.Name)
			end
		end
		
		
		local function f_rem()
			local name = nCombo:get_active_text()
			if not name or name == '' then return end
		    local pos
			for i , v in ipairs(self.Struct._FunctionBlock.ServiceSequences) do
				if v.Name == name then
					pos = i
					break
				end
			end
			self.Struct._FunctionBlock.ServiceSequences = list_remove_pos(self.Struct._FunctionBlock.ServiceSequences, pos)
			refresh()
			fill(true)
		end
		
		fill(false)
		rem:connect('clicked', f_rem)
		Vbox:add(nLabel, nCombo, rem)
		window:add(Vbox)
		window:show_all()
	end
	
	local function EditServiceSequence()
		local window = gtk.Window.new()
		window:set('title', "Edit Sequence ", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local nLabel 	  = gtk.Label.new('Name')
		local nCombo 	  = gtk.ComboBoxText.new()
		local rem    	  = gtk.Button.new_with_label('Remove ServiceSequence')
		local Vbox        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local cName       = gtk.Button.new_with_label('Change Sequence Name')
		local addTrans    = gtk.Button.new_with_label('Add Transaction')
		local removeTrans = gtk.Button.new_with_label('Remove Transaction')
		
		local function fill(remo)
			if remo then
				for i = 1, #self.Struct._FunctionBlock.ServiceSequences + 1 do
					nCombo:remove(0)
				end
			end
			for i , v in ipairs(self.Struct._FunctionBlock.ServiceSequences) do
				nCombo:append_text(v.Name)
			end
		end
		
		local function f_addTrans()
			local name = nCombo:get_active_text()
			if not name or name == '' then return end
			local window2 = gtk.Window.new()
			window2:set('title', "Add Transaction to Sequence", 'window-position', gtk.WIN_POS_CENTER)
			window2:set('default-width', 0, 'default-height', 0)	
			local Hbox    = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
			local Vbox    = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
			local Vbox1   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
			local Vbox2   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
			local Vbox3   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
			local iplabel = gtk.Label.new('InputPrimitive')
			local oplabel = gtk.Label.new('OutputPrimitive')
			local ilabel  = gtk.Label.new('Interface')
			local elabel  = gtk.Label.new('Event')
			local xlabel  = gtk.Label.new('     ')
			local iientry = gtk.Entry.new()
			local ieentry = gtk.Entry.new()
			local oientry = gtk.Entry.new()
			local oeentry = gtk.Entry.new()
			local add     = gtk.Button.new_with_label('Add Transaction')
			
			local function f_add()
				local in_interface  = iientry:get('text')
				local in_event      = ieentry:get('text')
				local out_interface = oientry:get('text')
				local out_event     = oeentry:get('text')
				if not in_interface or in_inteface == '' then return end
				if not in_event or in_event == '' then return end
				if not out_interface or out_inteface == '' then return end
				if not out_event or out_event == '' then return end
				local acSequence = self.Struct._FunctionBlock._SequenceNumber[name]
				local acTransaction = #self.Struct._FunctionBlock.ServiceSequences[acSequence].Transactions+1
				self.Struct._FunctionBlock.ServiceSequences[acSequence].Transactions[acTransaction] = {}
				self.Struct._FunctionBlock.ServiceSequences[acSequence].Transactions[acTransaction].InputPrimitive = {
					Interface   = in_interface,
					Event       = in_event,
					}
				self.Struct._FunctionBlock.ServiceSequences[acSequence].Transactions[acTransaction].OutputPrimitive = {
					Interface   = out_interface,
					Event       = out_event,
					} 
				refresh()
				window2:hide()
			end			
			
			add:connect('clicked', f_add)
			Vbox1:add(xlabel, iplabel)
			Vbox1:pack_start(oplabel, false, false, 7)
			Vbox2:add(ilabel, iientry, oientry)
			Vbox3:add(elabel, ieentry, oeentry)
			Hbox:add(Vbox1, Vbox2, Vbox3)	
			Vbox:add(Hbox, add)
			window2:add(Vbox)
			window2:show_all()
		end

		local function f_removeTrans()
			local name = nCombo:get_active_text()
			if not name or name == '' then return end
			local window2 = gtk.Window.new()
			window2:set('title', "Remove Transaction", 'window-position', gtk.WIN_POS_CENTER)
			window2:set('default-width', 0, 'default-height', 0)	
			local Vbox       = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
			local nCombo     = gtk.ComboBoxText.new()
			local nLabel     = gtk.Label.new()
			local removet    = gtk.Button.new_with_label('Remove Transaction')
			local acSequence = self.Struct._FunctionBlock._SequenceNumber[name]
			local function fill(remo)
				if remo then
					for i = 1, #self.Struct._FunctionBlock.ServiceSequences[acSequence].Transactions + 1 do
						nCombo:remove(0)
					end
				end
				for i, v in ipairs(self.Struct._FunctionBlock.ServiceSequences[acSequence].Transactions) do
					nCombo:append_text('Input='..v.InputPrimitive.Interface..'.'..v.InputPrimitive.Event..' -> Output='..v.OutputPrimitive.Interface..'.'..v.OutputPrimitive.Event)
				end
			end
			
			local function f_removet()
				local pos
				for i, v in ipairs(self.Struct._FunctionBlock.ServiceSequences[acSequence].Transactions) do
					if 'Input='..v.InputPrimitive.Interface..'.'..v.InputPrimitive.Event..' -> Output='..v.OutputPrimitive.Interface..'.'..v.OutputPrimitive.Event == nCombo:get_active_text() then
						pos = i
						break
					end
				end
				self.Struct._FunctionBlock.ServiceSequences[acSequence].Transactions = list_remove_pos(self.Struct._FunctionBlock.ServiceSequences[acSequence].Transactions, pos)
				refresh()
				fill(true)
				window2:hide()
			end			
		
			fill(false)
			removet:connect('clicked', f_removet)
			Vbox:add(nLabel, nCombo, removet)
			window2:add(Vbox)
			window2:show_all()
		end
		
		fill(false)
		addTrans:connect('clicked', f_addTrans)
		removeTrans:connect('clicked', f_removeTrans)
		Vbox:add(nLabel, nCombo,  addTrans, removeTrans)
		window:add(Vbox)
		window:show_all()
	end
	
	ApStructs		          = nil ApStructs = {}
	click_flag 			      = false
	self.Drawing_Area:queue_draw()
	--Boxes to keep the buttons
	self.SAddRemoveBox	      = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	self.SHeaderBox	          = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	--Labels----------------------------------------------------------------------------------
	self.SAddLabel            = gtk.Label.new('Add I/O')                             --Labels
	self.SRemoveLabel         = gtk.Label.new('Remove I/O')					      	  
	self.SHeaderLabel         = gtk.Label.new('Header')							  
	self.SWithVarLabel        = gtk.Label.new('WithVar')							  
	self.ServiceLabel         = gtk.Label.new('Service')
	
	
	--Buttons----------------------------------------------------------------------------------
	self.SAddEvent            = gtk.Button.new_with_label('Add <Event>'		  )     --ADD I/O
	self.SAddVar  	          = gtk.Button.new_with_label('Add <Var>'		  )     --
	self.SRemoveEvent         = gtk.Button.new_with_label('Remove <Event>'    )     --REMOVE I/O
	self.SRemoveVar	          = gtk.Button.new_with_label('Remove <Var>'      )     --
	self.SAddWithVar          = gtk.Button.new_with_label('Add <With Var>'	  )
	self.SRemoveWithVar       = gtk.Button.new_with_label('Remove <With Var>' )
	self.SHeaderButton        = gtk.Button.new_with_label('Edit <Header>'	  )     --HEADER
	self.ServiceButton        = gtk.Button.new_with_label('Edit <Service>'    )
	self.AddSequenceButton    = gtk.Button.new_with_label('Add <Sequence>'    )
	self.EditSequenceButton   = gtk.Button.new_with_label('Edit <Sequence>'   )
	self.RemoveSequenceButton = gtk.Button.new_with_label('Remove <Sequence>' )
	self.EditBaseFile         = gtk.Button.new_with_label('Edit BaseFile'	  )
	
	--Connecting Buttons to Functions--------------------------------------------------------
	self.SHeaderButton:connect(        'clicked', Header			      ) 
	self.SAddEvent:connect(      	   'clicked', AddIO,   'Event' 	      )
	self.SAddVar:connect(        	   'clicked', AddIO,   'Variable'     )		
	self.SRemoveEvent:connect(   	   'clicked', RemoveIO,'Event' 	      )
	self.SRemoveVar:connect(     	   'clicked', RemoveIO,'Variable'     )
	self.SAddWithVar:connect(		   'clicked', AddWithVar		      )   
	self.SRemoveWithVar:connect(	   'clicked', RemoveWithVar   	      )
	self.ServiceButton:connect(        'clicked', Service                 )
	self.AddSequenceButton:connect(    'clicked', AddServiceSequence      )
	self.RemoveSequenceButton:connect( 'clicked', RemoveServiceSequence	  )
	self.EditSequenceButton:connect(   'clicked', EditServiceSequence	  )
	self.EditBaseFile:connect(         'clicked', EditBaseFile			  )
	--Packing--------------------------------------------------------------------------------
	self.SHeaderBox:pack_start(   self.SHeaderLabel,         false, false, 5)  		 --HEADER_LABEL
  	self.SHeaderBox:pack_start(   self.SHeaderButton ,       false, false, 0)  		 --button
  	self.SHeaderBox:pack_start(   self.EditBaseFile  ,       false, false, 0)  		 --button
	self.SHeaderBox:pack_start(   self.SAddLabel,            false, false, 5)  		 --ADD_LABEL
  	self.SHeaderBox:pack_start(   self.SAddEvent,       	 false, false, 0)        --button
	self.SHeaderBox:pack_start(   self.SAddVar,              false, false, 0)  		 --button
	self.SHeaderBox:pack_start(   self.SRemoveLabel,         false, false, 5)  		 --REMOVE_LABEL
	self.SHeaderBox:pack_start(   self.SRemoveEvent,         false, false, 0)  		 --button
	self.SHeaderBox:pack_start(   self.SRemoveVar,	         false, false, 0)  		 --button
	self.SHeaderBox:pack_start(   self.SWithVarLabel,        false, false, 0)  		 --WITH VAR LABEL
	self.SHeaderBox:pack_start(   self.SAddWithVar,          false, false, 0)  		 --button
	self.SHeaderBox:pack_start(   self.SRemoveWithVar,       false, false, 0)  		 --button
	self.SHeaderBox:pack_start(   self.ServiceLabel,         false, false, 0)  		 --SERVICE_LABEL
	self.SHeaderBox:pack_start(   self.ServiceButton,        false, false, 0)  		 --button
	self.SHeaderBox:pack_start(   self.AddSequenceButton,    false, false, 0)  		 --button
	self.SHeaderBox:pack_start(   self.RemoveSequenceButton, false, false, 0)  		 --button
	self.SHeaderBox:pack_start(   self.EditSequenceButton,   false, false, 0)  		 --button
	self.EditBoxSIFB:pack_start(  self.SHeaderBox,           false, false, 0)        --HeaderBox 
end

function EditSIFB(self , new )
	if self._IsEditModeBasic then return end
	self._IsEditMode 	   = true
	self._IsEditModeSIFB   = true
	self._IsEditModeBasic  = false
	self._IsEditModeComp   = false
	self._IsEditModeDev    = false
	self._IsEditModeRes    = false
	self._IsEditModeDevice = false
	self.ScrollBox:pack_start(	     self.EditBoxSIFB,          false, false, 0)  		 --EditBox
	if new then
		ApStructs   = nil
		ApStructs   = {}
		self.Struct = BlockView.new(FB.importXML ('', 'TEMPLATE_SIFB.xml', "FunctionBlock"))
		self.CurrentStructEntry:set( 'text' , self.Struct._FunctionBlock.FBType )
		self._File  = 'TEMPLATE_BASICFB.xml'
	end
	--Reset Window-------------------------------------------------------------------------	
	--self.Main_Window:hide()
	self.Main_Window:show_all()
	
end

