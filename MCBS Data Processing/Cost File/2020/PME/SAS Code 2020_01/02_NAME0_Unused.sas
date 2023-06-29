*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 02_NAME0_Unused                                                         |
|      UPDATED: 02/27/2012                                                              |
|  INPUT FILES: Last year's unused events, last year's "Final" file                     | 
| OUTPUT FILES: FINAL_&CURRYEAR._V2                                                     |
|  DESCRIPTION: Creates a file events unused in last year's PUF                         |
|               to be merged with the current "Final" file . Plus distinct spellings    |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%LET CURRYEAR=20;
%LET LASTYEAR=19;

%let unused = pm_events_impd_86_2020;*update round by 3;  

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";

LIBNAME  MCBSLAST "&loc_last";
LIBNAME  POP "Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\2020 Population";


options nofmterr;

**In previous years we have used the PEOPLE or WEIGHT file to capture of population;
**For 2015 processing year we are using a population file.  This file already exists so no need to download;


Data MCBSDATA.POP_&CURRYEAR;
SET POP.pop2020_draft_final_092021 (keep=baseid);
run;


/*In 2017 certain vars were changed from character to numeric, for ease of processing
those were temporarily changed back to character, bringing in those for 2018 processing*/
***GET LIST OF UNSUED EVENTS;
DATA UNUSED_EVENTS; 
SET mcbslast.&unused (KEEP=BASEID PMEDNAME EVNTNUM ROUND UTILNUM COSTNUM ROUND_C COSTNUM_C EVNTNUM_C UTILNUM_C);
UNUSED='KEEP';
RUN;


*LIMIT TO PEOPLE IN CURRENT YEAR SURVEY (WITH EVENTS);
PROC SQL;
CREATE TABLE UNUSED_EVENTS2 AS SELECT B.* FROM
MCBSDATA.POP_&CURRYEAR A 
INNER JOIN UNUSED_EVENTS  B ON A.BASEID=B.BASEID;
QUIT;



***PULL UNUSED SURVEY EVENTS FROM LAST YEAR'S FINAL FILE;
*GET ALL DISTINCT BENE/ROUND/COSTNUMS;
PROC SQL; 
CREATE table UNUSED_BASEID AS SELECT DISTINCT 
 BASEID, 
 ROUND_c,
 COSTNUM_c
FROM UNUSED_EVENTS2
ORDER BY  BASEID,  ROUND_c, COSTNUM_c ;
QUIT;

*GET ALL EVENTS FOR THE BENE/ROUND/COSTNUMS;
PROC SQL;
CREATE TABLE UNUSED_ALL AS SELECT 
 B.*
FROM UNUSED_BASEID      A
       LEFT JOIN 
	 MCBSLAST.FINAL_&LASTYEAR._V2  (drop=unused) B
       ON A.BASEID  = B.BASEID
	  AND A.ROUND_c   = B.ROUND
      AND A.COSTNUM_c = B.COSTNUM
;
QUIT;


*FLAG UNUSED EVENTS;
PROC SQL;
CREATE TABLE UNUSED_ALL_FLAGGED AS SELECT 
 A.*,
 B.UNUSED
FROM UNUSED_ALL       A
       FULL JOIN 
	 UNUSED_EVENTS2   B
       ON A.BASEID  = B.BASEID
	  AND A.ROUND   = B.ROUND_c
      AND A.EVNTNUM = B.EVNTNUM_c
      AND A.UTILNUM = B.UTILNUM_c   ;
QUIT;

DATA mcbsdata.UNUSED_ALL_FLAGGED_&lastyear ;
LENGTH PMEDNAME $350;
SET UNUSED_ALL_FLAGGED;
/*PMEDNAME_NAME=UPCASE(PMEDNAME);
PMSTRUNI=UPCASE(PMSTRUNI);
IF PMSTRUNI='-1' THEN PMSTRUNI='';
PMEDNAME=TRIM(PMEDNAME_NAME)||' '||TRIM(PMSTRUNI);*/
LABEL PMEDNAME = 'NAME OF PRESCRIBED MEDICINE AND STRENGTH TEXT';

IF UNUSED='' THEN UNUSED='DROP';

RUN;


***save distinct names for cleaning;
proc sql; 
create table mcbsdata.unused_names as select distinct
pmedname, pmform as pmformmc, strnunit, strnnum, /* strnuni2, strnnum2*/ pmformfn
from mcbsdata.UNUSED_ALL_FLAGGED_&lastyear;
quit;


/*

*OUTPUT UPDATED FINAL FILE WITH LAST YEAR'S UNUSED EVENTS;
DATA MCBSDATA.FINAL_&CURRYEAR._V2;
SET MCBSDATA.cost&CURRYEAR._final_pm     (IN=A)
    UNUSED_ALL_FLAGGED2 (IN=B);
if a then Y&CurrYear =1;
if b then Y&LastYear =1;
RUN;

TITLE "Duplicate Check for merging of FINAL_&curryear and UNUSED_&lastyear ";
PROC SQL; 
SELECT 
 COUNT(BASEID) AS NUMBER_OF_DUPS, 
 SUM(COUNT)    AS DUP_RECORDS 
FROM 
(SELECT BASEID, EVNTNUM, ROUND, UTILNUM, COUNT(BASEID) AS COUNT
 FROM MCBSDATA.FINAL_&CURRYEAR._V2 
 GROUP BY BASEID, EVNTNUM, ROUND, UTILNUM
 HAVING COUNT(BASEID)>1);
QUIT;title;
