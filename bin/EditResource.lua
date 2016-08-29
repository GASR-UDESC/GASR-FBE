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

function EditResource_Initialize(self)
	--auxiliar function
	local split = function ( str )
		local _,_,str1,str2 = str:find('(.+)%.(.+)')
		return str1, str2
	end
	--reload resource with new settings
	function refresh_resource()
		ApStructs   		 = nil
		ApStructs   		 = {}
		local dt 		     = F.Struct.DrawType 
		F.Struct 		     = ResourceView.new(F.Struct._FunctionBlock, F.Struct.ORIGEM)
		if dt == 'open' then
			F.Struct.CORPO.CLICKED  = true
			F.Struct:get_clicked(F.Drawing_Area, F.Struct.ORIGEM[1]*N, F.Struct.ORIGEM[2]*N)
		end
		F.Drawing_Area:queue_draw()
	end
	
	--callback functions-----------------------------------------------------------------------
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
		local nlabel    = gtk.Label.new('Resource Name')
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
				self.Struct._FunctionBlock.ResourceType = nEntry:get('text')
				self.Struct._FunctionBlock.other.Version[1] = {
					Author       = aEntry:get('text'),
					Date         = dEntry:get('text') 
				}
				self.Struct._FunctionBlock.other.Comment['FBType'] = cEntry:get('text')
				self.Struct._FunctionBlock.ResourceTypeComment     = cEntry:get('text') 
			end
			refresh_resource()
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
				for i, v in ipairs(self.Struct._FunctionBlock._varlist) do
					svarCombo:append_text(v)
				end
				o_tam = #self.Struct._FunctionBlock._varlist
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
			refresh_resource()
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
			refresh_resource()
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
			refresh_resource()
			
			
		end
		
		local function f_var()
			local str = varCombo:get_active_text()
			if not str or str == '' then return end
			local source, seve, dest, desteve, a, b, c
			a, b, source, seve, c, dest, desteve = str:find('(.+)%.(.+)%s(.+)%s(.+)%.(.+)')
			self.Struct._FunctionBlock.DataConnections[dest][desteve] = nil
			fill(true, false)
			refresh_resource()
			
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
					self.Struct._FunctionBlock[name].Upper 			  	     	= self.Struct._FunctionBlock
					self.Struct._FunctionBlock[name].dx 	  			  		= 200
					self.Struct._FunctionBlock[name].dy 	  			  		= 200
					self.Struct._FunctionBlock.FBNetwork[#self.Struct._FunctionBlock.FBNetwork+1] = {name,200, 200,
							Name = name,
				            x    = 200,
						    y    = 200,
						    Type = self.Struct._FunctionBlock[name].FBType
					}
					window:hide()
				end
			end
			nEntry:set('text', '')
			open_dialog:hide()
			refresh_resource()
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
			local continue = true
			while(continue) do
				continue = false
				for i, v in ipairs (self.Struct._FunctionBlock.Parameters) do
					if v[1] == name then
						self.Struct._FunctionBlock.Parameters = list_remove_pos(self.Struct._FunctionBlock.Parameters,i)
						continue = true
						break
					end
				end
			end
			
			
			refresh_resource()
			fill()
			window:hide()
		end
		
		fill()
		removb:connect('clicked', f_remove)
		Vbox:add(nLabel, nCombo, removb)
		window:add(Vbox)
		window:show_all()
	end
	
	function AddParameter(set_all) --if set_all == true, function call from add global param
		local window = gtk.Window.new()
		window:set('title', "Add Parameter", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Hbox      = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
		local Vbox1     = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox2     = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox3     = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local fbLabel   = gtk.Label.new('FB Instance')
		local varLabel  = gtk.Label.new('Parameter/Var')
		local enLabel   = gtk.Label.new('Value')
		local fbCombo   = gtk.ComboBoxText.new()
		local varCombo  = gtk.ComboBoxText.new()
		local valEntry  = gtk.Entry.new()
		local selectfb  = gtk.Button.new_with_label('Select FB')
		local add       = gtk.Button.new_with_label('Add Parameter')
		local tam       = 0
		
		for i, v in ipairs(self.Struct._FunctionBlock.FBNetwork) do
			fbCombo:append_text(v[1])
		end
		
		local function f_select_fb()
			for i = 1, tam do
				varCombo:remove(0)
			end
			tam = 0
			local name = fbCombo:get_active_text()
			if not name or name == '' then return end
			for i, v in ipairs(self.Struct._FunctionBlock[name].invarlist) do
				varCombo:append_text(v)
				tam = tam + 1
			end
			--for i, v in ipairs(self.Struct._FunctionBlock[name].outvarlist) do
				--varCombo:append_text(v)
				--tam = tam + 1
			--end
		end
		
		local function f_add(set_all)
			local name, var, val
			if not set_all then
				name = fbCombo:get_active_text()
				var  = varCombo:get_active_text()
				val  = valEntry:get('text')
			else
				name = set_all[1]
				var  = set_all[2]
				val  = set_all[3]
			end
			if not name or name == '' then return end
			if not var  or var  == '' then return end
			if not val  or val  == '' then return end
			if type(self.Struct._FunctionBlock._Parameters[name]) ~= 'table' then
				self.Struct._FunctionBlock._Parameters[name] = {}
			end
			local to_remove
			for i, v in ipairs(self.Struct._FunctionBlock.Parameters) do
				if v[1] == name and v[2] == var then
					to_remove = i
					break
				end
			end
			if to_remove then
				self.Struct._FunctionBlock.Parameters = list_remove_pos(self.Struct._FunctionBlock.Parameters, to_remove)
			end
			to_remove = nil
			for i, v in ipairs(self.Struct._FunctionBlock._Parameters[name]) do
				if v.Name == var then
					to_remove = i
					break
				end
			end
			if to_remove then
				self.Struct._FunctionBlock._Parameters[name] = list_remove_pos(self.Struct._FunctionBlock._Parameters[name], to_remove)
			end
			self.Struct._FunctionBlock._Parameters[name][#self.Struct._FunctionBlock._Parameters[name]+1] = {
				Name  = var,
				Value = val
			}
			self.Struct._FunctionBlock.Parameters[#self.Struct._FunctionBlock.Parameters+1] = {name, var, val}
			refresh_resource()
			window:destroy()
		end
		
		
		if set_all then
			f_add(set_all)
			return
		end
		
		add:connect('clicked', f_add)
		selectfb:connect('clicked', f_select_fb)
		Vbox1:add(fbLabel, fbCombo)
		Vbox2:add(varLabel, varCombo)
		Vbox3:add(enLabel, valEntry)
		Hbox:add(Vbox1, Vbox2, Vbox3)
		Vbox:add(Hbox, selectfb, add)
		window:add(Vbox)
		window:show_all()
		
	end
	
	local function RemoveParameter()
		local window = gtk.Window.new()
		window:set('title', "Remove Parameter", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox      = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Hbox      = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
		local Vbox1     = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox2     = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local fbLabel   = gtk.Label.new('FB Instance')
		local varLabel  = gtk.Label.new('Parameter/Var')
		local fbCombo   = gtk.ComboBoxText.new()
		local varCombo  = gtk.ComboBoxText.new()
		
		local selectfb  = gtk.Button.new_with_label('Select FB')
		local removp    = gtk.Button.new_with_label('Remove Parameter')
		local tam       = 0
		
		for i, v in ipairs(self.Struct._FunctionBlock.FBNetwork) do
			fbCombo:append_text(v[1])
		end
		
		local function f_select_fb()
			for i = 1, tam do
				varCombo:remove(0)
			end
			tam = 0
			local name = fbCombo:get_active_text()
			if not name or name == '' then return end
			for i, v in ipairs(self.Struct._FunctionBlock._Parameters[name]) do
				varCombo:append_text(v.Name)
				tam = tam + 1
			end
			--for i, v in ipairs(self.Struct._FunctionBlock[name].outvarlist) do
				--varCombo:append_text(v)
				--tam = tam + 1
			--end
		end
		
		local function f_removp()
			local name = fbCombo:get_active_text()
			local var  = varCombo:get_active_text()
			if not name or name == '' then return end
			if not var  or var  == '' then return end
			local pos
			for i, v in ipairs(self.Struct._FunctionBlock._Parameters[name]) do
				if v.Name == var then
					pos = i
					break
				end
			end
			self.Struct._FunctionBlock._Parameters[name] = list_remove_pos(self.Struct._FunctionBlock._Parameters[name], pos)
			
			
			for i, v in ipairs(self.Struct._FunctionBlock.Parameters) do
				if v[1] == name and v[2] == var then
					pos = i
					break
				end
			end
			self.Struct._FunctionBlock.Parameters = list_remove_pos(self.Struct._FunctionBlock.Parameters, pos)
			refresh_resource()
			f_select_fb()
		end
		
		removp:connect('clicked', f_removp)
		selectfb:connect('clicked', f_select_fb)
		Vbox1:add(fbLabel, fbCombo)
		Vbox2:add(varLabel, varCombo)
		Hbox:add(Vbox1, Vbox2)
		Vbox:add(Hbox, selectfb, removp)
		window:add(Vbox)
		window:show_all()
	end
	
	local function AddVar()
		--widgets
		local window = gtk.Window.new()
		window:set('title', "Add Var", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local array  = gtk.Entry.new()
		local typex  = gtk.Entry.new()
		local initv  = gtk.Entry.new()
		local name   = gtk.Entry.new()
		local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox1  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox3  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox4  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox5  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Hbox1  = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
		local alabel = gtk.Label.new('ArraySize*')
		local tlabel = gtk.Label.new('Type (INT, BOOL..)')
		local nlabel = gtk.Label.new('Name')
		local vlabel = gtk.Label.new('Initial Value*')
		
		local function f_add()
			if (name:get('text') == '') or (name:get('text') == nil) then return end
			local typex  = typex:get('text')
			local arrays = array:get('text')
			local initva = initv:get('text')
			local nome   = name:get('text')
			
			if initva then
				self.Struct._FunctionBlock[ nome ] = string_to_value( initva, arrays,  typex )
			end
			self.Struct._FunctionBlock._varlist[#self.Struct._FunctionBlock._varlist+1] = {
				Name 		 = nome, 
				Type 		 = typex, 
				ArraySize    = arrays, 
				InitialValue = initva,
				Comment      = ''
			}
			name:set('text', '')
			refresh_resource()
		end
		
		local add    = gtk.Button.new_with_label('Add Var')
		add:connect('clicked', f_add)
		
		Vbox1:add(nlabel, name)
		Hbox1:add(Vbox1)
		
		Vbox3:add(tlabel, typex)
		Vbox4:add(alabel, array)
		Vbox5:add(vlabel, initv)
		Hbox1:add(Vbox3, Vbox4, Vbox5)
		Vbox:add(Hbox1, add)
		window:add(Vbox)
		window:show_all()
	end
	
	local function RemoveVar()
		local window = gtk.Window.new()
		window:set('title', "Add Var", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local nLabel  = gtk.Label.new('Var Name')
		local nCombo  = gtk.ComboBoxText.new()
		local rButton = gtk.Button.new_with_label('Remove')
		local Vbox    = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local tam     = 0
		local function fill()
			for i = 1, #self.Struct._FunctionBlock._varlist + 1 do
				nCombo:remove(0)
			end
			tam = 0
			for i, v in ipairs(self.Struct._FunctionBlock._varlist) do
				nCombo:append_text(v.Name)
				tam = tam + 1
			end
		end
		
		local function f_remove()
			local name = nCombo:get_active_text()
			if not name or name == '' then return end
			local pos
			for i, v in ipairs(self.Struct._FunctionBlock._varlist) do
				if v.Name == name then 
					pos = i
					break
				end
			end
			self.Struct._FunctionBlock._varlist = list_remove_pos(self.Struct._FunctionBlock._varlist, pos)
			refresh_resource()
			fill()
		end
		
		fill()
		rButton:connect('clicked', f_remove)
		Vbox:add(nLabel, nCombo, rButton)
		window:add(Vbox)
		window:show_all()
	end
	
	
	--loading Resource .xml Template
	ApStructs		       = nil ApStructs = {}
	click_flag 			   = false
	self.Drawing_Area:queue_draw()
	--Boxes to keep the buttons
	self.RAddRemoveBox	   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	self.RHeaderBox	       = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	--Labels----------------------------------------------------------------------------------
	self.RAddLabel          = gtk.Label.new('Add I/O')                             --Labels
	self.RRemoveLabel       = gtk.Label.new('Remove I/O')					      
	self.RHeaderLabel       = gtk.Label.new('Header')							  
	self.RVarLabel          = gtk.Label.new('ResourceVar')							  
	self.RConnectionLabel   = gtk.Label.new('Connections')							  
	self.RFBNetLabel        = gtk.Label.new('FBNetwork')							  
	self.RParametersLabel   = gtk.Label.new('Parameters')
	
	--Entrys-----------------------------------------------------------------------------------
	
	--Buttons----------------------------------------------------------------------------------
	self.RAddEvent               = gtk.Button.new_with_label('Add <Event>'		     )      --ADD I/O
	self.RAddVar  	             = gtk.Button.new_with_label('Add <Var>'		 	 )      --
	self.RRemoveEvent  	         = gtk.Button.new_with_label('Remove <Event>'       )      --REMOVE I/O
	self.RRemoveVar	             = gtk.Button.new_with_label('Remove <Var>'         )      --
	self.RAddWithVar             = gtk.Button.new_with_label('Add <With Var>'	   	 ) 
	self.RRemoveWithVar          = gtk.Button.new_with_label('Remove <With Var>'    )
	self.RAddVarConnection       = gtk.Button.new_with_label('Add <VarConnection>'  )       
	self.RAddEventConnection     = gtk.Button.new_with_label('Add <EventConnection>')       
	self.RRemoveConnection       = gtk.Button.new_with_label('Remove <Connection>'  )      
	self.RAddFB                  = gtk.Button.new_with_label('Add <FB>'             )
	self.RRemoveFB               = gtk.Button.new_with_label('Remove <FB>'          )
	self.RHeaderButton           = gtk.Button.new_with_label('Edit <Header>'	    )     --HEADER
	self.RAddParameterButton     = gtk.Button.new_with_label('Add <Parameter>'      )
	self.RRemoveParameterButton  = gtk.Button.new_with_label('Remove <Parameter>'   )
	self.RAddVar                 = gtk.Button.new_with_label('Add <Var>'			)
	self.RRemoveVar              = gtk.Button.new_with_label('Remove <Var>'			)
	
	--Connecting Buttons to Functions--------------------------------------------------------
	self.RHeaderButton:connect(         'clicked', Header			    ) 
	self.RAddVarConnection:connect(	    'clicked', AddVarConnection     )
	self.RAddEventConnection:connect(   'clicked', AddEventConnection   )
	self.RRemoveConnection:connect(     'clicked', RemoveConnection     )
	self.RAddFB:connect(			    'clicked', AddFB			    )
	self.RRemoveFB:connect(			    'clicked', RemoveFB			    )
	self.RAddParameterButton:connect(   'clicked', AddParameter         )
	self.RRemoveParameterButton:connect('clicked', RemoveParameter      )
	self.RAddVar:connect(               'clicked', AddVar				)
	self.RRemoveVar:connect(            'clicked', RemoveVar			)
	
	--Packing--------------------------------------------------------------------------------
	self.RHeaderBox:pack_start(    self.RHeaderLabel,           false, false, 5)  		 --HEADER_LABEL
  	self.RHeaderBox:pack_start(    self.RHeaderButton ,         false, false, 0)  		 --button
	self.RHeaderBox:pack_start(    self.RVarLabel,              false, false, 5)  		 --VAR_LABEL
  	self.RHeaderBox:pack_start(    self.RAddVar ,               false, false, 0)  		 --button
	self.RHeaderBox:pack_start(    self.RRemoveVar ,            false, false, 0)  		 --button
	self.RHeaderBox:pack_start(    self.RFBNetLabel,     	    false, false, 0)  		 --FBNETWORK LABEL
	self.RHeaderBox:pack_start(    self.RAddFB,   		        false, false, 0)  		 --button
	self.RHeaderBox:pack_start(    self.RRemoveFB,    	        false, false, 0)  		 --button
	self.RHeaderBox:pack_start(    self.RConnectionLabel,       false, false, 0)  		 --CONNECTION LABEL
	self.RHeaderBox:pack_start(    self.RAddVarConnection,      false, false, 0)  		 --button
	self.RHeaderBox:pack_start(    self.RAddEventConnection,    false, false, 0)  		 --button
	self.RHeaderBox:pack_start(    self.RRemoveConnection,      false, false, 0)  		 --button
	self.RHeaderBox:pack_start(    self.RParametersLabel,       false, false, 0)  		 --PARAMETER LABEL
    self.RHeaderBox:pack_start(    self.RAddParameterButton,    false, false, 0)  		 --button
    self.RHeaderBox:pack_start(    self.RRemoveParameterButton, false, false, 0)  		 --button
	self.EditBoxRes:pack_start(    self.RHeaderBox,             false, false, 0)         --HeaderBox 
end

function EditResource(self , new )
	if self._IsEditModeComp then return end
	self._IsEditMode 	   = true
	self._IsEditModeRes    = true
	self._IsEditModeDev    = false
	self._IsEditModeComp   = false
	self._IsEditModeBasic  = false
	self._IsEditModeSIFB   = false
	self._IsEditModeDevice = false
	self.ScrollBox:pack_start(	     self.EditBoxRes,       false, false, 0)  		 --EditBoxComp
	if new then
		ApStructs   = nil
		ApStructs   = {}
		self.Struct = ResourceView.new(Resource.importXML ('', 'TEMPLATE_RESOURCE.xml', "Resource"))
		self.CurrentStructEntry:set( 'text' , self.Struct._FunctionBlock.FBType )
		self._File  = 'TEMPLATE_RESOURCE.xml'
	end
	--Reset Window-------------------------------------------------------------------------	
	--self.Main_Window:hide()
	self.Main_Window:show_all()
	
end
