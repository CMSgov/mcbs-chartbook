*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 03_PMEDNAME_MERGE                                                       |
|      UPDATED: 01/21/2011                                                              |
|  INPUT FILES: PMEDNAME to BN crosswalk, PDE data NDC weights file, "Final v2" file    |
| OUTPUT FILES: THRUBDMS.txt                                                            |
|  DESCRIPTION: Merges the FDB Brand Name (BN) onto the survey events for use in        |
|               pricing the individual events.                                          |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;

options nofmterr;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear  =20;
%let LastYear  =19;
%let fdbdate   =fdb_20210310;        * This is the FDB/NDDF file date;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";


libname  MCBSDATA "&location";
filename THRUBDMS "&location.THRUBDMS.txt";

ods rtf file ="&location.Output\03_PMEDNAME_MERGE Output - %sysfunc(DATE(),mmddyyd10.).rtf";

/*As of 2015 this is no longer on the mainframe*/
*Readin the FINAL PM SAS survey file from NORC -- 
Y:\Share\IPG\DSMA\MCBS\MCBS Cost Supplement File\2016\Admin\ECC\EC2016.sas7bdat;

libname PMFINAL 'Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2020\Admin\ECC';

/*ECC includes all records need to filter on PM*/

Data MCBSDATA.EC_PM (compress=yes); /*file usually called cost&curryear._final_pm -- will
rename this later on*/
set PMFINAL.EC2020; **update**;
if EVNTTYPE = 'PM' then output MCBSDATA.EC_PM; /*MCBSDATA.cost&curryear._final_pm;*/
proc sort; by baseid EVNTNUM; run;


/*Temp fix for 2016*/
/*When the ECC was originally delivered already valid PMENAMES
were not copied onto the final file -- NORC sent a supplement file
to be merged to the ECC*/
/*
Data MCBSDATA.EC_NAMES;
set PMFINAL.EC17_PMEDNAME;
proc sort; by baseid EVNTNUM; run;

*------------------Hafiz;
proc sql;
create table mcbsdata.cost16 as
select A.*
, Coalesce(A.pmedname, B.pmedname) as pmedname_1
, coalesce(A.PMSTRUNI, B.PMSTRUNI) as PMSTRUNI_1
, B.pname
from MCBSDATA.EC_PM as A full join MCBSDATA.EC_NAMES as B on
A.baseid=B.baseid and A.evntnum=B.evntnum;
quit;

DATA MCBSDATA.cost&curryear._final_pm;
set mcbsdata.cost16 (drop=pmedname pmstruni);
rename pmedname_1=pmedname;
rename PMSTRUNI_1=pmstruni;
proc sort; by baseid; run;
*/

/*END of temp fix for 2016*/

/*renaming the file here to historic name*/
data MCBSDATA.cost&curryear._final_pm (compress=yes); 
set MCBSDATA.EC_PM;

/*Certain vars were changed to numeric by NORC -- 
for ease of processing those were changed to character*/
*char_id = put(id, 7.) ;
*drop id ;
*rename char_id=id ;
evntnum_c = put(evntnum,z3.);
round_c = put(round,2.);
costnum_c = put(costnum,z3.);
utilnum_c = put(utilnum,z4.);
evntprov_c = put(evntprov,z2.);
rentrecr_c = put(rentrecr,2.);
rentendr_c = put(rentendr,2.);
pymntrnd_c = put(pymntrnd,2.);
ev95flg_c = put(ev95flg,2.);
costrndc_c = put(costrndc,2.);
orignsev_c = put(orignsev,z3.);
corornd1_c = put(corornd1,2.);
corornd2_c = put(corornd2,2.);
corornd3_c = put(corornd3,2.);
xcevrndc_c = put(xcevrndc,2.);
cosarndc_c = put(cosarndc,2.);
drop  evntnum round costnum utilnum evntprov
rentrecr rentendr pymntrnd ev95flg costrndc 
orignsev corornd1 corornd2 corornd3 xcevrndc 
cosarndc;
rename evntnum_c=evntnum;
rename round_c = round;
rename costnum_c = costnum;
rename utilnum_c = utilnum;
rename evntprov_c = evntprov;
rename rentrecr_c = rentrecr;
rename rentendr_c = rentendr;
rename pymntrnd_c = pymntrnd;
rename ev95flg_c = ev95flg;
rename costrndc_c = costrndc;
rename orignsev_c = orignsev;
rename corornd1_c = corornd1;
rename corornd2_c = corornd2;
rename corornd3_c = corornd3;
rename xcevrndc_c = xcevrndc;
rename cosarndc_c = cosarndc;

/*fix 2017*/
/*if pmform = . then pmform=pmformmc;*/


proc freq data=MCBSDATA.cost&curryear._final_pm; 
TABLES PMFORMMC/LIST MISSING ;
*tables PMFORMFN*PMFORMMC/list missing;
TITLE '2020 PMFORMMC';
run;

data MCBSDATA.UNUSED_ALL_FLAGGED_&lastyear;
set MCBSDATA.UNUSED_ALL_FLAGGED_&lastyear;
proc sort; by baseid; run;

*CREATE UPDATED FINAL FILE WITH LAST YEAR'S UNUSED EVENTS;
DATA MCBSDATA.FINAL_&CURRYEAR._V2;
LENGTH PMEDNAME $350 pmformmc 8. strnunit 8. strnnum 8.  pmstruni $150;
SET MCBSDATA.cost&CURRYEAR._final_pm      (IN=A)
    MCBSDATA.UNUSED_ALL_FLAGGED_&lastyear  (IN=B);
if a then Y&CurrYear =1;
if b then Y&LastYear =1;

*ADD PMEDNAME;
if a then 
do;
 PMEDNAME_OLD=PMEDNAME; 

 PMEDNAME_NAME=UPCASE(PMEDNAME);
 PMSTRUNI=UPCASE(PMSTRUNI);
 IF PMSTRUNI='-1' THEN PMSTRUNI='';
 PMEDNAME=TRIM(PMEDNAME_NAME)||' '||TRIM(PMSTRUNI);
 LABEL PMEDNAME = 'NAME OF PRESCRIBED MEDICINE AND STRENGTH TEXT';
 DROP PMEDNAME_NAME;
end;

RUN;

*PROC SORT DATA=MCBSDATA.FINAL_&CURRYEAR._V2;    *BY pmedname PMFORMMC STRNUNIT STRNNUM; *RUN;


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


***WORKING FILE OF Current Final File and last year's Unused Events;
DATA FINAL_&CURRYEAR;
set MCBSDATA.FINAL_&CURRYEAR._V2
        (KEEP=PMEDNAME pname PMFORMMC STRNNUM STRNUNIT AMTNUM AMTUNIT SUPPNUM TABNUM TABSADAY TABTAKE 
               BASEID EVNTNUM ROUND UTILNUM COMPFLAG AMTNUM2 AMTUNIT2 PMCOND PMKNWNM y&curryear y&lastyear);

/*LENGTH PMEDNAME $350 pmform 8. strnunit 8. strnuni2 8. strnnum 8. strnnum2 8. pmstruni $150;*/
rename PMFORMMC=PMFORM;


run;

***IMPORT UPDATED PMEDNAME TO BN CROSSWALK FILE;
DATA PMEDNAME_FDB_&CURRYEAR; LENGTH PMEDNAME $350;
SET MCBSDATA.PMEDNAME_FDB_&CURRYEAR;
LENGTH pmform 8. /*strnunit 8. strnnum 8.*/;
RUN;
 
PROC SORT DATA=FINAL_&CURRYEAR;                 BY pmedname PMFORM STRNUNIT STRNNUM; RUN;
PROC SORT DATA=PMEDNAME_FDB_&CURRYEAR nodupkey; BY pmedname PMFORM /*STRNUNIT STRNNUM*/; RUN;


DATA TOG mcbsdata.WHY;
length pmform 8. strnunit 8. strnnum 8.;

MERGE FINAL_&CurrYear          (IN=A) 
      PMEDNAME_FDB_&CURRYEAR   (IN=B);
BY pmedname PMFORM /*STRNUNIT STRNNUM*/ ;
IF A ;

PMROID=BASEID||EVNTNUM||ROUND;
/*if a and b then output tog; 
else if a then output mcbsdata.why;*/

IF A AND (NOT B) THEN OUTPUT mcbsdata.WHY;
else IF A THEN output TOG;
run;


TITLE "THESE EVENTS DID NOT MATCH TO THE PMEDNAME / FDB CROSSWALK!!!";
PROC PRINT DATA=mcbsdata.WHY (OBS=500);RUN;TITLE;

TITLE "Duplicate Check for merging of FINAL_&curryear and PMEDNAME to FDB crosswalk";
PROC SQL; 
SELECT 
 COUNT(BASEID) AS NUMBER_OF_DUPS, 
 SUM(COUNT)    AS DUP_RECORDS 
FROM 
(SELECT BASEID, EVNTNUM, ROUND, UTILNUM, COUNT(BASEID) AS COUNT
 FROM TOG
 GROUP BY BASEID, EVNTNUM, ROUND, UTILNUM
 HAVING COUNT(BASEID)>1);
QUIT;title;


DATA _NULL_; /*2013 UPDATED INPUTS TO ADJUST FOR UTILNUM*/
SET TOG;
FILE THRUBDMS;
PUT    
@ 1    PMROID	$CHAR13.
@ 14   BN		$CHAR60.
@ 74   PMFORM	8.
@ 82   STRNNUM	8.
@ 90   STRNUNIT	8.
@ 99   UTILNUM	$CHAR4.
@ 103  AMTNUM	5.
@ 108  AMTUNIT	3.	
@ 111  SUPPNUM	3.
@ 114  TABNUM	4.
@ 118  TABSADAY	3.	
@ 124  TABTAKE	3.
@ 130  COMPFLAG	3.
@ 133  AMTNUM2	5.
@ 138  AMTUNIT2	3.
@ 141  PMCOND	8.
@ 149  PMKNWNM	8.
;
run;
ods rtf close;
