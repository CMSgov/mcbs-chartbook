/******************************************************************************************************/
/*** CODE: Demographics of Medicare Beneficiaries                  				    ***/																		
/*** OBJECTIVE: Create demographic measures using LDS segments                                      ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*------------Age - 3 separate categorical structures----------------------------*/
	
	if d_strat = .  | d_strat = .N | 
	   d_strat = .R | d_strat = .D                  then age1 = .;   /* Missing */
	else if d_strat in (1:2)						then age1 = 1;   /* <65 Years */
	else if d_strat in (3:7)						then age1 = 2;   /* 65+ Years */
	else 										 		age1 = 999;  /* Undefined */
	
	if d_strat = .  | d_strat = .N | 
	   d_strat = .R | d_strat = .D                  then age3 = .;   /* Missing */
	else if d_strat in (1:2)						then age3 = 1;   /* <65 Years */
	else if d_strat in (3:4)						then age3 = 2;   /* 65-74 Years */
	else if d_strat in (5:6)						then age3 = 3;   /* 75-84 Years */
	else if d_strat = 7								then age3 = 4;   /* 85+ Years */
	else                                    		     age3 = 999; /* Undefined */
	
	if d_strat = .  | d_strat = .N | 
	   d_strat = .R | d_strat = .D                  then age2 = .;   /* Missing */
	else if d_strat = 1 							then age2 = 1;   /* <45 Years */
	else if d_strat = 2  							then age2 = 2;   /* 45-64 Years */
	else if d_strat in (3:4) 						then age2 = 3;   /* 65-74 Years */
	else if d_strat in (5:6)  						then age2 = 4;   /* 75-84 Years */
	else if d_strat = 7 							then age2 = 5;   /* 85+ Years */
	else                                                 age2 = 999; /* Undefined */

/*----------- Metropolitan Residence Status---------------------------------------------------*/

	if h_cbsa = ' '                         then metro_num = .;      /* Missing */
	else if h_cbsa = 'Metro' 				then metro_num = 1;	     /* Yes */
	else if	h_cbsa in ('Micro', 'Non-CBSA')	then metro_num = 0;		 /* No */
	else                                         metro_num = 999;    /* Undefined */

/*----------- Residence Area (4-Category) (New Rez Status Codes 2020) -----------------------------*/

	if h_ruca1 = .                         	then RezStat4 = .;    /* Missing */
	else if h_ruca1 in (1,2,3) 				then RezStat4 = 0;	  /* Metro */
	else if	h_ruca1 in (4,5,6)	            then RezStat4 = 1;	  /* Micro */
	else if	h_ruca1 in (7,8,9)	            then RezStat4 = 2;	  /* Small Town */
	else if	h_ruca1 = 10	            	then RezStat4 = 3;	  /* Rural */
	else                                         RezStat4 = 999;  /* Undefined */

/*----------- Urban/Rural Status (New Rez Status Codes 2020) --------------------------------------*/

	if h_ruca = ' '                         then UrbRurStat = .;      /* Missing */
	else if h_ruca = 'Rural' 				then UrbRurStat = 0;	  /* Rural */
	else if	h_ruca = 'Urban'	            then UrbRurStat = 1;	  /* Urban */
	else                                         UrbRurStat = 999;    /* Undefined */

/*----------- Sex --------------------------------------------------------------------------*/
	
	if rostsex = .  | rostsex = .N | 
	   rostsex = .R | rostsex = .D                  then gender = .;   /* Missing */
	else if rostsex = 1								then gender = 1;   /* Male */ 
	else if rostsex = 2								then gender = 2;   /* Female */
	else                                                 gender = 999; /* Undefined */

/*----------- Race/Ethnicity -----------------------------------------------------------------*/

	if (hisporig = . | hisporig = .R | hisporig = .D | hisporig = .N | hisporig = 2) and 
	   (d_race2 = .  | d_race2 = .R  | hisporig = .D | d_race2 = .D) 
	   										then ethnicty = .;
	else if hisporig = 1					then ethnicty = 3;		/* Hispanic origin */
	else do;
		if d_race2 = 4						then ethnicty = 1;		/* White */
		else if d_race2 = 2					then ethnicty = 2;		/* Black */
		else if d_race2 in (1,3,5:7)		then ethnicty = 4;		/* Other */
		else                                     ethnicty = 999;    /* Undefined */
	end;
	
/*----------- Marital Status -----------------------------------------------------------------*/
	
	if spmarsta = .  | spmarsta = .N | 
	   spmarsta = .R | spmarsta = .D                then maristat = .;   /* Missing */
	else if spmarsta = 1							then maristat = 1; 	 /* Married */
	else if spmarsta = 2							then maristat = 2; 	 /* Widowed */
	else if spmarsta in (3,4)						then maristat = 3;	 /* Divorced or Separated */
	else if spmarsta = 5							then maristat = 4;	 /* Never Married */
	else                                                 maristat = 999; /* Undefined */
	
/*----------- Education ----------------------------------------------------------------------*/
	
	if spdegrcv = .  | spdegrcv = .N | 
	   spdegrcv = .R | spdegrcv = .D                then educlev2 = .;   /* Missing */
	else if spdegrcv in (1,2,3)						then educlev2 = 1;   /* Less than HS diploma */
	else if spdegrcv = 4							then educlev2 = 2;   /* HS Graduate */
	else if spdegrcv in (5,6,7)						then educlev2 = 3;   /* Some College/Vocational School */
	else if spdegrcv in (8,9)						then educlev2 = 4;   /* Bachelor's Degree and Beyond */ 
	else                                                 educlev2 = 999; /* Undefined */

/*-----------Mortality---------------------------------------------------------------------------------*/

	if h_dod = . 							then death = 0 ;			/* Deceased */
	else if h_dod ^= . 						then death = 1 ;			/* Alive */
	else                                         death = 999;           /* Undefined */

/*----------- Veteran Status------------------------------------------------------------------*/
	
	if spafever = .  | spafever = .N | 
	   spafever = .R | spafever = .D                then veteran = .;   /* Missing */
	else if spafever = 1							then veteran = 1;	/* Yes */
	else if	spafever = 0							then veteran = 0;	/* No */
	else                                                 veteran = 999; /* Undefined */

/*----------- Interview Type------------------------------------------------------------------*/
	
	if int_type = " " 						then resista3 = .;   /* Missing */
	else if upcase(int_type) = 'C'			then resista3 = 1;   /* Community */
	else if upcase(int_type) = 'F'			then resista3 = 2;   /* Facility */
	else if upcase(int_type) = 'B'			then resista3 = 3;   /* Community and Facility */
	else                                         resista3 = 999; /* Undefined */


	/* Special Populations Identifiers */
	if resista3 in (1,3) 					then intvtype2 = "COMM OR BOTH";
	if resista3 = 2 						then intvtype2 = "FACILITY";
	if resista3 in (1,3) and gender = 2 	then intvtype3= "COMM OR BOTH FEMALES";
	if resista3 = 1 						then intvtype4= "COMM";
	
	/* Community-only Flag */
	if resista3 = .							then community_char = .;
	else if resista3 = 1 					then community_char = 1;
	else if resista3 in (2,3)				then community_char = 0;
	else                                         community_char = 999;

/*----------- Limited English Proficiency---------------------------------------------------------------*/
	
	if ENGWELL = .  | ENGWELL = .N | 
	   ENGWELL = .R | ENGWELL = .D                  then lep = .;   /* Missing */
	else if ENGWELL in (2:4) 						then lep = 1;   /* LEP */
	else if ENGWELL = 1								then lep = 0;   /* Not LEP */
	else 												 lep = 999; /* Undefined */

/*-----------Language Other than English Spoken at Home-------------------------------------------*/
	
	if OTHRLANG = .  | OTHRLANG = .N | 
	   OTHRLANG = .R | OTHRLANG = .D                then otherlang = .;   /* Missing */
	else if OTHRLANG = 1 							then otherlang = 1;   /* Yes */
	else if OTHRLANG = 2 							then otherlang = 0;   /* No */
	else                                                 otherlang = 999; /* Undefined */

/*--------------------Poverty Level---------------------------------------------------------------*/
	
	if ipr = .  | ipr = .N | 
	   ipr = .R | ipr = .D                 		   then poverty5 = .;    /* Missing */
    else if ipr <= 1.00                            then poverty5 = 1;    /* <=100% of the Federal Poverty Level */   
	else if 1.00 < ipr <= 1.20                     then poverty5 = 2;    /* >100% and <=120% of the Federal Poverty */ 
    else if 1.20 < ipr <= 1.35                     then poverty5 = 3;    /* >120% and <=135% of the Federal Poverty */ 
    else if 1.35 < ipr <= 2.00                     then poverty5 = 4;    /* >135% and <=200% of the Federal Poverty */ 
    else if ipr > 2.00                             then poverty5 = 5;    /* >200% of the Federal Poverty Level */
	else                                                poverty5 = 999;  /* Undefined */

/*----------- Income -------------------------------------------*/

if income = .  | income = .N | 
   income = .R | income = .D       then beneinc = .;   /* Missing */
else if income in (1:5)            then beneinc = 1;   /* Less than $25,000 */  
else if income in (6:8)            then beneinc = 2;   /* $25,000-$49,999 */ 
else if income in (9:11)           then beneinc = 3;   /* $50,000-$99,999 */
else if income in (12:14)          then beneinc = 4;   /* $100,0000 + */       
else                              	    beneinc = 999; /* Undefined */

/*---------------------------------------------------------------------------------*/
/*----------- 2020 SPECIAL FEATURE: Area Deprivation Index (ADI) ------------------*/
/*---------------------------------------------------------------------------------*/

if ADINATNL = . or ADINATNL = .S 		then ADIcat = .;    /* Missing */
else if ADINATNL <= 25 					then ADIcat = 1;    /* 1 – 25th percentile */
else if 26 <= ADINATNL <= 50 			then ADIcat = 2;    /* 26 – 50th percentile */
else if 51 <= ADINATNL <= 75 			then ADIcat = 3;    /* 51 – 75th percentile */
else if ADINATNL >= 76 					then ADIcat = 4;    /*76 – 100th percentile */
else 										 ADIcat = 999; 	/* Undefined */



