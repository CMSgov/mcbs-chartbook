/******************************************************************************************************/																		
/*** CODE: Create Access to Care measures using LDS segments                                        ***/
/******************************************************************************************************/


data tempf.accesscr;
	set survey.accesscr;

	/*----------- Access to Care Measures --------------------------------------------------------*/


	/*Had Difficulty Obtaining Care*/
    if ( hctroubl = .  | hctroubl = .N | 
	    hctroubl = .R  | hctroubl = .D )   			then diffgetc = .;   /* Missing */
	else if hctroubl = 1 							then diffgetc = 1;	 /*Yes*/
	else if hctroubl = 2 							then diffgetc = 2;	 /*No*/
	else                                                 diffgetc = 999; /* Undefined */

	/*Delayed Care Due to Cost*/
    if ( hcdelay = .  | hcdelay = .N | 
	    hcdelay = .R  | hcdelay = .D )   			then delaycar = .;   /* Missing */
	else if hcdelay = 1 							then delaycar = 1;	 /*Yes*/
	else if hcdelay = 2 							then delaycar = 2;	 /*No*/
	else                                                 delaycar = 999; /* Undefined */

run;     
