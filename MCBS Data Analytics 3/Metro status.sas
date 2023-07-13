/******************************************************************************************************/
/*** CODE: Demographics of Medicare Beneficiaries                  				      	            ***/																		
/*** OBJECTIVE: Create Metro status measure using LDS segments                                     ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Metropolitan Residence Status---------------------------------------------------*/

	if h_cbsa = ' '                         then metro_num = .;      /* Missing */
	else if h_cbsa = 'Metro' 				then metro_num = 1;	     /* Yes */
	else if	h_cbsa in ('Micro', 'Non-CBSA')	then metro_num = 0;		 /* No */
	else                                         metro_num = 999;    /* Undefined */
