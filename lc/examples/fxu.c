/**
*
*	Modified for C-SPRITE demonstration
*
* name         fxu -- function extract utility
*
* usage        fxu filename function
*
*              where "filename" is the name of a file containing
*              several C functions, and "function" is the name of
*              the particular function to be extracted.  If the
*              named function is found, the text of the named function
*              is written to the standard output.
*
**/

#include "stdio.h"
#include "ctype.h"

#define MAX 16            /* maximum characters in function name */
#define MAXBUF 2000       /* maximum characters buffered between functions */

unsigned _stack = MAXBUF + 2000;	   /* reserve sufficient stack */

main(argc, argv)
int argc;
char *argv[];
{
int c, brace, cnest, nc;
int i, ns, copy, inlit, delim, pc;
FILE *sfp;
char symbol[MAX+1];
char text[MAXBUF];

if (argc != 3)
   {
   fputs("Usage: fxu filename function\n", stderr);
   exit(1);
   }
if ((sfp = fopen(argv[1], "r")) == NULL)
   {
   fputs("Can't open source file\n", stderr);
   exit(1);
   }
brace = cnest = nc = ns = copy = inlit = pc = 0;
c = getc(sfp);                             /* get first char */
while (c != EOF)
   {                                       /* scan through source file */
   if (ns == MAXBUF)
       {
       fputs("Maximum buffer size exceeded\n", stderr);
       exit(1);
       }
   if (copy == 0)
       {
       if (brace == 0) text[ns++] = c; /* save chars between functions */
       }
   else
       if (putch(c) == EOF)
           {
           fputs("Copy error\n", stderr);
           exit(1);
           }
   if (c == '/')
       {                                   /* possible comment */
       nc = 0;
       if ((c = getc(sfp)) == '*')
           {
           ++cnest;                        /* bump nesting level */
           if (copy) putch(c);
           else if (brace == 0) text[ns++] = c;
           c = getc(sfp);
           }
       continue;
       }
   if (cnest != 0)
       {                                   /* inside comment */
       if (c == '*')
           {
           if ((c = getc(sfp)) == '/')
              {
              --cnest;                     /* reduce nesting level */
              if (copy) putch(c);
              else if (brace == 0) text[ns++] = c;
              c = getc(sfp);
              }
           continue;
           }
       nc = 0;
       }
   else if (inlit)
       {                                   /* inside literal string */
       if (c == '\\' && pc == '\\') c = 0;
       if (c == delim && pc != '\\') inlit = 0;
       pc = c;                             /* save previous character */
       }
   else if (c == '\'' || c == '\"')
       {                                   /* enter literal string */
       inlit = 1;
       pc = 0;
       delim = c;
       }
   else if (c == '{') ++brace;
   else if (c == '}')
       {                                   /* right brace */
       nc = 0;
       if (--brace == 0)
           if (copy == 0) ns = 0;     /* reset save index if not found */
           else
               {                           /* copy complete */
               putch('\n');
               exit(0);
               }
       }
   else if (brace == 0)
       {
       if (nc == 0)
           {                               /* symbol not started yet */
           if (iscsymf(c))
               symbol[nc++] = c;           /* start new symbol */
           }
       else if (iscsym(c) || c == '$')
                                           /* continue symbol */
           if (nc < MAX) symbol[nc++] = c;
           else symbol[0] = '\0';
       else if (nc != 0)
           {                               /* end of current symbol */
           symbol[nc++] = '\0';
           if (symcmp(symbol,argv[2]) == 0)
               {                      /* named function has been found */
               for (i = 0; i < ns; i++)
                   putch(text[i]);         /* copy saved characters */
               copy = 1;                   /* turn on copy flag */
               }
           nc = 0;
           }
       }
   c = getc(sfp);                          /* get next char */
   }

fputs("Named function not found\n", stderr);
exit(1);
}
/**
*
* name         symcmp -- compare symbols
*
* synopsis     retval = symcmp(p, q);
*              int retval;            return code: 0 if equal, 1 if not
*              char *p, *q;           symbols to be compared
*
* description  This function compares two alphanumeric symbols for
*              identity.  Upper and lower case alphabetic characters
*              are considered equivalent by this function.
*
**/
symcmp(p,q)
char *p, *q;
{
int a, b;

while ((toupper(*p)) == (toupper(*q)))
{
if (*p == '\0') return(0);
p++;
q++;
}
return(1);
}
                                                                                                                                                                   