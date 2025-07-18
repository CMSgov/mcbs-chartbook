/******************************************************************************************************/																		
/*** CODE: Create Education measure using LDS segments                                              ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Education ----------------------------------------------------------------------*/
	
		/* 4-level education construction */
	if spdegrcv = .  | spdegrcv = .N | 
	   spdegrcv = .R | spdegrcv = .D                then educlev2 = .;   /* Missing */
	else if spdegrcv in (1,2,3)						then educlev2 = 1;   /* Less than HS diploma */
	else if spdegrcv = 4							then educlev2 = 2;   /* HS Graduate */
	else if spdegrcv in (5,6,7)						then educlev2 = 3;   /* Some College/Vocational School */
	else if spdegrcv in (8,9)						then educlev2 = 4;   /* Bachelor's Degree and Beyond */ 
	else                                                 educlev2 = 999; /* Undefined */

	run;


	       /* 5-level education construction */
       if spdegrcv = . |spdegrcv = .N |
          spdegrcv = .R | spdegrcv = .D            then educlev2 = .;   /* Missing */                                                           
       else if spdegrcv in (1,2,3)                 then educlev2 = 1;   /* Less than HS diploma */             
       else if spdegrcv = 4                        then educlev2 = 2;   /* HS Graduate */
       else if spdegrcv in (5,6,7)                 then educlev2 = 3;   /* Some College/Vocational School */
       else if spdegrcv = 8                        then educlev2 = 4;   /* Bachelor's Degree */
       else if spdegrcv = 9                        then educlev2 = 5;   /* Graduate or professional degree */
       else                                             educlev2 = 999; /* Undefined */            

	run;
