@echo off
cd AppSemaforo
..\fad.py --clear 10
PAUSE
..\fad.py --system SystemSem.xml
PAUSE
..\fad.py --load SystemSem.cmd
PAUSE