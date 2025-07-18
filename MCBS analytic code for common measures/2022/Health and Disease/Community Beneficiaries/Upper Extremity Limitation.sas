/******************************************************************************************************/																		
/*** CODE: Create Upper Extremity Limitation measure using LDS segments                             ***/
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

	   run;
