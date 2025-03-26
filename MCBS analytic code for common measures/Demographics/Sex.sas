/******************************************************************************************************/																		
/*** CODE: Create Sex measure using LDS segments                                                    ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Sex --------------------------------------------------------------------------*/
	
	if rostsex = .  | rostsex = .N | 
	   rostsex = .R | rostsex = .D                  then sex = .;   /* Missing */
	else if rostsex = 1								then sex = 1;   /* Male */ 
	else if rostsex = 2								then sex = 2;   /* Female */
	else                                                 sex = 999; /* Undefined */

	run;
