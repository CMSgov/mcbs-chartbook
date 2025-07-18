*******************************************************************************
*  CODE: Create Chronic Pain measures using LDS segments				   	  *
*  This section uses the following Survey File segments: CHRNPAIN             *
******************************************************************************;

DATA PAIN;
set survey.CHRNPAIN;


/*------------Frequency of chronic pain---------------------------*/
		
if (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_FREQ = .; 		/*Missing*/	
else if PAINOFTN = 1 then PAIN_FREQ = 1;					/*Never*/		
else if PAINOFTN = 2 then PAIN_FREQ = 2;					/*Some days*/	
else if PAINOFTN = 3 then PAIN_FREQ = 3;					/*Most days*/	
else if PAINOFTN = 4 then PAIN_FREQ = 4;					/*Every day*/
else PAIN_FREQ = 999; 										/*Undefined*/	

	
/*------------Amount of pain---------------------------*/

if (PAINAMNT = .  | PAINAMNT = .N | 
	PAINAMNT = .R | PAINAMNT = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_AMT = .; 			/*Missing*/
else if PAINAMNT = 1 and PAINOFTN in (2,3,4) then PAIN_AMT = 1;	/*A little*/	
else if PAINAMNT = 2 and PAINOFTN in (2,3,4) then PAIN_AMT = 2;	/*A lot*/		
else if PAINAMNT = 3 and PAINOFTN in (2,3,4) then PAIN_AMT = 3;	/*Somewhere between a little and a lot*/		
else if PAINOFTN = 1 then PAIN_AMT = 4;							/*Does not have chronic pain*/		
else PAIN_AMT = 999; 											/*Undefined*/	


/*------------Pain limits life/work activities---------------------------*/
	
if (PAINLIMT = .  | PAINLIMT = .N | 
	PAINLIMT = .R | PAINLIMT = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_LIMT = .; 				/*Missing*/
else if PAINLIMT = 1 and PAINOFTN in (2,3,4) then PAIN_LIMT = 1;	/*Never*/		
else if PAINLIMT = 2 and PAINOFTN in (2,3,4) then PAIN_LIMT = 2;	/*Some days*/		
else if PAINLIMT = 3 and PAINOFTN in (2,3,4) then PAIN_LIMT = 3;	/*Most days*/		
else if PAINLIMT = 4 and PAINOFTN in (2,3,4) then PAIN_LIMT = 4;	/*Every day*/
else if PAINOFTN = 1 then PAIN_LIMT = 5;							/*Does not have chronic pain*/	
else PAIN_LIMT = 999; 												/*Undefined*/	
	

/*------------Pain affects family/significant others---------------------------*/	

if (PAINFAM = .   | PAINFAM = .N | 
	PAINFAM = .R  | PAINFAM = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_FAM = .; 			/*Missing*/
else if PAINFAM = 1 and PAINOFTN in (2,3,4)	then PAIN_FAM = 1;	/*Never*/		
else if PAINFAM = 2 and PAINOFTN in (2,3,4)	then PAIN_FAM = 2;	/*Some days*/		
else if PAINFAM = 3 and PAINOFTN in (2,3,4)	then PAIN_FAM = 3;	/*Most days*/		
else if PAINFAM = 4 and PAINOFTN in (2,3,4)	then PAIN_FAM = 4;	/*Every day*/		
else if PAINOFTN = 1 then PAIN_FAM = 5;							/*Does not have chronic pain*/	
else PAIN_FAM = 999; 											/*Undefined*/		


/*------------Can manage pain so that they can do the things they enjoy---------------------------*/	

if (PAINMANG = .  | PAINMANG = .N | 
	PAINMANG = .R | PAINMANG = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_MANG = .; 			/*Missing*/
else if PAINMANG = 1 and PAINOFTN in (2,3,4)	PAIN_MANG = 1;	/*Not at all*/		
else if PAINMANG = 2 and PAINOFTN in (2,3,4)	PAIN_MANG = 2;	/*A little*/		
else if PAINMANG = 3 and PAINOFTN in (2,3,4)	PAIN_MANG = 3;	/*A lot*/ 		
else if PAINMANG = 4 and PAINOFTN in (2,3,4)	PAIN_MANG = 4;	/*Somewhere between a little and a lot*/ 		
else PAIN_MANG = 999; 											/*Undefined*/


/*------------Uses physical/occupational therapy to manage pain---------------------------*/	

if (MANGPHYS = .  | MANGPHYS = .N | 
	MANGPHYS = .R | MANGPHYS = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_PT = .; 				/*Missing*/
else if MANGPHYS = 1 and PAINOFTN in (2,3,4) then PAIN_PT = 1;		/*Yes*/	
else if MANGPHYS in (2,3) and PAINOFTN in (2,3,4) then PAIN_PT = 2;	/*No*/
else PAIN_PT = 999; 												/*Undefined*/
	

/*------------Has chronic back pain---------------------------*/	

if (PAINBACK = .  | PAINBACK = .N | 
	PAINBACK = .R | PAINBACK = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_BACK = .; 					/*Missing*/
else if PAINBACK in (2,3,4) and PAINOFTN in (2,3,4) then PAIN_BACK = 1;	/*Yes*/	
else if PAINBACK = 1 or PAINOFTN = 1 then PAIN_BACK = 2;				/*No*/
else PAIN_BACK = 999; 													/*Undefined*/
	

/*------------Has chronic hand, arm, or shoulder pain---------------------------*/		

if (PAINARMS = .  | PAINARMS = .N | 
	PAINARMS = .R | PAINARMS = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_ARM = .; 					/*Missing*/
else if PAINARMS in (2,3,4) and PAINOFTN in (2,3,4) then PAIN_ARM = 1;	/*Yes*/	
else if PAINARMS = 1 or PAINOFTN = 1 then PAIN_ARM = 2;					/*No*/
else PAIN_ARM = 999; 													/*Undefined*/
	

/*------------Has chronic hip, knee, or foot pain---------------------------*/	

if (PAINLEGS = .  | PAINLEGS = .N | 
	PAINLEGS = .R | PAINLEGS = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_LEG = .; 					/*Missing*/
else if PAINLEGS in (2,3,4) and PAINOFTN in (2,3,4) then PAIN_LEG = 1;	/*Yes*/	
else if PAINLEGS = 1 or PAINOFTN = 1 then PAIN_LEG = 2;				/*No*/
else PAIN_LEG = 999; 													/*Undefined*/
	

/*------------Has chronic headache, migraine, or facial pain---------------------------*/	

if (PAINHEAD = .  | PAINHEAD = .N | 
	PAINHEAD = .R | PAINHEAD = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_HEAD = .; 					/*Missing*/
else if PAINHEAD in (2,3,4) and PAINOFTN in (2,3,4) then PAIN_HEAD = 1;	/*Yes*/	
else if PAINHEAD = 1 or PAINOFTN = 1 then PAIN_HEAD = 2;				/*No*/
else PAIN_HEAD = 999; 													/*Undefined*/
	

/*------------Has chronic abdominal, pelvic, or genital pain---------------------------*/	

if (PAINABDM = .  | PAINABDM = .N | 
	PAINABDM = .R | PAINABDM = .D) AND
   (PAINOFTN = .  | PAINOFTN = .N | 
	PAINOFTN = .R | PAINOFTN = .D) then PAIN_ABDM = .; 					/*Missing*/
else if PAINABDM in (2,3,4) and PAINOFTN in (2,3,4) then PAIN_ABDM = 1;	/*Yes*/	
else if PAINABDM = 1 or PAINOFTN = 1 then PAIN_ABDM = 2;				/*No*/
else PAIN_ABDM = 999; 													/*Undefined*/
		
