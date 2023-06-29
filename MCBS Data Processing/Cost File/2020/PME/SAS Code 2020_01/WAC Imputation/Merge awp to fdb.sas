libname FDB 'Y:\Share\SMAG\MCBS\MCBS PM\AWP Imputation\2020';
run;

/*The first program below is used to merge the original FBD file with partial WAC to Lupings imputed WAC file*/
/*This is the last program to be run in the AWP Imputation process - 4 of 4*/
/*Program 1 (WAC 4 in documentation)*/

/*Maggie's FDB file with missing AWP and partial WAC--Drop the incomplete WAC (WHN) variable*/
data FDB2021 (drop=WHN BBPR bbx_c01 bbx_c01 bbx_c02 bbx_c03 bbx_c04 bbx_c05 bbx_c06 bbx_c07 bbx_c08
bbx_p01 bbx_p02 bbx_p03 bbx_p04 bbx_p05 bbx_p06 bbx_p07 bbx_p08);
set FDB.fdb_20210310_partial_WAC; **UPDATED 1/18/2022***
proc sort;
by ndc;
run;

/*Luping's imputed WAC file -- rename PRICE variable to WAC_PRICE*/
DATA FDBImpute;     
SET FDB.fdb_wac_imputed_2020 (keep=NDC PRICE); 
RENAME PRICE=BBPR;
PROC SORT;                         
BY NDC;
run;

/*New FDB to be used for the 2020 RIC PME with complete WAC pricing*/
Data FDB.FDB_202103010_WAC; ***UPDATED 1/18/2022**;
MERGE FDB2021 (in=a) 
	  FDBImpute (in=b);   
 BY ndc;
 if a;
run;


****************************************************************************************;

/*Program 2*/ /*WAC 1 in documentation*/
/*This is the first program to be run in the AWP Imputation process - 1 of 4*/
/*Other program -- using previous years FDB to populate WAC for current year*/
libname FDB2019 'Y:\Share\SMAG\MCBS\MCBS PM\AWP Imputation\2020';
libname FDB2020 'Y:\Share\SMAG\MCBS\MCBS PM\AWP Imputation\2020';
run;

/*Maggie's 2019 FDB file with WAC*/
data FDB2019;
set FDB2019.fdb_20200305_wac;
RENAME BBPR=BBPR19;  
proc sort;
by ndc;
run;

/*Maggie's 2020 FDB file with partial WAC -- drop BBPR*/
DATA FDB2020 (drop=bbpr);     
SET FDB2020.fdb_20210310_partial_WAC; /*rename FDB file to this*/ 
RENAME WHN=BBPR20;
PROC SORT;                         
BY NDC;
run;

/*New FDB to be used for the 2019 RIC PME with complete WAC pricing*/
Data FDB2020.fdb_with_last_years_WAC_merged;
MERGE FDB2019 (in=a) 
	  FDB2020 (in=b);   
 BY ndc; if b then output;

run;
