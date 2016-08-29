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
function FBViewerLOAD(self)
    local LOAD
    local StructType
    local open_dialog = gtk.FileChooserDialog.new('Load a file', self.Main_Window, gtk.FILE_CHOOSER_ACTION_OPEN, 'gtk-close', gtk.RESPONSE_CLOSE, 'gtk-open', gtk.RESPONSE_OK)
    local file_name
    
    if (open_dialog:run() == gtk.RESPONSE_OK) then
        file_name 		= open_dialog:get_filenames()
        file_name       = file_name[1]
        dofile(file_name)
        f(self)
        self.Drawing_Area:queue_draw()
        
    end
    
    open_dialog:hide()
end
