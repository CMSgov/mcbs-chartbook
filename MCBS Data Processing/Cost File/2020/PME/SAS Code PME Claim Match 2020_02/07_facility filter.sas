*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|                                                                        |
|  PROGRAM:                                                              |
|   AUTHOR:                                                              |
|  CREATED:                                                              |
|  UPDATED:                                                              |
|                                                                        |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;
options nofmterr;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear =20;
%let LastYear =19;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";
/*New file structure for 2019*/ /*UPDATE*/
libname SF "Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Data\SAS Files";
libname CF "Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2020\Data\SAS Files";


*This is the first step in creating the RICPME and RICPMP
This program needs the RIC9 and the final imputed drug events from Chris Powers;

* First check Chris's file to see what's in it;

proc contents data=MCBSDATA.pm_events_impd_final_20&CURRYEAR VARNUM;run;

/*SUBSET COST POPULATION USING X*/

/*Data X (keep = baseid);
set CF.csevwgts;
proc sort; by baseid; 
run;*/

/*Type is no longer in RIC 9 -- found in Demo*/
/*Need to bring in and merge DEMO file prior to this step*/
Data DEMO (keep = baseid D_TYPE);
set SF.DEMO;
d_type=int_type; /*new for 2018*/
proc sort; by baseid;
run;

/*RIC 9 is now RESTMLN*/
/*D_CODE and D_BEG only go to 13 for 2020*/
data REST;
   set SF.RESTMLN;
proc sort; by baseid; 
run;

/*DATA ALL_X;
merge X (in=a) DEMO (in=b) REST (in=c);
by baseid; if a;
run;*/

data ric9 (keep=baseid d_code1 - d_code13 d_beg1 - d_beg13 setting); 
merge DEMO REST;
/*set ALL_X;*/
by baseid;

if d_type in ('F','B');

array code {13} d_code1 - d_code13;


do i = 2 to 13;
   if code{i}='S' and code{i-1} in ('C','D') then code{i}='C';
      else if code{i}='S' then code{i}='F';
end;
if d_code1='S' and d_code2 in ('C','D') then d_code1='C';
   else if d_code1='S' then d_code1='F';
do i = 1 to 13;
   if code{i}='D' then code{i}='C';
   if code{i}='G' then code{i}='F';
end;
if substr (baseid,1,1)='G' then delete;
setting=d_type;
run;
proc freq data=ric9;
   tables d_code1 d_code2 d_code3 d_code4 d_code5 d_code6
          d_code7 d_code8 d_code9 d_code10 d_code11 d_code12
		  d_code13;
run;


data MCBSDATA.pm_events_om_20&CURRYEAR 
     MCBSDATA.pm_events_impd_final_20&CURRYEAR._noome;
   set MCBSDATA.pm_events_impd_final_20&CURRYEAR;

if othermedical='Y' then output MCBSDATA.pm_events_om_20&CURRYEAR;
                    else output MCBSDATA.pm_events_impd_final_20&CURRYEAR._noome;
run;

data facdrugs (drop=y1-y11 fy1-fy11 yplus fyplus fd1-fd11 
                    QNTY DAYSUPP NDC_CD otcleg thercc amtunit
                    amtnum type tabnum FDB_GCRT_DESC FDB_str /*STRNNUM2 STRNUNI2*/ STRNNUM STRNUNIT 
                    PMFORM /*2020 PMFORMMC renamed to PMFORM based on input data*/ 
                    FDB_gnn FDB_bn y1_p y2_p y3_p y4_p y5_p y6_p y7_p y8_p y9_p
                    y10_p y11_p fy1_p fy2_p fy3_p fy4_p fy5_p fy6_p fy7_p fy8_p fy9_p fy10_p
                    fy11_p fd1_p fd2_p fd3_p fd4_p fd5_p fd6_p fd7_p fd8_p fd9_p fd10_p fd11_p
                    delta1 - delta11 x1 - x11 _AMTCARE _AMTCAID _AMTHMOP _AMTVA _AMTPRVE _AMTPRVI
                    _AMTOOP _AMTDISC _AMTOTH _AMTPD _AMTMA _TREIM
                    /*HDDM HDPHMO HDOPUB HDPRVE HDPRVI HDRX YPLUSADJ */ 
                    YPLUS_P FYplus_P NORCID WAC _IMPSTAT DAYSUPP
                    QNTY THERCC_DESC COND2 COND1 SUPPNUM pmform_desc PMEDNAME OtherMedical); 


   merge MCBSDATA.pm_events_impd_final_20&CURRYEAR._noome (in=b) 
         ric9 (in=a);
   by baseid;
   if a and b;
run;

data comflag (drop=i d_beg1-d_beg13 d_code1-d_code13 dt /*dt2*/ serv_dt pde_flag setting baseid);
   set facdrugs;
comm=0;
dt=datepart(serv_dt);

dt2=compress(put(dt,yymmdd10.),'-');

if dt2='' then comm=1;

array code {13} d_code1 - d_code13;
array beg {13} d_beg1 - d_beg13;


if setting='B' then do;
   if d_code1='C' and (dt2 < d_beg2) then comm=1;

   do i = 2 to 13;
   if code{i}='C' then do;
     if ((dt2 < beg{i+1}) or beg{i+1}=.) and (dt2 > beg{i}) then comm=1;
   end;
   end;
   if d_code13='C' and (dt2 > d_beg13) then comm=1;
end;
run;

proc contents varnum;run;

proc sort data=comflag;  by pmeid;  run;
proc freq data=comflag;
   tables comm;
run;

proc sort data=MCBSDATA.pm_events_impd_final_20&CURRYEAR; by pmeid; run;
proc sort data=MCBSDATA.pm_events_impd_final_20&CURRYEAR._noome; by pmeid; run;

data MCBSDATA.trimm&CURRYEAR._caid_comm 
     MCBSDATA.trimm&CURRYEAR._caid_fac;
   merge MCBSDATA.pm_events_impd_final_20&CURRYEAR._noome 
         comflag;
     by pmeid;
   if comm=0 then output MCBSDATA.trimm&CURRYEAR._caid_fac;
      else output MCBSDATA.trimm&CURRYEAR._caid_comm;
run;
proc freq data=comflag;
   tables comm;
run;


title "Number of survey records in final file";
proc sql; 


select count (*) as all from  MCBSDATA.pm_events_impd_final_20&CURRYEAR where EVNTNUM is not null;
select count (*) as no_ome from  MCBSDATA.pm_events_impd_final_20&CURRYEAR._noome where EVNTNUM is not null;
select count (*) as ome from  MCBSDATA.pm_events_om_20&CURRYEAR where EVNTNUM is not null;
quit;
title;
