
ODS HTML CLOSE;
  ODS HTML;

libname ref2020 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Timeline'; /*REF2020*/
libname POP 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\2020 Population'; /* 2020 POP FILE*/
libname FILES 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Datafiles\Community\2020 CAAF';
libname r88F  'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Datafiles\Facility\Fall 2020 (Round 88) Data';
libname r87F  'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Datafiles\Facility\Summer 2020 (Round 87) Data';
libname r86F  'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Datafiles\Facility\Winter 2020 (Round 86) Data';
libname IntvLnth 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\INTERV\INTERIM'; /*Output*/
libname MRESROND 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\INTERV\INTERIM'; /*Output*/
libname ROSTRND 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\INTERV\INTERIM'; /*Output*/

LIBNAME MCBSDATA 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\INTERV'; /*FINAL FILES*/

LIBNAME fmts 'Y:\Share\SMAG\MCBS\MCBS Codebook Production\Formats\2020 Formats';
options fmtsearch=(fmts);

options nofmterr;

DATA POP20 (keep=baseid); 
set POP.POP2020_FINAL_FEB22; 
proc sort; by baseid; 
run;

/*REF 2020 -- missing MINTOTAL.  This code will separate REF2020 into individual round files*/
/*REF contains: BASEID ROUND RESP INT_TYPE SEQNUM INTVDISP TOTLINTV INTVDATE INTMODE */
DATA timeline;     
SET REF2020.REF2020;
PROC SORT;                         
BY baseid; 
run;

/*Timeline (REF2020) file with just POP people*/
Data timeline2;
merge POP20 (in=a) timeline (in=b);
by baseid; if a;
run;

/*Split REF file into community and facility*/
data IntvLnth.REF_F IntvLnth.REF_C;
set timeline2;
if INT_TYPE='C' then output IntvLnth.REF_C; 
	else if INT_TYPE='F' then output IntvLnth.REF_F;
 proc sort;
  by baseid; 
  run;

/*Split community REF into rounds and to be set later with community time in INTV*/
data IntvLnth.r86 IntvLnth.r87 IntvLnth.r88;
set IntvLnth.REF_C;
if round=86 then output IntvLnth.r86;
   else if round=87 then output IntvLnth.r87;
	else if round=88 then output IntvLnth.r88;
  proc sort;
  by baseid; 
  run;

/*Split facility interviews by round and to be set later with facility time in SP*/
data IntvLnth.F86 IntvLnth.F87 IntvLnth.F88;
set IntvLnth.REF_F;
if INT_TYPE='F' and round=86 then output IntvLnth.F86;
   else if INT_TYPE='F' and round=87 then output IntvLnth.F87;
	else if INT_TYPE='F' and round=88 then output IntvLnth.F88;
  proc sort;
  by baseid; 
  run;

/*STOP HERE AND CHECK OUTPUT FILES*/

/*LENGTH OF COMMUNITY INTERVIEW IS NOW ON INTV SEGMENT*/
/*INTV contains: BASEID INTVRND INTVRESP INTVID RROSTNUM INTLANG
  SPPROXY WHYPROXY RHELPNUM RINFOSAT RRECHELP CINTDUR*/
/*As of 2018 INTVDISP INTVDATE are in REF file*/
  DATA INTV1;     
SET FILES.INTV;
/*renamed so not to get confused with these vars on REF*/
rename INTVRND=RNDI;
rename INTVRESP=RESPI;
PROC SORT;                         
BY baseid;
run;

/*INTV file with just INTV and POP people*/
Data INTV2;
merge POP20 (in=a) INTV1 (in=b);
by baseid; if a and b; /*merged by a and b b/c I don't want to keep the 
facility baseids that show up in POP since INTV is community only*/
run;

/*Split INTV into round files*/
data IntvLnth.r86intv IntvLnth.r87intv IntvLnth.r88intv;
set INTV2;
if rndI=86 then output IntvLnth.r86intv;
   else if rndI=87 then output IntvLnth.r87intv;
	else if rndI=88 then output IntvLnth.r88intv;
  proc sort;
  by baseid; 
  run;

/*merge community REF round data with community interview round data (INTV)*/
options nofmterr;
libname IntvLnth 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\INTERV\INTERIM';
run;

Data IntvLnth.REFIN86;
MERGE IntvLnth.r86 (in=a)
      IntvLnth.R86intv (in=b);   
 BY baseid; 
run;

Data IntvLnth.REFIN87;
MERGE IntvLnth.r87 (in=a)
      IntvLnth.r87INTV (in=b);   
 BY baseid; 
run;

Data IntvLnth.REFIN88;
MERGE IntvLnth.r88 (in=a)
      IntvLnth.r88INTV (in=b);   
 BY baseid; 
run;

/*Facility interview length rounds*/ /*rename fintdur*/
data IntvLnth.FTIME88 (keep=baseid mintotal /*fintdur*/);
set r88F.sp;
rename fintdur=mintotal;
proc sort; by baseid;
run;

/*Merge facility time with facility from REF*/
data IntvLnth.F88ALL;
merge IntvLnth.F88 (in=a) IntvLnth.FTIME88 (in=b);
by baseid; if a;
run;

/*Facility interview length rounds*/ /*rename fintdur*/
data IntvLnth.FTIME87 (keep=baseid mintotal /*fintdur*/);
set r87F.sp;
rename fintdur=mintotal;
proc sort; by baseid;
run;

/*Merge facility time with facility from REF*/
data IntvLnth.F87ALL;
merge IntvLnth.F87 (in=a) IntvLnth.FTIME87 (in=b);
by baseid; if a;
run;

/*Facility interview length rounds*/ /*rename fintdur*/
data IntvLnth.FTIME86 (keep=baseid mintotal /*fintdur*/);
set r86F.sp;
rename fintdur=mintotal;
proc sort; by baseid;
run;

/*Merge facility time with facility from REF*/
data IntvLnth.F86ALL;
merge IntvLnth.F86 (in=a) IntvLnth.FTIME86 (in=b);
by baseid; if a;
run;

/*Merge community REF/INTV round data with facility data*/
data IntvLnth.REFIN88A;
set IntvLnth.REFIN88 (in=a)
	  IntvLnth.F88ALL (in=b);
by baseid; 
run;

data IntvLnth.REFIN87A;
set IntvLnth.REFIN87 (in=a)
	  IntvLnth.F87ALL (in=b);
by baseid;
run;	

data IntvLnth.REFIN86A;
set IntvLnth.REFIN86 (in=a)
	  IntvLnth.F86ALL (in=b);
by baseid;
run;

/*STOP HERE AND CHECK OUTPUT FILES*/
/*Code to Concatenate the data sets*/
options nofmterr;
libname IntvLnth 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\INTERV\INTERIM';
run;
data IntvLnth.all2020;
set IntvLnth.REFIN88A IntvLnth.REFIN87A IntvLnth.REFIN86A;
/*few checks*/
if INT_TYPE='F' then CINTDUR=.;
else if INT_TYPE='C' then MINTOTAL=.;
if ROUND=. and RNDI>0 then ROUND=RNDI;
if RESP=. and RESPI>0 then RESP=RESPI;
/*Comm and Facil time is now MINTOTAL*/

if MINTOTAL=. and CINTDUR >0 then MINTOTAL=CINTDUR;
proc sort;
by baseid;
run;

/*END OF CODE TO APPENED INTERVIEW LENGTH ONTO REF2020 FILE CHECK FINAL OUTPUT FILE*/

 /*SAME PROCESS AS BEFORE WITH NEW REFERENCE FILE CREATED BY MSM IN PREVIOUS STEP*/
DATA TL; SET IntvLnth.all2020;
IF INTVDISP=40 OR INTVDISP=50;
IF ROUND=86 OR ROUND=87 OR ROUND=88;

PROC SORT DATA=TL NODUP; BY BASEID ROUND RESP;
DATA IntvLnth.TL;
MERGE POP20(IN=P) TL(IN=T); BY BASEID; IF P & T;

PROC FREQ; TABLES RESP*SPPROXY*INT_TYPE/LIST MISSING; TITLE 'TL'; run;


/*Including ROSTREL*/

data ROSTIN (keep = baseid round rostrel rostnum);
set FILES.ROST;
rename rostrndc=round;
proc sort; 
by baseid;
run;


/*ROST was delivered with multiple rounds this puts each round into separate files*/
data ROSTRND.r86 ROSTRND.r87 ROSTRND.r88;
set ROSTIN;
if ROUND='86' then output ROSTRND.r86;
else if ROUND='87' then output ROSTRND.r87;
else output ROSTRND.r88;
  proc sort;
  by baseid; 
 run;

DATA ROST1;
SET ROSTRND.r88(KEEP=BASEID ROSTNUM ROUND ROSTREL)
 ROSTRND.r87(KEEP=BASEID ROSTNUM ROUND ROSTREL) /* GET EARLIER ROUNDS FOR*/ 
ROSTRND.r86(KEEP=BASEID ROSTNUM ROUND ROSTREL);/* PEOPLE WHO DIED BEFORE FALL*/
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


data finaldata (keep = SURVEYYR VERSION BASEID INTERVU INTVDATE MINTOTAL
INTLANG SPPROXY /*D_PROXRL*/ ROSTREL WHYPROXY RRECHELP RINFOSAT SEQNUM TOTLINTV INTVDISP ROUND INTVFLG INTMODE);
set TLMROST;

Version=1;
SURVEYYR=2020;
*INTMODE=1;
rename INT_TYPE = INTERVU;

/*2017 edits that were made during discussions with DRG*/
/*if SPPROXY = 1 then ROSTREL = 1;*/
if SPPROXY ne 1 then RRECHELP = .;
if SPPROXY = 1 then ROSTREL = .;
if INT_TYPE = 'F' then ROSTREL = .;

if round = 88 then INTVFLG = 1;
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
    INTMODE /*on REF*/
	INTERVU /*ON REF*/
	INTVDATE /*on INTV and REF*/
	MINTOTAL /*on INTV*/
	INTLANG  /*ON INTV*/
	SPPROXY /*ON INTV*/
	/*D_PROXRL*/
	ROSTREL /*Back in 2017*/ 
	WHYPROXY /*ON INTV*/
	RRECHELP /*BACK IN 2016*/ /*On INTV*/
	RINFOSAT /*BACK IN 2016*/ 
	SEQNUM /*ON REF*/
	TOTLINTV /*ON REF*/
	INTVDISP /*ON INTV*/
	;

	SET FINALDATA;
	 by baseid seqnum;

  KEEP   BASEID SURVEYYR VERSION INTVFLG INTMODE INTERVU INTVDATE MINTOTAL INTLANG 
	     SPPROXY /*D_PROXRL*/ ROSTREL WHYPROXY RRECHELP RINFOSAT
		  SEQNUM TOTLINTV INTVDISP ;

  FORMAT BASEID SURVEYYR VERSION INTVFLG INTMODE INTERVU INTVDATE MINTOTAL INTLANG 
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
	 MINTOTAL LENFMT.
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
	 MINTOTAL = "Duration of interview in minutes"
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
tables  BASEID SURVEYYR VERSION INTVFLG INTMODE INTERVU INTVDATE MINTOTAL INTLANG 
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
     		OUTFILE= "Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\INTERV\interv.csv" 
     		DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


proc freq data=MCBSDATA.INTERV_unfmt;
table SURVEYYR--INTVDISP /list missing;
title 'Order variables without formats';
run;


proc contents data=mcbsdata.INTERV;
run;

