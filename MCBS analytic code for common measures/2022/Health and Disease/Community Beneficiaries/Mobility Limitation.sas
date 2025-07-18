/******************************************************************************************************/																		
/*** CODE: Create Mobility Limitation measure using LDS segments                                    ***/
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

	/*---- Mobility Limitation -------------------------------------------------------------------*/

    if ( difwalk = .  | difwalk = .N | 
	    difwalk = .R  | difwalk = .D )   then mlimit = .; /* Missing */
    else if difwalk = 1 				 then mlimit = 0; /* No difficulty walking - No mobility limitation */
		else if difwalk in (2,3,4,5)     then do ; /* Yes mobility limitation with no disability */
			if disab = 0 			     then mlimit = 1;
				else if disab > 0        then mlimit = 2; /* Yes mobility limitation with any disability */
        end;
    else                                  mlimit = 999;   /* Undefined */

	run;
