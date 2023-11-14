/******************************************************************************************************/																		
/*** CODE: Create Knowledge/Information about Medicare measures using LDS segments                  ***/
/******************************************************************************************************/

data tempf.mcreplnq;
	set survey.mcreplnq(DROP= KNSEWT KNSE1-KNSE100 KNSCWT KNSC1-KNSC100 KNCEWT KNCE1-KNCE100);

/*----------- Knowledge/Information about Medicare -------------------------------------------*/


	/*How Much Do You Know About the Medicare Program*/
    if ( kcarknow = .  | kcarknow = .N | 
	    kcarknow = .R  | kcarknow = .D )   	then medknow = .;    /* Missing */	
	else if kcarknow in (1,2) 				then medknow = 1;	/*Most or All*/
	else if kcarknow = 3 					then medknow = 2;	/*Some*/
	else if kcarknow in (4,5) 				then medknow = 3;	/*Little or None*/
	else                                         medknow = 999; /* Undefined */

	/*Are You Satisfied With the Avail. Of Information*/
    if ( knfosati = .  | knfosati = .N | knfosati = 5 |
	    knfosati = .R  | knfosati = .D )   	then satavail = .;   /* Missing */	
	else if knfosati in (1,2) 				then satavail = 1;	 /*Yes*/
	else if knfosati in (3,4) 				then satavail = 2;	 /*No*/
	else                                         satavail = 999; /* Undefined */

	run;
