/*ADL*/

data work.adl;
 set survey.nagidis;

 /*ADL: Any difficulty getting in or out of bed or chairs*/
if HPPDCHAR = 1	then BED_D = 1;	/*Yes*/	
else if HPPDCHAR in (2,3) then BED_D = 2; /*No*/

/*ADL: Any difficulty using the toilet*/
if HPPDTOIL = 1	then TOIL_D = 1; /*Yes*/		
else if HPPDTOIL in (2,3) then TOIL_D = 2; /*No*/

/*ADL: Any difficulty bathing or showering*/
if HPPDBATH = 1	then BATH_D = 1; /*Yes*/	
else if HPPDBATH in (2,3) then BATH_D = 2; /*No*/	

/*ADL: Any difficulty dressing*/
if HPPDDRES = 1	then DRESS_D = 1; /*Yes*/	
else if HPPDDRES in (2,3) then DRESS_D = 2; /*No*/

/*ADL: Any difficulty eating*/
if HPPDEAT = 1	then EAT_D = 1; /*Yes*/	
else if HPPDEAT in (2,3) then EAT_D =  2; /*No*/

/*ADL: Any difficulty walking*/
if HPPDWALK = 1	then WALK_D = 1; /*Yes*/		
else if HPPDWALK in (2,3) then WALK_D = 2; /*No*/

run;


/** Number of functional limitations**/
	/*Count of ADLs*/
	data ADLs;
		set survey.nagidis;
		by baseid;

		array ADL6 8. hppdchar hppdtoil hppdbath hppddres hppdeat hppdwalk;

		adlcount = 0;
		do over ADL6; /* Iterate over variables to count */
			if ADL6 = 1 						  then adlcount + 1;
		end;

		adlmisscount = 0;
		do over ADL6;
			if ADL6 = .  | ADL6 = .N | 
		   	   ADL6 = .R | ADL6 = .D   then adlmisscount + 1;   /* Count Missing */
		end;				
	run;
	
		/*Count of IADLs*/
	data IADLs;
		set survey.nagidis;
		by baseid;

		array IADL6 8. prbtele prblhwk prbhhwk prbmeal prbshop prbbils;

		iadlcount = 0;
		do over IADL6; /* Iterate over variables to count */
			if IADL6 = 1 						  then iadlcount + 1;
		end;

		iadlmisscount = 0;
		do over IADL6;
			if IADL6 = .  | IADL6 = .N | 
		   	   IADL6 = .R | IADL6 = .D   then iadlmisscount + 1;   /* Count Missing */
		end;				
	run;
	
	/*Merge to datasets with counts*/
	data funclim1;
		merge ADLs IADLs;
		by baseid;
	run;
	
	data funclim2;
		set funclim1;
		    do;
			if adlmisscount >0 or iadlmisscount > 0       										then NUMLIM = .;    /* Missing */
			else if adlcount = 0 and iadlcount = 0 and adlmisscount =0 and iadlmisscount = 0    then NUMLIM = 0;	/* None */
			else if adlcount = 0 and iadlcount GE 1  and adlmisscount =0 and iadlmisscount = 0  then NUMLIM = 1;	/* IADL only */
			else if adlcount in (1,2) and adlmisscount =0							            then NUMLIM = 2;	/* 1-2 ADLs */
			else if adlcount GE 3  and adlmisscount =0					                        then NUMLIM = 3;    /*3 or more ADLs*/
		end;
	run;
	/*Create beneficiary-level dataset with only disability status variable*/	
	data NUMLIM;
		set funclim2;
		keep baseid numlim ;
	run;
%mend;
