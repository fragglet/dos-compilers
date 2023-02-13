#include <dos.h>
#include <stdio.h>
#include <fcntl.h>
#include <ios1.h>

extern char _PMODE,**_ARGV,**environ;
extern int _ARGC;
extern struct UFB _ufbs[];

#ifndef TINY
extern int _fmode;
#endif

/**
*
* name         _main - open standard files and call "main"
*
* synopsis     _main();
*
* description	This function performs the standard pre-processing for
*		the main module of a C program.  It assumes that the 
*		low-level startup routine has set up the appropriate 
*		global variables.
*
**/
void _main()
{
#ifndef TINY
int x;
#endif
/*
*
* Open standard files
*
*/
#ifndef TINY
x = ((_fmode) ? 0 : _IOXLAT);
stdin->_file = 0;
stdin->_flag = _IOREAD | x;
stdout->_file = 1;
stdout->_flag = _IOWRT | x;
if (isadev(1)) stdout->_flag |= _IONBF;
stderr->_file = 2;
stderr->_flag = _IORW | _IONBF | x;
if( !_PMODE )
	{
	stdaux->_file = 3;
	stdaux->_flag = _IORW | x;
	stdprt->_file = 4;
	stdprt->_flag = _IOWRT | x;
	_ufbs[3].ufbfh = 3;
	_ufbs[3].ufbflg = UFB_RA | UFB_WA ;
	_ufbs[4].ufbfh = 4;
	_ufbs[4].ufbflg = UFB_WA ;
	}
if(x == 0)
	{
	_ufbs[0].ufbflg |= O_RAW;
	_ufbs[1].ufbflg |= O_RAW;
	_ufbs[2].ufbflg |= O_RAW;
	if( !_PMODE )
		{
		_ufbs[3].ufbflg |=  O_RAW;
		_ufbs[4].ufbflg |=  O_RAW;
		}
	}
#endif
/*
*
* Call user's main program
*
*/
main(_ARGC,_ARGV,environ);              /* call main function */
#ifndef TINY
exit(0);
#else
_exit(0);
#endif
}

