/******************************************************************************************************/																		
/*** CODE: Create Mental Condition measure using LDS segments                                       ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*----------- Mental Condition --------------------------------------------------------------*/
	/* REMOVED: D_MENTAL removed in 2019 */
	
	if manicdep in (1,2) or schizoph in (1,2) or depress in (1,2) or psycotic in (1,2) or anxiety = 1 
		or ptsd in (1,2) or apsych = 1 or delus = 1 then mental = 1;	/* Yes */
	else if manicdep = 0 and schizoph = 0 and depress = 0 and psycotic = 0 and anxiety = 0 and ptsd = 0
		and apsych = 0 and delus = 0 								then mental = 0;	/* No */

		run;
