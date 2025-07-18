/******************************************************************************************************/																		
/*** CODE: Create Upper Extremity Limitation measure using LDS segments                                ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*---- Upper Extremity Limitation -------------------------------------------------------------------*/

	if difreach = 0 AND difwrite = 0 							  	  then ulimit = 0;   /* No limitation */
	else if (difreach = .  | difreach = .N | 
	   		 difreach = .R  | difreach = .D | difreach = 0) AND
	   		(difwrite = .  | difwrite = .N | 
	   		 difwrite = .R  | difwrite = .D | difwrite = 0)           then ulimit = .;   /* Missing */ 
	else if difreach in (1:4) or difwrite in (1:4)                    then ulimit = 2;   /* Yes with any disability */
	else                                                                   ulimit = 999; /* Undefined */

	run;

