********************************************************************;
*  PROCESS PACKAGE SIZE SUBROUTINE                                 *;
********************************************************************;
PROC_PKG:;

NOT_FD = 1;

DO X=1 TO 11;
IF PK_CTR(X) NE 0 THEN DO;
NOT_FD = 0;

GO TO PASSED;
END;
END;

PASSED:;

IF PK_CTR(1) EQ . OR NOT_FD THEN DO;
GEN = 1;

RETURN;
END;

DO X=1 TO 3;
AUNIT(X) = '';
END;

AMT_FD = 0;
AMTNUM = I_AMTN;

********************************************************************;
*  PROCESS VOLUME UNITS AND AMOUNT                                 *;
*                                                                  *;
*  ALGORITHM SUPPLIED BY MCB                                       *;
********************************************************************;

IF NOT I_SUPN THEN DO;
IF I_AMTU EQ '2' THEN
AUNIT(1) = '3';
ELSE IF I_AMTU EQ '3' THEN
AUNIT(1) = '2';
ELSE IF I_AMTU EQ '1' THEN DO;
AMTNUM   = I_AMTN * 30;
AUNIT(1) = '2';
AUNIT(2) = '3';
END;
ELSE IF I_AMTU EQ '5' THEN DO;
AMTNUM   = I_AMTN / 1000;
AUNIT(1) = '3';
END;
ELSE IF I_AMTU EQ '6' THEN DO;
AMTNUM   = I_AMTN / 1000000;
AUNIT(1) = '3';
END;
END;
ELSE DO;
AMTNUM = I_SUPN;
AUNIT(1) = '1';
AUNIT(2) = '2';
AUNIT(3) = '3';
END;

DCD = I_DCODE;

********************************************************************;
*  LOOP FOR EACH DOSAGE FORM CODE (EXCLUDING 1 AND 10) - CODES ARE *;
*  REMAPPED TO ACCOUNT FOR DROPPED CODES                           *;
********************************************************************;
IF NOT DOS_FD THEN DO;
DOS_FL = 1;
IDX = 0;

IF I_AMTN GT 0 THEN DO;
DO X=1 TO 11;
DO Y=1 TO PK_CTR(X);
IF PK_PS(X,Y) EQ I_AMTN THEN DO;
IDX + 1;
TMP_ARR(IDX) = X;

GO TO NXT_PKG1;
END;
END;

NXT_PKG1:;

END;

MAX = IDX;

LINK PROC_RDM;

IF NOT RANDOM THEN
RANDOM = 1;

DCD = TMP_ARR(RANDOM);
END;
ELSE IF I_AMTU NE '' THEN DO;
DO X=1 TO 11;
DO Y=1 TO PK_CTR(X);
IF PK_DF(X,Y) EQ I_AMTU THEN DO;
IDX + 1;
TMP_ARR(IDX) = X;

GO TO NXT_PKG2;
END;
END;

NXT_PKG2:;

END;

MAX = IDX;

LINK PROC_RDM;

IF NOT RANDOM THEN
RANDOM = 1;

DCD = TMP_ARR(RANDOM);
END;

IF DCD GE 0 AND DCD LT 10 THEN
DCD + 1;
ELSE IF DCD EQ 9 THEN
DCD = 11;
ELSE IF DCD EQ 10 THEN
DCD = 12;
ELSE
DCD = 91;
END;

DO A=1 TO 11;
IF DCD GT 1 AND DCD LT 10 THEN
IDX = DCD - 1;
ELSE IF DCD EQ 11 THEN
IDX = 9;
ELSE IF DCD EQ 12 THEN
IDX = 10;
ELSE IF DCD EQ 91 THEN
IDX = 11;
ELSE
IDX = A;

********************************************************************;
*     ATTEMPT TO MATCH INPUT AMOUNT NUMBER AND AMOUNT UNIT AGAINST *;
*     ROLL-UP ARRAYS (PACKAGE SIZES AND DRUG FORMS) - RANDOMLY     *;
*     GENERATE STRENGTH AFTER SUCCESSFUL MATCH                     *;
*                                                                  *;
*  1) MATCH ON VOLUME AMOUNT AND UNITS                             *;
*  2) MATCH ON VOLUME AMOUNT                                       *;
*  3) MATCH ON VOLUME UNITS                                        *;
********************************************************************;
DO X=1 TO PK_CTR(IDX);
IF AMTNUM GT 0 AND AUNIT(1) NE '' THEN DO;
IF AMTNUM EQ PK_PS(IDX,X) AND
(AUNIT(1) EQ PK_DF(IDX,X) OR
AUNIT(2) EQ PK_DF(IDX,X) OR
AUNIT(3) EQ PK_DF(IDX,X)) THEN DO;
MAX = S2_CTR(IDX,X);

LINK PROC_RDM;

DO Y=1 TO S2_CTR(IDX,X);
IF RANDOM LE S2_CT(IDX,X,Y) THEN DO;
OTC_CD = S2_OTC(IDX,X,Y);
TEC_CD = S2_TEC(IDX,X,Y);
AWP    = S2_PR(IDX,X,Y);
DOSAGE = S2_DOS(IDX,X,Y);
I_DCODE = S2_COD(IDX,X,Y);
STRENGTH = S2_TP(IDX,X,Y);
AMT_FD   = IDX;

GO TO BRK_PKG;
END;
END;
END;
END;
ELSE IF AMTNUM GT 0 THEN DO;
IF AMTNUM EQ PK_PS(IDX,X) THEN DO;
MAX = S2_CTR(IDX,X);

LINK PROC_RDM;

DO Y=1 TO S2_CTR(IDX,X);
IF RANDOM LE S2_CT(IDX,X,Y) THEN DO;
OTC_CD = S2_OTC(IDX,X,Y);
TEC_CD = S2_TEC(IDX,X,Y);
AWP    = S2_PR(IDX,X,Y);
DOSAGE = S2_DOS(IDX,X,Y);
I_DCODE = S2_COD(IDX,X,Y);
STRENGTH = S2_TP(IDX,X,Y);
AMT_FD   = IDX;
AMT_FL   = 1;

GO TO BRK_PKG;
END;
END;
END;
END;
ELSE IF AUNIT(1) NE '' THEN DO;
IF AUNIT(1) EQ PK_DF(IDX,X) OR
AUNIT(2) EQ PK_DF(IDX,X) OR
AUNIT(3) EQ PK_DF(IDX,X) THEN DO;
MAX = S2_CTR(IDX,X);

LINK PROC_RDM;

DO Y=1 TO S2_CTR(IDX,X);
IF RANDOM LE S2_CT(IDX,X,Y) THEN DO;
OTC_CD = S2_OTC(IDX,X,Y);
TEC_CD = S2_TEC(IDX,X,Y);
AWP    = S2_PR(IDX,X,Y);
DOSAGE = S2_DOS(IDX,X,Y);
I_DCODE = S2_COD(IDX,X,Y);
STRENGTH = S2_TP(IDX,X,Y);
AMTNUM   = PK_PS(IDX,X);
AMT_FD   = IDX;
AMT_FL   = 1;

GO TO BRK_PKG;
END;
END;
END;
END;
END;

IF DOS_FD THEN
GO TO BRK_PKG;

DOS_FL = 1;
DOS_FD = 0;
DCD = 0;
END;

BRK_PKG:;

********************************************************************;
* UNSUCCESSFUL PREVIOUS MATCH - IF AN EXACT MATCH WAS PERFORMED ON *;
* DOSAGE FORM CODE, THEN RANDOMLY GENERATE PACKAGE SIZE AND        *;
* STENGTH, OTHERWISE GENERATE DOSAGE/PACKAGE SIZE/STRENGTH FOR     *;
* THE CURRENT FDA NAME BEING PROCESSED                             *;
********************************************************************;

IF AMT_FD THEN
/* GOOD MATCH */;
ELSE IF NOT AMT_FD AND DOS_FD THEN DO;
DCD = I_DCODE;

IF DCD GT 0 AND DCD LT 10 THEN
IDX = DCD - 1;
ELSE IF DCD EQ 11 THEN
IDX = 9;
ELSE IF DCD EQ 12 THEN
IDX = 10;
ELSE
IDX = 11;

MAX = PK_CT(IDX,PK_CTR(IDX),1);
AMT_FL = 1;
STR_FL = 1;

LINK PROC_RDM;

DO X=1 TO PK_CTR(IDX);
IF RANDOM LE PK_CT(IDX,X,1) THEN DO;
AMTNUM = PK_PS(IDX,X);

MAX = S2_CT(IDX,X,S2_CTR(IDX,X));

LINK PROC_RDM;

DO Y=1 TO S2_CTR(IDX,X);
IF RANDOM LE S2_CT(IDX,X,Y) THEN DO;
OTC_CD = S2_OTC(IDX,X,Y);
TEC_CD = S2_TEC(IDX,X,Y);
AWP    = S2_PR(IDX,X,Y);
DOSAGE = S2_DOS(IDX,X,Y);
I_DCODE = S2_COD(IDX,X,Y);
STRENGTH = S2_TP(IDX,X,Y);
AMTNUM   = PK_PS(IDX,X);
AMT_FD   = IDX;

GO TO BRK_PKG1;
END;
END;
END;
END;
END;
ELSE
GEN = 1;

BRK_PKG1:;

RETURN;

