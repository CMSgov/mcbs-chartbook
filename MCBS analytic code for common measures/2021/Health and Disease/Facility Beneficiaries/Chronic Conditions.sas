/******************************************************************************************************/																		
/*** CODE: Create Chronic Conditions measures using LDS segments                                    ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*----------- Chronic Conditions ---------------------------------------*/

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

	/*Removed in 2019*/

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

	run;

