/*Program to pull survey only events off of match file*/ 
/*When NORC sent back the imputed file they only included survey events*/

options nofmterr;

libname PME 'C:\Users\S1C3\RIC PME\MCBS\2020\PME\Data';
run;

/*The private HMO var is spelled differently in each file -- pre-imputed and imputed*/
/*Pre-imputed Match file with rename*/
DATA PME.PM_PREIMPD2 (rename=(_AMTPHMO=_AMTHMOP _SOPPHMO=_SOPHMOP));     
SET PME.pm_events_pre_impd_2020;/*File sent to NORC for imputation -- contains PDE data and survey only events*/
PROC SORT;                         
BY baseid;
run;

/*Create survey only and Pmed/survey only files based off the Pre-Imputed file*/
data PME.survey_only PME.pmed_survey_match;
set PME.pm_preimpd2;
if PDE_FLAG='Survey Only' then output PME.survey_only;
else output PME.pmed_survey_match;/*This will be a final dataset used in the next program*/
  proc sort;
  by baseid; 
  run;

  
/*Delete duplicate variables from survey only file 
  prior to merge with survey only imputed file from NORC*/
data PME.survey_only_final(drop=BN FDB_STR OTCLEG COSTNUM EVNTNUM PDE_FLAG
     ROUND UTILNUM WAC _AMTCARE _AMTCAID _AMTDISC _AMTMA _AMTOOP _AMTOTH
	 _AMTPD _AMTHMOP _AMTPRVE _AMTPRVI _AMTVA _IMPSTAT _SOPCAID _SOPCARE
     _SOPDISC _SOPMA _SOPOOP _SOPOTH _SOPPD _SOPHMOP _SOPPRVE _SOPPRVI
     _SOPVA _TREIM);
set PME.survey_only;
  proc sort;
  by pmedid; 
  run;
  
  /*Merge the survey only pre-imputed data with the survey only imputed data*/

  /*Need to change numeric to character or trim will not work*/

****For 2017 need to change evntnum, round, and utilnum to 
  character so trim used to create PMEDID works. 
  Create new character variables -- evntnum_c and so forth so we don't alter the
  numeric vars****;
  
  data PME.pmimpd20_1; 
  set PME.pm20imp;
evntnum_c = put(evntnum,z3.);
round_c = put(round,2.);
utilnum_c = put(utilnum,z4.);
RUN;


  /*Imputed file from NORC -- contains ONLY survey only events that needed imputation*/
data PME.pmimpd20;
set PME.pmimpd20_1;
/*need to create PMEDID so that the 2 files can be linked by a common variable*/
length pmedid $17;

**2017 updated var names here to include _c after numeric was converted to char***;

pmedid=trim(baseid)||trim(evntnum_c)||trim(round_c)||trim(utilnum_c);
run;
 
proc sort;
by pmedid;
run;

 /*This will be a final dataset used in the next program*/
data PME.pmimpd20_survey;
merge pme.pmimpd20(in=a) PME.survey_only_final (in=b);
by pmedid; if a;
run;






