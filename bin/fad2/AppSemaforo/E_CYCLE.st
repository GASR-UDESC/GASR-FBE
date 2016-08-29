




CUSTOM FUNCTION_BLOCK E_CYCLE
	EVENT_INPUT
		START;
		STOP;
	END_EVENT
	
	EVENT_OUTPUT
		EO;
	END_EVENT
	
	VAR_INPUT
		DT:BYTE;
	END_VAR
	
	VAR
		oldt: BYTE;
		count:BYTE;
		state: BYTE;
	END_VAR
	
	ALGORITHM ALG_INIT:
		oldt := GET_REG(100);
		count := 0;
		state := 0;
		EO:=0;
	END_ALGORITHM
	ALGORITHM ALG_RUN:
		IF(START) THEN
			state :=1;
			START := 0;
			count := 0;
			oldt := GET_REG(100);
		END_IF;
		IF(STOP)THEN
			state := 0;
			EO := 0;
		END_IF;	
		(*
		IF(EO) THEN
			EO := 0;
		END_IF;
		*)
		IF(state = 1) THEN
			IF(NOT (oldt = GET_REG(100))) THEN
				count := count + 1;
				IF(count = DT) THEN
					EO := 1;
					count := 0;					
				END_IF;
				oldt := GET_REG(100);
			END_IF;
		END_IF;
	END_ALGORITHM	
	
END_FUNCTION_BLOCK