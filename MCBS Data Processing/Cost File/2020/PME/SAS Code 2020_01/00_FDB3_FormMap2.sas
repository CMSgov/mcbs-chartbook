*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 00_FDB3_FormMap2                                                        |
|      UPDATED: 01/0520109                                                              |
|  INPUT FILES: Merged FirstDatabank File, current year PDE claim data NDC weights file,| 
|               updated "[year] form crosswalk.xls" FDB to MCBS form croswalk file      |
| OUTPUT FILES: FGB_GSN_[FDBdate].sas7bdat                                              |
|  DESCRIPTION: Creates FDB file with PDE claim weights at the brand                    |
|               name, generic name, strength (1&2), DOSAGE form and route level. Inputs |
|               updated FDB to MCBS dosage form crosswalk and merges to FDB data        |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear  =20;
%let LastYear  =19;
%let cut       =20180101;   * This is 2 years prior to the survey year;
*%let fdbdate   =20210310;     * This is the FDB/NDDF file date;
%let fdbdate   =20210310_wac;  * This is the FDB/NDDF file date for rerun once WAC has been imputed;


%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";


*Note!!!: Import after manual updates are made to crosswalk and Access table is renamed to "FORM" ;

PROC IMPORT OUT= WORK.route_form_xwalk_&CurrYear 
            DATATABLE= "FORM" 
            DBMS=ACCESSCS REPLACE;
     DATABASE="&location.\EDIT\20&CurrYear Form Crosswalk.MDB"; 
     SCANMEMO=YES;
     USEDATE=NO;
     SCANTIME=YES;
RUN;


***Add MCBS Form code for new FDB route/form cobmos;
data route_form_xwalk_&CurrYear; 
set route_form_xwalk_&CurrYear;

if mcbs_form_code =. then do;
 if      mcbs_form ='Pill'                   then mcbs_form_code=1;
 else if mcbs_form ='Liquid'                 then mcbs_form_code=2;
 else if mcbs_form ='Drops'                  then mcbs_form_code=3;
 else if mcbs_form ='Topical ointment'       then mcbs_form_code=4;
 else if mcbs_form ='Suppository'            then mcbs_form_code=5;
 else if mcbs_form ='Inhalant/aerosol spray' then mcbs_form_code=6;
 else if mcbs_form ='Shampoo, soap'          then mcbs_form_code=7;
 else if mcbs_form ='Injection'              then mcbs_form_code=8;
 else if mcbs_form ='I.V.'                   then mcbs_form_code=9;
 else if mcbs_form ='Patch/pad'              then mcbs_form_code=10;
 else if mcbs_form ='Topical gel/jelly'      then mcbs_form_code=11;
 else if mcbs_form ='Powder'                 then mcbs_form_code=12;
 else if mcbs_form ='Other'                  then mcbs_form_code=91;
 else if mcbs_form ='Unknown'                then mcbs_form_code=-1;
end;
run;

***Print out any that did not match to a code (should be no output...);
proc print data=route_form_xwalk_&CurrYear;
where mcbs_form_code=.;
run;

***Make permanent SAS dataset (for next year);
data MCBSDATA.route_form_xwalk_&CurrYear; set route_form_xwalk_&CurrYear; run;



***FDB: merge in PDE weights for each NDC;
proc sort data=MCBSDATA.FDB_&fdbdate;      by NDC;run;
proc sort data=MCBSDATA.PDE_NDC_COUNTS_&CURRYEAR; by NDC;run;

data fdb; 
merge MCBSDATA.FDB_&fdbdate      (in=a)
      MCBSDATA.PDE_NDC_COUNTS_&CURRYEAR (in=b);
by NDC;
if a;

if obsdtec=0 or obsdtec>&cut; * obsdtec=0 means the NDC is active;
if obsdtec>0 then obsolete=1;
if claims =. then claims=0; 

run;


***Summarize FDB to GSN and Brand Name level and add MCBS forms;
proc sql;
create table fdb_gsn as 
select 
 f.gcn_seqno as GSN,
 f.BN,
 f.STR,
 f.str1,
 f.str2,
 f.GNN,
 f.GCDF_DESC as form,
 f.GCrt_DESC as route,
 f.gcdf,
 f.gcrt,
 f.gtc,
 f.gtc_desc,
 f.etc_name,
 sum(f.claims)    as weight,
 x.mcbs_form_code as pmform_fdb,
 x.mcbs_form      as pmform_fdb_desc

from fdb f 
 left join route_form_xwalk_&CurrYear x on f.gcdf=x.gcdf and f.gcrt=x.gcrt

group by  
 f.gcn_seqno ,
 f.BN,
 f.STR,
 f.str1,
 f.str2,
 f.GNN,
 f.GCDF_DESC ,
 f.GCRT_DESC ,
 f.gcdf,
 f.gcrt,
 f.gtc,
 f.gtc_desc,
 f.etc_name,
 x.mcbs_form_code,
 x.mcbs_form
order by f.bn, f.gnn, f.str;
quit;



*Set missing weights to zero and recode missing strengths to -1 to compare to MCBS
 and make permanent SAS dataset;
data MCBSDATA.fdb_gsn_&FDBdate; 
set fdb_gsn; 
if weight=. then weight=0; 
if str1=. or str1=0 then str1=-1;
if str2=. or str2=0 then str2=-1;

run;
