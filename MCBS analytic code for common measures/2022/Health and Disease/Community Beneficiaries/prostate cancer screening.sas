*******************************************************************
*  Received a digital rectal exam of prostate in past year (among * 
*  male beneficiaries who never reported having prostate surgery) *
*******************************************************************;

data DIGTEXAM;
	merge 
		survey.PREVCARE (keep= BASEID DIGTEXAM in = y)
		survey.DEMO (keep = BASEID ROSTSEX) 
		survey.CHRNCOND (keep = BASEID PROSSURG);
		by baseid;
	if y;
	run;
	data DIGTEXAM_pyr;
		set DIGTEXAM;
		/*DIGTEXAM_pyr: Digital exam for prostate (past year) */
		if DIGTEXAM = 1	and ROSTSEX = 1 and PROSSURG ne 1		then DIGTEXAM_pyr = 1; /* Yes */
		else if  DIGTEXAM = 2 and ROSTSEX = 1 and PROSSURG ne 1 then DIGTEXAM_pyr = 0; /* No */
		else if ( DIGTEXAM = .N | DIGTEXAM = . |
	   	 	DIGTEXAM = .R | DIGTEXAM = .D )					then DIGTEXAM_pyr = .; /* Missing */
		KEEP BASEID DIGTEXAM_PYR;
	run;

***********************************************************************
*Received a blood test for detection of prostate cancer in past year  *
*(among male beneficiaries who never reported having prostate surgery)*
***********************************************************************;


data BLOODTST;
	merge 
		survey.PREVCARE (keep= BASEID BLOODTST in = y)
		survey.DEMO (keep = BASEID ROSTSEX) 
		survey.CHRNCOND (keep = BASEID PROSSURG);
		by baseid;
	if y;
	run;
	data BLOODTST_pyr;
		set BLOODTST;
		/*BLOODTST_pyr: Blood test for prostate cancer (past year) */
		if BLOODTST = 1	and ROSTSEX = 1 and PROSSURG ne 1		then BLOODTST_pyr = 1; /* Yes */
		else if  BLOODTST = 2 and ROSTSEX = 1 and PROSSURG ne 1 then BLOODTST_pyr = 0; /* No */
		else if ( BLOODTST = .N | BLOODTST = . |
	   	 	BLOODTST = .R | BLOODTST = .D )					then BLOODTST_pyr = .; /* Missing */
		KEEP BASEID BLOODTST_PYR;
	run;
