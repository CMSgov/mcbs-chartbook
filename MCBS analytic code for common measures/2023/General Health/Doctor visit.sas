/**Doctor's visit*/

data temp.visit;
 set survey.ACCSSMED;

 /*ER visit in the last year*/
 if D_ERVIST = 1 then VISITER = 1; /*ER visit in the past year*/
 else if D_ERVIST = 2 then VISITER = 2; /*No ER visit in the past year*/

 /*Outpatient visit in the last year*/
 if D_OPVIST = 1 the VISITOP = 1; /*Outpatient visit in the past year*/
 else if D_OPVIST = 2 the VISITOP = 2; /*No outpatient visit in the past year*/
run;


