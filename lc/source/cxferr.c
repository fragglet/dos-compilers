#include <signal.h>
/**
*
* name		CXFERR -- low-level floating point error trap 
*
* synopsis	CXFERR(code);
*		int code;	error code (see math.h)
*
* description	This function is called when an error is detected by
*		one of the low-level floating point routines, such as
*		the arithmetic operations.  Higher-level routines such
*		as the transcendental functions, use the more sophisti-
*		cated "matherr" trap.
*
*		Users can replace this trap with application-dependent
*		code, as long as they still store the error code into
*		the global variable "_FPERR".  This is necessary because
*		some of the math functions check "_FPERR" to see if
*		low-level errors occurred.	
*
**/
extern int _FPERR;
extern int (*_SIGFPE)();
CXFERR(code)
int code;
{
_FPERR = code;
if((_SIGFPE != SIG_DFL) && (_SIGFPE != SIG_IGN)) (*_SIGFPE)(SIGFPE);
}

