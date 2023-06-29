*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 04_BB3_FINAL                                                            |
|      UPDATED: 01/21/2011                                                              |
|  INPUT FILES: THRUBDMS, ROLLUP_ALL                                                    |
| OUTPUT FILES: FINAL_DATA.txt,  outstats.txt                                           |
|  DESCRIPTION: Imports the survey data with BN, merges with the FDB "Rollup" output    |
|               and runs final Legacy processing to impute the individual event costs.  |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear  =20;
%let LastYear  =19;

%let location= C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%LET MACRO_LOC=C:\Users\S1C3\RIC PME\MCBS\2020\PME\SAS Code 2020\Macros\; /*UPDATE*/

libname  MCBSDATA "&location";
filename THRUBDMS "&location.THRUBDMS.txt";
filename FNL_DATA "&location.FINAL_DATA.txt";
filename outstats "&location.outstats.txt";

*******************************************************************;
* PROCESS SURVEY RECORDS                                          *;
*******************************************************************;
DATA SURVEY;
INFILE THRUBDMS TRUNCOVER lrecl=256; /*2015 UPDATED INPUTS*//*2013 UPDATED INPUTS TO ADJUST FOR UTILNUM*/

INPUT
@ 1    I_RECORD $156.
@ 1    I_ENUM   $13.
@ 14   BN       $60.
@ 74   I_DCODE  ??
@ 82   I_STRN1  ??
@ 90   I_STRU1  ??
@ 99   UTILNUM  $4.
@ 103  I_AMTN   ??
@ 108  I_AMTU   ??
@ 111  I_SUPN   ??
@ 114  I_TABN   ??
@ 118  I_TABSDA ??
@ 124  I_TABTAK ??
@ 130  I_CMPFL  3.
@ 141  I_PMCOND  ??
@ 149  I_PMKNWN  ??
;


/*
@ 1    I_RECORD $156.
@ 1    I_ENUM   $13.
@ 14   BN       $60.
@ 74   I_DCODE  8.
@ 82   I_STRN1  8.
@ 90   I_STRU1  $CHAR8.
@ 99   UTILNUM  $4.
@ 103  I_AMTN   5.
@ 109  I_AMTU   $3.
@ 111  I_SUPN   3.
@ 114  I_TABN   4.
@ 119  I_TABSDA 3.
@ 121  I_TAKUNT 3.
@ 124  I_TABTAK 3.
@ 127  I_TAKN   3.
@ 130  I_CMPFL  3.
@ 141  I_STRN2  8.
@ 149  I_STRU2  $8.

@ 1    I_RECORD $155.
@ 1    I_ENUM   $13.
@ 14   BN       $60.
@ 74   I_DCODE  8.
@ 82   I_STRN1  8.
@ 90   I_STRU1  8.
@ 98   UTILNUM  $4.
@ 102  I_AMTN   5.
@ 107  I_AMTU   3.
@ 110  I_SUPN   3.
@ 113  I_TABN   4.
@ 117  I_TABSDA 3.
@ 120  I_TAKUNT 3.
@ 123  I_TABTAK 3.
@ 126  I_TAKN   3.
@ 129  I_CMPFL  3.
@ 140  I_STRN2  8.
@ 148  I_STRU2  8. */

IF I_AMTN   EQ .  THEN I_AMTN    = 0;
IF I_SUPN   EQ .  THEN I_SUPN    = 0;
IF I_STRN1  EQ .  THEN I_STRN1   = 0;
IF I_CMPFL  EQ . THEN I_CMPFL   = 0;
IF I_TABN   EQ . THEN I_TABN    = 0;
IF I_TABSDA EQ . THEN I_TABSDA  = 0;
IF I_TAKUNT EQ . THEN I_TAKUNT  = 0;
IF I_TABTAK EQ . THEN I_TABTAK  = 0;
IF I_TAKN   EQ . THEN I_TAKN    = 0;
IF I_STRU1  EQ . THEN I_STRU1 = '';


/*IF I_AMTN   EQ . OR I_AMTN    EQ -1 THEN I_AMTN    = 0;
IF I_SUPN   EQ . OR I_SUPN    EQ -1 THEN I_SUPN    = 0;
IF I_STRN1  EQ . OR I_STRN1   EQ -1 THEN I_STRN1   = 0;
IF I_STRN2  EQ . OR I_STRN2   EQ -1 THEN I_STRN2   = 0;
IF I_CMPFL  EQ . THEN I_CMPFL   = 0;
IF I_TABN   EQ . THEN I_TABN    = 0;
IF I_TABSDA EQ . THEN I_TABSDA  = 0;
IF I_TAKUNT EQ . THEN I_TAKUNT  = 0;
IF I_TABTAK EQ . THEN I_TABTAK  = 0;
IF I_TAKN   EQ . THEN I_TAKN    = 0;
IF I_STRU1  EQ '-1' THEN I_STRU1 = '';
IF I_STRU2  EQ '-1' THEN I_STRU2 = '';*/

RUN;

*******************************************************************;
* SORT SURVEY RECORDS                                             *;
*******************************************************************;
PROC SORT OUT=SORTSURV;BY BN;
RUN;

PROC DELETE DATA=SURVEY;
RUN;
*******************************************************************;
* COMBINE SURVEY AND ROLLUP DATASETS                              *;
*******************************************************************;

*DUP CHECK;
proc sql;
create table dups as select bn
from MCBSDATA.ROLLUP_ALL 
group by bn 
having count(bn)>1 ;
quit;


DATA COMBINED A (KEEP=BN) B (KEEP=BN) AB (KEEP=BN) ;
MERGE SORTSURV            (IN=SURVEY) 
      MCBSDATA.ROLLUP_ALL (IN=ROLLUP) 
       END=LAST;
BY BN;

FILE "&LOCATION.FINAL_OUTERROR.TXT";
RETAIN TOTBAD 0;

IF _N_ EQ 1 THEN CALL SYMPUT('TOT_BAD','0');
IF SURVEY AND NOT ROLLUP THEN 
  DO;
    TOTBAD + 1;
    PUT BN;
  END;
ELSE IF NOT SURVEY AND ROLLUP THEN DELETE;
ELSE OUTPUT;
IF LAST THEN CALL SYMPUT('TOT_BAD',TOTBAD);

RUN;

*******************************************************************;
* START MAIN PROCESSING                                           *;
*******************************************************************;
DATA MCBSDATA.FINAL_PRCSD
   ( KEEP=I_RECORD DOSAGE STRENGTH AMTNUM TEC_CD OTC_CD AWP EVENT_PR CODE) ;
SET COMBINED END=LAST;
BY BN;

FORMAT 
DOSAGE $10. TEC_CD $3. OTC_CD $1. UNITCNV1 $3. UNITCNV2 $3. STRENGTH $10.
AMTNUM 10.3  AWP 10.5 EVENT_PR 12.5 IDX 8. DCD 8. A 8. X 8.RANDOM 8. 
MAX 8. DOS_FL 8.  STR_FL 8.  AMT_FL 8.  Y 8. IDX 8. EP1 14.5  DOS_FD 8.  
C_DCODE 8. STR_FD 8.  AMT_FD 8. TOTDCODE 8. TOTPROC 8. TEMP1-TEMP4 8.2 
TOTINP1-TOTINP3 8. ERROR_CD 8. TEMP1-TEMP4 8. AMTNUM1 10.3 CODE 8.  GEN 8. ;

ARRAY TMP_ARR {11}      8.   TOTARR1-TOTARR11;
ARRAY TOT_INP {3}       8.   TOTINP1-TOTINP3;
ARRAY TOT_DCD {15,4}    8.   TOTDCD1-TOTDCD60;
ARRAY UNIT1   {5}       $3.  UNITX1-UNITX5;
ARRAY UNIT2   {5}       $3.  UNITY1-UNITY5;
ARRAY TOT_CV  {14,13}   8.   TOTCV1-TOTCV182;
ARRAY AUNIT   {3}       $1.  AUNIT1-AUNIT3;
ARRAY RANG    {13,2}    8.   RANG1-RANG26;
ARRAY DC_CT   {13}      8.   DCCT1-DCCT13;
ARRAY DC_TP   {13}      8.   DCTP1-DCTP13;
ARRAY DC_TPD  {13}      $10. DCTPD1-DCTPD13;
ARRAY S1_CT   {2,10,2}  8.   S1CT1-S1CT40;
ARRAY S1_TP   {2,10}    $10. S1TP1-S1TP20;
ARRAY S1_NUM  {2,10,2}  8.   S1NUM1-S1NUM40;
ARRAY S1_UNT  {2,10,2}  $10. S1UNT1-S1UNT40;
ARRAY S1_COD  {2,10}    8.   S1COD1-S1COD20;
ARRAY S1_DOS  {2,10}    $10. S1DOS1-S1DOS20;
ARRAY S1_TEC  {2,10}    $3   S1TEC1-S1TEC20;
ARRAY S1_OTC  {2,10}    $3   S1OTC1-S1OTC20;
ARRAY S1_PR   {2,10}    8.   S1PR1-S1PR20;
ARRAY S1_CTR  {2}       8.   S1CTR1-S1CTR2;
ARRAY PK_CT   {11,3,2}  8.   PKCT1-PKCT66;
ARRAY PK_PS   {11,3}    8.   PKPS1-PKPS33;
ARRAY PK_DF   {11,3}    $1.  PKDF1-PKDF33;
ARRAY S2_CT   {11,3,3}  8.   S2CT1-S2CT99;
ARRAY S2_TP   {11,3,3}  $10. S2TP1-S2TP99;
ARRAY S2_COD  {11,3,3}  8.   S2COD1-S2COD99;
ARRAY S2_DOS  {11,3,3}  $10. S2DOS1-S2DOS99;
ARRAY S2_TEC  {11,3,3}  $3   S2TEC1-S2TEC99;
ARRAY S2_OTC  {11,3,3}  $3   S2OTC1-S2OTC99;
ARRAY S2_PR   {11,3,3}  8.   S2PR1-S2PR99;
ARRAY PK_CTR  {11}      8.   PKCTR1-PKCTR11;
ARRAY S2_CTR  {11,3}    3.   S2CTR1-S2CTR33;

RETAIN TOTDCD1-TOTDCD60 TOTOTCS TOTBAD TOTCV1-TOTCV182 0;
RETAIN UNITX1-UNITX5 UNITY1-UNITY5;

IF _N_ EQ 1 THEN DO;
UNIT1(1) = 'MCG';
UNIT1(2) = 'MG';
UNIT1(3) = 'G';
UNIT1(4) = 'MEQ';
UNIT1(5) = 'GM';
UNIT2(1) = '';
UNIT2(2) = '';
UNIT2(3) = 'GX';
UNIT2(4) = '';
UNIT2(5) = '';

TOTBAD = &TOT_BAD;
END;

DOS_FL = 0;STR_FL = 0;AMT_FL = 0;GEN = 0;
DOSAGE = '';STRENGTH = '';AMTNUM = 0;
TOTDCODE = I_DCODE;

IF I_DCODE EQ . THEN DO;
TOTDCODE = 14;
I_DCODE = 13;
END;
ELSE DO;
IF I_DCODE EQ 91 THEN DO;
TOTDCODE = 13;
I_DCODE = 13;
END;
ELSE IF I_DCODE GT 13 OR I_DCODE LT 1 THEN DO;
TOTDCODE = 14;
I_DCODE = 13;
END;
END;

IF I_AMTN    EQ .    THEN I_AMTN      = 0;
IF I_AMTU    EQ '.'  THEN I_AMTU      = '';
IF I_STRN1   EQ .    THEN I_STRN1     = 0;
IF I_STRU1   EQ '.'  THEN I_STRU1     = '';
IF I_SUPN    EQ .    THEN I_SUPN      = 0;

IF I_AMTU IN('-1','-8','-9','4 ','91') THEN
I_AMTU = '';

*******************************************************************;
*  1) IF DOSAGE FORM CODE IS 1 OR 10 - CALL DOSAGE AND STRENGTH   *;
*     SUBROUTINES                                                 *;
*  2) IF DOSAGE FORM CODE IS PRESENT - CALL DOSAGE AND PKG SIZE   *;
*     SUBROUTINES                                                 *;
*  3) IF STRENGTH IS PRESENT THEN CALL STRENGTH SUBROUTINE AND    *;
*     GENERATE DOSAGE FORM ( IF MATCH ON STRENGTH)                *;
*  4) IF PKG SIZE IS PRESENT THEN CALL PKG SIZE SUBROUTINE AND    *;
*     GENERATE DOSAGE FORM/STRENGTH (IF MATCH ON PACKAGE SIZE)    *;
*  5) OTHERWISE, GENERATE DOSAGE/STRENGTH OR DOSAGE/PACKAGE SIZE/ *;
*     STRENGTH                                                    *;
*******************************************************************;
IF I_DCODE EQ 1 OR I_DCODE EQ 10 THEN DO;
DOS_FD = 1;
LINK PROC_DOS;

LINK PROC_STR;

IF GEN THEN
LINK PROC_GEN;
END;
ELSE IF TOTDCODE NE 14 THEN DO;
DOS_FD = 1;
LINK PROC_DOS;
LINK PROC_PKG;

IF GEN THEN
LINK PROC_GEN;
END;
ELSE DO;
DOS_FD = 0;

IF I_STRN1 GT 0 OR I_STRU1 NE '' THEN DO;
LINK PROC_STR;

IF GEN THEN DO;
IF I_AMTN GT 0 OR I_AMTU NE '' OR I_SUPN GT 0 THEN DO;
GEN = 0;

LINK PROC_PKG;
END;
END;

IF GEN THEN
LINK PROC_GEN;
END;
ELSE IF I_AMTN GT 0 OR I_AMTU NE '' OR I_SUPN GT 0 THEN DO;
LINK PROC_PKG;

IF GEN THEN
LINK PROC_GEN;
END;
ELSE
LINK PROC_GEN;
END;

*******************************************************************;
*  WRITE PROCESSED INPUT RECORD AND AFTER LAST RECORD IS PROCESSED*;
*  OUTPUT STATISTICAL REPORT                                      *;
*******************************************************************;

LINK WRITE;

IF LAST THEN LINK STATS;
*******************************************************************;
* INCLUDE COMMON WRITE ROUTINES                                   *;
*******************************************************************;

FILENAME INCLIB  "&MACRO_LOC";


%INC INCLIB(MCB$DOS) /source2;
%INC INCLIB(MCB$STR) /source2;
%INC INCLIB(MCB$PKG) /source2;
%INC INCLIB(MCB$GEN) /source2;
%INC INCLIB(MCB$RDM) /source2;
%INC INCLIB(MCB$WRIT) /source2;
*note /source2 writes included code to the SAS log; 
RUN;

FILENAME INCLIB CLEAR;
