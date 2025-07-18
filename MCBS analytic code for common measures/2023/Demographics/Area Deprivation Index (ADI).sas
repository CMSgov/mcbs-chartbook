/******************************************************************************************************/																		
/*** CODE: Create Area Deprivation Index (ADI) measure using LDS segments                           ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Area Deprivation Index (ADI) ------------------*/


if ADINATNL = . or ADINATNL = .S 		then ADIcat = .;    /* Missing */
else if ADINATNL <= 25 					then ADIcat = 1;    /* 1 – 25th percentile */
else if 26 <= ADINATNL <= 50 			then ADIcat = 2;    /* 26 – 50th percentile */
else if 51 <= ADINATNL <= 75 			then ADIcat = 3;    /* 51 – 75th percentile */
else if ADINATNL >= 76 					then ADIcat = 4;    /*76 – 100th percentile */
else 										 ADIcat = 999; 	/* Undefined */

run;
