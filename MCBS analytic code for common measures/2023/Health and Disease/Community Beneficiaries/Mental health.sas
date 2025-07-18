
/*Mental health*/

data work.mental;
 set survey.menthlth;

 /*Felt nervous, anxious, or on edge more than half or nearly every day in the past 2 weeks*/
if GADANXTY in (1,2) then NERVE = 1; /*Not at all or several days*/
else if GADANXTY in (3,4) then NERVE = 2;	/*More than half or nearly every day*/

/*Not able to stop or control worrying more than half or nearly every day in the past 2 weeks*/
if GADWORRY in (1,2) then WORRY = 1; /*Not at all or several days*/
else if GADWORRY in (3,4) then WORRY = 2;	/*More than half or nearly every day*/

/*Had trouble falling or staying asleep or sleeping too much more than half or nearly every day in the past 2 weeks*/
if PHQNOSLP in (1,2) then SLEEP_P = 1;	/*Not at all or several days*/
else if PHQNOSLP in (3,4) then SLEEP_P = 2;	/*More than half or nearly every day*/


/*New in 2023*/
/*Depression makes life somewhat, very, or extremely difficult*/
if PHQDIFF in (2:4)	then DEPRSDIF = 1;	/*Yes*/	
else if PHQDIFF = 1 or (GADANXTY in (1, ., .D, .R, .N) and GADWORRY in (1, ., .D, .R, .N) 
        and PHQNOINT in (1, ., .D, .R, .N) and PHQDEPRS in (1, ., .D, .R, .N) and PHQNOSLP in (1, ., .D, .R, .N) 
        and PHQTIRED in (1, ., .D, .R, .N) and PHQEATNG in (1, ., .D, .R, .N) and PHQFAILR = in (1, ., .D, .R, .N)) 	
        then DEPRSDIF = 2;	/*No*/

/*New in 2023*/
/*Felt lonely/socially isolated often or always in the past year*/	
if SOCISOLA in (4:5) then LONELY =  1;	/*Yes*/		
else if SOCISOLA in (1:3) then LONELY =  2;	/*No*/

run;





	
