


CUSTOM FUNCTION_BLOCK E_DELAY
	EVENT_INPUT
		START;
		STOP;
	END_EVENT
	
	EVENT_OUTPUT
		EO;
	END_EVENT
	
	VAR_INPUT
		DT:INT;
	END_VAR
	
	VAR
		oldt: INT;
		count:INT;
		state: INT;
	END_VAR
	
	ALGORITHM ALG_INIT:
		oldt := GET_REG(100);
		count := 0;
		state := 0;
	END_ALGORITHM
	ALGORITHM ALG_RUN:
		IF(START) THEN
			state :=1;
			START := 0;
			count := GET_REG(100);
		END_IF;
	
		IF(state = 1) THEN
			IF(NOT (oldt = GET_REG(100))) THEN
				count := count + 1;
				IF(count = DT) THEN
					EO := 1;
					state := 0;
				END_IF;
				oldt := GET_REG(100);
				
			END_IF;
		END_IF;
	END_ALGORITHM	
	
END_FUNCTION_BLOCK