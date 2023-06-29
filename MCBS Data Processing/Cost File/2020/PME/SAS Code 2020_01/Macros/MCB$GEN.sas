********************************************************************;
*  GENERATE DOSAGES AND STRENGTHS (THERE WAS NOT A PREVIOUS MATCH  *;
*  MATCH ON DOSAGE FORM/PACKAGE SIZE) - DEPENDING ON WHICH DOSAGE  *;
*  FORM IS GENERATED (PROC_DOS) SELECT STRENGTHS OR PACKAGE SIZE   *;
*  PATHS                                                           *;
********************************************************************;
PROC_GEN:;

DOS_FD = 0;
DOS_FL = 1;

LINK PROC_DOS;

********************************************************************;
*  IF INPUT DOSAGE FORM CODE IS "1" OR "10" (TABLET, CAPSULE, ETC.)*;
*  THEN SELECT ONE PATH OF "ROLL-UP" RECORDS, OTHERWISE TAKE THE   *;
*  PATH INCLUDING PACKAGE SIZE AND DRUG FORM CODE                  *;
********************************************************************;
IF I_DCODE EQ 1 OR I_DCODE EQ 10 THEN DO;
STR_FL = 1;
LINK PROC_STR;
END;
ELSE DO;
AMT_FL = 1;
STR_FL = 1;
LINK PROC_PKG;
END;

RETURN;

