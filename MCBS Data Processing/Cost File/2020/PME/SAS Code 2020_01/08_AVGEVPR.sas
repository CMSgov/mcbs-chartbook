*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 08_AVGEVPR                                                              |
|      UPDATED: 01/21/2011                                                              |
|  INPUT FILES: OUTCOMM_Y&CURRYEAR                                                      |
| OUTPUT FILES: AVGEVPR_&CURRYEAR                                                       |
|  DESCRIPTION: Legacy Description: "THIS CODE CREATES AN AVERAGE EVENT PRICE FILE FOR  |
|               USE IN SOB PROGRAMS."                                                   |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%LET CURRYEAR=20;
%LET LASTYEAR=19;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
libname MCBSDATA  "&location";

ods rtf bodytitle file ="&location.Output\08_AVGEVPR Output - %sysfunc(DATE(),mmddyyd10.).rtf";

DATA START;
SET MCBSDATA.OUTCOMM_Y&CURRYEAR (KEEP=BN EVPRICE);
IF EVPRICE=. THEN DELETE;
RUN;

PROC SUMMARY DATA=START SUM;
CLASS BN;
VAR EVPRICE;
OUTPUT OUT = DONE SUM=;
RUN;

DATA MCBSDATA.AVGEVPR_&CURRYEAR(DROP=EVPRICE);
SET DONE;
IF _TYPE_ NE 0;
AVGEVPR=EVPRICE/_FREQ_;
RUN;

DATA ALL;
SET DONE;
IF _TYPE_=0;
AVGEVPR=EVPRICE/_FREQ_;
RUN;



TITLE "AVERAGE EVENT PRICE FOR USE IN SOB PROGRAMS";
PROC PRINT DATA=ALL;RUN;TITLE;
ODS RTF CLOSE;
 
