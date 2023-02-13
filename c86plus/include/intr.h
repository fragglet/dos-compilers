/* INTR.H: Header file for the Interrupt service routine gateways.
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef	_intrh 
int intrinit(void (*)(), unsigned int, int);
int intrset(void (far *)(), unsigned int, unsigned int, char *, unsigned);
void intrserv();
void (far * _dosf35(int))();
void _dosf25(int,void (far *)());

struct intr_frame {		/* registers at time of interrupt */
  unsigned short es;	
  unsigned short ds;
  unsigned short di;
  unsigned short si;
  unsigned short bp;
  unsigned short dummy;		/* no useful value */
  unsigned short bx;
  unsigned short dx;
  unsigned short cx;
  unsigned short ax;
  unsigned short dummy1;	/* no useful value */	
  struct icb far *icb_ptr; 	/* Pointer to our interrupt control block */
  void (far *interruptee)();	/* Interrupted routine */
  unsigned short flags;		/* Processor flags at time of interrupt */
};

struct icb {
  unsigned char vecno;		/* the interrupt number */
  unsigned char farcall_opcode;
  void (far *gateway)();	/* address of intrserv() */
  unsigned short frame_size;	/* stack needed for each invocation */
  unsigned short sub_sp;	/* current "stack top" */
  void (far *new_isr)();	/* address of c code */
  void (far *old_isr)();	/* the old service routine */
  char *free_base;			/* the base of the whole stack */
};

#define _intrh
#endif

