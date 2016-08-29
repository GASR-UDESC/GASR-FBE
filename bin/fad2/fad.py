"""
	CREATE INSTANCE
	{"name"="<instance name>", "type"="<type name>",
	 "device"=<device num>, "resource"=<res num>,
	 "command"=C_CREATE_INSTANCE}
	
	CREATE CONNECTION
	{"from_fb"="<instance name>", "from_var"=<var pos>,
	 "to_fb"="<instance name>", "to_var"=<var pos>,
	 "device"=<device num>, "resource"=<res num>,
	 "size" = <number>,
	 "mvalue"=<value>, //opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent"=<bool>,
	 "command"=C_CREATE_CONNECTION}
	 
	 
	

"""

import sys

from xml.dom.minidom import parse, parseString
import iecvmnet as inet
from time import sleep

C_CREATE_INSTANCE = 10
C_CREATE_CONNECTION = 20
C_DELETE_INSTANCE = 30
C_DELETE_CONNECTION = 35
C_SET_INSTANCE_STATE = 40

ST_RUN = 0x01
ST_STOP = 0x03

dir_asm = "."

def setDir(dir):
	global dir_asm
	dir_asm = dir;
	print "Ex.: '.../myDir'. Without '/' at the end."
	


p_exit = False

commands = [
#{"command": C_CREATE_INSTANCE, "name": "control1", "device":10, "resource": 0, "type": "CONTROL2"}

{"command": C_CREATE_INSTANCE, "name": "start", "device":10, "resource": 0, "type": "START"},
{"command": C_CREATE_INSTANCE, "name": "led1", "device": 10, "resource": 0, "type": "IO_WRITER"},
{"command": C_CREATE_INSTANCE, "name": "sub1", "device": 10, "resource": 0, "type": "SUB_2"},
{"command":C_CREATE_CONNECTION, "from_fb":"start", "from_var":"COLD",
	 "to_fb":"sub1", "to_var":"INIT",
	 "device":10, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"sub1", "from_var":"INIT0",
	 "to_fb":"led1", "to_var":"INIT",
	 "device":10, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"sub1", "from_var":"RSP",
	 "to_fb":"led1", "to_var":"REQ",
	 "device":10, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"sub1", "from_var":"SD_1",
	 "to_fb":"led1", "to_var":"SD_2",
	 "device":10, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":0
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"-001", "from_var":0,
	 "to_fb":"sub1", "to_var":"ID",
	 "device":10, "resource":0,
	 "size" : 1,
	 "mvalue":30,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":0
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"-002", "from_var":0,
	 "to_fb":"led1", "to_var":"SD_1",
	 "device":10, "resource":0,
	 "size" : 1,
	 "mvalue":1,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":0
	 },
{"command": C_CREATE_INSTANCE, "name": "start", "device":20, "resource": 0, "type": "START"},
{"command": C_CREATE_INSTANCE, "name": "split1", "device": 20, "resource": 0, "type": "E_SPLIT"},
{"command": C_CREATE_INSTANCE, "name": "split2", "device": 20, "resource": 0, "type": "E_SPLIT"},
{"command": C_CREATE_INSTANCE, "name": "bt1", "device": 20, "resource": 0, "type": "IO_READER"},
{"command": C_CREATE_INSTANCE, "name": "led1", "device": 20, "resource": 0, "type": "IO_WRITER"},
{"command": C_CREATE_INSTANCE, "name": "pub2", "device": 20, "resource": 0, "type": "PUB_2"},
{"command":C_CREATE_CONNECTION, "from_fb":"start", "from_var":"COLD",
	 "to_fb":"split1", "to_var":"EI1",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"split1", "from_var":"EO1",
	 "to_fb":"bt1", "to_var":"INIT",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"split1", "from_var":"EO2",
	 "to_fb":"pub2", "to_var":"INIT",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"bt1", "from_var":"INIT0",
	 "to_fb":"led1", "to_var":"INIT",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"bt1", "from_var":"IND",
	 "to_fb":"split2", "to_var":"EI1",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },	
{"command":C_CREATE_CONNECTION, "from_fb":"split2", "from_var":"EO1",
	 "to_fb":"led1", "to_var":"REQ",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"split2", "from_var":"EO2",
	 "to_fb":"pub2", "to_var":"REQ",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"led1", "from_var":"INIT0",
	 "to_fb":"bt1", "to_var":"RSP",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"led1", "from_var":"CNF",
	 "to_fb":"bt1", "to_var":"RSP",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":1
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"bt1", "from_var":"RD_1",
	 "to_fb":"pub2", "to_var":"RD_1",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":0
	 },
{"command":C_CREATE_CONNECTION, "from_fb":"bt1", "from_var":"RD_1",
	 "to_fb":"led1", "to_var":"SD_2",
	 "device":20, "resource":0,
	 "size" : 1,
	 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":0
	 },	 
{"command":C_CREATE_CONNECTION, "from_fb":"-002", "from_var":0,
	 "to_fb":"led1", "to_var":"SD_1",
	 "device":20, "resource":0,
	 "size" : 1,
	 "mvalue":1,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":0
	 }, 
{"command":C_CREATE_CONNECTION, "from_fb":"-003", "from_var":0,
	 "to_fb":"bt1", "to_var":"SD_1",
	 "device":20, "resource":0,
	 "size" : 1,
	 "mvalue":21,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":0
	 }, 
{"command":C_CREATE_CONNECTION, "from_fb":"-004", "from_var":0,
	 "to_fb":"pub2", "to_var":"ID",
	 "device":20, "resource":0,
	 "size" : 1,
	 "mvalue":30,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
	 "isEvent":0
	 }, 
{"command": C_SET_INSTANCE_STATE, "device": 20, "resource":0, "name": "pub2", "state": ST_RUN},
{"command": C_SET_INSTANCE_STATE, "device": 20, "resource":0, "name": "led1", "state": ST_RUN},
{"command": C_SET_INSTANCE_STATE, "device": 20, "resource":0, "name": "bt1", "state": ST_RUN},
{"command": C_SET_INSTANCE_STATE, "device": 20, "resource":0, "name": "split1", "state": ST_RUN},
{"command": C_SET_INSTANCE_STATE, "device": 20, "resource":0, "name": "split2", "state": ST_RUN},
{"command": C_SET_INSTANCE_STATE, "device": 20, "resource":0, "name": "start", "state": ST_RUN},
{"command": C_SET_INSTANCE_STATE, "device": 10, "resource":0, "name": "led1", "state": ST_RUN},
{"command": C_SET_INSTANCE_STATE, "device": 10, "resource":0, "name": "sub1", "state": ST_RUN},
{"command": C_SET_INSTANCE_STATE, "device": 10, "resource":0, "name": "start", "state": ST_RUN}
]

import json

def printCommandsFile(fname):
	f = open(fname,"w")
	f.write(json.dumps(commands))

def loadCommandsFile(fname):
	f = open(fname, "r")
	return json.loads(f.read())

def printCommands():
	cName = {C_CREATE_INSTANCE:"CREATE_INSTANCE", 
		C_CREATE_CONNECTION:"CREATE_CONNECTION", 
		C_DELETE_INSTANCE: "DELETE_INSTANCE",
		C_DELETE_CONNECTION: "DELETE_CONNECTION",
		C_SET_INSTANCE_STATE: "SET_INSTANCE_STATE"}
	print "      COMMANDS"
	print "========================================================"
	i = 0
	for c in commands:
		if(c["command"] == C_CREATE_INSTANCE):
			print "%d. %s %s of %s on D%d R%d" % (i, cName[c["command"]], c["name"], c["type"], c["device"], c["resource"])
		if(c["command"] == C_CREATE_CONNECTION):
			s = "VAR"
			if(c["isEvent"] == 1):
				s = "EVT"
			print "%d. %s %s from %s.%s to %s.%s D%d R%d" % (i, cName[c["command"]], s, c["from_fb"], c["from_var"], c["to_fb"], c["to_var"], c["device"], c["resource"])
		if(c["command"] == C_DELETE_INSTANCE):
			print "%d. %s %s on D%d R%d" % (i, cName[c["command"]], c["name"], c["device"], c["resource"])
		if(c["command"] == C_DELETE_CONNECTION):
			print "%d. %s from %s.%s to %s.%s D%d R%d" % (i, cName[c["command"]], c["from_fb"], c["from_var"], c["to_fb"], c["to_var"], c["device"], c["resource"])
		if(c["command"] == C_SET_INSTANCE_STATE):
			print "%d. SET_INSTANCE_STATE %s to state %d" % (i, c["name"], c["state"])
		i = i + 1
	print "========================================================"

	

def printCommandsHuman():
	f = open('commandsHuman.txt', 'w')
	lines = []
	cName = {C_CREATE_INSTANCE:"Criar instancia", 
		C_CREATE_CONNECTION:"Criar conexao", 
		C_DELETE_INSTANCE: "Excluir instancia",
		C_DELETE_CONNECTION: "Excluir conexao",
		C_SET_INSTANCE_STATE: "Alterar estado da instancia"}
	lines.append( "      COMMANDS")
	lines.append("========================================================")
	i = 1
	for c in commands:
		if(c["command"] == C_CREATE_INSTANCE):
			lines.append( "%d. %s '%s' de '%s' em D%d R%d" % (i, cName[c["command"]], c["name"], c["type"], c["device"], c["resource"]))
		if(c["command"] == C_CREATE_CONNECTION):
			s = "(dados)"
			if(c["isEvent"] == 1):
				s = "(evento)"
			lines.append("%d. %s %s de %s.%s para %s.%s em D%d R%d" % (i, cName[c["command"]], s, c["from_fb"], c["from_var"], c["to_fb"], c["to_var"], c["device"], c["resource"]))
		if(c["command"] == C_DELETE_INSTANCE):
			lines.append("%d. %s %s em D%d R%d" % (i, cName[c["command"]], c["name"], c["device"], c["resource"]))
		if(c["command"] == C_DELETE_CONNECTION):
			lines.append("%d. %s de %s.%s para %s.%s em D%d R%d" % (i, cName[c["command"]], c["from_fb"], c["from_var"], c["to_fb"], c["to_var"], c["device"], c["resource"]))
		if(c["command"] == C_SET_INSTANCE_STATE):
			lines.append("%d. Alterar estado do bloco '%s' para %d em D%d R%d" % (i, c["name"], c["state"], c["device"], c["resource"]))
		i = i + 1
	lines.append("========================================================")
	for l in lines:
		f.write(l+'\n')
	
isInit = False	
def init(host="10.20.211.32", port=5200):
	global isInit
	inet.init(host, port)
	isInit = True
	

def str2hex(str):
	h = ""
	for c in str:
		h = h + "%02X" % (ord(c))
	return h

def readFile(f):
	pass


def waitMsg():
	#print "WaitMsg "
	count = 10
	count2 = 0
	r = inet.recv()	
	while(r == None and count > 0):
		sleep(0.1)
		r = inet.recv()		
		#print ".",
		count2 = count2 + 1
		if(count2 >= 10):
			count = count - 1
			count2 = 0
	return r
	
def waitOk():
	print "Wait "
	count = 10
	count2 = 0
	r = inet.recv()	
	while(r == None and count > 0):
		sleep(0.1)
		r = inet.recv()		
		print ".",
		count2 = count2 + 1
		if(count2 >= 10):
			count = count - 1
			count2 = 0
	if( r == "#01DA0A$"):
		return True
	return False


def getVarsOfFb(fbname):
	f = open(dir_asm+'/'+fbname+'.map')
	v = f.read()
	v2 = v.split(',')
	vars={}
	for i in v2:
		if(len(i)>2):
			st = i.split(':')
			if(len(st) > 1):
				st[0] = st[0].replace('\r','')
				st[0] = st[0].replace('\n', '')
				#print st
				vars[st[0]] = {"pos": int(st[1]), "size": int(st[2]) }
			
	return vars
	
types= {}
varpos={}
	
def setAllVarPos():
	#types= {}
	#varpos={}
	global types
	global varpos
	for i in range(len(commands)):
		if(commands[i]["command"] == C_CREATE_INSTANCE):
			types[commands[i]["name"]] = commands[i]["type"]
			varpos[commands[i]["type"]] = getVarsOfFb(commands[i]["type"])
		if(commands[i]["command"] == C_CREATE_CONNECTION):
			if(not (type(commands[i]["from_var"]) is int)):
				commands[i]["from_var"] = varpos[types[commands[i]["from_fb"]]][commands[i]["from_var"]]["pos"]
			if(not (type(commands[i]["to_var"]) is int)):
				commands[i]["to_var"] = varpos[types[commands[i]["to_fb"]]][commands[i]["to_var"]]["pos"]
			

	#print "setAllVarPos() nao implementado."
	#eloaexit()
	
	
def devHasFbType(device, type):
	data = type
	s = len(data)
	#s+2 command+type+00
	msg = "#%02XD6%s00$" % (device, str2hex(type))
	print "Send1: ",msg
	inet.send(msg)
	return waitOk()
	#inet.send()
	
def devSendFb(device, type):
	f = open(dir_asm+'/'+type+'.hex')
	t = f.read()
	bytes = t.split(' ')
	#create the block
	msg = "#%02XD1%s00%04X$" % (device, str2hex(type), len(bytes))
	print "Send2: ",msg
	inet.send(msg)
	if(not waitOk()):
		return False
	#write on block
	pos = 0;
	er_count = 0;
	while(len(bytes)>0):
		#print "--> ",bytes
		c = 0;
		bs = bytes[0:10]
		data=""
		for b in bs:
			if(len(b) > 0 and b !=''):
				data = data + "%02X" % (int(b))
				c = c + 1
		if(c==0): 
			return True
		msg="#%02XD2%s00%04X%02X%s$" % (device, str2hex(type), pos, c, data)
		#msg = msg+'$'		
		print "Send3: ", msg
		inet.send(msg)
		if(waitOk()):
			#del bytes[0:10]
			bytes = bytes[10:]
			pos = pos + c
			er_count = 0
		else:
			er_count = er_count + 1
			if(er_count > 3):
				return False
		
	return True

def devNewInst(device, resource, name, type):
	msg = "#%02XD3%s00%s00%02X$" % (device, str2hex(type), str2hex(name), resource)
	print "Send4: ", msg
	inet.send(msg)
	if(waitOk()):
		return True
	return False
	
def devDelInstance(device, resource, name):
	msg = "#%02XE3%s00%02X$" % (device, str2hex(name), resource)
	print "Send6: ", msg
	inet.send(msg)
	if(waitOk()):
		return True
	return False

def devDelConnection(device, resource, from_fb, from_var, to_fb, to_var):
	msg="#%02XE4%s00%02X%s00%02X%02X$" % (device, from_fb, from_var, to_fb, to_var, resource)
	print "Send7: ",msg
	if(waitOk()):
		return True
	return False
	
def devNewCon(device, resource, from_fb, from_var, to_fb, to_var, size, isEvent, mvalue=None):
	value=""
	if(mvalue==None):
		value=""
	else:
		if(type(mvalue) is int):
			value= "%02X" % (mvalue)
			print "Value = ", value
		else:
			value= "%02X" % (int(mvalue))
			print "Value = ", value
			#print "Only integers are supported for conection with a constant."
			#return
	msg = "#%02XD4%s00%02X%s00%02X%02X%02X%02X%s$" % (device, str2hex(from_fb), from_var, str2hex(to_fb), to_var, size,resource,isEvent,value)
	print "Send5: ", msg
	inet.send(msg)
	if(waitOk()):
		return True
	return False
	
def devStFbState(device, resource, fbname, state):
	msg = "#%02XD7%s00%02X%02X$" % (device, str2hex(fbname), state, resource)
	print "Send7: ", msg
	inet.send(msg)
	if(waitOk()):
		return True
	return False
	
def devGetFbState(device, resource, fbname, fbtype):
	msg = "#%02XD8%s00%02X$" % (device, str2hex(fbname), resource)
	#print "Send8: ", msg
	inet.send(msg)
	msg = waitMsg()
	
	#print msg
	msgo = ''
	if(msg != None):
		vars = getVarsOfFb(fbtype)
		for k,v in vars.iteritems():
			if(k[0] != '_' and k[1] != '_'):
				d = ''
				t = 0
				while(t < v['size']):
					d = d + msg[vars[k]['pos']*2+5] + msg[vars[k]['pos']*2+5+1]
					t = t + 1
				
				msgo = msgo + "%s %d\n" % (k, int(d,16))
		
	return msgo[:len(msgo)-1]+''
	
def devClear(device):
	msg = "#%02XD9$" % (device)
	inet.send(msg)
	if(waitOk()):
		return True
	return False
	
def executeCommands():
	i=0
	for c in commands:
		if(c["command"] == C_CREATE_INSTANCE):
			print "Creating instance ",c["name"]," of type ", c["type"]
			if(not devHasFbType(c["device"], c["type"])):
				if(not devSendFb(c["device"], c["type"])):
					print "FB ",c["type"], " not accepted by MV."
					return
				print "...New type added to device ",c["device"]
			devNewInst(c["device"], c["resource"], c["name"], c["type"])
		if(c["command"]==C_SET_INSTANCE_STATE):
			if(devStFbState(c["device"], c["resource"], c["name"], c["state"])):
				print "OK"
			else:
				print "ERROR"
		if(c["command"]==C_CREATE_CONNECTION):
			print "Creating connection..."
			if("mvalue" in c):
				devNewCon(c["device"], c["resource"], c["from_fb"], c["from_var"], c["to_fb"], c["to_var"],c["size"], c["isEvent"], c["mvalue"])
			else:
				devNewCon(c["device"], c["resource"], c["from_fb"], c["from_var"], c["to_fb"], c["to_var"],c["size"], c["isEvent"])
		if(c["command"] == C_DELETE_INSTANCE):
			print "Deleting instance...",
			if(devDelInstance(c["device"], c["resource"], c["name"])):
				print "OK"
			else:
				print "ERROR"
		if(c["command"] == C_DELETE_CONNECTION):
			print "Deleting connection...",
			if(devDelConnection(c["device"], c["resource"], c["from_fb"], c["from_var"], c["to_fb"], c["to_var"])):
				print "OK"
			else:
				print "ERROR"
		
			
	print "Updated."

	
def connect():
	global isInit
	if(not isInit):
		init('10.20.211.32', 5200)
		isInit = True

def run():
	global isInit
	if(not isInit):
		init('10.20.211.32', 5200)
		isInit = True
	setAllVarPos()
	executeCommands()
	
def run2():
	commands = [{"command": C_DELETE_INSTANCE, "name": "control1", "device":10, "resource": 0}]
	setAllVarPos()
	executeCommands()
	
def clear():
	global commands
	commands = []
	
	
def newCom(c):
	global commands
	commands.append(c)
	

Device = 10
Resource = 0
	
def console():
	global Device
	global Resource
	global commands
	c = 100
	while(int(c)!=0):
		print " "
		print " "
		print " "
		printCommands()
		cmd  = {"device":Device, "resource":Resource}
		print "1.   Create Instance"
		print "2.   Create Connection"
		print "3.   Set Instance State"
		print "4.   Delete Instance"
		print "5.   Delete Connection"
		print "6.   Set Device"
		print "7.   Set Resource"
		print "8.   Get FB data"
		print "9.   Save List"
		print "10.   Load List"
		print " "
		print "100. Execute Commands"
		print " "
		print "0.   Exit console"
		print " "
		print "Command on Device %d, Resource %d: " % (int(Device), int(Resource)),
		c = raw_input()
		
		if(int(c) == 100):
			run()
		
		if(int(c) == 6):
			print "Device Address: ",		
			Device = int(raw_input())
		if(int(c) == 7):
			print "Resource Number: ",		
			Resource = int(raw_input())
		if(int(c) == 8):
			print "FB instance name: "
			print devGetFbState(int(Device), int(Resource), fbname)
		if(int(c) == 9):
			print "File Name: ",
			printCommandsFile(raw_input())
		if(int(c) == 10):
			print "File Name: ",
			commands = loadCommandsFile(raw_input())
		if(int(c) == 1):
			cmd["command"] = C_CREATE_INSTANCE
			print "Create Instance"
			print "Instance 'Name:Type' ( no spaces or ' ): ",
			cmd["name"] = raw_input()
			s = cmd["name"].split(':')
			cmd["name"] = s[0]
			cmd["type"] = s[1]
			
			#print "Instance Type: ",
			#cmd["type"] = raw_input()
				
			commands.append(cmd)
			
		if(int(c) == 2):
			cmd["command"] = C_CREATE_CONNECTION
			print "Create Connection"
			print "From instance.var: ",
			cmd["from_fb"] = raw_input()
			if(cmd["from_fb"][0] == "-"):
				print "Var size: ",
				cmd["size"] = int(raw_input())
				print "Var Value: ",
				cmd["mvalue"] = int(raw_input())
				cmd["from_var"] = 0
			else:
				s = cmd["from_fb"].split('.')
				cmd["from_fb"] = s[0]
				cmd["from_var"] = s[1]
				#print "From Var: ",
				#cmd["from_var"] = raw_input()
				cmd["size"] = 1
			print "To instance.var: ",
			cmd["to_fb"] = raw_input()
			s = cmd["to_fb"].split('.')
			cmd["to_fb"] = s[0]
			cmd["to_var"] = s[1]
			#print "To Var: ",
			#cmd["to_var"] = raw_input()		
			if(cmd["from_fb"][0] != "-"):
				print "Is Event?: ",
				cmd["isEvent"] = int(raw_input())	
			else:
				cmd["isEvent"] = 0
			
			commands.append(cmd)
		if(int(c) == 3):
			cmd["command"] = C_SET_INSTANCE_STATE
			print "SET INSTANCE STATE"
			print "Instance Name: ",
			cmd["name"] = raw_input()
			print "State (ST_RUN=%d, ST_TOP=%d): " % (ST_RUN, ST_STOP),
			cmd["state"] = int(raw_input())
			
			
			commands.append(cmd)
		if(int(c) == 4):
			cmd["command"] = C_DELETE_INSTANCE
			print "DELETE INSTANCE"
			print "Instance Name: ",
			cmd["name"] = raw_input()
			
			commands.append(cmd)
		
		if(int(c) == 5):
			cmd["command"] = C_DELETE_CONNECTION
			print "Delete Connection"
			print "From instance: ",
			cmd["from_fb"] = raw_input()
			if(cmd["from_fb"][0] == "-"):
				print "Var size: ",
				cmd["size"] = int(raw_input())
				print "Var Value: ",
				cmd["value"] = raw_input()	
				cmd["from_var"] = 0
			else:
				print "From Var: ",
				cmd["from_var"] = raw_input()
				cmd["size"] = 1
			print "To instance: ",
			cmd["to_fb"] = raw_input()
			print "To Var: ",
			cmd["to_var"] = raw_input()		
			
			commands.append(cmd)



	
def fadexit():
	inet.pexit()
	exit(0)	



import sys2cmd	

def printUsage():
	f = open('usage.txt','r')
	lines = f.readlines()
	for l in lines:
		print (l.replace('\n','')).replace('\r','')
	
if __name__ == "__main__":
	if(len(sys.argv) == 1):
		printUsage()
		exit(1)
	
	if(sys.argv[1] == '--system'):
		sys2cmd.SetCompile(True)
		sys2cmd.read(sys.argv[2])
		sys2cmd.printCommandsFile(sys.argv[2].replace('.xml','')+'.cmd')
		sys2cmd.printCommandsHuman(sys.argv[2].replace('.xml','')+'HumanCommands.txt')
	elif(sys.argv[1] == '--clear'):
		connect()
		if(devClear(int(sys.argv[2]))):
			print "Success"
		else:
			print "Error"		
		
	elif(sys.argv[1] == '--load'):
		commands = loadCommandsFile(sys.argv[2])
		run()
	elif(sys.argv[1] == '--get'):
		connect()
		print devGetFbState(int(sys.argv[2]), int(sys.argv[3]), sys.argv[4], sys.argv[5])
	else:
		printUsage()
		

		
		
		
		
		
		
		
		
		
		
		
		
