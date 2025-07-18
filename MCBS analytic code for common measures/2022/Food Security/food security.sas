
/*Fodd security*/
data work.food_ins;
 set survey.foodins;

 /*Food insecure*/
if HUNGRY = 1 or EATLESS = 1 or SKIPMEAL = 1 or AFFDMEAL in(1, 2) or FOODLAST in (1, 2)	then FOOD_INS = 1;	/*Yes*/	
else if HUNGRY in (.D, .N, .R, 2) and EATLESS in (.D, .N, .R, 2) and SKIPMEAL in (.D, .N, .R, 2) 
        and AFFDMEAL in (.D, .N, .R, 3) and FOODLAST in (.D, .N, .R, 3)	then FOOD_INS = 2;	/*No*/	

/*Food didn't last and no money to buy more*/
if FOODLAST in (1, 2) then NOFDMN = 1; /*Yes*/	
else if FOODLAST = 3 then NOFDMN = 2;	/*No*/

/*Cut size of meals or skip meals*/
if SKIPMEAL = 1	then CUTSKIP = 1; /*Yes*/	
else if SKIPMEAL = 2 then CUTSKIP = 2;	/*No*/

/*Eat less because not enough money for food*/
if EATLESS = 1	then LESSNMON = 1; /*Yes*/		
else if EATLESS = 2	then LESSNMON = 2;	/*No*/

/*Didn't eat because not enough money for food*/
if	HUNGRY = 1	then NOTEATMN = 1; /*Yes*/		
else if HUNGRY = 2	then NOTEATMN = 2;	/*No*/	

/*Couldn't afford balanced meals*/
if AFFDMEAL in(1, 2) then CNTAFDML = 1; /*Yes*/		
else if AFFDMEAL = 3 then CNTAFDML = 2;	/*No*/

/*New from 2023: Receives SNAP*/
if	SNAPBNFT = 1 then SNAP = 1; /*Yes*/	
else if SNAPBNFT = 2 then SNAP = 2;	/*No*/	

run;	
