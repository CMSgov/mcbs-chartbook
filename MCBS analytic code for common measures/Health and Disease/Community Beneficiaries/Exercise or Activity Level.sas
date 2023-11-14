/******************************************************************************************************/																		
/*** CODE: Create Exercise/Activity Level measure using LDS segments                                ***/
/******************************************************************************************************/


data tempf.nagidis;
	set nagidis;

		/*----------- Exercise/Activity Level --------------------------------------------------------*/

	if (d_vigtim = .  | d_vigtim = .N | 
	   d_vigtim = .R  | d_vigtim = .D) AND
	   (d_modtim = .  | d_modtim = .N | 
	   d_modtim = .R  | d_modtim = .D)              	then active = .;    /* Missing */
	else if d_vigtim ge 3 or d_modtim ge 5				then active = 3; 	/* Highly Active */
	else if d_vigtim eq 2 or d_modtim in (3 4)			then active = 2;	/* Active */
	else if d_vigtim in (0 1) or d_modtim in (0, 1, 2)	then active = 1;	/* Sedentary */
	else                                                     active = 999;  /* Undefined */

	run;
