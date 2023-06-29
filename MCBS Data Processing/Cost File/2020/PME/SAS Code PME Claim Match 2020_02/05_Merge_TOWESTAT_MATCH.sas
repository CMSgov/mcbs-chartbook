*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|                                                                        |
|  PROGRAM: 05_Merge_Imputed                                             |
|   AUTHOR: Maggie Murgolo                                           |
|  CREATED: 06/09/2010                                                   |
|  UPDATED: 05/27/2015                                                   |
|                                                                        |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;
options nofmterr;

%let fdbdate   =fdb_20210310_wac;         * This is the FDB/NDDF file date;

%let oversample = if substr(baseid,1,2) ne "08";***removes oversample benes;
  
%let nextyear =21;
%let CurrYear =20;
%let LastYear =19;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";
libname COST_USE "Y:\Share\SMAG\SMAG Staff\Cheri Sharpless\For_Joe_Maggie\For_2020";



/*FIX FOR 2020 and 2019,2018,2017 -- need to add PMCOND and PMKNWNM from ECC file -- will need 
to create PMEDID and keep only needed vars then merge*/

data fix2020;
set MCBSDATA.cost20_final_pm (keep = baseid evntnum round utilnum pmcond pmknwnm);

pmedid=trim(baseid)||trim(evntnum)||trim(round)||trim(utilnum);
run;

/* Check to make sure no dups in file if there are delete*/
PROC SORT DATA=fix2020
 OUT=fix2020
 NODUPKEY ;
 BY pmedid ;
RUN ;


********************************************************************************************;
*** 1. Starting Dataset  --MATCH FILE  *****************************************************;
********************************************************************************************;

data pm_events; 
set MCBSDATA.pm_events; 
proc sort; by baseid; run;

/*2016 Check to make sure no dups in file*/
PROC SORT DATA=pm_events
 OUT=pm_events_check
 NODUPKEY ;
 BY pmedid pde_id ;
RUN ;

*** FIX 2020 and 2019,2018,2017 Merge PM_EVENTS file with FIX2020 file;
proc sort data=fix2020; by pmedid; run;
proc sort data=pm_events; by pmedid; run;

data pm_events;
merge pm_events (in=a)
      fix2020 (in=b);
by pmedid; if a;
run;

**************************************************************************************;
*** 2.	Add ToWestat file        		 	     						  ************;
**************************************************************************************;

*** 2a. Select variables from TOWESTAT file and create PMEDID;
data pmimpd ;
set MCBSDATA.towestat_&currYear
(keep= BASEID AMTCHG AWP BN COSTNUM EV95FLG EVNTNUM HDOPUB HDPHMO HDPRVE HDPRVI HDRX
       INS_FLGS ISOPCAID ISOPCARE ISOPDISC ISOPMA ISOPOOP ISOPOTH ISOPPD ISOPPHMO ISOPPRVE ISOPPRVI ISOPVA
        NLNS OTCLEG PMSUMFLG ROUND RX_FLGS UTILNUM XTRAS _AMTCAID  
       _AMTCARE _AMTDISC _AMTPHMO _AMTVA _AMTPRVE _AMTPRVI _AMTOOP _AMTOTH _AMTPD _AMTMA _IMPSTAT 
       _SOPCAID _SOPCARE _SOPDISC _SOPMA _SOPOOP _SOPOTH _SOPPD _SOPPHMO _SOPPRVE _SOPPRVI _SOPVA _TREIM);
      
rename bn=PREMATCH_bn AWP=WAC;

length pmedid $17; /*update length to accomadate for utilnum change*/
pmedid=trim(baseid)||trim(evntnum)||trim(round)||trim(utilnum);
run;

/*2016 Check to make sure no dups in file if there are delete*/
PROC SORT DATA=pmimpd
 OUT=pmimpd
 NODUPKEY ;
 BY pmedid ;
RUN ;

*** 2b. Merge PM_EVENTS file with PREMATCH (TOWESTAT) file;
proc sort data=pmimpd; by pmedid; run;
proc sort data=pm_events; by pmedid; run;


data pm_events_impd;
merge pm_events (in=a)
      pmimpd (in=b);
by pmedid;

if pmedid ne '' then PMED_record=1; else PMED_record=2;
if pde_id ne .  then PDE_record=1; else PDE_record=2;

run;


*Check for dups by PMEDID and PDE_ID;
proc sql; 
create table dupcheck_pm  as select  
    pmedid, count (pmedid) as count 
  from pm_events_impd group by pmedid having count (pmedid) >1;
create table dupcheck_pde as select 
    pde_id, count (pde_id) as count  
  from pm_events_impd group by pde_id having count (pde_id) >1;
quit;


*** Get Part D enrollment data from RIC A and create flag 
Variable name updated for 2015;
data rica;
set cost_use.aprelim20final_15476 (keep= baseid H_PTD01 - H_PTD12);
length  H_PTD01 - H_PTD12 8.;
ARRAY H_PTD{12} H_PTD01 - H_PTD12;
 DO I= 1 TO 12;
  IF H_PTD{I} in (1) THEN H_PTD{I}=1; 
     ELSE IF H_PTD{I} in (2) THEN H_PTD{I}=2;
 END;

run;

** Check for any Part D claims and add indicator *********;
proc sql;
create table PartDclaims as select 
baseid,
max(pde_record) as Partd_claims
from pm_events_impd
group by baseid;
quit;

proc sort data=PartDclaims; by baseid; run;
proc sort data=rica; by baseid; run;

data rica;
merge rica (in=a)
      PartDclaims (in=b);
by baseid;
if a or b;

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
or Partd_claims =1 then PartD=1; else partd=2;

run;

proc freq data=rica;
tables partd/missing;
run;

*** Merge Part D Flag to PM_events and remove data for persons not in RIC A;
proc sort data=rica nodupkey;    by baseid; run;
proc sort data=pm_events_impd;  by baseid; run;

data pm_events_impd2 
      extra_PME 
      other; 
merge pm_events_impd (in=a)
      rica           (in=b );
by baseid;
if      a and      b  then output pm_events_impd2;
else if a and (not b) then output extra_PME;
else                       output other;;
run;

proc sql; 
create table extra_baseids as select distinct baseid from extra_PME;
quit;


*** 11e. Create final merged current year file with correct POP and PDE_FLAG;
data pm_events_impd_final_merge;
set pm_events_impd2; 
run;

proc sort data=pm_events_impd_final_merge;
by baseid;
run;


data pm_events_impd_final_merge2; 
set   pm_events_impd_final_merge ;
length pmeid $17 ; /*update length to accomadate for utilnum change*/
by baseid;
 if first.baseid then i=0;
 i+1;
if PDE_ID=. then PMEID=PMEDID;
            else PMEID=baseid || pde_round ||"P" || put(i,z5.);

if pde_record=1 then 
do;
 tabnum=.;
 suppnum=.;
 amtnum=.;
 amtunit=.;
end;

if      pmed_record=1 and pde_record=1  then PDE_FLAG=3 /*"Survey/PDE "*/;
else if pmed_record=1 and pde_record=2  then PDE_FLAG=1 /*"Survey Only"*/;
else if pmed_record=2 and pde_record=1  then PDE_FLAG=2 /*"PDE Only   "*/;

drop i;
run;

/*This step is to get the label back onto PDE_FLAG*/
data pm_events_impd_final_merge3;
set pm_events_impd_final_merge2;

char_PDE_FLAG = put(PDE_FLAG, 11.) ;
drop PDE_FLAG ;
rename char_PDE_FLAG=PDE_FLAG;
run;

data pm_events_impd_final_merge4;
set pm_events_impd_final_merge3; 

if PDE_FLAG = 3 then PDE_FLAG= 'Survey/PDE ';
else if PDE_FLAG = 1 then PDE_FLAG = 'Survey Only';
else if PDE_FLAG = 2 then PDE_FLAG = 'PDE Only   ';
 
run;

/*This step was created in 2017 to convert select variables back to numeric
prior to sending the file to NORC for imputation*/
data pm_events_impd_final_merge5;
set pm_events_impd_final_merge4;
   
   evntnum_n = input(evntnum, 8.);
   round_n = input(round, 8.);
   costnum_n = input(costnum, 8.);
   utilnum_n = input(utilnum, 4.);
   ev95flg_n = input(ev95flg, 8.);

   rename evntnum=evntnum_c;
   rename round=round_c;
   rename costnum=costnum_c;
   rename utilnum=utilnum_c;
   rename ev95flg=ev95flg_c;

   /*drop evntnum;
   drop round;
   drop costnum; 
   drop utilnum; 
   drop ev95flg;*/

   rename evntnum_n=evntnum;
   rename round_n=round;
   rename costnum_n=costnum;
   rename utilnum_n=utilnum;
   rename ev95flg_n=ev95flg;

run;


****************************************************************************;
*** 8. Select final variables      ****************************************;
****************************************************************************;

proc sql;

create table pm_events_pre_impd_20&curryear as select 
BASEID,
PMEID,
BENE_ID,
PDE_FLAG,
PARTD,
PMEDID,
PDE_ID,
MATCHID,
TYPE,
EVNTNUM,
ROUND,
PDE_ROUND,
COSTNUM,
UTILNUM,
PMEDNAME,
PMFORM,
PMFORM_DESC,
MCBS_FORM,
TABNUM,TABSADAY, TABTAKE, TAKENUM, TAKEUNIT,
SUPPNUM,
AMTNUM, AMTNUM2,
AMTUNIT, AMTUNIT2,
COMPFLAG,
COND1,
COND2,
PMCOND, PMKNWNM, /*new for 2017*/
PREMATCH_BN,
BN,
GNN      AS FDB_GNN,
GNN2, GSF, 
STR      AS FDB_STR,
STRNUNIT,
STRNNUM,
RT       AS FDB_GCRT_DESC,
OTCLEG,
_IMPSTAT,
WAC,
AMTCHG,
_AMTCARE,_AMTCAID,_AMTPHMO,_AMTVA,_AMTPRVE,_AMTPRVI,_AMTOOP,_AMTDISC,_AMTOTH,_AMTPD,_AMTMA,
_TREIM,
HDPHMO, HDOPUB, HDPRVE, HDPRVI, HDRX, EV95FLG, INS_FLGS, 
_SOPCAID, _SOPCARE, _SOPDISC, _SOPMA, _SOPOOP, _SOPOTH, _SOPPD, _SOPPHMO, _SOPPRVE, _SOPPRVI, _SOPVA,
ISOPCAID, ISOPCARE, ISOPDISC, ISOPMA,ISOPOOP, ISOPOTH, ISOPPD, ISOPPHMO, ISOPPRVE, ISOPPRVI, ISOPVA, 
NLNS, PMSUMFLG, RX_FLGS, XTRAS,
HIC_ID, SRVC_DT as SERV_DT, 
PROD_SRVC_ID as NDC_CD, 
PLAN_CNTRCT_ID, PBP_ID, PLAN_CNTRCT_REC_ID, PLAN_PBP_REC_NUM, 
QTY_DSPNSD_NUM as QNTY, 
DAYS_SUPLY_NUM as DAYSUPP,
INGRDNT_CST_PD_AMT, DSPNSNG_FEE_PD_AMT, TOT_AMT_ATTR_SLS_TAX_AMT, GDC_ABV_OOPT_AMT, 
GDC_BLW_OOPT_AMT, PTNT_PAY_AMT, OTHR_TROOP_AMT, LICS_AMT, PLRO_AMT, CVRD_D_PLAN_PD_AMT, NCVRD_PLAN_PD_AMT, 
GCN_SEQNO, FORM, STR1, STR2, MCBS_FORM_CODE, 
EVNTNUM_C,ROUND_C, COSTNUM_C, UTILNUM_C, EV95FLG_C, 
R86, R87, R88, R89  /*UPDATE*/ /*,KEYNAME*/

from pm_events_impd_final_merge5
order by BASEID;
quit;


data MCBSDATA.pm_events_pre_impd_20&curryear;
set pm_events_pre_impd_20&curryear;

&oversample;*removes oversample benes;

label
BASEID   = "Unique SP Identification Number"
PMEID =  "PMEID"
PDE_FLAG = "PDE Flag"
PARTD = "Part D Flag from Admin. File"
PMEDID = "BASEID||EVNTNUM||ROUND||UTILNUM"
PDE_ID = "CCW Part D Event Number"
MATCHID = "PDE Match ID"
TYPE = "Type of PDE Match"
EVNTNUM = "Event Number"
ROUND = "Round Number"
PDE_ROUND = "PDE Round Number"
COSTNUM = "Sequential Cost Number"
UTILNUM = "Utilization within this cost"
PMEDNAME = "Name of prescribed medicine and strength text"
PMFORM = "Medicine is in what form?"
TABNUM = "How many tablets in bottle when obtained?"
TABSADAY = "How many tabs a day are to be taken?"
TABTAKE = "Num of tabs SP usually takes in a day?"
TAKENUM	= "Unit number of days or weeks rx taken"
TAKEUNIT = "How many days/weeks tabs taken - unit"
SUPPNUM	=	"Num suppositories in container"
AMTNUM	=	"Unit number - how much rx in container?"
AMTNUM2	=	"Amount of medicine - 2nd compound"
AMTUNIT	=	"How much med was in bottle - unit"
AMTUNIT2 = "Unit amount of med - 2nd compound"
COMPFLAG =	"Flag - medicine is made up of compounds"
COND1	=	"Text for condition #1"
COND2	=	"Text for condition #2"
PREMATCH_BN	=	"Prematch brand name"
BN	=	"Brand Name"
FDB_GNN	=	"USAN Generic Name-short version"
GNN2	=	"GNN – Recode of special cases"
GSF		=	"GNN||STR||MCBS_FORM"
FDB_STR	=	"First Data Bank strength"
STRNUNIT =	"Unit of strength of tablet-1st compound"
STRNNUM	=	"Strength of tablet-1st compound"
FDB_GCRT_DESC = "Route Description"
OTCLEG	=	"OVER THE COUNTER LEGEND"
_IMPSTAT =	"Prematch imputation flag"
WAC		=	"Wholesale Acquisition Cost"
AMTCHG	=	"AMT > 0 but SOP flag =0,trust SOP"
_AMTCARE =	"Amount paid by Medicare"
_AMTCAID =	"Amount paid by Medicaid"
_AMTPHMO =	"Amount paid by Private HMO"
_AMTVA	=	"Amount paid by VA"
_AMTPRVE =	"Amount paid by Priv insurance(EMPL)"
_AMTPRVI =	"Amount paid by Priv insurance(INDIV)"
_AMTOOP	= 	"Amount paid by OOP"
_AMTDISC =	"Amount paid by provider discount"
_AMTOTH	=	"Amount paid by other sources"
_AMTPD	=	"Amount paid by PartD"
_AMTMA	=	"Amount paid by MA"
_TREIM	=	"Target Reimbursement"
HDPHMO	=	"Hold disc amount for priv HMO"
HDOPUB	=	"Hold disc amount for oth public"
HDPRVE	=	"Hold disc amount for priv employer"
HDPRVI	=	"Hold disc amount for priv individual"
HDRX	=	"Hold INS_FLAG,RX_FLAG if rx cov disc card"
EV95FLG	=	"Last round number where date= 95"
INS_FLGS =	"Concatenated values of INS_FLAGS"
_SOPCAID =	"Potential SOP: Medicaid"
_SOPCARE =	"Potential SOP: Medicare"
_SOPDISC =	"Potential SOP: provider discount"
_SOPMA	=	"Potential SOP: MA"
_SOPOOP	=	"Potential SOP: OOP"
_SOPOTH	=	"Potential SOP: other sources"
_SOPPD	=	"Potential SOP: PDP"
_SOPPHMO =	"Potential SOP: Private HMO"
_SOPPRVE =	"Potential SOP: Priv insurance(EMPL)"
_SOPPRVI =	"Potential SOP: Priv insurance(INDIV)"
_SOPVA	=	"Potential SOP: VA"
ISOPCAID =	"Insurance based SOP: Medicaid"
ISOPCARE =	"Insurance based SOP: Medicare"
ISOPDISC =	"Insurance based SOP: discount"
ISOPMA	=	"Insurance based SOP: MA"
ISOPOOP	=	"Insurance based SOP: OOP"
ISOPOTH	=	"Insurance based SOP: Other sources"
ISOPPD	=	"Insurance based SOP: PartD"
ISOPPHMO =	"Insurance based SOP: Private HMO"
ISOPPRVE =	"Insurance based SOP: Private insurance(EMPL)"
ISOPPRVI =	"Insurance based SOP: Private insurance(INDIV)"
ISOPVA	=	"Insurance based SOP: VA"
NLNS	=	"NUMLINK NUMSAME"
PMSUMFLG =	"PM or OM added during summary"
RX_FLGS	=	"Concatenated values of RX_FLAGS"
XTRAS	=	"Costs,after NMLNKS,created from this cost"
HIC_ID	=	"HIC_ID"
SERV_DT =	"SRVC_DT"
NDC_CD	=	"PROD_SRVC_ID"
PLAN_CNTRCT_ID	=	"PLAN_CNTRCT_ID"
PBP_ID = "PBP_ID"
PLAN_CNTRCT_REC_ID	=	"PLAN_CNTRCT_REC_ID"
PLAN_PBP_REC_NUM	=	"PLAN_PBP_REC_NUM"
QNTY	=	"QTY_DSPNSD_NUM"
DAYSUPP	=		"DAYS_SUPLY_NUM"
INGRDNT_CST_PD_AMT	=	"INGRDNT_CST_PD_AMT"
DSPNSNG_FEE_PD_AMT	=	"DSPNSNG_FEE_PD_AMT"
TOT_AMT_ATTR_SLS_TAX_AMT = "TOT_AMT_ATTR_SLS_TAX_AMT"
GDC_ABV_OOPT_AMT =	"GDC_ABV_OOPT_AMT"
GDC_BLW_OOPT_AMT =	"GDC_BLW_OOPT_AMT"
PTNT_PAY_AMT =	"PTNT_PAY_AMT"
OTHR_TROOP_AMT = "OTHR_TROOP_AMT"
LICS_AMT =	"LICS_AMT"
PLRO_AMT =	"PLRO_AMT"
CVRD_D_PLAN_PD_AMT = "CVRD_D_PLAN_PD_AMT"
NCVRD_PLAN_PD_AMT	=	"NCVRD_PLAN_PD_AMT"
GCN_SEQNO =	"Generic Code No. Seq. No."
FORM =	"Dosage form description"
STR1 =	"Ingredient 1 strength"
STR2 =	"Ingredient 2 strength"
MCBS_FORM_CODE = "MCBS_FORM_CODE"
R86 = "Round 86" 
R87	= "Round 87"
R88	= "Round 88"
R89	= "Round 89"
PMCOND = "Cond. medicine is used for"
PMKNWNM = "Name of medicine is known "
evntnum_c = "Event Number_char"
round_c = "Round Number_char"
costnum_c = "Sequential Cost Number_char"
utilnum_c = "Utilization within this cost_char" 
ev95flg_c = "Last round number where date= 95_char";


run;

PROC SORT data=MCBSDATA.pm_events_pre_impd_20&curryear; BY BASEID; RUN; 
/* While the data is already sorted from previous step, this SORT is needed to force PROC CONTENTS to say SORTED:YES */


ods rtf file="&location.pm_events_pre_impd_20&curryear contents - %sysfunc(DATE(),mmddyyd10.).rtf";
proc contents data=MCBSDATA.pm_events_pre_impd_20&curryear varnum;run;
proc freq data=MCBSDATA.pm_events_pre_impd_20&curryear;
tables PDE_FLAG;
run;
ods rtf close;


