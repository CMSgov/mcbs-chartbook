/******************************************************************************************************/
/*** CODE: Cost Supplement File Utilization					                                    ***/
/*** OBJECTIVE: Create utilization measures using LDS CS file data.                                 ***/
/******************************************************************************************************/

/*
Event type:
	DU Dental
	FA Facility
	HH Home health
	HP Hospice
	IP Inpatient
	IU Institutional utilization
	MP Medical provider
	OP Outpatient
	PM Prescribed medicine
	HU Hearing
	VU Vision
*/

/*-----------COMMUNITY----------------------*/

%MACRO getdata ;   
 
%LET typelist=ip op mp du pm hh hp fa iu hu vu;                                                                       
%LET userlist=ipuser  opuser  mpuser  duuser  pmuser  hhuser  hpuser  nhuser fauser iuuser huuser vuuser;                     
%LET usectlst=ipusect opusect mpusect duusect pmusect hhusect hpusect nhusect fausect iuusect huusect vuusect;                  
  
* Create a flag and counter for each type of event;

  DATA tempcs.ss1 ;
	/*TEMPORARY: USE RICSS FROM 2013 FOR TESTING*/ 
     SET cs&mcbsyear..ss ( KEEP = baseid evnttype aevents ) ;                                                     
     BY baseid;                                                                                                  
     LENGTH &userlist &usectlst 3.;      
 
    %DO i = 1 %TO 11 ;                                                                                            
      %LET evtyp=%SCAN(&typelist,&i);                                                                            
      IF evnttype="%UPCASE(&evtyp)" THEN DO ;                                                                    
         IF aevents > 0 THEN DO ;                                                                                
          &evtyp.user  = 1 ;                                                                                     
         END ;                                                                                                   
         ELSE DO ;                                                                                               
         &evtyp.user  = 0 ;                                                                                      
         END ;                                                                                                   
         &evtyp.usect = aevents ;                                                                                
         LABEL &evtyp.USER   = "EVER A USER OF %UPCASE(&evtyp) EVENT"                                            
               &evtyp.USECT  = "TOTAL NUMBER OF %UPCASE(&evtyp) EVENT" ;                                         
      END ;                                                                                                      
      
 	%END;

     IF evnttype IN ('FA','IU') THEN DO ;                                                                        
      IF aevents > 0 THEN DO ;                                                                                   
        nhuser = 1;                                                                                              
      END ;                                                                                                      
      ELSE DO ;                                                                                                  
        nhuser = 0;                                                                                              
      END ;                                                                                                      
      nhusect =  aevents ;                                                                                       
      LABEL nhuser   = 'EVER A USER OF FA,IU EVENT'                                                              
            nhusect  = 'TOTAL NUMBER OF FA,IU EVENT' ;                                                           
     END;                                                                                                        
  RUN;          


 * Reshape dataset from long to wide with a variable for each event type and a row for each unique baseid ;
  PROC SUMMARY DATA = tempcs.ss1;                                                                                       
     var &userlist &usectlst ;                                                                                   
     BY baseid;                                                                                                  
     OUTPUT out = tempcs.user_ss  SUM = &userlist &usectlst ;      
  RUN;

  DATA tempcs.user_community;
  SET tempcs.user_ss;
  if nhuser > 1 then nhuser =1;
  run;

%mend;

 %getdata;

/*-----------FACILITY----------------------*/

/* For facility beneficiaries, there are concerns that the overall summary data files undercount
 the real number of events that facility beneficiaries use. Thus, we bring in the raw facility
 events file to supplement the Cost Supplement Service Summary (SS) file.

 First, we create an imputed flag for medical practitioner (physician/supplier) visits for facility beneficiaries
 if they have had any visits to one of 5 provider types.

 Then, if the facility events (FAE) file has a beneficiary using either OP or dental services, we update the downstream
 file with the corrected number of events */

 /*TEMPORARY: USE RICFAE */
  DATA tempcs.fae ;                                                                                             
    SET cs&mcbsyear..fae ( KEEP = baseid dentnum opnum mdnum mhnumvis opthlflg optomflg podiaflg );
    ARRAY numcnt 4 opthlflg optomflg podiaflg ;                                                                  
    DO OVER numcnt ;                                                                                             
       IF numcnt NE 1 THEN numcnt = 0 ;                                                                          
    END ;                                                                                                        
    LENGTH mpnum 3 ;  

/* Identify all Medical practioner visits based on any visits to MD, Podiatrist, Ophtalmologist, 
  Optometrist, or Mental health professional
*/

    IF mdnum GE 1 OR mhnumvis GE 1 THEN mpnum = SUM ( OF mdnum mhnumvis  ) ;                                     
    ELSE mpnum = SUM ( OF opthlflg optomflg podiaflg ) ;                                                         
  RUN ;                                                                                                          


* Convert flags to counts for all event types except drug events. Use imputed flags for 
  Medical practitioner visits and ER visits;

 
  DATA tempcs.user_facility( KEEP = baseid opcnt_f mpcnt_f ducnt_f opcnt mpcnt ducnt) ;                    
    SET tempcs.fae ;                                                                                            
    BY baseid ;                                                                                                  
    RETAIN opcnt mpcnt ducnt ;                                                                             
    IF first.baseid THEN DO ;                                                                                                                                                                           
       opcnt = 0 ;                                                                                               
       mpcnt = 0 ;                                                                                               
       ducnt = 0 ;                                                                                               
    END ;
	/*Comment-out this section to remove adjustment; in &mcbsyear. Chartbook, adjustment is immaterial, since tables/exhibits for OP, MP, and DU will be restricted to Community-only beneficiaries*/ 
    ducnt + dentnum ;                                                                                            
    opcnt + opnum ;                                                                                              
    mpcnt + mpnum ;                                                                                              
    IF last.baseid ;                                                                                                                                                                         
    IF opcnt > 0 THEN opcnt_f = 1 ;                                                                              
    IF mpcnt > 0 THEN mpcnt_f = 1 ;                                                                              
    IF ducnt > 0 THEN ducnt_f = 1 ;                                                                              
  RUN ; 

* Merge event flags and counts from Service Summary and Facility Event Data; 
                                                                                             
DATA intermed.utilization/*UNADJUSTED*/ ( KEEP = baseid /*type*/ ipuser  opuser  mpuser  duuser  pmuser  hhuser  hpuser  nhuser fauser iuuser huuser vuuser ipusect opusect mpusect duusect pmusect hhusect hpusect nhusect fausect iuusect huusect vuusect anyuser otheruser x y) ;                                      
    MERGE tempcs.user_facility ( IN = a )                                                                                     
          tempcs.user_community ( IN = b ) ;                                                                                   
    BY baseid ;                                          
	x = a;
	y = b;
                                                        
/*---- Outpatient usage flag OPUSER -----------------------------------------------------------------------------*/

    IF opuser = 0 AND opcnt_f = 1 THEN opuser = 1 ;  * If RIC FAE facility events file indicates OP event;                                                              

/*----------------------------------------------------------------------------------------------------------------*/


/*---- Medical Practioner usage flag MPUSER ---------------------------------------------------------------------*/

    IF mpuser = 0 AND mpcnt_f = 1 THEN mpuser = 1 ;    * If RIC FAE facility events file indicates MD, Podiatrist, Ophtalmologist, Optometrist, or Mental health professional encounter;                                                           

/*----------------------------------------------------------------------------------------------------------------*/


/*---- Dental Services usage flag DUUSER ---------------------------------------------------------------------*/

	IF duuser = 0 AND ducnt_f = 1 THEN duuser = 1 ;   * If RIC FAE facility events file indicates Dental encounter;                                                           

/*----------------------------------------------------------------------------------------------------------------*/
                                                                   

/*---- Update Counts based on total sum of events sourced from RIC SS and RIC FAE ---------------------------------------*/
                                                                
    mpusect = SUM ( OF mpusect mpcnt ) ;                                                                         
    opusect = SUM ( OF opusect opcnt ) ;                                                                         
    duusect = SUM ( OF duusect ducnt ) ;                                                                         

/*----------------------------------------------------------------------------------------------------------------*/

	if ipuser OR opuser OR mpuser OR duuser OR pmuser OR hhuser OR hpuser OR nhuser OR fauser OR iuuser OR vuuser OR huuser then anyuser=1;
	else anyuser=0;

	if hhuser OR hpuser OR nhuser OR fauser OR iuuser OR vuuser OR huuser then otheruser=1;
	else otheruser=0;

	LABEL                                                                   
		  x = 'FACILITY RESPONDENT'
 		  y	= 'COMMUNITY RESPONDENT'
		  anyuser="Ever User of Any Service"
		  otheruser="Ever User of Other Services";
		  	

  RUN ;       


 

           
