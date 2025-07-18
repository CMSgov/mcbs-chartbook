
/******************************************************************************************************																		
CODE: Create SELF-REPORTED HEALTH STATUS measures using LDS segments                                   
******************************************************************************************************/

/** SELF-REPORTED HEALTH STATUS **/

	data health1;
		set survey.genhlth;
		if ( genhelth = .  | genhelth = .N | 
		     genhelth = .R  | genhelth = .D )   	then health1 = .;   /* Missing */
		else if genhelth in (1, 2, 3)				then health1 = 1;	/* Good, Very Good, or Excellent */
		else if genhelth in (4,5)					then health1 = 2;	/* Fair/Poor */
		else                                         health1 = 999; /* Undefined */
		keep baseid health1;
	run;
