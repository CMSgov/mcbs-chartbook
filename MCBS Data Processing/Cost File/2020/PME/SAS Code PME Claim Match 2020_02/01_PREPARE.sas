*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 01_PREPARE                                                                   |
|      UPDATED: 03/26/2010                                                                   |
|  INPUT FILES: "FINAL v2" file, current year PMED to FDB crosswalk, PDE claim               |
|               data file, First DataBank GSN level file, MCBS to CCWID crossawlk            |
|               current "people" file, timeline file                                         |
| OUTPUT FILES: MATCH_START_SURVEY AND MATCH_START_PDE                                       |
| DESCRIPTION: Inputs PDE data for all MCBS benes and crosswalks IDs.  Assigns FDB drug info|
|               to PDE data and assigns MCBS round number.  Inputs the Westat "final" file   |
|               and merges on cleaned fdb drug info.  Winnows out survey folks who do not    |
|               have PDE claims or who do not have pm events.                                |
|                                                                                            |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ods html close;
ods html;
option nofmterr;

*NOTE: MAINFRAME FILE NEEDED: MF00.@BLV3380.MCBS.COST{YY}.TIMELINE.FINAL;


OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;
%let CurrYear  =20;
%let LastYear  =19;
%let rnd1 =86;
%let rnd2 =87;
%let rnd3 =88; 
%let rnd4 =89; 
%let FDBdate = 20210310_wac; *this is the date of the FDB file;



%macro namefix();
*CREATE FIRST WORD GNN VARIABLE;
IF length(kscan(GNN,1) )>3 then GNN2=kscan(GNN,1); ELSE GNN2=GNN;
*RECODE SPECIAL CASES;
IF GNN="AMOX TR/POTASSIUM CLAVULANATE"  THEN GNN2="AMOXICILLIN TRIHYDRATE";
IF INDEX(UPCASE(GNN),'METOPROL'     )>0 THEN GNN2="METOPROLOL";
IF INDEX(UPCASE(GNN),'ALENDRONATE'  )>0 THEN GNN2="ALENDRONATE";
IF INDEX(UPCASE(GNN),'ATENOLOL'     )>0 THEN GNN2="ATENOLOL";
if INDEX(UPCASE(GNN),'NITROFURAN'   )>0 THEN GNN2='NITROFURANTOIN';
if INDEX(UPCASE(GNN),'AMLODIPINE'   )>0 THEN GNN2='AMLODIPINE';
%mend;


%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
%let cost = Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2020\Admin\Weights\Data Files;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";
Libname cost "&cost";

******************************************************;
*Create people file here first with correct pop count*;
******************************************************;
data cost;
set cost.annu&CURRYEAR._f (keep=baseid);
proc sort; by baseid; run;

data pop;
set mcbsdata.pop_&CURRYEAR (keep=baseid);
proc sort; by baseid; run;

data mcbsdata.people_&CURRYEAR;
merge cost (in=a) pop (in=b);
by baseid; if a;
run;


*******************************************************************************************;
* STEP 1: CROSSWALK CCW IDS TO MCBS IDS IN PDE DATA                                       *;
*******************************************************************************************;

*GET PDE RECORDS;
DATA PDE_ALL; SET MCBSDATA.MCBS_PDE_20&CURRYEAR; RUN;

*Get Crosswalk;
data MCBS_CCW_XWALK; set mcbsdata.MCBS_CCW_XWALK_&curryear; run;

***REMOVE DUPLICATES (IF PRESENT);
PROC SORT DATA=PDE_ALL         NODUPKEY DUPOUT=PDE_DUPS    ; BY PDE_ID; RUN;
PROC SORT DATA=MCBS_CCW_XWALK                              ; BY DESCENDING BENE_ID;RUN;
PROC SORT DATA=MCBS_CCW_XWALK  NODUPKEY DUPOUT=BASEID_DUPS2; BY BASEID;RUN;


***ADD BASEID AND LIMIT TO CURRENT MCBS BENES;
PROC SQL; 
CREATE TABLE PDE_BASEID AS SELECT 
A.BASEID,
B.*
FROM MCBS_CCW_XWALK  A   right JOIN PDE_ALL B   ON A.BENE_ID=B.BENE_ID;
QUIT; 


*******************************************************************************************;
* STEP 2: TRANSLATE PDE NDCS INTO BN, GNN, STR, MCBS_FORM                                 *;
*******************************************************************************************;

PROC SQL;
CREATE TABLE PDE AS SELECT
P.*,
F.GCN_SEQNO, F.BN, F.GNN,  F.STR,  F.FORM,  F.RT, F.STR1, F.STR2, 
X.MCBS_FORM_CODE, X.MCBS_FORM
FROM PDE_BASEID P 
LEFT JOIN MCBSDATA.FDB_&FDBDATE F ON P.PROD_SRVC_ID = F.NDC
LEFT JOIN MCBSDATA.ROUTE_FORM_XWALK_&CURRYEAR X ON F.GCDF = X.GCDF AND F.GCRT = X.GCRT;
QUIT;

*******************************************************************************************;
* STEP 3. ADD ROUND NUMBERS TO PDE DATA BASED ON INTERVIEW DATES                          *;
*******************************************************************************************;
data mcbsdata.TIMELINE_FINAL_20; /*UPDATE*/
   set mcbsdata.ref2020; /*UPDATE*/
   format INTVDATE date9.;
run;


proc sql;
create table timeline_baseid as select distinct baseid, 1 as timeline from MCBSDATA.timeline_final_&CURRYEAR;
create table people_baseid   as select distinct baseid, 1 as people   from MCBSDATA.people_&CURRYEAR;
create table pme_baseid   as select distinct baseid, 1 as pme   from MCBSDATA.cost&CURRYEAR._final_pm;

quit;

data combined; merge people_baseid pme_baseid timeline_baseid; by baseid;run;

****Assign rounds to interview dates;
*GET INTERVIEW DATES;
PROC SORT DATA=MCBSDATA.timeline_final_&CURRYEAR
           OUT=INTERVIEW_DATES (KEEP=BASEID DOD ROUND INTVDATE);
	       BY BASEID ROUND DESCENDING INTVDATE;
RUN;

*IF MULTIPLE INTERVIEW DATES WITHIN A ROUND CHOOSE LATEST (NOTE SORTED DESCNEDING ABOVE);
PROC SORT DATA=INTERVIEW_DATES NODUPKEY DUPOUT=INTVDUPS;  BY BASEID ROUND; RUN;

data INTERVIEW_DATES ; set INTERVIEW_DATES;
if round in ("&rnd1","&rnd2","&rnd3","&rnd4");
run;


*TRANSPOSE DATES ;
PROC TRANSPOSE DATA=INTERVIEW_DATES OUT=DATES_TRANSPOSED;
BY BASEID DOD;
VAR INTVDATE ;
ID ROUND;
RUN;

DATA DATES_TRANSPOSED;
SET DATES_TRANSPOSED;
KEEP  BASEID DOD _&RND1 - _&RND4; 
RENAME _&RND1 = R&RND1 
       _&RND2 = R&RND2 
       _&RND3 = R&RND3 
       _&RND4 = R&RND4 
       DOD=H_DOD;
run;

data rounds;
set dates_transposed;
if r&RND4 =. then r&RND4 = "01jan2999"d ;
format r&RND1 r&RND2 r&RND3 r&RND4  date9.;
run;

 
* Use this date vector to assign a round number To the PDE events, using the fill date (SRVC_DT) to do so.	;
* Note: if service date is missing, assigns the earliest round;
PROC SORT DATA=ROUNDS; BY BASEID; RUN;
proc sort data=pde; by baseid;run;

data PDE_FINAL
     check1_pdeonly    (keep=baseid round fill SRVC_DT r&RND1-r&RND4)
     check1_round_only (keep=baseid round fill SRVC_DT r&RND1-r&RND4)
	 check2 (keep=baseid round fill SRVC_DT r&RND1-r&RND4); 

merge PDE (in=a)
   rounds (in=b);
by baseid;
	length round $2 ;


format fill date9.;
FILL=DATEPART(SRVC_DT);

     if FILL < r&RND1 then round="&RND1";
else if FILL < r&RND2 then round="&RND2";
else if FILL < r&RND3 then round="&RND3";
else if FILL < r&RND4 then round="&RND4"; 
	                     else round='00';

*output;
if a and b then output PDE_FINAL;

*checks;
 if (a and (not b)) then output check1_pdeonly   ; 
 if (b and (not a)) then output check1_round_only;
 if (a and b) 
   and (round not in ("&RND1","&RND2","&RND3","&RND4") 
        or fill<"01jan20&CURRYEAR"d or fill>"31dec20&CURRYEAR"d ) then output check2;
run;

proc sql; 
select count(distinct(baseid)) as pde_only_benes from check1_pdeonly;
select count(distinct(baseid)) as round_only_benes from check1_round_only;
quit;


proc freq data=pde_FINAL;
tables round/missing;
run;


*******************************************************************************************;
* STEP 4. PREPARE SURVEY DATA FOR MATCHING                                                *;
*******************************************************************************************;

***IMPORT CURRENT FINAL FILE AND LAST YEAR'S UNUSED EVENTS ;
DATA FINAL;
set MCBSDATA.FINAL_&CURRYEAR._V2
        (KEEP=PMEDNAME PMFORMMC STRNNUM STRNUNIT AMTNUM AMTUNIT SUPPNUM TABNUM TABSADAY TAKEUNIT TABTAKE TAKENUM 
              BASEID EVNTNUM COSTNUM ROUND UTILNUM COND1 COND2 COMPFLAG AMTNUM2 AMTUNIT2 /*STRNNUM2 STRNUNI2*/ UNUSED 
		/*KEYNAME added in 2013 due to high number of unmatch*/);
		rename PMFORMMC = PMFORM;
WHERE UNUSED NE "DROP"; DROP UNUSED;
run;

***IMPORT UPDATED PMEDNAME TO BN CROSSWALK FILE;
DATA PMEDNAME_FDB_&CURRYEAR; SET MCBSDATA.PMEDNAME_FDB_&CURRYEAR ; RUN;


/*2013 -- ADDED SORT AND MERGE BY KEYNAME BECAUSE OF HIGH NUMBER OF UNMATCHED PMED NAMES*/
/*2016 merging on original variables*/

***MERGE ON CLEANED PMEDNAMES;
PROC SORT DATA=FINAL ;                 BY /*KEYNAME*/PMEDNAME  PMFORM STRNUNIT STRNNUM; RUN;
PROC SORT DATA=PMEDNAME_FDB_&CURRYEAR NODUPKEY ;BY /*KEYNAME*/ PMEDNAME  PMFORM /*STRNUNIT STRNNUM*/; RUN;

DATA FINAL2 WHY;
MERGE FINAL                   (IN=A) 
      PMEDNAME_FDB_&CURRYEAR  (IN=B);
BY /*KEYNAME*/PMEDNAME  PMFORM /*STRNUNIT STRNNUM*/;
IF A THEN OUTPUT FINAL2;
IF A AND NOT B THEN OUTPUT WHY;

run;


***LIMIT TO IMPUTED EVENTS;
proc sql;
create table PME_FINAL as 
select a.* 
from 
  FINAL2 a 
    right join 
  MCBSDATA.TOWESTAT_&CURRYEAR b 
       on a.baseid  =b.baseid
      and a.EVNTNUM =b.EVNTNUM 
      and a.ROUND   =b.ROUND 
      and a.UTILNUM =b.UTILNUM   ;
quit;


*******************************************************************************************;
* STEP 5. WINNOW OUT SURVEY FOLKS WHO DO NOT HAVE PDE CLAIMS OR WHO DO NOT HAVE PM EVENTS *;
*******************************************************************************************;

PROC SUMMARY DATA=PDE_FINAL NWAY;
	CLASS BASEID;
	OUTPUT OUT=PDE_GUYS (KEEP=BASEID);
	RUN;
PROC SUMMARY DATA=PME_FINAL NWAY;
	CLASS BASEID;
	OUTPUT OUT=PM_GUYS (KEEP=BASEID);
	RUN;

DATA PME_FINAL; SET PME_FINAL (RENAME=PMFORM_FDB_DESC=MCBS_FORM);
length pmedid $17;/*UPDATE for 2013 UTILNUM LENGTH CHANGE*/
PMEDID=TRIM(BASEID)||TRIM(EVNTNUM)||TRIM(ROUND)||TRIM(UTILNUM);

IF BN NE '' THEN 
DO;
  IF GNN       ='' THEN GNN      ='-1';
  IF STR       ='' THEN STR      ='-1';
  IF MCBS_FORM ='' THEN MCBS_FORM='-1';
END;


*FIX NAMES (see macro definition at top of code);
%namefix;

GSF = TRIM(GNN)||" "||TRIM(STR)||" "||TRIM(MCBS_FORM);

RUN;
*KEEP FULL PME SET FOR LATER;
DATA MCBSDATA.PME_NAME_CLEANED_20&CURRYEAR; SET PME_FINAL ;RUN;

PROC SORT DATA=PME_FINAL ; BY BASEID;RUN;

DATA SURVEY ;
MERGE PME_FINAL (IN=A)
      PDE_GUYS  (IN=B);
BY BASEID;
IF A AND B;
KEEP BASEID ROUND COSTNUM PMEDID PMEDNAME BN GNN STR MCBS_FORM GSF GNN2;
RUN;

DATA PDE_FINAL;
SET PDE_FINAL;
IF BN NE '' THEN 
DO;
  IF GNN       ='' THEN GNN      ='-1';
  IF STR       ='' THEN STR      ='-1';
  IF MCBS_FORM ='' THEN MCBS_FORM='-1';
END;

*FIX NAMES (see macro definition at top of code);
%namefix;

GSF = TRIM(GNN)||" "||TRIM(STR)||" "||TRIM(MCBS_FORM);
RUN;
*KEEP FULL PDE SET FOR LATER;
DATA MCBSDATA.MCBS_PDE_20&CURRYEAR._ONLY; SET PDE_FINAL ;RUN;

DATA PDE;
MERGE PDE_FINAL (IN=A)
      PM_GUYS   (IN=B);
BY BASEID;
IF A AND B;* AND PDE21 NE "P"; * THIS GETS RID OF PARTIAL-FILLS;
KEEP BASEID PDE_ID ROUND BN GNN STR MCBS_FORM GSF GNN2;
RUN;

*******************************************************************************************;
* STEP 6. MAKE PERMANENT PDE AND SURVEY FILES TO START MATCH PROCESS                      *;
*******************************************************************************************;

data mcbsdata.MATCH_START_SURVEY; SET SURVEY;RUN;
data mcbsdata.MATCH_START_PDE;    SET PDE   ;RUN;


