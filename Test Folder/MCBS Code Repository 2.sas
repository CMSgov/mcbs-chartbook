/******************************************************************************************************/
/*** CODE: Demographics of Medicare Beneficiaries                  				      	            ***/																		
/*** OBJECTIVE: Create demographic measures using LDS segments                                     ***/
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



/******************************************************************************************************/
/*** CODE: Health Status and Chronic Conditions                  					                ***/
/*** OBJECTIVE: Create health status and chronic condition measures using LDS segments.             ***/                                                                    
/******************************************************************************************************/

/* COMMUNITY BENEFICIARIES */
data limitations;
	merge survey.demo survey.nagidis survey.vishear;
	by baseid;
run;

/*Count of disabilities*/
data tempf.limitations2;
	set limitations;
	by baseid;

	array dis6 8. dishear dissee disdecsn diswalk disbath diserrnd;

	count = 0;
	do over dis6; /* Iterate over variables to count */
		if dis6 = 1 						  then count + 1;
	end;

	misscount = 0;
	do over dis6;
		if dis6 = .  | dis6 = .N | 
	   	   dis6 = .R | dis6 = .D   then misscount + 1;   /* Count Missing */
	end;

	if int_type = 'F' 		   then disab = 3;		/* LTC Facility */
	else do;
		if misscount = 6       then disab = .;      /* Missing */
		else if count = 0      then disab = 0;		/* No Disability */
		else if count = 1      then disab = 1;		/* 1 Disability */
		else if count in (2:6) then disab = 2;		/* 2 or More Disabilities */
		else 						disab = 999;    /* Undefined */
	end;
							
run;

/*Merge mental health data to create cognitive impairment measure later*/
data nagidisc;
	merge survey.menthlth tempf.limitations2;
	by baseid;
run;

/*Create measures of disability*/
data tempf.nagidisc;
	set nagidisc;

	/*---- Upper Extremity Limitation -----------------------------------------------------------*/
    if difreach = 1 and difwrite = 1 								then ulimit = 0; /* No difficulty reaching above shoulder or writing - No upper extremity limitation */
       else if (difreach = .  | difreach = .N | 
	   			difreach = .R  | difreach = .D | difreach = 1) AND
	   		   (difwrite = .  | difwrite = .N | 
	   			difwrite = .R  | difwrite = .D | difwrite = 1)      then ulimit = .;   /* Missing */
       else if (difreach in (2,3,4,5) or difwrite in (2,3,4,5)) then do; /* Yes upper extremity limitation with no disability */
			if disab = 0 				    						then ulimit = 1;
				else if disab > 0 		    						then ulimit = 2;  /* Yes upper extremity limitation with any disability */
       end;
       else                                        						 ulimit = 999;

	/*---- Mobility Limitation -------------------------------------------------------------------*/
    if ( difwalk = .  | difwalk = .N | 
	    difwalk = .R  | difwalk = .D )   then mlimit = .; /* Missing */
    else if difwalk = 1 				 then mlimit = 0; /* No difficulty walking - No mobility limitation */
		else if difwalk in (2,3,4,5)     then do ; /* Yes mobility limitation with no disability */
			if disab = 0 			     then mlimit = 1;
				else if disab > 0        then mlimit = 2; /* Yes mobility limitation with any disability */
        end;
    else                                  mlimit = 999;   /* Undefined */

	/*----------- Cognitive Impairment -----------------------------------------------------------*/
	if (disdecsn = .  | disdecsn = .N | 
	   disdecsn = .R  | disdecsn = .D) AND
	   (phqtrcon = .  | phqtrcon = .N | 
	   phqtrcon = .R  | phqtrcon = .D)              then cogimp = .;   /* Missing */
	else if disdecsn = 1 or phqtrcon in (3:4) 		then cogimp = 1;   /* Cognitively Impaired */
	else if disdecsn = 2 or phqtrcon in (1:2)       then cogimp = 0;   /* Not Cognitively Impaired */
	else                                                 cogimp = 999; /* Undefined */
	
	/*----------- Exercise/Activity Level --------------------------------------------------------*/
	if (d_vigtim = .  | d_vigtim = .N | 
	   d_vigtim = .R  | d_vigtim = .D) AND
	   (d_modtim = .  | d_modtim = .N | 
	   d_modtim = .R  | d_modtim = .D)              	then active = .;    /* Missing */
	else if d_vigtim ge 3 or d_modtim ge 5				then active = 3; 	/* Highly Active */
	else if d_vigtim eq 2 or d_modtim in (3 4)			then active = 2;	/* Active */
	else if d_vigtim in (0 1) or d_modtim in (0, 1, 2)	then active = 1;	/* Sedentary */
	else                                                     active = 999;  /* Undefined */
	
run;

data tempf.genhlthc;
	set survey.genhlth;

	/*----------- Perceived Health Status --------------------------------------------------------*/
	/* General Health (4 Category) */
	if ( genhelth = .  | genhelth = .N | 
	     genhelth = .R  | genhelth = .D )   then health1 = .;   /* Missing */
	else if genhelth = 1				    then health1 = 1;	/* Excellent */
	else if genhelth = 2					then health1 = 2;	/* Very Good */
	else if genhelth = 3					then health1 = 3;	/* Good */
	else if genhelth = 4					then health1 = 4;	/* Fair */
	else if genhelth = 5					then health1 = 5;	/* Poor */
	else                                         health1 = 999; /* Undefined */

	/* General Health (2 Category) */
	if ( genhelth = .  | genhelth = .N | 
	     genhelth = .R  | genhelth = .D )   then health2 = .;   /* Missing */
	else if genhelth in (1:3)				then health2 = 1;	/* Excellent/Very Good/Good */
	else if genhelth in (4,5)				then health2 = 2;	/* Fair/Poor */
	else                                         health2 = 999; /* Undefined */
run;

data tempf.chrncondc;
	set survey.chrncond;

/*----------- Percent of Beneficiaries with Medical Conditions -------------------------------*/

	/* Heart Disease */
	if ocmyocar = 1 or occhd = 1 or occfail = 1	or ochrtcnd = 1			then heartdis = 1;	/* Yes */
	else if ocmyocar = 2 and occhd = 2 and occfail = 2 and ochrtcnd = 2	then heartdis = 0;	/* No */

	/* Hypertension */
	if ochbp = 1							then hyperten = 1;	/* Yes */
	else if ochbp = 2						then hyperten = 0;	/* No */

	/* Diabetes */
	if ocbetes = 1							then diabetes = 1;	/* Yes */
	else if	ocbetes = 2						then diabetes = 0;	/* No */

	/* REMOVED: OCOSARTH and OCARTHOT removed in 2019 */

	/* Arthritis */
	*if ocarthrh = 1 or ocosarth = 1 or ocarthot = 1			then arthrits = 1;	/* Yes */
	*else if ocarthrh = 2 and ocosarth = 2 and ocarthot = 2	then arthrits = 0;	/* No */

	/* Osteoporosis/Broken Hip */
	if ocosteop = 1 or ocbrkhip = 1			then ostoporo = 1;	/* Yes */
	else if ocosteop = 2 and ocbrkhip = 2	then ostoporo = 0;	/* No */

	/* Pulmonary Disease */
	if ocemphys = 1							then pulmodis = 1;	/* Yes */
	else if ocemphys = 2					then pulmodis = 0;	/* No */

	/* Stroke */
	if ocstroke = 1							then stroke = 1;	/* Yes */
	else if ocstroke = 2					then stroke = 0;	/* No */

	/* Alzheimer's Disease*/
	if ocalzmer = 1 						then alzheimr = 1;	/* Yes */
	else if ocalzmer = 2 					then alzheimr = 0;	/* No */

	/* Non-Alzheimer's Dementia */
	if ocdement = 1							then dementia = 1;  /* Yes */
	else if ocdement = 2					then dementia = 0;  /* No */

	/* Parkinson's Disease*/
	if ocparkin = 1							then parkinsn = 1;	/* Yes */
	else if ocparkin = 2					then parkinsn = 0;	/* No */

	/* Skin Cancer */
	if occskin = 1							then skincanc = 1;	/* Yes */
	else if occskin = 2						then skincanc = 0;	/* No */

	/* Cancer, other than skin */
	if occancer = 1							then oth_canc = 1;	/* Yes */
	else if occancer = 2					then oth_canc = 0;	/* No */

/*----------- Mental Condition ---------------------------------------------------------------*/
	if ocpsycho = 1 or ocdeprss = 1			then mental = 1 ;	/* Yes */
	else if ocpsycho = 2 and ocdeprss = 2	then mental = 0 ; 	/* No */

/*----------- Intellectual or Developmental Disasbility --------------------------------------*/
*Proposed new measure in 2017;
	if ocmental = 1							then IDD = 1 ;	/* Yes */
	else if ocmental = 2					then IDD = 0 ; 	/* No */

/*----------- Urinary Incontinence -----------------------------------------------------------*/
	if losturin in (1:5)					then urinary = 1;	/* Yes */
	else if losturin in (6:7)				then urinary = 0;	/* No */

/*----------- High Cholesterol ---------------------------------------------------------------*/
	if occholes = 1							then cholest = 1;	/* Yes */
	else if occholes = 2					then cholest = 0;	/* No */

/*----------- Hysterectomy -------------------------------------------------------------------*/
	if hysterec = 1							then hyst = 1;		/* Yes */
	else if hysterec = 2					then hyst = 0; 		/* No */

/*----------- Depression ---------------------------------------------------------------------*/
	if ocdeprss = 1 						then depres = 1;
	else if ocdeprss = 2 					then depres = 0;
run;

/*------------------------ Health Behaviors --------------------------------------------------*/

data nicoalco;
	merge intermed.demographics survey.nicoalco;
	by baseid;
run;

data tempf.nicoalcoc;
	set nicoalco;

	keep  baseid drink smoker;  
	length drink smoker 3;

/*----------- Alcohol Use --------------------------------------------------------------------*/
	if   (alcday = .  | alcday = .N | 
	      alcday = .R  | alcday = .D) AND 		
	      (alc12mn = .  | alc12mn = .N | 
	      alc12mn = .R  | alc12mn = .D) AND		
	      (alclife = .  | alclife = .N | 
	      alclife = .R  | alclife = .D)	        then drink = .;   /* Missing */
	else if alclife = 2                         then drink = 0;   /*Does Not Drink*/
	else if alclife in(1,.,.N,.R,.D) then do;
		if alc12mn = 0                     		then drink = 0;   /*Does Not Drink*/	
		else if gender = 1 and alcday in (1:2)  then drink = 1;	  /*Moderate*/
		else if gender = 1 and alcday gt 2      then drink = 2;   /*Heavy*/
		else if gender = 2 and alcday eq 1      then drink = 1;	  /*Moderate*/
		else if gender = 2 and alcday gt 1      then drink = 2;	  /*Heavy*/
	end;
	else 										     drink = 999; /* Undefined */									    

/*----------- Smoking Status ----------------------------------------------------------------*/
	if (cignow = .  | cignow = .N | 
	   cignow = .R  | cignow = .D) AND
	   (cigarnow = .  | cigarnow = .N | 
	   cigarnow = .R  | cigarnow = .D) AND  
	   (cigarone = .  | cigarone = .N | 
	   cigarone = .R  | cigarone = .D) AND
	   (cigar50  = .  | cigar50 = .N | 
	   cigar50 = .R  | cigar50 = .D) AND 
	   (cig100  = .  | cig100 = .N | 
	   cig100 = .R  | cig100 = .D)								  then smoker = .; /* Missing */
	else if cignow in (1:2) or cigarnow in (1:2) 				  then smoker = 2; /* Current Smoker */
	else if cig100 = 1 or cigar50 = 1       				 	  then smoker = 1; /* Former Smoker */
	else if cig100 = 2 or (cigar50 = 2  or cigarone in (1:2))     then smoker = 0; /* Non-smoker */
	else if (cig100 not in (1:2) and cigar50 not in (1:2)) and 
			(cignow = 3 or cigarnow = 3) 						  then smoker = 0; /* Non-smoker */
	else                                                               smoker = 999; /* Undefined */
	
run;

data tempf.vishearc;
	set survey.vishear;

/*----------- Hearing Trouble-----------------------------------------------------------------*/
	if (hchelp = .  | hchelp = .N |
        hchelp = .R  | hchelp = .D) and
 	   (hctroub = .  | hctroub = .N |
 	    hctroub = .R  | hctroub = .D) 							   then hearingprob = .;   /* Missing */
	else if hchelp in (1, 3) or hctroub ge 2 					   then hearingprob = 1;   /* Yes */
	else if hchelp in (.,.N,.D,.R,2) and hctroub in (.,.N,.D,.R,1) then hearingprob = 0;   /* No */
	else 															    hearingprob = 999; /* Undefined */


/*----------- Vision Problem------------------------------------------------------------------*/
	if (echelp = .  | echelp = .N | echelp = .R  | echelp = .D) AND
	   (ectroub = .  | ectroub = .N | ectroub = .R  | ectroub = .D) AND
	   (eclegbli = .  | eclegbli = .N | eclegbli = .R  | eclegbli = .D) AND
	   (ecatarac = .  | ecatarac = .N | ecatarac = .R  | ecatarac = .D) AND
	   (eglaucom = .  | eglaucom = .N | eglaucom = .R  | eglaucom = .D) AND
	   (eretinop = .  | eretinop = .N | eretinop = .R  | eretinop = .D) AND
	   (emacular = .  | emacular = .N | emacular = .R  | emacular = .D)       then visionprob = .;	  /* Missing */                         
	else if echelp in (1, 3) or ectroub ge 2 or eclegbli = 1 or ecatarac = 1 or 
	        eglaucom = 1 or eretinop = 1 or emacular = 1	                  then visionprob = 1;	  /* Yes */
	else if echelp in (.,.N,.D,.R,2) and ectroub in (.,.N,.D,.R,1) and 
			eclegbli in (.,.N,.D,.R,2) and ecatarac in (.,.N,.D,.R,2) and 
	        eglaucom in (.,.N,.D,.R,2) and eretinop in (.,.N,.D,.R,2) and 
	        emacular in (.,.N,.D,.R,2)	                  					  then visionprob = 0;	  /* No */
	else                                                                           visionprob = 999;  /* Undefined */
run;

/*----------- Preventive Care ---------------------------------------------------------------*/

data tempf.prevcarec;
	set survey.prevcare;

/*----------- Flu Shot -----------------------------------------------------------------------*/
	if ( flushot = .  | flushot = .N | 
	     flushot = .R  | flushot = .D )     then flu = .;   /* Missing */ 
	else if flushot = 1						then flu = 1;	/* Yes */
	else if flushot = 2						then flu = 0;	/* No */
	else                                         flu = 999; /* Undefined */

/*----------- Pneumonia Vaccine --------------------------------------------------------------*/
	if ( pneushot = .  | pneushot = .N | 
	     pneushot = .R  | pneushot = .D )   then pneu = .;   /* Missing */ 
	else if pneushot = 1					then pneu = 1;   /* Yes */
	else if pneushot = 2					then pneu = 0;	 /* No */
	else                                         pneu = 999; /* Undefined */

/*----------- Shingles Vaccine ---------------------------------------------------------------*/
	if ( shingvac = .  | shingvac = .N | 
	     shingvac = .R  | shingvac = .D )   then shingles = .;      /* Missing */
	else if shingvac = 1					then shingles = 1;	    /* Yes */
	else if shingvac = 2					then shingles = 0;	    /* No */
	else                                         shingles = 999;    /* Undefined */

/*----------- Mammogram ----------------------------------------------------------------------*/
	if ( mammogrm = .  | mammogrm = .N | 
	     mammogrm = .R  | mammogrm = .D )   then mammogram = .;   /* Missing */
	else if mammogrm = 1					then mammogram = 1;	  /* Yes */
	else if mammogrm = 2					then mammogram = 0;	  /* No */
	else                                         mammogram = 999; /* Undefined */

/*----------- Blood Pressure Screening -------------------------------------------------------*/
	if ( bptaken = .  | bptaken = .N | 
	     bptaken = .R  | bptaken = .D )     then bloodpress = .;    /* Missing */
	else if bptaken in (1, 2)				then bloodpress = 1;	/* Yes */
	else if bptaken in (3, 4, 5, 6)			then bloodpress = 0;	/* No */
	else                                         bloodpress = 999;  /* Undefined */
run;

/* FACILITY BENEFICIARIES */

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

	/* Depression */
	if ( DEPRESS = .  | DEPRESS = .N | 
	     DEPRESS = .R  | DEPRESS = .D )   then DEPRES = .;   /* Missing */
	else If DEPRESS in (1:2) 				  then DEPRES = 1;   /* Depressed */ 
	Else if DEPRESS = 0 			      then DEPRES = 0;   /* Not Depressed */
	Else                                       DEPRES = 999; /* Undefined */

/*----------- Perceived Health Status --------------------------------------------------------*/

    /* General Health (5-Category) */
	if ( sphealth = .  | sphealth = .N | 
	     sphealth = .R  | sphealth = .D )   then health1 = .;   /* Missing */
	else if sphealth = 0					then health1 = 1;	/* Excellent */
	else if sphealth = 1					then health1 = 2;	/* Very Good */
	else if sphealth = 2					then health1 = 3;	/* Good */
	else if sphealth = 3					then health1 = 4;	/* Fair */
	else if sphealth = 4					then health1 = 5;	/* Poor */
	else                                         health1 = 999; /* Undefined */

	/* General Health (2-Category) */
	if ( sphealth = .  | sphealth = .N | 
	     sphealth = .R  | sphealth = .D )   then health2 = .;   /* Missing */
	else if sphealth in (0:2)				then health2 = 1;	/* Excellent/Very Good */
	else if sphealth in (3,4)				then health2 = 2;	/* Fair/Poor */
	else                                         health2 = 999; /* Undefined */

/*---- Upper Extremity Limitation -------------------------------------------------------------------*/

	if difreach = 0 AND difwrite = 0 							  	  then ulimit = 0;   /* No limitation */
	else if (difreach = .  | difreach = .N | 
	   		 difreach = .R  | difreach = .D | difreach = 0) AND
	   		(difwrite = .  | difwrite = .N | 
	   		 difwrite = .R  | difwrite = .D | difwrite = 0)           then ulimit = .;   /* Missing */ 
	else if difreach in (1:4) or difwrite in (1:4)                    then ulimit = 2;   /* Yes with any disability */
	else                                                                   ulimit = 999; /* Undefined */

/*---- Mobility Limitation --------------------------------------------------------------------------*/
	if ( DIFWALK = .  | DIFWALK = .N | 
	     DIFWALK = .R  | DIFWALK = .D )      then MLIMIT = .;   /* Missing */
	else if DIFWALK = 0                      then MLIMIT = 0;   /*No limitation*/
	else if DIFWALK in (1, 2, 3, 4)          then MLIMIT = 2;   /* Yes with any disability */
	else                                          MLIMIT = 999; /* Undefined */


/*----------- Prevelance of Chronic Conditions ---------------------------------------*/

	/* Heart Disease */
	if (myocard = .  | myocard = .N | myocard = .R  | myocard = .D) AND
	   (hartfail = .  | hartfail = .N | hartfail = .R  | hartfail = .D) AND
	   (corartds = .  | corartds = .N | corartds = .R  | corartds = .D) AND
	   (afibdys = .  | afibdys = .N | afibdys = .R  | afibdys = .D) AND	
	   (aosten = .  | aosten = .N | aosten = .R  | aosten = .D)                   			 then heartdis = .;   /* Missing */
	else if myocard ge 1 or hartfail ge 1 or corartds ge 1 or afibdys ge 1 or aosten ge 1    then heartdis = 1;   /* Yes */
	else if myocard in (.,.N,.D,.R,0) and hartfail in (.,.N,.D,.R,0) and
	        corartds in (.,.N,.D,.R,0) and afibdys in (.,.N,.D,.R,0) and 
	        aosten in (.,.N,.D,.R,0)                                                 		 then heartdis = 0;   /* No */
	else                                                                                   		  heartdis = 999; /* Undefined */
	*if myocard in (1,2) or hartfail in (1,2) or corartds in (1,2) or afibdys in (1,2) or aosten = 1 then heartdis = 1; /* Yes */	
	*else if myocard = 0 and hartfail = 0 and corartds  = 0 and afibdys = 0  and aosten = 0 then heartdis = 0; /* No */

	/* Hypertension */
  	if hypetens in (1,2)							then hyperten = 1;	/* Yes */
 	else if hypetens = 0							then hyperten = 0;	/* No */

	/* High Cholesterol */
  	if hyprlipi = 1									then cholest = 1;	/* Yes */
 	else if hyprlipi = 0							then cholest = 0;	/* No */

	/* Diabetes */
	if diabmrn in (1,2)								then diabetes = 1;	/* Yes */
	else if diabmrn = 0								then diabetes = 0;	/* No */

	/* Arthritis */
	*if arthrit = 1 or osarth = 1 or gout = 1		then arthrits = 1;	/* Yes */
	*else if arthrit = 0	and osarth = 0 and gout = 0	then arthrits = 0;	/* No */

	/* Osteoporosis/Broken Hip */
	if osteop in (1,2) or hipfract in (1,2)			then ostoporo = 1;	/* Yes */
	else if osteop = 0 and hipfract = 0				then ostoporo = 0;	/* No */

	/* Pulmonary Disease */
	if asthcopd in (1, 2)							then pulmodis = 1;	/* Yes */
	else if asthcopd = 0							then pulmodis = 0;	/* No */

	/* Stroke */
	if cvatiast in (1,2)							then stroke = 1;	/* Yes */
	else if cvatiast = 0							then stroke = 0;	/* No */

    /* Alzheimer's Disease */
	if alzhmr in (1,2) 								then alzheimr = 1;	/* Yes */
	else if alzhmr = 0 								then alzheimr = 0;	/* No */

	/* Non-Alzheimer's Dementia */
	if dement in (1,2) 								then dementia = 1; /* Yes */
	else if dement = 0								then dementia = 0; /* No */

	/* Parkinson's Disease */
	if parknson in (1,2) 							then parkinsn = 1;	/* Yes */
	else if parknson = 0 							then parkinsn = 0;	/* No */

	/* Skin Cancer */
	if cnrskin = 1									then skincanc = 1;	/* Yes */
	else if cnrskin = 0								then skincanc = 0;	/* No */

	/* Cancer, other than skin */
	if cancer in (1,2)								then oth_canc = 1;	/* Yes */
	else if cancer = 0								then oth_canc = 0;	/* No */

/*----------- Mental Condition --------------------------------------------------------------*/
	/* REMOVED: D_MENTAL removed in 2019 */
	
	if manicdep in (1,2) or schizoph in (1,2) or depress in (1,2) or psycotic in (1,2) or anxiety = 1 
		or ptsd in (1,2) or apsych = 1 or delus = 1 then mental = 1;	/* Yes */
	else if manicdep = 0 and schizoph = 0 and depress = 0 and psycotic = 0 and anxiety = 0 and ptsd = 0
		and apsych = 0 and delus = 0 								then mental = 0;	/* No */

/*----------- Intellectual or Developmental Disability --------------------------------------*/
	if ( mentdown = .  | mentdown = .N | 
	     mentdown = .R  | mentdown = .D ) AND
	     ( mentauti = .  | mentauti = .N | 
	     mentauti = .R  | mentauti = .D ) AND
	     ( mentotho = .  | mentotho = .N | 
	     mentotho = .R  | mentotho = .D ) AND
	     ( mentothn = .  | mentothn = .N | 
	     mentothn = .R  | mentothn = .D )		               		  then IDD = .;   /* Missing */
	else if mentdown = 1 or mentauti = 1 or
	        mentotho = 1 or mentothn = 1                              then IDD = 1;  
	else if mentdown in (0,.N,.D,.) and mentauti in (0,.N,.D,.) and					
		    mentotht in (0,.N,.D,.) and mentothn in (0,.N,.D,.) 	  then IDD = 0;	/* Yes */
	else                                                            	   IDD = 999; /* Undefined */

/*----------- Urinary Incontinence -----------------------------------------------------------*/
	if ( ctbladdc = .  | ctbladdc = .N | ctbladdc = 4 |
	     ctbladdc = .R  | ctbladdc = .D )  	    then urinary = .;   /* Missing */
	else if ctbladdc in (2:3)					then urinary = 1;	/* Yes */
	else if ctbladdc in (0:1)					then urinary = 0;	/* No */
	else                                             urinary = 999; /* Undefined */

/*----------- Smoking Status -----------------------------------------------------------------*/
	if ( d_smoke = .  | d_smoke = .N | 
	     d_smoke = .R  | d_smoke = .D ) AND
	   ( nowsmoke = .  | nowsmoke = .N | 
	     nowsmoke = .R  | nowsmoke = .D )   then smoker = .;    /* Missing */
	else if d_smoke = 0						then smoker = 0;	/* Non-smoker */
	else if d_smoke = 1 & nowsmoke ^= 1		then smoker = 1;	/* Former Smoker */
	else if nowsmoke = 1					then smoker = 2;	/* Current Smoker */
	else                                         smoker = 999;  /* Undefined */

/*----------- Cognitive Impairment ------------------------------------------------------------*/
	cogimp_ability = 0;
	if csmemst = 1 then cogimp_ability + 1;
	if csmemlt = 1 then cogimp_ability + 1;
	if cscursea = 0 then cogimp_ability + 1;
	if cslocrom = 0 then cogimp_ability + 1;
	if csnamfac = 0 then cogimp_ability + 1;
	if csinnh = 0 then cogimp_ability + 1;
	if hcuncond in (2,3) then cogimp_ability + 1;
	if hcundoth in (2,3) then cogimp_ability + 1;
	if csdecis in (2,3) then cogimp_ability + 1;

	cogimp_dx = 0;
	if aphasia = 1 then cogimp_dx + 1;

	if mentsum in (0:12) or cogimp_ability ge 1 or cogimp_dx = 1 then cogimp = 1;	/* Yes */
		else cogimp = 0;	/* No */

/*----------- Hearing Trouble -----------------------------------------------------------------*/
	if ( hcheaid = .  | hcheaid = .N |
         hcheaid = .R  | hcheaid = .D ) and 
   	   ( hchecond = .  | hchecond = .N |
         hchecond = .R  | hchecond = .D ) 						      then hearingprob = .;   /* Missing */
	else if hcheaid = 1 or hchecond ge 1 							  then hearingprob = 1;	  /* Yes */
	else if hcheaid in (.,.N,.D,.R,0) and hchecond in (.,.N,.D,.R,0)  then hearingprob = 0;   /* No */
	else                                                                   hearingprob = 999; /* Unknown */						/* Undefined */


/*----------- Vision Problem ------------------------------------------------------------------*/
	if (visappl = .  | visappl = .N | visappl = .R  | visappl = .D) AND
	   (vision = .  | vision = .N | vision = .R  | vision = .D) AND
	   (blind = .  | blind = .N | blind = .R  | blind = .D) AND
	   (catglauc = .  | catglauc = .N | catglauc = .R  | catglauc = .D) AND	
	   (catarop = .  | catarop = .N | catarop = .R  | catarop = .D)                   then visionprob = .;   /* Missing */
	else if visappl = 1 or vision ge 1 or blind = 1 or catglauc = 1 or catarop = 1    then visionprob = 1;   /* Yes */
	else if visappl in (.,.N,.D,.R,0) and vision in (.,.N,.D,.R,0) and
	        blind in (.,.N,.D,.R,0) and catglauc in (.,.N,.D,.R,0) and 
	        catarop in (.,.N,.D,.R,0)                                                 then visionprob = 0;   /* No */
	else                                                                                   visionprob = 999; /* Undefined */

/*----------- Mammogram ------------------------------------------------------------------------*/
	if ( mammogr = .  | mammogr = .N | 
	     mammogr = .R  | mammogr = .D )     then mammogram = .;   /* Missing */
	else if mammogr = 1						then mammogram = 1;	  /* Yes */
	else if mammogr = 0						then mammogram = 0;	  /* No */
	else                                         mammogram = 999; /* Undefined */

/*----------- Hysterectomy ---------------------------------------------------------------------*/
	if ( d_hyst = .  | d_hyst = .N | 
	     d_hyst = .R  | d_hyst = .D )     then hyst = .;   /* Missing */
	else if d_hyst = 1					  then hyst = 1;   /* Yes */
	else if d_hyst = 0					  then hyst = 0;   /* No */
	else                                       hyst = 999; /* Undefined */

run;

/*Merge Community Chronic Condition Data*/
data tempf.diseasec;
	merge tempf.nagidisc tempf.genhlthc tempf.chrncondc tempf.nicoalcoc tempf.vishearc tempf.prevcarec /*tempf.covidfal*/;
	by baseid;
run;

/*Merge Facility and Community Data*/
data intermed.disease;
	set tempf.diseasef (in = f) tempf.diseasec;
	by baseid;

	/* Create flag for benes that did not answer any chronic conditions Q's, so denominator can be restricted during Tableau file construction */
	if heartdis not in (0,1) and alzheimr not in (0,1) /*and arthrits not in (0,1)*/
	and diabetes not in (0,1) and hyperten not in (0,1) and depres not in (0,1)
	and ostoporo not in (0,1) and oth_canc not in (0,1) and pulmodis not in (0,1)
	and stroke not in (0,1) and cholest not in (0,1) and dementia not in (0,1)
	and mental not in (0,1) and parkinsn not in (0,1) then mischron = 1;

	/*Because data is brought forward (it is possible for someone to have ever been diagnosed with both Alzheimer's and non-Alzheimer's dementia), we should count this as one chronic condition*/
	if alzheimr = 1 or dementia = 1 then dmntcount = 1; 
	else dmntcount = 0; 

	/*Because the Chartbook definition of mental condition contains depression, perform the next step to avoid double counting beneficiaries for the same condition*/
	if depres = 1 or mental = 1 then mentcount = 1; 
	else mentcount = 0; 

	array oc 3 heartdis /*arthrits*/ diabetes hyperten ostoporo oth_canc pulmodis stroke cholest dmntcount parkinsn mentcount;

/*----------- Number of Chronic Conditions -----------------------------------------------------*/
	count = 0;

	do over oc;
		if (oc = 1) then
			count + 1;
	end;

	/* Revised Chronic Condition Tabulation (1, 2-3, 4-5, 6+) */
	if mischron = 1                         then numccon3 = .;
	else if count = 0                       then numccon3 = 0;  /* 0 */
	else if count = 1                       then numccon3 = 1;  /* 1 */
	else if count in (2,3) 					then numccon3 = 2;	/* 2-3 */
	else if count in (4,5)					then numccon3 = 3;	/* 4-5 */
	else if count >= 6					    then numccon3 = 4;	/* 6+ */

	/*Flag whether in facility; see adjudication between Community and Facility data (where both available) below*/

	if f = 1 then type = 1;
	else type = 2;
		
run;

/* Pull benes with community & facility data into one dataset and benes with ONLY facility or community data into another */
data tempf.disease_dup;
 set intermed.disease;
 	by baseid;
	if ^(first.baseid & last.baseid);
run;

data tempf.disease_nodup;
 set intermed.disease;
	by baseid;
	if first.baseid & last.baseid;
run;

/* Copy the disability status flag from the community data to the facility data to prevent data loss during adjudication */
PROC SQL;
CREATE TABLE tempf.disease_dup_adj AS 
  SELECT *, 
         Max(disab) AS DISAB_1 
  FROM   tempf.disease_dup 
  GROUP  BY baseid; 

CREATE TABLE tempf.disease_corr_rec AS 
  SELECT * 
  FROM   tempf.disease_dup_adj(drop = disab rename=(disab_1 = disab));
QUIT;

/* Remerge the corrected 'duplicate' benes with the unique benes */
data intermed.disease;
	set tempf.disease_corr_rec tempf.disease_nodup;
run;

/*If respondent is in both community and facility, then the facility data is used*/
proc sort data = intermed.disease;
	by baseid type;
run;

data intermed.disease;
	set intermed.disease;
	by baseid type;
	drop type;
	if first.baseid;
run;




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



/******************************************************************************************************/
/*** CODE: Insurance Coverage                  					                                    ***/
/*** OBJECTIVE: Create insurance coverage measures using LDS segments.                              ***/
/******************************************************************************************************/

data tempf.hisumry2;
	set survey.hisumry;
run;

/*Merge Hitline with demo file to get INT_TYPE. This will be used in logic to flag insurance*/
proc sql;
	create table hitline_inttype as
		select L.*, R.INT_TYPE
		from survey.hitline as L left outer join intermed.demographics as R
		on L.BASEID = R.BASEID; 
quit;

/*Create indicator variables COVERED01-COVERED12 to indicate coverage*/
data hitlinetemp;
	set hitline_inttype;
	array srccov [12] srccov01-srccov12;
	array covered [12] covered01-covered12;

	do i = 1 to 12;
		if srccov[i] in (2,3) then covered[i] = 1;
		else covered[i] = 0;
	end;

	*2017 UPDATE: PlanType and Insurance Coverage Plan are now flagged in the HITLINE segment rather than HISUMRY;
 
	* Any Employer-Sponsored Insurance (Line-Item Level);
	if plantype in (20, 21) and s_othpln not in(1, 3, 4) then esiany_t = 1; /* Yes */
	else                                                       esiany_t = 0; /* No */

	* Employer-Sponsored Insurance w/ Comprehensive Coverage (Line-Item Level);
	if esiany_t = 1 and (S_MSCOV = 1 or S_IP = 1 or S_COVNH = 1) then esigen_t = 1; /* Yes */
    else                                                                 esigen_t = 0; /* No */

	* Any Self-Pay Insurance (Line-Item Level);
	If plantype in (30, 31) and s_othpln not in(1, 3, 4) then selfany_t = 1; /* Yes */
	else										               selfany_t = 0; /* No */

	* Self-Pay Insurance w/ Comprehensive Coverage (Line-Item Level);
	if selfany_t = 1 and (S_MSCOV = 1 or S_IP = 1 or S_COVNH = 1) then selfgen_t = 1; /* Yes */
	else										                          selfgen_t = 0; /* No */
	
	* Supplemental Private Insurance Flag (Line-Item Level);
	if (plantype in (20:31) and s_othpln not in(1, 3, 4)) 
	   or (int_type in ('F') and plantype = 70)  		  then privateflag_t = 1; /* Yes */
	else                                                 	   privateflag_t = 0; /* No */

run;

/* Create Beneficiary-Level Flags for ESI, Self-Pay, and Any Private Coverage */
PROC SQL;
CREATE TABLE hitlinetemp_max AS 
  SELECT *, 
         Max(esiany_t)      AS esiany, 
         Max(esigen_t)      AS esigen, 
         Max(selfany_t)     AS selfany, 
         Max(selfgen_t)     AS selfgen, 
         Max(privateflag_t) AS privateflag 
  FROM   hitlinetemp 
  GROUP  BY baseid; 

CREATE TABLE hitlinetemp_uniq AS 
  SELECT DISTINCT baseid, 
                  esiany, 
                  esigen, 
                  selfany, 
                  selfgen, 
                  privateflag 
  FROM   hitlinetemp_max; 
QUIT;

/*PARTDFLAG indicates Part D coverage*/
PROC SQL;
CREATE TABLE partdcovered AS 
  SELECT DISTINCT baseid, 
                  1 AS partdflag 
  FROM   hitlinetemp 
  WHERE  plantype = 4 
  GROUP  BY baseid 
  HAVING Sum(covered01 * cov01 + covered02 * cov02 + covered03 * cov03 + 
             covered04 * cov04 + covered05 * cov05 + covered06 * cov06 + 
             covered07 * cov07 + covered08 * cov08 + covered09 * cov09 + 
             covered10 * cov10 + covered11 * cov11 + covered12 * cov12) > 0; 

CREATE TABLE partdnotcovered AS 
  SELECT DISTINCT baseid, 
                  0 AS partdflag 
  FROM   hitlinetemp 
  WHERE  baseid NOT IN (SELECT baseid 
                        FROM   partdcovered); 
QUIT;

data partdcoverage;
	set partdcovered partdnotcovered;
	by baseid;
run;

data tempf.hisumry3;
	merge tempf.hisumry2 partdcoverage;
	by baseid;
run;

/* Merge in Part D, ESI, Self-Pay, and Any Private Flags */
PROC SQL;
CREATE TABLE tempf.hisumry2_partd AS 
  SELECT A.*, 
         B.* 
  FROM   tempf.hisumry2 AS A 
         INNER JOIN partdcoverage AS B 
                 ON A.baseid = B.baseid; 

CREATE TABLE tempf.hisumry3 AS 
  SELECT A.*, 
         B.esiany, 
         B.esigen, 
         B.selfany, 
         B.selfgen, 
         B.privateflag 
  FROM   tempf.hisumry2_partd AS A 
         INNER JOIN hitlinetemp_uniq AS B 
                 ON A.baseid = B.baseid;
QUIT;

data tempf.hisumry4;
	set tempf.hisumry3;

/*----------- Type of Medicare Coverage ------------------------------------------------------*/

	maflag = (h_maff01 = "MA" or h_maff02 = "MA" or h_maff03 = "MA" or h_maff04 = "MA" or
			  h_maff05 = "MA" or h_maff06 = "MA" or h_maff07 = "MA" or h_maff08 = "MA" or
			  h_maff09 = "MA" or h_maff10 = "MA" or h_maff11 = "MA" or h_maff12 = "MA");

	if      maflag = .                      then ma = .;    /* Missing */
	else if maflag = 1						then ma = 1;	/* MA */
	else if maflag = 0			 			then ma = 0;	/* FFS */
	else                                         ma = 999; /* Undefined */

/*----------- Part D Coverage ----------------------------------------------------------------*/
	
	if partdflag = . 							then partd = .;
	else if partdflag = 1						then partd = 1;
	else if partdflag = 0						then partd = 0;
	else                                             partd = 999;

	if ma = . and partdflag = .             then ffsma = .; /* Missing */
	else if ma = 0 and not partdflag		then ffsma = 1;	/* FFS Only */
	else if ma = 0 and partdflag			then ffsma = 2;	/* FFS with Part D */
	else if ma = 1 and not partdflag		then ffsma = 3;	/* MA only */
	else if ma = 1 and partdflag			then ffsma = 4;	/* MA with Part D */
	else                                         ffsma = 999; /* Undefined */
	
run;

data tempf.hisumry5;
	set tempf.hisumry4;

/*----------- Dual-eligible ------------------------------------------------------------------*/

	* Dual-eligible (3 category);
	if h_opmdcd = .                         then dual = .;      /* Missing */
	else if h_opmdcd = 2					then dual = 1;		/* Non-dual */
	else if h_opmdcd = 1					then dual = 2;		/* Full */
	else if h_opmdcd in (3,4)				then dual = 3;		/* Partial */
	else                                         dual = 999;    /* Undefined */

	* Dual-eligible (2 category);
	if      h_opmdcd = .                    then anydual = .;   /* Missing */
	else if h_opmdcd in (1,3,4)				then anydual = 1;	/* Full/Partial */
	else if h_opmdcd = 2					then anydual = 0;	/* Non-dual */
	else                                         anydual = 999; /* Undefined */


/*----------- Additional Private Flags -------------------------------------------------------*/

	* No Private Supplemental Insurance;
	if privateflag = .						then noprivate = .;    /* Missing */
	else if privateflag = 1					then noprivate = 0;	   /* Bene has private insurance */
	else if	privateflag = 0				    then noprivate = 1;	   /* Bene has no private insurance */
	else                                         noprivate = 999;  /* Undefined */

	* Any Private Supplemental Insurance;
 	if noprivate = .                        then anyprivate = .;    /* Missing */
	else if noprivate = 0					then anyprivate = 1;	/* Bene has private insurance */
	else if noprivate = 1					then anyprivate = 0;	/* Bene has no private insurance */
	else                                         anyprivate = 999;  /* Undefined */

run;

/* Create Intermediate Insurance File for Merging */
data intermed.insurance;
	set tempf.hisumry5;
run;
