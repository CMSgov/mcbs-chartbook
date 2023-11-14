/******************************************************************************************************/																		
/*** CODE: Create Patient Centered Care measures using LDS segments                                   ***/
/******************************************************************************************************/



data tempf.uscare;
	set survey.uscare(DROP= USSEWT USSE1-USSE100 USSCWT USSC1-USSC100 USCEWT USCE1-USCE100);

	/*----------- Patient Centered Care ------------------------------------------------*/


	/*Patient Feels Listened to by Provider*/
    if ( doclstn = .  | doclstn = .N | 
	    doclstn = .R  | doclstn = .D )   				then listens = .;   /* Missing */
	else if doclstn = 1 								then listens = 1;   /* Never */
	else if doclstn = 2 								then listens = 2;   /* Sometimes */
	else if doclstn = 3 								then listens = 3;   /* Usually */
	else if doclstn = 4 								then listens = 4;   /* Always */
	else													 listens = 999; /* Undefined */
	
	/*Patient Feels Provider Respects Them*/
    if ( docrspct = .  | docrspct = .N | 
	    docrspct = .R  | docrspct = .D )   				    then respects = .;   /* Missing */
	else if docrspct = 1 									then respects = 1;   /* Never */
	else if docrspct = 2 									then respects = 2;   /* Sometimes */
	else if docrspct = 3 									then respects = 3;   /* Usually */
	else if docrspct = 4 									then respects = 4;   /* Always */
	else													     respects = 999; /* Undefined */
	
	/*Patient Feels Provider Spent Enough Time with Them*/
    if ( enuftime = .  | enuftime = .N | 
	    enuftime = .R  | enuftime = .D )   				    then spendtime = .;   /* Missing */
	else if enuftime = 1 									then spendtime = 1;   /* Never */
	else if enuftime = 2 									then spendtime = 2;   /* Sometimes */
	else if enuftime = 3 									then spendtime = 3;   /* Usually */
	else if enuftime = 4 									then spendtime = 4;   /* Always */  
	else													     spendtime = 999; /* Undefined */
	
	/*Provider Asks About Health*/
    if ( dochlth = .  | dochlth = .N | 
	    dochlth = .R  | dochlth = .D )   				then askhlth = .;   /* Missing */
	else if dochlth = 1 								then askhlth = 1;   /* Never */
	else if dochlth = 2 								then askhlth = 2;   /* Sometimes */
	else if dochlth = 3 								then askhlth = 3;   /* Usually */
	else if dochlth = 4 								then askhlth = 4;   /* Always */
	else													 askhlth = 999; /* Undefined */
	
	/*Provider Explains Clearly*/
    if ( doceasy = .  | doceasy = .N | 
	    doceasy = .R  | doceasy = .D )   				then clear = .;   /* Missing */
	else if doceasy = 1 								then clear = 1;   /* Never */
	else if doceasy = 2 								then clear = 2;   /* Sometimes */
	else if doceasy = 3 								then clear = 3;   /* Usually */
	else if doceasy = 4 								then clear = 4;   /* Always */
	else													 clear = 999; /* Undefined */

run;     
