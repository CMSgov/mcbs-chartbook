/******************************************************************************************************/																		
/*** CODE: Create Hearing and Visions measures using LDS segments                                   ***/
/******************************************************************************************************/

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
