*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 04_BB2_ROLLUP                                                           |
|      UPDATED: 01/21/2011                                                              |
|  INPUT FILES: MERGED_ALL_&CURRYEAR                                                    |
| OUTPUT FILES: TEMP_DOS, TEMP_STR, TEMP_PKG,  ROLLUP_ALL                               |
|  DESCRIPTION: Runs the Legacy "Rollup" programs for dose, strength, and package.      |
|               Note, these are located in a seperate MACRO folder.                     |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear  =20;
%let LastYear  =19;
%let fdbdate   =20210310_wac;         * This is the FDB/NDDF file date;


%let location= C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
%LET MACRO_LOC=C:\Users\S1C3\RIC PME\MCBS\2020\PME\SAS Code 2020\Macros\; /*UPDATE*/
libname  MCBSDATA "&location";
FILENAME INCLIB   "&MACRO_LOC";


%INC INCLIB(
 M03_BB7_ROLLUP1_EXT,
 M03_BB7_ROLLUP2_DOS,
 M03_BB7_ROLLUP3_STR,
 M03_BB7_ROLLUP4_PKG,
 M03_BB7_ROLLUP5_ALL
)/ source2; 
*note /source2 writes included code to the SAS log; 
