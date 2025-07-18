/******************************************************************************************************/																		
/*** CODE: Create Veteran status measure using LDS segments                                              ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Veteran Status------------------------------------------------------------------*/
	
	if spafever = .  | spafever = .N | 
	   spafever = .R | spafever = .D                then veteran = .;   /* Missing */
	else if spafever = 1							then veteran = 1;	/* Yes */
	else if	spafever = 0							then veteran = 0;	/* No */
	else                                                 veteran = 999; /* Undefined */

	run;
