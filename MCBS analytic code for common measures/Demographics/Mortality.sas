/******************************************************************************************************/																		
/*** CODE: Create Mortality measure using LDS segments                                              ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*-----------Mortality---------------------------------------------------------------------------------*/

	if h_dod = . 							then death = 0 ;			/* Deceased */
	else if h_dod ^= . 						then death = 1 ;			/* Alive */
	else                                         death = 999;           /* Undefined */

	run;
