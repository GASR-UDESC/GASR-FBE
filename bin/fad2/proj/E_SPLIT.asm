;File Asm: E_SPLIT.asm
	    0: GOTO           2
	    1: GOTO          41
	    2: LOAD           1
	    3: CONST          0
	    4: IFEQ           6
	    5: GOTO          22
	    6: LOAD           0
	    7: IF             9
	    8: GOTO          15
	    9: CONST          0
	   10: STORE          0
	   11: CONST          1
	   12: STORE          3
	   13: CONST          1
	   14: STORE          4
	   15: CONST          1
	   16: IF            18
	   17: GOTO          22
	   18: CONST          1
	   19: STORE          1
	   20: CONST          1
	   21: STORE          0
	   22: LOAD           1
	   23: CONST          1
	   24: IFEQ          26
	   25: GOTO          40
	   26: LOAD           0
	   27: IF            29
	   28: GOTO          31
	   29: CONST          0
	   30: STORE          0
	   31: LOAD           2
	   32: CONST          0
	   33: STORE          2
	   34: IF            36
	   35: GOTO          40
	   36: CONST          0
	   37: STORE          1
	   38: CONST          1
	   39: STORE          0
	   40: RET            0
	   41: ALLOC          5
	   42: CONST          1
	   43: STORE          1
	   44: CONST          1
	   45: STORE          0
	   46: RET            0
