********************************************************************;
*  BEGAN PROCESSING BLUEBOOK RECORDS (DOSAGE ROLL-UP RECORDS)      *;
********************************************************************;

DATA MCBSDATA.TEMP_DOS 
(KEEP=DCCT1-DCCT13 DCTP1-DCTP13 DC_CTR BN FDA_NM DCTPD1-DCTPD13);

SET MCBSDATA.NEWBLUE_ALL;
BY BN;

ARRAY DC_CT   {13}      4.   DCCT1-DCCT13;
ARRAY DC_TP   {13}      3.   DCTP1-DCTP13;
ARRAY DC_TPD  {13}    $10.   DCTPD1-DCTPD13;
ARRAY DCODE   {3}       3.   DCODE1-DCODE3;

RETAIN DCCT1-DCCT13 DCTP1-DCTP13 DC_CTR 0;
RETAIN DCTPD1-DCTPD13;

********************************************************************;
*  IF PROCESSING THE FIRST FDA NAME - INITIALIZE ROLL-UP VARIABLES *;
********************************************************************;

IF FIRST.BN THEN DO;
DC_CTR = 0;

DO X=1 TO 13;
DC_CT(X) = 0;
DC_TP(X) = 0;
DC_TPD(X) = '';
END;
END;

********************************************************************;
*  LOOP UP TO THREE TIMES (POTENTIAL NUMBER OF DOSAGE FORM CODES   *;
*  PER DOSAGE FORM).  LOAD DOSAGE ARRAYS WITH UNIQUE LIST OF DOSAGE*;
*  FORM CODES WITHIN EACH UNIQUE FDA NAME (BN IS THE SOUNDEX OF *;
*  THE MCB-SUPPLIED FDA NAME).                                     *;
*                                                                  *;
*  CLAIMS REPRESENTS THE NUMBER OF PDE RECORDS WITH THE            *;
*  SAME NDC CODES AS PRESENT ON THE BLUEBOOK FILE - THIS DETERMINES*;
*  THE PREVALENCE OF A PARTICULAR DOSAGE FORM                      *;
********************************************************************;

DO X=1 TO 3;
IF NOT DCODE(X) THEN
GOTO BRKDOS;

FD = 0;

DO Y=1 TO DC_CTR;
IF DCODE(X) EQ DC_TP(Y) THEN DO;
FD = 1;

DC_CT(Y) + CLAIMS;

GOTO BRKMAT;
END;
END;

BRKMAT:;

IF NOT FD THEN DO;
DC_CTR + 1;
DC_TP(DC_CTR)  = DCODE(X);
DC_TPD(DC_CTR) = D;
DC_CT(DC_CTR)  + CLAIMS;
END;
END;

BRKDOS:;

********************************************************************;
*  IF LAST RECORD FOR A SET OF RECORDS WITH THE SAME FDA NAME THEN *;
*  MOVE MSIS COUNTS SEQUENTIALLY THROUGH THE NUMBER OF UNIQUE      *;
*  DOSAGE FORMS (DC_CT ARRAY).  EXAMPLE: THE FIRST DIMENSION OF THE*;
*  ARRAY HAS A COUNT OF 10, THE SECOND DIMENSION OF 12 - THE FIRST *;
*  DIMENSION WILL REMAIN 10, BUT THE SECOND WILL NOW BE 22         *;
********************************************************************;

IF LAST.BN THEN DO;
LAST = DC_CT(1);

DO X=2 TO DC_CTR;
TEMP = DC_CT(X) + LAST;
DC_CT(X) = TEMP;

LAST = TEMP;
END;

OUTPUT;
END;

RUN;

