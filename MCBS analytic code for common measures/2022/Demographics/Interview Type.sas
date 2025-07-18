/******************************************************************************************************/																		
/*** CODE: Create Interview Type measure using LDS segments                                              ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Interview Type------------------------------------------------------------------*/
	
	if int_type = " " 						then resista3 = .;   /* Missing */
	else if upcase(int_type) = 'C'			then resista3 = 1;   /* Community */
	else if upcase(int_type) = 'F'			then resista3 = 2;   /* Facility */
	else if upcase(int_type) = 'B'			then resista3 = 3;   /* Community and Facility */
	else                                         resista3 = 999; /* Undefined */

	run;
