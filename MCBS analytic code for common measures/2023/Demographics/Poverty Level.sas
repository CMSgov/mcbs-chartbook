/******************************************************************************************************/																		
/*** CODE: Create Poverty Level measure using LDS segments                                          ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*--------------------Poverty Level---------------------------------------------------------------*/
	
	if ipr = .  | ipr = .N | 
	   ipr = .R | ipr = .D                 		   then poverty5 = .;    /* Missing */
    else if ipr <= 1.00                            then poverty5 = 1;    /* <=100% of the Federal Poverty Level */   
	else if 1.00 < ipr <= 1.20                     then poverty5 = 2;    /* >100% and <=120% of the Federal Poverty */ 
    else if 1.20 < ipr <= 1.35                     then poverty5 = 3;    /* >120% and <=135% of the Federal Poverty */ 
    else if 1.35 < ipr <= 2.00                     then poverty5 = 4;    /* >135% and <=200% of the Federal Poverty */ 
    else if ipr > 2.00                             then poverty5 = 5;    /* >200% of the Federal Poverty Level */
	else                                                poverty5 = 999;  /* Undefined */

	run;
