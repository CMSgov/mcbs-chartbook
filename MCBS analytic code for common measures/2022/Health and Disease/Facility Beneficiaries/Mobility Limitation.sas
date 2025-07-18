/******************************************************************************************************/																		
/*** CODE: Create Mobility Limitation measure using LDS segments                                    ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*---- Mobility Limitation --------------------------------------------------------------------------*/

	if ( DIFWALK = .  | DIFWALK = .N | 
	     DIFWALK = .R  | DIFWALK = .D )      then MLIMIT = .;   /* Missing */
	else if DIFWALK = 0                      then MLIMIT = 0;   /*No limitation*/
	else if DIFWALK in (1, 2, 3, 4)          then MLIMIT = 2;   /* Yes with any disability */
	else                                          MLIMIT = 999; /* Undefined */

	run;

