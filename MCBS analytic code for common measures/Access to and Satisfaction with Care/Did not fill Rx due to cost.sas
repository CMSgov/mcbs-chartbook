/******************************************************************************************************/																		
/*** CODE: Create Did not fill Rx due to cost measure using LDS segments                            ***/
/******************************************************************************************************/

data tempf.rxmed;
	set survey.rxmed(DROP= RXSEWT RXSE1-RXSE100 RXSCWT RXSC1-RXSC100 RXCEWT RXCE1-RXCE100);

	/*Have a prescription that you do not refill due to cost*/

    if ( nofillrx = .  | nofillrx = .N | 
	    nofillrx = .R  | nofillrx = .D )   	then nodrug = .;    /* Missing */	
	else if nofillrx in (1,2)				then nodrug = 1;	/*Yes*/
	else if nofillrx = 3					then nodrug = 0;	/*No*/
	else                                         nodrug = 999;  /* Undefined */
	
run;
