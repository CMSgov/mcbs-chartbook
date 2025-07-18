/******************************************************************************************************/																		
/*** CODE: Create Cognitive Impairment measure using LDS segments                                    ***/
/******************************************************************************************************/

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

	if int_type = 2 		   then disab = 3;		/* LTC Facility */
	else do;
		if misscount = 6       then disab = .;      /* Missing */
		else if count = 0      then disab = 0;		/* No Disability */
		else if count = 1      then disab = 1;		/* 1 Disability */
		else if count in (2:6) then disab = 2;		/* 2 or More Disabilities */
		else 						disab = 999;    /* Undefined */
	end;
							
run;

data nagidisc;
	merge survey.menthlth tempf.limitations2;
	by baseid;
run;

data tempf.nagidisc;
	set nagidisc;

	/*----------- Cognitive Impairment -----------------------------------------------------------*/

	if (disdecsn = .  | disdecsn = .N | 
	   disdecsn = .R  | disdecsn = .D) AND
	   (phqtrcon = .  | phqtrcon = .N | 
	   phqtrcon = .R  | phqtrcon = .D)              then cogimp = .;   /* Missing */
	else if disdecsn = 1 or phqtrcon in (3:4) 		then cogimp = 1;   /* Cognitively Impaired */
	else if disdecsn = 2 or phqtrcon in (1:2)       then cogimp = 0;   /* Not Cognitively Impaired */
	else                                                 cogimp = 999; /* Undefined */

	run;
