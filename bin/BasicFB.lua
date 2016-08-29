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

require"lxp"

-----------------------------------------------------------------------
--Composição do bloco

BasicFB = {}
setmetatable(BasicFB, {__index = _G})

for i, j in pairs(math) do    --reescreve as funções matemáticas
    BasicFB[i] = j
end

BasicFB.__index = BasicFB
--Instancia classes
function BasicFB.new(name--[[tbl]])
    tbl = --[[tbl or]] {} -- create table if user does not provide one
    setmetatable(tbl, BasicFB)
    tbl.label = string.format(name)
    return tbl
end

--Checa transições
function BasicFB:check_trans(event)
    LOG_FILE:write('BasicFB---Is on state: '..self.state..'\n')
    if event ~= nil and event ~=false then
        self[event] = true
        LOG_FILE:write('BasicFB---Event: '..event..' incoming\n')
    else
        LOG_FILE:write('BasicFB---No event incoming\n')
    end
    for i, v in ipairs(self.stlist[ self.state ].transition) do
        transition,state = self:exe_trans(v.Condition,  v.Destination)
        if transition == true or transition ==1 then
            self[event] = false
            return state
        end
    end
    self[event] = false
    return nil
end
--tradutor das expressoes booleanas
local translate = {
        ['&']     = ' and ' ,
        [' &']    = ' and ' ,
        [' & ']   = ' and ' ,
        ['& ']    = ' and ' ,
        ['||']    = ' or '  ,
        ['!']     = ' not ' ,
        ['!=']    = ' ~= '  ,
        ['==']    = ' == '
    }

--Executa a expressao de condição, retorna true (ou 1), false ( ou nil) e o destino
function BasicFB:exe_trans(Condition, Destination)
    Condition = Condition:gsub('([^%w%_]+)', translate )

    local f = loadstring( 'return ' .. Condition)

    setfenv( f, self )

    if f() then
        return true, Destination
    else
        return false, Destination
    end
end

--Executa algoritmo
function BasicFB:exe_alg ( algorithm )
    local f = loadstring ( algorithm )

    --print('\n\n\n'.. algorithm, f, self.label..'\n\n\n')
    if( f == nil ) then print( loadstring ( algorithm ) ) end
    setfenv( f, self )
    return f()
end


--Executa estados
function BasicFB:ECCaction()
    i = 1
    j = 1 -- controlador de event_list
    event_list = {}
    while(self.stlist[ self.state ].action[ i ] ~= nil) do
        LOG_FILE:write('BasicFB---Action No.: '..i..'\n')
        if self.FW_Alg[ self.stlist[ self.state ].action[ i ].alg] ~= nil then
        LOG_FILE:write('BasicFB---Algorithm = '.. self.stlist[ self.state ].action[ i ].alg..'\n')
            local algorithm = self.FW_Alg[self.stlist[ self.state ].action[i].alg]
            if ( algorithm ~= nil ) then
                self:exe_alg (algorithm)
            end
        end
        if (self.stlist[ self.state ].action[i]["out"] ~= nil) then
            event_list[ j ] = self.stlist[ self.state ].action[ i ][ "out" ]
            LOG_FILE:write( 'BasicFB---Event out = '.. event_list[ j ]..'\n')
            j = j + 1
        end
        i = i + 1
        LOG_FILE:write('BasicFB---Action completed\n')
    end
    return event_list
end

--ECC
function BasicFB:ECC(event)
    local event_list = {}
    is_there_transition = true

    while(is_there_transition) do
        ch_st = self:check_trans(event)
        event = nil
        if(ch_st ~= nil) then
            self.state = ch_st
            LOG_FILE:write('BasicFB---Changed to state: ' .. self.state..'\n')
            aux = self:ECCaction()

            for i = 1, #aux do
                event_list[ #event_list +1 ] = aux [ i ]
            end

        else
            is_there_transition = false
            LOG_FILE:write('BasicFB--- "'..self.label..'" execution completed\n')
        end

        self.event = false
        event = false

    end

    return event_list
end

--Executável
function BasicFB:exe(event)
    LOG_FILE:write('BasicFB--- "'..self.label..'" started with event: '..event..'\n')
    event = self:ECC(event)

    if event[1] ~=nil then
        LOG_FILE:write('BasicFB--- "'..self.label..'" returned event: '..event[1]..'\n')
    else
        LOG_FILE:write('BasicFB--- "'..self.label..'" did not return any event\n')
    end
    return event, self.label
end



