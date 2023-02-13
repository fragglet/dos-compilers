@echo off
IF not exist %1.C goto ERR
C:\C86PLUS\BIN\CC -c %1.c
IF not exist %1.OBJ goto ERR
CAROLE %1.obj
IF not exist %1.EXE goto ERR
DEL %1.OBJ
DEL %1.MAP
goto END
:ERR
echo An error has occurred!
echo Usage is "CC MYPROGRAM" 
echo No Extension (.c is assumed)
echo Output is MYPROGRAM.EXE
:END