
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

run;





	
