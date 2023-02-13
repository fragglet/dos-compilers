/* conio.h - low level I/O function prototypes
** Copyright (C) 1986 Computer Innovations, Inc. ALL RIGHTS RESERVED
*/

#ifndef _conioh
#define _conioh

char *cgets(char *);
int cprintf(char *, ...);
void cputs(char *);
int cscanf(char *, ...);
int getch(void);
int getche(void);
char inp(int );
char inportb(int );
int inportw(int );
int kbhit(void);
int outp(unsigned , int );
char outportb(unsigned , char );
int outportw(unsigned , int );
int peek(unsigned , unsigned );
unsigned pokeb(unsigned , unsigned , char );
unsigned pokew(unsigned , unsigned , unsigned );
void putch(int );

#endif /* _conioh */

