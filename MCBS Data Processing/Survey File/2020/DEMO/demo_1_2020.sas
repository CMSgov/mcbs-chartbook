
/************************************************************************
* File Name:   Demo 2020.sas                           		            *
*       						 		                                *
* Purpose: CREATE Survey File Demographic file 2020			            *
*                                                                       *
*                                                               	    *
* Created by:  Maggie Murgolo                                           *
* Created:     06/07/2017		                            	        *
*************************************************************************/

libname c88 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Datafiles\Community\2020 CAAF';
libname c85 'Y:\Share\SMAG\MCBS\MCBS Survey File\2019\Admin\Datafiles\Community\2019 CAAF'; 
libname f88 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Datafiles\Facility\Fall 2020 (Round 88) Data';
libname f87 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Datafiles\Facility\Summer 2020 (Round 87) Data';
libname f86 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Datafiles\Facility\Winter 2020 (Round 86) Data';
libname f85 'Y:\Share\SMAG\MCBS\MCBS Survey File\2019\Admin\Datafiles\Facility\R85';
libname f84 'Y:\Share\SMAG\MCBS\MCBS Survey File\2019\Admin\Datafiles\Facility\R84';
libname POP 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\2020 Population';  
libname DEMO19 'Y:\Share\SMAG\MCBS\MCBS Survey File\2019\Data\SAS Files';
libname DEMO18 'Y:\Share\SMAG\MCBS\MCBS Survey File\2018\Data\SAS Files';
libname INC    'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Income & Assets'; 
libname R88C   'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Datafiles\Community\2020 CAAF'; 
libname R85C   'Y:\Share\SMAG\MCBS\MCBS Survey File\2019\Admin\Datafiles\Community\2019 CAAF';   
Libname R82C   'Y:\Share\SMAG\MCBS\MCBS Survey File\2018\Admin\Datafiles\Community\2018 CAAF';                
libname R79C   'Y:\Share\SMAG\MCBS\MCBS Survey File\2017\Admin\Datafiles\Community\2017 CAAF'; 
*libname RICA   'Y:\Share\SMAG\SMAG Staff\Cheri Sharpless\Data_2020\For_Survey\PrelimA\'; *update*;
libname RICA   'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\_Administrative Data to Other Processes\SupportingDOCs_HIT_ADMINSRC_2020';
libname MIF	   'Y:\Share\SMAG\MCBS\Data\Data 2015-\MIF 2020\Data Files'; 
libname IPR    'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Income & Assets';

*libname library 'Y:\Share\IPG\DSMA\MCBS\MCBS Survey File\2017';

LIBNAME MCBSDATA 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\Demo\';

LIBNAME fmts 'Y:\Share\SMAG\MCBS\MCBS Codebook Production\Formats\2020 Formats';
*LIBNAME NORCFMT 'Y:\Share\IPG\DSMA\MCBS\MCBS Survey File\2018\Admin\Datafiles\Community\2018 CAAF\Formats';
options fmtsearch=(fmts);
*options fmtsearch=(NORCFMT);

options nofmterr;
ods html close;
ods html;

PROC FORMAT library=fmts;
  VALUE IND1FMT    . = "Inapplicable/Missing"
                  .R = "Refused"
                  .D = "Don't know"
                  .N = "Not ascertained"
                   1 = "Indicated"
                   0 = "Not indicated" ;

	VALUE YESNOJOB  
                   1 = "Yes"
                   2 = "No"
                   3 = "No, facility respondent"
                   . = "Inapplicable/Missing"
                  .R = "Refused"
                  .D = "Don't know"
                  .N = "Not ascertained";

	 /*VALUE ADISFMT
		 . = "Inapplicable"
		 .S = "Suppressed"
		 1-10 = "ADI state decile";

	 VALUE ADINFMT
		 . = "Inapplicable"
		 .S = "Suppressed"
		 1-100 = "ADI national percentile";
     */



quit;


*Pull in 2019 to capture data from previous year;
Data MCBSDATA.DEMO_19 (drop= version panel jobstat);
set DEMO19.DEMO;
*D_DOB,D_DOD are numeric will need to convert to character;
proc sort; by baseid; 
run;

Data DEMO_DATE19;
set mcbsdata.DEMO_19;
DOB_NEW=put(D_DOB,YYMMn6.);
DOD_NEW=put(D_DOD,YYMMn6.);
run;

Data mcbsdata.DEMO_2019 ;
set DEMO_DATE19 (drop=D_DOB D_DOD );
rename DOB_NEW=D_DOB;
rename DOD_NEW=D_DOD;
rename ENGWELL=ENGW19;
rename OTHRLANG=OTHR19;
rename WHATLANG=WHAT19;
rename SPMARSTA=MAR19_DEMO;
rename spchnlnm=child19;
proc sort; by baseid;
run;


/*POP file*/
DATA CUT /* 2020--POP*/;                                              
 SET POP.pop2020_final_feb22;  /*UPDATE*/
rostsex=input(sex, 4.);
proc sort; by baseid;
run;

/*New var D_DOD found in MIF file DOD_SURVEY)*/
/*DOD in MIF file is numeric MMDDYY10. (MM/DD/YYYY)*/
data MIF1 (keep= baseid DOD_SURVEY);
set MIF.M_INDEX_2020R90; /*UPDATE*/
proc sort; by baseid;
run;
/*converted numeric to character date here to get rid of '/' date is now MMDDYYYY*/
data MIFDATE;
set MIF1;
DOD_NEW=put(DOD_SURVEY,mmddyyn.); 
run;
/*Trimmed MMDDYYYY date to get YYYYMM date*/
Data MIF (keep= baseid DOD_NEW D_DOD DODMM DODYY);
length DODYY $4. DODMM $2. D_DOD $6.;
set MIFDATE;
DODMM=substr(DOD_NEW,1,2);
DODYY=substr(DOD_NEW,5,4);

D_DOD=TRIM(DODYY)||TRIM(DODMM);
proc sort; by baseid; 
run;


/*In segment files DOB is numeric and broken into separate variables. 
The code below combines hhdobyy and hhdobmm and makes character*/
data commsex88 (keep=baseid rostsex d_dob);/*d_dob format = YYYYMM*/
length D_DOB $6.;
set c88.rost;
if rostrel=1;
d_dob=(hhdobyy*100)+hhdobmm;
run;

/*2018 Community ENUM segment includes R80, R81 and R82 the code below creates separate round files*/
data commjob88;
set c88.enum (keep = baseid jobstat hhpwork enumrnd hhprel) ;
if hhprel=1;
/*Added to capture only 1 baseid per round*/
if enumrnd = 88 then output commjob88;
run;

data commjob88;
set commjob88; 
proc sort;
by baseid;
run;


/*In facility segment files DOB and DOD are numeric and broken into separate variables. 
The code below combines dobyy and dobmm and makes character*/
data fac88sex (keep=baseid rostsex d_dob d_dod /*dodyy dodmm*/);
length D_DOB $6. D_DOD $6. /*DODYY $4. DODMM $2.*/;
set f88.sp;
d_dob=(dobyy*100)+dobmm;
/*DODYY was only 2 digit needed to add 2000 to make 4 digit year*/
dodyy = (dodyy+2000);
D_DOD=(dodyy*100)+dodmm;
rename sex = rostsex;
run;

data fac87sex (keep=baseid rostsex d_dob d_dod /*dodyy dodmm*/);
length D_DOB $6. D_DOD $6. /*DODYY $4. DODMM $2.*/;
set f87.sp;
d_dob=(dobyy*100)+dobmm;
/*DODYY was only 2 digit needed to add 2000 to make 4 digit year*/
dodyy = (dodyy+2000);
D_DOD=(dodyy*100)+dodmm;
rename sex = rostsex;
run;

data fac86sex (keep=baseid rostsex d_dob d_dod /*dodyy dodmm*/);
length D_DOB $6. D_DOD $6. /*DODYY $4. DODMM $2.*/;
set f86.sp;
d_dob=(dobyy*100)+dobmm;
/*DODYY was only 2 digit needed to add 2000 to make 4 digit year*/
dodyy = (dodyy+2000);
D_DOD=(dodyy*100)+dodmm;
rename sex = rostsex;
run;

data fac85sex (keep=baseid rostsex d_dob d_dod /*dodyy dodmm*/);
length D_DOB $6. D_DOD $6. /*DODYY $4. DODMM $2.*/;
set f85.sp;
d_dob=(dobyy*100)+dobmm;
/*DODYY was only 2 digit needed to add 2000 to make 4 digit year*/
dodyy = (dodyy+2000);
D_DOD=(dodyy*100)+dodmm;
rename sex = rostsex;
run;

data fac84sex (keep=baseid rostsex d_dob d_dod /*dodyy dodmm*/);
length D_DOB $6. D_DOD $6. /*DODYY $4. DODMM $2.*/;
set f84.sp;
d_dob=(dobyy*100)+dobmm;
/*DODYY was only 2 digit needed to add 2000 to make 4 digit year*/
dodyy = (dodyy+2000);
D_DOD=(dodyy*100)+dodmm;
rename sex = rostsex;
run;


/*Merge all FACSEX data sets*/
data facsex;
merge fac84sex fac85sex fac86sex fac87sex fac88sex; 
by baseid;
if last.baseid;
length rostsex 4.;

/******************************************************************************
* The variable ROSTSEX (in community) has a length of 4. and the facility var  *
* SEX has a length of 8. This(length rostsex 4.) makes them equal.             *
*  Note: sex was renamed rostsex (rename sex = rostsex) for facility segments  *
********************************************************************************/
run;

/*Merge community and facility sex datasets as well as previous years files and the MIF*/
data gender (keep=baseid rostsex d_dob d_dod);
merge cut(in=a) mcbsdata.DEMO_2019 MIF facsex commsex88;
by baseid;
if a;
run;


/*Facility info on education and no. of children*/
data fac88_demo (keep = baseid spdegrcv MAR88_F spchnlnm);
set f88.back;
rename bedulev = spdegrcv;
rename bmrjan2 = MAR88_F;
if btotlson > -1 and btotldau > -1 then spchnlnm=btotlson + btotldau; else
if btotlson < -1 and btotldau > -1 then spchnlnm = btotldau; else
if btotlson > -1 and btotldau < -1 then spchnlnm = btotlson; else
if btotlson < -1 and btotldau < -1 then spchnlnm = btotlson;

run;

data fac87_demo (keep = baseid spdegrcv spchnlnm);
set f87.back;
rename bedulev = spdegrcv;
if btotlson > -1 and btotldau > -1 then spchnlnm=btotlson + btotldau; else
if btotlson < -1 and btotldau > -1 then spchnlnm = btotldau; else
if btotlson > -1 and btotldau < -1 then spchnlnm = btotlson; else
if btotlson < -1 and btotldau < -1 then spchnlnm = btotlson;
run;

data fac86_demo (keep = baseid spdegrcv spchnlnm);
set f86.back;
rename bedulev = spdegrcv;
if btotlson > -1 and btotldau > -1 then spchnlnm=btotlson + btotldau; else
if btotlson < -1 and btotldau > -1 then spchnlnm = btotldau; else
if btotlson > -1 and btotldau < -1 then spchnlnm = btotlson; else
if btotlson < -1 and btotldau < -1 then spchnlnm = btotlson;
run;

data fac85_demo (keep = baseid spdegrcv spchnlnm);
set f85.back;
rename bedulev = spdegrcv;
if btotlson > -1 and btotldau > -1 then spchnlnm=btotlson + btotldau; else
if btotlson < -1 and btotldau > -1 then spchnlnm = btotldau; else
if btotlson > -1 and btotldau < -1 then spchnlnm = btotlson; else
if btotlson < -1 and btotldau < -1 then spchnlnm = btotlson;
run;

data fac84_demo (keep = baseid spdegrcv spchnlnm);
set f84.back;
rename bedulev = spdegrcv;
if btotlson > -1 and btotldau > -1 then spchnlnm=btotlson + btotldau; else
if btotlson < -1 and btotldau > -1 then spchnlnm = btotldau; else
if btotlson > -1 and btotldau < -1 then spchnlnm = btotlson; else
if btotlson < -1 and btotldau < -1 then spchnlnm = btotlson;
run;

/*2018 Community HRND segment includes R80, R81 and R82 the code below creates separate round files*/
data comm_mar88 (keep = baseid spmarsta spchnlnm)comm_mar87 (keep = baseid spmarsta spchnlnm)
comm_mar86 (keep = baseid spmarsta spchnlnm);
set c88.hrnd; 
by baseid; 
/*Added to capture only 1 baseid per round*/
if hrndrnd = 88 then output comm_mar88;
if hrndrnd = 87 then output comm_mar87;
if hrndrnd = 86 then output comm_mar86;
proc sort; 
by baseid; run; 
run;

data comm_mar88;
set comm_mar88;
by baseid;
IF spmarsta = . then delete;
rename spmarsta = MAR88_C; 
run;

data comm_mar87;
set comm_mar87;
by baseid;
IF spmarsta = . then delete;
rename spmarsta = MAR87_C; 
run;

data comm_mar86;
set comm_mar86;
by baseid;
IF spmarsta = . then delete;
rename spmarsta = MAR86_C; 
run;

/*2016--Education is now in the HOME segment*/
data COMM_Ed88 (keep=baseid spdegrcv);
set c88.home;
proc sort; by baseid;
run;

/*Merge Community and Facility with previous years data files*/
data ed_mar (keep = baseid spdegrcv spmarsta spchnlnm jobstat hhpwork MAR88_C MAR87_C MAR86_C MAR88_F MAR19_DEMO spsdth);
merge cut(in=a) fac84_demo fac85_demo fac86_demo fac87_demo comm_mar86 comm_mar87
  mcbsdata.DEMO_2019 comm_ed88 commjob88 fac88_demo comm_mar88;
by baseid;
if a;
/*****************************************************************************
* There was one community sp (01219445=BASEID) with a value of -1 for both	 *
* SPCHNLNM and SPDEGRCV and 13 facility sp's with a value of -1 for spdegrcv.* 
* This will recode them to -8 (DONT KNOW).      							 *
*****************************************************************************/ 
if spchnlnm = . then spchnlnm = .D;
if spdegrcv in (., -1) then spdegrcv = .D;
if int_type = 'F' and jobstat ne . then jobstat = .;

/*Fix for number of children*/
IF SPCHNLNM = . OR (SPCHNLNM IN (.R,.D,.N) AND CHILD19 >=0) 
THEN SPCHNLNM=CHILD19;

/*Fix to fill in for missing ENG data*/
/*IF ENGWELL=. OR (ENGWELL IN (.R,.D,.N) AND ENGW17 IN (1,2,3,4))  
  THEN ENGWELL=ENGW17;  
IF OTHRLANG=. OR (OTHRLANG IN (.R,.D,.N) AND OTHR17 IN (1,2))  
  THEN OTHRLANG=OTHR17;
IF WHATLANG=. OR (WHATLANG IN (.R,.D,.N) AND WHAT17 IN (1,2,3,91))  
  THEN WHATLANG=WHAT17;*/

/*FIX TO FILL IN MISSING MARITIAL DATA*/
IF MAR88_C=. OR (MAR88_C IN (.R,.D,.N) AND MAR88_F IN (1,2,3,4,5))  
  THEN MAR88_C = MAR88_F; 
IF MAR88_C=. OR (MAR88_C IN (.R,.D,.N) AND MAR19_DEMO IN (1,2,3,4,5))  
  THEN MAR88_C = MAR19_DEMO; 
  SPMARSTA = MAR88_C;

/*2017 Create new variable SPSDTH -- flag that indictaes if a SPs spouse died within the last year*/
  IF SPMARSTA=2 THEN SPSDTH=1;
  ELSE SPSDTH=.;

run;

/*Additional code to create SPSDTH variable for 2017*/
/*Keep only these vars from ED_MAR*/
data SPMAR (keep =baseid spmarsta spsdth);
set ed_mar;
proc sort; by baseid;
run;

/*Keep only these vars from ENUM where hhprel is 2 and round is 88*/
data HELPDTH88 (keep = baseid nothhrsn hhprel);
set R88C.enum (where=(hhprel=2 and enumrnd=88) keep = baseid enumrnd hhprel nothhrsn);
run;

/*Keep only these vars from ENUM where hhprel is 2 and round is 87*/
data HELPDTH87 (keep = baseid nothhrsn hhprel);
set R88C.enum (where=(hhprel=2 and enumrnd=87) keep = baseid enumrnd hhprel nothhrsn);
run;

/*Keep only these vars from ENUM where hhprel is 2 and round is 86*/
data HELPDTH86 (keep = baseid nothhrsn hhprel);
set R88C.enum (where=(hhprel=2 and enumrnd=86) keep = baseid enumrnd hhprel nothhrsn);
run;

data HELPDTH /*(drop = nothhrsn86 nothhrsn87 nothhrsn88)*/;
            merge HELPDTH86 (in=c rename=(nothhrsn=nothhrsn86))
			HELPDTH87 (in=b rename=(nothhrsn=nothhrsn87))
            HELPDTH88 (in=a rename=(nothhrsn=nothhrsn88));
by baseid;
if a or b or c;
if nothhrsn88=1 or nothhrsn87=1 or nothhrsn86=1 then nothhrsn=1;
run;
proc datasets nodetails nolist; delete nothhrsn86 nothhrsn87 nothhrsn88; run;

data mcbsdata.SPDIED (keep = baseid spsdth spmarsta hhprel nothhrsn);
merge SPMAR (in=a) HELPDTH;
by baseid; if a;

/*2017 Create new variable SPSDTH -- flag that indictaes if a SPs spouse died within the last year*/
if spmarsta= 2 and hhprel= 2 and nothhrsn= 1 and SPSDTH ne . then spsdth= 1;
else if SPSDTH ne . then spsdth=2; 
run;

/*Duplicates on file -- who are they*/
/*proc sort data = mcbsdata.SPDIED ;
 by baseid ;
run ;
proc freq data = mcbsdata.SPDIED noprint ;
 by baseid ;
 table baseid / out = mcbsdata.SPDIED_DUPS (keep = baseid Count
 where = (Count > 1)) ;
run ; */

/*Delete dups after review */
PROC SORT DATA=mcbsdata.SPDIED
 OUT=mcbsdata.SPDIED_2
 NODUPKEYS ;
 BY baseid ;
RUN ;

/*Final file to be merged -- keep only baseid and spsdth*/
data SPDIED_3 (keep = baseid spsdth);
set mcbsdata.SPDIED_2;
proc sort; by baseid; 
run;


/*Facility race and military segment*/
data back88mil (keep=baseid spafever spafviet spafkore spafwwii spafgulf spafiraf 
                            spafpeac spngever spngall spvarate
         hisporig raceas raceaa racenh racewh raceai d_race2 HISPORMA HISPORPR HISPORCU HISPOROT
	 RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO RACEASVI RACEASOT  RACEPIHA RACEPIGU RACEPISA
	RACEPIOT );
set f88.back;

/*Beginning in 2015 all '2' responses should be '0' -- for indicated and not indicated responses*/
/*Looks like some yes no resposes were changed here -- will change those back to a '2' towards end of program*/
array switch{*} beveraf bvietnam bkorea bwwarii bgulf biraf ballothr beverng bngduty bvarate
                 hisporig raceas raceaa racenh racewh raceai BHSPMEXI BHSPPR BHSPCBAN BHSPOTHR
 	BRACASAI BRACASCH BRACASFI BRACASJA BRACASKO BRACASVI BRACASOT BRACPIHA BRACPIGU BRACPISA
 	BRACPIOT; 
  do i = 1 to dim(switch);
   if switch(i) = 2 then switch(i)=0;
    else if switch(i) = -1 then switch(i) = .;
 end;

 /*Rename to match community names*/
rename beveraf  = spafever;
rename bvietnam = spafviet;
rename bkorea   = spafkore;
rename bwwarii  = spafwwii;
rename bgulf    = spafgulf;
rename biraf    = spafiraf;
rename ballothr = spafpeac;
rename beverng  = spngever;
rename bngduty  = spngall;
rename bvarate  = spvarate;
rename BHSPMEXI = HISPORMA;
rename BHSPPR   = HISPORPR;
rename BHSPCBAN = HISPORCU;
rename BHSPOTHR  = HISPOROT;
rename BRACASAI = RACEASAI;
rename BRACASCH = RACEASCH;
rename BRACASFI = RACEASFI;
rename BRACASJA = RACEASJA;
rename BRACASKO = RACEASKO;
rename BRACASVI = RACEASVI;
rename BRACASOT = RACEASOT;
rename BRACPIHA = RACEPIHA;
rename BRACPIGU = RACEPIGU;
rename BRACPISA = RACEPISA;
rename BRACPIOT = RACEPIOT;

fmore=raceasia+raceblck+racepaci+racewhit+raceaian/*+raceothr*/;
if fmore = 1 and raceaian=1 then d_race2=5; else /*american indian-alaska native*/
if fmore = 1 and racepaci=1 then d_race2=3; else /*native hawaiian or pac islander*/
if fmore = 1 and raceasia=1 then d_race2=1; else /*asian*/
if fmore = 1 and raceblck=1 then d_race2=2; else /*black*/
if fmore = 1 and racewhit=1 then d_race2=4; else /*white*/
if fmore > 1 then d_race2 = 7; else         /*more than 1*/
if fmore < 1 then d_race2 = raceasia;

raceas = raceasia;
raceaa = raceblck;
racenh = racepaci;
racewh = racewhit;
raceai = raceaian;
hisporig=bhisporg;

run;

data back87mil (keep=baseid spafever spafviet spafkore spafwwii spafgulf spafiraf 
                            spafpeac spngever spngall spvarate
         hisporig raceas raceaa racenh racewh raceai d_race2 HISPORMA HISPORPR HISPORCU HISPOROT
	 RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA
	RACEPIOT);
set f87.back;

/*Beginning in 2015 all '2' responses should be '0'*/
array switch{*} beveraf bvietnam bkorea bwwarii bgulf biraf ballothr beverng bngduty bvarate
                 hisporig raceas raceaa racenh racewh raceai  BHSPMEXI BHSPPR BHSPCBAN BHSPOTHR
 	BRACASAI BRACASCH BRACASFI BRACASJA BRACASKO BRACASVI BRACASOT BRACPIHA BRACPIGU BRACPISA
 	BRACPIOT; 
  do i = 1 to dim(switch);
   if switch(i) =2 then switch(i)=0;
    else if switch(i) = -1 then switch(i) = .;
 end;

rename beveraf  = spafever;
rename bvietnam = spafviet;
rename bkorea   = spafkore;
rename bwwarii  = spafwwii;
rename bgulf    = spafgulf;
rename biraf    = spafiraf;
rename ballothr = spafpeac;
rename beverng  = spngever;
rename bngduty  = spngall;
rename bvarate  = spvarate;
rename BHSPMEXI = HISPORMA;
rename BHSPPR   = HISPORPR;
rename BHSPCBAN = HISPORCU;
rename BHSPOTHR  = HISPOROT;
rename BRACASAI = RACEASAI;
rename BRACASCH = RACEASCH;
rename BRACASFI = RACEASFI;
rename BRACASJA = RACEASJA;
rename BRACASKO = RACEASKO;
rename BRACASVI = RACEASVI;
rename BRACASOT = RACEASOT;
rename BRACPIHA = RACEPIHA;
rename BRACPIGU = RACEPIGU;
rename BRACPISA = RACEPISA;
rename BRACPIOT = RACEPIOT;

fmore=raceasia+raceblck+racepaci+racewhit+raceaian/*+raceothr*/;
if fmore = 1 and raceaian=1 then d_race2=5; else /*american indian-alaska native*/
if fmore = 1 and racepaci=1 then d_race2=3; else /*native hawaiian or pac islander*/
if fmore = 1 and raceasia=1 then d_race2=1; else /*asian*/
if fmore = 1 and raceblck=1 then d_race2=2; else /*black*/
if fmore = 1 and racewhit=1 then d_race2=4; else /*white*/
if fmore > 1 then d_race2 = 7; else         /*more than 1*/
if fmore < 1 then d_race2 = raceasia;

raceas = raceasia;
raceaa = raceblck;
racenh = racepaci;
racewh = racewhit;
raceai = raceaian;
hisporig=bhisporg;
run;

data back86mil (keep=baseid spafever spafviet spafkore spafwwii spafgulf spafiraf 
                            spafpeac spngever spngall spvarate
         hisporig raceas raceaa racenh racewh raceai d_race2 HISPORMA HISPORPR HISPORCU HISPOROT
	 RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA
	RACEPIOT);
set f86.back;

/*Beginning in 2015 all '2' responses should be '0'*/
array switch{*} beveraf bvietnam bkorea bwwarii bgulf biraf ballothr beverng bngduty bvarate
                 hisporig raceas raceaa racenh racewh raceai BHSPMEXI BHSPPR BHSPCBAN BHSPOTHR
 	BRACASAI BRACASCH BRACASFI BRACASJA BRACASKO BRACASVI BRACASOT BRACPIHA BRACPIGU BRACPISA
 	BRACPIOT; 
  do i = 1 to dim(switch);
   if switch(i) =2 then switch(i)=0;
    else if switch(i) = -1 then switch(i) = .;
 end;

rename beveraf  = spafever;
rename bvietnam = spafviet;
rename bkorea   = spafkore;
rename bwwarii  = spafwwii;
rename bgulf    = spafgulf;
rename biraf    = spafiraf;
rename ballothr = spafpeac;
rename beverng  = spngever;
rename bngduty  = spngall;
rename bvarate  = spvarate;
rename BHSPMEXI = HISPORMA;
rename BHSPPR   = HISPORPR;
rename BHSPCBAN = HISPORCU;
rename BHSPOTHR  = HISPOROT;
rename BRACASAI = RACEASAI;
rename BRACASCH = RACEASCH;
rename BRACASFI = RACEASFI;
rename BRACASJA = RACEASJA;
rename BRACASKO = RACEASKO;
rename BRACASVI = RACEASVI;
rename BRACASOT = RACEASOT;
rename BRACPIHA = RACEPIHA;
rename BRACPIGU = RACEPIGU;
rename BRACPISA = RACEPISA;
rename BRACPIOT = RACEPIOT;

fmore=raceasia+raceblck+racepaci+racewhit+raceaian/*+raceothr*/;
if fmore = 1 and raceaian=1 then d_race2=5; else /*american indian-alaska native*/
if fmore = 1 and racepaci=1 then d_race2=3; else /*native hawaiian or pac islander*/
if fmore = 1 and raceasia=1 then d_race2=1; else /*asian*/
if fmore = 1 and raceblck=1 then d_race2=2; else /*black*/
if fmore = 1 and racewhit=1 then d_race2=4; else /*white*/
if fmore > 1 then d_race2 = 7; else         /*more than 1*/
if fmore < 1 then d_race2 = raceasia;

raceas = raceasia;
raceaa = raceblck;
racenh = racepaci;
racewh = racewhit;
raceai = raceaian;
hisporig=bhisporg;
run;

data back85mil (keep=baseid spafever spafviet spafkore spafwwii spafgulf spafiraf 
                            spafpeac spngever spngall spvarate
         hisporig raceas raceaa racenh racewh raceai  d_race2 HISPORMA HISPORPR HISPORCU HISPOROT
	RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA
	RACEPIOT);
set f85.back;

/*Beginning in 2015 all '2' responses should be '0'*/
array switch{*} beveraf bvietnam bkorea bwwarii bgulf biraf ballothr beverng bngduty bvarate
                 hisporig raceas raceaa racenh racewh raceai BHSPMEXI BHSPPR BHSPCBAN BHSPOTHR
 	BRACASAI BRACASCH BRACASFI BRACASJA BRACASKO BRACASVI BRACASOT BRACPIHA BRACPIGU BRACPISA
 	BRACPIOT; 
  do i = 1 to dim(switch);
   if switch(i) = 2 then switch(i)=0;
    else if switch(i) = -1 then switch(i) = .;
 end;

rename beveraf  = spafever;
rename bvietnam = spafviet;
rename bkorea   = spafkore;
rename bwwarii  = spafwwii;
rename bgulf    = spafgulf;
rename biraf    = spafiraf;
rename ballothr = spafpeac;
rename beverng  = spngever;
rename bngduty  = spngall;
rename bvarate  = spvarate;
rename BHSPMEXI = HISPORMA;
rename BHSPPR   = HISPORPR;
rename BHSPCBAN = HISPORCU;
rename BHSPOTHR  = HISPOROT;
rename BRACASAI = RACEASAI;
rename BRACASCH = RACEASCH;
rename BRACASFI = RACEASFI;
rename BRACASJA = RACEASJA;
rename BRACASKO = RACEASKO;
rename BRACASVI = RACEASVI;
rename BRACASOT = RACEASOT;
rename BRACPIHA = RACEPIHA;
rename BRACPIGU = RACEPIGU;
rename BRACPISA = RACEPISA;
rename BRACPIOT = RACEPIOT;

fmore=raceasia+raceblck+racepaci+racewhit+raceaian/*+raceothr*/;
if fmore = 1 and raceaian=1 then d_race2=5; else /*american indian-alaska native*/
if fmore = 1 and racepaci=1 then d_race2=3; else /*native hawaiian or pac islander*/
if fmore = 1 and raceasia=1 then d_race2=1; else /*asian*/
if fmore = 1 and raceblck=1 then d_race2=2; else /*black*/
if fmore = 1 and racewhit=1 then d_race2=4; else /*white*/
if fmore > 1 then d_race2 = 7; else         /*more than 1*/
if fmore < 1 then d_race2 = raceasia;

raceas = raceasia;
raceaa = raceblck;
racenh = racepaci;
racewh = racewhit;
raceai = raceaian;
hisporig=bhisporg;

run;

data back84mil (keep=baseid spafever spafviet spafkore spafwwii spafgulf spafiraf 
                            spafpeac spngever spngall spvarate
         hisporig raceas raceaa racenh racewh raceai d_race2 HISPORMA HISPORPR HISPORCU HISPOROT
	RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA
	RACEPIOT);
set f84.back;

/*Beginning in 2015 all '2' responses should be '0'*/
array switch{*} beveraf bvietnam bkorea bwwarii bgulf biraf ballothr beverng bngduty bvarate
                 hisporig raceas raceaa racenh racewh raceai BHSPMEXI BHSPPR BHSPCBAN BHSPOTHR
 	BRACASAI BRACASCH BRACASFI BRACASJA BRACASKO BRACASVI BRACASOT BRACPIHA BRACPIGU BRACPISA
 	BRACPIOT; 
  do i = 1 to dim(switch);
  if switch(i) = 2 then switch(i)=0;
    else if switch(i) = -1 then switch(i) = .;
 end;

rename beveraf  = spafever;
rename bvietnam = spafviet;
rename bkorea   = spafkore;
rename bwwarii  = spafwwii;
rename bgulf    = spafgulf;
rename biraf    = spafiraf;
rename ballothr = spafpeac;
rename beverng  = spngever;
rename bngduty  = spngall;
rename bvarate  = spvarate;
rename BHSPMEXI = HISPORMA;
rename BHSPPR   = HISPORPR;
rename BHSPCBAN = HISPORCU;
rename BHSPOTHR  = HISPOROT;
rename BRACASAI = RACEASAI;
rename BRACASCH = RACEASCH;
rename BRACASFI = RACEASFI;
rename BRACASJA = RACEASJA;
rename BRACASKO = RACEASKO;
rename BRACASVI = RACEASVI;
rename BRACASOT = RACEASOT;
rename BRACPIHA = RACEPIHA;
rename BRACPIGU = RACEPIGU;
rename BRACPISA = RACEPISA;
rename BRACPIOT = RACEPIOT;

fmore=raceasia+raceblck+racepaci+racewhit+raceaian/*+raceothr*/;
if fmore = 1 and raceaian=1 then d_race2=5; else /*american indian-alaska native*/
if fmore = 1 and racepaci=1 then d_race2=3; else /*native hawaiian or pac islander*/
if fmore = 1 and raceasia=1 then d_race2=1; else /*asian*/
if fmore = 1 and raceblck=1 then d_race2=2; else /*black*/
if fmore = 1 and racewhit=1 then d_race2=4; else /*white*/
if fmore > 1 then d_race2 = 7; else         /*more than 1*/
if fmore < 1 then d_race2 = raceasia;

raceas = raceasia;
raceaa = raceblck;
racenh = racepaci;
racewh = racewhit;
raceai = raceaian;
/*raceoth = raceothr;*/
hisporig=bhisporg;

run;

/*Community race and military segment*/
/*Beginning in 2015 all '2' responses should be '0'*/
data commil88 (keep=baseid spafever spafviet spafkore spafwwii spafgulf spafiraf 
             spafpeac spngever spngall spngdsbl spvarate
             hisporig raceas raceaa racenh racewh raceai d_race2 HISPORMA HISPORPR HISPORCU HISPOROT
			 RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO 
			RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA RACEPIOT ENGREAD ENGWELL OTHRLANG WHATLANG whtlngos);
set c88.home;

array switch{*} spafever spafviet spafkore spafwwii spafgulf spafiraf 
             spafpeac spngever spngall spngdsbl spvarate
			 hisporig raceas raceaa racenh racewh raceai HISPORMA HISPORPR HISPORCU HISPOROT
			 RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO 
			 RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA RACEPIOT; 
  do i = 1 to dim(switch);
   if switch(i) = 2 then switch(i)=0;
    else if switch(i) = -1 then switch(i) = .;
 end;

more = raceas + raceaa + racenh + racewh + raceai /*+ raceoth*/;
if more = 1 and raceai=1 then d_race2=5; else /*american indian*/
if more = 1 and racenh=1 then d_race2=3; else /*native hawaiian or pac islander*/
if more = 1 and raceas=1 then d_race2=1; else /*asian*/
if more = 1 and raceaa=1 then d_race2=2; else /*black*/
if more = 1 and racewh=1 then d_race2=4; else /*white*/
if more > 1 then d_race2 = 7; else         /*more than 1*/
if more < 6 and raceas=.D or raceaa=.D or racenh=.D or
  racewh=.D or raceai=.D then d_race2=.D; else
if more < 6 and raceas=.N or raceaa=.N or racenh=.N or
  racewh=.N or raceai=.N then d_race2=.N; else
if more < 6 and raceas=.R or raceaa=.R or racenh=.R or
  racewh=.R or raceai=.R then d_race2=.R; else
if more = 0 then d_race2= .D;

if spafever = . then delete;
if racewh = . then delete;


run;


data commil85 (keep=baseid spafever spafviet spafkore spafwwii spafgulf spafiraf 
             spafpeac spngever spngall spngdsbl spvarate
             hisporig raceas raceaa racenh racewh raceai d_race2 HISPORMA HISPORPR HISPORCU HISPOROT
			 RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO 
			RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA RACEPIOT);
set c85.home;

array switch{*} spafever spafviet spafkore spafwwii spafgulf spafiraf 
             spafpeac spngever spngall spngdsbl spvarate
			 hisporig raceas raceaa racenh racewh raceai HISPORMA HISPORPR HISPORCU HISPOROT
			 RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO 
			 RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA RACEPIOT; 
  do i = 1 to dim(switch);
   if switch(i) = 2 then switch(i)=0;
    else if switch(i) = -1 then switch(i) = .;
 end;

more = raceas + raceaa + racenh + racewh + raceai;
if more = 1 and raceai=1 then d_race2=5; else /*american indian*/
if more = 1 and racenh=1 then d_race2=3; else /*native hawaiian or pac islander*/
if more = 1 and raceas=1 then d_race2=1; else /*asian*/
if more = 1 and raceaa=1 then d_race2=2; else /*black*/
if more = 1 and racewh=1 then d_race2=4; else /*white*/
if more > 1 then d_race2 = 7; else        /*more than 1*/
if more < 6 and raceas=-8 or raceaa=-8 or racenh=-8 or
  racewh=-8 or raceai=-8  then d_race2=-8; else
if more < 6 and raceas=.D or raceaa=.D or racenh=.D or
  racewh=.D or raceai=.D then d_race2=.D; else
if more < 6 and raceas=-9 or raceaa=-9 or racenh=-9 or
  racewh=-9 or raceai=-9 then d_race2=-9; else
if more < 6 and raceas=.N or raceaa=.N or racenh=.N or
  racewh=.N or raceai=.N then d_race2=.N; else
if more < 6 and raceas=-7 or raceaa=-7 or racenh=-7 or
  racewh=-7 or raceai=-7 then d_race2=-7; else
if more < 6 and raceas=.R or raceaa=.R or racenh=.R or
  racewh=.R or raceai=.R then d_race2=.R; else
if more = 0 then d_race2= -8; ELSE
if more = 0 then d_race2= .D;

if spafever = . then delete;
if racewh = . then delete;

run;


data commil (keep=baseid spafever spafviet spafkore spafwwii spafgulf spafiraf 
                            spafpeac spngever spngall spngdsbl spvarate
               hisporig raceas raceaa racenh racewh raceai d_race2 HISPORMA HISPORPR HISPORCU HISPOROT
			 RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO 
			RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA RACEPIOT ENGREAD ENGWELL OTHRLANG WHATLANG WHTLNGOS);
merge commil85 commil88(in=a);
by baseid;if a;
run;

/*Merge community and facility mil and race datasets*/
data mcbsdata.totalmil (keep=baseid spafever spafviet spafkore spafwwii spafgulf spafiraf 
    spafpeac spngever spngall spngdsbl spvarate
    hisporig raceas raceaa racenh racewh raceai /*raceoth*/ d_race2 HISPORMA HISPORPR HISPORCU HISPOROT
    RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO 
    RACEASVI RACEASOT RACEPIHA RACEPIGU RACEPISA RACEPIOT ENGREAD ENGWELL OTHRLANG WHATLANG WHTLNGOS 
    ENGW19 OTHR19 WHAT19);
merge cut(in=a)  back84mil back85mil back86mil 
back87mil mcbsdata.DEMO_2019 back88mil commil ;
by baseid;
if a;
if last.baseid;

/*Edit for ENGLISH variables if 2019 data is missing pull forward from 2018*/
IF ENGWELL=. OR (ENGWELL IN (.R,.D,.N) AND ENGW19 IN (1,2,3,4))  
  THEN ENGWELL=ENGW19;  
IF OTHRLANG=. OR (OTHRLANG IN (.R,.D,.N) AND OTHR19 IN (1,2))  
  THEN OTHRLANG=OTHR19;
IF WHATLANG=. OR (WHATLANG IN (.R,.D,.N) AND WHAT19 IN (1,2,3,91))  
  THEN WHATLANG=WHAT19;

/*2018 EDIT FOR OTHER LANGUAGE*/
IF WHTLNGOS IN ('CAJUN FRENCH','FRENCH','FRENCH CREOLE','FRENCH/CREOLE') THEN WHATLANG = 02; /*FRENCH*/

else IF WHTLNGOS IN ('GERMAN','GERMAN MOM IS GERMAN') THEN WHATLANG = 03; /*GERMAN*/

ELSE IF WHTLNGOS IN ('FITALIAN','ITALIAN','ITALINA','ITIALIAN','ITILIAN','IITALIAN') THEN WHATLANG = 4; /*ITALIAN*/

ELSE IF WHTLNGOS IN ('ATAGLOG','TAGALO','TAGALOG','TAGLOG','TAGOLOG','TEGALOG') THEN WHATLANG = 5; /*TAGALOG*/

ELSE IF WHTLNGOS IN ('CHINESE','MANDARIN CHINESE','CANTONESE','CANTONESE AND MANDARIAN','CHINESE, CANOTONESS',
'MANDARIN','MANDARIN AND CANTONESE','MANDRIN')THEN WHATLANG = 6; /*CHINESE*/

ELSE IF WHTLNGOS IN ('POLISH','POLISH.','POLISIH') THEN WHATLANG = 7; /*POLISH*/

ELSE IF WHTLNGOS = 'KOREAN' THEN WHATLANG = 8; /*KOREAN*/

ELSE IF WHTLNGOS IN ('RUSSIAN','RUSSIAN.','HE SPEAKS RUSSIAN') THEN WHATLANG = 9; /*RUSSIAN*/

ELSE IF WHTLNGOS IN ('GREEK','GREAK') THEN WHATLANG = 10; /*GREEK*/

ELSE IF WHTLNGOS IN ('FILAPINO','FILIINO','FILIPINO','FILOPINO','PHILIAPHINO','PHILIPHNOIS',
'PHILIPINO','PHILLINO','PHILLIPHINE','PHILLIPINE','PHILLIPINES','PHILLIPINO','PILIPINO') THEN WHATLANG = 11; /*FILIPINO*/

ELSE IF WHTLNGOS IN ('ABABIC','ARABIC','ARABIC ...','AREBIC') THEN WHATLANG = 12; /*ARABIC*/

*<15; ELSE IF WHTLNGOS IN ('JAPANESE'  ) THEN WHATLANG = 13; /*JAPANESE*/

* <15; ELSE IF WHTLNGOS IN ('VIATNAMESE','VIETNAM','VIETNAMESE','VIETNAMIESE','VIETNANMESE','VIETNAMEESE')
THEN WHATLANG = 14; /*VIETNAMESE*/

ELSE IF WHTLNGOS IN ('PORTUGAL','PORTUGES','PORTUGESE','PORTUGUESE','PORTUGUESS','PORTUGUEZE','PORTUGUS') THEN
WHATLANG = 15; /*PORTUGUESE*/

*<15; ELSE IF WHTLNGOS IN ('HINDI'  ) THEN WHATLANG = 16; /*HINDI*/

ELSE IF WHTLNGOS IN ('ARABIC, FRENCH AND ITALIAN','AMHARIC AND GEEZ','AMHARIC/ETHIOPIAN','ARMENIAN AND ARABIC.',
'ARMENIAN, ARABIC','ARMINIAN AND TURKISH','BENGALI/HINDI','CAPE VERDEAN CREOLE AND PORTUGUESE',
'CAPE VERDEAN CREOLE AND PROTUGUESE','CHINESE CANTONESE ARABIC','DUTCH AND INDONESIAN','FILIPINO SPANISH',
'FRENCH GERMAN','FILIPINO TAGALOG','FILIPINO VISAYAN','FILIPINO, TAGALOG','FILIPINO0- TAGALOG',
'FRENCH NATIVE DIALECT/TOGO, WEST AFRICA','FRENCH AND CEROLE','FRENCH AND ITALIAN',
'FRENCH, ITALIAN, GERMAN & DANISH. R IS MULTI-LANGUAGE','GERMAN AND SOME SPANISH',
'GERMAN AND SOME SPANISH. AND SOME FRENCH','GERMAN, ITALIAN AND FRENCH','GREEK SPANISH JAPANESE FRENCH ITALIAN',
'GREEK,SPANISH','GUJARADI AND HINDI','GUJRATI, URDO, HINDI','HEBREW AFGHAN','HEBREW AND SPANISH','HEBREW OR YIDDISH',
'HEBREW, BASSA','HEBREW, YIDDISH','HINDI AND PUJABI.','HINDI AND PUNJABI','HINDI GUJRATI','HINDI, GUJARTI',
'HINDI, GUJRATI','HINDI, PUNJABI','HINKO/URDU','HMONG AND LAOTIAN','INDIAN, HINDI','INDONESIAN; DUTCH',
'IRABICK AND FRENCH','ITALIAN AND FRENCH','ITALIAN AND SPANISH','PIUTE AND SHONE','POLISH AND FRENCH',
'PORTUGESE AND CREOLA','PORTUGESE, CUBAN','PORTUGUESE AND SPANISH','PUMJABI HINDI','PUNJABI AND HINDI',
'RUSSIAN/UKRANIAN/POLISH','SPANISH & FRENCH','SPANISH AND FRENCH','SPANISH AND FRENCH AND SIGN LANGUANGE AND ITALIAN',
'SPANISH AND ITALIAN','SWAHILI, FRENCH','TAGALOD/ ILOKANO','TAGALOG (FILIPINO)','TAGALOG, ILICANO','TAIWANESE AND MANDARIN',
'TAIWANESE OR MANDARIN','TURKISK, GREEK AND SPANISH. IM MULTILANGUISH','UKRANIAN POLISH GERMAN','WARAY AND TALJALOG',
'YIDDISH, HEBREW, LATVIAN, RUSSIAN','TAGALOG BICOL','TAGALOG PANGASINAN')THEN WHATLANG = 90; /*MORE THEN ONE LANGUAGE/DIALECT*/

ELSE IF WHTLNGOS NOT IN ('CAJUN FRENCH','FRENCH','FRENCH CREOLE','FRENCH/CREOLE','GERMAN','GERMAN MOM IS GERMAN',
'FITALIAN','ITALIAN','ITALINA','ITIALIAN','ITILIAN','IITALIAN','ATAGLOG','TAGALO','TAGALOG','TAGLOG','TAGOLOG',
'TEGALOG','CHINESE','MANDARIN CHINESE', 'CANTONESE','CANTONESE AND MANDARIAN','CHINESE, CANOTONESS','MANDARIN',
'MANDARIN AND CANTONESE','MANDRIN','POLISH.','POLISIH',
'POLISH','KOREAN','RUSSIAN','RUSSIAN.','HE SPEAKS RUSSIAN',
'GREEK','GREAK','FILAPINO','FILIINO','FILIPINO','FILOPINO','PHILIAPHINO','PHILIPHNOIS',
'PHILIPINO','PHILLINO','PHILLIPHINE','PHILLIPINE','PHILLIPINES','PHILLIPINO','PILIPINO',
'ABABIC','ARABIC','ARABIC ...','AREBIC','VIATNAMESE','VIETNAM','VIETNAMESE','VIETNAMIESE','VIETNAMEESE'
'VIETNANMESE','PORTUGAL','PORTUGES','PORTUGESE','PORTUGUESE','PORTUGUESS','PORTUGUEZE','PORTUGUS',
'HINDI','JAPANESE','ARABIC, FRENCH AND ITALIAN','AMHARIC AND GEEZ','AMHARIC/ETHIOPIAN','ARMENIAN AND ARABIC.',
'ARMENIAN, ARABIC','ARMINIAN AND TURKISH','BENGALI/HINDI','CAPE VERDEAN CREOLE AND PORTUGUESE',
'CAPE VERDEAN CREOLE AND PROTUGUESE','CHINESE CANTONESE ARABIC','DUTCH AND INDONESIAN','FILIPINO SPANISH',
'FRENCH GERMAN','FILIPINO TAGALOG','FILIPINO VISAYAN','FILIPINO, TAGALOG','FILIPINO0- TAGALOG',
'FRENCH NATIVE DIALECT/TOGO, WEST AFRICA','FRENCH AND CEROLE','FRENCH AND ITALIAN',
'FRENCH, ITALIAN, GERMAN & DANISH. R IS MULTI-LANGUAGE','GERMAN AND SOME SPANISH',
'GERMAN AND SOME SPANISH. AND SOME FRENCH','GERMAN, ITALIAN AND FRENCH','GREEK SPANISH JAPANESE FRENCH ITALIAN',
'GREEK,SPANISH','GUJARADI AND HINDI','GUJRATI, URDO, HINDI','HEBREW AFGHAN','HEBREW AND SPANISH','HEBREW OR YIDDISH',
'HEBREW, BASSA','HEBREW, YIDDISH','HINDI AND PUJABI.','HINDI AND PUNJABI','HINDI GUJRATI','HINDI, GUJARTI',
'HINDI, GUJRATI','HINDI, PUNJABI','HINKO/URDU','HMONG AND LAOTIAN','INDIAN, HINDI','INDONESIAN; DUTCH',
'IRABICK AND FRENCH','ITALIAN AND FRENCH','ITALIAN AND SPANISH','PIUTE AND SHONE','POLISH AND FRENCH',
'PORTUGESE AND CREOLA','PORTUGESE, CUBAN','PORTUGUESE AND SPANISH','PUMJABI HINDI','PUNJABI AND HINDI',
'RUSSIAN/UKRANIAN/POLISH','SPANISH & FRENCH','SPANISH AND FRENCH','SPANISH AND FRENCH AND SIGN LANGUANGE AND ITALIAN',
'SPANISH AND ITALIAN','SWAHILI, FRENCH','TAGALOD/ ILOKANO','TAGALOG (FILIPINO)','TAGALOG, ILICANO','TAIWANESE AND MANDARIN',
'TAIWANESE OR MANDARIN','TURKISK, GREEK AND SPANISH. IM MULTILANGUISH','UKRANIAN POLISH GERMAN','WARAY AND TALJALOG',
'YIDDISH, HEBREW, LATVIAN, RUSSIAN','TAGALOG BICOL','TAGALOG PANGASINAN', ' ') THEN WHATLANG = 91;


if spngdsbl = 0 and spvarate = -8 then spvarate = .;
/****************************************************************
* Four sp's had a value of 2(NO) for spngdsbl but a value       *
*  of -8 for spvarate. The value of spvarate should be .(missing)*
*  if spngdsbl = 2.  The above line fixes this.                 *
******************************************************************/

if spvarate ne . and spngdsbl = . then spngdsbl = 1;                               

/***********************************************************************
* The new SP segments did not contain spngdsbl but did have spvarate.  *
* The line above gives the missing facility sp's with a non-missing    *
* disability rating a "YES(1)" value for spngdsbl  			           *
************************************************************************/
if spvarate = 2 then do;/*use to be 2=no this fix may not work*/
   spngdsbl = 0; 
   spvarate = .;
end;
/*************************************************************
*   A value of "2" was input to indicate NO and
*   it is not a 2 percent disability rating so above 4 lines
*   will fix this. 
*************************************************************/
if spvarate = 4 then spvarate = -8;
/***************************************************************************
*  One sp had a value of 4. It could be a typo (40 should have been input?)
*  but this will make it -8 to be safe.
****************************************************************************/ 

/*************************************************************************************
*  VA rates disability from 0% to 100% in 10% increments (e.g. 10%, 20%, 30% etc.)   *
* Veterans can have multiple disabilities with different percentages of disability.  *
* If a Veteran has a 50 percent disability and a 30 percent disability, the          *
* combined value will be found to be 65 percent (there is a table to calculate this),*
* but the 65 percent must be converted to the nearest degree divisible by 10 to		 * 
* represent the final degree of disability. Check data for any odd rates!!										 *
*                                                    								 *
**************************************************************************************/

if spvarate =  5 then spvarate = 10;
if spvarate = 15 then spvarate = 20;
if spvarate = 25 then spvarate = 30;
if spvarate = 75 then spvarate = 80;

/*******************************************************
*  spvarate should be in multiples of 10. In the data 
* we have the following:
*  spvarate     N (Number of sp's)
*   5           4
*  15           4
*  25           1
*  75           1 
*  The above lines recode them to the nearest 10%.
******************************************************/
/*this code switches all '0' responses to '2' for yes no variables*/
array switch{*} hisporig spngall spngever spngdsbl /*raceas raceaa racenh racewh raceai raceoth*/ ; 
 do i = 1 to dim(switch);
  if switch(i) = 0 then switch(i)=2;
  end;
run;

proc freq data=MCBSDATA.totalmil;
tables engw19 othr19 what19 engwell othrlang whtlngos*whatlang/missing;
title 'English_ALL';
run;
	
/*As of 2015 RIC 1 and RIC A will be combined to create a demographics file
pull in the Admin vars to be included in the DEMO file here*/ 
Data RICA_2020(keep= baseid H_SEX H_RACE D_STRAT H_DOB H_DOD H_AGE H_DODSRC H_CENSUS H_RESST H_RESCTY 
H_ZIP H_LAF H_CBSA H_RUCA H_RUCA1 H_RUCA2 H_RTIRCE);
set RICA.aprelim20final_15476; *update*; 

/*New RUCA variables for 2017*/ 
 if H_RUCA1 = 1.1 then H_RUCA1= 1;
 if H_RUCA1 = 2.1 then H_RUCA1= 2;
 if H_RUCA1 = 4.1 then H_RUCA1= 4;
 if H_RUCA1 = 5.1 then H_RUCA1= 5;
 if H_RUCA1 in (7.1,7.2) then H_RUCA1= 7;
 if H_RUCA1 in (8.1,8.2) then H_RUCA1= 8;
 if H_RUCA1 in (10.1,10.2,10.3) then H_RUCA1= 10;
 run; 
 PROC SORT data=RICA_2020; 
BY BASEID;  
run; 

	  /****use rica to find state for facility sp's ****/ 
data RICA_STATE (keep= baseid H_RESST);
set RICA.aprelim20final_15476;   /*--NAME of FILE -- update*/  
    
run; 
 PROC SORT data=RICA_STATE; 
BY BASEID;  
run;      
   

/*INCOME*/
                                     
	/*UPDATE INCOME SECTION*/                                                                       
       DATA INCOME(KEEP=BASEID income_h1 INCOME_H INCSRCE INCOME);                                     
        SET INC.R90_DLV ; *update round ;             
         BY BASEID;                                          
   INCOME_H1 = INC20YR; /** update year **/ 
   INCSRCE = INC20Y_I; 

   /*2020 round income_h to the nearest dollar*/
	INCOME_H= round(income_h1,1);

  /*2020 Expanded income categories*/
   IF INCOME_H >= 140000 THEN INCOME=14;
   ELSE IF INCOME_H >= 120000 THEN INCOME=13;
   ELSE IF INCOME_H >= 100000 THEN INCOME=12;
   ELSE IF INCOME_H >= 80000 THEN INCOME=11;
   ELSE IF INCOME_H >= 60000 THEN INCOME=10;	
   ELSE IF INCOME_H >= 50000 THEN INCOME=9;                    
   ELSE IF INCOME_H >= 40000 THEN INCOME=8;                     
   ELSE IF INCOME_H >= 30000 THEN INCOME=7;                      
   ELSE IF INCOME_H >= 25000 THEN INCOME=6;                      
   ELSE IF INCOME_H >= 20000 THEN INCOME=5;                      
   ELSE IF INCOME_H >= 15000 THEN INCOME=4;                      
   ELSE IF INCOME_H >= 10000 THEN INCOME=3;                      
   ELSE IF INCOME_H >=  5000 THEN INCOME=2;                      
   ELSE IF INCOME_H >=    0 THEN INCOME=1;
	run;
                                                                        
                                                                                
/*As of 2016--ADI is now included in HOME segment*/ 
/*As of 2018 ADI is census block based*/
data ADI2020 (keep=baseid ADINATNL ADISTATE) ;
set c88.home;
proc sort; by baseid;
run;


/*As of 2016--IPR is now included in I&A*/ 

/*IPR is already processed by NORC so we do not need to run the code below. Have left in it so we can see what 
the process was and how IPR_IND was constructed.*/

/*Beginning in 2020 added the continuous variable IPR to the file and retired IPR_IND*/
/*Applied format to IPR so that researchers would have same categorical breakouts as IPR_IND*/

data IPR2020 (keep = baseid IPR IPR_IND IPRHSIZE IPRTHRSH INC20YR);
set IPR.r90_dlv;
proc sort; by baseid;
run;

/*data IPR2020_2 (keep= baseid h_age IPR IPR_IND IPRHSIZE IPRTHRSH INC20YR);
merge RICA_2020 IPR2020;
by baseid;*/
***********************  IPR THRESHOLDS: UPDATE for 2019   ***********************
*     Poverty thresholds obtained from CMS
*     https://www.medicaid.gov/federal-policy-guidance/index.html  
*     https://www.medicaid.gov/sites/default/files/federal-policy-guidance/downloads/cib030618.pdf
	  https://www.medicaid.gov/federal-policy-guidance/downloads/cib021119.pdf
*           Does not distinguish between over or under aged 65 for Medicare recipients
*For 2020 https://www.medicaid.gov/federal-policy-guidance/downloads/cib020320.pdf;

/**11/5/2021 thresholds need to be updated***/
*%let UND65HH1 = 12732; /* monthly $1,061*12 */
*%let OVR65HH1 = 12732; 
*%let UND65HH2 = 17160; /* monthly $1,430 *12 */
*%let OVR65HH2 = 17160;

/*if     H_AGE >= 65 and IPRHSIZE = 1 then IPRTHRSH = &OVR65HH1.;
else if H_AGE >= 65 and IPRHSIZE = 2 then IPRTHRSH = &OVR65HH2.;
else if H_AGE <  65 and IPRHSIZE = 1 then IPRTHRSH = &UND65HH1.;
else if H_AGE <  65 and IPRHSIZE = 2 then IPRTHRSH = &UND65HH2.;

IPR = INC20YR / IPRTHRSH;*/

*if     0.00 <= IPR <= 1.00 then IPR_IND = 1;  /*  100% FPL + $20   */
*else if 1.00 <  IPR <= 1.20 then IPR_IND = 2; /*  120% FPL + $20   */
*else if 1.20 <  IPR <= 1.35 then IPR_IND = 3; /*  135% FPL + $20   */
*else if 1.35 <  IPR <= 2.00 then IPR_IND = 4; /*  200% FPL + $20   */
*else if 2.00 <  IPR         then IPR_IND = 5;   
*run;


data mcbsdata.tmpdata (KEEP= BASEID PANEL INT_TYPE DOBtmp DODtmp ROSTSEX spafever spafviet spafkore spafwwii spafgulf   
       spafiraf spafpeac spNGEVER spngall spngdsbl spvarate 
       D_RACE2 HISPORIG SPCHNLNM SPDEGRCV SPMARSTA INCOME_H INCSRCE INCOME
	   RACEAS RACEAA RACENH RACEWH RACEAI       
       HISPORMA HISPORPR HISPORCU HISPOROT
       RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO RACEASVI 
	   RACEASOT RACEPIHA RACEPIGU RACEPISA
       RACEPIOT ENGREAD ENGWELL OTHRLANG WHATLANG HHPWORK JOBSTAT H_SEX H_RACE 
	   D_STRAT H_DOB H_DOD H_DODSRC H_AGE H_CENSUS H_RESST H_RESCTY 
	   H_ZIP H_LAF  H_CBSA H_RUCA H_RUCA1 H_RUCA2 H_RTIRCE ADINATNL ADISTATE /*IPR_IND*/ IPR engw19 othr19 what19
	   /*added in 2017*/ SPSDTH);
merge cut (in=a)income gender ed_mar MCBSDATA.totalmil RICA_2020 adi2020 ipr2020 SPDIED_3;  by baseid;
if a;

more = raceas + raceaa + racenh + racewh + raceai/* + raceoth*/;
if more = 1 and raceai=1 then d_race2=5; else /*american indian*/
if more = 1 and racenh=1 then d_race2=3; else /*native hawaiian or pac islander*/
if more = 1 and raceas=1 then d_race2=1; else /*asian*/
if more = 1 and raceaa=1 then d_race2=2; else /*black*/
if more = 1 and racewh=1 then d_race2=4; else /*white*/
if more > 1 then d_race2 = 7; else         /*more than 1*/
if more < 6 and raceas=-8 or raceaa=-8 or racenh=-8 or
  racewh=-8 or raceai=-8 then d_race2=-8; else
if more < 6 and raceas=-9 or raceaa=-9 or racenh=-9 or
  racewh=-9 or raceai=-9 then d_race2=-9; else
if more < 6 and raceas=-7 or raceaa=-7 or racenh=-7 or
  racewh=-7 or raceai=-7 then d_race2=-7; else
if more = 0 then d_race2= -8;

if jobstat = -8 then jobstat = .D;
if jobstat = -7 then jobstat = .R;
if jobstat = -9 then jobstat = .N;

/*2016 Edit to HHPWORK and JOBSTAT -- need to include HHPWORK responses 
in JOBSTAT and also add new catgegory for facility then drop HHPWORK*/
if HHPWORK= 1 then JOBSTAT= 1;
if HHPWORK=2 then JOBSTAT=2;
if HHPWORK=.d then JOBSTAT=.d;
if HHPWORK=.R then JOBSTAT= .R;
if INT_TYPE='F' then JOBSTAT=3;
***For 2017 make sure if HHPWORK= 1 then JOBSTAT= 1***;

if income = 0 then income = 1;
if INCOME = -8 then INCOME= .D;
if INCOME = -7 then INCOME=.R;
if SPDEGRCV = -8 then SPDEGRCV=.D;
if SPDEGRCV = -7 then SPDEGRCV=.R;
if SPDEGRCV = -9 then SPDEGRCV=.N;
if SPCHNLNM =-8 then SPCHNLNM  =.D;
if SPCHNLNM =-7 then SPCHNLNM  =.R;
if spafever= -8 then spafever = .D;
if spafever= -7 then spafever = .R;
if spafviet= -8 then spafviet = .D;
if spafkore= -8 then spafkore = .D;
if spafwwii= -8 then spafwwii = .D;
if spafgulf= -8 then spafgulf = .D;
if spafiraf= -8 then spafiraf = .D;
if spafpeac= -8 then spafpeac = .D;
if spNGEVER= -8 then spNGEVER = .D;
if SPNGDSBL= -8 then SPNGDSBL = .D;
if spvarate= -8 then spvarate = .D;
if D_RACE2= -8 then D_RACE2 = .D;
if D_RACE2= -7 then D_RACE2 = .R;
if HISPORIG= -8 then HISPORIG = .D;
if spmarsta= -8 then spmarsta = .D;
if spmarsta= -7 then spmarsta = .R;
if RACEAS= -8 then RACEAS = .D;
if RACEAS= -7 then RACEAS = .R;
if RACEAA= -8 then RACEAA = .D;
if RACEAA= -7 then RACEAA = .R;
if RACENH= -8 then RACENH = .D;
if RACENH= -7 then RACENH = .R;
if RACEWH= -8 then RACEWH = .D;
if RACEWH= -7 then RACEWH = .R;
if RACEAI= -8 then RACEAI = .D;
if RACEAI= -7 then RACEAI = .R;
if HISPORMA= -8 then HISPORMA= .D;
if HISPORPR= -8 then HISPORPR= .D;
if HISPORCU= -8 then HISPORCU= .D;
if HISPOROT= -8 then HISPOROT= .D;
if baseid = '01723579' then D_DOB = '198003';
/*2016 edits to .E*/
if SPVARATE = .E then SPVARATE = .;

/*fix for baseids that said no for SPNGDSBL but had an applicable SPVARATE*/
if baseid in ('01552953','01587640','01587991','01590929','01601397','01643563',
'01599215', '01565367') 
then SPVARATE = .;

/*EDIT for Disability rating*/
if spngdsbl= 1 and spvarate=. then spvarate=.d;

/*Edit to change 6 baseids with missing HISPOROT to .D*/
if baseid in ('01698773', '01694551', '01697207', '01690759', '01662651', '01650315')
then HISPOROT = .D;

/*Edit to change 3 baseids with missing to 0*/
if baseid in ('01728392', '01597182', '01564249')
then RACEPIOT = 0;

/*Edit for 4 baseids where HISPORIG is not indicated but extended race vars are applicable*/
if baseid in ('01571938','01595968','01647365','01747032') then HISPOROT = .;
if baseid in ('01571938','01595968','01647365','01747032') then HISPORMA = .;
if baseid in ('01571938','01595968','01647365','01747032') then HISPORPR = .;
if baseid in ('01571938','01595968','01647365','01747032') then HISPORCU = .;

/*Edit for 2 baseids where RACENH is not indicated but extended race vars are applicable*/
if baseid in ('01564249','01728392') then RACEPIHA = .;
if baseid in ('01564249','01728392') then RACEPIGU = .;
if baseid in ('01564249','01728392') then RACEPISA = .;
if baseid in ('01564249','01728392') then RACEPIOT = .;

/*EDIT for baseids that had data for JOBSTAT but kept showing up as missing*/
if baseid in ('01567600', '01614999','01519772', '01495003', '01410424') then jobstat = 1;

/*change D_DOB and D_DOD character date to SAS date*/
rename d_dob = dobtmp;
rename d_dod = dodtmp;

/*2016 fix to change H_DODSRC from '.' to ''*/
if H_DODSRC = . then H_DODSRC = '';

/*2018 edit for 1 baseid where SPAFKORE = 1 in 2017 and SPAFKORE = D in 2018 -- should equal 1*/
if baseid = '01937401' then SPAFKORE= 1; 

/*2018 edit for SPSDTH*/
if int_type in ('F', ' ') then SPSDTH = .;

/*EDIT for WHATLANG that are less than 15*/
If WHATLANG in (13,14) then WHATLANG = 91;


run;


data finaldata (keep =  SURVEYYR VERSION BASEID PANEL INT_TYPE D_DOB D_DOD H_AGE 
		ROSTSEX spafever spafviet spafkore spafwwii spafgulf   
       	spafiraf spafpeac spNGEVER spngall spngdsbl spvarate 
       	D_RACE2 HISPORIG SPCHNLNM SPDEGRCV SPMARSTA SPSDTH INCOME INCOME_H   
       	INCSRCE RACEAS RACEAA RACENH RACEWH RACEAI       
       	HISPORMA HISPORPR HISPORCU HISPOROT
      	RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO RACEASVI 
	   	RACEASOT RACEPIHA RACEPIGU RACEPISA
       	RACEPIOT ENGWELL ENGREAD OTHRLANG WHATLANG JOBSTAT H_SEX H_RACE 
	   	D_STRAT H_DOB H_DOD H_DODSRC SURVIVEA SURVIVES SURVIVE H_CENSUS H_RESST H_RESCTY 
	   	H_ZIP H_LAF H_CBSA H_RUCA H_RUCA1 H_RUCA2 H_RTIRCE ADINATNL ADISTATE /*IPR_IND*/ IPR );
set mcbsdata.tmpdata;

Version=1;

SURVEYYR=2020;

format baseid $8.;

/*Create Survive Indicator*/

d_dob = input(dobtmp,yymmn6.);
d_dod = input(dodtmp,yymmn6.);
format d_dod d_dob yymmn6.;

  IF H_DOD = '        ' OR H_DOD GT 12312020 THEN /*UPDATE DATE*/
    SURVIVEA = 'Y'; ELSE SURVIVEA = 'N'; 

  IF D_DOD = '       ' OR D_DOD GT '31DEC2020'd /*UPDATE DATE*/
  THEN SURVIVES = 'Y'; ELSE SURVIVES = 'N'; 

  if SURVIVEA = 'Y' and SURVIVES = 'Y' then SURVIVE = 'Y'; 
  else if SURVIVEA = 'Y' and SURVIVES = 'N' then SURVIVE = 'N';
  else if SURVIVEA = 'N' and SURVIVES = 'Y' then SURVIVE = 'N';
  else SURVIVE = 'N';
  proc sort; by baseid;
   run;

 /*Output to SAS file and use Retain statement so variables are in proper order*/
 
DATA MCBSDATA.DEMO1;
RETAIN 
   	BASEID SURVEYYR VERSION PANEL INT_TYPE D_DOB D_STRAT H_DOB D_DOD
   	H_DOD H_DODSRC SURVIVE H_AGE ROSTSEX H_SEX D_RACE2
   	H_RACE H_RTIRCE HISPORIG HISPORMA HISPORPR HISPORCU  
   	HISPOROT RACEAS RACEASAI RACEASCH RACEASFI RACEASJA      
   	RACEASKO RACEASVI RACEASOT RACEAA RACENH RACEPIHA     
   	RACEPIGU RACEPISA RACEPIOT RACEWH RACEAI  
   	ENGWELL ENGREAD OTHRLANG WHATLANG SPDEGRCV SPCHNLNM  
   	SPMARSTA SPSDTH JOBSTAT INCOME_H INCSRCE INCOME
   	SPAFEVER SPAFVIET SPAFKORE SPAFWWII SPAFGULF    
   	SPAFIRAF SPAFPEAC SPNGEVER SPNGALL SPNGDSBL SPVARATE  
    H_CENSUS H_RESST H_RESCTY H_ZIP H_LAF 
    H_CBSA H_RUCA H_RUCA1 H_RUCA2 ADINATNL ADISTATE /*IPR_IND*/ IPR ;

	SET FINALDATA;

  KEEP   BASEID SURVEYYR VERSION PANEL INT_TYPE D_DOB D_STRAT H_DOB D_DOD
   H_DOD H_DODSRC SURVIVE H_AGE ROSTSEX H_SEX D_RACE2
   H_RACE H_RTIRCE HISPORIG HISPORMA HISPORPR HISPORCU  
   HISPOROT RACEAS RACEASAI RACEASCH RACEASFI RACEASJA      
   RACEASKO RACEASVI RACEASOT RACEAA RACENH RACEPIHA     
   RACEPIGU RACEPISA RACEPIOT RACEWH RACEAI  
   ENGWELL ENGREAD OTHRLANG WHATLANG SPDEGRCV SPCHNLNM  
   SPMARSTA SPSDTH JOBSTAT INCOME_H INCSRCE INCOME
   SPAFEVER SPAFVIET SPAFKORE SPAFWWII SPAFGULF    
   SPAFIRAF SPAFPEAC SPNGEVER SPNGALL SPNGDSBL SPVARATE  
    H_CENSUS H_RESST H_RESCTY H_ZIP H_LAF 
   H_CBSA H_RUCA H_RUCA1 H_RUCA2 ADINATNL ADISTATE /*IPR_IND*/ IPR ;


  FORMAT   BASEID SURVEYYR VERSION PANEL INT_TYPE D_DOB D_STRAT H_DOB D_DOD
   H_DOD H_DODSRC SURVIVE H_AGE ROSTSEX H_SEX D_RACE2
   H_RACE H_RTIRCE HISPORIG HISPORMA HISPORPR HISPORCU  
   HISPOROT RACEAS RACEASAI RACEASCH RACEASFI RACEASJA      
   RACEASKO RACEASVI RACEASOT RACEAA RACENH RACEPIHA     
   RACEPIGU RACEPISA RACEPIOT RACEWH RACEAI  
   ENGWELL  ENGREAD OTHRLANG WHATLANG SPDEGRCV SPCHNLNM  
   SPMARSTA SPSDTH JOBSTAT INCOME_H INCSRCE INCOME
   SPAFEVER SPAFVIET SPAFKORE SPAFWWII SPAFGULF    
   SPAFIRAF SPAFPEAC SPNGEVER SPNGALL SPNGDSBL SPVARATE  
    H_CENSUS H_RESST H_RESCTY H_ZIP H_LAF 
   H_CBSA H_RUCA H_RUCA1 H_RUCA2 ADINATNL ADISTATE /*IPR_IND*/ IPR ;

   RUN;


Data mcbsdata.DEMO2;
set mcbsdata.DEMO1;
	/*Apply formats*/

FORMAT
     BASEID   $BSIDFMT.
	 SURVEYYR SVYRFMT.
	 PANEL SVYRFMT.
     VERSION VERSFMT.
	 INT_TYPE  $TYPEFMT.
     D_DOB    D_DOD yymmn6.
     SPVARATE VADISFMT.
     ROSTSEX  SEXFMT.
	 H_AGE AGEFMT.
	 D_STRAT SAGEFMT.
     D_RACE2  RACE2FMT.
     SPMARSTA MARFMT.
	 SPSDTH SPSDIED.
     INCOME   INCOFMT.
	 INCOME_H MONYFMT.
     INCSRCE  IMPFLAG.
     SPCHNLNM CHILDFMT.
	 SPDEGRCV DEGREFMT.
	 ENGREAD ENGWELL  HOWWELL.
	 WHATLANG WHTLANG.
     RACEAS   RACEAA   RACENH   RACEWH   RACEAI     
     SPAFEVER SPAFVIET SPAFKORE SPAFWWII
     SPAFPEAC SPAFGULF SPAFIRAF
     HISPORMA HISPORPR HISPORCU HISPOROT
     RACEASAI RACEASCH RACEASFI RACEASJA RACEASKO RACEASVI RACEASOT
     RACEPIOT RACEPIHA RACEPIGU RACEPISA RACEPIOT IND1FMT.
	 OTHRLANG  HISPORIG SPNGALL  SPNGDSBL 
     SPNGEVER YES1FMT.
	 JOBSTAT YESNOJOB. 
	 H_DOB H_DOD MMDDYYn8. 
	 H_DODSRC $SRCFMT.
	 H_SEX $SEXFMT. 
	 H_RACE $RACEFMT.
	 H_CENSUS $CENFMT.
	 H_RESST $STFMT. 
	 H_RESCTY $CTYFMT.
	 H_ZIP $ZIPFMT. 
	 H_LAF $LAFFMT. 
 	 SURVIVE $SURVFMT.
	 H_CBSA $URBRUR.
     H_RUCA $RUCA.
	 H_RUCA1 RUCA.
     H_RUCA2 $RUCACD.
     H_RTIRCE $RACEFMT.
	 ADINATNL ADINFMT.
	 ADISTATE ADISFMT.  
     /*IPR_IND IPRIND.*/
	 IPR IPRCNFMT.;

  /*variable labels here*/

  LABEL
            BASEID   = "Unique SP Identification Number"
			VERSION  = "Version Number"
			SURVEYYR = "Survey Year"
			PANEL    = "Sample Year"
			INT_TYPE = "Type of Interview"
            D_DOB    = "Date of birth (YYYYMM)"
			D_STRAT  = "MCBS Sample age stratum"
			H_DOB    = "Date of birth(Admin)"
			D_DOD    = "Date of death (YYYYMM)"
			H_DOD    = "Date of death(Admin)"
			H_DODSRC = "Source of date of death "
			H_AGE    = "Age of bene."
			SURVIVE  = "Survival indicator"
			ROSTSEX  = "Gender of SP"
			H_SEX    = "Sex code(Admin)"
			H_RACE   = "Race code(Admin)"
			D_RACE2  = "Race of SP"
			HISPORIG = "Is SP of Hispanic or Latino origin?"
			HISPORMA = "SP  is Mexican/Mex American/Chicano"
            HISPORPR = "SP is Puerto Rican"
            HISPORCU = "SP is Cuban"
            HISPOROT = "SP is oth Hispanic/Latino/Spanish Origin"
			RACEAS   = "Is SP Asian?"
			RACEASAI = "SP is Asian Indian"
            RACEASCH = "SP is Chinese"
            RACEASFI = "SP is Filipino"
            RACEASJA = "SP is Japanese"
            RACEASKO = "SP is Korean"
            RACEASVI = "SP is Vietnamese"
            RACEASOT = "SP is Other Asian"
			RACEAA   = "Is SP Black or African-American?"
			RACENH   = "Is SP Native Hawaiian/Pacific Islander?"
			RACEPIHA = "SP is Native Hawaiian"
            RACEPIGU = "SP is Guamanian Chamorro"
            RACEPISA = "SP is Samoan"
            RACEPIOT = "SP is Other Pacific Islander"
            RACEWH   = "Is SP Caucasian?"
			RACEAI   = "Is SP American Indian or Alaska Native?"
            ENGWELL  = "How well does SP speak English?"
			ENGREAD  = "How well does SP read English?"
			OTHRLANG = "Language oth than English spoken at home"
			WHATLANG = "What language spoken at home"
            SPDEGRCV = "Highest grade SP completed"
			SPCHNLNM = "Number of children living"
            SPMARSTA = "Marital status of SP"
			SPSDTH   = "SP's spouse died within the last year"
			JOBSTAT  = "Is SP or spouse currently working at job"
			INCOME_H = "SP and spouse total income last year"  
			INCOME   = "Income range of SP and spouse"
            INCSRCE  = "Source of SP and spouse income data"
			SPAFEVER = "SP ever served in armed forces (AF)?"
			SPAFVIET = "SP served in AF during Vietnam era?"
            SPAFKORE = "SP served in AF during Korean conflict?"
			SPAFWWII = "SP served in AF during World War II?"
			SPAFGULF = "SP served in AF during gulf  war?"
			SPAFIRAF = "SP served in AF during Iraq/Af conflict?"
            SPAFPEAC = "SP served in AF during peace time?"
			SPNGEVER = "SP ever active Nat'l Guard/Reserve?"
            SPNGALL  = "All active duty spent in Nat'l Guard?"
            SPNGDSBL = "Does SP have disability from service?"
            SPVARATE = "Current VA disability rating"
			H_CENSUS = "Census Region of residence as of 12/31"
			H_RESST  = "SSA State code of residence as of 12/31"
			H_RESCTY = "SSA county code of residence as of 12/31"
			H_ZIP    = "Postal zip code of residence as of 12/31"
			H_LAF    = "Status of SSA check (LAF) as of 12/31"
			H_CBSA = "Type of CBSA as designated by CBSA"
			H_RUCA = "Urban/Rural RUCA designation"
			H_RUCA1 = "Primary RUCA Code"
			H_RUCA2 = "Primary and Secondary RUCA Code"
			H_RTIRCE = "RTI Race Code"
			ADINATNL = "ADI based on Census Block Grp Ntl pct"
			ADISTATE = "ADI based on Census Block Grp ST decile"
			/*IPR_IND = "Income Poverty Ratio Medicare Threshold"*/
			IPR = "Income Poverty Ratio Medicare Threshold";
  run;
	
Proc contents data=mcbsdata.DEMO2;
   run;

   proc freq data=mcbsdata.DEMO2;
tables SURVEYYR VERSION PANEL INT_TYPE D_DOB D_STRAT H_DOB D_DOD H_DOD H_DODSRC  
       SURVIVE H_AGE ROSTSEX H_SEX D_RACE2 H_RACE H_RTIRCE HISPORIG HISPORMA HISPORPR  
   	   HISPORCU HISPOROT RACEAS RACEASAI RACEASCH RACEASFI     
	   RACEASJA RACEASKO RACEASVI RACEASOT RACEAA RACENH        
	   RACEPIHA RACEPIGU RACEPISA RACEPIOT RACEWH RACEAI     
   	   ENGWELL ENGREAD OTHRLANG WHATLANG SPDEGRCV SPCHNLNM  
   	   SPMARSTA SPSDTH JOBSTAT INCOME_H INCOME    
       INCSRCE  spafever spafviet 
   	   spafkore spafwwii spafgulf spafiraf spafpeac spNGEVER spngall   
   	   spngdsbl spvarate H_CENSUS H_RESST H_RESCTY 
	   H_ZIP H_LAF H_CBSA H_RUCA H_RUCA1 H_RUCA2 ADINATNL ADISTATE 
	   /*IPR_IND*/ IPR /missing;
	   tables H_RACE*H_RTIRCE*D_RACE2*HISPORIG/list missing;
	   title 'DEMO ';  
   run;

   data mcbsdata.DEMO;
   set mcbsdata.DEMO2;
   run;

   PROC SORT data=mcbsdata.DEMO; BY BASEID; RUN;
/* While the data is already sorted from previous step, this SORT is needed to force PROC CONTENTS to say SORTED:YES */

   data mcbsdata.DEMO_unfmt;
   set mcbsdata.DEMO1;
	format _all_;
 	format H_DOB H_DOD mmddyyn8.;
	format D_DOB D_DOD YYMMn6.;
run;


   ********************Remove variable labels******************;
proc datasets library=mcbsdata nolist;
  modify DEMO_unfmt;
  attrib _all_ label='';
quit;


   /*Create CSV file*/

PROC EXPORT DATA= MCBSDATA.DEMO_unfmt
     		OUTFILE= "Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Data Processing\Demo\demo.csv" 
     		DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

