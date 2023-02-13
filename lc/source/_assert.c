#include <stdio.h>
#include <stdlib.h>
/**
*
* name		_assert -- print assertion failure message
*
* synopsis	_assert(exp,file,line);
*		char *exp;	expression that failed
*		char *file;	file name
*		int  line;	line number
*
* description	This function is called by the assert macro when the
*		specified expression is false.  It prints an appropriate
*		message on stderr.
*
**/
void _assert(exp,file,line)
char *exp,*file;
int line;
{
fprintf(stderr,"Assertion (%s) failed in file %s at line %d\n",exp,file,line);
exit(1);

}
