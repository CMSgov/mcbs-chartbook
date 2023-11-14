/******************************************************************************************************/																		
/*** CODE: Create Residence Area measure using LDS segments                                     ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Residence Area (4-Category) (New Rez Status Codes) -----------------------------*/

	if h_ruca1 = .                         	then RezStat4 = .;    /* Missing */
	else if h_ruca1 in (1,2,3) 				then RezStat4 = 0;	  /* Metro */
	else if	h_ruca1 in (4,5,6)	            then RezStat4 = 1;	  /* Micro */
	else if	h_ruca1 in (7,8,9)	            then RezStat4 = 2;	  /* Small Town */
	else if	h_ruca1 = 10	            	then RezStat4 = 3;	  /* Rural */
	else                                         RezStat4 = 999;  /* Undefined */

	run;

/*----------- Urban/Rural Status (New Rez Status Codes) --------------------------------------*/

	if h_ruca = ' '                         then UrbRurStat = .;      /* Missing */
	else if h_ruca = 'Rural' 				then UrbRurStat = 0;	  /* Rural */
	else if	h_ruca = 'Urban'	            then UrbRurStat = 1;	  /* Urban */
	else                                         UrbRurStat = 999;    /* Undefined */

	run;
