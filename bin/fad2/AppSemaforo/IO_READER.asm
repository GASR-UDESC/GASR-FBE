;File Asm: IO_READER.asm
	    0: GOTO         0,   7 (    7 =    7h)
	    1: GOTO         0,  77 (   77 =   4Dh)
	    2: RET          0,   0 (    0 =    0h)
	    3: LOAD         1,   8 (  264 =  108h)
	    4: ARLOAD       0,   0 (    0 =    0h)
	    5: STORE        1,  11 (  267 =  10Bh)
	    6: RET          0,   0 (    0 =    0h)
	    7: LOAD         0,   1 (    1 =    1h)
	    8: CONST        0,   0 (    0 =    0h)
	    9: IFEQ         0,  11 (   11 =    Bh)
	   10: GOTO         0,  36 (   36 =   24h)
	   11: LOAD         0,   0 (    0 =    0h)
	   12: IF           0,  14 (   14 =    Eh)
	   13: GOTO         0,  16 (   16 =   10h)
	   14: CONST        0,   0 (    0 =    0h)
	   15: STORE        0,   0 (    0 =    0h)
	   16: LOAD         1,   2 (  258 =  102h)
	   17: CONST        0,   0 (    0 =    0h)
	   18: STORE        0,   2 (    2 =    2h)
	   19: IF           0,  21 (   21 =   15h)
	   20: GOTO         0,  26 (   26 =   1Ah)
	   21: CONST        0,   2 (    2 =    2h)
	   22: STORE        0,   1 (    1 =    1h)
	   23: CONST        0,   1 (    1 =    1h)
	   24: STORE        0,   0 (    0 =    0h)
	   25: GOTO         0,  36 (   36 =   24h)
	   26: LOAD         1,   3 (  259 =  103h)
	   27: CONST        0,   0 (    0 =    0h)
	   28: STORE        0,   3 (    3 =    3h)
	   29: IF           0,  31 (   31 =   1Fh)
	   30: GOTO         0,  36 (   36 =   24h)
	   31: CONST        0,   1 (    1 =    1h)
	   32: STORE        0,   1 (    1 =    1h)
	   33: CONST        0,   1 (    1 =    1h)
	   34: STORE        0,   0 (    0 =    0h)
	   35: GOTO         0,  36 (   36 =   24h)
	   36: LOAD         0,   1 (    1 =    1h)
	   37: CONST        0,   1 (    1 =    1h)
	   38: IFEQ         0,  40 (   40 =   28h)
	   39: GOTO         0,  56 (   56 =   38h)
	   40: LOAD         0,   0 (    0 =    0h)
	   41: IF           0,  43 (   43 =   2Bh)
	   42: GOTO         0,  48 (   48 =   30h)
	   43: CONST        0,   0 (    0 =    0h)
	   44: STORE        0,   0 (    0 =    0h)
	   45: CALL         0,   3 (    3 =    3h)
	   46: CONST        0,   1 (    1 =    1h)
	   47: STORE        0,   5 (    5 =    5h)
	   48: CONST        0,   1 (    1 =    1h)
	   49: IF           0,  51 (   51 =   33h)
	   50: GOTO         0,  56 (   56 =   38h)
	   51: CONST        0,   0 (    0 =    0h)
	   52: STORE        0,   1 (    1 =    1h)
	   53: CONST        0,   1 (    1 =    1h)
	   54: STORE        0,   0 (    0 =    0h)
	   55: GOTO         0,  56 (   56 =   38h)
	   56: LOAD         0,   1 (    1 =    1h)
	   57: CONST        0,   2 (    2 =    2h)
	   58: IFEQ         0,  60 (   60 =   3Ch)
	   59: GOTO         0,  76 (   76 =   4Ch)
	   60: LOAD         0,   0 (    0 =    0h)
	   61: IF           0,  63 (   63 =   3Fh)
	   62: GOTO         0,  68 (   68 =   44h)
	   63: CONST        0,   0 (    0 =    0h)
	   64: STORE        0,   0 (    0 =    0h)
	   65: CALL         0,   2 (    2 =    2h)
	   66: CONST        0,   1 (    1 =    1h)
	   67: STORE        0,   4 (    4 =    4h)
	   68: CONST        0,   1 (    1 =    1h)
	   69: IF           0,  71 (   71 =   47h)
	   70: GOTO         0,  76 (   76 =   4Ch)
	   71: CONST        0,   0 (    0 =    0h)
	   72: STORE        0,   1 (    1 =    1h)
	   73: CONST        0,   1 (    1 =    1h)
	   74: STORE        0,   0 (    0 =    0h)
	   75: GOTO         0,  76 (   76 =   4Ch)
	   76: RET          0,   0 (    0 =    0h)
	   77: ALLOC        0,  12 (   12 =    Ch)
	   78: CONST        0,   0 (    0 =    0h)
	   79: STORE        0,   1 (    1 =    1h)
	   80: CONST        0,   1 (    1 =    1h)
	   81: STORE        0,   0 (    0 =    0h)
	   82: RET          0,   0 (    0 =    0h)