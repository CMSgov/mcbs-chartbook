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

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear =20;
%let LastYear =19;

%let trimqty= if qnty>=5000 then qnty=.;**trims outlier PDE quanties;

%let location = C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%let loc_last = C:\Users\S1C3\RIC PME\MCBS\20&LASTYEAR.\PME\DATA\;
libname  MCBSDATA "&location";
LIBNAME  MCBSLAST "&loc_last";
*libname  COST 'Y:\Share\IPG\DSMA\MCBS\MCBS Cost Supplement File\20&CURRYEAR.\Data\SAS Files';
libname cost 'Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2020\Data\SAS Files';
*LIBNAME fmts 'Y:\Share\IPG\DSMA\MCBS\MCBS Codebook Production\Formats\20&CURRYEAR._Formats';
LIBNAME fmts 'Y:\Share\SMAG\MCBS\MCBS Codebook Production\Formats\2020 Formats';
options fmtsearch=(fmts);

OPTIONS NOFMTERR;

ods rtf file="&location.PUF 20&CurrYear output - %sysfunc(DATE(),mmddyyd10.).rtf";


/*Population of Cost*/
data X (keep = baseid);
   set COST.csevwgts;
proc sort;  by baseid;  
run;

/*Gap days file*/
data GAP20;
set mcbsdata.gapdays_20&curryear;  
proc sort; by baseid;  
run;


data a;
   merge X (in=a) /*2020 population*/
         GAP20 (in=b);
      by baseid;
   if a;
run;

/*OLD Ghost_donor code from 2013 -- beginning in 2015 we no longer needed to pull in ghosts
Data a;
   merge ghostxwalk (in=a) 
         donorxwalk 
         mcbsdata.gap_days_&curryear (in=b);
      by baseid;
   if a;
run;*/

data ghosts; /*We no longer pull in ghosts/donors but kept this data set name for ease*/
   set a;
   if baseid ne '       ';
run;


data trimm&curryear._caid_fac_clean     outliers_fac; *cleans up the variable names from Chris's file;
   set mcbsdata.trimm&curryear._caid_fac;
   y1=y1_p;
   y2=y2_p;
   y3=y3_p;
   y4=y4_p;
   y5=y5_p;
   y6=y6_p;
   y7=y7_p;
   y8=y8_p;
   y9=sum(y9_p,y10_p,y11_p);  *roll up the PDP and MAPD into Medicare;
   yplus=yplus_p; 
   fy1=fy1_p;
   fy2=fy2_p;
   fy3=fy3_p;
   fy4=fy4_p;
   fy5=fy5_p;
   fy6=fy6_p;
   fy7=fy7_p;
   fy8=fy8_p;
   if fy9_p=1 or fy10_p=1 or fy11_p=1 then fy9=1;
     else fy9=0;
   fyplus=fyplus_p;
   fd1=fd1_p;
   fd2=fd2_p;
   fd3=fd3_p;
   fd4=fd4_p;
   fd5=fd5_p;
   fd6=fd6_p;
   fd7=fd7_p;
   fd8=fd8_p;
   if fd9_p=1 or fd10_p=1 or fd11_p=1 then fd9=1;
     else fd9=0;
   *fdplus=fdplus_p;
	drop y1_p y2_p y3_p y4_p y5_p y6_p y7_p y8_p y9_p y10_p y11_p yplus_p
         fy1_p fy2_p fy3_p fy4_p fy5_p fy6_p fy7_p fy8_p fy9_p fy10_p fy11_p fyplus_p othermedical
		 fd1_p fd2_p fd3_p fd4_p fd5_p fd6_p fd7_p fd8_p fd9_p fd10_p fd11_p;* fdplus_p;

if delta1=1 then do;
	   mdri=y1*.24100;
	   fy1=fy1+1;                         *added by Andy for Cost 07 to;
	   y1=y1*(1-.24100);                  * perform Medicaid adjustment;
	   yplus=yplus-mdri;
	   fyplus=fyplus+1;
	   yplus=round(yplus,.01);
	   y1=round(y1,.01);
end;
   if otcleg='I' then otcleg='F';
  /*2015 if pmform=' .' then pmform='  ';*/
   if thercc='  ' then thercc='UN';
   rx_date=datepart(serv_dt);
   format rx_date mmddyyn8.;


***fix PDE costs;
diff= abs(YPLUS - sum(Y9,Y1,Y5,Y5B,Y7,Y2,Y6,YU,Y3,Y8,Y4) );

if diff>0.01 and PDE_FLAG in ('PDE Only   ','Survey/PDE ')  then 
do;
 totaltemp=sum(Y9,Y1,Y5,Y5B,Y7,Y2,Y6,YU,Y3,Y8,Y4);

 Y9  = round(YPLUS  * (Y9  / totaltemp),.01);
 Y1  = round(YPLUS  * (Y1  / totaltemp),.01);
 Y5  = round(YPLUS  * (Y5  / totaltemp),.01);
 Y5B = round(YPLUS  * (Y5B / totaltemp),.01);
 Y7  = round(YPLUS  * (Y7  / totaltemp),.01);
 Y2  = round(YPLUS  * (Y2  / totaltemp),.01);
 Y6  = round(YPLUS  * (Y6  / totaltemp),.01);
 YU  = round(YPLUS  * (YU  / totaltemp),.01);
 Y3  = round(YPLUS  * (Y3  / totaltemp),.01);
 Y8  = round(YPLUS  * (Y8  / totaltemp),.01);
 Y4  = round(YPLUS  * (Y4  / totaltemp),.01);
end;

drop diff totaltemp;

***trim outlier PDE quantities;
&trimqty;;


if pde_flag='Survey Only' and yplus>10000 then output outliers_fac;                                       
   else output trimm&curryear._caid_fac_clean;       * added by Andy for Cost 07 to remove;
                                         *crazy survey reported outliers;

run;


data trimm&curryear._caid_comm_clean outliers; *cleans up the variable names from Chris's file;
   set mcbsdata.trimm&curryear._caid_comm;
   /*fix for 2012 and 2013*/
   if FDB_BN='NAGLAZYME' then delete;
   y1=y1_p;
   y2=y2_p;
   y3=y3_p;
   y4=y4_p;
   y5=y5_p;
   y6=y6_p;
   y7=y7_p;
   y8=y8_p;
   y9=sum(y9_p,y10_p,y11_p); *roll up the PDP and MAPD into Medicare;
   yplus=yplus_p; 
   fy1=fy1_p;
   fy2=fy2_p;
   fy3=fy3_p;
   fy4=fy4_p;
   fy5=fy5_p;
   fy6=fy6_p;
   fy7=fy7_p;
   fy8=fy8_p;
   if fy9_p=1 or fy10_p=1 or fy11_p=1 then fy9=1;
     else fy9=0;
   fyplus=fyplus_p;
   fd1=fd1_p;
   fd2=fd2_p;
   fd3=fd3_p;
   fd4=fd4_p;
   fd5=fd5_p;
   fd6=fd6_p;
   fd7=fd7_p;
   fd8=fd8_p;
   if fd9_p=1 or fd10_p=1 or fd11_p=1 then fd9=1;
     else fd9=0;
  * fdplus=fdplus_p;
	drop y1_p y2_p y3_p y4_p y5_p y6_p y7_p y8_p y9_p y10_p y11_p yplus_p
         fy1_p fy2_p fy3_p fy4_p fy5_p fy6_p fy7_p fy8_p fy9_p fy10_p fy11_p fyplus_p othermedical
		 fd1_p fd2_p fd3_p fd4_p fd5_p fd6_p fd7_p fd8_p fd9_p fd10_p fd11_p;* fdplus_p;

    if delta1=1 then do;
	   mdri=y1*.24100;
	   fy1=fy1+1;                         *added by Andy for Cost 07 to;
	   y1=y1*(1-.24100);                  * perform Medicaid adjustment;
	   yplus=yplus-mdri;
	   fyplus=fyplus+1;
	   yplus=round(yplus,.01);
	   y1=round(y1,.01);
	end;
   if otcleg='I' then otcleg='F';
  /*2015 if pmform=' .' then pmform='  ';*/
   if thercc='  ' then thercc='UN';
   rx_date=datepart(serv_dt);
   format rx_date mmddyyn8.;

***fix PDE costs;
diff= abs(YPLUS - sum(Y9,Y1,Y5,Y5B,Y7,Y2,Y6,YU,Y3,Y8,Y4) );

if diff>0.01 and PDE_FLAG in ('PDE Only   ','Survey/PDE ')  then 
do;
 totaltemp=sum(Y9,Y1,Y5,Y5B,Y7,Y2,Y6,YU,Y3,Y8,Y4);

 Y9  = round(YPLUS  * (Y9  / totaltemp),.01);
 Y1  = round(YPLUS  * (Y1  / totaltemp),.01);
 Y5  = round(YPLUS  * (Y5  / totaltemp),.01);
 Y5B = round(YPLUS  * (Y5B / totaltemp),.01);
 Y7  = round(YPLUS  * (Y7  / totaltemp),.01);
 Y2  = round(YPLUS  * (Y2  / totaltemp),.01);
 Y6  = round(YPLUS  * (Y6  / totaltemp),.01);
 YU  = round(YPLUS  * (YU  / totaltemp),.01);
 Y3  = round(YPLUS  * (Y3  / totaltemp),.01);
 Y8  = round(YPLUS  * (Y8  / totaltemp),.01);
 Y4  = round(YPLUS  * (Y4  / totaltemp),.01);
end;

drop diff totaltemp;

***trim outlier PDE quantities;
&trimqty;;

if pde_flag='Survey Only' and yplus>10000 then output outliers;                                       
   else output trimm&curryear._caid_comm_clean;       * added by Andy for Cost 07 to remove;
                                         *crazy survey reported outliers;
run;

data all;/*update for 2018 to include facility*/
set trimm&curryear._caid_comm_clean
       trimm&curryear._caid_fac_clean;
proc sort; 
by baseid; 
run;

data surveyonlydrugs;
   set all /*trimm&curryear._caid_comm_clean*/; /*update for 2018 to include facility*/
   *if pde_flag='Survey Only'; /*update for 2018 to include facility*/
 run;
proc summary data=surveyonlydrugs sum;
   class baseid;
   var yplus y1-y9;
   output out=survtot(rename=(_freq_=scripts)) sum=;
run;  
proc summary data= all /*trimm&curryear._caid_comm_clean sum*/; /*update for 2018 to include facility*/
   class baseid;
   var yplus y1-y9;
   output out=usertot(rename=(_freq_=scripts)) sum=;
run;
data usertot_a;
   set usertot;
   IF _TYPE_ NE 0;           
   CPSY1=Y1/SCRIPTS;          
   CPSY2=Y2/SCRIPTS;          
   CPSY3=Y3/SCRIPTS;          
   CPSY4=Y4/SCRIPTS;          
   CPSY5=Y5/SCRIPTS;          
   CPSY6=Y6/SCRIPTS;          
   CPSY7=Y7/SCRIPTS;          
   CPSY8=Y8/SCRIPTS;          
   CPSY9=Y9/SCRIPTS;     
run;
PROC MEANS DATA=USERTOT; TITLE 'USERTOT';
run;
data survtot_a;
   set survtot;
   IF _TYPE_ NE 0;           
   CPSY1=Y1/SCRIPTS;          
   CPSY2=Y2/SCRIPTS;          
   CPSY3=Y3/SCRIPTS;          
   CPSY4=Y4/SCRIPTS;          
   CPSY5=Y5/SCRIPTS;          
   CPSY6=Y6/SCRIPTS;          
   CPSY7=Y7/SCRIPTS;          
   CPSY8=Y8/SCRIPTS;          
   CPSY9=Y9/SCRIPTS;     
run;       
data usertot_b;
   merge usertot_a (in=a) a;
      by baseid;
   if a;
run;
data survtot_b;
   merge survtot_a (in=a) a;
      by baseid;
   if a;
run;
DATA SETUPDO; /*OLD ghost_donor code (RENAME=(CDAYS=DONCDAYS ELIGDAYS=DONCOV_C          
                CGAPDAYS=DONDDAYS) DROP=DONORID); */                      
    SET USERTOT_b;                                                  
    CPSY1=Y1/SCRIPTS;                                             
    CPSY2=Y2/SCRIPTS;                                             
    CPSY3=Y3/SCRIPTS;                                             
    CPSY4=Y4/SCRIPTS;                                             
    CPSY5=Y5/SCRIPTS;                                             
    CPSY6=Y6/SCRIPTS;                                             
    CPSY7=Y7/SCRIPTS;                                             
    CPSY8=Y8/SCRIPTS;                                             
    CPSY9=Y9/SCRIPTS;   
run; 
PROC SORT DATA=SETUPDO /* OLD G_D code(RENAME=(BASEID=DONORID))*/;  BY BASEID; /*OLD G_D code BY DONORID;*/ run;
PROC SORT DATA=GHOSTS;  BY BASEID; /*OLD G_D code BY DONORID;*/ run;  
DATA GETDONOR;                                        
 MERGE GHOSTS (IN=AA) SETUPDO (IN=BB);                
  BY BASEID; /*OLD G_D code BY DONORID;*/                                        
   IF AA;                                             
   *NEXT LINE MAY HAVE TO BE COMMENTED OUT;           
   *IF BB THEN OUTPUT GETDONOR; 
run; 
DATA GETDONOR_a (keep=baseid finy1-finy9 finyplus totscrip);                                          
 SET GETDONOR;                                          
  TMPSCRIP=(ELIGDAYS/CDAYS)*SCRIPTS;                 
  GSCRIPTS=ROUND(TMPSCRIP,1);                           
   GY1=GSCRIPTS*CPSY1;                                  
   GY2=GSCRIPTS*CPSY2;                                  
   GY3=GSCRIPTS*CPSY3;                                  
   GY4=GSCRIPTS*CPSY4;                                  
   GY5=GSCRIPTS*CPSY5;                                  
   GY6=GSCRIPTS*CPSY6;                                  
   GY7=GSCRIPTS*CPSY7;                                  
   GY8=GSCRIPTS*CPSY8;                                  
   GY9=GSCRIPTS*CPSY9;                                  
GYPLUS=ROUND(SUM(OF GY1-GY9),.01);    
if gyplus>0;
finy1=gy1;
finy2=gy2;
finy3=gy3;
finy4=gy4;
finy5=gy5;
finy6=gy6;
finy7=gy7;
finy8=gy8;
finy9=gy9;
finyplus=gyplus;
totscrip=gscripts;
run; 
* data for ghosts is now finished;  *ghosts do not have gapday imputation;

* fill in for gap days using only the survey reported drug information;
 DATA gaptot (keep=baseid gp1 gp2 gp3 gp4 gp5 gp6 gp7 gp8 gp9 gpplus gapscrip);                                                           
  SET survTOT_b;                                                           
  IF CGAPDAYS NE 0 THEN DO;                                                                     
  GAPSCRIP=(CGAPDAYS/CDAYS)*SCRIPTS;                                                                 
  IF GAPSCRIP=. THEN GAPSCRIP=0;
  gp1=GAPSCRIP*CPSY1;                                                  
  gp2=GAPSCRIP*CPSY2;                                                  
  gp3=GAPSCRIP*CPSY3;                                                  
  gp4=GAPSCRIP*CPSY4;                                                  
  gp5=GAPSCRIP*CPSY5;                                                  
  gp6=GAPSCRIP*CPSY6;                                                  
  gp7=GAPSCRIP*CPSY7;  
  gp8=GAPSCRIP*CPSY8;                                
  gp9=GAPSCRIP*CPSY9;                                
  gpPLUS=ROUND(SUM(OF gp1-gp9),.01);                    
     END;
if gpPLUS >0; 
run; 

data nonghosts;
   merge gaptot (in=a) usertot (in=b);
      by baseid;
   ARRAY missfill {*} gp1-gp9 gpplus gapscrip;
   do i=1 to 11;
      if missfill{i}=. then missfill{i}=0;
   end;
   finy1=gp1+y1;
   finy2=gp2+y2;
   finy3=gp3+y3;
   finy4=gp4+y4;
   finy5=gp5+y5;
   finy6=gp6+y6;
   finy7=gp7+y7;
   finy8=gp8+y8;
   finy9=gp9+y9;
   finyplus=gpplus+yplus;
   totscrip=gapscrip+scripts;
run;
proc sort  data=getdonor_a;  by baseid;  run;
DATA ALLUSERS;                                                 
 SET nonghosts (in=a)                                  
     GETDONOR_a;
	 by baseid;
run; 
PROC SORT DATA=ALLUSERS NODUPKEY;                                
 BY BASEID;  run;    
DATA ALLPERS;                                                    
 MERGE A (IN=EVERY) ALLUSERS;         
   BY BASEID;                                                    
   IF EVERY;   
run; 
data allusers_a;
   merge allusers (in=a) X (in=b);
      by baseid;
   if a and b;
/*OLD G_D code
   merge allusers ghostxwalk;
      by baseid;
   drop baseid;
   rename ghostid=baseid;*/
run;
DATA mcbsdata.PUFF&curryear.;                                     
 SET ALLusers_a;                                         
  RIC='DT';                                           
  VERSION=1;                                        
  TYPE='PM';                                          
  /*CORF='C';*/    /*2018 removed this line b/c we want to include facility in summary files*/                                       
  totscrip=round(totscrip,1); 
  FINY1=ROUND(FINY1,.01);                           
  FINY2=ROUND(FINY2,.01);                           
  FINY3=ROUND(FINY3,.01);                           
  FINY4=ROUND(FINY4,.01);                           
  FINY5=ROUND(FINY5,.01);                           
  FINY6=ROUND(FINY6,.01);                           
  FINY7=ROUND(FINY7,.01);                           
  FINY8=ROUND(FINY8,.01);                           
  FINY9=ROUND(FINY9,.01); 
  finyplus=round (finyplus,.01);
  finy5b=0;
  finyu=0;
  yu=0;
  y5b=0;
  if baseid='        ' then delete;
  
***trim outlier PDE quantities;
&trimqty;;
run; 
proc sort data=mcbsdata.puff&curryear. ebcdic;  by baseid; run;
PROC MEANS DATA=mcbsdata.PUFF&curryear.; TITLE 'PUFF';  
run;
DATA CHECK(RENAME=(Y1=SY1 Y2=SY2 Y3=SY3 Y4=SY4 Y5=SY5 Y6=SY6 Y7=SY7 Y8=SY8                
                   Y9=SY9 YPLUS=SYPLUS scripts=UADJ_SCR));         
SET usertot;    
    SYU=.;                                  
    SY5B=.;                                 
    FINYU=.;                                
    FINY5B=.;                               
    IF _TYPE_ NE 0;                     
run;                             
PROC SORT DATA=mcbsdata.PUFF&curryear.; BY BASEID;  run;
DATA FORKIM;                                   
  MERGE mcbsdata.PUFF&curryear. (IN=KIM) CHECK (IN=B);      
    BY BASEID;                                   
  IF KIM; 
  IF SY5B=. THEN SY5B=0;              
  IF SYU=. THEN SYU=0;                
  IF FINY5B=. THEN FINY5B=0;          
  IF FINYU=. THEN FINYU=0;             
run;

/*Check to make sure PUFF only contains those in X*/
Data mcbsdata.puff_final&curryear.;
merge mcbsdata.puff&curryear. (in=a) X (in=b); 
by baseid; if a and b;
run;

DATA _NULL_;                                
 SET mcbsdata.puff_final&curryear.;                               
  IF FINYPLUS NE . AND FINYPLUS NE 0;       
  FILE "&location.ricpmp.dat"; 

PUT @1   RIC                                
    @3   VERSION                            
    @5   BASEID                             
    @13  TYPE                               
    @15  YPLUS    9.2                      
    @24  Y9       9.2                      
    @33  Y1       9.2                      
    @42  Y5       9.2                      
    @51  Y5B      9.2                      
    @60  Y7       9.2                      
    @69  Y2       9.2                      
    @78  Y6       9.2                      
    @87  YU       9.2                      
    @96  Y3       9.2                      
    @105 Y8       9.2                      
    @114 Y4       9.2  
    @123 scripts  4.                     
    @127 FINYPLUS  9.2                    
    @136 FINY9     9.2                    
    @145 FINY1     9.2                    
    @154 FINY5     9.2                    
    @163 FINY5B    9.2                    
    @172 FINY7     9.2                    
    @181 FINY2     9.2                    
    @190 FINY6     9.2                    
    @199 FINYU     9.2                    
    @208 FINY3     9.2                    
    @217 FINY8     9.2                    
    @226 FINY4     9.2                    
    @235 TOTSCRIP  4.;
run;

*** Make permanent SAS dataset;
OPTIONS COMPRESS=YES;
proc sql;
create table mcbsdata.ricpmp as select
RIC			as	RIC			label=""	,
VERSION		as	VERSION		label=""	,
BASEID		as	BASEID		label=""	,
TYPE		as	TYPE		label=""	,
YPLUS		as	YPLUS		label=""	,
Y9			as	Y9			label=""	,
Y1			as	Y1			label=""	,
Y5			as	Y5			label=""	,
Y5B			as	Y5B			label=""	,
Y7			as	Y7			label=""	,
Y2			as	Y2			label=""	,
Y6			as	Y6			label=""	,
YU			as	YU			label=""	,
Y3			as	Y3			label=""	,
Y8			as	Y8			label=""	,
Y4			as	Y4			label=""	,
scripts		as	scripts		label=""	,
FINYPLUS	as	TOTEXP		label=""	,
FINY9		as	CAREEXP		label=""	,
FINY1		as	CAIDEXP		label=""	,
FINY5		as	PHMOEXP		label=""	,
FINY5B		as	MHMOEXP		label=""	,
FINY7		as	VAEXP		label=""	,
FINY2		as	PRVEEXP		label=""	,
FINY6		as	PRVIEXP		label=""	,
FINYU		as	UNKEXP		label=""	,
FINY3		as	OOPEXP		label=""	,
FINY8		as	DISCEXP		label=""	,
FINY4		as	OTHEXP		label=""	,
TOTSCRIP	as	TOTSCRIP	label=""	

from mcbsdata.puff_final&curryear.
where FINYPLUS NE . AND FINYPLUS NE 0;
quit;

proc contents data=mcbsdata.ricpmp varnum; run;

proc means data=mcbsdata.puff_final&curryear.;
   var yplus;
run;
data checktot;
   set mcbsdata.puff_final&curryear.;
      if yplus > 50000;
run;


* stopped here to look into high cost obs  ;

PROC SORT DATA=trimm&curryear._caid_comm_clean OUT=NPUFFEV&curryear.c; BY PMEID;  run;   
PROC SORT DATA=trimm&curryear._caid_fac_clean OUT=NPUFFEV&curryear.f; BY PMEID;  run;  

DATA PUFFv1&curryear.;   
 SET NPUFFEV&curryear.c (in=a)
     NPUFFEV&curryear.F (in=b);
  if a then corf='C';
    else corf='F';
  RIC='PM'; 
  VERSION=1;                                      
  TYPE='PM';                                        
  IF FY1 NE 0 THEN IMPFY1=1; ELSE IMPFY1=0;       
  IF FY2 NE 0 THEN IMPFY2=1; ELSE IMPFY2=0;       
  IF FY3 NE 0 THEN IMPFY3=1; ELSE IMPFY3=0;       
  IF FY4 NE 0 THEN IMPFY4=1; ELSE IMPFY4=0;       
  IF FY5 NE 0 THEN IMPFY5=1; ELSE IMPFY5=0;       
  IF FY6 NE 0 THEN IMPFY6=1; ELSE IMPFY6=0;       
  IF FY7 NE 0 THEN IMPFY7=1; ELSE IMPFY7=0;       
  IF FY8 NE 0 THEN IMPFY8=1; ELSE IMPFY8=0;       
  IF FY9 NE 0 THEN IMPFY9=1; ELSE IMPFY9=0;       
  IF FYPLUS NE 0 THEN IMPFYPL=1; ELSE IMPFYPL=0;  
  IF FD1 NE 0 THEN IMPFD1=1; ELSE IMPFD1=0;       
  IF FD2 NE 0 THEN IMPFD2=1; ELSE IMPFD2=0;       
  IF FD3 NE 0 THEN IMPFD3=1; ELSE IMPFD3=0;       
  IF FD4 NE 0 THEN IMPFD4=1; ELSE IMPFD4=0;       
  IF FD5 NE 0 THEN IMPFD5=1; ELSE IMPFD5=0;       
  IF FD6 NE 0 THEN IMPFD6=1; ELSE IMPFD6=0;       
  IF FD7 NE 0 THEN IMPFD7=1; ELSE IMPFD7=0;
  IF FD8 NE 0 THEN IMPFD8=1; ELSE IMPFD8=0;   
  IF FD9 NE 0 THEN IMPFD9=1; ELSE IMPFD9=0;   
IF Y5B =. THEN Y5B=0;                                     
IF IMPFD5B=. THEN IMPFD5B=0;                          
IF IMPFY5B=. THEN IMPFY5B=0;                          
YU=0;                                                     
IMPFDU=0;                                                 
IMPFYU=0;

/*IN 2015 the only 2 recodes were done */ 
IF PMFORM=-8 THEN PMFORM=.;                                
*IF STRNUNI2=. THEN STRNNUM2=.; 
/*2016*/
if TABNUM= .E then TABNUM = .;
/*2018*/
IF TABSADAY= .E THEN TABSADAY= .;
IF TABTAKE= .E THEN TABTAKE= .;
IF AMTNUM = .E then AMTNUM= .;
 
run;
PROC SORT DATA=PUFFv1&curryear.; BY BASEID;  run;
proc freq data=puffv1&curryear.;
   tables corf;
run;

DATA puffv1&curryear. ;*_NULL_;                            
 SET puffv1&curryear.; 
   IF PDE_FLAG='Survey Only' then pdeflag=1;
   if PDE_FLAG='PDE Only   ' then pdeflag=2;
   if PDE_FLAG='Survey/PDE ' then pdeflag=3;
	if FDB_BN='NAGLAZYME' then delete;
	if baseid ='01319463' then delete; 


***fix PDE costs;
diff= abs(YPLUS - sum(Y9,Y1,Y5,Y5B,Y7,Y2,Y6,YU,Y3,Y8,Y4) );

if diff>0.01 and PDE_FLAG in ('PDE Only   ','Survey/PDE ')  then 
do;
 totaltemp=sum(Y9,Y1,Y5,Y5B,Y7,Y2,Y6,YU,Y3,Y8,Y4);

 Y9  = round(YPLUS  * (Y9  / totaltemp),.01);
 Y1  = round(YPLUS  * (Y1  / totaltemp),.01);
 Y5  = round(YPLUS  * (Y5  / totaltemp),.01);
 Y5B = round(YPLUS  * (Y5B / totaltemp),.01);
 Y7  = round(YPLUS  * (Y7  / totaltemp),.01);
 Y2  = round(YPLUS  * (Y2  / totaltemp),.01);
 Y6  = round(YPLUS  * (Y6  / totaltemp),.01);
 YU  = round(YPLUS  * (YU  / totaltemp),.01);
 Y3  = round(YPLUS  * (Y3  / totaltemp),.01);
 Y8  = round(YPLUS  * (Y8  / totaltemp),.01);
 Y4  = round(YPLUS  * (Y4  / totaltemp),.01);
end;

***trim outlier PDE quantities;
&trimqty;;

drop diff totaltemp;

RUN;

data qty_test ; set puffv1&curryear.; if qnty>=5000;run;

data puffev&curryear. (rename = (YPLUS=AMTTOT Y9=AMTCARE Y1=AMTCAID Y5=AMTHMOP
Y5B=AMTMADV Y7=AMTVA Y2=AMTPRVE Y6=AMTPRVI YU=AMTPRVU Y3=AMTOOP Y8=AMTDISC Y4=AMTOTH
PMEDNAME=DRUGNAME STRNUNIT=STRNUNI1 STRNNUM=STRNNUM1 IMPFD9=ISOPCARE    
IMPFD1=ISOPCAID IMPFD5=ISOPHMOP IMPFD5B=ISOPMADV IMPFD7=ISOPVA IMPFD2=ISOPPRVE    
IMPFD6=ISOPPRVI IMPFDU=ISOPUNK IMPFD3=ISOPOOP IMPFD8=ISOPDISC IMPFD4=ISOPOTH IMPFYPL=IAMTTOT
IMPFY9=IAMTCARE IMPFY1=IAMTCAID IMPFY5=IAMTHMOP IMPFY5B=IAMTMADV IMPFY7=IAMTVA IMPFY2=IAMTPRVE               
IMPFY6=IAMTPRVI IMPFYU=IAMTPRVU IMPFY3=IAMTOOP IMPFY8=IAMTDISC IMPFY4=IAMTOTH
FDB_GCRT_DESC=FDB_RTE SERV_DT=SERV_DT_OLD)); 
merge puffv1&curryear. (in=a) X (in=b);
by baseid; 
if a and b;
run;


Data mcbsdata.tmp (keep = BASEID SURVEYYR VERSION TYPE CORF AMTTOT IAMTTOT  
AMTCARE ISOPCARE IAMTCARE AMTCAID ISOPCAID IAMTCAID 
AMTHMOP ISOPHMOP IAMTHMOP AMTMADV ISOPMADV IAMTMADV 
/*AMTVA ISOPVA IAMTVA*/ AMTPRVE ISOPPRVE IAMTPRVE 
AMTPRVI ISOPPRVI IAMTPRVI AMTPRVU ISOPUNK IAMTPRVU 
AMTOOP ISOPOOP IAMTOOP AMTDISC ISOPDISC IAMTDISC 
AMTOTH ISOPOTH IAMTOTH DRUGNAME PMFORM PMCOND PMKNWNM  
STRNUNI1 STRNNUM1 /*STRNUNI2 STRNNUM2*/ 
TABNUM TABSADAY TABTAKE SUPPNUM AMTNUM AMTUNIT THERCC OTCLEG 
PMEID FDB_BN FDB_GNN FDB_STR FDB_RTE SERV_DT
NDC_CD QNTY DAYSUPP PDEFLAG);
set puffev&curryear. (RENAME =(RX_DATE=SERV_DT)); 

Version=1;
SURVEYYR=2020; /*UPDATE*/
/*2016 fix*/
if FDB_BN = "-1" then FDB_BN = "";
if FDB_GNN = "-1" then FDB_GNN = "";
if FDB_STR = "-1" then FDB_STR = "";

proc sort; by baseid; run;

data mcbsdata.final(keep = BASEID SURVEYYR VERSION TYPE CORF AMTTOT IAMTTOT  
AMTCARE ISOPCARE IAMTCARE AMTCAID ISOPCAID IAMTCAID 
AMTHMOP ISOPHMOP IAMTHMOP AMTMADV ISOPMADV IAMTMADV 
/*AMTVA ISOPVA IAMTVA*/ AMTPRVE ISOPPRVE IAMTPRVE 
AMTPRVI ISOPPRVI IAMTPRVI AMTPRVU ISOPUNK IAMTPRVU 
AMTOOP ISOPOOP IAMTOOP AMTDISC ISOPDISC IAMTDISC 
AMTOTH ISOPOTH IAMTOTH DRUGNAME PMFORM PMCOND PMKNWNM  
STRNUNI1 STRNNUM1 /*STRNUNI2 STRNNUM2*/ 
TABNUM TABSADAY TABTAKE SUPPNUM AMTNUM AMTUNIT THERCC OTCLEG 
PMEID FDB_BN FDB_GNN FDB_STR FDB_RTE SERV_DT  
NDC_CD QNTY DAYSUPP PDEFLAG);
set mcbsdata.tmp;

/*serv_dt = input(put(dt_tmp,best8.),yymmdd8.);*/
/*format serv_dt  yymmddn8.;*/

proc sort; by baseid; 
run;


/*Output to SAS file and use Retain statement so variables are in proper order*/
 
DATA MCBSDATA.PME2;
RETAIN 
BASEID SURVEYYR VERSION TYPE CORF AMTTOT IAMTTOT  
AMTCARE ISOPCARE IAMTCARE AMTCAID ISOPCAID IAMTCAID 
AMTHMOP ISOPHMOP IAMTHMOP AMTMADV ISOPMADV IAMTMADV 
/*AMTVA ISOPVA IAMTVA*/ AMTPRVE ISOPPRVE IAMTPRVE 
AMTPRVI ISOPPRVI IAMTPRVI AMTPRVU ISOPUNK IAMTPRVU 
AMTOOP ISOPOOP IAMTOOP AMTDISC ISOPDISC IAMTDISC 
AMTOTH ISOPOTH IAMTOTH DRUGNAME PMFORM PMCOND PMKNWNM  
/*STRNUNI1 STRNNUM1 STRNUNI2 STRNNUM2*/ 
TABNUM TABSADAY TABTAKE SUPPNUM AMTNUM AMTUNIT THERCC OTCLEG 
PMEID FDB_BN FDB_GNN FDB_STR FDB_RTE SERV_DT  
NDC_CD QNTY DAYSUPP PDEFLAG;

	SET mcbsdata.final;

  KEEP    BASEID SURVEYYR VERSION TYPE CORF AMTTOT IAMTTOT  
AMTCARE ISOPCARE IAMTCARE AMTCAID ISOPCAID IAMTCAID 
AMTHMOP ISOPHMOP IAMTHMOP AMTMADV ISOPMADV IAMTMADV 
/*AMTVA ISOPVA IAMTVA*/ AMTPRVE ISOPPRVE IAMTPRVE 
AMTPRVI ISOPPRVI IAMTPRVI AMTPRVU ISOPUNK IAMTPRVU 
AMTOOP ISOPOOP IAMTOOP AMTDISC ISOPDISC IAMTDISC 
AMTOTH ISOPOTH IAMTOTH DRUGNAME PMFORM PMCOND PMKNWNM  
/*STRNUNI1 STRNNUM1 STRNUNI2 STRNNUM2*/ 
TABNUM TABSADAY TABTAKE SUPPNUM AMTNUM AMTUNIT THERCC OTCLEG 
PMEID FDB_BN FDB_GNN FDB_STR FDB_RTE SERV_DT  
NDC_CD QNTY DAYSUPP PDEFLAG;

  FORMAT    BASEID SURVEYYR VERSION TYPE CORF AMTTOT IAMTTOT  
AMTCARE ISOPCARE IAMTCARE AMTCAID ISOPCAID IAMTCAID 
AMTHMOP ISOPHMOP IAMTHMOP AMTMADV ISOPMADV IAMTMADV 
/*AMTVA ISOPVA IAMTVA*/ AMTPRVE ISOPPRVE IAMTPRVE 
AMTPRVI ISOPPRVI IAMTPRVI AMTPRVU ISOPUNK IAMTPRVU 
AMTOOP ISOPOOP IAMTOOP AMTDISC ISOPDISC IAMTDISC 
AMTOTH ISOPOTH IAMTOTH DRUGNAME PMFORM PMCOND PMKNWNM  
/*STRNUNI1 STRNNUM1 STRNUNI2 STRNNUM2*/ 
TABNUM TABSADAY TABTAKE SUPPNUM AMTNUM AMTUNIT THERCC OTCLEG 
PMEID FDB_BN FDB_GNN FDB_STR FDB_RTE SERV_DT  
NDC_CD QNTY DAYSUPP PDEFLAG;

   RUN;


Data mcbsdata.PME3;
set mcbsdata.PME2;
	/*Apply formats*/

FORMAT
    BASEID   $BSIDFMT.
	SURVEYYR SVYRFMT.
    VERSION VERSFMT.
	AMTTOT AMTCARE AMTCAID AMTMADV AMTHMOP /*AMTVA*/ AMTPRVE AMTPRVI AMTPRVU 
    AMTOOP AMTDISC AMTOTH MONYFMT.
 	TYPE $EVNTTYP. 
	CORF $INTRFMT. 
	IAMTTOT ISOPCARE IAMTCARE  ISOPCAID IAMTCAID ISOPHMOP IAMTHMOP  ISOPMADV IAMTMADV 
 	/*ISOPVA IAMTVA*/  ISOPPRVE IAMTPRVE ISOPPRVI IAMTPRVI  ISOPUNK IAMTPRVU 
 	ISOPOOP IAMTOOP  ISOPDISC IAMTDISC ISOPOTH IAMTOTH IMPFLAG.
	DRUGNAME $DRUGNME.
    PMFORM FORMFMT.  
    /*STRNUNI1 STRNUNI2 STRENGTH.*/ 
	/*STRNNUM1  STRNNUM2 STRNFMT.*/
	TABNUM TABFMT. 
	SUPPNUM SUPPFMT. 
	AMTNUM AMTFMT.
	AMTUNIT PMUNIT.
	THERCC $THERFMT.
	OTCLEG $OTCFMT.
	PMEID $PMEID.
	FDB_BN $FDBBN.
	FDB_GNN $FDBGNN.
	FDB_STR $FDBSTRN.
	FDB_RTE $FDBRTE.  
	NDC_CD $NDC. 
	PDEFLAG MATCH.
	QNTY QNTYFMT. 
	DAYSUPP DAYSSUP.
	SERV_DT DTE8FMT.
	PMCOND PMCONDF.
	PMKNWNM YES1FMT.
	TABSADAY TABSADYF.
	TABTAKE TABTAKF.;

  /*variable labels here*/

  LABEL
BASEID   = "Unique SP Identification Number"
VERSION  = "Version Number"
SURVEYYR = "Survey Year"
TYPE     = "Event type-Prescribed Medicine"
CORF     = "Community or facility"
AMTTOT   = "Total payment"
IAMTTOT  = "AMTTOT payment amount imputed?"
AMTCARE  = "Amount paid by Medicare FFS/Part D"
ISOPCARE = "AMTCARE payment source imputed?"
IAMTCARE = "AMTCARE payment amount imputed?"
AMTCAID  = "Amount paid by Medicaid"
ISOPCAID = "AMTCAID payment source imputed?"
IAMTCAID = "AMTCAID payment amount imputed?"
AMTHMOP  = "Amount paid by private MCO/HMO"
ISOPHMOP = "AMTHMOP payment source imputed?"
IAMTHMOP = "AMTHMOP payment amount imputed?"
AMTMADV  = "Amount paid by Medicare MCO/HMO"
ISOPMADV = "AMTMADV payment source imputed?"
IAMTMADV = "AMTMADV payment amount imputed?"
/*AMTVA    = "Amount paid by Veterans Administration"
ISOPVA   = "AMTVA payment source imputed?"
IAMTVA   = "AMTVA payment amount imputed?"*/
AMTPRVE  = "Amt paid by employer-sponsored priv ins"
ISOPPRVE = "AMTPRVE payment source imputed?"
IAMTPRVE = "AMTPRVE payment amount imputed?"
AMTPRVI  = "Amt paid by individually-purch priv ins"
ISOPPRVI = "AMTPRVI payment source imputed?"
IAMTPRVI = "AMTPRVI payment amount imputed?"
AMTPRVU  = "Amt paid by priv ins (unknown purchased)"
ISOPUNK  = "AMTPRVU payment source imputed?"
IAMTPRVU = "AMTPRVU payment amount imputed?"
AMTOOP   = "Amount paid out-of-pocket (OOP)"
ISOPOOP  = "AMTOOP payment source imputed?"
IAMTOOP  = "Imputed out-of-pocket amount "
AMTDISC  = "Amount of uncollected SP liability"
ISOPDISC = "AMTDISC payment source imputed?"
IAMTDISC = "Imputed discount amount "
AMTOTH   = "Amt paid by other payor(s)(includes VA)"
ISOPOTH  = "AMTOTH payment source imputed?"
IAMTOTH  = "Imputed other amount"
DRUGNAME = "Prescribed Medicine name"
PMFORM   = "Prescribed Medicine form" 
PMCOND   = "Condition medicine is used for"
PMKNWNM  = "Name of medicine is known"
/*STRNUNI1 = "Unit of strength"
STRNNUM1 = "Number of units"
STRNUNI2 = "Unit of strength/2nd combination"
STRNNUM2 = "Number of units/2nd combination"*/
TABNUM   = "Number of tablets"
TABSADAY  = "How many tabs a day are to be taken" 
TABTAKE = "Number of tabs usually taken in a day"
SUPPNUM  = "Number of suppositories"
AMTNUM   = "Amount of prescr. medicine in container"
AMTUNIT  = "Amount unit"
THERCC   = "F.D.B. generic therapeutic class"
OTCLEG   = "Over-the-counter/legend indicator"
PMEID    = "RICPME event ID"
FDB_BN   = "First Databank brand name"
FDB_GNN  = "First Databank generic name"
FDB_STR  = "First Databank strength"
FDB_RTE  = "First Databank Route"
SERV_DT  = "Service Date"
NDC_CD   = "NDC Code"
QNTY     = "Quantity"
DAYSUPP  = "Days Supplied"
PDEFLAG  = "PDE Match Indicator";
  run;
	
Proc contents data=mcbsdata.PME3;
   run;

   proc freq data=mcbsdata.PME3;
tables SURVEYYR VERSION TYPE CORF AMTTOT IAMTTOT  
AMTCARE ISOPCARE IAMTCARE AMTCAID ISOPCAID IAMTCAID 
AMTHMOP ISOPHMOP IAMTHMOP AMTMADV ISOPMADV IAMTMADV 
/*AMTVA ISOPVA IAMTVA*/ AMTPRVE ISOPPRVE IAMTPRVE 
AMTPRVI ISOPPRVI IAMTPRVI AMTPRVU ISOPUNK IAMTPRVU 
AMTOOP ISOPOOP IAMTOOP AMTDISC ISOPDISC IAMTDISC 
AMTOTH ISOPOTH IAMTOTH DRUGNAME PMFORM PMCOND PMKNWNM  
/*STRNUNI1 STRNNUM1 STRNUNI2 STRNNUM2*/ 
TABNUM TABSADAY TABTAKE SUPPNUM AMTNUM AMTUNIT THERCC OTCLEG 
PMEID FDB_BN FDB_GNN FDB_STR FDB_RTE SERV_DT  
NDC_CD QNTY DAYSUPP PDEFLAG /missing;
	   title 'PME ';
   run;

   data mcbsdata.PME;
   set mcbsdata.PME3;
    format serv_dt mmddyyn8.;
   run;
   proc sort data = mcbsdata.PME presorted;
by baseid;
run;

DATA pmecsv;
set mcbsdata.pme;
by baseid;
format _all_;
format serv_dt mmddyyn8.;
run;

/*Create CSV file*/

PROC EXPORT DATA= pmecsv
     		OUTFILE= "C:\Users\S1C3\RIC PME\MCBS\2020\PME\Data\pme.csv" /*UPDATE YEAR*/
     		DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

proc contents data=mcbsdata.pme;
run;


/*
data mcbsdata.PME;
   set mcbsdata.PME3;
   format serv_dt mmddyyn8.;
   run;

   data mcbsdata.PME_unfmt;
   set mcbsdata.PME2;
	format _all_;
	format serv_dt mmddyyn8.;
run;

 
   ********************Remove variable labels******************;
proc datasets library=mcbsdata nolist;
  modify PME_unfmt;
  attrib _all_ label='';
quit;
*/

   /*Create CSV file*/
/*
PROC EXPORT DATA= MCBSDATA.PME_unfmt
     		OUTFILE= "C:\Users\S1C3\RIC PME\MCBS\2019\PME\Data\pme.csv" 
     		DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;*/
