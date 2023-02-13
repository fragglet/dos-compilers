#define GFX_PALETTE -1             /* set GFX PALETTE with COLOR() */

#define  DRAW_LINE   0             /* values for LINE() */
#define  FILL_BOX    1
#define  EMPTY_BOX   2
#define  PAT         0x400

#define DFLT         -14232        /* default value */
#define CURR_PT      -1347         /* relative coordinates */
#define STEP         -2415
#define XOR_PEL     0x2000

#define FLT_CURR_PT -275864.312
#define FLT_STEP    -982132.001
#define FLT_DFLT    -723943.914

#define PI          3.141593       /* for setting angles in ARC() */
#define ROUND       -1.1           /* for specifying a circular ARC() */


#define MONO_DISPLAY     0x1       /* Values for gfx.card_monitor */
#define COLOR_DISPLAY    0x2
#define EGA_DISPLAY      0x4
#define VGA_DISPLAY      0x8
#define MDA_CARD         0x100
#define CGA_CARD         0x200
#define EGA_CARD         0x400
#define VGA_CARD         0x800
#define HERC_CARD        0x1000
#define EGA_HERC         (EGA_CARD | HERC_CARD)

#define NOT_SET          0xFFFF         /* Values for gfx.bios_mode */
#define BW_40_TEXT       0
#define COLOR_40_TEXT    1
#define BW_80_TEXT       2
#define COLOR_80_TEXT    3
#define GRAPHICS         4
#define MED_RES_COLOR    4
#define MED_RES_BW       5
#define HI_RES_BW        6
#define MONO_TEXT        7
#define HERC_TEXT        8
#define HERC_GFX         9
#define EGA_MED_RES      0xD
#define EGA_HI_RES       0xE
#define EGA_MONO         0xF
#define EGA_COLOR        0x10
#define VGA_MONO         0x11
#define VGA_COLOR        0x12

#define ROM_8x8		1	/* Pre-defined ROM font handles */
#define ROM_8x14		2

#define FORCE_BIOS_MODE       0x8000
#define FORCE_EGA_MED_RES     FORCE_BIOS_MODE + EGA_MED_RES
#define FORCE_EGA_HI_RES      FORCE_BIOS_MODE + EGA_HI_RES
#define FORCE_EGA_MONO        FORCE_BIOS_MODE + EGA_MONO
#define FORCE_EGA_COLOR       FORCE_BIOS_MODE + EGA_COLOR
#define FORCE_VGA_MONO        FORCE_BIOS_MODE + VGA_MONO
#define FORCE_VGA_COLOR       FORCE_BIOS_MODE + VGA_COLOR

#define OR_EGA_MED_RES        0xD00
#define OR_EGA_HI_RES         0xE00
#define OR_EGA_MONO           0xF00
#define OR_EGA_COLOR          0x1000
#define OR_VGA_MONO           0x1100
#define OR_VGA_COLOR          0x1200
#define NO_MODE_CHANGE        0x7300

#define _gfx_error(text_string)    _set_gfx_err_number(0, text_string)
#define FREE_PIC(a)  free(a)

#define BAD_ARG          1
#define BAD_VIDEO        2
#define BAD_ASPECT       3
#define BAD_ANGLE        4
#define NO_DISK_SPACE    5
#define NO_HEAP_SPACE    6
#define PAINT_OVERFLOW   7
#define OUT_OF_VIEW      8
#define BAD_VIEW_HANDLE  9
#define WRONG_PIC_TYPE   10
#define NOT_A_PIC_FILE   11
#define BAD_FPIC_INDEX   12
#define BAD_FPIC_HANDLE  13
#define BAD_FONT_HANDLE  14


#define MAX_FPIC_CB      10


struct _arc {
     int col;       /* parameters for 'CURVE' routines */
     int row;
     int rad;
     int color;
     double aspect;
     double start;
     double end;
     void (*write_pix)(int, int);
     };


typedef struct _gfx_scale { int x_num, x_denom, y_num, y_denom;
                            double x_flt, y_flt; } SCALE;

typedef struct _vu {

     unsigned int bkgnd;       /* background color */
     unsigned int fgnd;        /* forground color */
     unsigned int font_handle; /* current font for view */
     unsigned int auto_scale;  /* use auto-scaling */
     unsigned int xlat_scale;  /* the auto-scaling factor */

     int v_start_byte;        /* first byte */
     int v_nbytes_wide;       /* viewport's width -- in bytes */
     int n_pels_high;         /* viewport's height */
     int n_pels_wide;

     int min_x, min_y;        /* viewport's upper left corner */
     int max_x, max_y;        /* viewport's lower right corner */
     int pt_x, pt_y;          /* current x,y coordinate pair */
     int ilog_x, ilog_y;      /* logical x,y pair for integer scaling */
     double flog_x, flog_y;   /* logical x,y pair for floating point scaling */
     int x_org, y_org;        /* viewport's origin */
     int x_dir, y_dir;        /* direction in which coordinates grow */
     SCALE scale;
     int (*get_pt)(int *);
     int vstatus;
     char *view_pic;
     int fpic_index;
     } VIEW;

#define MAX_VIEWS 16

typedef struct _fpic_cb {unsigned int signature, type;
                         int dos_handle, max_fpics;
                         long *pic_pos;
                        } FPIC_CB;

#define FPIC_HDR_SIZE              (sizeof(FPIC_CB) - sizeof(LONG *))
#define fpic_loc(fpic_cb, index)   (*((fpic_cb)->pic_pos + (index)))

typedef struct gc {int pt_x, pt_y;
                   int ilog_x, ilog_y;
                   double flog_x, flog_y;
                  } CRSR;

typedef struct {

     /* general parameters for setting rom bios */

          unsigned int gfx_mode;       /* graphics mode info */
          unsigned int card_monitor;   /* type of card and monitor */
          unsigned int bios_mode;      /* crt mode */
          unsigned int vpage_n;        /* active display page */
          unsigned int wpage_n;        /* active write page */
          unsigned int err_number;     /* function error number */
          unsigned int show_gfx_err;   /* display the error number */
          unsigned int use_ansi;       /* use ansi.sys */
          unsigned int ansi_is_loaded; /* is ansi.sys loaded? */
          unsigned int paint_stack_sz; /* size of stack for PAINT function */

     /* Info for writing text to the screen */

          unsigned int attr;         /* attribute byte for text mode */
          unsigned int screen_base;  /* base of screen ram for segment register */
          unsigned int width;        /* screen width - 80 or 40 */

     /* Graphics info */

          unsigned int view_nmbr;
          unsigned int palette;    /* palette of colors */
          int bytes_per_row;       /* 80 is standard*/
          int last_video_row;
          int xor_pel;

          unsigned int bkgnd;      /* background color */
          unsigned int fgnd;       /* forground color */
          unsigned int font_handle;/* font for writing */
          unsigned int auto_scale; /* use auto-scaling */
          unsigned int xlat_scale; /* the auto-scaling factor */

          int v_start_byte;        /* first byte */
          int v_nbytes_wide;       /* viewport's width -- in bytes */
          int n_pels_high;         /* viewport's height */
          int n_pels_wide;

          int min_x, min_y;        /* viewport's upper left corner */
          int max_x, max_y;        /* viewport's lower right corner */
          int pt_x, pt_y;          /* current x,y coordinate pair */
          int ilog_x, ilog_y;      /* logical x,y pair for integer scaling */
          double flog_x, flog_y;   /* logical x,y pair for floating point scaling */
          int x_org, y_org;        /* viewport's origin */
          int x_dir, y_dir;        /* direction in which coordinates grow */
          SCALE scale;
          int (*get_pt)(int *);
          int vstatus;
          char *view_pic;
          int fpic_index;

          struct _arc arc;

          int vpic_handle;
          FPIC_CB *vpic_cb;
          FPIC_CB *fpic_cb[MAX_FPIC_CB];

          }   GFX_STATUS;


extern GFX_STATUS _gfx;

typedef struct _box_coor {int x1, y1, x2, y2;} BOX_COOR;

typedef struct _pic {unsigned int xbytes;
                unsigned int yrows;
                unsigned int n_pels_per_row;
                unsigned char lopen_bits;
                unsigned char ropen_bits;} PIC;



#define GET_GFX_VAL		1
#define SET_GFX_VAL		2

#define GET_GFX_STATUS(a, b)	     set_get_gfx_status_val(GET_GFX_VAL, a, b)
#define get_gfx_status(a, b)	     set_get_gfx_status_val(GET_GFX_VAL, a, b)
#define SET_GFX_STATUS(a, b)	     set_get_gfx_status_val(SET_GFX_VAL, a, b)
#define set_gfx_status(a, b)	     set_get_gfx_status_val(SET_GFX_VAL, a, b)

#define GFX_GFX_MODE			1
#define GFX_CARD_MONITOR			2
#define GFX_BIOS_MODE			3
#define GFX_VPAGE_N			     4
#define GFX_WPAGE_N				5	        
#define GFX_ERR_NUMBER			6
#define GFX_SHOW_GFX_ERR			7
#define GFX_USE_ANSI			8
#define GFX_ANSI_IS_LOADED		9
#define GFX_PAINT_STACK_SZ		10
#define GFX_ATTR				11
#define GFX_SCREEN_BASE			12
#define GFX_WIDTH				13
#define GFX_VIEW_NMBR			14
#define GFX__PALLETE			15
#define GFX_BYTES_PER_ROW		16
#define GFX_LAST_VIDEO_ROW		17
#define GFX_XOR_PEL				18
#define GFX_BKGND				19
#define GFX_FGND				20
#define GFX_FONT_HANDLE			21
#define GFX_AUTO_SCALE			22
#define GFX_XLAT_SCALE			23
#define GFX_V_START_BYTE			24
#define GFX_V_NBYTES_WIDE		25
#define GFX_N_PELS_HIGH			26
#define GFX_N_PELS_WIDE			27
#define GFX_MIN_X				28
#define GFX_MIN_Y				29
#define GFX_MAX_X				30
#define GFX_MAX_Y				31
#define GFX_PT_X				32
#define GFX_PT_Y				33
#define GFX_ILOG_X				34
#define GFX_ILOG_Y				35

#define GFX_FLOG_X				36
#define GFX_FLOG_Y				37
#define GFX_X_ORG				38
#define GFX_Y_ORG				39
#define GFX_X_DIR				40
#define GFX_Y_DIR				41
#define GFX_SCALE_X_NUM 			42
#define GFX_SCALE_X_DENOM		43
#define GFX_SCALE_Y_NUM			44
#define GFX_SCALE_Y_DENOM		45				
#define GFX_SCALE_X_FLT			46
#define GFX_SCALE_Y_FLT			47
#define GFX_VSTATUS				48
#define GFX_VIEW_PIC			49
#define GFX_FPIC_INDEX			50
#define GFX_VPIC_HANDLE			51
#define GFX_VPIC_CB				52
#define GFX_FPIC_CB				53

