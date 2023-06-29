********************************************************************;
*  PROCESS "ROLL-UP" STRENGTH RECORDS                              *;
********************************************************************;


DATA MCBSDATA.TEMP_STR 
(KEEP=BN FDA_NM S1CT1-S1CT40 S1TP1-S1TP20 S1NUM1-S1NUM40 S1UNT1-S1UNT40 
      S1COD1-S1COD20 S1DOS1-S1DOS20 S1TEC1-S1TEC20 S1OTC1-S1OTC20 S1PR1-S1PR20 
      S1CTR1-S1CTR2 RANGE1 RANGE2 GTC);

SET MCBSDATA.NEWBLUE_STR;
BY BN;

ARRAY S1_CT   {2,10,2}  4.   S1CT1-S1CT40;
ARRAY S1_TP   {2,10}    $10. S1TP1-S1TP20;
ARRAY S1_NUM  {2,10,2}  4.   S1NUM1-S1NUM40;
ARRAY S1_UNT  {2,10,2}  $10. S1UNT1-S1UNT40;
ARRAY S1_COD  {2,10}    3.   S1COD1-S1COD20;
ARRAY S1_DOS  {2,10}    $10. S1DOS1-S1DOS20;
ARRAY S1_TEC  {2,10}    $3   S1TEC1-S1TEC20;
ARRAY SP_TEC  {2,10,10} $3   SPTEC1-SPTEC200;
ARRAY SC_TEC  {2,10,10} 3.   SCTEC1-SCTEC200;
ARRAY S1_OTC  {2,10}    $3   S1OTC1-S1OTC20;
ARRAY SP_OTC  {2,10,10} $3   SPOTC1-SPOTC200;
ARRAY SC_OTC  {2,10,10} 3.   SCOTC1-SCOTC200;
ARRAY S1_PR   {2,10}    4.   S1PR1-S1PR20;

ARRAY DCODE   {3}       3.   DCODE1-DCODE3;
ARRAY STRNUM  {2}       8.   SN1-SN2;
ARRAY STRUN   {2}     $10.   SU1-SU2;
ARRAY S1_CTR  {2}       3.   S1CTR1-S1CTR2;
ARRAY SPT_CTR {2,10}    3.   SPTCTR1-SPTCTR20;
ARRAY SPO_CTR {2,10}    3.   SPOCTR1-SPOCTR20;

RETAIN S1CT1-S1CT40       SCTEC1-SCTEC200  SCOTC1-SCOTC200
S1PR1-S1PR20       S1CTR1-S1CTR2    SPTCTR1-SPTCTR20
SPOCTR1-SPOCTR20   S1NUM1-S1NUM40   S1COD1-S1COD40
RANGE1 RANGE2 0;

RETAIN MAX10 10;

RETAIN S1TP1-S1TP20       SPTEC1-SPTEC200  SPOTC1-SPOTC200
S1UNT1-S1UNT40     S1DOS1-S1DOS20;

********************************************************************;
*  PROCESS ONLY TABLETS/CAPSULES (DCODE=1) AND ADHESIVES/PADS (10) *;
********************************************************************;
IF DCODE1 NE 1 AND DCODE1 NE 10 THEN DELETE;

IF FIRST.BN THEN DO;
S1CTR1 = 0;S1CTR2 = 0;
RANGE1 = 0;RANGE2 = 0;

DO X=1 TO 2;
DO Y=1 TO MAX10;
S1_TP(X,Y)  = '';
S1_PR(X,Y)  = 0;
S1_TEC(X,Y) = '';
S1_OTC(X,Y) = '';
S1_COD(X,Y) = 0;
S1_DOS(X,Y) = '';
SPT_CTR(X,Y) = 0;
SPO_CTR(X,Y) = 0;

DO Z=1 TO 2;
S1_CT(X,Y,Z) = 0;
S1_NUM(X,Y,Z) = 0;
S1_UNT(X,Y,Z) = '';
END;

DO Z=1 TO MAX10;
SP_TEC(X,Y,Z) = '';
SC_TEC(X,Y,Z) = 0;
SP_OTC(X,Y,Z) = '';
SC_OTC(X,Y,Z) = 0;
END;
END;
END;
END;

IF STR EQ '' THEN
GOTO BRKSTR4;

IF DCODE1 EQ 1 THEN
DIM = 1;
ELSE
DIM = 2;

FD = 0;

********************************************************************;
*  LOOP ON CURRENT STRENGTH COUNTER ARRAY (S1_CTR) UNTIL A MATCH IS*;
*  PERFORMED - VARIABLE "FD" WILL BE SET TO "0" IF A MATCH WAS NOT *;
*  SUCCESSFUL                                                      *;
********************************************************************;

DO Y=1 TO S1_CTR(DIM);
IF STR EQ S1_TP(DIM,Y) THEN DO;
FD = 1;

S1_CT(DIM,Y,2) + CLAIMS;
S1_PR(DIM,Y) = S1_PR(DIM,Y) + (CLAIMS * BBPR);

GOTO BRKSTR1;
END;
END;

BRKSTR1:;

********************************************************************;
*  UNSUCCESSFUL MATCH - STORE SELECTED ELEMENTS INTO STRENGTH/DOSAGE;
*  ARRAYS                                                          *;
********************************************************************;

IF NOT FD AND (S1_CTR(DIM) LT MAX10) THEN DO;
S1_CTR(DIM) + 1;
S1_TP(DIM,S1_CTR(DIM))    = STR;
S1_NUM(DIM,S1_CTR(DIM),1) = STRNUM(1);
S1_NUM(DIM,S1_CTR(DIM),2) = STRNUM(2);
S1_UNT(DIM,S1_CTR(DIM),1) = STRUN(1);
S1_UNT(DIM,S1_CTR(DIM),2) = STRUN(2);
S1_COD(DIM,S1_CTR(DIM))   = DCODE1;
S1_DOS(DIM,S1_CTR(DIM))   = D;
S1_CT(DIM,S1_CTR(DIM),2)  + CLAIMS;
S1_PR(DIM,S1_CTR(DIM))    = CLAIMS * BBPR;

END;

IF DIM EQ 2 THEN DO;
IF PS GT RANGE1 THEN
RANGE1 = PS;

IF PS LT RANGE2 OR RANGE2 EQ 0 THEN
RANGE2 = PS;
END;

FD = 0;

********************************************************************;
*  DETERMINE PREVALENT THERAPEUTIC CODE FOR EACH STRENGTH - WILL BE*;
*  MOVED INTO ANOTHER ARRAY LATER IN THE PROCESSING                *;
********************************************************************;

DO Y=1 TO SPT_CTR(DIM,S1_CTR(DIM));
IF GTC EQ SP_TEC(DIM,S1_CTR(DIM),Y) THEN DO;
FD = 1;

SP_TEC(DIM,S1_CTR(DIM),Y) = GTC;
SC_TEC(DIM,S1_CTR(DIM),Y) + 1;

GOTO BRKSTR2;
END;
END;

BRKSTR2:;

IF NOT FD AND (SPT_CTR(DIM,S1_CTR(DIM)) LT MAX10) THEN DO;
SPT_CTR(DIM,S1_CTR(DIM)) + 1;
SP_TEC(DIM,S1_CTR(DIM),SPT_CTR(DIM,S1_CTR(DIM))) = GTC;
SC_TEC(DIM,S1_CTR(DIM),SPT_CTR(DIM,S1_CTR(DIM))) + 1;
END;

FD = 0;

********************************************************************;
*  DETERMINE PREVALENT OVER-THE-COUNTER CODE FOR EACH STRENGTH     *;
********************************************************************;

DO Y=1 TO SPO_CTR(DIM,S1_CTR(DIM));
IF CL EQ SP_OTC(DIM,S1_CTR(DIM),Y) THEN DO;
FD = 1;

SP_OTC(DIM,S1_CTR(DIM),Y) = CL;
SC_OTC(DIM,S1_CTR(DIM),Y) + 1;

GOTO BRKSTR3;
END;
END;

BRKSTR3:;

IF NOT FD AND (SPO_CTR(DIM,S1_CTR(DIM)) LT MAX10) THEN DO;
SPO_CTR(DIM,S1_CTR(DIM)) + 1;
SP_OTC(DIM,S1_CTR(DIM),SPO_CTR(DIM,S1_CTR(DIM))) = CL;
SC_OTC(DIM,S1_CTR(DIM),SPO_CTR(DIM,S1_CTR(DIM))) + 1;
END;

BRKSTR4:;

********************************************************************;
*  LAST FDA NAME TO BE PROCESSED - MOVE MSIS COUNTS SEQUENTIALLY   *;
*  THROUGH S1_CT ARRAY - DETERMINE WEIGHTED AWP PRICE - DETERMINE  *;
*  PREVALENT TEC AND OTC CODES                                     *;
********************************************************************;

IF LAST.BN THEN DO;
DO X=1 TO 2;
DO Y=1 TO S1_CTR(X);
S1_PR(X,Y) = ROUND(S1_PR(X,Y) / S1_CT(X,Y,2),.00001);

IF Y EQ 1 THEN DO;
LAST = S1_CT(X,1,2);
S1_CT(X,1,1) = S1_CT(X,1,2);
END;
ELSE DO;
TEMP = S1_CT(X,Y,2) + LAST;
S1_CT(X,Y,1) = TEMP;

LAST = TEMP;
END;

TEMP = 0;POZ = 1;
DO Z=1 TO SPT_CTR(X,Y);
IF SC_TEC(X,Y,Z) GT TEMP THEN DO;
TEMP = SC_TEC(X,Y,Z);
POZ  = Z;
END;
END;

S1_TEC(X,Y) = SP_TEC(X,Y,POZ);

TEMP = 0;POZ = 1;
DO Z=1 TO SPO_CTR(X,Y);
IF SC_OTC(X,Y,Z) GT TEMP THEN DO;
TEMP = SC_OTC(X,Y,Z);
POZ  = Z;
END;
END;

S1_OTC(X,Y) = SP_OTC(X,Y,POZ);
END;
END;

OUTPUT;
END;

RUN;

