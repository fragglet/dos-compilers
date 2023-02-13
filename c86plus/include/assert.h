/* assert.h - define the assert macro 
   Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef _asserth
#define _asserth

#ifndef NDEBUG
#define assert(_exp_) { if(!(_exp_)) _assert(#_exp_, __FILE__, __LINE__); }
#else
#define assert(_exp_)
#endif 
#endif /* _asserth */

