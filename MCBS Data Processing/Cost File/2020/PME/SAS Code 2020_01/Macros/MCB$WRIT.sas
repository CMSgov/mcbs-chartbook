********************************************************************;
*  OUTPUT FINAL RECORD                                             *;
********************************************************************;

RETURN;

WRITE:;

FILE FNL_DATA;

ERROR_CD = 0;

********************************************************************;
*  IF OVER-THE-COUNTER DRUG, SET VARIABLES AND OUTPUT              *;
********************************************************************;

IF OTC_CD EQ 'O' THEN DO;
TOTOTCS + 1;
CODE      = 4;
EVENT_PR  = 0;
DOSAGE    = '';
STRENGTH  = '';
AMTNUM1   = 0;
END;
ELSE DO;

********************************************************************;
*  OTHERWISE PROCESS STRENGTH AND INCREMENT COUNTER ARRAYS         *;
********************************************************************;

EP1 = -1;
C_DCODE = I_DCODE;

TOT_DCD(TOTDCODE,1) + 1;

IF STR_FL THEN
TOT_DCD(TOTDCODE,3) + 1;
ELSE IF I_DCODE EQ 1 OR I_DCODE EQ 10 THEN
STRENGTH = '';

AMTNUM1 = AMTNUM;

IF AMT_FL THEN
TOT_DCD(TOTDCODE,4) + 1;
ELSE
AMTNUM1 = 0;

********************************************************************;
*  IF DOSAGE WAS GENERATED (DOS_FL=1), THEN DETERMINE DESCRIPTIONS *;
********************************************************************;

IF DOS_FL THEN DO;
TOT_DCD(TOTDCODE,2) + 1;

IF      C_DCODE EQ 1  THEN DOSAGE = 'PILLS';
ELSE IF C_DCODE EQ 2  THEN DOSAGE = 'LIQUIDS';
ELSE IF C_DCODE EQ 3  THEN DOSAGE = 'DROPS';
ELSE IF C_DCODE EQ 4  THEN DOSAGE = 'CREAM';
ELSE IF C_DCODE EQ 5  THEN DOSAGE = 'SUPPOS.';
ELSE IF C_DCODE EQ 6  THEN DOSAGE = 'AEROSOL';
ELSE IF C_DCODE EQ 7  THEN DOSAGE = 'SHAMPOO';
ELSE IF C_DCODE EQ 8  THEN DOSAGE = 'INJECTABLE';
ELSE IF C_DCODE EQ 9  THEN DOSAGE = 'INJECTABLE';
ELSE IF C_DCODE EQ 10 THEN DOSAGE = 'PATCHES';
ELSE IF C_DCODE EQ 11 THEN DOSAGE = 'JELLIES';
ELSE IF C_DCODE EQ 12 THEN DOSAGE = 'POWDER';
ELSE IF C_DCODE EQ 91 THEN DOSAGE = 'OTHERS';

IF C_DCODE NE 91 THEN
TOT_CV(TOTDCODE,C_DCODE) + 1;
ELSE
TOT_CV(TOTDCODE,13) + 1;
END;
ELSE
DOSAGE = '';

********************************************************************;
*  DETERMINE "EVENT PRICE" USING VARIOUS INPUT FIELDS              *;
********************************************************************;



IF C_DCODE EQ 1 THEN 
DO;
    IF I_TABN GT 0 AND I_TABN LT 999 THEN EP1 = I_TABN * AWP;
    ELSE IF I_TABN EQ -8 THEN 
    DO;
        IF I_TABSDA GT 0 AND I_TABSDA LT 13 THEN 
        DO;
            IF      I_TAKUNT EQ 1 THEN EP1 = I_TABSDA * I_TAKN * AWP;
            ELSE IF I_TAKUNT EQ 2 THEN EP1 = I_TABSDA * I_TAKN * 7 * AWP;
        END;
        ELSE IF I_TABSDA EQ 91 THEN 
        DO;
            IF      I_TAKUNT EQ 1 THEN EP1 = 0.5 * I_TAKN * AWP;
            ELSE IF I_TAKUNT EQ 2 THEN EP1 = 0.5 * I_TAKN * 7 * AWP;
        END;
        ELSE IF I_TABSDA EQ 96 THEN 
        DO;
            IF I_TABTAK GT 0 AND I_TABTAK LT 31 THEN 
            DO;
                IF      I_TAKUNT EQ 1 THEN EP1 = I_TABTAK * I_TAKN * AWP;
                ELSE IF I_TAKUNT EQ 2 THEN EP1 = I_TABTAK * 7 * I_TAKN * AWP;
            END;
            ELSE IF I_TABTAK EQ -8 THEN 
            DO;
                IF      I_TAKUNT EQ 1 THEN EP1 = I_TAKN * AWP;
                ELSE IF I_TAKUNT EQ 2 THEN EP1 = 7 * I_TAKN * AWP;
            END;
        END;
    END;
END;

ELSE IF C_DCODE EQ 10 THEN 
DO;
    IF I_TABN GE RANGE1 AND I_TABN LE RANGE2 THEN EP1 = I_TABN * AWP;
    ELSE ERROR_CD = 1;
END;
ELSE IF C_DCODE EQ 5 THEN 
DO;
    IF I_SUPN GE RANG(4,1) AND I_SUPN LE RANG(4,2) THEN EP1 = I_SUPN * AWP;
    ELSE ERROR_CD = 1;
END;

ELSE 
DO;
    IDX = AMT_FD;
    IF AMTNUM GT 0 THEN 
    DO;
        IF C_DCODE EQ 2 THEN 
        DO;
            IF AMTNUM GE 5 AND AMTNUM LE RANG(IDX,2) THEN EP1 = AMTNUM * AWP;
            ELSE ERROR_CD = 1;
        END;
        ELSE IF C_DCODE EQ 8 OR C_DCODE EQ 9 THEN 
        DO;
            IF AMTNUM GT 0 AND AMTNUM LE RANG(IDX,2) THEN EP1 = AMTNUM * AWP;
            ELSE ERROR_CD = 1;
        END;
        ELSE IF C_DCODE EQ 3 THEN 
        DO;
            IF AMTNUM GT 0 AND AMTNUM LE RANG(IDX,2) THEN EP1 = AMTNUM * AWP;
            ELSE ERROR_CD = 1;
        END;
        ELSE IF C_DCODE IN(4,6,11) THEN 
        DO;
            IF AMTNUM GE RANG(IDX,1) AND AMTNUM LE RANG(IDX,2) THEN EP1 = AMTNUM * AWP;
            ELSE ERROR_CD = 2;
        END;
        ELSE 
        DO;
            IF AMTNUM GE RANG(IDX,1) AND AMTNUM LE RANG(IDX,2) THEN EP1 = AMTNUM * AWP;
            ELSE ERROR_CD = 1;
        END;
    END;
END;

********************************************************************;
*  IF "EVENT PRICE" WAS NOT SET, THEN SET ERROR FLAG AND OUTPUT REC*;
********************************************************************;
IF EP1 NE -1 THEN
EVENT_PR = ROUND(EP1,.00001);
ELSE DO;
EVENT_PR = 0;

IF NOT ERROR_CD THEN
ERROR_CD = 2;
END;

IF ERROR_CD THEN
TOT_DCD(15,ERROR_CD) + 1;

CODE = ERROR_CD;
END;



PUT @1 I_RECORD    $CHAR156.
    @161 DOSAGE    $CHAR10.  /*MM add 40*/
    @171 STRENGTH  $CHAR10. @;

IF AMT_FL AND OTC_CD NE 'O' THEN
PUT @181 AMTNUM1   10.3 @;

PUT  @191 TEC_CD   $CHAR3.   
     @194 OTC_CD   $CHAR1.  
     @195 AWP      12.5 @;

IF OTC_CD NE 'O' AND CODE EQ 0 THEN
PUT @207 EVENT_PR  12.5 @;
PUT @219 CODE      1.;

RETURN;


********************************************************************;
*  OUTPUT STATS RECORD - PROCESSING COUNTS                         *;
********************************************************************;
STATS:;

FILE OUTSTATS;

PUT _PAGE_;

PUT '                    **************************' /
'                    *                        *' /
'                    *    T  O  T  A  L  S    *' /
'                    *                        *' /
'                    **************************' ///;

PUT
' DOS.       TOTAL    |  IMP.  DOSAGE | IMP. STRENGTH |  IMP.  AMTNUM' /
' CDE.   COUNT   PER% |  COUNT   PER% |  COUNT   PER% |  COUNT   PER%' /
' ---- ------- ------ | ------  ----- | ------  ----- | ------  -----';

DO X=1 TO 14;
TOTPROC + TOT_DCD(X,1);
END;

DO X=1 TO 14;
TEMP1 = ROUND((TOT_DCD(X,1) / TOTPROC) * 100.00,.01);
TEMP2 = 0;TEMP3 = 0;TEMP4 = 0;

IF TOT_DCD(X,1) THEN DO;
TEMP2 = ROUND((TOT_DCD(X,2) / TOT_DCD(X,1)) * 100.00,.01);
TEMP3 = ROUND((TOT_DCD(X,3) / TOT_DCD(X,1)) * 100.00,.01);
TEMP4 = ROUND((TOT_DCD(X,4) / TOT_DCD(X,1)) * 100.00,.01);
END;

TOTINP1 + TOT_DCD(X,2);
TOTINP2 + TOT_DCD(X,3);
TOTINP3 + TOT_DCD(X,4);

IF X LT 13 THEN
PUT @3 X Z3. @;
ELSE IF X EQ 13 THEN
PUT @3 '91' @;
ELSE
PUT @2 'UNK' @;

PUT  @7 TOT_DCD(X,1) COMMA7.  @15 TEMP1 6.2  @22 '|'
@24 TOT_DCD(X,2) COMMA6.  @32 TEMP2 5.2  @38 '|'
@40 TOT_DCD(X,3) COMMA6.  @48 TEMP3 5.2  @54 '|'
@56 TOT_DCD(X,4) COMMA6.  @64 TEMP4 5.2;

PUT @22 '|' @38 '|' @54 '|';
END;

TEMP1 = ROUND((TOTINP1 / TOTPROC) * 100.00,.01);
TEMP2 = ROUND((TOTINP2 / TOTPROC) * 100.00,.01);
TEMP3 = ROUND((TOTINP3 / TOTPROC) * 100.00,.01);

PUT    ' TOT:'          @8 TOTPROC COMMA7. @16 '100.00' @22 '|'
@24 TOTINP1 COMMA6. @32 TEMP1    5.2    @38 '|'
@40 TOTINP2 COMMA6. @48 TEMP2    5.2    @54 '|'
@56 TOTINP3 COMMA6. @64 TEMP3    5.2 ///;

TEMP1 = TOT_DCD(15,1) + TOT_DCD(15,2);
TEMP2 = ROUND((TEMP1 / TOTPROC) * 100.00,.01);
TEMP3 = ROUND((TOTBAD / TOTPROC) * 100.00,.01);
TEMP4 = ROUND((TOTOTCS / TOTPROC) * 100.00,.01);
PUT ' TOTAL NUMBER OF RECORDS WHICH FELL OUTSIDE PRICE RANGE:     '
TOT_DCD(15,1) COMMA7. /
' RECORDS WITHOUT AN EVENT PRICE:                             '
TOT_DCD(15,2) COMMA7. /
'                                                             '
'-------' /
' TOTAL NUMBER OF RECORDS WITHOUT AN EVENT PRICE:             '
TEMP1 COMMA7. '     ' TEMP2 7.2 //
' TOTAL NUMBER OF RECORDS WITH A BAD FDANAME:                 '
TOTBAD COMMA7. '     ' TEMP3 7.2 /
' TOTAL NUMBER OF OTC RECORDS DROPPED FROM PROCESSING:        '
TOTOTCS COMMA7. '     ' TEMP4 7.2 /;

TOTPROC = TOTPROC + TOTBAD + TOTOTCS;

PUT ' TOTAL NUMBER OF RECORDS PROCESSED:                          '
TOTPROC COMMA7. ////;
PUT '            ***************************************           ' /
'            *                                     *           ' /
'            *   CONVERSION OF DOSAGE FORM CODES   *           ' /
'            *                                     *           ' /
'            ***************************************           ' ///;
PUT
'    |   1 |   2 |  3 |  4 |  5 |  6 |  7 |  8 |  9 | 10 | 11 |'
' 12 | 91 |' /
'----|-----|-----|----|----|----|----|----|----|----|----|----|'
'----|----|';

DO X=1 TO 14;
IF X EQ 13 THEN
PUT ' 91 ' @;
ELSE IF X EQ 14 THEN
PUT 'UNK ' @;
ELSE IF X LT 10 THEN
PUT '  ' X @;
ELSE
PUT ' ' X @;

PUT '|' TOT_CV(X,1)  5.
'|' TOT_CV(X,2)  5.
'|' TOT_CV(X,3)  4.
'|' TOT_CV(X,4)  4.
'|' TOT_CV(X,5)  4.
'|' TOT_CV(X,6)  4.
'|' TOT_CV(X,7)  4.
'|' TOT_CV(X,8)  4.
'|' TOT_CV(X,9)  4.
'|' TOT_CV(X,10) 4.
'|' TOT_CV(X,11) 4.
'|' TOT_CV(X,12) 4.
'|' TOT_CV(X,13) 4. '|';

END;

RETURN;

