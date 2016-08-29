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

require 'FB'
require 'lxp'


------------------------------------------------------------------------
--Composição do bloco

Resource = {}
setmetatable(Resource, {__index = _G})


for i, j in pairs(math) do    --reescreve as funções matemáticas
    Resource[i] = j
end

Resource.__index = Resource

--Instancia classes
function Resource.new(name--[[tbl]])
    local tbl = --[[tbl or]] {} -- create table if user does not provide one
    setmetatable(tbl, Resource)
    tbl.label = string.format(name)
    
    return tbl
end
------------------------------------------------------------------------
--Função de fila do buffer de eventos - usar o primeiro item
function Resource:pick_first()

    if not self.buffer.event[1] then
		return nil, nil
	end
	local item_event = self.buffer.event[1][1]
    local item_instance = self.buffer.event[1][2]
    local aux
    for key = 1, #self.buffer.event do
        self.buffer.event[key] = self.buffer.event[(key + 1)]
        aux = key
    end
    self.buffer.event[(aux + 1)] = nil
    return item_event,item_instance
end

------------------------------------------------------------------------

function Resource:with_var(event, label, flag)--flag = 1 -> incoming output, flag = 2 -> outgoing input
	if label ~= "self" then
        if(flag == 1) then-- Atualizar variáveis de saída
            local key
            local value
            if(self[label]["with"][event] ~= nil) then
                for key, value in ipairs(self[label]["with"][event]) do
                    if type(self[label][value]) == 'table' then
                        self.buffer.var[label.."."..value] = {}
                        for i , v in ipairs (self[label][value]) do
                            self.buffer.var[label.."."..value][i] = v
                        end
                    elseif self[label][value] then
                        self.buffer.var[label.."."..value] = self[label][value]--Valor de variável de saída atualizado
                    end
                    LOG_FILE:write('RESOURCE---***Var: '..label..'.'..value..' stored on Buffer-Resource\n')
                end
            end
        ----------------------------------
        elseif(flag == 2) then--Atualiza variáveis de entrada do próximo bloco
           if(self[label]["with"][event] ~= nil  ) then
                for key, value in ipairs(self[label]["with"][event]) do
                    if self.DataConnections[label] ~=nil then
                        if(self.DataConnections[label][value]) then
                            if type(self.buffer.var[ self.DataConnections[label][value][1].."."..self.DataConnections[label][value][2]]) == 'table' then
                                for i , v in ipairs (self.buffer.var[ self.DataConnections[label][value][1].."."..self.DataConnections[label][value][2]]) do
                                    self[label][value][i] = v
                                end
                            elseif self.buffer.var[ self.DataConnections[label][value][1].."."..self.DataConnections[label][value][2]] then
                                self[label][value] = self.buffer.var[ self.DataConnections[label][value][1].."."..self.DataConnections[label][value][2]] --da variável que está no buffer
                            end
                            LOG_FILE:write('RESOURCE---***Var: '..label..'.'..value..' loaded on block\n')
                        end
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------

--Scheduler (agendador)
function Resource:scheduler(event_list, label)
    local aux = 1, tam
    
	if type(event_list) == 'string' then
		event_list = {event_list}
	end
	
	
	local xpos = 1
	for i = self.buffer.eventPos, (#event_list + self.buffer.eventPos) do     
		if self.EventConnections[label] and self.EventConnections[label][event_list[i]] then
			self.buffer.event[i] = {}
			self.buffer.event[i][1] = self.EventConnections[label][event_list[xpos]][2]--Evento    AQUI ESTA O PROBLEMA 
			self.buffer.event[i][2] = self.EventConnections[label][event_list[xpos]][1]--Instancia AQUI ESTA O PROBLEMA
			self:with_var(event_list[i], label, 1)
			aux = i-1
			xpos = xpos+1
		end
	end
	

    self.buffer.eventPos = aux
    local next_event
    local next_instance
    next_event,next_instance = self:pick_first()
    if next_event and next_instance then
		self:with_var(next_event, next_instance, 2)
	end
	if not next_instance then
		return -1, -1
    elseif (next_instance == "self") then
        return {next_event}, next_instance
    else
		return self[next_instance]:exe(next_event)
    end
end

--Executável
function Resource:exe(event, label)
    if event then
        LOG_FILE:write('RESOURCE--- '..self.label..' -> started with '..label..'.'..event..'\n')
    else
        LOG_FILE:write('RESOURCE--- '..self.label..' -> initialized with '..label..'\n')
    end
  
    if type(event) ~= 'table' then
        event = {event}
    end


 local execute = true
    ----------------------------------------------------------
    --Rede de FBs
    while(execute) do
          if not event then
	   event = {}
          end   
		if (not event[1]) or event[1] ~=-1 then
            
            event, label = self:scheduler(event, label) 
			if label =="self" or (not label) then 
                LOG_FILE:write('RESOURCE--- "'..self.label..'" execution complete\n') 
                execute = false
            elseif label == -1 then
                execute = false
            end
            
            if (label == "self") then
                
            end
            LOG_FILE:write()
        --[[elseif label == 'Execution_OK' then
            break
        else 
            LOG_FILE:write('\n***EXECUTION COMPLETED***\n') 
            break]]
        end
    end
    ----------------------------------------------------------
    ----------------------------------------------------------
    --return event, self.label
end


--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------


local split = function ( str )
	local _,_,str1,str2 = str:find('(.+)%.(.+)')	
	return str1, str2
end

Resource.importXML = function (root, ResourceType, label)
    
    local model            = {}
    local state            = {}
    local funcoes          = {}
    local Basics           = {}
    local acFB             = ""
    local parameters       = {}
    local BasicsPos        = {}
    model.Parameters       = {}
    model._Parameters      = {}
    model.FBNetwork        = {}
    model.label            = label
    model.terminou         = false
    model.EventConnections = {}
    model.with             = {}
    model.DataConnections  = {}
    model.other            = {}
	model.other.Comment   = {}
    model.other.Version    = {}
    model._varlist          = {}
    model.buffer = {
        eventPos = 1,
        event = {
        },
        var = {
            --Buffer: ["instance.var"] = value   
        },
    }
    
    funcoes[ 'Resource' ] = function( name, atb )
       model.ResourceType 	     = atb.Name
       model.Class        		 = 'Resource'
       model.FBType       	     = atb.Name
       model.ResourceTypeComment = atb.Comment
	   model.other.Comment['FBType'] = atb.Comment
    end
    ----------
    funcoes[ 'ResourceType' ] = function( name, atb )
       model.ResourceType 	     = atb.Name
       model.Class	             = 'Resource'
       model.FBType       	     = atb.Name
       model.ResourceTypeComment = atb.Comment
    end
    ----------
    funcoes['Identification'] = function( name, atb )
       ----LOG_FILE:write( 'Abriu Identification' )
       model._Standard = atb.Standard
       ----LOG_FILE:write( 'Standard = ' ,Identification )
    end  
    ----------------
    funcoes['VersionInfo'] = function( name, atb )
		model.other.Version [#model.other.Version+1] = {
            Organization = atb.Organization,
            Version      = atb.Version,
            Author       = atb.Author,
            Date         = atb.Date,
            Remarks      = atb.Remarks
        }
    end
    ----------
    funcoes[ 'CompilerInfo' ] = function( name, atb )
       model.other.BaseFile      = atb.BaseFile
       model.other.IsLua         = atb.IsLua
    end
    
    ----------------
    funcoes[ 'FBNetwork' ] = function ( name, atb)
       --LOG_FILE:write('Abriu FBNetwork')
       --class = "Composite
    end
    ---------
    funcoes['VarDeclaration'] = function (name, atb)
        model[atb.Name] = 0
        if atb.InitialValue then
            model[ atb.Name ] = string_to_value( atb.InitialValue, atb.ArraySize ,  atb.Type )
        end
        model._varlist[#model._varlist+1] = {
			Name 		 = atb.Name, 
			Type 		 = atb.Type, 
			ArraySize    = atb.ArraySize, 
			InitialValue = atb.InitialValue,
			Comment      = atb.Comment
			}
		
    end
    
    funcoes [ 'FB' ] = function ( name, atb )
        model[atb.Name] = FB.importXML (root, atb.Type..".xml", atb.Name)
        model[atb.Name].Upper = model
        model[atb.Name]._Resource     = model
        model[atb.Name]._ResourceName = model.label
        model[atb.Name].dx = atb.dx or atb.x
        model[atb.Name].dy = atb.dy or atb.y
        model.FBNetwork[#model.FBNetwork+1] = {atb.Name , atb.dx or atb.x,  atb.dy or atb.y,
			Name = atb.Name,
			x    = atb.x or atb.dx,
			y    = atb.y or atb.dy,
			Type = atb.Type
        }
        --~ Basics[#Basics +1] = {atb.Name, atb.Type}   --vai instanciar os blocos ao final
        acFB = atb.Name
        --~ BasicsPos[ #BasicsPos + 1] = {atb.dx or atb.x  , atb.dy or atb.y}
    end
    ---------
    funcoes[ 'Parameter' ] = function ( name, atb )
        if type(parameters[acFB])~= 'table' then
            parameters[acFB] 		= {}
            model._Parameters[acFB] = {}
        end
        tam = #parameters[acFB] +1
        parameters[acFB][tam] = {atb.Name, atb.Value}
        model._Parameters[acFB][tam] = {
			Name    = atb.Name,
			Value   = atb.Value,
			Comment = atb.Comment
        }
        model.Parameters[#model.Parameters+1] = {acFB, atb.Name, atb.Value}  -- {bloco, parametro, valor}
    end
    funcoes[ 'EventConnections' ] = function ( name, atb)
        --LOG_FILE:write('Abriu EventConnections')
    end
    ---------
    funcoes[ 'DataConnections' ]  = function ( name, atb)
        --LOG_FILE:write('Abriu DataConnections')
    end
    ---------
    funcoes[ 'Connection' ]  = function ( name, atb)
        --LOG_FILE:write('abriu connection')
        local sourceInst, sourceEvent, destInst, destEvent
        if state[#state -1] == 'EventConnections' then	
            sourceInst, sourceEvent = split (atb.Source)
            destInst, destEvent = split (atb.Destination)
            if destInst ==nil or destEvent ==nil then    --separa a string antes e depois do ponto
                destInst = 'self'
                destEvent = atb.Destination
            end
            if type (model.EventConnections[sourceInst]) ~= 'table' then
                model.EventConnections[sourceInst] = {}
            end
            model.EventConnections[sourceInst][sourceEvent] = { destInst , destEvent }
        ----
        elseif state[#state -1] == 'DataConnections' then
            local sourceInst, sourceData, destInst, destData
            
            sourceInst, sourceData = split (atb.Source)
            if sourceInst == nil or sourceData == nil then    --separa a string antes e depois do ponto
                sourceInst = 'self'
                sourceData = atb.Source
            end
            
            destInst, destData = split (atb.Destination)
            if destInst ==nil or destData ==nil then    --separa a string antes e depois do ponto
                destInst = 'self'
                destData = atb.Destination
            end
            
            if sourceInst == 'self' then
                --print(model.label,destInst, destData, sourceData)
                model[destInst][destData] = model[sourceData]
                
            else
                if type(model.DataConnections[destInst]) ~= 'table' then
                    model.DataConnections[destInst] = {}
                end
            
                model.DataConnections[destInst][destData] = {sourceInst, sourceData}
            end    
        end
    end
    
    
    -----------------------------Inicio do parser--------------------------------------------------------
    
    local callbacks = {
        StartElement = function ( parser, name, atb )
            state[#state +1] = name
            if funcoes[ state[#state] ] then
               
               funcoes[ state[#state] ]( name, atb )
            else --LOG_FILE:write('funcao ', name, ' nao encontrada')
            end
        end,
        EndElement = function ( parser, name )
          --  count = count - 1
          --  io.write(string.rep(" ", count),"- ",  name, "\n")
            --LOG_FILE:write('fechou', state[#state])
            state[#state] =nil 
        end
    }
    
    local p = lxp.new(callbacks)  --inicialização do parser
    --leitura do arquivo
    local file = io.open( root..ResourceType, 'r')

    for l in file:lines() do  -- iterate lines
        p:parse(l)          -- parses the line
        p:parse("\n")       -- parses the end of line
    
    end
    p:parse()               -- finishes the document
    p:close()               -- closes the parser
    file:close()
    --~ for i, v in ipairs(Basics) do
        --~ model[v[1]] = FB.importXML (root, v[2]..".xml", v[1], label)
        --~ model[v[1]].Upper = model
        --~ --_, _, model[v[1]].id = v[1]:find('.+%_+(.+)')
        --~ model[v[1]]._Resource     = model
        --~ model[v[1]]._ResourceName = model.label
        --~ model[v[1]].dx = BasicsPos[i][1]
        --~ model[v[1]].dy = BasicsPos[i][2]
        --~ model.FBNetwork[#model.FBNetwork+1] = {v[1],BasicsPos[i][1],  BasicsPos[i][2]}
    --~ end
    for j, k in pairs(parameters) do
        for i, v in ipairs(k) do
            
            model[j][v[1]] = string_to_value (v[2],model[j].other.ArraySize2[v[1]] , model[j].other.Type[v[1]])  -- Carrega os parâmetros
                LOG_FILE:write('RESOURCE---Parameters set on:  '..model.label..'.'..j..'.'..v[1]..' = '.. v[2]..'\n')
        end
    end
    setmetatable(model, Resource)
    return model
end







