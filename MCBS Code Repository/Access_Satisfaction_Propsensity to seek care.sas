/******************************************************************************************************/
/*** CODE: Access to, Satisfaction With, and Propensity to Seek Care					            ***/																				
/*** OBJECTIVE: Create access/satisfaction/propsensity to seek care measures using LDS segments     ***/
/******************************************************************************************************/

/*----------- Usual Source of Care -----------------------------------------------------------*/

data tempf.uscare;
	set survey.uscare(DROP= USSEWT USSE1-USSE100 USSCWT USSC1-USSC100 USCEWT USCE1-USCE100);

	/*Usual Source of Care*/
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

	
/*-----------Assistance Communicating with Medical Provider----------------------------------------*/

	if (MEDPVSTF = . | MEDPVSTF = .N | MEDPVSTF = .R | MEDPVSTF = .D | MEDPVSTF = 0) and
	   (MEDPVFAM = . | MEDPVFAM = .N | MEDPVFAM = .R | MEDPVFAM = .D | MEDPVFAM = 0) and
	   (MEDPVENG = . | MEDPVENG = .N | MEDPVENG = .R | MEDPVENG = .D | MEDPVENG = 0) 
	   														then engassist = .;   /* Missing */
	else if MEDPVSTF = 1 							  		then engassist = 1;   /* Medical Office Staff */
	else if MEDPVFAM = 1 							  		then engassist = 2;   /* Family Member */
	else if MEDPVENG = 1 							  		then engassist = 3;   /* Does their Best Speaking English */
	else                                                 		 engassist = 999; /* Undefined */
	
/*-----------Preferred Language for Medical Care--------------------------------------------------*/

	if LANGPREF = .  | LANGPREF = .N | 
	   LANGPREF = .R | LANGPREF = .D                then doclang = .;  /* Missing */
	else if LANGPREF = 1  							then doclang = 0;  /* English */
	else if LANGPREF = 2  							then doclang = 1;  /* Language Spoken at Home */
	else if LANGPREF = 3  							then doclang = 2;  /* Both English and Language Spoken at Home */
	else if LANGPREF = 91 							then doclang = 3;  /* Other */
	else                                                 doclang = 999; /* Undefined */
	

/*-----------Problem Understanding a Medical Situation--------------------------------------------*/

	if LANGPROB = .  | LANGPROB = .N | 
	   LANGPROB = .R | LANGPROB = .D                then probunder = .;   /* Missing */
	else if LANGPROB = 1 							then probunder = 1;   /* Yes */
	else if LANGPROB = 2 							then probunder = 0;   /* No */
	else												 probunder = 999; /* Undefined */

/*-----------Usual Provider Speaks Language Spoken at Home----------------------------------------*/

	if LANGPRVD = .  | LANGPRVD = .N | 
	   LANGPRVD = .R | LANGPRVD = .D                then provspeak = .;   /* Missing */
	else if LANGPRVD = 1  							then provspeak = 1;   /* Yes */
	else if LANGPRVD = 2 							then provspeak = 0;   /* No */
	else                                                 provspeak = 999; /* Undefined */

run; 

	/*----------- Patient Centered Care ------------------------------------------------*/

	/*Patient Feels Listened to by Provider*/
    if ( doclstn = .  | doclstn = .N | 
	    doclstn = .R  | doclstn = .D )   				then listens = .;   /* Missing */
	else if doclstn = 1 								then listens = 1;   /* Never */
	else if doclstn = 2 								then listens = 2;   /* Sometimes */
	else if doclstn = 3 								then listens = 3;   /* Usually */
	else if doclstn = 4 								then listens = 4;   /* Always */
	else													 listens = 999; /* Undefined */
	
	/*Patient Feels Provider Respects Them*/
    if ( docrspct = .  | docrspct = .N | 
	    docrspct = .R  | docrspct = .D )   				    then respects = .;   /* Missing */
	else if docrspct = 1 									then respects = 1;   /* Never */
	else if docrspct = 2 									then respects = 2;   /* Sometimes */
	else if docrspct = 3 									then respects = 3;   /* Usually */
	else if docrspct = 4 									then respects = 4;   /* Always */
	else													     respects = 999; /* Undefined */
	
	/*Patient Feels Provider Spent Enough Time with Them*/
    if ( enuftime = .  | enuftime = .N | 
	    enuftime = .R  | enuftime = .D )   				    then spendtime = .;   /* Missing */
	else if enuftime = 1 									then spendtime = 1;   /* Never */
	else if enuftime = 2 									then spendtime = 2;   /* Sometimes */
	else if enuftime = 3 									then spendtime = 3;   /* Usually */
	else if enuftime = 4 									then spendtime = 4;   /* Always */  
	else													     spendtime = 999; /* Undefined */
	
	/*Provider Asks About Health*/
    if ( dochlth = .  | dochlth = .N | 
	    dochlth = .R  | dochlth = .D )   				then askhlth = .;   /* Missing */
	else if dochlth = 1 								then askhlth = 1;   /* Never */
	else if dochlth = 2 								then askhlth = 2;   /* Sometimes */
	else if dochlth = 3 								then askhlth = 3;   /* Usually */
	else if dochlth = 4 								then askhlth = 4;   /* Always */
	else													 askhlth = 999; /* Undefined */
	
	/*Provider Explains Clearly*/
    if ( doceasy = .  | doceasy = .N | 
	    doceasy = .R  | doceasy = .D )   				then clear = .;   /* Missing */
	else if doceasy = 1 								then clear = 1;   /* Never */
	else if doceasy = 2 								then clear = 2;   /* Sometimes */
	else if doceasy = 3 								then clear = 3;   /* Usually */
	else if doceasy = 4 								then clear = 4;   /* Always */
	else													 clear = 999; /* Undefined */

run;

/*----------- Access to Care Measures --------------------------------------------------------*/

data tempf.accesscr;
	set survey.accesscr;

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

/*----------- Timely Access to Healthcare  ------------------------------------------------*/

data tempf.accssmed;
	set survey.accssmed (DROP= ACSEWT ACSE1-ACSE100 ACSCWT ACSC1-ACSC100 ACCEWT ACCE1-ACCE100);

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

/*----------- Satisfaction with Care Measures ------------------------------------------------*/

data tempf.satwcare;
	set survey.satwcare;

	/*Satisfaction with General Care*/
    if ( mcqualty = .  | mcqualty = .N | 
	    mcqualty = .R  | mcqualty = .D | 
	    mcqualty = 5)   					then satwqual = .;   /* Missing */	
	else if mcqualty = 1					then satwqual = 1;	 /*Very Satisfied*/
	else if	mcqualty = 2 					then satwqual = 2;	 /*Satisfied*/
	else if	mcqualty in (3,4)				then satwqual = 3;	 /*(Very) Unsatisfied*/
	else                                         satwqual = 999; /* Undefined */

	/*Satisfaction with Availability of Specialist Care*/
    if ( mcspecar = .  | mcspecar = .N | 
	    mcspecar = .R  | mcspecar = .D | 
	    mcspecar = 5)   					then satwspec = .;   /* Missing */		
	else if mcspecar = 1			    	then satwspec = 1;   /* Very Satisfied */
	else if mcspecar = 2					then satwspec = 2;   /* Satisfied */
	else if mcspecar in (3,4)				then satwspec = 3;   /* (Very) Unsatisfied */
	else                                         sawwspec = 999; /* Undefined */

	/*Satisfaction with Night & Weekend Availability*/
    if ( mcavail = .  | mcavail = .N | 
	    mcavail = .R  | mcavail = .D | 
	    mcavail = 5)   						then satwavai = .;   /* Missing */			
	else if mcavail = 1						then satwavai = 1;	 /*Very Satisfied*/
	else if	mcavail = 2						then satwavai = 2;	 /*Satisfied*/
	else if	mcavail in (3,4)				then satwavai = 3;	 /*(Very) Unsatisfied*/
	else                                         satwavai = 999; /* Undefined */

	/*Satisfaction with Ease of Access to Doctor*/
    if ( mcease = .  | mcease = .N | 
	    mcease = .R  | mcease = .D | 
	    mcease = 5)   					then satwease = .;   /* Missing */	
	else if mcease = 1					then satwease = 1;	 /*Very Satisfied*/
	else if	mcease = 2					then satwease = 2;	 /*Satisfied*/
	else if	mcease in (3,4)				then satwease = 3;	 /*(Very) Unsatisfied*/
	else                                     satwease = 999; /* Undefined */

	/*Satisfaction with Ability to Obtain Care in Same Location*/
    if ( mcsamloc = .  | mcsamloc = .N | 
	    mcsamloc = .R  | mcsamloc = .D | 
	    mcsamloc = 5)   					then satwlocn = .;   /* Missing */		
	else if mcsamloc = 1					then satwlocn = 1;	 /*Very Satisfied*/
	else if	mcsamloc = 2					then satwlocn = 2;	 /*Satisfied*/
	else if	mcsamloc in (3,4)				then satwlocn = 3;	 /*(Very) Unsatisfied*/
	else                                     	 satwlocn = 999; /* Undefined */

	/*Satisfaction with Information from Doctor*/
    if ( mcinfo = .  | mcinfo = .N | 
	    mcinfo = .R  | mcinfo = .D | 
	    mcinfo = 5)   					then satwinfo = .;   /* Missing */			
	else if mcinfo = 1					then satwinfo = 1;	 /*Very Satisfied*/
	else if	mcinfo = 2					then satwinfo = 2;	 /*Satisfied*/
	else if	mcinfo in (3,4)				then satwinfo = 3;	 /*(Very) Unsatisfied*/
	else                                     satwinfo = 999; /* Undefined */

	/*Satisfaction with Doctor's Concern for Overall Health*/
    if ( mcconcrn = .  | mcconcrn = .N | 
	    mcconcrn = .R  | mcconcrn = .D | 
	    mcconcrn = 5)   					then satwconc = .;   /* Missing */		
	else if mcconcrn = 1					then satwconc = 1;	 /*Very Satisfied*/
	else if	mcconcrn = 2					then satwconc = 2;	 /*Satisfied*/
	else if	mcconcrn in (3,4)				then satwconc = 3;	 /*(Very) Unsatisfied*/
	else                             			 satwconc = 999; /* Undefined

	/*Satisfaction with Cost of Care*/
    if ( mccosts = .  | mccosts = .N | 
	    mccosts = .R  | mccosts = .D | 
	    mccosts = 5)   						then satwcost = .;   /* Missing */	
	else if mccosts = 1						then satwcost = 1;	 /*Very Satisfied*/
	else if	mccosts = 2						then satwcost = 2;	 /*Satisfied*/
	else if	mccosts in (3,4)				then satwcost = 3;	 /*(Very) Unsatisfied*/
	else                                         satwcost = 999; /* Undefined */

/*----------- Propensity to Seek Care --------------------------------------------------------*/

	/*Visit a Doctor as Soon as You Feel Bad*/
    if ( mcdrsoon = .  | mcdrsoon = .N | 
	    mcdrsoon = .R  | mcdrsoon = .D )   	then drsoon = .;    /* Missing */	
	else if mcdrsoon = 1 					then drsoon = 1;	/*Yes*/
	else if mcdrsoon = 2					then drsoon = 0;	/*No*/
	else                                         drsoon = 999;  /* Undefined */

	/*Avoid Going to the Doctor*/
    if ( mcavoid = .  | mcavoid = .N | 
	    mcavoid = .R  | mcavoid = .D )   	then avoid = .;     /* Missing */		
	else if mcavoid = 1 					then avoid = 1;		/*Yes*/
	else if mcavoid = 2						then avoid = 0;		/*No*/
	else                                         avoid = 999;   /* Undefined */

	/*Worry About Your Health More Than Others*/
    if ( mcworry = .  | mcworry = .N | 
	    mcworry = .R  | mcworry = .D )   	then worry = .;     /* Missing */	
	else if mcworry = 1 					then worry = 1;		/*Yes*/
	else if mcworry = 2 					then worry = 0;		/*No*/
	else                                         worry = 999;   /* Undefined */

	/*When Sick, Keep to Yourself*/
    if ( mcsick = .  | mcsick = .N | 
	    mcsick = .R  | mcsick = .D )   	then sick = .;      /* Missing */	
	else if mcsick = 1 					then sick = 1;		/*Yes*/
	else if mcsick = 2 					then sick = 0;		/*No*/
	else                                     sick = 999;    /* Undefined */

run;

data tempf.rxmed;
	set survey.rxmed(DROP= RXSEWT RXSE1-RXSE100 RXSCWT RXSC1-RXSC100 RXCEWT RXCE1-RXCE100);

	/*Have a prescription that you do not refill due to cost*/
    if ( nofillrx = .  | nofillrx = .N | 
	    nofillrx = .R  | nofillrx = .D )   	then nodrug = .;    /* Missing */	
	else if nofillrx in (1,2)				then nodrug = 1;	/*Yes*/
	else if nofillrx = 3					then nodrug = 0;	/*No*/
	else                                         nodrug = 999;  /* Undefined */
	
run;


/*----------- Knowledge/Information about Medicare -------------------------------------------*/

data tempf.mcreplnq;
	set survey.mcreplnq(DROP= KNSEWT KNSE1-KNSE100 KNSCWT KNSC1-KNSC100 KNCEWT KNCE1-KNCE100);

	/*How Much Do You Know About the Medicare Program*/
    if ( kcarknow = .  | kcarknow = .N | 
	    kcarknow = .R  | kcarknow = .D )   	then medknow = .;    /* Missing */	
	else if kcarknow in (1,2) 				then medknow = 1;	/*Most or All*/
	else if kcarknow = 3 					then medknow = 2;	/*Some*/
	else if kcarknow in (4,5) 				then medknow = 3;	/*Little or None*/
	else                                         medknow = 999; /* Undefined */

	/*Are You Satisfied With the Avail. Of Information*/
    if ( knfosati = .  | knfosati = .N | knfosati = 5 |
	    knfosati = .R  | knfosati = .D )   	then satavail = .;   /* Missing */	
	else if knfosati in (1,2) 				then satavail = 1;	 /*Yes*/
	else if knfosati in (3,4) 				then satavail = 2;	 /*No*/
	else                                         satavail = 999; /* Undefined */
	
/*---------------------------------------------------------------------------------*/
/*----------- 2020 SPECIAL FEATURE: Internet Usage --------------------------------*/
/*---------------------------------------------------------------------------------*/

if ( knetpers = .  | knetpers = .N | 
     knetpers = .R  | knetpers = .D )   then netuse = .;    /* Missing */
else if knetpers = 1 					then netuse = 1; 	 /* Yes */
else if knetpers = 2 					then netuse = 0; 	 /* No */
else 										 netuse = 999;  /* Undefined */
	
run;

/*---------------------------------------------------------------------------------*/
/*----------- SPECIAL FEATURE: COVID-19 -------------------------------------------*/
/*---------------------------------------------------------------------------------*/
data tempf.covid;
	set survey.covidfal;

   /* Unable to Receive Care Due to COVID-19 since July 2020 */
	if ( covidcar = .  | covidcar = .N |
		 covidcar = .R  | covidcar = .D ) then foregone = .;   /* Missing */
	else if covidcar = 1 				  then foregone = 1;   /* Yes */
	else if covidcar = 2 				  then foregone = 0;   /* No */
	else 									   foregone = 999; /* Undefined */

	/* Telehealth Utilization since July 2020 */
	if ( telmedus = .  | telmedus = .N |
		 telmedus = .R  | telmedus = .D ) then telehealth = .;   /* Missing */
	else if telmedus = 1 				  then telehealth = 1; 	 /* Yes */
	else if telmedus = 2 				  then telehealth = 0; 	 /* No */
	else 									   telehealth = 999; /* Undefined */

run;


