
IF(WALKER) THEN
	WALKER := 0;
	SEMAPHORE_1 := 1;   
	SEMAPHORE_2 := 0; 
	lbtwalker := 0;
ELSE
	IF(SEMAPHORE_2 = 0) THEN  
		SEMAPHORE_1 := SEMAPHORE_1 + 1;  
		IF(SEMAPHORE_1 >= 3) THEN   
			SEMAPHORE_1 := 0;   
			SEMAPHORE_2 := 1;  
		END_IF; 
	ELSE  
		SEMAPHORE_2 := SEMAPHORE_2 + 1;  
		IF(SEMAPHORE_2 >= 3) THEN  
			IF(lbtwalker) THEN				
				WALKER := 1;
				SEMAPHORE_1 := 0;   
				SEMAPHORE_2 := 0; 
			ELSE
				SEMAPHORE_1 := 1;   
				SEMAPHORE_2 := 0; 
			END_IF;
		END_IF;  
	END_IF; 
END_IF;

(*
IF(SEMAPHORE_2 = 0) THEN  SEMAPHORE_1 := SEMAPHORE_1 + 1;  IF(SEMAPHORE_1 >= 3) THEN   SEMAPHORE_1 := 0;   SEMAPHORE_2 := 1;  END_IF; ELSE  SEMAPHORE_2 := SEMAPHORE_2 + 1;  IF(SEMAPHORE_2 >= 3) THEN   SEMAPHORE_1 := 1;   SEMAPHORE_2 := 0;  END_IF;  END_IF; R:=2.3 + 4.5; R:=(R+1.2)*3.0; R := R/2.0;
*)
