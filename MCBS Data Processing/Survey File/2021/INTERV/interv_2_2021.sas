/*For file year 2021 (and 2020,2019,2018,2017) the REF file that was delivered included interview data from R92.  
Due to this the total number of interviews (TOTLINTV) contained counts for R92 – 
this created a higher number of total interviews then in prior years.  
Using the REF 2021 file, a file with just BASEID the corrected counts
was created and merged to the old INTERV file.*/


DM output 'clear' continue;
DM log 'clear' continue; run;

%let topdir = Y:\Share\SMAG\MCBS;

libname sf "&topdir\MCBS Survey File\2021\Admin\Data Processing\INTERV";
libname tl "&topdir\MCBS Survey File\2021\Admin\Timeline";

libname mcbsfmts "&topdir\MCBS Codebook Production\Formats\2021 Formats";
options fmtsearch = (mcbsfmts);

options ls=130 ps=42;

/*Interview before corrected count*/
data interv_orig;
  set sf.interv_old;
  proc sort; by baseid;
run;

data reftl;
  set tl.ref2021;
  proc sort; by baseid;
    format _all_;
	format intvdate begdate enddate origbdat origedat date7.;
run;

data newsum(keep=baseid fielded);
  set reftl; by baseid;
    if first.baseid then fielded = 0;
    if round ne /*77*/ /*80*/ /*83*/ /*86*/ /*89*/ 92 and intvdisp ne . and intvdate ne . then fielded + 1; /*update round*/
    if last.baseid then output;
run;

data addnewsum(drop=fielded);
  merge interv_orig(in=a) newsum;
  by baseid; if a;
    totlintv = fielded;
run;

data sf.interv;
  set addnewsum;
  by baseid seqnum;
run;

PROC SORT data=sf.INTERV presorted; BY BASEID SEQNUM; RUN;

proc compare base = sf.interv_old compare = sf.interv listvar;
title "compare sas files";
run; 

data noformat;
set addnewsum;
by baseid seqnum;
  format _all_;
  format INTVDATE mmddyyn8.;
run;

PROC EXPORT DATA= noformat
     		OUTFILE= "&topdir\MCBS Survey File\2021\Admin\Data Processing\INTERV\interv.csv" 
     		DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

PROC IMPORT DATAFILE="&topdir\MCBS Survey File\2021\Admin\Data Processing\INTERV\interv.csv"
  OUT=newcsv
  DBMS=csv REPLACE;
  MISSING D N R B O;
  guessingrows = max;
run;

PROC IMPORT DATAFILE="&topdir\MCBS Survey File\2021\Admin\Data Processing\INTERV\interv_old.csv"
  OUT=oldcsv
  DBMS=csv REPLACE;
  MISSING D N R B O;
  guessingrows = max;
run;

proc compare base = oldcsv compare = newcsv listvar;
title "compare csv files";
run;

proc contents data=sf.INTERV;
run;




 
