/******************************************************************************************************/																		
/*** CODE: Create Marital status measure using LDS segments                                         ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Marital Status -----------------------------------------------------------------*/
	
	if spmarsta = .  | spmarsta = .N | 
	   spmarsta = .R | spmarsta = .D                then maristat = .;   /* Missing */
	else if spmarsta = 1							then maristat = 1; 	 /* Married */
	else if spmarsta = 2							then maristat = 2; 	 /* Widowed */
	else if spmarsta in (3,4)						then maristat = 3;	 /* Divorced or Separated */
	else if spmarsta = 5							then maristat = 4;	 /* Never Married */
	else                                                 maristat = 999; /* Undefined */

	run;
