/**
*
* Redefine secondary simulation function names to become primary names
* for systems without a Numeric Data Processor.  These symbols are
* used when re-compiling the Lattice library source for systems other
* than the iAPX86.
*
*/
#define _acos acos
#define _asin asin
#define _atan atan
#define _cos cos
#define _cosh cosh
#define _cot cot
#define _exp exp
#define _fabs fabs
#define _ldexp ldexp
#define _log log
#define _log10 log10
#define _modf modf
#define _pow pow
#define _pow2 pow2
#define _sin sin
#define _sinh sinh
#define _sqrt sqrt
#define _tan tan
#define _tanh tanh
