*-----------------------------------------------------------|
| THIS CODE CONCATENATES THE ONE TO ONE AND THE MULTICOST   |
| FILES SENT TO US FROM WESTAT AND ATTEMPTS TO DERIVE A     |
| THE PROPER METHODS TO ESTIMATE _TREIM REIMBURSMENT        |
| RAM 'RETAIL' GIVES US                                     |
| THE SOBRULES ARE AS FOLLOWS                               |
| 100=_NEWRECS=1_RECSPM=1_DIFPMS=1_PURCHPM=1                |
| 200=_NEWRECS=1 _RECSPM=1 _DIFPMS=1 _PURCHPM>1             |
| 300=_NEWRECS>1=_RECSPM>1 _DIFPMS=1 _PURCHPM>1             |
|400=_NEWRECS>1=_RECSPM>1=_DIFPMS>1=_PURCHPM>1              |
|450=_NEWRECS>1=_RECSPM>1=_DIFPMS>1 _PURCHPM>1 AND NE _NEWRECS|
| 500=_NEWRECS>_RECSPM                                      |
| 600=_NEWRECS=_RECSPM=_PURCHPM AND NE _DIFPMS              |
| 700=_NEWRECS=_RECSPM=_DIFPMS _PURCHPM=MISSING             |
| 800=ALL ARE MISSING                                       |
|-----------------------------------------------------------|
;

DATA DRUGSA;
SET MCBSDATA.OUTCOMM_Y&CurrYear;

IF _NEWRECS=. ;*AND FILE = '   ';
PMROID=BASEID||EVNTNUM||ROUND;
ID=BASEID||EVNTNUM||ROUND||UTILNUM;
AMTCARE_=_AMTCARE;
AMTCAID_=_AMTCAID;
AMTpHMO_=_AMTpHMO;
AMTVA_=_AMTVA;
AMTPRVE_=_AMTPRVE;
AMTPRVI_=_AMTPRVI;
AMTOOP_=_AMTOOP;
AMTDISC_=_AMTDISC;
AMTOTH_=_AMTOTH;
AMTPD_=_AMTPD;
AMTMA_=_AMTMA;

SOPCARE_=_SOPCARE;
SOPCAID_=_SOPCAID;
SOPpHMO_=_SOPpHMO;
SOPVA_=_SOPVA;
SOPPRVE_=_SOPPRVE;
SOPPRVI_=_SOPPRVI;
SOPOOP_=_SOPOOP;
SOPDISC_=_SOPDISC;
SOPOTH_=_SOPOTH;
SOPPD_=_SOPPD;
SOPMA_=_SOPMA;

PURCHPM_=_PURCHPM;
PMFORM_=PMFORMMC;
RUN;


********* THIS DATASET WE USE AT END;
********** OF PROG, IT IS ROUND 5-6 STUFF ;
********** FROM PREVIOUS YEAR AND TREIM IS ALREADY SET;
DATA DRUGSB;
SET MCBSDATA.OUTCOMM_Y&CurrYear;
IF _NEWRECS=. AND FILE = 'ALL';
PMROID=BASEID||EVNTNUM||ROUND;
ID=BASEID||EVNTNUM||ROUND||UTILNUM;
AMTCARE_=_AMTCARE;
AMTCAID_=_AMTCAID;
AMTpHMO_=_AMTpHMO;
AMTVA_=_AMTVA;
AMTPRVE_=_AMTPRVE;
AMTPRVI_=_AMTPRVI;
AMTOOP_=_AMTOOP;
AMTDISC_=_AMTDISC;
AMTOTH_=_AMTOTH;
AMTPD_=_AMTPD;
AMTMA_=_AMTMA;

SOPCARE_=_SOPCARE;
SOPCAID_=_SOPCAID;
SOPpHMO_=_SOPpHMO;
SOPVA_=_SOPVA;
SOPPRVE_=_SOPPRVE;
SOPPRVI_=_SOPPRVI;
SOPOOP_=_SOPOOP;
SOPDISC_=_SOPDISC;
SOPOTH_=_SOPOTH;
SOPPD_=_SOPPD;
SOPMA_=_SOPMA;

PURCHPM_=_PURCHPM;
PMFORM_=PMFORMMC;
RUN;
DATA DRUGS;
SET DRUGSA;
_AMTCARE=.;
_AMTCAID=.;
_AMTpHMO=.;
_AMTVA=.;
_AMTPRVE=.;
_AMTPRVI=.;
_AMTOOP=.;
_AMTDISC=.;
_AMTOTH=.;
_AMTPD=.;
_AMTMA=.;

*IF _SOPCARE=2 THEN _SOPCARE=0;
SOB='MISS';
IF EVPRICE<.5  AND EVPRICE NE . THEN EVPRICE=.5;
MULTIPLE=BASEID||_NEWRECS||_RECSPM||_DIFPMS||_PURCHPM||COSTNUM;
RUN;

*determine multiple length for merging;
proc sql noprint;
select max(length(MULTIPLE))
into:lengthset
from DRUGS;
quit;
%put &lengthset;

PROC SORT;
BY MULTIPLE;
RUN;
*;
*;
*;
DATA NUMSAME;
LENGTH TMPMUL $&lengthset..;
SET DRUGS;
BY MULTIPLE;
RETAIN TMPMUL '';
RETAIN TMPSET 0;
RETAIN COUNTER 0;
IF NUMLINKS>0 AND NUMSAME<0 THEN TMPSET=1;
IF NUMLINKS<0 AND NUMSAME>0 THEN TMPSET=.;
COUNTER=COUNTER+1;
IF FIRST.MULTIPLE THEN DO;
TMPMUL=MULTIPLE;
TMPSET=TMPSET;
COUNTER=1;
END;
RUN;
DATA B;
LENGTH TMPAAA $&lengthset..;
SET NUMSAME;
BY MULTIPLE;
RETAIN TMPAAA '';
RETAIN TMPNS 0;
IF TMPAAA=MULTIPLE THEN TMPNS=TMPNS+TMPSET;
IF FIRST.MULTIPLE THEN DO;
TMPAAA=MULTIPLE;
TMPNS=TMPSET;
END;
RUN;
DATA C(KEEP=COUNTER MULTIPLE TMPNS);
SET B;
BY MULTIPLE;
IF LAST.MULTIPLE;
RUN;
DATA A OUT;
MERGE DRUGS (IN=AA) C (IN=B);
BY MULTIPLE;
IF AA;
IF B THEN OUTPUT A;
ELSE OUTPUT OUT;
RUN;
DATA B;
SET A;
 
DATA PRI(DROP=TMPMUL TMPAAA);
SET A;
IF COUNTER NE _PURCHPM THEN _PURCHPM=COUNTER;
IF TMPNS NE . AND TOTALCHG>0 THEN FIN_CHG=(TOTALCHG/_PURCHPM);
IF TMPNS=. AND TOTALCHG>0 THEN FIN_CHG=TOTALCHG;
IF TOTALCHG<0 THEN FIN_CHG=.;
RUN;
*;
*;
*;
PROC SORT;
BY PMROID;
RUN;
DATA TRYIT;
SET PRI;
BY PMROID;
RETAIN TMPFIN 0;
RETAIN TMPPMRO '             ';
IF PMROID=TMPPMRO THEN TMPFIN=FIN_CHG;
ELSE TMPFIN=FIN_CHG;
IF FIRST.PMROID THEN DO;
TMPFIN=FIN_CHG;
TMPPMRO=PMROID;
END;
RUN;
DATA X;
SET TRYIT;
MYCARE=_AMTCARE;
MYCAID=_AMTCAID;
MYpHMO=_AMTpHMO;
MYVA=_AMTVA;
MYPRVI=_AMTPRVI;
MYPRVE=_AMTPRVE;
MYOOP=_AMTOOP;
MYDISC=_AMTDISC;
MYOTH=_AMTOTH;
MYPD=_AMTPD;
MYMA=_AMTMA;

IF TMPNS NE . THEN MYCARE=_AMTCARE/_PURCHPM;
IF TMPNS NE . THEN MYCAID=_AMTCAID/_PURCHPM;
IF TMPNS NE . THEN MYpHMO=_AMTpHMO/_PURCHPM;
IF TMPNS NE . THEN MYVA=_AMTVA/_PURCHPM;
IF TMPNS NE . THEN MYPRVI=_AMTPRVI/_PURCHPM;
IF TMPNS NE . THEN MYPRVE=_AMTPRVE/_PURCHPM;
IF TMPNS NE . THEN MYOOP=_AMTOOP/_PURCHPM;
IF TMPNS NE . THEN MYDISC=_AMTDISC/_PURCHPM;
IF TMPNS NE . THEN MYOTH=_AMTOTH/_PURCHPM;
IF TMPNS NE . THEN MYPD=_AMTPD/_PURCHPM;
IF TMPNS NE . THEN MYMA=_AMTMA/_PURCHPM;

*IF TMPNS NE . THEN _AMTCARE=_AMTCARE/_PURCHPM;
*IF TMPNS NE . THEN _AMTCAID=_AMTCAID/_PURCHPM;
*IF TMPNS NE . THEN _AMTpHMO=_AMTpHMO/_PURCHPM;
*IF TMPNS NE . THEN _AMTVA=_AMTVA/_PURCHPM;
*IF TMPNS NE . THEN _AMTPRVI=_AMTPRVI/_PURCHPM;
*IF TMPNS NE . THEN _AMTPRVE=_AMTPRVE/_PURCHPM;
*IF TMPNS NE . THEN _AMTOOP=_AMTOOP/_PURCHPM;
*IF TMPNS NE . THEN _AMTDISC=_AMTDISC/_PURCHPM;
*IF TMPNS NE . THEN _AMTOTH=_AMTOTH/_PURCHPM;
*IF TMPNS NE . THEN _AMTPD=_AMTPD/_PURCHPM;
*IF TMPNS NE . THEN _AMTMA=_AMTMA/_PURCHPM;

RUN;
DATA X;
SET X;
IF _AMTCARE=. THEN MYCARE=0;
IF _AMTCAID=. THEN MYCAID=0;
IF _AMTpHMO=. THEN MYpHMO=0;
IF _AMTVA=. THEN MYVA=0;
IF _AMTPRVI=. THEN MYPRVI=0;
IF _AMTPRVE=. THEN MYPRVE=0;
IF _AMTOOP=. THEN MYOOP=0;
IF _AMTDISC=. THEN MYDISC=0;
IF _AMTOTH=. THEN MYOTH=0;
IF _AMTPD=. THEN MYPD=0;
IF _AMTMA=. THEN MYMA=0;

MYTOTAL=MYCARE+MYCAID+MYpHMO+MYVA+MYPRVI+MYPRVE+MYOOP+MYDISC+MYOTH +MYPD+MYMA;

RUN;
*******************FACTOR CODE GOES HERE**********************;
DATA VECTORS;
SET X;
VCAID=' ';
VCARE=' ';
VDISC=' ';
VpHMO =' ';
VOOP =' ';
VOTH =' ';
VPRVE=' ';
VPRVI=' ';
VVA  =' ';
VPD  =' ';
VMA  =' ';

VCAID=PUT(_SOPCAID,1. );
VCARE=PUT(_SOPCARE,1. );
VDISC=PUT(_SOPDISC,1. );
VpHMO =PUT(_SOPpHMO ,1. );
VOOP =PUT(_SOPOOP ,1. );
VOTH =PUT(_SOPOTH ,1. );
VPRVE=PUT(_SOPPRVE,1. );
VPRVI=PUT(_SOPPRVI,1. );
VVA  =PUT(_SOPVA  ,1. );
VPD  =PUT(_SOPPD  ,1. );
VMA  =PUT(_SOPMA  ,1. );

*PAYVECT=VCAID||VCARE||VDISC||VpHMO||VOOP||VOTH||VPRVE||VPRVI||VVA;
PAYVECT2=VCAID||VCARE||VDISC||VpHMO||VOOP||VOTH||VPRVE||VPRVI||VVA||VPD||VMA;
RUN;
PROC SORT DATA=VECTORS;
BY PAYVECT2;
DATA PAYFACT;
SET MCBSDATA.PAYFACT2_&CurrYear;
 *INFILE PAYF;
 *INPUT PAYVECT $ 1-9 PAYFACT $ 10-10;
RUN;

PROC SORT DATA=PAYFACT;
BY PAYVECT2;
run;
DATA TOG WHY;
MERGE VECTORS (IN=A) PAYFACT (IN=B);
BY PAYVECT2;
IF A;
IF B THEN OUTPUT TOG;
ELSE OUTPUT WHY;
run;
***********************;
DATA Z;
SET TOG WHY;
IF _SOPCARE=2 THEN DO;
_SOPCARE=0;
_AMTCARE=0;
END;
RUN;
proc sql; select distinct payvect2 from why;quit;
DATA MCBSDATA.SOBMISS;
SET Z DRUGSB;
_IMPSTAT=2;
IF EVPRICE NE . AND PAYFACT NE ' ' THEN DO;
IF PAYFACT='R' AND EVPRICE<5                   THEN DO;_TREIM=EVPRICE*&R_factor_LT5;END;
IF PAYFACT='R' AND EVPRICE>4.99 AND EVPRICE<20 THEN DO;_TREIM=EVPRICE*&R_factor_5_20;END;
IF PAYFACT='R' AND EVPRICE>19.99               THEN DO;_TREIM=EVPRICE*&R_factor_GT20;END;
IF PAYFACT='E' THEN DO;_TREIM=EVPRICE*&E_factor;END;
IF PAYFACT='H' THEN DO;_TREIM=EVPRICE*&H_factor;END;
IF PAYFACT='V' THEN DO;_TREIM=EVPRICE*&V_factor;END;
IF PAYFACT='C' THEN DO;_TREIM=(EVPRICE*&C_factor) + (&C_PLUS);END;
IF PAYFACT='O' THEN DO;_TREIM=(EVPRICE*&O_factor) + (&O_PLUS);END;
IF PAYFACT='P' THEN DO;_TREIM=EVPRICE*&P_factor;END;
IF PAYFACT='A' THEN DO;_TREIM=EVPRICE*&A_factor;END;

END;
*IF PAYFACT='C' THEN _TREIM=BESTEST*.789;
RUN;