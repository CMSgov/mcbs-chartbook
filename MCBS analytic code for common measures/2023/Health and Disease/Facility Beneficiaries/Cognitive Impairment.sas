/******************************************************************************************************/																		
/*** CODE: Create Cognitive Impairment measure using LDS segments                                   ***/
/******************************************************************************************************/

data tempf.diseasef;
	set survey.facasmnt (rename = (iadreach = difreach iadgrasp = difwrite iadwalk = difwalk));

/*----------- Cognitive Impairment ------------------------------------------------------------*/
	cogimp_ability = 0;
	if csmemst = 1 then cogimp_ability + 1;
	if csmemlt = 1 then cogimp_ability + 1;
	if cscursea = 0 then cogimp_ability + 1;
	if cslocrom = 0 then cogimp_ability + 1;
	if csnamfac = 0 then cogimp_ability + 1;
	if csinnh = 0 then cogimp_ability + 1;
	if hcuncond in (2,3) then cogimp_ability + 1;
	if hcundoth in (2,3) then cogimp_ability + 1;
	if csdecis in (2,3) then cogimp_ability + 1;

	cogimp_dx = 0;
	if aphasia = 1 then cogimp_dx + 1;

	if mentsum in (0:12) or cogimp_ability ge 1 or cogimp_dx = 1 then cogimp = 1;	/* Yes */
		else cogimp = 0;	/* No */



		run;
