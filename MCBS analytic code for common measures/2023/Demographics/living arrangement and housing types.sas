*******************************************************************************
*  CODE: Create living arrangement measures using LDS segments				  *
*  This section uses the following Survey File segments: HHCHAR				  * 
******************************************************************************;

DATA LIVEARR;
set survey.HHCHAR;

/*------------Living arrangement - 2 separate categorical structures----------------------------*/
	
if D_HHTOT = 1 then ALONE = 1;		/*Lives alone*/	
else if D_HHTOT > 1	then ALONE = 2;	/*Lives with someone else*/	

run;

if D_COMPHH = 1	then LIVING = 1;							/*Lives alone*/	
else if D_COMPHH in (2,6) then LIVING = 2; 					/*Lives with spouse/partner only*/	
else if D_COMPHH in (3:5, 7:11, 13) then LIVING = 3;		/*Lives in a multigenerational household*/	
else if	D_COMPHH not in (.,1, 2:11, 13)	then LIVING = 4;	/*Other living arrangement*/

run;	

/*------------Housing type----------------------------*/

if (DWELLING = .  | DWELLING = .N | 
	DWELLING = .R  | DWELLING = .D) then DWELL_TYPE = .; 	/* Missing */
else if DWELLING = 1 then DWELL_TYPE = 1; 					/*One family home detached*/		
else if DWELLING in (2:3, 5) then DWELL_TYPE = 2;			/*Duplex, apartment building, or townhouse*/		
else if DWELLING in (4,6,91) then DWELL_TYPE = 3;			/*Other housing type*/
else DWELL_TYPE = 999; 										/* Undefined */	


/*------------Housing in special community----------------------------*/

if (HOUSTYPE = .  | HOUSTYPE = .N | 
	HOUSTYPE = .R  | HOUSTYPE = .D) then SPEC_HOUS = .; 	/* Missing */
else if HOUSTYPE = 1 then SPEC_HOUS = 1;					/*Yes*/		
else if HOUSTYPE = 2 then SPEC_HOUS = 2;					/*No*/	
else SPEC_HOUS = 999; 										/* Undefined */	

run;

/*------------Number of housing quality issues----------------------------*/

	/*Count of housing issues*/
	data hous_issues2;
		set survey.hhchar;
		by baseid;

		array iss8 8. HOUSPEST HOUSMOLD HOUSLEAD HOUSHEAT HOUSCOOL HOUSOVEN HOUSSMOK HOUSWATR;

		count = 0;
		do over iss8; /* Iterate over variables to count */
			if iss8 = 1 						  then count + 1;
		end;

		misscount = 0;
		do over iss8;
			if iss8 = .  | iss8 = .N | 
		   	   iss8 = .R | iss8 = .D   then misscount + 1;   /* Count Missing */
		end;

		do;
			if misscount >0        then NUMHOUS = .;        /* Missing */
			else if count = 0      then NUMHOUS = 0;		/* No housing quality issues */
			else if count = 1      then NUMHOUS = 1;		/* One housing quality issue */
			else if count in (2:8) then NUMHOUS = 2;		/* 2 or More housing quality issues */
		end;
							
	run;
