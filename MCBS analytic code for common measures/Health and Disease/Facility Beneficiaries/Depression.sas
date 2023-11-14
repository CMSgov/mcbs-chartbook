/******************************************************************************************************/																		
/*** CODE: Create Depression measure using LDS segments                                             ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

	/*------------------- Depression------------------ */

	if ( DEPRESS = .  | DEPRESS = .N | 
	     DEPRESS = .R  | DEPRESS = .D )   then DEPRES = .;   /* Missing */
	else If DEPRESS in (1:2) 				  then DEPRES = 1;   /* Depressed */ 
	Else if DEPRESS = 0 			      then DEPRES = 0;   /* Not Depressed */
	Else                                       DEPRES = 999; /* Undefined */

	run;
