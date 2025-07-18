/******************************************************************************************************/																		
/*** CODE: Create Perceived Health Status measure using LDS segments                                ***/
/******************************************************************************************************/

data tempf.genhlthc;
	set survey.genhlth;

	/*----------- Perceived Health Status --------------------------------------------------------*/

	/* General Health (5 Category) */
	if ( genhelth = .  | genhelth = .N | 
	     genhelth = .R  | genhelth = .D )   then health1 = .;   /* Missing */
	else if genhelth = 1				    then health1 = 1;	/* Excellent */
	else if genhelth = 2					then health1 = 2;	/* Very Good */
	else if genhelth = 3					then health1 = 3;	/* Good */
	else if genhelth = 4					then health1 = 4;	/* Fair */
	else if genhelth = 5					then health1 = 5;	/* Poor */
	else                                         health1 = 999; /* Undefined */

run;

	/* General Health (2 Category) */
	if ( genhelth = .  | genhelth = .N | 
	     genhelth = .R  | genhelth = .D )   then health2 = .;   /* Missing */
	else if genhelth in (1:3)				then health2 = 1;	/* Excellent/Very Good/Good */
	else if genhelth in (4,5)				then health2 = 2;	/* Fair/Poor */
	else                                         health2 = 999; /* Undefined */
run;
