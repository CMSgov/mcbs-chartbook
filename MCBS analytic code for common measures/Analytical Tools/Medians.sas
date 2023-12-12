
/**Below is the SAS code you need to create an analytic file that includes the Survey File variables, 
as well as the topical continuously enrolled weights and replicate weights, required to analyze finalcial well-being
for Medicare beneficiaries living in the community aged 65 and over by income.

The Survey File and Cost Supplement File both contain weight segments. However, it is important to
note that users conducting joint analysis of both Survey File and Cost Supplement File data must use
the Cost Supplement File weights. Users analyzing Survey File data separately should use the Survey
File weights. Further, to generate estimates using the data from one of the Topical Questionnaire sections on their
own or merged with another segment, researchers must always use the special non-response adjustment general 
and replicate weights included in the Topical segment INSTEAD of using the weights
that appear in the separate weight segments. See detailed information in MCBS Tutorial:
https://www.cms.gov/research-statistics-data-and-systems/research/mcbs/downloads/mcbs_tutorial.pdf
 **/

/*Compile Survey File segments at the beneficiary-level*/
data outcome1;
	merge surveyYY.demo (keep=BASEID)
		surveyYY.INCASSET (keep= BASEID IAWNHOME SPCHECK SPSECHK JNTCHECK SPSAVE SPSESAVE JNTSAVE SPDEPT SPSEDEPT 
        JNTDEPT SPFUND SPSEFUND JNTFUND SP401K SPSE401K SSRRSP SSRRSPSE SPSSIREC SPSESIRC SPPENS SPSEPENS
		INC21YR WORK HOMEEVAL HOMEOWE BANK FUND  TOT401K LY401K SSRR PENSION INSEWT INSE1-INSE100 in=y );
	by BASEID;
	if y AND INSEWT NE .; 
run;

/*Recode Outcome Variables from Survey File segments*/
data outcome2;
	set outcome1;
	
	/*-----------Home Ownership: HOMEOWN -------------------------------------------------------------------*/
	/* From IAWNHOME on INCASSET*/
	
	if ( iawnhome = .  | iawnhome = .N | 
		 iawnhome = .R | iawnhome = .D )				then homeown = .;   /* Missing */
	else if iawnhome = 1								then homeown = 1;	/* Full/Partial */
	else if iawnhome in (2, 91)							then homeown = 0;	/* Non-dual */
	else 												homeown = 999; /* Undefined */

	/*-----------Assets at Financial Institution: ASFINI--------------------------------------------------------*/
	/* From SPCHECK, SPSECHK, JNTCHK, SPSAVE, SPSESAVE, JNTSAVE, SPDEPT, SPSEDEPT, JNTDEPT on INCASSET*/
	
	asstflag = (SPCHECK = 1 or SPSECHK = 1 or JNTCHECK = 1 or SPSAVE = 1 or SPSESAVE = 1 or JNTSAVE = 1 or SPDEPT = 1 or SPSEDEPT = 1 or JNTDEPT = 1);

	if asstflag = .                      				then asfini = .;    /* Missing */
	else if asstflag = 1								then asfini = 1;	/* Yes */
	else if asstflag = 0			 					then asfini = 0;	/* No */
	else                                        		asfini = 999; /* Undefined */
	
	/*-----------Checking Account: CHKACC--------------------------------------------------------*/
	/* From SPCHECK, SPSECHK, JNTCHECK on INCASSET*/
	
	chacflag = (SPCHECK = 1 or SPSECHK = 1 or JNTCHECK = 1);

	if chacflag = .                      				then chkacc = .;    /* Missing */
	else if chacflag = 1								then chkacc = 1;	/* Yes */
	else if chacflag = 0			 					then chkacc = 0;	/* No */
	else                                        		chkacc = 999; /* Undefined */
	
	/*-----------Savings Account: SAVACC--------------------------------------------------------*/
	/* From SPSAVE, SPSESAVE, JNTSAVE on INCASSET*/
	
	svacflag = (SPSAVE = 1 or SPSESAVE = 1 or JNTSAVE = 1);

	if svacflag = .                      				then savacc = .;    /* Missing */
	else if svacflag = 1								then savacc = 1;	/* Yes */
	else if svacflag = 0			 					then savacc = 0;	/* No */
	else                                        		savacc = 999; /* Undefined */
	
	/*-----------Certificates of Deposit: CERTDEP--------------------------------------------------------*/
	/* From SPDEPT, SPSEDEPT, JNTDEPT on INCASSET*/
	
	svacflag = (SPDEPT = 1 or SPSEDEPT = 1 or JNTDEPT = 1);

	if svacflag = .                      				then certdep = .;    /* Missing */
	else if svacflag = 1								then certdep = 1;	/* Yes */
	else if svacflag = 0			 					then certdep = 0;	/* No */
	else                                        		certdep = 999; /* Undefined */
	
	/*-----------Stocks or Mutual Funds: STOCKMF--------------------------------------------------------*/
	/* From SPFUND, SPSEFUND, JNTFUND on INCASSET*/
	
	stmfflag = (SPFUND = 1 or SPSEFUND = 1 or JNTFUND = 1);

	if stmfflag = .                      				then stockmf = .;    /* Missing */
	else if stmfflag = 1								then stockmf = 1;	/* Yes */
	else if stmfflag = 0			 					then stockmf = 0;	/* No */
	else                                        		stockmf = 999; /* Undefined */
	
	/*-----------Retirement Accounts: RETACC--------------------------------------------------------*/
	/* From SP401K, SPSE401K on INCASSET*/
	
	retflag = (SP401K = 1 or SPSE401K = 1);

	if retflag = .                      				then retacc = .;    /* Missing */
	else if retflag = 1								then retacc = 1;	/* Yes */
	else if retflag = 0			 					then retacc = 0;	/* No */
	else                                        		retacc = 999; /* Undefined */
	
	/*-----------Receive Social Security: RECSS--------------------------------------------------------*/
	/* From SSRRSP, SSRRSPSE on INCASSET*/
	
	ssflag = (SSRRSP = 1 or SSRRSPSE = 1);

	if ssflag = .                      				then recss = .;    /* Missing */
	else if ssflag = 1								then recss = 1;	/* Yes */
	else if ssflag = 0			 					then recss = 0;	/* No */
	else                                        		 recss = 999; /* Undefined */
	
	/*-----------Receive Supplemental Security Income (SSI): RECSSI--------------------------------------------------------*/
	/* From SPSSIREC, SPSESIRC on INCASSET*/
	
	ssiflag = (SPSSIREC = 1 or SPSESIRC = 1);

	if ssiflag = .                      			then recssi = .;    /* Missing */
	else if ssiflag = 1								then recssi = 1;	/* Yes */
	else if ssiflag = 0			 					then recssi = 0;	/* No */
	else                                        		 recssi = 999; /* Undefined */
	
	/*-----------Receive Pension: RECPEN--------------------------------------------------------*/
	/* From SPPENS, SPSEPENS on INCASSET*/

	penflag = (SPPENS = 1 or  SPSEPENS= 1);

	if penflag = .                      			then recpen = .;    /* Missing */
	else if penflag = 1								then recpen = 1;	/* Yes */
	else if penflag = 0			 					then recpen = 0;	/* No */
	else                                        		 recpen = 999; /* Undefined */
	
	/*-----------Non-zero earnings from work: WORK----------------------------------------------*/
	/* From WORK on INCASSET*/

	if work in(.,0)	                				then work_cat = 0;  /* No */
	else if work > 0 								then work_cat = 1;	/* Yes */
	
	/*-----------Home equity: HOMEEQU--------------------------------------------------------*/
	/* From HOMEEVAL, HOMEOWE on INCASSET*/

	if homeeval = . 								then homeequ = .;	/* Missing */
	else if homeowe in(.,0)							then homeequ = homeeval; /* Calculated as only the value of the home */
	else 												homeequ = homeeval - homeowe; /* Calculated as the difference between the value and amount owed */



run;

/*Create beneficiary-level dataset with only outcome variables*/
data outcome;
	set outcome2;
	keep BASEID HOMEOWN ASFINI CHKACC SAVACC CERTDEP STOCKMF RETACC RECSS RECSSI RECPEN WORK_CAT
		INC21YR WORK HOMEEQU BANK FUND  TOT401K LY401K SSRR PENSION INSEWT INSE1-INSE100;
run;

%macro calcmedians(outcome_list); 
/*Output median of outcome by predictor variable*/
proc surveymeans data=outcome median stderr varmethod=brr (fay=.3);
			var  &outcome_list;
			weight INSEWT;
			repweight INSE1-INSE100;
					
			ods output quantiles=q 
					summary=n(keep=Label1 nValue1 where=(Label1="Number of Observations"));
run;	

/*Combine summary stats and calculate MOE*/
proc sql;
select q.VarName, int(n.nValue1) as N, q.Estimate as Median, 1.645*q.StdErr as MOE, q.StdErr as SE
				from q, n;
quit;
%mend calcmedians;

/**sample**/
%calcmedians (homeown)
%calcmedians (ASFINI)
