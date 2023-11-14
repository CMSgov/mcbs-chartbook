/******************************************************************************************************/																		
/*** CODE: Create Sex measure using LDS segments                                                    ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Sex --------------------------------------------------------------------------*/
	
	if rostsex = .  | rostsex = .N | 
	   rostsex = .R | rostsex = .D                  then gender = .;   /* Missing */
	else if rostsex = 1								then gender = 1;   /* Male */ 
	else if rostsex = 2								then gender = 2;   /* Female */
	else                                                 gender = 999; /* Undefined */

	run;
