/******************************************************************************************************/																		
/*** CODE: Create Hearing and Vision measure using LDS segments                                     ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*----------- Hearing Trouble -----------------------------------------------------------------*/
	if ( hcheaid = .  | hcheaid = .N |
         hcheaid = .R  | hcheaid = .D ) and 
   	   ( hchecond = .  | hchecond = .N |
         hchecond = .R  | hchecond = .D ) 						      then hearingprob = .;   /* Missing */
	else if hcheaid = 1 or hchecond ge 1 							  then hearingprob = 1;	  /* Yes */
	else if hcheaid in (.,.N,.D,.R,0) and hchecond in (.,.N,.D,.R,0)  then hearingprob = 0;   /* No */
	else                                                                   hearingprob = 999; /* Unknown */						/* Undefined */

		run;

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


		run;
