/******************************************************************************************************/																		
/*** CODE: Create Internet Usage measure using LDS segments                                         ***/
/******************************************************************************************************/

data tempf.mcreplnq;
	set survey.mcreplnq(DROP= KNSEWT KNSE1-KNSE100 KNSCWT KNSC1-KNSC100 KNCEWT KNCE1-KNCE100);

/*-----------  Internet Usage --------------------------------*/


if ( knetpers = .  | knetpers = .N | 
     knetpers = .R  | knetpers = .D )   then netuse = .;    /* Missing */
else if knetpers = 1 					then netuse = 1; 	 /* Yes */
else if knetpers = 2 					then netuse = 0; 	 /* No */
else 										 netuse = 999;  /* Undefined */
	
run;                                       satavail = 999; /* Undefined */
