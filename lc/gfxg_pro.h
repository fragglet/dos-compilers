int  ARC( );
int  CIRCLE( );
int  CLOSE_FPIC(int );
int  CLEAR_VIEW(int, int);
int  CLOSE_VIEW(int,int);
int  CLOSE_VIEW_FILE(void);
void CLS(void);
void COLOR(int, int, int, ... );
int  COMPRESS_FPIC_FILE(char *, char *);
int  COPY_VIDEO_PAGES(int, int);
int  CREATE_FPIC(char *, int);
int  CREATE_VIEW_FILE(char *);
int  DELETE_FPIC(int, int);
int  DRAW(char *, ... );
int  ELLIPSE( );
int  FASTFILL( );
int  GET_FPIC( );
struct _pic *GET_PIC( );
void INIT_GFX_STRUCT(int);
int  LINE( );
int  LOCATE(int, int);
int  MOVE_VIEW( );
int  OPEN_FPIC(char *, int);
int  OPEN_VIEW( );
int  PAINT( );
int  POINT( );
int  PSET( );
int  PUT_FONT(unsigned char *,int);
int  PUT_FPIC( );
int  PUT_PIC( );
void PUTC_FONT( );
void PUTS_FONT( );
struct _pic *READ_FPIC(int ,int );
void SCALE_FLOAT_VIEW(double ,double, double, double, int, int);
void SCALE_INT_VIEW(int, int, int, int, int, int);
int  SCREEN(int );
int  SET_EXTENDED_EGA_MODE(int, int, int, int);
int  SET_FONT( );
int  SET_VIDEO_PAGES(int, int);
void SET_VIDEO_RESOLUTION(int, int);
int  SWITCH_VIEW(int, int);
int  WRITE_FPIC(struct _pic *, int, int);

