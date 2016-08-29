@echo off
cd proj
..\fad.py --clear 10
..\fad.py --clear 20
PAUSE
..\fad.py --system System.xml
PAUSE
..\fad.py --load System.cmd
PAUSE