*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
|      PROGRAM: 04_BB1_MCBMERGE                                                         |
|      UPDATED: 01/21/2011                                                              |
|  INPUT FILES: FDB "Bluebook" file, PDE data NDC weights file                          |
| OUTPUT FILES: MERGED_ALL_&CURRYEAR (Modified FDB file with weights)                   |
|  DESCRIPTION: Merges the FDB "Bluebook" file with the PDE claim weights and modifies  |
|               codes for the event pricing process.                                    |
|                                                                                       |
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
ODS HTML CLOSE;
  ODS HTML;

OPTION MLOGIC MPRINT SYMBOLGEN COMPRESS=YES;

%let CurrYear  =20;
%let LastYear  =19;
%let fdbdate   =20210310_wac;         * This is the FDB/NDDF file date;


%let location= C:\Users\S1C3\RIC PME\MCBS\20&CURRYEAR.\PME\Data\;
libname MCBSDATA "&location";


******************************************************************;
* READ BLUEBOOK DATA                                             *;
******************************************************************;

DATA BLUEBOOK;
set mcbsdata.fdb_&fdbdate
(KEEP=NDC BBPR CL FORM DF BN GNN FDA_NM PS STR GTC STRNUM STRUN50);
RENAME FORM=D
     STRNUM=STRENG
    STRUN50=STRUN;
IF GTC='71' AND INDEX(UPCASE(GNN),'INSULIN')>0 THEN CL="I";
run;

 
******************************************************************;
* MERGE PDE FREQUENCIES WITH BLUEBOOK RECORDS                    *;
******************************************************************;

***Get PDE weights;
PROC SQL;
CREATE TABLE COMBINE AS SELECT
A.*,
B.CLAIMS
FROM BLUEBOOK A LEFT JOIN MCBSDATA.PDE_NDC_COUNTS_&CURRYEAR B
ON A.NDC=B.NDC;
QUIT;

DATA combine;
SET COMBINE;
IF CLAIMS=. THEN CLAIMS=1;
RUN;

******************************************************************;
* OUTPUT COMBINED DATA                                           *;
******************************************************************;
DATA MCBSDATA.MERGED_ALL_&CURRYEAR;
 
SET COMBINE;
BY NDC;

FORMAT DCODE1  2.  DCODE2 2.  DCODE3 2. DOS $3.;
FORMAT CHAR $1. TEMPVAR $10. TEMPSTR $10.;
 
DROP DOS;
 
ARRAY STR_NUM {2} 4.   SN1-SN2;
ARRAY STR_UN  {2} $10. SU1-SU2;
 
DOS = D;
DCODE2 = 0;
DCODE3 = 0;
 
******************************************************************;
* MCB-SUPPLIED DOSAGE FORM CODES ASSOCIATED WITH BLUEBOOK DOSAGE *;
* FORM DESCRIPTIONS                                              *;
******************************************************************;
 
IF DOS IN('CAP','TAB','LOZ','PEL','PIL') OR D EQ 'SPRINKLE' THEN 
 DO;
   DCODE1 = 1;
   IF DOS EQ 'PEL' OR DOS EQ 'DOS PART' THEN DCODE2 = 12;
 END;
ELSE IF DOS IN('SOL','MOU','SUS','EMU','FL ','ORA','DOU','ELI','ENE')
     OR DOS IN('EXP','IRR','TIN') OR D EQ 'LIQUID' OR D EQ 'SYRUP' THEN 
 DO;
   DCODE1 = 2;
   IF DOS EQ 'SOL' OR DOS EQ 'FL ' THEN DCODE2 = 11;
   ELSE IF DOS EQ 'SUS'            THEN DCODE2 = 4;
   ELSE IF DOS EQ 'IRR'            THEN DCODE2 = 3;
 END;
ELSE IF DOS EQ 'AMP' OR DOS EQ 'CAR' THEN 
  DO;
    DCODE1 = 8;DCODE2 = 9;DCODE3 = 2;
  END;
ELSE IF D EQ 'DROPS' THEN 
  DO;
    DCODE1 = 3;DCODE2 = 2;
  END;
ELSE IF D EQ 'VIAL-NEB' THEN 
  DO;
    DCODE1 = 2;DCODE2 = 8;DCODE2 = 9;
  END;
ELSE IF DOS IN('CRE','LUB','PAS','OIN','LOT','OIL') THEN 
  DO;
     DCODE1 = 4;DCODE2 = 11;
  END;
ELSE IF DOS IN('AER','FOA','SPR','GAS','INH','SPI') OR D EQ 'MIST' THEN 
  DO;
    DCODE1 = 6;
    IF D EQ 'AER POWDER' OR D EQ 'AERO POWD' THEN DCODE2 = 12;
    ELSE IF DOS EQ 'SPI'                     THEN DCODE2 = 91;
  END;
ELSE IF DOS EQ 'SUP' OR DOS EQ 'INS' THEN DCODE1 = 5;
ELSE IF DOS IN('BAR','CAK','SHA') OR INDEX(D,'SOAP') THEN 
  DO;
    DCODE1 = 7; 
    IF DOS EQ 'BAR' THEN 
       DO; 
         DCODE2 = 91;
         DCODE3 = 11;
       END;
    ELSE IF DOS EQ 'CAK'     THEN DCODE2 = 91;
    ELSE IF D EQ 'LIQ. SOAP' THEN DCODE2 = 2;
  END;
ELSE IF DOS IN('VIA','SKI','PLA','ADD','SYR','CRW','NEE') 
     OR D IN('IV SET','DISP SYRIN','DIS NEEDLE') THEN 
  DO;
    DCODE1 = 8;
    DCODE2 = 9;
    IF DOS EQ 'SKI' THEN DCODE3 = 91;
    ELSE IF DOS EQ 'VIA' OR DOS EQ 'PLA' OR INDEX(D,'SYR') THEN DCODE3 = 2;
  END;
ELSE IF DOS IN('INF','ALL','PIG') 
     OR D   IN('IV SOLN.','IP SOLN.','IP SET','IV ACCESS') THEN 
   DO;
     DCODE1 = 9;
     IF D EQ 'IP SOLN.' THEN 
        DO;
           DCODE2 = 8;
           DCODE3 = 2;
        END;
     ELSE IF DOS EQ 'PIG' OR D EQ 'IV SOLN.' THEN 
        DO;
           DCODE2 = 2;
           DCODE3 = 8;
        END;
     ELSE IF DOS EQ 'ALL' THEN DCODE2 = 8;
     ELSE IF DOS EQ 'INF' THEN DCODE2 = 2;
   END;
ELSE IF DOS EQ 'TAM' THEN DCODE1 = 91;
ELSE IF DOS IN('ADH','PAD') OR D EQ 'MED. PAD' OR D EQ 'DISK' THEN DCODE1 = 10;
ELSE IF DOS IN('STI','JEL','GEL','LIN') THEN 
  DO;
    DCODE1 = 11;
    DCODE2 = 4;
  END;
ELSE IF DOS IN('POW','CRY') 
     OR D IN('DROPS SUSP','GRAN. EFF.','GRANULES','TOOTH POWD.') THEN 
  DO;
     DCODE1 = 12;
     IF DOS EQ 'CRY' OR DOS EQ 'TOO' THEN DCODE2 = 91;
     ELSE IF D EQ 'GRAN. EFF.' OR D EQ 'GRANULES' THEN DCODE2 = 2;
  END;
ELSE DCODE1 = 91;
 
STR_NUM(1) = STRENG;
STR_NUM(2) = 0;
STR_UN(1)  = STRUN;
STR_UN(2)  = '';
 
******************************************************************;
* SPLIT MULTIPLE STRENGTHS INTO TWO FIELDS                       *;
******************************************************************;
 
IF INDEX(STR,'-') OR INDEX(STR,'/') THEN 
  DO;
    IDX = INDEX(STR,'-');
    IF NOT IDX THEN IDX = INDEX(STR,'/');
      DO J=1 TO 2;
         TEMPVAR = '';
         IF J EQ 1 THEN TEMPSTR = SUBSTR(STR,1,IDX-1);
         ELSE TEMPSTR = SUBSTR(STR,IDX+1);
         LEN = LENGTH(TEMPSTR);
            DO K=1 TO LEN;
               CHAR = SUBSTR(TEMPSTR,K,1);
               IF NOT VERIFY(CHAR,'1234567890.') THEN TEMPVAR = TRIM(TEMPVAR) || CHAR;
               ELSE 
                 DO;
                    STR_UN(J)  = SUBSTR(TEMPSTR,K);
                    GOTO BREAK;
                 END;
            END;
         BREAK:;
         STR_NUM(J) = TEMPVAR;
      END;
    IF STR_UN(1) EQ '' THEN STR_UN(1) = STR_UN(2);
    IF (STR_UN(2) NE '' AND (STR_NUM(2) EQ 0 OR STR_NUM(2) EQ .)) THEN STR_NUM(2) = STR_NUM(1);
  END;
 
*IF (DCODE1 EQ 1 OR DCODE1 EQ 10) AND STR EQ '' THEN DELETE;
*ELSE IF PS EQ 0 THEN DELETE;
 
RUN;

