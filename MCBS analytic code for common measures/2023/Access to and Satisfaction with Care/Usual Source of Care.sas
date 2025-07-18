/******************************************************************************************************/																		
/*** CODE: Create Usual Source of Care measure using LDS segments                                   ***/
/******************************************************************************************************/



data tempf.uscare;
	set survey.uscare(DROP= USSEWT USSE1-USSE100 USSCWT USSC1-USSC100 USCEWT USCE1-USCE100);

/*----------- Usual Source of Care -----------------------------------------------------------*/

    if (placepar = .  | placepar = .N | 
	   placepar = .R  | placepar = .D) AND
	   (placeknd = .  | placeknd = .N | 
	   placeknd = .R  | placeknd = .D)      		    then us_soc = .;    /* Missing */
	else if placepar = 2								then us_soc = 0;	/*None*/             
	else do ;                                                            
		if (placeknd = .  | placeknd = .N | 
	   		placeknd = .R  | placeknd = .D)             then us_soc = .;	/* Missing */
		else if placeknd = 1							then us_soc = 1;	/*Doctor's Office*/                     
		else if	placeknd = 2							then us_soc = 2;	/*Medical Clinic*/                     
		else if	placeknd = 3							then us_soc = 3;	/*Managed Care Center*/                     
		else if	placeknd in (11,12)						then us_soc = 4;	/*Hospital/OPD/ER*/                     
		else if	placeknd in (4,5,6,7,8,9,10,13,14,91)	then us_soc = 5;	/*Other Clinic/Health Center*/  
		else                                                 us_soc = 999;  /* Undefined */
	end;

run; 
