/******************************************************************************************************/																		
/*** CODE: Create Internet Usage measure using LDS segments                                         ***/
/******************************************************************************************************/

data tempf.mcreplnq;
	set survey.mcreplnq(DROP= KNSEWT KNSE1-KNSE100 KNSCWT KNSC1-KNSC100 KNCEWT KNCE1-KNCE100);

/*-----------  Internet Usage --------------------------------*/


if ( usenet = .  | usenet = .N | 
     usenet = .R  | usenet = .D )   then netuse = .;    /* Missing */
else if usenet = 1 					then netuse = 1; 	 /* Yes */
else if usenet = 2 					then netuse = 0; 	 /* No */
else 								     netuse = 999;  /* Undefined */
	

/*Owns a computer*/
if (COMPDESK = 1 or COMPPHON = 1 or COMPTAB = 1) then OWN_COMP = 1;	/*Yes*/	
else if (COMPDESK ne 1 and COMPPHON ne 1 and COMPTAB ne 1) and (COMPDESK not in (., .D, .R, .N) 
     and COMPPHON not in (., .D, .R, .N) and COMPTAB not in (., .D, .R, .N)) then OWN_COMP = 0;	/*No*/	

/*Owns a desktop*/
if COMPDESK = 1 then COMPUTER = 1;	/*Yes*/		
else if COMPDESK = 2 then COMPUTER = 0;	/*No*/

/*Owns a smartphone*/
if COMPPHON = 1	then SMARTPHONE = 1;	/*Yes*/		
else if COMPPHON = 2	SMARTPHONE = 0;	/*No*/	

/*Owns a tablet*/
if COMPTAB = 1	then TABLET = 1;	/*Yes*/	
else if COMPTAB = 2	TABLET = 0;	/*No*/	

run;                                     


