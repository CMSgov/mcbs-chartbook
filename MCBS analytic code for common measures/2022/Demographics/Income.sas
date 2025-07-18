/******************************************************************************************************/																		
/*** CODE: Create Income measure using LDS segments                                                 ***/
/******************************************************************************************************/

data tempf.demographics;
	set survey.demo;

/*----------- Income -------------------------------------------*/

if income = .  | income = .N | 
   income = .R | income = .D       then beneinc = .;   /* Missing */
else if income in (1:5)            then beneinc = 1;   /* Less than $25,000 */  
else if income in (6:8)            then beneinc = 2;   /* $25,000-$49,999 */ 
else if income in (9:11)           then beneinc = 3;   /* $50,000-$99,999 */
else if income in (12:14)          then beneinc = 4;   /* $100,0000 + */       
else                              	    beneinc = 999; /* Undefined */

run;
