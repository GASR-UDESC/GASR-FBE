
import socket
from threading import Thread
from collections import deque

sock = None
received = deque([])
recv_sem = False
p_exit=False

def send(msg):
	global sock
	sock.send(msg)
	
	

def recv():
	global received
	global recv_sem
	global sock
	server_recv(sock)
	while(recv_sem):
		pass
	
	recv_sem = True
	if(len(received) == 0):
		r = None
	else:
		r = received.popleft()
	recv_sem = False
	return r

def pexit():
	p_exit = True
	
def server_recv(s):
	global received
	global recv_sem
	while not p_exit:		
		msg = s.recv(500)
		
		r = ""
		a = False
		while(len(msg) > 0):
			c = msg[0]			
			if(a):				
				r = r + c
			if(c == '#'):
				a = True
				r = ""
				r = r + c				
			if(c == '$'):
				a = False
				#r = r + c				
				break
			
				
			msg = msg[1:]
		msg = r
		
		#print ">>> ", msg, " -- ", r
		if(len(msg) >0 and msg[0]=='#' and msg[1] == '0' and msg[2] <= '1'):
			#print "R: ", msg
			while(recv_sem):
				pass
			recv_sem = True
			received.append(msg)
			recv_sem = False
			return True
	return False
			

def init(host, port):
	global sock
	sock = socket.socket(
	  socket.AF_INET, socket.SOCK_STREAM)
	sock.connect((host, port))
	#th=Thread(target = server_recv, args=(sock, ))
	#th.start()
