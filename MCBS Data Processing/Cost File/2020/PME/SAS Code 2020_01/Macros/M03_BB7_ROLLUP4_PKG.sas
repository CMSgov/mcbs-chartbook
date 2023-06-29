********************************************************************;
*  PROCESS "ROLL-UP" PACKAGE/STRENGTH RECORDS                      *;
********************************************************************;


DATA MCBSDATA.TEMP_PKG
(KEEP=BN FDA_NM S2CT1-S2CT99 S2TP1-S2TP99 S2COD1-S2COD99 S2DOS1-S2DOS99 
      PKCT1-PKCT66 PKPS1-PKPS33 PKDF1-PKDF33 S2TEC1-S2TEC99 S2OTC1-S2OTC99 
      S2PR1-S2PR99 PKCTR1-PKCTR11 S2CTR1-S2CTR33 RANG1-RANG22);

SET MCBSDATA.NEWBLUE_PKG;
BY BN;

ARRAY RANG    {11,2}        4.   RANG1-RANG22;
ARRAY PK_CT   {11,3,2}      4.   PKCT1-PKCT66;
ARRAY PK_PS   {11,3}        4.   PKPS1-PKPS33;
ARRAY PK_DF   {11,3}        $1.  PKDF1-PKDF33;
ARRAY S2_CT   {11,3,3}      4.   S2CT1-S2CT99;
ARRAY S2_TP   {11,3,3}      $10. S2TP1-S2TP99;
ARRAY S2_COD  {11,3,3}      3.   S2COD1-S2COD99;
ARRAY S2_DOS  {11,3,3}      $10. S2DOS1-S2DOS99;
ARRAY S2_TEC  {11,3,3}      $3   S2TEC1-S2TEC99;
ARRAY SP_TEC  {11,3,3,3}    $3   SPTC1-SPTC297;
ARRAY SC_TEC  {11,3,3,3}    3.   SCTC1-SCTC297;
ARRAY S2_OTC  {11,3,3}      $3   S2OTC1-S2OTC99;
ARRAY SP_OTC  {11,3,3,3}    $3   SPOT1-SPOT297;
ARRAY SC_OTC  {11,3,3,3}    3.   SCOT1-SCOT297;
ARRAY S2_PR   {11,3,3}      4.   S2PR1-S2PR99;

ARRAY DCODE   {3}       3.   DCODE1-DCODE3;
ARRAY STRNUM  {2}       8.   SN1-SN2;
ARRAY STRUN   {2}     $10.   SU1-SU2;
ARRAY PK_CTR  {11}      3.   PKCTR1-PKCTR11;
ARRAY S2_CTR  {11,3}    3.   S2CTR1-S2CTR33;
ARRAY SPT_CTR {11,3,3}  3.   SPTCT1-SPTCT99;
ARRAY SPO_CTR {11,3,3}  3.   SPOCT1-SPOCT99;

RETAIN S2CT1-S2CT99       SCTC1-SCTC297    SCOT1-SCOT297
S2PR1-S2PR99       S2CTR1-S2CTR33   SPTCT1-SPTCT99
SPOCT1-SPOCT99     S2COD1-S2COD99   PKCT1-PKCT66
PKPS1-PKPS33       PKCTR1-PKCTR11   RANG1-RANG22 0;

RETAIN MAX3 3;

RETAIN S2TP1-S2TP99       SPTC1-SPTC297    SPOT1-SPOT297
S2DOS1-S2DOS99     PKDF1-PKDF33;

********************************************************************;
*  DO NOT PROCESS TABLETS/CAPSULES (DCODE=1) OR ADHESIVES/PAD (10) *;
********************************************************************;

IF DCODE1 EQ 1 OR DCODE1 EQ 10 THEN DELETE;

IF FIRST.BN THEN DO;
DO X=1 TO 11;
PK_CTR(X) = 0;

DO Y=1 TO 2;
RANG(X,Y) = 0;
END;
END;

********************************************************************;
*     INITIALIZE VARIABLES (11 POTENTIAL DOSAGE CODES - EXCLUDING  *;
*     1 AND 10, WHICH WOULD MAKE 13)                               *;
********************************************************************;

DO X=1 TO 11;
DO Y=1 TO MAX3;
S2_CTR(X,Y) = 0;
PK_PS(X,Y) = 0;
PK_DF(X,Y) = '';
PK_CT(X,Y,1) = 0;PK_CT(X,Y,2) = 0;

DO Z=1 TO MAX3;
S2_CT(X,Y,Z)  = 0;
S2_TP(X,Y,Z)  = '';
S2_PR(X,Y,Z)  = 0;
S2_TEC(X,Y,Z) = '';
S2_OTC(X,Y,Z) = '';
S2_COD(X,Y,Z) = 0;
S2_DOS(X,Y,Z) = '';
SPT_CTR(X,Y,Z) = 0;
SPO_CTR(X,Y,Z) = 0;

DO A=1 TO MAX3;
SP_TEC(X,Y,Z,A) = '';
SC_TEC(X,Y,Z,A) = 0;
SP_OTC(X,Y,Z,A) = '';
SC_OTC(X,Y,Z,A) = 0;
END;
END;
END;
END;
END;

********************************************************************;
*  LOOP ON EACH INPUT DCODE - REASSIGN CODES TO APPROPRIATE ARRAY  *;
*  DIMENSION ACCOUNTING FOR MISSING TWO CODES (1 AND 10)           *;
********************************************************************;

DO X=1 TO 3;
IF DCODE(X) EQ . OR DCODE(X) EQ 0 THEN
GO TO BRKPS6;

IF PS EQ 0 THEN
GO TO BRKPS5;

DIM = DCODE(X) -1;

IF DIM EQ 10 THEN
DIM = 9;
ELSE IF DIM EQ 11 THEN
DIM = 10;
ELSE IF DIM EQ 91 THEN
DIM = 11;

IF NOT DIM OR DIM GT 11 THEN
DIM = 11;

FD = 0;

********************************************************************;
*     LOOP ON PK_CTR ARRAY (NUMBER OF UNIQUE PACKAGE SIZE FOR THE  *;
*     DOSAGE FORM/FDA NAME) UNTIL A MATCH IS MADE OR EXIT LOOP AND *;
*     STORE CURRENT VARIABLES IN ASSOCIATED ARRAYS                 *;
********************************************************************;

DO Y=1 TO PK_CTR(DIM);
IF PS EQ PK_PS(DIM,Y) THEN DO;
FD = 1;
FD1= 0;

PK_CT(DIM,Y,2) + CLAIMS;

********************************************************************;
*           LOOP ON CURRENT PROCESSING STRENGTHS WITHIN PACKAGE    *;
*           SIZE/DOSAGE CODE/FDA NAME                              *;
********************************************************************;

DO Z=1 TO S2_CTR(DIM,Y);
IF STR EQ S2_TP(DIM,PK_CTR(DIM),Z) THEN DO;
FD1 = 1;

S2_CT(DIM,Y,Z) + CLAIMS;
S2_PR(DIM,Y,Z) = S2_PR(DIM,Y,Z) + (CLAIMS * BBPR);
GO TO BRKPS1;
END;
END;

BRKPS1:;

********************************************************************;
*           STRENGTH FOR THE PACKAGE SIZE IS NOT PRESENT IN THE    *;
*           ARRAY - MOVE ELEMENTS INTO APPROPRIATE ARRAYS - A      *;
*           WEIGHTED AVERAGE WILL BE APPLIED TO THE AWP PRICE FOR  *;
*           THIS STRENGTH, ARRAY: S2_PR.                           *;
********************************************************************;
IF NOT FD1 AND (S2_CTR(DIM,Y) LT MAX3) THEN DO;
S2_CTR(DIM,Y) + 1;
S2_TP(DIM,Y,S2_CTR(DIM,Y))    = STR;
S2_COD(DIM,Y,S2_CTR(DIM,Y))   = DCODE(X);
S2_DOS(DIM,Y,S2_CTR(DIM,Y))   = D;
S2_CT(DIM,Y,S2_CTR(DIM,Y))    + CLAIMS;
S2_PR(DIM,Y,S2_CTR(DIM,Y))    = CLAIMS * BBPR;
END;

GO TO BRKPS2;
END;
END;

BRKPS2:;

********************************************************************;
*     PACKAGE SIZE IS NOT PRESENT IN THE ARRAY - MOVE PACKAGE SIZE *;
*     AND STRENGTH ELEMENTS INTO APPROPRIATE ARRAYS                *;
********************************************************************;

IF NOT FD AND (PK_CTR(DIM) LT MAX3) THEN DO;
PK_CTR(DIM) + 1;
PK_CT(DIM,PK_CTR(DIM),2) + CLAIMS;
PK_PS(DIM,PK_CTR(DIM)) = PS;
PK_DF(DIM,PK_CTR(DIM)) = DF;

S2_CTR(DIM,PK_CTR(DIM)) + 1;
S2_TP(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM)))    = STR;
S2_COD(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM))) = DCODE(X);
S2_DOS(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM))) = D;
S2_CT(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM))) + CLAIMS;
S2_PR(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM))) =
CLAIMS * BBPR;
END;

FD = 0;

********************************************************************;
*     PROCESS EACH THERAPEUTIC CODE FOR A PARTICULAR PACKAGE SIZE/ *;
*     STRENGTH - THE MOST NUMEROUS TEC CODE WILL LATER BE MOVED TO *;
*     ANOTHER ARRAY AND WILL BE ASSOCIATED WITH THIS PROCESSED     *;
*     STRENGTH                                                     *;
********************************************************************;

DO Y=1 TO SPT_CTR(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM)));
IF GTC EQ SP_TEC(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM)),Y)
THEN DO;
FD = 1;

SP_TEC(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM)),Y) = GTC;
SC_TEC(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM)),Y) + 1;

GO TO BRKPS3;
END;
END;

BRKPS3:;

IF NOT FD AND
(SPT_CTR(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM))) LT MAX3)
THEN DO;
SPT_CTR(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM))) + 1;
X1= DIM;
X2= PK_CTR(X1);
X3= S2_CTR(X1,X2);
X4= SPT_CTR(X1,X2,X3);
SP_TEC(X1,X2,X3,X4) = GTC;
SC_TEC(X1,X2,X3,X4) + 1;
END;

FD = 0;

********************************************************************;
*     PROCESS EACH OVER-THE-COUNTER CODE FOR A PARTICULAR PKG SIZE/*;
*     STRENGTH - THE MOST NUMEROUS OTC CODE WILL LATER BE MOVED TO *;
*     ANOTHER ARRAY AND WILL BE ASSOCIATED WITH THIS PROCESSED     *;
*     STRENGTH                                                     *;
********************************************************************;

DO Y=1 TO SPO_CTR(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM)));
IF CL EQ SP_OTC(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM)),Y)
THEN DO;
FD = 1;

SP_OTC(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM)),Y) = CL;
SC_OTC(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM)),Y) + 1;

GO TO BRKPS4;
END;
END;

BRKPS4:;

IF NOT FD AND
(SPO_CTR(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM))) LT MAX3)
THEN DO;
SPO_CTR(DIM,PK_CTR(DIM),S2_CTR(DIM,PK_CTR(DIM))) + 1;
X1= DIM;
X2= PK_CTR(X1);
X3= S2_CTR(X1,X2);
X4= SPT_CTR(X1,X2,X3);
SP_OTC(X1,X2,X3,X4) = CL;
SC_OTC(X1,X2,X3,X4) + 1;
END;

********************************************************************;
*     DETERMINE THE "RANGE" OF THE PACKAGE SIZE WITHIN THE PKG SIZE/;
*     STRENGTH - E.G. 60-480                                       *;
********************************************************************;
IF PS GT RANG(DIM,2) THEN
RANG(DIM,2) = PS;

IF PS LT RANG(DIM,1) OR RANG(DIM,1) EQ 0 THEN
RANG(DIM,1) = PS;

BRKPS5:;

END;

BRKPS6:;

********************************************************************;
*  PROCESSING THE LAST FDA NAME FOR THIS GROUP - MOVE MSIS COUNTS   ;
*  SEQUENTIALLY THROUGH THE PK_CT ARRAY - DETERMINE THE PREVALENT  *;
*  TEC AND OTC CODES - DETERMINE WEIGHT AWP (TOTAL AWP DIVIDED BY  *;
*  MSIS COUNT)                                                     *;
********************************************************************;

IF LAST.BN THEN DO;
DO X=1 TO 11;
DO Y=1 TO PK_CTR(X);
IF Y EQ 1 THEN DO;
LAST1 = PK_CT(X,Y,2);
PK_CT(X,1,1) = PK_CT(X,1,2);
END;
ELSE DO;
TEMP = PK_CT(X,Y,2) + LAST1;
PK_CT(X,Y,1) = TEMP;

LAST1 = TEMP;
END;

DO Z=1 TO S2_CTR(X,Y);
IF S2_CT(X,Y,Z) THEN
S2_PR(X,Y,Z) =
ROUND(S2_PR(X,Y,Z) / S2_CT(X,Y,Z),.00001);
ELSE
S2_PR(X,Y,Z) = 0;

IF Z EQ 1 THEN
LAST = S2_CT(X,Y,1);
ELSE DO;
TEMP = S2_CT(X,Y,Z) + LAST;
S2_CT(X,Y,Z) = TEMP;

LAST = TEMP;
END;

TEMP = 0;POZ = 1;

DO A=1 TO SPT_CTR(X,Y,Z);
IF SC_TEC(X,Y,Z,A) GT TEMP THEN DO;
TEMP = SC_TEC(X,Y,Z,A);
POZ  = Z;
END;
END;

S2_TEC(X,Y,Z) = SP_TEC(X,Y,Z,POZ);

TEMP = 0;POZ = 1;

DO A=1 TO SPO_CTR(X,Y,Z);
IF SC_OTC(X,Y,Z,A) GT TEMP THEN DO;
TEMP = SC_OTC(X,Y,Z,A);
POZ  = Z;
END;
END;

S2_OTC(X,Y,Z) = SP_OTC(X,Y,Z,POZ);
END;
END;
END;

OUTPUT;
END;

RUN;

