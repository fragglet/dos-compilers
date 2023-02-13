/*
**
**	To set the stack space, compile this file as follows:
**
**		lc -m? -su=stack,stack -dSTACK=desired_size stack
**
**	and then link the object file into your program.
**
**	Example: to get a 20K stack for large model
**
**		lc -ml -su=stack,stack -dSTACK=20*1024 stack
**
*/
#ifndef STACK
#define	STACK	(6 * 1024)
#endif

#define MINSTK	2048

int	__SSIZE = STACK - MINSTK;

char	__STACK[STACK - MINSTK];
