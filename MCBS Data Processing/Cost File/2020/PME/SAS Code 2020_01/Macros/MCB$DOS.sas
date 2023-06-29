********************************************************************;
*  PROCESS DOSAGES                                                 *;
*                                                                  *;
*  1) IF DOSAGE CODE PRESENT ON INPUT RECORD THEN DETERMINE IF THE *;
*     DOSAGE IS TRUELY PRESENT FOR THE BLUEBOOK FDA RECORD         *;
*     PREVIOUSLY MATCHED                                           *;
*                                                                  *;
*  2) OTHERWISE, RANDOMLY GENERATE A NUMBER FOR THE FREQUENCY COUNT*;
*     FOR EACH DOSAGE BY FDA NAME, AND SELECT CORRESPONDING DOSAGE *;
*     FORM CODE                                                    *;
********************************************************************;
PROC_DOS:;

IF DOS_FD THEN DO;
DOS_FD = 0;
DOS_FL = 1;

DO X=1 TO DC_CTR;
IF I_DCODE EQ DC_TP(X) THEN DO;
DOS_FD = X;
DOS_FL = 0;
DOSAGE = DC_TPD(X);

GO TO BRK_DOS;
END;
END;
END;
ELSE IF NOT DOS_FD THEN DO;
MAX = DC_CT(DC_CTR);
DOS_FL = 1;

LINK PROC_RDM;

DO X=1 TO DC_CTR;
IF RANDOM LE DC_CT(X) THEN DO;
DOS_FD = X;
DOSAGE = DC_TPD(X);
I_DCODE = DC_TP(X);

GO TO BRK_DOS;
END;
END;
END;

BRK_DOS:;

RETURN;

