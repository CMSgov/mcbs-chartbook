/******************************************************************************************************/																		
/*** CODE: Create Race/Ethnicity measure using LDS segments                                         ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Race/Ethnicity -----------------------------------------------------------------*/

	if (hisporig = . | hisporig = .R | hisporig = .D | hisporig = .N | hisporig = 2) and 
	   (d_race2 = .  | d_race2 = .R  | hisporig = .D | d_race2 = .D) 
	   										then ethnicty = .;
	else if hisporig = 1					then ethnicty = 3;		/* Hispanic origin */
	else do;
		if d_race2 = 4						then ethnicty = 1;		/* White */
		else if d_race2 = 2					then ethnicty = 2;		/* Black */
		else if d_race2 in (1,3,5:7)		then ethnicty = 4;		/* Other */
		else                                     ethnicty = 999;    /* Undefined */
	end;
run;
