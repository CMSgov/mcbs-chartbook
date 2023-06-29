*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 02_NAME2_MatchClean                                                          |
|      UPDATED: 01/05/2010                                                                   |
|  INPUT FILES: MS Accfile:                                                              |
|               data NDC weights file, First DataBank to MCBS dosage form croswalk file      |
| OUTPUT FILES: MS Access tables: PME_NAMES_[date] (to be cleaned), FDB_GSN_[date]           | 
|               (FDB lookup table), PME_COND_[date] (lookup table of PME conditions)         |
|  DESCRIPTION: Inputs the Westat "final" file to pull all combinations PME name, form,      |
|               & strengths.  Creates FDB file with PDE claim weights at the brand           |
|               name, generic name, strength (1&2), MCBS form and route level.               |
|               Then matches PME combinations to FDB data, first using historical            |
|               matches, then a series of matching algorithms with loosening criteria.       |
|                                                                                            |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear  =20;
%let LastYear  =19;
*%let fdbdate   =20210310; * This is the FDB/NDDF file date;
%let fdbdate   =20210310_wac; * _wac was inserted for re-run after WAC imputation;


%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";


*ods rtf bodytitle file ="&location.Output\02_MatchClean Output - %sysfunc(DATE(),mmddyyd10.).rtf";

***IMPORT HAND-CLEANED PME NAME TO FDB NAME CROSSWALK;

PROC IMPORT OUT= PMENAME_CLEAN 
       DATATABLE= "ALL_FIXED" 
            DBMS= ACCESSCS REPLACE;
        DATABASE= "&location.EDIT\20&CurrYear. drug name match.mdb"; 
        SCANMEMO= YES; USEDATE=NO; SCANTIME=YES;
RUN;

data PMENAME_CLEAN; 
LENGTH BN $60;
SET PMENAME_CLEAN;
KEEP PMEDNAME PMFORM pmform_desc BN Str pmform_fdb_desc;

RUN;

PROC SORT DATA=PMENAME_CLEAN NODUPKEY DUPOUT=DUPS; 
BY PMEDNAME PMFORM  ;
RUN;

PROC PRINT DATA=DUPS (OBS=100) NOOBS;RUN;


*Input FDB GSN-level data with MCBS crosswalked forms;
data FDB_GSN; set MCBSDATA.FDB_GSN_&FDBdate;run;

***FIRST, CHECK THAT ALL BRAND NAMES MATCH FDB;
PROC SQL; 
CREATE TABLE BAD_NAMES AS SELECT  
 A.BN,
 COUNT(A.PMEDNAME) AS COUNT 
FROM PMENAME_CLEAN A
LEFT JOIN FDB_GSN B
ON A.BN=B.BN
WHERE B.BN IS NULL
GROUP BY A.BN;
QUIT;

title "Names that don't match FDB";
title2 "('0' is OK since it represents 'nontranslatable')";
proc print data=bad_names noobs;run;title; title2;


***Second, check the all MCBS Forms are valid;
PROC SQL; 
CREATE TABLE DISTINCT_BN_FORMS AS SELECT DISTINCT BN, PMFORM_FDB_DESC FROM FDB_GSN;
QUIT;
PROC SQL;
CREATE TABLE BAD_FORMS AS SELECT  
 A.BN,
 A.PMFORM_FDB_DESC,
 COUNT(A.PMEDNAME) AS COUNT 
FROM PMENAME_CLEAN A
        LEFT JOIN 
     DISTINCT_BN_FORMS B
        ON A.BN              = B.BN 
       AND A.PMFORM_FDB_DESC = B.PMFORM_FDB_DESC
WHERE A.PMFORM_FDB_DESC IS NOT NULL AND B.PMFORM_FDB_DESC IS NULL
GROUP BY A.BN, A.PMFORM_FDB_DESC;
QUIT;

title "Forms that don't match FDB";
proc print data=bad_forms noobs;run;title; 


***Third, check all strengths are valid;
PROC SQL; 
CREATE TABLE DISTINCT_BN_STR AS SELECT DISTINCT BN, STR FROM FDB_GSN;
QUIT;
PROC SQL;
CREATE TABLE BAD_STRENGTHS AS SELECT  
 A.BN,
 A.STR,
 COUNT(A.PMEDNAME) AS COUNT 
FROM PMENAME_CLEAN A
        LEFT JOIN 
     DISTINCT_BN_STR B
        ON A.BN              = B.BN 
       AND A.STR = B.STR
WHERE A.STR IS NOT NULL AND B.STR IS NULL
GROUP BY A.BN, A.STR;
QUIT;

title "Strengths that don't match FDB";
proc print data=bad_Strengths noobs;run;title; 


***Forth, check all bn, form, strength combos are valid;
PROC SQL; 
CREATE TABLE DISTINCT_BN_STR_FORM AS SELECT DISTINCT BN, STR, PMFORM_FDB_DESC  FROM FDB_GSN;
QUIT;
PROC SQL;
CREATE TABLE BAD_STRENGTH_FORM AS SELECT  
 A.BN,
 A.STR,
 A.PMFORM_FDB_DESC,
 COUNT(A.PMEDNAME) AS COUNT 
FROM PMENAME_CLEAN A
        LEFT JOIN 
     DISTINCT_BN_STR_FORM B
        ON A.BN              = B.BN 
       AND A.STR             = B.STR
	   AND A.PMFORM_FDB_DESC = B.PMFORM_FDB_DESC
WHERE (A.STR IS NOT NULL  AND A.PMFORM_FDB_DESC IS NOT NULL)
  AND (B.STR IS NULL       OR B.PMFORM_FDB_DESC IS NULL)
GROUP BY A.BN, A.STR, A.PMFORM_FDB_DESC;
QUIT;

title "Strengths/form combos that don't match FDB";
proc print data=bad_Strength_FORM noobs;run;title; 


***** FILL IN MISSING FDB STR OR FORM WHEN ONLY 1 STR OR FORM AVAILABLE;
DATA  BSF BSX BXF BXX XXX JUNK;
SET PMENAME_CLEAN;

IF      BN = '0'                                         THEN OUTPUT XXX;
ELSE IF BN NE '' AND STR NE '' AND PMFORM_FDB_DESC NE '' THEN OUTPUT BSF;
ELSE IF BN NE '' AND STR NE '' AND PMFORM_FDB_DESC =  '' THEN OUTPUT BSX;
ELSE IF BN NE '' AND STR =  '' AND PMFORM_FDB_DESC NE '' THEN OUTPUT BXF;
ELSE IF BN NE '' AND STR =  '' AND PMFORM_FDB_DESC =  '' THEN OUTPUT BXX;

ELSE OUTPUT JUNK;

RUN;

***MISSING FORM;
PROC SQL;
CREATE TABLE BN_STR_NODUP AS 
SELECT BN, STR, PMFORM_FDB_DESC, COUNT (BN) AS COUNT
FROM DISTINCT_BN_STR_FORM
GROUP BY BN, STR
HAVING COUNT (BN) =1;
QUIT;


PROC SQL;
CREATE TABLE BSX_FIXED AS SELECT
A.PMEDNAME, A.PMFORM, A.PMFORM_DESC,
A.BN,
A.STR,
B.PMFORM_FDB_DESC

FROM      BSX    A
LEFT JOIN BN_STR_NODUP    B 
 ON A.BN=B.BN
 AND A.STR=B.STR;
QUIT;


***MISSING STRENGTH;
PROC SQL;
CREATE TABLE BN_FORM_NODUP AS 
SELECT BN, STR, PMFORM_FDB_DESC, COUNT (BN) AS COUNT
FROM DISTINCT_BN_STR_FORM
GROUP BY BN, PMFORM_FDB_DESC
HAVING COUNT (BN) =1;
QUIT;

PROC SQL;
CREATE TABLE BXF_FIXED AS SELECT
A.PMEDNAME, A.PMFORM, A.PMFORM_DESC,
A.BN,
B.STR,
A.PMFORM_FDB_DESC

FROM      BXF    A
LEFT JOIN BN_FORM_NODUP    B 
 ON A.BN=B.BN
 AND A.PMFORM_FDB_DESC=B.PMFORM_FDB_DESC;
QUIT;

***MISSING FORM AND STRENGTH;
PROC SQL;
CREATE TABLE BN_NODUP AS 
SELECT BN, STR, PMFORM_FDB_DESC, COUNT (BN) AS COUNT
FROM DISTINCT_BN_STR_FORM
GROUP BY BN
HAVING COUNT (BN) =1;
QUIT;


PROC SQL;
CREATE TABLE BXX_FIXED AS SELECT
A.PMEDNAME, A.PMFORM, A.PMFORM_DESC,
A.BN,
B.STR,
B.PMFORM_FDB_DESC

FROM      BXX    A
LEFT JOIN BN_NODUP    B 
 ON A.BN=B.BN;

QUIT;


*** COMBINE FIXED FILES BACK TOGETHER;
DATA PMENAME_CLEAN2;
SET BSX_FIXED BXF_FIXED BXX_FIXED  BSF XXX;

*Add MCBS form Code;
 if      PMFORM_FDB_DESC ='Pill'                   then PMFORM_FDB=1;
 else if PMFORM_FDB_DESC ='Liquid'                 then PMFORM_FDB=2;
 else if PMFORM_FDB_DESC ='Drops'                  then PMFORM_FDB=3;
 else if PMFORM_FDB_DESC ='Topical ointment'       then PMFORM_FDB=4;
 else if PMFORM_FDB_DESC ='Suppository'            then PMFORM_FDB=5;
 else if PMFORM_FDB_DESC ='Inhalant/aerosol spray' then PMFORM_FDB=6;
 else if PMFORM_FDB_DESC ='Shampoo, soap'          then PMFORM_FDB=7;
 else if PMFORM_FDB_DESC ='Injection'              then PMFORM_FDB=8;
 else if PMFORM_FDB_DESC ='I.V.'                   then PMFORM_FDB=9;
 else if PMFORM_FDB_DESC ='Patch/pad'              then PMFORM_FDB=10;
 else if PMFORM_FDB_DESC ='Topical gel/jelly'      then PMFORM_FDB=11;
 else if PMFORM_FDB_DESC ='Powder'                 then PMFORM_FDB=12;
 else if PMFORM_FDB_DESC ='Other'                  then PMFORM_FDB=91;
 else if PMFORM_FDB_DESC ='Unknown'                then PMFORM_FDB=-1;

run;

PROC SORT DATA =PMENAME_CLEAN2; BY BN STR PMFORM_FDB_DESC; RUN;

*Save Full Crosswalk;
DATA MCBSDATA.PMEDNAME_FDB_&curryear;
SET PMENAME_CLEAN2;
RUN;

*De-dup and save PMEDNAMe to BN crosswalk;
proc sort data=PMENAME_CLEAN2   nodupkey 
            out=MCBSDATA.PMEDNAME_BN_&curryear (keep=pmedname bn);
by pmedname bn;
run;

ods rtf close;


***** ADD GENERIC NAME (PICK MOST FREQUENT IF MULTIPLE GNNS);

*Macro for matching;
%MACRO MATCH (INFILE, MATCH, JOIN);
proc sql; 
create table merge as select  
 A.PMEDNAME, A.PMFORM, A.PMFORM_DESC,
 A.BN,A.STR,A.PMFORM_FDB, A.PMFORM_FDB_DESC,
 b.gnn             as gnn_2,
 b.weight, 
 case when b.bn is not null then "&match" end as match length=3
from      &infile    a
left join FDB_gsn    b 
 on &join ;

create table dups as select 
 PMEDNAME, pmform, pmform_desc, 
 count (pmedname)  as dup_count
from merge
group by PMEDNAME, pmform, pmform_desc 
having count(pmedname) >1 ;

create table dups2 as select a.*, b.dup_count from merge a, dups b 
where a.pmedname=b.pmedname
  and a.pmform  =b.pmform
  and a.pmform_desc  =b.pmform_desc
order by a.PMEDNAME, a.pmform, a.pmform_desc, a.weight desc;
quit;

proc sql; 
create table merge1 as 
select a.*, b.dup_count 
from merge a left join dups b
   on a.pmedname=b.pmedname
  and a.pmform  =b.pmform
  and a.pmform_desc  =b.pmform_desc
 ;
  quit;

proc sort data=merge1; by PMEDNAME pmform pmform_desc descending weight ;run;
proc sort data=merge1 nodupkey; by PMEDNAME pmform pmform_desc  ;run;


data matched&match unmatched;
set merge1;
if match ne "" then output matched&match;
else output unmatched;
run;


%mend;



***Attempt 1:   Match based on BN, STR and MCBS FORM;
%match(  mcbsdata.PMEDNAME_FDB_&curryear, 1, (a.bn = b.bn and a.str = b.str and a.pmform = b.pmform_fdb)  );

***Attempt 2:   Match based on BN and  STR ;
%match(  Unmatched, 2, (a.bn = b.bn and a.str = b.str )  );

***Attempt 3:   Match based on BN and  form ;
%match(  Unmatched, 3, (a.bn = b.bn and a.pmform = b.pmform_fdb )  );

***Attempt 4:   Match based on BN only ;
%match(  Unmatched, 4, (a.bn = b.bn )  );


DATA PMENAME_CLEAN3;
SET 
MATCHED1
MATCHED2
MATCHED3
MATCHED4
UNMATCHED;
drop weight match dup_count;
rename gnn_2=GNN;
RUN;


data mcbsdata.PMEDNAME_FDB_&curryear; set PMENAME_CLEAN3; run;
