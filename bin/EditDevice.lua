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

function EditDevice_Initialize(self)
	--auxiliar function
	local split = function ( str )
		local _,_,str1,str2 = str:find('(.+)%.(.+)')
		return str1, str2
	end
	--reload Device with new settings
	function refresh_Device()
		ApStructs   		 = nil
		ApStructs   		 = {}
		local dt 		     = F.Struct.DrawType 
		F.Struct 		     = DeviceView.new(F.Struct._FunctionBlock, F.Struct.ORIGEM)
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
		local nlabel    = gtk.Label.new('Device Name')
		local clabel    = gtk.Label.new('Comment')
		local alabel    = gtk.Label.new('Author')
		local dlabel    = gtk.Label.new('Date')
		local nEntry    = gtk.Entry.new()
		local cEntry    = gtk.Entry.new()
		local aEntry    = gtk.Entry.new()
		local dEntry    = gtk.Entry.new()
		local apply     = gtk.Button.new_with_label('Apply')
		nEntry:set('text', self.Struct._FunctionBlock.FBType)
		cEntry:set('text', self.Struct._FunctionBlock.other.Comment['Device'] or '')
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
				self.Struct._FunctionBlock.DeviceType = nEntry:get('text')
				self.Struct._FunctionBlock.other.Version[1] = {
					Author       = aEntry:get('text'),
					Date         = dEntry:get('text') 
				}
				self.Struct._FunctionBlock.other.Comment['FBType'] = cEntry:get('text')
				self.Struct._FunctionBlock.DeviceTypeComment     = cEntry:get('text') 
			end
			refresh_Device()
			window:hide()
		end
		
		apply:connect('clicked', f_apply)
		window:add(Vbox)
		window:show_all()
	end
	
	local function AddRes() 
		local name
		local window = gtk.Window.new()
		window:set('title', "Add Resource", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local nlabel = gtk.Label.new('Resource Instance Name')
		local nEntry = gtk.Entry.new()
		local add    = gtk.Button.new_with_label('Add Resource')
		
		local function f_add()
			local name = nEntry:get('text')
			if not name or name =='' then return end
			local open_dialog = gtk.FileChooserDialog.new('Load Resource', self.Main_Window, gtk.FILE_CHOOSER_ACTION_OPEN, 'gtk-close', 
															gtk.RESPONSE_CLOSE, 'gtk-open', gtk.RESPONSE_OK)
			open_dialog:set_current_folder(self.Library)
			if (open_dialog:run() == gtk.RESPONSE_OK) then
				local file
				file 		= open_dialog:get_filenames()
				file        = file[1]
				file 		= select( 3, file:find( ".-([^%/]*)$"  ) )
				self.Struct._FunctionBlock[name]    		          		= Resource.importXML (self.Library..'\\',file, name)
				self.Struct._FunctionBlock[name].Upper 			  	     	= self.Struct._FunctionBlock
				self.Struct._FunctionBlock[name].dx 	  			  		= 200
				self.Struct._FunctionBlock[name].dy 	  			  		= 200
				self.Struct._FunctionBlock.ResourceList[#self.Struct._FunctionBlock.ResourceList + 1] = {
					self.Struct._FunctionBlock[name], 200, 200}
				
				self.Struct._FunctionBlock.FBNetwork[#self.Struct._FunctionBlock.FBNetwork+1] = {name , 200,  200,
					Name = name,
					x    = 200,
					y    = 200,
					Type = self.Struct._FunctionBlock[name].ResourceType
				}
				
				window:hide()
			end
			nEntry:set('text', '')
			open_dialog:hide()
			refresh_Device()
		end
		
		local function f_done()
			window:hide()
		end
		
		
		add:connect('clicked', f_add)
		Vbox:add(nlabel, nEntry, add)
		window:add(Vbox)
		window:show_all()
	
	end
	
	local function RemoveRes() 
		local window = gtk.Window.new()
		window:set('title', "Remove Resource", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local nLabel = gtk.Label.new('Resource Instance Name')
		local nCombo = gtk.ComboBoxText.new()
		local removb = gtk.Button.new_with_label('Remove Resource')
		
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
			
			for i, v in ipairs(self.Struct._FunctionBlock.ResourceList) do
				if v[1].label == name then
					self.Struct._FunctionBlock.ResourceList = list_remove_pos(self.Struct._FunctionBlock.ResourceList, i)
					break
				end
			end
			
			refresh_Device()
			fill()
			window:hide()
		end
		fill()
		removb:connect('clicked', f_remove)
		Vbox:add(nLabel, nCombo, removb)
		window:add(Vbox)
		window:show_all()
	end
	
	local function AddParam()
		local window = gtk.Window.new()
		window:set('title', "Add Parameter", 'window-position', gtk.WIN_POS_CENTER)
		window:set('default-width', 0, 'default-height', 0)
		local Vbox        = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Hbox        = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
		local Vbox1       = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox2       = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local Vbox3       = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
		local resLabel    = gtk.Label.new('Resource Instance')
		local resCombo    = gtk.ComboBoxText.new()
		local resButton   = gtk.Button.new_with_label('Select Resource')
		
		for i, v in ipairs(self.Struct._FunctionBlock.FBNetwork) do
			resCombo:append_text(v[1])
		end
		
		local function f_select_res()
			for i = 1, tam do
				varCombo:remove(0)
			end
			tam = 0
			local name = fbCombo:get_active_text()
			if not name or name == '' then return end
			for i, v in ipairs(self.Struct._FunctionBlock[name].FBNetwork) do
				varCombo:append_text(v[1])
				tam = tam + 1
			end
			--for i, v in ipairs(self.Struct._FunctionBlock[name].outvarlist) do
				--varCombo:append_text(v)
				--tam = tam + 1
			--end
		end
		
		local function f_add(set_all)
		end
		
		resButton:connect('clicked', selectRes)
		
		Vbox:add(resLabel, resCombo, resButton)
		window:add(Vbox)
		window:show_all()
		
	end
	
	local function RemoveParam()
	end

	--loading Device .xml Template
	ApStructs		       = nil ApStructs = {}
	click_flag 			   = false
	self.Drawing_Area:queue_draw()
	--Boxes to keep the buttons
	self.DAddRemoveBox	   = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	self.DHeaderBox	       = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
	--Labels----------------------------------------------------------------------------------
	self.DHeaderLabel      = gtk.Label.new('Header')							    
	self.DResNetLabel      = gtk.Label.new('Resources')							  

	
	--Buttons---------------------------------------------------------------------------------
	self.DAddRes            = gtk.Button.new_with_label('Add <Res>'          )
	self.DRemoveRes         = gtk.Button.new_with_label('Remove <Res>'       )
	self.DHeaderButton      = gtk.Button.new_with_label('Edit <Header>'	     )     --HEADER
	self.DAddParamButton    = gtk.Button.new_with_label('Add <Parameter>'    )     --HEADER
	self.DRemoveParamButton = gtk.Button.new_with_label('Remove <Parameter>' )     --HEADER
	
	--Connecting Buttons to Functions--------------------------------------------------------
	self.DHeaderButton:connect(         'clicked', Header	   ) 
	self.DAddRes:connect(			    'clicked', AddRes	   )
	self.DRemoveRes:connect(			'clicked', RemoveRes   )
	self.DAddParamButton:connect(    	'clicked', AddParam    )
	self.DRemoveParamButton:connect(  	'clicked', RemoveParam )
	
	--Packing--------------------------------------------------------------------------------
	self.DHeaderBox:pack_start(    self.DHeaderLabel,           false, false, 5)  		 --HEADER_LABEL
  	self.DHeaderBox:pack_start(    self.DHeaderButton,          false, false, 0)  		 --button
	self.DHeaderBox:pack_start(    self.DResNetLabel,	        false, false, 0)  		 --Resources Label
	self.DHeaderBox:pack_start(    self.DAddRes,   		        false, false, 0)  		 --button
	self.DHeaderBox:pack_start(    self.DRemoveRes,    	        false, false, 0)  		 --button
	self.DHeaderBox:pack_start(    self.DAddParamButton,        false, false, 0)  		 --button
	self.DHeaderBox:pack_start(    self.DRemoveParamButton,     false, false, 0)  		 --button
	self.EditBoxDev:pack_start(    self.DHeaderBox,             false, false, 0)         --HeaderBox 
end

function EditDevice(self , new )
	if self._IsEditModeComp then return end
	self._IsEditMode 	   = true
	self._IsEditModeDev    = true
	self._IsEditModeRes    = false
	self._IsEditModeComp   = false
	self._IsEditModeBasic  = false
	self._IsEditModeSIFB   = false
	self._IsEditModeSys = false
	self.ScrollBox:pack_start(	     self.EditBoxDev,       false, false, 0)  		 --EditBoxDev
	if new then
		ApStructs   = nil
		ApStructs   = {}
		self.Struct = DeviceView.new(Device.importXML ('', 'TEMPLATE_DEVICE.xml', "Device"))
		self.CurrentStructEntry:set( 'text' , self.Struct._FunctionBlock.FBType )
		self._File  = 'TEMPLATE_DEVICE.xml'
	end
	--Reset Window-------------------------------------------------------------------------	
	--self.Main_Window:hide()
	self.Main_Window:show_all()
	
end
