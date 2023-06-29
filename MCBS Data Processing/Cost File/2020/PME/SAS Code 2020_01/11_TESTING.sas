*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 11_TESTING                                                              |
|      UPDATED: 01/24/2011                                                              |
|  INPUT FILES: TOWESTAT_&CURRYEAR AND TOWESTAT_&LASTYEAR                               |
| OUTPUT FILES: NONE                                                                    |
|  DESCRIPTION: Testing program for file QA                                             |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;
ods html close;
ods html;
options nofmterr;

%LET CURRYEAR=20;
%LET LASTYEAR=19;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\Data\;

libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";
OPTIONS ORIENTATION=LANDSCAPE;
ODS RTF  BODYTITLE FILE="&LOCATION.OUTPUT\TESTING OUTPUT 20&CURRYEAR - %sysfunc(DATE(),mmddYYd10.).RTF";


*** 2a. Select variables from TOWESTAT file and create PMEDID;
data MCBSDATA.NEW_TO_&CURRYEAR;
set MCBSDATA.towestat_&currYear;

length pmedid $17; /*update length to accomadate for utilnum change*/
pmedid=trim(baseid)||trim(evntnum)||trim(round)||trim(utilnum);
run;

/*2017 Check to make sure no dups in file if there are delete*/
PROC SORT DATA=MCBSDATA.NEW_TO_&CURRYEAR
 OUT=MCBSDATA.NEW_TO_&CURRYEAR
 NODUPKEY ;
 BY pmedid ;
RUN ;

***Testing;

%let outlier=5000;

title "Outliers > $&outlier";
proc sql;

select 
bn,
awp,
_AMTOOP ,
_AMTCAID,
_AMTCARE,
_AMTpHMO,
_AMTVA ,
_AMTPRVE,
_AMTPRVI,
_AMTDISC,
_AMTOTH,
_AMTPD ,
_AMTMA ,
_TREIM 
from  MCBSDATA.NEW_TO_&CURRYEAR
where _AMTOOP >=&outlier
or _AMTCAID >=&outlier
or _AMTCARE  >=&outlier
or _AMTpHMO >=&outlier
or _AMTVA  >=&outlier
or _AMTPRVE >=&outlier
or _AMTPRVI >=&outlier
or _AMTDISC >=&outlier
or _AMTOTH >=&outlier
or _AMTPD >=&outlier
or _AMTMA  >=&outlier
or _TREIM >=&outlier
order by bn;
quit;title;

/*
proc sql;
create table test_merge as select
f.BASEID  , f.ROUND   , f.EVNTNUM , f.UTILNUM , 
f.PMEDNAME,
f.PMFORM, f.STRNUNIT, f.STRNNUM, f.STRNUNI2, f.STRNNUM2,
w._AMTOOP, w._AMTCAID, w._AMTCARE, w._AMTpHMO , w._AMTVA , w._AMTPRVE, 
w._AMTPRVI, w._AMTDISC, w._AMTOTH , w._AMTPD , w._AMTMA,
f._AMTOOP as f_AMTOOP, 
f._AMTCAID as f_AMTCAID,  
f._AMTCARE as f_AMTCARE,  
f._AMTpHMO as f_AMTpHMO ,  
f._AMTVA as f_AMTVA , 
f._AMTPRVE as f_AMTPRVE,  
f._AMTPRVI as f_AMTPRVI,  
f._AMTDISC as f_AMTDISC,  
f._AMTOTH as f_AMTOTH ,  
f._AMTPD as f_AMTPD ,
f._AMTMA as f_AMTMA

from test w
left join mcbsdata.final_&curryear._v2 f
       ON w.BASEID  = f.BASEID
	  AND w.ROUND   = f.ROUND
      AND w.EVNTNUM = f.EVNTNUM
      AND w.UTILNUM = f.UTILNUM   ;
quit;
*/


data f;  set mcbsdata.cost&curryear._final_pm      (keep=BASEID ROUND EVNTNUM UTILNUM );run;
data u;  set mcbsdata.unused_all_flagged_&lastyear (keep=BASEID ROUND EVNTNUM UTILNUM unused where=(UNUSED ne "DROP"));drop unused;run;
data f2; set mcbsdata.final_&curryear._v2          (keep=BASEID ROUND EVNTNUM UTILNUM );run;
data o;  set mcbsdata.deleted_otc_&curryear        (keep=BASEID ROUND EVNTNUM UTILNUM );run;
data w;  set mcbsdata.NEW_TO_&CURRYEAR           (keep=BASEID ROUND EVNTNUM UTILNUM );run;

proc sort data=f; by BASEID ROUND EVNTNUM UTILNUM ;run;
proc sort data=u; by BASEID ROUND EVNTNUM UTILNUM ;run;
proc sort data=f2; by BASEID ROUND EVNTNUM UTILNUM ;run;
proc sort data=o; by BASEID ROUND EVNTNUM UTILNUM ;run;
proc sort data=w; by BASEID ROUND EVNTNUM UTILNUM ;run;

data fuf2ow;
merge f (in=f) 
      u (in=u)
      f2 (in=f2)
      o(in=o)
      w (in=w);
final=f;
unused=u;
final_v2=f2;
otc=o;
westat=w;
if f or u or f2 or o or w;
run;

proc means data=fuf2ow sum maxdec=0;
class round;
var final unused final_v2 otc  westat;
run;
proc means data=fuf2ow sum maxdec=0;
var final unused final_v2 otc  westat;
run;





Title "This Year, Final file";proc freq data=mcbsdata.cost&curryear._final_pm; tables round/missing;run;title;
Title "This Year, Unused";    proc freq data=mcbsdata.unused_all_flagged_&lastyear; tables round/missing; where UNUSED ne "DROP";run;title;
Title "This Year, Final V2";  proc freq data=mcbsdata.final_&curryear._v2;     tables round/missing; where UNUSED ne "DROP";run;title;
Title "This Year, Outcomm";   proc freq data=mcbsdata.OUTCOMM_Y&CurrYear;      tables round/missing;run;title;
Title "This Year, To Westat"; proc freq data=mcbsdata.NEW_TO_&CURRYEAR;      tables round/missing;run;title;
Title "This Year, OTCs";      proc freq data=mcbsdata.deleted_otc_&curryear;   tables round/missing;run;title;

Title "Last Year, Final file";proc freq data=mcbslast.cost&LASTyear._final_pm; tables round/missing;run;title;
Title "Last Year, Final V2";  proc freq data=mcbslast.final_&lastYEAR._v2;     tables round/missing; where UNUSED ne "DROP";run;title;
Title "Last Year, Outcomm";   proc freq data=mcbslast.OUTCOMM_Y&lastYEAR;      tables round/missing;run;title;
Title "Last Year, To Westat"; proc freq data=mcbslast.TOWESTAT_&lastYEAR;      tables round/missing;run;title;
Title "Last Year, OTCs";      proc freq data=mcbslast.deleted_otc_&lastYEAR;   tables round/missing;run;title;


DATA W;
SET MCBSDATA.NEW_TO_&CURRYEAR
	(KEEP=      
          _AMTOOP _AMTCAID _AMTCARE _AMTpHMO _AMTVA _AMTPRVE _AMTPRVI _AMTDISC _AMTOTH _AMTPD _AMTMA
          _SOPOOP _SOPCAID _SOPCARE _SOPpHMO _SOPVA _SOPPRVE _SOPPRVI _SOPDISC _SOPOTH _SOPPD _SOPMA 
          iSOPOOP iSOPCAID iSOPCARE iSOPpHMO iSOPVA iSOPPRVE iSOPPRVI iSOPDISC iSOPOTH iSOPPD iSOPMA 
           );
file="NEW_TO";
RUN;
DATA F;
SET MCBSDATA.FINAL_&curryear._V2
	(KEEP=      
          _AMTOOP _AMTCAID _AMTCARE _AMTpHMO _AMTVA _AMTPRVE _AMTPRVI _AMTDISC _AMTOTH _AMTPD _AMTMA
          _SOPOOP _SOPCAID _SOPCARE _SOPpHMO _SOPVA _SOPPRVE _SOPPRVI _SOPDISC _SOPOTH _SOPPD _SOPMA 
          iSOPOOP iSOPCAID iSOPCARE iSOPpHMO iSOPVA iSOPPRVE iSOPPRVI iSOPDISC iSOPOTH iSOPPD iSOPMA 
        );
file="FINAL";
RUN;

DATA WF;
SET W F;
RUN;



title "ISOPs by FILE";
proc tabulate data=Work.Wf   ;
   class ISOPCARE ISOPCAID ISOPpHMO ISOPVA ISOPPRVE ISOPPRVI ISOPOOP ISOPDISC ISOPOTH ISOPPD ISOPMA;
   class FILE;
   table
		 ISOPCARE ISOPCAID ISOPpHMO ISOPVA ISOPPRVE ISOPPRVI ISOPOOP ISOPDISC ISOPOTH ISOPPD ISOPMA,
		 (file ) *
        ('N'='Number of nonmissing values'*F=COMMA15.0
		  'PCTN'='Frequency percentage')/;
run;TITLE;

title "SOPs by FILE";
proc tabulate data=Work.Wf   ;
   class _SOPCARE _SOPCAID _SOPpHMO _SOPVA _SOPPRVE _SOPPRVI _SOPOOP _SOPDISC _SOPOTH _SOPPD _SOPMA;
   class FILE;
   table
		 _SOPCARE _SOPCAID _SOPpHMO _SOPVA _SOPPRVE _SOPPRVI _SOPOOP _SOPDISC _SOPOTH _SOPPD _SOPMA,
		 (file ) *
        ('N'='Number of nonmissing values'*F=COMMA15.0
		  'PCTN'='Frequency percentage')  / misstext=' ';
run;TITLE;

title "Costs by FILE";
PROC TABULATE DATA=WORK.WF   ;
   VAR    _AMTOOP _AMTCAID _AMTCARE _AMTpHMO _AMTVA _AMTPRVE _AMTPRVI _AMTDISC _AMTOTH _AMTPD _AMTMA ;
   CLASS FILE;
   TABLE (_AMTOOP _AMTCAID _AMTCARE _AMTpHMO _AMTVA _AMTPRVE _AMTPRVI _AMTDISC _AMTOTH _AMTPD _AMTMA ),
          (FILE) *
			 ('N'='N'*F=COMMA12.0 
			  "SUM"= "Sum"*F=DOLLAR15.0
              'MEAN'='Mean'*F=DOLLAR15.2
			  'MEDIAN'='Median'*F=DOLLAR15.2
			  "MIN"= "Min"*F=DOLLAR15.0
			  "MAX"= "Max"*F=DOLLAR15.0)
/ misstext=' ';
RUN;title;

ODS RTF CLOSE;

