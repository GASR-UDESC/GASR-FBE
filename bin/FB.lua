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

SIFB_Class = {}
require 'BasicFB'
require 'CompFB'
require 'SIFB_Publ'
require 'SIFB_Subl'
require 'Starter'
require 'File_Writer'
require 'Modbus_read_4'
require 'Modbus_write_1'
require 'Modbus_write_7'
require 'Modbus_write_12'
require 'Run_until_loop_response'
require 'Trajectory_Viewer_Comm'

--funcoes auxiliares
local split = function ( str )
    local _,_,str1,str2 = str:find('(.+)%.(.+)')
    return str1, str2
end


local clone = function ( t , deep )  --créditos Y.K.
    if (type(t) ~='table') then
        r = t
    else
        local r = {}
        for k, v in pairs( t ) do
            if deep and type( v ) == 'table'
                then r[ k ] = table.clone( v, true )
                else r[ k ] = v
                end
        end
    end
    return r
end

FB = {}
FB.importXML = function(root, FBType, label)
	local model 				= {}
    model.invarlist             = {}
    model.ineventlist           = {}
    model.internalvarlist       = {}
    model._algs                 = {}
	model.other                 = {}
    model.other.ArraySize       = {}
    model.other.ArraySize2      = {}
    model.other.Type            = {}
    model.other.Version         = {}
    model.other.Comment         = {}
    model.other.Comment.ECState = {}
    model.other.Comment.Alg     = {}
    model.other.InitialValue    = {}
    model.outvarlist            = {}
    model.outeventlist          = {}
    model.FBNetwork             = {}
    model.Type                  = {}
    model.ArraySize             = {}
    model.ArraySize2            = {}
    model.FW_Alg                = {}    --Forbidden Word _ Algorithm
    model.Parameters            = {}
    local state                 = {}
    local funcoes               = {}
    model.label                 = label
    model.with                  = {}     --estruturas utilizadas para armazenar os dados
    model.flag                  = {}
    local Basics                = {}
    local BasicsPos             = {}
    model.flag                  = {}
    model.stlist                = {}
    model.transitions           = {}
    model.INPUTS                = {}
    model.ServiceSequences      = {}
	model._SequenceNumber       = {}
    local InPrim                = " "
    local acState               = 0
    local acEvent               = 0
    local acFB                  = " "
    local acAlg                 = 0
    local acSequence            = " "
    local acTransaction         = " "
    local class                 = " "
    local st_ev                 = " "
    local service               = " "
    model.EventConnections      = {}
    model.DataConnections       = {}
    model.STdx                  = {}                   --posiçao de estado no desenho do ECC
    model.STdy                  = {}
    local parameters            = {}
    model.buffer = {
        eventPos = 1,
        event = {
        },
        var = {
            --Buffer: ["instance.var"] = value  
        },
    }


    -- tratamento de estados

    
    funcoes[ 'FBType' ] = function( name, atb )
        model.FBType 				  = atb.Name
        model.other.Comment['FBType'] = atb.Comment
    end
    --------
    funcoes['Identification'] = function( name, atb )
        model.other.Standard = atb.Standard
    end  
    ---------
    funcoes[ 'VersionInfo' ]  = function (name, atb)
        model._Author    = atb.Author
		model._Date      = atb.Date
		model.other.Version [#model.other.Version+1] = {
            Organization = atb.Organization,
            Version      = atb.Version,
            Author       = atb.Author,
            Date         = atb.Date,
            Remarks      = atb.Remarks
        }
    
    end
    ---------
    funcoes[ 'CompilerInfo' ]  = function (name, atb)
        model.other.BaseFile = atb.BaseFile
        model.other.IsLua    = string_to_value(atb.IsLua,false,'BOOL')
		model.other.Neural   = string_to_value(atb.Neural,false,'BOOL')
		model.other.net_file = atb.NetFile
    end
    ---------
    funcoes[ 'InterfaceList' ] = function ( name, atb )
    end
    ---------
    funcoes[ 'EventInputs' ]   = function ( name, atb )
    end
    ---------
    funcoes[ 'EventOutputs' ]  = function ( name, atb )
    end
    ---------
    funcoes[ 'Event' ] = function ( name, atb )
        if state[#state-1] == 'EventInputs' then      
            model[atb.Name]                          = false    --inicializou o evento
            model.flag[atb.Name]                     = "InputEvent"
            model.ineventlist [#model.ineventlist+1] = atb.Name
            acEvent                                  = atb.Name
            model.other[atb.Name]                    = {
                Comment = atb.Comment
            }
        else
            model[atb.Name] = false    --inicializou o evento
            model.flag[atb.Name]                       = "OutputEvent"
            model.outeventlist [#model.outeventlist+1] = atb.Name
            acEvent = atb.Name
            st_ev = atb.Name
            model.other[atb.Name]                      = {
                Comment = atb.Comment
            }
            if model.Class == 'File_Writer' then  --GAMBI 3 --Consertar isto
                model.CONFIRMATION = atb.Name
            end
            --if atb.Name ==  'ind' then service = 'subscriber' end -- GAMBI_2
        end
    end
    ---------
    funcoes[ 'With' ] = function ( name, atb )
        if type(model.with[acEvent]) ~= "table" then
            model.with[acEvent] ={}
        end
        local tam = #model.with[acEvent]  +1
        model.with[acEvent][tam] = atb.Var
    end
    ---------
    funcoes [ 'InputVars' ]= function ( name, atb )
    end
    ---------
    funcoes [ 'OutputVars' ]= function ( name, atb )
	end
    ---------
    funcoes ['InternalVars'] = function ( name, atb )
    end
    ---------
    funcoes [ 'VarDeclaration' ] = function ( name, atb) 
        
        if atb.ArraySize ~= nil and atb.ArraySize ~= '' and tonumber(atb.ArraySize) > 1 then
            model[atb.Name] = {}
            for i = 1, atb.ArraySize do
                model[atb.Name][#model[atb.Name]+1] = 0 --inicializa vetor
                end
            else
            model[atb.Name] = 0  -- nao eh array
        end
        
        
        model.INPUTS[#model.INPUTS+1]    	  = atb.Name
        model.other.Type[atb.Name]       	  = atb.Type
        model.other.ArraySize[atb.Name]  	  = atb.ArraySize or 1 --usado para inicializar as 
        model.other.ArraySize2[atb.Name] 	  = atb.ArraySize      --usado para os parametros
        model.other.Comment[atb.Name]    	  = atb.Comment
        model.other.InitialValue[atb.Name]    = atb.InitialValue
        if atb.InitialValue  and InitialValue ~='' then
            model[atb.Name] = string_to_value (atb.InitialValue, atb.ArraySize, atb.Type)
        end
        
        if state[#state-1] == 'InputVars' then 
            model.flag[atb.Name] = 'InputVar'
            model.invarlist [#model.invarlist+1] = atb.Name
        
        elseif state[#state -1] == 'InternalVars' then
            model.flag[atb.Name] = 'InternalVar'
            model.internalvarlist[#model.internalvarlist+1] = atb.Name
        else
            model.flag[atb.Name] = 'OutputVar'
            model.outvarlist [#model.outvarlist+1] = atb.Name
        end
        
    end
    ---------
    funcoes[ 'FBNetwork' ] = function ( name, atb)
		model.Class = 'Composite'
    end
    ---------
    funcoes [ 'FB' ] = function ( name, atb )
        model.flag[atb.Name]      = 'Block'
        Basics[#Basics +1]        = {atb.Name, atb.Type}   --vai instanciar os blocos ao final
        BasicsPos[#BasicsPos +1]  = {atb.dx or atb.x  , atb.dy or atb.y}
        acFB                      = atb.Name
    end
    ---------
    funcoes[ 'Parameter' ] = function ( name, atb )
        if type(parameters[acFB])~= 'table' then
            parameters[acFB] = {}
        end
        tam = #parameters[acFB] +1
        parameters[acFB][tam] = {atb.Name, atb.Value}
        model.Parameters[#model.Parameters+1] = {acFB, atb.Name, atb.Value}  -- {bloco, parametro, valor}
    end
    ------------------------------------------------
    funcoes[ 'EventConnections' ] = function ( name, atb)
    end
    ---------
    funcoes[ 'DataConnections' ]  = function ( name, atb)
    end
    ---------
    
    funcoes[ 'Connection' ]  = function ( name, atb)
        local sourceInst, sourceEvent, destInst, destEvent
        if state[#state -1] == 'EventConnections' then 
            sourceInst, sourceEvent = split (atb.Source)
            if sourceInst ==nil or sourceEvent ==nil then    --separa a string antes e depois do ponto
                sourceInst  = 'self' 
                sourceEvent = atb.Source   
            end
            destInst, destEvent = split (atb.Destination)
            if destInst ==nil or destEvent ==nil then    --separa a string antes e depois do ponto
                destInst  = 'self'
                destEvent = atb.Destination
            end
            if type (model.EventConnections[sourceInst]) ~= 'table' then
                model.EventConnections[sourceInst] = {}
            end
            model.EventConnections[sourceInst][sourceEvent] = { destInst , destEvent }
        
        elseif state[#state -1] == 'DataConnections' then
            local sourceInst, sourceData, destInst, destData
            sourceInst, sourceData = split (atb.Source)
            if sourceInst == nil or sourceData == nil then    
                sourceInst = 'self'
                sourceData = atb.Source
            end
            
            destInst, destData = split (atb.Destination)
            if destInst ==nil or destData ==nil then    --separa a string antes e depois do ponto
                destInst = 'self'
                destData = atb.Destination
            end
            
            if type(model.DataConnections[destInst]) ~= 'table' then
                model.DataConnections[destInst] = {}
            end
            model.DataConnections[destInst][destData] = {sourceInst, sourceData}

        end
    end
    -----
    
    funcoes[ 'BasicFB' ] = function ( name, atb)
        model.Class = 'Basic'
    end
    -----
    
    funcoes [ 'ECC' ] = function ( name, atb)
        model.Class = 'Basic'
    end
    -----
    
    funcoes [ 'ECState' ] = function ( name, atb)
        model.other.Comment.ECState[atb.Name] = atb.Comment
        model.stlist[atb.Name]            = {}
        model.stlist[atb.Name].transition = {}
        model.stlist[atb.Name].action     = {}
        model.STdx[atb.Name]              = tonumber(atb.dx or atb.x)
        model.STdy[atb.Name]              = tonumber(atb.dy or atb.y)
        acState = atb.Name
    end
    -----
    
    funcoes [ 'ECAction' ] = function ( name, atb )
        local tam = #model.stlist[acState].action
        model.stlist[acState].action[tam+1] = {}
        model.stlist[acState].action[tam+1].alg = atb.Algorithm
        model.stlist[acState].action[tam+1].out = atb.Output
    end
    -----
    
    funcoes [ 'ECTransition' ] = function ( name, atb )
        local translate = {
            ['&']  = ' and ',
            ['||'] = ' or ',
            ['!']  = ' not ',
            ['!='] = '~=',
        }
        local tam = #model.stlist[atb.Source].transition 
            model.stlist[atb.Source].transition[#model.stlist[atb.Source].transition+1]         = {}
            model.stlist[atb.Source].transition[#model.stlist[atb.Source].transition].Condition = atb.Condition
            model.stlist[atb.Source].transition[#model.stlist[atb.Source].transition].Destination = atb.Destination
            model.transitions[#model.transitions+1] = {
				Source 	    = atb.Source,
				Destination = atb.Destination,
				Condition   = atb.Condition
            }
    end
    -----
    
    funcoes ['Algorithm'] = function ( name, atb )
        --print('abriu algorithm')
        acAlg 						= atb.Name
		model._algs[#model._algs+1] = atb.Name
    end
    ----
    
    funcoes ['Lua'] = function ( name, atb )   --armazena o conteúdo do algoritmo
        --print('abriu LUA')
		model.FW_Alg[acAlg] = atb.Text
        model.other.Comment.Alg[acAlg] = atb.Comment
    -----
    end
    ----- dados de publisher e subscriber, a seguir:
    
    funcoes ['Service'] = function ( name, atb)
        model.Class = 'ServiceInterface'
        --class = 'ServiceInterface'
        --print('L: '..atb.RightInterface..' R: '.. atb.LeftInterface)
        model.Service = {
            RightInterface = atb.RightInterface,
            LeftInterface  = atb.LeftInterface,
            Comment        = atb.Comment
        }
    end
    
    -----
    
    funcoes ['ServiceSequence'] = function ( name, atb )
        acSequence = #model.ServiceSequences + 1
        model.ServiceSequences[acSequence] = {
            Name = atb.Name,
            Transactions = {}
            }
		model._SequenceNumber[atb.Name] = acSequence
    end
    
    ----
    
    funcoes ['ServiceTransaction'] = function ( name, atb )
        acTransaction = #model.ServiceSequences[acSequence].Transactions+1
        model.ServiceSequences[acSequence].Transactions[acTransaction] = {}
    end
    
    ----
    
    funcoes ['InputPrimitive'] = function ( name, atb)
        --~ InPrim = atb.Event
        model.ServiceSequences[acSequence].Transactions[acTransaction].InputPrimitive = {
            Interface   = atb.Interface,
            Event       = atb.Event or '',
            Comment     = atb.Comment,
            Parameters  = atb.Parameters
        } 
    end
    
    ----
    
    funcoes ['OutputPrimitive'] = function ( name, atb)
        model.ServiceSequences[acSequence].Transactions[acTransaction].OutputPrimitive = {
            Interface   = atb.Interface,
            Event       = atb.Event or '',
            Comment     = atb.Comment,
            Parameters  = atb.Parameters
        } 
    end
    
    
	
    ------------------------Inicio do  parser---------------------
    local callbacks = {
        
        StartElement = function ( parser, name, atb )
            state[#state +1] = name
            if funcoes[ state[#state] ] then 
                funcoes[ state[#state] ]( name, atb )
            else --print('funcao ', name, ' nao encontrada')
            end
        end,
        
        EndElement = function ( parser, name )
        --  io.write(string.rep(" ", count),"- ",  name, "\n")
            state[#state] =nil 
        end
    }

    local p = lxp.new(callbacks)  --inicialização do parser
    --leitura do arquivo
	local file = io.open( root..FBType, 'r')
	for l in file:lines() do  -- iterate lines
        p:parse(l)            -- parses the line
        p:parse("\n")         -- parses the end of line

    end
    p:parse()               -- finishes the document
    p:close()               -- closes the parser
    file:close()
    --Instanciação dos blocos internos
    -----------------------------------------------------------------------
    
    for i, v in ipairs(Basics) do
        model[v[1]]  		          		= FB.importXML (root,v[2]..".xml", v[1])
		model.flag[model[v[1]].label] 		= model[v[1]].Class
        model[v[1]].Upper 			  		= model
        model[v[1]].dx 	  			  		= tonumber(BasicsPos[i][1])
        model[v[1]].dy 	  			  		= tonumber(BasicsPos[i][2])
        model.FBNetwork[#model.FBNetwork+1] = {v[1],tonumber(BasicsPos[i][1]),  tonumber(BasicsPos[i][2])}
    end
    if model.Class == 'Composite' then
        setmetatable(model, CompFB)
    elseif model.Class =='Basic' then
        setmetatable(model, BasicFB)
        model.state = 'START'
    elseif model.Class == 'ServiceInterface' then
        local _, _, baseFile = model.other.BaseFile:find('(.+).lua')
        setmetatable(model, SIFB_Class[baseFile])
    end
    for j, k in pairs(parameters) do
        for i, v in ipairs(k) do           
            model[j][v[1]] = string_to_value (v[2],model[j].other.ArraySize2[v[1]] , model[j].other.Type[v[1]])  -- Carrega os parâmetros
            LOG_FILE:write('RESOURCE---Parameters set on:  '..model.label..'.'..j..'.'..v[1]..' = '.. v[2]..'\n')
        end
    end
        
    return model
end
