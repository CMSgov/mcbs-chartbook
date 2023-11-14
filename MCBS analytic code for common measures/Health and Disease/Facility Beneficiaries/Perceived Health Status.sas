/******************************************************************************************************/																		
/*** CODE: Create Perceived Health Status measure using LDS segments                                ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

	/*----------- Perceived Health Status --------------------------------------------------------*/

    /* General Health (5-Category) */
	if ( sphealth = .  | sphealth = .N | 
	     sphealth = .R  | sphealth = .D )   then health1 = .;   /* Missing */
	else if sphealth = 0					then health1 = 1;	/* Excellent */
	else if sphealth = 1					then health1 = 2;	/* Very Good */
	else if sphealth = 2					then health1 = 3;	/* Good */
	else if sphealth = 3					then health1 = 4;	/* Fair */
	else if sphealth = 4					then health1 = 5;	/* Poor */
	else                                         health1 = 999; /* Undefined */

	run;

	/* General Health (2-Category) */
	if ( sphealth = .  | sphealth = .N | 
	     sphealth = .R  | sphealth = .D )   then health2 = .;   /* Missing */
	else if sphealth in (0:2)				then health2 = 1;	/* Excellent/Very Good */
	else if sphealth in (3,4)				then health2 = 2;	/* Fair/Poor */
	else                                         health2 = 999; /* Undefined */


	run;
