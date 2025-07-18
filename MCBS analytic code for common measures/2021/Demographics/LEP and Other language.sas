/******************************************************************************************************/																		
/*** CODE: Create LEP and Other language measures using LDS segments                                 ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Limited English Proficiency---------------------------------------------------------------*/
	
	if ENGWELL = .  | ENGWELL = .N | 
	   ENGWELL = .R | ENGWELL = .D                  then lep = .;   /* Missing */
	else if ENGWELL in (2:4) 						then lep = 1;   /* LEP */
	else if ENGWELL = 1								then lep = 0;   /* Not LEP */
	else 												 lep = 999; /* Undefined */

	run;

/*-----------Language Other than English Spoken at Home-------------------------------------------*/
	
	if OTHRLANG = .  | OTHRLANG = .N | 
	   OTHRLANG = .R | OTHRLANG = .D                then otherlang = .;   /* Missing */
	else if OTHRLANG = 1 							then otherlang = 1;   /* Yes */
	else if OTHRLANG = 2 							then otherlang = 0;   /* No */
	else                                                 otherlang = 999; /* Undefined */

	run;
