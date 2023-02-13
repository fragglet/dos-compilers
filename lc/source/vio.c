#include <dos.h>
/**
*
* name		putch -- put a character to the screen
*		cputc -- same as putch
*		cputs -- put a character string to the screen
*
* synopsis	ret = putch(c);
*		ret = cputc(c);
*		length = cputs(s);
*
* description	These function put single characters or character strings
*		to the screen at the current cursor position.  Newlines
*		are translated into CR-LF sequences.
*
**/
extern far pascal VioWrtTTY();
static char eol[2] = {'\r','\n'};
putch(c)
int c;
{
if(c == '\n') VioWrtTTY((char far *)eol,2,0);
else VioWrtTTY((char far *)(&c),1,0);
return(c);
}

cputc(c)
unsigned int c;
{
return(putch(c));
}

cputs(s)
unsigned char *s;
{
int i,j;

for(i = 0; *s != '\0'; i += j+1)
	{
	for(j = 0;(s[i+j] != '\0') && (s[i+j] != '\n'); j++);
	if(j) VioWrtTTY((char far *)(&s[i]),j,0);
	if(s[i+j] == '\0') return(i+j);
	VioWrtTTY((char far *)eol,2,0);
	}
return(i);
}
