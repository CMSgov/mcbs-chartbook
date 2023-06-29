*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 06_PAYFACT1                                                              |
|      UPDATED: 01/21/2011                                                              |
|  INPUT FILES: Westat "FINAL" file, Prior year historical PAYFACT file                 |
| OUTPUT FILES: PAYFACT.xls (file to be cleaned), PAYFACT_YY (updated PAYFACT file      |
|  DESCRIPTION: Inputs the Westat "final" file to pull all combinations of payors,      |
|               then compares to the historical PAYFACT crosswalk file to determine the |
|               primary payor.  Any new combination of payor vectors must be mannually  |
|               assigned to a primary payor.                                            |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;

*Note -- 01/16/2017 **
*****Maggie does VPHMO have to be VPPHMO instead***;
**7/25/17 Can keep VPHMO as is*;
**Changed VHMO in program to VPHMO*;

ODS HTML CLOSE;
  ODS HTML;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;
options nofmterr;

%LET CURRYEAR=20;
%LET LASTYEAR=19;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";


DATA FINAL_&CURRYEAR;
SET  MCBSDATA.FINAL_&CURRYEAR._V2 
     (KEEP=_SOPCAID _SOPCARE _SOPDISC _SOPPHMO _SOPHMO _SOPOOP _SOPOTH _SOPPRVE _SOPPRVI _SOPVA _SOPPD _SOPMA  UNUSED);
*note: _SOPHMO contains private HMO and Medicare HMO, replacing with _SOPPHMO which contains private HMO only 
	   and _SOPMA which contains Medicare HMO only, but still refering to private HMO as "HMO";

VCAID=' ';
VCARE=' ';
VDISC=' ';
*VHMO =' ';
VPHMO =' ';
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
*VHMO =PUT(_SOPHMO ,1. );
VPHMO =PUT(_SOPPHMO ,1. );
VOOP =PUT(_SOPOOP ,1. );
VOTH =PUT(_SOPOTH ,1. );
VPRVE=PUT(_SOPPRVE,1. );
VPRVI=PUT(_SOPPRVI,1. );
VVA  =PUT(_SOPVA  ,1. );
VPD  =PUT(_SOPPD  ,1. );
VMA  =PUT(_SOPMA  ,1. );

PAYVECT=VCAID||VCARE||VDISC||VPHMO||VOOP||VOTH||VPRVE||VPRVI||VVA;
PAYVECT2=VCAID||VCARE||VDISC||VPHMO||VOOP||VOTH||VPRVE||VPRVI||VVA||VPD||VMA;
RUN;

proc freq data =FINAL_&CURRYEAR;
tables 
_SOPCAID _SOPCARE _SOPDISC _SOPPHMO _SOPHMO _SOPOOP _SOPOTH _SOPPRVE _SOPPRVI _SOPVA _SOPPD _SOPMA  
/missing;
run;


PROC FREQ DATA=FINAL_&CURRYEAR NOPRINT ;
TABLES PAYVECT2 / OUT=PAYFREQ_&CURRYEAR;
RUN;
PROC SORT DATA=PAYFREQ_&CURRYEAR NODUPKEY; BY PAYVECT2; RUN;

DATA PAYFACT_&LASTYEAR;
set MCBSLAST.PAYFACT2_&LASTYEAR;
RENAME PAYFACT=PAYFACT_OLD;
LABEL PAYFACT=;
RUN;
PROC SORT DATA=PAYFACT_&LASTYEAR NODUPKEY; BY PAYVECT2; RUN;


DATA NEEDCORR;
MERGE PAYFREQ_&CURRYEAR (IN=A DROP=PERCENT)     
      PAYFACT_&LASTYEAR (IN=B drop= PAYVECT vpd vma )
        ;
BY PAYVECT2;

IF A OR B ;
Y_&LASTYEAR=B;
Y_&CURRYEAR=A;

if count=. then count=0;

*Initialize Payor Vars to Zero;
VCAID=0;
VCARE=0;
VDISC=0;
/*VHMO =0;*/
VPHMO=0;
VOOP =0;
VOTH =0;
VPRVE=0;
VPRVI=0;
VVA  =0;
VPD  =0;
VMA  =0;

*Reassign Payor Vars;
VCAID= INPUT(SUBSTR(PAYVECT2,1,1),1.);
VCARE= INPUT(SUBSTR(PAYVECT2,2,1),1.);
VDISC= INPUT(SUBSTR(PAYVECT2,3,1),1.);
*VHMO = INPUT(SUBSTR(PAYVECT2,4,1),1.);
VPHMO = INPUT(SUBSTR(PAYVECT2,4,1),1.);
VOOP = INPUT(SUBSTR(PAYVECT2,5,1),1.);
VOTH = INPUT(SUBSTR(PAYVECT2,6,1),1.);
VPRVE= INPUT(SUBSTR(PAYVECT2,7,1),1.);
VPRVI= INPUT(SUBSTR(PAYVECT2,8,1),1.);
VVA  = INPUT(SUBSTR(PAYVECT2,9,1),1.);
VPD  = INPUT(SUBSTR(PAYVECT2,10,1),1.);
VMA  = INPUT(SUBSTR(PAYVECT2,11,1),1.);


***ASSIGN PAYFACT VALUE;
payfact='';

if      VVA   in(1,2) then payfact="V";
else if VPD   in(1,2) then payfact="P";
else if VMA   in(1,2) then payfact="A";
else if VCAID in(1,2) then payfact="C";
else if VCARE in(1,2) then payfact="M";
else if VPRVE in(1,2) then payfact="E";
/*else if VHMO  in(1,2) then payfact="H";*/
else if VPHMO  in(1,2) then payfact="H";
else if VPRVI in(1,2) then payfact="H";
else if VOTH  in(1,2) then payfact="O";
else if VOOP  in(1,2) then payfact="R";
else if VDISC in(1,2) then payfact="R";


else if VVA   in(3,4) then payfact="V";
else if VPD   in(3,4) then payfact="P";
else if VMA   in(3,4) then payfact="A";
else if VCAID in(3,4) then payfact="C";
else if VCARE in(3,4) then payfact="M";
else if VPRVE in(3,4) then payfact="E";
/*else if VHMO  in(3,4) then payfact="H";*/
else if VPHMO  in(3,4) then payfact="H";
else if VPRVI in(3,4) then payfact="H";
else if VOTH  in(3,4) then payfact="O";
else if VOOP  in(3,4) then payfact="R";
else if VDISC in(3,4) then payfact="R";

ELSE payfact="R";

RUN;

PROC FREQ DATA=NEEDCORR ORDER =FREQ;
TABLES PAYFACT;
WEIGHT COUNT;
RUN;


*MAKE FINAL TABLE;
DATA MCBSDATA.PAYFACT2_&CURRYEAR; 
SET  NEEDCORR (keep=payvect2 payfact);

PAYVECT=SUBSTR(PAYVECT2,1,9);

VPD  = PUT(SUBSTR(PAYVECT2,10,1),1.);
VMA  = PUT(SUBSTR(PAYVECT2,11,1),1.);

RUN;



/*
**********LAST YEAR;
DATA LAST;
SET  MCBSLAST.FINAL_&LASTYEAR._V2 
     (KEEP=_SOPCAID _SOPCARE _SOPDISC _SOPPHMO _SOPHMO _SOPOOP _SOPOTH _SOPPRVE _SOPPRVI _SOPVA _SOPPD _SOPMA  UNUSED);


VCAID=' ';
VCARE=' ';
VDISC=' ';
VHMO =' ';
VPHMO =' ';
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
VHMO =PUT(_SOPHMO ,1. );
VPHMO =PUT(_SOPPHMO ,1. );
VOOP =PUT(_SOPOOP ,1. );
VOTH =PUT(_SOPOTH ,1. );
VPRVE=PUT(_SOPPRVE,1. );
VPRVI=PUT(_SOPPRVI,1. );
VVA  =PUT(_SOPVA  ,1. );
VPD  =PUT(_SOPPD  ,1. );
VMA  =PUT(_SOPMA  ,1. );




PAYVECT2_old=VCAID||VCARE||VDISC||VHMO||VOOP||VOTH||VPRVE||VPRVI||VVA||VPD||VMA;
PAYVECT2    =VCAID||VCARE||VDISC||VpHMO||VOOP||VOTH||VPRVE||VPRVI||VVA||VPD||VMA;

RUN;


PROC FREQ DATA=LAST NOPRINT ;
TABLES PAYVECT2 / OUT=LAST_FREQ;
RUN;
PROC SORT DATA=LAST_FREQ NODUPKEY; BY PAYVECT2; RUN;

DATA LAST_FREQ; 
SET LAST_FREQ;

*Initialize Payor Vars to Zero;
VCAID=0;
VCARE=0;
VDISC=0;
VHMO =0;
VOOP =0;
VOTH =0;
VPRVE=0;
VPRVI=0;
VVA  =0;
VPD  =0;
VMA  =0;

*Reassign Payor Vars;
VCAID= INPUT(SUBSTR(PAYVECT2,1,1),1.);
VCARE= INPUT(SUBSTR(PAYVECT2,2,1),1.);
VDISC= INPUT(SUBSTR(PAYVECT2,3,1),1.);
VHMO = INPUT(SUBSTR(PAYVECT2,4,1),1.);
VOOP = INPUT(SUBSTR(PAYVECT2,5,1),1.);
VOTH = INPUT(SUBSTR(PAYVECT2,6,1),1.);
VPRVE= INPUT(SUBSTR(PAYVECT2,7,1),1.);
VPRVI= INPUT(SUBSTR(PAYVECT2,8,1),1.);
VVA  = INPUT(SUBSTR(PAYVECT2,9,1),1.);
VPD  = INPUT(SUBSTR(PAYVECT2,10,1),1.);
VMA  = INPUT(SUBSTR(PAYVECT2,11,1),1.);
***ASSIGN PAYFACT VALUE;
payfact_NEW='';

if      VVA   in(1,2) then payfact="V";
else if VPD   in(1,2) then payfact="P";
else if VHMO  in(1,2) then payfact="H";
else if VPRVI in(1,2) then payfact="H";

else if VMA   in(1,2) then payfact="A";
else if VCAID in(1,2) then payfact="C";
else if VCARE in(1,2) then payfact="M";
else if VPRVE in(1,2) then payfact="E";

else if VOTH  in(1,2) then payfact="O";
else if VOOP  in(1,2) then payfact="R";
else if VDISC in(1,2) then payfact="R";


else if VVA   in(3,4) then payfact="V";
else if VPD   in(3,4) then payfact="P";
else if VHMO  in(3,4) then payfact="H";
else if VPRVI in(3,4) then payfact="H";

else if VMA   in(3,4) then payfact="A";
else if VCAID in(3,4) then payfact="C";
else if VCARE in(3,4) then payfact="M";
else if VPRVE in(3,4) then payfact="E";

else if VOTH  in(3,4) then payfact="O";
else if VOOP  in(3,4) then payfact="R";
else if VDISC in(3,4) then payfact="R";

ELSE payfact="R";


if VHMO  in(1,2) then hmo=1;
else if VPRVI in(1,2) then hmo=1;
else if VHMO  in(3,4) then hmo=2;
else if VPRVI in(3,4) then hmo=2;



RUN;

proc freq data =last;
tables 
_SOPCAID _SOPCARE _SOPDISC _SOPPHMO _SOPHMO _SOPOOP _SOPOTH _SOPPRVE _SOPPRVI _SOPVA _SOPPD _SOPMA  
/missing;
run;


PROC SQL;
CREATE TABLE LAST_PAYFACT AS SELECT 
 A.*,
 B.PAYFACT as payfact_old
FROM LAST_FREQ A 
LEFT JOIN MCBSLAST.PAYFACT2_&LASTYEAR B ON A.PAYVECT2_old=B.PAYVECT2;
QUIT;

TITLE 'last year';
PROC FREQ DATA=LAST_PAYFACT ORDER =FREQ;
TABLES PAYFACT payfact_old;
WEIGHT COUNT;
RUN;
