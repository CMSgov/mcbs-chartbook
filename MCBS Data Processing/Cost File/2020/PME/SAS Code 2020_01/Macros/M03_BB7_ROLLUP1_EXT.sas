********************************************************************;
*  READ BLUEBOOK COMBINED FILE - EXTRACT VARIABLES REQUIRED FOR    *;
*  THE ROLL-UP FILE                                                *;
********************************************************************;

DATA ALL(KEEP=BBPR CL D DF BN FDA_NM CLAIMS PS STR DCODE1 DCODE2 DCODE3 SN1 SN2 SU1 SU2 GTC)
      STR(KEEP=BBPR CL D DF BN FDA_NM CLAIMS PS STR DCODE1 DCODE2 DCODE3 SN1 SN2 SU1 SU2 GTC)
      PKG(KEEP=BBPR CL D DF BN FDA_NM CLAIMS PS STR DCODE1 DCODE2 DCODE3 SN1 SN2 SU1 SU2 GTC);

SET MCBSDATA.MERGED_ALL_&CURRYEAR;;
OUTPUT ALL;
IF DCODE1 EQ 1 OR DCODE1 EQ 10 THEN OUTPUT STR;
ELSE OUTPUT PKG;
RUN;
********************************************************************;
*  SORT "STR" AND "PKG" BY NFDA_NM                                 *;
********************************************************************;
PROC SORT DATA=ALL OUT=MCBSDATA.NEWBLUE_ALL;BY BN;RUN;

PROC SORT DATA=STR OUT=MCBSDATA.NEWBLUE_STR;BY BN;RUN;

PROC SORT DATA=PKG OUT=MCBSDATA.NEWBLUE_PKG;BY BN;RUN;

PROC DELETE DATA=ALL;RUN;

PROC DELETE DATA=STR;RUN;

PROC DELETE DATA=PKG;RUN;

