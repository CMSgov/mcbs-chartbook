*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|                                                                        |
|  PROGRAM: 06_Merge_Imputed_2                                             |
|   AUTHOR: Christopher Powers and Maggie Murgolo                        |
|  CREATED: 06/09/2010                                                   |
|  UPDATED: 05/27/2011                                                   |
|                                                                        |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

options nofmterr;

%let rnd1 =86;
%let rnd2 =87;  
%let rnd3 =88; 
%let rnd4 =89; 
%let fdbdate   =20210310_wac;         * This is the FDB/NDDF file date;


%let oversample = if substr(baseid,1,2) ne "08";***removes oversample benes;
/*Y:\Share\SMAG\MCBS\FILENOTE*/
*     
2018  01997318 -- 02124347
2019  02124353 -- 02252140 
2020  02252156 -- 02482185
2021  02482191 - 02641863    
;
%LET NEWSTART=02252156; ***NEED TO UPDATE USE CURRENT FILE YEAR BASEID RANGE;
%LET NEWEND  =02482185;



%let nextyear =21;
%let CurrYear =20;
%let LastYear =19;


%let unused   = pm_events_impd_&rnd1._20&CurrYear;
%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";
*libname COST_USE "Z:\share\IMG\Cost & Use\2015\Data\SAS Files"; /*update*/


***import IMPUTED FILE;
/*libname xptfile XPORT "&location.&xpsname..xpt" ;
data mcbsdata.&xpsname;
set xptfile.pm&curryear.impd;
run;*/


* Download Proportion SAS file from the Main Frame to the PC;
/*options obs=max compress=yes;
%let rmthost=cmsdev;
options remote=rmthost comamid=tcp device=win;
SIGNON rmthost.5227 user=_prompt_ password=_prompt_;
%syslput CurrYear=&CurrYear;
%syslput location=&location;
rsubmit;
 libname host  "S1C3.@BLV3380.COST&curryear..PROPTN";
 PROC DOWNLOAD
    DATA = host.PROPTN
     OUT = MCBSDATA.cost&curryear._proptn; 
 run;
libname host clear;
ENDRSUBMIT;
SIGNOFF;*/


*********************************************************************************************
* 1. Starting Dataset --A cut of file sent to NORC for imputation -- contains PDE data and   
*PDE_survey match events. Survey only events have been merged with the imputed NORC survey    
*only event file
*********************************************************************************************;

data pm_events2; 
set MCBSDATA.pmed_survey_match; 
proc sort;
by baseid;
run;

**************************************************************************************;
* 2.	Add payment information from "Imputed file" (PMYYIMPD)            
*Imputed file from NORC -- contains ONLY survey only events that needed imputation
*and merged with the survey only events from the pre-imputed file        
**************************************************************************************;

*** 2a. Select variables from Imputed file and create PMEDID;

data pmimpd ;
set MCBSDATA.pmimpd20_survey; /*update year*/
/*(keep= 
      BASEID EVNTNUM ROUND UTILNUM COSTNUM OTCLEG _IMPSTAT WAC BN NORCID PDE_FLAG
      DELTA1 DELTA2 DELTA3 DELTA4 DELTA5 DELTA6 DELTA7 DELTA8 DELTA9 DELTA10 DELTA11
      Y1 Y2 Y3 Y4 Y5 Y6 Y7 Y8 Y9 Y10 Y11 YPLUS
      FY1 FY2 FY3 FY4 FY5 FY6 FY7 FY8 FY9 FY10 FY11 FYPLUS
      FD1 FD2 FD3 FD4 FD5 FD6 FD7 FD8 FD9 FD10 FD11
      X9 X1 X5 X7 X2 X6 X3 X8 X4 X10 X11
      _AMTCARE _AMTCAID _AMTHMOP _AMTVA _AMTPRVE _AMTPRVI _AMTOOP _AMTDISC _AMTOTH 
	  _AMTPD _AMTMA _TREIM);*/
      *HDDM HDPHMO HDOPUB HDPRVE HDPRVI HDRX YPLUSADJ WESID); 
rename bn=bn_impd;

run;

/*2016 ROUND was defined as both char. and numeric*/
*DATA PMIMPD2;
*SET PMIMPD;
*RNDNEW=PUT (ROUND, 2.);
*RUN;

/*2016 drop original ROUND and rename new character one to old orig ROUND*/
*DATA PMIMPD3;
*SET PMIMPD2 (drop= ROUND);
*rename RNDNEW=ROUND;
*proc sort; *by baseid;
*run;



*** 2b. Merge PM_EVENTS file with Imputed file;
proc sort data=pmimpd; by pmedid; run;
proc sort data=pm_events2; by pmedid; run;


data mcbsdata.pm_events_impd;
set pm_events2 (in=a)pmimpd (in=b);
by pmedid;

if BN = " " and prematch_bn ne " " then BN=Prematch_bn;

if pmedid ne '' then PMED_record="Y"; else PMED_record="N";
if pde_id ne .  then PDE_record="Y"; else PDE_record="N";


run;


***add flag for year;
proc sql;
create table pm_events_impd2 as 
select 
a.*
 
/*case when b.baseid is not null then "&curryear" else "&nextyear" end as year */

from mcbsdata.pm_events_impd a 
       /* left join 
     mcbslast.&unused b
       on a.baseid  =b.baseid
      and a.EVNTNUM =b.EVNTNUM 
      and a.ROUND   =b.ROUND 
      and a.UTILNUM =b.UTILNUM */   ;
quit;


*Check for dups by PMEDID and PDE_ID;
proc sql; 
create table dupcheck_pm  as select  
    pmedid, count (pmedid) as count 
  from pm_events_impd2 group by pmedid having count (pmedid) >1;
create table dupcheck_pde as select 
    pde_id, count (pde_id) as count  
  from pm_events_impd2 group by pde_id having count (pde_id) >1;
quit;


****************************************************************************
*** 3. Replace imputed costs with actual PDE cost when matched   ***********
****************************************************************************;

data pm_events_impd3; 
set pm_events_impd2;
length Y1_P Y2_P Y3_P Y4_P Y5_P Y6_P Y7_P Y8_P Y9_P YPLUS_P 8;

*~~~ Variable Labels ~~~*
Y1	AMT: Medicaid
Y2	AMT: Private Insurance (EMP)
Y3	AMT: Out of Pocket
Y4	AMT: Other Sources
Y5	AMT: HMO
Y6	AMT: Private Insurance (IND)
Y7	AMT: Veterans Administration
Y8	AMT: Uncollected Liability
Y9	AMT: Medicare
YPLUS	AMT: Final Charge
*new:
Y10	AMT: Medicare Part D
Y11	AMT: Medicare Advantage

INGRDNT_CST_PD_AMT
DSPNSNG_FEE_PD_AMT
TOT_AMT_ATTR_SLS_TAX_AMT
GDC_BLW_OOPT_AMT
GDC_ABV_OOPT_AMT
PTNT_PAY_AMT
OTHR_TROOP_AMT
LICS_AMT
PLRO_AMT
CVRD_D_PLAN_PD_AMT
NCVRD_PLAN_PD_AMT
;

if PDE_record="Y" then 
do;
  *AMT: Final Charge: POS allowed charge for event;
   YPLUS_P= sum(INGRDNT_CST_PD_AMT,DSPNSNG_FEE_PD_AMT,TOT_AMT_ATTR_SLS_TAX_AMT); 
  *AMT: Out of Pocket ;
   y3_P   = PTNT_PAY_AMT;
  *PDP (S or E contracts)= LIS + CCP + NCP; 
   if substr(PLAN_CNTRCT_REC_ID,1,1)in ("S","E") then y10_P= SUM(LICS_AMT, CVRD_D_PLAN_PD_AMT, NCVRD_PLAN_PD_AMT);  
  *MAPD (H and R contracts)= LIS + CCP + NCP; 
   else y11_p= SUM(LICS_AMT, CVRD_D_PLAN_PD_AMT, NCVRD_PLAN_PD_AMT);  

  *Assign Other TrOOP and PLRO PDE amounts;
  *Note: if all imputed amounts are equal (or all missing) will be assigned to Y4: "Other Sources" first;
  IF      MAX(Y1,Y2,Y4,Y5,Y6,Y7)=Y4 THEN Y4_P=SUM(OTHR_TROOP_AMT, PLRO_AMT);*AMT: Other Sources ;
  ELSE IF MAX(Y1,Y2,Y4,Y5,Y6,Y7)=Y1 THEN Y1_P=SUM(OTHR_TROOP_AMT, PLRO_AMT);*AMT: Medicaid ;
  ELSE IF MAX(Y1,Y2,Y4,Y5,Y6,Y7)=Y2 THEN Y2_P=SUM(OTHR_TROOP_AMT, PLRO_AMT);*AMT: Private Insurance (EMP) ;
  ELSE IF MAX(Y1,Y2,Y4,Y5,Y6,Y7)=Y5 THEN Y5_P=SUM(OTHR_TROOP_AMT, PLRO_AMT);*AMT: HMO ;
  ELSE IF MAX(Y1,Y2,Y4,Y5,Y6,Y7)=Y6 THEN Y6_P=SUM(OTHR_TROOP_AMT, PLRO_AMT);*AMT: Private Insurance (IND) ;
  ELSE IF MAX(Y1,Y2,Y4,Y5,Y6,Y7)=Y7 THEN Y7_P=SUM(OTHR_TROOP_AMT, PLRO_AMT);*AMT: Veterans Administration ;

  *recode missing amounts to zero;
  if Y1_P=. then Y1_P=0;
  if Y2_P=. then Y2_P=0;
  if Y3_P=. then Y3_P=0;
  if Y4_P=. then Y4_P=0;
  if Y5_P=. then Y5_P=0;
  if Y6_P=. then Y6_P=0;
  if Y7_P=. then Y7_P=0;
  if Y8_P=. then Y8_P=0;
  if Y9_P=. then Y9_P=0;
  if Y10_P=. then Y10_P=0;
  if Y11_P=. then Y11_P=0;
  if YPLUS_P=. then YPLUS_P=0;

  *reset imputed amount flags (FY);
  FY1_P=0;
  FY2_P=0;
  FY3_P=0;
  FY4_P=0;
  FY5_P=0;
  FY6_P=0;
  FY7_P=0;
  FY8_P=0;
  FY9_P=0;
  FY10_P=0;
  FY11_P=0;
  FYplus_P=0;

  *reset imputed payor source flags (FD);
  FD1_P=0;
  FD2_P=0;
  FD3_P=0;
  FD4_P=0;
  FD5_P=0;
  FD6_P=0;
  FD7_P=0;
  FD8_P=0;
  FD9_P=0;
  FD10_P=0;
  FD11_P=0;

end;

*Fix PDE matched data where sum of PDE payor (bene, LICS, TrOOP/PLRO, plan) costs > gross drug cost;
Yplus_p2      = sum(Y1_P, Y2_P, Y3_P, Y4_P, Y5_P, Y6_P, Y7_P, Y8_P, Y9_P, Y10_P, Y11_P);
if PDE_record="Y" and abs(Yplus_p - Yplus_p2)>=.01 then 
do;
 Y1_P= Yplus_p * (Y1_P / Yplus_p2);
 Y2_P= Yplus_p * (Y2_P / Yplus_p2);
 Y3_P= Yplus_p * (Y3_P / Yplus_p2);
 Y4_P= Yplus_p * (Y4_P / Yplus_p2);
 Y5_P= Yplus_p * (Y5_P / Yplus_p2);
 Y6_P= Yplus_p * (Y6_P / Yplus_p2);
 Y7_P= Yplus_p * (Y7_P / Yplus_p2);
 Y8_P= Yplus_p * (Y8_P / Yplus_p2);
 Y9_P= Yplus_p * (Y9_P / Yplus_p2);
 Y10_P= Yplus_p * (Y10_P / Yplus_p2);
 Y11_P= Yplus_p * (Y11_P / Yplus_p2);
end;
drop yplus_p2;


*copy original values into new variable when not matched to PDE;
if PDE_record="N" then 
do;
 *amounts;
 Y1_P=Y1;
 Y2_P=Y2;
 Y3_P=Y3;
 Y4_P=Y4;
 Y5_P=Y5;
 Y6_P=Y6;
 Y7_P=Y7;
 Y8_P=Y8;
 Y9_P=Y9;
 Y10_P=Y10;
 Y11_P=Y11;
 YPLUS_P=YPLUS;

 *amount imputed flags;
 FY1_P=FY1;
 FY2_P=FY2;
 FY3_P=FY3;
 FY4_P=FY4;
 FY5_P=FY5;
 FY6_P=FY6;
 FY7_P=FY7;
 FY8_P=FY8;
 FY9_P=FY9;
 FY10_P=FY10;
 FY11_P=FY11;
 FYPLUS_P=FYPLUS;

 *source imputed flags;
 FD1_P=FD1;
 FD2_P=FD2;
 FD3_P=FD3;
 FD4_P=FD4;
 FD5_P=FD5;
 FD6_P=FD6;
 FD7_P=FD7;
 FD8_P=FD8;
 FD9_P=FD9;
 FD10_P=FD10;
 FD11_P=FD11; 
end;
run;

data sumtest; set pm_events_impd3;
DIFF_TEST=abs(sum(Y1_P, Y2_P, Y3_P, Y4_P, Y5_P, Y6_P, Y7_P, Y8_P, Y9_P, Y10_P, Y11_P)- YPLUS_P);
IF DIFF_TEST>0.02;
run;
 proc print data=sumtest (obs=500);run;
******************************************************************************************************/

****************************************************************************;
*** 4. Split End Round events        ***************************************;
****************************************************************************;

*** Get Proportions file ;
data prop;
set mcbsdata.cost&curryear._proptn;
run;

/************************
Already on file for 2012
*************************/
/** Get Part D enrollment data;
data rica;
set cost_use.rica (keep= baseid H_PDTP01 - H_PDTP12);
length  PartD_01 - PartD_12 $1;
ARRAY type{12} H_PDTP01 - H_PDTP12;
ARRAY partd{12} PartD_01 - PartD_12;
 DO I= 1 TO 12;
  IF type{I} in ('1', '2') THEN partd{I}='Y'; 
                           ELSE partd{I}='N';
 END;
DROP I H_PDTP01 - H_PDTP12;
run;*/



** Check for any Part D claims and add indicator *********;
proc sql;
create table PartDclaims as select 
baseid,
max(pde_record) as Partd_claims
from pm_events_impd3
group by baseid;
quit;


proc sort data=PartDclaims; by baseid; run;
/*proc sort data=rica; by baseid; run;*/

libname cost_use 'Y:\Share\SMAG\SMAG Staff\Cheri Sharpless\For_Joe_Maggie\For_2020';

data rica;
merge cost_use.aprelim20final_15476 (in=a)
      PartDclaims (in=b);
by baseid;
if a /*or b*/; /*changed for 2013*/

if  H_PTD01=1 
OR H_PTD02=1
OR H_PTD03=1 
OR H_PTD04=1 
OR H_PTD05=1 
OR H_PTD06=1 
OR H_PTD07=1 
OR H_PTD08=1 
OR H_PTD09=1 
OR H_PTD10=1 
OR H_PTD11=1 
OR H_PTD12=1      
or Partd_claims ='Y' then PartD=1; else partd=2;

run;

proc freq data=rica;
tables partd/missing;
run;


*** Merge Part D Flag to PM_events and remove data for persons not in RIC A;
proc sort data=rica nodupkey;    by baseid; run;
proc sort data=pm_events_impd3;  by baseid; run;

data pm_events_impd4 
      extra_PME 
      other; 
merge pm_events_impd3 (in=a)
      rica           (in=b );
by baseid;
if      a and      b  then output pm_events_impd4;
else if a and (not b) then output extra_PME;
else                       output other;;
run;

proc sql; 
create table extra_baseids as select distinct baseid from extra_PME;
quit;


*** 11a.  Split data into non-Part D benes in end round, Part D benes in end round , 
        (unknown Part D status in end round), and all other non-end-round events;;

data partd&rnd4 nonpartd&rnd4 other&rnd4 pm_events_impd_&rnd1._&rnd3;
set pm_events_impd4;

if      round ="&rnd4" and partd=1 then output partd&rnd4;
else if round ="&rnd4" and partd=2 then output nonpartd&rnd4;
else if round ="&rnd4"               then output other&rnd4;
else                                      output pm_events_impd_&rnd1._&rnd3;

run;


*** 11b. NON-PART D BENES ********************;


* 11bi. Count the number of drugs in the non-Part D file;
proc sql;
create table summary&rnd4 as select
 baseid,
 count(baseid) as total_fills
from nonpartd&rnd4
group by baseid;
quit;

* 11bii. Merge lprop onto nonpartd rnd 4;
proc sql; 
create table summary&rnd4.prop as select
 a.*,
 b.lprop,
 b.lrnd
from summary&rnd4 a
left join PROP b on a.baseid=b.baseid; 
quit;


* 11biii. Determine number in This Year and in next based on proportions;
data summary&rnd4.prop; set summary&rnd4.prop;
if lrnd ne "&rnd4" then lprop=0;
prop_this= lprop/100;
prop_next= (100-lprop) /100;
num_this = round(total_fills * prop_this,1);
num_next = round(total_fills * prop_next,1);
run;

* 11biv. Merge summary data and create random number for selecting drugs to stay/move;
proc sort data=nonpartd&rnd4;     by baseid;run;
proc sort data=summary&rnd4.prop;  by baseid;run;
data nonpartd&rnd4;														
merge nonpartd&rnd4
      summary&rnd4.prop (keep=baseid total_fills num_this num_next);
      by baseid;
retain seed 19500225 /*UPDATE??*/;
call ranuni(seed,randnum);
drop seed;
run;

* 11bv. Move drugs to this year or next year;
proc sort data=nonpartd&rnd4;by baseid randnum;run;
data nonpartd&rnd4._this nonpartd&rnd4._next;
set nonpartd&rnd4;
by baseid;
 if first.baseid then i=0;
 i+1;
if i <= num_this then output nonpartd&rnd4._this;
              else output nonpartd&rnd4._next;
drop total_fills num_this  num_next randnum i;
run;


*** 11c. PART D BENES ******************;
data partd&rnd4._this partd&rnd4._next; 
set partd&rnd4;
if pmed_record = "Y" and pde_record="N" then output partd&rnd4._next; 
                                        else output partd&rnd4._this ;
run;


*** 11d. Merge Part D and Non-Part D benes for this year and next;
data pm_events_impd_&rnd4._20&curryear;
set partd&rnd4._this 
    nonpartd&rnd4._this;
run;

data MCBSDATA.pm_events_impd_&rnd4._20&nextyear;
set partd&rnd4._next 
    nonpartd&rnd4._next;
run;


*Next year's file;
proc contents data=MCBSDATA.pm_events_impd_&rnd4._20&nextyear varnum;run;



*** 11e. Create final merged current year file;
data pm_events_impd_final_merge;
set pm_events_impd_&rnd1._&rnd3 
    pm_events_impd_&rnd4._20&curryear;
run;

proc sort data=pm_events_impd_final_merge;
by baseid ;
run;


data pm_events_impd_final_merge; 
set   pm_events_impd_final_merge ;
length pmeid $17 ;
by baseid;
 if first.baseid then i=0;
 i+1;
if PDE_ID=. then PMEID=PMEDID;
            else PMEID=baseid || pde_round ||"P" || put(i,z5.);

if pde_record="Y" then 
do;
 tabnum=.;
 suppnum=.;
 amtnum=.;
 amtunit=.;
end;

/********************
Already on 2012 file
********************/
/*if      pmed_record="Y" and pde_record="Y"  then PDE_FLAG="Survey/PDE ";
else if pmed_record="Y" and pde_record="N"  then PDE_FLAG="Survey Only";
else if pmed_record="N" and pde_record="Y"  then PDE_FLAG="PDE Only   ";*/

drop i;
run;



****************************************************************************;
*** 5. Split FIRST Round events for new panel benes     **********************;
****************************************************************************;


*1) Get round 1 and 2 events;
data pme&rnd1 
      pme&rnd2 
      pme&rnd3
      pme&rnd4
      junk; 
set pm_events_impd_final_merge;
if      round="&rnd1" then output pme&rnd1;
else if round="&rnd2" then output pme&rnd2;
else if round="&rnd3" then output pme&rnd3;
else if round="&rnd4" then output pme&rnd4;
else                       output junk;
run;

*2) Summarize: count the number of drugs in round 1 & 2,  total and PDE;
proc sql;
create table summary&rnd1 as select
 baseid,
 count(baseid) as total_fills,
 sum(case when PDE_RECORD ="Y" then 1 else 0 end) as PDE_fills
from pme&rnd1
group by baseid;
quit;

proc sql;
create table summary&rnd2 as select
 baseid,
 count(baseid) as total_fills,
 sum(case when PDE_RECORD ="Y" then 1 else 0 end) as PDE_fills
from pme&rnd2
group by baseid;
quit;


***********************************************************************;
****************** BENES WITH FRONT ROUND IN FIRST ROUND  *************;
***********************************************************************;

* 3) Merge lprop onto summary;
proc sql; 
create table summary&rnd1.prop as select
 a.*,
 b.fprop,
 b.frnd
from summary&rnd1 a 
left join prop b on a.baseid=b.baseid;
quit;


* 4) Determine number in Last Year and in This Year based on proportions;
data summary&rnd1.prop; set summary&rnd1.prop;
if      frnd < "&rnd1" then fprop=100; *for any baseids with FRND prior to first round will keep all drugs;
else if frnd > "&rnd1" then fprop=0;
prop&curryear= fprop/100;
prop&lastyear= (100-fprop) /100;
num&curryear = round(total_fills * prop&curryear,1);
num&lastyear = round(total_fills * prop&lastyear,1);
run;

*re-adjust CURRENT/LAST YEAR counts, accounting for number of PDE events;
data summary&rnd1.prop; set summary&rnd1.prop;
if num&curryear>=pde_fills then num&curryear = num&curryear - pde_fills;
else do;
  num&curryear=0;
  num&lastyear=total_fills - PDE_fills;
end;
run;



* 5) Merge summary data and create random number for selecting drugs to stay/move;
proc sort data=pme&rnd1;          by baseid;run;
proc sort data=summary&rnd1.prop;  by baseid;run;
data pme&rnd1;
merge pme&rnd1
      summary&rnd1.prop (keep=baseid frnd total_fills PDE_fills num&curryear num&lastyear);
      by baseid;
retain seed 19500225;
call ranuni(seed,randnum);
drop seed;
run;



*6) MOVE PDE EVENTS TO CURRENT YEAR;
data pme&rnd1.s pme&rnd1._&CURRYEAR.p (drop= frnd total_fills pde_fills num&CURRYEAR num&lastyear randnum ); 
set pme&rnd1;
if PDE_RECORD ="Y" then output pme&rnd1._&CURRYEAR.p ;
else output pme&rnd1.s;
run;



* 7) Move survey only events to This Year or Last Year;
proc sort data=pme&rnd1.s; by baseid randnum; run;

data pme&rnd1._&CURRYEAR.s 
      pme&rnd1._&lastyear.s;
set pme&rnd1.s;
by baseid;
if first.baseid then i=0;
 i+1;
if "&NEWSTART" <=baseid <="&NEWEND" then 
do;
   if i <= num&CURRYEAR then output pme&rnd1._&curryear.s;
                        else output pme&rnd1._&lastyear.s;
end;
else output pme&rnd1._&curryear.s;
drop frnd total_fills pde_fills num&curryear num&lastyear randnum i;
run;

* 8) Combine This Year round 1 survey only and PDE events;
data pme&rnd1._&curryear;
set pme&rnd1._&curryear.s pme&rnd1._&curryear.p;
run;
proc sort data=pme&rnd1._&curryear;by baseid ;run;




***********************************************************************;
*************  BENES WITH FRONT ROUND IN SECOND ROUND  ****************;
***********************************************************************;

* 1) Merge lprop onto summary;

proc sql; 
create table summary&rnd2.prop as select
 a.*,
 b.fprop,
 b.frnd
from summary&rnd2 a 
left join prop b on a.baseid=b.baseid;
quit;


* 2) Determine number in Last Year and in This Year based on proportions;
data summary&rnd2.prop; set summary&rnd2.prop;
if frnd < "&rnd2" then fprop=100;
prop&curryear= fprop/100;
prop&lastyear= (100-fprop) /100;
num&curryear = round(total_fills * prop&curryear,1);
num&lastyear = round(total_fills * prop&lastyear,1);
run;

*re-adjust 06/05 counts, accounting for number of PDE events;
data summary&rnd2.prop; set summary&rnd2.prop;
if num&curryear>=pde_fills then num&curryear = num&curryear - pde_fills;
else do;
  num&curryear=0;
  num&lastyear=total_fills - PDE_fills;
end;
run;



* 3) Merge summary data and create random number for selecting drugs to stay/move;
proc sort data=pme&rnd2;          by baseid;run;
proc sort data=summary&rnd2.prop;  by baseid;run;
data pme&rnd2;
merge pme&rnd2
      summary&rnd2.prop (keep=baseid frnd total_fills PDE_fills num&curryear num&lastyear);
      by baseid;
retain seed 19500225;
call ranuni(seed,randnum);
drop seed;
run;


*4) MOVE PDE EVENTS TO CURRENT YEAR;
data pme&rnd2.s 
      pme&rnd2._&curryear.p (drop= frnd total_fills pde_fills num&curryear num&lastyear randnum ); 
set pme&rnd2;
if PDE_RECORD ="Y" then output pme&rnd2._&curryear.p ;
else output pme&rnd2.s;
run;

* 5) Move survey only events to This Year or Last Year;
proc sort data=pme&rnd2.s;by baseid randnum;run;
data pme&rnd2._&curryear.s 
      pme&rnd2._&lastyear.s;
set pme&rnd2.s;
by baseid;
if first.baseid then i=0;
 i+1;
if "&NEWSTART" <=baseid <="&NEWEND" then 
do;
if i <= num&curryear then output pme&rnd2._&curryear.s;
                     else output pme&rnd2._&lastyear.s;
end;
else output pme&rnd2._&curryear.s;

drop frnd total_fills pde_fills num&curryear num&lastyear randnum i;
run;

* 6) Combine This Year round 45 survey only and PDE events;
data pme&rnd2._&curryear;
set pme&rnd2._&curryear.s pme&rnd2._&curryear.p;
run;
proc sort data=pme&rnd2._&curryear;by baseid ;run;



*******************************************************************;




* 7) Create final merged This Year file;
data pm_events_impd_final_merge2;
set pme&rnd1._&curryear
    pme&rnd2._&curryear
    pme&rnd3
	pme&rnd4;
run;
proc sort data=pm_events_impd_final_merge2 ;
by baseid ;
run;


* 8) Dropped new panel frnd records (moved to Last Year);
data NEWPANEL_FRND_DROPPED;
set pme&rnd1._&lastyear.s
    pme&rnd2._&lastyear.s;
run;


proc sort data=NEWPANEL_FRND_DROPPED 
            out=MCBSDATA.NEWPANEL_FRND_DROPPED_&curryear;
by baseid ;
run;

****************************************************************************;
*** 6. Add Additional First Databank Information   ************************;
****************************************************************************;


*** Add Route if missing by picking most common;
%macro routeadd(startset, outset, match);

data noroute (drop=fdb_gcrt_desc) route; 
 set &startset ;
 if fdb_gcrt_desc='' then output noroute;
 else output route;
run;

proc sql;
 create table route_new as select 
 a.*,
 b.route as fdb_gcrt_desc,
 b.weight

 from noroute a 
         left join 
     mcbsdata.fdb_gsn_&fdbdate b
          on &match;
quit;

proc sort data=route_new ; by pmeid/*baseid evntnum round utilnum  */ descending weight ;run;
proc sort data=route_new  nodupkey; by pmeid /*baseid evntnum round utilnum */;run;


data &outset;
 set route
 route_new ;
 drop weight;
run;
%mend;

%routeadd(pm_events_impd_final_merge2, pm_events_impd_final_merge3,
  (a.bn=b.bn and a.fdb_gnn=b.gnn and a.fdb_str=b.str and a.mcbs_form=b.pmform_fdb_desc));
%routeadd(pm_events_impd_final_merge3, pm_events_impd_final_merge3,
   (a.bn=b.bn and a.fdb_gnn=b.gnn and a.mcbs_form=b.pmform_fdb_desc));
%routeadd(pm_events_impd_final_merge3, pm_events_impd_final_merge3,
   (a.bn=b.bn and a.fdb_gnn=b.gnn and a.fdb_str=b.str ));

   proc freq data=pm_events_impd_final_merge3 order=freq;
   where fdb_gcrt_desc='';
   tables fdb_gnn/missing;
   run;


*** Add FDB General Therapeutic Code (GTC) by picking most common;

data pm_events_impd_final_merge3; set pm_events_impd_final_merge3;
length gtc_desc $55
       GTC      $3;
label gtc="Therapeutic Class Code, Generic";
label GTC_DESC="Therapeutic Class Code Description, Generic";
gtc_desc='';
gtc='';
run;

%macro gtcadd(startset, outset, match);

data nogtc (drop=gtc gtc_desc) gtc; 
 set &startset ;
 if gtc='' then output nogtc;
 else output gtc;
run;

proc sql;
 create table nogtc_fix as select 
 a.*,
 b.gtc,
 b.gtc_desc,
 b.weight
 from nogtc            a 
         left join 
     mcbsdata.fdb_gsn_&fdbdate b
          on &match;
quit;

proc sort data=nogtc_fix ; by pmeid/*baseid evntnum round utilnum  */ descending weight ;run;
proc sort data=nogtc_fix  nodupkey; by pmeid /*baseid evntnum round utilnum */;run;


data &outset;
 set gtc nogtc_fix;
 drop weight;
run;
%mend;

%gtcadd(pm_events_impd_final_merge3, pm_events_impd_final_merge4,
  (a.bn=b.bn and a.fdb_gnn=b.gnn and a.fdb_str=b.str and a.mcbs_form=b.pmform_fdb_desc));
%gtcadd(pm_events_impd_final_merge4, pm_events_impd_final_merge4,
   (a.bn=b.bn and a.fdb_gnn=b.gnn and a.mcbs_form=b.pmform_fdb_desc));
%gtcadd(pm_events_impd_final_merge4, pm_events_impd_final_merge4,
   (a.bn=b.bn and a.fdb_gnn=b.gnn and a.fdb_str=b.str  ));
%gtcadd(pm_events_impd_final_merge4, pm_events_impd_final_merge4,
   (a.bn=b.bn and a.fdb_gnn=b.gnn  ));


   proc freq data=pm_events_impd_final_merge4;
   tables gtc_desc/missing;
   run;

   proc freq data=pm_events_impd_final_merge4;
   where gtc_desc='';
   tables fdb_gnn /missing;
   run;


*** add OTC/ Legend (rx) indicator for PDE events;
data  norxotc (drop=otcleg) rxotc;
 set pm_events_impd_final_merge4;
 if otcleg='' then output norxotc;
 else output rxotc;
run;

proc sql;
create table norxotc_fix as select
 a.*, 
 b.cl as OTCLEG
from norxotc a 
         left join 
     mcbsdata.fdb_&fdbdate b
          on a.ndc_cd = b.ndc;
quit;

data pm_events_impd_final_merge4;
 set rxotc norxotc_fix;
run;

	proc freq data=pm_events_impd_final_merge4;
	tables otcleg*pde_record/missing;
	run;



***RECODES;
data pm_events_impd_final_merge4;
 set pm_events_impd_final_merge4;

*overwrite survey reported form with form from PDE;
if pde_record="Y" then 
do;
    PMFORM_desc = mcbs_form;
	 if      PMFORM_desc ='Pill'                   then PMFORM=1; /*2020 PMFORMMC renamed to PMFORM based on input data*/ 
     else if PMFORM_desc ='Liquid'                 then PMFORM=2;
     else if PMFORM_desc ='Drops'                  then PMFORM=3;
     else if PMFORM_desc ='Topical ointment'       then PMFORM=4;
     else if PMFORM_desc ='Suppository'            then PMFORM=5;
     else if PMFORM_desc ='Inhalant/aerosol spray' then PMFORM=6;
     else if PMFORM_desc ='Shampoo, soap'          then PMFORM=7;
     else if PMFORM_desc ='Injection'              then PMFORM=8;
     else if PMFORM_desc ='I.V.'                   then PMFORM=9;
     else if PMFORM_desc ='Patch/pad'              then PMFORM=10;
     else if PMFORM_desc ='Topical gel/jelly'      then PMFORM=11;
     else if PMFORM_desc ='Powder'                 then PMFORM=12;
     else if PMFORM_desc ='Other'                  then PMFORM=91;
     else if PMFORM_desc ='Unknown'                then PMFORM=-1;
end;


if bn='' or bn='0' then bn='-1';
if gnn=''          then gnn='-1';

run;

	proc freq data=pm_events_impd_final_merge4;
	tables PMFORM_desc*PMFORM  /missing; /*2020 PMFORMMC renamed to PMFORM based on input data*/  
	run;




****************************************************************************;
*** 7. Remove PDE reported Insulin Supplies for Other Medical      ********;
****************************************************************************;

***inspect ETC codes to use and get all brand names for supplies;
proc sql;
select distinct etc_id, etc_name from mcbsdata.fdb_&fdbdate;
create table insulinsup as select distinct bn from mcbsdata.fdb_&fdbdate where etc_id in (1133,1157,1158,4602);
quit;


*  Add Insulin supply indicator to PME data;
proc sql;
create table  pm_events_impd_final_merge5 as select 
 a.*,
 case when b.bn ne '' then "Y" else "N" end as insulin_supply

from  pm_events_impd_final_merge4  a
        left join 
     insulinsup       b 
         on a.bn=b.bn;
quit;

title "Table 2: Insulin Supplies ";
proc freq data= pm_events_impd_final_merge5 ;
tables insulin_supply *pde_record /missing ; 
run;title; 
 

**Identify PDE insulin supplies and delete survey only insulin supplies;
data pm_events_impd_final_merge5 ;
 set pm_events_impd_final_merge5; 
if pde_record="Y" and insulin_supply ='Y' then OtherMedical="Y";
if pde_record="N" and insulin_supply ='Y' then delete;
run;


ods rtf file="&location.pm_events_OM_20&curryear contents - %sysfunc(DATE(),mmddyyd10.).rtf";
****Summary of events move to OM File;
title 'Summary of events to move to RIC MPE as OM';
proc sql; 
select 
 BN, 
 gnn, 
 count(baseid) as totalcount,
 sum (case when pde_record ="Y" then 1 else 0 end)as PDE_count,  
 sum (case when yplus_p is not null then yplus_p else yplus end)as cost_sum , 
 sum(case when yplus_p is null and yplus is null then 1 else 0 end) as missing_cost_count 

from pm_events_impd_final_merge5  where OtherMedical="Y" group by bn, gnn order by  totalcount desc;
quit;title;
ods rtf close;

**save full file;
data mcbsdata.pm_events_impd_full_merge;set pm_events_impd_final_merge5; run;



****************************************************************************;
*** 8. Select final variables      ****************************************;
****************************************************************************;

/*UPDATE 08/10/2022*/
/*2017 ADD PMCOND AND PMKNWNM VARS -- ADD CHAR VARS TOO??*/

proc sql;

create table pm_events_impd_final_20&curryear as select 
BASEID,
pmeid,
PDE_FLAG,
OtherMedical,
pmedid,
pde_id,
matchid,
type,

EVNTNUM, evntnum_c,
ROUND, round_c,
pde_round,
COSTNUM,
UTILNUM, utilnum_c,


PMEDNAME,
PMFORM,/*2020 PMFORMMC renamed to PMFORM based on input data*/ 
PMFORM_DESC,
STRNUNIT,
STRNNUM,
/*STRNUNI2,
STRNNUM2,*/ /*removed in 2018*/

tabsaday,
tabtake,
tabnum, 
suppnum,
amtnum,
amtunit,

PMKNWNM,
PMCOND,

COND1,
COND2,

BN       AS FDB_BN,
FDB_GNN,
fdb_STR,
FDB_GCRT_DESC,
GTC      AS THERCC,
GTC_DESC AS THERCC_DESC,
OTCLEG,


SERV_DT,
QNTY,
DAYSUPP,
NDC_CD,

_IMPSTAT,
WAC,
NORCID,
DELTA1,DELTA2,DELTA3,DELTA4,DELTA5,DELTA6,DELTA7,DELTA8,DELTA9,DELTA10,DELTA11,

FD1, FD2, FD3, FD4, FD5, FD6, FD7, FD8, FD9, FD10, FD11,
FY1, FY2, FY3, FY4, FY5, FY6, FY7, FY8, FY9, FY10, FY11, FYPLUS,
Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8, Y9, Y10, Y11, YPLUS,
X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, 
_AMTCARE,_AMTCAID,_AMTHMOP,_AMTVA,_AMTPRVE,_AMTPRVI,_AMTOOP,_AMTDISC,_AMTOTH,_AMTPD,_AMTMA,
_TREIM,
/*HDDM,HDPHMO, HDOPUB, HDPRVE, HDPRVI, HDRX,YPLUSADJ*/

Y1_P,  Y2_P,  Y3_P,  Y4_P,  Y5_P,  Y6_P,  Y7_P,  Y8_P,  Y9_P,  Y10_P,  Y11_P,  YPLUS_P,
FY1_P, FY2_P, FY3_P, FY4_P, FY5_P, FY6_P, FY7_P, FY8_P, FY9_P, FY10_P, FY11_P, FYplus_P,
FD1_P, FD2_P, FD3_P, FD4_P, FD5_P, FD6_P, FD7_P, FD8_P, FD9_P, FD10_P, FD11_P


from pm_events_impd_final_merge5 
order by BASEID;
quit;


data MCBSDATA.pm_events_impd_final_20&curryear;
set pm_events_impd_final_20&curryear;

&oversample;*removes oversample benes;

run;

ods rtf file="&location.pm_events_impd_final_&curryear contents - %sysfunc(DATE(),mmddyyd10.).rtf";
proc contents data=MCBSDATA.pm_events_impd_final_20&curryear varnum;run;
proc freq data=MCBSDATA.pm_events_impd_final_20&curryear;
tables PDE_FLAG;
run;
ods rtf close;


title "Number of survey records in final file";
proc sql; select count (*) from  MCBSDATA.pm_events_impd_final_20&curryear where EVNTNUM is not null;quit;
title;
