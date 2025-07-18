/******************************************************************************************************/																		
/*** CODE: Create Health Behaviors measures (Nicotine and Alcohol) using LDS segments               ***/
/******************************************************************************************************/

/*------------------------ Health Behaviors --------------------------------------------------*/

data nicoalco;
	merge temp.demo survey.nicoalco;
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
		else if rostsex = 1 and alcday in (1:2)  then drink = 1;  /*Moderate*/
		else if rostsex = 1 and alcday gt 2      then drink = 2;  /*Heavy*/
		else if rostsex = 2 and alcday eq 1      then drink = 1;  /*Moderate*/
		else if rostsex = 2 and alcday gt 1      then drink = 2;  /*Heavy*/
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
