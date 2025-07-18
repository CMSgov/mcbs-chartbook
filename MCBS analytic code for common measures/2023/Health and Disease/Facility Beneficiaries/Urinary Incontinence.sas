/******************************************************************************************************/																		
/*** CODE: Create Urinary Incontinence Disability measure using LDS segments                        ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*----------- Urinary Incontinence -----------------------------------------------------------*/
	if ( ctbladdc = .  | ctbladdc = .N | ctbladdc = 4 |
	     ctbladdc = .R  | ctbladdc = .D )  	    then urinary = .;   /* Missing */
	else if ctbladdc in (2:3)					then urinary = 1;	/* Yes */
	else if ctbladdc in (0:1)					then urinary = 0;	/* No */
	else                                             urinary = 999; /* Undefined */


		run;
