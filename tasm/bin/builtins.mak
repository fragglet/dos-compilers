
#
# Borland C++ - (C) Copyright 1993 by Borland International
#

# default is to target 16BIT
# pass -DWIN32 to make to target 32BIT

!if !$d(WIN32)
CC       = bcc
RC       = brcc
AS       = tasm
!else
CC       = bcc32
RC       = brcc32
AS       = tasm32
!endif

.asm.obj:
      $(AS) $(AFLAGS) $&.asm

.c.exe:
      $(CC) $(CFLAGS) $&.c

.c.obj:
      $(CC) $(CFLAGS) /c $&.c

.cpp.exe:
      $(CC) $(CFLAGS) $&.cpp

.cpp.obj:
      $(CC) $(CPPFLAGS) /c $&.cpp

.rc.res:
      $(RC) $(RFLAGS) /r $&

.SUFFIXES: .exe .obj .asm .c .res .rc

!if !$d(BCEXAMPLEDIR)
BCEXAMPLEDIR = $(MAKEDIR)\..\EXAMPLES
!endif
