**Note for 2021 INTMODE is on new Interview Characteristics file; 
**This file should also replace INTV in CAAF;


ODS HTML CLOSE;
  ODS HTML;

libname ref2021 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Timeline'; /*REF2021*/
libname POP 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\2021 Population'; /* 2021 POP FILE*/
libname FILES 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Datafiles\Community\2021 CAAF\Data Files';
libname r91F  'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Datafiles\Facility\Fall 2021 (Round 91) Data';
libname r90F  'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Datafiles\Facility\Summer 2021 (Round 90) Data';
libname r89F  'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Datafiles\Facility\Winter 2021 (Round 89) Data';
libname IntvLnth 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Data Processing\INTERV\INTERIM'; /*Output*/
libname MRESROND 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Data Processing\INTERV\INTERIM'; /*Output*/
libname ROSTRND 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Data Processing\INTERV\INTERIM'; /*Output*/
libname IC 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Deliveries\Interview characteristics'; /*2021 IC*/
LIBNAME MCBSDATA 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Data Processing\INTERV'; /*FINAL FILES*/

LIBNAME fmts 'Y:\Share\SMAG\MCBS\MCBS Codebook Production\Formats\2021 Formats';
options fmtsearch=(fmts);

options nofmterr;

DATA POP21 (keep=baseid); 
set POP.pop2021_final_feb23; 
proc sort; by baseid; 
run;

/*REF contains: BASEID ROUND RESP INT_TYPE SEQNUM INTVDISP TOTLINTV INTVDATE */

DATA timeline;     
SET REF2021.REF2021; 
PROC SORT;                         
BY baseid; 
run;

/*Timeline (REF2021) file with just POP people*/
Data timeline2;
merge POP21(in=a) timeline (in=b);
by baseid; if a;
run;


/*Update for 2021 Split REF into rounds and to be set later with IC file*/
data IntvLnth.r89 IntvLnth.r90 IntvLnth.r91;
set timeline2;
if round=89 then output IntvLnth.r89;
   else if round=90 then output IntvLnth.r90;
	else if round=91 then output IntvLnth.r91;
  proc sort;
  by baseid; 
  run;


/*STOP HERE AND CHECK OUTPUT FILES*/

/*New data file for 2021 -- IC*/
/*IC contains: BASEID ROUND INT_TYPE INTMODE INTDUR RROSTNUM INTLANG
  SPPROXY WHYPROXY RHELPNUM RINFOSAT RRECHELP */

  DATA INTV1;     
	SET IC.IC2021 (keep = BASEID ROUND INT_TYPE INTMODE INTDUR RROSTNUM INTLANG
  SPPROXY WHYPROXY RHELPNUM RINFOSAT RRECHELP);
	/*renamed so not to get confused with these vars on REF*/
	rename ROUND=RNDI;
	rename INT_TYPE=TYPEI;
	PROC SORT;                         
	BY baseid;
	run;

/*IC file with just IC and POP people*/
Data INTV2;
merge POP21(in=a) INTV1 (in=b);
by baseid; if a and b; 
run;

/*Split IC into round files*/
data IntvLnth.r89intv IntvLnth.r90intv IntvLnth.r91intv;
set INTV2;
if rndI=89 then output IntvLnth.r89intv;
   else if rndI=90 then output IntvLnth.r90intv;
	else if rndI=91 then output IntvLnth.r91intv;
  proc sort;
  by baseid; 
  run;

/*merge REF round data with interview round data (IC)*/
options nofmterr;
libname IntvLnth 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Data Processing\INTERV\INTERIM';
run;

Data IntvLnth.REFIN89;
MERGE IntvLnth.r89 (in=a)
      IntvLnth.R89intv (in=b);   
 BY baseid; 
run;

Data IntvLnth.REFIN90;
MERGE IntvLnth.r90 (in=a)
      IntvLnth.r90INTV (in=b);   
 BY baseid; 
run;

Data IntvLnth.REFIN91;
MERGE IntvLnth.r91 (in=a)
      IntvLnth.r91INTV (in=b);   
 BY baseid; 
run;


/*STOP HERE AND CHECK OUTPUT FILES*/
/*Code to Concatenate the data sets*/
options nofmterr;
libname IntvLnth 'Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Data Processing\INTERV\INTERIM';
run;
data IntvLnth.all2021;
set IntvLnth.REFIN91 IntvLnth.REFIN90 IntvLnth.REFIN89;
/*few checks*/
if ROUND=. and RNDI>0 then ROUND=RNDI;
if INT_TYPE='.' and TYPEI> '0' then INT_TYPE=TYPEI;
/*Comm and Facil time is now INTDUR and on the IC*/

proc sort;
by baseid;
run;

/*END OF CODE TO JOIN REF2021 AND IC FILE -- CHECK FINAL OUTPUT FILE*/

 /*SAME PROCESS AS BEFORE WITH NEW REFERENCE FILE CREATED BY MSM IN PREVIOUS STEP*/
DATA TL; SET IntvLnth.all2021;
IF INTVDISP=40 OR INTVDISP=50;
IF ROUND=89 OR ROUND=90 OR ROUND=91;

PROC SORT DATA=TL NODUP; BY BASEID ROUND RESP;
DATA IntvLnth.TL;
MERGE POP21(IN=P) TL(IN=T); BY BASEID; IF P & T;

PROC FREQ; TABLES RESP*SPPROXY*INT_TYPE/LIST MISSING; TITLE 'TL'; run;


/*Including ROSTREL*/

data ROSTIN (keep = baseid round rostrel rostnum);
set FILES.ROST;
rename rostrndc=round;
proc sort; 
by baseid;
run;


/*ROST was delivered with multiple rounds this puts each round into separate files*/
data ROSTRND.r89 ROSTRND.r90 ROSTRND.r91;
set ROSTIN;
if ROUND='89' then output ROSTRND.r89;
else if ROUND='90' then output ROSTRND.r90;
else output ROSTRND.r91;
  proc sort;
  by baseid; 
 run;

DATA ROST1;
SET ROSTRND.r91(KEEP=BASEID ROSTNUM ROUND ROSTREL)
 ROSTRND.r90(KEEP=BASEID ROSTNUM ROUND ROSTREL) /* GET EARLIER ROUNDS FOR*/ 
ROSTRND.r89(KEEP=BASEID ROSTNUM ROUND ROSTREL);/* PEOPLE WHO DIED BEFORE FALL*/
PROC SORT DATA=ROST1 NODUPKEY; 
BY BASEID ROUND;
run;

PROC SORT DATA=IntvLnth.TL; 
BY BASEID ROUND /*RESP*/;
run;

DATA TLMROST;
MERGE IntvLnth.TL(IN=T) 
ROST1(IN=R);
BY BASEID ROUND;
IF T; 
IF NOT R THEN NOTROST=1;
run;


data finaldata (keep = SURVEYYR VERSION BASEID INTERVU INTVDATE INTDUR /*2021 should MINTOTAL be renamed to INTDUR??*/
INTLANG SPPROXY /*D_PROXRL*/ ROSTREL WHYPROXY RRECHELP RINFOSAT SEQNUM TOTLINTV INTVDISP ROUND INTVFLG INTMODE);
set TLMROST;

Version=1;
SURVEYYR=2021;
*INTMODE=1;
rename INT_TYPE = INTERVU;

/*2017 edits that were made during discussions with DRG*/
/*if SPPROXY = 1 then ROSTREL = 1;*/
if SPPROXY ne 1 then RRECHELP = .;
if SPPROXY = 1 then ROSTREL = .;
if INT_TYPE = 'F' then ROSTREL = .;

if round = 91 then INTVFLG = 1;
else INTVFLG = .;

proc sort; by baseid seqnum;   
run;

PROC FREQ DATA=finaldata;
TABLES SPPROXY*ROSTREL*WHYPROXY*RRECHELP*INTERVU/LIST MISSING; TITLE 'FINAL'; run;

 /*Output to SAS file and use Retain statement so variables are in proper order*/
 
DATA MCBSDATA.INTERV1;
RETAIN 
	BASEID 
	SURVEYYR
	VERSION 
	INTVFLG
    INTMODE /*ON IC*/
	INTERVU /*ON REF AND IC*/
	INTVDATE /*on REF*/
	INTDUR /*on IC*/
	INTLANG  /*ON IC*/
	SPPROXY /*ON IC*/
	/*D_PROXRL*/
	ROSTREL /*Back in 2017*/ 
	WHYPROXY /*ON IC*/
	RRECHELP /*BACK IN 2016*/ /*On IC*/
	RINFOSAT /*BACK IN 2016*/ /*On IC*/
	SEQNUM /*ON REF*/
	TOTLINTV /*ON REF*/
	INTVDISP /*ON REF*/
	;

	SET FINALDATA;
	 by baseid seqnum;

  KEEP   BASEID SURVEYYR VERSION INTVFLG INTMODE INTERVU INTVDATE INTDUR INTLANG 
	     SPPROXY /*D_PROXRL*/ ROSTREL WHYPROXY RRECHELP RINFOSAT
		  SEQNUM TOTLINTV INTVDISP ;

  FORMAT BASEID SURVEYYR VERSION INTVFLG INTMODE INTERVU INTVDATE INTDUR INTLANG 
	     SPPROXY /*D_PROXRL*/ ROSTREL WHYPROXY RRECHELP RINFOSAT
		  SEQNUM TOTLINTV INTVDISP ;

   RUN;

Data mcbsdata.INTERV2;
set mcbsdata.INTERV1;
 by baseid seqnum;
	/*Apply formats*/

FORMAT
     BASEID   $BSIDFMT.
	 SURVEYYR SVYRFMT.
     VERSION  VERSFMT.
	 INTVFLG INTVFMT.
     INTMODE MODE.
 	 INTERVU  $INTRFMT.
	 INTVDATE mmddyyn8.
	 INTDUR LENFMT.
	 INTLANG  LANGFMT.
	 SPPROXY  PROXFMT.
	 /*D_PROXRL*/
	 ROSTREL RELFMT.
	 WHYPROXY WHYPROXY.
	 RRECHELP  YES1FMT.
	 RINFOSAT YES1FMT.
	 SEQNUM   SEQFMT.
	 TOTLINTV TOTINFMT.
	 INTVDISP DISPFMT.
	 ;

  /*variable labels here*/

  LABEL
     BASEID   = "Unique SP Identification Number" 
	 SURVEYYR = "Survey Year"
	 VERSION  = "Version Number"
	 INTVFLG   = "Interview Timeframe"
     INTMODE   = "Interview Mode"
	 INTERVU  = "Type of interview"
	 INTVDATE = "Interview Date (MMDDYYYY)"
	 INTDUR = "Duration of interview in minutes"
	 INTLANG  = "Language of interview"
	 SPPROXY  = "Self - respondent or proxy"
	 /*D_PROXRL*/
	 ROSTREL   = "Proxy's relationship to SP"
	 WHYPROXY  = "Why proxy is needed"
	 RRECHELP  = "Did respondent receive help answering?"
	 RINFOSAT  = "Info provided by respondent satisfactory"
	 SEQNUM    = "Sequence number within SP"
	 TOTLINTV  = "Total number of interviews for SP"
	 INTVDISP  = "Interview Disposition"
     ;
  run;
	
Proc contents data=mcbsdata.INTERV2;
   run;

   proc freq data=mcbsdata.INTERV2;
tables  BASEID SURVEYYR VERSION INTVFLG INTMODE INTERVU INTVDATE INTDUR INTLANG 
	     SPPROXY /*D_PROXRL */ROSTREL WHYPROXY RRECHELP RINFOSAT
		  SEQNUM TOTLINTV INTVDISP/missing;
	   title 'INTERV ';
   run;

   data mcbsdata.INTERV;
   set mcbsdata.INTERV2;
   by baseid seqnum;
   run;
      PROC SORT data=mcbsdata.INTERV presorted; BY BASEID SEQNUM; RUN;
/* While the data is already sorted from previous step, this SORT is needed to force PROC CONTENTS to say SORTED:YES */

	data mcbsdata.INTERV_unfmt;
   set mcbsdata.INTERV1;
   by baseid seqnum;
   format _all_;
  format INTVDATE mmddyyn8.;
   run;

   ********************Remove variable labels******************;
proc datasets library=mcbsdata nolist;
  modify INTERV_unfmt;
  attrib _all_ label='';
quit;


   /*Create CSV file*/

PROC EXPORT DATA= MCBSDATA.INTERV_unfmt
     		OUTFILE= "Y:\Share\SMAG\MCBS\MCBS Survey File\2021\Admin\Data Processing\INTERV\interv.csv" 
     		DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


proc freq data=MCBSDATA.INTERV_unfmt;
table SURVEYYR--INTVDISP /list missing;
title 'Order variables without formats';
run;


proc contents data=mcbsdata.INTERV;
run;

