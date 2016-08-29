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

require 'BasicFB'
require"lxp"


-----------------------------------------------------------------------
--Composição do bloco

CompFB = {}
setmetatable(CompFB, {__index = _G})

CompFB.__index = CompFB

---------------------------------------------------------
--Função de fila do buffer de eventos - usar o primeiro item
function CompFB:pick_first()
	local item_event = self.buffer.event[ 1 ][ 1 ]
    local item_instance = self.buffer.event[ 1 ][ 2 ]
    local aux
    for key = 1, #self.buffer.event do
        self.buffer.event[ key ] = self.buffer.event[ (key + 1) ]
        aux = key
    end

    return item_event,item_instance
end

-------------------------------------------------------------
--Funcção de atualização de variáveis conectadas a eventos
function CompFB:with_var(event, label, flag)--flag = 1 -> incoming output, flag = 2 -> outgoing input
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
                    LOG_FILE:write('CompFB---***Var: '..label..'.'..value..' stored on Buffer-CompFB = '..tostring(self.buffer.var[label.."."..value])..'\n')
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
                            LOG_FILE:write('CompFB---***Var: '..label..'.'..value..' loaded on block\n')
                        end
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------

--Scheduler (agendador)
function CompFB:scheduler(event_list, label)
    if type (event_list) ~= 'table' then
        event_list = {event_list}
    end
    local aux, tam
    --[[if event_list ~=nil then
        tam = #event_list
    else
        tam = 0
    end]]
    for i = self.buffer.eventPos, (#event_list + self.buffer.eventPos-1) do     --Enfileira eventos chegando na Network
        if self.EventConnections[label] ~= nil then
            if self.EventConnections[label][event_list[i]] ~= nil then
                self.buffer.event[i] = {}
                self.buffer.event[i][1] = self.EventConnections[label][event_list[i]][2]--Evento
                self.buffer.event[i][2] = self.EventConnections[label][event_list[i]][1]--Instancia
                self:with_var(event_list[i], label, 1)
                aux = i
            end
        end
    end
    self.buffer.eventPos = aux
    local next_event
    local next_instance
    next_event,next_instance = self:pick_first()
    self:with_var(next_event, next_instance, 2)

    --LOG_FILE:write(next_event)
    if (next_instance == "self") then
        return {next_event}, next_instance
    else
        return self[next_instance]:exe(next_event)
    end
end

--Executável
function CompFB:exe(event)
    LOG_FILE:write('CompFB--- '..self.label..' started with event: '..event..'\n')

    if type(event) == 'string' then
        event = {event}
    end
    local execute = true
    local label = "self"             -- o evento inicial é entrada de self
    --Atualiza buffer com variáveis de entrada do FB composto
    local k,v,c,va
    for k,v in pairs(self.DataConnections) do
        for c,va in pairs(v) do
        local valor = va[2]
            if (va[1] == "self") then
                self.buffer.var["self."..valor] = self[valor]
            end
        end
    end
    ----------------------------------------------------------
    --Rede de FBs
    while(execute) do
        event, label = self:scheduler(event, label)
        if label =="self" then LOG_FILE:write('CompFB--- "'..self.label..'" execution completed\n')
        end
        if (label == "self") then
            execute = false
        end
        LOG_FILE:write()
    end
    LOG_FILE:write('CompFB--- '..self.label.. ': returned event: '..event[1]..'\n')
    ----------------------------------------------------------
    --atualizar variaveis de saída
    if self.DataConnections.self then
        for i, v in pairs (self.DataConnections.self) do
            self[i] = self.buffer.var[v[1]..'.'..v[2]]
        end
    end
    ----------------------------------------------------------
    return event, self.label
end











