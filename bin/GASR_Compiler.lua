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

GASR_Compiler         = {}
GASR_Compiler.__index = GASR_Compiler

function GASR_Compiler.Run(self)
    self.Window_Main:show_all()
end

function GASR_Compiler.hide(self)    
    self.Window_Main:hide()
end


function GASR_Compiler.buscar_arquivo(self)
    if (self.exp_arquivo:run() == gtk.RESPONSE_OK) then
        local names = self.exp_arquivo:get_filenames()
        self.entry_arquivo:set('text', names[1])
    end
    self.exp_arquivo:hide()
end

function GASR_Compiler.buscar_destino(self)
    if (self.exp_destino:run() == gtk.RESPONSE_OK) then
        local names = self.exp_destino:get_filenames()
        self.entry_destino:set('text', names[1])
    end
    self.exp_destino:hide()
end


function GASR_Compiler.Compile(self)
    
    local arquivo = ' "'..self.entry_arquivo:get('text')..'" '
    local destino = ' "'..self.entry_destino:get('text')..'/" '
    local name    = ' "'..self.entry_system:get('text')..'"'
    
    --print(arquivo, destino, name)
    
    local p = io.popen('java -jar JARs\\compiler.jar'..arquivo..destino..name)
    while true do
        d = p:read()
        self.buffer:get_end_iter(self.iter)
        if d ~=nil then
            self.buffer:insert(self.iter, d..'\n', -1)
        else 
            break
        end
    end
    
end


function GASR_Compiler.new()
    local self = {}
    self.Window_Main = gtk.Window.new()
    self.Window_Main:connect('delete-event', GASR_Compiler.hide, self)
    
    self.Window_Main:set('default-height', 450, 'default-width', 450)
    self.Window_Main:set('title', 'Compilador STEP-NC GASR')

    self.VBox0  = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
    self.HBox1  = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
    self.HBox2  = gtk.Box.new(gtk.ORIENTATION_HORIZONTAL)
    self.VBox11 = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
    self.VBox12 = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
    self.VBox21 = gtk.Box.new(gtk.ORIENTATION_VERTICAL)
    self.VBox22 = gtk.Box.new(gtk.ORIENTATION_VERTICAL)

--Arquivo
    self.label_arquivo  = gtk.Label.new('Arquivo STEP-NC: ')
    self.entry_arquivo  = gtk.Entry.new()
    self.vazio_arquivo  = gtk.Label.new(' ')

    

    self.exp_arquivo    = gtk.FileChooserDialog.new('Selecione o arquivo', Window_Main, gtk.FILE_CHOOSER_ACTION_OPEN, 'gtk-cancel', gtk.RESPONSE_CANCEL, 'gtk-ok', gtk.RESPONSE_OK)
    self.filter_arquivo = gtk.FileFilter.new()
    self.filter_arquivo:add_pattern('*.stp')
    self.filter_arquivo:set_name("STEP Files")
    self.exp_arquivo:add_filter(self.filter_arquivo)

    self.button_arquivo = gtk.Button.new_with_label('Explorar')
    self.button_arquivo:connect('clicked', GASR_Compiler.buscar_arquivo, self)

--Destino
    self.label_destino  = gtk.Label.new('Local de Destino: ')
    self.entry_destino  = gtk.Entry.new()
    self.vazio_destino  = gtk.Label.new(' ')



    self.exp_destino    = gtk.FileChooserDialog.new('Selecione o destino', Window_Main, gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER, 'gtk-cancel', gtk.RESPONSE_CANCEL, 'gtk-ok', gtk.RESPONSE_OK)
    self.filter_destino = gtk.FileFilter.new()
    self.filter_destino:add_pattern('')
    self.filter_destino:set_name("directory")
    self.exp_arquivo:add_filter(self.filter_destino)
    self.button_destino = gtk.Button.new_with_label('Explorar')
    self.button_destino:connect('clicked', GASR_Compiler.buscar_destino, self)


--System
    self.label_system  = gtk.Label.new('Nome do System gerado: ')
    self.entry_system  = gtk.Entry.new()


--Log
    self.scroll_log    = gtk.ScrolledWindow.new()
    self.scroll_log:set('hscrollbar-policy', gtk.POLICY_AUTOMATIC, 'vscrollbar-policy', gtk.POLICY_AUTOMATIC)
    self.label_log     = gtk.Label.new('Log:')
    self.view_log      = gtk.TextView.new()
    self.buffer        = self.view_log:get('buffer')
    self.iter          = gtk.TextIter.new()
    self.scroll_log:add(self.view_log)


    self.button_compilar = gtk.Button.new_with_label('Compilar')
    self.button_compilar:connect('clicked', GASR_Compiler.Compile, self)

--VBox11 packing
    self.VBox11:pack_start(self.label_arquivo,   false, false, 5)
    self.VBox11:pack_start(self.entry_arquivo,   false, false, 5)
    self.VBox11:pack_start(self.label_destino,   false, false, 5)
    self.VBox11:pack_start(self.entry_destino,   false, false, 5)
    self.VBox11:pack_start(self.label_system,    false, false, 5)
    self.VBox11:pack_start(self.entry_system,    false, false, 5)

--VBox12 packing

    self.VBox12:pack_start(self.vazio_arquivo,    false, false, 5)
    self.VBox12:pack_start(self.button_arquivo,   false, false, 5)
    self.VBox12:pack_start(self.vazio_destino,    false, false, 5)
    self.VBox12:pack_start(self.button_destino,   false, false, 5)

--VBox21 packing
    self.VBox21:pack_start(self.label_log, false, false, 10)
    self.VBox21:pack_end(self.scroll_log, true, true, 10)

--VBox22 packing
    self.VBox22:pack_end(self.button_compilar, false, false, 10)

--HBox1 packing
    self.HBox1:pack_start(self.VBox11, true, true, 10)
    self.HBox1:pack_end(self.VBox12, false, false, 10)
 
--HBox2 packing 
    self.HBox2:pack_start(self.VBox21, true, true, 10)
    self.HBox2:pack_end(self.VBox22, false, false, 10)

--Vbox0 packing    
    self.VBox0:pack_start(self.HBox1, false, false, 10)
    self.VBox0:pack_start(self.HBox2, true, true, 10)

    self.Window_Main:add(self.VBox0)

--finishing
    setmetatable(self, GASR_Compiler)
    return self
end

