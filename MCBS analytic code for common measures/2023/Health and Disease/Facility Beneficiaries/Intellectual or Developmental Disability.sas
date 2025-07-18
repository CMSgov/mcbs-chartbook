/******************************************************************************************************/																		
/*** CODE: Create Intellectual or Developmental Disability measure using LDS segments               ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*----------- Intellectual or Developmental Disability --------------------------------------*/
	if ( mentdown = .  | mentdown = .N | 
	     mentdown = .R  | mentdown = .D ) AND
	     ( mentauti = .  | mentauti = .N | 
	     mentauti = .R  | mentauti = .D ) AND
	     ( mentotho = .  | mentotho = .N | 
	     mentotho = .R  | mentotho = .D ) AND
	     ( mentothn = .  | mentothn = .N | 
	     mentothn = .R  | mentothn = .D )		               		  then IDD = .;   /* Missing */
	else if mentdown = 1 or mentauti = 1 or
	        mentotho = 1 or mentothn = 1                              then IDD = 1;  
	else if mentdown in (0,.N,.D,.) and mentauti in (0,.N,.D,.) and					
		    mentotht in (0,.N,.D,.) and mentothn in (0,.N,.D,.) 	  then IDD = 0;	/* Yes */
	else                                                            	   IDD = 999; /* Undefined */

		run;
