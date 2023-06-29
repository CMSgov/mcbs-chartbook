*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 02_NAME1_CompMatch                                                           |
|      UPDATED: 01/05/2010                                                                   |
|  INPUT FILES: "FINAL v2" file, prior year PMED to FDB GSN crosswalk, PDE claim             |
|               data NDC weights file, First DataBank GSN level file  , PMEDNAME (names to   |
|				clean from WESTAT)                                                           |
| OUTPUT FILES: MS Access tables (Drug Name Match.mdb): PME_NAMES_[date] (to be cleaned)     |
|               FDB_GSN_[date] (FDB lookup table), PME_COND_[date] (PME conditions)          |
|  DESCRIPTION: Inputs the Westat "final" file to pull all combinations PME name, form,      |
|               & strengths.  Inputs FDB GSN level file.                                     |
|               Then matches PME combinations to FDB data, first using historical            |
|               matches, then a series of matching algorithms with loosening criteria.       |
|                                                                                            |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;

ODS HTML CLOSE;
  ODS HTML;

 options nofmterr;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let reviewer_no=6;
%let rev1=Bill;
%let rev2=Hafiz;
%let rev3=Michael;
%let rev4=Joe;
%let rev5= Nic;
%let rev6= Maggie;
*%let rev7= Bill;


%let CurrYear  =20;
%let LastYear  =19;
%let fdbdate   =20210310;         * This is the FDB/NDDF file date;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";


data mcbsdata.pmed20&curryear;
length pmedname $350 /*updated for 2016*/
	   pmformmc 8. 
	   /*update for 2018*/
	   /*strnunit 8. strnuni2 8.*/
	   /*strnnum 8. /*strnnum2 8.*/;
set mcbsdata.NORC_pmed20&curryear;
rename PMFORMMC = PMFORM;
pmedname_name=upcase(pmedname);
pmstruni=upcase(pmstruni);
if pmstruni='-1' then pmstruni='';

pmedname=trim(pmedname_name)||' '||trim(pmstruni);

label pmedname = 'NAME OF PRESCRIBED MEDICINE AND STRENGTH TEXT';
run;

proc sort data=mcbsdata.pmed20&curryear nodupkey;
by pmedname pmform  /*update for 2019*/ /*strnunit strnnum strnuni2 strnnum2*/;
run;


***CONDITIONS;
**Data was discontinued beginning in 2012;
/*libname pcnd XPORT "&location\pcnd20&curryear..xpt" 
data conditions; set pcnd.pcnd20&curryear; rename pmedname=pmedname_name;run;

proc sql;
create table mcbsdata.pcnd20&curryear
as select distinct
a.pmedname,
b.cond1
from mcbsdata.pmed20&curryear a
left join conditions  b on a.pmedname_name=b.pmedname_name;
quit;*/


*Input FDB GSN-level data with MCBS crosswalked forms;
data FDB_GSN; 
set MCBSDATA.FDB_GSN_&FDBdate;

*recodes;
if gnn='ALBUTEROL SULFATE'       then gnn ='ALBUTEROL';
if index(gnn,'NITROFURANTOIN')>0 then gnn='NITROFURANTOIN';

*remove bulk chemical powders;
if etc_name='Bulk Chemicals' then delete;
run;

*2019 Rename PMFORMMC to PMFORM;
data MCBSDATA.UNUSED_NAMES;
set MCBSDATA.UNUSED_NAMES;
*rename pmformmc = pmform;
run;

proc sort data= MCBSDATA.UNUSED_NAMES;
by pmedname;
run;

*Input distinct pmednames new and unused from last year) and dedup ;
data PMEDNAMES_NEW; 
set MCBSDATA.Pmed20&CURRYEAR 
    MCBSDATA.UNUSED_NAMES;
run;

proc sort data= PMEDNAMES_NEW nodupkey;
by pmedname pmform  /*update for 2019*/ /*strnunit strnnum strnuni2 strnnum2*/;
run;


DATA PMEDNAMES_OLD; 
LENGTH PMEDNAME $350;****TEMP FIX FOR 2009;
LENGTH PMFORMMC 8.;
SET MCBSLAST.PMEDNAME_FDB_&LASTYEAR;
IF GNN='' THEN GNN='-1';
if str='' then str='-1';
IF pmform_fdb_desc='' THEN pmform_fdb_desc='-1';
IF pmform_fdb=. THEN pmform_fdb=-1;

RUN;

*2019 rename PMFORMMC to PMFORM;
data PMEDNAMES_OLD;
set PMEDNAMES_OLD;
rename pmformmc=pmform;
run;

***Match new PME data to old PME previously matched;
proc sort data=PMEDNAMES_NEW nodupkey; by pmedname pmform  /*update for 2019*/ /*strnunit strnnum strnuni2 strnnum2*/ ;run;
proc sort data=PMEDNAMES_old nodupkey; by pmedname pmform  /*update for 2019*/ /*strnunit strnnum strnuni2 strnnum2*/;run;

data pme_history;
merge PMEDNAMES_NEW (in=a)
      PMEDNAMES_old (in=b); 
by pmedname pmform /*update for 2019*/ /*strnunit strnnum strnuni2 strnnum2*/;
if a or b;
new=a;
old=b;
drop pmform_desc ;

run;

*Update FDB data for prior matches via crosswalk;

/*PROC SQL;
CREATE TABLE PME_HISTORY2 AS SELECT
 A.PMEDNAME,
 A.PMFORM, 
 A.STRNUNIT,
 A.STRNNUM,
 A.STRNUNI2,
 A.STRNNUM2,

 A.BN           AS BN_OLD,
 A.GNN          AS GNN_OLD,
 A.STR          AS STR_OLD,
 A.PMFORM_FDB   AS MCBS_FORM_CODE_OLD,
 A.NEW,
 A.OLD,

 F.BN , 
 F.GNN,
 F.STR,
 F.MCBS_FORM_CODE
FROM PME_HISTORY A
 LEFT JOIN MCBSDATA.FDB_XWALK_&LASTYEAR._TO_&CURRYEAR    F
   ON A.BN         = F.BN_LAST
  AND A.GNN        = F.GNN_LAST
  AND A.STR        = F.STR_LAST
  AND A.PMFORM_FDB = F.MCBS_FORM_CODE_LAST;
QUIT;

DATA PME_HISTORY2; SET PME_HISTORY2;
IF BN_OLD = '0' THEN DO
 BN='0';
 GNN='-1';
 str='-1';
 MCBS_FORM_CODE=-1;
END;
RUN;


data matched_prior1 unmatched;
set PME_HISTORY2;
if bn ne '' then 
 do;
   length match $3;
   match='p1';
   output matched_prior1;
 end;
else output unmatched;
run;

*SKIP FOR 2018??;
***IF ONLY NAME AND STRENGTH MATCHED;
PROC SQL;
CREATE TABLE BN_STR_XWALK AS SELECT 
 BN_LAST, GNN_LAST, STR_LAST, 
 BN,      GNN ,     STR ,     
 SUM(CLAIMS_LAST) AS CLAIMS_LAST,
 SUM(CLAIMS)      AS CLAIMS
FROM MCBSDATA.FDB_XWALK_&LASTYEAR._TO_&CURRYEAR
GROUP BY  BN_LAST, GNN_LAST, STR_LAST, 
          BN,      GNN ,     STR 
;
QUIT;

PROC SORT DATA=BN_STR_XWALK;
BY BN_LAST GNN_LAST STR_LAST DESCENDING CLAIMS DESCENDING CLAIMS_LAST;
RUN;
PROC SORT DATA=BN_STR_XWALK NODUPKEY; 
BY BN_LAST GNN_LAST STR_LAST;
RUN;


PROC SQL;
CREATE TABLE PME_HISTORY3 AS SELECT
 A.PMEDNAME, A.PMFORM , A.STRNUNIT, A.STRNNUM, A.STRNUNI2, A.STRNNUM2,
 A.BN_OLD,  A.GNN_OLD,  A.STR_OLD,  A.MCBS_FORM_CODE_OLD,
 A.NEW, A.OLD,

 F.BN ,  
 F.GNN, 
 F.STR, 
 -1 as MCBS_FORM_CODE

FROM UNMATCHED A
 LEFT JOIN BN_STR_XWALK    F
   ON A.BN_OLD         = F.BN_LAST
  AND A.GNN_OLD        = F.GNN_LAST
  AND A.STR_OLD        = F.STR_LAST;
QUIT;

data matched_prior2 unmatched;
set PME_HISTORY3;
if bn ne '' then 
 do;
   length match $3;
   match='p2';
   output matched_prior2;
 end;
else output unmatched;
run;

***IF ONLY NAME AND FORM MATCHED;
PROC SQL;
CREATE TABLE BN_FORM_XWALK AS SELECT 
 BN_LAST, GNN_LAST, MCBS_FORM_CODE_LAST, 
 BN,      GNN ,     MCBS_FORM_CODE ,     
 SUM(CLAIMS_LAST) AS CLAIMS_LAST,
 SUM(CLAIMS)      AS CLAIMS
FROM MCBSDATA.FDB_XWALK_&LASTYEAR._TO_&CURRYEAR
GROUP BY  BN_LAST, GNN_LAST, MCBS_FORM_CODE_LAST, 
          BN,      GNN ,     MCBS_FORM_CODE 
;
QUIT;

PROC SORT DATA=BN_FORM_XWALK;
BY BN_LAST GNN_LAST MCBS_FORM_CODE_LAST DESCENDING CLAIMS DESCENDING CLAIMS_LAST;
RUN;
PROC SORT DATA=BN_FORM_XWALK NODUPKEY; 
BY BN_LAST GNN_LAST MCBS_FORM_CODE_LAST;
RUN;


PROC SQL;
CREATE TABLE PME_HISTORY4 AS SELECT
 A.PMEDNAME, A.PMFORM , A.STRNUNIT, A.STRNNUM, A.STRNUNI2, A.STRNNUM2,
 A.BN_OLD,  A.GNN_OLD,  A.STR_OLD, A.MCBS_FORM_CODE_OLD,
 A.NEW, A.OLD,

 F.BN ,  
 F.GNN, 
 '-1' AS STR, 
 F.MCBS_FORM_CODE

FROM UNMATCHED A
 LEFT JOIN BN_FORM_XWALK    F
   ON A.BN_OLD            = F.BN_LAST
  AND A.GNN_OLD           = F.GNN_LAST
  AND A.MCBS_FORM_CODE_OLD     = F.MCBS_FORM_CODE_LAST;
QUIT;

data matched_prior3 unmatched;
set PME_HISTORY4;
if bn ne '' then 
 do;
   length match $3;
   match='p3';
   output matched_prior3;
 end;
else output unmatched;
run;

***IF ONLY NAME MATCHED;
PROC SQL;
CREATE TABLE BN_XWALK AS SELECT 
 BN_LAST, GNN_LAST,  
 BN,      GNN ,          
 SUM(CLAIMS_LAST) AS CLAIMS_LAST,
 SUM(CLAIMS)      AS CLAIMS
FROM MCBSDATA.FDB_XWALK_&LASTYEAR._TO_&CURRYEAR
GROUP BY  BN_LAST, GNN_LAST, 
          BN,      GNN;
QUIT;

PROC SORT DATA=BN_XWALK;
BY BN_LAST GNN_LAST  DESCENDING CLAIMS DESCENDING CLAIMS_LAST;
RUN;
PROC SORT DATA=BN_XWALK NODUPKEY; 
BY BN_LAST GNN_LAST;
RUN;


PROC SQL;
CREATE TABLE PME_HISTORY5 AS SELECT
 A.PMEDNAME, A.PMFORM, A.STRNUNIT, A.STRNNUM, A.STRNUNI2, A.STRNNUM2,
 A.BN_OLD,  A.GNN_OLD,  A.STR_OLD, A.MCBS_FORM_CODE_OLD,
 A.NEW, A.OLD,

 F.BN ,  
 F.GNN, 
 '-1' AS STR, 
 -1 AS MCBS_FORM_CODE

FROM UNMATCHED A
 LEFT JOIN BN_XWALK    F
   ON A.BN_OLD            = F.BN_LAST
  AND A.GNN_OLD           = F.GNN_LAST;
QUIT;

data matched_prior4 unmatched;
set PME_HISTORY5;
if bn ne '' then 
 do;
   length match $3;
   match='p4';
   output matched_prior4;
 end;
else output unmatched;
run;


DATA MATCHED_PRIOR;
SET MATCHED_PRIOR1 MATCHED_PRIOR2 MATCHED_PRIOR3 MATCHED_PRIOR4;
drop BN_OLD GNN_OLD STR_OLD MCBS_FORM_CODE_OLD ;
rename mcbs_form_code=pmform_fdb;
RUN;*/

DATA UNMATCHED; SET PMEDNAMES_NEW /*UNMATCHED*/ ;
KEEP pmedname pmform /*strnunit strnnum strnuni2 strnnum2*/ /*NEW OLD*/;

RUN;


*Seperate PME data into names with strengths (i.e., numbers) and no strengths;
data pme_str pme_nostr;
set UNMATCHED;
if indexc(pmedname,'1''2''3''4''5''6''7''8''9''0')>0 then output pme_str;
else output pme_nostr;
run;

*Macro for matching;
%macro match (infile, match, join);
proc sql; 
create table merge as select  
 a.PMEDNAME, a.pmform,/*2019*/  /*a.strnunit, a.strnuni2, a.strnnum, a.strnnum2,*/ /*a.new, a.old,*/
 b.gsn,
 b.bn,
 b.gnn,
 b.str,
 b.form,
 b.route,
 b.str1,
 b.str2,
 b.pmform_fdb,
 b.weight, 
 case when b.bn is not null then "&match" end as match length=3
from      &infile    a
left join FDB_gsn    b 
 on &join ;

create table dups as select 
PMEDNAME, pmform, /*strnunit, strnuni2,strnnum,strnnum2,*/
count (pmedname)  as count
from merge
group by PMEDNAME, pmform /*strnunit, strnuni2, strnnum strnnum2*/
having count(pmedname) >1 ;

create table dups2 as select a.* from merge a, dups b 
where a.pmedname=b.pmedname
  and a.pmform  =b.pmform /*2019*/
  /*and a.strnunit =b.strnunit
  and a.strnuni2 =b.strnuni2
  and a.strnnum =b.strnnum
  and a.strnnum2=b.strnnum2*/
order by a.PMEDNAME, a.pmform /*2018*/, /*a.strnunit, a.strnuni2, a.strnnum, a.strnnum2,*/ a.weight desc;
quit;

proc sort data=merge; by PMEDNAME pmform /*2018*/ /*strnunit strnuni2 strnnum strnnum2*/ descending weight ;run;
proc sort data=merge nodupkey; by PMEDNAME pmform /*2018*/ /*strnunit strnuni2 strnnum strnnum2*/  ;run;


data matched&match unmatched;
set merge;
if match ne "" then output matched&match;
else output unmatched;
run;
%mend;

*******************************************************************************************;
******************************* PMEs with strength in name ********************************;
*******************************************************************************************;

***Attempt 1: 
   Match based on full PMEDNAME to FDB BN BN || STR minus any special chars and form;
%match(pme_str, 1,
compress(a.pmedname,"~@#$%^&*()_+|}{:? `-=[]\;',./""") =  compress(b.bn ||b.str,"~@#$%^&*()_+|}{:? `-=[]\;',./""")
and a.pmform /*2018*/  =b.pmform_fdb
/*and a.strnnum  =b.str1*/
/*and a.strnnum2 =b.str2*/
);

***Attempt 2: 
   Match based on full PMEDNAME to FDB BN minus any special chars and MCBS form;
%match(unmatched, 2,
compress(a.pmedname,"~@#$%^&*()_+|}{:? `-=[]\;',./""") = compress(b.bn,"~@#$%^&*()_+|}{:? `-=[]\;',./""")
 /*and a.strnnum  =b.str1*/
 /*and a.strnnum2 =b.str2*/
 and a.pmform /*2018*/   =b.pmform_fdb
);

***Attempt 3: 
   Match based on full PMEDNAME to FDB BN BN || STR minus any special chars ;
%match(unmatched, 3,
compress(a.pmedname,"~@#$%^&*()_+|}{:? `-=[]\;',./""") =  compress(b.bn ||b.str,"~@#$%^&*()_+|}{:? `-=[]\;',./""")
/*and a.strnnum  =b.str1*/
/*and a.strnnum2 =b.str2*/
);

***Attempt 4: 
   Match based on first 4 words (first word must be at least 4 chars)of PMEDNAME to FDB BN, 
   MCBS form;
%match(unmatched, 4,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn||" "||b.str,2) and kscan(a.pmedname,3) =kscan(b.bn||" "||b.str,3) and kscan(a.pmedname,4) =kscan(b.bn||" "||b.str,4)
 /*and a.strnnum  =b.str1*/
/* and a.strnnum2 =b.str2*/
 and a.pmform /*2019*/   =b.pmform_fdb
);

***Attempt 5: 
   Match based on first 4 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,
   regardless of MCBS form and strength 1 and 2;
%match(unmatched, 5,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn||" "||b.str,2) and kscan(a.pmedname,3) =kscan(b.bn||" "||b.str,3) and kscan(a.pmedname,4) =kscan(b.bn||" "||b.str,4)
);

***Attempt 6: 
   Match based on first 3 words (first word must be at least 4 chars)of PMEDNAME to FDB BN, 
   MCBS form;
%match(unmatched, 6,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn||" "||b.str,2) and kscan(a.pmedname,3) =kscan(b.bn||" "||b.str,3)
 /*and a.strnnum  =b.str1*/
/* and a.strnnum2 =b.str2*/
 and a.pmform /*2019*/   =b.pmform_fdb
);

***Attempt 7: 
   Match based on first 3 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,
   regardless of MCBS form and strength 1 and 2;
%match(unmatched, 7,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn||" "||b.str,2) and kscan(a.pmedname,3) =kscan(b.bn||" "||b.str,3)
);

***Attempt 8: 
   Match based on first 2 words (first word must be at least 4 chars)of PMEDNAME to FDB BN, 
   MCBS form ;
%match(unmatched, 8,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn||" "||b.str,2)
 /*and a.strnnum  =b.str1*/
/* and a.strnnum2 =b.str2*/
 and a.pmform /*2019*/   =b.pmform_fdb
);

***Attempt 9: 
   Match based on first 2 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,
   regardless of MCBS form and strength 1 and 2;
%match(unmatched, 9,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn||" "||b.str,2)
);

***Attempt 10: 
   Match based on first 1 word (at least 4 chars) of PMEDNAME to FDB BN, MCBS form;
%match(unmatched, 10,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
/*and a.strnnum  =b.str1*/
/*and a.strnnum2 =b.str2*/
and a.pmform /*2019*/   =b.pmform_fdb
);

***Attempt 11: 
   Match based on first 1 word (at least 4 chars)of PMEDNAME to FDB BN,
   regardless of MCBS form and MCBS strength 1 and 2 ;
%match(unmatched, 11,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
/*and a.strnnum  =b.str1*/
/*and a.strnnum2 =b.str2*/
);

***Attempt 12: 
   Match based on full PMEDNAME to FDB BN minus any special chars,
   regardless of MCBS form and strength 1 and 2;
%match(unmatched, 12,
compress(a.pmedname,"~@#$%^&*()_+|}{:? `-=[]\;',./""") = compress(b.bn,"~@#$%^&*()_+|}{:? `-=[]\;',./""")
);

***Attempt 9: 
   Match based on first 1 word (at least 4 chars) of PMEDNAME to FDB BN, and MCBS strength 1 
   regardless of MCBS form and strength 2 ;
/*%match(unmatched, 9,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end*/
/*and a.strnnum  =b.str1*/
/*);*/

***Attempt 10: 
   Match based on first 1 word (at least 4 chars) of PMEDNAME to FDB BN, and MCBS form, 
   regardless of MCBS strength 1 and 2;
/*%match(unmatched, 10,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and a.pmform   =b.pmform_fdb
);*/


***Attempt 13: 
   Match based on first 1 word (must be at least 4 chars) of PMEDNAME to FDB BN,
   regardless of MCBS form and strength 1 and 2;
/*%match(unmatched, 13,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
);*/

***keep data for str;
data unmatched_str; set unmatched;run;
data matched_str; 
set matched1 matched2 matched3 matched4 matched5 matched6 matched7 
    matched8 matched9 matched10 matched11 matched12 /*matched13*/;
run;



*******************************************************************************************;
**************************** PMEs with no strength in name ********************************;
*******************************************************************************************;

***Attempt 1a: 
   Match based on full PMEDNAME to FDB BN minus any special chars and MCBS form;
%match(pme_nostr, 1a,
compress(a.pmedname,"~@#$%^&*()_+|}{:? `-=[]\;',./""") = compress(b.bn,"~@#$%^&*()_+|}{:? `-=[]\;',./""")
 /*and a.strnnum  =b.str1*/
 /*and a.strnnum2 =b.str2*/
 and a.pmform /*2019*/   =b.pmform_fdb
);

***Attempt 2a: 
   Match based on full PMEDNAME to FDB BN BN || STR minus any special chars,regardless of form;
%match(unmatched, 2a,
compress(a.pmedname,"~@#$%^&*()_+|}{:? `-=[]\;',./""") =  compress(b.bn ,"~@#$%^&*()_+|}{:? `-=[]\;',./""")
/*and a.strnnum  =b.str1*/
/*and a.strnnum2 =b.str2*/
);

***Attempt 3a: 
Match based on first 4 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN, 
   MCBS form;
%match(unmatched, 3a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end = case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn,2) and kscan(a.pmedname,3) =kscan(b.bn,3) and kscan(a.pmedname,4) =kscan(b.bn,4)
 /*and a.strnnum  =b.str1*/
 /*and a.strnnum2 =b.str2*/
 and a.pmform /*2019*/   =b.pmform_fdb
);

***Attempt 4a: 
    Match based on first 4 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,
   regardless of MCBS form and strength 1 and 2;
%match(unmatched, 4a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn,2) and kscan(a.pmedname,3) =kscan(b.bn,3) and kscan(a.pmedname,4) =kscan(b.bn,4)
);

***Attempt 5a: 
   Match based on first 3 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN, 
   MCBS form;
%match(unmatched, 5a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end = case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn,2) and kscan(a.pmedname,3) =kscan(b.bn,3)
 /*and a.strnnum  =b.str1*/
 /*and a.strnnum2 =b.str2*/
 and a.pmform /*2019*/   =b.pmform_fdb
);

***Attempt 6a: 
    Match based on first 3 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,
   regardless of MCBS form and strength 1 and 2;
%match(unmatched, 6a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn,2) and kscan(a.pmedname,3) =kscan(b.bn,3)
);


***Attempt 7a:
   Match based on first 2 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN, 
   MCBS form ;
%match(unmatched, 7a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end = case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn,2)
 /*and a.strnnum  =b.str1*/
 /*and a.strnnum2 =b.str2*/
 and a.pmform /*2019*/   =b.pmform_fdb
);

***Attempt 8a: 
    Match based on first 2 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,
   regardless of MCBS form and strength 1 and 2;
%match(unmatched, 8a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn,2) 
);

***Attempt 9a: 
   Match based on first 1 word (must be at least 4 chars) of PMEDNAME to FDB BN, MCBS form;
%match(unmatched, 9a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
/*and a.strnnum  =b.str1*/
/*and a.strnnum2 =b.str2*/
and a.pmform /*2019*/   =b.pmform_fdb
);

***Attempt 10a: 
   Match based on first 1 word (must be at least 4 chars) of PMEDNAME to FDB BN, and MCBS strength 1 and 2,
   regardless of MCBS form ;
%match(unmatched, 10a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
/*and a.strnnum  =b.str1*/
/*and a.strnnum2 =b.str2*/
);

***Attempt 8a: 
   Match based on first 1 word (must be at least 4 chars) of PMEDNAME to FDB BN, and MCBS strength 1 
   regardless of MCBS form and strength 2 ;
/*%match(unmatched, 8a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
*//*and a.strnnum  =b.str1*/
/*);*/

***Attempt 9a: 
   Match based on first 1 word (must be at least 4 chars) of PMEDNAME to FDB BN, and MCBS form, 
   regardless of MCBS strength 1 and 2;
/*%match(unmatched, 9a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and a.pmform   =b.pmform_fdb
);*/

***Attempt 10a: 
   Match based on full PMEDNAME to FDB BN minus any special chars,
   regardless of MCBS form and strength 1 and 2;
/*%match(unmatched, 10a,
compress(a.pmedname,"~@#$%^&*()_+|}{:? `-=[]\;',./""") = compress(b.bn,"~@#$%^&*()_+|}{:? `-=[]\;',./""")
);*/

***Attempt 11a: 
   Match based on first 2 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,
   regardless of MCBS form and strength 1 and 2;
/*%match(unmatched, 11a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
and kscan(a.pmedname,2) =kscan(b.bn,2)
);*/

***Attempt 12a: 
   Match based on first 1 word (must be at least 4 chars) of PMEDNAME to FDB BN,
   regardless of MCBS form and strength 1 and 2;
/*%match(unmatched, 12a,
case when length(kscan(a.pmedname,1) )>3 then kscan(a.pmedname,1) else 'S' end =case when length(kscan(b.bn,1))>3 then kscan(b.bn,1) else 'P' end
);*/



***keep data for no_str;
data unmatched_nostr; set unmatched;run;
data matched_nostr;   
set matched1a matched2a matched3a matched4a matched5a matched6a 
    matched7a matched8a matched9a matched10a /*matched11a matched12a*/;
run;



*****Combine ******************************************************************;;

data matched;   
set   
/*matched_prior*/
matched_str 
matched_nostr; 
run;

data unmatched; set unmatched_str   unmatched_nostr; run;

proc format;
value $match
/*'' ='Unmatched'
'p1'=' 0: Based on prior year MCBS name matching, name, strength, form'
'p2'=' 0: Based on prior year MCBS name matching, name, strength'
'p3'=' 0: Based on prior year MCBS name matching, name, form'
'p4'=' 0: Based on prior year MCBS name matching, name only'*/
'1'=' 1: STR: full PMEDNAME to FDB BN BN || STR and form'
'2'=' 2: STR: full PMEDNAME to FDB BN and MCBS form'
'3'=' 3: STR: full PMEDNAME to FDB BN BN || STR '
'4'=' 4: STR: first 4 words (first word must be at least 4 chars)of PMEDNAME to FDB BN,MCBS form'
'5'=' 5: STR: first 4 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,minus form and strength 1 and 2'
'6'=' 6: STR: first 3 words (first word must be at least 4 chars)of PMEDNAME to FDB BN,MCBS form'
'7'=' 7: STR: first 3 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,minus form and strength 1 and 2'
'8'=' 8: STR: first 2 words (first word must be at least 4 chars)of PMEDNAME to FDB BN,MCBS form' 
'9'=' 9: STR: first 2 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,minus form and strength 1 and 2 '
'10'='10: STR: first 1 word (first word must be at least 4 chars)of PMEDNAME to FDB BN,MCBS form'
'11'='11: STR: first 1 word (first word must be at leasst 4 chars) of PMEDNAME to FDB BN,minus form and strength 1 and 2'
'12'='12: STR: full PMEDNAME to FDB BN, regardless of MCBS form and strength 1 and 2'
/*'12'='12: STR: first 2 words of PMEDNAME to FDB BN, regardless of MCBS form and strength 1 and 2'*/
/*'13'='13: STR: first 1 word of PMEDNAME to FDB BN, regardless of MCBS form and strength 1 and 2'*/
'1a'=' 1a: No_STR: full PMEDNAME to FDB BN and MCBS form'
'2a'=' 2a: No_STR: full PMEDNAME to FDB BN regardless of form'
'3a'=' 3a: No_STR: first 4 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN, MCBS form'
'4a'=' 4a: No_STR: first 4 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN'
'5a'=' 5a: No_STR: first 3 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN, MCBS form'
'6a'=' 6a: No_STR: first 3 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN'
'7a'=' 7a: No_STR: first 2 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN, MCBS form '
'8a'=' 8a: No_STR: first 2 words (first word must be at leasst 4 chars) of PMEDNAME to FDB BN'
'9a'=' 9a: No_STR: first 1 word (first word must be at leasst 4 chars) of PMEDNAME to FDB BN, MCBS form '
'10a'=' 10a: No_STR: first 1 word of PMEDNAME to FDB BN, and MCBS form, regardless of MCBS strength 1 and 2'
/*'11a'='11a: No_STR: first 2 words of PMEDNAME to FDB BN, regardless of MCBS form and strength 1 and 2'
'12a'='12a: No_STR: first 1 word of PMEDNAME to FDB BN, regardless of MCBS form and strength 1 and 2'*/
;
run;


proc format;
value form
1	='Pill'
2	='Liquid'
3	='Drops'
4	='Topical ointment'
5	='Suppository'
6	='Inhalant/aerosol spray'
7	='Shampoo, soap'
8	='Injection'
9	='I.V.'
10	='Patch/pad'
11	='Topical gel/jelly'
12	='Powder'
91	='Other'
-1  ='Unknown'
.   ="-1"
;
run;




data all; set matched unmatched;
pmform_desc     =put(pmform /*2019*/,     form.);
pmform_fdb_desc =put(pmform_fdb, form.);
match_desc      =put(match,     $match.);
/*if new=1;*/

IF pmform_desc     ='-1' THEN PMFORM_DESC='';
IF pmform_fdb_desc ='-1' THEN PMFORM_fdb_DESC='';


run;

ods rtf file="&location.\Output\MCBS to FDB Drug Name Match Stats - %sysfunc(DATE(),mmddyyd10.).rtf";

***Stats on match;
title "Match Rates (PME and combination level)";
proc sql;
select 
sum( case when match ne '' then 1 else 0 end ) as matched label='Matched Combos' format=comma10.,
sum( case when match = '' then 1 else 0 end ) as unmatched label='Unmatched Combos' format=comma10.,
count(pmedname) as total label='Total Combos' format=comma10.,
sum( case when match ne '' then 1 else 0 end )  / count(pmedname) as percent label='Matched Combo %' format=percent5.
/*,

sum( case when match ne '' then pme_count else 0 end ) as matched_pme label='Matched PMEs' format=comma10.,
sum( case when match = '' then pme_count else 0 end ) as unmatched_pme label='Unmatched PMEs' format=comma10.,
sum( pme_count ) as total_pme label='Total PMEs' format=comma10.,
sum( case when match ne '' then pme_count else 0 end ) / sum( pme_count ) as percent_pme label='Matched PME %'  format=percent5.
*/
from all;
quit;

title "Matching based on distinct MCBS name/strength/form combinations";
proc freq data=all order=formatted;
tables match_desc/missing;
run;title;
/*
title "Matching based on PME counts";
proc freq data=all order=formatted;
tables match_desc/missing ;
weight pme_count;
run;title;
*/
ods rtf close;
proc contents data=all varnum;run;


PROC SORT DATA=ALL; BY pmedname PMFORM /*2019*/ /*STRNUNIT STRNNUM STRNUNI2 STRNNUM2*/ pmform_desc;RUN;


****ASSIGN REVIEWERS;
proc sql noprint;
select floor(count(*) *1 / &reviewer_no) into : revrec1 from WORK.all ;
select floor(count(*) *2 / &reviewer_no) into : revrec2 from WORK.all ;
select floor(count(*) *3 / &reviewer_no) into : revrec3 from WORK.all ;
select floor(count(*) *4 / &reviewer_no) into : revrec4 from WORK.all ;
select floor(count(*) *5 / &reviewer_no) into : revrec5 from WORK.all ;
select floor(count(*) *6 / &reviewer_no) into : revrec6 from WORK.all ;
/*select floor(count(*) *7 / &reviewer_no) into : revrec7 from WORK.all ;*/
quit;
%put &revrec1; %put &revrec2; %put &revrec3; %put &revrec4; %put &revrec5; %put &revrec6; /*%put &revrec7;*/


data all; 
set all ;
LENGTH REVIEWER $12;
rec_id=_n_;
if               rec_id <=&revrec1 then reviewer="&rev1";
else if &revrec1<rec_id <=&revrec2 then reviewer="&rev2";
else if &revrec2<rec_id <=&revrec3 then reviewer="&rev3";
else if &revrec3<rec_id <=&revrec4 then reviewer="&rev4";
else if &revrec4<rec_id <=&revrec5 then reviewer="&rev5";
else if &revrec5<rec_id <=&revrec6 then reviewer="&rev6";
*else if &revrec6<rec_id <=&revrec7 then reviewer="&rev7";

if str='-1' then str='';
if pmform_fdb_desc='-1' then pmform_fdb_desc=''; 
run;


proc sql;
create table mcbsdata.PMENAMES_TOCLEAN_&curryear as select
REC_ID,
pmedname,
PMFORM /*2019*/,
/*STRNUNIT,
STRNNUM,*/
/*STRNUNI2,
STRNNUM2,*/
pmform_desc,

bn,
STR,
pmform_fdb_desc,
pmform_fdb,
gnn,

GSN,
form,
route,
str1,
str2,
weight,

match,
match_desc,
reviewer ,
. as update_ts format=datetime20. 
from all
order by pmedname,PMFORM /*2019*/,/*strnunit strnuni2 strnnum strnnum2*/pmform_desc;
quit;

*%put &=SYSSITE &=SYSVLONG4 &=SYSSCPL ;
*options sastrace='d,d,d,d' sastraceloc=saslog nostsuffix msglevel=i ;


/*libname MCBSDATA 'C:\Users\S1C3\RIC PME\MCBS\2020\PME\Data';
proc export data=mcbsdata.pmenames_toclean_20
         outfile='C:\Users\S1C3\RIC PME\MCBS\2020\PME\Data\2020 Drug Name Match.csv'
         dbms=dlm replace;
     delimiter=';';
     putnames=no;
run;*/


***Export to Access for Hand matching;
*PMEDNAMES;
PROC EXPORT DATA= mcbsdata.PMENAMES_TOCLEAN_&curryear
            OUTTABLE= "ALL_PME_NAMES_%sysfunc(DATE(),mmddyyd10.)"
            DBMS=ACCESSCS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear Drug Name Match.mdb";
RUN; 



*FDB LOOKUP;
PROC EXPORT DATA= MCBSDATA.FDB_GSN_&FDBdate
            OUTTABLE= "FDB_GSN_%sysfunc(DATE(),mmddyyd10.)" 
            DBMS=ACCESSCS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear Drug Name Match.mdb"; 

RUN;

*CONDITIONS;
*Discontinued beginning in 2012;
/*PROC EXPORT DATA= mcbsdata.pcnd20&curryear
            OUTTABLE= "PME_LOOKUP_%sysfunc(DATE(),mmddyyd10.)" 
            DBMS=ACCESS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear Drug Name Match.mdb"; 

RUN;*/

*****ALSO EXPORT TO DRUG REFERENCE DATABASE *****;
*FDB LOOKUP;
PROC EXPORT DATA= MCBSDATA.FDB_GSN_&FDBdate
            OUTTABLE= "FDB_GSN_%sysfunc(DATE(),mmddyyd10.)" 
            DBMS=ACCESSCS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear FDB and PME lookup.mdb"; 

RUN;
*CONDITIONS;
*Discontinued beginning in 2012;
/*PROC EXPORT DATA=  mcbsdata.pcnd20&curryear
            OUTTABLE= "PME_LOOKUP_%sysfunc(DATE(),mmddyyd10.)" 
            DBMS=ACCESS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear FDB and PME lookup.mdb"; 
*/
RUN;

****files for Westat;
data mcbsdata.FDB_Westat_&FDBdate;
set MCBSDATA.FDB_GSN_&FDBdate;
keep bn gnn str str1 str2 PMFORM_FDB PMFORM_FDB_desc;
run;

proc sort data=mcbsdata.FDB_Westat_&FDBdate noduplicates; by gnn bn str; run;
