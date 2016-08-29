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

function XML_export(self, root)
	print('saving to XML --> ',self.Struct.NAME, self.Struct._FunctionBlock.FBType)
	root = root or ""
	local FILE
	FILE = io.open(root..'\\'..self.Struct._FunctionBlock.FBType..'.xml', 'w')
	if self.Struct._Type == 'BlockView' or self.Struct._Type == 'CompView' then
		FILE:write('<?xml version="1.0" encoding="UTF-8"?>'..'\n'..'<!DOCTYPE FBType >\n')
		FILE:write('<FBType Name="'..self.Struct._FunctionBlock.FBType..'" ')
		if self.Struct._FunctionBlock.other.Comment['FBType'] then
			FILE:write('Comment= "'..self.Struct._FunctionBlock.other.Comment['FBType']..'" ')
		end
		FILE:write('>\n')
		FILE:write('\t<Identification Standard="'..self.Struct._FunctionBlock.other.Standard..'"/>\n')
		FILE:write('\t<VersionInfo ')
		if self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Organization then
			FILE:write('Organization="'..self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Organization..'" ')
		end
		if self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Version then
			FILE:write('Version="'..self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Version..'" ')
		end
		if self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Author then
			FILE:write('Author="'..self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Author..'" ')
		end
		if self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Date then
			FILE:write('Date="'..self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Date..'" ')
		end
		FILE:write('/>\n')
		FILE:write('\t<CompilerInfo ') 
		if self.Struct._FunctionBlock.other.IsLua then
			FILE:write('IsLua="true" ')
		end
		if self.Struct._FunctionBlock.other.BaseFile then
			FILE:write('BaseFile="'..self.Struct._FunctionBlock.other.BaseFile..'" ')
		end
		if self.Struct._FunctionBlock.other.Neural then
			FILE:write('Neural="true" ')
			FILE:write('NetFile="'..self.Struct._FunctionBlock.other.net_file..'"')
		end	
		FILE:write('>\n')
		FILE:write('\t</CompilerInfo>\n')
		FILE:write('\t<InterfaceList>\n')
		FILE:write('\t\t<EventInputs>\n')
		for i, v in ipairs(self.Struct._FunctionBlock.ineventlist) do
			FILE:write('\t\t\t<Event Name="'..v..'" ')	
			if self.Struct._FunctionBlock.other[v].Comment then
				FILE:write('Comment="'..self.Struct._FunctionBlock.other[v].Comment..'" ')	
			end
			FILE:write('>\n')
			if self.Struct._FunctionBlock.with[v] then
				for j, k in ipairs(self.Struct._FunctionBlock.with[v]) do
					FILE:write('\t\t\t\t<With Var="'..k..'" />\n')	
				end
			end
			FILE:write('\t\t\t</Event>\n')
		end
		FILE:write('\t\t</EventInputs>\n')
		FILE:write('\t\t<EventOutputs>\n')
		for i, v in ipairs(self.Struct._FunctionBlock.outeventlist) do
			FILE:write('\t\t\t<Event Name="'..v..'" ')	
			if self.Struct._FunctionBlock.other[v].Comment then
				FILE:write('Comment="'..self.Struct._FunctionBlock.other[v].Comment..'" ')	
			end
			FILE:write('>\n')
			if self.Struct._FunctionBlock.with[v] then
				for j, k in ipairs(self.Struct._FunctionBlock.with[v]) do
					FILE:write('\t\t\t\t<With Var="'..k..'" />\n')	
				end
			end
			FILE:write('\t\t\t</Event>\n')
		end
		FILE:write('\t\t</EventOutputs>\n')
		FILE:write('\t\t<InputVars>\n')
		for i, v in ipairs(self.Struct._FunctionBlock.invarlist) do
			FILE:write('\t\t\t<VarDeclaration Name="'..v..'" Type="'..self.Struct._FunctionBlock.other.Type[v]..'" ')
			if self.Struct._FunctionBlock.other.ArraySize2[v] then
				FILE:write('ArraySize="'..self.Struct._FunctionBlock.other.ArraySize2[v]..'" ')
			end
			if self.Struct._FunctionBlock.other.InitialValue[v] then
				FILE:write('InitialValue="'..self.Struct._FunctionBlock.other.InitialValue[v]..'" ')
			end
			if self.Struct._FunctionBlock.other.Comment[v] then
				FILE:write('Comment="'..self.Struct._FunctionBlock.other.Comment[v]..'" ')
			end
			FILE:write('/>\n')
		end
		FILE:write('\t\t</InputVars>\n')
		FILE:write('\t\t<OutputVars>\n')
		for i, v in ipairs(self.Struct._FunctionBlock.outvarlist) do
			FILE:write('\t\t\t<VarDeclaration Name="'..v..'" Type="'..self.Struct._FunctionBlock.other.Type[v]..'" ')
			if self.Struct._FunctionBlock.other.ArraySize2[v] then
				FILE:write('ArraySize="'..self.Struct._FunctionBlock.other.ArraySize2[v]..'" ')
			end
			if self.Struct._FunctionBlock.other.InitialValue[v] then
				FILE:write('InitialValue="'..self.Struct._FunctionBlock.other.InitialValue[v]..'" ')
			end
			if self.Struct._FunctionBlock.other.Comment[v] then
				FILE:write('Comment="'..self.Struct._FunctionBlock.other.Comment[v]..'" ')
			end
			FILE:write('/>\n')
		end
		FILE:write('\t\t</OutputVars>\n')
		FILE:write('\t</InterfaceList>\n')
		if self.Struct._FunctionBlock.Class == 'ServiceInterface' then
			FILE:write('\t<Service RightInterface="'..self.Struct._FunctionBlock.Service.RightInterface..'" ')
			FILE:write('LeftInterface="'..self.Struct._FunctionBlock.Service.LeftInterface..'" ')
			if self.Struct._FunctionBlock.Service.Comment then
				FILE:write('Comment="'..self.Struct._FunctionBlock.Service.Comment..'" ')
			end
			FILE:write('>\n')
			for i, v in ipairs(self.Struct._FunctionBlock.ServiceSequences) do
				FILE:write('\t\t<ServiceSequence Name="'..v.Name..'" >\n')
				for j, k in ipairs(v.Transactions) do
					FILE:write('\t\t\t<ServiceTransaction>\n')
					FILE:write('\t\t\t\t<InputPrimitive Interface="'..k.InputPrimitive.Interface..'" ')
					if k.InputPrimitive.Event then
						FILE:write('Event="'..k.InputPrimitive.Event..'" ')
					end
					if(k.InputPrimitive.Parameters) then
						FILE:write('Parameters="'..k.InputPrimitive.Parameters..'" ')
					end
					if(k.InputPrimitive.Comment) then
						FILE:write('Comment="'..k.InputPrimitive.Comment..'" ')
					end
					FILE:write('/>\n')
					FILE:write('\t\t\t\t<OutputPrimitive Interface="'..k.OutputPrimitive.Interface..'" ')
					if k.OutputPrimitive.Event then
						FILE:write('Event="'..k.OutputPrimitive.Event..'" ')
					end
					if(k.OutputPrimitive.Parameters) then
						FILE:write('Parameters="'..k.OutputPrimitive.Parameters..'" ')
					end
					if(k.OutputPrimitive.Comment) then
						FILE:write('Comment="'..k.OutputPrimitive.Comment..'" ')
					end
					FILE:write('/>\n')
					FILE:write('\t\t\t</ServiceTransaction>\n')
				end
				FILE:write('\t\t</ServiceSequence>\n')
			end
			FILE:write('\t</Service>\n')
		elseif self.Struct._Type == 'BlockView' then
			FILE:write('\t<BasicFB>\n')
			FILE:write('\t\t<ECC>\n')
			for i, v in pairs(self.Struct._FunctionBlock.stlist) do
				FILE:write('\t\t\t<ECState Name="'..i..'" ')
				if(self.Struct._FunctionBlock.STdx[i]) then
					FILE:write('x="'..self.Struct._FunctionBlock.STdx[i]..'" ')
				end
				if(self.Struct._FunctionBlock.STdy[i]) then
					FILE:write('y="'..self.Struct._FunctionBlock.STdy[i]..'" ')
				end
				FILE:write(' >\n')
				for j, k in ipairs(v.action) do
					FILE:write('\t\t\t\t<ECAction ')
					if(k.alg) then
						FILE:write('Algorithm="'..k.alg..'" ')
					end
					if(k.out) then
						FILE:write('Output="'..k.out..'" ')
					end
					FILE:write('/>\n')
				end
				FILE:write('\t\t\t</ECState>\n')
			end
			for i, v in ipairs(self.Struct._FunctionBlock.transitions) do
				local aux = v.Condition
				aux = aux:gsub('&', '&#38;')
				FILE:write('\t\t\t<ECTransition Source="'..v.Source..'" Destination="'..v.Destination..'" Condition="'..aux..'" />\n')
			end
			FILE:write('\t\t</ECC>\n')
			for i, v in pairs(self.Struct._FunctionBlock.FW_Alg) do
				FILE:write('\t\t<Algorithm Name="'..i..'" ')
				if self.Struct._FunctionBlock.other.Comment.Alg[i] then
					FILE:write('Comment="'..self.Struct._FunctionBlock.other.Comment.Alg[i]..'" >\n')
				else
					FILE:write(' >\n')
				end
				FILE:write('\t\t\t<Lua Text="'..v..'" />\n')
				FILE:write('\t\t</Algorithm>\n')
			end
			FILE:write('\t</BasicFB>\n')
		
		else
			FILE:write('\t<FBNetwork>\n')
			for i, v in ipairs (self.Struct._FunctionBlock.FBNetwork) do
				FILE:write('\t\t<FB Name="'..v[1]..'" Type="'..self.Struct._FunctionBlock[v[1]].FBType..'" x="'..self.Struct._FunctionBlock[v[1]].dx..'" y="'..self.Struct._FunctionBlock[v[1]].dy..'" />\n')
			end
			FILE:write('\t\t<EventConnections>\n')
			for i, v in pairs(self.Struct._FunctionBlock.EventConnections) do
				for j, k in pairs(v) do
					FILE:write('\t\t\t<Connection Source="')
					if(i ~='self') then
						FILE:write(i..'.'..j..'" ')
					else
						FILE:write(j..'" ')
					end
					FILE:write('Destination="')
					if k[1] ~= 'self' then
						FILE:write(k[1]..'.'..k[2]..'" ')
					else
						FILE:write(k[2]..'" ')
					end
					FILE:write('/>\n')
				end
			end
			FILE:write('\t\t</EventConnections>\n')
			FILE:write('\t\t<DataConnections>\n')
			for i, v in pairs(self.Struct._FunctionBlock.DataConnections) do
				for j, k in pairs(v) do
					FILE:write('\t\t\t<Connection Source="')
					if k[1] ~= 'self' then
						FILE:write(k[1]..'.'..k[2]..'" ')
					else
						FILE:write(k[2]..'" ')
					end
					FILE:write('Destination="')
					if(i ~='self') then
						FILE:write(i..'.'..j..'" ')
					else
						FILE:write(j..'" ')
					end
					
					FILE:write('/>\n')
				end
			end
			FILE:write('\t\t</DataConnections>\n')
			FILE:write('\t</FBNetwork>\n')
		end
		FILE:write('</FBType>')
	elseif self.Struct._Type == 'ResourceView' then
		FILE:write('<?xml version="1.0" encoding="UTF-8"?>'..'\n'..'<!DOCTYPE ResourceType >\n')
		FILE:write('<ResourceType Name="'..self.Struct._FunctionBlock.FBType..'" ')
		if self.Struct._FunctionBlock.ResourceTypeComment then
			FILE:write('Comment= "'..self.Struct._FunctionBlock.ResourceTypeComment..'" ')
		end
		FILE:write('>\n')
		FILE:write('\t<Identification Standard="'..self.Struct._FunctionBlock._Standard..'"/>\n')
		FILE:write('\t<VersionInfo ')
		if self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Organization then
			FILE:write('Organization="'..self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Organization..'" ')
		end
		if self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Version then
			FILE:write('Version="'..self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Version..'" ')
		end
		if self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Author then
			FILE:write('Author="'..self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Author..'" ')
		end
		if self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Date then
			FILE:write('Date="'..self.Struct._FunctionBlock.other.Version[#self.Struct._FunctionBlock.other.Version].Date..'" ')
		FILE:write('/>\n')
		end
		FILE:write('\t<CompilerInfo') 
		if self.Struct._FunctionBlock.other.IsLua then
			FILE:write(' IsLua="true"'..' ')
		end
		if self.Struct._FunctionBlock.other.BaseFile then
			FILE:write('BaseFile="'..self.Struct._FunctionBlock.other.BaseFile..'" ')
		end	
		FILE:write('>\n')
		FILE:write('\t</CompilerInfo>\n')
		for i, v in ipairs(self.Struct._FunctionBlock._varlist) do
			FILE:write('\t<VarDeclaration Name="'..v.Name..'" Type="'..v.Type..'" ')
			if v.ArraySize then
				FILE:write('ArraySize="'..v.ArraySize..'" ')
			end
			if v.InitialValue then
				FILE:write('InitialValue="'..v.InitialValue..'" ')
			end
			if v.Comment then
				FILE:write('Comment="'..v.Comment..'" ')
			end
			FILE:write('/>\n')
		end
		FILE:write('\t<FBNetwork>\n')
		for i, v in ipairs(self.Struct._FunctionBlock.FBNetwork) do
			FILE:write('\t\t<FB Name="'..v.Name..'" Type="'..v.Type..'" x="'..self.Struct._FunctionBlock[v[1]].dx..'" y="'..self.Struct._FunctionBlock[v[1]].dy..'" ')
			if v.Comment then
				FILE:write('Comment="'..v.Comment..'" ')
			end
			FILE:write('>\n')
			if self.Struct._FunctionBlock._Parameters[v.Name] then
				for j, k in ipairs(self.Struct._FunctionBlock._Parameters[v.Name]) do
					FILE:write('\t\t\t<Parameter Name="'..k.Name..'" Value="'..k.Value..'" ')
					if k.Comment then
						FILE:write('Comment="'..k.Comment..'" ')
					end
					FILE:write('/>\n')
				end
			end
			FILE:write('\t\t</FB>\n')
		end
		FILE:write('\t\t<EventConnections>\n')
			for i, v in pairs(self.Struct._FunctionBlock.EventConnections) do
				for j, k in pairs(v) do
					FILE:write('\t\t\t<Connection Source="')
					if(i ~='self') then
						FILE:write(i..'.'..j..'" ')
					else
						FILE:write(j..'" ')
					end
					FILE:write('Destination="')
					if k[1] ~= 'self' then
						FILE:write(k[1]..'.'..k[2]..'" ')
					else
						FILE:write(k[2]..'" ')
					end
					FILE:write('/>\n')
				end
			end
			FILE:write('\t\t</EventConnections>\n')
			FILE:write('\t\t<DataConnections>\n')
			for i, v in pairs(self.Struct._FunctionBlock.DataConnections) do
				for j, k in pairs(v) do
					FILE:write('\t\t\t<Connection Source="')
					if k[1] ~= 'self' then
						FILE:write(k[1]..'.'..k[2]..'" ')
					else
						FILE:write(k[2]..'" ')
					end
					FILE:write('Destination="')
					if(i ~='self') then
						FILE:write(i..'.'..j..'" ')
					else
						FILE:write(j..'" ')
					end
					
					FILE:write('/>\n')
				end
			end
			FILE:write('\t\t</DataConnections>\n')
		FILE:write('\t</FBNetwork>\n')
		FILE:write('</ResourceType>\n')
	elseif self.Struct._Type == 'DeviceView' then
		FILE:write('<?xml version="1.0" encoding="UTF-8"?>'..'\n'..'<!DOCTYPE DeviceType SYSTEM "FBSystem.dtd">\n')
		FILE:write('<DeviceType Name="'..self.Struct._FunctionBlock.DeviceType..'" ')
		if self.Struct._FunctionBlock.DeviceTypeComment then
			FILE:write('Comment="'..self.Struct._FunctionBlock.DeviceTypeComment..'" ')
		end
		FILE:write('>\n')
		
		if(self.Struct._FunctionBlock._Standard) then
			FILE:write('\t<Identification Standard="'..self.Struct._FunctionBlock._Standard..'" />\n')
		end
		FILE:write('\t<VersionInfo ')
		if(self.Struct._FunctionBlock._VersionInfo) then
			for i, v in pairs(self.Struct._FunctionBlock._VersionInfo) do
				FILE:write(i..'="'..v..'" ')
			end
		end
		FILE:write('/>\n')
		for i, v in ipairs(self.Struct._FunctionBlock.FBNetwork) do
			FILE:write('\t<Resource Name="'..v.Name..'" Type="'..v.Type..'" dx="'..v.x..'" dy ="'..v.y..'" ')
			if v.Comment then
				FILE:write('Comment="'..v.Comment..'" ')
			end	
			FILE:write('>\n')
			--~ escrever todos os Resources
			FILE:write('\t</Resource>\n')
		end
		FILE:write('</DeviceType>\n')
	elseif self.Struct._Type == 'SystemView' then
		FILE:write('<?xml version="1.0" encoding="UTF-8"?>'..'\n'..'<!DOCTYPE RSystem SYSTEM "FBSystem.dtd">\n')
		FILE:write('<System Name="'..self.Struct._FunctionBlock.SystemType..'" ')
		if self.Struct._FunctionBlock.SystemTypeComment then
			FILE:write('Comment="'..self.Struct._FunctionBlock.SystemTypeComment..'" ')
		end
		FILE:write('>\n')
		FILE:write('\t<Identification Standard="'..self.Struct._FunctionBlock._Standard..'" />\n')
		FILE:write('\t<VersionInfo ')
		for i, v in pairs(self.Struct._FunctionBlock._VersionInfo) do
			FILE:write(i..'="'..v..'" ')
		end
		FILE:write('/>\n')
		for i, v in ipairs(self.Struct._FunctionBlock.DeviceList) do
			FILE:write('\t<Device Name="'..v[1].label..'" Type="'..v[1].DeviceType..'" x="'..v[2]..'" y ="'..v[3]..'" ')
			if v.Comment then
				FILE:write('Comment="'..v.Comment..'" ')
			end	
			FILE:write('>\n')
			if(type(self.Struct._FunctionBlock[v[1].label].ResourceList)=='table') then
				for j, k in ipairs(self.Struct._FunctionBlock[v[1].label].ResourceList) do
					FILE:write('\t\t<Resource Name="'..k[1].label..'" Type="'..k[1].ResourceType..'" x="'..k[2]..'" y ="'..k[3]..'" ')
					if k.Comment then
						FILE:write('Comment="'..k.Comment..'" ')
					end	
					FILE:write('>\n')
					if self.Struct._FunctionBlock._Parameters[v.Name] and self.Struct._FunctionBlock._Parameters[v.Name][k.Name] then
						for a, b in ipairs(self.Struct._FunctionBlock._Parameters[v.Name][k.Name]) do
							FILE:write('\t\t\t<Parameter Name="'..b.Name..'" Value="'..b.Value..'" ')
							if b.Comment then
								FILE:write('Comment="'..b.Comment..'" ')
							end
							FILE:write('/>\n')
						end
					end
					FILE:write('\t\t</Resource>\n')
				end
			end
			--~ escrever todos os Resources
			FILE:write('\t</Device>\n')
		end
		FILE:write('</System>\n')
	end
	FILE:close()
end
