/******************************************************************************************************/																			***/
/*** OBJECTIVE: Create expenditure measures using LDS segments                                      ***/
/******************************************************************************************************/;																				***/


* Create a copy of SS - Service Summary file - which is used to get the event and spending data;

DATA tempcs.ss_in ;                                                                                         
   SET cost.ss( KEEP = baseid evnttype aamt: aevents ) ;                                       
RUN;  

* UPDATE (2019): Create a copy of the HISUMRY segment which is used to
                 collect premium payment data and merge onto the SS file.;

DATA tempcs.hisumry_in;                                                                                         
	SET survey.hisumry(KEEP = baseid H_PTAPRM H_PTBPRM H_CPRM01-H_CPRM12 H_DPRM01-H_DPRM12);
RUN;  

PROC SQL;
CREATE TABLE tempcs.ss1 AS 
  SELECT A.*, 
         B.*
  FROM   tempcs.ss_in AS A 
         LEFT JOIN tempcs.hisumry_in AS B 
                ON A.baseid = B.baseid; 
QUIT;

* Rename variables to distinguish expenditures across event type;
DATA DU FA IU HH HP IP MP OP PM HU VU;                                                                       
   SET tempcs.ss1;                                                                                        
   BY baseid;                                                                                          
   KEEP BASEID AAMTTOT AAMTCARE AAMTCAID AAMTMADV AAMTHMOP AAMTPRVE AAMTPRVI AAMTPRVU AAMTOOP AAMTDISC AAMTOTH H_PTAPRM H_PTBPRM H_CPRM01-H_CPRM12 H_DPRM01-H_DPRM12;                                    
   IF evnttype = 'DU'           THEN OUTPUT DU;                                                        
   ELSE IF evnttype = 'FA'      THEN OUTPUT FA;                                                        
   ELSE IF evnttype = 'IU'      THEN OUTPUT IU;                                                        
   ELSE IF evnttype = 'HH'      THEN OUTPUT HH;                                                        
   ELSE IF evnttype = 'HP'      THEN OUTPUT HP;                                                        
   ELSE IF evnttype = 'IP'      THEN OUTPUT IP;                                                        
   ELSE IF evnttype = 'MP'      THEN OUTPUT MP;                                                        
   ELSE IF evnttype = 'OP'      THEN OUTPUT OP;                                                        
   ELSE IF evnttype = 'PM'      THEN OUTPUT PM;
   ELSE IF evnttype = 'HU'      THEN OUTPUT HU;                                                        
   ELSE IF evnttype = 'VU'      THEN OUTPUT VU;                                                        

RUN;              

%MACRO evt(x);                                                                                         
   DATA &x.1; SET &x;                                                                                  
      rename                                                                                           
         AAMTTOT  = &x.TOT   AAMTCARE = &x.CARE   AAMTCAID = &x.CAID                                   
         AAMTMADV = &x.MADV  AAMTHMOP  = &x.HMOP                                                                                           
         AAMTPRVE  = &x.PRVE AAMTPRVI = &x.PRVI   AAMTPRVU = &x.PRVU                                   
         AAMTOOP = &X.OOP    AAMTDISC  = &x.DISC  AAMTOTH  = &x.OTH                                     
      ;                                                                                                
   RUN;                                                                                                
%MEND;                                                                                                 
%evt(DU) %evt(FA) %evt(IU) %evt(HH) %evt(HP) %evt(IP) %evt(MP) %evt(PM) %evt(OP) %evt(HU) %evt(VU)   

* Create lables for expenditure variables; 

%LET typelist = du fa iu hh hp ip mp pm op hu vu;    
 
%MACRO setlabel ;                                                                                      
  %LET i=1 ;                                                                                           
  %LET typ=%SCAN(&typelist, &i ) ;                                                                     
  %DO %WHILE (&typ NE  ) ;                                                                             
      &typ.CARE   = "MEDICARE EXPENDITURE FOR %UPCASE(&typ) EVENT"                                     
      &typ.CAID   = "MEDICAID EXPENDITURE FOR %UPCASE(&typ) EVENT"                                     
      &typ.PRVI   = "PRIVATE INS. EXPENDITURE FOR %UPCASE(&typ) EVENT"                                 
      &typ.OOP    = "OUT-OF-POCKET EXPENDITURE FOR %UPCASE(&typ) EVENT"                                
      &typ.OTH    = "OTHER EXPENDITURE FOR %UPCASE(&typ) EVENT"                                        
      &typ.TOT    = "TOTAL EXPENDITURE FOR %UPCASE(&typ) EVENT"                                        
      %LET i = %EVAL(&i+1) ;                                                                           
      %LET typ=%SCAN(&typelist, &i) ;                                                                  
  %END ;                                                                                               
      TCARE    = 'TOTAL EXP. FOR ALL MEDICARE EVENTS'                                                  
      TCAID    = 'TOTAL EXP. FOR ALL MEDICAID EVENTS'                                                  
      TPRVI    = 'TOTAL EXP. FOR ALL PRIVATE INS. EVENTS'                                              
      TOOP     = 'TOTAL EXP. FOR ALL OOP EVENTS'                                                       
      TOTH     = 'TOTAL EXP. FOR ALL OTHER EVENTS'                                                     
      TTOTAL   = 'TOTAL EXPENDITURE FOR ALL EVENTS'
      PTC      = 'TOTAL PART C PREMIUM PAYMENTS'
      PTD      = 'TOTAL PART D PREMIUM PAYMENTS'
      TPREM    = 'TOTAL OVERALL PREMIUM PAYMENTS'
%MEND setlabel ;  

* Create final EXPENDITURE dataset and calculate aggregate expenditures by source of payment across all event types;
DATA intermed.expenditure;                                                                                    
	MERGE du1 fa1 iu1 hh1 hp1 ip1 mp1 op1 pm1 hu1 vu1;                                                          
	BY baseid;

	/*Medicare*/ 
	tcare  = SUM(ducare,facare,iucare,hhcare,hpcare,ipcare,mpcare,opcare,pmcare,hucare,vucare,
					dumadv ,famadv ,iumadv ,hhmadv ,hpmadv ,ipmadv ,mpmadv ,opmadv ,pmmadv, humadv, vumadv);                       

	/*Medicaid*/
	tcaid  = SUM(ducaid,facaid,iucaid,hhcaid,hpcaid,ipcaid,mpcaid,opcaid,pmcaid,hucaid,vucaid);                       

	/*Private*/
	tprvi  = SUM(duprvi,faprvi,iuprvi,hhprvi,hpprvi,ipprvi,mpprvi,opprvi,pmprvi,huprvi,vuprvi,
					duprve ,faprve ,iuprve ,hhprve ,hpprve ,ipprve ,mpprve ,opprve ,pmprve,huprve,vuprve,
					duprvu ,faprvu ,iuprvu ,hhprvu ,hpprvu ,ipprvu ,mpprvu ,opprvu ,pmprvu,huprvu,vuprvu,
					duhmop ,fahmop ,iuhmop ,hhhmop ,hphmop ,iphmop ,mphmop ,ophmop ,pmhmop,huhmop,vuhmop);                       

	/*OOP*/
	toop   = SUM(duoop ,faoop ,iuoop ,hhoop ,hpoop ,ipoop ,mpoop ,opoop ,pmoop ,huoop, vuoop);                       

	/*  UPDATE (2019): Removed all -va variables (duva, fava, iuva, etc.) as they are no longer
	                   present on the files.                                                    */
	/*All Other*/
	toth   = SUM(duoth ,faoth ,iuoth ,hhoth ,hpoth ,ipoth ,mpoth ,opoth ,pmoth ,huoth ,vuoth ,
					dudisc ,fadisc ,iudisc ,hhdisc ,hpdisc ,ipdisc ,mpdisc ,opdisc ,pmdisc ,hudisc, vudisc);                       

	/*Total*/
	ttotal = SUM(dutot ,fatot ,iutot ,hhtot ,hptot ,iptot ,mptot ,optot ,pmtot ,hutot ,vutot );

	/* Part C Premiums */
	PTC = sum(H_CPRM01, H_CPRM02, H_CPRM03, H_CPRM04, H_CPRM05, H_CPRM06, H_CPRM07, H_CPRM08, H_CPRM09, H_CPRM10, H_CPRM11, H_CPRM12);
	
	/* Part D Premiums */
	PTD = sum(H_DPRM01, H_DPRM02, H_DPRM03, H_DPRM04, H_DPRM05, H_DPRM06, H_DPRM07, H_DPRM08, H_DPRM09, H_DPRM10, H_DPRM11, H_DPRM12);
	
	/* Total Premiums */
	TPREM = sum(H_PTAPRM, H_PTBPRM, PTC, PTD);
	
	LABEL %setlabel ;     
	DROP H_PTAPRM H_PTBPRM H_CPRM01-H_CPRM12 H_DPRM01-H_DPRM12;
RUN;
