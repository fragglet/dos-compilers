#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

struct Vio_Config 
	{
	unsigned size ;			/* Size in bytes (must be 8) */
	unsigned adapter;		/* Video adapter type */
	unsigned display;		/* Video display type */
	unsigned long memory;		/* Memory size in bytes */
	};

struct Vio_Cursor 
	{
	unsigned start;			/* Cursor start line */
	unsigned end;			/* Cursor end line */
	unsigned width;			/* Cursor width */
	unsigned attr;		 	/* Cursor attribute */
	};

struct Vio_Font 
	{
	unsigned size;			/* Size in bytes (must be 14) */
	unsigned type;			/* 0=current font, 1=ROM font */
	unsigned width;			/* Character cell width */
	unsigned height;		/* Character cell height */
	char far *font;			/* Far ptr to font data area */
	unsigned fontsize;		/* Font size in bytes */
	};

struct Vio_Mode 
	{
	unsigned size;			/* Size in bytes (must be 12) */
	unsigned char type;		/* Text or graphics */
	unsigned char color;		/* Color or monochrome */
	unsigned tcols;			/* No. of text columns */
	unsigned trows;			/* No. of text rows */
	unsigned pcols;			/* No. of pixel columns */
	unsigned prows;			/* No. of pixel rows */
	};

struct Vio_PhysBuf 
	{
	unsigned long buf_start;	/* Physical address of buffer */
	unsigned long buf_length;	/* Size of buffer (in bytes) */
	unsigned short selectors[2];	/* 1 or more selectors (assume 2) */
	};

struct Vio_State 
	{
	unsigned size;			/* Size in bytes (max 38) */
	unsigned type;			/* 0 = set palette regs   */
					/* 1 = set overscan color */
	unsigned color;			/* type = 0:	             */
					/*  first palette reg to set */
					/* type = 1:		     */
					/*  border (overscan) color  */
	unsigned palette[16];		/* color values */
	};

OS2API VioDeRegister (void);
OS2API VioEndPopup (unsigned);
OS2API VioGetANSI (unsigned far *,unsigned);
OS2API VioGetBuf (unsigned long far *,unsigned far *,unsigned);
OS2API VioGetConfig (unsigned,struct Vio_Config far *,unsigned);
OS2API VioGetCP (unsigned,unsigned far *,unsigned);
OS2API VioGetCurPos (unsigned far *,unsigned far *,unsigned);
OS2API VioGetCurType (struct Vio_Cursor far *,unsigned);
OS2API VioGetFont (struct Vio_Font far *,unsigned);
OS2API VioGetMode (struct Vio_Mode far *,unsigned);
OS2API VioGetPhysBuf (struct Vio_PhysBuf far *,unsigned);
OS2API VioGetState (struct Vio_State far *,unsigned);
OS2API VioModeUndo (unsigned,unsigned,unsigned);
OS2API VioModeWait (unsigned,unsigned far *,unsigned);
OS2API VioPopUp (unsigned far *,unsigned);
OS2API VioPrtSc (unsigned);
OS2API VioPrtScToggle (unsigned);
OS2API VioReadCellStr (char far *,unsigned far *,unsigned,unsigned,unsigned);
OS2API VioReadCharStr (char far *,unsigned far *,unsigned,unsigned,unsigned);
OS2API VioRegister (char far *,char far *,unsigned long,unsigned long);
OS2API VioSavReDrawUndo (unsigned,unsigned,unsigned);
OS2API VioSavReDrawWait (unsigned,unsigned far *,unsigned);
OS2API VioScrLock (unsigned,unsigned char far *,unsigned);
OS2API VioScrollDn (unsigned,unsigned,unsigned,unsigned,unsigned,char far *,unsigned);
OS2API VioScrollLf (unsigned,unsigned,unsigned,unsigned,unsigned,char far *,unsigned);
OS2API VioScrollRt (unsigned,unsigned,unsigned,unsigned,unsigned,char far *,unsigned);
OS2API VioScrollUp (unsigned,unsigned,unsigned,unsigned,unsigned,char far *,unsigned);
OS2API VioScrUnlock (unsigned);
OS2API VioSetANSI (unsigned,unsigned);
OS2API VioSetCP (unsigned,unsigned,unsigned);
OS2API VioSetCurPos (unsigned,unsigned,unsigned);
OS2API VioSetCurType (struct Vio_Cursor far *,unsigned);
OS2API VioSetFont (struct Vio_Font far *,unsigned);
OS2API VioSetMode (struct Vio_Mode far *,unsigned);
OS2API VioSetState (struct Vio_State far *,unsigned);
OS2API VioShowBuf (unsigned,unsigned,unsigned);
OS2API VioWrtCellStr (char far *,unsigned,unsigned,unsigned,unsigned);
OS2API VioWrtCharStr (char far *,unsigned,unsigned,unsigned,unsigned);
OS2API VioWrtCharStrAtt (char far *,unsigned,unsigned,unsigned,char far *,unsigned);
OS2API VioWrtNAttr (char far *,unsigned,unsigned,unsigned,unsigned);
OS2API VioWrtNCell (char far *,unsigned,unsigned,unsigned,unsigned);
OS2API VioWrtNChar (char far *,unsigned,unsigned,unsigned,unsigned);
OS2API VioWrtTTY (char far *,unsigned,unsigned);

#if OS2CAPS
#define VIODEREGISTER VioDeRegister
#define VIOENDPOPUP VioEndPopUp
#define VIOGETANSI VioGetANSI
#define VIOGETBUF VioGetBuf
#define VIOGETCONFIG VioGetConfig
#define VIOGETCP VioGetCP
#define VIOGETCURPOS VioGetCurPos
#define VIOGETCURTYPE VioGetCurType
#define VIOGETFONT VioGetFont
#define VIOGETMODE VioGetMode
#define VIOGETPHYSBUF VioGetPhysBuf
#define VIOGETSTATE VioGetState
#define VIOMODEUNDO VioModeUndo
#define VIOMODEWAIT VioModeWait
#define VIOPOPUP VioPopUp
#define VIOPRTSC VioPrtSc
#define VIOPRTSCTOGGLE VioPrtScToggle
#define VIOREADCELLSTR VioReadCellStr
#define VIOREADCHARSTR VioReadCharStr
#define VIOREGISTER VioRegister
#define VIOSAVREDRAWUNDO VioSavRedrawUndo
#define VIOSAVREDRAWWAIT VioSavRedrawWait
#define VIOSCRLOCK VioScrLock
#define VIOSCROLLDN VioScrollDn
#define VIOSCROLLLF VioScrollLf
#define VIOSCROLLRT VioScrollRt
#define VIOSCROLLUP VioScrollUp
#define VIOSCRUNLOCK VioScrUnlock
#define VIOSETANSI VioSetANSI
#define VIOSETCP VioSetCP
#define VIOSETCURPOS VioSetCurPos
#define VIOSETCURTYPE VioSetCurType
#define VIOSETFONT VioSetFont
#define VIOSETMODE VioSetMode
#define VIOSETSTATE VioSetState
#define VIOSHOWBUF VioShowBuf
#define VIOWRTCELLSTR VioWrtCellStr
#define VIOWRTCHARSTR VioWrtCharStr
#define VIOWRTCHARSTRATT VioWrtCharStrAtt
#define VIOWRTNATTR VioWrtNAttr
#define VIOWRTNCELL VioWrtNCell
#define VIOWRTNCHAR VioWrtNChar
#define VIOWRTTTY VioWrtTTY
#endif
