/******************************************************************************************************/																		
/*** CODE: Create Region measures using LDS segments                                                ***/
/******************************************************************************************************/


   data region;
		set survey.demo;	
		if ( h_census = .  | h_census = .N | 
		    h_census = .R | h_census = .D  )              	then region = .;   /* Missing */
		else if h_census in (1, 2)							then region = 1;   /* Northeast */ 
		else if h_census in (3, 4)							then region = 2;   /* Midwest */
		else if h_census in (5, 6, 7)						then region = 3;   /* South */
		else if h_census in (8, 9)							then region = 4;   /* West */
		else  												region = 999;		/* Undefined */
		keep baseid region;
	run;
