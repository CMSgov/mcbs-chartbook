/******************************************************************************************************/																		
/*** CODE: Create Smoking Status measure using LDS segments                                         ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*----------- Smoking Status -----------------------------------------------------------------*/
	if ( d_smoke = .  | d_smoke = .N | 
	     d_smoke = .R  | d_smoke = .D ) AND
	   ( nowsmoke = .  | nowsmoke = .N | 
	     nowsmoke = .R  | nowsmoke = .D )   then smoker = .;    /* Missing */
	else if d_smoke = 0						then smoker = 0;	/* Non-smoker */
	else if d_smoke = 1 & nowsmoke ^= 1		then smoker = 1;	/* Former Smoker */
	else if nowsmoke = 1					then smoker = 2;	/* Current Smoker */
	else                                         smoker = 999;  /* Undefined */


		run;
