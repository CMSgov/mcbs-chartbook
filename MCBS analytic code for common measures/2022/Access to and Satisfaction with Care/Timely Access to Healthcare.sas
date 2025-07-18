/******************************************************************************************************/																		
/*** CODE: Create Timely Access to Healthcare measures using LDS segments                           ***/
/******************************************************************************************************/


data tempf.accssmed;
	set survey.accssmed (DROP= ACSEWT ACSE1-ACSE100 ACSCWT ACSC1-ACSC100 ACCEWT ACCE1-ACCE100);

/*----------- Timely Access to Healthcare  ------------------------------------------------*/



	/* Physician Wait Time */
    if ( d_mdappt = .  | d_mdappt = .N | 
	    d_mdappt = .R  | d_mdappt = .D )   			then p_wait = .;   /* Missing */	
	else if d_mdappt = 0 							then p_wait = 1;   /* No wait */
	else if d_mdappt in (1:6) 						then p_wait = 2;   /* 1 - 6 Days */
	else if d_mdappt in (7:12)						then p_wait = 3;   /* 7 - 12 Days */
	else if d_mdappt in (13:18) 					then p_wait = 4;   /* 13 - 18 Days */
	else if d_mdappt ge 19							then p_wait = 5;   /* 19+ Days */
	else                                                 p_wait = 999; /* Undefined */

	/*Had a Problem and Did Not See Doctor*/
    if ( mcdrnsee = .  | mcdrnsee = .N | 
	    mcdrnsee = .R  | mcdrnsee = .D )   	then drnotsee = .;   /* Missing */		
	else if mcdrnsee = 1 					then drnotsee = 1;	 /*Yes*/
	else if mcdrnsee = 2 					then drnotsee = 0;	 /*No*/
	else                                         drnotsee = 999; /* Undefined */

run;
