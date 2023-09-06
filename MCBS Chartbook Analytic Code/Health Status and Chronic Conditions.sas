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
