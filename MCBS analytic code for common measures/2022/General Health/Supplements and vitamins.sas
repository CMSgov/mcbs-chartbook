
/*Dietary supplements and vitamins*/

data work.genhlth;
 set survey.genhlth;

/*Taken any dietary supplements in the past year*/
if DISUPPYR = 1	then DSUPP = 1;	 /*Yes*/	
else if DISUPPYR = 2 then DSUPP = 2; /*No*/		

run;	
