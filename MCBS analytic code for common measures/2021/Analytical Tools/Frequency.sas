/**
Below is the SAS code you need to create an analytic file that includes the Survey File variables, as well
as the topical continuously enrolled weights and replicate weights, required to analyze food insecurity
for Medicare beneficiaries living in the community aged 65 and over by income.

The Survey File and Cost Supplement File both contain weight segments. However, it is important to
note that users conducting joint analysis of both Survey File and Cost Supplement File data must use
the Cost Supplement File weights. Users analyzing Survey File data separately should use the Survey
File weights. Further, to generate estimates using the data from one of the Topical Questionnaire sections on their
own or merged with another segment, researchers must always use the special non-response adjustment general 
and replicate weights included in the Topical segment INSTEAD of using the weights
that appear in the separate weight segments. See detailed information in MCBS Tutorial:
https://www.cms.gov/research-statistics-data-and-systems/research/mcbs/downloads/mcbs_tutorial.pdf

**/

/*To produce estimates that are representative of the continuously enrolled population, you need to limit your dataset
to the continuously enrolled population in the FOODINS segment.**/
data food_inc_merged;
merge surveyYY.FOODINS (in=a keep=BASEID
AFFDMEAL SKIPMEAL FDSCWT FDSC1-FDSC100)
surveyYY.DEMO (keep=BASEID INCOME INCOME_H
INT_TYPE H_AGE);
by BASEID;
if a and FDSCWT^=. then output;
run;

/**Recoding Variables**/
data food_inc_recode;
set food_inc_merged;
if INCOME in (1,2,3,4,5) then INCOME_GROUP=1; else INCOME_GROUP=2;
if AFFDMEAL in (1,2) then AFFORD=1; else if AFFDMEAL=3 then AFFORD=2;
run;

/**In order to restrict the file to beneficiaries living in the community ages 65 and over, segment the file on
the variables INT_TYPE and H_AGE.**/
data food_inc_final;
set food_inc_recode;
where INT_TYPE='C' and H_AGE GE 65;
run;

/**The following code requests the frequencies of beneficiaries living in the community aged 65 and over who
experience food insecurity by income using the BRR method for variance estimation.**/
proc surveyfreq data= food_inc_final varmethod=brr (fay=.30);
table INCOME_GROUP*(AFFORD SKIPMEAL) / row;
weight FDSCWT;
repweights FDSC1-FDSC100;
run;
