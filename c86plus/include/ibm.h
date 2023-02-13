/* ibm.h - routines dependant on the ROM BIOS
** Copyright (C) 1986,87 Computer Innovations, Inc. ALL RIGHTS RESERVED
*/

#ifndef _ibmh
#define _ibmh

int  com_getc(int channel);
int  com_putc(int channel, char c);
int  com_rdy(int channel);
int  com_rst(int channel, int baud, int parity, int stop, int length);
unsigned com_stat(int channel);

void crt_cls(void);
void crt_home(void);
int crt_gmod(void);
unsigned crt_grcp(void);
int  crt_line(unsigned x1, unsigned y1, unsigned x2, unsigned y2, int color);
int  crt_mode(int mode);
int  crt_putc(char c, int attribute);
int  crt_rdot(int row, int column);
int  crt_roll(int top, int bottom, int left, int right, int n);
int  crt_srcp(int row, int column, int page);
int  crt_wdot(int row, int column, int color);

int  key_getc(void);
int  key_scan(void);
int  key_shft(void);

int  prt_busy(int printer);
int  prt_err(int printer);
int  prt_putc(int printer, char c);
int  prt_rst(int printer);
void prt_scr(void);
int  prt_stat(int printer);

#endif /* _ibmh */

