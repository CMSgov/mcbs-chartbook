/******************************************************************************************************/
/*** CODE: Demographics of Medicare Beneficiaries                  				      	            ***/																		
/*** OBJECTIVE: Create Age measure using LDS segments                                     ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*------------Age - 3 separate categorical structures----------------------------*/
	
	if d_strat = .  | d_strat = .N | 
	   d_strat = .R | d_strat = .D                  then age1 = .;   /* Missing */
	else if d_strat in (1:2)						then age1 = 1;   /* <65 Years */
	else if d_strat in (3:7)						then age1 = 2;   /* 65+ Years */
	else 										 		age1 = 999;  /* Undefined */
	
	if d_strat = .  | d_strat = .N | 
	   d_strat = .R | d_strat = .D                  then age3 = .;   /* Missing */
	else if d_strat in (1:2)						then age3 = 1;   /* <65 Years */
	else if d_strat in (3:4)						then age3 = 2;   /* 65-74 Years */
	else if d_strat in (5:6)						then age3 = 3;   /* 75-84 Years */
	else if d_strat = 7								then age3 = 4;   /* 85+ Years */
	else                                    		     age3 = 999; /* Undefined */
	
	if d_strat = .  | d_strat = .N | 
	   d_strat = .R | d_strat = .D                  then age2 = .;   /* Missing */
	else if d_strat = 1 							then age2 = 1;   /* <45 Years */
	else if d_strat = 2  							then age2 = 2;   /* 45-64 Years */
	else if d_strat in (3:4) 						then age2 = 3;   /* 65-74 Years */
	else if d_strat in (5:6)  						then age2 = 4;   /* 75-84 Years */
	else if d_strat = 7 							then age2 = 5;   /* 85+ Years */
	else                                                 age2 = 999; /* Undefined */
