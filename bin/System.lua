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

require ('Device')
require ('Resource')
System = {}

local split = function ( str )
    local _,_,str1,str2 = str:find('(.+)%.(.+)')
    return str1, str2
end

function string_to_value (str, ArraySize, tipo)
	local valor 
	ArraySize = tonumber(ArraySize)
	
    if not ArraySize or ArraySize == 0 then
        if tipo == 'BOOL' or tipo == 'BOOLEAN' or tipo == 'BINARY' then
            if str =='false' or str == 'FALSE' or str == 'False' or str == '.F. 'then return false
            elseif str =='true' or str == 'True' or str == 'TRUE' or str == '.T.' then return true
            end
        elseif tipo == 'INT' or tipo == 'REAL' or tipo == 'INTEGER' or tipo == 'NUMBER' or tipo == 'FLOAT' or tipo == 'DOUBLE' or tipo =='BYTE' then
            return tonumber(str)
        elseif tipo == 'STR' or tipo == 'STRING' or tipo == 'CHAR' or tipo == 'WSTRING' then
            return str
        else return '@INVALID'
        end
    else
        valor = {}
        local final , _
        if tipo == 'INT' or tipo == 'REAL' or tipo == 'INTEGER' or tipo == 'NUMBER' or tipo == 'FLOAT' or tipo == 'DOUBLE' or tipo =='BYTE' then
			if ArraySize == 1 then
				_,final,valor[1] =  str:find("%[%s*(%-?%d+%.*%d*)%s*%]")
			else
				_,final,valor[1] =  str:find("%[%s*(%-?%d+%.*%d*)%s*%,")
				for i = 2, ArraySize-1 do
					_,final,valor[i] =  str:find("%,%s*(%-?%d+%.*%d*)%s*", final)
				end
				_,final,valor[ArraySize] =  str:find("%,%s*(%-?%d+%.*%d*)%s*%]")
			end
			for i = 1, ArraySize do	
				valor[i] = tonumber(valor[i])
			end
		elseif tipo == 'STR' or tipo == 'STRING' or tipo == 'CHAR' or tipo == 'WSTRING' then
			if ArraySize == 1 then
				_,final,valor[1] =  str:find("%[%s*([%w%.%-%_%s]+)%s*%]")
			else
				_,final,valor[1] =  str:find("%[%s*([%w%.%-%_%s]+)%s*%,")
				for i = 2, ArraySize-1 do
					_,final,valor[i] =  str:find("%,%s*([%w%.%-%_%s]+)%s*", final)
				end
				_,final,valor[ArraySize] =  str:find("%,%s*([%w%.%-%_%s]+)%s*%]")
			end
		elseif tipo == 'BOOL' or tipo == 'BOOLEAN' or tipo == 'BINARY' then
			if ArraySize == 1 then
				_,final,valor[1] =  str:find("%[%s*(%w+)%s*%]")
			else
				_,final,valor[1] =  str:find("%[%s*(%w+)%s*%,")
				for i = 2, ArraySize-1 do
					_,final,valor[i] =  str:find("%,%s*(%w+)%s*", final)
				end
				_,final,valor[ArraySize] =  str:find("%,%s*(%w+)%s*%]")
			end
			for i = 1, ArraySize do	
				if valor[i] == '.T.' or valor[i] == 'True' or valor[i] == 'true' or valor[i] == 'TRUE' or valor[i] == '1' then
					valor[i] = true
				elseif valor[i] == '.F.' or valor[i] == 'False' or valor[i] == 'false' or valor[i] == 'FALSE' or valor[i] == '0' then
					valor[i] = false
				else
					valor[i] = '@INVALID'
				end
			end
		end
	end

    return valor    
end

function value_to_string(value)
	local str = ""
	if(type(value)=='table') then
		str = "["
		for i, v in ipairs(value) do
			str = str..' '..tostring(v)
		end
		str = str.."]"
	else
		if(type(value) == 'number') then
			str = string.format("%.5f", value)
		else
			str = tostring(value)
		end
	end
	return str
end


System.importXML = function (root, SystemType, label)
    local actResource   = " "
    local state         = {}
    local model         = {}
    model.other         = {}
    model.other.Comment = {}
    model.other.Version = {}
    local funcoes       = {}
    local actDevice     = {}
    model.label         = label
    model.DeviceList    = {}
    model._VersionInfo  = {}
    model._Parameters   = {}
    
    funcoes['System'] = function (name, atb)
        model.SystemType 		= atb.Name
        model.FBType			= atb.Name
        model.SystemTypeComment = atb.Comment
    end
    ------------------------------------------
    funcoes['Identification'] = function (name, atb)
        model._Standard 		= atb.Standard
    end
    -------------------------------------------
    funcoes['VersionInfo'] = function (name, atb)
        model._VersionInfo 		= {
			Date		 = atb.Date,
			Organization = atb.Organization,
			Author       = atb.Author,
			Version      = atb.Version
        }
    end
    -------------------------------------------
    funcoes['Device'] = function ( name, atb )
        model[atb.Name]          = {
            DeviceType   = atb.Type,
            label        = atb.Name,
            ResourceList = {}
        }
        actDevice                               = atb.Name
        model[actDevice]._System                = model
        model[actDevice]._SystemName            = model.label
        model.DeviceList[#model.DeviceList + 1] = {model[atb.Name], atb.dx or atb.x, atb.dy or atb.y,
			Name    = atb.Name,
			Type    = atb.Type,
			x       = atb.x or atb.dx,
			y       = atb.y or atb.dy,
			Comment = atb.Comment
        }
    end
    -------------------------------------------
    funcoes[ 'Resource' ] = function ( name, atb )
        model[actDevice][atb.Name]             = Resource.importXML (root, atb.Type..'.xml', atb.Name)
        model[actDevice][atb.Name]._Device     = model[actDevice]
        model[actDevice][atb.Name]._DeviceName = actDevice
        actResource 						   = atb.Name
        model[actDevice].ResourceList[#model[actDevice].ResourceList+1] = {model[actDevice][atb.Name], atb.x or atb.dx, atb.y or atb.dy,
			Name    = atb.Name,
			Type    = atb.Type,
			x       = atb.x or atb.dx,
			y       = atb.y or atb.dy,
			Comment = atb.Comment
        }
        
    end
    
    funcoes[ 'Parameter' ] = function ( name, atb )
        local block, var = split(atb.Name)
        if not model._Parameters[actDevice] then
			model._Parameters[actDevice] = {}
		end
		if not model._Parameters[actDevice][actResource] then
			model._Parameters[actDevice][actResource] = {}
		end
        if type(model[actDevice][actResource].Parameters) ~= 'table' then
            model[actDevice][actResource].Parameters = {}
        end
        model._Parameters[actDevice][actResource][#model._Parameters[actDevice][actResource]+1] = {
			Name    = atb.Name,
			Value   = atb.Value,
			Comment = atb.Comment
        }
        
        model[actDevice][actResource].Parameters[#model[actDevice][actResource].Parameters+1]= {block, var, atb.Value}
        model[actDevice][actResource][block][var] = string_to_value (atb.Value, model[actDevice][actResource][block].other.ArraySize2[var], model[actDevice][actResource][block].other.Type[var])
        LOG_FILE:write('SYSTEM---Parameters set on:  '..actResource..'.'..block..'.'..var..' = '.. atb.Value..'\n' )
    end
    local callbacks = {
        StartElement = function ( parser, name, atb )
            state[#state +1] = name
            if funcoes[ state[#state] ] then 
                funcoes[ state[#state] ]( name, atb )
            end
        end,
        EndElement = function ( parser, name )
            state[#state] =nil 
        end
    }

    local p = lxp.new(callbacks)  --inicialização do parser
    --leitura do arquivo
    local file = io.open( root..SystemType, 'r')
    for l in file:lines() do  -- iterate lines
        p:parse(l)            -- parses the line
        p:parse("\n")         -- parses the end of line

    end
    p:parse()               -- finishes the document
    p:close()               -- closes the parser
    file:close()
    return model
end

