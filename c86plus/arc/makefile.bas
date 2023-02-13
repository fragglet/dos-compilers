# makefile for the base libraries, cbasexxx.lib

#  4dec86 zap  First cut.
# 22dec86 zap  New models.
# 19jan87 zap  New library arangement: removed some files.
# 23feb87 zap  Compact model
# 20oct87 zap  Libs got too big -- remove some functions to FIO libraries.

#  -----------------------------------------------

FLAGS= -c -AS -Zl
AFLAGS= /I\c86plus\include /DCPU_0 /DMODEL_snd /mx
OBJ= c86snd

#FLAGS= -c -AC -Zl
#AFLAGS= /I\c86plus\include /DCPU_0 /DMODEL_sfd /mx
#OBJ= c86sfd

#FLAGS= -c -AM -Zl
#AFLAGS= /I\c86plus\include /DCPU_0 /DMODEL_lnd /mx
#OBJ= c86lnd

#FLAGS= -c -AL -Zl
#AFLAGS= /I\c86plus\include /DCPU_0 /DMODEL_lfd /mx
#OBJ= c86lfd

#FLAGS= -c -Alfu -Zl
#AFLAGS= /I\c86plus\include /DCPU_0 /DMODEL_lfu /mx
#OBJ= c86lfu

SRC= src
INCL= \c86plus\include

#  -----------------------------------------
#       These functions from cbasec.arc
#  -----------------------------------------

$(OBJ)\abort.obj: $(SRC)\abort.c $(INCL)\signal.h $(COMP)
	cc $(FLAGS) $(SRC)\abort.c
	copy abort.obj $(OBJ)
	del abort.obj

$(OBJ)\abs.obj: $(SRC)\abs.c $(COMP)
	cc $(FLAGS) $(SRC)\abs.c
	copy abs.obj $(OBJ)
	del abs.obj

$(OBJ)\abstoptr.obj: $(SRC)\abstoptr.c $(COMP)
	cc $(FLAGS) $(SRC)\abstoptr.c
	copy abstoptr.obj $(OBJ)
	del abstoptr.obj

$(OBJ)\access.obj: $(SRC)\access.c $(INCL)\dos.h $(INCL)\errno.h $(COMP)
	cc $(FLAGS) $(SRC)\access.c
	copy access.obj $(OBJ)
	del access.obj

$(OBJ)\acos.obj: $(SRC)\acos.c $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h $(COMP)
	cc $(FLAGS) $(SRC)\acos.c
	copy acos.obj $(OBJ)
	del acos.obj

$(OBJ)\alloc.obj: $(SRC)\alloc.c $(INCL)\stdio.h $(INCL)\errno.h $(COMP) \
		$(INCL)\signal.h $(INCL)\malloc.h
	cc $(FLAGS) $(SRC)\alloc.c
	copy alloc.obj $(OBJ)
	del alloc.obj

$(OBJ)\asctime.obj: $(SRC)\asctime.c $(INCL)\time.h $(COMP)
	cc $(FLAGS) $(SRC)\asctime.c
	copy asctime.obj $(OBJ)
	del asctime.obj

$(OBJ)\asin.obj: $(SRC)\asin.c $(INCL)\math.h $(INCL)\errno.h \
		$(INCL)\float.h $(COMP)
	cc $(FLAGS) $(SRC)\asin.c
	copy asin.obj $(OBJ)
	del asin.obj

$(OBJ)\atan.obj: $(SRC)\atan.c $(INCL)\_math.h $(INCL)\float.h \
		$(INCL)\errno.h $(COMP)
	cc $(FLAGS) $(SRC)\atan.c
	copy atan.obj $(OBJ)
	del atan.obj

$(OBJ)\atexit.obj: $(SRC)\atexit.c $(SRC)\onexit.c $(COMP)
	cc $(FLAGS) $(SRC)\atexit.c
	copy atexit.obj $(OBJ)
	del atexit.obj

$(OBJ)\atof.obj: $(SRC)\atof.c $(INCL)\math.h $(INCL)\float.h \
		$(INCL)\errno.h $(COMP)
	cc $(FLAGS) $(SRC)\atof.c
	copy atof.obj $(OBJ)
	del atof.obj

$(OBJ)\atoi.obj: $(SRC)\atoi.c $(COMP)
	cc $(FLAGS) $(SRC)\atoi.c
	copy atoi.obj $(OBJ)
	del atoi.obj

$(OBJ)\atol.obj: $(SRC)\atol.c $(INCL)\stdlib.h $(COMP)
	cc $(FLAGS) $(SRC)\atol.c
	copy atol.obj $(OBJ)
	del atol.obj

$(OBJ)\bsearch.obj: $(SRC)\bsearch.c $(INCL)\stdio.h $(COMP)
	cc $(FLAGS) $(SRC)\bsearch.c
	copy bsearch.obj $(OBJ)
	del bsearch.obj

$(OBJ)\calloc.obj: $(SRC)\calloc.c $(INCL)\malloc.h $(COMP)
	cc $(FLAGS) $(SRC)\calloc.c
	copy calloc.obj $(OBJ)
	del calloc.obj

$(OBJ)\ceil.obj: $(SRC)\ceil.c $(INCL)\float.h $(INCL)\_math.h  $(COMP)
	cc $(FLAGS) $(SRC)\ceil.c
	copy ceil.obj $(OBJ)
	del ceil.obj

$(OBJ)\chdir.obj: $(SRC)\chdir.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\chdir.c
	copy chdir.obj $(OBJ)
	del chdir.obj

$(OBJ)\chmod.obj: $(SRC)\chmod.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\chmod.c
	copy chmod.obj $(OBJ)
	del chmod.obj

$(OBJ)\chsize.obj: $(SRC)\chsize.c $(INCL)\dos.h $(INCL)\stdio.h \
		$(INCL)\errno.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\chsize.c
	copy chsize.obj $(OBJ)
	del chsize.obj

$(OBJ)\clearerr.obj: $(SRC)\clearerr.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\clearerr.c
	copy clearerr.obj $(OBJ)
	del clearerr.obj

$(OBJ)\clock.obj: $(SRC)\clock.c $(INCL)\time.h $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\clock.c
	copy clock.obj $(OBJ)
	del clock.obj

$(OBJ)\close.obj: $(SRC)\close.c $(INCL)\stdio.h $(INCL)\dos.h \
		$(INCL)\fileio3.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\close.c
	copy close.obj $(OBJ)
	del close.obj

$(OBJ)\cos.obj: $(SRC)\cos.c $(INCL)\_math.h $(INCL)\float.h \
		$(INCL)\errno.h $(COMP)
	cc $(FLAGS) $(SRC)\cos.c
	copy cos.obj $(OBJ)
	del cos.obj

$(OBJ)\cosh.obj: $(SRC)\cosh.c $(INCL)\float.h $(INCL)\math.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\cosh.c
	copy cosh.obj $(OBJ)
	del cosh.obj

$(OBJ)\cotan.obj: $(SRC)\cotan.c $(INCL)\float.h $(INCL)\_math.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\cotan.c
	copy cotan.obj $(OBJ)
	del cotan.obj

$(OBJ)\creat.obj: $(SRC)\creat.c $(INCL)\fcntl.h  $(COMP)
	cc $(FLAGS) $(SRC)\creat.c
	copy creat.obj $(OBJ)
	del creat.obj

$(OBJ)\ctime.obj: $(SRC)\ctime.c $(INCL)\time.h  $(COMP)
	cc $(FLAGS) $(SRC)\ctime.c
	copy ctime.obj $(OBJ)
	del ctime.obj

$(OBJ)\difftime.obj: $(SRC)\difftime.c $(INCL)\time.h  $(COMP)
	cc $(FLAGS) $(SRC)\difftime.c
	copy difftime.obj $(OBJ)
	del difftime.obj

$(OBJ)\div.obj: $(SRC)\div.c $(INCL)\math.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\div.c
	copy div.obj $(OBJ)
	del div.obj

$(OBJ)\dosexter.obj: $(SRC)\dosexter.c $(INCL)\dos.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\dosexter.c
	copy dosexter.obj $(OBJ)
	del dosexter.obj

$(OBJ)\dup.obj: $(SRC)\dup.c $(INCL)\stdio.h $(INCL)\fileio3.h $(INCL)\dos.h \
		 $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\dup.c
	copy dup.obj $(OBJ)
	del dup.obj

$(OBJ)\dup2.obj: $(SRC)\dup2.c $(INCL)\stdio.h $(INCL)\fileio3.h \
		$(INCL)\dos.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\dup2.c
	copy dup2.obj $(OBJ)
	del dup2.obj

$(OBJ)\ecvt.obj: $(SRC)\ecvt.c $(COMP)
	cc $(FLAGS) $(SRC)\ecvt.c
	copy ecvt.obj $(OBJ)
	del ecvt.obj

$(OBJ)\eof.obj: $(SRC)\eof.c $(INCL)\dos.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\eof.c
	copy eof.obj $(OBJ)
	del eof.obj

$(OBJ)\errno.obj: $(SRC)\errno.c $(INCL)\process.h $(COMP)
	cc $(FLAGS) $(SRC)\errno.c
	copy errno.obj $(OBJ)
	del errno.obj

$(OBJ)\execl.obj: $(SRC)\execl.c $(INCL)\process.h $(COMP)
        cc $(FLAGS) $(SRC)\execl.c
        copy execl.obj $(OBJ)
        del execl.obj

$(OBJ)\execle.obj: $(SRC)\execle.c $(INCL)\process.h $(COMP)
        cc $(FLAGS) $(SRC)\execle.c
        copy execle.obj $(OBJ)
        del execle.obj

$(OBJ)\execlp.obj: $(SRC)\execlp.c $(INCL)\process.h $(COMP)
        cc $(FLAGS) $(SRC)\execlp.c
        copy execlp.obj $(OBJ)
        del execlp.obj

$(OBJ)\execlpe.obj: $(SRC)\execlpe.c $(INCL)\process.h $(COMP)
        cc $(FLAGS) $(SRC)\execlpe.c
        copy execlpe.obj $(OBJ)
        del execlpe.obj

$(OBJ)\execv.obj: $(SRC)\execv.c $(INCL)\process.h $(COMP)
        cc $(FLAGS) $(SRC)\execv.c
        copy execv.obj $(OBJ)
        del execv.obj

$(OBJ)\execve.obj: $(SRC)\execve.c $(INCL)\process.h $(COMP)
        cc $(FLAGS) $(SRC)\execve.c
        copy execve.obj $(OBJ)
        del execve.obj

$(OBJ)\execvp.obj: $(SRC)\execvp.c $(INCL)\process.h $(COMP)
        cc $(FLAGS) $(SRC)\execvp.c
        copy execvp.obj $(OBJ)
        del execvp.obj

$(OBJ)\execvpe.obj: $(SRC)\execvpe.c $(INCL)\process.h $(COMP)
        cc $(FLAGS) $(SRC)\execvpe.c
        copy execvpe.obj $(OBJ)
        del execvpe.obj

$(OBJ)\exit.obj: $(SRC)\exit.c $(INCL)\dos.h $(INCL)\process.h \
		$(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\exit.c
	copy exit.obj $(OBJ)
	del exit.obj

$(OBJ)\exit_tsr.obj: $(SRC)\exit_tsr.c $(COMP)
	cc $(FLAGS) $(SRC)\exit_tsr.c
	copy exit_tsr.obj $(OBJ)
	del exit_tsr.obj

$(OBJ)\exp.obj: $(SRC)\exp.c $(INCL)\_math.h $(INCL)\float.h \
		$(INCL)\errno.h $(COMP)
	cc $(FLAGS) $(SRC)\exp.c
	copy exp.obj $(OBJ)
	del exp.obj

$(OBJ)\fabs.obj: $(SRC)\fabs.c $(COMP)
	cc $(FLAGS) $(SRC)\fabs.c
	copy fabs.obj $(OBJ)
	del fabs.obj

$(OBJ)\fclose.obj: $(SRC)\fclose.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\fclose.c
	copy fclose.obj $(OBJ)
	del fclose.obj

$(OBJ)\fcloseal.obj: $(SRC)\fcloseal.c $(INCL)\stdio.h \
		$(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\fcloseal.c
	copy fcloseal.obj $(OBJ)
	del fcloseal.obj

$(OBJ)\fcvt.obj: $(SRC)\fcvt.c $(COMP)
	cc $(FLAGS) $(SRC)\fcvt.c
	copy fcvt.obj $(OBJ)
	del fcvt.obj

$(OBJ)\fdopen.obj: $(SRC)\fdopen.c $(INCL)\stdio.h $(INCL)\fileio3.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\fdopen.c
	copy fdopen.obj $(OBJ)
	del fdopen.obj

$(OBJ)\feof.obj: $(SRC)\feof.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\feof.c
	copy feof.obj $(OBJ)
	del feof.obj

$(OBJ)\ferror.obj: $(SRC)\ferror.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\ferror.c
	copy ferror.obj $(OBJ)
	del ferror.obj

$(OBJ)\fflush.obj: $(SRC)\fflush.c $(INCL)\stdio.h $(INCL)\fileio3.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\fflush.c
	copy fflush.obj $(OBJ)
	del fflush.obj

$(OBJ)\fgetc.obj: $(SRC)\fgetc.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\fgetc.c
	copy fgetc.obj $(OBJ)
	del fgetc.obj

$(OBJ)\fgetchar.obj: $(SRC)\fgetchar.c $(INCL)\stdio.h $(INCL)\fileio3.h $(COMP)
	cc $(FLAGS) $(SRC)\fgetchar.c
	copy fgetchar.obj $(OBJ)
	del fgetchar.obj

$(OBJ)\fgetpos.obj: $(SRC)\fgetpos.c $(INCL)\stdio.h $(INCL)\fileio3.h \
		$(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\fgetpos.c
	copy fgetpos.obj $(OBJ)
	del fgetpos.obj

$(OBJ)\fgets.obj: $(SRC)\fgets.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\fgets.c
	copy fgets.obj $(OBJ)
	del fgets.obj

$(OBJ)\filedir.obj: $(SRC)\filedir.c $(INCL)\stdio.h $(INCL)\dos.h \
		$(INCL)\malloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\filedir.c
	copy filedir.obj $(OBJ)
	del filedir.obj

$(OBJ)\filelen.obj: $(SRC)\filelen.c $(INCL)\stdio.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\filelen.c
	copy filelen.obj $(OBJ)
	del filelen.obj

$(OBJ)\fileno.obj: $(SRC)\fileno.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\fileno.c
	copy fileno.obj $(OBJ)
	del fileno.obj

$(OBJ)\floor.obj: $(SRC)\floor.c $(INCL)\float.h $(INCL)\_math.h  $(COMP)
	cc $(FLAGS) $(SRC)\floor.c
	copy floor.obj $(OBJ)
	del floor.obj

$(OBJ)\flushall.obj: $(SRC)\flushall.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\flushall.c
	copy flushall.obj $(OBJ)
	del flushall.obj

$(OBJ)\fmod.obj: $(SRC)\fmod.c $(INCL)\float.h $(INCL)\math.h  $(COMP)
	cc $(FLAGS) $(SRC)\fmod.c
	copy fmod.obj $(OBJ)
	del fmod.obj

$(OBJ)\fopen.obj: $(SRC)\fopen.c $(INCL)\stdio.h $(INCL)\fileio3.h \
		$(INCL)\errno.h $(INCL)\fcntl.h $(COMP)
	cc $(FLAGS) $(SRC)\fopen.c
	copy fopen.obj $(OBJ)
	del fopen.obj

$(OBJ)\fputc.obj: $(SRC)\fputc.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\fputc.c
	copy fputc.obj $(OBJ)
	del fputc.obj

$(OBJ)\fputchar.obj: $(SRC)\fputchar.c $(INCL)\stdio.h $(INCL)\fileio3.h $(COMP)
	cc $(FLAGS) $(SRC)\fputchar.c
	copy fputchar.obj $(OBJ)
	del fputchar.obj

$(OBJ)\fputs.obj: $(SRC)\fputs.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\fputs.c
	copy fputs.obj $(OBJ)
	del fputs.obj

$(OBJ)\fread.obj: $(SRC)\fread.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\fread.c
	copy fread.obj $(OBJ)
	del fread.obj

$(OBJ)\free.obj: $(SRC)\free.c $(COMP)
	cc $(FLAGS) $(SRC)\free.c
	copy free.obj $(OBJ)
	del free.obj

$(OBJ)\free_lst.obj: $(SRC)\free_lst.c $(INCL)\stdio.h $(INCL)\malloc.h \
		$(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\free_lst.c
	copy free_lst.obj $(OBJ)
	del free_lst.obj

$(OBJ)\free_max.obj: $(SRC)\free_max.c $(COMP)
	cc $(FLAGS) $(SRC)\free_max.c
	copy free_max.obj $(OBJ)
	del free_max.obj

$(OBJ)\free_mem.obj: $(SRC)\free_mem.c $(INCL)\dos.h $(INCL)\_alloc.h \
		$(INCL)\signal.h  $(COMP)
	cc $(FLAGS) $(SRC)\free_mem.c
	copy free_mem.obj $(OBJ)
	del free_mem.obj

$(OBJ)\freopen.obj: $(SRC)\freopen.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\freopen.c
	copy freopen.obj $(OBJ)
	del freopen.obj

$(OBJ)\frexp.obj: $(SRC)\frexp.c $(COMP)
	cc $(FLAGS) $(SRC)\frexp.c
	copy frexp.obj $(OBJ)
	del frexp.obj

$(OBJ)\fseek.obj: $(SRC)\fseek.c $(INCL)\stdio.h $(INCL)\fileio3.h \
		$(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\fseek.c
	copy fseek.obj $(OBJ)
	del fseek.obj

$(OBJ)\fsetpos.obj: $(SRC)\fsetpos.c $(INCL)\stdio.h $(INCL)\fileio3.h \
		$(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\fsetpos.c
	copy fsetpos.obj $(OBJ)
	del fsetpos.obj

$(OBJ)\fstat.obj: $(SRC)\fstat.c $(INCL)\sys\stat.h $(INCL)\fcntl.h \
		$(INCL)\fileio3.h $(INCL)\dos.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\fstat.c
	copy fstat.obj $(OBJ)
	del fstat.obj

$(OBJ)\ftell.obj: $(SRC)\ftell.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\ftell.c
	copy ftell.obj $(OBJ)
	del ftell.obj

$(OBJ)\ftime.obj: $(SRC)\ftime.c $(INCL)\dos.h $(INCL)\sys\timeb.h  $(COMP)
	cc $(FLAGS) $(SRC)\ftime.c
	copy ftime.obj $(OBJ)
	del ftime.obj

$(OBJ)\ftoa.obj: $(SRC)\ftoa.c $(COMP)
	cc $(FLAGS) $(SRC)\ftoa.c
	copy ftoa.obj $(OBJ)
	del ftoa.obj

$(OBJ)\fwrite.obj: $(SRC)\fwrite.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\fwrite.c
	copy fwrite.obj $(OBJ)
	del fwrite.obj

$(OBJ)\gcdir.obj: $(SRC)\gcdir.c $(INCL)\dos.h $(INCL)\malloc.h \
		$(INCL)\string.h  $(COMP)
	cc $(FLAGS) $(SRC)\gcdir.c
	copy gcdir.obj $(OBJ)
	del gcdir.obj

$(OBJ)\gcvt.obj: $(SRC)\gcvt.c $(COMP)
	cc $(FLAGS) $(SRC)\gcvt.c
	copy gcvt.obj $(OBJ)
	del gcvt.obj

$(OBJ)\getc.obj: $(SRC)\getc.c $(COMP)
	cc $(FLAGS) $(SRC)\getc.c
	copy getc.obj $(OBJ)
	del getc.obj

$(OBJ)\getchar.obj: $(SRC)\getchar.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\getchar.c
	copy getchar.obj $(OBJ)
	del getchar.obj

$(OBJ)\getcwd.obj: $(SRC)\getcwd.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\getcwd.c
	copy getcwd.obj $(OBJ)
	del getcwd.obj

$(OBJ)\getenv.obj: $(SRC)\getenv.c $(INCL)\dos.h $(INCL)\string.h  $(COMP)
	cc $(FLAGS) $(SRC)\getenv.c
	copy getenv.obj $(OBJ)
	del getenv.obj

$(OBJ)\getpid.obj: $(SRC)\getpid.c $(COMP)
	cc $(FLAGS) $(SRC)\getpid.c
	copy getpid.obj $(OBJ)
	del getpid.obj

$(OBJ)\gets.obj: $(SRC)\gets.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\gets.c
	copy gets.obj $(OBJ)
	del gets.obj

$(OBJ)\getw.obj: $(SRC)\getw.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\getw.c
	copy getw.obj $(OBJ)
	del getw.obj

$(OBJ)\gmtime.obj: $(SRC)\gmtime.c $(INCL)\time.h $(INCL)\stdio.h \
		$(INCL)\errno.h $(INCL)\stdlib.h  $(COMP)
	cc $(FLAGS) $(SRC)\gmtime.c
	copy gmtime.obj $(OBJ)
	del gmtime.obj

$(OBJ)\halloc.obj: $(SRC)\halloc.c $(INCL)\malloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\halloc.c
	copy halloc.obj $(OBJ)
	del halloc.obj

$(OBJ)\hfree.obj: $(SRC)\hfree.c $(INCL)\malloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\hfree.c
	copy hfree.obj $(OBJ)
	del hfree.obj

$(OBJ)\horse.obj: $(SRC)\horse.c $(COMP)
	cc $(FLAGS) $(SRC)\horse.c
	copy horse.obj $(OBJ)
	del horse.obj

$(OBJ)\intrinit.obj: $(SRC)\intrinit.c $(INCL)\malloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\intrinit.c
	copy intrinit.obj $(OBJ)
	del intrinit.obj

$(OBJ)\intrrest.obj: $(SRC)\intrrest.c $(INCL)\malloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\intrrest.c
	copy intrrest.obj $(OBJ)
	del intrrest.obj

$(OBJ)\intrterm.obj: $(SRC)\intrterm.c $(INCL)\dos.h $(INCL)\intr.h  $(COMP)
	cc $(FLAGS) $(SRC)\intrterm.c
	copy intrterm.obj $(OBJ)
	del intrterm.obj

$(OBJ)\intrset.obj: $(SRC)\intrset.c $(INCL)\dos.h $(INCL)\intr.h  $(COMP)
	cc $(FLAGS) $(SRC)\intrset.c
	copy intrset.obj $(OBJ)
	del intrset.obj

$(OBJ)\isalnum.obj: $(SRC)\isalnum.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isalnum.c
	copy isalnum.obj $(OBJ)
	del isalnum.obj

$(OBJ)\isalpha.obj: $(SRC)\isalpha.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isalpha.c
	copy isalpha.obj $(OBJ)
	del isalpha.obj

$(OBJ)\isatty.obj: $(SRC)\isatty.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isatty.c
	copy isatty.obj $(OBJ)
	del isatty.obj

$(OBJ)\iscd.obj: $(SRC)\iscd.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\iscd.c
	copy iscd.obj $(OBJ)
	del iscd.obj

$(OBJ)\iscntrl.obj: $(SRC)\iscntrl.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\iscntrl.c
	copy iscntrl.obj $(OBJ)
	del iscntrl.obj

$(OBJ)\iscsym.obj: $(SRC)\iscsym.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\iscsym.c
	copy iscsym.obj $(OBJ)
	del iscsym.obj

$(OBJ)\iscsymf.obj: $(SRC)\iscsymf.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\iscsymf.c
	copy iscsymf.obj $(OBJ)
	del iscsymf.obj

$(OBJ)\isdigit.obj: $(SRC)\isdigit.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isdigit.c
	copy isdigit.obj $(OBJ)
	del isdigit.obj

$(OBJ)\isgraph.obj: $(SRC)\isgraph.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isgraph.c
	copy isgraph.obj $(OBJ)
	del isgraph.obj

$(OBJ)\islower.obj: $(SRC)\islower.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\islower.c
	copy islower.obj $(OBJ)
	del islower.obj

$(OBJ)\isodigit.obj: $(SRC)\isodigit.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isodigit.c
	copy isodigit.obj $(OBJ)
	del isodigit.obj

$(OBJ)\isprint.obj: $(SRC)\isprint.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isprint.c
	copy isprint.obj $(OBJ)
	del isprint.obj

$(OBJ)\ispunct.obj: $(SRC)\ispunct.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\ispunct.c
	copy ispunct.obj $(OBJ)
	del ispunct.obj

$(OBJ)\isspace.obj: $(SRC)\isspace.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isspace.c
	copy isspace.obj $(OBJ)
	del isspace.obj

$(OBJ)\isupper.obj: $(SRC)\isupper.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isupper.c
	copy isupper.obj $(OBJ)
	del isupper.obj

$(OBJ)\isxdigit.obj: $(SRC)\isxdigit.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\isxdigit.c
	copy isxdigit.obj $(OBJ)
	del isxdigit.obj

$(OBJ)\itoa.obj: $(SRC)\itoa.c $(COMP)
	cc $(FLAGS) $(SRC)\itoa.c
	copy itoa.obj $(OBJ)
	del itoa.obj

$(OBJ)\itoh.obj: $(SRC)\itoh.c $(COMP)
	cc $(FLAGS) $(SRC)\itoh.c
	copy itoh.obj $(OBJ)
	del itoh.obj

$(OBJ)\j0.obj: $(SRC)\j0.c $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\j0.c
	copy j0.obj $(OBJ)
	del j0.obj

$(OBJ)\j1.obj: $(SRC)\j1.c $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\j1.c
	copy j1.obj $(OBJ)
	del j1.obj

$(OBJ)\jn.obj: $(SRC)\jn.c $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\jn.c
	copy jn.obj $(OBJ)
	del jn.obj

$(OBJ)\kbhit.obj: $(SRC)\kbhit.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\kbhit.c
	copy kbhit.obj $(OBJ)
	del kbhit.obj

$(OBJ)\labs.obj: $(SRC)\labs.c $(COMP)
	cc $(FLAGS) $(SRC)\labs.c
	copy labs.obj $(OBJ)
	del labs.obj

$(OBJ)\ldexp.obj: $(SRC)\ldexp.c $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\ldexp.c
	copy ldexp.obj $(OBJ)
	del ldexp.obj

$(OBJ)\ldiv.obj: $(SRC)\ldiv.c $(INCL)\math.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\ldiv.c
	copy ldiv.obj $(OBJ)
	del ldiv.obj

$(OBJ)\lfind.obj: $(SRC)\lfind.c $(COMP)
	cc $(FLAGS) $(SRC)\lfind.c
	copy lfind.obj $(OBJ)
	del lfind.obj

$(OBJ)\localtim.obj: $(SRC)\localtim.c $(INCL)\time.h $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\localtim.c
	copy localtim.obj $(OBJ)
	del localtim.obj

$(OBJ)\locking.obj: $(SRC)\locking.c $(INCL)\dos.h $(INCL)\sys\locking.h \
		$(INCL)\stdio.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\locking.c
	copy locking.obj $(OBJ)
	del locking.obj

$(OBJ)\log.obj: $(SRC)\log.c $(INCL)\_math.h $(INCL)\float.h \
		$(INCL)\errno.h $(COMP)
	cc $(FLAGS) $(SRC)\log.c
	copy log.obj $(OBJ)
	del log.obj

$(OBJ)\log10.obj: $(SRC)\log10.c $(INCL)\_math.h $(INCL)\float.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\log10.c
	copy log10.obj $(OBJ)
	del log10.obj

$(OBJ)\lower.obj: $(SRC)\lower.c $(COMP)
	cc $(FLAGS) $(SRC)\lower.c
	copy lower.obj $(OBJ)
	del lower.obj

$(OBJ)\lsearch.obj: $(SRC)\lsearch.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\lsearch.c
	copy lsearch.obj $(OBJ)
	del lsearch.obj

$(OBJ)\lseek.obj: $(SRC)\lseek.c $(INCL)\dos.h $(INCL)\fileio3.h \
		$(INCL)\stdio.h $(COMP)
	cc $(FLAGS) $(SRC)\lseek.c
	copy lseek.obj $(OBJ)
	del lseek.obj

$(OBJ)\ltell.obj: $(SRC)\ltell.c $(INCL)\io.h $(INCL)\stdio.h \
		$(INCL)\errno.h $(COMP)
	cc $(FLAGS) $(SRC)\ltell.c
	copy ltell.obj $(OBJ)
	del ltell.obj

$(OBJ)\ltoa.obj: $(SRC)\ltoa.c $(COMP)
	cc $(FLAGS) $(SRC)\ltoa.c
	copy ltoa.obj $(OBJ)
	del ltoa.obj

$(OBJ)\ltoh.obj: $(SRC)\ltoh.c $(COMP)
	cc $(FLAGS) $(SRC)\ltoh.c
	copy ltoh.obj $(OBJ)
	del ltoh.obj

$(OBJ)\ltos.obj: $(SRC)\ltos.c $(COMP)
	cc $(FLAGS) $(SRC)\ltos.c
	copy ltos.obj $(OBJ)
	del ltos.obj

$(OBJ)\makefcb.obj: $(SRC)\makefcb.c $(COMP)
	cc $(FLAGS) $(SRC)\makefcb.c
	copy makefcb.obj $(OBJ)
	del makefcb.obj

$(OBJ)\makefnam.obj: $(SRC)\makefnam.c $(COMP)
	cc $(FLAGS) $(SRC)\makefnam.c
	copy makefnam.obj $(OBJ)
	del makefnam.obj

$(OBJ)\malloc.obj: $(SRC)\malloc.c $(COMP)
	cc $(FLAGS) $(SRC)\malloc.c
	copy malloc.obj $(OBJ)
	del malloc.obj

$(OBJ)\matherr.obj: $(SRC)\matherr.c $(COMP)
	cc $(FLAGS) $(SRC)\matherr.c
	copy matherr.obj $(OBJ)
	del matherr.obj

$(OBJ)\memccpy.obj: $(SRC)\memccpy.c $(COMP)
	cc $(FLAGS) $(SRC)\memccpy.c
	copy memccpy.obj $(OBJ)
	del memccpy.obj

$(OBJ)\memchr.obj: $(SRC)\memchr.c $(COMP)
	cc $(FLAGS) $(SRC)\memchr.c
	copy memchr.obj $(OBJ)
	del memchr.obj

$(OBJ)\memcmp.obj: $(SRC)\memcmp.c $(COMP)
	cc $(FLAGS) $(SRC)\memcmp.c
	copy memcmp.obj $(OBJ)
	del memcmp.obj

$(OBJ)\memicmp.obj: $(SRC)\memicmp.c $(COMP)
	cc $(FLAGS) $(SRC)\memicmp.c
	copy memicmp.obj $(OBJ)
	del memicmp.obj

$(OBJ)\mkdir.obj: $(SRC)\mkdir.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\mkdir.c
	copy mkdir.obj $(OBJ)
	del mkdir.obj

$(OBJ)\mktemp.obj: $(SRC)\mktemp.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\mktemp.c
	copy mktemp.obj $(OBJ)
	del mktemp.obj

$(OBJ)\mktime.obj: $(SRC)\mktime.c $(INCL)\time.h $(INCL)\sys\types.h \
		$(INCL)\sys\utime.h  $(COMP)
	cc $(FLAGS) $(SRC)\mktime.c
	copy mktime.obj $(OBJ)
	del mktime.obj

$(OBJ)\modf.obj: $(SRC)\modf.c $(INCL)\math.h $(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\modf.c
	copy modf.obj $(OBJ)
	del modf.obj

$(OBJ)\movblock.obj: $(SRC)\movblock.c $(COMP)
	cc $(FLAGS) $(SRC)\movblock.c
	copy movblock.obj $(OBJ)
	del movblock.obj

$(OBJ)\oldgets.obj: $(SRC)\oldgets.c $(COMP)
	cc $(FLAGS) $(SRC)\oldgets.c
	copy oldgets.obj $(OBJ)
	del oldgets.obj

$(OBJ)\onexit.obj: $(SRC)\onexit.c $(COMP)
	cc $(FLAGS) $(SRC)\onexit.c
	copy onexit.obj $(OBJ)
	del onexit.obj

$(OBJ)\open.obj: $(SRC)\open.c $(COMP)
	cc $(FLAGS) $(SRC)\open.c
	copy open.obj $(OBJ)
	del open.obj

$(OBJ)\peek.obj: $(SRC)\peek.c $(COMP)
	cc $(FLAGS) $(SRC)\peek.c
	copy peek.obj $(OBJ)
	del peek.obj

$(OBJ)\perror.obj: $(SRC)\perror.c $(INCL)\errno.h $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\perror.c
	copy perror.obj $(OBJ)
	del perror.obj

$(OBJ)\pokeb.obj: $(SRC)\pokeb.c $(COMP)
	cc $(FLAGS) $(SRC)\pokeb.c
	copy pokeb.obj $(OBJ)
	del pokeb.obj

$(OBJ)\pokew.obj: $(SRC)\pokew.c $(COMP)
	cc $(FLAGS) $(SRC)\pokew.c
	copy pokew.obj $(OBJ)
	del pokew.obj

$(OBJ)\pow.obj: $(SRC)\pow.c $(INCL)\float.h $(INCL)\_math.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\pow.c
	copy pow.obj $(OBJ)
	del pow.obj

$(OBJ)\ptrdiff.obj: $(SRC)\ptrdiff.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\ptrdiff.c
	copy ptrdiff.obj $(OBJ)
	del ptrdiff.obj

$(OBJ)\ptrtoabs.obj: $(SRC)\ptrtoabs.c $(COMP)
	cc $(FLAGS) $(SRC)\ptrtoabs.c
	copy ptrtoabs.obj $(OBJ)
	del ptrtoabs.obj

$(OBJ)\putc.obj: $(SRC)\putc.c $(COMP)
	cc $(FLAGS) $(SRC)\putc.c
	copy putc.obj $(OBJ)
	del putc.obj

$(OBJ)\putchar.obj: $(SRC)\putchar.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\putchar.c
	copy putchar.obj $(OBJ)
	del putchar.obj

$(OBJ)\putenv.obj: $(SRC)\putenv.c $(INCL)\stdlib.h $(INCL)\malloc.h \
		$(INCL)\stdio.h $(INCL)\string.h  $(COMP)
	cc $(FLAGS) $(SRC)\putenv.c
	copy putenv.obj $(OBJ)
	del putenv.obj

$(OBJ)\puts.obj: $(SRC)\puts.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\puts.c
	copy puts.obj $(OBJ)
	del puts.obj

$(OBJ)\putw.obj: $(SRC)\putw.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\putw.c
	copy putw.obj $(OBJ)
	del putw.obj

$(OBJ)\qsort.obj: $(SRC)\qsort.c $(INCL)\search.h  $(COMP)
	cc $(FLAGS) $(SRC)\qsort.c
	copy qsort.obj $(OBJ)
	del qsort.obj

$(OBJ)\raise.obj: $(SRC)\raise.c $(INCL)\signal.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\raise.c
	copy raise.obj $(OBJ)
	del raise.obj

$(OBJ)\rand.obj: $(SRC)\rand.c $(COMP)
	cc $(FLAGS) $(SRC)\rand.c
	copy rand.obj $(OBJ)
	del rand.obj

$(OBJ)\read.obj: $(SRC)\read.c $(INCL)\stdio.h $(INCL)\dos.h \
		$(INCL)\fileio3.h $(INCL)\errno.h $(INCL)\signal.h  $(COMP)
	cc $(FLAGS) $(SRC)\read.c
	copy read.obj $(OBJ)
	del read.obj

$(OBJ)\realloc.obj: $(SRC)\realloc.c $(INCL)\stdio.h $(INCL)\errno.h \
		$(INCL)\signal.h $(INCL)\malloc.h $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\realloc.c
	copy realloc.obj $(OBJ)
	del realloc.obj

$(OBJ)\remove.obj: $(SRC)\remove.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\remove.c
	copy remove.obj $(OBJ)
	del remove.obj

$(OBJ)\rename.obj: $(SRC)\rename.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\rename.c
	copy rename.obj $(OBJ)
	del rename.obj

$(OBJ)\rewind.obj: $(SRC)\rewind.c $(INCL)\stdio.h $(INCL)\dos.h \
		$(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\rewind.c
	copy rewind.obj $(OBJ)
	del rewind.obj

$(OBJ)\rmdir.obj: $(SRC)\rmdir.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\rmdir.c
	copy rmdir.obj $(OBJ)
	del rmdir.obj

$(OBJ)\rmtmp.obj: $(SRC)\rmtmp.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\rmtmp.c
	copy rmtmp.obj $(OBJ)
	del rmtmp.obj

$(OBJ)\sbrk.obj: $(SRC)\sbrk.c $(INCL)\stdio.h $(INCL)\dos.h \
		$(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\sbrk.c
	copy sbrk.obj $(OBJ)
	del sbrk.obj

$(OBJ)\setbuf.obj: $(SRC)\setbuf.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\setbuf.c
	copy setbuf.obj $(OBJ)
	del setbuf.obj

$(OBJ)\setlocal.obj: $(SRC)\setlocal.c $(INCL)\locale.h $(COMP)
	cc $(FLAGS) $(SRC)\setlocal.c
	copy setlocal.obj $(OBJ)
	del setlocal.obj

$(OBJ)\setmem.obj: $(SRC)\setmem.c $(COMP)
	cc $(FLAGS) $(SRC)\setmem.c
	copy setmem.obj $(OBJ)
	del setmem.obj

$(OBJ)\setmode.obj: $(SRC)\setmode.c $(INCL)\fcntl.h $(INCL)\fileio3.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\setmode.c
	copy setmode.obj $(OBJ)
	del setmode.obj

$(OBJ)\settrace.obj: $(SRC)\settrace.c $(COMP)
	cc $(FLAGS) $(SRC)\settrace.c
	copy settrace.obj $(OBJ)
	del settrace.obj

$(OBJ)\setvbuf.obj: $(SRC)\setvbuf.c $(INCL)\stdio.h $(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\setvbuf.c
	copy setvbuf.obj $(OBJ)
	del setvbuf.obj

$(OBJ)\signal.obj: $(SRC)\signal.c $(INCL)\signal.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\signal.c
	copy signal.obj $(OBJ)
	del signal.obj

$(OBJ)\sin.obj: $(SRC)\sin.c $(INCL)\_math.h $(INCL)\float.h \
		$(INCL)\errno.h $(COMP)
	cc $(FLAGS) $(SRC)\sin.c
	copy sin.obj $(OBJ)
	del sin.obj

$(OBJ)\sinh.obj: $(SRC)\sinh.c $(INCL)\math.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\sinh.c
	copy sinh.obj $(OBJ)
	del sinh.obj

$(OBJ)\sopen.obj: $(SRC)\sopen.c $(COMP)
	cc $(FLAGS) $(SRC)\sopen.c
	copy sopen.obj $(OBJ)
	del sopen.obj

$(OBJ)\spawnl.obj: $(SRC)\spawnl.c $(COMP)
	cc $(FLAGS) $(SRC)\spawnl.c
	copy spawnl.obj $(OBJ)
	del spawnl.obj

$(OBJ)\spawnle.obj: $(SRC)\spawnle.c $(COMP)
	cc $(FLAGS) $(SRC)\spawnle.c
	copy spawnle.obj $(OBJ)
	del spawnle.obj

$(OBJ)\spawnlp.obj: $(SRC)\spawnlp.c $(COMP)
	cc $(FLAGS) $(SRC)\spawnlp.c
	copy spawnlp.obj $(OBJ)
	del spawnlp.obj

$(OBJ)\spawnlpe.obj: $(SRC)\spawnlpe.c $(COMP)
	cc $(FLAGS) $(SRC)\spawnlpe.c
	copy spawnlpe.obj $(OBJ)
	del spawnlpe.obj

$(OBJ)\spawnv.obj: $(SRC)\spawnv.c $(COMP)
	cc $(FLAGS) $(SRC)\spawnv.c
	copy spawnv.obj $(OBJ)
	del spawnv.obj

$(OBJ)\spawnve.obj: $(SRC)\spawnve.c $(COMP)
	cc $(FLAGS) $(SRC)\spawnve.c
	copy spawnve.obj $(OBJ)
	del spawnve.obj

$(OBJ)\spawnvp.obj: $(SRC)\spawnvp.c $(COMP)
	cc $(FLAGS) $(SRC)\spawnvp.c
	copy spawnvp.obj $(OBJ)
	del spawnvp.obj

$(OBJ)\spawnvpe.obj: $(SRC)\spawnvpe.c $(COMP)
	cc $(FLAGS) $(SRC)\spawnvpe.c
	copy spawnvpe.obj $(OBJ)
	del spawnvpe.obj

$(OBJ)\sqrt.obj: $(SRC)\sqrt.c $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h $(COMP)
	cc $(FLAGS) $(SRC)\sqrt.c
	copy sqrt.obj $(OBJ)
	del sqrt.obj

$(OBJ)\square.obj: $(SRC)\square.c $(INCL)\_math.h  $(COMP)
	cc $(FLAGS) $(SRC)\square.c
	copy square.obj $(OBJ)
	del square.obj

$(OBJ)\stat.obj: $(SRC)\stat.c $(INCL)\time.h $(INCL)\sys\stat.h \
		$(INCL)\errno.h $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\stat.c
	copy stat.obj $(OBJ)
	del stat.obj

$(OBJ)\strchr.obj: $(SRC)\strchr.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\strchr.c
	copy strchr.obj $(OBJ)
	del strchr.obj

$(OBJ)\strcmpi.obj: $(SRC)\strcmpi.c $(COMP)
	cc $(FLAGS) $(SRC)\strcmpi.c
	copy strcmpi.obj $(OBJ)
	del strcmpi.obj

$(OBJ)\strcoll.obj: $(SRC)\strcoll.c $(INCL)\string.h $(COMP)
	cc $(FLAGS) $(SRC)\strcoll.c
	copy strcoll.obj $(OBJ)
	del strcoll.obj

$(OBJ)\strcspn.obj: $(SRC)\strcspn.c $(INCL)\string.h  $(COMP)
	cc $(FLAGS) $(SRC)\strcspn.c
	copy strcspn.obj $(OBJ)
	del strcspn.obj

$(OBJ)\strdup.obj: $(SRC)\strdup.c $(INCL)\string.h $(INCL)\malloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\strdup.c
	copy strdup.obj $(OBJ)
	del strdup.obj

$(OBJ)\strerror.obj: $(SRC)\strerror.c $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\strerror.c
	copy strerror.obj $(OBJ)
	del strerror.obj

$(OBJ)\stricmp.obj: $(SRC)\stricmp.c $(COMP)
	cc $(FLAGS) $(SRC)\stricmp.c
	copy stricmp.obj $(OBJ)
	del stricmp.obj

$(OBJ)\strlwr.obj: $(SRC)\strlwr.c $(COMP)
	cc $(FLAGS) $(SRC)\strlwr.c
	copy strlwr.obj $(OBJ)
	del strlwr.obj

$(OBJ)\strncat.obj: $(SRC)\strncat.c $(COMP)
	cc $(FLAGS) $(SRC)\strncat.c
	copy strncat.obj $(OBJ)
	del strncat.obj

$(OBJ)\strncmp.obj: $(SRC)\strncmp.c $(COMP)
	cc $(FLAGS) $(SRC)\strncmp.c
	copy strncmp.obj $(OBJ)
	del strncmp.obj

$(OBJ)\strncpy.obj: $(SRC)\strncpy.c $(COMP)
	cc $(FLAGS) $(SRC)\strncpy.c
	copy strncpy.obj $(OBJ)
	del strncpy.obj

$(OBJ)\strnicmp.obj: $(SRC)\strnicmp.c $(COMP)
	cc $(FLAGS) $(SRC)\strnicmp.c
	copy strnicmp.obj $(OBJ)
	del strnicmp.obj

$(OBJ)\strnset.obj: $(SRC)\strnset.c $(COMP)
	cc $(FLAGS) $(SRC)\strnset.c
	copy strnset.obj $(OBJ)
	del strnset.obj

$(OBJ)\strpbrk.obj: $(SRC)\strpbrk.c $(INCL)\stdio.h $(INCL)\string.h  $(COMP)
	cc $(FLAGS) $(SRC)\strpbrk.c
	copy strpbrk.obj $(OBJ)
	del strpbrk.obj

$(OBJ)\strpos.obj: $(SRC)\strpos.c $(COMP)
	cc $(FLAGS) $(SRC)\strpos.c
	copy strpos.obj $(OBJ)
	del strpos.obj

$(OBJ)\strpot.obj: $(SRC)\strpot.c $(COMP)
	cc $(FLAGS) $(SRC)\strpot.c
	copy strpot.obj $(OBJ)
	del strpot.obj

$(OBJ)\strrchr.obj: $(SRC)\strrchr.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\strrchr.c
	copy strrchr.obj $(OBJ)
	del strrchr.obj

$(OBJ)\strrev.obj: $(SRC)\strrev.c $(COMP)
	cc $(FLAGS) $(SRC)\strrev.c
	copy strrev.obj $(OBJ)
	del strrev.obj

$(OBJ)\strrpos.obj: $(SRC)\strrpos.c $(COMP)
	cc $(FLAGS) $(SRC)\strrpos.c
	copy strrpos.obj $(OBJ)
	del strrpos.obj

$(OBJ)\strset.obj: $(SRC)\strset.c $(COMP)
	cc $(FLAGS) $(SRC)\strset.c
	copy strset.obj $(OBJ)
	del strset.obj

$(OBJ)\strspn.obj: $(SRC)\strspn.c $(INCL)\string.h  $(COMP)
	cc $(FLAGS) $(SRC)\strspn.c
	copy strspn.obj $(OBJ)
	del strspn.obj

$(OBJ)\strstr.obj: $(SRC)\strstr.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\strstr.c
	copy strstr.obj $(OBJ)
	del strstr.obj

$(OBJ)\strtod.obj: $(SRC)\strtod.c $(INCL)\fileio3.h $(INCL)\ctype.h \
		$(INCL)\math.h $(INCL)\limits.h  $(COMP)
	cc $(FLAGS) $(SRC)\strtod.c
	copy strtod.obj $(OBJ)
	del strtod.obj

$(OBJ)\strtok.obj: $(SRC)\strtok.c $(INCL)\string.h  $(COMP)
	cc $(FLAGS) $(SRC)\strtok.c
	copy strtok.obj $(OBJ)
	del strtok.obj

$(OBJ)\strtol.obj: $(SRC)\strtol.c $(INCL)\ctype.h $(INCL)\limits.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\strtol.c
	copy strtol.obj $(OBJ)
	del strtol.obj

$(OBJ)\strtoul.obj: $(SRC)\strtoul.c $(INCL)\ctype.h $(INCL)\limits.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\strtoul.c
	copy strtoul.obj $(OBJ)
	del strtoul.obj

$(OBJ)\strupr.obj: $(SRC)\strupr.c $(COMP)
	cc $(FLAGS) $(SRC)\strupr.c
	copy strupr.obj $(OBJ)
	del strupr.obj

$(OBJ)\system.obj: $(SRC)\system.c $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\system.c
	copy system.obj $(OBJ)
	del system.obj

$(OBJ)\tan.obj: $(SRC)\tan.c $(INCL)\float.h $(INCL)\_math.h \
		$(INCL)\errno.h $(COMP)
	cc $(FLAGS) $(SRC)\tan.c
	copy tan.obj $(OBJ)
	del tan.obj

$(OBJ)\tanh.obj: $(SRC)\tanh.c $(INCL)\math.h $(INCL)\float.h \
		$(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\tanh.c
	copy tanh.obj $(OBJ)
	del tanh.obj

$(OBJ)\tmpfile.obj: $(SRC)\tmpfile.c $(INCL)\stdio.h $(INCL)\malloc.h $(COMP)
	cc $(FLAGS) $(SRC)\tmpfile.c
	copy tmpfile.obj $(OBJ)
	del tmpfile.obj

$(OBJ)\time.obj: $(SRC)\time.c $(INCL)\time.h $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\time.c
	copy time.obj $(OBJ)
	del time.obj

$(OBJ)\tmpfile.obj: $(SRC)\tmpfile.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\tmpfile.c
	copy tmpfile.obj $(OBJ)
	del tmpfile.obj

$(OBJ)\tmpnam.obj: $(SRC)\tmpnam.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\tmpnam.c
	copy tmpnam.obj $(OBJ)
	del tmpnam.obj

$(OBJ)\toascii.obj: $(SRC)\toascii.c $(COMP)
	cc $(FLAGS) $(SRC)\toascii.c
	copy toascii.obj $(OBJ)
	del toascii.obj

$(OBJ)\toint.obj: $(SRC)\toint.c $(COMP)
	cc $(FLAGS) $(SRC)\toint.c
	copy toint.obj $(OBJ)
	del toint.obj

$(OBJ)\tolower.obj: $(SRC)\tolower.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\tolower.c
	copy tolower.obj $(OBJ)
	del tolower.obj

$(OBJ)\toupper.obj: $(SRC)\toupper.c $(INCL)\ctype.h  $(COMP)
	cc $(FLAGS) $(SRC)\toupper.c
	copy toupper.obj $(OBJ)
	del toupper.obj

$(OBJ)\tzset.obj: $(SRC)\tzset.c $(INCL)\time.h  $(COMP)
	cc $(FLAGS) $(SRC)\tzset.c
	copy tzset.obj $(OBJ)
	del tzset.obj

$(OBJ)\ultoa.obj: $(SRC)\ultoa.c $(COMP)
	cc $(FLAGS) $(SRC)\ultoa.c
	copy ultoa.obj $(OBJ)
	del ultoa.obj

$(OBJ)\umask.obj: $(SRC)\umask.c $(COMP)
	cc $(FLAGS) $(SRC)\umask.c
	copy umask.obj $(OBJ)
	del umask.obj

$(OBJ)\ungetc.obj: $(SRC)\ungetc.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\ungetc.c
	copy ungetc.obj $(OBJ)
	del ungetc.obj

$(OBJ)\unlink.obj: $(SRC)\unlink.c $(INCL)\stdio.h  $(COMP)
	cc $(FLAGS) $(SRC)\unlink.c
	copy unlink.obj $(OBJ)
	del unlink.obj

$(OBJ)\upper.obj: $(SRC)\upper.c $(COMP)
	cc $(FLAGS) $(SRC)\upper.c
	copy upper.obj $(OBJ)
	del upper.obj

$(OBJ)\utime.obj: $(SRC)\utime.c $(INCL)\time.h $(INCL)\sys\utime.h \
		$(INCL)\stdio.h $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\utime.c
	copy utime.obj $(OBJ)
	del utime.obj

$(OBJ)\utoa.obj: $(SRC)\utoa.c $(COMP)
	cc $(FLAGS) $(SRC)\utoa.c
	copy utoa.obj $(OBJ)
	del utoa.obj

$(OBJ)\wqsort.obj: $(SRC)\wqsort.c $(COMP)
	cc $(FLAGS) $(SRC)\wqsort.c
	copy wqsort.obj $(OBJ)
	del wqsort.obj

$(OBJ)\write.obj: $(SRC)\write.c $(INCL)\stdio.h $(INCL)\dos.h \
		$(INCL)\fileio3.h $(INCL)\errno.h $(INCL)\signal.h  $(COMP)
	cc $(FLAGS) $(SRC)\write.c
	copy write.obj $(OBJ)
	del write.obj

$(OBJ)\y0.obj: $(SRC)\y0.c $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\y0.c
	copy y0.obj $(OBJ)
	del y0.obj

$(OBJ)\y1.obj: $(SRC)\y1.c $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\y1.c
	copy y1.obj $(OBJ)
	del y1.obj

$(OBJ)\yn.obj: $(SRC)\yn.c $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\yn.c
	copy yn.obj $(OBJ)
	del yn.obj

$(OBJ)\zork.obj: $(SRC)\zork.c $(COMP)
	cc $(FLAGS) $(SRC)\zork.c
	copy zork.obj $(OBJ)
	del zork.obj

$(OBJ)\_assert.obj: $(SRC)\_assert.c $(COMP)
	cc $(FLAGS) $(SRC)\_assert.c
	copy _assert.obj $(OBJ)
	del _assert.obj

$(OBJ)\_dodummy.obj: $(SRC)\_dodummy.c $(COMP)
	cc $(FLAGS) $(SRC)\_dodummy.c
	copy _dodummy.obj $(OBJ)
	del _dodummy.obj

$(OBJ)\_dtos.obj: $(SRC)\_dtos.c $(INCL)\math.h  $(COMP)
	cc $(FLAGS) $(SRC)\_dtos.c
	copy _dtos.obj $(OBJ)
	del _dtos.obj

$(OBJ)\_err_map.obj: $(SRC)\_err_map.c $(INCL)\_math.h  $(COMP)
	cc $(FLAGS) $(SRC)\_err_map.c
	copy _err_map.obj $(OBJ)
	del _err_map.obj

$(OBJ)\_exec.obj: $(SRC)\_exec.c $(COMP)
        cc $(FLAGS) $(SRC)\_exec.c
        copy _exec.obj $(OBJ)
        del _exec.obj

$(OBJ)\_exit.obj: $(SRC)\_exit.c $(INCL)\process.h  $(COMP)
	cc $(FLAGS) $(SRC)\_exit.c
	copy _exit.obj $(OBJ)
	del _exit.obj

$(OBJ)\_expand.obj: $(SRC)\_expand.c $(INCL)\malloc.h $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_expand.c
	copy _expand.obj $(OBJ)
	del _expand.obj

$(OBJ)\_ffree.obj: $(SRC)\_ffree.c $(INCL)\stdio.h $(INCL)\errno.h \
		$(INCL)\signal.h $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_ffree.c
	copy _ffree.obj $(OBJ)
	del _ffree.obj

$(OBJ)\_filbuf.obj: $(SRC)\_filbuf.c $(INCL)\stdio.h $(INCL)\fileio3.h \
		$(INCL)\errno.h $(INCL)\signal.h  $(COMP)
	cc $(FLAGS) $(SRC)\_filbuf.c
	copy _filbuf.obj $(OBJ)
	del _filbuf.obj

$(OBJ)\_flsbuf.obj: $(SRC)\_flsbuf.c $(INCL)\stdio.h $(INCL)\fileio3.h \
		$(INCL)\errno.h $(INCL)\signal.h  $(COMP)
	cc $(FLAGS) $(SRC)\_flsbuf.c
	copy _flsbuf.obj $(OBJ)
	del _flsbuf.obj

$(OBJ)\_fmalloc.obj: $(SRC)\_fmalloc.c $(INCL)\stdio.h $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_fmalloc.c
	copy _fmalloc.obj $(OBJ)
	del _fmalloc.obj

$(OBJ)\_fmsize.obj: $(SRC)\_fmsize.c $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_fmsize.c
	copy _fmsize.obj $(OBJ)
	del _fmsize.obj

$(OBJ)\_freect.obj: $(SRC)\_freect.c $(INCL)\malloc.h $(INCL)\_alloc.h \
		$(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\_freect.c
	copy _freect.obj $(OBJ)
	del _freect.obj

$(OBJ)\_j0.obj: $(SRC)\_j0.c $(INCL)\math.h $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\_j0.c
	copy _j0.obj $(OBJ)
	del _j0.obj

$(OBJ)\_j1.obj: $(SRC)\_j1.c $(INCL)\math.h $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\_j1.c
	copy _j1.obj $(OBJ)
	del _j1.obj

$(OBJ)\_jn.obj: $(SRC)\_jn.c $(INCL)\math.h $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\_jn.c
	copy _jn.obj $(OBJ)
	del _jn.obj

$(OBJ)\_main0.obj: $(SRC)\_main0.c $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_main0.c
	copy _main0.obj $(OBJ)
	del _main0.obj

$(OBJ)\_main1.obj: $(SRC)\_main1.c $(INCL)\stdio.h $(INCL)\dos.h \
		$(INCL)\fileio3.h  $(COMP)
	cc $(FLAGS) $(SRC)\_main1.c
	copy _main1.obj $(OBJ)
	del _main1.obj

$(OBJ)\_main2.obj: $(SRC)\_main2.c $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_main2.c
	copy _main2.obj $(OBJ)
	del _main2.obj
# 
# Note: _main3 MUST be compiled with stack checking enabled
# stack is needed for building argc,argv
#
$(OBJ)\_main3.obj: $(SRC)\_main3.c $(INCL)\malloc.h $(INCL)\string.h \
		$(INCL)\ctype.h $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) -Ge $(SRC)\_main3.c
	copy _main3.obj $(OBJ)
	del _main3.obj

$(OBJ)\_main4.obj: $(SRC)\_main4.c $(COMP)
	cc $(FLAGS) $(SRC)\_main4.c
	copy _main4.obj $(OBJ)
	del _main4.obj

$(OBJ)\_main9.obj: $(SRC)\_main9.c $(COMP)
	cc $(FLAGS) $(SRC)\_main9.c
	copy _main9.obj $(OBJ)
	del _main9.obj

$(OBJ)\_mainlas.obj: $(SRC)\_mainlas.c $(INCL)\time.h $(INCL)\dos.h  $(COMP)
	cc $(FLAGS) $(SRC)\_mainlas.c
	copy _mainlas.obj $(OBJ)
	del _mainlas.obj

$(OBJ)\_msize.obj: $(SRC)\_msize.c $(INCL)\malloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_msize.c
	copy _msize.obj $(OBJ)
	del _msize.obj

$(OBJ)\_nfree.obj: $(SRC)\_nfree.c $(INCL)\stdio.h $(INCL)\errno.h \
		$(INCL)\signal.h $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_nfree.c
	copy _nfree.obj $(OBJ)
	del _nfree.obj

$(OBJ)\_nmalloc.obj: $(SRC)\_nmalloc.c $(INCL)\stdio.h $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_nmalloc.c
	copy _nmalloc.obj $(OBJ)
	del _nmalloc.obj

$(OBJ)\_nmsize.obj: $(SRC)\_nmsize.c $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\_nmsize.c
	copy _nmsize.obj $(OBJ)
	del _nmsize.obj

$(OBJ)\_open.obj: $(SRC)\_open.c $(INCL)\fcntl.h $(INCL)\fileio3.h \
		$(INCL)\dos.h $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\_open.c
	copy _open.obj $(OBJ)
	del _open.obj

$(OBJ)\_raise.obj: $(SRC)\_raise.c $(INCL)\errno.h  $(COMP)
	cc $(FLAGS) $(SRC)\_raise.c
	copy _raise.obj $(OBJ)
	del _raise.obj

$(OBJ)\_signal.obj: $(SRC)\_signal.c $(INCL)\signal.h  $(COMP)
	cc $(FLAGS) $(SRC)\_signal.c
	copy _signal.obj $(OBJ)
	del _signal.obj

$(OBJ)\_spawn.obj: $(SRC)\_spawn.c $(INCL)\dos.h $(INCL)\errno.h \
                $(INCL)\process.h $(INCL)\malloc.h $(INCL)\signal.h $(COMP)
	cc $(FLAGS) $(SRC)\_spawn.c
	copy _spawn.obj $(OBJ)
	del _spawn.obj

$(OBJ)\_time.obj: $(SRC)\_time.c $(INCL)\time.h  $(COMP)
	cc $(FLAGS) $(SRC)\_time.c
	copy _time.obj $(OBJ)
	del _time.obj

$(OBJ)\_tolower.obj: $(SRC)\_tolower.c $(COMP)
	cc $(FLAGS) $(SRC)\_tolower.c
	copy _tolower.obj $(OBJ)
	del _tolower.obj

$(OBJ)\_toupper.obj: $(SRC)\_toupper.c $(COMP)
	cc $(FLAGS) $(SRC)\_toupper.c
	copy _toupper.obj $(OBJ)
	del _toupper.obj

$(OBJ)\_y0.obj: $(SRC)\_y0.c $(INCL)\math.h $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\_y0.c
	copy _y0.obj $(OBJ)
	del _y0.obj

$(OBJ)\_y1.obj: $(SRC)\_y1.c $(INCL)\math.h $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\_y1.c
	copy _y1.obj $(OBJ)
	del _y1.obj

$(OBJ)\_yn.obj: $(SRC)\_yn.c $(INCL)\math.h $(INCL)\_math.h $(INCL)\errno.h \
		$(INCL)\float.h  $(COMP)
	cc $(FLAGS) $(SRC)\_yn.c
	copy _yn.obj $(OBJ)
	del _yn.obj

$(OBJ)\__ffree.obj: $(SRC)\__ffree.c $(INCL)\stdio.h $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\__ffree.c
	copy __ffree.obj $(OBJ)
	del __ffree.obj

$(OBJ)\__nfree.obj: $(SRC)\__nfree.c $(INCL)\stdio.h $(INCL)\_alloc.h  $(COMP)
	cc $(FLAGS) $(SRC)\__nfree.c
	copy __nfree.obj $(OBJ)
	del __nfree.obj


#  ---------------------------------------
#      These functions from cbasea.arc
#  ---------------------------------------

$(OBJ)\87sincos.obj: $(SRC)\87sincos.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\87sincos;
	copy 87sincos.obj $(OBJ)
	del 87sincos.obj

$(OBJ)\87_arc.obj: $(SRC)\87_arc.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\87_arc;
	copy 87_arc.obj $(OBJ)
	del 87_arc.obj

$(OBJ)\87_data.obj: $(SRC)\87_data.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\87_data;
	copy 87_data.obj $(OBJ)
	del 87_data.obj

$(OBJ)\87_fac.obj: $(SRC)\87_fac.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\87_fac;
	copy 87_fac.obj $(OBJ)
	del 87_fac.obj

$(OBJ)\87_y2x.obj: $(SRC)\87_y2x.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\87_y2x;
	copy 87_y2x.obj $(OBJ)
	del 87_y2x.obj

$(OBJ)\alloca.obj: $(SRC)\alloca.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\alloca;
	copy alloca.obj $(OBJ)
	del alloca.obj

$(OBJ)\bdos.obj: $(SRC)\bdos.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\bdos;
	copy bdos.obj $(OBJ)
	del bdos.obj

$(OBJ)\cli.obj: $(SRC)\cli.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\cli;
	copy cli.obj $(OBJ)
	del cli.obj

$(OBJ)\cswitch.obj: $(SRC)\cswitch.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\cswitch;
	copy cswitch.obj $(OBJ)
	del cswitch.obj

$(OBJ)\ctl87.obj: $(SRC)\ctl87.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\ctl87;
	copy ctl87.obj $(OBJ)
	del ctl87.obj

$(OBJ)\ctype.obj: $(SRC)\ctype.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\ctype;
	copy ctype.obj $(OBJ)
	del ctype.obj

$(OBJ)\eoi.obj: $(SRC)\eoi.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\eoi;
	copy eoi.obj $(OBJ)
	del eoi.obj

$(OBJ)\exp10.obj: $(SRC)\exp10.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\exp10;
	copy exp10.obj $(OBJ)
	del exp10.obj

$(OBJ)\fix87s.obj: $(SRC)\fix87s.asm
	masm $(AFLAGS) $(SRC)\FIX87S;
	copy fix87s.obj $(OBJ)
	del fix87s.obj

#$(OBJ)\free_stk.obj: $(SRC)\free_stk.asm $(INCL)\prologue.ah
#	masm $(AFLAGS) $(SRC)\free_stk;
#	copy free_stk.obj $(OBJ)
#	del free_stk.obj

$(OBJ)\frexp.obj: $(SRC)\frexp.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\frexp;
	copy frexp.obj $(OBJ)
	del frexp.obj

$(OBJ)\inportb.obj: $(SRC)\inportb.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\inportb;
	copy inportb.obj $(OBJ)
	del inportb.obj

$(OBJ)\inportw.obj: $(SRC)\inportw.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\inportw;
	copy inportw.obj $(OBJ)
	del inportw.obj

$(OBJ)\intrserv.obj: $(SRC)\intrserv.asm $(INCL)\prologue.ah $(INCL)\intr.ah
	masm $(AFLAGS) $(SRC)\intrserv;
	copy intrserv.obj $(OBJ)
	del intrserv.obj

$(OBJ)\introld.obj: $(SRC)\introld.asm $(INCL)\prologue.ah $(INCL)\intr.ah
	masm $(AFLAGS) $(SRC)\introld;
	copy introld.obj $(OBJ)
	del introld.obj

$(OBJ)\iswap.obj: $(SRC)\iswap.asm $(INCL)\prologue.ah 
	masm $(AFLAGS) $(SRC)\iswap;
	copy iswap.obj $(OBJ)
	del iswap.obj

$(OBJ)\ldexp.obj: $(SRC)\ldexp.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\ldexp;
	copy ldexp.obj $(OBJ)
	del ldexp.obj

$(OBJ)\ldivide.obj: $(SRC)\ldivide.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\ldivide;
	copy ldivide.obj $(OBJ)
	del ldivide.obj

$(OBJ)\lmodulo.obj: $(SRC)\lmodulo.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\lmodulo;
	copy lmodulo.obj $(OBJ)
	del lmodulo.obj

$(OBJ)\loadexec.obj: $(SRC)\loadexec.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\loadexec;
	copy loadexec.obj $(OBJ)
	del loadexec.obj

$(OBJ)\longjmp.obj: $(SRC)\longjmp.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\longjmp;
	copy longjmp.obj $(OBJ)
	del longjmp.obj

$(OBJ)\lswitch.obj: $(SRC)\lswitch.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\lswitch;
	copy lswitch.obj $(OBJ)
	del lswitch.obj

$(OBJ)\memcpy.obj: $(SRC)\memcpy.asm
	masm $(AFLAGS) $(SRC)\memcpy;
	copy memcpy.obj $(OBJ)
	del memcpy.obj

$(OBJ)\memset.obj: $(SRC)\memset.asm
	masm $(AFLAGS) $(SRC)\memset;
	copy memset.obj $(OBJ)
	del memset.obj

$(OBJ)\movmem.obj: $(SRC)\movmem.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\movmem;
	copy movmem.obj $(OBJ)
	del movmem.obj

$(OBJ)\n87init.obj: $(SRC)\n87init.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\n87init;
	copy n87init.obj $(OBJ)
	del n87init.obj

$(OBJ)\outportb.obj: $(SRC)\outportb.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\outportb;
	copy outportb.obj $(OBJ)
	del outportb.obj

$(OBJ)\outportw.obj: $(SRC)\outportw.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\outportw;
	copy outportw.obj $(OBJ)
	del outportw.obj

$(OBJ)\segread.obj: $(SRC)\segread.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\segread;
	copy segread.obj $(OBJ)
	del segread.obj

$(OBJ)\setjmp.obj: $(SRC)\setjmp.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\setjmp;
	copy setjmp.obj $(OBJ)
	del setjmp.obj

$(OBJ)\sswitch.obj: $(SRC)\sswitch.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\sswitch;
	copy sswitch.obj $(OBJ)
	del sswitch.obj

$(OBJ)\stackava.obj: $(SRC)\stackava.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\stackava;
	copy stackava.obj $(OBJ)
	del stackava.obj

$(OBJ)\stat87.obj: $(SRC)\stat87.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\stat87;
	copy stat87.obj $(OBJ)
	del stat87.obj

$(OBJ)\sti.obj: $(SRC)\sti.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\sti;
	copy sti.obj $(OBJ)
	del sti.obj

$(OBJ)\strcat.obj: $(SRC)\strcat.asm $(INCL)\prologue.ah 
	masm $(AFLAGS) $(SRC)\strcat.asm;
	copy strcat.obj $(OBJ)
	del strcat.obj

$(OBJ)\strcmp.obj: $(SRC)\strcmp.asm $(INCL)\prologue.ah 
	masm $(AFLAGS) $(SRC)\strcmp.asm;
	copy strcmp.obj $(OBJ)
	del strcmp.obj

$(OBJ)\strcpy.obj: $(SRC)\strcpy.asm $(INCL)\prologue.ah 
	masm $(AFLAGS) $(SRC)\strcpy.asm;
	copy strcpy.obj $(OBJ)
	del strcpy.obj

$(OBJ)\strlen.obj: $(SRC)\strlen.asm $(INCL)\prologue.ah 
	masm $(AFLAGS) $(SRC)\strlen.asm;
	copy strlen.obj $(OBJ)
	del strlen.obj

$(OBJ)\sysint.obj: $(SRC)\sysint.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\sysint;
	copy sysint.obj $(OBJ)
	del sysint.obj

$(OBJ)\sysint21.obj: $(SRC)\sysint21.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\sysint21;
	copy sysint21.obj $(OBJ)
	del sysint21.obj

$(OBJ)\_acos.obj: $(SRC)\_acos.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_acos;
	copy _acos.obj $(OBJ)
	del _acos.obj

$(OBJ)\_asin.obj: $(SRC)\_asin.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_asin;
	copy _asin.obj $(OBJ)
	del _asin.obj

$(OBJ)\_atan.obj: $(SRC)\_atan.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_atan;
	copy _atan.obj $(OBJ)
	del _atan.obj

$(OBJ)\_cabs.obj: $(SRC)\_cabs.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_cabs;
	copy _cabs.obj $(OBJ)
	del _cabs.obj

$(OBJ)\_ceil.obj: $(SRC)\_ceil.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_ceil;
	copy _ceil.obj $(OBJ)
	del _ceil.obj

$(OBJ)\_chkstk.obj: $(SRC)\_chkstk.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\_chkstk;
	copy _chkstk.obj $(OBJ)
	del _chkstk.obj

$(OBJ)\_clear87.obj: $(SRC)\_clear87.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_clear87;
	copy _clear87.obj $(OBJ)
	del _clear87.obj

$(OBJ)\_cos.obj: $(SRC)\_cos.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_cos;
	copy _cos.obj $(OBJ)
	del _cos.obj

$(OBJ)\_cotan.obj: $(SRC)\_cotan.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_cotan;
	copy _cotan.obj $(OBJ)
	del _cotan.obj

$(OBJ)\_doexec.obj: $(SRC)\_doexec.asm $(INCL)\prologue.ah
        masm $(AFLAGS) $(SRC)\_doexec;
        copy _doexec.obj $(OBJ)
        del _doexec.obj

$(OBJ)\_dosf25.obj: $(SRC)\_dosf25.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\_dosf25;
	copy _dosf25.obj $(OBJ)
	del _dosf25.obj

$(OBJ)\_dosf35.obj: $(SRC)\_dosf35.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\_dosf35;
	copy _dosf35.obj $(OBJ)
	del _dosf35.obj

$(OBJ)\_dosf3f.obj: $(SRC)\_dosf3f.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\_dosf3f;
	copy _dosf3f.obj $(OBJ)
	del _dosf3f.obj

$(OBJ)\_dosf40.obj: $(SRC)\_dosf40.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\_dosf40;
	copy _dosf40.obj $(OBJ)
	del _dosf40.obj

$(OBJ)\_dosf48.obj: $(SRC)\_dosf48.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\_dosf48;
	copy _dosf48.obj $(OBJ)
	del _dosf48.obj

$(OBJ)\_dosf49.obj: $(SRC)\_dosf49.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\_dosf49;
	copy _dosf49.obj $(OBJ)
	del _dosf49.obj

$(OBJ)\_dosf4a.obj: $(SRC)\_dosf4a.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\_dosf4a;
	copy _dosf4a.obj $(OBJ)
	del _dosf4a.obj

$(OBJ)\_dtobcd.obj: $(SRC)\_dtobcd.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_dtobcd;
	copy _dtobcd.obj $(OBJ)
	del _dtobcd.obj

$(OBJ)\_exp.obj: $(SRC)\_exp.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_exp;
	copy _exp.obj $(OBJ)
	del _exp.obj

$(OBJ)\_fcmp.obj: $(SRC)\_fcmp.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_fcmp;
	copy _fcmp.obj $(OBJ)
	del _fcmp.obj

$(OBJ)\_floor.obj: $(SRC)\_floor.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_floor;
	copy _floor.obj $(OBJ)
	del _floor.obj

$(OBJ)\_fpreset.obj: $(SRC)\_fpreset.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_fpreset;
	copy _fpreset.obj $(OBJ)
	del _fpreset.obj

$(OBJ)\_ftol.obj: $(SRC)\_ftol.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_ftol;
	copy _ftol.obj $(OBJ)
	del _ftol.obj

$(OBJ)\_log.obj: $(SRC)\_log.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_log;
	copy _log.obj $(OBJ)
	del _log.obj

$(OBJ)\_modf.obj: $(SRC)\_modf.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_modf;
	copy _modf.obj $(OBJ)
	del _modf.obj

$(OBJ)\_pow.obj: $(SRC)\_pow.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_pow;
	copy _pow.obj $(OBJ)
	del _pow.obj

$(OBJ)\_quit.obj: $(SRC)\_quit.asm $(INCL)\prologue.ah
	masm $(AFLAGS) $(SRC)\_quit;
	copy _quit.obj $(OBJ)
	del _quit.obj

$(OBJ)\_sigint.obj: $(SRC)\_sigint.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_sigint;
	copy _sigint.obj $(OBJ)
	del _sigint.obj

$(OBJ)\_sin.obj: $(SRC)\_sin.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_sin;
	copy _sin.obj $(OBJ)
	del _sin.obj

$(OBJ)\_sqrt.obj: $(SRC)\_sqrt.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_sqrt;
	copy _sqrt.obj $(OBJ)
	del _sqrt.obj

$(OBJ)\_square.obj: $(SRC)\_square.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_square;
	copy _square.obj $(OBJ)
	del _square.obj

$(OBJ)\_tan.obj: $(SRC)\_tan.asm $(INCL)\prologue.ah
	masm $(AFLAGS) /e $(SRC)\_tan;
	copy _tan.obj $(OBJ)
	del _tan.obj



