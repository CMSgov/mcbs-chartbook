/******************************************************************************************************/																		
/*** CODE: Create Propensity to Seek Care measures using LDS segments                               ***/
/******************************************************************************************************/


data tempf.satwcare;
	set survey.satwcare;

/*----------- Propensity to Seek Care --------------------------------------------------------*/

	/*Visit a Doctor as Soon as You Feel Bad*/
    if ( mcdrsoon = .  | mcdrsoon = .N | 
	    mcdrsoon = .R  | mcdrsoon = .D )   	then drsoon = .;    /* Missing */	
	else if mcdrsoon = 1 					then drsoon = 1;	/*Yes*/
	else if mcdrsoon = 2					then drsoon = 0;	/*No*/
	else                                         drsoon = 999;  /* Undefined */

	/*Avoid Going to the Doctor*/
    if ( mcavoid = .  | mcavoid = .N | 
	    mcavoid = .R  | mcavoid = .D )   	then avoid = .;     /* Missing */		
	else if mcavoid = 1 					then avoid = 1;		/*Yes*/
	else if mcavoid = 2						then avoid = 0;		/*No*/
	else                                         avoid = 999;   /* Undefined */

	/*Worry About Your Health More Than Others*/
    if ( mcworry = .  | mcworry = .N | 
	    mcworry = .R  | mcworry = .D )   	then worry = .;     /* Missing */	
	else if mcworry = 1 					then worry = 1;		/*Yes*/
	else if mcworry = 2 					then worry = 0;		/*No*/
	else                                         worry = 999;   /* Undefined */

	/*When Sick, Keep to Yourself*/
    if ( mcsick = .  | mcsick = .N | 
	    mcsick = .R  | mcsick = .D )   	then sick = .;      /* Missing */	
	else if mcsick = 1 					then sick = 1;		/*Yes*/
	else if mcsick = 2 					then sick = 0;		/*No*/
	else                                     sick = 999;    /* Undefined */

run;
