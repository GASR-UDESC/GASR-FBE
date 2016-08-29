
import xml.etree.ElementTree as ET
import sys
import fb2st
import subprocess
import json

C_CREATE_INSTANCE = 10
C_CREATE_CONNECTION = 20
C_DELETE_INSTANCE = 30
C_DELETE_CONNECTION = 35
C_SET_INSTANCE_STATE = 40

ST_RUN = 0x01
ST_STOP = 0x03


COMPILE = False

commands = []
conection_count = 1

def SetCompile(v):
	global COMPILE
	COMPILE = v

def printCommandsFile(fname):
	global commands
	f = open(fname,"w")
	f.write(json.dumps(commands))
	
def printCommandsHuman(fname=None):
	global commands
	if(fname == None):
		f = open('commandsHuman.txt', 'w')
	else:
		f = open(fname, 'w')
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

def genResCmds(filename, dev, res):
	global commands
	global conection_count
	global COMPILE
	tree = ET.parse(filename+'.xml')
	root = tree.getroot()
	
	startFbs=[]
	otherFbs=[]
	
	if(root.tag != 'ResourceType'):
		print "File %s is not a Resource." % (filename)
		return 0
	fbs = root.find('FBNetwork').findall('FB')	
	for fb in fbs:
	
		if(COMPILE):
			print "Generating ST code for "+fb.get('Type')+"...",
			if(fb2st.read(fb.get('Type')+'.xml')):			
				print 'OK',
				print " > Compiling "+fb.get('Type')+"...",
				r = subprocess.call(["../ieccomp.exe", fb.get('Type')+".st"])
				if(int(r)==0):
					print 'OK'
				else:
					print "ERROR"
			else:
				print "ERROR"
		commands.append({"command": C_CREATE_INSTANCE, "name": fb.get('Name'), "device":dev, "resource": res, "type": fb.get('Type')})
		
		fbset={"command": C_SET_INSTANCE_STATE, "device": dev, "resource":res, "name": fb.get('Name'), "state": ST_RUN}
		if(fb.get('Type') == 'START'):			
			startFbs.append(fbset)
		else:
			otherFbs.append(fbset)
		par = fb.findall('Parameter')
		for p in par:
			commands.append({"command":C_CREATE_CONNECTION, "from_fb":"%04d"%(-conection_count), "from_var":0,
			 "to_fb":fb.get('Name'), "to_var":p.get('Name'),
			 "device":dev, "resource":res,
			 "size" : 1,
			 "mvalue":p.get('Value'),#opcional from-fb passa a ser o nome do arquivo com os dados da constante
			 "isEvent":0
			 })
			conection_count = conection_count + 1
	conevt = root.find('FBNetwork').find('EventConnections').findall('Connection')
	for c in conevt:
		source = c.get('Source').split('.')
		destination = (c.get('Destination')).split('.')
		commands.append({"command":C_CREATE_CONNECTION, "from_fb":source[0], "from_var":source[1],
		 "to_fb":destination[0], "to_var":destination[1],
		 "device":dev, "resource":res,
		 "size" : 1,
		 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
		 "isEvent":1
		 })
	convar = root.find('FBNetwork').find('DataConnections').findall('Connection')
	for c in convar:
		source = (c.get('Source')).split('.')
		destination = (c.get('Destination')).split('.')
		commands.append({"command":C_CREATE_CONNECTION, "from_fb":source[0], "from_var":source[1],
		 "to_fb":destination[0], "to_var":destination[1],
		 "device":dev, "resource":res,
		 "size" : 1,
		 "value":0,#opcional from-fb passa a ser o nome do arquivo com os dados da constante
		 "isEvent":0
		 })
	for fb in otherFbs:
		commands.append(fb)
	for fb in startFbs:
		commands.append(fb)	

def genSys(root):
	dev = root.findall('Device')
	for d in dev:
		dname = d.get('Name')
		dnum = int(dname[3:])
		print "Device ", dnum
		res = d.findall('Resource')
		for r in res:
			rname = r.get('Name')
			rtype = r.get('Type')
			rnum = int(rname[3:])
			
			print "Resource ", rnum
			genResCmds(rtype, dnum, rnum)
	

def read(filename):
	tree = ET.parse(filename)
	root = tree.getroot()
	#log.write('Processing '+filename)
	if(root.tag == 'System'):
		genSys(root)
		return 1
	else:
		print 'File is not a System.'
	return 0
	#print root.tag
	
if __name__ == "__main__":
	if(len(sys.argv) == 1):
		print "Usage: sys2cmd.py System.xml"
		exit(1)
	if('-c' in sys.argv):
		COMPILE = True
	read(sys.argv[1])
	printCommandsHuman()
	printCommandsFile('SystemCommands')