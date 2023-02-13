#include <dos.h>
/**
* 
* name		cget -- get character from console (no echo)
*		cgetc -- get character from console (echo)
*		cgets -- get character string from console (echo)
*		getch -- same as cget
*		getche -- same as cgetc
*		iskbecho -- test if keyboard is in echo mode
*		iskbraw -- test if keyboard is in raw mode
*		iskbhit -- test if keyboard character is present
*		kbhit -- same as iskbhit
*		kbecho -- set/reset echo mode
*		kbraw -- set/reset raw mode
*		ungetch -- push a character back to the keyboard
*		
*
* synopsis	c = getch();
*		c = getche();
*		c = ungetch(c);
*
*		t = iskbecho();
*		t = iskbraw();
*		t = kbhit();
*		int c;		input character
*
* description	This function obtains the next character typed at
*		the console or, if one was pushed back via "ungetch",
*		returns the previously pushed back character.
*
**/
/**
*
* External references
*
*/
extern far pascal KbdCharIn();
extern far pascal KbdGetStatus();
extern far pascal KbdPeek();
extern far pascal KbdSetStatus();
extern far pascal KbdStringIn();
extern int _OSERR;
/**
*
* Static data
*/
char _cpush = 0;	/* character save for "ungetch" */ 
/**
*
* Set or reset echo mode
*
*/
kbecho(s)
int s;
{
struct KBDINFO x;

memset((char *)(&x),0,sizeof(struct KBDINFO));  /* reset data area */
x.size = sizeof(struct KBDINFO);	/* load length */
x.mode = (s ? 1 : 2);			/* set echo on/off flag */
return(CXCERR(KbdSetStatus((struct KBDINFO far *)(&x),0)));
}
/**
*
* Set or reset raw mode
*
*/
kbraw(s)
int s;
{
struct KBDINFO x;

memset((char *)(&x),0,sizeof(struct KBDINFO));  /* reset data area */
x.size = sizeof(struct KBDINFO);	/* load length */
x.mode = (s ? 4 : 8);			/* set raw on/off flag */
return(CXCERR(KbdSetStatus((struct KBDINFO far *)&x,0)));
}
/**
*
* Test if keyboard character is present
*
*/
kbhit()
{
struct KBDDATA x;

if(_OSERR = KbdPeek((struct KBDDATA far *)&x,0)) return(CXCERR(_OSERR));
if(x.status) return(1);
return(0);
}

iskbhit()
{
return(kbhit());
}
/**
*
* Test if in echo mode
*
*/
iskbecho()
{
struct KBDINFO x;

x.size = sizeof(struct KBDINFO);	/* load length */
if(_OSERR = KbdGetStatus((struct KBDINFO far *)&x,0)) return(CXCERR(_OSERR));
return((x.mode & 1) ? 1 : 0);
}
/**
*
* Test if in raw mode
*
*/
iskbraw()
{
struct KBDINFO x;

x.size = sizeof(struct KBDINFO);	/* load length */
if(_OSERR = KbdGetStatus((struct KBDINFO far *)&x,0)) return(CXCERR(_OSERR));
return((x.mode & 4) ? 1 : 0);
}
/**
*
* Get a character without echoing it
*
*/
getch()
{
int c,echo;
struct KBDDATA x;

if(c = _cpush)
   {
   _cpush = 0;
   return(c);
   }
if(echo = iskbecho()) if(kbecho(0)) return(-1); 
if(_OSERR = KbdCharIn((struct KBDDATA far *)&x,0,0)) return(CXCERR(_OSERR));
if(echo) if(kbecho(1)) return(-1); 
if((x.acode == 0) || (x.acode == 0xe0)) 
	{
	_cpush = x.scode;
	return(0);
	}
return((int)x.acode);
}
cget()
{
return(getch());
}
/**
*
* Get a character and echo it
*
*/
getche()
{
int c,echo;
struct KBDDATA x;

if(c = _cpush)
   {
   _cpush = 0;
   return(c);
   }
if((echo = iskbecho()) == 0) if(kbecho(1)) return(-1);
if(_OSERR = KbdCharIn((struct KBDDATA far *)&x,0,0)) return(CXCERR(_OSERR)); 
if(echo == 0) if(kbecho(0)) return(-1);
return((int)x.acode);
}
cgetc()
{
return(getche());
}
/**
*
* Push a character back onto the 1-level keyboard stack
*
*/
ungetch(c)
int c;
{

if(_cpush) return(-1);
_cpush = c;
return(c);
}
/*
*
* Get a character string
*
*/
char *cgets(b)
char *b;
{
int size = 255;
char *p;

if(_OSERR = KbdStringIn((char far *)b,(int far *)&size,0,0)) 
	{
	CXCERR(_OSERR);
	return(NULL);
	}
for(p = b; size-- > 0; p++) if((*p == '\r') || (*p == '\n')) break;
*p = '\0';
return(b);
}







