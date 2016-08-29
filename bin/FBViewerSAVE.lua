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

function FBViewerSAVE(self, run)
    if self._File then
        local file_name   = string.gsub(self._File, '.xml', '.xml')
        local save_dialog = gtk.FileChooserDialog.new('Save a file', self.Main_Window, gtk.FILE_CHOOSER_ACTION_SELECT_FOLDER, 'gtk-close', gtk.RESPONSE_CLOSE, 'gtk-save', gtk.RESPONSE_OK)
        if run then
			XML_export(self, self.Library)
        elseif (save_dialog:run() == gtk.RESPONSE_OK) then
            dir           = save_dialog:get_filenames()
            XML_export(self, dir[1])
        end
		save_dialog:hide()
    end
end
  
