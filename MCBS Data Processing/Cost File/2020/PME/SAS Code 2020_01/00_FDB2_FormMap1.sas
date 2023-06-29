*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 00_FDB2_FormMap1                                                        |
|      UPDATED: 04/09/2013                                                              |
|  INPUT FILES: Merged FirstDatabank File, current year PDE claim data NDC weights file,| 
|               prior year First DataBank to MCBS dosage form croswalk file             |
| OUTPUT FILES: [year] form crosswalk TEMP.xls (to be manually updated                  |
|  DESCRIPTION: Inputs prior year's FDB to MCBS dosage form crosswalk, merges to        |
|               current FDB route/form combinations and exports to MS Excel for         | 
|               manual crosswalk updates for new FDW route/dosage form combinations.    |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
/*PRIOR TO RUNNING NEED TO GET PDE WEIGHTS -- CCW_PDE_NDC_counts for PME.SAS*/

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear  =20;
%let LastYear  =19;
%let cut       ='01-jan-2018'd;   * This is 2 years prior to the survey year;
*%let fdbdate   =20210310;         * This is the FDB/NDDF file date;
%let fdbdate   =20210310_wac;         * This is the FDB/NDDF file date for rerun once WAC has been imputed;


%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";


***PDE weights from CCW (set ndc lengthe to 11)Use 'CCW_PDE_NDC_COUNTS for PME program' to get weights;
DATA MCBSDATA.PDE_NDC_COUNTS_&curryear; length ndc $ 11.; SET MCBSDATA.PDE_NDC_counts_&curryear; RUN;


***FDB: merge in PDE weights for each NDC;
proc sort data=MCBSDATA.FDB_&fdbdate; by NDC;run;
proc sort data=MCBSDATA.PDE_NDC_counts_&curryear; by NDC;run;

data fdb; 
merge MCBSDATA.FDB_&fdbdate (in=a)
      MCBSDATA.PDE_NDC_counts_&curryear (in=b);
by NDC;
if a;

if obsdtec=0 or obsdtec>&cut; * obsdtec=0 means the NDC is active;
if obsdtec>0 then obsolete=1;
if claims =. then claims=0; 

run;

*** Create all current Route/Form Combinations with claim weights for reference;
proc sql; 
create table route_form_&CurrYear as 
select gcrt, gcdf, gcrt_desc, gcdf_desc, sum(claims) as weight 
from fdb group by gcrt, gcdf, gcrt_desc, gcdf_desc 
order by gcrt, gcdf;
quit;


***Get Last Year's Crosswalk;
data route_form_xwalk_&LastYear; 
set MCBSLAST.route_form_xwalk_&LastYear; 
run;

***Merge Current combinations with Last Year's crosswalk;
proc sort data=route_form_&CurrYear      ; by gcrt gcdf; run;
proc sort data=route_form_xwalk_&LastYear; by gcrt gcdf; run;
data route_form_temp_&CurrYear;
merge route_form_xwalk_&LastYear (in=a)
      route_form_&CurrYear       (in=b);
by gcrt gcdf; 
if a or b;
run;
PROC SQL;
CREATE TABLE FORM_LOOKUP AS 
SELECT DISTINCT MCBS_FORM_CODE, MCBS_FORM
FROM route_form_temp_&CurrYear
ORDER BY MCBS_FORM_CODE;
QUIT;


***Need to manually map FDB route/form into PME basic format!  Then Re-save removing TEMP from the table name ;
PROC EXPORT DATA= route_form_temp_&CurrYear
            OUTTABLE= "FORM_temp" 
            DBMS=ACCESSCS REPLACE;
      DATABASE="&location.\EDIT\20&CurrYear Form Crosswalk.MDB"; 
RUN;

PROC EXPORT DATA= FORM_LOOKUP
            OUTTABLE= "FORM_LOOKUP" 
            DBMS=ACCESSCS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear Form Crosswalk.MDB"; 
RUN;



**** MCBS Forms:
1	='Pill'
2	='Liquid'
3	='Drops'
4	='Topical ointment'
5	='Suppository'
6	='Inhalant/aerosol spray'
7	='Shampoo, soap'
8	='Injection'
9	='I.V.'
10	='Patch/pad'
11	='Topical gel/jelly'
12	='Powder'
91	='Other'
-1  ='Unknown'
;
