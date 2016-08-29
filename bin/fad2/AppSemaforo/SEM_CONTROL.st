(* Generated by xml2st *)
FUNCTION_BLOCK SEM_CONTROL
  EVENT_INPUT
    INIT;
    ETIME;
    BTWALKER;
  END_EVENT
  EVENT_OUTPUT
    INIT0;
    SET_SEMAPHORE;
  END_EVENT

  EC_STATES
    START;
    RUN: ALG_RUN -> SET_SEMAPHORE;
    ST_WALKER: ALG_WALKER ->;
    INIT: ALG_INIT -> INIT0;
  END_STATES

  EC_TRANSITIONS
    START TO INIT := INIT;
    START TO RUN := ETIME;
    INIT TO START := 1;
    RUN TO START := 1;
    START TO ST_WALKER := BTWALKER;
    ST_WALKER TO START := 1;
  END_TRANSITIONS

  VAR_INPUT
    lbtwalker: BOOL;
    btwalker: BOOL;
  END_VAR

  VAR_OUTPUT
    SEMAPHORE_1: BYTE;
    SEMAPHORE_2: BYTE;
    SEMAPHORE_3: BYTE;
    SEMAPHORE_4: BYTE;
    WALKER: BOOL;
  END_VAR

  ALGORITHM ALG_INIT IN ST:
SEMAPHORE_1 := 0; SEMAPHORE_2 := 0; SEMAPHORE_3 := 0; SEMAPHORE_4 := 0; WALKER :=0;
  END_ALGORITHM

  ALGORITHM ALG_WALKER IN ST:
IF(btwalker) THEN lbtwalker:=1; END_IF;
  END_ALGORITHM

  ALGORITHM ALG_RUN IN ST:
IF(WALKER) THEN  WALKER := 0;  SEMAPHORE_1 := 1;     SEMAPHORE_2 := 0;   lbtwalker := 0; ELSE  IF(SEMAPHORE_2 = 0) THEN     SEMAPHORE_1 := SEMAPHORE_1 + 1;     IF(SEMAPHORE_1 >= 3) THEN       SEMAPHORE_1 := 0;       SEMAPHORE_2 := 1;     END_IF;   ELSE     SEMAPHORE_2 := SEMAPHORE_2 + 1;     IF(SEMAPHORE_2 >= 3) THEN      IF(lbtwalker) THEN         WALKER := 1;     SEMAPHORE_1 := 0;        SEMAPHORE_2 := 0;     ELSE     SEMAPHORE_1 := 1;        SEMAPHORE_2 := 0;     END_IF;   END_IF;    END_IF;  END_IF;
  END_ALGORITHM

END_FUNCTION_BLOCK