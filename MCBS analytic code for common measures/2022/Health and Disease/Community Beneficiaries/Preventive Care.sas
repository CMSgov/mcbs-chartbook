/******************************************************************************************************/																		
/*** CODE: Create Preventive Care measures using LDS segments                                       ***/
/******************************************************************************************************/

/*----------- Preventive Care ---------------------------------------------------------------*/

data tempf.prevcarec;
	set survey.prevcare;

/*----------- Flu Shot -----------------------------------------------------------------------*/
	if ( flushot = .  | flushot = .N | 
	     flushot = .R  | flushot = .D )     then flu = .;   /* Missing */ 
	else if flushot = 1						then flu = 1;	/* Yes */
	else if flushot = 2						then flu = 0;	/* No */
	else                                         flu = 999; /* Undefined */

/*----------- Pneumonia Vaccine --------------------------------------------------------------*/
	if ( pneushot = .  | pneushot = .N | 
	     pneushot = .R  | pneushot = .D )   then pneu = .;   /* Missing */ 
	else if pneushot = 1					then pneu = 1;   /* Yes */
	else if pneushot = 2					then pneu = 0;	 /* No */
	else                                         pneu = 999; /* Undefined */

/*----------- Shingles Vaccine ---------------------------------------------------------------*/
	if ( shingvac = .  | shingvac = .N | 
	     shingvac = .R  | shingvac = .D )   then shingles = .;      /* Missing */
	else if shingvac = 1					then shingles = 1;	    /* Yes */
	else if shingvac = 2					then shingles = 0;	    /* No */
	else                                         shingles = 999;    /* Undefined */

/*----------- Mammogram ----------------------------------------------------------------------*/
	if ( mammogrm = .  | mammogrm = .N | 
	     mammogrm = .R  | mammogrm = .D )   then mammogram = .;   /* Missing */
	else if mammogrm = 1					then mammogram = 1;	  /* Yes */
	else if mammogrm = 2					then mammogram = 0;	  /* No */
	else                                         mammogram = 999; /* Undefined */

/*----------- Blood Pressure Screening -------------------------------------------------------*/
	if ( bptaken = .  | bptaken = .N | 
	     bptaken = .R  | bptaken = .D )     then bloodpress = .;    /* Missing */
	else if bptaken in (1, 2)				then bloodpress = 1;	/* Yes */
	else if bptaken in (3, 4, 5, 6)			then bloodpress = 0;	/* No */
	else                                         bloodpress = 999;  /* Undefined */
run;
