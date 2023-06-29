*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|                                                                        |
|  PROGRAM: 08_Put OTC in MPE                                            |
|   AUTHOR: Maggie Murgolo                                               |
|  CREATED:                                                              |
|  UPDATED: 10/30/2018                                                   |
|  NOTES: Prior to running this program need to create prel_mpe_xtra	 |
|  in the current data year Cost MPE data processing folder              |
|  mpe1_run_first_output_to_pme_2020.sas                                 |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear =20;
%let LastYear =19;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";
libname CF "Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2020\Data\SAS Files";
libname SF "Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Data\SAS Files";
libname MPE "Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2020\Admin\Data Processing\MPE\PREL_MPE\Create xtra";
*libname MPE "Y:\Share\IPG\DSMA\MCBS\MCBS Cost Supplement File\2018\Admin\Data Processing\MPE\new process";

LIBNAME fmts 'Y:\Share\SMAG\MCBS\MCBS Codebook Production\Formats\2020 Formats';
options fmtsearch=(fmts);

options nofmterr;

data demo;
set SF.demo;
d_type=int_type;
proc sort; by baseid; 
run;

data restmln;
set SF.restmln;
proc sort; by baseid;
run;

data X (keep=baseid);
set CF.csevwgts;
proc sort; by baseid; 
run;

DATA mcbsdata.RIC9 (keep=baseid d_code1 - d_code9 d_beg1 - d_beg9 setting) ;
MERGE X (in=a) restmln demo; by baseid;
if a;

if d_TYPE in ('F','B');

array code {9} d_code1 - d_code9;

do i = 2 to 9;
   if code{i}='S' and code{i-1} in ('C','D') then code{i}='C';
      else if code{i}='S' then code{i}='F';
end;
if d_code1='S' and d_code2 in ('C','D') then d_code1='C';
   else if d_code1='S' then d_code1='F';
do i = 1 to 9;
   if code{i}='D' then code{i}='C';
   if code{i}='G' then code{i}='F';
end;
if substr (baseid,1,1)='G' then delete;
setting=d_TYPE;

run;


data mcbsdata.om_from_pme 
   (keep=baseid ric version evnttype claimtyp evbegyy evbegmm evbegdd source amtcare amtncov amtcov amtcare
   impacare impscare amtcaid impscaid impacaid amtmadv impsmadv impamadv amthmop impshmop impahmop amtva
   impsva impava amtprve impsprve impaprve amtprvi impaprvi impsprvi amtprvu impsprvu impaprvu amtoop 
   impsoop impaoop amtdisc impsdisc impadisc amtoth impsoth impaoth pamtmed pamtsurg pamtlabx pamtom 
   pamtpm ometype sitcode amttot impatot evntnum_c MCOHMO);

   merge mcbsdata.pm_events_om_20&curryear (in=a) 
         mcbsdata.ric9 (in=b);
		 by baseid;
      if a;
   comm=0;
   if a and not b then comm=1;
pde08=compress(put(datepart(serv_dt),yymmdd10.),'-');

if pde08=. then comm=1;
array code {9} d_code1 - d_code9;
array beg {9} d_beg1 - d_beg9;

if setting='B' then do;
   if d_code1='C' and (pde08 < d_beg2) then comm=1;

   do i = 2 to 8;
   if code{i}='C' then do;
     if ((pde08 < beg{i+1}) or beg{i+1}=.) and (pde08 > beg{i}) then comm=1;
   end;
   end;
   if d_code9='C' and (pde08 > d_beg9) then comm=1;
end;
   ric='MP';
   version=1;
   evnttype='OM';
   Claimtyp='R';
   Evntnum_c='    ';
   MCOHMO=3;
   EVBEGYY=substr(pde08,3,2);
   evbegmm=substr(pde08,5,2);
   evbegdd=substr(pde08,7,2);
   if evntnum_c=. then source='2';
      else source='3';

   amtcov=sum(y9_p,y10_p,y11_p);	/*updated for 2012*/
   amtncov=yplus_p-y9_p-y10_p-y11_p;/*updated for 2012*/
   amtcare=sum(y9_p,y10_p,y11_p);/*updated for 2012*/
   impacare=0;
   impscare=0;
   amtcaid=y1_p;
   impscaid=0;
   impacaid=0;
   amtmadv=0;
   impsmadv=0;
   impamadv=0;
   amthmop=y5_p;
   impshmop=0;
   impahmop=0;
   amtva=y7_p;
   impsva=0;
   impava=0;
   amtprve=y2_p;
   impsprve=0;
   impaprve=0;
   amtprvi=y6_p;
   impaprvi=0;
   impsprvi=0;
   amtprvu=0;
   impsprvu=0;
   impaprvu=0;
   amtoop=y3_p;
   impsoop=0;
   impaoop=0;
   amtdisc=y8_p;
   impsdisc=0;
   impadisc=0;
   amtoth=y4_p;
   impsoth=0;
   impaoth=0;
   pamtmed=0;
   pamtsurg=0;
   pamtlabx=0;
   pamtom=0;
   pamtpm=yplus_p;
   ometype=4;
   amtncov=round(amtncov,.01);
   amtcov=round(amtcov,.01);/*updated for 2012*/
   amttot=yplus_p;
   impatot=0;
   if comm=1 then sitcode='C';
      else sitcode='F';

   run;

    ***In mcbsdata.om_from_pme need to change dates from character to numeric to match the mpe_prepme file
   and we kept evntnum_c bc we needed character and renamed to evntnum;
data mcbsdata.om_from_pme_2;
  set mcbsdata.om_from_pme(rename=(EVBEGYY=EVBEGYY_old EVBEGMM=EVBEGMM_old EVBEGDD=EVBEGDD_old EVNTNUM_C=EVNTNUM
	SOURCE=SOURCE_old));
  D_BEGYY=input(EVBEGYY_old,best12.);
  D_BEGMM=input(EVBEGMM_old,best12.);
  D_BEGDD=input(EVBEGDD_old,best12.);
  *evntnum = put(evntnum_old,z4.);
  source = input(source_old,best8.);*whatever is appropriate informat for your variable;
  proc sort; by baseid;
run;

/*Merge OM from PME with prelim MPE file*/ 
data mcbsdata.mpe_new;
   set MPE.prel_mpe_xtra 
       mcbsdata.om_from_pme_2;
   by baseid; run; 
   proc sort data=mcbsdata.mpe_new /*ebcdic*/;  by baseid; run;

 /*Make sure final data file only contains benes. in Cost*/
Data FINAL1;
merge mcbsdata.mpe_new (in=a) X (in=b);
by baseid; if a and b;
run;



/*CREATE SAS AND CSV FILES*/

DATA FINALDATA (keep = SURVEYYR VERSION BASEID EVNTNUM EVNTTYPE 
  OREVTYPE CLAIMID CLAIMTYP D_BEGYY D_BEGMM D_BEGDD SOURCE SITCODE  
  AMTTOT IMPATOT AMTCOV AMTNCOV AMTCARE IMPSCARE IMPACARE AMTCAID  
  IMPSCAID IMPACAID AMTMADV IMPSMADV IMPAMADV AMTHMOP IMPSHMOP 
  IMPAHMOP /*AMTVA IMPSVA IMPAVA*/ AMTPRVE IMPSPRVE IMPAPRVE AMTPRVI  
  IMPSPRVI IMPAPRVI AMTPRVU IMPSPRVU IMPAPRVU AMTOOP IMPSOOP IMPAOOP 
  AMTDISC IMPSDISC IMPADISC AMTOTH IMPSOTH IMPAOTH PAMTMED PAMTSURG 
  PAMTLABX PAMTOM PAMTPM PROVSPEC OMETYPE ORTHTYPE ALTRTYPE OTHRTYPE
  VUTYPLEN VUTYPFRA VUTYPCON VUTYPREP 
  CANALLFT CANALRGT INEARLFT INEARRGT BHEARLFT BHEARRGT    /*NEW VISION AND HEARING 2019*/
  MCOHMO SOWMP TELEHLTH /*NEW FOR 2020*/);
set /*mcbsdata.mpe_new*/FINAL1; 
Version=1;
SURVEYYR=2020;
format baseid $8.;

proc sort; by baseid;
run; 

Data Recodes; 
set finaldata;

if SURVEYYR = . then SURVEYYR = 2020; 
/*if EVBEGYY = -9 then EVBEGYY = .N;
if EVBEGYY = -8 then EVBEGYY = .D;
if EVBEGYY = -7 then EVBEGYY = .R;
if EVBEGYY = -1 then EVBEGYY = .;
if EVBEGMM = -9 then EVBEGMM = .N;
if EVBEGMM = -8 then EVBEGMM = .D;
if EVBEGMM = -7 then EVBEGMM = .R;
if EVBEGMM = -1 then EVBEGMM = .;
if EVBEGDD = -9 then EVBEGDD = .N;
if EVBEGDD = -8 then EVBEGDD = .D;
if EVBEGDD = -7 then EVBEGDD = .R;
if EVBEGDD = -1 then EVBEGDD = .;*/
if PROVSPEC = -9 then PROVSPEC = .N;
if PROVSPEC = -8 then PROVSPEC = .D;
if PROVSPEC = -7 then PROVSPEC = .R;
if PROVSPEC = -1 then PROVSPEC = .;
if ORTHTYPE = -9 then ORTHTYPE = .N;
if ORTHTYPE = -8 then ORTHTYPE = .D;
if ORTHTYPE = -7 then ORTHTYPE = .R;
if ORTHTYPE = -1 then ORTHTYPE = .;
if ALTRTYPE = -9 then ALTRTYPE = .N;
if ALTRTYPE = -8 then ALTRTYPE = .D;
if ALTRTYPE = -7 then ALTRTYPE = .R;
if ALTRTYPE = -1 then ALTRTYPE = .;
if OTHRTYPE = -9 then OTHRTYPE = .N;
if OTHRTYPE = -8 then OTHRTYPE = .D;
if OTHRTYPE = -7 then OTHRTYPE = .R;
if OTHRTYPE = -1 then OTHRTYPE = .;
if EVNTNUM = '.' then EVNTNUM = '    ';

proc sort; by baseid; run;

 /*Output to SAS file and use Retain statement so variables are in proper order*/
 
DATA MCBSDATA.PREmpe1;
RETAIN 
  BASEID SURVEYYR VERSION EVNTNUM EVNTTYPE 
  OREVTYPE CLAIMID CLAIMTYP D_BEGYY D_BEGMM D_BEGDD SOURCE SITCODE 
  TELEHLTH /*NEW FOR 2020*/ 
  AMTTOT IMPATOT AMTCOV AMTNCOV AMTCARE IMPSCARE IMPACARE AMTCAID  
  IMPSCAID IMPACAID AMTMADV IMPSMADV IMPAMADV AMTHMOP IMPSHMOP 
  IMPAHMOP /*AMTVA IMPSVA IMPAVA*/ AMTPRVE IMPSPRVE IMPAPRVE AMTPRVI  
  IMPSPRVI IMPAPRVI AMTPRVU IMPSPRVU IMPAPRVU AMTOOP IMPSOOP IMPAOOP 
  AMTDISC IMPSDISC IMPADISC AMTOTH IMPSOTH IMPAOTH PAMTMED PAMTSURG 
  PAMTLABX PAMTOM PAMTPM PROVSPEC OMETYPE ORTHTYPE ALTRTYPE OTHRTYPE
  VUTYPLEN VUTYPFRA VUTYPCON VUTYPREP 
  CANALLFT CANALRGT INEARLFT INEARRGT BHEARLFT BHEARRGT    /*NEW VISION AND HEARING 2019*/
  MCOHMO SOWMP;

	SET RECODES;

  KEEP    
  BASEID SURVEYYR VERSION EVNTNUM EVNTTYPE 
  OREVTYPE CLAIMID CLAIMTYP D_BEGYY D_BEGMM D_BEGDD SOURCE SITCODE 
  TELEHLTH /*NEW FOR 2020*/ 
  AMTTOT IMPATOT AMTCOV AMTNCOV AMTCARE IMPSCARE IMPACARE AMTCAID  
  IMPSCAID IMPACAID AMTMADV IMPSMADV IMPAMADV AMTHMOP IMPSHMOP 
  IMPAHMOP /*AMTVA IMPSVA IMPAVA*/ AMTPRVE IMPSPRVE IMPAPRVE AMTPRVI  
  IMPSPRVI IMPAPRVI AMTPRVU IMPSPRVU IMPAPRVU AMTOOP IMPSOOP IMPAOOP 
  AMTDISC IMPSDISC IMPADISC AMTOTH IMPSOTH IMPAOTH PAMTMED PAMTSURG 
  PAMTLABX PAMTOM PAMTPM PROVSPEC OMETYPE ORTHTYPE ALTRTYPE OTHRTYPE
  VUTYPLEN VUTYPFRA VUTYPCON VUTYPREP 
  CANALLFT CANALRGT INEARLFT INEARRGT BHEARLFT BHEARRGT    /*NEW VISION AND HEARING 2019*/
  MCOHMO SOWMP;

  FORMAT    
  BASEID SURVEYYR VERSION EVNTNUM EVNTTYPE 
  OREVTYPE CLAIMID CLAIMTYP D_BEGYY D_BEGMM D_BEGDD SOURCE SITCODE 
  TELEHLTH /*NEW FOR 2020*/ 
  AMTTOT IMPATOT AMTCOV AMTNCOV AMTCARE IMPSCARE IMPACARE AMTCAID  
  IMPSCAID IMPACAID AMTMADV IMPSMADV IMPAMADV AMTHMOP IMPSHMOP 
  IMPAHMOP /*AMTVA IMPSVA IMPAVA*/ AMTPRVE IMPSPRVE IMPAPRVE AMTPRVI  
  IMPSPRVI IMPAPRVI AMTPRVU IMPSPRVU IMPAPRVU AMTOOP IMPSOOP IMPAOOP 
  AMTDISC IMPSDISC IMPADISC AMTOTH IMPSOTH IMPAOTH PAMTMED PAMTSURG 
  PAMTLABX PAMTOM PAMTPM PROVSPEC OMETYPE ORTHTYPE ALTRTYPE OTHRTYPE
  VUTYPLEN VUTYPFRA VUTYPCON VUTYPREP 
  CANALLFT CANALRGT INEARLFT INEARRGT BHEARLFT BHEARRGT    /*NEW VISION AND HEARING 2019*/
  MCOHMO SOWMP;

   RUN;


Data mcbsdata.PREMPE2;
set mcbsdata.PREMPE1;
	/*Apply formats*/

FORMAT
     BASEID   $BSIDFMT.
	 SURVEYYR SVYRFMT.
     VERSION VERSFMT.
	 EVNTTYPE OREVTYPE $EVNTTYP. 
	 SOURCE SRCE.
	 MCOHMO HMO. 
     SITCODE $CODEFMT.
 	 IMPATOT IMPACARE IMPACAID IMPAMADV IMPAHMOP /*IMPAVA*/ IMPAPRVE IMPAPRVI
 	 IMPAPRVU IMPAOOP IMPADISC IMPAOTH IMPFLAG.
  	 IMPSCARE IMPSCAID IMPSMADV IMPSHMOP /*IMPSVA*/ IMPSPRVE IMPSPRVI
 	 IMPSPRVU IMPSOOP IMPSDISC IMPSOTH IMPFLAG.
	 AMTTOT AMTCARE AMTCAID AMTMADV AMTHMOP /*AMTVA*/ AMTPRVE AMTPRVI AMTPRVU 
     AMTOOP AMTDISC AMTOTH PAMTMED PAMTSURG PAMTLABX PAMTOM PAMTPM 
     AMTCOV AMTNCOV MONYFMT.
 	 D_BEGMM EVMM. D_BEGDD EVDD. D_BEGYY EVYY.
  	 OMETYPE OMETYPE. 
	 ORTHTYPE ORTHTYPE. 
	 ALTRTYPE ALTRTYPE. 
	 OTHRTYPE OTHRTYPE. 
	 PROVSPEC PROVSPEC.
 	 EVNTNUM $EVNTNUM. 
	 CLAIMTYP $CLAIMTP.
	 CLAIMID  CLAIMID.
	 /*NEW VISION AND HEARING 2019*/
	 VUTYPLEN VUTYPFRA VUTYPCON VUTYPREP CANALLFT CANALRGT 
     INEARLFT INEARRGT BHEARLFT BHEARRGT  IND1FMT.  
	 SOWMP SOWMP.
	 /*NEW FOR 2020*/
	 TELEHLTH YES1FMT.;


  /*variable labels here*/

  LABEL
BASEID   = "Unique SP Identification Number"
VERSION  = "Version Number"
SURVEYYR = "Survey Year"
EVNTNUM  = 'Unique event identifier'
EVNTTYPE = 'Event type'
OREVTYPE = 'Original reported event type'
CLAIMID  = 'Claim this survey event matched to'
CLAIMTYP = 'Claim type that event matched to'
D_BEGYY  = 'Event begin year' 
D_BEGMM  = 'Event begin month' 
D_BEGDD  = 'Event begin day' 
SOURCE   = 'Source of event: survey, claim, or both'
SITCODE  = 'Community or facility setting'
AMTTOT   = 'Total payment'
IMPATOT  = 'Imputation flag:  total payment' 
AMTCOV   = 'Portion of total pay cov by Medicare'
AMTNCOV  = 'Portion of total pay not cov by Medicare'
AMTCARE  = 'Amount paid by Medicare FFS'
IMPSCARE = 'Imputation flag: SOP Medicare FFS' 
IMPACARE = 'Imputation flag: amt Medicare FFS' 
AMTCAID  = 'Amount paid by Medicaid'
IMPSCAID = 'Imputation flag: SOP Medicaid' 
IMPACAID = 'Imputation flag: amt Medicaid' 
AMTMADV  = 'Amount paid by Medicare MCO/HMO'
IMPSMADV = 'Imputation flag: SOP Medicare MCO/HMO' 
IMPAMADV = 'Imputation flag: amt Medicare MCO/HMO' 
AMTHMOP  = 'Amount paid by Private MCO/HMO'
IMPSHMOP = 'Imputation flag: SOP Private MCO/HMO' 
IMPAHMOP = 'Imputation flag: amt Private MCO/HMO' 
/*AMTVA    = 'Amount paid by Veterans Admin.'
IMPSVA   = 'Imputation flag: SOP Veterans Admin.' 
IMPAVA   = 'Imputation flag: amt Veterans Admin.'*/ 
AMTPRVE  = 'Amount paid by Priv ins (Employer Spon)'
IMPSPRVE = 'Imputation flag: SOP Priv ins-Employer' 
IMPAPRVE = 'Imputation flag: amt Priv ins-Employer' 
AMTPRVI  = 'Amount paid by Priv ins (Indiv Purch)'
IMPSPRVI = 'Imputation flag: SOP Priv ins-Indiv Pur' 
IMPAPRVI = 'Imputation flag: amt Priv ins-Indiv Pur' 
AMTPRVU  = 'Amount paid by Priv ins (Unknown Purch)'
IMPSPRVU = 'Imputation flag: SOP Priv ins-Unknown' 
IMPAPRVU = 'Imputation flag: amt Priv ins-Unknown' 
AMTOOP   = 'Amount paid by person/family'
IMPSOOP  = 'Imputation flag: SOP paid by person' 
IMPAOOP  = 'Imputation flag: amt paid by person' 
AMTDISC  = 'Amount of uncollected liabilities'
IMPSDISC = 'Imputation flag: SOP of uncoll liab' 
IMPADISC = 'Imputation flag: amt of uncoll liab' 
AMTOTH   = 'Amt paid by other sources (includes VA)'
IMPSOTH  = 'Imputation flag: SOP other sources' 
IMPAOTH  = 'Imputation flag: amt other sources' 
PAMTMED  = 'Total amount paid for medical services'
PAMTSURG = 'Total amount paid for surgical services'
PAMTLABX = 'Total amount paid for lab/x-ray'
PAMTOM   = 'Total amount paid for oth med services'
PAMTPM   = 'Total amount paid for pres. medicines'
ALTRTYPE = 'Type of alteration'
OMETYPE  = 'Type of OM event'
ORTHTYPE = 'Type of orthopedic item'
OTHRTYPE = 'Type of other OME'
PROVSPEC = 'Medical provider speciality'
VUTYPLEN ='Purchased glass lenses'   /*these are released in OM, not VUE */
VUTYPFRA ='Purchased glass frames'   /*these are released in OM, not VUE */
VUTYPCON ='Purchased contact lenses' /*these are released in OM, not VUE */
VUTYPREP ='Repaired glasses'         /*these are released in OM, not VUE */
CANALLFT = 'In the ear hearing aid, left ear'      /*these are released in OM, not HUE */
CANALRGT = 'In the ear hearing aid, right ear'     /*these are released in OM, not HUE */
INEARLFT = 'In the canal hearing aid, left ear'    /*these are released in OM, not HUE */
INEARRGT = 'In the canal hearing aid, right ear'   /*these are released in OM, not HUE */
BHEARLFT = 'Behind the ear hearing aid, left ear'  /*these are released in OM, not HUE */
BHEARRGT = 'Behind the ear hearing aid, right ear' /*these are released in OM, not HUE */
MCOHMO   = 'Event provided by MCO/HMO'
SOWMP    = 'Survey Only with Medicare Not MA Payment Flag'
TELEHLTH = 'Was this a Telehealth Visit?';
  run;
	
Proc contents data=mcbsdata.PREMPE2;
   run;

   proc freq data=mcbsdata.PREMPE2;
tables SURVEYYR VERSION EVNTNUM EVNTTYPE 
  OREVTYPE CLAIMID CLAIMTYP  D_BEGYY D_BEGMM D_BEGDD SOURCE SITCODE
  TELEHLTH /*NEW FOR 2020*/ 
  AMTTOT IMPATOT AMTCOV AMTNCOV AMTCARE IMPSCARE IMPACARE AMTCAID  
  IMPSCAID IMPACAID AMTMADV IMPSMADV IMPAMADV AMTHMOP IMPSHMOP 
  IMPAHMOP /*AMTVA IMPSVA IMPAVA*/ AMTPRVE IMPSPRVE IMPAPRVE AMTPRVI  
  IMPSPRVI IMPAPRVI AMTPRVU IMPSPRVU IMPAPRVU AMTOOP IMPSOOP IMPAOOP 
  AMTDISC IMPSDISC IMPADISC AMTOTH IMPSOTH IMPAOTH PAMTMED PAMTSURG 
  PAMTLABX PAMTOM PAMTPM PROVSPEC OMETYPE ORTHTYPE ALTRTYPE OTHRTYPE 
  VUTYPLEN VUTYPFRA VUTYPCON VUTYPREP 
  CANALLFT CANALRGT INEARLFT INEARRGT BHEARLFT BHEARRGT    /*NEW VISION AND HEARING 2019*/
  MCOHMO SOWMP /missing;
	   title 'PREMPE ';

  
   run;

   data mcbsdata.MPE;
   set mcbsdata.PREMPE2;
   run;
   proc sort data = mcbsdata.MPE presorted;
by baseid;
run;

DATA mpecsv;
set mcbsdata.MPE;
by baseid;
format _all_;
run;

/*Create CSV file*/

PROC EXPORT DATA= mpecsv
     		OUTFILE= "C:\Users\S1C3\RIC PME\MCBS\2020\PME\Data\mpe.csv" 
     		DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

proc contents data=mcbsdata.MPE;
run;


/*
   data mcbsdata.MPE_unfmt;
   set mcbsdata.PREMPE1;
	format _all_;
run;

 
   ********************Remove variable labels******************;
proc datasets library=mcbsdata nolist;
  modify MPE_unfmt;
  attrib _all_ label='';
quit;


   /*Create CSV file*/
/*
PROC EXPORT DATA= MCBSDATA.MPE_unfmt
     		OUTFILE= "C:\Users\S1C3\RIC PME\MCBS\2018\PME\Data\mpe.csv" 
     		DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


/*

PROC FORMAT;
VALUE $EVNTTYP '-1' = 'INAPPLICABLE'
               '-9' = 'NOT ASCERTAINED'
               'DU' = 'DENTAL'
               'IP' = 'INPATIENT'
               'IU' = 'INSTITUTIONAL UTILIZATION'
               'MP' = 'MEDICAL PROVIDER'
               'OM' = 'OTHER MEDICAL EXPENSE'
               'OP' = 'OUTPATIENT'
               'PM' = 'PRESCRIBED MEDICINE'
               'SD' = 'SEP BILLING DOCTOR'
               'SL' = 'SEP BILLING LAB'
               '  ' = ' ';

VALUE SRCE      1 = 'SURVEY ONLY'
                2 = 'CLAIMS ONLY'
                3 = 'BOTH SURVEY & CLAIMS';

VALUE $HMO      '0' = 'EVENT NOT PROV BY HMO'
                '1' = 'EVENT PROVIDED BY HMO';

VALUE $CODEFMT   ' ' = 'Missing'
                 'C' = 'Community'
                 'D' = 'Deemed Community'
                 'F' = 'Facility'
                 'G' = 'Deemed facility'
		         'H' = 'Hospice'
 		         'I' = 'Inpatient'
		        'IH' = 'Inpatient Hospice'
                 'S' = 'SNF' ;

VALUE IMPFLAG    0  = 'NOT IMPUTED'
                 1  = 'IMPUTED';

VALUE EVDD       .  = '  '
                -1  = 'INAPPLICABLE'
                -5  = 'MULTIPLE VISITS THIS MONTH'
                -7  = 'REFUSED'
                -8  = 'DK'
                -9  = 'NOT ASCERTAINED'
            1 - 31  = 'DAY OF MONTH';

VALUE EVMM       .  = '  '
                -1  = 'INAPPLICABLE'
                -7  = 'REFUSED'
                -8  = 'DK'
                -9  = 'NOT ASCERTAINED'
            1 - 12  = 'MONTH'
                95  = 'STILL IN PROGRESS';

VALUE EVYY       .  = '  '
                -1  = 'INAPPLICABLE'
                -7  = 'REFUSED'
                -8  = 'DK'
                -9  = 'NOT ASCERTAINED'
            1 - 99  = 'YEAR';

VALUE OMETYPE   -1  = 'INAPPLICABLE'
                -7  = 'REFUSED'
                -8  = 'DK'
                -9  = 'NOT ASCERTAINED'
                 1  = 'EYEGLASSES'
                 2  = 'HEARING OR SPEECH DEVICE'
                 3  = 'ORTHOPEDIC'
                 4  = 'DIABETIC'
                 5  = 'AMBULANCE'
                 6  = 'PROSTHESIS'
                 7  = 'ALTERATION'
                 8  = 'OXYGEN'
                 9  = 'KIDNEY DIALYSIS'
                10  = 'OTHER';

VALUE ORTHTYPE  -1  = 'INAPPLICABLE'
                -7  = 'REFUSED'
                -8  = 'DK'
                -9  = 'NOT ASCERTAINED'
                 1  = 'BRACES OR SUPPORTS'
                 2  = 'CANE'
                 3  = 'CORRECTIVE SHOES OR INSERTS'
                 4  = 'CRUTCHES'
                 5  = 'WALKER'
                 6  = 'WHEELCHAIR'
                91  = 'OTHER';

VALUE ALTRTYPE  -1  = 'INAPPLICABLE'
                -7  = 'REFUSED'
                -8  = 'DK'
                -9  = 'NOT ASCERTAINED'
                 1  = 'ELEVATOR OR INCLINE CHAIR'
                 2  = 'HANDRAILS (OTHER THAN TUB)'
                 3  = 'RAMPS'
                 4  = 'TUB HANDRAILS'
                 5  = 'TUB SEAT'
                 6  = 'ANY CAR ALTERATION'
                91  = 'OTHER';

VALUE OTHRTYPE  -1  = 'INAPPLICABLE'
                -7  = 'REFUSED'
                -8  = 'DK'
                -9  = 'NOT ASCERTAINED'
                 1  = 'PORT./RAISED TOILET'
                 2  = 'PORTABLE TUB SEAT'
                 3  = 'SPECIAL CHAIR OR CUSHION'
                 4  = 'HOSPITAL BED'
                 5  = 'OSTOMY SUPPLIES'
                 6  = 'DEPENDS (DIAPERS)'
                 7  = 'BANDAGES,DRESSINGS,TAPE SUPP.'
                 8  = 'PULMONARY EQUIPMENT'
                91  = 'OTHER';

VALUE PROVSPEC  -1  = 'INAPPLICABLE'
                -7  = 'REFUSED'
                -8  = 'DK'
                -9  = 'NOT ASCERTAINED'
                 1  = 'DENTIST/DENTAL PROVIDER'
                10  = 'HOSPICE WORKER'
                11  = 'I.V. THERAPIST'
                12  = 'NURSE (RN)'
                13  = 'NURSE PRACTITIONER (LPN)'
                14  = 'NURSE''S AIDE'
                15  = 'OCCUPATIONAL THERAPIST (OT)'
                16  = 'OPTOMETRIST'
                17  = 'OSTEOPATH (DO)'
                18  = 'PARAMEDIC'
                19  = 'PHYSICAL THERAPIST (PT)'
                2   = 'MEDICAL DOCTOR'
                20  = 'PHYSICIAN''S ASSISTANT'
                21  = 'PODIATRIST (FOOT DOCTOR)'
                22  = 'PSYCHOLOGIST'
                23  = 'RESPIRATORY THERAPIST'
                24  = 'SOCIAL/CASE WORKER'
                25  = 'SPEECH THERAPIST'
                26  = 'THERAPIST (MENTAL HEALTH)'
                27  = 'X-RAY TECHNICIAN'
                3   = 'AUDIOLOGIST'
                4   = 'CHIROPRACTOR'
                5   = 'CLINICAL SOCIAL WORKER'
                6   = 'DIETITIAN-NUTRITIONIST'
                7   = 'HEARING THERAPIST'
                8   = 'HOME HEALTH/HEALTH AIDE'
                9   = 'HOMEMAKER'
                91  = 'OTHER MEDICAL PROVIDER';

VALUE $EVNTNUM
    'CF00' - 'C999' = 'EVENT CREATED FROM CLAIM'
    '0000' - '9999' = 'SURVEY REPORTED EVENT';

VALUE $CLAIMTP  ' ' = ' '
                'D' = 'DME CLAIM'
                'P' = 'PHYSICIAN CLAIM';


