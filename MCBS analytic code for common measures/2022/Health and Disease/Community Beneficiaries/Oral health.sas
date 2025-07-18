
/*Oral Health*/

data work.oral1;
 set survey.provcare;

 /*Ever had an oral cancer exam*/
 if BASKORAL = 1 then EVROMCNR = 1;	/*Yes, ever had an oral cancer exam*/	
else if BASKORAL = 2 then EVROMCNR = 2;	/*No oral cancer exam ever*/	

/*Had oral/mouth cancer exam in the past year*/
if OCCEXAM = 1 then	OCCEXAM_pyr = 1; /*Yes, had oral/mouth cancer exam in the past year*/
else if OCCEXAM in (2,3) or BASKORAL = 2 then OCCEXAM_pyr = 0;	/*No oral/mouth cancer exam in the past year*/

/*Had an annual wellness visit in the past year*/
if WELLNESS = 1	then WELLNESS_pyr = 1; /*Yes, had an annual wellness visit in the past year	*/
else if WELLNESS = 2 then WELLNESS_pyr = 2;	/*No annual wellness visit in the past year	*/

run;

data work.oral2;
 set survey.accssmed;

 /*Ever unable to get dental care (any reason)*/
 if DVNEED = 1 then NODNTANY = 1;	/*Yes*/
else if DVNEED = 2	then NODNTANY = 2;	/*No*/	

/*Ever unable to get dental care (because of cost)*/
if DVNDCOST = 1	then NODNTCST = 1;	/*Yes*/	
else if DVNDCOST = 0 or DVNEED = 2	then NODNTCST = 2;	/*No*/	

run;	


data work.oral3;
 set survey.nagidis;

 /*Trouble eating solid food because of teeth*/
 if FOODTRBL in (2,3)	then FOOD_P = 1;	/*Yes*/	
else if FOODTRBL = 1 then FOOD_P = 2;	/*No*/	

/*Has lost all natural teeth*/
if DISTEETH = 1 then TEETH_L = 1;	/*Yes*/	
else if DISTEETH = 2 then TEETH_L = 2;	/*No*/	

run;

data work.oral4;
set survey.chrnpain;

/*Has chronic tooth pain*/
if PAINOFTN in (2,3,4) and PAINTOTH in (2,3,4)	then TOOTH_P = 1;	/*Yes*/	
else if PAINOFTN = 1 or PAINTOTH = 1 then TOOTH_P = 2;	/*No*/	

run;





	

	

