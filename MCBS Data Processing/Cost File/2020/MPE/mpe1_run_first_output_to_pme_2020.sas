DM output 'clear' continue;
DM log 'clear' continue; run;

%let yr = 20;

libname local "Y:\Share\SMAG\MCBS\MCBS Cost Supplement File\2020\Admin\Data Processing\MPE\PREL_MPE\Create xtra";

data local.prel_mpe_xtra;
  set local.prel_mpe;

    IF SOURCE IN (2,3) THEN DO;
      IF _MTYPE='OMD' THEN CLAIMTYP='D';
      ELSE CLAIMTYP='P';
    END;

    ARRAY BUCKETS {*} _TRMED _TRSURG _TRLABX _TRPM _TROM;
    IF SOURCE IN (2,3) THEN DO;
      DO I=1 TO DIM(BUCKETS); 
        IF BUCKETS{I}=. THEN BUCKETS{I}=0; 
      END;
    END;

    *FOR EVENTS WHERE MEDICAID'S A PAYER AND YPLUS HAS BEEN LOWERED FROM
     TREIM, PRO-RATE THE BUCKET AMOUNTS ACCORDINGLY;
    IF Y1 & SOURCE IN (2,3) THEN DO;
      DO I=1 TO DIM(BUCKETS);
        BUCKETS{I}=ROUND(BUCKETS{I} * (YPLUS/_TREIM),.01); 
      END;
      _BUCKADJ=1; 
    END;

    *SOMETIMES THE SUM OF THE BUCKETS IS OFF FROM YPLUS BY A FEW CENTS.
     ADJUST THESE CASES.;
    DIFFBUCK=YPLUS-SUM(_TRMED,_TRSURG,_TRLABX,_TROM,_TRPM);

    IF 0<ABS(DIFFBUCK)<=.05 THEN DO;
      DO I=1 TO DIM(BUCKETS);
        IF BUCKETS{I}>0 THEN DO;
           BUCKETS{I}=ROUND(BUCKETS{I}+DIFFBUCK,.01); 
           GO TO C; 
        END;
      END;
      C:_BUCKADJ=2;
    END;

    *IF THE DIFFERENCE BETWEEN THE BUCKETS AND YPLUS IS MORE THAN A
     NICKEL, PRO-RATE THE DIFFERENCE ACROSS THE BUCKETS.;
    IF ABS(DIFFBUCK)>.05 THEN DO;
      DO I=1 TO DIM(BUCKETS);
        IF BUCKETS{I}>0 THEN DO;
          BUCKETS{I}=ROUND(BUCKETS{I}+BUCKETS{I}/_TREIM*DIFFBUCK,.01); 
        END;
      END;
      _BUCKADJ=3;
    END;

	do i = 1 to dim(buckets);
	  buckets{i} = round(buckets{i},.01);
	end;

    rename _TRMED = PAMTMED
          _TRSURG = PAMTSURG
          _TRLABX = PAMTLABX
            _TROM = PAMTOM
            _TRPM = PAMTPM;
run;
