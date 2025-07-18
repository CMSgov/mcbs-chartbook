/******************************************************************************************************/																		
/*** CODE: Create Satisfaction with Care measures using LDS segments                                ***/
/******************************************************************************************************/


data tempf.satwcare;
	set survey.satwcare;

/*----------- Satisfaction with Care Measures ------------------------------------------------*/


	/*Satisfaction with General Care*/
    if ( mcqualty = .  | mcqualty = .N | 
	    mcqualty = .R  | mcqualty = .D | 
	    mcqualty = 5)   					then satwqual = .;   /* Missing */	
	else if mcqualty = 1					then satwqual = 1;	 /*Very Satisfied*/
	else if	mcqualty = 2 					then satwqual = 2;	 /*Satisfied*/
	else if	mcqualty in (3,4)				then satwqual = 3;	 /*(Very) Unsatisfied*/
	else                                         satwqual = 999; /* Undefined */

	/*Satisfaction with Availability of Specialist Care*/
    if ( mcspecar = .  | mcspecar = .N | 
	    mcspecar = .R  | mcspecar = .D | 
	    mcspecar = 5)   					then satwspec = .;   /* Missing */		
	else if mcspecar = 1			    	then satwspec = 1;   /* Very Satisfied */
	else if mcspecar = 2					then satwspec = 2;   /* Satisfied */
	else if mcspecar in (3,4)				then satwspec = 3;   /* (Very) Unsatisfied */
	else                                         sawwspec = 999; /* Undefined */

	/*Satisfaction with Night & Weekend Availability*/
    if ( mcavail = .  | mcavail = .N | 
	    mcavail = .R  | mcavail = .D | 
	    mcavail = 5)   						then satwavai = .;   /* Missing */			
	else if mcavail = 1						then satwavai = 1;	 /*Very Satisfied*/
	else if	mcavail = 2						then satwavai = 2;	 /*Satisfied*/
	else if	mcavail in (3,4)				then satwavai = 3;	 /*(Very) Unsatisfied*/
	else                                         satwavai = 999; /* Undefined */

	/*Satisfaction with Ease of Access to Doctor*/
    if ( mcease = .  | mcease = .N | 
	    mcease = .R  | mcease = .D | 
	    mcease = 5)   					then satwease = .;   /* Missing */	
	else if mcease = 1					then satwease = 1;	 /*Very Satisfied*/
	else if	mcease = 2					then satwease = 2;	 /*Satisfied*/
	else if	mcease in (3,4)				then satwease = 3;	 /*(Very) Unsatisfied*/
	else                                     satwease = 999; /* Undefined */

	/*Satisfaction with Ability to Obtain Care in Same Location*/
    if ( mcsamloc = .  | mcsamloc = .N | 
	    mcsamloc = .R  | mcsamloc = .D | 
	    mcsamloc = 5)   					then satwlocn = .;   /* Missing */		
	else if mcsamloc = 1					then satwlocn = 1;	 /*Very Satisfied*/
	else if	mcsamloc = 2					then satwlocn = 2;	 /*Satisfied*/
	else if	mcsamloc in (3,4)				then satwlocn = 3;	 /*(Very) Unsatisfied*/
	else                                     	 satwlocn = 999; /* Undefined */

	/*Satisfaction with Information from Doctor*/
    if ( mcinfo = .  | mcinfo = .N | 
	    mcinfo = .R  | mcinfo = .D | 
	    mcinfo = 5)   					then satwinfo = .;   /* Missing */			
	else if mcinfo = 1					then satwinfo = 1;	 /*Very Satisfied*/
	else if	mcinfo = 2					then satwinfo = 2;	 /*Satisfied*/
	else if	mcinfo in (3,4)				then satwinfo = 3;	 /*(Very) Unsatisfied*/
	else                                     satwinfo = 999; /* Undefined */

	/*Satisfaction with Doctor's Concern for Overall Health*/
    if ( mcconcrn = .  | mcconcrn = .N | 
	    mcconcrn = .R  | mcconcrn = .D | 
	    mcconcrn = 5)   					then satwconc = .;   /* Missing */		
	else if mcconcrn = 1					then satwconc = 1;	 /*Very Satisfied*/
	else if	mcconcrn = 2					then satwconc = 2;	 /*Satisfied*/
	else if	mcconcrn in (3,4)				then satwconc = 3;	 /*(Very) Unsatisfied*/
	else                             			 satwconc = 999; /* Undefined

	/*Satisfaction with Cost of Care*/
    if ( mccosts = .  | mccosts = .N | 
	    mccosts = .R  | mccosts = .D | 
	    mccosts = 5)   						then satwcost = .;   /* Missing */	
	else if mccosts = 1						then satwcost = 1;	 /*Very Satisfied*/
	else if	mccosts = 2						then satwcost = 2;	 /*Satisfied*/
	else if	mccosts in (3,4)				then satwcost = 3;	 /*(Very) Unsatisfied*/
	else                                         satwcost = 999; /* Undefined */

	run;
