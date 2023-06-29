*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 00_XWALK                                                                     |
|      UPDATED: 02/08/2011                                                                   |
|  INPUT FILES: current "people" file, Full MCBS-to-HIC xwalk, CBSHICs                       |
| OUTPUT FILES: mcbsdata.MCBS_CCW_XWALK_&curryear                                            |
|  DESCRIPTION: Creates MCBS BASEID to CCW BENE_ID crosswalk for current year                |
|                                                                                            |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;

/*NOTE FOR 2019 and future years in the past Maggie got raw file and then this program would cut down the POP.
Cheri preformed this step for 2018 so this program does not need to be run.
Can move on to the next program 01_PREPARE after copying data set from here
Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2020\Admin\annu20_f_xwalk_bb 
and renaming file to 'mcbs_ccw_xwalk_xx'*/ /*DID NOT RUN FOR 2019 SINCE ALREADY HAD XWALK 
CREATED BY CHERI*/

ods html close;
ods html;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let idstart   =01747145 ; /*Y:\Share\SMAG\MCBS\FILENOTE*/
%let idend     =02252140; 
%let CurrYear  =19;
%let LastYear  =18;
*%let xwalk     = MM14_17; *MCBS CROSSWALK FILE -- Maggie pulled down for 2017
                Y:\Share\IPG\DSMA\MCBS\MCBS Cost Supplement File\2017\Admin\annu17_f_xwalk_bb.sas7bdat
				was created by Cheri after I ran this program. Both files were exact.
				In the future this program probably doesn't need to be run -- just copy and rename 
				Cheri's file to 'mcbs_ccw_xwalk_xx';

  

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;

libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";

*filename PEOPLE   "&location.COST&CURRYEAR._PEOPLE1.txt";
*filename CBSHIC   "&location.CCWMCBS_1541011.txt";


*******************************************************************************************;
* STEP 1: CROSSWALK CCW IDS TO MCBS IDS IN PDE DATA                                       *;
*******************************************************************************************;
libname POP 'Y:\Share\IPG\DSMA\MCBS\MCBS Cost Supplement File\2018\Admin\Weights\Data Files';  /*NEW X for POP*/ 

/*New X file for POP*/
DATA MCBSDATA.PEOPLE_&CURRYEAR(KEEP=BASEID);                                              
 SET POP.annu18_f; /*UPDATE*/
run;


PROC SORT DATA=MCBSDATA.PEOPLE_&CURRYEAR NODUPKEY; BY BASEID;RUN;
PROC SORT DATA=MCBSDATA.&XWALK;                    BY BASEID;RUN;

*CREATE CCW TO MCBS CROSSWALK;
PROC SQL;
CREATE TABLE MCBS_CCW_XWALK AS 
 SELECT DISTINCT 
   A.BASEID,
   B.BENE_ID
 FROM       MCBSDATA.PEOPLE_&CURRYEAR        A
 LEFT JOIN MCBSDATA.&XWALK   B 
 ON A.BASEID=B.BASEID
 /*where flag= "Y"*/  
;
quit;

*dup check;
proc sql;
 title "Duplicate BASEIDs";
 select baseid,  count(baseid)  as count from MCBS_CCW_XWALK group by baseid  having count(baseid) >1;
 title "Duplicate BENE_IDs";
 select bene_id, count(bene_id) as count from MCBS_CCW_XWALK group by bene_id having count(bene_id)>1;
 title "Missing BENE_IDs";
 select * from MCBS_CCW_XWALK where bene_id is null;
 title;
QUIT;

data mcbsdata.MCBS_CCW_XWALK_&curryear; set MCBS_CCW_XWALK;run;
