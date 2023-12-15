/******************************************************************************************************/																			***/
/*** OBJECTIVE: Create insurance coverage measures using LDS segments                               ***/
/******************************************************************************************************/;

data tempf.hisumry2;
	set survey.hisumry;
run;

/*Merge Hitline with demo file to get INT_TYPE. This will be used in logic to flag insurance*/
proc sql;
	create table hitline_inttype as
		select L.*, R.INT_TYPE
		from survey.hitline as L left outer join survey.demo as R
		on L.BASEID = R.BASEID; 
quit;

/*Create indicator variables COVERED01-COVERED12 to indicate coverage*/
data hitlinetemp;
	set hitline_inttype;
	array srccov [12] srccov01-srccov12;
	array covered [12] covered01-covered12;

	do i = 1 to 12;
		if srccov[i] in (2,3) then covered[i] = 1;
		else covered[i] = 0;
	end;

	*2017 UPDATE: PlanType and Insurance Coverage Plan are now flagged in the HITLINE segment rather than HISUMRY;
 
	* Any Employer-Sponsored Insurance (Line-Item Level);
	if plantype in (20, 21) and s_othpln not in(1, 3, 4) then esiany_t = 1; /* Yes */
	else                                                       esiany_t = 0; /* No */

	* Employer-Sponsored Insurance w/ Comprehensive Coverage (Line-Item Level);
	if esiany_t = 1 and (S_MSCOV = 1 or S_IP = 1 or S_COVNH = 1) then esigen_t = 1; /* Yes */
    else                                                                 esigen_t = 0; /* No */

	* Any Self-Pay Insurance (Line-Item Level);
	If plantype in (30, 31) and s_othpln not in(1, 3, 4) then selfany_t = 1; /* Yes */
	else										               selfany_t = 0; /* No */

	* Self-Pay Insurance w/ Comprehensive Coverage (Line-Item Level);
	if selfany_t = 1 and (S_MSCOV = 1 or S_IP = 1 or S_COVNH = 1) then selfgen_t = 1; /* Yes */
	else										                          selfgen_t = 0; /* No */
	
	* Supplemental Private Insurance Flag (Line-Item Level);
	if (plantype in (20:31) and s_othpln not in(1, 3, 4)) 
	   or (int_type in ('F') and plantype = 70)  		  then privateflag_t = 1; /* Yes */
	else                                                 	   privateflag_t = 0; /* No */

run;

/* Create Beneficiary-Level Flags for ESI, Self-Pay, and Any Private Coverage */
PROC SQL;
CREATE TABLE hitlinetemp_max AS 
  SELECT *, 
         Max(esiany_t)      AS esiany, 
         Max(esigen_t)      AS esigen, 
         Max(selfany_t)     AS selfany, 
         Max(selfgen_t)     AS selfgen, 
         Max(privateflag_t) AS privateflag 
  FROM   hitlinetemp 
  GROUP  BY baseid; 

CREATE TABLE hitlinetemp_uniq AS 
  SELECT DISTINCT baseid, 
                  esiany, 
                  esigen, 
                  selfany, 
                  selfgen, 
                  privateflag 
  FROM   hitlinetemp_max; 
QUIT;

/*PARTDFLAG indicates Part D coverage*/
PROC SQL;
CREATE TABLE partdcovered AS 
  SELECT DISTINCT baseid, 
                  1 AS partdflag 
  FROM   hitlinetemp 
  WHERE  plantype = 4 
  GROUP  BY baseid 
  HAVING Sum(covered01 * cov01 + covered02 * cov02 + covered03 * cov03 + 
             covered04 * cov04 + covered05 * cov05 + covered06 * cov06 + 
             covered07 * cov07 + covered08 * cov08 + covered09 * cov09 + 
             covered10 * cov10 + covered11 * cov11 + covered12 * cov12) > 0; 

CREATE TABLE partdnotcovered AS 
  SELECT DISTINCT baseid, 
                  0 AS partdflag 
  FROM   hitlinetemp 
  WHERE  baseid NOT IN (SELECT baseid 
                        FROM   partdcovered); 
QUIT;

data partdcoverage;
	set partdcovered partdnotcovered;
	by baseid;
run;

data tempf.hisumry3;
	merge tempf.hisumry2 partdcoverage;
	by baseid;
run;

/* Merge in Part D, ESI, Self-Pay, and Any Private Flags */
PROC SQL;
CREATE TABLE tempf.hisumry2_partd AS 
  SELECT A.*, 
         B.* 
  FROM   tempf.hisumry2 AS A 
         INNER JOIN partdcoverage AS B 
                 ON A.baseid = B.baseid; 

CREATE TABLE tempf.hisumry3 AS 
  SELECT A.*, 
         B.esiany, 
         B.esigen, 
         B.selfany, 
         B.selfgen, 
         B.privateflag 
  FROM   tempf.hisumry2_partd AS A 
         INNER JOIN hitlinetemp_uniq AS B 
                 ON A.baseid = B.baseid;
QUIT;

data tempf.hisumry4;
	set tempf.hisumry3;

/*----------- Type of Medicare Coverage ------------------------------------------------------*/

	maflag = (h_maff01 = "MA" or h_maff02 = "MA" or h_maff03 = "MA" or h_maff04 = "MA" or
			  h_maff05 = "MA" or h_maff06 = "MA" or h_maff07 = "MA" or h_maff08 = "MA" or
			  h_maff09 = "MA" or h_maff10 = "MA" or h_maff11 = "MA" or h_maff12 = "MA");

	if      maflag = .                      then ma = .;    /* Missing */
	else if maflag = 1						then ma = 1;	/* MA */
	else if maflag = 0			 			then ma = 0;	/* FFS */
	else                                         ma = 999; /* Undefined */

/*----------- Part D Coverage ----------------------------------------------------------------*/
	
	if partdflag = . 							then partd = .;
	else if partdflag = 1						then partd = 1;
	else if partdflag = 0						then partd = 0;
	else                                             partd = 999;

	if ma = . and partdflag = .             then ffsma = .; /* Missing */
	else if ma = 0 and not partdflag		then ffsma = 1;	/* FFS Only */
	else if ma = 0 and partdflag			then ffsma = 2;	/* FFS with Part D */
	else if ma = 1 and not partdflag		then ffsma = 3;	/* MA only */
	else if ma = 1 and partdflag			then ffsma = 4;	/* MA with Part D */
	else                                         ffsma = 999; /* Undefined */
	
run;

data tempf.hisumry5;
	set tempf.hisumry4;

/*----------- Dual-eligible ------------------------------------------------------------------*/

	* Dual-eligible (3 category);
	if h_opmdcd = .                         then dual = .;      /* Missing */
	else if h_opmdcd = 2					then dual = 1;		/* Non-dual */
	else if h_opmdcd = 1					then dual = 2;		/* Full */
	else if h_opmdcd in (3,4)				then dual = 3;		/* Partial */
	else                                         dual = 999;    /* Undefined */

	* Dual-eligible (2 category);
	if      h_opmdcd = .                    then anydual = .;   /* Missing */
	else if h_opmdcd in (1,3,4)				then anydual = 1;	/* Full/Partial */
	else if h_opmdcd = 2					then anydual = 0;	/* Non-dual */
	else                                         anydual = 999; /* Undefined */


/*----------- Additional Private Flags -------------------------------------------------------*/

	* No Private Supplemental Insurance;
	if privateflag = .						then noprivate = .;    /* Missing */
	else if privateflag = 1					then noprivate = 0;	   /* Bene has private insurance */
	else if	privateflag = 0				    then noprivate = 1;	   /* Bene has no private insurance */
	else                                         noprivate = 999;  /* Undefined */

	* Any Private Supplemental Insurance;
 	if noprivate = .                        then anyprivate = .;    /* Missing */
	else if noprivate = 0					then anyprivate = 1;	/* Bene has private insurance */
	else if noprivate = 1					then anyprivate = 0;	/* Bene has no private insurance */
	else                                         anyprivate = 999;  /* Undefined */

run;

/* Create Intermediate Insurance File for Merging */
data intermed.insurance;
	set tempf.hisumry5;
run;
