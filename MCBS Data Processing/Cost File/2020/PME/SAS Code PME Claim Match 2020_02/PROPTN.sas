******************************************************************           
* DETERMINE FIRST AND LAST ROUNDS OF CY AND PERCENTAGE OF DAYS             
* VAR LPROP AND FPROP SHOULD BE DEFINED AS INTEGER                         
* THIS FILE IS NEEDED FOR THE CREATION OF THE RIC SS AND PS                
* STEP 1 THEN RUN CREATHH PROGRAM                                          
* LAST UPDATED 7/2/2014 FOR 2011 CAU RUN                                   
***************************************************************;           
                   
/*OUT   DD DSN=S1C3.@BLV3380.COST13.PROPTN, */                                 
  
libname WHO 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\2020 Population';
libname TL1 'Y:\Share\SMAG\MCBS\MCBS Survey File\2020\Admin\Timeline';
libname X 'Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2020\Data\SAS Files';
libname OUT 'C:\Users\S1C3\RIC PME\MCBS\2020\PME\Data';
 
    OPTIONS NOFMTERR;                                  
    OPTIONS LS=80;                                     
    %LET YEAR=20; /*CURENT YEAR*/                      
    %LET PY=2019; /*PREVIOUS YEAR*/                    
    %LET CY=2020; /*CURENT YEAR*/                      
  %LET NY=2021; /*NEXT YEAR*/                          
                                                       
  DATA WHO&YEAR (keep=baseid panel);                                       
    set WHO.pop2020_final_feb22;                                                                
  PROC SORT;                                           
    BY BASEID; run;  

/*Add the X and merge with POP*/ 
  Data X (keep=baseid);
  set X.csevwgts;
  proc sort; by baseid;
  run;

  Data WHO;
  merge WHO&YEAR. (in=a) X (in=b);
  by baseid; 
  if b;
  run;
                                                       
  DATA TL NO_TL NO_WHO;                                
    MERGE TL1.REF&CY.(IN=TL) WHO(IN=P);          
    BY BASEID;                                         
  IF TL AND P THEN OUTPUT TL;                          
  IF P AND NOT TL THEN OUTPUT NO_TL;                   
  IF TL AND NOT P THEN OUTPUT NO_WHO;                  
                                                                           
  PROC SORT DATA=TL OUT=TEMP(KEEP=BASEID) NODUPKEY;                        
    BY BASEID; run;                                                            
 PROC SORT DATA=NO_WHO NODUPKEY;                                           
   BY BASEID;  run;                                                            
 PROC PRINT DATA=NO_WHO;                                                   
   VAR BASEID; run;                                                            
 TITLE "IN TIMELINE BUT NOT IN WHO &YEAR";                                 
 PROC FREQ DATA=NO_TL;                                                     
   TABLES PANEL;                                                           
 TITLE 'NO TIMELINE RECORDS';                                              
                                                                           
/*IN THE 2016 REF FILE ORIGBNEW AND ORIGENEW DATES WERE CHANGED TO NUMERIC(DATE) YYMMDD10. 2015-12-31*/
/*To simplify things the numeric date was changed to a chatacter date like it was in the 
 2015 REF file*/
DATA TL_DATE;
SET TL;
ORIGBNEW=PUT (ORIGBDAT,YYMMDDN8.);
ORIGENEW=PUT (ORIGEDAT,YYMMDDN8.);
RUN;
/*2017 drop original dates and rename new character ones to old orig dates*/
DATA TL_DATE2;
SET TL_DATE (drop= ORIGBDAT ORIGEDAT);
rename ORIGBNEW=ORIGBDAT;
rename ORIGENEW=ORIGEDAT;
proc sort; by baseid;
run;

/*Test Changing date format*/
/*DATA tl_date2;
  SET tl;
  FORMAT ORIGBDAT MMDDYY10.;
RUN;*/

DATA TL BADBDAT;                                                          
   SET TL_date2;  /*update for 2016 to reflect format conversion*/                                                               
 FORMAT SASBDAT SASEDAT DATE7.;                                            
 
 * NEW IN 1996;                                                            
 IF BASEID='00090314' & ROUND='08' & SUBSTR(ORIGEDAT,3,4)='DKDK' THEN      
  SUBSTR(ORIGEDAT,3,4)='0214';                                         
 IF SUBSTR(ORIGBDAT,5,2)='DK' THEN DO;                                     
  SUBSTR(ORIGBDAT,5,2)='15';                                                   
  FLAGSUBB=1;                                                                  
 END;                                                                        
 IF ORIGBDAT>0 THEN SASBDAT=INPUT(ORIGBDAT,YYMMDD8.);                          
 IF ORIGEDAT>0 THEN SASEDAT=INPUT(ORIGEDAT,YYMMDD8.);                          
 OUTPUT TL;                                                                    
 IF ORIGBDAT<0 OR ORIGEDAT<0 THEN OUTPUT BADBDAT;                              
 PROC FREQ DATA=TL;                                                            
   TABLES FLAGSUBB /*FLAGSUBE*/;                                               
 TITLE 'HOW OFTEN WAS ORIGBDAT AND ORIGEDAT=DK';                               
                                                                               
 PROC PRINT DATA=BADBDAT(OBS=20);                                              
   VAR BASEID ROUND ORIGBDAT ORIGEDAT ENDDATE DOD INTVDISP;                    
 TITLE 'BAD DATES';                                                            
 FORMAT ENDDATE DATE7.;                                                        
 PROC FREQ DATA=BADBDAT;                                                       
   TABLES ROUND INTVDISP/MISSING;                                              
                                                                               
 PROC SORT DATA=TL;                                                            
   BY BASEID ROUND INT_TYPE INTVDISP;                                          
DATA PROP NOPROP;                                                              
  SET TL;                                                                      
  BY BASEID ROUND INT_TYPE INTVDISP;                                           
RETAIN FLAGOUT FLAG41;                                                         
IF FIRST.BASEID THEN DO;                                                       
    FLAGOUT=.;                                                                 
    FLAG41=.;                                                                  
END;                                                                           
IF INT_TYPE=' ' THEN INT_TYPE='X';                                             
*WANT IT TO SORT LAST FOR NEXT STEP;                                           
                                                                               
***NOTES:                                                                      
 MOST FALL IN CONDITION 1:  FIRST ROUND SPANS YEAR. DETERMINE PROPORTIO        
 CONDITION 2: IF FIRST ROUND BEGINS IN 1999 THEN ALL EVENTS ARE 1999.          
 CONDITION 3: IF PERSON DIED WITH NO FOLLOW-UP INTERVIEW TAKE PROPORTIO        
  (WON'T MATTER--THERE WON'T BE ANY EVENTS ANYWAY)                             
 CONDITION 4: FIRST ROUND IS A 41.;                                            
                                                                               
IF (YEAR(SASBDAT)=&PY AND YEAR(SASEDAT)=&CY) OR                                
(FLAG41 AND YEAR(SASEDAT)=&CY AND NOT FLAGOUT) THEN DO;                        
  FPROP=(SASEDAT-MAX("1JAN&CY"D,SASBDAT)) / (SASEDAT-SASBDAT) *100;        
  FRND=ROUND;                                                              
 OUTPUT PROP;                                                              
      FLAGOUT=1;                                                           
 END;                                                                      
 ELSE IF FIRST.BASEID AND YEAR(SASBDAT)=&CY THEN DO;                       
  FPROP=100;                                                               
  FRND=ROUND;                                                              
 OUTPUT PROP;                                                              
      FLAGOUT=1;                                                           
 END;                                                                      
 ELSE IF FIRST.BASEID & YEAR(SASBDAT)=&PY AND DOD>0 AND INTVDISP NE '41'   
 THEN DO;                                                                  
  FPROP=(DOD-"1JAN&CY"D) / (DOD-SASBDAT) *100;                             
  FRND=ROUND;                                                              
 OUTPUT PROP;                                                              
 FLAGOUT=1;                                                                
 END;                                                                      
 ELSE IF FIRST.BASEID AND INTVDISP='41' THEN DO;                           
  FLAG41=1;                                                                
 END;                                             
 ELSE IF NOT FLAGOUT THEN OUTPUT NOPROP;          
                                                  
 PROC PRINT DATA=PROP(OBS=15);                    
 TITLE 'PROP SAMPLE';                             
 PROC FREQ DATA=PROP;                             
   TABLES FRND*INTVDISP/LIST MISSING;             
 PROC PRINT DATA=NOPROP(OBS=20);                  
 TITLE 'STILL NO PROPORTION ASSIGNED';            
 PROC FREQ DATA=NOPROP;                           
   TABLES INTVDISP/MISSING;                       
                                                  
 DATA MTONE;                                      
   SET PROP;                                      
   BY BASEID;                                     
 IF NOT (FIRST.BASEID AND LAST.BASEID);           
 PROC PRINT DATA=MTONE;                           
 TITLE 'MORE THAN ONE RECORD THAT SPANS 97/98';   
                                                  
PROC SORT DATA=PROP;                              
  BY BASEID INT_TYPE INTVDISP;                 
DATA PROP;                                     
  SET PROP;                                    
 BY BASEID INT_TYPE INTVDISP;                  
 IF FIRST.BASEID;                              
                                               
 PROC FORMAT;                                  
   VALUE PROPTN LOW-<0='TOO LOW!'              
                0     ='0        '             
                >0-25.99 ='1% - 25% '          
                26-50.99 ='26% - 50%'          
                51-75.99 ='51% - 75%'          
                76-99.99 ='76% - 99%'          
                100   ='100%'                  
                101-HIGH ='TOO HIGH!';         
 PROC FREQ DATA=PROP;                          
   TABLES FPROP FPROP*INT_TYPE/LIST MISSING;   
 FORMAT FPROP PROPTN.;                         
 TITLE 'DISTRIBUTION OF FPROP';                
DATA LOOKATB;                                                            
  SET PROP(KEEP=BASEID FPROP FRND);                                      
IF FPROP>=100 OR FPROP=0;                                                
 DATA LOOKAT;                                                            
   MERGE TL(IN=T) LOOKATB(IN=B);                                         
   BY BASEID;                                                            
 IF T AND B;                                                             
 PROC PRINT DATA=LOOKAT(OBS=20);                                         
 TITLE 'LOOK AT THESE OUTLIERS FOR FPROP';                               
                                                                         
 DATA PROP_A NOPROP_A;                                                   
   SET TL;                                                               
   BY BASEID ROUND INT_TYPE;                                             
 RETAIN FLAGOUT;                                                         
 IF FIRST.BASEID THEN FLAGOUT=.;                                         
                                                                         
 IF YEAR(SASBDAT)=&CY AND YEAR(SASEDAT)=&NY THEN DO;                     
  LPROP=("31DEC&CY"D - SASBDAT) / (SASEDAT-SASBDAT) *100;                
  LRND=ROUND; OUTPUT PROP_A; FLAGOUT=1; END;                             
 ELSE IF LAST.BASEID AND (YEAR(SASEDAT)=&CY OR YEAR(ENDDATE)=&CY) THEN   
DO;                                                              
 LPROP=100;                                                      
 LRND=ROUND;                                                     
 OUTPUT PROP_A;                                                  
 FLAGOUT=1;                                                      
END;                                                             
ELSE IF LAST.BASEID AND NOT FLAGOUT THEN OUTPUT NOPROP_A;        
                                                                 
                                                                 
DATA NOPROP_P;                                                   
  MERGE NOPROP_A(KEEP=BASEID IN=N) TL;                           
  BY BASEID;                                                     
IF N;                                                            
PROC PRINT DATA=NOPROP_P(OBS=20);                                
TITLE 'STILL NO PROP_A  ASSIGNED';                               
PROC FREQ DATA=NOPROP_A;                                         
  TABLES INTVDISP;                                               
                                                                 
PROC PRINT DATA=PROP_A(OBS=50);                                  
TITLE 'PROP_A SAMPLE';                                           
 PROC FREQ DATA=PROP_A;                                       
   TABLES LRND LRND*INTVDISP/LIST MISSING;                    
   TABLES LPROP LPROP*INT_TYPE/LIST MISSING;                  
 FORMAT LPROP PROPTN.;                                        
                                                              
PROC PRINT DATA=NOPROP_A;                                     
TITLE 'NO LAST ROUND STUFF ASSIGNED';                         
PROC FREQ DATA=NOPROP_A;                                      
  TABLES INTVDISP/MISSING;                                    
                                                              
DATA MTONE;                                                   
  SET PROP_A;                                                 
  BY BASEID;                                                  
IF NOT (FIRST.BASEID AND LAST.BASEID);                        
PROC PRINT DATA=MTONE;                                        
TITLE 'MORE THAN ONE FOR PROP_A';                             
                                                              
 * LOOKS LIKE IT'S IRRELEVANT WHICH DUPLICATE TO INCLUDE      
   (SAME PROPORTIONS);                                        
 DATA PROP_A;                                                 
   SET PROP_A;                               
   BY BASEID INT_TYPE;                       
 IF FIRST.BASEID;                            
                                             
 DATA OUT.Cost&YEAR._PROPTN;                            
   MERGE PROP(KEEP=BASEID FRND FPROP)        
         PROP_A(KEEP=BASEID LRND LPROP);     
   BY BASEID;                                
 PROC CONTENTS DATA=OUT.Cost&YEAR._PROPTN;              
 PROC PRINT DATA=OUT.Cost&YEAR._PROPTN(OBS=20);         
 TITLE 'FINAL';                              
 RUN;                                        
                                              
