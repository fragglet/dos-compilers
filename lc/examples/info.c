/**
*
* name		info -- display information about this system
*
* description	This program displays the configuration information for
*		the system on which it is executing.  It also shows how
*		to use some of the DOS-specific calls included in the
*		Lattice C Compiler package.
*
*		Note: requires oserr.c
*
**/
/*
*
* Header files
*
*/
#include <stdio.h>
#include <dos.h>
#include <fcntl.h>
#include <string.h>
/**
*
* Static data
*
*/
union REGS regs;		/* register structure */
extern int _OSERR;		/* error number */
extern char *os_errlist[];	/* error list from oserr.c */
extern char _dos[2];  		/* main sets dos version */
extern char _NDP;		/* numeric data processor flag */
unsigned char clock[9];		/* clock array */
char date[30];			/* date string */
char time[30];			/* clock string */
char name[16];			/* network name */
char path[80];			/* current drive and path */
char *days[] = {
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday"
	};
/**
*
* Main program
*
*/	
main(argc,argv,envp)
int argc;
char *argv[];
char *envp[];
{
char *p;
char **tmp;
char drive[2];
int fh,i,x,y;
/**
*
* Display system type
*
*/
p = NULL;
if(isibmat()) p = "PC/AT";
if(isibmpc()) p = "PC or PC/XT";
if(isibmjr()) p = "PC/Jr";
if(p != NULL) printf("I am an IBM %s\n",p);
else puts("I don't know what I am, but I feel OK.\n");
/**
*
* Display DOS version
*
*/
printf("I'm under control of DOS Version %d.%d.\n",_dos[0],_dos[1]);
/**
*
* Display the current time
*
*/
getclk(clock);
stpdate(date,5,&clock[1]);
stptime(time,4,&clock[4]);
printf("My clock says that it is %s %s at %s.\n",days[clock[0]],date,time);
/**
*
* Display memory size
*
*/
int86(0x12,&regs,&regs);
printf("My BIOS reports %d kilobytes of RAM installed.\n",regs.x.ax);
/**
*
* Display math chip installation state
*
*/
if(_NDP) p = "an";
else p = "no";
printf("I have %s 8087 or 80287 Numeric Data Processor.\n",p);
/**
*
* Display video mode
*
*/
regs.h.ah = 15;				/* read the crt mode */		
int86(0x10,&regs,&regs);
if (regs.h.al == 7) puts("I am using a monochrome display.");
else puts("I am using a color display.");
/**
*
* Display break state
*
*/
printf("BREAK is %s.\n",getbrk() ? "ON" : "OFF");
/**
*
* Display verify mode
*
*/
printf("VERIFY is %s.\n",getvfy() ? "ON" : "OFF");
/**
*
* Display the contents of the environment area
*
*/
puts("\nMy environment area contains:");
for (tmp = envp; *tmp; tmp++)
	puts(*tmp);
puts("");
/**
*
* Display the current drive an path
*
*/
if (getcd(0,path) == 0)
	{
	strins(path,":");
	drive[0] = getdsk() + 'A';
	drive[1] = 0;
	strins(path,drive);
	printf("Current Path: %s\n\n",path);
	}
else
	printerr("\nCannot read Path: ",_OSERR);
/**
*
* Display network name
*
*/
if( (_dos[0] == 3) && (_dos[1] >= 10) && isnet() ) 
	{
	puts("Press any key for network information");
	getch();
	x = pcngmn(name);
	i = _OSERR;
	if(x == -1) 
		printerr("\nCannot get network name: ",_OSERR);
	else
		printf("My network name is %s and my machine number is %d.\n",name,x);
/**
*
* Display network status of block devices
*
*/
	x = chgdsk(100);
	for(i = 1; i <= x; i++) 
		{
		y = isnetdc(i);
		if(y > 0) p = "a network";
		if(y == 0) p = "a local";
		if(y < 0) p = "an unequipped";
		printf("My drive %c is %s drive.\n",i+'A'-1,p);
		}
/**
*
* Display network status of all file names passed as arguments
*
*/	
	for(i = 1; i < argc; i++)
		{
		strupr(argv[i]);
		if((fh = open(argv[i],O_RDONLY)) >= 0) 
			{
			if(isnetfh(fh) > 0) 
				printf("%s is on the network",argv[1]);
			else printf("%s is not on the network",argv[1]);
			close(fh);
			}
		else printf("I can't open %s\n",argv[i]);
		}
	}
/**
*
* Conclude
*
*/
puts("*** END OF REPORT ***");
}


/**
*
*	Print the passed message and the error type passsed
*
*/
printerr(msg,err)
char *msg;
int err;
{
printf("%s%s\n",msg,os_errlist[err]);
}
