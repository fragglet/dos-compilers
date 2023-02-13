/**
*
* This is a program to demonstrate the Lattice Graphics Library.  It 
* should be compiled via the following command:
*
*	lc -Lgm -n -v -md draw
*
* 
*/
#include <gfx.h>
/**
*
* These are the prompter messages for the graphics demonstration.                   
*
*/                    
char *msg00[] = {"WELCOME TO",
			  "the graphics demonstration suite.",
			  "It displays many of the graphics",
			  "library's features.",
                 "",
			  "If you are already using another",
			  "graphics package, do some timing",
			  "tests to see how fast the routines",
			  "are, and take a few minutes to see",
			  "how easy the functions are to use.",
			 };

char *msg01[] = {"WARNING: YOU MUST HAVE A HARD DISK",
			  "WITH AT LEAST ONE MEGABYTE FREE",
			  "FOR TEMPORARY FILES TO BE STORED",
			  "IN THE ROOT DIRECTORY OF DRIVE C:",
			  "",
			  "IF YOU HAVE SUCH A CONFIGURATION",
			  "PRESS Y TO CONTINUE."
			  };

char *msg02[] = {"The graphics routines can scale",
			  "coordinates automatically to adjust",
			  "for different screen resolutions.",
                 "",
                 "ENTER THE DESIRED VIDEO MODE",
                 "",
                 "1. CGA MED RES    2. CGA HI RES ",
                 "3. EGA COLOR      4. EGA MONO   ",
                 "5. EGA 320x200    6. EGA 640x200",
                 "7. VGA COLOR      8. VGA MONO   ",
                 "          9. HERCULES           ",
                 "     X. EXIT THIS PROGRAM       "
                };
                 
char *msg03[] = {"SORRY",
			  "the input must be a digit 1-9",
			  " or the letter X.",
			  "",
			  "Try again."
			 };

char *msg04[] = {"WARNING:",
			  "",
			  "We are not checking your selection",
			  "against your hardware, so please be",
			  "sure that your selection fits your",
			  "video card and monitor hardware.",
			  "", 
			  "Enter Y to continue or any other key",
			  "to make a new graphics mode selection."
			 };

char *msg1[] = {"LINE_SWEEP()", 
			 "",
			 "This routine sweeps pattern lines",
			 "around the screen like a radar to",
			 "exercise the line() function."
			 };
			
char *msg2[] = {"TEST_XOR()",
			 "",
			 "Following LINE_SWEEP(), a series",
			 "of lines and boxes are xor'ed",
			 "onto the screen, using the line()",
			 "function, to show a technique",
			 "called 'rubber-banding'."
			};

char *msg3[] = {"SPIN()",
			 "",
			 "SPIN demonstrates some very simple",
			 "animation using the PIC functions.",
			 "",
			 "After creating and capturing views",
			 "of a spinning coin with GET_PIC,",
			 "PUT_PIC is repeatedly called to",
			 "give a sense of movement."
			}; 
	
char *msg4[] = {"We've used both graphics pages",	
	           "of EGA cards to give a smoother",	
                "animation.  However, some video",	
	           "cards will still show flashing",	
                "at the top of the spinning coin.",	
               };


char *msg5[] = {"PAINT_TEST()",
			 "",
                "The PAINT_TEST() function first",
                "constructs a small labyrinth and",
                "then uses the paint() function to",
                "to flood the area with a color."
	          };

char *msg6[] = {"ARC_TEST()",
			 "",
                "ARC_TEST() repeatedly calls the",
                "arc() function to draw many",
                "multi-colored ellipses to",
                "construct a striped ball."
                };

char *msg7[] = {"DRAW_TEST()",
			 "",
                "The DRAW_TEST() routine",
                "demonstrates the use of the",
                "draw() function to display",
                "angled lines and polygons."
               };

char *msg8[] = {"TRIANGLES()",
			 "",
			 "This routine draws a series",
			 "of concentric triangles and",
			 "then repeatedly calls the",
			 "fastfill() function to flood",
			 "each triangle with a color.",
			 "",
			 "At the end, it fills the last",
			 "triangle with a pattern."
			};


char *msg9[] = {"MOVE_BLOCK()",
			 "",
			 "This routine draws four blocks",
			 "on the screen, and then saves the",
			 "images with GET_PIC.  It then moves",
			 "the blocks about with repeated",
			 "calls to the PUT_PIC function.",
			 "",
			 "Note the automatic clipping as the",
			 "blocks move off and on the screen."
			};

char *msg10[] = {"SHOW_FPICS()",
		  	  "",
		  	  "A picture of the complete screen",
		  	  "of each test has been taken, using",
		  	  "GET_FPIC and set in a file.  These",
		  	  "pictures are called FPICS.",
		  	  "",
		  	  "This next routine opens the fpic",
		  	  "file and uses PUT_FPIC to show", 
		  	  "the FPICS of each test."
		  	  };

char *msg11[] = {"TEST_VIEWPORTS()",
		  	  "",
		  	  "This routine shows many of the",
		  	  "features of viewports.",
		  	  "",
		  	  "First, the LINE_SWEEP() routine",
		  	  "is used to set a background",
		  	  "screen for the viewports."
		  	  };

char *msg12[] = {"A viewport appears in the upper",
		  	  "left corner and a LINE_SWEEP() is",
		  	  "executed inside the viewport.",
		  	  "",
		  	  "Three times the viewport is moved",
		  	  "with move_view(), given a new",
		  	  "background color and LINE_SWEEP().",
		  	  "",
		  	  "Each new position shows a different",
		  	  "section of the sweep because a new",
		  	  "origin is set with scale_int_view()."
		  	  };

char *msg13[] = {"Finally a second viewport is opened",
			  "in the lower right corner and",
			  "LINE_SWEEPs are done in each",
			  "using the switch_view() function",
			  "to move between viewports.",
                 "",
                 "The hide_view() function is used",
                 "to make a viewport disappear as",
                 "a new LINE_SWEEP() executes",
                 "in the other viewport."
                 };


char *msg14[] = {"FONT_TEST()",
		  	  "",
		  	  "This last routine shows some",
		  	  "additional features of the font",
		  	  "handling routines.",
		  	  "",
		  	  "Initially, HELLO WORLD is written",
		  	  "inside a double line box, showing",
		  	  "the ability to use characters",
		  	  "above 127."
		  	 }; 
		  	  

char *msg15[] = {"From HELLO WORLD four new copies",
		  	  "of the phrase move in all four",
		  	  "directions showing the use of",
		  	  "xoring the text onto the screen.",
		  	  "",
		  	  "Finally, note the automatic",
		  	  "clipping as the phrases move",
		  	  "outside the viewport."
		  	 };
/**
*
* Function definitions
*
**/		  	  
void LINE_SWEEP(), TEST_XOR(), ARC_TEST(), TRIANGLES();
void DRAW_TEST(), MOVE_BLOCK(), PAINT_TEST(), SPIN();
void SHOW_FPICS(char * ), TEST_VIEWPORTS(), FONT_TEST();
void draw_triangle(), restore_scrn(), graphics_suite(), exit(), delay();
void set_graphics_mode();
int abend();
/**
*
* Compilation parameters
*
*/
#define NO 0
#define YES 1
/**
*
* Static data
*
*/
int get_key_input = NO, is_mono = NO;
int screen_mode[] = 
	{ 
	MED_RES_COLOR, 
	HI_RES_BW, 
	EGA_COLOR, 
	EGA_MONO,
	EGA_MED_RES, 
	EGA_HI_RES,
	VGA_COLOR, 
	VGA_MONO,
	HERC_GFX
	};
/**
*
* Main program
*
*/ 
main(argc,argv)
int argc;
char *argv[];
{
int c;

_gfx.auto_scale = YES;		/* Use auto scaling */
_gfx.xlat_scale = 1;    	/* Assume 320x200 screen */
_gfx.err_number = NO;		/* Don't display error messages */
if(!screen(3)) 
	{
	if (_gfx.card_monitor & 0xF00 == MDA_CARD) exit(1);
	_gfx.card_monitor &= ~EGA_CARD;
	screen(3);
	}
display_message(msg00, 10);
get_key_input = YES;
c = display_message(msg01, 7);
if ((c != 'Y') && (c != 'y')) restore_scrn();
set_graphics_mode();
onbreak(abend);
graphics_suite();
cls();
delay(5);
restore_scrn();
}
/**
*
* This routine is called when the user presses CTRL-C or CTRL-BREAK.  It
* restores the screen and aborts.
*
*/
abend()
{
cls();
delay(5);
restore_scrn();
return(1);
}
/**
*
* This routine sets the appropriate graphics mode.
*
*/
void set_graphics_mode()
{
int c, mode;

screen(3);
cls();
while (1) {
	get_key_input = YES;
	c = display_message(msg02, 12);
	if ((c == 'x') || (c == 'X')) restore_scrn();
     mode = c - '1';
     if ((mode < 0) || (mode > 8)) {
	     get_key_input = NO;
          display_message(msg03, 5);
     	continue;
     	}
     c = display_message(msg04, 9);
     if ((c == 'Y') || (c == 'y')) {
     	if (mode == 8)
     		_gfx.card_monitor = HERC_CARD | MONO_DISPLAY;
		screen(FORCE_BIOS_MODE | screen_mode[mode]);
		if ((_gfx.bios_mode == HI_RES_BW) || (_gfx.bios_mode == HERC_GFX) || 
	    	    (_gfx.bios_mode == EGA_MONO) || (_gfx.bios_mode == VGA_MONO)) {
	      	is_mono = YES;
	      	}
	     get_key_input = NO;
		cls();
		return;
		}
	}
}
/**
*
* This routine restores the screen to its original state.
*
*/
void restore_scrn()
{
SCREEN(0);
exit(1);
}
/**
*
* This routine steps through the graphics demonstration suite.  
*
**/
void graphics_suite()
{
int fpic_handle;

cls();
fpic_handle = create_fpic("C:\\PIC.DAT", 40);

display_message(msg1, 5);
display_message(msg2, 7);
LINE_SWEEP();

TEST_XOR();
get_fpic(0, 0, 319, 199, 0, fpic_handle);
delay(30);

if (sizeof(char *) == 4) 
	{
	display_message(msg3, 9);
	if(_gfx.bios_mode >= HERC_GFX) display_message(msg4, 5);
	SPIN();
	get_fpic(0, 0, 319, 199, 0, fpic_handle);
	delay(30);
	cls();
	}

display_message(msg5, 6);
PAINT_TEST();
get_fpic(0, 0, 319, 199, 0, fpic_handle);
delay(30);

display_message(msg6, 6);
ARC_TEST();
get_fpic(0, 0, 319, 199, 0, fpic_handle);
delay(30);

display_message(msg7, 6);
DRAW_TEST();
get_fpic(0, 0, 319, 199, 0, fpic_handle);
delay(30);

display_message(msg8, 10);
TRIANGLES();
get_fpic(0, 0, 319, 199, 0, fpic_handle);
delay(30);

display_message(msg9, 10);
MOVE_BLOCK();
get_fpic(0, 0, 319, 199, 0, fpic_handle);

close_fpic(fpic_handle);

display_message(msg10, 10);
SHOW_FPICS("C:\\PIC.DAT");

remove("C:\\PIC.DAT");

display_message(msg11, 8);
display_message(msg12, 11);
display_message(msg13, 10);
TEST_VIEWPORTS();

display_message(msg14, 10);
display_message(msg15, 8);
FONT_TEST();
}
/**
*
* The following routines are the various graphics demonstrations.
*
*/
static int pattern[] = {0xF0F0, 0xCCCC, 0xFFFF, 0xAAAA};

void LINE_SWEEP()
{
int j,x,y;

for (j = 0; j < 25; j++) {
	for (x = 6; x < 320; x += 14)
		line(159, 99, x, 2, j|PAT, 0, pattern[j & 0x3]);
	for (y = 2; y < 200; y += 14)
		line(159, 99, 314, y, j|PAT, 0, pattern[j & 0x3]);
	for (x = 314; x > 0; x -= 14)
		line(159, 99, x, 197, j|PAT, 0, pattern[j & 0x3]);
	for (y = 197; y > 0; y -= 14)
		line(159, 99, 6, y, j|PAT, 0, pattern[j & 0x3]);
	}
}

void TEST_XOR()
{
 int width, height;
int x, y, i, j;

x = 145;
y =  90;
width = 30;
height = 20;
for (i = 0; i < 40; i++) {
	line(x -= 3, y -= 2, STEP, width, height, 3 | XOR_PEL, EMPTY_BOX);
	delay(1);
	line(x, y, STEP, width, height, 3 | XOR_PEL, EMPTY_BOX);
	width += 6;
	height += 4;
	}
line(x -= 3, y -= 2, STEP, width, height, 3 | XOR_PEL, EMPTY_BOX);
width /= 2;
height /= 2;
x += width;
for (j = 0; j < 4; j++) {
	for (i = 0; i < 40; i++) {
		line(x, y, STEP, -width, height, 14 | XOR_PEL, DRAW_LINE);
		line(x-width, y+height, STEP, width, height, 14 | XOR_PEL, DRAW_LINE);
		line(x, y+(height<<1), STEP, width, -height, 14 | XOR_PEL, DRAW_LINE);
		line(x+width, y+height, STEP, -width, -height, 14 | XOR_PEL, DRAW_LINE);
		delay(1);
		line(x, y, STEP, -width, height, 14 | XOR_PEL, DRAW_LINE);
		line(x-width, y+height, STEP, width, height, 14 | XOR_PEL, DRAW_LINE);
		line(x, y+(height<<1), STEP, width, -height, 14 | XOR_PEL, DRAW_LINE);
		line(x+width, y+height, STEP, -width, -height, 14 | XOR_PEL, DRAW_LINE);
		width -= 3;
		}
	for (i = 0; i < 40; i++) {
		line(x, y, STEP, -width, height, 14 | XOR_PEL, DRAW_LINE);
		line(x-width, y+height, STEP, width, height, 14 | XOR_PEL, DRAW_LINE);
		line(x, y+(height<<1), STEP, width, -height, 14 | XOR_PEL, DRAW_LINE);
		line(x+width, y+height, STEP, -width, -height, 14 | XOR_PEL, DRAW_LINE);
		delay(1);
		line(x, y, STEP, -width, height, 14 | XOR_PEL, DRAW_LINE);
		line(x-width, y+height, STEP, width, height, 14 | XOR_PEL, DRAW_LINE);
		line(x, y+(height<<1), STEP, width, -height, 14 | XOR_PEL, DRAW_LINE);
		line(x+width, y+height, STEP, -width, -height, 14 | XOR_PEL, DRAW_LINE);
		width += 3;
		}
	}
line(x-width, y, STEP, width*2, height*2, 3 | XOR_PEL, EMPTY_BOX);
}


		/*   NOTE THAT THIS FUNCTION WILL ONLY EXECUTE IN
	 	 *         PROGRAMS USING LARGE DATA MODEL
           */

void SPIN()
{
int i, j, x, y, radius, index, color, step, angle, pg;
double aspect_ratio, conversion=0.0174527, cos();
PIC *pic1[20], *get_pic();

if (sizeof(char *) == 2) return;
color = is_mono ? 0 : 2;
index = 0;
step = 9;
angle = 0;
set_video_pages(0, 1);
for (j=0; j < 2; j++) {
	for (i = 0; i < 10; i++) {
		line(110,80,210,160,13, FILL_BOX);
		if (!is_mono) {
			line(120,115,200, 125,0, FILL_BOX);
			}
		x =	160, y = 120, radius = 30;
		aspect_ratio = 1.1 / (cos((double)(angle * conversion)));
		ellipse(x, y, radius, color, aspect_ratio);
		fastfill(x, y+10, color, color);
		pic1[index] = get_pic(128,88,190,150);
		if (pic1[index] == 0) goto THE_END;
		angle += step;
		index++;
		}
	if (!is_mono) color = 9;
	step = -9;
	}
set_video_pages(0, 0);
line(110,80,210,160,13, FILL_BOX);
if (!is_mono) line(120,115,200, 125,0, FILL_BOX);
copy_video_pages(0,1);
pg = 0;
for (j = 0; j < 4; j++) {
	for (i = 0; i < 20; i++) {
	     set_video_pages(pg&1, (pg+1)&1);
		pg++;
		put_pic(128,88,pic1[i],'P');
		delay(1);
		}
	for (i = 19; --i > 0; ) {
	     set_video_pages(pg&1, (pg+1)&1);
		pg++;
		put_pic(128,88,pic1[i],'P');
		delay(1);
		}
	}

THE_END:
for (j = 0; j < 20; j++)
	if (pic1[j] != 0) free((char *)pic1[j]);
set_video_pages(0, 0);
}


int x[] = {180, 32, 129};
int y[] = {130, 32, 146};

void PAINT_TEST()
{
 int j;

for (j = 0; j < 3; j++) {
	cls();
	line(28, 28,262, 177, 1, FILL_BOX);
	line(30, 30, 260, 175, 2, FILL_BOX);
	line(40, 160, 240, 165, 1, FILL_BOX);
	line(40, 60, 240, 65, 1, FILL_BOX);
	line(40, 60, 45, 160, 1, FILL_BOX);
	line(235, 64, 240, 157, 1, FILL_BOX);
	line(47, 67, 55, 157, 1, FILL_BOX);
	line(58, 100, 238, 110, 1, FILL_BOX);
	line(230, 110, 235, 145, 1, FILL_BOX);
	line(130, 110, 150, 145, 1, FILL_BOX);
	line(100, 147, 235, 150, 1, FILL_BOX);
	delay(15);
	paint(x[j], y[j], 12, 1);
	delay(15);
	}
}


void ARC_TEST()
{
int i;
double start, end, delta_angle, frac;

for (frac = 0.1; frac < 4.0; frac += 0.1) {
	start = 0.0;
	delta_angle = .0872638;
	end = 6.283;
	ellipse(159,99,50,3, frac);
	for (i = 0; i < 71; i++) {
		arc(159,99,50,i&0xF, frac,start, end -= delta_angle);
		}
	}
for (i = 200; i > 0; i -= 5) {
	line(60,15,60+i,15,(i+1)&0xF,0);
	}
for (i = 170; i > 0; i -= 3) {
	line(260,15,260,15+i,(i+1)&0xF,0);
	}
for (i = 200; i > 0; i -= 5) {
	line(60,185,60+i,185,(i+1)&0xF,0);
	}
for (i = 170; i > 0; i -= 3) {
	line(60,15,60,15+i,(i+1)&0xF,0);
	}
}


void DRAW_TEST()
{
int i, kolor;
extern void COLOR();

draw("BM160,70");
draw("S4");
for (i = 0; i++ < 2; draw("S8 BM100,190")) {
	draw("C1 U= R= D= L=",60,60,60,60);
	draw("BU30 C1 E= F= G= H=",30,30,30,30);
	draw("BR30 C1 NU10 NL10 ND10 NR10 NH10 NG10 NE10 NF10");
	delay(30);
	}
draw("BM160,100 S4");
kolor = 1;
;
for (i = 1; i < 14; i++) {
	draw("S= BM-30,+0 C= U= R= D= L= U= BM+30,+0", i, kolor, 30, 60, 60, 60, 31);
	}
}

void draw_triangle(x, y, base, height, color)
	int x, y, base, height, color;
{
int y2, new_color;

base >>= 1;
y2 = height;
new_color = gfx_get_color(color);
line(x, y, x-base, y2, new_color, 0);
line(x, y, x+base, y2, new_color, 0);
line(x-base, y2, x+base, y2, new_color, 0);
}




char dot_pat[] = {9, 9, 0xC4, 0x62, 0x31, 0x18, 0x8C, 0x46, 0x23, 0x11, 0x88,
				    0x88, 0xC4, 0x62, 0x31, 0x18, 0x8C, 0x46, 0x23, 0x11,
				    0x11, 0x88, 0xC4, 0x62, 0x31, 0x18, 0x8C, 0x46, 0x23,
				    0x23, 0x11, 0x88, 0xC4, 0x62, 0x31, 0x18, 0x8C, 0x46,
				    0x46, 0x23, 0x11, 0x88, 0xC4, 0x62, 0x31, 0x18, 0x8C,
				    0x8C, 0x46, 0x23, 0x11, 0x88, 0xC4, 0x62, 0x31, 0x18,
				    0x18, 0x8C, 0x46, 0x23, 0x11, 0x88, 0xC4, 0x62, 0x31,
				    0x31, 0x18, 0x8C, 0x46, 0x23, 0x11, 0x88, 0xC4, 0x62,
				    0x62, 0x31, 0x18, 0x8C, 0x46, 0x23, 0x11, 0x88, 0xC4
				    };

char xdot_pat[] = {1, 1, 0x88};

void TRIANGLES()
{
int x, y, height, base, color, fill_color, n_reps, i, max_color, last_color;

max_color = 16;
for (i = 0; i < 1; i++) {
	x = 160;
	y = 4;
	height = 190;
	base = 310;
	color = i;
	n_reps = 0;
	while (y < 80) {
		if (++color == max_color) color = 1;
		draw_triangle(x, y, base, height, color);
		height -= 5;
		base -= 20;
		y += 5;
		n_reps++;
		}
	}
y += 20;
last_color = color;
while (n_reps--) {
	if ((fill_color = color+1) >= max_color) fill_color = 1;
	fastfill(x, y, fill_color, color--);
	if (color < 1) color = max_color-1;
	}
delay(40);
fastfill(x, y, PAT|5, last_color, xdot_pat);
fastfill(x, y, PAT|4, last_color, dot_pat);
delay(40);
}



void MOVE_BLOCK()
{
PIC *pic1, *pic2, *pic3, *pic4, *get_pic();
int p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y, ch;
int max_x, max_y;

line(100, 60, 158, 98, 8, 2);
line(100, 102, 158, 140, 6, 2);
line(162, 60, 220, 98, 6, 2);
line(162, 102, 220, 140, 1, 2);
fastfill(101, 61, 9, 8);
fastfill(101, 103, 4, 6);
fastfill(163, 61, 7, 6);
fastfill(163, 103, 12, 1);
pic1 = get_pic(99, 59, 159, 99);	 p1x = 99;  p1y = 59;
pic2 = get_pic(160, 59, 221, 100);	 p2x = 160; p2y = 59;
pic3 = get_pic(99, 101, 159, 141);  p3x = 99;  p3y = 101;
pic4 = get_pic(160, 101, 221, 141); p4x = 160; p4y = 101;
max_x = 320;
max_y = 200;
for (ch= 0; ch < 600; ch++) {
	if (p1x < -60) p1x = max_x+1;
	put_pic(p1x, p1y, pic1, 'P');
	p1x--;
	if (p4x > max_x) p4x = -60;
	put_pic(p4x, p4y, pic4, 'P');
	p4x++;
	if (p2y < -40) p2y = max_y+1;
	put_pic(p2x, p2y, pic2, 'P');
	p2y--;
	if (p3y > max_y) p3y = -40;
	put_pic(p3x, p3y, pic3, 'P');
	p3y++;
	}

free((char *)pic1);
free((char *)pic2);
free((char *)pic3);
free((char *)pic4);
}

void SHOW_FPICS(fpic_name)
	char *fpic_name;
{
 int i, fpic_handle;

fpic_handle = open_fpic(fpic_name, 1);
cls();
_gfx.auto_scale = NO;
for (i = 1; i < 8; i++) {
	put_fpic(0, 0, 'P', i, fpic_handle);
	delay(40);
	}
_gfx.auto_scale = YES;
close_fpic(fpic_handle);
}



void TEST_VIEWPORTS()
{
int view_1, view_2;

cls();
LINE_SWEEP();

view_1 = open_view(10, 10, 110, 55, 2, YES);
LINE_SWEEP();
delay(15);

move_view(190, 20);
delay(15);
clear_view(view_1, 4);
delay(5);
scale_int_view(DFLT, DFLT, 0, -45, 1, -1);
LINE_SWEEP();
delay(15);

move_view(190, 130);
delay(15);
clear_view(view_1, 11);
delay(5);
scale_int_view(DFLT, DFLT, -110, -72, 1, 1);
LINE_SWEEP();
delay(15);

move_view(20, 130);
delay(15);
clear_view(view_1, 9);
delay(5);
scale_int_view(DFLT, DFLT, 0, 0, 1, 1);
LINE_SWEEP();
delay(30);

move_view(10,10);
cls();
view_2 = open_view(130, 90, 300, 180, 4, YES);
delay(30);
LINE_SWEEP();
clear_view(view_2, 8);
switch_view(view_1, 1);
LINE_SWEEP();
clear_view(view_1, 6);
delay(30);
switch_view(view_2, 1);
clear_view(view_2, 9);
LINE_SWEEP();
switch_view(view_1, 0);
LINE_SWEEP();
delay(30);
close_view(view_2, 1);
close_view(view_1, 1);
delay(30);
}

char oem_tp[] = {'X', 200, 201, 202, 203, 204, 'X', 0};
char Tbuf[260];
         
void FONT_TEST()
{
 int x, y, dy, view_1, i, box_color;

set_font(0,0,0,ROM_8x14);
view_1 = open_view(10, 10, 300, 180, 11, NO);
x = 96, y = 87;
dy = 7;
if (_gfx.max_y <= 200) {
	dy = 8;
	}
if (_gfx.max_x <= 320) x += 9;
puts_font(x, y, is_mono ? 0 : 6, "HELLO WORLD");
box_color = is_mono ? 0 : 1;
puts_font(88, 70, box_color, "ษอออออออออออออป");
for (i = 1; i < 5; i++)
	puts_font(88, 70 + (i * dy), box_color, "บ             บ");
puts_font(88, 70+(5*dy), box_color, "ศอออออออออออออผ");
delay(30);
for (i = 1; i < 140; i++) {
	puts_font(x-i, y, 6 | XOR_PEL, "HELLO WORLD");
	puts_font(x, y+i, 2 | XOR_PEL, "HELLO WORLD");
	puts_font(x+i, y, 3 | XOR_PEL, "HELLO WORLD");
	puts_font(x, y-i, 15 | XOR_PEL, "HELLO WORLD");
	delay(2);
	puts_font(x-i, y, 6 | XOR_PEL, "HELLO WORLD");
	puts_font(x, y+i, 2 | XOR_PEL, "HELLO WORLD");
	puts_font(x+i, y, 3 | XOR_PEL, "HELLO WORLD");
	puts_font(x, y-i, 15 | XOR_PEL, "HELLO WORLD");
	}
close_view(view_1);
}


display_message(tp, n_lines)
	char **tp;
	int n_lines;
{
int max_strlen, n, i, auto_scale, line_height;
int x1, y1, y_height, x_width, x, fh, c;

cls();
max_strlen = 0;
for (i = 0; i < n_lines; i++) {
	if ((n = strlen(tp[i])) > max_strlen)
		max_strlen = n;
	}
x_width = (max_strlen + 6) * 8;
line_height = 20;
set_font(0,0,0,ROM_8x14);
if (_gfx.max_y <= 200) {
     x_width = (max_strlen + 4) * 8;
	line_height = 11;
	set_font(0,0,0,ROM_8x8);
	}
x1 = (((_gfx.max_x - x_width) / 2) + 7) & 0x7F8;
y1 = (_gfx.max_y - (((n_lines+2) * line_height)) - 10) / 2;
auto_scale = _gfx.auto_scale;
_gfx.auto_scale = 0;
y_height = ((n_lines + 2) * line_height) + 10;
fh = open_view(x1, y1, x1 + x_width - 1, y1 + y_height, 11, 0);
line(x_width-3, 0, STEP, 2, y_height, 4, FILL_BOX);
line(0, y_height-2, STEP, x_width, 3, 4, FILL_BOX);
line(0, 0, STEP, x_width, 2, 4, FILL_BOX);
line(0, 0, STEP, 2, y_height, 4, FILL_BOX);
y1 = 9;
for (i = 0; i < n_lines; i++) {
	x = (x_width - (strlen(tp[i]) * 8)) / 2;
	puts_font(x, y1, 0, tp[i]);
	y1 += line_height;
	}
if (get_key_input)
	puts_font((x_width-192) / 2, y1+line_height-1, 0, "Please make your entry:");
else 
	puts_font((x_width-200) / 2, y1+line_height-1, 0, "Press any key to continue");
c = getch();
close_view(fh, 1);
_gfx.auto_scale = auto_scale;
return c;
}


typedef struct { unsigned int  ax, bx, cx, dx, si, di, cflag; } REG_X;

unsigned int bios_time()
{
REG_X reg;

reg.ax = 0;
call_bios(0x1A, (char *)&reg, (char *)&reg);
return reg.dx;
}

void delay(n_ticks)
	int n_ticks;
{
unsigned int ct;

while (kbhit()) {
	if ((_gfx_call_dos(7, 0) & 0xFF) == '*') restore_scrn();
	}
ct = bios_time() + n_ticks;
while (ct > bios_time());
}
