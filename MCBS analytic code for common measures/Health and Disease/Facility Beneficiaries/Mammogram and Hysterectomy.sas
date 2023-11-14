/******************************************************************************************************/																		
/*** CODE: Create Mammogram and Hysterectomy measures using LDS segments                            ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*----------- Mammogram ------------------------------------------------------------------------*/
	if ( mammogr = .  | mammogr = .N | 
	     mammogr = .R  | mammogr = .D )     then mammogram = .;   /* Missing */
	else if mammogr = 1						then mammogram = 1;	  /* Yes */
	else if mammogr = 0						then mammogram = 0;	  /* No */
	else                                         mammogram = 999; /* Undefined */
run;

/*----------- Hysterectomy ---------------------------------------------------------------------*/
	if ( d_hyst = .  | d_hyst = .N | 
	     d_hyst = .R  | d_hyst = .D )     then hyst = .;   /* Missing */
	else if d_hyst = 1					  then hyst = 1;   /* Yes */
	else if d_hyst = 0					  then hyst = 0;   /* No */
	else                                       hyst = 999; /* Undefined */

run;
