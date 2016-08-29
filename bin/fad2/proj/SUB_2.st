(* Generated by xml2st *)
FUNCTION_BLOCK SUB_2
  EVENT_INPUT
    INIT;
  END_EVENT
  EVENT_OUTPUT
    INIT0;
    RSP;
  END_EVENT

  EC_STATES
    START;
    RCV: ALG_RCV -> RSP;
    INIT: ALG_INIT -> INIT0;
  END_STATES

  EC_TRANSITIONS
    START TO INIT := INIT;
    INIT TO START := 1;
    START TO RCV := 1;
    RCV TO START := 1;
  END_TRANSITIONS

  VAR_INPUT
    ID: BOOL;
  END_VAR

  VAR_OUTPUT
    SD_1: INT;
    SD_2: BOOL;
  END_VAR

  ALGORITHM ALG_RCV IN ST:
ASM       CONST 2  LOAD ID  NIRCV   IF GOTO process     GOTO out  process:    STORE SD_1    STORE SD_2  out:   END_ASM  
  END_ALGORITHM

  ALGORITHM ALG_INIT IN ST:

  END_ALGORITHM

END_FUNCTION_BLOCK