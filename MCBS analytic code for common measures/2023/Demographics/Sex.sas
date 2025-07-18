/******************************************************************************************************/																		
/*** CODE: Create Sex measure using LDS segments                                                    ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Sex --------------------------------------------------------------------------*/
	
	if h_sex = .  | h_sex = .N | 
	   h_sex = .R | h_sex = .D                  then sex = .;   /* Missing */
	else if h_sex = 1								then sex = 1;   /* Male */ 
	else if h_sex = 2								then sex = 2;   /* Female */
	else                                                 sex = 999; /* Undefined */

	run;
